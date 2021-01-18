# TTL CPU

I want to make a CPU out of discrete logic chips.

This repo is likely to be a loosely-connected collection of Verilog source, KiCad files, text notes,
and software.

## Plan

1. Create the CPU in Verilog, with a testbench for each part.
2. Replace the raw Verilog with Verilog that only uses 74xx-compatible primitives
   (e.g. https://github.com/TimRudy/ice-chips-verilog), but still passes the testbenches.
3. Convert the 74xx-Verilog into KiCad schematics.
4. Build the CPU

It is likely that steps 1 to 3 will go through several iterations while I figure out how
the CPU is actually going to work, but hopefully step 4 will only happen once. It is likely
that if step 4 needs to happen substantially more than once that it will never get completed.

## Resources

I thoroughly recommend the Nand2Tetris course. https://nand2tetris.org/

If you want to do the exercises from Nand2Tetris without learning what a hardware-description language
is, and without going through all the lectures, you can play https://nandgame.com/

## Contact

I can't imagine why it would, but if anything in this repo causes you to want to communicate with
the person who wrote it, you can email me:

    James Stanley <james@incoherency.co.uk>

or read my blog:

    https://incoherency.co.uk/
