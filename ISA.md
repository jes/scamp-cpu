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

## Control bits

| Name | Meaning |
| :--- | :------ |
| PO   | Program counter output to bus |
| IOH  | Immediate small value from instruction register output to bus with high bits set to 1 |
| IOL  | Immediate small value from instrugtion register output to bus with high bits set to 0 |
| RO   | RAM output to bus |
| XO   | X register output to bus |
| YO   | Y register output to bus |
| DO   | I/O device output to bus |
| EO   | ALU output to bus |
| :--- | :------ |
| MI   | Memory address register input from bus |
| RI   | RAM input from bus |
| II   | Instruction register input from bus |
| XI   | X register input from bus |
| YI   | Y register input from bus |
| DI   | I/O device input from bus |
| :--- | :------ |
| P+   | increment program counter |
| RT   | reset T-state counter |
| JC   | jump if carry |
| JZ   | jump if zero |
| JGT  | jump if greater than zero |
| JLT  | jump if less than zero |
| :--- | :------ |
| EX   | ALU flag: enable X (don't set X to 0) |
| NX   | ALU flag: invert bits of X |
| EY   | ALU flag: enable Y (don't set Y to 0) |
| NY   | ALU flag: invert bits of Y |
| F    | ALU flag: function select (0 for '&', 1 for '+') |
| NO   | ALU Flag: invert bits of output |

## Decoding

Every instruction implicitly starts with microcode of:

    PO MI     load address from program counter
    RO II P+  load RAM into instruction register, increment PC

So I don't think we need to include that in the microcode. We just do that for 2 cycles,
and then start the "real" T-state counter.

In general each step of microcode assumes the form:
    - choose a module to write to the bus (xO)
    - choose a module to read from the bus (xI)
    - choose ALU flags
    - choose whether to increment the PC (P+)
    - choose jump flags
    - choose whether to reset the T-state counter (RT)

We only ever want one module driving the bus at a time, so all of the xO microcodes can
be encoded into fewer bits (see control.v). Similarly, I *think* we only want one module
reading from the bus at a time, so it's probably worth encoding the xI microcodes the
same way.

Jump flags are not quite worth encoding, we'd want 4 bits either way, for JC, JZ, JGT, JLT.

Other bits we want to encode:
 * RT         - reset T-state (basically, finish this instruction)
 * P+         - increment PC (called PA in Verilog where P+ isn't allowed)
 * ALU flags  - naturally 6; we might want to add a 7th to gain more functions, but in any case we should be encode these into fewer bits

So currently I think the microcode will require:

      3 (bus_out)
    + 3 (bus_in)
    + 3 (RT, P+, IO enable)
    + 6 (ALU flags)
    + 4 (jump flags)
    = 19 bits

Too large to fit on 2x 8-bit ROM chips.

We only ever want ALU flags when bus_out == EO, so we can move EO out of bus_out,
and overlap bus_out with ALU flags. ALU flags are longer than necessary, so we'll
also use these bits to encode RT and P+.

      1 (EO)
    + 6 (ALU flags and bus_out/RT/P+)
    + 3 (bus_in)
    + 4 (jump flags)
    = 14 bits

Leaving 1 bit spare to add an extra ALU flag (e.g. 2 more functions), and 1 more bit unused.
We could use an unused bit to drive P+ directly so that it can be used concurrently with the
ALU, in case that is ever useful.

We also have 1 bit spare that we can toggle when !EO.

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
    2. PO MI            load address from PC (jump target)
    3. RO JGT JLZ P+    jump to address from RAM if X-1 != 0, else inc PC

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
