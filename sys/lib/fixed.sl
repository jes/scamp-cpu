# Fixed point arithmetic

include "stdio.sl";
include "sys.sl";

var fix_prec = 8;

# forward declarations
var fixinit;
var fixatofbase;
var fixatof;
var fixftoa;
var fixitof;
var fixftoi;
var fixmul;
var fixdiv;

fixinit = func(frac) {
    fix_prec = frac;
};

fixatofbase = func(s, base) {
    var v = 0;
    var neg = 0;
    if (*s == '-') {
        neg = 1;
        s++;
    };

    # parse the integer part with atoibase
    v = fixitof(atoibase(s, base));

    # now see if there's a fractional part
    while (*s && *s != '.') s++;

    if (*s == '.') {
        s++;
        while (*s) {
            # TODO: ???
            s++;
        };
    };

    if (neg) v = -v;
    return v;
};

fixatof = func(s) return fixatofbase(s, 10);

fixftoa = func(f) {
    printf("TODO: fixftoa\n", 0);
    exit(1);
};
xpreg('f', fixftoa);

fixitof = func(i) {
    return shl(i, fix_prec);
};

fixftoi = func(f) {
    return shr(f, fix_prec);
};

fixmul = func(a, b) {
    var result = 0;
    var n = shr(a,fix_prec);
    var i = 0;
    var bit = 1;
    var f = fix_prec;
    while (i != 16) {
        if (b & bit) result = result + n;
        n = n + n;
        bit = bit + bit;

        i++;
        if (f) {
            f--;
            if (a & powers_of_2[f]) n++;
        };
    };
    return result;
};

fixdiv = func(a, b) {
    printf("TODO: fixdiv\n", 0);
    exit(1);
};
