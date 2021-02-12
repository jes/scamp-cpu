add x, (i8h): # Add <tt>r</tt> to <tt>x</tt>.
    IOH AI
    MO YI
    XI X+Y

add x, i16: # Add <tt>i16</tt> to <tt>x</tt>.
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

add x, ((i8h)++): # Add the value in <tt>(r)</tt> to <tt>x</tt>. Post-increment <tt>r</tt>.
    IOH AI
    MO YI
    Y+1 MI
    YO AI
    MO YI
    XI X+Y

add x, ((i8h)--): # Add the value in <tt>(r)</tt> to <tt>x</tt>. Post-decrement <tt>r</tt>.
    IOH AI
    MO YI
    Y-1 MI
    YO AI
    MO YI
    XI X+Y

add x, i8l: # Add <tt>i8l</tt> to <tt>x</tt>.
    IOL YI
    XI X+Y

add x, i8h: # Add <tt>i8h</tt> to <tt>x</tt>.
    IOH YI
    XI X+Y

add (i8h), x: # Add <tt>x</tt> to <tt>r</tt>.
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

add (i8h), i16: # Add <tt>i16</tt> to the value in <tt>r</tt>.
    PO AI
    MO XI P+
    IOH AI
    MO YI
    MI Y+X

add ((i8h)), i16: # Add <tt>i16</tt> to the value in <tt>(r)</tt>.
    PO AI
    MO XI P+
    IOH AI
    MO AI
    MO YI
    MI Y+X

add (i8h), (i16): # Add <tt>(i16)</tt> to the value in <tt>r</tt>.
    PO AI
    MO AI
    MO XI P+
    IOH AI
    MO YI
    MI Y+X

nop:

sub x, (i8h): # Subtract <tt>r</tt> from <tt>x</tt>.
    IOH AI
    MO YI
    XI X-Y

sub x, i16: # Subtract <tt>i16</tt> from <tt>x</tt>.
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

sub x, ((i8h)++): # Subtract the value in <tt>(r)</tt> from <tt>x</tt>. Post-increment <tt>r</tt>.
    IOH AI
    MO YI
    Y+1 MI
    YO AI
    MO YI
    XI X-Y

sub x, ((i8h)--): # Subtract the value in <tt>(r)</tt> from <tt>x</tt>. Post-decrement <tt>r</tt>.
    IOH AI
    MO YI
    Y-1 MI
    YO AI
    MO YI
    XI X-Y

sub x, i8l: # Subtract <tt>i8l</tt> from <tt>x</tt>.
    IOL YI
    XI X-Y

sub x, i8h: # Subtract <tt>i8h</tt> from <tt>x</tt>.
    IOH YI
    XI X-Y

sub (i8h), x: # Subtract <tt>x</tt> from <tt>r</tt>.
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

sub (i8h), i16: # Subtract <tt>i16</tt> from <tt>r</tt>.
    PO AI
    MO XI P+
    IOH AI
    MO YI
    MI Y-X

sub ((i8h)), i16: # Subtract <tt>i16</tt> from the value in <tt>(r)</tt>.
    PO AI
    MO XI P+
    IOH AI
    MO AI
    MO YI
    MI Y-X

sub (i8h), (i16): # Subtract the value in <tt>(i16)</tt> from <tt>r</tt>.
    PO AI
    MO AI
    MO XI P+
    IOH AI
    MO YI
    MI Y-X

nop:

and x, (i8h): # AND <tt>r</tt> with <tt>x</tt>.
    IOH AI
    MO YI
    XI X&Y

and x, i16: # AND <tt>i16</tt> with <tt>x</tt>.
    PO AI
    MO YI P+
    XI X&Y

and x, (i16): # AND the value in <tt>(i16)</tt> with <tt>x</tt>.
    PO AI
    MO AI P+
    MO YI
    XI X&Y

and x, ((i8h)): # AND the value in <tt>(r)</tt> with <tt>x</tt>.
    IOH AI
    MO AI
    MO YI
    XI X&Y

and x, ((i8h)++): # AND the value in <tt>(r)</tt> with <tt>x</tt>. Post-increment <tt>r</tt>.
    IOH AI
    MO YI
    Y+1 MI
    YO AI
    MO YI
    XI X&Y

and x, ((i8h)--): # AND the value in <tt>(r)</tt> with <tt>x</tt>. Post-decrement <tt>r</tt>.
    IOH AI
    MO YI
    Y-1 MI
    YO AI
    MO YI
    XI X&Y

and x, i8l: # AND <tt>i8l</tt> with <tt>x</tt>.
    IOL YI
    XI X&Y

and x, i8h: # AND <tt>i8h</tt> with <tt>x</tt>.
    IOH YI
    XI X&Y

and (i8h), x: # AND <tt>x</tt> with <tt>r</tt>.
    IOH AI
    MO YI
    MI Y&X

and (i16), x: # AND <tt>x</tt> with the value in <tt>(i16)</tt>.
    PO AI
    MO AI P+
    MO YI
    MI Y&X

and (i16), i8l: # AND <tt>i8l</tt> with the value in <tt>(i16)</tt>.
    PO AI
    MO AI P+
    MO XI
    IOL YI
    MI X&Y

and ((i8h)), x: # AND <tt>x</tt> with the value in <tt>(r)</tt>.
    IOH AI
    MO AI
    MO YI
    MI Y&X

and (i8h), i16: # AND <tt>i16</tt> with the value in <tt>r</tt>.
    PO AI
    MO XI P+
    IOH AI
    MO YI
    MI Y&X

and ((i8h)), i16: # AND <tt>i16</tt> with the value in <tt>(r)</tt>.
    PO AI
    MO XI P+
    IOH AI
    MO AI
    MO YI
    MI Y&X

and (i8h), (i16): # AND the value in <tt>(i16)</tt> with <tt>r</tt>.
    PO AI
    MO AI
    MO XI P+
    IOH AI
    MO YI
    MI Y&X

nop:

or x, (i8h): # OR <tt>r</tt> into <tt>x</tt>.
    IOH AI
    MO YI
    XI X|Y

or x, i16: # OR <tt>i16</tt> into <tt>x</tt>.
    PO AI
    MO YI P+
    XI X|Y

or x, (i16): # OR the value in <tt>(i16)</tt> into <tt>x</tt>.
    PO AI
    MO AI P+
    MO YI
    XI X|Y

or x, ((i8h)): # OR the value in <tt>r</tt> into <tt>x</tt>.
    IOH AI
    MO AI
    MO YI
    XI X|Y

or x, ((i8h)++): # OR the value in <tt>r</tt> into <tt>x</tt>. Post-increment <tt>r</tt>.
    IOH AI
    MO YI
    Y+1 MI
    YO AI
    MO YI
    XI X|Y

or x, ((i8h)--): # OR the value in <tt>r</tt> into <tt>x</tt>. Post-decrement <tt>r</tt>.
    IOH AI
    MO YI
    Y-1 MI
    YO AI
    MO YI
    XI X|Y

or x, i8l: # OR <tt>i8l</tt> into <tt>x</tt>.
    IOL YI
    XI X|Y

or x, i8h: # OR <tt>i8h</tt> into <tt>x</tt>.
    IOH YI
    XI X|Y

or (i8h), x: # OR <tt>x</tt> into <tt>r</tt>.
    IOH AI
    MO YI
    MI Y|X

or (i16), x: # OR <tt>x</tt> into the value in <tt>(i16)</tt>.
    PO AI
    MO AI P+
    MO YI
    MI Y|X

or (i16), i8l: # OR <tt>i8l</tt> into the value in <tt>(i16)</tt>.
    PO AI
    MO AI P+
    MO XI
    IOL YI
    MI X|Y

or ((i8h)), x: # OR <tt>x</tt> into the value in <tt>(r)</tt>.
    IOH AI
    MO AI
    MO YI
    MI Y|X

or (i8h), i16: # OR <tt>i16</tt> into <tt>r</tt>.
    PO AI
    MO XI P+
    IOH AI
    MO YI
    MI Y|X

or ((i8h)), i16: # OR <tt>i16</tt> into the value in <tt>(r)</tt>.
    PO AI
    MO XI P+
    IOH AI
    MO AI
    MO YI
    MI Y|X

or (i8h), (i16): # OR the value in <tt>(i16)</tt> into <tt>r</tt>.
    PO AI
    MO AI
    MO XI P+
    IOH AI
    MO YI
    MI Y|X

nop:

nand x, (i8h): # NAND <tt>r</tt> with <tt>x</tt>.
    IOH AI
    MO YI
    XI ~(X&Y)

nand x, i16: # NAND <tt>i16</tt> with <tt>x</tt>.
    PO AI
    MO YI P+
    XI ~(X&Y)

nand x, (i16): # NAND the value in <tt>(i16)</tt> with <tt>x</tt>.
    PO AI
    MO AI P+
    MO YI
    XI ~(X&Y)

nand x, ((i8h)): # NAND the value in <tt>(r)</tt> with <tt>x</tt>.
    IOH AI
    MO AI
    MO YI
    XI ~(X&Y)

nand x, ((i8h)++): # NAND the value in <tt>(r)</tt> with <tt>x</tt>. Post-increment <tt>r</tt>.
    IOH AI
    MO YI
    Y+1 MI
    YO AI
    MO YI
    XI ~(X&Y)

nand x, ((i8h)--): # NAND the value in <tt>(r)</tt> with <tt>x</tt>. Post-decrement <tt>r</tt>.
    IOH AI
    MO YI
    Y-1 MI
    YO AI
    MO YI
    XI ~(X&Y)

nand x, i8l: # NAND <tt>i8l</tt> with <tt>x</tt>.
    IOL YI
    XI ~(X&Y)

nand x, i8h: # NAND <tt>i8h</tt> with <tt>x</tt>.
    IOH YI
    XI ~(X&Y)

nand (i8h), x: # NAND <tt>x</tt> with <tt>r</tt>.
    IOH AI
    MO YI
    MI ~(Y&X)

nand (i16), x: # NAND <tt>x</tt> with the value in <tt>(i16)</tt>.
    PO AI
    MO AI P+
    MO YI
    MI ~(Y&X)

nand (i16), i8l: # NAND <tt>i8l</tt> with the value in <tt>(i16)</tt>.
    PO AI
    MO AI P+
    MO XI
    IOL YI
    MI ~(Y&X)

nand ((i8h)), x: # NAND <tt>x</tt> with the value in <tt>(r)</tt>.
    IOH AI
    MO AI
    MO YI
    MI ~(Y&X)

nand (i8h), i16: # NAND <tt>i16</tt> with <tt>r</tt>.
    PO AI
    MO XI P+
    IOH AI
    MO YI
    MI ~(Y&X)

nand ((i8h)), i16: # NAND <tt>i16</tt> with the value in <tt>(r)</tt>.
    PO AI
    MO XI P+
    IOH AI
    MO AI
    MO YI
    MI ~(Y&X)

nand (i8h), (i16): # NAND the value in <tt>(i16)</tt> with <tt>r</tt>.
    PO AI
    MO AI
    MO XI P+
    IOH AI
    MO YI
    MI ~(Y&X)

nop:

nor x, (i8h): # NOR <tt>r</tt> with <tt>x</tt>.
    IOH AI
    MO YI
    XI ~(X|Y)

nor x, i16: # NOR <tt>i16</tt> with <tt>x</tt>.
    PO AI
    MO YI P+
    XI ~(X|Y)

nor x, (i16): # NOR the value in <tt>(i16)</tt>.
    PO AI
    MO AI P+
    MO YI
    XI ~(X|Y)

nor x, ((i8h)): # NOR the value in <tt>(r)</tt> with <tt>x</tt>.
    IOH AI
    MO AI
    MO YI
    XI ~(X|Y)

nor x, ((i8h)++): # NOR the value in <tt>(r)</tt> with <tt>x</tt>. Post-increment <tt>r</tt>.
    IOH AI
    MO YI
    Y+1 MI
    YO AI
    MO YI
    XI ~(X|Y)

nor x, ((i8h)--): # NOR the value in <tt>(r)</tt> with <tt>x</tt>. Post-decrement <tt>r</tt>.
    IOH AI
    MO YI
    Y-1 MI
    YO AI
    MO YI
    XI ~(X|Y)

nor x, i8l: # NOR <tt>i8l</tt> with <tt>x</tt>.
    IOL YI
    XI ~(X|Y)

nor x, i8h: # NOR <tt>i8h</tt> with <tt>x</tt>.
    IOH YI
    XI ~(X|Y)

nor (i8h), x: # NOR <tt>x</tt> with <tt>r</tt>.
    IOH AI
    MO YI
    MI ~(Y|X)

nor (i16), x: # NOR <tt>x</tt> with the value in <tt>(i16)</tt>.
    PO AI
    MO AI P+
    MO YI
    MI ~(Y|X)

nor (i16), i8l: # NOR <tt>i8l</tt> with the value in <tt>(i16)</tt>.
    PO AI
    MO AI P+
    MO XI
    IOL YI
    MI ~(Y|X)

nor ((i8h)), x: # NOR <tt>x</tt> with the value in <tt>(r)</tt>.
    IOH AI
    MO AI
    MO YI
    MI ~(Y|X)

nor (i8h), i16: # NOR <tt>i16</tt> with <tt>r</tt>.
    PO AI
    MO XI P+
    IOH AI
    MO YI
    MI ~(Y|X)

nor ((i8h)), i16: # NOR <tt>i16</tt> with the value in <tt>(r)</tt>.
    PO AI
    MO XI P+
    IOH AI
    MO AI
    MO YI
    MI ~(Y|X)

nor (i8h), (i16): # NOR the value in <tt>(i16)</tt> with <tt>r</tt>.
    PO AI
    MO AI
    MO XI P+
    IOH AI
    MO YI
    MI ~(Y|X)

nop:

xor x, y: # XOR <tt>y</tt> with <tt>x</tt>.
    # clobbers: r254
    -2 AI
    MI X|Y
    YI ~(X&Y)
    MO XI
    XI X&Y

xor x, i8l: # XOR <tt>i8l</tt> with <tt>x</tt>.
    # clobbers: r254
    -2 AI
    IOL YI
    MI X|Y
    YI ~(X&Y)
    MO XI
    XI X&Y

xor x, i8h: # XOR <tt>i8h</tt> with <tt>x</tt>.
    # clobbers: r254
    -2 AI
    IOH YI
    MI X|Y
    YI ~(X&Y)
    MO XI
    XI X&Y

shl x: # Bitwise shift-left <tt>x</tt> by 1 place.
    YI X
    XI X+Y

shl2 x: # Bitwise shift-left <tt>x</tt> by 2 places.
    YI X
    XI X+Y
    YI X
    XI X+Y

shl3 x: # Bitwise shift-left <tt>x</tt> by 3 places.
    YI X
    XI X+Y
    YI X
    XI X+Y
    YI X
    XI X+Y

shl (i8h): # Bitwise shift-left <tt>r</tt> by 1 place.
    IOH AI
    MO XI
    YI X
    MI X+Y

shl2 (i8h): # Bitwise shift-left <tt>r</tt> by 2 places.
    IOH AI
    MO XI
    YI X
    XI X+Y
    YI X
    MI X+Y

tbsz (i8h), i16: # Test bits and skip if zero: if none of the bits set in <tt>i16</tt> are also set in <tt>r</tt>, then skip the next 1-word instruction. Use in tandem with <tt>sb</tt> to compute bitwise shift-right of 8 or more bits.
    IOH AI
    MO XI
    PO AI
    MO YI P+
    X&Y
    PO JNZ P+

sb (65534), i8l: # Set bits in <tt>r254</tt> based on <tt>i8l</tt>. i.e. <tt>r254 |= i8l</tt>.
    -2 AI
    MO XI
    IOL YI
    MI X|Y

nop:
nop:
nop:
nop:
nop:
nop:

ld x, (i8h): # Load <tt>r</tt> into <tt>x</tt>.
    IOH AI
    MO XI

ld x, i16: # Load <tt>i16</tt> into <tt>x</tt>.
    PO AI
    MO XI P+

ld x, (i16): # Load the value in <tt>(i16)</tt> into <tt>x</tt>.
    PO AI
    MO AI P+
    MO XI

ld x, ((i8h)): # Load the value in <tt>(r)</tt> into <tt>x</tt>.
    IOH AI
    MO AI
    MO XI

ld x, ((i8h)++): # Load the value in <tt>(r)</tt> into <tt>x</tt>. Post-increment <tt>r</tt>.
    IOH AI
    MO YI
    MO AI
    MO XI
    IOH AI
    MI Y+1

ld x, ((i8h)--): # Load the value in <tt>(r)</tt> into <tt>x</tt>. Post-decrement <tt>r</tt>.
    IOH AI
    MO YI
    MO AI
    MO XI
    IOH AI
    MI Y-1

ld x, i8l: # Load <tt>i8l</tt> into <tt>x</tt>.
    IOL XI

ld x, i8h: # Load <tt>i8h</tt> into <tt>x</tt>.
    IOH XI

ld (i8h), x: # Load <tt>x</tt> into <tt>r</tt>.
    IOH AI
    MI XO

ld (i16), x: # Load <tt>x</tt> into the value in <tt>(i16)</tt>.
    PO AI
    MO AI P+
    MI XO

ld (i16), i8l: # Load <tt>i8l</tt> into the value in <tt>(i16)</tt>.
    PO AI
    MO AI P+
    MI IOL

ld ((i8h)), x: # Load <tt>x</tt> into the value in <tt>(r)</tt>.
    IOH AI
    MO AI
    MI XO

ld x, ++(i8h): # Pre-increment <tt>r</tt>. Load <tt>r</tt> into <tt>x</tt>.
    IOH AI
    MO XI
    X+1 MI
    X+1 XI

ld x, --(i8h): # Pre-decrement <tt>r</tt>. Load <tt>r</tt> into <tt>x</tt>.
    IOH AI
    MO XI
    X-1 MI
    X-1 XI

ld x, (i8h)++: # Load <tt>r</tt> into <tt>x</tt>. Post-increment <tt>r</tt>.
    IOH AI
    MO XI
    X+1 MI

ld x, (i8h)--: # Load <tt>r</tt> into <tt>x</tt>. Post-decrement <tt>r</tt>.
    IOH AI
    MO XI
    X-1 MI

ld x, ++(i16): # Pre-increment the value in <tt>(i16)</tt>. Load the value in <tt>(i16)</tt> into <tt>x</tt>.
    PO AI
    MO AI P+
    MO XI
    X+1 MI
    X+1 XI

ld x, --(i16): # Pre-decrement the value in <tt>(i16)</tt>. Load the value in <tt>(i16)</tt> into <tt>x</tt>.
    PO AI
    MO AI P+
    MO XI
    X-1 MI
    X-1 XI

ld x, (i16)++: # Load the value in <tt>(i16)</tt> into <tt>x</tt>. Post-increment the value in <tt>(i16)</tt>.
    PO AI
    MO AI P+
    MO XI
    X+1 MI

ld x, (i16)--: # Load the value in <tt>(i16)</tt> into <tt>x</tt>. Post-decrement the value in <tt>(i16)</tt>.
    PO AI
    MO AI P+
    MO XI
    X-1 MI

ld x, (++(i8h)): # Pre-increment <tt>r</tt>. Load the value in <tt>(r)</tt> into <tt>x</tt>.
    IOH AI
    MO XI
    MI X+1
    AI X+1
    MO XI

ld x, (--(i8h)): # Pre-decrement <tt>r</tt>. Load the value in <tt>(r)</tt> into <tt>x</tt>.
    IOH AI
    MO XI
    MI X-1
    AI X-1
    MO XI

ld x, ((i16)): # Load the value in <tt>((i16))</tt> into <tt>x</tt>.
    PO AI
    MO AI P+
    MO AI
    MO XI

ld x, i8l((65535)): # Load the value in <tt>(sp+i8l)</tt> into <tt>x</tt>.
    -1 AI
    MO YI
    IOL XI
    X+Y AI
    MO XI

ld i8l((65535)), x: # Load <tt>x</tt> into <tt>(sp+i8l)</tt>.
    -1 AI
    MO YI
    IOL XI
    X+Y AI
    XO MI

ld (i8h), 1((65535)): # Load the value in <tt>(sp+1)</tt> into <tt>r</tt>.
    -1 AI
    MO YI
    Y+1 AI
    MO YI
    IOH AI
    YO MI

ld 1((65535)), (i8h): # Load the value in <tt>r</tt> into <tt>(sp+1)</tt>.
    IOH AI
    MO XI
    -1 AI
    MO YI
    Y+1 AI
    XO MI

ld 1((65535)), i8l: # Load <tt>i8l</tt> into <tt>(sp+1)</tt>.
    -1 AI
    MO YI
    Y+1 AI
    IOL MI

ld (i8h), (x): # Load the value in <tt>(x)</tt> into <tt>r</tt>.
    XO AI
    MO YI
    IOH AI
    MI YO

ld (i8h), i16(x): # Load the value in <tt>(x+i16)</tt> into <tt>r</tt>.
    PO AI
    MO YI P+
    AI X+Y
    MO YI
    IOH AI
    MI YO

ld ((i16)), x: # Load <tt>x</tt> into the value in <tt>((i16))</tt>.
    PO AI
    MO AI P+
    MO AI
    MI XO

ld (++(i8h)), x: # Pre-increment <tt>r</tt>. Load <tt>x</tt> into the value in <tt>(r)</tt>.
    IOH AI
    MO YI
    Y+1 MI
    Y+1 AI
    MI XO

ld (--(i8h)), x: # Pre-decrement <tt>r</tt>. Load <tt>x</tt> into the value in <tt>(r)</tt>.
    IOH AI
    MO YI
    Y-1 MI
    Y-1 AI
    MI XO

ld ((i8h)++), x: # Load <tt>x</tt> into the value in <tt>(r)</tt>. Post-increment <tt>r</tt>.
    IOH AI
    MO YI
    MO AI
    MI XO
    IOH AI
    Y+1 MI

ld ((i8h)--), x: # Load <tt>x</tt> into the value in <Tt>(r)</tt>. Post-decrement <tt>r</tt>.
    IOH AI
    MO YI
    MO AI
    MI XO
    IOH AI
    Y-1 MI

ld (i8h), (i16): # Load the value in <tt>(i16)</tt> into <tt>r</tt>.
    PO AI
    MO AI P+
    MO YI
    IOH AI
    MI YO

ld (i16), (i8h): # Load <tt>r</tt> into the value in <tt>(i16)</tt>.
    IOH AI
    MO YI
    PO AI
    MO AI
    MI YO P+

ld (i8h), i16: # Load <tt>i16</tt> into <tt>r</tt>.
    PO AI
    MO YI P+
    IOH AI
    MI YO

ld ((i8h)), i16: # Load <tt>i16</tt> into the value in <tt>(r)</tt>.
    PO AI
    MO YI P+
    IOH AI
    MO AI
    MI YO

ld (x), i16: # Load <tt>i16</tt> into <tt>(x)</tt>.
    PO AI
    MO YI P+
    XO AI
    MO AI
    MI YO

ld (x), (i8h): # Load <tt>r</tt> into <tt>(x)</tt>.
    IOH AI
    MO YI
    XO AI
    MO AI
    MI YO

ld (x), ((i8h)): # Load the value in <tt>(r)</tt> into <tt>(x)</tt>.
    IOH AI
    MO AI
    MO YI
    XO AI
    MO AI
    MI YO

ld (x), (i16): # Load the value in <tt>(i16)</tt> into <tt>(x)</tt>.
    PO AI
    MO AI P+
    MO YI
    XO AI
    MO AI
    MI YO

ld x, (x): # Load the value in <tt>(x)</tt> into <tt>x</tt>.
    XO AI
    MO XI

ld y, x: # Load <tt>x</tt> into <tt>y</tt>. Only useful for <tt>xor x, y</tt>.
    YI XO

ld y, (i8h): # Load <tt>r</tt> into <tt>y</tt>. Only useful for <tt>xor x, y</tt>.
    IOH AI
    MO YI

ld y, i16: # Load <tt>i16</tt> into <tt>y</tt>. Only useful for <tt>xor x, y</tt>.
    PO AI
    MO YI P+

nop:

jmp x: # Jump to <tt>x</tt>.
    XO JMP

jz x: # Jump to <tt>x</tt> if <tt>Z</tt> is set.
    XO JZ

jnz x: # Jump to <tt>x</tt> if <tt>Z</tt> is not set.
    XO JNZ

jgt x: # Jump to <tt>x</tt> if <tt>Z</tt> is not set and <tt>LT</tt> is not set.
    XO JGT

jlt x: # Jump to <tt>x</tt> if <tt>LT</tt> is set.
    XO JLT

jge x: # Jump to <tt>x</tt> if <tt>LT</tt> is not set.
    XO JZ JGT

jle x: # Jump to <tt>x</tt> if <tt>Z</tt> is set or <tt>LT</tt> is set.
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

jmp i16: # Jump to <tt>i16</tt>.
    PO AI
    MO JMP

jz i16: # Jump to <tt>i16</tt> if <tt>Z</tt> is set.
    PO AI
    MO JZ P+

jnz i16: # Jump to <tt>i16</tt> if <tt>Z</tt> is not set.
    PO AI
    MO JNZ P+

jgt i16: # Jump to <tt>i16</tt> if <tt>Z</tt> is not set and <tt>LT</tt> is not set.
    PO AI
    MO JGT P+

jlt i16: # Jump to <tt>i16</tt> if <tt>LT</tt> is set.
    PO AI
    MO JLT P+

jge i16: # Jump to <tt>i16</tt> if <tt>LT</tt> is not set.
    PO AI
    MO JZ JGT P+

jle i16: # Jump to <tt>i16</tt> if <tt>Z</tt> is set or <tt>LT</tt> is set.
    PO AI
    MO JZ JLT P+

push x: # Store <tt>x</tt> to the value in <tt>(sp)</tt>. Post-decrement <tt>sp</tt>.
    -1 AI
    MO YI
    MO AI
    MI XO
    -1 AI
    Y-1 MI

push i8l: # Store <tt>i8l</tt> to the value in <tt>(sp)</tt>. Post-decrement <tt>sp</tt>.
    -1 AI
    MO YI
    MO AI
    MI IOL
    -1 AI
    Y-1 MI

push i8h: # Store <tt>i8h</tt> to the value in <tt>(sp)</tt>. Post-decrement <tt>sp</tt>.
    -1 AI
    MO YI
    MO AI
    MI IOH
    -1 AI
    Y-1 MI

pop x: # Pre-increment <tt>sp</tt>. Load <tt>x</tt> from the value in <tt>(sp)</tt>.
    -1 AI
    MO XI
    MI X+1
    AI X+1
    MO XI

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

jmp (i16): # Jump to the address in <tt>(i16)</tt>.
    PO AI
    MO AI
    MO JMP

jz (i16): # Jump to the address in <tt>(i16)</tt> if <tt>Z</tt> is set.
    PO AI
    MO AI P+
    MO JZ

jnz (i16): # Jump to the address in <tt>(i16)</tt> if <tt>Z</tt> is not set.
    PO AI
    MO AI P+
    MO JNZ

jgt (i16): # Jump to the address in <tt>(i16)</tt> if <tt>Z</tt> is not set and <tt>LT</tt> is not set.
    PO AI
    MO AI P+
    MO JGT

jlt (i16): # Jump to the address in <tt>(i16)</tt> if <tt>LT</tt> is set.
    PO AI
    MO AI P+
    MO JLT

jge (i16): # Jump to the address in <tt>(i16)</tt> if <tt>LT</tt> is not set.
    PO AI
    MO AI P+
    MO JZ JGT

jle (i16): # Jump to the address in <tt>(i16)</tt> if <tt>Z</tt> is set or <tt>LT</tt> is set.
    PO AI
    MO AI P+
    MO JZ JLT

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

neg x: # Arithmetic negate <tt>x</tt>.
    XI -X

neg (i8h): # Arithmetic negate <tt>r</tt>.
    IOH AI
    MO YI
    MI -Y

neg (x): # Arithmetic negate the value in <tt>(x)</tt>.
    XO AI
    MO YI
    MI -Y

neg ((i8h)): # Arithmetic negate the value in <tt>(r)</tt>.
    IOH AI
    MO AI
    MO YI
    MI -Y

neg (i16): # Arithmetic negate the value in <tt>(i16)</tt>.
    PO AI
    MO AI P+
    MO YI
    MI -Y

nop:
nop:
nop:
nop:
nop:
nop:
nop:

call x: # Set <tt>r254</tt> to the return address. Jump to <tt>x</tt>.
    # clobbers: r254
    -2 AI
    PO MI
    XO JMP

call (x): # Set <tt>r254</tt> to the return address. Jump to <tt>(x)</tt>.
    # clobbers: r254
    -2 AI
    PO MI
    XO AI
    MO JMP

nop:
nop:


not x: # Bitwise complement <tt>x</tt>.
    XI ~X

not (i8h): # Bitwise complement <tt>r</tt>.
    IOH AI
    MO YI
    MI ~Y

not (x): # Bitwise complement the value in <tt>(x)</tt>.
    XO AI
    MO YI
    MI ~Y

not ((i8h)): # Bitwise complement the value in <tt>(r)</tt>.
    IOH AI
    MO AI
    MO YI
    MI ~Y

not (i16): # Bitwise complement the value in <tt>(i16)</tt>.
    PO AI
    MO AI P+
    MO YI
    MI ~Y

in x, (i8h): # Input from address <tt>r</tt> to <tt>x</tt>.
    IOH AI
    MO AI
    DO XI

in x, i16: # Input from address <tt>i16</tt> to <tt>x</tt>.
    PO AI
    MO AI P+
    DO XI

in x, (i16): # Input from the address in <tt>(i16)</tt> to <tt>x</tt>.
    PO AI
    MO AI P+
    MO AI
    DO XI

in x, ((i8h)): # Input from the address in <tt>(r)</tt> to <tt>x</tt>.
    IOH AI
    MO AI
    MO AI
    DO XI

in x, i8l: # Input from address <tt>i8l</tt> to <tt>x</tt>.
    IOL AI
    DO XI

in x, i8h: # Input from address <tt>i8h</tt> to <tt>x</tt>.
    IOH AI
    DO XI

in (i8h), x: # Input from address <tt>x</tt> to <tt>r</tt>.
    AI XO
    DO YI
    IOH AI
    MI YO

in (i16), x: # Input from address <tt>x</tt> to the value in <tt>(i16)</tt>.
    AI XO
    DO YI
    PO AI
    MO AI P+
    MI YO

in ((i8h)), x: # Input from address <tt>x</tt> to the value in <tt>(r)</tt>.
    AI XO
    DO YI
    IOH AI
    MO AI
    MI YO

in (i8h), i16: # Input from address <tt>i16</tt> to <tt>r</tt>.
    PO AI
    MO AI P+
    YI DO
    IOH AI
    MI YO

in ((i8h)), i16: # Input from address <tt>i16</tt> to the value in <tt>(r)</tt>.
    PO AI
    MO AI P+
    YI DO
    IOH AI
    MO AI
    MI YO

test x: # Set flags based on <tt>x</tt>.
    X

test (i8h): # Set flags based on <tt>r</tt>.
    IOH AI
    MO YI
    Y

test (x): # Set flags based on the value in <tt>(x)</tt>.
    XO AI
    MO YI
    Y

test ((i8h)): # Set flags based on the value in <tt>(r)</tt>.
    IOH AI
    MO AI
    MO YI
    Y

test (i16): # Set flags based on the value in <tt>(i16)</tt>.
    PO AI
    MO AI P+
    MO YI
    Y

out x, (i8h): # Output <tt>r</tt> to address <tt>x</tt>.
    IOH AI
    MO YI
    XO AI
    YO DI

out x, i16: # Output <tt>i16</tt> to address <tt>x</tt>.
    PO AI
    MO YI P+
    XO AI
    YO DI

out x, (i16): # Output the value in <tt>(i16)</tt> to address <tt>x</tt>.
    PO AI
    MO AI P+
    MO YI
    XO AI
    YO DI

out x, ((i8h)): # Output the value in <tt>(r)</tt> to address <tt>x</tt>.
    IOH AI
    MO AI
    MO YI
    XO AI
    YO DI

out x, i8l: # Output <tt>i8l</tt> to address <tt>x</tt>.
    XO AI
    IOL DI

out x, i8h: # Output <tt>i8h</tt> to address <tt>x</tt>.
    XO AI
    IOH DI

out (i8h), x: # Output <tt>x</tt> to address <tt>r</tt>.
    IOH AI
    MO AI
    XO DI

out (i16), x: # Output <tt>x</tt> to the address in <tt>(i16)</tt>.
    PO AI
    MO AI P+
    MO AI
    XO DI

out ((i8h)), x: # Output <tt>x</tt> to the address in <tt>(r)</tt>.
    IOH AI
    MO AI
    MO AI
    XO DI

out i8l, x: # Output <tt>x</tt> to address <tt>i8l</tt>.
    IOL AI
    XO DI

out i8h, x: # Output <tt>x</tt> to address <tt>i8h</tt>.
    IOH AI
    XO DI

out i16, x: # Output <tt>x</tt> to address <tt>i16</tt>.
    PO AI
    MO AI P+
    XO DI

out i16, (i8h): # Output <tt>r</tt> to address <tt>i16</tt>.
    IOH AI
    MO YI
    PO AI
    MO AI P+
    YO DI

out i16, ((i8h)): # Output the value in <tt>(r)</tt> to address <tt>i16</tt>.
    IOH AI
    MO AI
    MO YI
    PO AI
    MO AI P+
    YO DI

nop: # Do nothing.

slownop: # Do nothing, and take 8 cycles.
    PO
    PO
    PO
    PO
    PO
    PO
