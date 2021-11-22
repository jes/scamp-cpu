include "bufio.sl";
include "stdio.sl";
include "string.sl";
include "sys.sl";

var bufsz = 16384;
var buf = malloc(bufsz);

setbuf(1, malloc(257));

var showfilename = 0;
var filename = "";

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

var bgrep = func(term, in) {
    while (bgets(in,buf,bufsz))
        if (match(buf, term)) {
            if (showfilename) {
                puts(filename);
                putchar(':');
            };
            puts(buf);
        };
};

var grep = func(term, name) {
    var in = bopen(name, O_READ);
    var fd;
    if (!in) {
        fd = open(name, O_READ);
        fprintf(2, "grep: %s: %s\n", [name, strerror(fd)]);
        return 0;
    };
    filename = name;
    bgrep(term, in);
    bclose(in);
};

var args = cmdargs()+1;

if (!*args) {
    fputs(2,"usage: grep SEARCHTERM FILE...\n");
    exit(1);
};

var searchterm = *(args++);

if (*args) {
    # show filename in output if more than 1 filename is given
    if (*(args+1)) showfilename = 1;

    while (*args)
        grep(searchterm, *(args++));
} else {
    bgrep(searchterm, bfdopen(0, O_READ));
};
