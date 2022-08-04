# hex dump

include "bufio.sl";
include "stdio.sl";
include "sys.sl";
include "malloc.sl";

var bufsz = 256;
var buf = malloc(bufsz);

var linebuf = malloc(8);
var linepos = 0;
var first = 1;

var out = bfdopen(1, O_WRITE);

var show_text_line = func() {
    var end = 8;

    var n;
    if ((linepos & 7) != 0) {
        n = 8 - (linepos&7);
        while (n--) bputs(out, "     ");
        end = linepos & 7;
    };

    bputs(out, "  |");
    var i = 0;
    var ch;
    while (i < end) {
        ch = linebuf[i++] & 0xff;
        if (ch >= ' ' && ch <= '~') bputc(out, ch)
        else bputc(out, '.');
    };
    bputs(out, "|\n");
};

var output = func(ch) {
    if ((linepos & 7) == 0) {
        if (!first) show_text_line()
        else first = 0;

        bprintf(out, "%04x: ", [linepos]);
    };

    *(linebuf+(linepos&7)) = ch;

    bprintf(out, " %04x", [ch]);
};

var hd = func(name) {
    var fd = 0;
    if (name) {
        fd = open(name, O_READ);
        if (fd < 0) {
            fprintf(2, "hd: open %s: %s\n", [name, strerror(fd)]);
            return 0;
        };
    };
    var in = bfdopen(fd, O_READ);

    var n;
    var i;
    while (1) {
        n = bread(in, buf, bufsz);
        if (n == 0) break;
        if (n < 0) {
            fprintf(2, "hd: read %d: %s\n", [fd, strerror(n)]);
            break;
        };

        i = 0;
        while (i < n) {
            output(buf[i++]);
            linepos++;
        };
    };
    bclose(in);

    if ((linepos & 7) != 0) show_text_line();
};

var args = cmdargs()+1;

if (args[1]) {
    fputs(2, "usage: hd [FILE]\n");
    exit(1);
};

if (*args) hd(*args)
else       hd(0);

bclose(out);

exit(0);
