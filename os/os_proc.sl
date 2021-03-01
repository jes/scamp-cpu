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

    # TODO: bounds-check args copying
    # TODO: what happens if no fds are available
    # TODO: put sp somewhere it won't trash the kernel if the program misbehaves? (i.e. osbase()?)

    # count the number of arguments
    var nargs = 0;
    while (args[nargs]) nargs++;

    # copy the args into cmdargs
    var cmdargp = cmdargs + nargs + 1;
    var i = 0;
    var j;
    while (args[i]) {
        *(cmdargs+i) = cmdargp;
        j = 0;
        while (args[i][j]) {
            *(cmdargp++) = args[i][j];
            j++;
        };
        *(cmdargp++) = 0;
        i++;
    };
    *(cmdargs+i) = 0;

    # load file from disk
    var fd = sys_open(args[0], O_READ);
    if (fd < 0) return fd;
    var p = 0x100;
    var n;
    while (1) {
        n = sys_read(fd, p, 254);
        if (n <= 0) break;
        p = p + n;
    };
    sys_close(fd);

    # jump to it
    var user = 0x100;
    user();
    kpanic("user program returned to exec() call");
};
