include "bufio.sl";
include "malloc.sl";
include "sys.sl";

var LINES = 25;
var COLS = 80;

var bufsz = COLS;
var buf = malloc(bufsz);

var out = bfdopen(1, O_WRITE);

# put console in raw mode
serflags(3, 0);

var prompt = func(text) {
    bputs(out, text);
    bflush(out);
    var ch = fgetc(3); # read 1 char from the console

    # now rub out the prompt
    bputc(out, '\r');
    while (*(text++)) bputc(out, ' ');
    bputc(out, '\r');

    if (ch == 'q') exit(0);
};

var more = func(in) {
    var l = 0;

    while (bgets(in, buf, bufsz)) {
        bputs(out, buf);
        l++;

        if (l == LINES-1) {
            prompt("--MORE--");
            l = 0;
        };
    };
};

var in;

var args = cmdargs()+1;
if (!*args) {
    in = bfdopen(0, O_READ);
    more(in);
} else {
    while (*args) {
        in = bopen(*args, O_READ);
        if (in) {
            more(in);
        } else {
            bflush(out);
            fprintf(2, "more: %s: can't read\n", [*args]);
            bflush(out);
        };
        args++;
        if (*args) prompt("--MORE (next file)--");
    };
};

bflush(out);
