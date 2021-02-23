# Filesystem

include "util.sl";

extern sys_open;
extern sys_close;
extern sys_unlink;
extern sys_stat;

sys_open   = func() unimpl("open");
sys_close  = func() unimpl("close");
sys_unlink = func() unimpl("unlink");
sys_stat   = func() unimpl("stat");
