include "sys.sl";
include "stdio.sl";
include "malloc.sl";

var bufsz = 256;
var buf = malloc(bufsz);
var n = getcwd(buf, bufsz);
if (n < 0) fprintf(2, "pwd: %s\n", [strerror(n)])
else printf("%s\n", [buf]);
