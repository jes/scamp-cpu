# Processes syscalls

include "util.sl";

extern sys_cmdargs;
extern sys_system;
extern sys_exec;
extern sys_exit;

sys_cmdargs = asm {
    ld r0, cmdargs
    ret
};

sys_system  = func() unimpl("system");
sys_exec    = func() unimpl("exec");
sys_exit    = func() unimpl("exit");
