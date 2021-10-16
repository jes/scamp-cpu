# we need ".at" to start us at the point where "head.s" will end
.at 0x10a

# point to the _TOP storage allocated in head.s
.def _TOP 0x109

# system call vectors
.def _sys_blkwrite 0xfee8
.def _sys_blkread  0xfee9
.def _sys_random   0xfeea
.def _sys_serflags 0xfeeb
.def _sys_cmdargs  0xfeec
.def _sys_osbase   0xfeed
.def _sys_copyfd   0xfeee
.def _sys_unlink   0xfeef
.def _sys_stat     0xfef0
.def _sys_readdir  0xfef1
.def _sys_opendir  0xfef2
.def _sys_mkdir    0xfef3
.def _sys_chdir    0xfef4
.def _sys_rename   0xfef5
.def _sys_sync     0xfef6
.def _sys_close    0xfef7
.def _sys_open     0xfef8
.def _sys_read     0xfef9
.def _sys_setbuf   0xfefa
.def _sys_write    0xfefb
.def _sys_getcwd   0xfefc
.def _sys_system   0xfefd
.def _sys_exec     0xfefe
.def _sys_exit     0xfeff
