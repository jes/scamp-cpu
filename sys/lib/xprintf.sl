# generic printf() implementation

var xprintf;

include "stdlib.sl";
include "string.sl";

# usage: xprintf(fmt, [arg1, arg2, ...], putc_cb);
# format string:
#   %% -> %
#   %c -> character
#   %s -> string
#   %d -> decimal integer
#   %x -> hex integer
#   %b -> bigint
#   %f -> fixed-point
#   %5d -> decimal integer, padded with spaces in front to make at least 5 chars
#   %05d -> decimal integer, padded with zeroes in front to make at least 5 chars
# TODO: [nice] show arrays? lists?
# TODO: [nice] padding at right-hand-side with negative padlen (%-5d)
# TODO: [nice] allow setting precision of %f, e.g. "%0.3f"
xprintf = func(fmt, args, putc_cb) {
    var p = fmt;
    var argidx = 0;
    var padchar;
    var padlen;
    var str;
    var len;
    var total = 0;
    var fn;

    while (*p) {
        if (*p == '%') {
            padchar = ' ';
            padlen = 0;
            p++; if (!*p) return total;

            # use "0" for padding?
            if (*p == '0') {
                padchar = '0';
                p++; if (!*p) return total;
            };

            # padding size?
            while (isdigit(*p)) {
                padlen = mul(padlen,10) + (*p - '0');
                p++; if (!*p) return total;
            };

            # format type
            if (*p == '%') {
                str = "%";
            } else if (islower(*p) && xprintf_handlers[*p-'a']) {
                fn = xprintf_handlers[*p-'a'];
                str = fn(args[argidx++]);
            } else {
                str = "<???>";
                argidx++;
            };
            if (!str) str = "(null)";

            # padding
            len = strlen(str);
            if (padlen > len) {
                padlen = padlen - len;
                while (padlen--) putc_cb(padchar);
            };

            while (*str) {
                putc_cb(*(str++));
                total++;
            };
        } else {
            putc_cb(*p);
            total++;
        };
        p++;
    };

    return total;
};
