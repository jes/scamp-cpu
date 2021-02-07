# Operating System notes

I realise it's a bit early to be talking about an operating system, but I can't help having the thoughts...

I think I'd want a very short boot ROM permanently mapped into memory at address 0, maybe 512 bytes long, or less if possible.
When the machine is reset the PC would be reset to 0 which would cause the boot ROM to execute.
The boot ROM's only job is to liaise with the storage device (hard disk? compactflash? sd? not sure yet) and load the kernel
from the first N KBytes from the storage into RAM and then jump to it.

The kernel would contain implementations of the system calls, and space for system buffers etc.

At startup, the kernel would probably just execute a program from disk (e.g. init).

I was initially thinking that this N KByte block from storage would then be responsible for loading the real OS from disk, but
actually if I pick a sensible value for N then the block at the start of the storage could just be the real OS, with no
secondary bootloader required.

I have been toying with the idea of supporting a workflow that is kind of in between CP/M and FUZIX. The filesystem could
support directories instead of CP/M's silly drive letter and user number system. We could support a system()-like call
by swapping the existing program out to disk, making a note of where to reload it from and what address to jump to, and then loading the called program.
Calling another program would then work a lot like calling a function, in the sense that you completely lose control until
the callee is done, and then when it's done you get returned to. We'd have a process stack instead of a process tree.

## Filesystem

I think I'd want a pretty Unix-like filesystem. I don't know that I'd bother with "flags" on files (i.e. rwx), I'd be happy to just
append ".x" to anything that I want to be executable.

Example:

    /bin
        asm.x
        cat.x
        cc.x
        cp.x
        init.x
        ls.x
        mkdir.x
        rm.x
        sh.x
        vi.x
    /etc
        motd
        [other configuration?]
    /home
        [user files]
    /src
        [source code of kernel and all programs]
    /swap
        [contents of swapped-out processes]

## Programs

### init

Probably just system("cat /etc/motd") and exec("sh")

### sh

Since the shell is just a program, and programs can call other programs via the swapping-to-disk system,
the shell could quite easily support pipes and IO redirection.

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

The kernel wuold then swap the shell out once again, and this time execute grep, whose stdin
comes from the temporary file. Once grep calls exit(), the kernel would swap the shell back in
and the second system() call would return.

This method doesn't allow for example `cat foo.txt | head` to bail out of the cat early, but it still provides a lot of
the useful properties of program composition, without needing to support actual multitasking.

### asm/cc

These would form a complete self-hosting build environment. I don't yet know whether I'd rather write
a proper C compiler, or whether it should be a different language entirely.
Writing in C means I can bootstrap it using an existing C compiler, but even C probably has more features than I really
need.

Probably a strict subset of C would suffice.

### vi

I definitely want a text editor that works like vi. It doesn't need to do everything that vim does, I'll be happy as long
as my "finger macros" mostly function correctly. I read that nobody uses more than 20% of vim's features, but the
problem is everyone uses a different 20%. Well as long as it supports the 20% that I use, I'll be happy.

## IO

The kinds of places that a program might want to read or write include:

 - files on disk
 - serial devices (I want at least 2, might not be too hard to support more)

I'm not sure I'd ever want more than 1 storage device. Maybe I would.

## Process state

When a process is swapped out, we need to store some state about it:

 - where do stdin/stdout/stderr go?
 - what is the return address for the system() call
 - what filename is the TPA stored in

## System calls

### Unix-inspired

system(file, cmdline):
    - open() a new temporary file on disk
    - copy the contents of the TPA into the file
    - push the temporary filename, and the return address from the call stack, onto an in-kernel process stack
    - exec() the callee
    - if copying the entire TPA onto disk is too slow, system() could potentially take an argument to say how many
      bytes of the caller's TPA need to be saved/restored; the value for this would be provided by the C runtime,
      which would track the required value via malloc()/free() calls

exec(file, cmdline):
    - open() the named file
    - load it into the TPA
    - close() it
    - jump to the start of the TPA

exit(rc):
    - pop the calling processes return address and filename off the process stack
    - restore the caller into the TPA
    - unlink() the caller's swap file
    - put 'rc' in register A?
    - jump to the return address

open()/read()/write()/close() ?
mkdir()/opendir()/readdir() ?

unlink():
    - lookup the named file
    - remove its directory entry

### CP/M-inspired

change stdin/stdout/stderr:
    - change it from whatever it currently is, to whatever is asked for
    - this could be a file on disk, or 1 of the serial devices
    - probably should return some representation of what it was previously set to,
      so that the shell can set it back
output to stdout/stderr:
    - write to an output device/file
input from stdin:
    - read from an input device/file

read/write a byte directly to/from a serial device

check if reading/writing a serial device would block

## Conventions

We could say that system/exec will either run a proper named file if it begins with a slash, or otherwise lookup "/bin/$foo.x" and execute that.
Or maybe system/exec only take absolute paths, and the shell is responsible for handling the $PATH.

"Executables" work exactly like COM files in CP/M: just load them into a fixed address and jump to the start.

Since the CPU is likely to have the bare minimum of registers, we could define a block of 16 addresses (say, 0xfff0 - 0xffff)
to use as "surrogate" registers that are basically used as swap space for the real registers.

It is likely that the word size will not be 8 bits. Should strings typically be packed so that there are multiple
characters per word, or is it better to just use 1 character per word for simplicity?

How should we pass command-line arguments? Probably array of strings, like C

Do we want environment variables? Probably not.

Do we want to support a shebang for shell scripts? Probably, seems easy enough. If not, just "sh foo.sh" would work for most cases.

Do we want the concept of a working directory in kernel-space? Maybe it's enough to have it in the C runtime.
