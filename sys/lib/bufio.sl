# buffered i/o lib
#
# bio structure:
# 0:   fd (length = 1)
# 1:   buflen (1)
# 2:   bufpos (1)
# 3..: buffer (BIO_BUFSZ)

include "stdio.sl";
include "malloc.sl";

var BIO_BUFSZ = 256;

var bfdopen = func(fd) {
    var bio = malloc(BIO_BUFSZ + 3);
    *bio = fd;
    *(bio+1) = 0;
    *(bio+2) = 0;

    return bio;
};

var bopen = func(file, mode) {
    var fd = open(file, mode);
    if (fd < 0) return 0;
    return bfdopen(fd);
};

var bclose = func(bio) {
    var fd = bio[0];
    close(fd);
    free(bio);
};

var bread = func(bio, buf, sz) {
    fprintf(2, "bread() not implemented yet\n", 0);
};

var bwrite = func(bio, buf, sz) {
    fprintf(2, "bwrite() not implemented yet\n", 0);
};

var bgetc = func(bio) {
    var fd = bio[0];
    var buflen = bio[1];
    var bufpos = bio[2];

    if (bufpos == buflen) {
        *(bio+2) = 0; bufpos = 0;
        *(bio+1) = read(fd, bio+3, BIO_BUFSZ);
        if (bio[1] < 0) {
            fprintf(2, "bread %d: %s\n", [fd, strerror(bio[1])]);
            return EOF;
        } else if (bio[1] == 0) {
            return EOF;
        };
    };

    var ch = *(bio+3+bufpos);
    *(bio+2) = bufpos+1;
    return ch;
};
