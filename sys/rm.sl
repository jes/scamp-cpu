include "getopt.sl";
include "malloc.sl";
include "stdio.sl";
include "string.sl";
include "sys.sl";

var bufsz = 256;
var recursive = 0;

var help = func(rc) {
    puts("usage: rm [-r] NAME...

options:
    -h    show this text
    -r    recursive
");
    exit(rc);
};

var rc = 0;

var rm;

var rm_recurse = func(name) {
    var n;

    printf("rm_recurse(%s)\n", [name]);

    var olddir = malloc(bufsz);
    n = getcwd(olddir, bufsz);
    if (n < 0) {
        fprintf(2, "rm: getcwd: %s\n", [strerror(n)]);
        rc = 1;
        free(olddir);
        return 0;
    };
    n = chdir(name);
    if (n < 0) {
        fprintf(2, "rm: chdir %s: %s\n", [name, strerror(n)]);
        rc = 1;
        free(olddir);
        return 0;
    };

    var fd = opendir(".");
    if (fd < 0) {
        fprintf(2, "rm: opendir %s: %s\n", [name, strerror(fd)]);
        rc = 1;
        chdir(olddir);
        free(olddir);
        return 0;
    };

    var p;
    var namebuf = malloc(bufsz);
    while (1) {
        n = readdir(fd, namebuf, bufsz);
        if (n == 0) break;
        if (n < 0) {
            fprintf(2, "rm: readdir %s: %s\n", [name, strerror(n)]);
            rc = 1;
            break;
        };

        p = namebuf;
        while (n--) {
            printf("readdir of %s sees: %s\n", [name,p]);
            if (strcmp(p,".") != 0 && strcmp(p,"..") != 0)
                rm(p);
            p = p + strlen(p)+1;
        };
    };
    free(namebuf);

    close(fd);

    chdir(olddir);
    free(olddir);
};

rm = func(name) {
    var n;
    var statbuf = [0,0,0,0];

    printf("rm(%s)\n", [name]);

    if (recursive) {
        n = stat(name, statbuf);
        if (n < 0) {
            fprintf(2, "rm: stat %s: %s\n", [name, strerror(n)]);
            rc = 1;
            return n;
        };

        # if this is a directory, recurse into it before unlinking it
        if (statbuf[0] == 0) rm_recurse(name);
    };

    n = unlink(name);
    if (n < 0) {
        fprintf(2, "rm: unlink %s: %s\n", [name, strerror(n)]);
        rc = 1;
    };
    return 0;
};

var args = getopt(cmdargs()+1, "", func(ch,arg) {
    if (ch == 'r') recursive = 1
    else if (ch == 'h') help(0)
    else help(1);
});

if (!*args) help(1);

while (*args) rm(*(args++));

exit(rc);
