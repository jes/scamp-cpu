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
