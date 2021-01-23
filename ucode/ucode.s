# Provisional microcode for testing

add: 0 # X = X+Y
    EX EY F EO XI

ldx: 1 # load X from IOL
    IOL XI

ldy: 2 # load Y from IOL
    IOL YI

out: 3 # output X register
    XO DI

inc: 4 # increment X register: X = X+1
    EX NX NY F NO EO XI

dec: 5 # decrement X register: X = X-1
    EX NY F EO XI

sub: 6 # X = X-Y
    EX NX F NO EO XI
