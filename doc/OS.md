# Operating System notes

We'll have a very short boot ROM permanently mapped into memory at address 0, 256 words long.
When the machine is reset the PC would be reset to 0 which would cause the boot ROM to execute.
The boot ROM's only job is to liaise with the storage device (hard disk? compactflash? sd? not sure yet) and load the kernel
from the first N KBytes from the storage into RAM and then jump to it. See [BOOT.md](BOOT.md).

The kernel contains implementations of the system calls, and space for system buffers etc.

At startup, the kernel just executes `/bin/init`.

The intention is to support a workflow that is kind of in between CP/M and FUZIX. The filesystem
supports directories instead of CP/M's silly drive letter and user number system. The OS provides a `system()`-like call
by swapping the existing program out to disk, making a note of where to reload it from and what address to jump to, and then loading the called program.
Calling another program works a lot like calling a function, in the sense that you completely lose control until
the callee is done, and then when it's done you get returned to. We have a process *stack* instead of a process *tree*.

## Filesystem

`SCAMP/os` has a pretty Unix-like filesystem, but without annoying features like device nodes, symlinks, permissions, or
reference counting.

Example:

    /bin
        asm
        cat
        cmp
        cp
        grep
        init
        ls
        mkdir
        peepopt
        rm
        sh
        slangc
        slc
        vi
    /etc
        motd
        [other configuration?]
    /home
        [user files]
    /src
        [source code of kernel and all programs]
    /proc
        [contents of swapped-out processes]

## Programs

### init

Probably just system("cat /etc/motd") and exec("sh")

### sh

Since the shell is just a program, and programs can call other programs via the swapping-to-disk system,
the shell could quite easily support pipes and IO redirection. Currently it supports IO redirection but
not "pipes".

For the command:
    $ cat foo.txt | grep bar

The shell would first open a temporary file for writing. It would set stdout to point to that file.
It would system("cat", "foo.txt").

The kernel would then swap the shell out to disk and execute cat, whose stdout goes to the temporary
file. Once cat calls exit(), the kernel
would swap the shell back into memory and jump to the return address for the system() call.
From the shell's perspective, the system() call would return.

At this point the shell would set stdout to point back to whatever it was originally set to, and then
set stdin to point to the temporary file. It would then system("grep", "bar").

The kernel would then swap the shell out once again, and this time execute grep, whose stdin
comes from the temporary file. Once grep calls exit(), the kernel would swap the shell back in
and the second system() call would return.

This method doesn't allow for example `cat foo.txt | head` to bail out of the cat early, but it still provides a lot of
the useful properties of program composition, without needing to support actual multitasking.

### asm/slangc/slc/peepopt

These would form a complete self-hosting build environment.

    asm: assembler
    slangc: compiler
    slc: compiler driver (slangc foo.sl | peepopt > foo.s; cat head.s foo.s foot.s | asm > foo)
    peepopt: peephole optimiser

### vi

I definitely want a text editor that works like vi. It doesn't need to do everything that vim does, I'll be happy as long
as my "finger macros" mostly function correctly. I read that nobody uses more than 20% of vim's features, but the
problem is everyone uses a different 20%. Well as long as it supports the 20% that I use, I'll be happy.

Currently the editor is `kilo`, which is not very vi-like. It's more nano-like. It's adequate for now. It seems
unlikely that I'll ever make it vi-like, it seems good enough.

## IO

The kinds of places that a program might want to read or write include:

 - files on disk
 - serial devices (I want at least 2, might not be too hard to support more)

Currently serial devices are implemented with fixed file descriptors. Fd 3 is always the
serial console. It might be worth making a new file type for "device files" so that the
console can be found by opening `/dev/console` instead of assuming it's always at fd 3.
The "fixed fd" system is *OK* for now, but would not scale very well, especially given that
the fd table only has 16 slots.

I'm not sure I'd ever want more than 1 storage device. Maybe I would. I am thinking
that if I want to talk to an SD card, there'll be a dedicated program to interact with it,
instead of mounting it on the main filesystem.

## Process state

When a process is swapped out, in addition to storing the contents
of the Transient Program Area (0x100 up to `TOP`) in `/proc/$n.user`,
we need to store some state about the process in `/proc/$n.kernel` (see
`kernel/sys_proc.sl`):

 - current stack pointer
 - return address from `system()` call
 - current working directory
 - contents of fd table
 - command line arguments

## Conventions

"Executables" work exactly like COM files in CP/M: just load them into 0x100 and jump to the start.

Command line arguments are stored by the kernel. A pointer to the
array of string pointers is retrieved with the `cmdargs()` syscall.

There is no such thing as environment variables.

Shebangs work.
