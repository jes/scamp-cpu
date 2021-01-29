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
 * the Y register

Levels of indirection:
 * immediate value
 * 1 trip through RAM
 * 2 trips through RAM
 * 3 trips through RAM
 * 1 trip through RAM with pre-/post- increment/decrement
 * 2 trip through RAM with pre-/post- increment/decrement of pointer
 * 2 trip through RAM with pre-/post- increment/decrement of value

We could consider "hiding" the Y register, so that it can always be clobbered without needing
an excuse. And then the opcode space saved by removing instructions that store to Y can for
example be used for instructions that instead fetch indirect values into Y. It would probably
be worth writing some simple-ish programs in the instruction set as defined here and seeing if
there are any obvious candidates for creating instructions that do the job of 2 at once.

Even if we don't hide "Y", it should be a point of philosophy that instructions will clobber the
Y register in preference to the X register where there is a free choice.

Apart from instructions that do specifically require an imm8h, we should flesh out the instruction
set with all immediate values as imm16, and then add optimised versions later for common
operations.

We could consider the imm8h addresses to be "registers", and make a "r0" .. "r255" syntax for
addressing them. So then instead of "add x, (0xff00)", you'd be able to write "add x, r0" and
it all becomes much easier to read. It also clarifies the difference between the (imm16) and (imm8h)
addressing modes, and we could potentially make the assembler warn if you use a (imm16) that is in
the top page.

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
 * clock cycles to execute it (including 2 for fetch)
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
0xffff), or "imm16" if produced with an extra word operand, in which case the operands
should appear in the machine code in the same order as they appear in the mnemonic.
"r" means one of the pseudo-registers r0 to r255, which is equivalent to an "(imm8h)" argument.
"sp" means r255, i.e. "(0xffff)".

The assembly language should be as orthogonal as possible, with the assembler responsible for
deciding which opcode to use, e.g. "ld x, 5" can be accomplished with both "ld x, imm8l" and
"ld x, imm16".

The instructions listed below are currently aspirational. The list might have to be cut down if
the opcode space is not large enough, and some opcodes might not be implementable without
exceeding 6 T-states. We also might be able to add more if there is opcode space left over.

Where instructions clobber an address in memory (e.g. xor), there should probably be a
default that is normally used, and also some syntax to choose an alternative.

We should make sure that where 2 opcodes can perform an equivalent operation (e.g. "ld x, imm8h"
and "ld x, imm16") that the shorter/faster/better one has the lower opcode, so that the assembler
can know to always choose the smallest opcode that can fulfill an instruction.

In total we currently have 165 opcodes.

### Load/store

42 opcodes:

    ld x, y
    ld y, x
    ld x, imm16
    ld y, imm16
    ld x, (imm16)
    ld y, (imm16)
    ld x, ((imm16))
    ld y, ((imm16))
    ld (x), x
    ld (x), y
    ld (y), x
    ld (y), y
    ld (imm16), x
    ld (imm16), y
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
    ld x, (imm16)++
    ld x, (imm16)--
    ld y, (imm16)++
    ld y, (imm16)--
    ld x, r
    ld y, r
    ld r, x
    ld r, y

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
    jr imm8l # imm8l is a positive offset
    jr imm8l # imm8l is a negative offset

### Arithmetic

20 opcodes:

    inc x
    inc y
    dec x
    dec y
    inc (x)
    inc (y)
    dec (x)
    dec (y)
    inc (imm16)
    dec (imm16)
    add x, x
    add x, y
    add x, imm16
    add x, (imm16)
    add x, (imm16)++
    add x, (imm16)--
    sub x, y
    sub x, (imm16)
    sub x, (imm16)++
    sub x, (imm16)--

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
    and y, imm16
    or x, y
    or y, x
    or x, imm16
    or y, imm16
    not x
    not y
    nand x, y
    nand y, x
    nand x, imm16
    nand y, imm16
    nor x, y
    nor y, x
    nor x, imm16
    nor y, imm16
    xor x, y
    xor y, x
    xor x, imm16
    xor y, imm16

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

    push x
    push y
    push r
    push (x)
    push (y)
    push (r)
    push imm16
    push (imm16)
    pop x
    pop y
    pop r
    pop (x)
    pop (y)
    pop (r)
    pop (imm16)
    ret

The stack pointer is always r255.

"push" post-decrements sp, and "pop" pre-increments it. "ret" is basically just "pop pc".

### Misc

1 opcode:

    nop

## Special instructions

5 opcodes:

    djnz x, imm16
    djnz y, imm16
    djnz (imm16), imm16
    tbsz r, imm16
    sb r254, imm8l

Decrement and jump if not zero. Test bits and skip if zero. Set bits in M[0xfffe].

Also consider making single instructions that do things like:

    ld (imm16), x
    inc (imm16)

or
    ld x, (imm16)
    inc (imm16)

## ALU & Load

We could easily make instructions like:

    ld (imm16), x+y
    ld (imm16), x-y
    ld (imm16), x-1
    ld (imm16), x+1
    ld (imm16), y-1
    ld (imm16), y+1
    ...
    ld x, (imm16)+y
    ld x, (imm16)-y
    ld y, (imm16)+x
    ld y, (imm16)-x
    ld x, (imm16)-1
    ld x, (imm16)+1
    ...

For all of the sensible ALU operations. Just a case of working out which ones are useful

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

## Assembly language

Each line is 1 instruction or 1 assembler directive. Each line optionally begins
with 1 or more labels. The label will refer to the address at which the assembly code
for that point will be loaded into memory.

A "#" character begins a comment that runs to the end of the line.

## Directives

### .def WORD TEXT

Preprocessor macro. All subsequent occurrences of "WORD", at word boundaries, will be
replaced verbatim with the TEXT, with excess spaces stripped.

Example:

    .def SP 0xff00     # stack pointer at 0xff00
    .def SP_x (SP), x

Would transform:

    push (SP), x
    push SP_x

into:

    push (0xff00), x
    push (0xff00), x

### .at VALUE

Set the address at which the next word should be loaded into memory. Use it
to make sure everything is where you expect. No padding words will be output
when ".at" is used before any words have been generated, but subsequently padding
will be generated so that everything is correct relative to the first ".at".

Example:

    .at 0x100
    ld x, (ptr)
    out 0x80, (x)
    ...
    ptr: .word 0x200
    .at 0x200
    .str "Hello, world!"

Padding words with value 0x0000 will be generated between the location of "ptr" and the
"Hello, world!" string, such that the string will be located at address 0x200 if the generated
output is loaded at 0x100 (i.e. the string will be 0x100 words into the generated output).

### .gap VALUE

Leave a gap of N unused words

Example:

    .at 0x200
    buffer: .gap 256

Creates a 256-byte buffer at address 0x200, with the label "buffer".

### .str "TEXT"

Generate the given string, with 1 character per word (i.e. the upper 8 bits of each value is
always zeroes).

Example:

    msg: .str "Hello, world!\n"

### .pstr "TEXT"

Generates a "packed string", with 2 characters per word, with the first character of the string in
the upper 8 bits of the first word (i.e. big endian).

Example:

    msg: .pstr "Hello, world!\n";

### .word VALUE

Generate a literal word.

Example:

    value: .word 0x1010

Will generate a word containing 0x1010, whose address will be available in the "value" label.

## Labels

Labels and macro names must match

    /^[a-zA-Z_][a-zA-Z_0-9]*$/

i.e. begin with uppercase, lowercase, or underscore, and then contain only uppercase, lowercase, underscore, and numeric.

## Values

Values are decimal by default.

Hex values are written starting with "0x", and binary values starting with "0b".

All numeric values are 16 bits long, but in special cases the assembler may put them in an imm8l
or imm8h where possible.

Inside strings, the following escape sequences are available:

* "\\" - literal backslash
* "\r" - 0x0d value
* "\n" - 0x0a value
* "\t" - 0x09 value
* "\[" - 0x1b value
* "\x.." - literal hexadecimal 8-bit value
* "\w...." - literal hexadecimal 16-bit value (not allowed in packed strings)
* "\0" - literal 0, same as "\x00"

Example values:

    .word 100
    .word 0x123
    .word 0b1010111100000101
    .str "ABC\wffffDEFG\r\n\0"
    .pstr "ABCD\x1b\n\0"
