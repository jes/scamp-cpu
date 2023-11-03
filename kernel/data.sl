# Data storage and related functions

extern OSBASE;

# File descriptor table
#
# Each file descriptor contains 8 words:
#   0: read function pointer
#   1: write function pointer
#   2: close function pointer
#   3: sync function pointer
#   4..7: device-specific reserved space
const READFD  = 0;
const WRITEFD = 1;
const CLOSEFD = 2;
const SYNCFD  = 3;
const FDDATA  = 4;
#
# Unallocated fds should have all pointers set to 0
#
# Fixed fd allocations:
#   0: stdin  (change with copyfd)
#   1: stdout (change with copyfd)
#   2: stderr (change with copyfd)
#   3: serial port 0 (console)
const nfds = 16;
var KERNELFD = nfds-1;
# TODO: [nice] add some system call to allow the user process to specify extra
#       storage for extra file descriptors, and then file descriptors from
#       "nfds" upwards are in the user memory rather than the main fdtable; but
#       what happens upon system()? are the extra ones just lost?
const fdtable = 0xff40;

# fd base pointer is (fdtable + fd*8)
#var fdbaseptr = func(fd) {
#    if (fd ge nfds) return [0,0,0,0,0,0,0,0];
#    return fdtable+shl(fd,3);
#};

# usage: fdbaseptr(fd)
var fdbaseptr = asm {
    pop x
    ld r1, x # fd

    # if (fd >= nfds) return [0,0,0,0,0,0,0,0];
    cmp r1, 16 # (_nfds)
    jge fdbaseptr_badfd

    # if (fd < 0) return [0,0,0,0,0,0,0,0];
    cmp r1, 0
    jlt fdbaseptr_badfd

    # return fdtable+shl(fd,3)
    ld r0, 0xff40 # (_fdtable)
    shl2 r1
    shl r1
    add r0, r1
    ret

    fdbaseptr_badfd:
    ld r0, fdbaseptr_nullfd
    ret

    fdbaseptr_nullfd: .str "\0\0\0\0\0\0\0\0"
};

# return the next free fd, or -1 if there is none
var fdalloc = func() {
    var fd = 0;
    var i;

    # leave 1 fd free for kernel use
    while (fd != KERNELFD) {
        i = 0;
        while (i != 8) {
            if (*(fdbaseptr(fd)+i) != 0)
                break;
            i++;
        };
        # if all 8 fields are 0, this fd is free
        if (i == 8) return fd;
        fd++;
    };

    return -1;
};

# make the given fd available for use again
var fdfree = func(fd) {
    memset(fdbaseptr(fd), 0, 8);
};

var fd_init = func() {
    var i = 0;
    while (i != nfds) {
        fdfree(i);
        i++;
    };
};

# serial port fd fields
const BASEPORT = 4; # FDDATA;
const BUFPTR = 5; # FDDATA+1;
const SERFLAGS = 6; # FDDATA+2;

# serial port flags
const SER_COOKED   = 1;
const SER_DISABLE  = 2;
const SER_LONGREAD = 4;

# Block device state
const BLKSZ = 256; # 256 words, 512 bytes
var BLKBUF = asm { .gap 257 };
const TYPE_DIR = 0;
const TYPE_FILE = 0x100;
const DIRENTSZ = 16;

const SKIP_BLOCKS = 64; # to hold the kernel image
var ROOTBLOCK = SKIP_BLOCKS + 16; # skip the kernel image and the free-space bitmap

var nextfreeblk = 0;

# Command-line arguments
#
# Starts out with a 0-terminated list of pointers to strings; the strings
# immediately follow, with a 0 word after each one
var cmdargs_sz = 0;
var cmdargs = OSBASE - cmdargs_sz;

# Space to build names for undirent()
var undirent_str = asm { .gap 32 };

# block number of current working directory
var CWDBLK = ROOTBLOCK;

# file modes
const O_READ     = 0x01;
const O_WRITE    = 0x02;
const O_CREAT    = 0x04;
const O_NOTRUNC  = 0x08;
const O_APPEND   = 0x10;
const O_KERNELFD = 0x20;

# "process id"
var pid = 0;

var rngstate = 0;

var trapfunc = 0;
