# 8250 UART test

.def REG0 0
.def REG1 1
.def REG3 3
.def REG5 5
.def CLKDIVIDE 12 # 115200 / 12 = 9600 baud

ld sp, 0x8000

nop
nop
nop
nop
nop
nop

push CLKDIVIDE
call init8250

# write letters
loop:
    call read8250
    ld x, r0
    push x
    call write8250
    push 65
    call write8250
    push 66
    call write8250
    push 67
    call write8250
    jmp loop

# usage: init8250(CLKDIVIDE)
init8250:
    # select divisor latches:
    # write 0x80 to line control register
    ld x, 0x80
    out REG3, x

    # set high byte of divisor latch = 0
    ld x, 0
    out REG1, x
    # set low byte of divisor latch = CLKDIVIDE
    pop x
    out REG0, x

    # select data register instead of divisor latches, and set 8-bit words, no parity, 1 stop:
    # write 0x03 to line control register (addr 3)
    ld x, 0x03
    out REG3, x

    ret

# usage: write8250(char)
write8250:
    ld r253, r254 # stash return address
    # spin until writable
    write8250_loop:
        call writable8250
        test r0
        jz write8250_loop

    pop x
    out REG0, x
    jmp r253

# return 1 if ready to write, 0 otherwise
writable8250:
    # read Line Status Register
    in x, REG5
    # bit 5 of Line Status Register is 1 when transmitter holding register is empty
    and x, 32
    jz ret0
    ld r0, 1
    ret
    ret0:
    ret

# usage: char = read8250()
read8250:
    ld r253, r254 # stash return address
    # spin until writable
    read8250_loop:
        call readable8250
        test r0
        jz read8250_loop

    in r0, REG0
    jmp r253

# return 1 if ready to read, 0 otherwise
readable8250:
    # read Line Status Register
    in x, REG5
    # lsb of Line Status Register is 1 when data is ready
    and x, 1
    ld r0, x
    ret
