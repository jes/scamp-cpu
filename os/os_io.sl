# File/device IO

include "util.sl";
include "os_proc.sl";

extern sys_copyfd;
extern sys_tell;
extern sys_seek;
extern sys_read;
extern sys_getchar;
extern sys_write;
extern sys_putchar;

# TODO: is this sound in the general case? what about seek/tell offsets?
#       buffers? maybe we just tell people not to use it if they're not sure;
#       the intended purpose is for remapping stdin/stdout/stderr, so as long
#       as srcfd is never used again, it's not a problem; but what happens if
#       they call close(srcfd)? hopefully we won't destroy the destfd?
#       maybe it should be swapfd instead?
sys_copyfd  = func(destfd, srcfd) {
    var srcbase = fdbaseptr(srcfd);
    var destbase = fdbaseptr(destfd);
    memcpy(destbase, srcbase, 8);
};

# The following calls dispatch to their implementations based on the fd table

sys_tell = func(fd) {
    var fdbase = fdbaseptr(fd);
    var tellimpl = fdbase[4];
    if (tellimpl) return tellimpl(fd);
    return BADFD;
};

sys_seek = func(fd, pos) {
    var fdbase = fdbaseptr(fd);
    var seekimpl = fdbase[5];
    if (seekimpl) return seekimpl(fd, pos);
    return BADFD;
};

sys_read = func(fd, buf, sz) {
    var fdbase = fdbaseptr(fd);
    var readimpl = fdbase[0];
    if (readimpl) return readimpl(fd, buf, sz);
    return BADFD;
};

sys_getchar = func(fd) {
    var fdbase = fdbaseptr(fd);
    var getcharimpl = fdbase[2];
    if (getcharimpl) return getcharimpl(fd);
    return BADFD;
};

sys_write = func(fd, buf, sz) {
    var fdbase = fdbaseptr(fd);
    var writeimpl = fdbase[1];
    if (writeimpl) return writeimpl(fd, buf, sz);
    return BADFD;
};

sys_putchar = func(fd, ch) {
    var fdbase = fdbaseptr(fd);
    var putcharimpl = fdbase[3];
    if (putcharimpl) return putcharimpl(fd, ch);
    return BADFD;
};
