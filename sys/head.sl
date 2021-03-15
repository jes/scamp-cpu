include "stdio.sl";
include "malloc.sl";

var bufsz = 16384;
var buf = malloc(bufsz);

var args = cmdargs()+1;
if (!*args || *(args+1)) {
    fputs("usage: head N\n");
    exit(1);
};

var N = atoi(*args);

while (gets(buf,bufsz) && N--)
    puts(buf);
