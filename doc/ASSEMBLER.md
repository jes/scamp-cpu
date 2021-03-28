# Assembler

(This is about the assembler written in SLANG, not the one written in Perl).

The assembler writes code into a file, and writes unresolved symbol addresses to
a different file. Once the first pass is finished, the generated code is re-processed,
with unresolved symbols now resolved on the second pass.

The parser uses the recursive descent parsing framework. The code to turn
instructions into code is generated from `instructions.json` on a "modern"
computer using `mk-asm-parser`.
