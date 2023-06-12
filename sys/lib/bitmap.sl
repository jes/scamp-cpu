# 2D Bitmap library

# [0] = width in cells, ceil(bitwidth / 16)
# [1] = h
# [2..] = data

var bmnew;
var bmfree;
var bmindex;
var bmset;
var bmget;
var bmclear;
var bmcount;
var bmwalk;

var _bmdiv16;

bmnew = func(w, h) {
    w = _bmdiv16(w+15);
    var bm = malloc(mul(w,h) + 2);
    bm[0] = w;
    bm[1] = h;
    bmclear(bm);
    return bm;
};

bmfree = free;

bmindex = func(bm, x, y) {
    var w = bm[0];
    var h = bm[1];
    var xcell = _bmdiv16(x);
    return 2 + mul(y,w) + xcell;
};

bmset = func(bm, x, y, val) {
    var xbit = x&0x0f;
    var i = bmindex(bm, x, y);
    if (val) bm[i] = bm[i] |  powers_of_2[xbit]
    else     bm[i] = bm[i] & ~powers_of_2[xbit];
};

bmget = func(bm, x, y) {
    var xbit = x&0x0f;
    var i = bmindex(bm, x, y);
    return bm[i] & powers_of_2[xbit]
};

bmclear = func(bm) {
    var w = bm[0];
    var h = bm[1];
    memset(bm+2, 0, mul(w,h));
};

bmcount = func(bm) {
    var w = bm[0];
    var h = bm[1];
    var cnt = 0;
    var lim = mul(w,h)+2;
    var i = 2;
    while (i != lim) {
        cnt = cnt + popcnt(bm[i]);
        i++;
    };
    return cnt;
};

# call cb(x,y) for every bit set to 1
bmwalk = func(bm, cb) {
    var w = bm[0];
    var h = bm[1];
    var base = bm+2;
    var xbit;
    var xcell = 0;
    var y = 0;
    var i = 0;
    while (y != h) {
        xcell = 0;
        while (xcell != w) {
            if (base[xcell] != 0) {
                xbit = mul(xcell, 16);
                i = 0;
                while (i != 16) {
                    if (bmget(bm, xbit+i, y)) cb(xbit+i, y);
                    i++;
                };
            };
            xcell++;
        };
        base = base + w;
        y++;
    };
};

# for x <= 32767:
# _bmdiv16 = func(x) return div(x, 16);
# for x > 32767 this function performs an unsigned division, whereas div() performs signed division
_bmdiv16 = asm {
    pop x
    ld r0, x

    ld r1, r254 # return address
    zero r254

    # set the lower 8 bits using tbsz/sb the simple way
    tbsz r0, 0x0010
    sb r254, 0x01
    tbsz r0, 0x0020
    sb r254, 0x02
    tbsz r0, 0x0040
    sb r254, 0x04
    tbsz r0, 0x0080
    sb r254, 0x08
    tbsz r0, 0x0100
    sb r254, 0x10
    tbsz r0, 0x0200
    sb r254, 0x20
    tbsz r0, 0x0400
    sb r254, 0x40
    tbsz r0, 0x0800
    sb r254, 0x80

    # set the next 4 bits by switching them all on and then conditionally jumping
    # over the instruction that switches them off (tbsz can only skip 1-word instructions)
    or r254, 0x0f00

    tbsz r0, 0x1000
    jr+ 2
    and r254, 0xfeff
    tbsz r0, 0x2000
    jr+ 2
    and r254, 0xfdff
    tbsz r0, 0x4000
    jr+ 2
    and r254, 0xfbff
    tbsz r0, 0x8000
    jr+ 2
    and r254, 0xf7ff

    ld r0, r254
    jmp r1
};
