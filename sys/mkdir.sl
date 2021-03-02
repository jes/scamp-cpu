include "sys.sl";
include "stdio.sl";

# TODO: implement"-p"

var args = cmdargs()+1;

if (!*args) {
    fputs(2, "usage: mkdir NAME...\n");
    exit(1);
};

while (*args) {
    mkdir(*args);
    args++;
};
