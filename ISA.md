# Instruction Set Architecture

Each word is 16 bits wide.

The high 8 bits of the opcode select the actual opcode. The low 8 bits are available
for an immediate small-valued constant. XXX: We could change this to 9/7 or 10/6 if
we need more opcode space.

## Addressing modes

There are kind of 2 orthogonal questions here: 1 is where the address comes from, and the other
is how many levels of indirection it takes.

Numbers can come from:
 * the low bits of the instruction word (IOH)
 * the low bits of the instruction word (IOL)
 * an operand word
 * the X register

Levels of indirection:
 * immediate value
 * 1 trip through RAM
 * 2 trips through RAM
 * 3 trips through RAM

Multiplying all combinations of these gets 16 different addressing modes, which would take up 4
bits of the opcode, leaving only 4 remaining bits to specify the operation. We probably either want
to cut down on the possibilities here, or commit to using 9 or 10 bits for the actual opcode.

## Instruction table

I'd like to produce a table like the one on https://clrhome.org/table/

It's a grid indexed by opcode, with each cell in the grid indicating the instruction
with that opcode. Destinations are the first argument, e.g. "ld a, b" means load the contents
of b into a. Indirection is given with parentheses, e.g. "ld (hl), a" means load the contents
of a into memory at the address stored in hl.

Hovering over an instruction pops up a box with more information. Information I would want to
show includes:

 * opcode in hex
 * instruction length in words
 * whether it clobbers or not for each of X, Y, flags, and memory (do we
    make a distinction between "writes to" and "clobbers"? e.g. "ld x, *" writes to X, so
    you lose what was already in X, but it's not exactly "clobbered"), and the nature of
    the clobber (e.g. if the new value might be useful)
 * a short description of what it does
 * the microcode implementing it, source and hex

Ideally this would all be auto-generated from information in the microcode source.

It would also be cool if the assembler could use the microcode source to define the available
opcodes, with as little hardcoding as possible.

## Instructions

The registers are called "x" and "y". Immediate values
are called "imm8l" if produced with "IOL" (0 to 255), "imm8h" if produced with "IOH" (0xff00 to
0xff), or "imm16" if produced with an extra word operand, in which case the operands
should appear in the machine code in the same order as they appear in the mnemonic. "SP" means
the same as "imm8h", but considers the imm8h value to be a stack pointer.

The assembly language should be as orthogonal as possible, with the assembler responsible for
deciding which opcode to use, e.g. "ld x, 5" can be accomplished with both "ld x, imm8l" and
"ld x, imm16".

The instructions listed below are currently aspirational. The list might have to be cut down if
the opcode space is not large enough, and some opcodes might not be implementable without
exceeding 6 T-states. We also might be able to add more if there is opcode space left over.

Where instructions clobber an address in memory (e.g. xor), there should probably be a
default that is normally used, and also some syntax to choose an alternative.

In total we currently have 169 opcodes.

### Load/store

38 opcodes:

    ld x, y
    ld y, x
    ld x, imm8l
    ld y, imm8l
    ld x, imm8h
    ld y, imm8h
    ld x, imm16
    ld y, imm16
    ld x, (imm8h)
    ld y, (imm8h)
    ld x, (imm16)
    ld y, (imm16)
    ld x, ((imm8h))
    ld y, ((imm8h))
    ld x, ((imm16))
    ld y, ((imm16))
    ld (x), x
    ld (x), y
    ld (y), x
    ld (y), y
    ld (imm8h), x
    ld (imm8h), y
    ld (imm16), x
    ld (imm16), y
    ld ((imm8h)), x
    ld ((imm8h)), y
    ld ((imm16)), x
    ld ((imm16)), y
    ld x, pc
    ld y, pc
    ld x, (imm16+x)
    ld y, (imm16+x)
    ld x, (imm16+y)
    ld y, (imm16+y)
    ld x, ((imm16)+x)
    ld y, ((imm16)+x)
    ld x, ((imm16)+y)
    ld y, ((imm16)+y)

### Jump

34 opcodes:

    jmp imm16
    jz  imm16
    jnz imm16
    jgt imm16
    jlt imm16
    jge imm16
    jle imm16
    jc  imm16
    jmp (imm16)
    jz  (imm16)
    jnz (imm16)
    jgt (imm16)
    jlt (imm16)
    jge (imm16)
    jle (imm16)
    jc  (imm16)
    jmp (x)
    jz (x)
    jnz (x)
    jgt (x)
    jlt (x)
    jge (x)
    jle (x)
    jc (x)
    jmp (y)
    jz (y)
    jnz (y)
    jgt (y)
    jlt (y)
    jge (y)
    jle (y)
    jc (y)
    jr (imm8l) # imm8l is a positive offset
    jr (imm8l) # imm8l is a negative offset

### Arithmetic

29 opcodes:

    inc x
    inc y
    dec x
    dec y
    inc (x)
    inc (y)
    dec (x)
    dec (y)
    inc (imm8h)
    dec (imm8h)
    inc (imm16)
    dec (imm16)
    add x, x
    add x, y
    add x, imm8l
    add x, imm8h
    add x, imm16
    sub x, y
    sub x, imm8l
    sub x, imm8h
    adc x, x
    adc x, y
    adc x, imm8l
    adc x, imm8h
    adc x, imm16
    sbc x, y
    sbc x, imm8l
    sbc x, imm8h
    clc

So far this mostly includes register and immediate-mode arguments. If opcode space
allows, we could add some memory operands for either source or destination, as well
as opcodes for the more elaborate ALU operations like "X+Y+1", "-X-Y-2".

The assembler could also provide "sub r, imm16" as "add r, -imm16" and
"sub r, r" as "ld x, 0".

### Logic

42 opcodes:

    and x, y
    and y, x
    and x, imm16
    and x, imm8l
    and x, imm8h
    and y, imm16
    and y, imm8l
    and y, imm8h
    or x, y
    or y, x
    or x, imm16
    or x, imm8l
    or x, imm8h
    or y, imm16
    or y, imm8l
    or y, imm8h
    not x
    not y
    nand x, y
    nand y, x
    nand x, imm16
    nand x, imm8l
    nand x, imm8h
    nand y, imm16
    nand y, imm8l
    nand y, imm8h
    nor x, y
    nor y, x
    nor x, imm16
    nor x, imm8l
    nor x, imm8h
    nor y, imm16
    nor y, imm8l
    nor y, imm8h
    xor x, y
    xor y, x
    xor x, imm16
    xor x, imm8l
    xor x, imm8h
    xor y, imm16
    xor y, imm8l
    xor y, imm8h

Again we could add some memory operands if opcode space allows.

### I/O

10 opcodes:

    in x, imm16
    in x, y
    in y, imm16
    in y, x
    out x, y
    out y, x
    out imm16, x
    out imm16, y
    out imm16, imm16
    out imm16, imm16

Device numbers and data are both 16 bits wide.

The first argument refers to the place that receives the data, so "out" takes the device number
first and "in" takes it second. We could look at the kinds of I/O that are likely to be common
and see if adding any memory operands would be helpful. In particular, the large block copy
of the TPA to disk should be optimised.

### Stack

11 opcodes:

    push (SP), x
    push (SP), y
    push (SP), (x)
    push (SP), (y)
    push (SP), imm16
    push (SP), (imm16)
    pop x, (SP)
    pop y, (SP)
    pop (x), (SP)
    pop (y), (SP)
    pop (imm16), (SP)
    ret (SP)

The (SP) arg is an imm8h stack pointer. I envisage defining a stack pointer in assembly language,
and using it like:

    SP: 0xff00
    push (SP), x
    pop x, (SP)

"push" post-decrements (SP), and "pop" pre-increments it. "ret" is basically just "pop pc, (SP)"

### Misc

1 opcode:

    nop

## Special instructions

4 opcodes:

    djnz x, imm16
    djnz y, imm16
    tbsz (imm8h), imm16
    sb 0xfffe, imm8l

Decrement and jump if not zero. Test bits and skip if zero. Set bits in M[0xfffe].

## Calling convention

The microcode is a bit too restricted to make an instruction that would push PC+2 and jump to an
argument, so the general method of calling would be to have the assembler generate the hardcoded
return address, and push it, and then jump to the callee.

In general, calling is:

    0: push (SP), 4 # push (SP), imm16
    2: jmp imm16
    4: ...

In the event that position-independent code is required, use something like:

    0: ld x, pc
    1: add x, 4      # with the "add x, imm8l" opcode (1 word)
    2: push (SP), x
    3: jmp imm16
    5: ...

The "ret" instruction can be used to return to the caller. It pops the return address
from the stack and jumps to it.

    0: ret

### Shift-right

These 2 instructions are kind of a bodge to support shift-right:

tbsz (test bits and skip if zero), sb (set bits)

tbsz takes the address of the value from IOH, and a bitmask as an argument, and skips the program
counter over the next 1-word instruction if none of the bits set in the value are also set in
the bitmask (i.e. if "val & mask == 0").

sb is a 1-word instruction that computes "M[0xfffe] |= IOL", i.e. OR's some of the lower
8 bits set in IOL into the value in M[0xfffe].

Use it by repeatedly tbsz of some value in the upper 8 bits, followed by sb of the
same value in the lower 8 bits:

    tbsz(0xff) 0x8000 # skip next if !(M[0xffff] & 0x8000)
    sb(0x80)          # M[0xfffe] |= 0x80
    tbsz(0xff) 0x4000 # skip next if !(M[0xffff] & 0x4000)
    sb(0x40)          # M[0xfffe] |= 0x40
    ...

so the >>8 operation takes up to 8*(8+6) = 112 cycles, plus setup time

### CISC

The microcode potentially gives us a lot of freedom to do more complicated things:

djnz of X: (Decrement and jump if not zero)

    [opcode] [jump target]

    1. ALU=X-1 EO XI    load X-1 into X
    2. PO AI            load address from PC (jump target)
    3. MO JGT JLZ P+    jump to address from RAM if X-1 != 0, else inc PC

Could we do something like ldir from Z80 (i.e. copy a block of data using 1 instruction that
keeps jumping to itself until the block is done)? My sense is no, because there aren't enough
registers or T-states. But it might be possible. Also might be possible to make a pair of
special-purpose instructions, like tbsz and sb, that make block copies faster than the simple way.
