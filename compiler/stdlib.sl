extern mul;

# compute:
#   *pdiv = num / denom
#   *pmod = num % denom
# Pass a null pointer if you want to discard one of the results
# https://en.wikipedia.org/wiki/Division_algorithm#Integer_division_(unsigned)_with_remainder
extern powers_of_2;
var divmod = func(num, denom, pdiv, pmod) {
    var Q = 0;
    var R = 0;
    var i = 15;

    if (denom == 0)
        return 0;

    while (i >= 0) {
        R = R+R;
        if (num & *(powers_of_2+i)) {
            R++;
        };
        if (R >= denom) {
            R = R - denom;
            Q = Q | *(powers_of_2+i);
        };
        i--;
    };

    *pdiv = Q;
    *pmod = R;

    return 0;
};

var itoa_alphabet = "0123456789abcdefghijklmnopqrstuvwxyz";

# returns pointer to static buffer
# "base" should range from 2 to 36
var itoabase = func(num, base) {
    var s = "storage space here";
    var d;
    var m;

    *s = 0;

    # special case when num == 0
    if (num == 0) {
        *--s = '0';
        return s;
    };

    while (num != 0) {
        divmod(num, base, &d, &m);
        *--s = *(itoa_alphabet + m);
        num = d;
    };

    return s;
};

# returns pointer to static buffer
var itoa = func(num) return itoabase(num, 10);

var tolower = func(ch) {
    if (ch >= 'A' && ch <= 'Z') return ch - 'A' + 'a';
    return ch;
};

var stridx = func(alphabet, ch) {
    var i = 0;
    while (*(alphabet+i)) {
        if (*(alphabet+i) == ch) return i;
        i++;
    };
    return 0;
};

# TODO: negative values?
var atoibase = func(s, base) {
    var v = 0;
    while (*s) {
        v = mul(v, base) + stridx(itoa_alphabet, tolower(*s));
        s++;
    };
    return v;
};

# TODO: negative values?
var atoi = func(s) return atoibase(s, 10);

extern TOP;
var malloc = func(sz) {
    var oldtop = TOP;
    # TODO: die if this is going to exceed TPA
    TOP = TOP + sz;
    return oldtop;
};

var free = func(p) {
    # TODO: free
};
