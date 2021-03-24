# set divisor latches to select 115200 baud

.def REG0 0
.def REG1 1
.def REG3 3
.def CLKDIVIDE 12 # 115200 / 12 = 9600 baud

# select divisor latches:
# write 0x80 to line control register
ld x, 0x80
out REG3, x

# set divisor to 1: 115200 baud
# set high byte of divisor latch = 0
ld x, 0
out REG1, x
# set low byte of divisor latch = CLKDIVIDE
ld x, CLKDIVIDE
out REG0, x

# select data register instead of divisor latches, and set 8-bit words, no parity, 1 stop:
# write 0x03 to line control register (addr 3)
ld x, 0x03
out REG3, x

# write A's
loop:
    ld x, 65
    out REG0, x
    ld x, 66
    out REG0, x
    ld x, 67
    out REG0, x
    ld x, 68
    jmp loop
