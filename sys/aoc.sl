# Advent of Code client

include "serial.sl";
include "strbuf.sl";

var linecount = func(s) {
    var c = 0;
    while (*s) {
        if (*s == '\n') c++;
        s++;
    };
    return c;
};

var args = cmdargs()+1;

var usage_get = "aoc get YEAR DAY";
var usage_part2 = "aoc part2 YEAR DAY";
var usage_input = "aoc input YEAR DAY";
var usage_submit = "aoc submit YEAR DAY PART ANSWER";

if (!*args) {
    fprintf(2, "usage: %s\n       %s\n       %s\n       %s\n", [usage_get, usage_part2, usage_input, usage_submit]);
    exit(1);
};

var path;
var ok;

var str = malloc(16384);
*str = 0;
var strp = str;
# TODO: [bug] buffer overflow
var cb = func(ok, ch) {
    fputc(2, ch);
    *(strp++) = ch;
};

ser_sync();

var to_stdout = 1;
var show_size = 0;

if (strcmp(args[0], "get") == 0) {
    if ((!args[1]) || (!args[2]) || args[3]) {
        fprintf(2, "usage: %s\n", [usage_get]);
        exit(1);
    };
    path = sprintf("/%s/%s", [args[1], args[2]]);
    ok = ser_get_p("aoc", path, 0, cb);
} else if (strcmp(args[0], "part2") == 0) {
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
    ok = ser_put_p("aoc", path, args[4], cb);
    to_stdout = 0;
} else {
    fprintf(2, "usage: %s\n       %s\n", [usage_get, usage_submit]);
    exit(1);
};

*strp = 0;

if (ok && show_size) {
    fprintf(2, "%d characters\n", [strlen(str)]);
    fprintf(2, "%d lines\n", [linecount(str)]);
};

if (to_stdout) {
    puts(str);
    if (!ok) putchar('\n');
};
