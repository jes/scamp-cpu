# Processes syscalls

include "util.sl";
include "os_io.sl";
include "os_fs.sl";

extern sys_cmdargs;
extern sys_system;
extern sys_exec;
extern sys_exit;

sys_cmdargs = asm {
    ld r0, cmdargs
    ret
};

sys_exit    = func() unimpl("exit");
sys_system  = func() unimpl("system");

# example: sys_exec(["/bin/ls", "/etc", 0])
sys_exec = func(args) {
    var err = catch();
    if (err) return err;

    # TODO: copy args into cmdargs, up to cmdargs_sz words
    # TODO: what happens if no fds are available
    # TODO: put sp somewhere it won't trash the kernel if the program misbehaves? (i.e. osbase()?)

    # load file from disk
    kputs("init tries to open "); kputs(args[0]); kputs("\n");
    var fd = sys_open(args[0], O_READ);
    if (fd < 0) return fd;
    var p = 0x100;
    var n;
    while (1) {
        n = sys_read(fd, p, 1);
        if (n <= 0) break;
        p = p + n;
    };

    # jump to it
    var user = 0x100;
    user();
};
