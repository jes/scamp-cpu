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

I wanted to "hide" the Y register, so that it can always be clobbered without needing
an excuse. And then the opcode space saved by removing instructions that store to Y can for
example be used for instructions that instead fetch indirect values into Y. Unfortunately,
the implementation of the `xor` instruction only fits within 8 cycles if the operands are the
X and Y registers. That means we also need instructions to load the Y register, and need to
document what clobbers it. It's a bit inelegant, but mostly fine. Most code is written as if
the Y register did not exist.

It is a point of philosophy in writing the microcode that instructions will clobber the
Y register in preference to the X register where there is a free choice.

We can consider the `i8h` addresses (0xff00 .. 0xffff) to be pseudo-registers, and make "r0" .. "r255" syntax for
addressing them. So instead of "add x, (0xff00)", you can write "add x, r0" and
it all becomes much easier to read. Where the same instruction syntax exists with both an
`(i8h)` and `(i16)` argument, the assembler should (normally?) pick the `i8h` version where possible.

## Instruction table

The instruction set is documented in `doc/table.html`.

It might be nice to add the hex representation of the microcode.

## Function calls

Function arguments are passed on the stack, in an order not yet determined. Return address is passed
in r254. Nested function calls (which is almost all of them) need to save r254.

There are 2 obvious ways to collect arguments:

    func:
        pop x        # 7 cycles, 1 word
        ld r1, x     # 4 cycles, 1 word
        pop x        # 7 cycles, 1 word
        ld r2, x     # 4 cycles, 1 word
        ...
        ret          # 4 cycles, 1 word

and

    func:
        ld x, sp     # 4 cycles, 1 word
        ld r1, 1(x)  # 8 cycles, 2 words
        ld r2, 2(x)  # 8 cycles, 2 words
        ...
        ret 2        # 8 cycles, 1 word

So for *n* arguments:
 - The `pop` method uses *11n+4* clock cycles and *2n+1* words.
 - The `ld r, i16(x)` method uses *8n+12* clock cycles and *2n+2* words.

Optimising for memory:
 - Always use `pop`, it is always 1 word shorter

Optimising for speed:
 - Use `pop` for *n<=2* and `ld r, i16(x)` otherwise

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

This is not implemented in ASM-in-SLANG, simply because `slangc` does not use it.

Example:

    msg: .str "Hello, world!\n"

### .word VALUE

Generate a literal word.

Example:

    value: .word 0x1010

Will generate a word containing 0x1010, whose address will be available in the "value" label.

### .blob FILE

Load raw binary data from `FILE`. This directive is only implemented in the ASM-in-SLANG
assembler, not in the Perl version. Not for any particular reason, other than that the only
use for it is to support a primitive form of "linking" to reduce compile times by pre-compiling
the libraries into a blob.

Example:

    .blob /lib/lib.o

## Labels

Labels and macro names must match

    /^[a-zA-Z_][a-zA-Z_0-9]*$/

i.e. begin with uppercase, lowercase, or underscore, and then contain only uppercase, lowercase, underscore, and numeric.

## Values

Values are decimal by default.

Hex values are written starting with "0x".

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
    .str "ABC\wffffDEFG\r\n\0"
