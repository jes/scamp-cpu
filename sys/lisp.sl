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
var length;

var newint;
var intval;

var newbigint;
var bigintval;

var newvector;

var newstring;
var stringstring;

var newhash;

var newsymbol;
var symbolname;
var intern;
var lookupglobal;
var lookup;

var newclosure;
var closureargs;
var closurebody;
var closurescope;

var newport;
var portsetchar;
var portsetbuf;
var portchar;
var portbuf;
var porteof;

var needargs;
var init;

var peekread;
var nextread;
var skipread;
var READ;
var read_form;
var read_list;
var read_string;
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
var _EOF;
var _QUOTE;
var _LAMBDA;
var _COND;
var _DEFINE;

var NOCHAR = -1000;
var showprompt = 1;

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
var PORT = 18;
var PAIR = 0x100;

### Cons cells ###
var ARENASZ = 2000;
var arenas = grnew();

newarena = func() {
    var arena = malloc(ARENASZ+1); # XXX: "+1" to handle the case where we get an odd pointer
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
    # TODO: for certain types of cell we also need to free cdr(cell),
    # e.g. bigints, vectors, strings, hash tables, etc.
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
    assert((a&1)==0, "cons: car field must be even\n", 0);
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

length = func(pair) {
    var l = 0;
    while (pair) {
        assert(type(pair) == PAIR, "can't take length of non-pair\n", 0);
        pair = cdr(pair);
        l++;
    };
    return l;
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
stringstring = func(s) return cdr(s);

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

### Ports ###

newport = func(buf) {
    var p = malloc(2);
    var port = cons(PORT, p);
    portsetchar(port, NOCHAR);
    portsetbuf(port, buf);
    return port;
};

portsetchar = func(port, ch) {
    *(cdr(port)+1) = ch;
};

portsetbuf = func(port, buf) {
    *(cdr(port)) = buf;
};

portchar = func(port) {
    return *(cdr(port)+1);
};

portbuf = func(port) {
    return *(cdr(port));
};

porteof = func(port) {
    return peekread(port) == EOF; # XXX: SLANG EOF, not Lisp _EOF
};

### Initialisation ###

needargs = func(num, args) {
    assert(length(args) == num, "arity mismatch\n", 0);
};

init = func() {
    # intern required objects
    _NIL = 0;
    _T = newsymbol("t");
    _EOF = newsymbol(""); # needs to be distinguishable from anything that can be read in

    htput(GLOBALS, "EOF", _EOF);
    htput(GLOBALS, "else", _T);

    # put builtins in GLOBALS
    var b = func(name, fn) {
        htput(GLOBALS, intern(name), cons(BUILTIN, fn));
    };
    b("null?", func(args) {
        needargs(1, args);
        if (car(args) == _NIL) return _T else return _NIL;
    });
    b("symbol?", func(args) {
        needargs(1, args);
        if (type(car(args)) == SYMBOL) return _T else return _NIL;
    });
    b("int?", func(args) {
        needargs(1, args);
        if (type(car(args)) == INT) return _T else return _NIL;
    });
    b("bigint?", func(args) {
        needargs(1, args);
        if (type(car(args)) == BIGINT) return _T else return _NIL;
    });
    b("vector?", func(args) {
        needargs(1, args);
        if (type(car(args)) == VECTOR) return _T else return _NIL;
    });
    b("string?", func(args) {
        needargs(1, args);
        if (type(car(args)) == STRING) return _T else return _NIL;
    });
    b("hash?", func(args) {
        needargs(1, args);
        if (type(car(args)) == HASH) return _T else return _NIL;
    });
    b("procedure?", func(args) {
        needargs(1, args);
        if (type(car(args)) == CLOSURE || type(car(args)) == BUILTIN) return _T else return _NIL;
    });
    b("pair?", func(args) {
        needargs(1, args);
        if (type(car(args)) == PAIR) return _T else return _NIL;
    });
    b("port?", func(args) {
        needargs(1, args);
        if (type(car(args)) == PORT) return _T else return _NIL;
    });
    b("eof-object?", func(args) {
        needargs(1, args);
        if (car(args) == _EOF) return _T else return _NIL;
    });
    b("cons", func(args) {
        needargs(2, args);
        return cons(car(args), car(cdr(args)));
    });
    b("car", func(args) {
        needargs(1, args);
        return car(car(args));
    });
    b("cdr", func(args) {
        needargs(1, args);
        return cdr(car(args));
    });
    b("+", func(args) {
        var n = 0;
        while (args) {
            n = n + intval(car(args));
            args = cdr(args);
        };
        return newint(n);
    });
    b("-", func(args) {
        if (!args) return newint(0);
        var n = intval(car(args));
        args = cdr(args);
        while (args) {
            n = n - intval(car(args));
            args = cdr(args);
        };
        return newint(n);
    });
    b("*", func(args) {
        var n = 1;
        while (args) {
            n = mul(n,intval(car(args)));
            args = cdr(args);
        };
        return newint(n);
    });
    b("/", func(args) {
        if (!args) return newint(0);
        var n = intval(car(args));
        args = cdr(args);
        while (args) {
            n = div(n,intval(car(args)));
            args = cdr(args);
        };
        return newint(n);
    });
    b("=", func(args) {
        if (!args) return _T;
        var a = intval(car(args));
        args = cdr(args);
        while (args) {
            if (intval(car(args)) != a) return _NIL;
            args = cdr(args);
        };
        return _T;
    });
    b(">", func(args) {
        if (!args) return _T;
        var a = intval(car(args));
        args = cdr(args);
        while (args) {
            if (a <= intval(car(args))) return _NIL;
            a = intval(car(args));
            args = cdr(args);
        };
        return _T;
    });
    b("<", func(args) {
        if (!args) return _T;
        var a = intval(car(args));
        args = cdr(args);
        while (args) {
            if (a >= intval(car(args))) return _NIL;
            a = intval(car(args));
            args = cdr(args);
        };
        return _T;
    });
    b(">=", func(args) {
        if (!args) return _T;
        var a = intval(car(args));
        args = cdr(args);
        while (args) {
            if (a < intval(car(args))) return _NIL;
            a = intval(car(args));
            args = cdr(args);
        };
        return _T;
    });
    b("<=", func(args) {
        if (!args) return _T;
        var a = intval(car(args));
        args = cdr(args);
        while (args) {
            if (a > intval(car(args))) return _NIL;
            a = intval(car(args));
            args = cdr(args);
        };
        return _T;
    });
    b("read", func(args) {
        var port = in;
        if (args) { # optional input port
            needargs(1, args);
            port = car(args);
            assert(type(port)==PORT, "can't read non-port\n", 0);
        };
        return READ(port);
    });
    b("open-input-file", func(args) {
        needargs(1, args);
        var name = car(args);
        assert(type(name) == STRING, "filename should be string\n", 0);
        var buf = bopen(stringstring(name), O_READ);
        if (!buf) return _NIL;
        return newport(buf);
    });
    b("close-input-port", func(args) {
        needargs(1, args);
        var port = car(args);
        assert(type(port) == PORT, "port should be port\n", 0);
        bclose(portbuf(port));
        portsetbuf(port, 0);
    });

    # intern symbols for special forms
    _QUOTE = intern("quote");
    _LAMBDA = intern("lambda");
    _COND = intern("cond");
    _DEFINE = intern("define");

    # TODO: load default lisp code from /lisp/lib.l ?

    # initialise input port for stdin
    in = newport(bfdopen(0, O_READ));
};

### Interpreter ###

peekread = func(port) {
    if (portbuf(port) == 0) {
        assert(0, "can't read a closed port\n", 0);
    };
    if (portchar(port) == NOCHAR) {
        portsetchar(port, bgetc(portbuf(port)));
    };
    return portchar(port);
};

nextread = func(port) {
    var ch = peekread(port);
    portsetchar(port, NOCHAR);
    return ch;
};

skipread = func(port) {
    while (iswhite(peekread(port))) nextread(port);
};

READ = func(port) {
    skipread(port);
    if (porteof(port)) return _EOF;
    return read_form(port);
};

read_form = func(port) {
    skipread(port);
    if (peekread(port) == '(') {
        return read_list(port);
    } else if (peekread(port) == '\'') {
        nextread(port);
        return cons(newsymbol("quote"), cons(read_form(port), 0));
    } else if (peekread(port) == '"') {
        return read_string(port);
    } else if (isdigit(peekread(port)) || peekread(port) == '-') {
        return read_number(port);
    } else {
        return read_symbol(port);
    };
};

read_list = func(port) {
    skipread(port);
    assert(nextread(port) == '(', "list must start with open-paren\n", 0);

    var list = 0;
    var p = 0;
    var cell;

    skipread(port);
    while (peekread(port) != ')') {
        if (peekread(port) == '.') {
            assert(0, "we don't handle dotted pairs yet\n", 0);
        };
        cell = cons(read_form(port), 0);
        if (p) setcdr(p, cell);
        if (!list) list = cell;
        p = cell;

        assert(iswhite(peekread(port)) || peekread(port) == ')', "list elements should be separated with space\n", 0);

        skipread(port);
    };
    nextread(port);

    return list;
};

read_string = func(port) {
    assert(nextread(port) == '"', "string must start with double-quote\n", 0);
    var str = sbnew();
    var ch;
    while (1) {
        # TODO: escape characters
        ch = nextread(port);
        if (ch == '"') break;
        sbputc(str, ch);
    };
    var cell = newstring(sbbase(str));
    sbfree(str);
    return cell;
};

read_number = func(port) {
    var num = 0;
    var neg = 0;
    if (peekread(port) == '-') {
        neg = 1;
        nextread(port);

        # XXX: bodge: allow "-" as a symbol
        if (!isdigit(peekread(port))) return newsymbol("-");
    };

    # TODO: support hex input, bignums
    while (isdigit(peekread(port))) {
        num = mul(num,10) + (nextread(port) - '0');
    };

    if (neg) num = -num;
    return newint(num);
};

issymch = func(ch) {
    return isalnum(ch) || ch == '_' || ch == '?' || ch == '+' || ch == '-' || ch == '*' || ch == '/' || ch == '%' || ch == '=' || ch == '>' || ch == '<';
};

read_symbol = func(port) {
    var str = sbnew();
    while (issymch(peekread(port))) {
        sbputc(str, nextread(port));
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
    var name;
    var val;
    var args;
    var body;
    if (type(fn) == SYMBOL) {
        # TODO: check number and type of arguments to special forms!
        if (symbolname(fn) == _QUOTE) {
            return car(cdr(form));
        } else if (symbolname(fn) == _COND) {
            form = cdr(form);
            while (form) {
                # TODO: support more than 1 expression in the "body"
                if (EVAL(car(car(form)), scope)) return EVAL(car(cdr(car(form))), scope);
                form = cdr(form);
            };
            return 0;
        } else if (symbolname(fn) == _LAMBDA) {
            return newclosure(car(cdr(form)), cdr(cdr(form)), scope);
        } else if (symbolname(fn) == _DEFINE) {
            if (type(car(cdr(form))) == SYMBOL) {
                name = symbolname(car(cdr(form)));
                val = EVAL(car(cdr(cdr(form))), scope);
            } else if (type(car(cdr(form))) == PAIR) {
                name = symbolname(car(car(cdr(form))));
                args = cdr(car(cdr(form)));
                body = cdr(cdr(form));
                val = newclosure(args, body, scope);
            } else {
                assert(0, "bad define\n", 0);
            };

            if (scope) {
                assert(0, "we can't yet handle define outside global scope\n", 0);
            } else {
                htput(GLOBALS, name, val);
            };
            return 0;
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
        # TODO: escape
        puts("\""); puts(stringstring(form)); puts("\"");
    } else if (type(form) == HASH) {
        puts("#<hash>");
    } else if (type(form) == CLOSURE) {
        # TODO: if the body has multiple expressions, print each one in turn
        puts("#<procedure>:(lambda "); PRINT(closureargs(form)); puts(" "); PRINT(car(closurebody(form))); puts(")");
    } else if (type(form) == BUILTIN) {
        puts("#<procedure>:<builtin>");
    } else if (type(form) == PAIR) {
        print_list(form);
    } else if (type(form) == PORT) {
        puts("#<port>");
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

var args = cmdargs()+1;
if (*args) {
    in = newport(bopen(*args, O_READ));
    showprompt = 0;
    if (!portbuf(in)) {
        fprintf(2, "%s: can't open for reading\n", [*args]);
        exit(1);
    };
};

if (showprompt) puts("> ");
var form;
while (1) {
    form = READ(in);
    if (form == _EOF) break;
    PRINT(EVAL(form, 0));
    putchar('\n');
    if (showprompt) puts("> ");
};
