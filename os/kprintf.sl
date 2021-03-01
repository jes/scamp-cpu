# kernel printf: this should not be compiled into the "real" kernel because
# it takes up quite a lot of space, but it can be included as needed for
# debugging

include "util.sl";

var itoa_alphabet = "0123456789abcdefghijklmnopqrstuvwxyz";
var itoa_space = "................."; # static 17-word buffer

# returns pointer to static buffer
# "base" should range from 2 to 36
var itoabase = func(num, base) {
    var s = itoa_space+16;
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

var kprintf = func(fmt, args) {
    var p = fmt;
    var argidx = 0;

    while (*p) {
        if (*p == '%') {
            p++;
            if (!*p) return 0;
            if (*p == '%') {
                outp(2, '%');
            } else if (*p == 'c') {
                outp(2, args[argidx++]);
            } else if (*p == 's') {
                kputs(args[argidx++]);
            } else if (*p == 'd') {
                kputs(itoa(args[argidx++]));
            } else if (*p == 'x') {
                kputs(itoabase(args[argidx++],16));
            } else {
                kputs("<???>");
            }
        } else {
            outp(2, *p);
        };
        p++;
    };
};
