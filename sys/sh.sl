# SCAMP shell

include "malloc.sl";
include "stdio.sl";
include "sys.sl";

var buf = malloc(256);

var args = malloc(32);
var i;
var p;

while (1) {
    puts("$ ");

    i = gets(buf, 256);
    if (i == 0) break;

    p = buf;
    i = 0;
    while (*p && iswhite(*p)) p++;

    *args = p;
    i = 1;
    while (*p) {
        while (*p && !iswhite(*p)) p++;
        if (*p) {
            *(p++) = 0;
            while (*p && iswhite(*p)) p++;
            if (*p) *(args+i) = p
            else *(args+i) = 0;
        } else {
            *(args+i) = 0;
        };
        i++;
    };

    p = args;
    while (*p) {
        printf("arg: [%s]\n", [*p]);
        p++;
    };

    system(args);
};
