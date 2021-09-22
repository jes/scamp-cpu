# Fixed point arithmetic

include "string.sl";
include "sys.sl";

var fix_prec = 8;
var fixpi;

# forward declarations
var fixinit;
var fixatofbase;
var fixatof;
var fixftoabase;
var fixftoa;
var fixitof;
var fixftoi;
var fixmul;
var fixdiv;
var fixlerp;
var fixint;
var fixfrac;
var fixfloor;
var fixceil;
var fixsin;
var fixcos;

fixinit = func(frac) {
    fix_prec = frac;
    fixpi = fixatof("3.1415927");
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

    var divisor = base;
    var n;

    if (*s == '.') {
        s++;
        while (*s) {
            n = stridx(itoa_alphabet, tolower(*s));
            if (n == 0 && *s != *itoa_alphabet) break; # digit doesn't exist
            if (n >= base) break; # digit out of range for base
            # TODO: [bug] what about e.g. "0.9" when fix_prec is not enough to
            #       represent 9?
            v = v + div(fixitof(n), divisor);
            divisor = mul(divisor, base);
            s++;
        };
    };

    if (neg) v = -v;
    return v;
};

fixatof = func(s) return fixatofbase(s, 10);

# TODO: [bug] how much space does this actually need in the worst case?
var fixftoa_space = asm { .gap 64 };
fixftoabase = func(f, base) {
    var neg = 0;
    var s = fixftoa_space;
    if (f < 0) {
        neg = 1;
        f = -f;
        *(s++) = '-';
    };

    # handle the integer part with itoabase
    strcpy(s, itoabase(fixftoi(f), base));
    # append a '.'
    while (*s) s++;
    *(s++) = '.';

    f = fixfrac(f);
    var n;
    while (f) {
        n = mul(f, base);
        f = fixfrac(n);
        *(s++) = itoa_alphabet[fixftoi(n)];
    };

    if (*(s-1) == '.') *(s++) = '0';

    *s = 0;
    return fixftoa_space;
};

fixftoa = func(f) return fixftoabase(f, 10);
xpreg('f', fixftoa);

fixitof = func(i) {
    return shl(i, fix_prec);
};

fixftoi = func(f) {
    return shr(f, fix_prec);
};

#fixmul = func(a, b) {
#    var neg = 0;
#    if (a < 0) {
#        a = -a;
#        neg = !neg;
#    };
#    if (b < 0) {
#        b = -b;
#        neg = !neg;
#    };
#    var result = 0;
#    var n = shr(a,fix_prec);
#    var i = 16;
#    var bit = 1;
#    var f = fix_prec;
#    while (i) {
#        if (b & bit) result = result + n;
#        n = n + n;
#        bit = bit + bit;
#
#        if (f) {
#            f--;
#            if (a & powers_of_2[f]) n++;
#        };
#
#        i--;
#    };
#    if (neg) result = -result;
#    return result;
#};

# usage: fixmul(b,a);
fixmul = asm {
    pop x # a
    ld r1, x # a

    # see if a is negative
    ld (fixmul_neg), 0
    test r1
    jgt fixmul_pos_a
    jlt fixmul_neg_a
    # else a == 0, so result is 0
    pop x # discard b
    ld r0, 0
    ret
    fixmul_neg_a:
    neg r1
    not (fixmul_neg)
    fixmul_pos_a:

    ld x, r254
    push x # return address

    ld x, r1 # a
    push x # a
    push x # a

    ld x, (_fix_prec)
    push x

    call (_shr)

    ld r3, r0 # r3 = n

    pop x
    ld r1, x # r1 = a

    pop x
    ld r254, x # return address

    pop x
    ld r2, x # r2 = b

    ld r0, 0 # r0 = result
    ld r6, 16 # r6 = i
    ld r7, 1 # r7 = bit
    ld r8, (_fix_prec) # r8 = f
    ld r9, (_powers_of_2)
    add r9, r8 # r9 = powers_of_2+f

    # see if b is negative
    test r2
    jgt fixmul_loop
    jz fixmul_ret
    neg r2
    not (fixmul_neg)

    # loop 16 times
    fixmul_loop:
        # if (b & bit) result = result + n;
        ld x, r2
        and x, r7 # x = (b & bit)
        jz fixmul_noadd
        add r0, r3

        fixmul_noadd:

        # n = n + n
        shl r3
        # bit = bit + bit
        shl r7

        # if ((f--) < 0) continue;
        dec r8
        jlt fixmul_cont

        # if (a & powers_of_2[f]) n++;
        ld x, (--r9) # x = powers_of_2[f]
        and x, r1 # x = (a & powers_of_2[f])
        jz fixmul_cont
        inc r3

    fixmul_cont:
        dec r6
        jnz fixmul_loop

    # negate the result if exactly one of the inputs was negative
    test (fixmul_neg)
    jz fixmul_ret
    neg r0

    fixmul_ret:
    ret

    fixmul_neg: .word 0
};

# TODO: [perf] write a non-awful version of this
# https://blog.veitheller.de/Fixed_Point_Division.html
fixdiv = func(a, b) {
    var neg = 0;
    if (a < 0) {
        a = -a;
        neg = !neg;
    };
    if (b < 0) {
        b = -b;
        neg = !neg;
    };

    var quotient = 0;
    var i = fix_prec;
    var d;
    var m;
    while (a && i) {
        divmod(a, b, &d, &m);
        a = m+m;
        quotient = quotient + shl(d, i);
        i--;
    };

    if (neg) return -quotient
    else return quotient;
};

# linear interpolate between a and b, according to k (k=0 gets a, k=1 gets b)
fixlerp = func(a, b, k) {
    return a + fixmul(b-a,k);
};

# return the integer part of f, as a fixed-point value
fixint = func(f) {
    # TODO: is this right? what about negative values?
    return fixitof(fixftoi(f));
};

# return the fractional part of f
fixfrac = func(f) {
    # TODO: is this right? what about negative values?
    return f - fixint(f);
};

fixfloor = func(f) {
    # TODO: is this right? what about negative values?
    return f - fixfrac(f)
};

fixceil = func(f) {
    # TODO: is this right? what about negative values?
    if (f == fixfloor(f)) return f
    else return fixfloor(f)+1;
};

# TODO: characterise error
fixsin = func(f) {
    while (f > fixpi) f = f - fixpi;
    while (f < -fixpi) f = f + fixpi;
    var f2 = fixmul(f, f);
    var f3 = fixmul(f, f2);
    var f5 = fixmul(f3, f2);
    var f7 = fixmul(f5, f2);
    return f - div(f3, 6) - div(f5, 120) - div(f7, 5040);
};

# TODO: characterise error
fixcos = func(f) {
    while (f > fixpi) f = f - fixpi;
    while (f < -fixpi) f = f + fixpi;
    var f2 = fixmul(f, f);
    var f4 = fixmul(f2, f2);
    var f6 = fixmul(f4, f2);
    return fixitof(1) - div(f2, 2) + div(f4, 24) + div(f6, 720);
};

fixinit(fix_prec);
