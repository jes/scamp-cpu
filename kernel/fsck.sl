# Filesystem check

include "kprintf.sl";

# check that the start of the disk is a valid boot header
var check_boot = func() {
    kputs("check boot header...\r\n");
    blkread(0, 0);

    if (BLKBUF[0] != 0x5343) kprintf("boot header: b[0] = %x, expected 0x5343\r\n", [BLKBUF[0]]);
    if (BLKBUF[1] < 0xa000) kprintf("boot header: b[1] = %x, seems unlikely; expected >= 0xa000\r\n", [BLKBUF[1]]);
    if (BLKBUF[1]+BLKBUF[2] < BLKBUF[1]) kprintf("boot header: b[1]+b[2] (%x+%x) overflows address\r\n", [BLKBUF[1],BLKBUF[2]]);
};

var usedmap = 0x0100; # length = 0x1000
var seenmap = 0x1100; # length = 0x1000

var load_usedmap = func() {
    var i = 0;
    var p = usedmap;

    while (i < 16) {
        blkread(SKIP_BLOCKS+i, 0);
        memcpy(p, BLKBUF, BLKSZ);
        p = p + BLKSZ;
        i++;
    };
};

var init_seenmap = func() {
    memset(seenmap, 0, 0x1000);
};

var blkisfree = func(blk) {
    var bitmapblk = shr12(blk);
    var blkgroup  = byteshr4(blk & 0x0fff);
    var i         = blk & 0x0f;

    var addr = shl(bitmapblk,8) | blkgroup;
    return (usedmap[addr] & powers_of_2[i]) == 0;
};

var blkisseen = func(blk) {
    var bitmapblk = shr12(blk);
    var blkgroup  = byteshr4(blk & 0x0fff);
    var i         = blk & 0x0f;

    var addr = shl(bitmapblk,8) | blkgroup;
    return (seenmap[addr] & powers_of_2[i]) != 0;
};

var blkmarkseen = func(blk) {
    var bitmapblk = shr12(blk);
    var blkgroup  = byteshr4(blk & 0x0fff);
    var i         = blk & 0x0f;

    var addr = shl(bitmapblk,8) | blkgroup;
    seenmap[addr] = seenmap[addr] | powers_of_2[i];
};

# walk the blocks in a file
# check for:
#  - files with length != 254 and next != 0
#  - linked blocks not marked as used
var filewalk = func(blknum) {
    if (blkisseen(blknum)) kprintf("\r\nblock %d is seen more than once (file)\r\n", [blknum]);
    blkmarkseen(blknum);
    if (blkisfree(blknum)) kprintf("\r\nblock %d is linked but free (file)\r\n", [blknum]);
    while (blknum) {
        kputs(".");
        blkread(blknum, 0);

        if (blknext(0) && blklen(0) != 254) kprintf("\r\nblock %d has next block %d but length=%d (should be 254)\r\n", [blknum, blknext(0), blklen(0)]);

        blknum = blknext(0);
    };
};

# usage: strcmp(s1,s2)
# return a value:
#  <0  if s1 < s2
#   0  if s1 == s2
#  >0  if s1 > s2
var strcmp = asm {
    pop x
    ld r2, x # r2 = s2
    pop x
    ld r1, x # r1 = s1

    # while (*s1 && *s2)
    strcmp_loop:
        ld x, (r1)
        and x, (r2)
        jz strcmp_done

        # if (*s1 != *s2) return *s1-*s2
        ld x, (r1)
        sub x, (r2)
        jz strcmp_cont
        ld r0, x
        ret

        strcmp_cont:
        inc r1
        inc r2
        jmp strcmp_loop
    strcmp_done:

    # return *s1-*s2
    ld x, (r1)
    sub x, (r2)
    ld r0, x
    ret
};

# walk the entire directory tree 
# check for:
#  - illegal block type
#  - [TODO] directories that lack "." or ".."
#  - linked blocks not marked as used
#  - [TODO] blocks marked as used but not linked
#  - [TODO] blocks used more than once
var check_file = func(blk) {
    blkread(blk, 0);

    if (blktype(0) == TYPE_DIR) {
        kputs("D");
        if (blkisseen(blk)) kprintf("\r\nblock %d is seen more than once (dir)\r\n", [blk]);
        blkmarkseen(blk);
        if (blkisfree(blk)) kprintf("\r\nblock %d is linked but free (dir)\r\n", [blk]);
        dirwalk(blk, func(name, blknum, dirblknum, dirent_offset) {
            if (dirent_offset == 2) kputs(".");
            if (strcmp(name, ".") == 0) {
                if (blknum != dirblknum) kprintf("\r\nin dir block %d, '.' links to %d\r\n", [dirblknum,blknum]);
                return 1;
            } else if (strcmp(name, "..") == 0) {
                # TODO: [nice] check that it actually links to the parent dir
                return 1;
            };
            if (*name) {
                if (blknum < 80) kprintf("\r\nin dir block %d, %s links to %d\r\n", [dirblknum, name, blknum]);
                check_file(blknum);
                blkread(dirblknum, 0); # XXX: restore block for this dirwalk()
            };
            return 1;
        });
    } else if (blktype(0) == TYPE_FILE) {
        kputs("F");

        filewalk(blk);
    } else {
        kprintf("\r\nblock %d has illegal file type (%x)\r\n", [blk, blktype(0)]);
    };
};

# load free-space bitmap and start recursively checking directors starting at /
var check_dirs = func() {
    kputs("load free-space bitmap into memory...\r\n");
    load_usedmap();
    init_seenmap();

    kputs("check directories...\r\n");
    check_file(ROOTBLOCK);
};

var fsck = func() {
    check_boot();
    check_dirs();
    kputs(" fsck done\r\n");
};
