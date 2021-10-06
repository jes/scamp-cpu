# du - show disk usage

include "sys.sl";
include "stdio.sl";
include "string.sl";
include "bigint.sl";

biginit(4);

var BLKSZ = 256;
var bufsz = 2048;
var pathbuf = malloc(bufsz);

var totalblocks = 0;

var bignum = bignew(0);

var size = func(blocks) {
    bigsetw(bignum, blocks);
    bigmulw(bignum, BLKSZ);
    return bignum;
};

var chkchdir = func(dir) {
    var n = chdir(dir);
    if (n != 0) {
        fprintf(2, "du: chdir %s: %s\n", [dir, strerror(n)]);
        exit(1);
    };
    n = getcwd(pathbuf, bufsz);
    if (n != 0) {
        fprintf(2, "du: getcwd: %s\n", [strerror(n)]);
        exit(1);
    };
};

var du = func(dir) {
    var statbuf = [0,0,0,0];
    var fd = opendir(dir);
    if (fd < 0) {
        fprintf(2, "du: opendir %s: %s\n", [pathbuf, strerror(fd)]);
        return 0;
    };

    chkchdir(dir);
    var dirbuf = malloc(bufsz);
    var blocks = 0;

    var n;
    var p;
    var b;
    var m;
    while (1) {
        n = readdir(fd, dirbuf, bufsz);
        if (n == 0) break;
        if (n < 0) {
            fprintf(2, "du: readdir %s: %s\n", [pathbuf, strerror(n)]);
            break;
        };

        p = dirbuf;
        while (n--) {
            if (strcmp(p,".") && strcmp(p,"..")) {
                m = stat(p, statbuf);
                if (m < 0) {
                    fprintf(2, "du: stat %s%s: %s\n", [pathbuf, p, strerror(m)]);
                    continue;
                };

                b = statbuf[2];
                if (statbuf[0] == 0) b = b + du(p); # recurse if directory

                printf("%b\t%s%s\n", [size(b), pathbuf, p]);
                blocks = blocks + b;
            };

            p = p + strlen(p)+1;
        };
    };

    free(dirbuf);

    chkchdir("..");
    return blocks;
};

var args = cmdargs()+1;
var dir = ".";
if (*args) dir = *args;

printf("%b\n", [size(du(dir))]);
