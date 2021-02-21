include "stdio.sl";
include "stdlib.sl";

extern TOP;
var malloc = func(sz) {
    var oldtop = TOP;
    TOP = TOP + sz;
    if ((TOP&0xff00) == 0xff00) { # TODO: use unsigned >= operator when it exists
        puts("out of memory\n");
        exit(1);
    };
    return oldtop;
};

var free = func(p) {
    # TODO: free
};


