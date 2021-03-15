# Filesystem routines

include "data.sl";
include "util.sl";

var fs_read = func(fd, buf, sz) {
    var fdbase = fdbaseptr(fd);
    var readsz = 0;
    var blknum = *(fdbase+FDDATA);
    var posinblk = *(fdbase+FDDATA+1);
    var remain;
    var read;

    while (sz) {
        # read the current block of the file
        blkread(blknum);

        # blklen() is counted in bytes, so the number of words remaining is:
        #   ceil(blklen/2) - posinblk
        remain = half(blklen()+1) - posinblk;
        if (remain == 0) {
            break; # EOF
        } else if (remain <= sz) {
            # consume the entire block
            read = remain;
            if (blknext()) blknum = blknext();
        } else {
            # don't consume the entire block
            read = sz;
        };

        # copy data to user buffer
        # "posinblk+2" skips over the block header
        memcpy(buf+readsz, BLKBUF+posinblk+2, read);

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
    var nextblknum;
    var remain;
    var write;

    while (sz) {
        # read the current block of the file
        # TODO: [perf] we can skip this if we know we're writing at the end of the
        # file and posinblk==0, because we don't need length, next pointer, or
        # block contents.
        blkread(blknum);

        # how much space remains in this block?
        remain = (BLKSZ-2)-posinblk;

        # how much can we write into this block?
        if (sz < remain) write = sz
        else             write = remain;

        # do we need to update the block length?
        if (shl(posinblk+write,1) > blklen()) blksetlen(shl(posinblk+write,1));

        # do we need to move to the next block?
        if (posinblk+write == BLKSZ-2) {
            # use the "nextfreeblk" if we need a free block
            if (!blknext()) blksetnext(nextfreeblk);
            nextblknum = blknext();
        };

        # copy data to block
        memcpy(BLKBUF+posinblk+2, buf+writesz, write);

        # write block to disk
        blkwrite(blknum);

        if (sz > write && nextblknum == blknum) kpanic("write: nextblknum == blknum");

        # if we allocated a new block, initialise its header and refresh "nextfreeblk"
        if (nextblknum == nextfreeblk) {
            blksetused(nextblknum, 1);
            blkfindfree();

            blksettype(TYPE_FILE);
            blksetlen(0);
            blksetnext(0);
            blkwrite(nextblknum);
        };

        writesz = writesz + write;
        sz = sz - write;
        posinblk = posinblk + write;

        # move to the next block
        if (posinblk == BLKSZ-2) {
            blknum = nextblknum;
            posinblk = 0;
        };
    };

    *(fdbase+FDDATA) = blknum;
    *(fdbase+FDDATA+1) = posinblk;

    return writesz;
};

# we don't need to do anything to close the file
var fs_close = func(fd);

# truncate the given fd at the current position
var fs_trunc = func(fd) {
    var fdbase = fdbaseptr(fd);
    var blknum = *(fdbase+FDDATA);
    var posinblk = *(fdbase+FDDATA+1);

    blktrunc(blknum, posinblk);
};
