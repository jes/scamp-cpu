# Processes syscalls

include "util.sl";
include "os_io.sl";
include "os_fs.sl";
include "sys.sl";

sys_cmdargs = asm {
    ld r0, cmdargs
    ret
};

# usage: return_to_parent(sp, ret, rc)
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

var sys_exit_impl = func(rc) {
    var err = catch();
    denycatch();
    if (err) kpanic("exit() panics");

    if (pid == 0) kpanic("init exits.");
    pid--;

    # sync buffers
    sys_sync(-1);

    # create filenames
    var userfile = "/proc/0.user";
    var kernelfile = "/proc/0.kernel";
    *(userfile+6) = pid+'0';
    *(kernelfile+6) = pid+'0';

    # 1. restore user program
    var ufd = sys_open(userfile, O_READ|O_KERNELFD);
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
    var kfd = sys_open(kernelfile, O_READ|O_KERNELFD);
    if (kfd < 0) throw(kfd);

    var sp;
    var ret;

    sys_read(kfd, &sp, 1);
    sys_read(kfd, &ret, 1);
    sys_read(kfd, &CWDBLK, 1);
    sys_read(kfd, fdtable, 128);
    sys_read(kfd, cmdargs, cmdargs_sz);
    sys_close(kfd);

    sys_unlink(userfile);
    sys_unlink(kernelfile);

    allowcatch();
    return_to_parent(sp, ret, rc);
    kpanic("return_to_parent() returned to exit()");
};

# copy the rc, switch to the kernel stack, and call sys_exit_impl()
sys_exit = asm {
    pop x
    ld sp, INITIAL_SP
    push x
    jmp (_sys_exit_impl)

    jr- 1 # XXX: sys_exit_impl() shouldn't ever return
};

# example: sys_system(0x8000, ["/bin/ls", "-l"])
var sys_system_impl  = func(top, args, sp, ret) {
    var err = catch();
    denycatch();
    if (err) {
        allowcatch();
        return err;
    };

    # sync buffers
    sys_sync(-1);

    # create filenames
    # TODO: [bug] should support more than 1 digit in filenames
    var userfile = "/proc/0.user";
    var kernelfile = "/proc/0.kernel";
    *(userfile+6) = pid+'0';
    *(kernelfile+6) = pid+'0';

    # open "/proc/$pid.user" for writing
    var ufd = sys_open(userfile, O_WRITE|O_CREAT|O_KERNELFD);
    if (ufd < 0) throw(ufd);

    # copy bytes from 0x100..top
    var n = sys_write(ufd, 0x100, top-0x100);
    sys_close(ufd);
    if (n < 0) throw(n);
    if (n != top-0x100) kpanic("system(): write() didn't write enough");

    # open "/proc/$pid.kernel" for writing
    var kfd = sys_open(kernelfile, O_WRITE|O_CREAT|O_KERNELFD);
    if (kfd < 0) throw(kfd);

    # copy into $pid.kernel:
    #  - stack pointer
    #  - return address
    #  - CWDBLK
    #  - fdtable
    #  - cmdargs
    # TODO: [bug] error checking
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

    sys_unlink(userfile);
    sys_unlink(kernelfile);

    allowcatch();
    return err;
};

# call sys_system_impl() with the return address, stack pointer, and system() arguments
sys_system = asm {
    ld x, sp # stack pointer
    add x, 2 # pop past the 2 args to system()
    push x
    ld x, r254 # return address
    push x
    jmp (_sys_system_impl)

    # TODO: [nice] how can we distinguish a system() error from a return code from the child?
};

var jmp_to_user = asm {
    # put sp below kernel so that a misbehaving program is less likely to trash the kernel
    ld sp, OSBASE
    dec sp

    # jump to program
    jmp 0x100
};

# example: sys_exec(["/bin/ls", "/etc"])
var sys_exec_impl = func(args) {
    var fd = -1;
    var err = catch();
    denycatch();
    if (err) {
        if (fd >= 0) sys_close(fd);
        allowcatch();
        return err;
    };

    # TODO: [nice] what happens if no fds are available

    # count the number of arguments
    var nargs = 0;
    while (args[nargs]) nargs++;

    # copy the args into cmdargs
    var cmdargp = cmdargs + nargs + 1;
    var max_cmdargp = cmdargs + cmdargs_sz - 2;
    var i = 0;
    var j;
    while (args[i]) {
        *(cmdargs+i) = cmdargp;
        j = 0;
        while (args[i][j]) {
            *(cmdargp++) = args[i][j];
            if (cmdargp == max_cmdargp) throw(TOOLONG);
            j++;
        };
        *(cmdargp++) = 0;
        i++;
    };
    *(cmdargs+i) = 0;

    # load file from disk
    fd = sys_open(args[0], O_READ);
    if (fd < 0) throw(fd);
    var p = 0x100;
    var n;
    while (1) {
        n = sys_read(fd, p, 16384);
        if (n == 0) break;
        if (n < 0) throw(n);
        p = p + n;
    };
    sys_close(fd);

    # jump to it
    allowcatch();
    jmp_to_user();
    kpanic("user program returned to exec() call");
};

# copy arg pointer, switch to kernel stack, and call sys_exec_impl()
var exec_sp;
var exec_ret;
sys_exec = asm {
    pop x
    ld (_exec_ret), r254
    ld (_exec_sp), sp

    ld sp, INITIAL_SP
    push x
    call (_sys_exec_impl)

    ld sp, (_exec_sp)
    ld r254, (_exec_ret)
    ret
};
