# Based on the "Example Storage Allocator" from chapter 8 of K&R Second Edition

var malloc;
var free;
var realloc;

include "stdio.sl";
include "stdlib.sl";
include "sys.sl";

# return a pointer to "sz" words of unused memory
var sbrk = func(sz) {
    var oldtop = TOP;
    var newtop = TOP + sz;
    if (newtop ge osbase() || newtop lt oldtop)
        return 0;
    TOP = newtop;
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

var init_sp = *0xffff;

free = func(ap) {
    if (ap == 0) return 0;

    if (ap lt init_sp) {
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
        bp[1] = bp[1] + p[0][1];
        *bp = p[0][0];
    } else {
        *bp = p[0];
    };

    if ((p + p[1]) == bp) { # join to lower neighbour
        p[1] = p[1] + bp[1];
        *p = bp[0];
    } else {
        *p = bp;
    };

    freep = p;
};

var morecore = func(needsz) {
    var sz = needsz;
    if (sz lt 1024) sz = 1024;

    var p = sbrk(sz);
    if (!p) {
        # not enough space for 1024? try just what we need
        sz = needsz;
        p = sbrk(sz);
    };
    if (!p) {
        # oom
        # TODO: [nice] can we print a call stack? or at least the return
        #       address of malloc()?
        fputs(2, "out of memory\n");
        exit(1);
    };

    p[1] = sz;
    free(p+2);
    return freep;
};

malloc = func(sz) {
    var p;
    var q;
    var prevp;
    var origsz = sz;

    # sz needs to include block header, and align on 2-word boundaries
    sz = sz + 2 + (sz&1);

    prevp = freep;
    p = freep[0];
    while (1) {
        if (p[1] ge sz) { # big enough
            if (p[1] == sz) { # exactly
                prevp[0] = p[0];
            #} else { # allocate tail end
            #    p[1] = p[1]-sz; # block size gets shorter by the size of the new block
            #    p = p+p[1]; # point to new block
            #    p[1] = sz; # set size of new block
            #};
            } else { # allocate head end
                q = p+sz;
                q[0] = p[0];
                q[1] = p[1]-sz;
                prevp[0] = q;
                p[1] = sz;
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

realloc = func(p, sz) {
    var bp = p-2;
    var oldsz = bp[1];

    # if we can shrink in-place, do so
    if (sz+2 le oldsz) {
        if (sz+4 ge oldsz) return p; # no-op if only shrinking by 0..2
        bp[1] = sz+2;
        bp = p+sz;
        bp[1] = oldsz-(sz+2);
        free(bp+2);
        return p;
    };

    # otherwise: malloc, memcpy, free
    var newp = malloc(sz);
    var copysz = oldsz;
    if (sz < oldsz) copysz = sz;

    memcpy(newp, p, copysz);

    free(p);

    return newp;
};

var cons = func(a,b) {
    var tuple = malloc(2);
    *tuple = a;
    tuple[1] = b;
    return tuple;
};

var cons3 = func(a,b,c) {
    var p = malloc(3);
    p[0] = a; p[1] = b; p[2] = c;
    return p;
};

var cons4 = func(a,b,c,d) {
    var p = malloc(4);
    p[0] = a; p[1] = b; p[2] = c; p[3] = d;
    return p;
};

var zmalloc = func(sz) {
    var p = malloc(sz);
    while (sz--) *(p+sz) = 0;
    return p;
};

# vector zmalloc, for example:
#   var p = vzmalloc([10,5,3]);
# the final element is p[9][4][2];
var vzmalloc = func(szs) {
    if (!szs[0]) return 0;
    if (!szs[1]) return zmalloc(szs[0]);
    var i = 0;
    var p = malloc(szs[0]);
    while (i != szs[0])
        p[i++] = vzmalloc(szs+1);
    return p;
};

# free memory allocated with vzmalloc
var vfree = func(p, szs) {
    if (!szs[0]) return 0;
    if (!szs[1]) return free(p);
    var i = 0;
    while (i != szs[0])
        vfree(p[i++], szs+1);
    free(p);
    return 0;
};
