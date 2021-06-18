include "stdio.sl";
include "stdlib.sl";

var setclkdiv = asm {
    .def SERIALREG0 136
    .def SERIALREG1 137
    .def SERIALREG3 139

    pop x
    ld r0, x # r0 = clkdiv

    # select divisor latches:
    # write 0x80 to line control register
    ld x, 0x80
    out SERIALREG3, x

    # set high byte of divisor latch = 0
    ld x, 0
    out SERIALREG1, x
    # set low byte of divisor latch = SERIALCLKDIV
    ld x, r0
    out SERIALREG0, x

    # select data register instead of divisor latches, and set 8-bit words, no parity, 1 stop:
    # write 0x03 to line control register (addr 3)
    ld x, 0x03
    out SERIALREG3, x

    ret
};

var args = cmdargs()+1;

if (!*args) {
    fprintf(2, "usage: baud N\nexample: baud 9600\n", 0);
    exit(1);
};

var baud_rate = atoi(*args);

# XXX: should be 115200/baud_rate but 115200 is too large for 16-bit
var clkdiv = div(57600, baud_rate);
clkdiv = clkdiv + clkdiv;

setclkdiv(clkdiv);
