# hash table
#
# ht[0] = allocated size
# ht[1] = used slots
# ht[2] = table
#
# each element of the table is either 0 (unused), or
# a pointer to a cons(key,val)

include "malloc.sl";
include "stdlib.sl";
include "string.sl";

var htnew = func() {
    var ht = malloc(3);
    *(ht+0) = 32;
    *(ht+1) = 0;
    *(ht+2) = malloc(32);
    memset(ht[2], 0, 32);
    return ht;
};

var htfree = func(ht) {
    var i = 0;
    var p;
    while (i != ht[0]) {
        p = ht[2][i];
        if (p) {
            free(car(p));
            free(p);
        };
        i++;
    };
    free(ht[2]);
    free(ht);
};

var htsize = func(ht) {
    return ht[0];
};
var htused = func(ht) {
    return ht[1];
};

var htput;

var htgrow = func(ht) {
    # XXX: this is a bit horrid; we create a new hash table,
    # hack its size, insert all of our elements into it, then
    # swap the arrays and sizes, then free the spare
    var newht = htnew();
    free(newht[2]);

    var newsize = htsize(ht)+htsize(ht);
    var newarr = malloc(newsize);
    memset(newarr, 0, newsize);
    *(newht+0) = newsize;
    *(newht+2) = newarr;

    var i = 0;
    var p;
    while (i != htsize(ht)) {
        p = ht[2][i];
        if (p)
            htput(newht, car(p), cdr(p));
        i++;
    };

    # now "newht" has all the elements, we want to swap its
    # array with ours and then free it
    *(newht+0) = htsize(ht);
    *(ht+0) = newsize;
    *(newht+2) = ht[2];
    *(ht+2) = newarr;
    htfree(newht);
};

var hashstr = func(str) {
    var h = 0;
    var i = 0;

    while (*str) {
        h = shl(h, 1) + *str + i++ + 997;
        str++;
    };

    return h;
};

# return pointer to slot in ht for key
# (mainly for "internal" use - library users probably want htget/htput)
var htfind = func(ht, key) {
    var n = hashstr(key);
    var idx;
    # idx = n mod htsize
    idx = n & (htsize(ht)-1);

    var orig_idx = idx;

    # linear probe to find a free slot
    var p = ht[2]+idx;
    var endp = ht[2]+htsize(ht);
    while (p) {
        if (strcmp(key, car(p)) == 0) break; # found
        p++;
        if (p == endp) p = ht[2];
    };

    return p;
};

# return the cons of (key,val) for "key", if found, or 0 otherwise
var htget = func(ht, key) {
    var p = htfind(ht, key);
    return *p;
};

# "key" is a string
htput = func(ht, key, val) {
    # create more space if more than 50% used
    var used = htused(ht);
    if (used+used > htsize(ht))
        htgrow(ht);

    var p = htfind(ht, key);
    if (*p) {
        setcdr(*p, val);
    } else {
        *p = cons(strdup(key), val);
        *(ht+1) = ht[1] + 1;
    };
};
