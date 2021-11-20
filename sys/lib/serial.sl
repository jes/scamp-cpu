# serial port protocol handling

# the "_p" functions allow retrieval of responses "piecewise" via a callback

include "stdio.sl";
include "malloc.sl";
include "strbuf.sl";

var ser_readfd = 4;
var ser_writefd = 4;
var ser_textbuf_sz = 259;
var ser_textbuf = malloc(ser_textbuf_sz);

# forward declarations
var ser_get;
var ser_put;
var ser_get_p;
var ser_put_p;
var ser_readbytes;
var ser_writebytes;
var ser_readpacket;
var ser_writepacket;
var ser_read;
var ser_readline;
var ser_write;
var ser_request;
var ser_request_p;
var ser_puts_cb;
var ser_sync;

ser_get = func(endpoint, path, content) return ser_request("get", endpoint, path, content);
ser_put = func(endpoint, path, content) return ser_request("put", endpoint, path, content);

ser_get_p = func(endpoint, path, content, cb) return ser_request_p("get", endpoint, path, content, cb);
ser_put_p = func(endpoint, path, content, cb) return ser_request_p("put", endpoint, path, content, cb);

ser_readbytes = func(buf, sz) {
    var need = sz;
    var n;
    var i;
    while (need) {
        n = read(ser_readfd, buf, need);
        if (n == 0) {
            fprintf(2, "error: read: eof on serial\n", 0);
            exit(1);
        };
        if (n < 0) {
            fprintf(2, "error: read: %s\n", [strerror(n)]);
            exit(1);
        };

        need = need - n;
        buf = buf + n;
    };
};

ser_writebytes = func(buf, sz) {
    var need = sz;
    var n;
    while (need) {
        n = write(ser_writefd, buf, need);
        if (n == 0) {
            fprintf(2, "error: write: eof on serial\n", 0);
            exit(1);
        };
        if (n < 0) {
            fprintf(2, "error: write: %s\n", [strerror(n)]);
            exit(1);
        };
        need = need - n;
        buf = buf + n;
    };
};

# read packet into buf and return size
ser_readpacket = func(buf) {
    var soh;
    var size;
    var checksum;
    var sum;
    var i;

    while (1) {
        while (1) {
            # keep reading until we get SOH
            ser_readbytes(&soh, 1);
            if (soh == 0x01) break;
        };

        ser_readbytes(&size, 1);
        ser_readbytes(buf, size);
        ser_readbytes(&checksum, 1);

        sum = soh + size + checksum;
        i = 0;
        while (i < size) {
            sum = sum + buf[i];
            i++;
        };

        sum = sum & 0xff;

        if (sum != 0) {
            # checksum failed: send NAK and try again
            ser_writebytes([0x15], 1);
            continue;
        };

        # checksum good: send ACK and return size
        ser_writebytes([0x06], 1);
        return size;
    };
};

ser_writepacket = func(buf, sz) {
    if (sz gt 255) {
        fprintf(2, "error: ser_writepacket: length too long (%u)\n", [sz]);
        exit(1);
    };
    var soh = 0x01;
    var sum = soh + sz;
    var i = 0;
    while (i < sz) {
        sum = sum + buf[i];
        i++;
    };
    var checksum = 0x100 - sum;

    var ack;

    while (1) {
        ser_writebytes(&soh, 1);
        ser_writebytes(&sz, 1);
        ser_writebytes(buf, sz);
        ser_writebytes(&checksum, 1);

        ser_readbytes(&ack, 1);
        if (ack == 0x06) break; # ACK - success
        if (ack == 0x15) continue; # NAK - resend
        fprintf(2, "unexpected packet response: %02x\n", [ack]);
        exit(1);
    };
};

ser_read = func(buf, sz) {
    sz++; # grab trailing \n

    var n;

    while (sz) {
        n = ser_readpacket(buf);
        buf = buf + n;
        sz = sz - n;
        # TODO: [bug] buffer overflows before we exit
        if (sz < 0) {
            fprintf(2, "error: size becomes negative\n", 0);
            exit(1);
        };
    };
};

ser_readline = func(buf, maxsz) {
    var n;

    while (1) {
        n = ser_readpacket(buf);
        buf = buf + n;
        maxsz = maxsz - n;
        # TODO: [bug] buffer overflows before we exit
        if (maxsz < 0) {
            fprintf(2, "error: maxsz becomes negative\n", 0);
            exit(1);
        };
        if (buf[-1] == '\n') { # TODO: what's better?
            *buf = 0;
            break;
        }
    };
};

ser_write = func(p, sz) {
    while (sz > 255) {
        ser_writepacket(p, 255);
        p = p + 255;
        sz = sz - 255;
    };
    if (sz) ser_writepacket(p, sz);
};

# make a request over the serial connection, return 1 if ok and 0 otherwise
# call cb(ok, chunklen, content) for each chunk of content
# TODO: [bug] what about request bodies too large to buffer in memory?
# TODO: [bug] what about request/response bodies that contain nul bytes?
ser_request_p = func(method, endpoint, path, content, cb) {
    if (!content) content = "";

    # put serial port in raw mode
    serflags(ser_readfd, 0);
    serflags(ser_writefd, 0);

    # send request
    var data = sprintf("%s %s %u %s\n%s\n", [method, endpoint, strlen(content), path, content]);
    ser_write(data, strlen(data));

    # read response header
    ser_readline(ser_textbuf, ser_textbuf_sz);
    var p = strchr(ser_textbuf, ' ');
    if (!p) {
        fprintf(2, "error: response header has no space\n", 0);
        exit(1);
    };
    *p = 0;
    var length = atoi(p+1);

    var ok = (strcmp(ser_textbuf, "ok") == 0);

    # read response body
    var n;
    while (length) {
        n = ser_readpacket(ser_textbuf);
        if (n > length) n = length;
        cb(ok, n, ser_textbuf);
        length = length - n;
    };

    # TODO: [bug] should we make sure we read the trailing \n?
    return ok;
};

var ser_request_sb;
ser_request = func(method, endpoint, path, content) {
    ser_request_sb = sbnew();
    var ok = ser_request_p(method, endpoint, path, content, func(ok, chunklen, content) {
        while (chunklen--) sbputc(ser_request_sb, *(content++));
    });
    var str = strdup(sbbase(ser_request_sb));
    sbfree(ser_request_sb);
    return [ok, str];
};

ser_puts_cb = func(ok, chunklen, content) {
    while (chunklen--)
        putchar(*(content++));
};

# sync the serial connection by making a ping request and waiting for the reply
# TODO: [bug] this doesn't work; what if we're stuck inside the body of a contentful request?
#             how do we sync then? should there be an escape character that always syncs up?
ser_sync = func() {
    var response;
    var n;
    var str;
    var sunc = 0;
    while (!sunc) {
        n = random();
        str = strdup(utoa(n));
        response = ser_get("ping", str, 0);
        free(str);
        if (response[0] && (strncmp(response[1], "pong:", 5) == 0) && (atoi(response[1]+5) == n)) sunc = 1;
        free(response[1]);
        if (!sunc) fputs(2, "syncing...\n");
    };
};
