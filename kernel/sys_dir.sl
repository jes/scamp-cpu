# Directories syscalls

include "util.sl";
include "sys.sl";

var readdir_buf;
var readdir_sz;
var readdir_blknum;
var readdir_minoffset;
var readdir_ndirents;
var readdir_accepting;
sys_readdir = func(fd, buf, sz) {
    ser_poll(3);

    var err = catch();
    if (err) return err;

    var fdbase = fdbaseptr(fd);

    readdir_buf = buf;
    readdir_sz = sz;

    readdir_blknum = *(fdbase+FDDATA);
    readdir_minoffset = *(fdbase+FDDATA+1);
    readdir_ndirents = 0;
    readdir_accepting = 0;

    dirwalk(readdir_blknum, func(name, blknum, dirblknum, dirent_offset) {
        if (dirblknum == readdir_blknum) readdir_accepting = 1;
        if (!readdir_accepting) return 1;
        if (dirent_offset < readdir_minoffset && dirblknum == readdir_blknum) return 1;

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
    ser_poll(3);

    var startblk = CWDBLK;
    if (*name == '/') startblk = ROOTBLOCK;

    var err = catch();
    if (err) return err;

    # try to find the name
    var location = dirfindname(startblk, name);
    if (!location) return NOTFOUND;

    # return NOTDIR if it's not a directory
    blkread(location[0], 0);
    if(blktype(0) != TYPE_DIR) return NOTDIR;

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
    ser_poll(3);

    var startblk = CWDBLK;
    if (*name == '/') startblk = ROOTBLOCK;

    var err = catch();
    if (err) return err;

    var location = dirmkname(startblk, name, TYPE_DIR, 0);
    if (!location) return NOTFOUND;
    if (location == -1) return EXISTS;
    var dirblk = location[0];
    var parentdirblk = location[3];

    # make "." and ".."
    blkread(dirblk, 0);
    memset(BLKBUF+2, 0, BLKSZ-2); # zero out the filenames
    dirent(BLKBUF+2, ".", dirblk);
    dirent(BLKBUF+18, "..", parentdirblk);
    blkwrite(dirblk, 0);

    return 0;
};

sys_chdir = func(name) {
    ser_poll(3);

    var startblk = CWDBLK;
    if (*name == '/') startblk = ROOTBLOCK;

    var err = catch();
    if (err) return err;

    # try to find the name
    var location = dirfindname(startblk, name);
    if (!location) return NOTFOUND;

    # return NOTDIR if it's not a directory
    blkread(location[0], 0);
    if(blktype(0) != TYPE_DIR) return NOTDIR;

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
    sz = sz - (next_bufp - buf);

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

    while (*getcwd_name) {
        *(next_bufp++) = *(getcwd_name++);
        sz--;
        if (sz < 2) return TOOLONG;
    };
    *(next_bufp++) = '/';
    *next_bufp = 0;
    *bufp = next_bufp;

    return 0;
};

sys_getcwd = func(buf, sz) {
    ser_poll(3);

    var err = catch();
    if (err) return err;
    return getcwd_level(buf, sz, CWDBLK, 0);
};

var unlink_count;
sys_unlink = func(name) {
    ser_poll(3);

    var startblk = CWDBLK;
    if (*name == '/') startblk = ROOTBLOCK;

    var err = catch();
    if (err) return err;

    # try to find the name
    var location = dirfindname(startblk, name);
    if (!location) return NOTFOUND;

    var blknum = location[0];
    var dirblk = location[1];
    var unlink_offset = location[2];
    var dir_parent = location[3];

    # don't unlink the empty string file, or "."
    if (dirblk == 0) return NOTFOUND;
    if (dirblk == blknum) return EXISTS;

    blkread(blknum, 0);
    # don't unlink non-empty directories
    if (blktype(0) == TYPE_DIR) {
        unlink_count = 0;
        dirwalk(blknum, func(name, blknum, dirblknum, dirent_offset) {
            if (*name) unlink_count++;
            return 1;
        });

        # an empty directory has just "." and ".."
        if (unlink_count != 2) return EXISTS;
    };

    # delete it from the directory
    blkread(dirblk, 0);
    dirent(BLKBUF+unlink_offset, "", 0);
    blkwrite(dirblk, 0);

    # free the rest of the blocks in the file
    blktrunc(blknum, 0);

    # free the first block
    blksetused(blknum, 0);

    # clear up the containing directory block if it's now empty
    dirgc(dir_parent, dirblk, 0);

    return 0;
};

sys_rename = func(oldname, newname) {
    ser_poll(3);

    var oldstartblk = CWDBLK;
    if (*oldname == '/') oldstartblk = ROOTBLOCK;
    var newstartblk = CWDBLK;
    if (*newname == '/') newstartblk = ROOTBLOCK;

    var err = catch();
    if (err) return err;

    # try to find the name
    var oldlocation = dirfindname(oldstartblk, oldname);
    if (!oldlocation) return NOTFOUND;

    var blknum = oldlocation[0];
    var dirblk = oldlocation[1];
    var unlink_offset = oldlocation[2];
    var dir_parent = oldlocation[3];

    # don't rename the empty string file, or "."
    if (dirblk == 0 || dirblk == blknum) return NOTFOUND;

    # don't rename ".."
    var name;
    undirent(BLKBUF+unlink_offset, &name, 0);
    if (name[0] == '.' && name[1] == '.' && name[2] == 0) return NOTFOUND;

    # create the new name, linked to the existing file
    var newlocation = dirmkname(newstartblk, newname, 0, blknum);
    if (!newlocation) return NOTFOUND;
    if (newlocation == -1) return EXISTS;

    # delete it from the old directory
    blkread(dirblk, 0);
    dirent(BLKBUF+unlink_offset, "", 0);
    blkwrite(dirblk, 0);

    # clear up the containing directory block if it's now empty
    dirgc(dir_parent, dirblk, 0);

    # if it's a directory, update its ".." pointer
    var dotdotlocation = dirfindname(blknum, "..");
    if (!dotdotlocation) return 0; # probably a normal file

    # read the block, rewrite the target pointer for "..", and write it back out
    blkread(dotdotlocation[1], BLKBUF);
    if (blktype(BLKBUF) == TYPE_DIR) {
        BLKBUF[dotdotlocation[2] + 15] = newlocation[3];
        blkwrite(dotdotlocation[1], BLKBUF);
    };

    return 0;

};
