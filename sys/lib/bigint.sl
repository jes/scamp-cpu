# bigint library
# bigints are signed integers taking up "bigint_prec" words
#
# TODO: [nice] provide constants for bigzero, bigone, bigminusone, etc.?
# TODO: [nice] maybe we should support variable-sized numbers? might even
#       provide performance benefit
# TODO: [nice] string formatting and unformatting
# TODO: [nice] convert bigint to word

include "malloc.sl";
include "string.sl";

var bigint_prec = 4;

# if you use bigint_init, you must call it before creating
# any bigints
var biginit = func(prec) {
    bigint_prec = prec;
};

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

# big1 = big2
var bigset = func(big1, big2) {
    memcpy(big1, big2, bigint_prec);
};

# big = w
var bigsetw = func(big, w) {
    if (val < 0) memset(big, -1, bigint_prec); # sign extension
    *big = val;
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
    if (w < 0) return bigsubw(big, -w);
    # now assume w >= 0

    # TODO
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
    if (w < 0) return bigaddw(big, -w);
    # now assume w >= 0

    # TODO
};

# big1 = big1 * big2
var bigmul = func(big1, big2) {
};

# big = big * w
var bigmulw = func(big, w) {
};

# big1 = big1 / big2
var bigdiv = func(big1, big2) {
};

#big = big / w
var bigdivw = func(big, w) {
};

# big1 = big1 % big2
var bigmod = func(big1, big2) {
};

# big = big % w
var bigmodw = func(big, w) {
};
