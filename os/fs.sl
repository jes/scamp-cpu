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

    if (!blkbuf) blkbuf = BLKBUF;

    while (sz) {
        # read the current block of the file
        blkread(blknum, blkbuf);

        # blklen() is counted in bytes, so the number of words remaining is:
        #   ceil(blklen/2) - posinblk
        remain = half(blklen(blkbuf)+1) - posinblk;
        if (remain == 0) {
            break; # EOF
        } else if (remain <= sz) {
            # consume the entire block
            read = remain;
            if (blknext(blkbuf)) blknum = blknext(blkbuf);
        } else {
            # don't consume the entire block
            read = sz;
        };

        # copy data to user buffer
        # "posinblk+2" skips over the block header
        memcpy(buf+readsz, blkbuf+posinblk+2, read);

        readsz = readsz + read;
        sz = sz - read;
        posinblk = posinblk + read;
        if (posinblk == BLKSZ-2) posinblk = 0;
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
    var nextblknum;
    var remain;
    var write;

    if (!blkbuf) blkbuf = BLKBUF;

    while (sz) {
        # read the current block of the file
        # TODO: [perf] we can skip this if we know we're writing at the end of the
        # file and posinblk==0, because we don't need length, next pointer, or
        # block contents.
        blkread(blknum, blkbuf);

        # how much space remains in this block?
        remain = (BLKSZ-2)-posinblk;

        # how much can we write into this block?
        if (sz < remain) write = sz
        else             write = remain;

        # do we need to update the block length?
        if (shl(posinblk+write,1) > blklen(blkbuf)) blksetlen(shl(posinblk+write,1), blkbuf);

        # do we need to move to the next block?
        if (posinblk+write == BLKSZ-2) {
            # use the "nextfreeblk" if we need a free block
            if (!blknext(blkbuf)) blksetnext(nextfreeblk, blkbuf);
            nextblknum = blknext(blkbuf);
        };

        # copy data to block
        memcpy(blkbuf+posinblk+2, buf+writesz, write);

        # write block to disk
        if (blkbuf == BLKBUF) blkwrite(blknum, blkbuf);

        if (sz > write && nextblknum == blknum) kpanic("write: nextblknum == blknum");

        # if we allocated a new block, initialise its header and refresh "nextfreeblk"
        if (nextblknum == nextfreeblk) {
            blksetused(nextblknum, 1);
            blkfindfree();

            blksettype(TYPE_FILE, 0);
            blksetlen(0, 0);
            blksetnext(0, 0);
            blkwrite(nextblknum, 0);
        };

        writesz = writesz + write;
        sz = sz - write;
        posinblk = posinblk + write;

        # move to the next block
        if (posinblk == BLKSZ-2) {
            fs_sync(fd);
            blknum = nextblknum;
            *(fdbase+FDDATA) = blknum;
            posinblk = 0;
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

    if (writefunc && blkbuf) blkwrite(blknum, blkbuf);
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
