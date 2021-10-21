# df - show overall disk usage

include "stdio.sl";
include "sys.sl";
include "fixed.sl";

# usage: popcnt(val)
# return number of bits in val set to 1
# TODO: [nice] should this be in stdlib.sl?
var popcnt = asm {
    pop x
    ld r1, x # val
    ld r0, 0

    tbsz r1, 0x0001
    inc r0
    tbsz r1, 0x0002
    inc r0
    tbsz r1, 0x0004
    inc r0
    tbsz r1, 0x0008
    inc r0
    tbsz r1, 0x0010
    inc r0
    tbsz r1, 0x0020
    inc r0
    tbsz r1, 0x0040
    inc r0
    tbsz r1, 0x0080
    inc r0
    tbsz r1, 0x0100
    inc r0
    tbsz r1, 0x0200
    inc r0
    tbsz r1, 0x0400
    inc r0
    tbsz r1, 0x0800
    inc r0
    tbsz r1, 0x1000
    inc r0
    tbsz r1, 0x2000
    inc r0
    tbsz r1, 0x4000
    inc r0
    tbsz r1, 0x8000
    inc r0

    ret
};

var countbits = func(p, len) {
    var n = 0;
    var i = 0;
    while (i < len) {
        n = n + popcnt(p[i]);
        i++;
    };
    return n;
};

# work out how many blocks are used by counting bits set to 1 in the free-space bitmap
var b = 64;
var p;
var usedblocks = 0;
while (b < 80) {
    p = blkread(b);
    usedblocks = usedblocks + countbits(p, 256);
    b++;
};

printf("%u blocks used of 65536\n", [usedblocks]);

var usedb = mul(usedblocks, 512);
var usedkb = div(usedblocks, 2);
var usedmb = div(usedblocks, 2048);
if (usedkb < 2) printf("%u bytes used of 32 Mbytes\n", [usedb])
else if (usedmb < 2) printf("%u Kbytes used of 32 Mbytes\n", [usedkb])
else printf("%u Mbytes used of 32 MB\n", [usedmb]);

fixinit(8);
var usedpct = shr(usedblocks,8);
printf("%f%% used\n", [mul(usedpct,100)]);
