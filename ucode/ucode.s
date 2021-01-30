add x, (imm8h):
    IOH AI
    MO YI
    XI X+Y

add x, imm16:
    PO AI
    MO YI P+
    XI X+Y

add x, (imm16):
    PO AI
    MO AI P+
    MO YI
    XI X+Y

add x, ((imm8h)):
    IOH AI
    MO AI
    MO YI
    XI X+Y

add x, imm8l:
    IOL YI
    XI X+Y

add x, imm8h:
    IOH YI
    XI X+Y

add (imm8h), x:
    IOH AI
    MO YI
    MI Y+X

add (imm16), x:
    PO AI
    MO AI P+
    MO YI
    MI Y+X

add ((imm8h)), x:
    IOH AI
    MO AI
    MO YI
    MI Y+X

sub x, (imm8h):
    IOH AI
    MO YI
    XI X-Y

sub x, imm16:
    PO AI
    MO YI P+
    XI X-Y

sub x, (imm16):
    PO AI
    MO AI P+
    MO YI
    XI X-Y

sub x, ((imm8h)):
    IOH AI
    MO AI
    MO YI
    XI X-Y

sub x, imm8l:
    IOL YI
    XI X-Y

sub x, imm8h:
    IOH YI
    XI X-Y

sub (imm8h), x:
    IOH AI
    MO YI
    MI Y-X

sub (imm16), x:
    PO AI
    MO AI P+
    MO YI
    MI Y-X

sub ((imm8h)), x:
    IOH AI
    MO AI
    MO YI
    MI Y-X

inc (x):
    XO AI
    MO YI
    MI Y+1

dec (x):
    XO AI
    MO YI
    MI Y-1

inc x:
    XI X+1

dec x:
    XI X-1

inc (imm8h):
    IOH AI
    MO YI
    MI Y+1

dec (imm8h):
    IOH AI
    MO YI
    MI Y-1

inc (imm16):
    PO AI
    MO AI P+
    MO YI
    MI Y+1

dec (imm16):
    PO AI
    MO AI P+
    MO YI
    MI Y-1

inc ((imm8h)):
    IOH AI
    MO AI
    MO YI
    MI Y+1

dec ((imm8h)):
    IOH AI
    MO AI
    MO YI
    MI Y-1

in x, (imm8h):
    IOH AI
    MO AI
    DO XI

in x, imm16:
    PO AI
    MO AI P+
    DO XI

in x, (imm16):
    PO AI
    MO AI P+
    MO AI
    DO XI

in x, ((imm8h)):
    IOH AI
    MO AI
    MO AI
    DO XI

in x, imm8l:
    IOL AI
    DO XI

in x, imm8h:
    IOH AI
    DO XI

in (imm8h), x:
    AI XO
    DO YI
    IOH AI
    MI YO

in (imm16), x:
    AI XO
    DO YI
    PO AI
    MO AI P+
    MI YO

in ((imm8h)), x:
    AI XO
    DO YI
    IOH AI
    MO AI
    MI YO

out x, (imm8h):
    IOH AI
    MO YI
    XO AI
    YO DI

out x, imm16:
    PO AI
    MO YI P+
    XO AI
    YO DI

out x, (imm16):
    PO AI
    MO AI P+
    MO YI
    XO AI
    YO DI

out x, ((imm8h)):
    IOH AI
    MO AI
    MO YI
    XO AI
    YO DI

out x, imm8l:
    XO AI
    IOL DI

out x, imm8h:
    XO AI
    IOH DI

out (imm8h), x:
    IOH AI
    MO AI
    XO DI

out imm16, x:
    PO AI
    MO AI P+
    XO DI

out (imm16), x:
    PO AI
    MO AI P+
    MO AI
    XO DI

out ((imm8h)), x:
    IOH AI
    MO AI
    MO AI
    XO DI

out imm8l, x:
    IOL AI
    XO DI

out imm8h, x:
    IOH AI
    XO DI

out imm16, (imm8h):
    IOH AI
    MO YI
    PO AI
    MO AI P+
    YO DI

in (imm8h), imm16:
    IOH AI
    MO YI
    PO AI
    MO AI P+
    YI DO

jmp x:
    XO JMP

jz x:
    XO JZ

jnz x:
    XO JNZ

jgt x:
    XO JGT

jlt x:
    XO JLT

jge x:
    XO JZ JGT

jle x:
    XO JZ JLT

jmp imm16:
    PO AI
    MO JMP

jz imm16:
    PO AI
    MO JZ P+

jnz imm16:
    PO AI
    MO JNZ P+

jgt imm16:
    PO AI
    MO JGT P+

jlt imm16:
    PO AI
    MO JLT P+

jge imm16:
    PO AI
    MO JZ JGT P+

jle imm16:
    PO AI
    MO JZ JLT P+

jmp (imm16):
    PO AI
    MO AI
    MO JMP

jz (imm16):
    PO AI
    MO AI P+
    MO JZ

jnz (imm16):
    PO AI
    MO AI P+
    MO JNZ

jgt (imm16):
    PO AI
    MO AI P+
    MO JZ JGT

jlt (imm16):
    PO AI
    MO AI P+
    MO JZ JLT

jge (imm16):
    PO AI
    MO AI P+
    MO JZ JGT

jle (imm16):
    PO AI
    MO AI P+
    MO JZ JLT

ret: # jmp (++(0xffff))
    -1 AI
    MO YI
    MI Y+1
    MO AI
    MO JMP

jr+ imm8l: # clobbers X
    PO YI
    IOL XI
    JMP X+Y

jr- imm8l: # clobbers X
    PO YI
    IOL XI
    JMP Y-X

jr+ (imm8h): # clobbers X
    PO YI
    IOH AI
    MO XI
    JMP X+Y

jr- (imm8h): # clobbers X
    PO YI
    IOH AI
    MO XI
    JMP Y-X

ld x, (imm8h):
    IOH AI
    MO XI

ld x, imm16:
    PO AI
    MO XI P+

ld x, (imm16):
    PO AI
    MO AI P+
    MO XI

ld x, ((imm8h)):
    IOH AI
    MO AI
    MO XI

ld x, ((imm16)):
    PO AI
    MO AI P+
    MO AI
    MO XI

ld x, imm8l:
    IOL XI

ld x, imm8h:
    IOH XI

ld x, ++(imm8h):
    IOH AI
    MO XI
    X+1 MI # XXX: we'd save a cycle if we could do "MI XI" in one step
    X+1 XI

ld x, --(imm8h):
    IOH AI
    MO XI
    X-1 MI # XXX: we'd save a cycle if we could do "MI XI" in one step
    X-1 XI

ld x, (imm8h)++:
    IOH AI
    MO XI
    X+1 MI

ld x, (imm8h)--:
    IOH AI
    MO XI
    X-1 MI

ld x, ++(imm16):
    PO AI
    MO AI P+
    MO XI
    X+1 MI # XXX: we'd save a cycle if we could do "MI XI" in one step
    X+1 XI

ld x, --(imm16):
    PO AI
    MO AI P+
    MO XI
    X-1 MI # XXX: we'd save a cycle if we could do "MI XI" in one step
    X-1 XI

ld x, (imm16)++:
    PO AI
    MO AI P+
    MO XI
    X+1 MI

ld x, (imm16)--:
    PO AI
    MO AI P+
    MO XI
    X-1 MI

ld x, (++(imm8h)):
    IOH AI
    MO XI
    MI X+1 # XXX: we'd save a cycle if we could do "MI AI" in one step
    AI X+1
    MO XI

ld x, (--(imm8h)):
    IOH AI
    MO XI
    MI X-1 # XXX: we'd save a cycle if we could do "MI AI" in one step
    AI X-1
    MO XI

ld x, ((imm8h)++):
    IOH AI
    MO YI # XXX: we'd save a cycle if we could do "YI AI" in one step
    MO AI
    MO XI
    IOH AI
    MI Y+1

ld x, ((imm8h)--):
    IOH AI
    MO YI # XXX: we'd save a cycle if we could do "YI AI" in one step
    MO AI
    MO XI
    IOH AI
    MI Y-1

ld (imm8h), x:
    IOH AI
    MI XO

ld (imm16), x:
    PO AI
    MO AI P+
    MI XO

ld ((imm8h)), x:
    IOH AI
    MO AI
    MI XO

ld ((imm16)), x:
    PO AI
    MO AI P+
    MO AI
    MI XO

ld (++(imm8h)), x:
    IOH AI
    MO YI
    Y+1 MI # XXX: we'd save a cycle if we could do "MI AI" in one step
    Y+1 AI
    MI XO

ld (--(imm8h)), x:
    IOH AI
    MO YI
    Y-1 MI # XXX: we'd save a cycle if we could do "MI AI" in one step
    Y-1 AI
    MI XO

ld ((imm8h)++), x:
    IOH AI
    MO YI # XXX: we'd save a cycle if we could do "YI AI" in one step
    MO AI
    MI XO
    IOH AI
    Y+1 MI

ld ((imm8h)--), x:
    IOH AI
    MO YI # XXX: we'd save a cycle if we could do "YI AI" in one step
    MO AI
    MI XO
    IOH AI
    Y-1 MI

ld (imm8h), (imm16):
    PO AI
    MO AI P+
    MO YI
    IOH AI
    MI YO

ld (imm16), (imm8h):
    IOH AI
    MO YI
    PO AI
    MO AI
    MI YO P+

ld (imm8h), imm16:
    PO AI
    MO YI P+
    IOH AI
    MI YO

ld y, x: # The "ld y, ..." instructions exist solely for use with "xor x, y"
    YI XO

ld y, (imm8h):
    IOH AI
    MO YI

ld y, imm8h:
    IOH YI

ld y, imm8l:
    IOL YI

ld y, imm16:
    PO AI
    MO YI P+

and (imm16), x:
    PO AI
    MO AI P+
    MO YI
    MI Y&X

and ((imm8h)), x:
    IOH AI
    MO AI
    MO YI
    MI Y&X

and (imm8h), x:
    IOH AI
    MO YI
    MI Y&X

and x, (imm16):
    PO AI
    MO AI P+
    MO YI
    XI X&Y

and x, imm16:
    PO AI
    MO YI P+
    XI X&Y

and x, ((imm8h)):
    IOH AI
    MO AI
    MO YI
    XI X&Y

and x, (imm8h):
    IOH AI
    MO YI
    XI X&Y

and x, imm8l:
    IOL YI
    XI X&Y

nand (imm16), x:
    PO AI
    MO AI P+
    MO YI
    MI ~(Y&X)

nand ((imm8h)), x:
    IOH AI
    MO AI
    MO YI
    MI ~(Y&X)

nand (imm8h), x:
    IOH AI
    MO YI
    MI ~(Y&X)

nand x, (imm16):
    PO AI
    MO AI P+
    MO YI
    XI ~(X&Y)

nand x, imm16:
    PO AI
    MO YI P+
    XI ~(X&Y)

nand x, ((imm8h)):
    IOH AI
    MO AI
    MO YI
    XI ~(X&Y)

nand x, (imm8h):
    IOH AI
    MO YI
    XI ~(X&Y)

nand x, imm8l:
    IOL YI
    XI ~(X&Y)

nor (imm16), x:
    PO AI
    MO AI P+
    MO YI
    MI ~(Y|X)

nor ((imm8h)), x:
    IOH AI
    MO AI
    MO YI
    MI ~(Y|X)

nor (imm8h), x:
    IOH AI
    MO YI
    MI ~(Y|X)

nor x, (imm16):
    PO AI
    MO AI P+
    MO YI
    XI ~(X|Y)

nor x, imm16:
    PO AI
    MO YI P+
    XI ~(X|Y)

nor x, ((imm8h)):
    IOH AI
    MO AI
    MO YI
    XI ~(X|Y)

nor x, (imm8h):
    IOH AI
    MO YI
    XI ~(X|Y)

nor x, imm8l:
    IOL YI
    XI ~(X|Y)

or (imm16), x:
    PO AI
    MO AI P+
    MO YI
    MI Y|X

or ((imm8h)), x:
    IOH AI
    MO AI
    MO YI
    MI Y|X

or (imm8h), x:
    IOH AI
    MO YI
    MI Y|X

or x, (imm16):
    PO AI
    MO AI P+
    MO YI
    XI X|Y

or x, imm16:
    PO AI
    MO YI P+
    XI X|Y

or x, ((imm8h)):
    IOH AI
    MO AI
    MO YI
    XI X|Y

or x, (imm8h):
    IOH AI
    MO YI
    XI X|Y

or x, imm8l:
    IOL YI
    XI X|Y

xor x, y:
    # the idea here is to calculate X^Y == (X|Y) & ~(X&Y) by first storing X|Y in memory,
    # then storing X&Y in Y, then loading the original X|Y from memory into X, then
    # computing ~(X&Y) and storing it in X
    -2 AI      # addr = -2
    MI X|Y     # M[-2] = X|Y
    YI ~(X&Y)  # Y = ~(X&Y)
    MO XI      # X = M[-2]
    XI X&Y     # X = X&Y

xor x, imm8l:
    -2 AI      # addr = -2
    IOL YI     # Y = IOL
    MI X|Y     # M[-2] = X|Y
    YI ~(X&Y)  # Y = ~(X&Y)
    MO XI      # X = M[-2]
    XI X&Y     # X = X&Y

xor x, imm8h:
    -2 AI      # addr = -2
    IOH YI     # Y = IOH
    MI X|Y     # M[-2] = X|Y
    YI ~(X&Y)  # Y = ~(X&Y)
    MO XI      # X = M[-2]
    XI X&Y     # X = X&Y

shl x:
    YI X
    XI X+Y

shl2 x:
    YI X
    XI X+Y
    YI X
    XI X+Y

shl3 x:
    YI X
    XI X+Y
    YI X
    XI X+Y
    YI X
    XI X+Y

shl (imm8h): # clobbers X
    IOH AI
    MO XI
    YI X
    XI X+Y

shl2 (imm8h): # clobbers X
    IOH AI
    MO XI
    YI X
    XI X+Y
    YI X
    XI X+Y

push x: # ld ((-1)--), x
    -1 AI
    MO YI # XXX: we'd save a cycle if we could do "YI AI" in one step
    MO AI
    MI XO
    -1 AI
    Y-1 MI

push imm8l: # ld ((-1)--), imm8l
    -1 AI
    MO YI # XXX: we'd save a cycle if we could do "YI AI" in one step
    MO AI
    MI IOL
    -1 AI
    Y-1 MI

push imm8h: # ld ((-1)--), imm8h
    -1 AI
    MO YI # XXX: we'd save a cycle if we could do "YI AI" in one step
    MO AI
    MI IOH
    -1 AI
    Y-1 MI

pop x: # ld x, (++(-1))
    -1 AI
    MO XI
    MI X+1 # XXX: we'd save a cyle if we could do "MI AI" in one step
    AI X+1
    MO XI

nop:

tbsz (imm8h), imm16: # test bits and skip if zero (address in IOH, val to test against in imm16)
    IOH AI # addr = IOH
    MO XI  # X = M[IOH]
    PO AI  # addr = PC
    MO YI P+ # Y = M[PC], inc PC
    X&Y    # compute X&Y
    PO JNZ P+ # skip next 1 word if zero

sb imm8l: # set bits in val at 0xfffe based on bits in IOL (M[0xfffe] |= IOL)
    -2 AI # addr = 0xfffe
    MO XI # X = M[0xfffe]
    IOL YI # Y = IOL
    MI X|Y # M[0xfffe] = X|Y
