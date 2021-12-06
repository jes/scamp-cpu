include "sys.sl";

# TODO: [nice] init should become a shell script if they get fast enough

var bufsz = 128;
var buf = asm { .gap 128 };

var clearout = func(dir) {
    var fd = opendir(dir);
    if (fd < 0) return 0;

    chdir(dir);

    var n;
    var p;
    while (1) {
        n = readdir(fd, buf, bufsz);
        if (n <= 0) break;
        p = buf;
        while (n--) {
            unlink(p);
            while (*p) p++;
            p++;
        };
    };
    close(fd);
};

var cat = func(name) {
    var fd = open(name, O_READ);
    if (fd < 0) return 0;

    var n;
    while (1) {
        n = read(fd, buf, bufsz);
        if (n <= 0) break;
        write(1, buf, n);
    };
    close(fd);
};

clearout("/tmp");
clearout("/proc");
cat("/etc/motd");
chdir("/home");
while (1)
    system(["/bin/sh"]);
