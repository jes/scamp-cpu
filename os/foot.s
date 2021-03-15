
sys_osbase:
    ld r0, OSBASE
    ret

# kernel stack
#sym:kernel_stack
.gap STACKSZ
.word 0
#nosym
INITIAL_SP: .word 0

.at 0xfeec
# system call vectors
_sys_cmdargs: .word 0
_sys_osbase:  .word sys_osbase
_sys_copyfd:  .word 0
_sys_unlink:  .word 0
_sys_stat:    .word 0
_sys_readdir: .word 0
_sys_opendir: .word 0
_sys_mkdir:   .word 0
_sys_chdir:   .word 0
_sys_UNUSED1: .word 0
_sys_sync:    .word 0
_sys_close:   .word 0
_sys_open:    .word 0
_sys_read:    .word 0
_sys_setbuf:  .word 0
_sys_write:   .word 0
_sys_getcwd:  .word 0
_sys_system:  .word 0
_sys_exec:    .word 0
_sys_exit:    .word 0

# sanity check
.at 0xff00
