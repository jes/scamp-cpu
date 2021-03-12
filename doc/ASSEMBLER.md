# Assembler

(This is about the assembler written in SLANG, not the one written in Perl).

The assembler generates code in memory and then writes it to stdout when done.

When an instruction needs to generate a word using a label, a pointer
to that address is added to a `grarr` for the undefined label. Once all the code
is generated, those pointers are resolved to addresses and then the output is
written.

The parser uses the recursive descent parsing framework. The code to turn
instructions into code is generated from `instructions.json` on a "modern"
computer using `mk-asm-parser`.
