# Serial port routines

include "util.sl";
include "data.sl";
include "sys.sl";

var ser_bufsz = 140;
var ser_buflen = ser_bufsz - 3;
var ser_buf_area = asm {
    # BUFSPACE needs to be bufsz multiplied by no. of devices
    .def CONSOLE_BUFSPACE 280
    ser_buf_area: .gap CONSOLE_BUFSPACE

    _ser_bufspace: .word CONSOLE_BUFSPACE
};
extern ser_bufspace;

var ser_write;

var ser_readpos = func(bufp) return bufp[0];
var ser_readmaxpos = func(bufp) return bufp[1];
var ser_writepos = func(bufp) return bufp[2];
var ser_nextwritepos = func(bufp) {
    if (ser_writepos(bufp) == ser_buflen-1) return 0;
    return ser_writepos(bufp)+1;
};
var ser_buf = func(bufp) return bufp+3;
var ser_setreadpos = func(bufp,pos) *(bufp+0) = pos;
var ser_setreadmaxpos = func(bufp,pos) *(bufp+1) = pos;
var ser_setwritepos = func(bufp,pos) *(bufp+2) = pos;

# return 1 if the buffer is full, 0 otherwise
var ser_buffull = func(bufp) {
    return (ser_nextwritepos(bufp) == ser_readpos(bufp));
};

# return 1 if the buffer is empty, 0 otherwise
var ser_bufempty = func(bufp) {
    return (ser_readpos(bufp) == ser_readmaxpos(bufp));
};

# return a character from the buffer, or -1 if none
var ser_bufget = func(bufp) {
    # need to check "!ser_buffull(bufp)" so that a single long line doesn't block
    # the entire stream
    if (ser_bufempty(bufp) && !ser_buffull(bufp)) return -1;

    var buf = ser_buf(bufp);
    var readpos = ser_readpos(bufp);
    var readmaxpos = ser_readmaxpos(bufp);

    if (readpos == readmaxpos) readmaxpos++;

    var ch = buf[readpos++];
    if (readpos == ser_buflen) readpos = 0;

    ser_setreadpos(bufp, readpos);
    ser_setreadmaxpos(bufp, readmaxpos);

    return ch;
};

# add "ch" to the buffer, or do nothing if the buffer is full
var ser_bufput = func(bufp, ch) {
    var buf = ser_buf(bufp);
    var writepos = ser_writepos(bufp);

    if (ser_buffull(bufp)) return 0;

    *(buf+(writepos++)) = ch;
    if (writepos == ser_buflen) writepos = 0;
    if (ch == '\n' || ch == 4) ser_setreadmaxpos(bufp, writepos); # '\n' or ^D

    ser_setwritepos(bufp, writepos);
};

# remove last char from "fd"'s buffer and console
var ser_backspace = func(fd, bufp) {
    var writepos = ser_writepos(bufp);

    if (writepos == ser_readpos(bufp)) return 0;

    ser_write(fd, [8], 1); # move left 1 char
    ser_write(fd, [0x1b,'[','K'], 3); # clear to end of line

    writepos--;
    if (writepos < 0) writepos = ser_buflen-1;

    ser_setwritepos(bufp, writepos);
};

# check for available data on the given fd and stick it in the buffer;
# if in cooked mode, also handle ^C,^S,^Q,'\r', and echo;
# ^D is kind of a special case; it gets put in the buffer even though it's a control
# character, because it needs to be able to interrupt a read call;
# if the buffer is full, do nothing;
# TODO: [nice] should we instead drop incoming characters if the buffer is full?
#       how can we make sure to handle ^C even if the user did a bunch of typing?
#       maybe only drop them in cooked mode?
# TODO: [bug] this seems to fall over when the buffer fills up
var ser_poll = func(fd) {
    rngstate++;
    var p = fdbaseptr(fd);
    var writeimpl = p[WRITEFD];
    if (writeimpl != ser_write) return 0; # don't try to ser_poll() on non-serial devices

    if (p[SERFLAGS] & SER_DISABLE) return 0;

    var readport = p[BASEPORT];
    var lsrport = readport+5;
    var cooked_mode = p[SERFLAGS] & SER_COOKED;
    var bufp = p[BUFPTR];
    var ch;
    var dispch;

    # read while there are characters ready and the buffer is not full
    while ((inp(lsrport)&1) && !ser_buffull(bufp)) {
        ch = inp(readport) & 0xff;

        rngstate = rngstate + ch;

        if (cooked_mode) {
            if (ch == 3 && pid != 0) { # ctrl-c
                # clear input buffer
                ser_setreadpos(bufp, 0);
                ser_setreadmaxpos(bufp, 0);
                ser_setwritepos(bufp, 0);

                # trap or exit
                if (trapfunc) trapfunc()
                else sys_exit(255);
            };
            if (ch == 12) { # ctrl-l
                ser_write(fd, [0x1b, '[', '2', 'J'], 4); # clear screen
                ser_write(fd, [0x1b, '[', 'H'], 3); # home cursor
                continue;
            };
            if (ch == 19) { # ctrl-s
                # block the entire system until they type ctrl-q
                while (1) {
                    if (inp(lsrport)&1) {
                        if ((inp(readport)&0xff) == 17) break; # ctrl-q
                    };
                };
                continue;
            };
            if (ch == 26) { # ctrl-z
                # TODO: [bug] give the user a proper interactive session even if stdin/out are redirected
                sys_system(sys_osbase(), ["/bin/sh"]);
                continue;
            };
            if (ch == 8 || ch == 127) { # backspace
                ser_backspace(fd, bufp);
                continue;
            };
            if (ch == '\r') ch = '\n'; # turn enter key into '\n'

            # echo
            dispch = ch;
            if ((dispch < 0x20) && (dispch != '\n') && (dispch != '\t')) {
                dispch = ch + 'A' - 1;
                ser_write(fd, "^", 1);
            };
            ser_write(fd, &dispch, 1);
        };

        ser_bufput(bufp, ch);
        if (!cooked_mode) {
            # in raw mode, no line-buffering: we can always read every character
            # that we've written
            ser_setreadmaxpos(bufp, ser_writepos(bufp));
        };
    };
};

var ser_read = func(fd, buf, sz) {
    var p = fdbaseptr(fd);
    var bufp = p[BUFPTR];
    var cooked_mode = p[SERFLAGS] & SER_COOKED;
    var i = sz;
    var ch = 0;

    if (p[SERFLAGS] & SER_DISABLE) return 0;

    ser_poll(fd);

    # return number of characters that can be read without blocking
    if (sz == 0) {
        sz = ser_readmaxpos(bufp) - ser_readpos(bufp);
        if (sz < 0) sz = sz + ser_buflen;
        return sz;
    };

    sz = 0;
    while (i) {
        ser_poll(fd);

        ch = ser_bufget(bufp);
        if (ch == -1) {
            if (sz != 0) break; # return what we have, if any
            if (fd != 3) ser_poll(3);
            continue; # otherwise wait for some input
        };

        if (cooked_mode) {
            if (ch == 4) break; # ctrl-d
        };

        *(buf++) = ch;
        sz++;
        i--;
    };
    return sz;
};

# usage: ser_writech(baseport, ch)
var ser_writech = asm {
    pop x
    ld r1, x # r1 = ch
    pop x
    ld r2, x # r2 = baseport
    add x, 5
    ld r3, x # r3 = lsrport

    # wait for tx holding register empty
    ser_writech_spin:
        in x, r3
        and x, 0x20
        jz ser_writech_spin

    # output character
    ld x, r1
    out r2, x
    ret
};

ser_write = func(fd, buf, sz) {
    var p = fdbaseptr(fd);
    var baseport = p[BASEPORT];
    var cooked_mode = p[SERFLAGS] & SER_COOKED;
    var ch;
    var szsz = sz;

    if (p[SERFLAGS] & SER_DISABLE) return 0;

    while (sz--) {
        ch = *(buf++);

        if (cooked_mode) {
            if (ch == '\n') ser_writech(baseport, '\r'); # put \r before \n
        };

        ser_writech(baseport, ch);
    };
    return szsz;
};

var ser_init = func() {
    var ser_fds = [3, 4];
    var ser_baseports = [136, 144];
    var i = 0;
    var p;
    var bufp = ser_buf_area;
    while (ser_fds[i]) {
        # set functions for fd ser_fds[i]
        p = fdbaseptr(ser_fds[i]);
        *(p+READFD) = ser_read;
        *(p+WRITEFD) = ser_write;
        *(p+BASEPORT) = ser_baseports[i];
        *(p+BUFPTR) = bufp;
        *(p+SERFLAGS) = SER_COOKED;
        if (bufp ge (ser_buf_area + ser_bufspace)) kpanic("insufficient ser_bufspace"); # need to update CONSOLE_BUFSPACE?
        ser_setreadpos(bufp, 0);
        ser_setreadmaxpos(bufp, 0);
        ser_setwritepos(bufp, 0);

        # initialise port
        outp(ser_baseports[i]+3, 0x80); # dlab = 1
        outp(ser_baseports[i]+1, 0);
        outp(ser_baseports[i]+0, 1); # 115200/1 = 115200 baud
        outp(ser_baseports[i]+3, 0x03); # dlab = 0, mode 8n1

        bufp = bufp + ser_bufsz;
        i++;
    };
    # use primary serial port for console:
    sys_copyfd(0, ser_fds[0]);
    sys_copyfd(1, ser_fds[0]);
    sys_copyfd(2, ser_fds[0]);
};
