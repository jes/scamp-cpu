# Filesystem routines

include "data.sl";
include "util.sl";

var fs_read = func(fd, buf, sz) {
    var fdbase = fdbaseptr(fd);
    var readsz = 0;
    var blknum = *(fdbase+FDDATA);
    var seekpos = *(fdbase+FDDATA+1);
    var startat;
    var remain;
    var read;

    while (sz) {
        # read the current block of the file
        blkread(blknum);

        # 254 words per block, so the position within the block contents is seekpos%254
        #   startat = seekpos % 254;
        # TODO: [nice] abstract out this divmod into some other function?
        # TODO: [perf] abolish seek/tell, and have "seekpos" always be the
        #       position within the current block, instead of within the file
        divmod(seekpos, BLKSZ-2, 0, &startat);

        # blklen() is counted in bytes, so the number of words remaining is:
        #   ceil(blklen/2) - startat
        remain = half(blklen()+1) - startat;
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
        # "startat+2" skips over the block header
        memcpy(buf+readsz, BLKBUF+startat+2, read);

        readsz = readsz + read;
        sz = sz - read;
        seekpos = seekpos + read;
    };

    *(fdbase+FDDATA) = blknum;
    *(fdbase+FDDATA+1) = seekpos;

    return readsz;
};

var fs_write = func(fd, buf, sz) {
    var fdbase = fdbaseptr(fd);
    var writesz = 0;
    var blknum = *(fdbase+FDDATA);
    var seekpos = *(fdbase+FDDATA+1);
    var nextblknum;
    var startat;
    var remain;
    var write;

    while (sz) {
        # read the current block of the file
        # TODO: [perf] we can skip this if we know we're writing at the end of the
        # file and startat==0, because we don't need length, next pointer, or
        # block contents.
        blkread(blknum);

        # 254 words per block, so the position within the block contents is seekpos%254
        #   startat = seekpos % 254;
        divmod(seekpos, BLKSZ-2, 0, &startat);

        # how much space remains in this block?
        remain = (BLKSZ-2)-startat;

        # how much can we write into this block?
        if (sz < remain) write = sz
        else             write = remain;

        # do we need to update the block length?
        if (shl(startat+write,1) > blklen()) blksetlen(shl(startat+write,1));

        # do we need to move to the next block?
        if (startat+write == BLKSZ-2) {
            # use the "nextfreeblk" if we need a free block
            if (!blknext()) blksetnext(nextfreeblk);
            nextblknum = blknext();
        };

        # copy data to block
        memcpy(BLKBUF+startat+2, buf+writesz, write);

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
        seekpos = seekpos + write;

        # move to the next block
        if (startat+write == BLKSZ-2) blknum = nextblknum;
    };

    *(fdbase+FDDATA) = blknum;
    *(fdbase+FDDATA+1) = seekpos;

    return writesz;
};

var fs_tell = func(fd) return *(fdbaseptr(fd)+FDDATA+1);
var fs_seek = func() unimpl("fs_seek");

# we don't need to do anything to close the file
var fs_close = func(fd);

# truncate the given fd at the current seek position
var fs_trunc = func(fd) {
    var fdbase = fdbaseptr(fd);
    var blknum = *(fdbase+FDDATA);
    var seekpos = *(fdbase+FDDATA+1);
    var startat;

    # 254 words per block, so the position within the block contents is seekpos%254
    #   startat = seekpos % 254;
    divmod(seekpos, BLKSZ-2, 0, &startat);
    blktrunc(blknum, startat);
};
