# Compiling

This document is about compiling software within **SCAMP/os**. For more general
thoughts on the compiler, see COMPILER.md instead.

## Basic usage

    $ kilo foo.sl
    $ slc < foo.sl > foo
    $ ./foo

## Linking

To keep the library blob small, the bigint and fixed-point code is not included
by default. Ideally we'd be able to link against arbitrary combinations of
libraries, but for now the compiler only supports a single library blob, which
means if we want to support different options then we need to have a
pre-compiled blob for each possible combination.

If you need to use either the `fixed` or `bigint` libraries, then you need to
tell `slc` to select the appropriate library blob by passing it a blob name in
`-l`. Example:

    $ slc -lfixed < foo.sl > foo

Available blobs are:

             - normal library
    fixed    - normal library, plus `fixed.sl`
    bigint   - normal library, plus `bigint.sl`
    bigfix   - normal library, plus both of `fixed.sl` and `bigint.sl`

For more explanation of how linking works, see LINKING.md.

## Workings

`slc` is the compiler driver. It delegates to `slangc` to turn source code into
assembly language, and `asm` to turn assembly language into machine code. It also
brings in pre-packaged assembly language source for the "head" and "foot" of
the program, from `/lib/head.s` and `/lib/foot.s`, and library definitions
from `/lib/lib.s` (or `/lib/libfoo.s` in the case of `-lfoo`).

`head.s` is responsible for setting the start address of the program code
to 0x100, initialising the stack pointer, allocating space to store the `TOP`
variable, and defining constants for system call vectors.

`foot.s` is responsible for calling `exit(0)` after the program finishes,
and defining a constant for the initial value of `TOP`.

`lib.s` is responsible for including the library blob from `/lib/lib.o`, and
defining the addresses of the symbols exposed by the library.
