# bigint library
# bigints are signed integers taking up "bigint_prec" words
#
# TODO: [nice] provide constants for bigzero, bigone, bigminusone, etc.?
# TODO: [nice] maybe we should support variable-sized numbers? might even
#       provide performance benefit
# TODO: [nice] convert bigint to word

include "malloc.sl";
include "string.sl";

var bigint_prec = 4;
var bigint_itoaspace = 0;

# if you use biginit, you must call it before creating
# any bigints
var biginit = func(prec) {
    bigint_prec = prec;
    free(bigint_itoaspace);
    bigint_itoaspace = malloc(bigint_prec * 16) + 2;
};
biginit(4); # initialise itoaspace etc.

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
    return big1;
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
var bigatoibase = func(str, base) {
    # TODO
};

# allocate a new bigint, populated with the value in "str", base 10
var bigatoi = func(str) {
    return bigatoibase(str, 10);
};

# return a pointer to a static string formatting "big"
var bigitoabase = func(big, base) {
    # TODO
};

# convert "big" to a single word signed value
# in case of overflow, the value will be clamped to the min/max
var bigtow = func(big) {
    if (bigcmpw(big, 32767) > 0) return 32767;
    if (bigcmpw(big, -32768) < 0) return -32768;
    return big[0];
};

# return a pointer to a static string formatting "big", base 10
var bigitoa = func(big) {
    return bigitobase(big, 10);
};

# big1 = big2
var bigset = func(big1, big2) {
    memcpy(big1, big2, bigint_prec);
};

# big = w
var bigsetw = func(big, w) {
    if (w < 0) memset(big, -1, bigint_prec); # sign extension
    *big = w;
};

# big1 = big1 + big2
var bigadd = func(big1, big2) {
    var carry = 0;
    var i = 0;
    var prev;

    while (i != bigint_prec) {
        prev = big1[i];
        *(big1+i) = big1[i] + big2[i] + carry;
        carry = (big1[i] lt prev);
        i++;
    };
};

# big = big + w
var bigaddw = func(big, w) {
    var bigw = bignew(w);
    bigadd(big, bigw);
    bigfree(bigw);
}

# big1 = big1 - big2
var bigsub = func(big1, big2) {
    var carry = 1;
    var i = 0;
    var prev;

    while (i != bigint_prec) {
        prev = big1[i];
        *(big1+i) = big1[i] + ~big2[i] + carry;
        carry = (big1[i] lt prev);
        i++;
    };
};

# big = big - w
var bigsubw = func(big, w) {
    var bigw = bignew(w);
    bigsub(big, bigw);
    bigfree(bigw);
};

# big1 = big1 * big2
var bigmul = func(big1, big2) {
    # TODO
};

# big = big * w
var bigmulw = func(big, w) {
    var bigw = bignew(w);
    bigmul(big, bigw);
    bigfree(bigw);
};

# big1 = big1 / big2
var bigdiv = func(big1, big2) {
    # TODO
};

#big = big / w
var bigdivw = func(big, w) {
    var bigw = bignew(w);
    bigdiv(big, bigw);
    bigfree(bigw);
};

# big1 = big1 % big2
var bigmod = func(big1, big2) {
    # TODO
};

# big = big % w
var bigmodw = func(big, w) {
    var bigw = bignew(w);
    bigmod(big, bigw);
    bigfree(bigw);
};
