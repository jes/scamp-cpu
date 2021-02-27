# System calls

extern sys_cmdargs;
extern sys_osbase;
extern sys_copyfd;
extern sys_unlink;
extern sys_stat;
extern sys_readdir;
extern sys_opendir;
extern sys_mkdir;
extern sys_chdir;
extern sys_tell;
extern sys_seek;
extern sys_close;
extern sys_open;
extern sys_read;
extern sys_write;
extern sys_system;
extern sys_exec;
extern sys_exit;

var cmdargs = sys_cmdargs;
var osbase  = sys_osbase;
var copyfd  = sys_copyfd;
var unlink  = sys_unlink;
var stat    = sys_stat;
var readdir = sys_readdir;
var mkdir   = sys_mkdir;
var chdir   = sys_chdir;
var tell    = sys_tell;
var seek    = sys_seek;
var close   = sys_close;
var open    = sys_open;
var read    = sys_read;
var write   = sys_write;
var system  = sys_system;
var exec    = sys_exec;
var exit    = sys_exit;
