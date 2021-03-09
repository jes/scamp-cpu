# Serial port routines

include "util.sl";
include "data.sl";
include "sys.sl";

var READPORT = FDDATA;
var WRITEPORT = FDDATA+1;

var ser_write;

# TODO: [nice] provide a way to turn off "cooked mode" stuff, per-device
#       (maybe just by switching the "read"/"write" functions in the fd table
#       between a "ser_rawread" and "ser_cookedread" for example)

var ser_read = func(fd, buf, sz) {
    var p = fdbaseptr(fd);
    var readport = p[READPORT];
    var i = sz;
    var ch = 0;
    sz = 0;
    while (i--) {
        ch = inp(readport);
        if (ch == 3) sys_exit(255); # ctrl-c
        if (ch == 4) break; # ctrl-d
        # TODO: [nice] if (ch == 17) ... # ctrl-q
        # TODO: [nice] if (ch == 19) ... # ctrl-s
        # TODO: [nice] what about arrow keys? backspace? delete? should we do
        #       line-buffering when serial is in cooked mode? or just make a
        #       user library for line editing?

        if (ch == '\r') ch = '\n'; # turn enter key into '\n'

        ser_write(fd, &ch, 1); # echo

        *(buf++) = ch;
        sz++;
    };
    return sz;
};

ser_write = func(fd, buf, sz) {
    var p = fdbaseptr(fd);
    var writeport = p[WRITEPORT];
    var ch;
    while (sz--) {
        ch = *(buf++);
        if (ch == '\n') outp(writeport, '\r'); # put \r before \n
        outp(writeport, ch);
    };
    return sz;
};

# store read/write port number in fd field 6/7
var ser_init = func() {
    var ser_fds = [3];
    var ser_readports = [2];
    var ser_writeports = [2];
    var i = 0;
    var p;
    while (ser_fds[i]) {
        # set functions for fd ser_fds[i]
        p = fdbaseptr(ser_fds[i]);
        *(p+READFD) = ser_read;
        *(p+WRITEFD) = ser_write;
        *(p+READPORT) = ser_readports[i];
        *(p+WRITEPORT) = ser_writeports[i];
        i++;
    };
    # use primary serial port for console:
    sys_copyfd(0, ser_fds[0]);
    sys_copyfd(1, ser_fds[0]);
    sys_copyfd(2, ser_fds[0]);
};
