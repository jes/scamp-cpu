# System calls

extern sys_serflags;
extern sys_cmdargs;
extern sys_osbase;
extern sys_copyfd;
extern sys_unlink;
extern sys_stat;
extern sys_readdir;
extern sys_opendir;
extern sys_mkdir;
extern sys_chdir;
extern sys_rename;
extern sys_sync;
extern sys_close;
extern sys_open;
extern sys_read;
extern sys_setbuf;
extern sys_write;
extern sys_getcwd;
extern sys_system;
extern sys_exec;
extern sys_exit;

var serflags = sys_serflags;
var cmdargs  = sys_cmdargs;
var osbase   = sys_osbase;
var copyfd   = sys_copyfd;
var unlink   = sys_unlink;
var stat     = sys_stat;
var readdir  = sys_readdir;
var opendir  = sys_opendir;
var mkdir    = sys_mkdir;
var chdir    = sys_chdir;
var rename   = sys_rename;
var sync     = sys_sync;
var close    = sys_close;
var open     = sys_open;
var read     = sys_read;
var setbuf   = sys_setbuf;
var write    = sys_write;
var getcwd   = sys_getcwd;
var exec     = sys_exec;
var exit     = sys_exit;

# example: system(["/bin/ls", "-l"])
extern TOP;
var system = func(args) sys_system(TOP, args);

# file modes
var O_READ    = 0x01;
var O_WRITE   = 0x02;
var O_CREAT   = 0x04;
var O_NOTRUNC = 0x08;
var O_APPEND  = 0x10;

# error codes
var EOF = -1;
var NOTFOUND = -2;
var NOTFILE = -3;
var NOTDIR = -4;
var BADFD = -5;
var TOOLONG = -6;
var EXISTS = -7;

var strerror = func(err) {
    if (err == 0) return "success";
    if (err == EOF) return "end-of-file";
    if (err == NOTFOUND) return "not found";
    if (err == NOTFILE) return "not a file";
    if (err == NOTDIR) return "not a directory";
    if (err == BADFD) return "bad file descriptor";
    if (err == TOOLONG) return "path component too long";
    if (err == EXISTS) return "path exists";
    return "<unknown error>";
};
