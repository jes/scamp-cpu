# set divisor latches to select 115200 baud

# select divisor latches:
# write 0x80 to line control register (addr 3)
ld x, 0x80
out 3, x

# set divisor to 1: 115200 baud
# set high byte of divisor latch = 0
ld x, 0
out 1, x
# set low byte of divisor latch = 1
ld x, 1
out 0, x

# select data register instead of divisor latches, and set 8-bit words, no parity, 1 stop:
# write 0x03 to line control register (addr 3)
ld x, 0x03
out 3, x

# write A's
loop:
    ld x, 65
    out 0, x
    jmp loop
