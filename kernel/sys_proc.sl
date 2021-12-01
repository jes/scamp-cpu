# Processes syscalls

include "util.sl";
include "sys_io.sl";
include "sys_fs.sl";
include "sys.sl";

sys_cmdargs = asm {
    ld r0, (_cmdargs)
    ret
};
sys_osbase = sys_cmdargs;

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
    ser_poll(3);

    var err = catch();
    denycatch();
    if (err) kpanic("exit() panics");

    if (pid == 0) kpanic("init exits");
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
    var maxread;
    while (1) {
        maxread = OSBASE - p;
        if (maxread == 0) kpanic("exit: too big");
        if (maxread gt 16256) maxread = 16256;
        n = sys_read(ufd, p, maxread);
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
    sys_read(kfd, &cmdargs_sz, 1);
    sys_read(kfd, &cmdargs, 1);
    sys_read(kfd, cmdargs, cmdargs_sz);
    sys_read(kfd, &trapfunc, 1);
    sys_read(kfd, fdtable, 128);
    sys_close(kfd);

    sys_unlink(userfile);
    sys_unlink(kernelfile);

    allowcatch();
    return_to_parent(sp, ret, rc);
    kpanic("returned to exit");
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
    ser_poll(3);

    # create filenames
    # TODO: [bug] should support more than 1 digit in filenames
    var userfile = "/proc/0.user";
    var unlink_userfile = 0;
    var kernelfile = "/proc/0.kernel";
    var unlink_kernelfile = 0;
    *(userfile+6) = pid+'0';
    *(kernelfile+6) = pid+'0';

    var exit_on_catch = 0;

    var err = catch();
    denycatch();
    if (err) {
        allowcatch();
        if (exit_on_catch) {
            return sys_exit(err);
        } else {
            if (unlink_userfile) sys_unlink(userfile);
            if (unlink_kernelfile) sys_unlink(kernelfile);
            return err;
        };
    };

    # sync buffers (before writing fdtable to disk)
    sys_sync(-1);

    # open "/proc/$pid.user" for writing
    var ufd = sys_open(userfile, O_WRITE|O_CREAT|O_KERNELFD);
    if (ufd < 0) throw(ufd);
    unlink_userfile = 1;

    # copy bytes from 0x100..top
    var p = 0x100;
    var n;
    var writesz;
    while (p != top) {
        writesz = top-p;
        if (writesz gt 16384) writesz = 16384;
        n = sys_write(ufd, p, writesz);
        if (n < 0) throw(n);
        if (n != writesz) kpanic("system: write too small");
        p = p + writesz;
    };
    sys_close(ufd);

    # open "/proc/$pid.kernel" for writing
    var kfd = sys_open(kernelfile, O_WRITE|O_CREAT|O_KERNELFD);
    if (kfd < 0) throw(kfd);
    unlink_kernelfile = 1;

    # copy into $pid.kernel:
    #  - stack pointer
    #  - return address
    #  - CWDBLK
    #  - cmdargs
    #  - trapfunc
    #  - fdtable (has to come last because it'll overwrite our fd)
    sys_write(kfd, &sp, 1);
    sys_write(kfd, &ret, 1);
    sys_write(kfd, &CWDBLK, 1);
    sys_write(kfd, &cmdargs_sz, 1);
    sys_write(kfd, &cmdargs, 1);
    sys_write(kfd, cmdargs, cmdargs_sz);
    sys_write(kfd, &trapfunc, 1);
    sys_write(kfd, fdtable, 128);
    sys_close(kfd);

    # execute the "child" process
    pid++;
    exit_on_catch = 1;
    err = sys_exec(args);
    throw(err);
};

# call sys_system_impl() with the return address, stack pointer, and system() arguments
sys_system = asm {
    ld x, sp # stack pointer
    add x, 2 # pop past the 2 args to system()
    push x
    ld x, r254 # return address
    push x
    jmp (_sys_system_impl)
};

var jmp_to_user = asm {
    # put sp below kernel so that a misbehaving program is less likely to trash the kernel
    ld sp, OSBASE
    dec sp

    # jump to program
    jmp 0x100
};

var cmdargp;
var cmdarg_idx;
var build_cmdargs = func(firstarg, args) {
    # count the number & size of arguments
    var nargs = 0;
    var args_sz = 0;
    if (firstarg) {
        nargs++;
        args_sz = args_sz + strlen(firstarg) + 1;
    };
    var i = 0;
    while (args[i]) {
        args_sz = args_sz + strlen(args[i]) + 1;
        nargs++;
        i++;
    };

    var addarg = func(arg) {
        var max_cmdargp = cmdargs + cmdargs_sz;

        *(cmdargs+cmdarg_idx++) = cmdargp;
        var i = 0;
        while (arg[i]) {
            *(cmdargp++) = arg[i];
            if (cmdargp == max_cmdargp) throw(TOOLONG);
            i++;
        };
        *(cmdargp++) = 0;
        if (cmdargp == max_cmdargp) throw(TOOLONG);
    };

    cmdargs_sz = args_sz + nargs + 2;
    cmdargs = OSBASE - cmdargs_sz;

    # copy the args into cmdargs
    cmdargp = cmdargs + nargs + 1;
    cmdarg_idx = 0;
    if (firstarg) addarg(firstarg);
    i = 0;
    while (args[i]) addarg(args[i++]);

    *(cmdargs+cmdarg_idx) = 0;
};

var load_program = func(name) {
    # load file from disk
    var fd = sys_open(name, O_READ|O_KERNELFD);
    if (fd < 0) throw(fd);
    var p = 0x100;
    var n;
    while (1) {
        n = sys_read(fd, p, 16256);
        if (n == 0) break;
        if (n < 0) {
            sys_close(fd);
            throw(n);
        };
        p = p + n;
    };
    sys_close(fd);
};

# example: sys_exec(["/bin/ls", "/etc"])
var sys_exec_impl = func(args) {
    ser_poll(3);

    var err = catch();
    denycatch();
    if (err) {
        allowcatch();
        return err;
    };

    # stop using buffers
    var i = 0;
    while (i != nfds) sys_setbuf(i++, 0);

    # load the program
    build_cmdargs(0, args);
    load_program(cmdargs[0]);

    # TODO: [bug] from this point onwards, if an error is thrown, simply
    #       returning the error doesn't suffice; we've already overwritten
    #       the program we've been returning to with the contents of the
    #       new program - what should we do about this? I think the only
    #       time we'd throw an error from now on is if the loaded program
    #       was a script and we're deciding to try to find its interpreter
    #       instead - so perhaps load_program() should check if the first 2
    #       characters are "#!" and if so, indicate it in some way, and
    #       *don't* overwrite the parent program. That way we can safely
    #       return to the parent if, for example, the interpreter doesn't
    #       exist.

    # if it's a script, we need to load an interpreter instead
    var name;
    var len_name;
    if (*0x100 == '#' && *0x101 == '!') {
        # work out the name of the interpreter
        name = 0x102;
        len_name = 0;
        while (*name != '\n') {
            name++;
            len_name++;
        };
        *name = 0;
        name = 0x102;

        # load the interpreter
        # TODO: [bug] "args" is a pointer to user memory, which we just overwrote
        #       with the contents of the script! should we instead just stick
        #       "name" in at the bottom of the cmdargs we just built?
        build_cmdargs(name, args);
        load_program(name);
    };

    # jump to it
    allowcatch();
    trapfunc = 0;
    jmp_to_user();
    kpanic("returned to exec");
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

sys_trap = func(f) {
    trapfunc = f;
    return 0;
};
