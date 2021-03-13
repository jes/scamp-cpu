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
    return write(fd,&ch,1);
};

var getchar = func() {
    var ch = fgetc(0);
    if (ch < 0) return EOF; # collapse all types of error to "EOF"
    return ch;
};
var putchar = func(ch) return fputc(1, ch);

# read at most size-1 characters into s, and terminate with a 0
# return s if any chars were read
# return 0 if EOF was reached with no chars
var fgets = func(fd, s, size) {
    var ch = 0;
    var len = 0;

    while (ch >= 0 && ch != '\n' && len < size) {
        ch = fgetc(fd);
        if (ch >= 0)
            *(s+(len++)) = ch;
    };

    if (ch < 0 && len == 0)
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
#   %5d -> decimal integer, padded with spaces in front to make at least 5 chars
#   %05d -> decimal integer, padded with zeroes in front to make at least 5 chars
# TODO: [nice] signed vs unsigned integers? padding?
# TODO: [nice] show (null) for null pointers
# TODO: [nice] show arrays? lists?
# TODO: [nice] return the number of chars output
# TODO: [nice] padding at right-hand-side with negative padlen (%-5d)
var fprintf = func(fd, fmt, args) {
    var p = fmt;
    var argidx = 0;
    var padchar;
    var padlen;
    var str;
    var len;

    # XXX: [nice] how do we use the one from string.s without creating a circular dependency?
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
                while (padlen--) fputc(fd, padchar);
            };

            fputs(fd, str);
        } else {
            fputc(fd, *p);
        };
        p++;
    };
};

var printf = func(fmt, args) return fprintf(1, fmt, args);

# return a pointer to a static buffer containing the string "/tmp/tmpfileXX",
# with X's changed to digits, naming a file that did not previously exist;
# also, create the (empty) file
# in the event that creating the file fails (e.g. the system is out of fds), exit(256)
# TODO: [nice] use application-specific names instead of always "tmpfile"
var tmpnam_buf = "/tmp/tmpfileXX";
var tmpnam_x = tmpnam_buf+12; # address of first "X"
var tmpnam = func() {
    var ok = 0;

    # search for an unused name
    var y = 0;
    var x;
    var n;
    var statbuf = [0,0,0,0];
    while (y < 10 && !ok) {
        *tmpnam_x = y+'0';
        x = 0;
        while (x < 10 && !ok) {
            *(tmpnam_x+1) = x+'0';
            n = stat(tmpnam_buf, statbuf);
            if (n == NOTFOUND) ok=1;
            x++;
        };
        y++;
    };

    # create the file
    mkdir("/tmp"); # just in case
    var fd = open(tmpnam_buf, O_WRITE|O_CREAT);
    if (fd < 0) {
        fputs(2, "tmpnam: %s: %s\n", [tmpnam_buf, strerror(fd)]);
        exit(256);
    };
    close(fd);

    return tmpnam_buf;
};
