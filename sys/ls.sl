include "stdio.sl";
include "sys.sl";
include "malloc.sl";

# TODO: -l? -r? -a? sort? align in columns?

var bufsz = 256;
var buf = malloc(bufsz);

var rc = 0;

var ls = func(name) {
    var fd = opendir(name);
    if (fd < 0) {
        fprintf(2, "ls: opendir %s: %s\n", [name, strerror(fd)]);
        rc = 1;
        return 0;
    };

    var n;
    var p;
    while (1) {
        n = readdir(fd, buf, bufsz);
        if (n == 0) break;
        if (n < 0) {
            fprintf(2, "ls: readdir %s: %s\n", [name, strerror(fd)]);
            rc = 1;
            break;
        };

        p = buf;
        while (n--)
            while (*p)
                putchar(*(p++));
    };
    close(fd);
};

var args = cmdargs()+1;

if (!*args) {
    ls(".");
} else {
    while (*args) {
        printf("%s:\n", [*args]); # TODO: only if multiple arguments
        ls(*args);
        ls++;
    };
};

exit(rc);
