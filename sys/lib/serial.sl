# serial port protocol handling

# TODO: [perf] this is all too slow to do anything with the data we read other
#       than buffer it in memory, else we drop bytes :(

# the "_p" functions allow retrieval of responses "piecewise" via a callback

include "stdio.sl";
include "malloc.sl";
include "strbuf.sl";

var ser_readfd = 4;
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
var ser_puts_cb;
var ser_sync;
var ser_readbytes;

ser_get = func(endpoint, path, content) return ser_request("get", endpoint, path, content);
ser_put = func(endpoint, path, content) return ser_request("put", endpoint, path, content);

ser_get_p = func(endpoint, path, content, cb) return ser_request_p("get", endpoint, path, content, cb);
ser_put_p = func(endpoint, path, content, cb) return ser_request_p("put", endpoint, path, content, cb);

# make a request over the serial connection, return 1 if ok and 0 otherwise
# call cb(ok, ch) for each character of content
# TODO: [bug] what about request bodies too large to buffer in memory?
# TODO: [bug] what about request/response bodies that contain nul bytes?
ser_request_p = func(method, endpoint, path, content, cb) {
    if (!content) content = "";

    # put serial port in raw mode
    serflags(ser_readfd, 0);
    serflags(ser_writefd, 0);

    # send request
    fprintf(ser_writefd, "%s %s %u %s\n", [method, endpoint, strlen(content), path]);
    fprintf(ser_writefd, "%s\n", [content]);

    # read response header
    # TODO: [bug] buffer overflow on reading into textbuf
    # TODO: [bug] fscanf format string should need a trailing "\n", but the xscanf bug means it always consumes 1 more character than asked
    var length;
    fscanf(ser_readfd, "%s %d", [ser_textbuf, &length]);

    var ok = (strcmp(ser_textbuf, "ok") == 0);

    # read response body
    var need = length;
    var n;
    var ch;
    while (need) {
        n = read(ser_readfd, &ch, 1);
        if (n == 0) {
            fprintf(2, "error: read: eof on serial\n", 0);
            exit(1);
        };
        if (n < 0) {
            fprintf(2, "error: read: %s\n", [strerror(n)]);
            exit(1);
        };
        cb(ok, ch);
        need--;
    };

    # read trailing \n
    if (fgetc(ser_readfd) != '\n') ok = 0;
    return ok;
};

var ser_request_sb;
ser_request = func(method, endpoint, path, content) {
    ser_request_sb = sbnew();
    var ok = ser_request_p(method, endpoint, path, content, func(ok, ch) {
        sbputc(ser_request_sb, ch);
    });
    var str = strdup(sbbase(ser_request_sb));
    sbfree(ser_request_sb);
    return [ok, str];
};

ser_puts_cb = func(ok, chunklen, content) {
    while (chunklen--)
        putchar(*(content++));
};

# sync the serial connection by waiting until nothing is waiting
# TODO: [bug] this doesn't work; what if we're stuck inside the body of a contentful request?
#             how do we sync then? should there be an escape character that always syncs up?
ser_sync = func() {
    # give a few blank lines so that the other side knows to reset
    fputs(ser_writefd, "\n\n\n\n\n");

    # wait until the other side isn't trying to send anything
    var i;
    while (1) {
        i = 1000;
        while ((read(ser_writefd, 0, 0) == 0) && --i);
        if (i == 0) break;
        read(ser_writefd, 0, 1);
    };
};
