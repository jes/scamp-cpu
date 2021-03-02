# Filesystem syscalls

include "data.sl";
include "util.sl";
include "fs.sl";

extern sys_open;
extern sys_unlink;
extern sys_stat;

# open the given name in the given mode
sys_open = func(name, mode) {
    var startblk = CWDBLK;
    if (*name == '/') startblk = ROOTBLOCK;

    var err = catch();
    if (err) return err;

    # try to find the name
    var location = dirfindname(startblk, name);

    # if it doesn't exist, either create it or error
    if (!location) {
        if (!(mode & O_CREAT)) return NOTFOUND;

        location = dirmkname(startblk, name, TYPE_FILE);
        if (!location) return NOTFOUND;
    };

    # return NOTFILE if it's not a file
    blkread(location[0]);
    if(blktype() != TYPE_FILE) return NOTFILE;

    # allocate an fd, or return BADFD if they're all taken
    var fd = fdalloc();
    if (fd == -1) return BADFD;

    # free the fd if we have any errors now
    err = catch();
    if (err) {
        fdfree(fd);
        return err;
    };

    # attach read/write/seek/tell
    var fdbase = fdbaseptr(fd);
    if (mode & O_READ)  *(fdbase+READFD)  = fs_read;
    if (mode & O_WRITE) *(fdbase+WRITEFD) = fs_write;
    *(fdbase+TELLFD)  = fs_tell;
    *(fdbase+SEEKFD)  = fs_seek;
    *(fdbase+CLOSEFD) = fs_close;

    # initialise block number and seek location
    *(fdbase+FDDATA) = location[0]; # block number
    *(fdbase+FDDATA+1) = 0; # seek location

    # seek to end if O_APPEND
    if (mode & O_APPEND) unimpl("O_APPEND");

    # truncate the file if O_WRITE && !O_APPEND && !O_NOTRUNC
    if ((mode & O_WRITE) && !(mode & O_APPEND) && !(mode & O_NOTRUNC))
        fs_trunc(fd);

    return fd;
};

sys_unlink = func() unimpl("unlink");

sys_stat = func(name, statbuf) {
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
        blkread(blknum);
        if (blktype() == TYPE_DIR) {
            *statbuf = 0;
            nwords = nwords + BLKSZ-2;
        } else {
            *statbuf = 1;
            nwords = nwords + half(blklen()+1);
        };

        nblocks++;
        blknum = blknext();
    };

    *(statbuf+1) = nwords;
    *(statbuf+2) = nblocks;

    return 0;
};
