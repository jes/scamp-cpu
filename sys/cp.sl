# copy files
#
# usage:
#   cp curfile newfile
#   cp curfile newdir
#   TODO: cp curfile1 curfile2 curfile3 targetdir
#   TODO: cp -a curdir newdir

include "malloc.sl";
include "stdio.sl";
include "string.sl";
include "sys.sl";

var bufsz = 1024;
var buf = malloc(bufsz);

var isdir = func(name) {
    var n;
    var buf = [0,0,0,0];
    n = stat(name, buf);
    if (n < 0) return 0; # it can't be a directory if we can't stat() it

    return (buf[0] == 0); # check if type is directory
};

# return pointer to the final path name component
var basename = func(name) {
    var r = name;
    while (*name) {
        if (*name == '/' && *(name+1))
            r = name;
        name++;
    };
    return r;
};

var cp = func(src, dst) {
    var srcfd;
    var dstfd;

    srcfd = open(src, O_READ);
    if (srcfd < 0) {
        fprintf(2, "cp: %s: %s\n", [src, strerror(srcfd)]);
        return 0;
    };

    # if "dst" exists and is a directory, create a file inside
    # it with the same basename as "src"
    if (isdir(dst))
        dst = sprintf("%s/%s", [dst, basename(src)]);

    dstfd = open(dst, O_WRITE|O_CREAT);
    if (dstfd < 0) {
        fprintf(2, "cp: %s: %s\n", [dst, strerror(dstfd)]);
        return 0;
    };

    var n;
    while (1) {
        n = read(srcfd, buf, bufsz);
        if (n == 0) break;
        if (n < 0) {
            fprintf(2, "cp: %s: %s\n", [src, strerror(n)]);
            break;
        };
        n = n - write(dstfd, buf, n);
        if (n != 0) {
            fprintf(2, "cp: write %s: write() didn't complete\n", [dst]);
            break;
        }
    };

    close(srcfd);
    close(dstfd);
};

var args = cmdargs()+1;
if (!args[0] || !args[1] || args[2]) {
    fprintf(2, "usage: cp SRC DEST\n");
    exit(1);
};

var src = args[0];
var dst = args[1];

cp(src, dst);
