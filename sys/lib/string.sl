include "malloc.sl";
include "xprintf.sl";

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
        ld x, (r1)
        sub x, (r2)
        jz strcmp_cont
        ld r0, x
        ret

        strcmp_cont:
        inc r1
        inc r2
        jmp strcmp_loop
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

var strlen = func(s) {
    var ss = s;
    while (*ss) ss++;
    return ss - s;
};

var memset = func(s, val, len) {
    var ss = s;
    while (len--) *(s++) = val;
    return ss;
};

var memcpy = func(dest, src, len) {
    var dd = dest;
    while (len--) *(dest++) = *(src++);
    return dd;
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
    sprintf_len = 16;
    sprintf_output = malloc(sprintf_len);
    sprintf_p = sprintf_output;

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
