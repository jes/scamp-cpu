include "stdio.sl";
include "malloc.sl";

var bufsz = 16384;
var buf = malloc(bufsz);

var args = cmdargs()+1;
if (!*args || *(args+1)) {
    fputs(2, "usage: head N\n");
    exit(1);
};

var N = atoi(*args);

setbuf(0, malloc(257));
setbuf(1, malloc(257));

while (gets(buf,bufsz) && N--)
    puts(buf);
