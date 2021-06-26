# buffered i/o lib
#
# bio structure:
# 0:   fd (length = 1)
# 1:   buflen (1)
# 2:   bufpos (1)
# 3:   mode (1)
# 4..: buffer (BIO_BUFSZ)

include "stdio.sl";
include "malloc.sl";

var BIO_BUFSZ = 254; # align with block size on disk

# "mode" should be O_READ or O_WRITE
var bfdopen = func(fd, mode) {
    var bio = malloc(BIO_BUFSZ + 4);
    *bio = fd;
    *(bio+1) = 0;
    *(bio+2) = 0;
    *(bio+3) = mode;

    return bio;
};

# "mode" should be O_READ or O_WRITE
var bopen = func(file, mode) {
    var fd = open(file, mode);
    if (fd < 0) return 0;
    return bfdopen(fd, mode);
};

var bflush = func(bio) {
    var fd = bio[0];
    var bufpos = bio[2];
    var mode = bio[3];

    if (!(mode & O_WRITE)) return 0;

    # TODO: [bug] error-check?
    write(fd, bio+4, bufpos);
    *(bio+2) = 0;
};

# free without closing the underlying fd
var bfree = func(bio) {
    bflush(bio);
    free(bio);
};

var bclose = func(bio) {
    var fd = bio[0];
    bfree(bio);
    close(fd);
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
        *(bio+1) = read(fd, bio+4, BIO_BUFSZ);
        if (bio[1] < 0) {
            fprintf(2, "bread %d: %s\n", [fd, strerror(bio[1])]);
            return EOF;
        } else if (bio[1] == 0) {
            return EOF;
        };
    };

    var ch = *(bio+4+bufpos);
    *(bio+2) = bufpos+1;
    return ch;
};

var bputc = func(bio, ch) {
    var fd = bio[0];
    var bufpos = bio[2];

    *(bio+4+bufpos) = ch;
    *(bio+2) = bufpos+1;

    if (bufpos == BIO_BUFSZ) bflush(bio);
};
