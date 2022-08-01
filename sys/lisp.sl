# LISP for SCAMP

include "bigint.sl";
include "bufio.sl";
include "grarr.sl";
include "hash.sl";
include "strbuf.sl";

### Cons cells ###
var newarena;
var freearena;
var initarena;
var markcellused;
var ref;
var unref;
var gc;
var freecell;
var freeusedcells;
var newcellinarena;
var newcell;
var type;
var length;

### Ints ###
var newint;
var intval;

### Bigints ###
var newbigint;
var bigintval;

### Vectors ###
var newvector;

### Strings ###
var newstring;
var stringstring;

### Hash tables ###
var newhash;

### Symbols ###
var newsymbol;
var symbolname;
var intern;
var lookupglobal;
var lookup;
var scopeset;

### Closures ###
var newclosure;
var closureargs;
var closurebody;
var closurescope;

### Macros ###
var newmacro;
var macroargs;
var macrobody;
var macroscope;

### Ports ###
var newport;
var portsetchar;
var portsetbuf;
var portchar;
var portbuf;
var porteof;

### Reader ###
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

### Continuations ###
var newcondcont;
var condcont;
var newdefinecont;
var definecont;
var newevliscont;
var evliscont;
var newsetcont;
var setcont;
var newqqcont;
var qqcont;
var newmacrocont;
var macrocont;
var newbegincont;
var begincont;
var pushcontinuation;
var popcontinuation;
var yield;

### Interpreter ###
var buildscope;
var quasiquote;
var applymacro;
var begin;
var dospecial;
var EVAL;

### Printer ###
var PRINT;
var print_list;

### Initialisation ###
var needargs;
var init;
var load;
var process;

var SYMBOLS = htnew();
var GLOBALS = htnew();

var in;
var readch;

### Constants ###
var _NIL;
var _T;
var _EOF;
var _QUOTE;
var _LAMBDA;
var _COND;
var _DEFINE;
var _SETBANG;
var _QUASIQUOTE;
var _UNQUOTE;
var _DEFMACRO;
var _EVAL;
var _BEGIN;

var NOCHAR = -1000;
var showprompt = 1;
var RESTART;
var NOVALUE;
var CALLSTACK = 0;
var FORM;
var SCOPE;
var RET;
var PRINTANSWERS = 1;

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
var CONTINUATION = 20;
var MACRO = 22;

### Continuation types ###
# XXX: when adding a new continuation type, make sure to add it to "contfuncs"
var N_mincont = 100;
var N_condcont = 100;
var N_definecont = 102;
var N_evliscont = 104;
var N_setcont = 106;
var N_qqcont = 108;
var N_macrocont = 110;
var N_begincont = 112;
var N_maxcont = 112;
var contfuncs = [&condcont, 0, &definecont, 0, &evliscont, 0, &setcont, 0, &qqcont, 0, &macrocont, 0, &begincont];

var PAIR = 0x100;

### Cons cells ###
var ARENASZ = 2000;
var minfreecells = 500; # threshold for allocating a new arena
var arenas = grnew();
var freecells = 0;

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
    while (i != ARENASZ) {
        freecell(freelist, arena+i);
        i = i+2;
    };
};

# mark the given cell as used, recursing into any of the cells it references,
# and return how many new cells are now marked used that weren't already
markcellused = func(cell) {
    var typ;

    while (cell) {
        #assert(cell gt 0x100, "bad cell! %d\n", [cell]); # DEBUG

        # already visited?
        if (car(cell)&1) return 0;

        typ = type(cell);

        # mark the cell as "used" by ORing a 1 into its car
        setcar(cell, car(cell)|1);

        if (typ == PAIR) {
            markcellused(car(cell)&~1);
            cell = cdr(cell);
        } else if (typ == CLOSURE || typ == CONTINUATION || typ == MACRO) {
            cell = cdr(cell);
        } else {
            break;
        };
        # TODO: vectors, hashes, more?
    };
};

gc = func() {
    # 1. mark all referenced cells as "used" by ORing a 1 into their car
    htwalk(GLOBALS, func(key,val) {
        markcellused(val);
    });
    markcellused(CALLSTACK);
    markcellused(FORM);
    markcellused(SCOPE);
    markcellused(RET);

    # 2. walk over all cells, free the ones that aren't marked, remove the markings
    var i = 0;
    freecells = 0;
    while (i != grlen(arenas)) {
        freeusedcells(grget(arenas, i));
        i++;
    };

    # make a new arena if we're running low
    if (freecells lt minfreecells) newarena();
};

freeusedcells = func(arena) {
    var freelist = arena;

    var i = 0;
    while (i != ARENASZ) {
        if (car(arena+i)&1) {
            # used: remove the 1 bit
            setcar(arena+i, car(arena+i)&~1);
        } else {
            # not used: free the cell
            freecell(arena, arena+i);
        };
        i = i + 2;
    };
    # TODO: free an arena if all of the cells are unused?
};

freecell = func(arena, cell) {
    var freelist = arena;
    # TODO: for certain types of cell we also need to free cdr(cell),
    # e.g. bigints, vectors, strings, hash tables, etc.
    # Note we *don't* need to freecell(cdr(cell)) in any case because if
    # nothing references it then it will be free'd automatically
    freecells++;
    setcar(cell, 0);
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
    freecells--;
    while (i != grlen(arenas)) {
        cell = newcellinarena(grget(arenas, i));
        if (cell) return cell;
        i++;
    };
    assert(0, "ran out of free cells! freecells=%d\n", [freecells]);
};

# XXX: we override the "cons" name in malloc.sl, but for the time being this is
# fine because nothing should be using that one
cons = func(a, b) {
    #assert((a&1)==0, "cons: car field must be even\n", 0); # DEBUG
    var cell = newcell();
    setcar(cell, a);
    setcdr(cell, b);
    return cell;
};

type = func(cell) {
    if (!cell) return NIL;
    var c = car(cell);
    if (c ge N_mincont && c le N_maxcont) return CONTINUATION;
    if (c == 0) return PAIR;
    if (c & 0xff00) return PAIR;
    return c&~1;
};

length = func(pair) {
    var l = 0;
    while (pair) {
        #assert(type(pair) == PAIR, "can't take length of non-pair\n", 0); # DEBUG
        pair = cdr(pair);
        l++;
    };
    return l;
};

### Ints ###

newint = func(v) return cons(INT, v);
intval = cdr;#func(cell) return cdr(cell);

### Bigints ###

newbigint = func(v) return cons(BIGINT, bignew(v));
bigintval = cdr;#func(cell) return cdr(cell);

### Vectors ###

newvector = func() return cons(VECTOR, grnew());

### Strings ###

newstring = func(s) return cons(STRING, strdup(s));
stringstring = cdr;#func(s) return cdr(s);

### Hash tables ###

newhash = func() return cons(VECTOR, htnew());

### Symbols ###

newsymbol = func(name) return cons(SYMBOL, intern(name));
symbolname = cdr;#func(cell) return cdr(cell);

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
        #assert(type(scope) == PAIR, "scope is not pair\n", 0); # DEBUG
        #assert(type(car(scope)) == PAIR, "car(scope) is not pair\n", 0); # DEBUG
        #assert(type(car(car(scope))) == SYMBOL, "scope key is not symbol\n",0); # DEBUG
        if (symbolname(car(car(scope))) == name) return cdr(car(scope));
        scope = cdr(scope);
    };
    return lookupglobal(name);
};

scopeset = func(name, scope, val) {
    while (scope) {
        if (symbolname(car(car(scope))) == name) return setcdr(car(scope), val);
        scope = cdr(scope);
    };
    var p = htgetkv(GLOBALS,name);
    assert(p, "scopeset undefined name: %s\n", [name]);
    htputp(GLOBALS, p, name, val);
};

### Closures ###

newclosure = func(args, body, scope) {
    return cons(CLOSURE, cons(args, cons(body, scope)));
};

closureargs = func(clos) return car(cdr(clos));
closurebody = func(clos) return car(cdr(cdr(clos)));
closurescope = func(clos) return cdr(cdr(cdr(clos)));

### Macros ###

newmacro = func(args, body, scope) {
    return cons(MACRO, cons(args, cons(body, scope)));
};

macroargs = func(macro) return car(cdr(macro));
macrobody = func(macro) return car(cdr(cdr(macro)));
macroscope = func(macro) return cdr(cdr(cdr(macro)));

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

### Reader ###

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
    var a;
    var r;

    skipread(port);
    if (peekread(port) == '(') {
        return read_list(port);
    } else if (peekread(port) == '\'') {
        nextread(port);
        return cons(newsymbol("quote"), cons(read_form(port), _NIL));
    } else if (peekread(port) == '`') {
        nextread(port);
        return cons(newsymbol("quasiquote"), cons(read_form(port), _NIL));
    } else if (peekread(port) == ',') {
        nextread(port);
        return cons(newsymbol("unquote"), cons(read_form(port), _NIL));
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
            nextread(port);
            assert(p, "can't have a dotted single\n", 0);
            setcdr(p, read_form(port));
            assert(peekread(port) == ')', "dotted pair can't have trailing cruft\n", 0);
            break;
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
    return isalnum(ch) || ch == '_' || ch == '?' || ch == '!' || ch == '+' || ch == '-' || ch == '*' || ch == '/' || ch == '%' || ch == '=' || ch == '>' || ch == '<';
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

### Continuations ###

newcondcont = func(form, scope) {
    return cons(N_condcont, cons(form, scope));
};
newdefinecont = func(form, scope) {
    return cons(N_definecont, cons(form, scope));
};
newevliscont = func(form, scope, arglist) {
    return cons(N_evliscont, cons(cons(form, scope), arglist));
};
newsetcont = func(form, scope) {
    return cons(N_setcont, cons(form, scope));
};
newqqcont = func(got, rest, scope) {
    return cons(N_qqcont, cons(got, cons(rest, scope)));
};
newmacrocont = func(scope) {
    return cons(N_macrocont, scope);
};
newbegincont = func(form, scope) {
    return cons(N_begincont, cons(form, scope));
};

condcont = func(state) {
    var form = car(state);
    var scope = cdr(state);

    # form is the list of condition clauses: e.g. (((> n 4) 1) (else 2))
    if (RET) {
        # condition evaluated true: now we want to run the condition body
        begin(cdr(car(form)), scope);
        return 1;
    } else {
        # condition evaluated false: run the next test
        form = cdr(form); # e.g. ((else 2))
        if (!form) {
            # no more conditions?
            RET = _NIL;
            return 1;
        };
        pushcontinuation(newcondcont(form, scope));
        FORM = car(car(form)); # e.g. else, result goes to the continuation
        SCOPE = scope;
        return 1;
    };
};

definecont = func(state) {
    var form = car(state);
    var scope = cdr(state);

    assert(!scope, "can't use define in non-global scope yet!\n", 0);

    # form is the name followed by the expression: e.g. (varname (expr))
    var name = car(form);
    assert(type(name) == SYMBOL, "can't define non-symbol\n", 0);

    htput(GLOBALS, symbolname(name), RET);
    RET = _NIL;

    return 0;
};

evliscont = func(state) {
    var form = car(car(state));
    var scope = cdr(car(state));
    var arglist = cdr(state);

    # append the new value to the arglist
    var tail = arglist;
    while (cdr(tail)) tail = cdr(tail);
    setcdr(tail, cons(RET, _NIL));

    # move to the next form
    form = cdr(form);

    # now "form" contains the args we still need to evaluate
    # "scope" is the scope of the call site
    # "arglist" is the evaluations of the things that came before "form"

    # if "form" is the empty list then we've finished evaluating the arguments
    # and we now need to apply the function to its arguments
    var fn;
    if (!form) {
        # skip past the leading _NIL
        arglist = cdr(arglist);

        fn = car(arglist);
        arglist = cdr(arglist);

        if (type(fn) == BUILTIN) {
            fn = cdr(fn);
            RET = fn(arglist);
            RESTART = 1;
            return 1;
        };

        assert(type(fn) == CLOSURE, "don't know how to apply anything other than a builtin or closure (got %d)\n", [car(fn)]);

        SCOPE = buildscope(arglist, closureargs(fn), closurescope(fn));

        # execute the closure body
        begin(closurebody(fn), SCOPE);
        return 1;
    };

    # otherwise, "form" still has more to eval

    # push a continuation to consume its value
    pushcontinuation(newevliscont(form, scope, arglist));

    FORM = car(form);
    SCOPE = scope;
    return 1;
};

setcont = func(state) {
    var form = car(state);
    var scope = cdr(state);

    var name = car(form);
    assert(type(name) == SYMBOL, "can't set! of non-symbol\n", 0);

    scopeset(symbolname(name), scope, RET);

    RET = _NIL;
    return 0;
};

qqcont = func(state) {
    var got = car(state);
    var rest = car(cdr(state));
    var scope = cdr(cdr(state));

    if (got == _NIL) {
        got = cons(RET, _NIL)
    } else {
        RET = cons(car(got), RET);
        RESTART = 1;
        return 1;
    };

    # we need to push a continuation before calling quasiquote(), even though
    # we don't yet know whether or not we'll need it, so that
    # the continuations end up on CALLSTACK in the correct order
    pushcontinuation(newqqcont(got, _NIL, scope));
    if (quasiquote(rest, scope)) {
        popcontinuation(); # discard the continuation: we don't need it
        RET = cons(car(got), RET);
        RESTART = 1;
    };

    return 1;
};

macrocont = func(scope) {
    FORM = RET;
    SCOPE = scope;
    NOVALUE = 1;
    return 1;
};

begincont = func(state) {
    var form = car(state);
    var scope = cdr(state);

    if (cdr(form))
        pushcontinuation(newbegincont(cdr(form), scope));

    FORM = car(form);
    SCOPE = scope;
    NOVALUE = 1;

    return 1;
};

pushcontinuation = func(cont) {
    CALLSTACK = cons(cont, CALLSTACK);
};
popcontinuation = func() {
    assert(CALLSTACK, "can't pop from empty CALLSTACK\n", 0);
    var top = car(CALLSTACK);
    CALLSTACK = cdr(CALLSTACK);
    return top;
};

yield = func(value) {
    RET = value;
    if (!CALLSTACK) return 0;

    # pop a continuation
    var cont = popcontinuation();

    # apply the continuation
    var fnum = car(cont);
    var state = cdr(cont);

    var fn = *(contfuncs[fnum - N_mincont]);
    return fn(state);
};

### Interpreter ###

buildscope = func(arglist, namelist, parentscope) {
    var scope = parentscope;

    # XXX: special-case for empty arglist into list-consuming name
    if (type(namelist) == SYMBOL && !arglist) {
        scope = cons(cons(namelist, arglist), scope);
        return scope;
    };

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
    return scope;
};

# return 1 if form is successfully quasiquoted, with the result in RET
# return 0 if we pushed a continuation to evaluate
quasiquote = func(form, scope) {
    # non-pairs stay unchanged
    if (type(form) != PAIR) {
        RET = form;
        return 1;
    };

    # if it's an unquote, we need to eval it
    if (type(car(form)) == SYMBOL && symbolname(car(form)) == _UNQUOTE) {
        FORM = car(cdr(form));
        SCOPE = scope;
        NOVALUE = 1;
        return 0;
    };

    # otherwise, it's a pair, which get quasiquoted recursively

    pushcontinuation(newqqcont(_NIL, cdr(form), scope));
    if (quasiquote(car(form), scope)) {
        return !yield(RET);
    } else {
        return 0;
    };
};

applymacro = func(macro, form, scope) {
    # the macro has a list of argument names, a body, and a scope;
    # we need to substitute the positional args from "form" into named arguments
    # in a new scope derived from the macro's scope, evaluate the macro in the
    # new scope, and then evaluate the result in the calling scope

    var namelist = macroargs(macro);
    var arglist = cdr(form);
    SCOPE = buildscope(arglist, namelist, macroscope(macro));
    
    pushcontinuation(newmacrocont(scope));
    return begin(macrobody(macro), SCOPE);
};

begin = func(form, scope) {
    return begincont(cdr(newbegincont(form, scope)));
};

dospecial = func(form) {
    var fn = car(form);
    var name;
    var args;
    var body;
    var val;

    if (type(fn) != SYMBOL) return 0;

    # TODO: check number and type of arguments to special forms!
    if (symbolname(fn) == _QUOTE) {
        # (quote foo)
        RET = car(cdr(form));
        return 1;
    } else if (symbolname(fn) == _COND) {
        # (cond (pred1 expr1) (pred2 expr2) ...)
        form = cdr(form); # list of condition clauses: e.g. (((> n 4) 1) (else 2))
        pushcontinuation(newcondcont(form, SCOPE));
        FORM = car(car(form)); # first condition test: e.g. (> n 4), and the result will go to the continuation
        NOVALUE = 1;
        return 1;
    } else if (symbolname(fn) == _LAMBDA) {
        # (lambda (x y z) expr)
        # (lambda lst expr)
        # (lambda (x y . lst) expr)
        RET = newclosure(car(cdr(form)), cdr(cdr(form)), SCOPE);
        return 1;
    } else if (symbolname(fn) == _DEFINE) {
        # (define (fn args) expr)
        # (define varname val)
        assert(!SCOPE, "we can't yet handle define outside global scope\n", 0);

        if (type(car(cdr(form))) == SYMBOL) {
            form = cdr(form); # e.g. (varname (expr))
            pushcontinuation(newdefinecont(form, SCOPE));
            FORM = car(cdr(form));
            NOVALUE = 1;
            return 1;
        } else if (type(car(cdr(form))) == PAIR) {
            form = cdr(form); # ((fn args) expr)
            name = symbolname(car(car(form)));
            args = cdr(car(form));
            body = cdr(form);
            val = newclosure(args, body, SCOPE);
            htput(GLOBALS, name, val);
            RET = _NIL;
            return 1;
        } else {
            assert(0, "bad define\n", 0);
        };
    } else if (symbolname(fn) == _SETBANG) {
        # (set! varname val)
        form = cdr(form); # (varname val)
        pushcontinuation(newsetcont(form, SCOPE));
        FORM = car(cdr(form)); # need to evaluate "val"
        NOVALUE = 1;
        return 1;
    } else if (symbolname(fn) == _QUASIQUOTE) {
        # (quasiquote (foo bar (unquote x)))
        # x = 5
        # ==> (foo bar 5)
        form = car(cdr(form)); # (foo bar (unquote x))
        quasiquote(form, SCOPE);
        return 1;
    } else if (symbolname(fn) == _DEFMACRO) {
        # (defmacro (foo args) expr)
        assert(!SCOPE, "we can't yet handle defmacro outside global scope\n", 0);

        form = cdr(form); # ((foo args) expr)
        name = symbolname(car(car(form))); # foo
        args = cdr(car(form)); # (args)
        body = cdr(form); # (expr)
        form = newmacro(args,body,SCOPE);
        htput(GLOBALS, name, form);
        RET = _NIL;
        return 1;
    } else if (symbolname(fn) == _EVAL) {
        # (eval expr)
        FORM = car(cdr(form)); # expr
        NOVALUE = 1;
        return 1;
    } else if (symbolname(fn) == _BEGIN) {
        # (begin expr1 expr2 expr3)
        form = cdr(form); # (expr1 expr2 expr3)
        begin(form, SCOPE);
        return 1;
    } else if (type(lookup(symbolname(fn), SCOPE)) == MACRO) {
        # macro application: evaluate the macro & then evaluate its result
        applymacro(lookup(symbolname(fn), SCOPE), form, SCOPE);
        return 1;
    };

    return 0;
};

EVAL = func(form, scope) {
    FORM = form;
    SCOPE = scope;
    NOVALUE = 1;

    while (1) {
        # gc now if there are fewer than N cells remaining, and assume that that is
        # enough that we can not run out of cells until we next get back here; only
        # having 1 place that gc() can be called from during program execution makes
        # it a lot easier to make sure we don't accidentally garbage-collect parts of
        # half-constructed objects that just aren't referenced yet
        # TODO: measure the maximum number of free cells we might need
        if (freecells lt 100) gc();

        # yield the value computed by the prior iteration, if any
        if (!NOVALUE) {
            RESTART = 0;
            if (!yield(RET)) break;
            if (RESTART) continue;
        };
        NOVALUE = 0;

        assert(FORM, "can't eval the empty list\n", 0);
        if (type(FORM) == SYMBOL) {
            # symbols are looked up by name
            RET = lookup(symbolname(FORM), SCOPE);
        } else if (type(FORM) != PAIR) {
            # non-pair objects evaluate to themselves
            RET = FORM;
        } else if (dospecial(FORM)) {
            # (nothing)
        } else {
            # otherwise use an evlis continuation to evaluate the elements of
            # a list like (+ 1 2) to find the builtin "+" procedure and the values of
            # 1 and 2, and then apply the procedure to the arguments
            pushcontinuation(newevliscont(FORM, SCOPE, cons(_NIL,_NIL)));
            FORM = car(FORM);
            NOVALUE = 1;
        };
    };

    return RET;
};

### Printer ###

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
    } else if (type(form) == CONTINUATION) {
        puts("#<continuation>");
    } else if (type(form) == MACRO) {
        puts("#<macro>:(make-macro "); PRINT(macroargs(form)); puts(" "); PRINT(car(macrobody(form))); puts(")");
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

### Initialisation ###

needargs = func(num, args) {
    assert(length(args) == num, "arity mismatch\n", 0);
};

init = func() {
    newarena();

    # intern required objects
    _NIL = 0;
    _T = newsymbol("t");
    _EOF = newsymbol(""); # needs to be distinguishable from anything that can be read in

    htput(GLOBALS, "EOF", _EOF);
    htput(GLOBALS, "else", _T);

    # intern symbols for special forms
    _QUOTE = intern("quote");
    _LAMBDA = intern("lambda");
    _COND = intern("cond");
    _DEFINE = intern("define");
    _SETBANG = intern("set!");
    _QUASIQUOTE = intern("quasiquote");
    _UNQUOTE = intern("unquote");
    _DEFMACRO = intern("defmacro");
    _EVAL = intern("eval");
    _BEGIN = intern("begin");

    # load default library code
    load("/lisp/lib.l");
};

load = func(filename) {
    var port = newport(bopen(filename, O_READ));
    if (!portbuf(port)) {
        fprintf(2, "%s: can't open for reading\n", [filename]);
        exit(1);
    };
    var oldprompt = showprompt;
    var oldanswers = PRINTANSWERS;
    showprompt = 0; PRINTANSWERS = 0;
    process(port);
    showprompt = oldprompt;
    PRINTANSWERS = oldanswers;
};

process = func(port) {
    var old_in = in;
    in = port;
    htput(GLOBALS, intern("current-input-port", in));

    if (showprompt) puts("> ");
    var form;
    while (1) {
        form = READ(in);
        if (form == _EOF) break;

        form = EVAL(form, _NIL);
        if (PRINTANSWERS) {
            PRINT(form);
            putchar('\n');
        };

        assert(!CALLSTACK, "callstack not empty!\n", 0);

        if (showprompt) puts("> ");
    };

    in = old_in;
    htput(GLOBALS, intern("current-input-port", old_in));
};

init();

include "lisp-builtins.sl";

var args = cmdargs()+1;
var port;
if (*args) {
    load(*args);
} else {
    port = newport(bfdopen(0, O_READ));
    showprompt = 1; PRINTANSWERS = 1;
    process(port);
};
