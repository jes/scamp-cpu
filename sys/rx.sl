# rx - receive a file with xmodem from secondary serial port
# TODO: [nice] show debug info if "-v" or similar

include "stdio.sl";
include "sys.sl";

var CH_SOH = 0x01;
var CH_EOT = 0x04;
var CH_ACK = 0x06;
var CH_NAK = 0x15;

var packet = 1;
var buf = malloc(132);

serflags(4, 0); # raw mode

var readpacket = func() {
    var need = 132;
    var bufp = buf;
    var n;
    while (need) {
        n = read(4, bufp, need);
        if (n < 0) {
            fprintf(2, "error: read: %s\n", [strerror(n)]);
            exit(1);
        };
        need = need - n;
        bufp = bufp + n;

        if (*buf == CH_EOT) break;
    };
};

var ack = func() write(4, &CH_ACK, 1);
var nak = func() write(4, &CH_NAK, 1);

var chk = func() {
    var sum = 0;
    var n = 131;
    while (n--) {
        sum = sum + buf[n];
    };
    return (sum&0xff) == buf[131];
};

nak();

while (1) {
    readpacket();
    if (*buf == CH_EOT) {
        nak();
        readpacket();
        if (*buf != CH_EOT) {
            nak();
            continue;
        };
        break;
    };

    if (*buf != CH_SOH) {
        nak();
        continue;
    };

    if ((buf[1] != packet) || (buf[2] != (0xff - packet))) {
        nak();
        continue;
    };

    if (!chk()) {
        nak();
        continue;
    };

    write(1, buf+3, 128);
    fputc(2, '.');
    packet++;
    ack();
};

fputc(2, '\n');
