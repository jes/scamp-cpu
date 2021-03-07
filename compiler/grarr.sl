# Grow-able arrays
#
# The array doubles in size every time it needs to grow, such that n insertions
# only incurs O(lg n) realloc()s.
#
# gr[0] = number of elements
# gr[1] = allocated space for elements
# gr[2] = pointer to element space

include "malloc.sl";

var grnew = func() {
    var gr = malloc(3);
    *gr = 0;
    *(gr+1) = 32;
    *(gr+2) = malloc(32);
    return gr;
};

var grfree = func(gr) {
    free(gr[2]);
    free(gr);
};

var grpush = func(gr, el) {
    var n;
    if (gr[0] == gr[1]) { # need more space
        n = gr[1] + gr[1]; # double the length
        *(gr+2) = realloc(gr[2], n);
        *(gr+1) = n;
    };
    n = *gr;
    var p = gr[2];
    *(p+n) = el;
    *gr = *gr+1;
};

var grbase = func(gr) return gr[2];

var grset = func(gr, i, el) {
    var p = gr[2];
    *(p+i) = el;
};

var grget = func(gr, i) {
    var p = gr[2];
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
    var max = gr[0];
    var p = gr[2];

    while (i != max) {
        if (cb(findval, p[i])) return p[i];
        i++;
    };

    return 0;
};
