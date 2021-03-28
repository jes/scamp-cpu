include "stdio.sl";
include "stdlib.sl";
include "sys.sl";
include "malloc.sl";

# TODO: [bug] support numbers > 16-bit

var usage = func() {
    fputs(2,"usage: wc [-cwl]\n");
    exit(1);
};

var argc = 0;
var argw = 0;
var argl = 0;

var getopts = func(opts) {
    while (*opts) {
        if (*opts == 'c') argc = 1
        else if (*opts == 'w') argw = 1
        else if (*opts == 'l') argl = 1
        else usage();
        opts++;
    };
};

var args = cmdargs()+1;

while (*args) {
    if (**args == '-') {
        getopts((*args)+1);
    } else {
        usage();
    };
    args++;
};

var inwhite = 1;

var chars = 0;
var words = 0;
var lines = 0;

var wc = func(s) {
    while(*s) {
        chars++;
        if (*s == '\n') lines++;
        if (iswhite(*s)) {
            inwhite = 1;
        } else {
            if (inwhite) words++;
            inwhite = 0;
        };
        s++;
    };
};

var bufsz = 254;
var buf = malloc(bufsz);
var n;
while (1) {
    n = read(0, buf, bufsz);
    if (n == 0) break;
    if (n < 0) {
        fprintf(2, "read: %s\n", [strerror(n)]);
        exit(1);
    };
    *(buf+n) = 0;
    wc(buf);
};

if (argc) printf("%d\n", [chars])
else if (argw) printf("%d\n", [words])
else if (argl) printf("%d\n", [lines])
else printf("%d\t%d\t%d\n", [lines,words,chars]);
