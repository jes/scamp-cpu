var fprintf;
var fputs;

include "stdlib.sl";
include "sys.sl";
include "xprintf.sl";
include "xscanf.sl";

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
            s[len++] = ch;
    };

    s[len] = 0;

    if (ch < 0 && len == 0)
        return 0;

    return s;
};

# take a pointer to a nul-terminated string, and print it
fputs = func(fd, s) {
    var ss = s;
    var len = 0;
    while (*ss++) len++;
    write(fd,s,len);
};

var gets = func(s,size) return fgets(0,s,size);
var puts = func(s) return fputs(1,s);

var fprintf_fd;
fprintf = func(fd, fmt, args) {
    fprintf_fd = fd;
    return xprintf(fmt, args, func(ch) { fputc(fprintf_fd, ch) });
};

var printf = func(fmt, args) return xprintf(fmt, args, putchar);

var fscanf_fd;
var fscanf = func(fd, fmt, args) {
    fscanf_fd = fd;
    return xscanf(fmt, args, func() { return fgetc(fscanf_fd) });
};

var scanf = func(fmt, args) return xscanf(fmt, args, getchar);

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
            tmpnam_x[1] = x+'0';
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
        fprintf(2, "tmpnam: %s: %s\n", [tmpnam_buf, strerror(fd)]);
        exit(256);
    };
    close(fd);

    return tmpnam_buf;
};

var assert = func(true, fmt, args) {
    if (!true) {
        fprintf(2, fmt, args);
        exit(1);
    };
};
