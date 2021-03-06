# File/device IO syscalls

include "util.sl";
include "data.sl";
include "sys.sl";

# TODO: [nice] is this sound in the general case? what about seek/tell offsets?
#       buffers? maybe we just tell people not to use it if they're not sure;
#       the intended purpose is for remapping stdin/stdout/stderr, so as long
#       as srcfd is never used again, it's not a problem; but what happens if
#       they call close(srcfd)? hopefully we won't destroy the destfd?
#       maybe it should be swapfd instead? but then fd 3 wouldn't always be
#       the console. hmm.
sys_copyfd  = func(destfd, srcfd) {
    if (destfd >= nfds || srcfd >= nfds || srcfd < 0) return BADFD;

    if (destfd < 0) destfd = fdalloc();
    if (destfd < 0) return destfd;

    var srcbase = fdbaseptr(srcfd);
    var destbase = fdbaseptr(destfd);
    memcpy(destbase, srcbase, 8);
    return destfd;
};

# The following calls dispatch to their implementations based on the fd table

sys_tell = func(fd) {
    var err = catch();
    if (err) return err;
    var fdbase = fdbaseptr(fd);
    var tellimpl = fdbase[TELLFD];
    if (tellimpl) return tellimpl(fd);
    return BADFD;
};

sys_seek = func(fd, pos) {
    var err = catch();
    if (err) return err;
    var fdbase = fdbaseptr(fd);
    var seekimpl = fdbase[SEEKFD];
    if (seekimpl) return seekimpl(fd, pos);
    return BADFD;
};

sys_read = func(fd, buf, sz) {
    var err = catch();
    if (err) return err;
    var fdbase = fdbaseptr(fd);
    var readimpl = fdbase[READFD];
    if (readimpl) return readimpl(fd, buf, sz);
    return BADFD;
};

sys_write = func(fd, buf, sz) {
    var err = catch();
    if (err) return err;
    var fdbase = fdbaseptr(fd);
    var writeimpl = fdbase[WRITEFD];
    if (writeimpl) return writeimpl(fd, buf, sz);
    return BADFD;
};

sys_close = func(fd) {
    var err = catch();
    if (err) return err;
    var fdbase = fdbaseptr(fd);
    var closeimpl = fdbase[CLOSEFD];
    var n = 0;
    if (closeimpl) n = closeimpl(fd);
    fdfree(fd);
    return n;
};
