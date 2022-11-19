# read /proc/*.kernel and report the state of the process stack
#
# TODO: [nice] what other stuff should we display? size of *.user? number of open
#       files? return address? whether a trap function is in use?

include "stdio.sl";

var showproc = func(pid) {
    var name = sprintf("/proc/%d.kernel", [pid]);
    var fd = open(name, O_READ);
    free(name);
    if (fd < 0) return 0;

    var sp;
    var ret;
    var cwdblk;
    var args_sz;
    var args_ptr;
    var args;
    var trapfunc;
    var fdtable = malloc(128);

    # this should match sys_exit_impl() from kernel/sys_proc.sl
    read(fd, &sp, 1);
    read(fd, &ret, 1);
    read(fd, &cwdblk, 1);
    read(fd, &args_sz, 1);
    args = malloc(args_sz);
    read(fd, &args_ptr, 1);
    read(fd, args, args_sz);
    read(fd, &trapfunc, 1);
    read(fd, fdtable, 128);
    close(fd);

    printf("%d  ", [pid]);

    var args_off = args - args_ptr;
    var p = args;
    while (*p) {
        puts(*p + args_off);
        p++;
        if (*p) putchar(' ');
    };
    putchar('\n');

    free(args);
    free(fdtable);
    return 1;
};

var pid = 0;
while (pid < getpid()) {
    if (!showproc(pid)) break;
    pid++;
};
