# hash table
#
# ht[0] = allocated size
# ht[1] = number of used slots
# ht[2..] = table
#
# each element of the table is 2 words: the first word is a pointer to the key
# (or 0 if the element is unused); the second word is the value
#
# the "key"s are strings that are *not* strdup()'d, so they need to be
# immutable and not free()'d until after you've finished using the hash table

include "malloc.sl";
include "stdlib.sl";
include "string.sl";

var htnew = func() {
    var ht = malloc(3);
    ht[0] = 32;
    ht[1] = 0;
    ht[2] = malloc(64); # 2x htsize because each element is 2 words
    memset(ht[2], 0, 64);
    return ht;
};

var htfree = func(ht) {
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
    var newarr = malloc(newsize+newsize);
    memset(newarr, 0, newsize+newsize);
    newht[0] = newsize;
    newht[2] = newarr;

    var i = 0;
    var p;
    while (i != htsize(ht)) {
        p = ht[2]+i+i;
        if (*p)
            htput(newht, p[0], p[1]);
        i++;
    };

    # now "newht" has all the elements, we want to swap its
    # array with ours and free it
    newht[2] = ht[2];
    htfree(newht);

    ht[0] = newsize;
    ht[2] = newarr;
};

#var hashstr = func(str) {
#    var h = 0;
#    var i = 997;
#    while (*str)
#        h = h+h+h + *(str++) + i++;
#    return h;
#};
# usage: hashstr(str)
var hashstr = asm {
    pop x
    ld r1, x # str
    ld r0, 0 # h
    ld r2, 997 # i

    hashstr_loop:
        # while (*str)
        test (r1)
        jz hashstr_ret

        # h = h+h+h
        ld r3, r0
        add r3, r0
        add r3, r0
        ld r0, r3

        # + *(str++)
        ld x, (r1++)
        add r0, x

        # + i++
        add r0, r2
        inc r2

        jmp hashstr_loop

    hashstr_ret:
        ret
};

# return pointer to slot in ht for key
# (mainly for "internal" use - library users probably want htget/htput)
#var htfind = func(ht, key) {
#    var n = hashstr(key);
#    # idx = n mod htsize
#    var idx = n & (htsize(ht)-1);
#
#    # linear probe to find the key, or the next free slot
#    var p = ht[2]+idx+idx;
#    var endp = ht[2]+htsize(ht)+htsize(ht);
#    while (*p) {
#        if (strcmp(key, *p) == 0) break; # found
#        p = p + 2;
#        if (p == endp) p = ht[2];
#    };
#
#    return p;
#};
# usage: htfind(ht, key)
var htfind = asm {
    # store return address
    ld (htfind_ret), r254

    pop x
    ld (htfind_key), x
    pop x
    ld (htfind_ht), x

    # n = hashstr(key)
    ld x, (htfind_key)
    push x
    call (_hashstr)
    ld (htfind_n), r0

    # s = htsize(ht)
    ld x, (htfind_ht)
    push x
    call (_htsize)
    ld (htfind_s), r0

    # idx = n & (s-1)
    ld x, (htfind_s)
    dec x
    and x, (htfind_n)
    ld (htfind_idx), x

    # p = ht[2]+idx+idx
    ld x, (htfind_ht)
    add x, 2
    ld x, (x)
    add x, (htfind_idx)
    add x, (htfind_idx)
    ld (htfind_p), x

    # endp = ht[2]+s+s
    ld x, (htfind_ht)
    add x, 2
    ld x, (x)
    add x, (htfind_s)
    add x, (htfind_s)
    ld (htfind_endp), x

    # while(*p)
htfind_loop:
    ld x, (htfind_p)
    test (x)
    jz htfind_done

    # if (strcmp(key, *p) == 0) break; # found
    ld x, (htfind_key)
    push x
    ld x, (htfind_p)
    ld x, (x)
    push x
    call (_strcmp)
    test r0
    jz htfind_done

    # p = p + 2;
    add (htfind_p), 2

    # if (p == endp) p = ht[2];
    ld x, (htfind_p)
    sub x, (htfind_endp)
    jnz htfind_loop

    ld x, (htfind_ht)
    add x, 2
    ld x, (x)
    ld (htfind_p), x

    jmp htfind_loop

htfind_done:
    # return p
    ld r0, (htfind_p)
    jmp (htfind_ret)

htfind_ht: .word 0
htfind_key: .word 0
htfind_ret: .word 0
htfind_n: .word 0
htfind_s: .word 0
htfind_idx: .word 0
htfind_p: .word 0
htfind_endp: .word 0
};

# return [key,val] for "key", if found, or 0 otherwise
var htgetkv = func(ht, key) {
    var p = htfind(ht, key);
    if (*p) return p;
    return 0;
};

# return val for "key" if found, or 0 otherwise
# (you need to use htgetkv() to distinguish "not found" from "val == 0")
var htget = func(ht, key) {
    var p = htfind(ht, key);
    if (*p) return p[1];
    return 0;
};

# htput() but skipping the htfind() where possible, using the "p" pointer
# already passed in
var htputp = func(ht, p, key, val) {
    # create more space if 75% full
    var used = htused(ht);
    var size = htsize(ht);
    if (used+used+used+used gt size+size+size) {
        htgrow(ht);
        p = htfind(ht, key);
    };

    if (!*p) ht[1] = ht[1] + 1;
    p[0] = key;
    p[1] = val;
};

# "key" is a string
htput = func(ht, key, val) {
    # create more space if 75% full
    var used = htused(ht);
    var size = htsize(ht);
    if (used+used+used+used gt size+size+size)
        htgrow(ht);

    var p = htfind(ht, key);
    if (!*p) ht[1] = ht[1] + 1;
    p[0] = key;
    p[1] = val;
};

# call cb(key, val) for each element of the table
var htwalk = func(ht, cb) {
    var i = 0;
    var p;

    while (i < htsize(ht)) {
        p = ht[2]+i+i;

        if (*p) cb(*p, p[1]);

        i++;
    };
};
