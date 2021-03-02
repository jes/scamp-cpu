# Directories syscalls

include "util.sl";

extern sys_readdir;
extern sys_opendir;
extern sys_mkdir;
extern sys_chdir;

var readdir_minoffset;
var readdir_buf;
var readdir_sz;
var readdir_blknum;
sys_readdir = func(fd, buf, sz) {
    var fdbase = fdbaseptr(fd);

    readdir_buf = buf;
    readdir_sz = sz;

    readdir_blknum = *(fdbase+FDDATA);
    readdir_minoffset = *(fdbase+FDDATA+1);

    dirwalk(readdir_blknum, func(name, blknum, dirblknum, dirent_offset) {
        if (dirent_offset < readdir_minoffset) return 1; # already seen this one

        if (*name) { # copy the name into readdir_buf
            while (*name && readdir_sz) {
                *(readdir_buf++) = *(name++);
                readdir_sz--;
            };
            if (readdir_sz == 0) return 0; # buf is full

            *(readdir_buf++) = 0; # terminate the name
            readdir_sz--;
        };

        readdir_blknum = dirblknum;
        readdir_minoffset = dirent_offset+1;
    });

    *(fdbase+FDDATA) = readdir_blknum;
    *(fdbase+FDDATA+1) = readdir_minoffset;

    return (sz - readdir_sz);
};

sys_opendir = func(name) {
    var startblk = CWDBLK;
    if (*name == '/') startblk = ROOTBLOCK;

    var err = catch();
    if (err) return err;

    # try to find the name
    var location = dirfindname(startblk, name);
    if (!location) return NOTFOUND;

    # return NOTDIR if it's not a directory
    blkread(location[0]);
    if(blktype() != TYPE_DIR) return NOTDIR;

    # allocate an fd, or return BADFD if they're all taken
    var fd = fdalloc();
    if (fd == -1) return BADFD;
    var fdbase = fdbaseptr(fd);

    # attach read(), although it is really intended to be used with readdir()
    *(fdbase+READFD) = sys_readdir;

    # initialise block number and dirent offset
    *(fdbase+FDDATA) = location[0];
    *(fdbase+FDDATA+1) = 2;

    return fd;
};

sys_mkdir = func(name) {
    var startblk = CWDBLK;
    if (*name == '/') startblk = ROOTBLOCK;

    var err = catch();
    if (err) return err;

    var location = dirmkname(startblk, name, TYPE_DIR);
    if (!location) return NOTFOUND;
    var dirblk = location[0];
    var parentdirblk = location[3];

    # make "." and ".."
    blkread(dirblk);
    dirent(BLKBUF+2, ".", dirblk);
    dirent(BLKBUF+18, "..", parentdirblk);
    blkwrite(dirblk);

    return 0;
};

sys_chdir = func(name) {
    var startblk = CWDBLK;
    if (*name == '/') startblk = ROOTBLOCK;

    var err = catch();
    if (err) return err;

    # try to find the name
    var location = dirfindname(startblk, name);
    if (!location) return NOTFOUND;

    # return NOTDIR if it's not a directory
    blkread(location[0]);
    if(blktype() != TYPE_DIR) return NOTDIR;

    CWDBLK = location[0];

    return 0;
};
