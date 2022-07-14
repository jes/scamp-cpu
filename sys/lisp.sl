# LISP for SCAMP

include "bigint.sl";
include "bufio.sl";
include "grarr.sl";
include "hash.sl";
include "strbuf.sl";

### Forward declarations ###
var newarena;
var freearena;
var initarena;
var gc;
var freecell;
var newcellinarena;
var newcell;
var type;

var newint;
var intval;

var newbigint;
var bigintval;

var newvector;

var newstring;

var newhash;

var newsymbol;
var symbolname;

var newclosure;
var closureargs;
var closurebody;
var closurescope;

var intern;
var lookupglobal;
var lookup;

var init;

var peekread;
var nextread;
var skipread;
var READ;
var read_form;
var read_list;
var read_number;
var issymch;
var read_symbol;
var evlis;
var EVAL;
var apply;
var PRINT;
var print_list;

var SYMBOLS = htnew();
var GLOBALS = htnew();

var in;
var readch;

var _NIL;
var _T;
var _QUOTE;
var _LAMBDA;
var _COND;

### Types ###
# these all need to be even-valued so as not to confuse the garbage collector
var NIL = 0;
var SYMBOL = 2;
var INT = 4;
var BIGINT = 6;
var VECTOR = 8;
var STRING = 10;
var HASH = 12;
var CLOSURE = 14;
var BUILTIN = 16;
var PAIR = 0x100;

### Cons cells ###
var ARENASZ = 2000;
var arenas = grnew();

newarena = func() {
    var arena = malloc(ARENASZ);
    # TODO: we need to keep track of whether it was odd or even so we can free it
    arena = arena + (arena&1);
    initarena(arena);
    grpush(arenas, arena);
    return arena;
};

freearena = func(arena) {
    assert(0, "we can't free arenas yet because we don't know if they were odd or even\n", 0);
};

initarena = func(arena) {
    # we initialise an arena by making the cdr fields into a circularly-linked
    # list of all the cells

    # start off with 1 cell linked to itself
    var freelist = arena;
    setcdr(freelist, freelist);

    # free all the remaining cells
    var i = 2;
    while (i < ARENASZ) {
        freecell(freelist, arena+i);
        i = i+2;
    };
};

gc = func() {
    # TODO: need to actually gc the existing arenas, and only make a new one if
    # we're more than 75% full
    newarena();
};

freecell = func(arena, cell) {
    var freelist = arena;
    setcdr(cell, cdr(freelist));
    setcdr(freelist, cell);
};

newcellinarena = func(arena) {
    var freelist = arena;
    # no free cells?
    if (cdr(freelist) == freelist) return 0;

    # take the next cell and unlink it from the list
    var cell = cdr(freelist);
    setcdr(freelist, cdr(cdr(freelist)));
    return cell;
};

newcell = func() {
    var i = 0;
    var cell;
    while (i < grlen(arenas)) {
        cell = newcellinarena(grget(arenas, i));
        if (cell) return cell;
        i++;
    };
    # no space in the existing arenas? gc and try again
    gc();
    return newcell();
};

# XXX: we override the "cons" name in malloc.sl, but for the time being this is
# fine because nothing should be using that one
cons = func(a, b) {
    var cell = newcell();
    setcar(cell, a);
    setcdr(cell, b);
    return cell;
};

type = func(cell) {
    if (!cell) return NIL;
    if (car(cell) != 0 && car(cell) lt 0x100) return car(cell);
    return PAIR;
};

### Ints ###

newint = func(v) return cons(INT, v);
intval = func(cell) return cdr(cell);

### Bigints ###

newbigint = func(v) return cons(BIGINT, bignew(v));
bigintval = func(cell) return cdr(cell);

### Vectors ###

newvector = func() return cons(VECTOR, grnew());

### Strings ###

newstring = func(s) return cons(STRING, strdup(s));

### Hash tables ###

newhash = func() return cons(VECTOR, htnew());

### Symbols ###

newsymbol = func(name) return cons(SYMBOL, intern(name));
symbolname = func(cell) return cdr(cell);

# return interned version of name, or allocate a new one if none
intern = func(name) {
    var p = htget(SYMBOLS,name);
    if (p) return p;
    p = strdup(name);
    htput(SYMBOLS,p,p);
    # TODO: should this map a name to a cons(SYMBOL,name) so that we intern the
    # pair as well, rather than just the string?
    return p;
};

lookupglobal = func(name) {
    var p = htgetkv(GLOBALS,name);
    assert(p, "lookup undefined name: %s\n", [name]);
    return p[1];
};

# "scope" should be a linked list of (name,val) pairs;
# if a name is not found in the "scope" list, then  the "GLOBALS" hash table
# is consulted instead
lookup = func(name, scope) {
    while (scope) {
        assert(type(scope) == PAIR, "scope is not pair\n", 0);
        assert(type(car(scope)) == PAIR, "car(scope) is not pair\n", 0);
        assert(type(car(car(scope))) == SYMBOL, "scope key is not symbol\n",0);

        if (symbolname(car(car(scope))) == name) return cdr(car(scope));

        scope = cdr(scope);
    };

    return lookupglobal(name);
};

### Closures ###

newclosure = func(args, body, scope) {
    return cons(CLOSURE, cons(args, cons(body, scope)))
};

closureargs = func(clos) return car(cdr(clos));
closurebody = func(clos) return car(cdr(cdr(clos)));
closurescope = func(clos) return cdr(cdr(cdr(clos)));

### Initialisation ###
init = func() {
    # intern true/false
    _NIL = 0;
    _T = newsymbol("t");

    # put builtins in GLOBALS
    var b = func(name, fn) {
        htput(GLOBALS, intern(name), cons(BUILTIN, fn));
    };
    # TODO: make builtins check number of arguments
    b("null?", func(args) {
        if (car(args) == _NIL) return _T else return _NIL;
    });
    b("symbol?", func(args) {
        if (type(car(args)) == SYMBOL) return _T else return _NIL;
    });
    b("int?", func(args) {
        if (type(car(args)) == INT) return _T else return _NIL;
    });
    b("bigint?", func(args) {
        if (type(car(args)) == BIGINT) return _T else return _NIL;
    });
    b("vector?", func(args) {
        if (type(car(args)) == VECTOR) return _T else return _NIL;
    });
    b("string?", func(args) {
        if (type(car(args)) == STRING) return _T else return _NIL;
    });
    b("hash?", func(args) {
        if (type(car(args)) == HASH) return _T else return _NIL;
    });
    b("procedure?", func(args) {
        if (type(car(args)) == CLOSURE || type(car(args)) == BUILTIN) return _T else return _NIL;
    });
    b("pair?", func(args) {
        if (type(car(args)) == PAIR) return _T else return _NIL;
    });

    # intern symbols for special forms
    _QUOTE = intern("quote");
    _LAMBDA = intern("lambda");
    _COND = intern("cond");

    # TODO: load default lisp code from /lisp/lib.l ?

    # initialise input stream for stdin
    in = bfdopen(0, O_READ);
    readch = 0;
};

### Interpreter ###

peekread = func() {
    if (readch == 0) {
        readch = bgetc(in);
        if (readch == EOF) exit(0);
    };
    return readch;
};

nextread = func() {
    var ch = peekread();
    readch = 0;
    return ch;
};

skipread = func() {
    while (iswhite(peekread())) nextread();
};

READ = func() {
    return read_form();
};

read_form = func() {
    skipread();
    if (peekread() == '(') {
        return read_list();
    } else if (peekread() == '\'') {
        nextread();
        return cons(newsymbol("quote"), cons(read_form(), 0));
    } else if (isdigit(peekread()) || peekread() == '-') {
        return read_number();
    } else {
        return read_symbol();
    };
};

read_list = func() {
    skipread();
    assert(nextread() == '(', "list must start with open-paren\n", 0);

    var list = 0;
    var p = 0;
    var cell;

    skipread();
    while (peekread() != ')') {
        if (peekread() == '.') {
            assert(0, "we don't handle dotted pairs yet\n", 0);
        };
        cell = cons(read_form(), 0);
        if (p) setcdr(p, cell);
        if (!list) list = cell;
        p = cell;

        assert(iswhite(peekread()) || peekread() == ')', "list elements should be separated with space\n", 0);

        skipread();
    };
    nextread();

    return list;
};

read_number = func() {
    var num = 0;
    var neg = 0;
    if (peekread() == '-') {
        neg = 1;
        nextread();
    };

    # TODO: support hex input, bignums
    while (isdigit(peekread())) {
        num = mul(num,10) + (nextread() - '0');
    };

    if (neg) num = -num;
    return newint(num);
};

issymch = func(ch) {
    return isalpha(ch) || ch == '_' || ch == '?' || ch == '+' || ch == '-' || ch == '*' || ch == '/' || ch == '%';
};

read_symbol = func() {
    var str = sbnew();
    while (issymch(peekread())) {
        sbputc(str, nextread());
    };

    var cell = newsymbol(sbbase(str));
    sbfree(str);
    return cell;
};

evlis = func(list, scope) {
    if (!list) return 0;
    assert(type(list) == PAIR, "can't evlis of non-pair\n", 0);
    return cons(EVAL(car(list), scope), evlis(cdr(list), scope));
};

EVAL = func(form, scope) {
    assert(form, "can't eval the empty list\n", 0);
    if (type(form) == SYMBOL) return lookup(symbolname(form), scope);
    if (type(form) != PAIR) return form;

    var fn = car(form);
    if (type(fn) == SYMBOL) {
        # TODO: check number and type of arguments to special forms!
        if (symbolname(fn) == _QUOTE) {
            return car(cdr(form));
        } else if (symbolname(fn) == _COND) {
            form = cdr(form);
            while (form) {
                if (EVAL(car(car(form)), scope)) return EVAL(car(cdr(car(form))), scope);
                form = cdr(form);
            };
            return 0;
        } else if (symbolname(fn) == _LAMBDA) {
            return newclosure(car(cdr(form)), cdr(cdr(form)), scope);
        };
        fn = lookup(symbolname(fn), scope);
    } else {
        fn = EVAL(fn, scope);
    };

    var arglist = evlis(cdr(form), scope);

    # TODO: refactor to support tail-call optimisation
    return apply(fn, arglist);
};

apply = func(fn, arglist) {
    if (type(fn) == BUILTIN) {
        fn = cdr(fn);
        return fn(arglist);
    };

    assert(type(fn) == CLOSURE, "don't know how to apply anything other than a builtin or closure (got %d)\n", [car(fn)]);

    var scope = closurescope(fn);
    var namelist = closureargs(fn);
    while (namelist && arglist) {
        if (type(namelist) == PAIR) {
            assert(type(car(namelist)) == SYMBOL, "name list must have only symbols, got carnamelist=%d\n", [car(namelist)]);

            # normal case: 1 name goes to 1 arg
            scope = cons(cons(car(namelist), car(arglist)), scope);

            namelist = cdr(namelist);
            arglist = cdr(arglist);
        } else if (type(namelist) == SYMBOL) {
            # otherwise assign the rest of the arg list to 1 name
            scope = cons(cons(namelist, arglist), scope);

            namelist = 0;
            arglist = 0;
        } else {
            assert(0, "name list must have only symbols\n", 0);
        };
    };
    assert(!namelist && !arglist, "non-matching number of arguments\n", 0);

    # TODO: if the body has multiple expressions, apply each one in turn
    return EVAL(car(closurebody(fn)), scope);
};

PRINT = func(form) {
    if (!form) {
        puts("()");
    } else if (type(form) == SYMBOL) {
        printf("%s", [symbolname(form)]);
    } else if (type(form) == INT) {
        printf("%d", [intval(form)]);
    } else if (type(form) == BIGINT) {
        printf("%b", [bigintval(form)]);
    } else if (type(form) == VECTOR) {
        puts("#<vector>");
    } else if (type(form) == STRING) {
        puts("#<string>");
    } else if (type(form) == HASH) {
        puts("#<hash>");
    } else if (type(form) == CLOSURE) {
        puts("#<closure>");
    } else if (type(form) == BUILTIN) {
        puts("#<builtin>");
    } else if (type(form) == PAIR) {
        print_list(form);
    } else {
        assert(0, "tried to print unrecognised type: %d\n", [car(form)]);
    }
};

print_list = func(form) {
    assert(type(form) == PAIR, "print_list() should take a pair\n", 0);

    puts("(");
    while (form) {
        if (type(form) != PAIR) {
            puts(". ");
            PRINT(form);
            break;
        };
        PRINT(car(form));
        form = cdr(form);
        if (form) puts(" ");
    };
    puts(")");
};

init();
puts("> ");
while (1) {
    PRINT(EVAL(READ(), 0));
    putchar('\n');
    puts("> ");
};
