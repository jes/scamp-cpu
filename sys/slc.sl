# Compiler driver
# give source on stdin
# get binary on stdout

# TODO: [nice] flag "-O" to use optimisation
# TODO: [nice] flags "-H" and "-F" to set head.s and foot.s paths
# TODO: [nice] "-o" to set output filename
# TODO: [nice] better usage text

include "stdio.sl";
include "sys.sl";
include "malloc.sl";
include "getopt.sl";

# redirect "name" to "fd" with the given "mode"; return an fd that stores
# the previous state, suitable for use with "unredirect()";
# if "name" is a null pointer, do nothing and return -1
var redirect = func(fd, name, mode) {
    if (name == 0) return -1;

    var filefd = open(name, mode);
    if (filefd < 0) {
        fprintf(2, "can't open %s: %s", [name, strerror(filefd)]);
        exit(1);
    };

    var prev = copyfd(-1, fd); # backup the current configuration of "fd"
    copyfd(fd, filefd); # overwrite it with the new file
    close(filefd);

    return prev;
};

# close the "fd" and restore "prev"
# if "fd" is -1, do nothing
var unredirect = func(fd, prev) {
    if (prev == -1) return 0;

    close(fd);
    copyfd(fd, prev);
    close(prev);
};

var bufsz = 1024;
var buf = malloc(bufsz);

# save shelling out to cat
var cat = func(name) {
    var fd = open(name, O_READ);
    if (fd < 0) {
        fprintf(2, "open %s: %s\n", [name, strerror(fd)]);
        exit(1);
    };

    var n;
    while (1) {
        n = read(fd, buf, bufsz);
        if (n == 0) break;
        if (n < 0) {
            fprintf(2, "cat: read %d: %s\n", [fd, strerror(n)]);
            exit(1);
        };
        write(1, buf, n);
    };
    close(fd);
};

# primarily: "foo.sl" => "foo"
# else, "foo" => "foo.bin"
var mkoutname = func(s) {
    var l = strlen(s);
    var ss = malloc(l+4);
    strcpy(ss, s);

    if (strcmp(ss+l-3, ".sl") == 0) {
        ss[l-3] = 0;
    } else {
        strcpy(ss+l, ".bin");
    };

    return ss;
};

var usage = func(rc) {
    fputs(2, "usage: slc [-l LIB] < SRC.sl > BIN\n");
    fputs(2, "       slc [-l LIB] SRC.sl\n");
    exit(rc);
};

var libname = "";
var outfile;
var args = getopt(cmdargs()+1, "l", func(ch, arg) {
    if (ch == 'l') libname = strdup(arg)
    else if (ch == 'h') usage(0)
    else usage(1);
});
if (args[1]) usage(1);
if (args[0]) {
    redirect(0, args[0], O_READ); # stdin comes from the named file
    outfile = mkoutname(args[0]); # stdout goes to an appropriate name
};

var rc;

# copy the required lib into "/lib/slc-lib.h"
var libhfile = sprintf("/lib/lib%s.h", [libname]);
var libsfile = sprintf("/lib/lib%s.s", [libname]);
var prev_out = redirect(1, "/lib/slc-lib.h", O_WRITE|O_CREAT);
cat(libhfile);
unredirect(1, prev_out);

# direct stdout to "/tmp/1.s" and run slangc
fprintf(2, "slangc...\n", 0);
prev_out = redirect(1, "/tmp/1.s", O_WRITE|O_CREAT);
rc = system(["/bin/slangc"]);
if (rc != 0) exit(rc);
unredirect(1, prev_out);

# cat "/lib/head.s /lib/lib$libname.s /tmp/1.s /lib/foot.s" into "/tmp/2.s"
fprintf(2, "cat...\n", 0);
prev_out = redirect(1, "/tmp/2.s", O_WRITE|O_CREAT);
cat("/lib/head.s");
cat(libsfile);
cat("/tmp/1.s");
cat("/lib/foot.s");
unredirect(1, prev_out);

# assemble "/tmp/2.s"
fprintf(2, "asm...\n", 0);
redirect(0, "/tmp/2.s", O_READ);
if (outfile) {
    redirect(1, outfile, O_WRITE|O_CREAT);
};
exec(["/bin/asm"]);
