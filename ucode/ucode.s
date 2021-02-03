add x, (i8h): # Add the <tt>r</tt> to <tt>x</tt>.
    IOH AI
    MO YI
    XI X+Y

add x, i16: # Add the <tt>i16</tt> to <tt>x</tt>.
    PO AI
    MO YI P+
    XI X+Y

add x, (i16): # Add the value in <tt>(i16)</tt> to <tt>x</tt>.
    PO AI
    MO AI P+
    MO YI
    XI X+Y

add x, ((i8h)): # Add the value in <tt>(r)</tt> to <tt>x</tt>.
    IOH AI
    MO AI
    MO YI
    XI X+Y

add x, ((i8h)++): # Add the value in <tt>(r)</tt> to <tt>x</tt>. Increment <tt>r</tt>.
    IOH AI
    MO YI
    Y+1 MI
    YO AI
    MO YI
    XI X+Y

add x, ((i8h)--): # Add the value in <tt>(r)</tt> to <tt>x</tt>. Decrement <tt>r</tt>.
    IOH AI
    MO YI
    Y-1 MI
    YO AI
    MO YI
    XI X+Y

add x, i8l: # Add the <tt>i8l</tt> to <tt>x</tt>.
    IOL YI
    XI X+Y

add x, i8h: # Add the <tt>i8h</tt> to <tt>x</tt>.
    IOH YI
    XI X+Y

add (i8h), x: # Add <tt>x</tt> to the <tt>r</tt>.
    IOH AI
    MO YI
    MI Y+X

add (i16), x: # Add <tt>x</tt> to the value in <tt>(i16)</tt>.
    PO AI
    MO AI P+
    MO YI
    MI Y+X

add (i16), i8l: # Add <tt>i8l</tt> to the value in <tt>(i16)</tt>.
    PO AI
    MO AI P+
    MO XI
    IOL YI
    MI X+Y

add ((i8h)), x: # Add <tt>x</tt> to the value in <tt>(r)</tt>.
    IOH AI
    MO AI
    MO YI
    MI Y+X

add (i8h), i16:
    PO AI
    MO XI P+
    IOH AI
    MO YI
    MI Y+X

add ((i8h)), i16:
    PO AI
    MO XI P+
    IOH AI
    MO AI
    MO YI
    MI Y+X

add (i8h), (i16):
    PO AI
    MO AI
    MO XI P+
    IOH AI
    MO YI
    MI Y+X

nop:

sub x, (i8h): # Subtract the <tt>r</tt> from <tt>x</tt>.
    IOH AI
    MO YI
    XI X-Y

sub x, i16: # Subtract the <tt>i16</tt> from <tt>x</tt>.
    PO AI
    MO YI P+
    XI X-Y

sub x, (i16): # Subtract the value in <tt>(i16)</tt> from <tt>x</tt>.
    PO AI
    MO AI P+
    MO YI
    XI X-Y

sub x, ((i8h)): # Subtract the value in <tt>(r)</tt> from <tt>x</tt>.
    IOH AI
    MO AI
    MO YI
    XI X-Y

sub x, ((i8h)++): # Subtract the value in <tt>(r)</tt> from <tt>x</tt>. Increment <tt>r</tt>.
    IOH AI
    MO YI
    Y+1 MI
    YO AI
    MO YI
    XI X-Y

sub x, ((i8h)--): # Subtract the value in <tt>(r)</tt> from <tt>x</tt>. Decrement <tt>r</tt>.
    IOH AI
    MO YI
    Y-1 MI
    YO AI
    MO YI
    XI X-Y

sub x, i8l: # Subtract the <tt>i8l</tt> from <tt>x</tt>.
    IOL YI
    XI X-Y

sub x, i8h: # Subtract the <tt>i8h</tt> from <tt>x</tt>.
    IOH YI
    XI X-Y

sub (i8h), x: # Subtract <tt>x</tt> from the <tt>r</tt>.
    IOH AI
    MO YI
    MI Y-X

sub (i16), x: # Subtract <tt>x</tt> from the value in <tt>(i16)</tt>.
    PO AI
    MO AI P+
    MO YI
    MI Y-X

sub (i16), i8l: # Subtract <tt>i8l</tt> from the value in <tt>(i16)</tt>.
    PO AI
    MO AI P+
    MO XI
    IOL YI
    MI X-Y

sub ((i8h)), x: # Subtract <tt>x</tt> from the value in <tt>(r)</tt>.
    IOH AI
    MO AI
    MO YI
    MI Y-X

sub (i8h), i16:
    PO AI
    MO XI P+
    IOH AI
    MO YI
    MI Y-X

sub ((i8h)), i16:
    PO AI
    MO XI P+
    IOH AI
    MO AI
    MO YI
    MI Y-X

sub (i8h), (i16):
    PO AI
    MO AI
    MO XI P+
    IOH AI
    MO YI
    MI Y-X

nop:

and x, (i8h):
    IOH AI
    MO YI
    XI X&Y

and x, i16:
    PO AI
    MO YI P+
    XI X&Y

and x, (i16):
    PO AI
    MO AI P+
    MO YI
    XI X&Y

and x, ((i8h)):
    IOH AI
    MO AI
    MO YI
    XI X&Y

and x, ((i8h)++):
    IOH AI
    MO YI
    Y+1 MI
    YO AI
    MO YI
    XI X&Y

and x, ((i8h)--):
    IOH AI
    MO YI
    Y-1 MI
    YO AI
    MO YI
    XI X&Y

and x, i8l:
    IOL YI
    XI X&Y

and x, i8h:
    IOH YI
    XI X&Y

and (i8h), x:
    IOH AI
    MO YI
    MI Y&X

and (i16), x:
    PO AI
    MO AI P+
    MO YI
    MI Y&X

and (i16), i8l:
    PO AI
    MO AI P+
    MO XI
    IOL YI
    MI X&Y

and ((i8h)), x:
    IOH AI
    MO AI
    MO YI
    MI Y&X

and (i8h), i16:
    PO AI
    MO XI P+
    IOH AI
    MO YI
    MI Y&X

and ((i8h)), i16:
    PO AI
    MO XI P+
    IOH AI
    MO AI
    MO YI
    MI Y&X

and (i8h), (i16):
    PO AI
    MO AI
    MO XI P+
    IOH AI
    MO YI
    MI Y&X

nop:

or x, (i8h):
    IOH AI
    MO YI
    XI X|Y

or x, i16:
    PO AI
    MO YI P+
    XI X|Y

or x, (i16):
    PO AI
    MO AI P+
    MO YI
    XI X|Y

or x, ((i8h)):
    IOH AI
    MO AI
    MO YI
    XI X|Y

or x, ((i8h)++):
    IOH AI
    MO YI
    Y+1 MI
    YO AI
    MO YI
    XI X|Y

or x, ((i8h)--):
    IOH AI
    MO YI
    Y-1 MI
    YO AI
    MO YI
    XI X|Y

or x, i8l:
    IOL YI
    XI X|Y

or x, i8h:
    IOH YI
    XI X|Y

or (i8h), x:
    IOH AI
    MO YI
    MI Y|X

or (i16), x:
    PO AI
    MO AI P+
    MO YI
    MI Y|X

or (i16), i8l:
    PO AI
    MO AI P+
    MO XI
    IOL YI
    MI X|Y

or ((i8h)), x:
    IOH AI
    MO AI
    MO YI
    MI Y|X

or (i8h), i16:
    PO AI
    MO XI P+
    IOH AI
    MO YI
    MI Y|X

or ((i8h)), i16:
    PO AI
    MO XI P+
    IOH AI
    MO AI
    MO YI
    MI Y|X

or (i8h), (i16):
    PO AI
    MO AI
    MO XI P+
    IOH AI
    MO YI
    MI Y|X

nop:

nand x, (i8h):
    IOH AI
    MO YI
    XI ~(X&Y)

nand x, i16:
    PO AI
    MO YI P+
    XI ~(X&Y)

nand x, (i16):
    PO AI
    MO AI P+
    MO YI
    XI ~(X&Y)

nand x, ((i8h)):
    IOH AI
    MO AI
    MO YI
    XI ~(X&Y)

nand x, ((i8h)++):
    IOH AI
    MO YI
    Y+1 MI
    YO AI
    MO YI
    XI ~(X&Y)

nand x, ((i8h)--):
    IOH AI
    MO YI
    Y-1 MI
    YO AI
    MO YI
    XI ~(X&Y)

nand x, i8l:
    IOL YI
    XI ~(X&Y)

nand x, i8h:
    IOH YI
    XI ~(X&Y)

nand (i8h), x:
    IOH AI
    MO YI
    MI ~(Y&X)

nand (i16), x:
    PO AI
    MO AI P+
    MO YI
    MI ~(Y&X)

nand (i16), i8l:
    PO AI
    MO AI P+
    MO XI
    IOL YI
    MI ~(Y&X)

nand ((i8h)), x:
    IOH AI
    MO AI
    MO YI
    MI ~(Y&X)

nand (i8h), i16:
    PO AI
    MO XI P+
    IOH AI
    MO YI
    MI ~(Y&X)

nand ((i8h)), i16:
    PO AI
    MO XI P+
    IOH AI
    MO AI
    MO YI
    MI ~(Y&X)

nand (i8h), (i16):
    PO AI
    MO AI
    MO XI P+
    IOH AI
    MO YI
    MI ~(Y&X)

nop:

nor x, (i8h):
    IOH AI
    MO YI
    XI ~(X|Y)

nor x, i16:
    PO AI
    MO YI P+
    XI ~(X|Y)

nor x, (i16):
    PO AI
    MO AI P+
    MO YI
    XI ~(X|Y)

nor x, ((i8h)):
    IOH AI
    MO AI
    MO YI
    XI ~(X|Y)

nor x, ((i8h)++):
    IOH AI
    MO YI
    Y+1 MI
    YO AI
    MO YI
    XI ~(X|Y)

nor x, ((i8h)--):
    IOH AI
    MO YI
    Y-1 MI
    YO AI
    MO YI
    XI ~(X|Y)

nor x, i8l:
    IOL YI
    XI ~(X|Y)

nor x, i8h:
    IOH YI
    XI ~(X|Y)

nor (i8h), x:
    IOH AI
    MO YI
    MI ~(Y|X)

nor (i16), x:
    PO AI
    MO AI P+
    MO YI
    MI ~(Y|X)

nor (i16), i8l:
    PO AI
    MO AI P+
    MO XI
    IOL YI
    MI ~(Y|X)

nor ((i8h)), x:
    IOH AI
    MO AI
    MO YI
    MI ~(Y|X)

nor (i8h), i16:
    PO AI
    MO XI P+
    IOH AI
    MO YI
    MI ~(Y|X)

nor ((i8h)), i16:
    PO AI
    MO XI P+
    IOH AI
    MO AI
    MO YI
    MI ~(Y|X)

nor (i8h), (i16):
    PO AI
    MO AI
    MO XI P+
    IOH AI
    MO YI
    MI ~(Y|X)

nop:

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

ld x, ((i8h)++):
    IOH AI
    MO YI
    MO AI
    MO XI
    IOH AI
    MI Y+1

ld x, ((i8h)--):
    IOH AI
    MO YI
    MO AI
    MO XI
    IOH AI
    MI Y-1

ld x, i8l:
    IOL XI

ld x, i8h:
    IOH XI

ld (i8h), x:
    IOH AI
    MI XO

ld (i16), x:
    PO AI
    MO AI P+
    MI XO

ld (i16), i8l:
    PO AI
    MO AI P+
    MI IOL

ld ((i8h)), x:
    IOH AI
    MO AI
    MI XO

ld x, ++(i8h):
    IOH AI
    MO XI
    X+1 MI
    X+1 XI

ld x, --(i8h):
    IOH AI
    MO XI
    X-1 MI
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
    X+1 MI
    X+1 XI

ld x, --(i16):
    PO AI
    MO AI P+
    MO XI
    X-1 MI
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
    MI X+1
    AI X+1
    MO XI

ld x, (--(i8h)):
    IOH AI
    MO XI
    MI X-1
    AI X-1
    MO XI

ld x, ((i16)):
    PO AI
    MO AI P+
    MO AI
    MO XI

ld x, i8l((65535)): # Load <tt>x</tt> from the address <tt>sp+i8l</tt>.
    -1 AI
    MO YI
    IOL XI
    X+Y AI
    MO XI

ld (i8h), (x):
    XO AI
    MO YI
    IOH AI
    MI YO

ld (i8h), i16(x): # Load <tt>x</tt> from the address <tt>x+i16</tt>.
    PO AI
    MO YI P+
    AI X+Y
    MO YI
    IOH AI
    MI YO

ld ((i16)), x:
    PO AI
    MO AI P+
    MO AI
    MI XO

ld (++(i8h)), x:
    IOH AI
    MO YI
    Y+1 MI
    Y+1 AI
    MI XO

ld (--(i8h)), x:
    IOH AI
    MO YI
    Y-1 MI
    Y-1 AI
    MI XO

ld ((i8h)++), x:
    IOH AI
    MO YI
    MO AI
    MI XO
    IOH AI
    Y+1 MI

ld ((i8h)--), x:
    IOH AI
    MO YI
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

ld ((i8h)), i16:
    PO AI
    MO YI P+
    IOH AI
    MO AI
    MI YO

ld y, x: # The <tt>ld y, ...</tt> instructions exist solely for use with <tt>xor x, y</tt>.
    YI XO

ld y, (i8h): # The <tt>ld y, ...</tt> instructions exist solely for use with <tt>xor x, y</tt>.
    IOH AI
    MO YI

ld y, i16: # The <tt>ld y, ...</tt> instructions exist solely for use with <tt>xor x, y</tt>.
    PO AI
    MO YI P+

nop:
nop:
nop:
nop:
nop:
nop:
nop:
nop:
nop:
nop:

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

out i16, x:
    PO AI
    MO AI P+
    XO DI

out i16, (i8h):
    IOH AI
    MO YI
    PO AI
    MO AI P+
    YO DI

out i16, ((i8h)):
    IOH AI
    MO AI
    MO YI
    PO AI
    MO AI P+
    YO DI

nop:
nop:

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

in (i8h), i16:
    PO AI
    MO AI P+
    YI DO
    IOH AI
    MI YO

in ((i8h)), i16:
    PO AI
    MO AI P+
    YI DO
    IOH AI
    MO AI
    MI YO

nop:
nop:
nop:
nop:
nop:

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

jr+ i8l: # Jump forwards relative to the address of the next instruction. <tt>jr+ 0</tt> is a no-op.
    PO YI
    IOL XI
    JMP X+Y

jr- i8l: # Jump backwards relative to the address of the next instruction. <tt>jr- 0</tt> is a no-op. <tt>jr- 1</tt> is an infinite loop.
    PO YI
    IOL XI
    JMP Y-X

jr+ (i8h): # Jump forwards relative to the address of the next instruction. <tt>jr+ 0</tt> is a no-op.
    PO YI
    IOH AI
    MO XI
    JMP X+Y

jr- (i8h): # Jump backwards relative to the address of the next instruction. <tt>jr- 0</tt> is a no-op. <tt>jr- 1</tt> is an infinite loop.
    PO YI
    IOH AI
    MO XI
    JMP Y-X

call i16: # Set <tt>r254</tt> to the return address. Jump to <tt>i16</tt>.
    # clobbers: r254
    -2 AI
    PO YI
    Y+1 MI
    PO AI
    MO JMP

call (i16): # Set <tt>r254</tt> to the return address. Jump to <tt>(i16)</tt>.
    # clobbers: r254
    -2 AI
    PO YI
    Y+1 MI
    PO AI
    MO AI
    MO JMP

ret: # Jump to <tt>r254</tt>.
    -2 AI
    MO JMP

ret i8l: # Increase <tt>sp</tt> by <tt>i8l</tt>. Jump to <tt>r254</tt>.
    -1 AI
    MO YI
    IOL XI
    MI X+Y
    -2 AI
    MO JMP

nop:

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

nop:
nop:
nop:
nop:
nop:
nop:
nop:
nop:
nop:

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
    MO JGT

jlt (i16):
    PO AI
    MO AI P+
    MO JLT

jge (i16):
    PO AI
    MO AI P+
    MO JZ JGT

jle (i16):
    PO AI
    MO AI P+
    MO JZ JLT

test x:
    X

test (i8h):
    IOH AI
    MO YI
    Y

test (x):
    XO AI
    MO YI
    Y

test ((i8h)):
    IOH AI
    MO AI
    MO YI
    Y

test (i16):
    PO AI
    MO AI P+
    MO YI
    Y

nop:
nop:
nop:
nop: # Do nothing.

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
    MI X+Y

shl2 (i8h): # Bitwise shift-left by 2 bits.
    IOH AI
    MO XI
    YI X
    XI X+Y
    YI X
    MI X+Y

tbsz (i8h), i16: # Test bits and skip if zero: if none of the bits set in the <tt>i16</tt> are also set in <tt>r</tt>, then skip the next 1-word instruction. Use in tandem with <tt>sb</tt> to compute bitwise shift-right of 8 or more bits.
    IOH AI
    MO XI
    PO AI
    MO YI P+
    X&Y
    PO JNZ P+

sb (65534), i8l: # Set bits in <tt>r254</tt> based on the <tt>i8l</tt>. i.e. <tt>r254 |= i8l</tt>.
    -2 AI
    MO XI
    IOL YI
    MI X|Y

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
nop:

inc x: # Increment <tt>x</tt>.
    XI X+1

inc (i8h): # Increment <tt>r</tt>.
    IOH AI
    MO YI
    MI Y+1

inc (x): # Increment the value in <tt>(x)</tt>.
    XO AI
    MO YI
    MI Y+1

inc ((i8h)): # Increment the value in <tt>(r)</tt>.
    IOH AI
    MO AI
    MO YI
    MI Y+1

inc (i16): # Increment the value in <tt>(i16)</tt>.
    PO AI
    MO AI P+
    MO YI
    MI Y+1

dec x: # Decrement <tt>x</tt>.
    XI X-1

dec (i8h): # Decrement <tt>r</tt>.
    IOH AI
    MO YI
    MI Y-1

dec (x): # Decrement the value in <tt>(x)</tt>.
    XO AI
    MO YI
    MI Y-1

dec ((i8h)): # Decrement the value in <tt>(r)</tt>.
    IOH AI
    MO AI
    MO YI
    MI Y-1

dec (i16): # Decrement the value in <tt>(i16)</tt>.
    PO AI
    MO AI P+
    MO YI
    MI Y-1

not x:
    XI ~X

not (i8h):
    IOH AI
    MO YI
    MI ~Y

not (x):
    XO AI
    MO YI
    MI ~Y

not ((i8h)):
    IOH AI
    MO AI
    MO YI
    MI ~Y

not (i16):
    PO AI
    MO AI P+
    MO YI
    MI ~Y

slownop: # Do nothing, and take 8 cycles.
    PO
    PO
    PO
    PO
    PO
    PO
