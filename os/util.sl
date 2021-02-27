# "Kernel" utilities

# Error codes
var EOF = -1;
var NOTFOUND = -2;
var NOTFILE = -3;
var NOTDIR = -4;
var BADFD = -5;
var TOOLONG = -6;

# usage: inp(addr)
var inp = asm {
    pop x
    in r0, x
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

# take a pointer to a nul-terminated string, and print it
var kputs = asm {
    pop x
    test (x)
    jnz kputs_loop
    ret
    kputs_loop:
        out 2, (x)
        inc x
        test (x)
        jnz kputs_loop
    ret
};

var khalt = func() {
    outp(3, 0); # halt the emulator
    while(1);
};

var kpanic = func(s) {
    kputs("panic: ");
    kputs(s);
    kputs("\n");
    khalt();
};

var unimpl = func(s) {
    kputs("panic: unimplemented: ");
    kputs(s);
    kputs("\n");
    khalt();
};

var memcpy = func(dest, src, len) {
    var dd = dest;
    while (len--) *(dest++) = *(src++);
    return dd;
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
    ld (x), r254 # return address
    inc x
    ld (x), sp # stack pointer
    inc x
    ld (x), r2 # stashed return
    ld r0, 0 # return 0 this time
    ret
};

# restore control and stack pointer to the addresses in jmpbuf,
# as if setjmp() had returned "val"
# example:
#   longjmp(jmpbuf, NOTFOUND);
var longjmp = asm {
    pop x
    ld r0, x # return val
    pop x # x = jmpbuf
    ld r254, (x) # return address
    inc x
    ld sp, (x) # stack pointer
    inc x
    ld x, (x) # stashed return address
    push x
    ret
};

var throw_jmpbuf = [0,0,0];

# use setjmp/longjmp to return the error to the last place that called catch()
var throw = func(n) longjmp(throw_jmpbuf, n);

# return 0 on first call, and update state for throw();
# when throw() is called, return the value that was thrown
# ("catch()" is equivalent to "setjmp(throw_jmpbuf)")
var catch = asm {
    ld r2, 1(sp) # caller's stashed return address
    ld x, (_throw_jmpbuf)
    ld (x), r254 # return address
    inc x
    ld (x), sp # stack pointer
    inc x
    ld (x), r2 # stashed return
    ld r0, 0 # return 0 this time
    ret
};

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

# compute:
#   *pdiv = num / denom
#   *pmod = num % denom
# Pass a null pointer if you want to discard one of the results
# https://en.wikipedia.org/wiki/Division_algorithm#Integer_division_(unsigned)_with_remainder
var divmod = asm {
    ld x, sp
    ld r7, 1(x) # r7 = pmod
    ld r8, 2(x) # r8 = pdiv
    ld r9, 3(x) # r9 = denom
    ld r10, 4(x) # r10 = num

    ld r4, 0 # r4 = Q
    ld r5, 0 # r5 = R
    ld r6, 15 # r6 = i

    # while (i >= 0)
    divmod_loop:
        # R = R+R
        shl r5

        # r11 = powers_of_2[i]
        ld x, powers_of_2
        add x, r6
        ld r11, (x)

        # if (num & powers_of_2[i]) R++;
        ld r12, r10
        and r12, r11
        jz divmod_cont1
        inc r5
        divmod_cont1:

        # if (R >= denom)
        ld r12, r5
        sub r12, r9 # r12 = R - denom
        jlt divmod_cont2
            # R = R - denom
            ld r5, r12
            # Q = Q | powers_of_2[i]
            or r4, r11
        divmod_cont2:

        # i--
        dec r6
        jge divmod_loop

    # if pdiv or pmod are null, they'll point to rom, so writing to them is a no-op
    # *pdiv = Q
    ld x, r8
    ld (x), r4
    # *pmod = R
    ld x, r7
    ld (x), r5
    # return
    ret 4
};

var half = func(x) {
    var r;
    divmod(x,2,&r,0);
    return r;
};
