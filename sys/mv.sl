include "stdio.sl";
include "sys.sl";

var args = cmdargs()+1;

if (!*args || !*(args+1) || *(args+2)) {
    fputs(2,"usage: mv OLDNAME NEWNAME\n");
    exit(1);
};

# TODO: [nice] if *(args+1) is a directory, create the name inside the directory
# TODO: [nice] if *(args+1) is a file, delete it first

var n = rename(*args, *(args+1));
if (n != 0) fprintf(2, "mv: %s\n", [strerror(n)]);
