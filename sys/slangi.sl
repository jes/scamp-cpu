# SLANG Interpreter

include "bufio.sl";
include "getopt.sl";
include "grarr.sl";
include "hash.sl";
include "parse.sl";
include "stdio.sl";
include "stdlib.sl";
include "strbuf.sl";
include "string.sl";

# AST
var cons3;
var cons4;
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
var DeclarationNode;
var EvalDeclarationNode;
var ConditionalNode;
var EvalConditionalNode;
var LoopNode;
var EvalLoopNode;
var VariableNode;
var EvalVariableNode;
var AddressOfNode;
var EvalAddressOfNode;
var AssignmentNode;
var EvalAssignmentNode;
var PreOpNode;
var EvalPreOpNode;
var PostOpNode;
var EvalPostOpNode;
var FunctionCallNode;
var EvalFunctionCallNode;
var ReturnNode;
var EvalReturnNode;
var ArrayLiteralNode;
var EvalArrayLiteralNode;

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
var eval_function;
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
var GLOBALS; # hash of string => address
var LOCALS; # grarr of (name, address)
var OLDLOCALS; # stack of scopes
var RETURNS; # grarr of jmpbufs
var RETURN_jmpbuf;
var RETURN_val;
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

# TODO: [perf] should this use a hash table?
var intern = func(str) {
    var v = grfind(STRINGS, str, func(find,s) { return strcmp(find,s)==0 });
    if (v) return v;
    str = strdup(str);
    grpush(STRINGS, str);
    return str;
};

var findglobal = func(name) {
    return htget(GLOBALS, name);
};

var addglobal = func(name, addr) {
    if (findglobal(name)) die("duplicate global: %s",[name]);
    htput(GLOBALS, name, addr);
};

var addexterns = func(filename) {
    var b = bopen(filename, O_READ);
    if (!b) die("can't open %s for reading\n", [filename]);

    var name;
    var addr = bgetc(b); # address
    while (bgets(b, literal_buf, maxliteral)) {
        literal_buf[strlen(literal_buf)-1] = 0; # no '\n'
        name = intern(literal_buf);
        addglobal(name, addr);
        addr = bgetc(b); # address
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

var newscope = func() {
    grpush(OLDLOCALS, LOCALS);
    LOCALS = grnew();
};

var endscope = func() {
    if (!LOCALS) die("can't end the global scope",0);
    grwalk(LOCALS, func(tuple) {
        free(tuple);
    });
    grfree(LOCALS);
    LOCALS = grpop(OLDLOCALS);
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

cons3 = func(a,b,c) {
    var p = malloc(3);
    p[0] = a; p[1] = b; p[2] = c;
    return p;
};

cons4 = func(a,b,c,d) {
    var p = malloc(4);
    p[0] = a; p[1] = b; p[2] = c; p[3] = d;
    return p;
};

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
    return cons(EvalConstNode, val);
};
EvalConstNode = func(n) {
    return n[1];
};

ArrayIndexNode = func(ptr, index) {
    return cons3(EvalArrayIndexNode, ptr, index);
};
EvalArrayIndexNode = func(n) {
    var ptr = eval(n[1]);
    var idx = eval(n[2]);
    return ptr[idx];
};

OperatorNode = func(op, arg1, arg2) {
    return cons3(op, arg1, arg2);
};

EvalAddNode = func(n) { return eval(n[1]) + eval(n[2]); };
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

DeclarationNode = func(name, expr) {
    return cons3(EvalDeclarationNode, name, expr);
};
EvalDeclarationNode = func(n) {
    var name = n[1];
    var val = eval(n[2]);
    var p = malloc(1);
    *p = val;
    if (LOCALS) {
        grpush(LOCALS, cons(name, p));
    } else {
        addglobal(name, p);
    };
};

ConditionalNode = func(cond, thenexpr, elseexpr) {
    return cons4(EvalConditionalNode, cond, thenexpr, elseexpr);
};
EvalConditionalNode = func(n) {
    var cond = n[1];
    var thenexpr = n[2];
    var elseexpr = n[3];
    if (eval(cond)) return eval(thenexpr)
    else if (elseexpr) return eval(elseexpr)
    else return 0;
};

LoopNode = func(cond, body) {
    return cons3(EvalLoopNode, cond, body);
};
EvalLoopNode = func(n) {
    var cond = n[1];
    var body = n[2];
    while (eval(cond)) if (body) eval(body);
    return 0;
};

VariableNode = func(name) {
    return cons(EvalVariableNode, name);
};
EvalVariableNode = func(n) {
    return *(EvalAddressOfNode(n));
};
AddressOfNode = func(name) {
    return cons(EvalAddressOfNode, name);
};
EvalAddressOfNode = func(n) {
    var v;
    var name = n[1];
    if (LOCALS) {
        v = findlocal(name);
        if (v) return cdr(v);
    };
    v = findglobal(name);
    if (v) return v;
    die("use of undefined name: %s\n", [name]);
};

AssignmentNode = func(addr, value) {
    return cons3(EvalAssignmentNode, addr, value);
};
EvalAssignmentNode = func(n) {
    var addr = n[1];
    var value = n[2];
    *(eval(addr)) = eval(value);
    return 0;
};

PreOpNode = func(inc, name) {
    return cons3(EvalPreOpNode, inc, AddressOfNode(name));
};
EvalPreOpNode = func(n) {
    var inc = n[1];
    var addr = eval(n[2]);
    var val = *addr;
    if (inc) val++
    else val--;
    *addr = val;
    return val;
};

PostOpNode = func(inc, name) {
    return cons3(EvalPostOpNode, inc, AddressOfNode(name));
};
EvalPostOpNode = func(n) {
    var inc = n[1];
    var addr = eval(n[2]);
    var val = *addr;
    if (inc) *addr = val + 1
    else *addr = val - 1;
    return val;
};

FunctionCallNode = func(name, args) {
    return cons3(EvalFunctionCallNode, VariableNode(name), args);
};
var do_EvalFunctionCallNode = asm {
    pop x
    ld r1, x # num args
    pop x
    ld r2, x # args pointer
    pop x
    ld r3, x # function pointer

    callnode_loop:
        test r1
        jz callnode_call

        ld x, (r2)
        push x

        dec r1
        inc r2
        jmp callnode_loop

    callnode_call:
    jmp r3
};
# TODO: [perf] do this in asm without allocating grarrs
EvalFunctionCallNode = func(n) {
    var fn = eval(n[1]);
    var argnodes = n[2];
    var argvals = grnew();
    var i = 0;
    while (i != grlen(argnodes)) {
        grpush(argvals, eval(grget(argnodes, i)));
        i++;
    };
    var r = do_EvalFunctionCallNode(fn, grbase(argvals), grlen(argvals));
    grfree(argvals);
    return r;
};

ReturnNode = func(expr) {
    return cons(EvalReturnNode, expr);
};
EvalReturnNode = func(n) {
    RETURN_val = eval(n[1]);
    longjmp(RETURN_jmpbuf, 1);
};

ArrayLiteralNode = func(exprs) {
    var base = malloc(grlen(exprs));
    return cons3(EvalArrayLiteralNode, exprs, base);
};
EvalArrayLiteralNode = func(n) {
    var exprs = n[1];
    var base = n[2];
    var i = 0;
    while (i != grlen(exprs)) {
        base[i] = eval(grget(exprs,i));
        i++;
    };
    return base;
};

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
    grpush(INCLUDED, intern(file));

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
    #addextern(intern(IDENTIFIER));
    return 1;
};

Declaration = func(x) {
    if (!Keyword("var")) return 0;
    if (BLOCKLEVEL != 0) die("var not allowed here",0);
    if (!Identifier(0)) die("var needs identifier",0);
    var name = intern(IDENTIFIER);

    if (!parse(CharSkip,'=')) return DeclarationNode(name, 0);

    var r = Expression(0);
    if (!r) die("initialisation needs expression",0);

    return DeclarationNode(name, r);
};

Conditional = func(x) {
    if (!Keyword("if")) return 0;
    BLOCKLEVEL++;
    if (!CharSkip('(')) die("if condition needs open paren",0);
    var cond = Expression(0);
    if (!cond) die("if condition needs expression",0);

    if (!CharSkip(')')) die("if condition needs close paren",0);
    var thenexpr = Statement(0);
    if (!thenexpr) die("if needs body",0);

    var endiflabel;
    var elseexpr = 0;
    if (parse(Keyword,"else")) {
        elseexpr = Statement(0);
        if (!elseexpr) die("else needs body",0);
    };
    BLOCKLEVEL--;

    return ConditionalNode(cond, thenexpr, elseexpr);
};

Loop = func(x) {
    if (!Keyword("while")) return 0;
    BLOCKLEVEL++;
    if (!CharSkip('(')) die("while condition needs open paren",0);

    var cond = Expression(0);
    if (!cond) die("while condition needs expression",0);

    if (!CharSkip(')')) die("while condition needs close paren",0);

    var body = Statement(0); # optional

    BLOCKLEVEL--;
    return LoopNode(cond, body);
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
    var r = Expression(0);
    if (!r) die("return needs expression",0);
    return ReturnNode(r);
};

Assignment = func(x) {
    var id = 0;
    var lvalue_addr;
    var rvalue;
    if (parse(Identifier,0)) {
        id = intern(IDENTIFIER);
        lvalue_addr = AddressOfNode(id);

        if (parse(CharSkip,'[')) {
            die("assignment to array index not supported!\n",0);
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
        lvalue_addr = Term(0);
        if (!lvalue_addr) die("can't dereference non-expression",0);
    };

    if (!CharSkip('=')) return 0;
    rvalue = Expression(0);
    if (!rvalue) die("assignment needs rvalue",0);

    return AssignmentNode(lvalue_addr, rvalue);
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
    if (!Identifier(0)) return 0;
    return VariableNode(intern(IDENTIFIER));
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
    var strlabel = intern(str);
    return ConstNode(strlabel);
};

# expects you to have already parsed the opening quote; consumes the closing quote
StringLiteralText = func() {
    var i = 0;
    while (i < maxliteral) {
        if (parse(Char,'"')) {
            *(literal_buf+i) = 0;
            skip();
            return intern(literal_buf);
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

    var exprs = grnew();
    var r;
    while (1) {
        r = parse(Expression, 0);
        if (!r) break;

        grpush(exprs, r);

        if (!parse(CharSkip,',')) break;
    };

    if (!CharSkip(']')) die("array literal needs close bracket",0);

    return ArrayLiteralNode(exprs);
};

Parameters = func(x) {
    var params = grnew();
    while (1) {
        if (!parse(Identifier,0)) break;
        grpush(params, intern(IDENTIFIER));
        if (!parse(CharSkip,',')) break;
    };
    return params;
};

FunctionDeclaration = func(x) {
    if (!Keyword("func")) return 0;
    if (!CharSkip('(')) die("func needs open paren",0);

    var params = Parameters(0);

    if (!CharSkip(')')) die("func needs close paren",0);

    var body = Statement(0); # optional

    var codesz = 16;
    var code_addr = malloc(codesz);

    # now we create a stub to allow normal SLANG calling convention to
    # call into the interpreter; this way interpreted functions and
    # compiled functions get called the same way, which means either one
    # can safely call the other without having to keep track of what's
    # compiled and what's interpreted.
    #
    # we need to call eval_function(argbase, params, body)
    var p = code_addr;
    *(p++) = 0x61fe; # ld x, r254
    *(p++) = 0x5a00; # push x # stash return
    *(p++) = 0x61ff; # ld x, sp
    *(p++) = 0x0602; # add x, 2
    *(p++) = 0x5a00; # push x # argbase
    *(p++) = 0x6200; *(p++) = params; # ld x, params
    *(p++) = 0x5a00; # push x # params
    *(p++) = 0x6200; *(p++) = body; # ld x, body
    *(p++) = 0x5a00; # push x # body
    *(p++) = 0x4f00; *(p++) = eval_function; # call eval_function
    *(p++) = 0x5d00; # pop x
    *(p++) = 0x69fe; # ld r254, x
    *(p++) = 0x9400 + grlen(params); # return

    if (p != code_addr+codesz) die("function body is wrong size (%d)!\n",[code_addr-p]);

    return ConstNode(code_addr);
};

InlineAsm = func(x) {
    if (!Keyword("asm")) return 0;
    die("inline asm not supported!\n",0);
};

FunctionCall = func(x) {
    if (!Identifier(0)) return 0;
    if (!CharSkip('(')) return 0;

    var name = intern(IDENTIFIER);

    var args = Arguments();
    if (!CharSkip(')')) die("argument list needs closing paren",0);

    return FunctionCallNode(name, args);
};

Arguments = func() {
    var args = grnew();
    var r;
    while (1) {
        r = parse(Expression,0);
        if (!r) return args;
        grpush(args, r);
        if (!parse(CharSkip,',')) return args;
    }
};

PreOp = func(x) {
    var inc;
    if (parse(String,"++")) {
        inc = 1;
    } else if (parse(String,"--")) {
        inc = 0;
    } else {
        return 0;
    };
    skip();
    if (!Identifier(0)) return 0;
    skip();
    return PreOpNode(inc, intern(IDENTIFIER));
};

PostOp = func(x) {
    if (!Identifier(0)) return 0;
    skip();
    var inc;
    if (parse(String,"++")) {
        inc = 1;
    } else if (parse(String,"--")) {
        inc = 0;
    } else {
        return 0;
    };
    skip();
    return PostOpNode(inc, intern(IDENTIFIER));
};

AddressOf = func(x) {
    if (!CharSkip('&')) return 0;
    if (!Identifier(0)) die("address-of (&) needs identifier",0);
    return AddressOfNode(intern(IDENTIFIER));
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

eval_function = func(argbase, params, body) {
    newscope();

    var i = 0;
    while (i != grlen(params)) {
        # note we get args in reverse order
        grpush(LOCALS, cons(grget(params,grlen(params)-i-1), argbase+i));
        i++;
    };

    var r = 0;
    RETURN_jmpbuf = malloc(3);
    grpush(RETURNS, RETURN_jmpbuf);
    if (setjmp(RETURN_jmpbuf)) {
        r = RETURN_val;
    } else {
        eval(body);
    };
    free(RETURN_jmpbuf);
    RETURN_jmpbuf = grpop(RETURNS);

    endscope();
    return r;
};

eval = func(node) {
    if (node lt 256) die("tried to eval %d\n", [node]);
    var f = node[0];
    return f(node);
};

INCLUDED = grnew();
ARRAYS = grnew();
STRINGS = grnew();
GLOBALS = htnew();
OLDLOCALS = grnew();

include "rude-globals.sl";

var printnum = func(x) { printf("*** %d\n", [x]); };
addglobal("printnum", &printnum);

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

eval(program);
