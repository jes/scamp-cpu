# System calls

extern sys_getpid;
extern sys_savetpa;
extern sys_trap;
extern sys_blkwrite;
extern sys_blkread;
extern sys_random;
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

var getpid   = sys_getpid;
var trap     = sys_trap;
var blkwrite = sys_blkwrite;
var blkread  = sys_blkread;
var random   = sys_random;
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

var savetpa = func(filename) sys_savetpa(filename, TOP);

# file modes
const O_READ    = 0x01;
const O_WRITE   = 0x02;
const O_CREAT   = 0x04;
const O_NOTRUNC = 0x08;
const O_APPEND  = 0x10;

# error codes
const EOF = -1;
const NOTFOUND = -2;
const NOTFILE = -3;
const NOTDIR = -4;
const BADFD = -5;
const TOOLONG = -6;
const EXISTS = -7;

# serial flags
const SER_COOKED  = 1;
const SER_DISABLE = 2;
const SER_LONGREAD = 4;

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
