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

bmnew = func(w, h) {
    w = div(w+15, 16);
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
    # TODO: how do we make the division more optimal?
    var xcell = div(x,16);
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
