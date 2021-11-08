# Supporting constants in the compiler

## Constant expressions

Currently the different types of constant expression are:

 - numeric literal: evaluates to its numeric value
 - string literal: evaluates to the address of the first character
 - array literal: evaluates to the address of the first element
 - function declaration: evaluates to the address of the function entry point
 - `asm { }` block: evaluates to the address at which the code is placed

We don't yet recognise expressions like `1+2` as being constant, but maybe we could.

We want to do several types of things with constant expressions.

## `const` declarations

When a variable is declared `const`, e.g.:

    const x = 5;

Then we want to put an entry in the current scope noting that `x` is a constant value 5, rather
than a global. We might want to support taking the address of `x` with `&x` - or maybe not? If we do,
then we need to allocate some static storage for it.

We don't want to support direct assignment to any variable declared `const` (other than in its
initialisation).

We want to support constants that are a *label* rather than a number. For example, in:

    const s = "hello";

We don't know at compile-time what address the string "hello" will be placed at, but we do allocate
a label for it, so as long as our symbol table knows the label that the constant `s` refers to, then
it can all be compiled perfectly fine.

We could make the compiler ambivalent about whether a given constant is a label or a number by
stringifying the numbers. So our `x` would get a symbol table entrying saying `x` is "5", while
our `s` would get an entry saying `s` is "L123", for example. When we generate assembly code,
we'd get things like:

    ld x, 5

and

    ld x, L123

Both of which will compile perfectly happily.

We need to be careful with `push`, however, because while `push i8l` exists, `push i16` does not. So
`push 5` will compile just fine, but `push L123` will not. From this perspective, we might want to
keep track of whether a given constant is a number or a label, so that we can special-case the small
numbers. Or we might want to ignore that, and accept that we'll generate code like:

    ld x, 5
    push x

Even where just `push 5` would do.

### Initialisation

Perhaps `Declaration` should be updated to handle `const` in addition to `var`? Or perhaps we
should add a `ConstDeclaration` that handles `const`s separately?

Currently we use `genliteral()` to parse constant values, which currently outputs the code to
push the constant. We would instead want to split up the parsing and code generation for constants,
so that we can parse a constant for initialising a `const`, and then stash it in the symbol table
rather than generating code to push it.

### Usage

In `pushvar`, if the name is a constant, we should push the value (or label) instead of looking up
the variable, dereferencing it, and pushing its content.

In `Constant`, we could look for an `Identifier`, and if we find one check that it's a constant,
and push its value if so.

## Constant intialisation of global `var`s

The other thing we want to do is optimise the initialisation of globals with constant expressions.

In code like:

    var x = 5;

at global scope, instead of initialising `x` like:

    push 5
    pop x
    ld (_x), x
    jmp l__1
    _x: .word 0
    l__1:
    (7 words)

we should initialise `x` with the constant value in the first place:

    jmp l__1
    _x: .word 5
    l__1:
    (3 words)

And possibly we could even put globals all together at the end of the program, like we currently do
with strings, and save all the jumping over them, for just 1 word for each global that has constant
initialisation?
