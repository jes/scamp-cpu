# File/device IO

include "util.sl";

extern sys_copyfd;
extern sys_tell;
extern sys_seek;
extern sys_read;
extern sys_getchar;
extern sys_write;
extern sys_putchar;

sys_copyfd  = func() unimpl("copyfd");
sys_tell    = func() unimpl("tell");
sys_seek    = func() unimpl("seek");
sys_read    = func() unimpl("read");
sys_getchar = func() unimpl("getchar");
sys_write   = func() unimpl("write");
sys_putchar = func() unimpl("putchar");
