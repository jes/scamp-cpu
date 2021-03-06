include "sys.sl";
include "stdio.sl";

# TODO: [nice] implement "-r"
# TODO: [nice] decide whether "rm" or "rmdir" is used to delete directories

var args = cmdargs()+1;

if (!*args) {
    fputs(2, "usage: rm NAME...\n");
    exit(1);
};

var n;
while (*args) {
    n = unlink(*args);
    if (n < 0) fprintf(2, "rm: %s: %s\n", [*args, strerror(n)]);
    args++;
};
