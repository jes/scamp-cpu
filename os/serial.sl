# Serial port routines

include "data.sl";

var READPORT = FDDATA;
var WRITEPORT = FDDATA+1;

var ser_read = func(fd, buf, sz) {
    var p = fdbaseptr(fd);
    var readport = p[READPORT];
    var i = sz;
    while (i--)
        *(buf++) = inp(readport);
    return sz;
};

var ser_write = func(fd, buf, sz) {
    var p = fdbaseptr(fd);
    var writeport = p[WRITEPORT];
    while (sz--)
        outp(writeport, *(buf++));
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
};
ser_init();
