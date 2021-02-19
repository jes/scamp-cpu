# SCAMP CPU

I want to make a CPU out of TTL chips.

This repo is likely to be a loosely-connected collection of Verilog source, KiCad files, text notes,
and software.

It's called "SCAMP" which means something like "Simple Computing and Arithmetic Microcoded Processor".

## Plan

1. Create the CPU in Verilog, with a testbench for each part.
2. Replace the raw Verilog with Verilog that only uses 74xx-compatible primitives
   (e.g. https://github.com/TimRudy/ice-chips-verilog), but still passes the testbenches.
3. Convert the 74xx-Verilog into KiCad schematics.
4. Build the CPU

It is likely that steps 1 to 3 will go through several iterations while I figure out how
the CPU is actually going to work, but hopefully step 4 will only happen once. It is likely
that if step 4 needs to happen substantially more than once that it will never get completed.

## Current status

I've finished writing Verilog and think I've settled on the overall CPU architecture (see diagram below).

I'm quite happy with the instruction set, see [doc/table.html](doc/table.html), available online at https://incoherency.co.uk/interest/table.html - but the instruction set is implemented with microcode, so changes are relatively cheap.

I have some blog posts here: https://incoherency.co.uk/blog/tags/cpu.html

I have created an emulator (see in `emulator/`) and a compiler (`compiler/`). Although there is still useful
work to be done on the compiler, it can now compile itself from within the emulator, provided the `include`
lines are preprocessed outside, although it's very tight on memory usage - only about 1K spare.

I'm currently designing the PCBs:

 - [x] ALU
 - [x] Memory
 - [x] Instruction/control
 - [x] Backplane
 - [ ] Clock
 - [ ] Serial port
 - [ ] Storage

Other work includes:

 - [x] get the PCBs manufactured
 - [ ] work out how to interface with storage and serial
 - [ ] assemble the computer inside a convenient case
 - [ ] write the bootloader ROM
 - [ ] write the "kernel"
 - [x] write a compiler
 - [ ] write system utilities
 - [ ] write an editor
 - [ ] make it self-host

## Architecture

It is a 16-bit CPU. The bus is 16-bit, registers are 16-bit, addresses are 16-bit, and memory contents are
16-bit. The upper 8 bits of an instruction select the opcode, and the lower 8 bits are available
for small immediate values.

Here is a diagram of the architecture I currently have in mind:

![](doc/architecture.png)

For more information, see [doc/UCODE.md](doc/UCODE.md) and [doc/ISA.md](doc/ISA.md).

## Resources

I thoroughly recommend the Nand2Tetris course. https://nand2tetris.org/

If you want to do the exercises from Nand2Tetris without learning what a hardware-description language
is, and without going through all the lectures, you can play https://nandgame.com/

Ben Eater's videos on 8-bit CPU design are excellent and heavily influenced
the design of my CPU.

I plan to go through the [YouTube playlist](https://www.youtube.com/playlist?list=PLOech0kWpH8-njQpmSNGSiQBPUvl8v3IM) for Nicolas Laurent's [compiler class](https://norswap.com/compilers/)

## Contact

I can't imagine why it would, but if anything in this repo causes you to want to communicate with
the person who wrote it, you can email me:

    James Stanley <james@incoherency.co.uk>

or read my blog:

    https://incoherency.co.uk/
