include "stdio.sl";
include "sys.sl";

var showstat = func(name) {
    var statbuf = [0,0,0];
    var n = stat(name, statbuf);
    if (n < 0) {
        fprintf(2, "stat: %s: %s\n", [name, strerror(n)]);
        return 0;
    };

    var typch = 'f';
    if (*statbuf == 0) typch = 'd';
    printf("%c %d %d %s\n", [typch, statbuf[1], statbuf[2], name]);
};

var args = cmdargs()+1;

if (!*args) {
    fputs(2, "usage: stat NAME...\n");
    exit(1);
};

while (*args) {
    showstat(*args);
    args++;
};
