# Compiler

At some point I'll want a compiler that targets SCAMP and runs on SCAMP.

It should either be self-hosting or implemented in assembly language, so that the compiler can (at least
in principle) be developed completely inside SCAMP.

I'm not really picky about the syntax, but I definitely want pointers, pointer arithmetic, function pointers, and
inline assembly code.

Potential sources of inspiration include:

 - [Small-C](https://en.wikipedia.org/wiki/Small-C)
 - [Cowgol](http://cowlark.com/cowgol/)
 - [PL/0](https://en.wikipedia.org/wiki/PL/0)
 - [KenCC](http://gsoc.cat-v.org/projects/kencc/) - although this might be too big
 - [Nicolas Laurent's compiler class](https://norswap.com/compilers/)

## Purposes

There are really 3 types of program I want to write with the compiler:

 - the compiler itself (potentially)
 - system utilities (shell, text editor, grep, ls, ...)
 - Advent of Code problems

Advent of Code problems often benefit from bignums and recursion. So recursive function calls are definitely
something I'd want the language to support. Bignum functions should probably go in the standard library, but (eventually)
with optimised assembly language implementations.

## Types

SCAMP only has native support for 16-bit values (both values and addresses are 16-bit). We could
make a language that only has one actual data type, and make pointers be a matter of syntax rather than
a type. That gets us pointer arithmetic for free. We could imagine something like:

    var x = 100;
    var y = &x;
    var z;

    x = 5;
    z = *y + 10; // z == 15, because *y==x

(Although I'm not committing to using "*" as the pointer dereference operator, because of the obvious collision
with multiplication).

### Strings

A string literal will evaluate to the address of the first character. I'm not sure if we'd want to support "packed strings" as well,
which use memory a bit more efficiently? Probably best to keep it simple and just waste the upper byte.

### Functions

Since we only support one type, we don't *really* need to know function signatures. Passing arguments to a function
just means pushing them onto the stack in the correct order. It might be helpful to have compile-time checking that
the number of arguments is correct (not least because the calling convention involves the caller popping the arguments off,
which will likely cause confusing and hard-to-understand bugs if the wrong number is pushed). Maybe we could have the "non-optimised"
compilation mode always append a known sentinel value to the stack, and have each function check for the presence of the
sentinel (and then overwrite it), as a runtime check that the function has been passed the correct number of arguments.

So *if* we accept calling functions without knowing the signature, then this leads very easily to function pointers: just put
function names in the main symbol table, and when you assign a function name to something you get the address of the function:

    func double(x) {
        return x+x;
    }

    var f = double;
    f(10); // == 20

We could abolish normal function definitions and *only* support anonymous functions:

    var double = func(x) {
        return x+x;
    };

And then passing function pointers around becomes much more intuitive, even though it's actually equivalent. Not sure which is better.
The "anonymous functions" version comes with an extra level of indirection on every single function call, which is potentially not
worth it.

### Arrays

There are really 2 parts to arrays: declaration and usage. In C there is a distinction between a pointer (which stores an address) and an array (which
stores values, but evaluates to the address of the first value). I think we could abolish this distinction, and essentially make all arrays anonymous,
so the only way to use them is with pointers. So declaration might be something like:

    var arr = array[20];

In fact, this almost looks like `malloc()`. We could just not have *any* special syntax for array declaration, and use something like `malloc()`/`alloca()`
to allocate arrays. The downside is we don't get to initialise the contents at compile time. Hmm.

We would support pointer-arithmetic-style usage of arrays for free:

    *(arr + 15) = 6;

But could probably easily add "array-like" syntactic sugar for the same:

    arr[15] = 6;

## Operators

I don't know if we want/need to support anything that the CPU doesn't natively support. In particular multiplication
and division come to mind here. Is it better to implement them as special-cased operators that compile to a function call,
or to not provide them at all and make the function call explicit? Or should we just add special syntax for defining
custom operators, and use the standard library to provide defaults for multiplication and division?

## Compiler output

I envisage the compiler outputting assembly language code, which is then assembled by a separate assembler program. I
don't think I'd bother with writing a linker, at least not at first. I maybe don't mind if the standard library is compiled
and assembled separately every time. We might be able to short-circuit compilation of unused functions, which would save
a lot of time. Or at least split the standard library across multiple files and only include the relevant ones in each
program.

## Calling convention

I really like `printf()` and want something like it. That means we need to support a variable number of arguments. For `printf()` to
know how many arguments to pop, it needs to be able to grab the format string before it grabs any of the other arguments, which
probably means we need the *first* argument to the function to be the *last* value pushed to the stack. Otherwise, for `printf()` to
get the format string first, we'd need to use it like:

    printf(1, "hello", "%d. %s\n"); // "1. hello\n"

which is annoying and unintuitive.

## Grammar

Something like (completely unimplemented and untested):

    program           ::= statements
    statements        ::= '' | (statement ';' statements)
    statement         ::= block | declaration | assignment | expression | conditional | loop | return
    block             ::= statement | ('{' statements '}')
    declaration       ::= ('var' identifier) | ('var' identifier '=' expression)
    assignment        ::= expression '=' expression
    conditional       ::= ('if' expression block) | ('if' expression block 'else' block)
    loop              ::= 'while' expression block
    return            ::= 'return' expression
    expression        ::= constant | function_call | unary_expression | binary_expression | ('(' expression ')')
    function_call     ::= identifier '(' expressions ')'
    expressions       ::= '' | (expression ',' expressions)
    unary_expression  ::= unary_op expression
    binary_expression ::= binary_op expression
    unary_op          ::= '!' | '~' | '-' | '+' | '*' | '&'
    binary_op         ::= '+' | '-' | '*' | '/' | '&' | '|'
    constant          ::= num_literal | string_literal | function_decl
    function_decl     ::= 'func' '(' arguments ')' block
    arguments         ::= '' | (identifier ',' arguments)
    identifier        ::= /^[a-z_][0-9a-z_]*$/
    num_literal       ::= /^[0-9]+$/ | /^0x[0-9a-f]+$/ | /^0b[01]+$/
    string_literal    ::= '"' characters '"'
    characters        ::= '' | (character characters)
    character         ::= [characters except backslash] | '\\' | '\"' | '\t' | '\r' | '\n' | '\[' | '\0' | ...

But with the understanding that there can be optional whitespace between any pair of tokens, and comments that start with a '#'
and run to the end of the line.

Intended to allow programs like:

    # Example program
    var x = 0;
    var y = 5;
    var z;
    var welcome = "Hello, world!\n";
    
    printf("%s", welcome);
    
    var i = 0;
    while (i < 5) {
        i = inc(i); # Increment i
        printf("Loop number %d\n", i);
    };
    
    var inc = func(x) {
        return x + 1;
    };
