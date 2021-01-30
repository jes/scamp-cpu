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
    # clobbers: r254
    -2 AI
    MI X|Y
    YI ~(X&Y)
    MO XI
    XI X&Y

xor x, i8l:
    # clobbers: r254
    -2 AI
    IOL YI
    MI X|Y
    YI ~(X&Y)
    MO XI
    XI X&Y

xor x, i8h:
    # clobbers: r254
    -2 AI
    IOH YI
    MI X|Y
    YI ~(X&Y)
    MO XI
    XI X&Y

shl x: # Bitwise shift-left by 1 bit.
    YI X
    XI X+Y

shl2 x: # Bitwise shift-left by 2 bits.
    YI X
    XI X+Y
    YI X
    XI X+Y

shl3 x: # Bitwise shift-left by 3 bits.
    YI X
    XI X+Y
    YI X
    XI X+Y
    YI X
    XI X+Y

shl (i8h): # Bitwise shift-left by 1 bit.
    IOH AI
    MO XI
    YI X
    XI X+Y

shl2 (i8h): # Bitwise shift-left by 2 bits.
    IOH AI
    MO XI
    YI X
    XI X+Y
    YI X
    XI X+Y

push x:
    -1 AI
    MO YI
    MO AI
    MI XO
    -1 AI
    Y-1 MI

push i8l:
    -1 AI
    MO YI
    MO AI
    MI IOL
    -1 AI
    Y-1 MI

push i8h:
    -1 AI
    MO YI
    MO AI
    MI IOH
    -1 AI
    Y-1 MI

pop x:
    -1 AI
    MO XI
    MI X+1
    AI X+1
    MO XI

nop:

tbsz (i8h), i16: # Test bits and skip if zero: if none of the bits set in the <tt>i16</tt> are also set in <tt>r</tt>, then skip the next 1-word instruction. Use in tandem with <tt>sb</tt> to compute bitwise shift-right of 8 or more bits.
    IOH AI
    MO XI
    PO AI
    MO YI P+
    X&Y
    PO JNZ P+

sb i8l: # Set bits in <tt>r254</tt> based on the <tt>i8l</tt>. i.e. <tt>r254 |= i8l</tt>.
    -2 AI
    MO XI
    IOL YI
    MI X|Y
