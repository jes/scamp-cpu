
_OSBASE: .word OSBASE

# kernel stack
#sym:kernel_stack
.gap STACKSZ
#nosym
INITIAL_SP: .word 0

.at 0xfee6
# system call vectors
_sys_savetpa:  .word 0
_sys_trap:     .word 0
_sys_blkwrite: .word 0
_sys_blkread:  .word 0
_sys_random:   .word 0
_sys_serflags: .word 0
_sys_cmdargs:  .word 0
_sys_osbase:   .word 0
_sys_copyfd:   .word 0
_sys_unlink:   .word 0
_sys_stat:     .word 0
_sys_readdir:  .word 0
_sys_opendir:  .word 0
_sys_mkdir:    .word 0
_sys_chdir:    .word 0
_sys_rename:   .word 0
_sys_sync:     .word 0
_sys_close:    .word 0
_sys_open:     .word 0
_sys_read:     .word 0
_sys_setbuf:   .word 0
_sys_write:    .word 0
_sys_getcwd:   .word 0
_sys_system:   .word 0
_sys_exec:     .word 0
_sys_exit:     .word 0

# sanity check
.at 0xff00
