# Data storage and related functions

# File descriptor table
#
# Each file descriptor contains 8 words:
#   0: read function pointer
#   1: write function pointer
#   2: tell function pointer
#   3: seek function pointer
#   4: close function pointer
#   5..8: device-specific reserved space
var READFD =  0;
var WRITEFD = 1;
var TELLFD =  2;
var SEEKFD =  3;
var CLOSEFD = 4;
var FDDATA =  5;
#
# Unallocated fds should have all pointers set to 0
#
# Fixed fd allocations:
#   0: stdin  (change with copyfd)
#   1: stdout (change with copyfd)
#   2: stderr (change with copyfd)
#   3: serial port 0 (console)
#   4: serial port 1 (console)
var nfds = 16;
var fdtable = asm {
    fdtable: .gap 128 # space for 16 fds
};

# base pointer for an fd is that fd*8
var fdbaseptr = func(fd) {
    if (fd ge nfds) return [0,0,0,0,0,0,0,0];
    var fd8 = (fd+fd+fd+fd)+(fd+fd+fd+fd);
    return fdtable+fd8;
};

# Block device state
var BLKSZ = 256; # 256 words, 512 bytes
var BLKBUF = asm {
    BLKBUF: .gap 256
};
var BLKBUFNUM;

var TYPE_DIR = 0;
var TYPE_FILE = 0x200;

var blkselectport = 4;
var blkdataport = 5;

var nextfreeblk = 0;

# Command-line arguments
#
# Starts out with a 0-terminated list of pointers to strings; the strings
# immediately follow, with a 0 word after each one
var cmdargs_sz = 128; # words, including pointers, characters, and nuls
var cmdargs = asm {
    cmdargs: .gap 128
};
