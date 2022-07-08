# LISP for SCAMP

I'm not sure whether LISP performance would be too poor to be worth using, but at least for
the simpler Advent of Code problems it might save time.

Some things I definitely require:

 - basic lisp stuff: cons, lambda, symbols, etc.
 - garbage collection
 - fixed-width integers
 - some way to use bigints
 - strings
 - tail call optimisation

Some things that would be nice to have:

 - decent error reporting (what went wrong? what line of code? backtrace?)
 - transparent bigints
 - lexical scope
 - vectors
 - hash tables
 - Scheme-style "function is evaluated the same way as its arguments" (i.e. no need to quote
   lambda's that are passed as arguments)

## Thoughts

### Cons pairs

Represented like `(a . b)`

We want a memory-efficient way to create cons pairs in such a way that we can always find
them all in order to garbage-collect them.

I think the empty list would be a null pointer.

### Symbol interning

Everywhere you write the same symbol, it needs to point to the same place in order for `eq?` to
be efficient. That means we need a fast way to intern symbols (the other possibility is not
to intern symbols, to make `eq?` use strcmp() on symbols, and waste more memory, which seems worse
overall).

Probably we'd use a hash table for this. I think it would be simple enough to automatically
free the symbols when they get garbage collected (e.g. if the hash table maps a string to
itself, then we could `htwalk()` to set every string to 0, then as part of garbage collection
we could add back the string pointer for every accessibly symbol, and then free all of the ones
that are still 0 in the table).

### Garbage collection

The McCarthy Lisp paper said that there is an area of memory in which all cons pairs live. It is
long enough for 15000 cons cells. At startup the memory is initialised into a circular linked
list covering every cell. This is the free cell list. When a cell is needed (i.e. when `cons`
is called), the list is modified to remove 1 cell, and that cell is returned.

When there are no free cells, garbage collection happens. The system walks through the tree of
all the things that are accessible to the Lisp program and marks them all by making
the address in the `car` field negative. Then it walks through all 15000 cells, building a new
free list out of all the cells that do *not* have negative `car`, and turning `car` positive
again for all the ones that do have negative `car`.

Then we have a new free list made out of all of the cells that are no longer accessible to
the program. Supposedly this is performant as long as there is a healthy amount of
unused cells.

We could do something like that on SCAMP, but it would interact poorly with trying to use other
data types like a `grarr` or a hash table, because then we would no longer have a single
contiguous arena from which we are allocating cells, which means we no longer have a quick and
easy way to do garbage collection. One possibility is that we do the McCarthy garbage collection
scheme over multiple small arenas. We could allocate `cons` arenas in blocks of like 2000 elements,
using `malloc()`, and that still allows us to allocate hash tables and vectors with `malloc()`,
without having to pre-commit to relative memory ratios. We should probably make the garbage
collection allocate a new `cons` arena whenever it finds that existing memory is more than,
say, 75% full. Maybe we could make it free them whenever it finds that an entire arena
is unused?

### Integers

Represented like `123`

If we just try to stuff integers into the `car` and `cdr` field then they will become
indistinguishable from pointers.

We could store an obvious non-pointer value in the `car` field as a type identifier,
and the integer value in the `cdr` field. So `(cons 1 2)` in Lisp code would be a `cons`
cell pointing to 2 integer cells.

More generally we can say that a `car` field always has to be either a pointer or a type
identifier. If it's a pointer then the cell is a pair. If it's a type identifier then it's
something else, and the `cdr` field points to the real object. Values less than 256 would point
to ROM, so cannot make sense as pointers to pairs, so that gives us 256 different type identifiers
which should be more than enough.

### Bigints

Represented like `123b`

We can use the same idea as for integers (where the `car` field identifies the type),
but have the `cdr` field point to a bigint made with `bignew()`.
When a cell of this type is free'd by garbage collection, the associated bigint would also
need to be free'd.

I don't know if we'd try to expose exactly the bigint API (so it's up to the user to
structure the expressions to try to reduce copying), or whether we'd say that Lisp has
a performance hit already and programming convenience is more important. We could present
to the user exactly the same arithmetic functions as for integers, and either require
them to create bigints manually, or automatically create bigints whenever integer operations
would overflow.

### Strings and vectors

Strings represented like: `"string here"`
Vectors represented like: `[1 2 3 (4 5) 6]`

Strings would be exactly the same as symbols except they don't get interned. Operations that
modify strings would be quite inefficient (because they'd have to copy the string every time)
but we don't care.

Vectors would be exactly identical to strings except they print as numbers instead of characters.

### Tail call optimisation

We want `eval()` in SLANG code *not* to be recursive, and then we have half a chance of making
a general tail call optimisation.
So `eval` should be iterative and it should
explicitly allocate return continuations(?) using `cons`, so that they get garbage collected
automatically.

### Hash tables

Represnted like: `(hash-table (k1 . v1) (k2 . v2) ...)`

Same story again: we just set the type identifier in the `car` field and `htnew()` in the
`cdr` field.

Do we allow arbitrary forms to be keys? And we just `PRINT` them to get a canonical string
representation to use for keys? Only problem is it seems inefficient for the common case of
using strings as keys. Maybe for strings we use them directly, and for other things we call
`PRINT` in the background but make sure to append/prepend some character that means it can
never be confused for a string (like a 0xffff?).

### Scoping

The easy way to do scoping in Lisp is to pass an alist as an argument to `eval`. This
makes *dynamic scope*, because the variables visible in one place depend on what was
visible in the calling scope.

A [StackOverflow question](https://stackoverflow.com/questions/3786033/how-to-live-with-emacs-lisp-dynamic-scoping) asks "How to live with Emacs Lisp dynamic scoping?". The top answer
is **It isn't that bad**, and argues that as long as you don't use free variables by
accident, and make sure that globals are not easily confused with locals, then it pretty
much behaves the same as lexical scope?

But what about closures? Surely under dynamic scope, closures basically don't work?

What if every created lambda has an implicit environment pointer to the scope it was created
in rather than the one it was called from? Is that enough to provide fully lexical scopes? See
[Dynamic Closure](http://wiki.c2.com/?DynamicClosure) on c2wiki?

### "Function is evaluated the same way as its arguments"

It seems that the way "old" Lisp did lambda functions is that if the `car` of an expression
is a pair, and `car` of that pair is the symbol "lambda", then the lambda function is
applied to the expression's arguments. There is no lambda object of any kind. To return
a lambda, or pass one as an argument, you'd have to quote it.

The Scheme thing seems to be that `lambda` is a special form that creates a closure, and then
it doesn't matter whether the closure is returned or called, it still works the same and doesn't
need to be quoted. I like the Scheme way better, but there is a certain beauty to not having
to create any kind of object.

But for lexical scope we need an object.

## Specifics

### Type identifiers

 * (cons pair implicit)
 * 1 - Symbol
 * 2 - Integer
 * 3 - Bigint
 * 4 - String
 * 5 - Vector
 * 6 - Hash table
 * 7 - Closure

### Globals

 * symbols - hash table mapping symbol names to themselves
 * ARENASZ = 2000
 * arenas - grarr of arenas; each arena is a `malloc(ARENASZ)`

### Functions

Some functions need capital names because they'd otherwise collide with SLANG library functions.

 * symbol(str) - return a pointer to an interned string for `str`, allocating a new one if none
 * integer(num) - return a pointer to a cons cell representing `num` as a machine word
 * bigint(num) - return a pointer to a cons cell representing `num` as a bigint
 * string(str) - return a pointer to a cons cell representing `str`
 * vector([vec ...]) - return a pointer to a cons cell representing `vec ...`
 * gc() - garbage collect arenas, create new ones if necessary
 * CONS(a,b) - alllocate and return a cons pair with `car` set to `a` and `cdr` set to `b`;
   if there's not a free slot in any arena, perform `gc()` first
 * READ(str) - turn `str` into an S-expression made of cons pairs
 * EVAL(form) - evaluate `form` (S-expression)
 * PRINT(form) - print `form` to stdout

var EVAL = func(form) {
    if form is nil: return nil
    if form is a symbol: look it up in ENV and return it, error if none
    if form is any other type of non-pair: return it
    otherwise form is a pair:
        if it's not a true list, error
        evaluate elements 1..n in current environment
        evaluate argument 1 to find the function to apply
        if the function is not a procedure, builtin, or special form, error
        apply the function to the arguments <-- this needs to be able to loop instead of recurse
};
