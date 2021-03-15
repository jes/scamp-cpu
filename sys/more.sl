include "stdio.sl";
include "malloc.sl";

var LINES = 25;
var COLS = 80;

var bufsz = COLS;
var buf = malloc(bufsz);

var l = 0;
var ch;

while (gets(buf, bufsz)) {
    puts(buf);
    l++;

    if (l == LINES-1) {
        puts("--MORE--");
        ch = fgetc(3); # read 1 char from the console
        puts("\r        \r"); # clear "--MORE--"
        if (ch == 'q') exit(0);
        l = 0;
    };
};
