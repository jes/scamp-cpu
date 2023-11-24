# Grow-able arrays
#
# TODO: [perf] provide some way to switch between exponential and geometric
#       growth strategies
#
# gr[0] = start index (first index of a real element)
# gr[1] = end index (first index that is past the end)
# gr[2] = allocated capacity
# gr[3] = pointer to element space

const GR_START = 0;
const GR_END = 1;
const GR_CAPACITY = 2;
const GR_PTR = 3;

var grnew;
var grpush;
var grtrunc;
var grbase;

include "malloc.sl";
include "stdlib.sl";

const grarr_maxgrow = 1024;

grnew = func() {
    var gr = malloc(4);
    gr[GR_START] = 0;
    gr[GR_END] = 0;
    gr[GR_CAPACITY] = 32;
    gr[GR_PTR] = malloc(gr[GR_CAPACITY]);
    return gr;
};

var grfree = func(gr) {
    free(gr[GR_PTR]);
    free(gr);
};

var grgrow = func(gr, atend) {
    var grow = gr[GR_CAPACITY];
    if (grow > grarr_maxgrow) grow = grarr_maxgrow;
    var newcap = gr[GR_CAPACITY] + grow; # increase the length
    var newptr = malloc(newcap);
    var curbase = gr[GR_PTR]+gr[GR_START];
    var curlen = gr[GR_END]-gr[GR_START];
    if (atend) {
        memcpy(newptr, curbase, curlen);
        gr[GR_START] = 0;
        gr[GR_END] = curlen;
    } else {
        memcpy(newptr+newcap-curlen, curbase, curlen);
        gr[GR_START] = newcap-curlen;
        gr[GR_END] = newcap;
    };
    free(gr[GR_PTR]);
    gr[GR_PTR] = newptr;
    gr[GR_CAPACITY] = newcap;
};

grpush = func(gr, el) {
    if (gr[GR_END] == gr[GR_CAPACITY]) grgrow(gr, 1);
    var n = gr[GR_END];
    gr[GR_END] = n+1;
    gr[GR_PTR][n] = el;
};

var grpop = func(gr) {
    if (gr[GR_END] == gr[GR_START]) return 0;
    gr[GR_END] = gr[GR_END]-1;
    return gr[GR_PTR][gr[GR_END]];
};

var grshift = func(gr) {
    if (gr[GR_END] == gr[GR_START]) return 0;
    var n = gr[GR_START];
    gr[GR_START] = n+1;
    return gr[GR_PTR][n];
};

var grunshift = func(gr, el) {
    if (gr[GR_START] == 0) grgrow(gr, 0);
    var n = gr[GR_START]-1;
    gr[GR_START] = n;
    gr[GR_PTR][n] = el;
};

grtrunc = func(gr, at) {
    var len = gr[GR_END] - gr[GR_START];
    if (at lt len) gr[GR_END] = gr[GR_START] + at;
};

grbase = func(gr) return gr[GR_PTR]+gr[GR_START];

var grset = func(gr, i, el) {
    if (i ge (gr[GR_END]-gr[GR_START])) {
        fprintf(2, "out of bounds grset: N=%d, i=%d\n", [gr[GR_END]-gr[GR_START], i]);
        exit(1);
    };
    gr[GR_PTR][gr[GR_START] + i] = el;
};

var grget = func(gr, i) {
    if (i ge (gr[GR_END]-gr[GR_START])) {
        fprintf(2, "out of bounds grget: N=%d, i=%d\n", [gr[GR_END]-gr[GR_START], i]);
        exit(1);
    };
    return gr[GR_PTR][gr[GR_START] + i];
};

var grlen = func(gr) {
    return gr[GR_END] - gr[GR_START];
};

# call cb() on each value in the growarray
var grwalk = func(gr, cb) {
    var i = gr[GR_START];
    var max = gr[GR_END];
    var p = gr[GR_PTR];

    while (i != max) {
        cb(p[i]);
        i++;
    };
};

# call cb(findval, val) on each value in the growarray
# if cb(findval, val) returns nonzero, break the loop and return val
# return 0 if the value is not found
var grfind = func(gr, findval, cb) {
    var p = gr[GR_PTR] + gr[GR_START];
    var maxp = gr[GR_PTR] + gr[GR_END];

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
