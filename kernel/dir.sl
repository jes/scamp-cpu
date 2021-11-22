# Directory handling routines

# encode (name,blknum) into a dirent at the given dirent address
# "name" has max. length of 30 characters
# example:
#    dirent(BLKBUF+off, "foo.txt", 1234)
const dirent = func(dirent, name, blknum) {
    var s = name;
    var i = 0;

    while (1) {
        *(dirent+i) = shl(*s, 8);
        if (!*s) break;
        s++;

        *(dirent+i) = dirent[i] | (*s & 0xff);
        if (!*s) break;
        s++;

        i++;
        if (i == 16) throw(TOOLONG);
    };

    *(dirent+15) = blknum;
};

# decode the dirent starting at dirent into a name and block number;
# store a pointer to a (static) string containing the name in *pname,
# and store the block number in *pblknum
const undirent = func(dirent, pname, pblknum) {
    var p = dirent;
    var s = undirent_str;

    while (p != dirent+15) {
        *s = shr8(*p); # high byte
        if (!*s) break;
        s++;

        *s = *p & 0xff; # low byte
        if (!*s) break;
        s++;

        p++;
    };

    *s = 0; # nul-terminate even if the name in the dirent used all 30 chars

    *pname = undirent_str;
    *pblknum = dirent[15];
};

# call cb(name, blknum, dirblknum, dirent_offset) for every entry in the
# directory starting at "dirblk"; callback arguments are:
#   name:          file/directory name (this will be "" for unallocated dirents)
#   blknum:        block number that this name is linked to
#   dirblknum:     number of directory block that this name is in
#   dirent_offset: word offset of the dirent for this name in "dirblknum"
# cb() should return 1 to continue searching or 0 to bail early
const dirwalk = func(dirblk, cb) {
    var off;
    var name;
    var blknum;
    var next;
    while (1) {
        blkread(dirblk, 0);
        if (blktype(0) != TYPE_DIR) throw(NOTDIR);
        next = blknext(0);

        off = 2;
        while ((off+DIRENTSZ) <= BLKSZ) {
            undirent(BLKBUF+off, &name, &blknum);
            if (cb(name, blknum, dirblk, off) == 0) return 0;
            off = off + DIRENTSZ;
        };

        # proceed to next block in this directory, if there is one
        if (!next) break;
        dirblk = next;
    };
};

# find the given name in dirblk, traversing directories as necessary
# return a pointer to a static list:
#  [
#    blknum,           # the block number that the name links to
#    dirblknum,        # the block number that the name was found in
#    dirent_offset,    # the word offset of the dirent for this name
#    parent_dirblknum, # the block number of the immediate parent of the
#                      # directory block that the name was found in
#  ]
# return a null pointer if not found
var dir_offset;
var dir_name;
var dir_blknum;
var dir_dirblknum;
var dir_parentblknum;
var dir_curblknum;
const dirfindname = func(dirblk, findname) {
    dir_name = findname;
    while (*dir_name == '/') dir_name++;

    if (!*dir_name) return [dirblk, 0, 0];

    while (1) {
        dir_blknum = 0;
        dir_parentblknum = 0;
        dir_curblknum = 0;

        dirwalk(dirblk, func(name, blknum, dirblknum, dirent_offset) {
            if (dirblknum != dir_curblknum) {
                dir_parentblknum = dir_curblknum;
                dir_curblknum = dirblknum;
            };
            if (*name && pathbegins(dir_name, name)) {
                while (*dir_name && *dir_name != '/') dir_name++;
                dir_blknum = blknum;
                dir_dirblknum = dirblknum;
                dir_offset = dirent_offset;
                return 0; # found it
            } else {
                return 1; # keep searching
            };
        });

        if (dir_blknum == 0) return 0; # doesn't exist

        while (*dir_name == '/') dir_name++;
        if (*dir_name == 0) break;

        dirblk = dir_blknum;
    };

    return [dir_blknum, dir_dirblknum, dir_offset, dir_parentblknum];
};

# create the given name in dirblk, traversing directories as necessary
# return a pointer to a static list:
#  [
#    blknum,        # the block number that the name links to
#    dirblknum,     # the block number that the name was created in
#    dirent_offset, # the word offset of the dirent for this name
#    parent_blknum, # the block number of the start of the parent directory
#  ]
# return a null pointer if intermediate path components are not found, or
# -1 if the file already exists
# if "firstblock" is 0, "mktype" should set the type of block to allocate
# if "firstblock" is nonzero, "mktype" is ignored
var dir_lastblk;
const dirmkname = func(dirblk, mkname, mktype, firstblock) {
    dir_name = mkname;
    while (*dir_name == '/') dir_name++;

    while (1) {
        dir_blknum = 0;

        dirwalk(dirblk, func(name, blknum, dirblknum, dirent_offset) {
            if (*name && pathbegins(dir_name, name)) {
                while (*dir_name && *dir_name != '/') dir_name++;
                dir_blknum = blknum;
                return 0; # found it
            } else {
                return 1; # keep searching
            };
        });

        while (*dir_name == '/') dir_name++;
        if (*dir_name == 0) return -1; # file already exists

        if (dir_blknum == 0) break; # doesn't exist

        dirblk = dir_blknum;
    };

    # "dirblk" is the directory that "dir_name" should be created in

    # if "dir_name" has slashes in, then some intermediate path components don't exist
    var p = dir_name;
    while (*p && *p != '/') p++;
    if (*p) return 0; # intermediate components don't exist

    # allocate a block for our new file, if we don't already have one
    var blknum = firstblock;
    if (blknum == 0) {
        blknum = nextfreeblk;
        blksetused(blknum, 1);

        # initialise the new file
        blksettype(mktype, 0);
        blksetlen(0, 0);
        blksetnext(0, 0);
        blkwrite(blknum, 0);
    };

    # find an empty dirent and stick a link in
    dir_blknum = 0;
    dir_lastblk = 0;
    dirwalk(dirblk, func(name, blknum, dirblknum, dirent_offset) {
        dir_lastblk = dirblknum;
        if (*name) return 1; # keep searching until we find an unused dirent

        # save the location of the unused dirent and stop searching
        dir_blknum = dirblknum;
        dir_offset = dirent_offset;
        return 0;
    });

    var i;
    if (dir_blknum == 0) {
        # allocate a new block for this directory
        dir_blknum = nextfreeblk;
        blksetused(dir_blknum, 1);

        # write a header
        blksettype(TYPE_DIR, 0);
        blksetnext(0, 0);
        memset(BLKBUF+2, 0, BLKSZ-2); # zero out the filenames
        blkwrite(dir_blknum, 0);

        # link it in to the directory
        blkread(dir_lastblk, 0);
        blksetnext(dir_blknum, 0);
        blkwrite(dir_lastblk, 0);

        dir_offset = 2; # skip header
    };

    # now the dirent we should write to is at "dir_offset" into block number "dir_blknum"
    # and the new name is "dir_name" with contents starting at block "blknum"
    blkread(dir_blknum, 0);
    dirent(BLKBUF+dir_offset, dir_name, blknum);
    blkwrite(dir_blknum, 0);

    return [blknum, dir_blknum, dir_offset, dirblk];
};

# unlink "dirblk" from its parent "parentblk" if "dirblk" is now empty
# "dirblk" should be the next block for "parentblk";
# "blkbuf" can be the block buffer to use, or 0 to use BLKBUF, either way note
# that it will get clobbered
const dirgc = func(parentblk, dirblk, blkbuf) {
    if (!parentblk) return 0;

    if (!blkbuf) blkbuf = BLKBUF;

    blkread(dirblk, blkbuf);

    # if any of the entries are still in use, we can't gc this directory
    var off = 2;
    var pname;
    while ((off+DIRENTSZ) <= BLKSZ) {
        # if the first byte of any entry's name is nonzero, then the directory
        # still contains at least one entry, so we just return early
        pname = blkbuf+off;
        if (*pname & 0xff00) return 0;

        off = off + DIRENTSZ;
    };

    # OK, we now know that this block is empty

    # remember its "next" block
    var nextdirblk = blknext(blkbuf);

    # verify that blknext of parentblk==dirblk, else panic
    blkread(parentblk, blkbuf);
    if (blknext(blkbuf) != dirblk) kpanic("dirgc: bad block");

    # now unlink this block from the list
    blksetnext(nextdirblk, blkbuf);
    blkwrite(parentblk, blkbuf);

    # and mark the free'd block as free
    blksetused(dirblk, 0);

    # TODO: [nice] we could "de-fragment" directory entries even when they're
    #       not fully empty, by moving entries up to the first empty slots?
};
