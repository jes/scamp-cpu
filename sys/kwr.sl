# write kernel to disk
#
# usage: kwr kernel.bin c000

include "getopt.sl";
include "sys.sl";

var args = cmdargs()+1;

if (!*args || !*(args+1) || *(args+2)) {
    fprintf(2, "usage: kwr FILE START\nWhere START is the start address in hex.\n", 0);
    exit(1);
};

var file = args[0];
var start = atoibase(args[1], 16);

var statbuf = malloc(4);
var n = stat(file, statbuf);
if (n == -1) {
    fprintf(2, "stat %s: %s\n", [file, strerror(n)]);
    exit(1);
};
var length = statbuf[1];

var sum = 0;
var blksz = 256;
var blk = malloc(blksz);
blk[0] = 0x5343;
blk[1] = start;
blk[2] = length+1;

var fd = open(file, O_READ);
if (fd == -1) {
    fprintf(2, "open %s: %s\n", [file, strerror(n)]);
    exit(1);
};

# read first block
n = read(fd, blk+3, blksz-3);
var i = 0;
while (i < n+3) {
    sum = sum + blk[i];
    i++;
};

# TODO: [bug] if kernel is smaller than 1 block, put checksum in first block

# write first block
var blknum = 0;
blkwrite(blknum++, blk);

# write more blocks
while (1) {
    n = read(fd, blk, blksz);
    if (n < 0) {
        fprintf(2, "read %s: %s\n", [file, strerror(n)]);
        exit(1);
    };
    i = 0;
    while (i < n) {
        sum = sum + blk[i];
        i++;
    };
    if (n < blksz) blk[n] = -sum;
    blkwrite(blknum++, blk);
    if (n < blksz) break;
};
