# Filesystem syscalls

include "data.sl";
include "util.sl";
include "fs.sl";
include "sys.sl";

# open the given name in the given mode
sys_open = func(name, mode) {
    ser_poll(3);

    var startblk = CWDBLK;
    if (*name == '/') startblk = ROOTBLOCK;

    var fd = -1;

    var err = catch();
    if (err) {
        # TODO: [bug] fd leak if sys_open() is called under denycatch() (think
        #       there is actually no code path that triggers this currently, but
        #       there may be in the future)
        if (fd != -1) fdfree(fd);
        return err;
    };

    # try to find the name
    var location = dirfindname(startblk, name);

    # if it doesn't exist, either create it or error
    if (!location) {
        if (!(mode & O_CREAT)) return NOTFOUND;

        location = dirmkname(startblk, name, TYPE_FILE, 0);
        if (!location) return NOTFOUND;
        if (location == -1) return EXISTS;
    };

    # return NOTFILE if it's not a file
    blkread(location[0], 0);
    if(blktype(0) != TYPE_FILE) return NOTFILE;

    # allocate an fd, or return BADFD if they're all taken
    if (mode & O_KERNELFD) fd = KERNELFD
    else                   fd = fdalloc();
    if (fd == -1) return BADFD;

    # attach read/write/close
    var fdbase = fdbaseptr(fd);
    if (mode & O_READ)  *(fdbase+READFD)  = fs_read;
    if (mode & O_WRITE) {
        *(fdbase+WRITEFD) = fs_write;
        *(fdbase+SYNCFD) = fs_sync;
    };
    *(fdbase+CLOSEFD) = fs_close;

    # initialise block number and seek location
    *(fdbase+FDDATA) = location[0]; # block number
    *(fdbase+FDDATA+1) = 0; # position within block

    # truncate the file if O_WRITE && !O_NOTRUNC
    if ((mode & O_WRITE) && !(mode & O_NOTRUNC))
        fs_trunc(fd);

    return fd;
};

sys_stat = func(name, statbuf) {
    ser_poll(3);

    var startblk = CWDBLK;
    if (*name == '/') startblk = ROOTBLOCK;

    var err = catch();
    if (err) return err;

    # try to find the name
    var location = dirfindname(startblk, name);
    if (!location) return NOTFOUND;

    var blknum = location[0];
    var nwords = 0;
    var nblocks = 0;

    while (blknum) {
        blkread(blknum, 0);
        if (blktype(0) == TYPE_DIR) {
            *statbuf = 0;
            nwords = nwords + BLKSZ-2;
        } else {
            *statbuf = 1;
            nwords = nwords + blklen(0);
        };

        nblocks++;
        blknum = blknext(0);
    };

    *(statbuf+1) = nwords;
    *(statbuf+2) = nblocks;
    *(statbuf+3) = location[0];

    return 0;
};

sys_setbuf = func(fd, buf) {
    ser_poll(3);

    var fdbase = fdbaseptr(fd);
    var closefunc = *(fdbase+CLOSEFD);

    # setbuf() only works for files on disk
    if (closefunc != fs_close) return BADFD;

    sys_sync(fd);

    *(fdbase+FDDATA+2) = buf;
    *(buf+256) = 0;

    return 0;
};

sys_sync = func(fd) {
    ser_poll(3);

    var i;

    if (fd == -1) {
        # sync all fds
        i = 0;
        while (i != nfds) sys_sync(i++);
        return 0;
    };

    var fdbase = fdbaseptr(fd);
    var syncimpl = *(fdbase+SYNCFD);
    if (syncimpl) return syncimpl(fd);
    return BADFD;
};
