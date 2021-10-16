# File/device IO syscalls

include "util.sl";
include "data.sl";
include "sys.sl";

# TODO: [nice] is this sound in the general case? what about
#       buffers? maybe we just tell people not to use it if they're not sure;
#       the intended purpose is for remapping stdin/stdout/stderr, so as long
#       as srcfd is never used again, it's not a problem; but what happens if
#       they call close(srcfd)? hopefully we won't destroy the destfd?
#       maybe it should be swapfd instead? but then fd 3 wouldn't always be
#       the console. hmm.
sys_copyfd  = func(destfd, srcfd) {
    ser_poll(3);

    if (destfd >= nfds || srcfd >= nfds || srcfd < 0) return BADFD;

    if (destfd < 0) destfd = fdalloc();
    if (destfd < 0) return destfd;

    var srcbase = fdbaseptr(srcfd);
    var destbase = fdbaseptr(destfd);
    memcpy(destbase, srcbase, 8);
    return destfd;
};

# The following calls dispatch to their implementations based on the fd table

sys_read = func(fd, buf, sz) {
    ser_poll(3);

    var err = catch();
    if (err) return err;
    var fdbase = fdbaseptr(fd);
    var readimpl = fdbase[READFD];
    if (readimpl) return readimpl(fd, buf, sz);
    return BADFD;
};

sys_write = func(fd, buf, sz) {
    ser_poll(3);

    var err = catch();
    if (err) return err;
    var fdbase = fdbaseptr(fd);
    var writeimpl = fdbase[WRITEFD];
    if (writeimpl) return writeimpl(fd, buf, sz);
    return BADFD;
};

sys_close = func(fd) {
    ser_poll(3);

    var err = catch();
    if (err) return err;
    var fdbase = fdbaseptr(fd);
    var closeimpl = fdbase[CLOSEFD];
    var n = 0;
    if (closeimpl) n = closeimpl(fd);
    fdfree(fd);
    return n;
};

# TODO: [bug] this will kind of behave weird if, for example, you turn off
#       cooked mode on stdin but not on fd 3 - ^C will still kill the process
#       etc. when any syscall calls ser_poll(3) because fd 3 will still have
#       cooked mode - I think the flags should be a property of the input
#       buffer perhaps?
sys_serflags = func(fd, flags) {
    ser_poll(3);

    var err = catch();
    if (err) return err;

    var fdbase = fdbaseptr(fd);
    var readfunc = fdbase[READFD];

    # serflags() only works for serial ports
    if (readfunc != ser_read) return BADFD;

    var oldflags = fdbase[SERFLAGS];
    *(fdbase+SERFLAGS) = flags;

    return oldflags;
};

sys_blkread = func(blknum) {
    ser_poll(3);
    blkread(blknum, BLKBUF);
    return BLKBUF;
};

sys_blkwrite = func(blknum, data) {
    ser_poll(3);

    # TODO: [perf] maybe call cf_blkwrite() directly so we don't need to memcpy via BLKBUF?
    #       the reason we need to copy to BLKBUF is because blkwrite() uses buf[256] to store
    #       the number of the block that was written so that subsequent blkread() calls can use
    #       the cached data without hitting the disk
    memcpy(BLKBUF, data, BLKSZ);
    blkwrite(blknum, BLKBUF);

    return 0;
};
