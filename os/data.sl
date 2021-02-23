# Data storage and related functions

# File descriptor table
#
# Each file descriptor contains 8 words:
#   0: read function pointer
#   1: write function pointer
#   2: getchar function pointer
#   3: putchar function pointer
#   4: tell function pointer
#   5: seek function pointer
#   6..8: device-specific reserved space
# TODO: what about close()?
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

# Command-line arguments
#
# Starts out with a 0-terminated list of pointers to strings; the strings
# immediately follow, with a 0 word after each one
var cmdargs_sz = 128; # words, including pointers, characters, and nuls
var cmdargs = asm {
    cmdargs: .gap 128
};
