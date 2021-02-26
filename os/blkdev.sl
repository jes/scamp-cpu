# SCAMP block device handling
#
# Probably currently only supports 1 device. If we ever have multiple block
# devices we'll probably want the buffer to remember which device it came
# from to avoid confusing and annoying bugs. Or maybe a separate buffer for
# each device?

var BLKSZ = 256;
var BLKBUF = asm { .gap 256 };
var BLKBUFNUM;

var TYPE_DIR = 0;
var TYPE_FILE = 0x200;

var blkselectport = 4;
var blkdataport = 5;

var nextfreeblk = 0;

# read the given block number into the BLKBUF
var blkread = func(num) {
    if (BLKBUFNUM == num) return 0;

    BLKBUFNUM = num;
    outp(blkselectport, num);

    var i = 0;
    var high;
    var low;
    while (i != BLKSZ) {
        high = inp(blkdataport);
        low = inp(blkdataport);
        *(BLKBUF+i) = shl(high,8) | low;
        i++;
    };
};

# write the BLKBUF to the given block number
var blkwrite = func(num) {
    outp(blkselectport, num);

    var i = 0;
    var high;
    var low;
    while (i != BLKSZ) {
        high = shr8(*(BLKBUF+i));
        low = *(BLKBUF+i) & 0xff;
        outp(blkdataport, high);
        outp(blkdataport, low);
        i++;
    };
};

# return the "type" field from the current block
var blktype = func() return BLKBUF[0] & 0xfe00;

# return the "length" field from the current block
var blklen = func() return BLKBUF[0] & 0x01ff;

# return the "next" field from the current block
var blknext = func() return BLKBUF[1];

# find a free block and update "blknextfree"
# TODO: start searching from the current "blknextfree" to avoid the long
# linear search in the case where the start of the disk is all used
var blkfindfree = func() {
    var bitmapblk = 0;
    var blkgroup;

    while (bitmapblk != 16) {
        blkread(bitmapblk);

        blkgroup = 0;
        while (blkgroup != BLKSZ) {
            if (BLKBUF[blkgroup] != 0xffff) break;
            blkgroup++;
        };
        if (blkgroup != BLKSZ) break;
        bitmapblk++;
    };

    # TODO: don't kernel panic when disk is full
    if (bitmapblk == 16) kpanic("block device full");

    # we now know that BLKBUF[blkgroup] != 0xffff, which means at least one of
    # the 16 bits is 0, corresponding to a free block
    var i = 0;
    while (BLKBUF[blkgroup] & shl(1, i)) i++;

    # so now bit i in BLKBUF[blkgroup] is 0, so the free block number is:
    #    (bitmapblk*4096 + blkgroup*16 + i)
    nextfreeblk = shl(bitmapblk, 12) + shl(blkgroup, 4) + i;
};

# initialise nextfreeblk
kputs("finding free block...");
blkfindfree();
kputs(" ok\n");
