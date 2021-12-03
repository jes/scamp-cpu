include "stdlib.sl";

var EOF = -1;

var serport = 136;
var lsrport = 141;

var getchar = func() {
    while (!(inp(lsrport)&1));
    return inp(serport);
};

var putchar = func(ch) {
    if (ch == '\n') outp(serport, '\r');
    outp(serport, ch);
};

# read at most size-1 characters into s, and terminate with a 0
# return s if any chars were read
# return 0 if EOF was reached with no chars
var gets = func(s, size) {
    var ch = 0;
    var len = 0;

    while (ch != EOF && ch != '\n' && len < size) {
        ch = getchar();
        if (ch != EOF)
            *(s+(len++)) = ch;
    };

    if (ch == EOF && len == 0)
        return 0;

    *(s+len) = 0;

    return s;
};

# take a pointer to a nul-terminated string, and print it
var puts = func(s) {
    while (*s) putchar(*(s++));
};

# usage: printf(fmt, [arg1, arg2, ...]);
# format string:
#   %% -> %
#   %c -> character
#   %s -> string
#   %d -> decimal integer
#   %x -> hex integer
# TODO: signed vs unsigned integers? padding?
# TODO: show (null) for null pointers
# TODO: show arrays? lists?
# TODO: return the number of chars output
var printf = func(fmt, args) {
    var p = fmt;
    var argidx = 0;

    while (*p) {
        if (*p == '%') {
            p++;
            if (!*p) return 0;
            if (*p == '%') {
                putchar('%');
            } else if (*p == 'c') {
                putchar(args[argidx++]);
            } else if (*p == 's') {
                puts(args[argidx++]);
            } else if (*p == 'd') {
                puts(itoa(args[argidx++]));
            } else if (*p == 'x') {
                puts(itoabase(args[argidx++],16));
            } else {
                puts("<???>");
            }
        } else {
            putchar(*p);
        };
        p++;
    };
};
