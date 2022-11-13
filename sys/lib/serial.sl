# serial port protocol handling

# TODO: [perf] this is all too slow to do anything with the data we read other
#       than buffer it in memory, else we drop bytes :(

# the "_p" functions allow retrieval of responses "piecewise" via a callback

include "stdio.sl";
include "malloc.sl";
include "strbuf.sl";
include "xscanf.sl";

var SERIALDEV = 144;
var SERIALDEVLSR = 149;
var ser_writefd = 4;
var ser_textbuf_sz = 256;
var ser_textbuf = malloc(ser_textbuf_sz);

# forward declarations
var ser_get;
var ser_put;
var ser_get_p;
var ser_put_p;
var ser_request;
var ser_request_p;
var ser_sync;
var ser_readch;
var ser_readblock;
var ser_scanf;

ser_get = func(endpoint, path, content) return ser_request("get", endpoint, path, content);
ser_put = func(endpoint, path, content) return ser_request("put", endpoint, path, content);

ser_get_p = func(endpoint, path, content, cb) return ser_request_p("get", endpoint, path, content, cb);
ser_put_p = func(endpoint, path, content, cb) return ser_request_p("put", endpoint, path, content, cb);

# make a request over the serial connection, return 1 if ok and 0 otherwise
# call cb(ok, buf, len) for each block of content
ser_request_p = func(method, endpoint, path, content, cb) {
    if (!content) content = "";

    # put serial port in raw mode
    serflags(ser_writefd, 0);

    # send request
    fprintf(ser_writefd, "%s %s %u %s\n", [method, endpoint, strlen(content), path]);
    fprintf(ser_writefd, "%s\n", [content]);

    # read response header
    # TODO: [bug] buffer overflow on reading into textbuf
    # TODO: [bug] scanf format string should need a trailing "\n", but the xscanf bug means it always consumes 1 more character than asked
    var length;
    ser_scanf("%s %d", [ser_textbuf, &length]);

    var ok = (strcmp(ser_textbuf, "ok") == 0);

    # read response body
    var need = length+1; # +1 for trailing \n
    var n;
    var ch;
    var readsz;
    while (need) {
        readsz = need;
        if (readsz gt 256) readsz = 256;

        n = ser_readblock(ser_textbuf, readsz);
        if (n == 0) {
            fprintf(2, "error: read: eof on serial\n", 0);
            exit(1);
        };
        if (n < 0) {
            fprintf(2, "error: read: %s\n", [strerror(n)]);
            exit(1);
        };

        need = need-n;
        if (need == 0) {
            n--; # hide trailing \n from application
        };
        cb(ok, ser_textbuf, n);
    };

    if (ser_textbuf[n] != '\n') ok = 0; # not ok if we didn't end on the trailing \n

    return ok;
};

var ser_request_sb;
ser_request = func(method, endpoint, path, content) {
    ser_request_sb = sbnew();
    var ok = ser_request_p(method, endpoint, path, content, func(ok, buf, len) {
        sbwrite(ser_request_sb, buf, len);
    });
    var str = strdup(sbbase(ser_request_sb));
    sbfree(ser_request_sb);
    return [ok, str];
};

# sync the serial connection by stopping the other side from waiting for the prompt
# TODO: [bug] this doesn't work; what if we're stuck inside the body of a contentful request?
#             how do we sync then? should there be an escape character that always syncs up?
ser_sync = func() {
    # give a few blank lines so that the other side knows to reset
    fputs(ser_writefd, "\n\n\n\n\n");

    # wait until the other side isn't trying to send anything
    #var i;
    #while (1) {
    #    i = 1000;
    #    while ((read(ser_readfd, 0, 0) == 0) && --i);
    #    if (i == 0) break;
    #    read(ser_readfd, 0, 1);
    #};
};

ser_readch = func() {
    while ((inp(SERIALDEVLSR)&1) == 0);
    return inp(SERIALDEV) & 0xff;
};

ser_readblock = func(buf, readsz) {
    # prompt for next block
    fputs(ser_writefd, "!\n");

    var n = 0;
    while (n != readsz) {
        buf[n] = ser_readch();
        n++;
    };
    return n;
};

ser_scanf = func(fmt, args) return xscanf(fmt, args, ser_readch);
