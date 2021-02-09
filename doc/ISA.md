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

Apart from instructions that do specifically require an i8h, we should flesh out the instruction
set with all immediate values as i16, and then add optimised versions later for common
operations.

We could consider the i8h addresses to be "registers", and make a "r0" .. "r255" syntax for
addressing them. So then instead of "add x, (0xff00)", you'd be able to write "add x, r0" and
it all becomes much easier to read. It also clarifies the difference between the (i16) and (i8h)
addressing modes, and we could potentially make the assembler warn if you use a (i16) that is in
the top page.

## Instruction table

The instruction set is documented in table.html.

It might be nice to add the hex representation of the microcode.

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

All numeric values are 16 bits long, but in special cases the assembler may put them in an i8l
or i8h where possible.

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
