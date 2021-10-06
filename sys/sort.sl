# sorting test: read lines into memory, sort, print out
#
# TODO: [perf] long-term, this should swap to disk so that it can sort longer inputs

include "bufio.sl";
include "grarr.sl";
include "malloc.sl";
include "stdlib.sl";
include "string.sl";
include "getopt.sl";

var help = func(rc) {
    puts("usage: sort [options] < INPUT

options:
    -h   show this text
    -n   numeric sort
    -r   reverse sort
");
    exit(rc);
};

var rev = 0;
var num = 0;

var cmp = func(a, b) {
    var n;

    if (num) n = atoi(a) - atoi(b)
    else n = strcmp(a, b);

    if (rev) return -n;
    return n;
};

var args = getopt(cmdargs()+1, "", func(ch,arg) {
    if (ch == 'r') rev = 1
    else if (ch == 'n') num = 1
    else if (ch == 'h') help(0)
    else help(1);
});
if (*args) help(1);

var in = bfdopen(0, O_READ);
var out = bfdopen(1, O_WRITE);

var bufsz = 1024;
var buf = malloc(bufsz);

var strings = grnew();

while (bgets(in, buf, bufsz))
    grpush(strings, strdup(buf));

sort(grbase(strings), grlen(strings), cmp);

grwalk(strings, puts);
