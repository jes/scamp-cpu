# Serial port routines

include "util.sl";
include "data.sl";
include "sys.sl";

var READPORT = FDDATA;
var WRITEPORT = FDDATA+1;
var READYPORT = FDDATA+2;
var BUFPTR = FDDATA+3;

var ser_bufsz = 128;
var ser_buf = asm {
    # BUFSPACE needs to be bufsz multiplied by no. of devices
    .def CONSOLE_BUFSPACE 128
    ser_buf: .gap CONSOLE_BUFSPACE

    _ser_bufspace: .word CONSOLE_BUFSPACE
};
extern ser_bufspace;

var ser_write;

# TODO: [nice] provide a way to turn off "cooked mode" stuff, per-device
#       (maybe just by switching the "read"/"write" functions in the fd table
#       between a "ser_rawread" and "ser_cookedread" for example)
var cooked_mode = 1;

# return 1 if the buffer is full, 0 otherwise
var ser_buffull = func(bufp) {
    var readpos = bufp[0];
    var writepos = bufp[1];
    var buf = bufp+2;
    var buflen = ser_bufsz-2;

    var nextwritepos = writepos+1;
    if (nextwritepos == buflen) nextwritepos = 0;

    return (nextwritepos == readpos);
};

# return 1 if the buffer is empty, 0 otherwise
var ser_bufempty = func(bufp) {
    var readpos = bufp[0];
    var writepos = bufp[1];
    var buf = bufp+2;
    var buflen = ser_bufsz-2;

    return (readpos == writepos);
};

# return a character from the buffer, or -1 if none
var ser_bufget = func(bufp) {
    var readpos = bufp[0];
    var writepos = bufp[1];
    var buf = bufp+2;
    var buflen = ser_bufsz-2;

    if (ser_bufempty(bufp)) return -1;

    var ch = buf[readpos++];
    if (readpos == buflen) readpos = 0;

    *(bufp+0) = readpos;

    return ch;
};

# add "ch" to the buffer, or do nothing if the buffer is full
var ser_bufput = func(bufp, ch) {
    var readpos = bufp[0];
    var writepos = bufp[1];
    var buf = bufp+2;
    var buflen = ser_bufsz-2;

    if (ser_buffull(bufp)) return 0;

    *(buf+(writepos++)) = ch;
    if (writepos == buflen) writepos = 0;

    *(bufp+1) = writepos;
};

# check for available data on the given fd and stick it in the buffer;
# if in cooked mode, also handle ^C,^S,^Q,'\r', and echo;
# ^D is kind of a special case; it gets put in the buffer even though it's a control
# character, because it needs to be able to interrupt a read call;
# if the buffer is full, do nothing;
# TODO: [nice] should we instead drop incoming characters if the buffer is full?
#       how can we make sure to handle ^C even if the user did a bunch of typing?
#       maybe only drop them in cooked mode?
var ser_poll = func(fd) {
    var p = fdbaseptr(fd);
    var readport = p[READPORT];
    var readyport = p[READYPORT];
    var bufp = p[BUFPTR];
    var ch;

    # read while there are characters ready and the buffer is not full
    while (inp(readyport) && !ser_buffull(bufp)) {
        ch = inp(readport);

        if (cooked_mode) {
            if (ch == 3) sys_exit(255); # ctrl-c
            # TODO: [nice] if (ch == 17) ... # ctrl-q
            # TODO: [nice] if (ch == 19) ... # ctrl-s
            # TODO: [nice] what about backspace?

            if (ch == '\r') ch = '\n'; # turn enter key into '\n'

            ser_write(fd, &ch, 1); # echo
        };

        ser_bufput(bufp, ch);
    };
};

var ser_read = func(fd, buf, sz) {
    var p = fdbaseptr(fd);
    var bufp = p[BUFPTR];
    var i = sz;
    var ch = 0;
    sz = 0;
    while (i) {
        ser_poll(fd);

        if (ser_bufempty(bufp)) {
            if (sz != 0) break; # return what we have, if any
            continue; # otherwise wait for some input
        };

        ch = ser_bufget(bufp);

        if (cooked_mode) {
            if (ch == 4) break; # ctrl-d
        };

        *(buf++) = ch;
        sz++;
        i--;
    };
    return sz;
};

ser_write = func(fd, buf, sz) {
    var p = fdbaseptr(fd);
    var writeport = p[WRITEPORT];
    var ch;
    while (sz--) {
        ch = *(buf++);

        # TODO: [nice] maybe we need to block and wait for the serial device to be ready?

        if (cooked_mode) {
            if (ch == '\n') outp(writeport, '\r'); # put \r before \n
        };

        outp(writeport, ch);
    };
    return sz;
};

var ser_init = func() {
    var ser_fds = [3];
    var ser_readports = [2];
    var ser_writeports = [2];
    var ser_readyports = [6];
    var i = 0;
    var p;
    var bufp = ser_buf;
    while (ser_fds[i]) {
        # set functions for fd ser_fds[i]
        p = fdbaseptr(ser_fds[i]);
        *(p+READFD) = ser_read;
        if (ser_fds[i] == 3) *(p+READFD) = ser_read;
        *(p+WRITEFD) = ser_write;
        *(p+READPORT) = ser_readports[i];
        *(p+WRITEPORT) = ser_writeports[i];
        *(p+READYPORT) = ser_readyports[i];
        *(p+BUFPTR) = bufp;
        if (bufp ge (ser_buf + ser_bufspace)) kpanic("insufficient ser_bufspace");
        bufp = bufp + ser_bufsz;
        i++;
    };
    # use primary serial port for console:
    sys_copyfd(0, ser_fds[0]);
    sys_copyfd(1, ser_fds[0]);
    sys_copyfd(2, ser_fds[0]);
};
