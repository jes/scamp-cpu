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
    if (err) kpanic("exit() panics");

    if (pid == 0) kpanic("init exits.");
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

# copy the rc, switch to the kernel stack, and call sys_exit_impl()
sys_exit = asm {
    pop x
    ld sp, INITIAL_SP
    push x
    call (_sys_exit_impl)

    jr- 1 # XXX: sys_exit_impl() shoudln't ever return
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

    # TODO: [nice] unlink $pid.user, $pid.kernel?
    return err;
};

# copy the return address, stack pointer, and system() arguments into the
# kernel stack, switch to the kernel stack, and call sys_system_impl()
var system_sp;
var system_ret;
sys_system = asm {
    pop x
    ld r0, x # args
    pop x
    ld r1, x # top
    ld r2, sp # stack pointer
    ld r3, r254 # return address
    ld sp, INITIAL_SP # switch to kernel stack

    ld (_system_sp), r2
    ld (_system_ret), r3

    ld x, r1 # top
    push x
    ld x, r0 # args
    push x
    ld x, r2 # stack pointer
    push x
    ld x, r3 # return address
    push x
    call (_sys_system_impl)

    # if system() returned there was an error: restore user stack
    # TODO: [nice] how can we distinguish a system() error from a return code from the child?
    ld sp, (_system_sp)
    jmp (_system_ret)
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
    var err = catch();
    if (err) return err;

    # TODO: [bug] bounds-check args copying
    # TODO: [nice] what happens if no fds are available

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
        n = sys_read(fd, p, 16384);
        if (n == 0) break;
        if (n < 0) {
            sys_close(fd);
            return n;
        };
        p = p + n;
    };
    sys_close(fd);

    # jump to it
    jmp_to_user();
    kpanic("user program returned to exec() call");
};

# copy arg pointer, switch to kernel stack, and call sys_exec_impl()
var exec_sp;
sys_exec = asm {
    pop x
    ld (_exec_sp), sp
    ld sp, INITIAL_SP
    push x
    call (_sys_exec_impl)
    ld sp, (_exec_sp)
    ret
};
