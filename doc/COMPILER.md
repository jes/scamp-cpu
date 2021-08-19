# Compiler

The language is called SLANG but I haven't quite worked out what it stands for yet, other
than "SCAMP Language".

`compiler/slangc` contains a Perl implementation of a SLANG compiler.
The code it generates is not great, but `peepopt` cleans it up quite a lot.

## Design goals

It should either be self-hosting or implemented in assembly language, so that the compiler can (at least
in principle) be developed completely inside SCAMP.

I'm not really picky about the syntax, but I definitely want pointers, pointer arithmetic, function pointers, and
inline assembly code.

Sources of inspiration include:

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

Update: I added some syntax for defining a statically-allocated array at compile time:

    var arr = [1, 2, 3, 4, 5];

The memory allocation works the same as string literals, but the contents are filled in dynamically at runtime, which
allows things like this to do what you expect:

    var x = foo();
    var y = bar();
    var arr = [1, 2, 3, x, y];

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

Update: the solution I went with was to use the statically-allocated array syntax to pass an array of arguments to `printf()`:

    printf("Hello, %s. Number is %d.\n", ["world", 42]);

## Grammar

The implemented grammar is something like:

    program           ::= statements
    statements        ::= '' | (statement (';' statement)* ';'?)
    statement         ::= block | extern | declaration | conditional | loop | 'break' | 'continue' | return | assignment | expression
    block             ::= '{' statements '}'
    extern            ::= 'extern' identifier
    declaration       ::= ('var' identifier) | ('var' identifier '=' expression)
    conditional       ::= 'if' '(' expression ')' statement ('else' statement)?
    loop              ::= 'while' expression statement
    return            ::= 'return' expression
    assignment        ::= lvalue '=' expression
    lvalue            ::= identifier | ('*' term)
    expression        ::= expr0
    expr0             ::= expr2 ([&|^] expr2)*
    expr1             ::= term (('&&'|'||') term)*
    expr2             ::= expr3 (('=='|'!='|'>='|'<='|'>'|'<') expr3)*
    expr3             ::= expr1 ([+-] expr1)*
    term              ::= constant | func_call | address_of | preop | postop | unary_expr | paren_expr | identifier
    constant          ::= num_literal | str_literal | func_decl
    num_literal       ::= hex_literal | char_literal | dec_literal
    hex_literal       ::= '0x' [0-9a-fA-F]+
    dec_literal       ::= [-+]? [0-9]+
    char_literal      ::= ("'" '\' <char> "'") | ("'" <char> "'")
    str_literal       ::= '"' <string> '"'
    func_decl         ::= 'func' '(' paramaters ')' statement
    parameters        ::= '' | (identifier (',' identifier)* ','?)
    func_call         ::= identifier '(' arguments ')'
    arguments         ::= '' | (expression (',' expression)* ','?)
    address_of        ::= '&' identifier
    preop             ::= ('++' identifier) | ('--' identifier)
    postop            ::= (identifier '++') | (identifier '--')
    unary_expr        ::= [!~*+-] term
    paren_expr        ::= '(' expression ')'
    identifier        ::= [a-zA-Z_] [a-zA-Z0-9_]*

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

## Optimisation

### Peephole

There is a peephole optimiser in `compiler/peepopt`. It works by reading in assembly code and passing it through
several "levels" of optimisation, which each pass through code unchanged if they don't recognise it, and optimise
the bits they are responsible for if they do.

Here are some benchmarks for `test.sl`, the compiler test program, showing how the code size
and runtime are improved by `peepopt`.

| Optimisation   | Time (cycles)     | Size (words) |
| :------------- | :------------     | :----------- |
| None           | 49,687,474        | 7,495        |
| 1 pass peepopt | 33,806,242 (-32%) | 5,555 (-26%) |
| 2 pass peepopt | 31,414,357 (-37%) | 5,503 (-27%) |

After the first pass of `peepopt` there are some new `push x; pop x;` instances that can be
optimised out, hence the second pass is slightly better.

Applying more than 2 passes doesn't yield any further improvement on this particular
program, but I haven't proven that it can't do on other programs.

### Function locations

Instead of generating functions inline and jumping over them, we should stick them at the end with the other globals.

### Function calls

Is there a more efficient way to go about the whole business of backing up r254 (return address) before function calls?
