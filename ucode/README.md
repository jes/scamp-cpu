# Microcode

Microcode will be stored in a ROM.

The immediate small-valued constant can be placed on the bus either as 00xx or FFxx
using the IOL and IOH control bits respectively.

I was thinking we could dedicate the top 256 (or whatever) bytes of RAM to
act as "registers", which could be conveniently accessed with a single opcode by
loading the memory into Y, e.g.:

    1. IOH AI (put FFxx into MAR)
    2. MO  YI (put RAM contents into Y register)

The purpose of this document is to crystalise exactly what things are required from
the instruction set so that I can be confident of things like:

 - how the instruction set is going to be laid out
 - how many control bits are required
 - how many T-states are required
 - what kind of decoding logic is required

It might be interesting if some of the opcode space were dedicated to a "decode RAM" instead
of a "decode ROM", so that extra microcoded instructions can be created at runtime.

## Addressing

Upper 8 bits indicate the opcode, lower 3 bits indicate the T-state.

9 bits of address space = 512 words. Each address contains 16 bits of microcode (spread
over 2x 8-bit ROM chips).

Each microinstruction just switches on/off the CPU's control bits. Not all bits
can be on at the same time, because this would be nonsensical at best, and cause
bus fighting at worst.

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

Provisionally, the microcode instruction word encodes the control bits as follows:

|   Bit | Meaning |
| :---- | :------ |
|    15 | EO |
|    14 | EO ? EX : bus_out[2] |
|    13 | EO ? NX : bus_out[1] |
|    12 | EO ? EY : bus_out[0] |
|    11 | EO ? NY : RT |
|    10 | EO ? F  : P+ |
|     9 | EO ? NO : (unused) |
|     8 | EO ? CE : (unused) |
|     7 | bus_in[2] |
|     6 | bus_in[1] |
|     5 | bus_in[0] |
|     4 | JZ |
|     3 | JGT |
|     2 | JLT |
|     1 | JC |
|     0 | (unused) |

This uses 14 bits, leaving 1 bit spare to add an extra ALU flag (e.g. 2 more functions),
and 1 more bit unused.
We could use an unused bit to drive P+ directly so that it can be used concurrently with the
ALU, in case that is ever useful.

We also have 1 bit spare that we can toggle when !EO.

We might consider adding a bit to disable carry input to the ALU.

## Extensibility

In addition to the 2 unused bits, and the spare but when !EO,
bus_out/bus_in have some decodings which are currently unused. In principle, as long as these unused signals are routed
alongside everything else on the backplane, it would be possible to extend the CPU with an extra register (e.g. a
dedicated stack pointer) or other modules, at a later date, by just plugging the new module into the backplane
and writing microcode to make use of it.
