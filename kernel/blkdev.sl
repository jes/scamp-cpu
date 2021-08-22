# SCAMP block device handling
#
# Probably currently only supports 1 device. If we ever have multiple block
# devices we'll probably want the buffer to remember which device it came
# from to avoid confusing and annoying bugs. Or maybe a separate buffer for
# each device?

include "cf.sl";

# read the given block number into the BLKBUF
var blkread = func(num, buf) {
    if (!buf) buf = BLKBUF;

    if (buf[256] == num) return 0;

    *(buf+256) = num;

    return cf_blkread(num, buf);
};

# write the BLKBUF to the given block number
var blkwrite = func(num, buf) {
    if (!buf) buf = BLKBUF;

    *(buf+256) = num;

    return cf_blkwrite(num, buf);
};

# get the "type"/"length"/"next" field of the current block
var blktype = func(buf) {
    if (!buf) buf = BLKBUF;
    return buf[0] & 0xff00;
};
var blklen = func(buf) {
    if (!buf) buf = BLKBUF;
    return buf[0] & 0x00ff;
};
var blknext = func(buf) {
    if (!buf) buf = BLKBUF;
    return buf[1];
};

# set the "type"/"length"/"next" field of the current block
var blksettype = func(typ, buf) {
    if (!buf) buf = BLKBUF;
    *(buf+0) = typ | blklen(buf);
};
var blksetlen = func(len, buf) {
    if (!buf) buf = BLKBUF;
    *(buf+0) = blktype(buf) | len;
};
var blksetnext = func(blk, buf) {
    if (!buf) buf = BLKBUF;
    *(buf+1) = blk;
};

var FREEBLKBUF = asm { .gap 257 };
var freeblkblk = 0;
var freeblkgroup = 0;

# find a free block and update "blknextfree"
var blkfindfree = func() {
    var bitmapblk = 0;
    var blkgroup;

    while (bitmapblk != 16) {
        blkread(SKIP_BLOCKS + ((bitmapblk + freeblkblk) & 0xf), FREEBLKBUF);

        blkgroup = 0;
        while (blkgroup != BLKSZ) {
            if (FREEBLKBUF[(blkgroup + freeblkgroup) & 0xff] != 0xffff) break; # XXX: "& 0xff" assumes BLKSZ==256
            blkgroup++;
        };
        if (blkgroup != BLKSZ) break;
        bitmapblk++;
    };

    # TODO: [nice] don't kernel panic when disk is full
    if (bitmapblk == 16) kpanic("block device full");

    bitmapblk = (bitmapblk + freeblkblk) & 0xf;
    blkgroup = (blkgroup + freeblkgroup) & 0xff;
    # keep track of the block that we found a free block in, so we can start searching
    # from there next time
    freeblkblk = bitmapblk;
    freeblkgroup = blkgroup;

    # we now know that FREEBLKBUF[blkgroup] != 0xffff, which means at least one of
    # the 16 bits is 0, corresponding to a free block
    var i = 0;
    while (FREEBLKBUF[blkgroup] & powers_of_2[i]) i++;

    # upper 8 bits refer to lower 8 block numbers: swap them
    # TODO: [perf] do this byte-swapping thing in the perl script instead of the kernel
    i = i^8;

    # so now bit i in FREEBLKBUF[blkgroup] is 0, so the free block number is:
    #    (bitmapblk*4096 + blkgroup*16 + i)
    nextfreeblk = shl(bitmapblk, 12) + shl(blkgroup, 4) + i;
};

# Mark the given block as used/unused ("used" should be 0 or 1)
# If using "nextfreeblk", make sure to call blkfindfree() straight away
# note this function clobbers the block buffer
var blksetused = func(blk, used) {
    # block "blk" corresponds to:
    #   bitmapblk = blk / 4096
    #   blkgroup  = (blk%4096) / 16
    #   bit i     = blk % 16
    var bitmapblk = shr12(blk);
    var blkgroup  = byteshr4(blk & 0x0fff);
    var i         = blk & 0x0f;

    # upper 8 bits refer to lower 8 block numbers: swap them
    i = i^8;

    blkread(SKIP_BLOCKS + bitmapblk, FREEBLKBUF);
    if (used) *(FREEBLKBUF+blkgroup) = FREEBLKBUF[blkgroup] |  powers_of_2[i]
    else      *(FREEBLKBUF+blkgroup) = FREEBLKBUF[blkgroup] & ~powers_of_2[i];
    blkwrite(SKIP_BLOCKS + bitmapblk, FREEBLKBUF);
};

# recursively truncate the file from the given block number
# and offset into the block contents
var blktrunc = func(blknum, startat) {
    var nextblknum;

    # 1. truncate the current block at the current point
    blkread(blknum, 0);
    nextblknum = blknext(0);
    blksetnext(0, 0);
    blksetlen(startat, 0);
    blkwrite(blknum, 0);

    # 2. free all the remaining blocks
    while (nextblknum) {
        blknum = nextblknum;
        blkread(blknum, 0);
        nextblknum = blknext(0);
        blksetused(blknum, 0);
    };
};

# initialise nextfreeblk
blkfindfree();
