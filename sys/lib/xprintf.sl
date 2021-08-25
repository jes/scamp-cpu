# generic printf() implementation

include "stdlib.sl";

var xprintf_handlers = asm { .gap 26 };

# register a character handler for xprintf et al
# that takes in the value to format and returns the
# formatted string; the character must be a lowercase letter
#   e.g. xpreg('x', func(val) { return "x" });
# it's fine if the returned string is static
# set cb=0 to unregister the handler
var xpreg = func(ch, cb) {
    if (!islower(ch)) return 0;
    xprintf_handlers[ch-'a'] = cb;
};

xpreg('c', func(ch) { return [ch] });
xpreg('s', func(s) { return s });
xpreg('d', itoa);
xpreg('u', utoa);
xpreg('x', func(v) { return utoabase(v, 16) });

# usage: xprintf(fmt, [arg1, arg2, ...], putc_cb);
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
# TODO: [nice] padding at right-hand-side with negative padlen (%-5d)
var xprintf = func(fmt, args, putc_cb) {
    var p = fmt;
    var argidx = 0;
    var padchar;
    var padlen;
    var str;
    var len;
    var total = 0;
    var fn;

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
