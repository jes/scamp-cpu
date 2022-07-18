# df - show overall disk usage

include "stdio.sl";
include "sys.sl";
include "fixed.sl";

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
