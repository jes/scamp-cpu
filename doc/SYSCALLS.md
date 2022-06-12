# System calls reference

System calls are made by pushing arguments onto the stack, in the order specified
in the reference, and calling the function pointed to at the system call address.

Example:

    # write(1, "foo", 3);
    .def sys_write 0xfefb
    push 1
    ld x, foo_s
    push x
    push 3
    call (sys_write)
    # ...
    foo_s: .str "foo\0"

Note that stack contents will be in TPA, so system calls that overwrite the TPA
probably need to copy the arguments first.

System calls must act like normal SLANG functions: `r255` (`sp`) must consume the passed
arguments. `r254` must be left alone. Other pseudoregs can be trashed at will.

## System calls

### 0xfeff: exit(rc)

    Return: n/a
    Implemented: yes
    Errors: n/a

Exit the current process and return `rc` to the parent. Negative values of `rc` are discouraged
as they are indistinguishable from an error value returned by `system()`.

### 0xfefe: exec([cmd, args])

    Return: -ERR on error
    Implemented: yes
    Errors: NOTFOUND

Replace the current process with a new one.

`cmd` should be a filename. `args` should be terminated with a 0.

### 0xfefd: system(TOP, [cmd, args])

    Return: rc of child process, or -ERR on error
    Implemented: yes
    Errors: NOTFOUND

Suspend the current process, start a child. When the child calls `exit(rc)`, resume the
current process and return `rc`.

`cmd` should be a filename. `args` should be terminated with a 0.

### 0xfefc: getcwd(buf, sz)

    Return: 0, or -ERR on error
    Implemented: yes
    Errors: TOOLONG

Work out the current working directory and store it in `buf`. Behaviour is undefined
if the current working directory or one of its parents has been deleted. Return `TOOLONG`
if the path is too long to fit in `buf` with a trailing 0.

### 0xfefb: write(fd, buf, sz)

    Return: 0, or -ERR on error
    Implemented: yes
    Errors: BADFD

Write multiple characters to the given file descriptor.

Avoid writes larger than 2^15-1 because the return value will be indistinguishable
from an error value.

### 0xfefa: setbuf(fd, buf)

    Return: 0, or -ERR on error
    Implemented: yes
    Errors: BADFD

Set the buffer to use for the given `fd`. If `buf` is 0, the `fd` will be unbuffered, and all
writes and reads will go directly to disk. If `buf` is nonzero, it should point to a buffer of
at least **257** words.

### 0xfef9: read(fd, buf, sz)

    Return: number of characters read, or -ERR on error
    Implemented: yes, but serial needs cooked mode
    Errors: BADFD

Read multiple characters from the given file descriptor.

If `sz` is 0, returns a number of characters that can be read immediately. For a serial port,
this means you can read this many characters without blocking. For a file, it means there are at
least this many characters left in the file.

Avoid reads larger than 2^15-1 because the return value will be indistinguishable
from an error value.

### 0xfef8: open(name, mode)

    Return: new file descriptor, or -ERR on error
    Implemented: mostly
    Errors: NOTFOUND

Open the file at the given path with the given mode.

Mode flags are:

    0x01: O_READ    - support read()
    0x02: O_WRITE   - support write()
    0x04: O_CREAT   - create the file if it doesn't exist
    0x08: O_NOTRUNC - with O_WRITE: don't truncate the file if it already exists
    0x10: O_APPEND  - start at the end of the file instead of the start

### 0xfef7: close(fd)

    Return: 0, or -ERR on error
    Implemented: yes
    Errors: BADFD

Close the given file descriptor.

### 0xfef6: sync(fd)

    Return: 0, or -ERR on error
    Implemented: yes
    Errors: BADFD

Sync the buffer for the given `fd`. If `fd` is -1, sync all `fd`s.

### 0xfef5: rename(oldname, newname)

    Return: 0, or -ERR on error
    Implemented: yes
    Errors: BADFD, NOTFOUND, NOTDIR, EXISTS

Rename the file from `oldname` to `newname`, moving it to a different directory
if required. In the event that we ever support mounting filesystems from multiple
devices, this call will not permit moving the file across devices.

### 0xfef4: chdir(path)

    Return: 0, or -ERR on error
    Implemented: yes
    Errors: NOTFOUND, NOTDIR

Change the current working directory.

### 0xfef3: mkdir(path)

    Return: 0, or -ERR on error
    Implemented: yes
    Errors: NOTFOUND, NOTDIR, EXISTS

Create a directory at the given path.

### 0xfef2: opendir(path)

    Return: new file descriptor, or -ERR on error
    Implemented: yes
    Errors: NOTFOUND, NOTDIR

Open the directory at the given path for reading.

### 0xfef1: readdir(fd, buf, sz)

    Return: number of entries read, or -ERR on error
    Implemented: yes
    Errors: BADFD

Read entries from the given directory fd into buf. Each directory entry is a nul-terminated
string containing the filename. `buf` will contain N concatenated nul-terminated strings.

To read the entire directory, call `readdir()` repeatedly until 0 directory entries are returned.

It is not sound to add or remove files to the directory while the directory is open.

### 0xfef0: stat(path, buf)

    Return: 0, or -ERR on error
    Implemented: yes
    Errors: NOTFOUND

Fill in `buf` with information about the file at the given path.

Fields are:

    0: file type (0 = dir, 1 = file)
    1: length of file in words
    2: length of file in blocks
    3: block number of start of file

### 0xfeef: unlink(path)

    Return: 0, or -ERR on error
    Implemented: yes
    Errors: NOTFOUND, EXISTS

Remove the file at the given path. Return `EXISTS` if the path is a non-empty directory.

### 0xfeee: copyfd(destfd, srcfd)

    Return: the new fd, or -ERR on error
    Implemented: yes, but dubious
    Errors: BADFD

Make `destfd` go to/from the same place as `srcfd`. If the passed `destfd` is negative, then
a new fd will be allocated.

By convention programs should take input from fd *0*, output to fd *1*, and send error messages
to fd *2*. Fds *3..n* should be permanently mapped to serial ports, with fd *3* being the
console.

Example: To make stdin and stderr go to the console, but stdout go to a file, and then
restore it later

    var logfd = open("log", O_WRITE|O_CREAT);
    var old_stdin  = copyfd(0, 3);
    var old_stdout = copyfd(1, logfd);
    var old_stderr = copyfd(2, 3);
    # ...
    # now stdin/err are console, and stdout is the file 
    # ...
    copyfd(0, old_stdin);
    copyfd(1, old_stdout);
    copyfd(2, old_stderr);
    close(logfd);
    # now the original configuration is restored

### 0xfeed: osbase()

    Return: the first address above the TPA
    Implemented: yes
    Errors: n/a

Return the first address of the OS, i.e. the lowest address that the user heap is not allowed
to grow into.

### 0xfeec: cmdargs()

    Return: pointer to argument list
    Implemented: yes
    Errors: n/a

Return a pointer to the argument list, including the command name, exactly as passed to `exec()`/`system()`.

Example:

    system(["/bin/ls", "-l", "/home", 0]);

    cmdargs() returns ["/bin/ls", "-l", "/home", 0]

### 0xfeeb: serflags(fd, flags)

    Return: previous `flags`, or -ERR on error
    Implemented: yes
    Errors: BADFD

If `fd` refers to a serial port, set the flags to `flags`. `flags` is a bitmask of:

    SER_COOKED  = 1; # enable cooked mode
    SER_DISABLE = 2; # disable serial device in kernel (e.g. for direct I/O)
    SER_LONGREAD = 4; # make read() calls block and fill the buffer before returning

To find out what `flags` is set to without changing it, just set it to 0 and then back
to the previous value:

    var flags = serflags(fd, 0);
    serflags(fd, flags);

### 0xfeea: random()

    Return: random integer in range 0 .. 0xffff
    Implemented: yes
    Errors: n/a

Return a random integer. Input on serial ports permutes the state of the RNG, so if
you try to use the RNG before any input is observed, it won't be very random.

### 0xfee9: blkread(blknum)

    Return: pointer to block content
    Implemented: yes
    Errors: n/a

Read a block (256 words) from disk and return a pointer to its contents.
Blocks 0-63 are reserved for storing the kernel.
Blocks 64-79 are the free space bitmap.
Blocks 80+ are disk contents.

### 0xfee8: blkwrite(blknum, data)

    Return: 0
    Implemented: yes
    Errors: n/a

Write a block (256 words) to disk. Use carefully.
Blocks 0-63 are reserved for storing the kernel.
Blocks 64-79 are the free space bitmap.
Blocks 80+ are disk contents.

### 0xfee7: trap(func)

    Return: 0
    Implemented: yes
    Errors: n/a

Set the trap function. This is a function that will be called, with no
arguments, when ^C is typed at the console. Set `func` to 0 to revert
to the default behaviour of exiting. The trap function need not return,
but should make sure to set the stack pointer to something sensible if
it doesn't.

### 0xfee6: savetpa(filename, TOP)

    Return: 0, or ERR on error
    Implemented: no
    Errors: NOTFOUND? NOTDIR? TOOLONG?

Save the TPA to the given filename.

## Errors

Errors are generally returned from system calls as `-ERR`, with the following meanings:

### -1: EOF

Reached end-of-file.

### -2: NOTFOUND

File with given name does not exist.

### -3: NOTFILE

The given path exists but is not a file (e.g. it's a directory).

### -4: NOTDIR

The given path exists but is not a directory (e.g. it's a file).

### -5: BADFD

File descriptor not allocated, or requested operation not available on this fd.

### -6: TOOLONG

A path component was too long.

### -7: EXISTS

Path already exists.
