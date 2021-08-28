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
    ld r9, powers_of_2
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

fixdiv = func(a, b) {
    printf("TODO: fixdiv\n", 0);
    exit(1);
};
