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

sys_exit = func() {
    kpanic("exit");
};

# example: sys_system(0x8000, ["/bin/ls", "-l"])
sys_system  = func(top, args) {
    var err = catch();
    if (err) return err;

    # create filenames
    var userfile = "/proc/0.user";
    var kernelfile = "/proc/0.kernel";
    *(userfile+6) = pid+'0';
    *(kernelfile+6) = pid+'0';

    # open "/proc/$pid.user" for writing
    var ufd = sys_open(userfile, O_WRITE|O_CREAT);
    if (ufd < 0) return ufd;

    # copy bytes from 0x100..top
    var n = sys_write(ufd, 0x100, top-0x100);
    sys_close(ufd);
    if (n < 0) throw(n);
    if (n != top-0x100) kpanic("system(): write() didn't write enough");

    # open "/proc/$pid.kernel" for writing
    var kfd = sys_open(kernelfile, O_WRITE|O_CREAT);
    if (kfd < 0) return kfd;

    # copy into $pid.kernel:
    #  - stack pointer
    #  - return address
    #  - CWDBLK
    #  - fdtable
    #  - cmdargs
    # TODO: error checking
    sys_write(kfd, 0, 1); # TODO: stack pointer
    sys_write(kfd, 0, 1); # TODO: return address
    sys_write(kfd, &CWDBLK, 1);
    sys_write(kfd, fdtable, 128);
    sys_write(kfd, cmdargs, cmdargs_sz);
    sys_close(kfd);

    # execute the "child" process
    pid++;
    err = sys_exec(args);
    pid--;

    # if sys_exec() returned, there was an error

    # TODO: unlink $pid.user, $pid.kernel?
    return err;
};

# example: sys_exec(["/bin/ls", "/etc"])
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
