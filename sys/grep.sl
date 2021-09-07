include "bufio.sl";
include "stdio.sl";
include "string.sl";
include "sys.sl";

# return 1 if haystack contains needle, 0 otherwise
# TODO: [perf] we can do better than strncmp() here, e.g. Aho-Corasick?
var match = func(haystack, needle) {
    var i = 0;
    var len = strlen(needle);

    while (haystack[i]) {
        if (strncmp(haystack+i,needle,len) == 0) return 1;
        i++;
    };

    return 0;
};

var args = cmdargs()+1;

if (!*args || *(args+1)) {
    fputs(2,"usage: grep SEARCHTERM\n");
    exit(1);
};

var searchterm = *args;

var bufsz = 16384;
var buf = malloc(bufsz);

var in = bfdopen(0, O_READ);

setbuf(1, malloc(257));
while (bgets(in,buf,bufsz))
    if (match(buf, searchterm))
        puts(buf);
