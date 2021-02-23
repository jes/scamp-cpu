# Processes

extern sys_cmdargs;
extern sys_system;
extern sys_exec;
extern sys_exit;

sys_cmdargs = func() unimpl("cmdargs");
sys_system  = func() unimpl("system");
sys_exec    = func() unimpl("exec");
sys_exit    = func() unimpl("exit");
