# Grow-able arrays
#
# TODO: [perf] provide some way to switch between exponential and geometric
#       growth strategies
#
# gr[0] = number of elements
# gr[1] = allocated space for elements
# gr[2] = pointer to element space

var grnew;
var grpush;
var grtrunc;
var grbase;

include "malloc.sl";
include "stdlib.sl";

const grarr_maxgrow = 1024;

grnew = func() {
    var gr = malloc(3);
    *gr = 0;
    gr[1] = 32;
    gr[2] = malloc(gr[1]);
    return gr;
};

var grfree = func(gr) {
    free(gr[2]);
    free(gr);
};

grpush = func(gr, el) {
    var n;
    var grow;
    if (gr[0] == gr[1]) { # need more space
        grow = gr[1];
        if (grow > grarr_maxgrow) grow = grarr_maxgrow;
        n = gr[1] + grow; # increase the length
        gr[2] = realloc(gr[2], n);
        gr[1] = n;
    };
    n = *gr;
    var p = gr[2];
    p[n] = el;
    *gr = n+1;
};

var grpop = func(gr) {
    var p = gr[2];
    var len = gr[0];
    if (len == 0) return 0; # TODO: [nice] what value should we return if there are none??
    var val = p[len-1]; # grab final value
    *gr = (*gr)-1; # decrement length
    return val;
};

grtrunc = func(gr, at) {
    var len = gr[0];
    if (at lt len) *gr = at;
};

grbase = func(gr) return gr[2];

var grset = func(gr, i, el) {
    var p = gr[2];
    if (i ge gr[0]) {
        fprintf(2, "out of bounds grset: N=%d, i=%d\n", [gr[0], i]);
        exit(1);
    };
    p[i] = el;
};

var grget = func(gr, i) {
    var p = gr[2];
    if (i ge gr[0]) {
        fprintf(2, "out of bounds grget: N=%d, i=%d\n", [gr[0], i]);
        exit(1);
    };
    return p[i];
};

var grlen = func(gr) {
    return *gr;
};

# call cb() on each value in the growarray
var grwalk = func(gr, cb) {
    var i = 0;
    var max = gr[0];
    var p = gr[2];

    while (i != max) {
        cb(p[i]);
        i++;
    };
};

# call cb(findval, val) on each value in the growarray
# if cb(findval, val) returns nonzero, break the loop and return val
# return 0 if the value is not found
var grfind = func(gr, findval, cb) {
    var i = 0;
    var p = gr[2];
    var maxp = p + gr[0];

    while (maxp-p) { # while p != maxp
        if (cb(findval, *p)) return *p;
        p++;
    };

    return 0;
};

var grsort = func(gr, cmp) {
    return sort(grbase(gr), grlen(gr), cmp);
};

# reverse the elements in the growarray
var grrev = func(gr) {
    var i = 0;
    var j = grlen(gr)-1;

    var tmp;

    # TODO: [perf] this could operate directly on the underlying array
    while (i < j) {
        tmp = grget(gr, j);
        grset(gr, j, grget(gr, i));
        grset(gr, i, tmp);
        i++;
        j--;
    };

    return gr;
};
