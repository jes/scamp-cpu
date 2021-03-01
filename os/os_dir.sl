# Directories syscalls

include "util.sl";

extern sys_readdir;
extern sys_opendir;
extern sys_mkdir;
extern sys_chdir;

sys_readdir = func() unimpl("readdir");
sys_opendir = func() unimpl("opendir");
sys_chdir   = func() unimpl("chdir");

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
