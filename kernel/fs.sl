# Filesystem routines

include "data.sl";
include "util.sl";
include "sys.sl";

var fs_sync;

var fs_read = func(fd, buf, sz) {
    var fdbase = fdbaseptr(fd);
    var readsz = 0;
    var blknum = *(fdbase+FDDATA);
    var posinblk = *(fdbase+FDDATA+1);
    var blkbuf = *(fdbase+FDDATA+2);
    var remain;
    var read;
    var direct;

    # return number of chars left in this block?
    if (sz == 0) {
        blkread(blknum, blkbuf);
        return blklen(blkbuf) - posinblk;
    };

    if (!blkbuf) blkbuf = BLKBUF;

    while (sz) {
        # can we read this block directly into the user buffer?
        direct = (sz ge 254) && (posinblk == 0);

        # read the current block of the file
        if (direct) {
            cf_blkread(blknum, blkbuf, buf+readsz);
            blkbuf[256] = 0; # invalidate the cached contents of blkbuf
        } else {
            blkread(blknum, blkbuf);
        };

        remain = blklen(blkbuf) - posinblk;

        if (remain == 0) break # EOF
        else if (sz lt remain) read = sz
        else                   read = remain;

        # copy data to user buffer if we didn't read it there directly
        # "posinblk+2" skips over the block header
        if (!direct) memcpy(buf+readsz, blkbuf+posinblk+2, read);

        readsz = readsz + read;
        sz = sz - read;
        posinblk = posinblk + read;
        if (posinblk == BLKSZ-2 && blknext(blkbuf)) {
            blknum = blknext(blkbuf);
            posinblk = 0;
        };
    };

    *(fdbase+FDDATA) = blknum;
    *(fdbase+FDDATA+1) = posinblk;

    return readsz;
};

var fs_write = func(fd, buf, sz) {
    var fdbase = fdbaseptr(fd);
    var writesz = 0;
    var blknum = *(fdbase+FDDATA);
    var posinblk = *(fdbase+FDDATA+1);
    var blkbuf = *(fdbase+FDDATA+2);
    var nextblknum = 0;
    var remain;
    var write;
    var isnewblock = 0;
    var direct;

    if (!blkbuf) blkbuf = BLKBUF;

    while (sz) {
        # can we write this block directly from the user buffer?
        direct = (sz ge 254) && (posinblk == 0);

        # read the current block of the file
        if (!isnewblock) {
            if (direct) {
                if (blkbuf[256] != blknum) {
                    cf_blkread_head(blknum, blkbuf); # read header only
                    blkbuf[256] = 0; # invalidate cached contents
                };
            } else {
                blkread(blknum, blkbuf);
            };
        };

        # how much space remains in this block?
        remain = (BLKSZ-2)-posinblk;

        # how much can we write into this block?
        if (sz lt remain) write = sz
        else              write = remain;

        # do we need to update the block length?
        if (posinblk+write gt blklen(blkbuf)) blksetlen(posinblk+write, blkbuf);

        # do we need to move to the next block?
        if (posinblk+write == BLKSZ-2) {
            # use the "nextfreeblk" if we need a free block
            if (!blknext(blkbuf)) blksetnext(nextfreeblk, blkbuf);
            nextblknum = blknext(blkbuf);
        };

        if (direct) {
            # write straight from user buffer
            cf_blkwrite(blknum, blkbuf, buf+writesz);
            blkbuf[256] = 0; # buffer no longer contains true contents of block on disk
        } else {
            # copy data to block
            memcpy(blkbuf+posinblk+2, buf+writesz, write);

            # write block to disk immediately if we're using the shared buffer
            if (blkbuf == BLKBUF) blkwrite(blknum, blkbuf);
        };

        if (sz gt write && nextblknum == blknum) kpanic("write: nextblknum == blknum");

        writesz = writesz + write;
        sz = sz - write;
        posinblk = posinblk + write;

        # if we filled this block, sync it to disk
        if (posinblk == BLKSZ-2) {
            fs_sync(fd);
            blknum = nextblknum;
            *(fdbase+FDDATA) = blknum;
            posinblk = 0;
        };

        # if we allocated a new block, initialise its header and refresh "nextfreeblk"
        # note: this is subtly different to "if we filled this block", because we might not
        # always be writing at the end of the file, even if we reach the end of a block
        if (nextblknum == nextfreeblk) {
            blksetused(nextblknum, 1); # side-effect: finds a new "nextfreeblk"

            if (nextblknum == nextfreeblk) kpanic("write: nextfreeblk is not free");

            blksettype(TYPE_FILE, blkbuf);
            blksetlen(0, blkbuf);
            blksetnext(0, blkbuf);
            blkbuf[256] = nextblknum;

            # write block to disk if we won't immediately write it on the next
            # loop iteration
            if (sz == 0) blkwrite(nextblknum, blkbuf);

            isnewblock = 1;
        } else {
            isnewblock = 0;
        };
    };

    *(fdbase+FDDATA) = blknum;
    *(fdbase+FDDATA+1) = posinblk;

    return writesz;
};

fs_sync = func(fd) {
    var fdbase = fdbaseptr(fd);
    var writefunc = *(fdbase+WRITEFD);
    var blknum = *(fdbase+FDDATA);
    var blkbuf = *(fdbase+FDDATA+2);

    if (writefunc && blkbuf && blkbuf[256] != 0) blkwrite(blknum, blkbuf);
};

var fs_close = func(fd) {
    fs_sync(fd);
};

# truncate the given fd at the current position
var fs_trunc = func(fd) {
    var fdbase = fdbaseptr(fd);
    var blknum = *(fdbase+FDDATA);
    var posinblk = *(fdbase+FDDATA+1);

    blktrunc(blknum, posinblk);
};
