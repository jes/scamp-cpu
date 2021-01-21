# Instruction Set Architecture

Each word is 16 bits wide.

The high 8 bits of the opcode select the actual opcode. The low 8 bits are available
for an immediate small-valued constant. XXX: We could change this to 9/7 or 10/6 if
we need more opcode space.

The immediate small-valued constant can be placed on the bus either as 00xx or FFxx
using the IOL and IOH control bits respectively.

I was thinking we could dedicate the top 256 (or whatever) bytes of RAM to
act as "registers", which could be conveniently accessed with a single opcode by
loading the memory into Y, e.g.:
    1. IOH MI (put FFxx into MAR)
    2. RO  YI (put RAM contents into Y register)

The purpose of this document is to crystalise exactly what things are required from
the instruction set so that I can be confident of things like:

 - how the instruction set is going to be laid out
 - how many control bits are required
 - how many T-states are required
 - what kind of decoding logic is required

It might be interesting if some of the opcode space were dedicated to a "decode RAM" instead
of a "decode ROM", so that extra microcoded instructions can be created at runtime.

## Decoding

Every instruction implicitly starts with microcode of:

    PO MI     load address from program counter
    RO II P+  load RAM into instruction register, increment PC

So I don't think we need to include that in the microcode. We just do that for 2 cycles,
and then start the "real" T-state counter.

We only ever want one module driving the bus at a time, so all of the xO microcodes can
be encoded into fewer bits (see control.v). Similarly, I *think* we only want one module
reading from the bus at a time, so it's probably worth encoding the xI microcodes the
same way.

Jump flags are not quite worth encoding, we'd want 4 bits either way, for JC, JZ, JGT, JLT.

Other bits we want to encode:
 * RT         - reset T-state (basically, finish this instruction)
 * P+         - increment PC (called PA in Verilog where P+ isn't allowed)
 * ALU flags  - naturally 6; we might want to add a 7th to gain more functions, but in any case we should be encode these into fewer bits
 * IO enable  - speak to IO instead of RAM - only applicable with RI or RO?

So currently I think the microcode will require:

      3 (bus_out)
    + 3 (bus_in)
    + 3 (RT, P+, IO enable)
    + 6 (ALU flags)
    + 4 (jump flags)
    = 19 bits

It would be good to save 3 more bits, to fit in 16 bits and therefore 2 ROM chips instead of 3.

RT only ever occurs on its own, because it immediately triggers the start of the next instruction,
without waiting for a clock tick. We could use one of the spare decodings of bus_out or bus_in
to generate RT, bringing it down to 18 bits.

We can definitely encode the ALU flags in 5 bits instead of 6. 17 bits.
If we throw away 2 of the functions from this table: https://img.jes.xxx/3151 then we only
need 4 bits to set ALU flags, and that brings us down to 16 already.

We might also observe that some combinations of xI and xO don't make any sense. For example,
the identity assignment doesn't seem useful (i.e. we never want `XO XI`). We are also unlikely
to be writing to the instruction register from anywhere other than RAM, for what it's worth.

We currently have 7 possibilities for bus_out and 5 for bus_in, 7*5 = 35, if we throw away
the identity assignments then we save 4, leaving us with 31 possibilities, and still 1
left over to generate RT, so we could save another bit there compared to using 3 bits for each
of bus_out and bus_in. And we haven't even got rid of stupid loads to the IR like `XO II`.

In general each step of microcode assumes the form:
    - choose a module to write to the bus
    - choose a module to read from the bus
    - choose ALU flags
    - choose whether to increment the PC
    - choose jump flags

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

XXX: We could add an extra control bit to the ALU to allow it to
select from XOR and 1 other function as well as ADD and AND.

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
    2. PO MI 
    3. JGT JLZ

Add 2 consecutive numbers together from an immediate address operand and store it in a 2nd
immediate address operand:

    [opcode] [address of first number] [address of result]

    1. PO MI          load address from PC (address of first number)
    2. RO MI          load address from RAM
    3. RO YI P+       load RAM contents into Y, increment PC
    4. YO MI          load address from Y
    5. RO XI P+       load RAM into X, increment PC
    6. ALU=Y+1 EO MI  load Y+1 into address
    7. RO YI          load RAM into Y
    8. ALU=X+Y EO AI  load X+Y into X
    9. PO MI          load address from PC (address of result)
   10. RO MI          load address from RAM
   11. XO RI          store X in address from PC

11 microcode steps is probably pushing it a bit. It would be good if we could fit everything
in 8, because then we only need 3 bits for T-state. Maybe 4 would be fine.
