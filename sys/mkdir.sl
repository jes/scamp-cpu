include "sys.sl";
include "stdio.sl";

# TODO: implement"-p"

var args = cmdargs()+1;

if (!*args) {
    fputs(2, "usage: mkdir NAME...\n");
    exit(1);
};

var n;
while (*args) {
    n = mkdir(*args);
    if (n < 0) fprintf(2, "mkdir: %s: %s\n", [*args, strerror(n)]);
    args++;
};
