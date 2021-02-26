# "Kernel" utilities

# Error codes
var EOF = -1;
var NOTFOUND = -2;
var NOTFILE = -3;
var NOTDIR = -4;
var BADFD = -5;

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
