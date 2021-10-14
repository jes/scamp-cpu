# sx - send a file with xmodem to secondary serial port
# TODO: [nice] show debug info if "-v" or similar

include "stdio.sl";
include "sys.sl";

var CH_SOH = 0x01;
var CH_EOT = 0x04;
var CH_ACK = 0x06;
var CH_NAK = 0x15;
var CH_SUB = 0x1a;

var packet = 1;
var buf = malloc(132);
var seeneof = 0;

var readblock = func() {
    var need = 128;
    var bufp = buf+3;
    var n;
    while (need) {
        n = read(0, bufp, need);
        if (n < 0) {
            fprintf(2, "error: read stdin: %s\n", [strerror(n)]);
            exit(1);
        };
        if (n == 0) {
            seeneof = 1;
            while (need--) *(bufp++) = CH_SUB;
            break;
        };
        need = need - n;
        bufp = bufp + n;
    };
};

var chk = func() {
    var sum = 0;
    var n = 131;
    while (n--) {
        sum = sum + buf[n];
    };
    buf[131] = sum&0xff;
};

serflags(4, 0); # raw mode

# wait for initial NAK from remote side
while (fgetc(4) != CH_NAK);

var ch;
var finished = 0;
while (!finished) {
    buf[0] = CH_SOH;
    buf[1] = packet;
    buf[2] = 0xff-packet;
    readblock();
    chk();
    write(4, buf, 132);
    while (1) {
        read(4, &ch, 1);
        if (ch == CH_ACK) {
            fputc(2, '.');
            if (seeneof) finished = 1;
            packet++;
            break;
        } else if (ch == CH_NAK) {
            fputc(2, '!');
            break;
        };
    };
};

fputc(2, '\n');
