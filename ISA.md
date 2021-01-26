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

## Instructions

### Load/store

ld, st

Maybe don't need these if we are sufficiently CISC: loads and stores can simply be side
effects of more interesting instructions.

### Jump

jz, jnz, jgt, jlt, jge, jle, jc, jmp

### Arithmetic

inc, dec, add, sub, adc (add w/ carry), sbc (sub w/ carry), clc (clear carry)

### Logic

and, or, not

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


### I/O

in, out

### Calling

push, pop, call, ret

### Misc

nop? halt?

### CISC

The microcode potentially gives us a lot of freedom to do more complicated things:

djnz of X: (Decrement and jump if not zero)

    [opcode] [jump target]

    1. ALU=X-1 EO XI    load X-1 into X
    2. PO AI            load address from PC (jump target)
    3. MO JGT JLZ P+    jump to address from RAM if X-1 != 0, else inc PC

Add 2 consecutive numbers together from an immediate address operand and store it in a 2nd
immediate address operand:

    [opcode] [address of first number] [address of result]

    1.  PO AI          load address from PC (address of first number)
    2.  MO AI          load address from RAM
    3.  MO YI P+       load RAM contents into Y, increment PC
    4.  YO AI          load address from Y
    5.  MO XI P+       load RAM into X, increment PC
    6.  ALU=Y+1 EO AI  load Y+1 into address
    7.  MO YI          load RAM into Y
    8.  ALU=X+Y EO AI  load X+Y into X
    9.  PO AI          load address from PC (address of result)
    10. MO AI          load address from RAM
    11. XO MI          store X in address from PC

11 microcode steps is probably pushing it a bit. It would be good if we could fit everything
in 8, because then we only need 3 bits for T-state. Maybe 4 would be fine.
