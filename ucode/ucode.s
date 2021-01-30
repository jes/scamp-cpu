add x, (i8h):
    IOH AI
    MO YI
    XI X+Y

add x, i16:
    PO AI
    MO YI P+
    XI X+Y

add x, (i16):
    PO AI
    MO AI P+
    MO YI
    XI X+Y

add x, ((i8h)):
    IOH AI
    MO AI
    MO YI
    XI X+Y

add x, i8l:
    IOL YI
    XI X+Y

add x, i8h:
    IOH YI
    XI X+Y

add (i8h), x:
    IOH AI
    MO YI
    MI Y+X

add (i16), x:
    PO AI
    MO AI P+
    MO YI
    MI Y+X

add ((i8h)), x:
    IOH AI
    MO AI
    MO YI
    MI Y+X

sub x, (i8h):
    IOH AI
    MO YI
    XI X-Y

sub x, i16:
    PO AI
    MO YI P+
    XI X-Y

sub x, (i16):
    PO AI
    MO AI P+
    MO YI
    XI X-Y

sub x, ((i8h)):
    IOH AI
    MO AI
    MO YI
    XI X-Y

sub x, i8l:
    IOL YI
    XI X-Y

sub x, i8h:
    IOH YI
    XI X-Y

sub (i8h), x:
    IOH AI
    MO YI
    MI Y-X

sub (i16), x:
    PO AI
    MO AI P+
    MO YI
    MI Y-X

sub ((i8h)), x:
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

inc (i8h):
    IOH AI
    MO YI
    MI Y+1

dec (i8h):
    IOH AI
    MO YI
    MI Y-1

inc (i16):
    PO AI
    MO AI P+
    MO YI
    MI Y+1

dec (i16):
    PO AI
    MO AI P+
    MO YI
    MI Y-1

inc ((i8h)):
    IOH AI
    MO AI
    MO YI
    MI Y+1

dec ((i8h)):
    IOH AI
    MO AI
    MO YI
    MI Y-1

in x, (i8h):
    IOH AI
    MO AI
    DO XI

in x, i16:
    PO AI
    MO AI P+
    DO XI

in x, (i16):
    PO AI
    MO AI P+
    MO AI
    DO XI

in x, ((i8h)):
    IOH AI
    MO AI
    MO AI
    DO XI

in x, i8l:
    IOL AI
    DO XI

in x, i8h:
    IOH AI
    DO XI

in (i8h), x:
    AI XO
    DO YI
    IOH AI
    MI YO

in (i16), x:
    AI XO
    DO YI
    PO AI
    MO AI P+
    MI YO

in ((i8h)), x:
    AI XO
    DO YI
    IOH AI
    MO AI
    MI YO

out x, (i8h):
    IOH AI
    MO YI
    XO AI
    YO DI

out x, i16:
    PO AI
    MO YI P+
    XO AI
    YO DI

out x, (i16):
    PO AI
    MO AI P+
    MO YI
    XO AI
    YO DI

out x, ((i8h)):
    IOH AI
    MO AI
    MO YI
    XO AI
    YO DI

out x, i8l:
    XO AI
    IOL DI

out x, i8h:
    XO AI
    IOH DI

out (i8h), x:
    IOH AI
    MO AI
    XO DI

out i16, x:
    PO AI
    MO AI P+
    XO DI

out (i16), x:
    PO AI
    MO AI P+
    MO AI
    XO DI

out ((i8h)), x:
    IOH AI
    MO AI
    MO AI
    XO DI

out i8l, x:
    IOL AI
    XO DI

out i8h, x:
    IOH AI
    XO DI

out i16, (i8h):
    IOH AI
    MO YI
    PO AI
    MO AI P+
    YO DI

in (i8h), i16:
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

jmp i16:
    PO AI
    MO JMP

jz i16:
    PO AI
    MO JZ P+

jnz i16:
    PO AI
    MO JNZ P+

jgt i16:
    PO AI
    MO JGT P+

jlt i16:
    PO AI
    MO JLT P+

jge i16:
    PO AI
    MO JZ JGT P+

jle i16:
    PO AI
    MO JZ JLT P+

jmp (i16):
    PO AI
    MO AI
    MO JMP

jz (i16):
    PO AI
    MO AI P+
    MO JZ

jnz (i16):
    PO AI
    MO AI P+
    MO JNZ

jgt (i16):
    PO AI
    MO AI P+
    MO JZ JGT

jlt (i16):
    PO AI
    MO AI P+
    MO JZ JLT

jge (i16):
    PO AI
    MO AI P+
    MO JZ JGT

jle (i16):
    PO AI
    MO AI P+
    MO JZ JLT

ret: # jmp (++(0xffff))
    -1 AI
    MO YI
    MI Y+1
    MO AI
    MO JMP

jr+ i8l: # clobbers X
    PO YI
    IOL XI
    JMP X+Y

jr- i8l: # clobbers X
    PO YI
    IOL XI
    JMP Y-X

jr+ (i8h): # clobbers X
    PO YI
    IOH AI
    MO XI
    JMP X+Y

jr- (i8h): # clobbers X
    PO YI
    IOH AI
    MO XI
    JMP Y-X

ld x, (i8h):
    IOH AI
    MO XI

ld x, i16:
    PO AI
    MO XI P+

ld x, (i16):
    PO AI
    MO AI P+
    MO XI

ld x, ((i8h)):
    IOH AI
    MO AI
    MO XI

ld x, ((i16)):
    PO AI
    MO AI P+
    MO AI
    MO XI

ld x, i8l:
    IOL XI

ld x, i8h:
    IOH XI

ld x, ++(i8h):
    IOH AI
    MO XI
    X+1 MI # XXX: we'd save a cycle if we could do "MI XI" in one step
    X+1 XI

ld x, --(i8h):
    IOH AI
    MO XI
    X-1 MI # XXX: we'd save a cycle if we could do "MI XI" in one step
    X-1 XI

ld x, (i8h)++:
    IOH AI
    MO XI
    X+1 MI

ld x, (i8h)--:
    IOH AI
    MO XI
    X-1 MI

ld x, ++(i16):
    PO AI
    MO AI P+
    MO XI
    X+1 MI # XXX: we'd save a cycle if we could do "MI XI" in one step
    X+1 XI

ld x, --(i16):
    PO AI
    MO AI P+
    MO XI
    X-1 MI # XXX: we'd save a cycle if we could do "MI XI" in one step
    X-1 XI

ld x, (i16)++:
    PO AI
    MO AI P+
    MO XI
    X+1 MI

ld x, (i16)--:
    PO AI
    MO AI P+
    MO XI
    X-1 MI

ld x, (++(i8h)):
    IOH AI
    MO XI
    MI X+1 # XXX: we'd save a cycle if we could do "MI AI" in one step
    AI X+1
    MO XI

ld x, (--(i8h)):
    IOH AI
    MO XI
    MI X-1 # XXX: we'd save a cycle if we could do "MI AI" in one step
    AI X-1
    MO XI

ld x, ((i8h)++):
    IOH AI
    MO YI # XXX: we'd save a cycle if we could do "YI AI" in one step
    MO AI
    MO XI
    IOH AI
    MI Y+1

ld x, ((i8h)--):
    IOH AI
    MO YI # XXX: we'd save a cycle if we could do "YI AI" in one step
    MO AI
    MO XI
    IOH AI
    MI Y-1

ld (i8h), x:
    IOH AI
    MI XO

ld (i16), x:
    PO AI
    MO AI P+
    MI XO

ld ((i8h)), x:
    IOH AI
    MO AI
    MI XO

ld ((i16)), x:
    PO AI
    MO AI P+
    MO AI
    MI XO

ld (++(i8h)), x:
    IOH AI
    MO YI
    Y+1 MI # XXX: we'd save a cycle if we could do "MI AI" in one step
    Y+1 AI
    MI XO

ld (--(i8h)), x:
    IOH AI
    MO YI
    Y-1 MI # XXX: we'd save a cycle if we could do "MI AI" in one step
    Y-1 AI
    MI XO

ld ((i8h)++), x:
    IOH AI
    MO YI # XXX: we'd save a cycle if we could do "YI AI" in one step
    MO AI
    MI XO
    IOH AI
    Y+1 MI

ld ((i8h)--), x:
    IOH AI
    MO YI # XXX: we'd save a cycle if we could do "YI AI" in one step
    MO AI
    MI XO
    IOH AI
    Y-1 MI

ld (i8h), (i16):
    PO AI
    MO AI P+
    MO YI
    IOH AI
    MI YO

ld (i16), (i8h):
    IOH AI
    MO YI
    PO AI
    MO AI
    MI YO P+

ld (i8h), i16:
    PO AI
    MO YI P+
    IOH AI
    MI YO

ld y, x: # The "ld y, ..." instructions exist solely for use with "xor x, y"
    YI XO

ld y, (i8h):
    IOH AI
    MO YI

ld y, i8h:
    IOH YI

ld y, i8l:
    IOL YI

ld y, i16:
    PO AI
    MO YI P+

and (i16), x:
    PO AI
    MO AI P+
    MO YI
    MI Y&X

and ((i8h)), x:
    IOH AI
    MO AI
    MO YI
    MI Y&X

and (i8h), x:
    IOH AI
    MO YI
    MI Y&X

and x, (i16):
    PO AI
    MO AI P+
    MO YI
    XI X&Y

and x, i16:
    PO AI
    MO YI P+
    XI X&Y

and x, ((i8h)):
    IOH AI
    MO AI
    MO YI
    XI X&Y

and x, (i8h):
    IOH AI
    MO YI
    XI X&Y

and x, i8l:
    IOL YI
    XI X&Y

nand (i16), x:
    PO AI
    MO AI P+
    MO YI
    MI ~(Y&X)

nand ((i8h)), x:
    IOH AI
    MO AI
    MO YI
    MI ~(Y&X)

nand (i8h), x:
    IOH AI
    MO YI
    MI ~(Y&X)

nand x, (i16):
    PO AI
    MO AI P+
    MO YI
    XI ~(X&Y)

nand x, i16:
    PO AI
    MO YI P+
    XI ~(X&Y)

nand x, ((i8h)):
    IOH AI
    MO AI
    MO YI
    XI ~(X&Y)

nand x, (i8h):
    IOH AI
    MO YI
    XI ~(X&Y)

nand x, i8l:
    IOL YI
    XI ~(X&Y)

nor (i16), x:
    PO AI
    MO AI P+
    MO YI
    MI ~(Y|X)

nor ((i8h)), x:
    IOH AI
    MO AI
    MO YI
    MI ~(Y|X)

nor (i8h), x:
    IOH AI
    MO YI
    MI ~(Y|X)

nor x, (i16):
    PO AI
    MO AI P+
    MO YI
    XI ~(X|Y)

nor x, i16:
    PO AI
    MO YI P+
    XI ~(X|Y)

nor x, ((i8h)):
    IOH AI
    MO AI
    MO YI
    XI ~(X|Y)

nor x, (i8h):
    IOH AI
    MO YI
    XI ~(X|Y)

nor x, i8l:
    IOL YI
    XI ~(X|Y)

or (i16), x:
    PO AI
    MO AI P+
    MO YI
    MI Y|X

or ((i8h)), x:
    IOH AI
    MO AI
    MO YI
    MI Y|X

or (i8h), x:
    IOH AI
    MO YI
    MI Y|X

or x, (i16):
    PO AI
    MO AI P+
    MO YI
    XI X|Y

or x, i16:
    PO AI
    MO YI P+
    XI X|Y

or x, ((i8h)):
    IOH AI
    MO AI
    MO YI
    XI X|Y

or x, (i8h):
    IOH AI
    MO YI
    XI X|Y

or x, i8l:
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

xor x, i8l:
    -2 AI      # addr = -2
    IOL YI     # Y = IOL
    MI X|Y     # M[-2] = X|Y
    YI ~(X&Y)  # Y = ~(X&Y)
    MO XI      # X = M[-2]
    XI X&Y     # X = X&Y

xor x, i8h:
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

shl (i8h): # clobbers X
    IOH AI
    MO XI
    YI X
    XI X+Y

shl2 (i8h): # clobbers X
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

push i8l: # ld ((-1)--), i8l
    -1 AI
    MO YI # XXX: we'd save a cycle if we could do "YI AI" in one step
    MO AI
    MI IOL
    -1 AI
    Y-1 MI

push i8h: # ld ((-1)--), i8h
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

tbsz (i8h), i16: # test bits and skip if zero (address in IOH, val to test against in i16)
    IOH AI # addr = IOH
    MO XI  # X = M[IOH]
    PO AI  # addr = PC
    MO YI P+ # Y = M[PC], inc PC
    X&Y    # compute X&Y
    PO JNZ P+ # skip next 1 word if zero

sb i8l: # set bits in val at 0xfffe based on bits in IOL (M[0xfffe] |= IOL)
    -2 AI # addr = 0xfffe
    MO XI # X = M[0xfffe]
    IOL YI # Y = IOL
    MI X|Y # M[0xfffe] = X|Y
