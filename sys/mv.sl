include "stdio.sl";
include "sys.sl";
include "malloc.sl";

var args = cmdargs()+1;

if (!*args || !*(args+1) || *(args+2)) {
    fputs(2,"usage: mv OLDNAME NEWNAME\n");
    exit(1);
};

# TODO: [nice] if *(args+1) is a directory, create the name inside the directory

var n;

var statbuf = malloc(4);
n = stat(*(args+1), statbuf);
if (n == 0 && statbuf[0] == 0) {
    fprintf(2, "mv: %s: is directory\n", [*(args+1)]);
    exit(1);
};

n = rename(*args, *(args+1));
if (n == EXISTS) {
    unlink(*(args+1));
    n = rename(*args, *(args+1));
};
if (n != 0) fprintf(2, "mv: %s\n", [strerror(n)]);
