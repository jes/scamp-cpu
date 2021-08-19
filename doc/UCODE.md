# Microcode

Microcode is stored in a ROM.

The immediate small-valued constant, from the low 8 bits of the instruction, can
be placed on the bus either as 00xx or FFxx using the IOL and IOH control bits respectively.

The top 256 words of RAM are available to act as "pseudo-registers", which can be
conveniently accessed with a single-word instruction, e.g.:

    1. IOH AI (put FFxx into MAR)
    2. MO  YI (put RAM contents into Y register)

The T-state counter (or "sequencer") counts from 0 to 7 and then wraps. The first 2 states of every instruction
are required to be:

    1. PO AI
    2. MO II P+

In order to fetch the next instruction. These are provided implicitly by the microassembler (see
[ucode/uasm](ucode/uasm)).

## Addressing

The upper 8 bits of the microcode address indicate the opcode, lower 3 bits indicate the T-state.

11 bits of address space = 2048 words. Each address contains 16 bits of microcode (spread
over 2x 8-bit ROM chips).

Each microinstruction just switches on/off the CPU's control bits. Not all bits
can be on at the same time, because this would be nonsensical at best, and cause
bus fighting at worst.

## Microassembler syntax

Comments begin with "#" and run to the end of the line.
All excess whitespace is ignored.

Each instruction begins with a name for the instruction. This name sets the syntax needed to use
this instruction via the assembler, and is shown in the cheatsheet.
The name is followed by a colon, optionally followed by the number for the opcode. These
are represented in hex and, where present, are required to count up sequentially starting from 0. Example:

    clc: 0a    # The 'clc' instruction has opcode 0x0a

A comment on the same line as the instruction name turns into the text
that eventually appears at the bottom of the "hover" box on the instruction set cheatsheet.

A line in the microcde that says " # clobbers: ..." turns into an indication in the cheatsheet
that that instruction clobbers the given register. This is only required where it can't be
worked out automatically by `mk-table-html`, e.g. for r254.

Each microinstruction consists of several control bits, e.g.

    PO AI

Turns on the "PO" (program counter output to bus) and "AI" (address register input from bus)
bits, with the result that the address register takes the value from the program counter.

The "xO" and "xI" bits are encoded into the microinstruction, see the "Decoding" section,
so only one "xO" and one "xI" may be present at a time. The microassembler enforces this.

When not specifying any "xO", ALU operations become available. Specify ALU operations in
relatively-natural syntax, e.g.:

    X+Y     # compute X+Y
    X       # pass X straight through the ALU
    ~(X|Y)  # compute X nor Y

This syntactic sugar automatically enables "EO" and the relevant function selection flags, although
this can be done manually. The above examples are equivalent to:

    EO EX EY F      # compute X+Y
    EO EX F         # pass X straight through the ALU
    EO EX NX EY NY  # compute X nor Y

There is also syntactic sugar for "JNZ" which is equivalent to "JLT JGT", and for "JMP"
which is equivalent to "JZ JLT JGT".

Other than that, the microinstruction flags available should exactly match the control bits
documented below. The microassembler should give a warning or error message if you do
something wrong.

## Control bits

| Name | Meaning |
| :--- | :------ |
| PO   | Program counter output to bus |
| IOH  | Immediate small value from instruction register output to bus with high bits set to 1 |
| IOL  | Immediate small value from instrugtion register output to bus with high bits set to 0 |
| MO   | Memory output to bus |
| DO   | I/O device output to bus |
| EO   | ALU output to bus |
| :--- | :------ |
| AI   | Address register input from bus |
| MI   | Memory input from bus |
| II   | Instruction register input from bus |
| XI   | X register input from bus |
| YI   | Y register input from bus |
| DI   | I/O device input from bus |
| :--- | :------ |
| P+   | increment program counter |
| RT   | reset T-state counter |
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

    PO AI     load address from program counter
    MO II P+  load RAM into instruction register, increment PC

So I don't think we need to include that in the microcode. We could just do that for 2 cycles,
and then start the "real" T-state counter. Maybe it's easier to waste decode ROM space on it
than to make hardware logic to decide?

In general each step of microcode assumes the form:
    - choose a module to write to the bus (xO)
    - choose a module to read from the bus (xI)
    - choose ALU flags
    - choose whether to increment the PC (P+)
    - choose jump flags
    - choose whether to reset the T-state counter (RT)

The microcode instruction word encodes the control bits as follows:

|   Bit | Meaning |
| :---- | :------ |
|    15 | !EO |
|    14 | EO ? EX : bus_out[2] |
|    13 | EO ? NX : bus_out[1] |
|    12 | EO ? EY : bus_out[0] |
|    11 | EO ? NY : (unused) |
|    10 | EO ? F  : P+ |
|     9 | EO ? NO : (unused) |
|     8 | DO |
|     7 | bus_in[2] |
|     6 | bus_in[1] |
|     5 | bus_in[0] |
|     4 | JZ |
|     3 | JGT |
|     2 | JLT |
|     1 | RT |
|     0 | DI |

We still have 2 bits spare that we can toggle when !EO.

Originally RT was in one of the "(unused)" slots conditional on !EO, and DO/DI were decoded
from bus_out/bus_in. The problem is that these signals can cause side effects without
a clock edge required, so they are moved out so that they can't "glitch" during the gate delay
of the decoding logic.

## Extensibility

In addition to the 2 unused bits, and the spare bit when !EO,
bus_out/bus_in have some decodings which are currently unused. In principle, as long as these unused signals are routed
alongside everything else on the backplane, it would be possible to extend the CPU with an extra register (e.g. a
dedicated stack pointer) or other modules, at a later date, by just plugging the new module into the backplane
and writing microcode to make use of it.

## Tricks

### Conditionally skip the next instruction

The obvious way to conditionally skip the next instruction is to generate the address to jump
to, stash it somewhere, perform the operation that will set the condition flags, and then
ask for a conditional jump.

With the restriction that the instruction to skip is only 1 word, we can instead perform
the comparison operation, and then:

    PO JNZ P+

In this case using JNZ for the conditional jump. PO means the current value of the program
counter will be on the bus, which currently points to the next instruction. If the result
of the comparison was not zero, then JNZ makes the PC load its value from the bus, meaning
it doesn't change. Otherwise, P+ means the PC is incremented, which skips it past the next
instruction.

If the next instruction is going to be 2 words, then:

    PO JNZ P+
    PO JNZ P+

will achieve the same goal.

I can't think of a general way to skip the next instruction without knowing its length.

### Microcode RAM

It would be interesting if some of the opcode space were dedicated to a "decode RAM" instead
of a "decode ROM", so that extra microcoded instructions can be created at runtime. I'm not
going to do it for this machine, because although it would be easy to implement, it sounds like
it makes for hard-to-debug programs, which I'll have enough of already.

### Microjump

The microcode doesn't provide a mechanism to jump to a different microinstruction, but we could
do it anyway. Something like:

    XO II

Will put the X register into the instruction register, and will proceed from the next T state from
the instruction indexed by the high byte of the X register.

#### Longer instructions

If we have up to 2 instructions that need more than 6 cycles, then we can make their T7 microcode
say "-1 II" or "0 II". This will then proceed from T0 of instruction 255 or 0, respectively. If we
make sure that T0 of these instructions does *not* fetch the next instruction from memory, then we
get 8 extra cycles for our useful instruction.

One problem is that we would get stuck in the 0 or 255 instruction since the first 2 T-states are not
the standard fetch cycle.

I wonder if it would work to make the 0 instruction do something like:

    [ 6 useful cycles ]
    PO AI
    MO II

It would then load the next instruction. With the next instruction loaded, we'd then run that instruction's
T0 and T1 microcode, which would repeat "PO AI" and "MO II", but now with P+, and carry on as normal, at
the cost of 2 "wasted" cycles.

In total we'd get 5 extra cycles to use for up to 2 long instructions: we lose 1 cycle on the "-1 II"
step, gain 8 for the second opcode, and lose 2 more for getting back out of our instruction.

Long instructions that we might want to implement include:

 * xor x, ... - we could implement "xor x, y" in opcode 0 or 255, and the "ld x, ..." in the first 4 cycles at different opcodes, followed by "0 II" to get to the actual xor step?
 * push r
 * push i16
 * tbsz but skips 2 words instead of just 1
 * shl3 r

Possibly it is better to just keep instructions small enough to fit into 6 T-states.

But being able to implement "xor x, r" etc. would mean we could finally stop exposing the Y register.

#### Conditional microjump

There isn't an obvious general-case way to do a useful conditional microjump, but in special cases (e.g.
tbsz comes to mind), we could arrange for the X register to contain 0 in the "want the jump" case, and
some other value otherwise, for example:

    7. X&Y II

In the event that "X&Y" is 0, we'll next execute instruction 0 at T0, which could do some useful work. In other
cases we'll jump to some non-0 instruction, which will have the normal "fetch" microcode at T0, and we have effectively
microjumped to address 0, conditional on the result of some expression.
