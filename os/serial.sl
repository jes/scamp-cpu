# Serial port routines

include "data.sl";

var ser_read = func(fd, buf, sz) {
    var p = fdbaseptr(fd);
    var readport = p[6];
    var i = sz;
    while (i--)
        *(buf++) = inp(readport);
    return sz;
};

var ser_write = func(fd, buf, sz) {
    var p = fdbaseptr(fd);
    var writeport = p[7];
    while (sz--)
        outp(writeport, *(buf++));
};

var ser_getchar = func(fd) {
    var p = fdbaseptr(fd);
    var readport = p[6];
    return inp(readport);
};

var ser_putchar = func(fd, ch) {
    var p = fdbaseptr(fd);
    var writeport = p[7];
    outp(writeport, ch);
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
        *(p+0) = ser_read;
        *(p+1) = ser_write;
        *(p+2) = ser_getchar;
        *(p+3) = ser_putchar;
        *(p+6) = ser_readports[i];
        *(p+7) = ser_writeports[i];
        i++;
    };
};
ser_init();
