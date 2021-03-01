include "stdio.sl";
include "sys.sl";
include "malloc.sl";

var bufsz = 256;
var buf = malloc(bufsz);

var cat = func(name) {
    var fd = open(name, O_READ);
    if (fd < 0) {
        fprintf(2, "cat: open %s: %s\n", [name, strerror(fd)]);
        return 0;
    };

    var n;
    while (1) {
        n = read(fd, buf, bufsz);
        if (n == 0) break;
        if (n < 0) {
            fprintf(2, "cat: read %d: %s\n", [fd, strerror(n)]);
            break;
        };
        write(1, buf, n);
    };
    close(fd);
};

var args = cmdargs()+1;

if (!*args) {
    fputs(2, "usage: cat FILES...\n");
    exit(1);
};

while (*args) {
    cat(*args);
    args++;
};

exit(0);
