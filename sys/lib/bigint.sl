# bigint library
# bigints are signed integers taking up "bigint_prec" words
#
# TODO: [nice] provide constants for bigzero, bigone, bigminusone, etc.?
# TODO: [nice] maybe we should support variable-sized numbers? might even
#       provide performance benefit

include "malloc.sl";
include "stdlib.sl";
include "string.sl";

var bigint_prec = 4;
var bigint_bits;
var bigint_itoaspace = 0;
var bigint_itoaspace_end;

# if you use biginit, you must call it before creating
# any bigints
var biginit = func(prec) {
    bigint_prec = prec;
    bigint_bits = shl(bigint_prec,4);

    free(bigint_itoaspace);

    var len = bigint_bits + 2;
    bigint_itoaspace = malloc(len);
    bigint_itoaspace_end = bigint_itoaspace + len - 1;
};
biginit(bigint_prec); # initialise itoaspace etc.

# TODO: [nice] more systematic forward declarations
var bigset;
var bigsetw;
var bigsub;
var bigdivmodw;
var bigtow;
var bigbit;
var bigmulw;
var bigaddw;
var bigitoa;

# create a new bigint with the given (word) value
var bignew = func(w) {
    var big = malloc(bigint_prec);
    bigsetw(big, w);
    return big;
};

# clone a bigint
var bigclone = func(big1) {
    var big2 = malloc(bigint_prec);
    bigset(big2, big1);
    return big2;
};

# free a bigint
var bigfree = free;

# return a value less than, equal to, or greater than 0 depending on whether big1
# is judged to be less than, equal to, or greater than big2
var bigcmp = func(big1, big2) {
    var big1neg = big1[bigint_prec-1] & 0x8000;
    var big2neg = big2[bigint_prec-1] & 0x8000;
    if (big1neg != big2neg) {
        if (big1neg) return -1
        else         return 1;
    };

    var i = bigint_prec;
    while (i--) {
        if (big1[i] gt big2[i]) return 1;
        if (big1[i] lt big2[i]) return -1;
    };
    return 0;
};

# return a value less than, equal to, or greater than 0 depending on whether big
# is judged to be less than, equal to, or greater than w
var bigcmpw = func(big, w) {
    var equal_high = 0;
    var unequal_high_result = 1;

    if (w & 0x8000) { # w < 0
        # if "big" is not negative, then big > w
        if (!(big[bigint_prec-1] & 0x8000)) return 1;

        # if "big" and "w" are equal, the high words of "big" will be -1; if
        # this is not the case, then "big" is smaller than "w"
        equal_high = -1;
        unequal_high_result = -1;
    } else { # w >= 0
        # if "big" is negative, then big < w
        if (big[bigint_prec-1] & 0x8000) return -1;
    };

    # check for inequality in high words
    var i = bigint_prec;
    while (i-- > 1)
        if (big[i] != equal_high)
            return unequal_high_result;

    if (big[0] gt w) return 1;
    if (big[0] lt w) return -1;
    return 0;
};

# allocate a new bigint, populated with the value in "str"
var bigatoibase = func(s, base) {
    var big = bignew(0);
    var neg = 0;
    if (*s == '-') {
        neg = 1;
        s++;
    };
    var n;
    while (*s) {
        n = stridx(itoa_alphabet, tolower(*s));
        if (n == 0 && *s != *itoa_alphabet) break; # digit doesn't exist
        if (n >= base) break; # digit out of range for base
        bigmulw(big, base);
        bigaddw(big, n);
        s++;
    };
    var b;
    if (neg) {
        b = bignew(0);
        bigsub(b, big);
        bigfree(big);
        return b;
    } else {
        return big;
    };
};

# allocate a new bigint, populated with the value in "str", base 10
var bigatoi = func(str) {
    return bigatoibase(str, 10);
};

# return a pointer to a static string formatting "big"
var bigitoabase = func(big, base) {
    var b = big;
    var neg = 0;

    if (bigcmpw(big, 0) < 0) {
        # b = 0 - big;
        b = bignew(0);
        bigsub(b, big);
        neg = 1;
    } else {
        # b = big;
        b = bigclone(big);
    };

    var s = bigint_itoaspace_end;
    var d;
    var m;

    *s = 0;

    # special case when b == 0
    if (bigcmpw(b, 0) == 0) {
        *--s = '0';
        bigfree(b);
        return s;
    };

    while (bigcmpw(b, 0) != 0) {
        bigdivmodw(b, base, &d, &m);
        *--s = *(itoa_alphabet + bigtow(m));
        bigset(b, d);
        bigfree(d); bigfree(m);
    };

    if (neg) {
        *--s = '-';
    };

    bigfree(b);
    return s;
};

# return a pointer to a static string formatting "big", base 10
bigitoa = func(big) {
    return bigitoabase(big, 10);
};
xpreg('b', bigitoa);

# convert "big" to a single word signed value
# in case of overflow, the value will be clamped to the min/max
bigtow = func(big) {
    if (bigcmpw(big, 32767) > 0) return 32767;
    if (bigcmpw(big, -32768) < 0) return -32768;
    return big[0];
};

# big1 = big2
bigset = func(big1, big2) {
    memcpy(big1, big2, bigint_prec);
};

# big = w
bigsetw = func(big, w) {
    if (w < 0) memset(big, -1, bigint_prec) # sign extension
    else       memset(big,  0, bigint_prec);
    *big = w;
};

# big1 = big1 + big2
#var bigadd = func(big1, big2) {
#    var carry = 0;
#    var i = 0;
#    var prev;
#
#    while (i != bigint_prec) {
#        prev = big1[i];
#        *(big1+i) = big1[i] + big2[i] + carry;
#        carry = (big1[i] lt prev) || (carry && (big1[i] == prev));
#        i++;
#    };
#
#    return big1;
#};
var bigadd = asm {
    pop x
    ld r1, x # big2
    pop x
    ld r0, x # big1
    ld r10, x # big1

    ld r2, 0 # carry
    ld r3, (_bigint_prec) # i = bigint_prec+1
    inc r3
    # r4 == prev

    bigadd_loop:
        # if (--i == 0) break;
        dec r3
        jz bigadd_ret

        # r5 = big1[i]
        ld x, (r10)
        ld r5, x
        ld r4, x # prev = big1[i]

        # x = big2[i]
        ld x, (r1++)

        # r5 = big1[i] + big2[i] + carry
        add r5, x # + big2[i]
        add r5, r2 # + carry

        # big1[i] = r5
        ld x, r10++
        ld (x), r5

        # carry gets set to 1 if the addition overflowed, which is true if either of:
        #  - (big1[i] == prev) && carry
        #  - big1[i] lt prev, which is true if any of:
        #     - prev has high bit set and big1[i] does not
        #     - sign bits are equal and big1[i] < prev

        cmp r4, r5
        jnz prev_ne_big1i
        # prev == big1[i], so we leave the carry flag as it was
        jmp bigadd_loop

        prev_ne_big1i:

        # carry = 0
        ld r2, 0

        # now we need to see if big1[i] is less than prev
        # first compare the signs:
        ld r7, r4
        ld r8, r5
        and r7, 32768 # only retain sign bit
        and r8, 32768 # only retain sign bit
        sub r7, r8
        jz value_cmp

        # signs differ: if prev has high bit set, then big1[i] lt prev, so we carry, otherwise not
        test r4
        jlt do_carry
        jmp bigadd_loop

        value_cmp:
        # signs are equal: compare the values
        cmp r4, r5 # prev -= big1[i]
        jlt bigadd_loop

        do_carry:
        inc r2
        jmp bigadd_loop

    bigadd_ret:
        ret
};

# big = big + w
bigaddw = func(big, w) {
    var bigw = bignew(w);
    bigadd(big, bigw);
    bigfree(bigw);

    return big;
};

# big1 = big1 - big2
bigsub = func(big1, big2) {
    var minusbig2 = bigclone(big2);
    var i = 0;
    while (i != bigint_prec) {
        *(minusbig2+i) = ~big2[i];
        i++;
    };
    bigaddw(minusbig2, 1);

    bigadd(big1, minusbig2);
    bigfree(minusbig2);

    return big1;
};

# big = big - w
var bigsubw = func(big, w) {
    var bigw = bignew(-w);
    bigadd(big, bigw);
    bigfree(bigw);

    return big;
};

# big1 = big1 * big2
var bigmul = func(big1, big2) {
    var result = bignew(0);
    var resultn = bigclone(big2);
    var i = 0;
    while (i != bigint_bits) {
        if (bigbit(big1, i)) bigadd(result, resultn);
        bigadd(resultn, resultn);
        i++;
    };
    bigset(big1, result);
    bigfree(result);
    bigfree(resultn);

    return big1;
};

# big = big * w
bigmulw = func(big, w) {
    var bigw = bignew(w);
    bigmul(big, bigw);
    bigfree(bigw);

    return big;
};

# shift-left a small-valued number by 4 bits
# n must be < 4096 (12 bits) due to tbsz limitation
# usage: _byteshr4(n)
var _byteshr4 = asm {
    pop x
    ld r0, x
    ld r1, r254 # stash return address
    ld r254, 0
    tbsz r0, 0x800
    sb r254, 0x80
    tbsz r0, 0x400
    sb r254, 0x40
    tbsz r0, 0x200
    sb r254, 0x20
    tbsz r0, 0x100
    sb r254, 0x10
    tbsz r0, 0x80
    sb r254, 0x8
    tbsz r0, 0x40
    sb r254, 0x4
    tbsz r0, 0x20
    sb r254, 0x2
    tbsz r0, 0x10
    sb r254, 0x1
    ld r0, r254
    jmp r1 # return
};

# return the nth bit of big (where 0 is least-significant)
bigbit = func(big, n) {
    var word = _byteshr4(n);
    var bit = n&0xf;

    if (big[word] & powers_of_2[bit]) return 1
    else return 0;
};

# set the nth bit of big (where 0 is lsb) to v (0 or 1)
var bigsetbit = func(big, n, v) {
    var word = _byteshr4(n);
    var bit = n&0xf;

    if (v) {
        *(big+word) = big[word] | powers_of_2[bit];
    } else {
        *(big+word) = big[word] & ~powers_of_2[bit];
    };
};

# *divp = big1 / big2
# *modp = big1 % big2
# both *divp and *modp are new allocations; big1 and big2 are unchanged
# https://en.wikipedia.org/wiki/Division_algorithm#Integer_division_(unsigned)_with_remainder
var bigdivmod = func(big1, big2, divp, modp) {
    var num = bigclone(big1);
    var denom = bigclone(big2);

    var negnum = 0;
    var negdenom = 0;

    # is numerator negative? set negnum and make it positive
    if (bigcmpw(num,0) < 0) {
        negnum = 1;
        bigsetw(num, 0);
        bigsub(num, big1);
    };

    # is denominator negative? set negdenom and make it positive
    if (bigcmpw(denom,0) < 0) {
        negdenom = 1;
        bigsetw(denom, 0);
        bigsub(denom, big2);
    };

    *divp = bignew(0);
    *modp = bignew(0);
    var i = bigint_bits-1;
    while (i != -1) {
        bigadd(*modp, *modp); # R := R << 1
        if (bigbit(num, i)) bigaddw(*modp, 1); # R(0) := N(i)
        if (bigcmp(*modp, denom) >= 0) { # if R >= D then
            bigsub(*modp, denom); # R := R - D
            bigsetbit(*divp, i, 1); # Q(i) := 1
        };
        i--;
    };

    bigfree(num);
    bigfree(denom);

    # if exactly one of numerator and denominator are negative, quotient is negative
    var tmp;
    if (negnum != negdenom) {
        tmp = bignew(0);
        bigsub(tmp, *divp);
        bigset(*divp, tmp);
        bigfree(tmp);
    };

    # if numerator is negative, remainder is negative
    if (negnum) {
        tmp = bignew(0);
        bigsub(tmp, *modp);
        bigset(*modp, tmp);
        bigfree(tmp);
    };

    return *divp;
};

bigdivmodw = func(big, w, divp, modp) {
    var bigw = bignew(w);
    bigdivmod(big, bigw, divp, modp);
    bigfree(bigw);

    return *divp;
};

# big1 = big1 / big2
var bigdiv = func(big1, big2) {
    var d;
    var m;
    bigdivmod(big1, big2, &d, &m);
    bigset(big1, d);
    bigfree(d);
    bigfree(m);
    return big1;
};

#big = big / w
var bigdivw = func(big, w) {
    var bigw = bignew(w);
    bigdiv(big, bigw);
    bigfree(bigw);

    return big;
};

# big1 = big1 % big2
var bigmod = func(big1, big2) {
    var d;
    var m;
    bigdivmod(big1, big2, &d, &m);
    bigset(big1, m);
    bigfree(d);
    bigfree(m);

    return big1;
};

# big = big % w
var bigmodw = func(big, w) {
    var bigw = bignew(w);
    bigmod(big, bigw);
    bigfree(bigw);

    return big;
};
