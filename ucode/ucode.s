# Provisional microcode for testing

add: 00 # X = X+Y
    EO F
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
    EO F
    EX NX F NO EO XI

jmp: 07 # jump to immediate address from operand
    PO AI
    MO JMP

jz: 08 # jump if last ALU output was 0
    PO AI
    MO JZ

djnz: 09 # decrement and jump if not zero
    EX NY F EO XI
    PO AI
    MO JNZ P+

clc: 0a # clear carry
    EO F # 0+0 = 0

adc: 0b # add with carry
    EX EY F EO XI

sbc: 0c # subtract with carry (TODO: does this work or make sense?)
    EX NX F NO EO XI

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
    EO F          # clear carry (could potentially save a cycle with "XO YI F"? need to check)
    EO XI EX EY F # X = X+Y

# XXX: how could we implement a right-shift?

xor: 12 # X = X^Y (clobbers a word in the upper page of RAM, based on the 8-bit immediate constant in the opcode)
    # the idea here is to calculate X^Y == (X|Y) & ~(X&Y) by first storing X|Y in memory,
    # then storing X&Y in Y, then loading the original X|Y from memory into X, then
    # computing ~(X&Y) and storing it in X
    IOH AI               # addr = IOH (i.e. ff..)
    EO MI EX EY NX NY NO # M[ff..] = X|Y
    EO YI EX EY          # Y = X&Y
    MO XI                # X = M[ff..]
    EO XI EX EY NO       # X = ~(X&Y)
