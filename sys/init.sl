include "stdio.sl";
include "sys.sl";
include "malloc.sl";

# print motd
var fd = open("/etc/motd", O_READ);
var buf;
var n;
if (fd >= 0) {
    buf = malloc(256);
    while (1) {
        n = read(fd, buf, 256);
        if (n == 0) break;
        if (n < 0) {
            fprintf(2, "init: read %d: %s\n", [fd, strerror(n)]);
            break;
        };
        write(1, buf, n);
    };
    close(fd);
} else {
    fprintf(2, "init: open /etc/motd: %s\n", [strerror(fd)]);
};

# TODO: exec(["/bin/sh"]) ?

puts("init halts.\n");
while (1);
