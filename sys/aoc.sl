# Advent of Code client

include "bufio.sl";
include "serial.sl";
include "strbuf.sl";

var args = cmdargs()+1;

var usage_get = "aoc get YEAR DAY";
var usage_part2 = "aoc part2 YEAR DAY";
var usage_input = "aoc input YEAR DAY";
var usage_submit = "aoc submit YEAR DAY PART ANSWER";
var usage_rank = "aoc rank YEAR";

var usage = func() {
    fprintf(2, "usage: %s\n       %s\n       %s\n       %s\n       %s\n", [usage_get, usage_part2, usage_input, usage_submit, usage_rank]);
    exit(1);
};

if (!*args) usage();

var path;
var ok;

var to_stdout = 1;
var out = bfdopen(1, O_WRITE);

var nlines = 0;
var nchars = 0;

var cb = func(ok, buf, len) {
    if (to_stdout) bwrite(out, buf, len);
    write(2, buf, len);

    nchars = nchars + len;
    while (len--)
        if (buf[len] == '\n') nlines++;
};

ser_sync();

var show_size = 0;

if (strcmp(args[0], "get") == 0) {
    if ((!args[1]) || (!args[2]) || args[3]) {
        fprintf(2, "usage: %s\n", [usage_get]);
        exit(1);
    };
    path = sprintf("/%s/%s", [args[1], args[2]]);
    ok = ser_get_p("aoc", path, 0, cb);
} else if (strcmp(args[0], "part2") == 0 || strcmp(args[0], "get2") == 0) {
    if ((!args[1]) || (!args[2]) || args[3]) {
        fprintf(2, "usage: %s\n", [usage_part2]);
        exit(1);
    };
    path = sprintf("/%s/%s/part2", [args[1], args[2]]);
    ok = ser_get_p("aoc", path, 0, cb);
} else if (strcmp(args[0], "input") == 0) {
    if ((!args[1]) || (!args[2]) || args[3]) {
        fprintf(2, "usage: %s\n", [usage_input]);
        exit(1);
    };
    path = sprintf("/%s/%s/input", [args[1], args[2]]);
    ok = ser_get_p("aoc", path, 0, cb);
    show_size = 1;
} else if (strcmp(args[0], "submit") == 0) {
    if ((!args[1]) || (!args[2]) || (!args[3]) || (!args[4]) || args[5]) {
        fprintf(2, "usage: %s\n", [usage_submit]);
        exit(1);
    };
    path = sprintf("/%s/%s/%s", [args[1], args[2], args[3]]);
    to_stdout = 0;
    ok = ser_put_p("aoc", path, args[4], cb);
} else if (strcmp(args[0], "rank") == 0) {
    if (!args[1] || args[2]) {
        fprintf(2, "usage: %s\n", [usage_rank]);
        exit(1);
    };
    path = sprintf("/%s", [args[1]]);
    to_stdout = 0;
    ok = ser_get_p("aocrank", path, 0, cb);
} else {
    usage();
};

if (ok && show_size) {
    fprintf(2, "%u characters\n", [nchars]);
    fprintf(2, "%u lines\n", [nlines]);
};

if (to_stdout && !ok) bputc(out, '\n');

bflush(out);
