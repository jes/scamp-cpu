include "stdio.sl";
include "sys.sl";

var args = cmdargs()+1;

while (*args) {
    puts(*args);
    args++;
    if (*args) putchar(' ');
};
putchar('\n');
