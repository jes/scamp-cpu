include "bigint.sl";
include "bufio.sl";
include "getopt.sl";
include "stdio.sl";
include "stdlib.sl";
include "sys.sl";

var usage = func() {
    fputs(2,"usage: wc [-cwl]\n");
    exit(1);
};

var argc = 0;
var argw = 0;
var argl = 0;

var more = getopt(cmdargs()+1, "", func(ch, arg) {
    if (ch == 'c') argc = 1
    else if (ch == 'w') argw = 1
    else if (ch == 'l') argl = 1
    else usage();
});
if (*more) usage();

var inwhite = 1;

var allchars = bignew(0);
var chars = 0;
var allwords = bignew(0);
var words = 0;
var alllines = bignew(0);
var lines = 0;
const LIMIT = 16384;

var wc = func(bio) {
    var ch;
    while(1) {
        ch = bgetc(bio);
        if (ch == EOF) break;

        chars++;
        if (chars gt LIMIT) {
            bigaddw(allchars, chars);
            chars = 0;
        };

        if (ch == '\n') {
            lines++;
            if (lines gt LIMIT) {
                bigaddw(alllines, lines);
                lines = 0;
            };
        };
        if (iswhite(ch)) {
            inwhite = 1;
        } else {
            if (inwhite) {
                words++;
                if (words gt LIMIT) {
                    bigaddw(allwords, words);
                    words = 0;
                };
            };
            inwhite = 0;
        };
    };

    bigaddw(allchars, chars);
    bigaddw(allwords, words);
    bigaddw(alllines, lines);
};

var in = bfdopen(0, O_READ);
wc(in);
bclose(in);

if (argc) printf("%b\n", [allchars])
else if (argw) printf("%b\n", [allwords])
else if (argl) printf("%b\n", [alllines])
else printf("%b\t%b\t%b\n", [alllines,allwords,allchars]);
