include "stdlib.sl";
include "sys.sl";

var fgetc = func(fd) {
    var ch;
    var n = read(fd, &ch, 1);
    if (n == 0) return EOF;
    if (n < 0) return n;
    return ch;
};

var fputc = func(fd, ch) {
    var chs = [ch,0];
    return write(fd,&chs,1);
};

var getchar = func() return fgetc(0);
var putchar = func(ch) return fputc(1, ch);

# read at most size-1 characters into s, and terminate with a 0
# return s if any chars were read
# return 0 if EOF was reached with no chars
var fgets = func(fd, s, size) {
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
var fputs = func(fd, s) {
    var ss = s;
    var len = 0;
    while (*ss++) len++;
    write(fd,s,len);
};

var gets = func(s,size) return fgets(0,s,size);
var puts = func(s) return fputs(1,s);

# usage: fprintf(fd, fmt, [arg1, arg2, ...]);
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
var fprintf = func(fd, fmt, args) {
    var p = fmt;
    var argidx = 0;

    while (*p) {
        if (*p == '%') {
            p++;
            if (!*p) return 0;
            if (*p == '%') {
                fputc(fd, '%');
            } else if (*p == 'c') {
                fputc(fd, args[argidx++]);
            } else if (*p == 's') {
                fputs(fd, args[argidx++]);
            } else if (*p == 'd') {
                fputs(fd, itoa(args[argidx++]));
            } else if (*p == 'x') {
                fputs(fd, itoabase(args[argidx++],16));
            } else {
                fputs(fd, "<???>");
            }
        } else {
            fputc(fd, *p);
        };
        p++;
    };
};

var printf = func(fmt, args) return fprintf(1, fmt, args);
