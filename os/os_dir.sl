# Directories syscalls

include "util.sl";

extern sys_readdir;
extern sys_opendir;
extern sys_mkdir;
extern sys_chdir;
extern sys_getcwd;
extern sys_unlink;

var readdir_buf;
var readdir_sz;
var readdir_blknum;
var readdir_minoffset;
var readdir_ndirents;
sys_readdir = func(fd, buf, sz) {
    var err;
    err = catch();
    if (err) return err;

    var fdbase = fdbaseptr(fd);

    readdir_buf = buf;
    readdir_sz = sz;

    readdir_blknum = *(fdbase+FDDATA);
    readdir_minoffset = *(fdbase+FDDATA+1);
    readdir_ndirents = 0;

    dirwalk(readdir_blknum, func(name, blknum, dirblknum, dirent_offset) {
        if (dirent_offset < readdir_minoffset && dirblknum == readdir_blknum) return 0;

        if (*name) {
            # copy the name into readdir_buf
            while (*name && readdir_sz) {
                *(readdir_buf++) = *(name++);
                readdir_sz--;
            };
            if (readdir_sz == 0) return 0; # buf is full

            *(readdir_buf++) = 0; # terminate the name
            readdir_sz--;
            readdir_ndirents++;
        };

        readdir_blknum = dirblknum;
        readdir_minoffset = dirent_offset+1;
        return 1;
    });

    *(fdbase+FDDATA) = readdir_blknum;
    *(fdbase+FDDATA+1) = readdir_minoffset;

    return readdir_ndirents;
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
    if (location == -1) return EXISTS;
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

var getcwd_name;
var getcwd_dirblk;
var getcwd_level = func(buf, sz, dirblk, bufp) {
    var dotdot = dirfindname(dirblk, "..");
    if (!dotdot) return NOTFOUND;

    var parentblk = dotdot[0];

    # found root
    if (parentblk == dirblk) {
        *(buf++) = '/';
        *buf = 0;
        *bufp = buf;
        return 0;
    };

    # get the parent directory in buf
    var next_bufp;
    var n = getcwd_level(buf, sz, parentblk, &next_bufp);
    if (n < 0) return n;

    # work out the name of this directory
    getcwd_dirblk = dirblk;
    getcwd_name = 0;
    dirwalk(parentblk, func(name, blknum, dirblknum, dirent_offset) {
        if (*name && blknum == getcwd_dirblk) {
            getcwd_name = name;
            return 0;
        };
        return 1;
    });
    if (!getcwd_name) return NOTFOUND;

    # TODO: [bug] bounds-checking
    while (*getcwd_name) *(next_bufp++) = *(getcwd_name++);
    *(next_bufp++) = '/';
    *next_bufp = 0;
    *bufp = next_bufp;

    return 0;
};

sys_getcwd = func(buf, sz) {
    var err = catch();
    if (err) return err;
    return getcwd_level(buf, sz, CWDBLK, 0);
};

sys_unlink = func(name) {
    var startblk = CWDBLK;
    if (*name == '/') startblk = ROOTBLOCK;

    var err = catch();
    if (err) return err;

    # try to find the name
    var location = dirfindname(startblk, name);
    if (!location) return NOTFOUND;

    var blknum = location[0];
    var dirblk = location[1];
    var dir_offset = location[2];

    # don't unlink the empty string file, or "."
    # TODO: [bug] don't unlink ".."
    if (dirblk == 0 || dirblk == blknum) return NOTFOUND;

    # delete it from the directory
    dirent(BLKBUF+dir_offset, "", 0);
    blkwrite(dirblk);

    # TODO: [bug] this leaves inaccessible-but-not-freed files when
    #       unlinking a non-empty directory

    # free the rest of the blocks in the file
    blktrunc(blknum, 0);

    # free the first block
    blksetused(blknum, 0);

    # TODO: [nice] if the directory block is now empty, we should unlink it
    #       from the linked list of blocks in the directory

    return 0;
};
