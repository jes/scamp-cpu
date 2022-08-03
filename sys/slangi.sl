# SLANG Interpreter

include "bufio.sl";
include "getopt.sl";
include "grarr.sl";
include "hash.sl";
include "parse.sl";
include "stdio.sl";
include "stdlib.sl";
include "string.sl";

# AST
var SeqNode;
var SeqAdd;
var EvalSeqNode;
var NopNode;
var EvalNopNode;
var ConstNode;
var EvalConstNode;
var ArrayIndexNode;
var EvalArrayIndexNode;
var OperatorNode;
var EvalAddNode;
var EvalSubNode;
var EvalAndNode;
var EvalOrNode;
var EvalXorNode;
var EvalLogicalAndNode;
var EvalLogicalOrNode;
var EvalEqNode;
var EvalNeNode;
var EvalLtNode;
var EvalGtNode;
var EvalLeNode;
var EvalGeNode;
var EvalUnsignedLtNode;
var EvalUnsignedGtNode;
var EvalUnsignedLeNode;
var EvalUnsignedGeNode;
var UnaryOpNode;
var EvalNotNode;
var EvalComplementNode;
var EvalValueOfNode;
var EvalNegateNode;

# Parser
var Program;
var Statements;
var Statement;
var Include;
var Block;
var Extern;
var Declaration;
var Conditional;
var Loop;
var Break;
var Continue;
var Return;
var Assignment;
var Expression;
var ExpressionLevel;
var Term;
var AnyTerm;
var Constant;
var NumericLiteral;
var HexLiteral;
var DecimalLiteral;
var CharacterLiteral;
var StringLiteral;
var StringLiteralText;
var ArrayLiteral;
var FunctionDeclaration;
var InlineAsm;
var Parameters;
var FunctionCall;
var Arguments;
var PreOp;
var PostOp;
var AddressOf;
var UnaryExpression;
var ParenExpression;
var Identifier;

### Evaluator ###
var eval;

# space to store numeric and stirng literals
var maxliteral = 512;
var literal_buf = malloc(maxliteral);
# space to store identifier value parsed by Identifier()
var maxidentifier = maxliteral;
var IDENTIFIER = literal_buf; # reuse literal_buf for identifiers

var INCLUDED;
var STRINGS;
var ARRAYS;
# EXTERNS and GLOBALS are hashes of pointers to variable names
var EXTERNS;
var GLOBALS;
# LOCALS is a grarr of pointers to tuples of (name,bp_rel)
var LOCALS;
var BP_REL;
var SP_OFF;
var NPARAMS;
var BLOCKLEVEL = 0;

var label = func(){die("don't make labels!\n", 0)};
var myputs = func(str){die("don't myputs!\n", 0)};
var myputc = func(c){die("don't myputc!\n", 0)};
var pushx = func(){die("don't push x!\n", 0)};
var popx = func(){die("don't pop x!\n", 0)};
var magnitude_op=0;
var magnitude_func=0;
var magnitude_used=0;
var plabel = func(x){die("don't plabel!\n",0)};
var OUT=0;
var BREAKLABEL = 0;
var CONTLABEL = 0;

# return 1 if "name" is a global or extern, 0 otherwise
var findglobal = func(name) {
    # TODO: [perf] would these be better the other way around?
    #              would we be better off with only one table?
    if (htgetkv(GLOBALS, name)) return 1;
    if (htgetkv(EXTERNS, name)) return 1;
    return 0;
};

var addextern = func(name) {
    if (findglobal(name)) die("duplicate global: %s",[name]);
    htput(EXTERNS, name, name);
};
var addglobal = func(name) {
    if (findglobal(name)) die("duplicate global: %s",[name]);
    htput(GLOBALS, name, name);
};

var addexterns = func(filename) {
    var b = bopen(filename, O_READ);
    if (!b) die("can't open %s for reading\n", [filename]);

    var name;
    var addr = bgetc(b); # skip the address
    while (bgets(b, literal_buf, maxliteral)) {
        literal_buf[strlen(literal_buf)-1] = 0; # no '\n'
        name = strdup(literal_buf);
        htput(EXTERNS, name, name);
        addr = bgetc(b); # skip the address
    };
    bclose(b);
};

# return pointer to (name,bp_rel) if "name" is a local, 0 otherwise
var findlocal = func(name) {
    if (!LOCALS) die("can't find local in global scope: %s",[name]);
    return grfind(LOCALS, name, func(findname,tuple) { return strcmp(findname,car(tuple))==0 });
};
var addlocal = func(name, bp_rel) {
    if (!LOCALS) die("can't add local in global scope: %s",[name]);

    if (findlocal(name)) die("duplicate local: %s",[name]);

    var tuple = cons(name,bp_rel);
    grpush(LOCALS, tuple);
    return tuple;
};

var addstring = func(str) {
    var v = grfind(STRINGS, str, func(find,tuple) { return strcmp(find,car(tuple))==0 });
    if (v) return cdr(v);

    var l = label();
    grpush(STRINGS, cons(str,l));
    return l;
};

var newscope = func() {
    LOCALS = grnew();
    BP_REL = -1;
};

var endscope = func() {
    if (!LOCALS) die("can't end the global scope",0);
    grwalk(LOCALS, func(tuple) {
        var name = car(tuple);
        free(name);
        free(tuple);
    });
    grfree(LOCALS);
};

var pushvar = func(name) {
    var v;
    var bp_rel;
    if (LOCALS) {
        v = findlocal(name);
        if (v) {
            bp_rel = cdr(v);
            myputs("ld x, "); myputs(itoa(bp_rel-SP_OFF)); myputs("(sp)\n");
            pushx();
            return 0;
        };
    };

    if (findglobal(name)) {
        myputs("ld x, (_"); myputs(name); myputs(")\n");
        pushx();
        return 0;
    };

    die("unrecognised identifier: %s",[name]);
};
var poptovar = func(name) {
    var v;
    var bp_rel;
    if (LOCALS) {
        v = findlocal(name);
        if (v) {
            bp_rel = cdr(v);
            myputs("ld y, "); myputs(itoa(bp_rel-SP_OFF)); myputs("+sp\n");
            popx();
            myputs("ld (y), x\n");
            return 0;
        };
    };

    if (findglobal(name)) {
        popx();
        myputs("ld (_"); myputs(name); myputs("), x\n");
        return 0;
    };

    die("unrecognised identifier: %s",[name]);
};

var genliteral = func(v) {
    if ((v&0xff00)==0 || (v&0xff00)==0xff00) {
        myputs("push "); myputs(itoa(v)); myputs("\n");
        SP_OFF--;
    } else {
        myputs("ld x, "); myputs(itoa(v)); myputs("\n");
        pushx();
    };
};

var genop = func(op) {
    var i;
    if ((*op == '>') || (*op == '<') || (*op == 'g') || (*op == 'l')) {
        i = 0;
        while (i != 8) {
            if (strcmp(magnitude_op[i], op) == 0) {
                myputs("call "); plabel(magnitude_func[i]); myputs("\n");
                SP_OFF++; # 2 args consumed, 1 result pushed
                magnitude_used[i] = 1;
                return 0;
            };
            i++;
        };
    };

    popx();
    myputs("ld r0, x\n");
    popx();

    var end;

    if (strcmp(op,"+") == 0) {
        myputs("add x, r0\n");
    } else if (strcmp(op,"-") == 0) {
        myputs("sub x, r0\n");
    } else if (strcmp(op,"&") == 0) {
        myputs("and x, r0\n");
    } else if (strcmp(op,"|") == 0) {
        myputs("or x, r0\n");
    } else if (strcmp(op,"^") == 0) {
        myputs("ld r1, r254\n"); # xor clobbers r254
        myputs("ld y, r0\n");
        myputs("xor x, y\n");
        myputs("ld r254, r1\n");
    } else if (strcmp(op,"!=") == 0) {
        end = label();
        myputs("sub x, r0 #peepopt:test\n");
        myputs("jz "); plabel(end); myputs("\n");
        myputs("ld x, 1\n");
        plabel(end); myputs(":\n");
    } else if (strcmp(op,"==") == 0) {
        end = label();
        myputs("sub x, r0 #peepopt:test\n");
        myputs("ld x, 0\n"); # doesn't clobber flags
        myputs("jnz "); plabel(end); myputs("\n");
        myputs("ld x, 1\n");
        plabel(end); myputs(":\n");
    } else if (strcmp(op,"&&") == 0) {
        end = label();
        myputs("test x\n");
        myputs("ld x, 0\n"); # doesn't clobber flags
        myputs("jz "); plabel(end); myputs("\n");
        myputs("test r0\n");
        myputs("jz "); plabel(end); myputs("\n");
        myputs("ld x, 1\n"); # both args true: x=1
        plabel(end); myputs(":\n");
    } else if (strcmp(op,"||") == 0) {
        end = label();
        myputs("test x\n");
        myputs("ld x, 1\n"); # doesn't clobber flags
        myputs("jnz "); plabel(end); myputs("\n");
        myputs("test r0\n");
        myputs("jnz "); plabel(end); myputs("\n");
        myputs("ld x, 0\n"); # both args false: x=0
        plabel(end); myputs(":\n");
    } else {
        myputs("bad op: "); myputs(op); myputs("\n");
        die("unrecognised binary operator %s (probably a compiler bug)",[op]);
    };

    pushx();
};

var make_magnitude_functions = func() {
    var signcmp = func(subxr0, match, wantlt) {
        var wantgt = !wantlt;
        var nomatch = !match;

        myputs("pop x\n");
        myputs("ld r0, x\n");
        myputs("and x, 32768 #peepopt:test\n");
        myputs("ld r1, x\n");

        myputs("pop x\n");
        myputs("and x, 32768 #peepopt:test\n");

        # subtract 2nd argument from first, if result is less than zero, then 2nd
        # argument is bigger than first
        var lt = label();
        var docmp = label();

        myputs("sub r1, x #peepopt:test\n");
        myputs("jz "); plabel(docmp); myputs("\n"); # only directly compare x and r0 if they're both negative or both positive

        # just compare signs
        myputs("test x\n");
        bprintf(OUT, "ld x, %d\n", [wantlt]); # doesn't clobber flags
        myputs("jnz "); plabel(lt); myputs("\n");
        bprintf(OUT, "ld x, %d\n", [wantgt]); # doesn't clobber flags
        myputs("jmp "); plabel(lt); myputs("\n");

        # do the actual magnitude comparison
        plabel(docmp); myputs(":\n");
        myputs("ld x, (sp)\n");
        if (subxr0) myputs("sub x, r0 #peepopt:test\n")
        else        myputs("sub r0, x #peepopt:test\n");
        bprintf(OUT, "ld x, %d\n", [match]); # doesn't clobber flags
        myputs("jlt "); plabel(lt); myputs("\n");
        bprintf(OUT, "ld x, %d\n", [nomatch]);
        plabel(lt); myputs(":\n");

        myputs("push x\n");
        myputs("ret\n");
    };

    # >, <, >=, <=, gt, lt, ge, le
    var subxr0 = [0,1,1,0,0,1,1,0];
    var match = [1,1,0,0,1,1,0,0];
    var wantlt = [0,1,0,1,1,0,1,0];
    var i = 0;
    while (i < 8) {
        if (magnitude_used[i]) {
            plabel(magnitude_func[i]); myputs(":\n");
            signcmp(subxr0[i], match[i], wantlt[i]);
        };
        i++;
    };
};

var funcreturn = func() {
    if (!LOCALS) die("can't return from global scope",0);

    # here we make use of the "add" instruction's clobber of the X register;
    # "add sp, N" can be fulfilled with either "add (i16), i8l" or "add r, i16";
    # in both cases, the X register is left containing the value of sp *prior*
    # to the addition, so we then use "jmp i8l(x)" to jump to an address grabbed
    # from the stack, at a point relative to where the *previous* stack pointer
    # pointed
    myputs("add sp, "); myputs(itoa(NPARAMS-BP_REL)); myputs(" #peepopt:xclobber\n");
    myputs("jmp "); myputs(itoa(-BP_REL)); myputs("(x)\n");
};

### AST ###

SeqNode = func() {
    return cons(EvalSeqNode, grnew());
};

SeqAdd = func(seq, n) {
    grpush(seq[1], n);
};

EvalSeqNode = func(n) {
    var gr = n[1];
    var i = 0;
    var r;
    while (i != grlen(gr)) {
        r = eval(grget(gr, i));
        i++;
    };
    return 0;
};

NopNode = func() {
    return [EvalNopNode];
};
EvalNopNode = func(n) {
    return 0;
};

ConstNode = func(val) {
    printf("ConstNode(%d)\n", [val]);
    return cons(EvalConstNode, val);
};
EvalConstNode = func(n) {
    return n[1];
};

ArrayIndexNode = func(ptr, index) {
    var n = malloc(3);
    n[0] = EvalArrayIndexNode;
    n[1] = ptr;
    n[2] = index;
    return n;
};
EvalArrayIndexNode = func(n) {
    var ptr = eval(n[1]);
    var idx = eval(n[2]);
    return ptr[idx];
};

OperatorNode = func(op, arg1, arg2) {
    printf("operatornode: %d op %d; op = 0x%04x; add=0x%04x\n", [arg1, arg2, op, EvalAddNode]);
    var n = malloc(3);
    n[0] = op;
    n[1] = arg1;
    n[2] = arg2;
    return n;
};

EvalAddNode = func(n) { printf("%d+%d\n", [n[1], n[2]]); return eval(n[1]) + eval(n[2]); };
EvalSubNode = func(n) { return eval(n[1]) - eval(n[2]); };
EvalAndNode = func(n) { return eval(n[1]) & eval(n[2]); };
EvalOrNode = func(n) { return eval(n[1]) | eval(n[2]); };
EvalLogicalAndNode = func(n) { return eval(n[1]) && eval(n[2]); };
EvalLogicalOrNode = func(n) { return eval(n[1]) || eval(n[2]); };
EvalEqNode = func(n) { return eval(n[1]) == eval(n[2]); };
EvalNeNode = func(n) { return eval(n[1]) != eval(n[2]); };
EvalLtNode = func(n) { return eval(n[1]) < eval(n[2]); };
EvalGtNode = func(n) { return eval(n[1]) > eval(n[2]); };
EvalLeNode = func(n) { return eval(n[1]) <= eval(n[2]); };
EvalGeNode = func(n) { return eval(n[1]) >= eval(n[2]); };
EvalUnsignedLtNode = func(n) { return eval(n[1]) lt eval(n[2]); };
EvalUnsignedGtNode = func(n) { return eval(n[1]) gt eval(n[2]); };
EvalUnsignedLeNode = func(n) { return eval(n[1]) le eval(n[2]); };
EvalUnsignedGeNode = func(n) { return eval(n[1]) ge eval(n[2]); };

UnaryOpNode = func(op, arg1) {
    return cons(op, arg1);
};
EvalNotNode = func(n) { return !eval(n[1]); };
EvalComplementNode = func(n) { return ~eval(n[1]); };
EvalValueOfNode = func(n) { return *(eval(n[1])); };
EvalNegateNode = func(n) { return -eval(n[1]); };

### Parser ###

Program = func(x) {
    skip();
    return Statements(0);
};

Statements = func(x) {
    var seq = SeqNode();
    var r;
    while (1) {
        r = parse(Statement, 0);
        if (!r) return seq;
        SeqAdd(seq, r);
        if (!parse(CharSkip,';')) return seq;
    };
};

Statement = func(x) {
    var ch = peekchar();
    var r;
    if (ch == 'i') {
        r = parse(Include,0); if (r) return r;
        r = parse(Conditional,0); if (r) return r;
    } else if (ch == '{') {
        r = Block(0);
        if (r) return r
        else die("curly brace has to start block",0);
    } else if (ch == 'e') {
        r = parse(Extern,0); if (r) return r;
    } else if (ch == 'v') {
        r = parse(Declaration,0); if (r) return r;
    } else if (ch == 'w') {
        r = parse(Loop,0); if (r) return r;
    } else if (ch == 'b') {
        r = parse(Break,0); if (r) return r;
    } else if (ch == 'c') {
        r = parse(Continue,0); if (r) return r;
    } else if (ch == 'r') {
        r = parse(Return,0); if (r) return r;
    };
    r = parse(Assignment,0); if (r) return r;
    r = Expression(0); if (r) return r;
    return 0;
};

var open_include = func(file, path) {
    var lenpath = strlen(path);
    var fullpath = malloc(lenpath+strlen(file)+1);
    strcpy(fullpath, path);
    strcpy(fullpath+lenpath, file);

    var fd = open(fullpath, O_READ);

    free(fullpath);
    return fd;
};

var include_fd;
var include_inbuf;
Include = func(x) {
    if (!Keyword("include")) return 0;
    die("include not implemented!\n",0);
    if (!Char('"')) return 0;
    var file = StringLiteralText();

    # don't include the same file twice
    if (grfind(INCLUDED, file, func(a,b) { return strcmp(a,b)==0 })) return 1;
    grpush(INCLUDED, strdup(file));

    # save parser state
    var pos0 = pos;
    var readpos0 = readpos;
    var line0 = line;
    var parse_getchar0 = parse_getchar;
    var parse_filename0 = parse_filename;
    var include_fd0 = include_fd;
    var ringbuf0 = malloc(ringbufsz);
    var include_inbuf0 = include_inbuf;
    memcpy(ringbuf0, ringbuf, ringbufsz);

    include_fd = open(file, O_READ);
    if (include_fd < 0) include_fd = open_include(file, "/lib/");
    if (include_fd < 0) include_fd = open_include(file, "/src/lib/");
    if (include_fd < 0) die("can't open %s: %s", [file, strerror(include_fd)]);

    include_inbuf = bfdopen(include_fd, O_READ);
    parse_init(func() {
        return bgetc(include_inbuf);
    });
    parse_filename = strdup(file);

    # parse the included file
    if (!Program(0)) die("expected statements",0);

    bclose(include_inbuf);

    # restore parser state
    pos = pos0;
    readpos = readpos0;
    line = line0;
    parse_getchar = parse_getchar0;
    free(parse_filename);
    parse_filename = parse_filename0;
    include_fd = include_fd0;
    memcpy(ringbuf, ringbuf0, ringbufsz);
    free(ringbuf0);
    include_inbuf = include_inbuf0;

    return 1;
};

Block = func(x) {
    if (!CharSkip('{')) return 0;
    var r = Statements(0);
    if (!CharSkip('}')) die("block needs closing brace",0);
    return r;
};

Extern = func(x) {
    if (!Keyword("extern")) return 0;
    die("extern not implemented!\n", 0);
    if (!Identifier(0)) die("extern needs identifier",0);
    addextern(strdup(IDENTIFIER));
    return 1;
};

Declaration = func(x) {
    if (!Keyword("var")) return 0;
    die("declarations not implemented!\n", 0);
    if (BLOCKLEVEL != 0) die("var not allowed here",0);
    if (!Identifier(0)) die("var needs identifier",0);
    var name = strdup(IDENTIFIER);
    if (!LOCALS) {
        addglobal(name);
    } else {
        addlocal(name, BP_REL--);
    };
    # for locals, if there's no initialiser, just decrement sp
    if (!parse(CharSkip,'=')) {
        if (LOCALS) {
            myputs("dec sp\n");
            SP_OFF--;
        };
        return 1;
    };
    # otherwise, we implicitly allocate space for $id by *not* popping
    # the result of evaluating the expression:

    if (!Expression(0)) die("initialisation needs expression",0);
    if (!LOCALS) poptovar(name);
    # TODO: [perf] if 'name' is a global, and the expression was a constant
    #       (e.g. it's a function, inline asm, string, array literal, etc.) then
    #       we should try to initialise it at compile-time instead of by
    #       generating runtime code with poptovar()
    return 1;
};

Conditional = func(x) {
    if (!Keyword("if")) return 0;
    die("conditionals not implemented!\n", 0);
    BLOCKLEVEL++;
    if (!CharSkip('(')) die("if condition needs open paren",0);
    if (!Expression(0)) die("if condition needs expression",0);

    # if top of stack is 0, jmp falselabel
    var falselabel = label();
    popx();
    myputs("test x\n");
    myputs("jz "); plabel(falselabel); myputs("\n");

    if (!CharSkip(')')) die("if condition needs close paren",0);
    if (!Statement(0)) die("if needs body",0);

    var endiflabel;
    if (parse(Keyword,"else")) {
        endiflabel = label();
        myputs("jmp L"); myputs(itoa(endiflabel)); myputs("\n");
        plabel(falselabel); myputs(":\n");
        if (!Statement(0)) die("else needs body",0);
        plabel(endiflabel); myputs(":\n");
    } else {
        plabel(falselabel); myputs(":\n");
    };
    BLOCKLEVEL--;
    return 1;
};

Loop = func(x) {
    if (!Keyword("while")) return 0;
    die("loops not implemented!\n", 0);
    BLOCKLEVEL++;
    if (!CharSkip('(')) die("while condition needs open paren",0);

    var oldbreaklabel = BREAKLABEL;
    var oldcontlabel = CONTLABEL;
    var loop = label();
    var endloop = label();

    BREAKLABEL = endloop;
    CONTLABEL = loop;

    plabel(loop); myputs(":\n");

    if (!Expression(0)) die("while condition needs expression",0);

    # if top of stack is 0, jmp endloop
    popx();
    myputs("test x\n");
    myputs("jz "); plabel(endloop); myputs("\n");

    if (!CharSkip(')')) die("while condition needs close paren",0);

    Statement(0); # optional
    myputs("jmp "); plabel(loop); myputs("\n");
    plabel(endloop); myputs(":\n");

    BREAKLABEL = oldbreaklabel;
    CONTLABEL = oldcontlabel;
    BLOCKLEVEL--;
    return 1;
};

Break = func(x) {
    if (!Keyword("break")) return 0;
    die("break not implemented!\n", 0);
    if (!BREAKLABEL) die("can't break here",0);
    myputs("jmp "); plabel(BREAKLABEL); myputs("\n");
    return 1;
};

Continue = func(x) {
    if (!Keyword("continue")) return 0;
    die("continue not implemented!\n",0);
    if (!CONTLABEL) die("can't continue here",0);
    myputs("jmp "); plabel(CONTLABEL); myputs("\n");
    return 1;
};

Return = func(x) {
    if (!Keyword("return")) return 0;
    die("return not implemented!\n",0);
    if (!Expression(0)) die("return needs expression",0);
    popx();
    myputs("ld r0, x\n");
    funcreturn();
    return 1;
};

Assignment = func(x) {
    var id = 0;
    if (parse(Identifier,0)) {
        id = strdup(IDENTIFIER);

        if (parse(CharSkip,'[')) {
            # array assignment: "a[x] = ..."; we need to put a+x on the stack and
            # unset "id" so that we get pointer assignment code

            # first put a on the stack
            pushvar(id);
            id = 0;

            while (1) {
                # now put the index on the stack
                if (!Expression(0)) die("array index needs expression",0);
                if (!CharSkip(']')) die("array index needs close bracket",0);

                # and add them together
                popx();
                myputs("ld r0, x\n");
                popx();
                myputs("add x, r0\n");

                if (!parse(CharSkip,'[')) {
                    pushx();
                    break;
                };

                # looping around for another level: dereference this pointer
                myputs("ld x, (x)\n");
                pushx();
            };
        };
    } else {
        if (!CharSkip('*')) return 0;
        if (!Term(0)) die("can't dereference non-expression",0);
    };
    if (!CharSkip('=')) return 0;
    die("assignment not implemented!\n",0);
    if (!Expression(0)) die("assignment needs rvalue",0);

    if (id) {
        poptovar(id);
        free(id);
    } else {
        popx();
        myputs("ld r0, x\n");
        popx();
        myputs("ld (x), r0\n");
    };
    return 1;
};

Expression = func(x) { return ExpressionLevel(0); };

var operators = [
    ["&", "|", "^"],
    ["&&", "||"],
    ["==", "!=", ">=", "<=", ">", "<", "lt", "gt", "le", "ge"],
    ["+", "-"],
];
var operatorevals = [
    [EvalAndNode, EvalOrNode, EvalXorNode],
    [EvalLogicalAndNode, EvalLogicalOrNode],
    [EvalEqNode, EvalNeNode, EvalGeNode, EvalLeNode, EvalGtNode, EvalLtNode, EvalUnsignedLtNode, EvalUnsignedGtNode, EvalUnsignedLeNode, EvalUnsignedGeNode],
    [EvalAddNode, EvalSubNode],
];
ExpressionLevel = func(lvl) {
    if (!operators[lvl]) return Term(0);

    var apply_op = 0;
    var apply_op_eval = 0;
    var p;
    var e;
    var r;
    var node;
    while (1) {
        r = parse(ExpressionLevel, lvl+1);
        if (apply_op) {
            if (!r) die("operator %s needs a second operand",[apply_op]);
            node = OperatorNode(apply_op_eval, node, r);
        } else {
            if (!r) return 0;
            node = r;
        };

        p = operators[lvl]; # p points to an array of pointers to strings
        e = operatorevals[lvl]; # e points to an array of pointers to eval'ers
        while (*p) {
            if (parse(String,*p)) break;
            p++; e++;
        };
        if (!*p) return node;
        apply_op = *p;
        apply_op_eval = *e;
        skip();
    };
};

Term = func(x) {
    var r;
    r = AnyTerm(0); if (!r) return 0;
    var ind;
    while (1) { # index into array
        if (!parse(CharSkip,'[')) break;
        die("array indexing not implemented!\n",0);
        ind = Expression(0);
        if (!ind) die("array index needs expression",0);
        r = ArrayIndexNode(r, ind);
        if (!CharSkip(']')) die("array index needs close bracket",0);
    };
    return r;
};

AnyTerm = func(x) {
    var r;
    r = parse(Constant,0); if (r) return r;
    r = parse(FunctionCall,0); if (r) return r;
    r = parse(AddressOf,0); if (r) return r;
    r = parse(PreOp,0); if (r) return r;
    r = parse(PostOp,0); if (r) return r;
    r = parse(UnaryExpression,0); if (r) return r;
    r = parse(ParenExpression,0); if (r) return r;
    r = Identifier(0);
    if (!r) return 0;
    die("identifiers not implemented!\n", 0);
    pushvar(IDENTIFIER);
    return 1;
};

Constant = func(x) {
    var r;
    r = parse(NumericLiteral,0); if (r) return r;
    r = parse(StringLiteral,0); if (r) return r;
    r = parse(ArrayLiteral,0); if (r) return r;
    r = parse(FunctionDeclaration,0); if (r) return r;
    r = InlineAsm(0); if (r) return r;
    return 0;
};

NumericLiteral = func(x) {
    var r;
    r = parse(HexLiteral,0); if (r) return r;
    r = parse(CharacterLiteral,0); if (r) return r;
    r = DecimalLiteral(0); if (r) return r;
    return 0;
};

var NumLiteral = func(alphabet,base,neg) {
    *literal_buf = peekchar();
    if (!AnyChar(alphabet)) return 0;
    var i = 1;
    var val;
    while (i < maxliteral) {
        *(literal_buf+i) = peekchar();
        if (!parse(AnyChar,alphabet)) {
            *(literal_buf+i) = 0;
            skip();
            if (neg) return ConstNode(-atoibase(literal_buf,base))
            else     return ConstNode( atoibase(literal_buf,base));
        };
        i++;
    };
    die("numeric literal too long",0);
};

HexLiteral = func(x) {
    if (!String("0x")) return 0;
    return NumLiteral("0123456789abcdefABCDEF",16,0);
};

DecimalLiteral = func(x) {
    var neg = peekchar() == '-';
    parse(AnyChar,"+-");
    return NumLiteral("0123456789",10,neg);
};

var escapedchar = func(ch) {
    if (ch == 'r') return '\r';
    if (ch == 'n') return '\n';
    if (ch == 't') return '\t';
    if (ch == '0') return '\0';
    if (ch == ']') return '\]';
    return ch;
};

CharacterLiteral = func(x) {
    if (!Char('\'')) return 0;
    var ch = nextchar();
    if (ch == '\\') {
        ch = escapedchar(nextchar());
    };
    if (CharSkip('\'')) return ConstNode(ch);
    die("illegal character literal",0);
};

StringLiteral = func(x) {
    if (!Char('"')) return 0;
    var str = StringLiteralText();
    var strlabel = addstring(str);
    myputs("ld x, "); plabel(strlabel); myputs("\n");
    pushx();
    return 1;
};

# expects you to have already parsed the opening quote; consumes the closing quote
StringLiteralText = func() {
    var i = 0;
    while (i < maxliteral) {
        if (parse(Char,'"')) {
            *(literal_buf+i) = 0;
            skip();
            return strdup(literal_buf);
        };
        if (parse(Char,'\\')) {
            *(literal_buf+i) = escapedchar(nextchar());
        } else {
            *(literal_buf+i) = nextchar();
        };
        i++;
    };
    die("string literal too long",0);
};

ArrayLiteral = func(x) {
    if (!CharSkip('[')) return 0;

    var l = label();
    var length = 0;

    while (1) {
        if (!parse(Expression,0)) break;

        # TODO: [perf] this loads to a constant address, we should make the assembler
        # allow us to calculate it at assembly time like:
        #   ld (l+length), x
        myputs("ld r0, "); plabel(l); myputs("\n");
        myputs("add r0, "); myputs(itoa(length)); myputs("\n");
        popx();
        myputs("ld (r0), x\n");

        length++;
        if (!parse(CharSkip,',')) break;
    };

    if (!CharSkip(']')) die("array literal needs close bracket",0);

    myputs("ld x, "); plabel(l); myputs("\n");
    pushx();

    grpush(ARRAYS, cons(l,length));
    return 1;
};

var maxparams = 32;
var PARAMS = malloc(maxparams);
Parameters = func(x) {
    var p = PARAMS;
    while (1) {
        if (!parse(Identifier,0)) break;
        *(p++) = strdup(IDENTIFIER);
        if (p == PARAMS+maxparams) die("too many params for function",0);
        if (!parse(CharSkip,',')) break;
    };
    *p = 0;
    return PARAMS;
};

FunctionDeclaration = func(x) {
    if (!Keyword("func")) return 0;
    if (!CharSkip('(')) die("func needs open paren",0);

    var params = Parameters(0);
    var functionlabel = label();
    var functionend = label();
    myputs("jmp "); plabel(functionend); myputs("\n");
    plabel(functionlabel); myputs(":\n");

    var old_sp_off = SP_OFF;
    SP_OFF = 0;

    myputs("ld x, r254\n");
    pushx();

    var oldscope = LOCALS;
    var old_bp_rel = BP_REL;
    var oldnparams = NPARAMS;
    newscope();

    var bp_rel = 1; # parameters (grows up)
    var p = params;
    while (*p) p++;
    # p now points past the last param
    NPARAMS = p - params;
    while (p-- > params)
        addlocal(*p, bp_rel++);

    if (!CharSkip(')')) die("func needs close paren",0);
    var blocklevel = BLOCKLEVEL;
    var breaklabel = BREAKLABEL;
    var contlabel = CONTLABEL;
    BLOCKLEVEL = 0; BREAKLABEL = 0; CONTLABEL = 0;
    Statement(0); # optional
    BLOCKLEVEL = blocklevel; BREAKLABEL = breaklabel; CONTLABEL = contlabel;

    funcreturn();
    endscope();
    LOCALS = oldscope;
    BP_REL = old_bp_rel;
    NPARAMS = oldnparams;
    SP_OFF = old_sp_off;

    plabel(functionend); myputs(":\n");
    myputs("ld x, "); plabel(functionlabel); myputs("\n");
    pushx();
    return 1;
};

InlineAsm = func(x) {
    if (!Keyword("asm")) return 0;
    if (!CharSkip('{')) return 0;

    var end = label();
    var asm = label();
    myputs("jmp "); plabel(end); myputs("\n");
    plabel(asm); myputs(":\n");

    myputs("#peepopt:off\n");
    var ch;
    while (1) {
        ch = nextchar();
        if (ch == EOF) die("eof inside asm block",0);
        if (ch == '}') break;
        myputc(ch);
    };
    myputs("\n");
    myputs("#peepopt:on\n");

    plabel(end); myputs(":\n");
    myputs("ld x, "); plabel(asm); myputs("\n");
    pushx();
    return 1;
};

FunctionCall = func(x) {
    if (!Identifier(0)) return 0;
    if (!CharSkip('(')) return 0;

    var name = strdup(IDENTIFIER);

    var nargs = Arguments();
    if (!CharSkip(')')) die("argument list needs closing paren",0);

    pushvar(name);
    free(name);
    # call function
    popx();
    myputs("call x\n");
    # arguments have been consumed
    SP_OFF = SP_OFF + nargs;
    # push return value
    myputs("ld x, r0\n");
    pushx();

    return 1;
};

Arguments = func() {
    var n = 0;
    while (1) {
        if (!parse(Expression,0)) return n;
        n++;
        if (!parse(CharSkip,',')) return n;
    }
};

PreOp = func(x) {
    var op;
    if (parse(String,"++")) {
        op = "inc";
    } else if (parse(String,"--")) {
        op = "dec";
    } else {
        return 0;
    };
    die("preop not implemented!\n", 0);
    skip();
    if (!Identifier(0)) return 0;
    skip();
    pushvar(IDENTIFIER);
    popx();
    myputs(op); myputs(" x\n");
    pushx();
    poptovar(IDENTIFIER);
    pushx();
    return 1;
};

PostOp = func(x) {
    if (!Identifier(0)) return 0;
    skip();
    var op;
    if (parse(String,"++")) {
        op = "inc";
    } else if (parse(String,"--")) {
        op = "dec";
    } else {
        return 0;
    };
    die("postop not implemented!\n", 0);
    skip();
    pushvar(IDENTIFIER);
    popx();
    pushx();
    myputs(op); myputs(" x\n");
    pushx();
    poptovar(IDENTIFIER);
    return 1;
};

AddressOf = func(x) {
    if (!CharSkip('&')) return 0;
    if (!Identifier(0)) die("address-of (&) needs identifier",0);

    var v;
    var bp_rel;
    if (LOCALS) {
        v = findlocal(IDENTIFIER);
        if (v) {
            bp_rel = cdr(v);
            myputs("ld x, sp\n");
            myputs("add x, "); myputs(itoa(bp_rel-SP_OFF)); myputs("\n");
            pushx();
            return 1;
        };
    };

    if (findglobal(IDENTIFIER)) {
        myputs("ld x, _"); myputs(IDENTIFIER); myputs("\n");
        pushx();
        return 1;
    };

    die("unrecognised identifier: %s",[IDENTIFIER]);

    return 1;
};

UnaryExpression = func(x) {
    var op = peekchar();
    if (!AnyChar("!~*+-")) return 0;
    skip();
    var r = Term(0);
    if (!r) die("unary operator %c needs operand",[op]);

    if (op == '~') {
        return UnaryOpNode(EvalComplementNode, r);
    } else if (op == '-') {
        return UnaryOpNode(EvalNegateNode, r);
    } else if (op == '!') {
        return UnaryOpNode(EvalNotNode, r);
    } else if (op == '+') {
        return r;
    } else if (op == '*') {
        return UnaryOpNode(EvalValueOfNode, r);
    } else {
        die("unrecognised unary operator %c (probably a compiler bug)",[op]);
    };
    die("wut",0);
};

ParenExpression = func(x) {
    if (!CharSkip('(')) return 0;
    var r = Expression(0);
    if (CharSkip(')')) return r;
    return 0;
};

Identifier = func(x) {
    *IDENTIFIER = peekchar();
    if (!AlphaUnderChar(0)) return 0;
    var i = 1;
    while (i < maxidentifier) {
        *(IDENTIFIER+i) = peekchar();
        if (!parse(AlphanumUnderChar,0)) {
            *(IDENTIFIER+i) = 0;
            skip();
            return 1;
        };
        i++;
    };
    die("identifier too long",0);
};

### Evaluator ###

eval = func(node) {
    printf("eval 0x%04x\n", [node]);
    if (node lt 256) die("tried to eval %d\n", [node]);
    var f = node[0];
    var r = f(node);
    printf(" = %d\n", [r]);
    return r;
};

INCLUDED = grnew();
ARRAYS = grnew();
STRINGS = grnew();
EXTERNS = htnew();
GLOBALS = htnew();

# input buffering
var inbuf = bfdopen(0, O_READ);

parse_init(func() {
    return bgetc(inbuf);
});
var program = parse(Program,0);

if (nextchar() != EOF) die("garbage after end of program",0);
if (LOCALS) die("expected to be left in global scope after program",0);
if (BLOCKLEVEL != 0) die("expected to be left at block level 0 after program (probably a compiler bug)",0);
if (SP_OFF != 0) die("expected to be left at SP_OFF==0 after program, found %d (probably a compiler bug)",[SP_OFF]);
if (!program) die("parsed AST is null pointer",0);

printf("%d\n", [eval(program)]);
