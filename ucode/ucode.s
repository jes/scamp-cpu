# Provisional microcode for testing

add: 00 # X = X+Y
    X+Y XI

ldx: 01 # load X from IOL
    IOL XI

ldy: 02 # load Y from IOL
    IOL YI

out: 03 # output X register
    XO DI

inc: 04 # increment X register: X = X+1
    X+1 XI

dec: 05 # decrement X register: X = X-1
    X-1 XI

sub: 06 # X = X-Y
    X-Y XI

jmp: 07 # jump to immediate address from operand
    PO AI
    MO JMP

jz: 08 # jump if last ALU output was 0
    PO AI
    MO JZ

djnz: 09 # decrement and jump if not zero
    X-1 XI
    PO AI
    MO JNZ P+

nop: 0a
nop: 0b
nop: 0c

and: 0d # X = X&Y
    X&Y XI

or: 0e # X = X|Y
    X|Y XI

nand: 0f # X = ~(X&Y)
    ~(X&Y) XI

nor: 10 # X = ~(X|Y)
    ~(X|Y) XI

shl: 11 # X = (X<<1) = X+X (clobbers Y register)
    XO YI         # Y = X
    X+Y XI

xor: 12 # X = X^Y (clobbers a word in the upper page of RAM, based on the 8-bit immediate constant in the opcode)
    # the idea here is to calculate X^Y == (X|Y) & ~(X&Y) by first storing X|Y in memory,
    # then storing X&Y in Y, then loading the original X|Y from memory into X, then
    # computing ~(X&Y) and storing it in X
    IOH AI               # addr = IOH (i.e. ff..)
    MI X|Y            # M[addr] = X|Y
    YI ~(X&Y)         # Y = ~(X&Y)
    MO XI                # X = M[ff..]
    XI X&Y            # X = X&Y

push: 13 # push X onto stack with post-decrement of sp (clobbers Y)
    -1 AI # addr = -1 (i.e. SP)
    MO YI  # Y = M[addr] (get current value of SP in Y)
    MO AI  # addr = M[addr] (i.e. dereference SP) (XXX: we'd save a cycle if we could do YI and AI concurrently)
    XO MI  # M[addr] = X
    -1 AI # addr = -1 (i.e. SP)
    MI Y-1 # M[addr] = Y-1 (i.e. decrement SP)

pop: 14 # pop X from stack with pre-increment of sp (clobbers Y)
    -1 AI # addr = -1 (i.e. SP)
    MO YI  # Y = M[addr]
    YI Y+1 # Y = Y+1 (i.e. increment SP)
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
    MO YI  # Y = M[addr]

incy: 19 # increment Y register: Y = Y+1
    YI Y+1

decy: 1a # decrement Y register: Y = Y-1
    YI Y-1

# some special instructions for efficiently computing ">>8":
# e.g.:
# initialise by putting X in 0xffff for tbsz:
#   stx 0xffff
# initialise 0xfffe to 0 for sb:
#   ldy(0)
#   sty 0xfffe
#
# repeatedly tbsz and sb of the same value shifted right by 8
#   tbsz(0xff) 0x8000
#   sb(0x80)
#   tbsz(0xff) 0x4000
#   sb(0x40)
# so the >>8 operation takes up to 8*(8+6) = 112 cycles, plus setup time

tbsz: 1b # test bitwise and skip if zero (address of val in IOH, val to test against in immediate operand)
    IOH AI # addr = IOH
    MO XI  # X = M[IOH]
    PO AI  # addr = PC
    MO YI P+ # Y = M[PC], inc PC
    X&Y    # compute X&Y
    PO JNZ P+ # skip next 1 word if zero

sb: 1c # set bits in val at 0xfffe based on bits in IOL (M[0xfffe] |= IOL)
    -2 AI # addr = 0xfffe
    MO XI # X = M[0xfffe]
    IOL YI # Y = IOL
    MI X|Y # M[0xfffe] = X|Y

ldxi: 1d # load x from 16-bit immediate operand
    PO AI   # addr = PC
    MO XI P+ # X = M[addr], inc PC

ldyi: 1e # load y from 16-bit immediate operand
    PO AI   # addr = PC
    MO YI P+ # Y = M[addr], inc PC

jr_pos: 1f # jump to a positive offset 1 to 256, relative to address of next instr
    PO XI     # X = PC
    IOL YI    # Y = IOL
    JMP X+Y+1 # jump to X+Y+1

jr_neg: 20 # jump to a negative offset -1 to -256, relative to address of next instr
    PO XI     # X = PC
    IOL YI    # Y = IOL
    JMP X-Y-1 # jump to X-Y-1

ldxoy: 21 # load x from imm16 + y
    PO AI # addr = PC
    MO XI P+ # X = M[addr], inc PC
    AI X+Y # addr = X+Y (= imm16 + y)
    MO XI # X = M[addr] = M[imm16+y]

ret: 22 # pop PC from stack pointed to by IOH (e.g. instruction 14ff if SP is at ffff), with pre-increment of sp
    IOH AI # addr = IOH (i.e. SP)
    MO YI  # Y = M[addr]
    YI Y+1 # Y = Y+1 (i.e. increment SP)
    YO MI # M[addr] = Y (write incremented SP)
    YO AI # addr = Y (i.e. new SP)
    MO JMP # jmp to M[addr]
