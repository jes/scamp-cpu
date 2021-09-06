var strlen;

include "malloc.sl";
include "xprintf.sl";
include "xscanf.sl";

# usage: strcmp(s1,s2)
# return a value:
#  <0  if s1 < s2
#   0  if s1 == s2
#  >0  if s1 > s2
var strcmp = asm {
    pop x
    ld r2, x # r2 = s2
    pop x
    ld r1, x # r1 = s1

    # while (*s1 && *s2)
    strcmp_loop:
        ld x, (r1)
        and x, (r2)
        jz strcmp_done

        # if (*s1 != *s2) return *s1-*s2
        ld x, (r1++)
        sub x, (r2++)
        jz strcmp_loop

        ld r0, x
        ret

    strcmp_done:

    # return *s1-*s2
    ld x, (r1)
    sub x, (r2)
    ld r0, x
    ret
};

# same as strcmp, but only look at up to n chars
var strncmp = func(s1,s2,n) {
    while (*s1 && *s2 && n) {
        if (*s1 != *s2) return *s1-*s2;
        s1++;
        s2++;
        n--;
    };

    if (n == 0) return 0;
    return *s1-*s2;
};

strlen = func(s) {
    var ss = s;
    while (*ss) ss++;
    return ss - s;
};

var memset = func(s, val, len) {
    var ss = s;
    while (len--) *(s++) = val;
    return ss;
};

#var memcpy = func(dest, src, len) {
#    var dd = dest;
#    while (len--) *(dest++) = *(src++);
#    return dd;
#};
#
# usage: memcpy(dest, src, len)
var memcpy = asm {
    pop x
    ld r1, x # len
    pop x
    ld r2, x # src
    pop x
    ld r3, x # dest
    ld r0, x # return

    # the memcpy loop is unrolled into groups of 8 words; when the
    # length to copy is not a multiple of 8 we need to jump into the
    # loop to skip over the first few copies

    # grab last 3 bits to work out where to jump
    ld r4, r1
    and r4, 7
    add r4, memcpy_offset
    ld x, (r4)
    ld r4, x

    # round length up to next multiple of 8
    or r1, 7
    inc r1
    # jump into loop
    jmp r4

    memcpy_loop:
        ld x, (r2++)
        ld (r3++), x
    memcpy7:
        ld x, (r2++)
        ld (r3++), x
    memcpy6:
        ld x, (r2++)
        ld (r3++), x
    memcpy5:
        ld x, (r2++)
        ld (r3++), x
    memcpy4:
        ld x, (r2++)
        ld (r3++), x
    memcpy3:
        ld x, (r2++)
        ld (r3++), x
    memcpy2:
        ld x, (r2++)
        ld (r3++), x
    memcpy1:
        ld x, (r2++)
        ld (r3++), x
    memcpy0:
        sub r1, 8
        jnz memcpy_loop

    memcpy_ret:
    ret

    memcpy_offset:
    .word memcpy0
    .word memcpy1
    .word memcpy2
    .word memcpy3
    .word memcpy4
    .word memcpy5
    .word memcpy6
    .word memcpy7
};

var strcpy = func(dest, src) {
    var dd = dest;
    while (*src) *(dest++) = *(src++);
    *dest = 0;
    return dd;
};

var strdup = func(s) {
    var ss = malloc(strlen(s)+1);
    strcpy(ss, s);
    return ss;
};

# allocate a string and format "args" into it according to "fmt"
var sprintf_len;
var sprintf_output;
var sprintf_p;
var sprintf = func(fmt, args) {
    sprintf_len = 64;
    sprintf_output = malloc(sprintf_len);
    sprintf_p = sprintf_output;

    *sprintf_output = 0;

    xprintf(fmt, args, func(ch) {
        var l = sprintf_p - sprintf_output;
        if (l == sprintf_len-1) {
            sprintf_len = l+l;
            sprintf_output = realloc(sprintf_output, sprintf_len);
            sprintf_p = sprintf_output + l;
        };

        *(sprintf_p++) = ch;
        *sprintf_p = 0;
    });

    return sprintf_output;
};

var sscanf_str;
var sscanf = func(str, fmt, args) {
    sscanf_str = str;
    xscanf(fmt, args, func() {
        return *(sscanf_str++);
    });
};

# TODO: [perf] this can be better
var strstr = func(haystack, needle) {
    var lenneedle = strlen(needle);

    while (*haystack) {
        if (strncmp(haystack, needle, lenneedle) == 0)
            return haystack;
        haystack++;
    };

    return 0;
};

var strchr = func(s, ch) {
    while (*s) {
        if (*s == ch) return s;
        s++;
    };

    return 0;
};
