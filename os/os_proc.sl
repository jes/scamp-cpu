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

# usage: return_to_caller(sp, ret, rc)
# restore stack pointer and return address, and return rc
var return_to_parent = asm {
    pop x
    ld r0, x
    pop x
    ld r254, x
    pop x
    ld sp, x
    ret
};

sys_exit = func(rc) {
    var err = catch();
    if (err) kpanic("exit() panics");

    pid--;

    # make sure there's at least 1 free fd slot
    # XXX: is this right? should we be doing more? less?
    sys_close(nfds-1);

    # create filenames
    var userfile = "/proc/0.user";
    var kernelfile = "/proc/0.kernel";
    *(userfile+6) = pid+'0';
    *(kernelfile+6) = pid+'0';

    # 1. restore user program
    var ufd = sys_open(userfile, O_READ);
    if (ufd < 0) throw(ufd);
    var n;
    var p = 0x100;
    while (1) {
        n = sys_read(ufd, p, 254);
        if (n == 0) break;
        if (n < 0) throw(n);
        p = p + n;
    };
    sys_close(ufd);

    # 2. restore kernel state
    # TODO: error checking
    var kfd = sys_open(kernelfile, O_READ);
    if (kfd < 0) throw(kfd);

    var sp;
    var ret;

    sys_read(kfd, &sp, 1);
    sys_read(kfd, &ret, 1);
    sys_read(kfd, &CWDBLK, 1);
    sys_read(kfd, fdtable, 128);
    sys_read(kfd, cmdargs, cmdargs_sz);
    sys_close(kfd);

    return_to_parent(sp, ret, rc);
    kpanic("return_to_parent() returned to exit()");
};

# example: sys_system(0x8000, ["/bin/ls", "-l"])
var sys_system_impl  = func(top, args, sp, ret) {
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
    sys_write(kfd, &sp, 1);
    sys_write(kfd, &ret, 1);
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

# copy the return address, stack pointer, and system() arguments into the
# kernel stack, switch to the kernel stack, and call sys_system_impl()
sys_system = asm {
    pop x
    ld r0, x # args
    pop x
    ld r1, x # top
    ld r2, sp # stack pointer
    ld r3, r254 # return address
    ld sp, INITIAL_SP
    ld x, r1 # top
    push x
    ld x, r0 # args
    push x
    ld x, r2 # stack pointer
    push x
    ld x, r3 # return address
    push x
    call (_sys_system_impl)

    # TODO: handle errors from sys_system_impl()

    ld x, system_panic_s
    push x
    call (_kpanic)

    system_panic_s: .str "system() return an error\0"
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
