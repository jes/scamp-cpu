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
