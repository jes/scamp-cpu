# Based on the "Example Storage Allocator" from chapter 8 of K&R Second Edition

include "stdio.sl";
include "stdlib.sl";
include "sys.sl";

# return a pointer to "sz" words of unused memory
var sbrk = func(sz) {
    var oldtop = TOP;
    TOP = TOP + sz;
    if (TOP ge osbase() || TOP lt oldtop) {
        fputs(2, "out of memory\n");
        exit(1);
    };
    return oldtop;
};

# The "free list" is a circularly linked list of free blocks. Each block header
# is 2 words: the first word is a pointer to the next item in the list, the
# second element is the size of the block.
#
# foo[0] -> next block
# foo[1] -> size of block, including header
# foo[2..] -> free space
#
# start off with a list of 1 element of 0 size
var freep = [0, 0];
*freep = freep;

var free = func(ap) {
    if (ap == 0) return 0;

    if (ap lt &TOP) {
        fprintf(2, "free'd static pointer: 0x%x\n", [ap]);
        exit(1);
    };
    var bp = ap-2; # point to block header

    var p = freep;
    while (!((bp gt p) && (bp lt p[0]))) {
        if (p ge p[0]) # next block wraps around to start
            if ((bp gt p) || (bp lt p[0])) # freed block at start or end of arena
                break;
        p = p[0];
    };

    if ((bp + bp[1]) == p[0]) { # join to upper neighbour
        *(bp+1) = bp[1] + p[0][1];
        *bp = p[0][0];
    } else {
        *bp = p[0];
    };

    if ((p + p[1]) == bp) { # join to lower neighbour
        *(p+1) = p[1] + bp[1];
        *p = bp[0];
    } else {
        *p = bp;
    };

    freep = p;
};

var morecore = func(sz) {
    if (sz < 1024)
        sz = 1024;
    var p = sbrk(sz);
    *(p+1) = sz;
    free(p+2);
    return freep;
};

var malloc = func(sz) {
    var p;
    var prevp;
    var origsz = sz;

    # sz needs to include block header, and align on 2-word boundaries
    sz = sz + 2 + (sz&1);

    prevp = freep;
    p = freep[0];
    while (1) {
        if (p[1] ge sz) { # big enough
            if (p[1] == sz) { # exactly
                *prevp = p[0];
            } else { # allocate tail end
                *(p+1) = p[1]-sz; # block size gets shorter by the size of the new block
                p = p+p[1]; # point to new block
                *(p+1) = sz; # set size of new block
            };
            freep = prevp;
            return p+2; # return pointer to new space
        };

        if (p == freep) # wrapped around free list
            p = morecore(sz);
        prevp = p;
        p = p[0];
    };
};

var realloc = func(p, sz) {
    var bp = p-2;
    var oldsz = bp[1];

    # TODO: [perf] if there's free space immediately after p, just grow into it

    var newp = malloc(sz);
    var copysz = oldsz;
    if (sz < oldsz) copysz = sz;

    var dest = newp;
    var src = p;
    while (copysz--) *(dest++) = *(src++);

    free(p);

    return newp;
};

var cons = func(a,b) {
    var tuple = malloc(2);
    *tuple = a;
    *(tuple+1) = b;
    return tuple;
};
