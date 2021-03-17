# generic printf() implementation

include "stdlib.sl";

# usage: xprintf(fd, fmt, [arg1, arg2, ...], putc_cb);
# format string:
#   %% -> %
#   %c -> character
#   %s -> string
#   %d -> decimal integer
#   %x -> hex integer
#   %5d -> decimal integer, padded with spaces in front to make at least 5 chars
#   %05d -> decimal integer, padded with zeroes in front to make at least 5 chars
# TODO: [nice] signed vs unsigned integers? padding?
# TODO: [nice] show arrays? lists?
# TODO: [nice] return the number of chars output
# TODO: [nice] padding at right-hand-side with negative padlen (%-5d)
var xprintf = func(fmt, args, putc_cb) {
    var p = fmt;
    var argidx = 0;
    var padchar;
    var padlen;
    var str;
    var len;

    # TODO: [nice] how do we use the one from string.s without creating a circular dependency?
    var strlen = func(s) {
        var len = 0;
        while (*(s++)) len++;
        return len;
    };

    while (*p) {
        if (*p == '%') {
            padchar = ' ';
            padlen = 0;
            p++; if (!*p) return 0;

            # use "0" for padding?
            if (*p == '0') {
                padchar = '0';
                p++; if (!*p) return 0;
            };

            # padding size?
            while (isdigit(*p)) {
                padlen = mul(padlen,10) + (*p - '0');
                p++; if (!*p) return 0;
            };

            # format type
            if (*p == '%') {
                str = "%";
            } else if (*p == 'c') {
                str = [args[argidx++]];
            } else if (*p == 's') {
                str = args[argidx++];
                if (!str) str = "(null)";
            } else if (*p == 'd') {
                str = itoa(args[argidx++]);
            } else if (*p == 'x') {
                str = itoabase(args[argidx++],16);
            } else {
                str = "<???>";
            };

            # padding
            len = strlen(str);
            if (padlen > len) {
                padlen = padlen - len;
                while (padlen--) putc_cb(padchar);
            };

            while (*str) putc_cb(*(str++));
        } else {
            putc_cb(*p);
        };
        p++;
    };

    return 0;
};
