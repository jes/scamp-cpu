# "Kernel" utilities

# Error codes
var EOF = -1;
var NOTFOUND = -2;
var NOTFILE = -3;
var NOTDIR = -4;
var BADFD = -5;
var TOOLONG = -6;
var EXISTS = -7;

# usage: inp(addr)
var inp = asm {
    pop x

    # TODO: [bug] for some reason, trying to do:
    #   in r0, x
    # results in corrupting the state of the UART, so we instead
    # input into x and then load r0 from x
    ld r0, x
    in x, r0
    ld r0, x

    ret
};

# usage: outp(addr, value)
var outp = asm {
    pop x
    ld r0, x
    pop x
    out x, r0
    ret
};

var kputc = asm {
    .def SERIALDEV 136
    .def SERIALDEVLSR 141
    kputc:
        # wait for uart to be ready
        # TODO: [bug] why are the nops required? it seems to corrupt the uart state if they're not here
        nop
        in x, SERIALDEVLSR
        nop
        and x, 0x20
        nop
        jz kputc
        nop

        pop x
        out SERIALDEV, x
        ret
};

# take a pointer to a nul-terminated string, and print it
var kputs = asm {
    ld r253, r254
    pop x
    ld r0, x
    test (r0)
    jnz kputs_loop
    ret
    kputs_loop:
        ld x, (r0)
        push x
        call kputc
        inc r0
        test (r0)
        jnz kputs_loop
    jmp r253 # ret
};

var khalt = func() {
    outp(3, 0); # halt the emulator
    while(1);
};

var kpanic = func(s) {
    kputs("panic: ");
    kputs(s);
    kputs("\r\n");
    khalt();
};

var unimpl = func(s) {
    kputs("panic: unimplemented: ");
    kputs(s);
    kputs("\r\n");
    khalt();
};

#var memcpy = func(dest, src, len) {
#    var dd = dest;
#    while (len--) *(dest++) = *(src++);
#    return dd;
#};

# usage: memcpy(dest, src, len)
var memcpy = asm {
    pop x
    ld r1, x # len
    pop x
    ld r2, x # src
    pop x
    ld r3, x # dest
    ld r0, x # return

    test r1
    jz memcpy_ret

    # the memcpy loop is unrolled into groups of 8 words; when the
    # length to copy is not a multiple of 8 we need to jump into the
    # loop to skip over the first few copies

    # grab last 3 bits to work out where to jump
    ld r4, r1
    and r4, 7
    add r4, memcpy_offset
    ld x, (r4)
    ld r4, x

    # round length up to next multiple of 8
    or r1, 7
    inc r1
    # jump into loop
    jmp r4

    memcpy_loop:
        ld x, (r2++)
        ld (r3++), x
    memcpy7:
        ld x, (r2++)
        ld (r3++), x
    memcpy6:
        ld x, (r2++)
        ld (r3++), x
    memcpy5:
        ld x, (r2++)
        ld (r3++), x
    memcpy4:
        ld x, (r2++)
        ld (r3++), x
    memcpy3:
        ld x, (r2++)
        ld (r3++), x
    memcpy2:
        ld x, (r2++)
        ld (r3++), x
    memcpy1:
        ld x, (r2++)
        ld (r3++), x
    memcpy0:
        sub r1, 8
        jnz memcpy_loop

    memcpy_ret:
    ret

    memcpy_offset:
    .word memcpy0
    .word memcpy1
    .word memcpy2
    .word memcpy3
    .word memcpy4
    .word memcpy5
    .word memcpy6
    .word memcpy7
};

var memset = func(s, c, n) {
    while (n--) *(s++) = c;
};

# >>8 1 arg from the stack and return the result in r0
var shr8 = asm {
    pop x
    ld r0, x
    ld r1, r254 # stash return address
    ld r254, 0
    tbsz r0, 0x8000
    sb r254, 0x80
    tbsz r0, 0x4000
    sb r254, 0x40
    tbsz r0, 0x2000
    sb r254, 0x20
    tbsz r0, 0x1000
    sb r254, 0x10
    tbsz r0, 0x0800
    sb r254, 0x08
    tbsz r0, 0x0400
    sb r254, 0x04
    tbsz r0, 0x0200
    sb r254, 0x02
    tbsz r0, 0x0100
    sb r254, 0x01
    ld r0, r254
    jmp r1 # return
};

# >>12 1 arg from the stack and return the result in r0
var shr12 = asm {
    pop x
    ld r0, x
    ld r1, r254 # stash return address
    ld r254, 0
    tbsz r0, 0x8000
    sb r254, 0x8
    tbsz r0, 0x4000
    sb r254, 0x4
    tbsz r0, 0x2000
    sb r254, 0x2
    tbsz r0, 0x1000
    sb r254, 0x1
    ld r0, r254
    jmp r1 # return
};

# >>4 1 arg from the stack and return the result in r0
# note upper byte is ignored
var byteshr4 = asm {
    pop x
    ld r0, x
    ld r1, r254 # stash return address
    ld r254, 0
    tbsz r0, 0x800
    sb r254, 0x80
    tbsz r0, 0x400
    sb r254, 0x40
    tbsz r0, 0x200
    sb r254, 0x20
    tbsz r0, 0x100
    sb r254, 0x10
    tbsz r0, 0x80
    sb r254, 0x8
    tbsz r0, 0x40
    sb r254, 0x4
    tbsz r0, 0x20
    sb r254, 0x2
    tbsz r0, 0x10
    sb r254, 0x1
    ld r0, r254
    jmp r1 # return
};

# usage: shl(i,n)
# compute "i << n", return it in r0
var shl = asm {
    pop x
    ld r1, 15
    sub r1, x # r1 = 15 - n

    pop x
    ld r0, x # r0 = i

    # kind of "Duff's device" way to get a variable
    # number of left shifts
    jr+ r1

    shl r0
    shl r0
    shl r0
    shl r0
    shl r0
    shl r0
    shl r0
    shl r0
    shl r0
    shl r0
    shl r0
    shl r0
    shl r0
    shl r0
    shl r0

    ret
};

# return 1 if the "name" is the first element of the given path
# examples:
#   pathbegins("foo/bar/fsdfs","foo") = 1
#   pathbegins("foo/bar/fsdfs","f") = 0
#   pathbegins("foo/bar/fsdfs","foo/bar") = 0
var pathbegins = func(path, name) {
    while (*path && *name && *path != '/') {
        if (*path != *name) return 0;
        path++;
        name++;
    };

    if (*name == 0 && (*path == 0 || *path == '/')) return 1;
    return 0;
};

# store current return address, stack pointer, and caller's stashed return
# address in jmpbuf[0,1,2];
# it is only acceptable to jump "up" the call stack, never down;
# return 0 on the initial call
# return the "val" passed to longjmp when the long jump occurs
# example:
#   var jmpbuf = [0,0,0];
#   if (setjmp(jmpbuf)) {
#       ... long jump occurred ...
#   };
var setjmp = asm {
    pop x
    ld r1, x # r1 = jmpbuf
    ld r2, 1(sp) # r2 = caller's stashed return address
    ld x, r1 # x = jmpbuf

do_setjmp: # x = jmpbuf pointer, r2 = stashed return

    ld (x), r254 # return address
    inc x
    ld (x), sp # stack pointer
    inc x
    ld (x), r2 # stashed return
    ld r0, 0 # return 0 this time
    ret
};

# only the top-most catch() in each system call needs to be allowed;
# when system calls call other system calls, any throw()s created
# in the sub-calls need to go tot he top one instead
var catch_allowed = 1;
var denycatch = func() catch_allowed = 0;
var allowcatch = func() catch_allowed = 1;

# return 0 on first call, and update state for throw();
# when throw() is called, return the value that was thrown
# ("catch()" is equivalent to "setjmp(throw_jmpbuf)")
var catch = asm {
    # first check if catch() is allowed, and no-op if not
    test (_catch_allowed)
    jnz catch_ok
    ld r0, 0
    ret

    catch_ok:
    # ok, now setjmp()
    ld r2, 1(sp) # r2 = caller's stashed return address
    ld x, (_throw_jmpbuf) # x = jmpbuf pointer
    jmp do_setjmp
};

# restore control and stack pointer to the addresses in jmpbuf,
# as if setjmp() had returned "val"
# example:
#   longjmp(jmpbuf, val);
var longjmp = asm {
    pop x
    ld r0, x # return val
    pop x # x = jmpbuf
    ld r254, (x) # return address
    inc x
    ld sp, (x) # stack pointer
    inc x
    ld r2, (x) # stashed return address
    ld 1(sp), r2
    ret
};

var throw_jmpbuf = [0,0,0];

# use setjmp/longjmp to return the error to the last place that called catch()
var throw = func(n) longjmp(throw_jmpbuf, n);

var powers_of_2 = asm {
    powers_of_2:
    .word 0x0001
    .word 0x0002
    .word 0x0004
    .word 0x0008
    .word 0x0010
    .word 0x0020
    .word 0x0040
    .word 0x0080
    .word 0x0100
    .word 0x0200
    .word 0x0400
    .word 0x0800
    .word 0x1000
    .word 0x2000
    .word 0x4000
    .word 0x8000
};
