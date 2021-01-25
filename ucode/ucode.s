# Provisional microcode for testing

add: 00 # X = X+Y
    EX EY F EO XI

ldx: 01 # load X from IOL
    IOL XI

ldy: 02 # load Y from IOL
    IOL YI

out: 03 # output X register
    XO DI

inc: 04 # increment X register: X = X+1
    EX NX NY F NO EO XI

dec: 05 # decrement X register: X = X-1
    EX NY F EO XI

sub: 06 # X = X-Y
    EX NX EY F NO EO XI

jmp: 07 # jump to immediate address from operand
    PO AI
    MO JMP

jz: 08 # jump if last ALU output was 0
    PO AI
    MO JZ

djnz: 09 # decrement and jump if not zero
    EX NY F EO XI # dec X
    PO AI
    MO JNZ P+

clc: 0a # clear carry
    EO F # 0+0 = 0

adc: 0b # add with carry
    CE EX EY F EO XI

sbc: 0c # subtract with carry (XXX: does this work or make sense?)
    CE EX NX F NO EO XI

and: 0d # X = X&Y
    EO XI EX EY

or: 0e # X = X|Y
    EO XI EX EY NX NY NO

nand: 0f # X = ~(X&Y)
    EO XI EX EY NO

nor: 10 # X = ~(X|Y)
    EO XI EX EY NX NY

shl: 11 # X = (X<<1) = X+X (clobbers Y register)
    XO YI         # Y = X
    EO XI EX EY F # X = X+Y

# XXX: should there be a control bit to either clear the carry, or enable carry input to ALU, with it disabled by default?

# XXX: how could we implement a right-shift?

xor: 12 # X = X^Y (clobbers a word in the upper page of RAM, based on the 8-bit immediate constant in the opcode)
    # the idea here is to calculate X^Y == (X|Y) & ~(X&Y) by first storing X|Y in memory,
    # then storing X&Y in Y, then loading the original X|Y from memory into X, then
    # computing ~(X&Y) and storing it in X
    IOH AI               # addr = IOH (i.e. ff..)
    EO MI EX EY NX NY NO # M[ff..] = X|Y
    EO YI EX EY NO       # Y = ~(X&Y)
    MO XI                # X = M[ff..]
    EO XI EX EY          # X = X&Y

push: 13 # push X onto stack pointed to by IOH (e.g. instruction 13ff if SP is at ffff), with post-decrement of sp (clobbers Y)
    IOH AI # addr = IOH (i.e. SP)
    MO YI  # Y = M[addr] (get current value of SP in Y)
    MO AI  # addr = M[addr] (i.e. dereference SP) (XXX: we'd save a cycle if we could do YI and AI concurrently)
    XO MI  # M[addr] = X
    IOH AI # addr = IOH (i.e. SP)
    EO MI EY NX F # M[addr] = Y-1 (i.e. decrement SP)

pop: 14 # pop X from stack pointed to by IOH (e.g. instruction 14ff if SP is at ffff), with pre-increment of sp
    IOH AI # addr = IOH (i.e. SP)
    MO YI  # Y = M[addr]
    EO YI EY NX NY F NO # Y = Y+1 (i.e. increment SP)
    YO MI # M[addr] = Y (write incremented SP)
    YO AI # addr = Y (i.e. new SP)
    MO XI # X = M[addr]

stx: 15 # load X into address given in operand
    PO AI # addr = PC
    MO AI P+ # addr = M[addr], inc PC
    XO MI # M[addr] = X

sty: 16 # load Y into address given in operand
    PO AI # addr = PC
    MO AI P+ # addr = M[addr], inc PC
    YO MI # M[addr] = Y

ldx: 17 # load X from address given in operand
    PO AI # addr = PC
    MO AI P+ # addr = M[addr], inc PC
    MO XI  # X = M[addr]

ldy: 18 # load Y from address given in operand
    PO AI # addr = PC
    MO AI P+ # addr = M[addr], inc PC
    MO XI  # Y = M[addr]

incy: 19 # increment Y register: Y = Y+1
    EY NY NX F NO EO YI

decy: 1a # decrement Y register: Y = Y-1
    EY NX F EO YI
