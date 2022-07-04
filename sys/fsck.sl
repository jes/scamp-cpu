# Filesystem check
# This used to live in the kernel, but when it was moved to userspace a lot of stuff was
# just copy-and-pasted out of the kernel code. There's probably neater ways to do a lot
# of this.

include "stdio.sl";

var SKIP_BLOCKS = 64;
var ROOTBLOCK = SKIP_BLOCKS + 16; # skip the kernel image and the free-space bitmap
var BLKSZ = 256;
var BLKBUF;
var TYPE_DIR = 0;
var TYPE_FILE = 0x100;
var DIRENTSZ = 16;

# >>12 1 arg from the stack and return the result in r0
var shr12 = asm {
    pop x
    ld r0, x
    ld r1, r254 # stash return address
    ld r254, 0
    tbsz r0, 0x8000
    sb r254, 0x8
    tbsz r0, 0x4000
    sb r254, 0x4
    tbsz r0, 0x2000
    sb r254, 0x2
    tbsz r0, 0x1000
    sb r254, 0x1
    ld r0, r254
    jmp r1 # return
};

# >>4 1 arg from the stack and return the result in r0
# note upper byte is ignored
var byteshr4 = asm {
    pop x
    ld r0, x
    ld r1, r254 # stash return address
    ld r254, 0
    tbsz r0, 0x800
    sb r254, 0x80
    tbsz r0, 0x400
    sb r254, 0x40
    tbsz r0, 0x200
    sb r254, 0x20
    tbsz r0, 0x100
    sb r254, 0x10
    tbsz r0, 0x80
    sb r254, 0x8
    tbsz r0, 0x40
    sb r254, 0x4
    tbsz r0, 0x20
    sb r254, 0x2
    tbsz r0, 0x10
    sb r254, 0x1
    ld r0, r254
    jmp r1 # return
};

# get the "type"/"length"/"next" field of the current block
var blktype = func(buf) {
    if (!buf) buf = BLKBUF;
    return buf[0] & 0xff00;
};
var blklen = func(buf) {
    if (!buf) buf = BLKBUF;
    return buf[0] & 0x00ff;
};
var blknext = func(buf) {
    if (!buf) buf = BLKBUF;
    return buf[1];
};

# >>8 1 arg from the stack and return the result in r0
var kernel_shr8 = asm {
    # XXX: careful changing this! undirent() assumes it only
    # clobbers r0,r1,r254
    pop x
    ld r0, x
    ld r1, r254 # stash return address
shr8_entry:
    ld r254, 0
    tbsz r0, 0x8000
    sb r254, 0x80
    tbsz r0, 0x4000
    sb r254, 0x40
    tbsz r0, 0x2000
    sb r254, 0x20
    tbsz r0, 0x1000
    sb r254, 0x10
    tbsz r0, 0x0800
    sb r254, 0x08
    tbsz r0, 0x0400
    sb r254, 0x04
    tbsz r0, 0x0200
    sb r254, 0x02
    tbsz r0, 0x0100
    sb r254, 0x01
    ld r0, r254
    jmp r1 # return
};

var undirent_str = asm { .gap 32 };
# decode the dirent starting at dirent into a name and block number;
# store a pointer to a (static) string containing the name in *pname,
# and store the block number in *pblknum
#var undirent = func(dirent, pname, pblknum) {
#    var p = dirent;
#    var s = undirent_str;
#
#    while (p != dirent+15) {
#        *s = shr8(*p); # high byte
#        if (!*s) break;
#        s++;
#
#        *s = *p & 0xff; # low byte
#        if (!*s) break;
#        s++;
#
#        p++;
#    };
#
#    *s = 0; # nul-terminate even if the name in the dirent used all 30 chars
#
#    *pname = undirent_str;
#    *pblknum = dirent[15];
#};
var undirent = asm {
    # XXX: undirent() can't use r0,r1,r254 because shr8() uses them
    pop x
    ld r3, x # pblknum
    pop x
    ld r2, x # pname
    pop x
    ld r4, x # dirent

    # stash return address
    ld x, r254
    push x

    ld r5, r4 # p = dirent
    ld r6, (_undirent_str) # s = undirent_str

    add r4, 15 # r4 == dirent+15

    undirent_loop:
        # if (p == dirent+15) break;
        ld x, r5
        cmp x, r4
        jz undirent_done

        # *s = shr8(*p); # high byte
        ld r0, (x) # passed into shr8

        ld r1, shr8_ret_to_undirent
        jmp shr8_entry
        shr8_ret_to_undirent:

        ld x, r0
        ld (r6), x
        # if (!*s) break;
        jz undirent_done
        # s++;
        inc r6

        # *s = *(p++) & 0xff; # low byte
        ld x, (r5++)
        and x, 0xff
        ld (r6), x
        # if (!*s) break;
        jz undirent_done
        # s++;
        inc r6

        jmp undirent_loop

    undirent_done:
    ld (r6), 0 # *s = 0
    ld x, (_undirent_str)
    ld (r2), x # *pname = undirent_str

    ld x, (r4)
    ld (r3), x # *pblknum = dirent[15]

    # return
    pop x
    jmp x
};

# call cb(name, blknum, dirblknum, dirent_offset) for every entry in the
# directory starting at "dirblk"; callback arguments are:
#   name:          file/directory name (this will be "" for unallocated dirents)
#   blknum:        block number that this name is linked to
#   dirblknum:     number of directory block that this name is in
#   dirent_offset: word offset of the dirent for this name in "dirblknum"
# cb() should return 1 to continue searching or 0 to bail early
var dirwalk = func(dirblk, cb) {
    var off;
    var name;
    var blknum;
    var next;
    while (1) {
        BLKBUF = blkread(dirblk);
        if (blktype(0) != TYPE_DIR) {
            printf("directory block %d is not a directory block\n", [dirblk]);
            return 0;
        };
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

# check that the start of the disk is a valid boot header
var check_boot = func() {
    puts("check boot header...\n");
    BLKBUF = blkread(0);

    if (BLKBUF[0] != 0x5343) printf("boot header: b[0] = %x, expected 0x5343\n", [BLKBUF[0]]);
    if (BLKBUF[1] < 0xa000) printf("boot header: b[1] = %x, seems unlikely; expected >= 0xa000\n", [BLKBUF[1]]);
    if (BLKBUF[1]+BLKBUF[2] < BLKBUF[1]) printf("boot header: b[1]+b[2] (%x+%x) overflows address\n", [BLKBUF[1],BLKBUF[2]]);
};

var usedmap = malloc(0x1000);
var seenmap = malloc(0x1000);

var load_usedmap = func() {
    var i = 0;
    var p = usedmap;

    while (i < 16) {
        BLKBUF = blkread(SKIP_BLOCKS+i);
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
    if (blkisseen(blknum)) printf("\nblock %d is seen more than once (file)\n", [blknum]);
    blkmarkseen(blknum);
    if (blkisfree(blknum)) printf("\nblock %d is linked but free (file)\n", [blknum]);
    while (blknum) {
        puts(".");
        BLKBUF = blkread(blknum);

        if (blknext(0) && blklen(0) != 254) printf("\nblock %d has next block %d but length=%d (should be 254)\n", [blknum, blknext(0), blklen(0)]);

        blknum = blknext(0);
    };
};

# walk the entire directory tree 
# check for:
#  - illegal block type
#  - [TODO] directories that lack "." or ".."
#  - linked blocks not marked as used
#  - [TODO] blocks marked as used but not linked
#  - [TODO] blocks used more than once
var check_file = func(blk) {
    BLKBUF = blkread(blk);

    if (blktype(0) == TYPE_DIR) {
        puts("D");
        if (blkisseen(blk)) printf("\nblock %d is seen more than once (dir)\n", [blk]);
        blkmarkseen(blk);
        if (blkisfree(blk)) printf("\nblock %d is linked but free (dir)\n", [blk]);
        dirwalk(blk, func(name, blknum, dirblknum, dirent_offset) {
            if (dirent_offset == 2) puts(".");
            if (strcmp(name, ".") == 0) {
                if (blknum != dirblknum) printf("\nin dir block %d, '.' links to %d\n", [dirblknum,blknum]);
                return 1;
            } else if (strcmp(name, "..") == 0) {
                # TODO: [nice] check that it actually links to the parent dir
                return 1;
            };
            if (*name) {
                if (blknum < 80) printf("\nin dir block %d, %s links to %d\n", [dirblknum, name, blknum]);
                check_file(blknum);
                BLKBUF = blkread(dirblknum); # XXX: restore block for this dirwalk()
            };
            return 1;
        });
    } else if (blktype(0) == TYPE_FILE) {
        puts("F");

        filewalk(blk);
    } else {
        printf("\nblock %d has illegal file type (%x)\n", [blk, blktype(0)]);
    };
};

# load free-space bitmap and start recursively checking directors starting at /
var check_dirs = func() {
    puts("load free-space bitmap into memory...\n");
    load_usedmap();
    init_seenmap();

    puts("check directories...\n");
    check_file(ROOTBLOCK);
};

check_boot();
check_dirs();
puts(" fsck done\n");
