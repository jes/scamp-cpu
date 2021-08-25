# sorting test: read lines into memory, sort, print out
#
# TODO: [perf] long-term, this should swap to disk so that it can sort longer inputs

include "bufio.sl";
include "grarr.sl";
include "malloc.sl";
include "stdlib.sl";
include "string.sl";

var in = bfdopen(0, O_READ);
var out = bfdopen(1, O_WRITE);

var bufsz = 1024;
var buf = malloc(bufsz);

var strings = grnew();

while (bgets(in, buf, bufsz))
    grpush(strings, strdup(buf));

sort(grbase(strings), grlen(strings), strcmp);

grwalk(strings, puts);
