.at 0x100

# initialise sp and TOP
.def STACKSZ 2048
ld sp, TOP
add sp, STACKSZ

# stack grows down, _TOP grows up;
# make _TOP point 1 word past the initial stack pointer
ld (_TOP), sp
inc (_TOP)

# system call vectors
.def _sys_cmdargs 0xfeec
.def _sys_osbase  0xfeed
.def _sys_copyfd  0xfeee
.def _sys_unlink  0xfeef
.def _sys_stat    0xfef0
.def _sys_readdir 0xfef1
.def _sys_opendir 0xfef2
.def _sys_mkdir   0xfef3
.def _sys_chdir   0xfef4
.def _sys_tell    0xfef5
.def _sys_seek    0xfef6
.def _sys_close   0xfef7
.def _sys_open    0xfef8
.def _sys_read    0xfef9
.def _sys_UNUSED1 0xfefa
.def _sys_write   0xfefb
.def _sys_getcwd  0xfefc
.def _sys_system  0xfefd
.def _sys_exec    0xfefe
.def _sys_exit    0xfeff
