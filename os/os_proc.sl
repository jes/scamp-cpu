# Processes

include "util.sl";

extern sys_cmdargs;
extern sys_system;
extern sys_exec;
extern sys_exit;

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
#
# Unallocated fds should have all pointers set to 0
var nfds = 16;
var fdtable = asm {
    fdtable: .gap 128 # space for 16 fds
};

# base pointer for an fd is that fd*8
# TODO: return an all-0s fd if the given fd is illegal
var fdbaseptr = asm {
    pop x
    shl3 x
    ld r0, fdtable
    add r0, x
    ret
};

# Command-line arguments
#
# Starts out with a 0-terminated list of pointers to strings; the strings
# immediately follow, with a 0 word after each one
var cmdargs_sz = 128; # words, including pointers, characters, and nuls
var cmdargs = asm {
    cmdargs: .gap 128
};

sys_cmdargs = asm {
    ld r0, cmdargs
    ret
};

sys_system  = func() unimpl("system");
sys_exec    = func() unimpl("exec");
sys_exit    = func() unimpl("exit");
