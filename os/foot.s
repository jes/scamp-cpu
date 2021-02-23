
sys_osbase:
    ld r0, OSBASE
    ret

# kernel stack
.gap STACKSZ
INITIAL_SP: .word 0

# system call vectors
.at 0xfeec
_sys_cmdargs: .word 0
_sys_osbase:  .word sys_osbase
_sys_copyfd:  .word 0
_sys_unlink:  .word 0
_sys_stat:    .word 0
_sys_readdir: .word 0
_sys_opendir: .word 0
_sys_mkdir:   .word 0
_sys_chdir:   .word 0
_sys_tell:    .word 0
_sys_seek:    .word 0
_sys_close:   .word 0
_sys_open:    .word 0
_sys_read:    .word 0
_sys_getchar: .word 0
_sys_write:   .word 0
_sys_putchar: .word 0
_sys_system:  .word 0
_sys_exec:    .word 0
_sys_exit:    .word 0

# sanity check
.at 0xff00
