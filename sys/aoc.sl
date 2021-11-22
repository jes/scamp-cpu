# Advent of Code client

include "serial.sl";
include "strbuf.sl";

var args = cmdargs()+1;

var usage_get = "aoc get YEAR DAY";
var usage_input = "aoc input YEAR DAY";
var usage_submit = "aoc submit YEAR DAY PART ANSWER";

if (!*args) {
    fprintf(2, "usage: %s\n       %s       \n%s\n", [usage_get, usage_input, usage_submit]);
    exit(1);
};

var path;
var ok;

var str = malloc(16384);
*str = 0;
var strp = str;
# TODO: [bug] buffer overflow
var cb = func(ok, len, content) {
    while (len--) {
        fputc(2, *content);
        *(strp++) = *(content++);
    };
    *strp = 0;
};

if (strcmp(args[0], "get") == 0) {
    if ((!args[1]) || (!args[2]) || args[3]) {
        fprintf(2, "usage: %s\n", [usage_get]);
        exit(1);
    };
    path = sprintf("/%s/%s", [args[1], args[2]]);
    ok = ser_get_p("aoc", path, 0, cb);
} else if (strcmp(args[0], "input") == 0) {
    if ((!args[1]) || (!args[2]) || args[3]) {
        fprintf(2, "usage: %s\n", [usage_input]);
        exit(1);
    };
    path = sprintf("/%s/%s/input", [args[1], args[2]]);
    ok = ser_get_p("aoc", path, 0, cb);
} else if (strcmp(args[0], "submit") == 0) {
    if ((!args[1]) || (!args[2]) || (!args[3]) || (!args[4]) || args[5]) {
        fprintf(2, "usage: %s\n", [usage_submit]);
        exit(1);
    };
    path = sprintf("/%s/%s/%s", [args[1], args[2], args[3]]);
    ok = ser_put_p("aoc", path, args[4], cb);
} else {
    fprintf(2, "usage: %s\n       %s\n", [usage_get, usage_submit]);
    exit(1);
};

puts(str);

if (!ok) putchar('\n');
