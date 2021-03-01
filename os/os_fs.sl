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
        if (mode & O_CREAT) unimpl("O_CREAT")
        else return NOTFOUND;
    };

    # allocate an fd, or return BADFD if they're all taken
    var fd = fdalloc();
    if (fd == -1) return BADFD;
    var fdbase = fdbaseptr(fd);

    # attach read/write/seek/tell
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
sys_stat   = func() unimpl("stat");
