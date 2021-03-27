# Compiler driver
# give source on stdin
# get binary on stdout

include "stdio.sl";
include "sys.sl";

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

# TODO: [nice] option parsing

var rc;

# direct stdout to "/tmp/1.s" and run slangc
fprintf(2, "slangc...\n", 0);
var prev_out = redirect(1, "/tmp/1.s", O_WRITE|O_CREAT);
rc = system(["/bin/slangc"]);
if (rc != 0) exit(rc);
unredirect(1, prev_out);

# cat "/lib/head.s /tmp/1.s /lib/foot.s" into "/tmp/2.s"
fprintf(2, "cat...\n", 0);
prev_out = redirect(1, "/tmp/2.s", O_WRITE|O_CREAT);
var prev_in = redirect(0, "/tmp/1.s", O_READ);
rc = system(["/bin/cat", "/lib/head.s", "/tmp/1.s", "/lib/foot.s"]);
if (rc != 0) exit(rc);
unredirect(1, prev_out);
unredirect(0, prev_in);

# assemble "/tmp/2.s" to stdout
fprintf(2, "asm...\n", 0);
prev_in = redirect(0, "/tmp/2.s", O_READ);
exec(["/bin/asm"]);
