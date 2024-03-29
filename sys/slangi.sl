# SLANG Interpreter

include "bigint.sl";
include "bitmap.sl";
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
var SeqNode;
var NopNode;
var EvalNopNode;
var ConstNode;
var isConstNode;
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
var ConditionalNode;
var EvalConditionalNode;
var EvalConditionalNodeWithElse;
var LoopNode;
var EvalLoopNode;
var VariableNode;
var AddressOfNode;
var LocalNode;
var EvalLocalNode;
var GlobalNode;
var EvalGlobalNode;
var AddressOfLocalNode;
var EvalAddressOfLocalNode;
var AddressOfGlobalNode;
var IndexAddressOfNode;
var EvalIndexAddressOfNode;
var AssignmentNode;
var EvalAssignmentNode;
var PreOpNode;
var EvalPreOpNode;
var PostOpNode;
var EvalPostOpNode;
var FunctionCallNode;
var ReturnNode;
var EvalReturnNode;
var ArrayLiteralNode;
var EvalArrayLiteralNode;
var BreakNode;
var EvalBreakNode;
var ContinueNode;
var EvalContinueNode;

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
var GLOBALS; # hash of string => address
var LOCALSTACK = malloc(2048);
var LOCALS; # grarr of (name, address) (compile-time only)
var OLDLOCALS; # stack of scopes
var BP; # current stack base pointer
var BPS; # grarr of base pointers
var RETURN_jmpbuf;
var RETURN_val;
var BREAK_jmpbuf;
var CONTINUE_jmpbuf;
var BLOCKLEVEL = 0;
var LOOPLEVEL = 0;

const arenasz = 512;
const arenamax = 32;
var arenaspace = arenasz;
var arena = malloc(arenasz);

var aalloc = func(sz) {
    if (sz > arenamax) return malloc(sz);
    arenaspace = arenaspace - sz;
    if (arenaspace < 0) {
        arena = malloc(arenasz);
        arenaspace = arenasz - sz;
    };
    var p = arena;
    arena = arena + sz;
    return p;
};

var acons = func(a,b) {
    var p = aalloc(2);
    p[0] = a;
    p[1] = b;
    return p;
};
var acons3 = func(a,b,c) {
    var p = aalloc(3);
    p[0] = a;
    p[1] = b;
    p[2] = c;
    return p;
};
var acons4 = func(a,b,c,d) {
    var p = aalloc(4);
    p[0] = a;
    p[1] = b;
    p[2] = c;
    p[3] = d;
    return p;
};

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

# return pointer to (name,bp_reg) if "name" is a local, 0 otherwise
var findlocal = func(name) {
    if (!LOCALS) return 0;
    return grfind(LOCALS, name, func(findname,tuple) { return strcmp(findname,car(tuple))==0 });
};

var addlocal = func(name) {
    grpush(LOCALS, cons(name, grlen(LOCALS)));
};

#var lsalloc = func(sz) {
#    var p = LOCALSTACK;
#    LOCALSTACK = LOCALSTACK + sz;
#    return p;
#};
#var lsfree = func(sz) {
#    LOCALSTACK = LOCALSTACK - sz;
#};
var lsalloc = asm {
    ld r0, (_LOCALSTACK)
    pop x
    add x, r0
    ld (_LOCALSTACK), x
    ret
};
var lsfree = asm {
    pop x
    sub (_LOCALSTACK), x
    ret
};

var newscope_runtime = func(sz) {
    *(LOCALSTACK++) = CONTINUE_jmpbuf;
    *(LOCALSTACK++) = BREAK_jmpbuf;
    *(LOCALSTACK++) = RETURN_jmpbuf;
    *(LOCALSTACK++) = BP;
    BP = lsalloc(sz);

    BREAK_jmpbuf = 0;
    CONTINUE_jmpbuf = 0;

    return BP;
};
var endscope_runtime = func(bp) {
    LOCALSTACK = bp;
    BP = *(--LOCALSTACK);
    RETURN_jmpbuf = *(--LOCALSTACK);
    BREAK_jmpbuf = *(--LOCALSTACK);
    CONTINUE_jmpbuf = *(--LOCALSTACK);
};

var newscope_parsetime = func() {
    grpush(OLDLOCALS, LOCALS);
    LOCALS = grnew();
};
var endscope_parsetime = func() {
    if (!LOCALS) die("can't end the global scope",0);
    grwalk(LOCALS, free);
    grfree(LOCALS);
    LOCALS = grpop(OLDLOCALS);
};

### AST ###

SeqNode = func(nodes) {
    if (grlen(nodes) == 0) return NopNode()
    else if (grlen(nodes) == 1) return grget(nodes, 0);

    var codesz = 3 + mul(4, grlen(nodes)) + 2;
    var arr = aalloc(codesz+1);
    var code = arr+1;

    # first element is a pointer to the evaluator function (the function we're
    # making)
    arr[0] = code;

    # stash return address
    var p = code;
    *(p++) = 0xa1ff; # inc sp (ignore our argument)
    *(p++) = 0x61fe; # ld x, r254
    *(p++) = 0x5a00; # push x

    # call each node in turn
    var i = 0;
    while (i != grlen(nodes)) {
        if (*(grget(nodes,i)) != EvalNopNode) {
            *(p++) = 0x6200; *(p++) = grget(nodes, i); # ld x, node
            *(p++) = 0x5a00; # push x
            *(p++) = 0x3f00; # call (x)
        };

        i++;
    };

    # return
    *(p++) = 0x5d00; # pop x
    *(p++) = 0xa900; # jmp x

    var len = p-code;
    if (len gt codesz) die("seqnode evaluator is too large (%d, should be %d)!\n", [len, codesz]);

    return arr;
};

NopNode = func() {
    return [EvalNopNode];
};
EvalNopNode = func(n) {
    return 0;
};

ConstNode = func(val) {
    var p = aalloc(6);
    p[0] = p+1; # pointer to evaluator
    p[1] = 0xa1ff; # inc sp
    p[2] = 0x8500; p[3] = val; # ld r0, val
    p[4] = 0x9300; # ret
    p[5] = isConstNode; # make it identifiable...
    return p;
};
isConstNode = func(n) {
    return (n[0] == n+1) && (n[5] == isConstNode);
};
#EvalConstNode = func(n) {
#    return n[1];
#};

ArrayIndexNode = func(ptr, index) {
    return acons3(EvalArrayIndexNode, ptr, index);
};
EvalArrayIndexNode = func(n) {
    #var ptr = eval(n[1]);
    #var idx = eval(n[2]);
    return *(eval(n[1]) + eval(n[2]));
};

OperatorNode = func(op, arg1, arg2) {
    var node = acons3(op, arg1, arg2);
    if (isConstNode(arg1) && isConstNode(arg2)) {
        return ConstNode(eval(node))
    } else {
        return node;
    };
};

EvalAddNode = func(n) { return eval(n[1]) + eval(n[2]); };
EvalSubNode = func(n) { return eval(n[1]) - eval(n[2]); };
EvalAndNode = func(n) { return eval(n[1]) & eval(n[2]); };
EvalOrNode = func(n) { return eval(n[1]) | eval(n[2]); };
EvalXorNode = func(n) { return eval(n[1]) ^ eval(n[2]); };
#EvalLogicalAndNode = func(n) { return eval(n[1]) && eval(n[2]); };
#EvalLogicalOrNode = func(n) { return eval(n[1]) || eval(n[2]); };
EvalLogicalAndNode = func(n) {
    if (!eval(n[1])) return 0;
    return eval(n[2]);
};
EvalLogicalOrNode = func(n) {
    if (eval(n[1])) return 1;
    return eval(n[2]);
};
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
    var node = acons(op, arg1);
    if (isConstNode(arg1) && op != EvalValueOfNode) {
        return ConstNode(eval(node));
    } else {
        return node;
    };
};
EvalNotNode = func(n) { return !eval(n[1]); };
EvalComplementNode = func(n) { return ~eval(n[1]); };
EvalValueOfNode = func(n) { return *(eval(n[1])); };
EvalNegateNode = func(n) { return -eval(n[1]); };

ConditionalNode = func(cond, thenexpr, elseexpr) {
    if (elseexpr) return acons4(EvalConditionalNodeWithElse, cond, thenexpr, elseexpr)
    else return acons3(EvalConditionalNode, cond, thenexpr);
};
EvalConditionalNode = asm {
    # stash return
    ld x, r254
    push x

    # evaluate condition
    ld x, 2(sp) # n
    inc x
    ld x, (x)
    push x # n[1]
    call (_eval)
    test r0
    jz EvalConditionalNode_ret

    # evaluate body
    ld x, 2(sp) # n
    add x, 2
    ld x, (x)
    push x # n[2]
    call (_eval)

    EvalConditionalNode_ret:
    pop x
    ld r254, x
    pop x
    ret
};
EvalConditionalNodeWithElse = asm {
    # stash return
    ld x, r254
    push x

    # evaluate condition
    ld x, 2(sp) # n
    inc x
    ld x, (x)
    push x # n[1]
    call (_eval)
    test r0
    jz EvalConditionalNodeWithElse_else

    # evaluate body
    ld x, 2(sp) # n
    add x, 2
    ld x, (x)
    push x # n[2]
    call (_eval)
    jmp EvalConditionalNodeWithElse_ret

    # evaluate else
    EvalConditionalNodeWithElse_else:
    ld x, 2(sp) # n
    add x, 3
    ld x, (x)
    push x # n[3]
    call (_eval)

    EvalConditionalNodeWithElse_ret:
    pop x
    ld r254, x
    pop x
    ret
};

LoopNode = func(cond, body) {
    return acons3(EvalLoopNode, cond, body);
};
EvalLoopNode = func(n) {
    var cond = n[1];
    var body = n[2];
    var r;

    var old_CONTINUE_jmpbuf = CONTINUE_jmpbuf;
    CONTINUE_jmpbuf = lsalloc(3);

    var old_BREAK_jmpbuf = BREAK_jmpbuf;
    BREAK_jmpbuf = lsalloc(3);

    setjmp(CONTINUE_jmpbuf);
    if (!setjmp(BREAK_jmpbuf)) {
        while (eval(cond))
            if (body) eval(body);
    };

    lsfree(6); # CONTINUE_jmpbuf, BREAK_jmpbuf

    BREAK_jmpbuf = old_BREAK_jmpbuf;
    CONTINUE_jmpbuf = old_CONTINUE_jmpbuf;

    return 0;
};

VariableNode = func(name) {
    if (findlocal(name)) return LocalNode(name)
    else return GlobalNode(name);
};
AddressOfNode = func(name) {
    if (findlocal(name)) return AddressOfLocalNode(name)
    else return AddressOfGlobalNode(name);
};

LocalNode = func(name) {
    var v = findlocal(name);
    if (v) return acons(EvalLocalNode, cdr(v));
    die("use of undefined local: %s\n", [name]);
};
#EvalLocalNode = func(n) {
#    var bp_rel = n[1];
#    return *(BP + bp_rel);
#};
EvalLocalNode = asm {
    pop x
    ld x, 1(x)
    add x, (_BP)
    ld r0, (x)
    ret
};
GlobalNode = func(name) {
    var addr = findglobal(name);
    if (addr) return acons(EvalGlobalNode, addr);
    die("use of undefined global: %s\n", [name]);
};
#EvalGlobalNode = func(n) {
#    return *(n[1]);
#};
EvalGlobalNode = asm {
    pop x
    ld x, 1(x)
    ld r0, (x)
    ret
};
AddressOfLocalNode = func(name) {
    var v = findlocal(name);
    if (v) return acons(EvalAddressOfLocalNode, cdr(v));
    die("use of undefined local: %s\n", [name]);
};
EvalAddressOfLocalNode = func(n) {
    var bp_rel = n[1];
    return BP + bp_rel;
};
AddressOfGlobalNode = func(name) {
    var addr = findglobal(name);
    if (addr) return ConstNode(addr);
    die("use of undefined global: %s\n", [name]);
};

IndexAddressOfNode = func(exprs) {
    if (grlen(exprs)<1) die("index address-of must have at least 1 expr\n",0);
    return acons(EvalIndexAddressOfNode, exprs);
};
EvalIndexAddressOfNode = func(n) {
    var exprs = grbase(n[1]);
    var len = grlen(n[1]);
    var addr = eval(exprs[0]);
    var i = 1;
    while (i != len) {
        addr = *addr + eval(exprs[i]);
        i++;
    };
    return addr;
};

AssignmentNode = func(addr, value) {
    return acons3(EvalAssignmentNode, addr, value);
};
EvalAssignmentNode = func(n) {
    #var addr = n[1];
    #var value = n[2];
    *(eval(n[1])) = eval(n[2]);
    return 0;
};

PreOpNode = func(inc, name) {
    return acons3(EvalPreOpNode, inc, AddressOfNode(name));
};
EvalPreOpNode = func(n) {
    #var inc = n[1];
    var addr = eval(n[2]);
    var val = *addr + n[1];
    *addr = val;
    return val;
};

PostOpNode = func(inc, name) {
    return acons3(EvalPostOpNode, inc, AddressOfNode(name));
};
EvalPostOpNode = func(n) {
    #var inc = n[1];
    var addr = eval(n[2]);
    var val = *addr;
    *addr = val + n[1];
    return val;
};

FunctionCallNode = func(name, args) {
    var codesz = 3 + mul(6, grlen(args)) + 8;
    var arr = aalloc(codesz+1);
    var code = arr+1;

    # first element is a pointer to the evaluator function (the function we're
    # making)
    arr[0] = code;

    # stash return address
    var p = code;
    *(p++) = 0xa1ff; # inc sp (ignore our argument)
    *(p++) = 0x61fe; # ld x, r254
    *(p++) = 0x5a00; # push x

    # evaluate each argument in turn and push it
    var i = 0;
    var n;
    while (i != grlen(args)) {
        n = grget(args,i);
        if (isConstNode(n)) {
            n = eval(n);
            if ((n & 0xff00) == 0) {
                *(p++) = 0x5b00 | n; # push i8l
            } else if ((n & 0xff00) == 0xff00) {
                *(p++) = 0x5c00 | (n & 0x00ff); # push i8h
            } else {
                *(p++) = 0x6200; *(p++) = n; # ld x, val
                *(p++) = 0x5a00; # push x
            };
        } else {
            *(p++) = 0x6200; *(p++) = n; # ld x, node
            *(p++) = 0x5a00; # push x
            *(p++) = 0x3f00; # call (x)
            *(p++) = 0x6100; # ld x, r0
            *(p++) = 0x5a00; # push x
        };
        i++;
    };

    # get function location
    var varnode = VariableNode(name);
    *(p++) = 0x6200; *(p++) = varnode; # ld x, node
    *(p++) = 0x5a00; # push x
    *(p++) = 0x3f00; # call (x)

    # call function
    *(p++) = 0x1f00; *(p++) = 0xff00; # call r0

    # return
    *(p++) = 0x5d00; # pop x
    *(p++) = 0xa900; # jmp x

    var len = p-code;
    if (len gt codesz) die("functioncallnode evaluator is too large (%d, should be %d)!\n", [len, codesz]);

    return arr;
};

ReturnNode = func(expr) {
    return acons(EvalReturnNode, expr);
};
EvalReturnNode = func(n) {
    RETURN_val = eval(n[1]);
    longjmp(RETURN_jmpbuf, 1);
};

ArrayLiteralNode = func(exprs) {
    var base = aalloc(grlen(exprs)+1);
    return acons4(EvalArrayLiteralNode, grbase(exprs), base, grlen(exprs));
};
EvalArrayLiteralNode = func(n) {
    var exprs = n[1];
    var base = n[2];
    var len = n[3];
    var i = 0;
    while (i != len) {
        base[i] = eval(exprs[i]);
        i++;
    };
    base[i] = 0;
    return base;
};

BreakNode = func() {
    return [EvalBreakNode];
};
EvalBreakNode = func(n) {
    longjmp(BREAK_jmpbuf, 1);
};
ContinueNode = func() {
    return [EvalContinueNode];
};
EvalContinueNode = func(n) {
    longjmp(CONTINUE_jmpbuf, 1);
};

### Parser ###

Program = func(x) {
    skip();
    return Statements(0);
};

Statements = func(x) {
    var nodes = grnew();
    var r;
    while (1) {
        r = parse(Statement, 0);
        if (!r) break;
        grpush(nodes, r);
        if (!parse(CharSkip,';')) break;
    };
    r = SeqNode(nodes);
    grfree(nodes);
    return r;
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
    } else if (ch == 'c') {
        r = parse(Declaration,0); if (r) return r;
        r = parse(Continue,0); if (r) return r;
    } else if (ch == 'w') {
        r = parse(Loop,0); if (r) return r;
    } else if (ch == 'b') {
        r = parse(Break,0); if (r) return r;
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
    if (!Char('"')) return 0;
    var file = StringLiteralText();

    # don't include the same file twice
    if (grfind(INCLUDED, file, func(a,b) { return strcmp(a,b)==0 })) return NopNode();
    grpush(INCLUDED, intern(file));

    # save parser state
    var pos0 = parse_pos;
    var readpos0 = parse_readpos;
    var line0 = parse_line;
    var parse_getchar0 = parse_getchar;
    var parse_filename0 = parse_filename;
    var include_fd0 = include_fd;
    var ringbuf0 = malloc(parse_ringbufsz);
    var include_inbuf0 = include_inbuf;
    memcpy(ringbuf0, parse_ringbuf, parse_ringbufsz);

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
    var r = Program(0);
    if (!r) die("expected statements",0);

    bclose(include_inbuf);

    # restore parser state
    parse_pos = pos0;
    parse_readpos = readpos0;
    parse_line = line0;
    parse_getchar = parse_getchar0;
    free(parse_filename);
    parse_filename = parse_filename0;
    include_fd = include_fd0;
    memcpy(parse_ringbuf, ringbuf0, parse_ringbufsz);
    free(ringbuf0);
    include_inbuf = include_inbuf0;

    return r;
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
};

Declaration = func(x) {
    var vartype;
    if (Keyword("var")) vartype = "var"
    else if (Keyword("const")) vartype = "const"
    else return 0;
    if (BLOCKLEVEL != 0) die("%s not allowed here", [vartype]);
    if (!Identifier(0)) die("%s needs identifier", [vartype]);
    var name = intern(IDENTIFIER);

    if (LOCALS) {
        addlocal(name);
    } else {
        addglobal(name, aalloc(1));
    };

    if (!parse(CharSkip,'=')) return NopNode();

    var r = Expression(0);
    if (!r) die("initialisation needs expression",0);

    return AssignmentNode(AddressOfNode(name), r);
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
    LOOPLEVEL++;
    if (!CharSkip('(')) die("while condition needs open paren",0);

    var cond = Expression(0);
    if (!cond) die("while condition needs expression",0);

    if (!CharSkip(')')) die("while condition needs close paren",0);

    var body = Statement(0); # optional

    LOOPLEVEL--;
    BLOCKLEVEL--;
    return LoopNode(cond, body);
};

Break = func(x) {
    if (!Keyword("break")) return 0;
    if (!LOOPLEVEL) die("can't break here", 0);
    return BreakNode();
};

Continue = func(x) {
    if (!Keyword("continue")) return 0;
    if (!LOOPLEVEL) die("can't continue here",0);
    return ContinueNode();
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
    var r;
    var v;
    if (parse(Identifier,0)) {
        id = intern(IDENTIFIER);
        lvalue_addr = AddressOfNode(id);

        if (parse(CharSkip,'[')) {
            r = grnew();
            grpush(r, lvalue_addr);

            while (1) {
                v = Expression(0);
                if (!v) die("array index needs expression",0);
                grpush(r, v);
                if (!CharSkip(']')) die("array index needs close bracket",0);

                if (!parse(CharSkip,'[')) break;
            };

            lvalue_addr = IndexAddressOfNode(r);
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
    if (ch == 'w' || ch == 's' || ch == 'd' || ch == 'W' || ch == 'S' || ch == 'D') {
        warn("possible attempt to encode '\\%c' with too few slashes", [ch]);
    };
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
    return ConstNode(intern(StringLiteralText()));
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
        addlocal(intern(IDENTIFIER));
        if (!parse(CharSkip,',')) break;
    };
    return params;
};

FunctionDeclaration = func(x) {
    if (!Keyword("func")) return 0;
    if (!CharSkip('(')) die("func needs open paren",0);

    newscope_parsetime();

    Parameters(0);
    var nparams = grlen(LOCALS);

    if (!CharSkip(')')) die("func needs close paren",0);

    var blocklevel = BLOCKLEVEL;
    var looplevel = LOOPLEVEL;
    BLOCKLEVEL = 0;
    LOOPLEVEL = 0;
    var body = Statement(0); # optional
    BLOCKLEVEL = blocklevel;
    LOOPLEVEL = looplevel;

    var codesz = 15;
    var code_addr = aalloc(codesz);

    # now we create a stub to allow normal SLANG calling convention to
    # call into the interpreter; this way interpreted functions and
    # compiled functions get called the same way, which means both types
    # can safely call each other without having to keep track of what's
    # compiled and what's interpreted.
    #
    # we need to call eval_function(argbase, params, body)
    var p = code_addr;
    *(p++) = 0x61fe; # ld x, r254
    *(p++) = 0x5a00; # push x # stash return
    *(p++) = 0x61ff; # ld x, sp
    *(p++) = 0x0602; # add x, 2
    *(p++) = 0x5a00; # push x # argbase
    *(p++) = 0x5b00 + nparams; # push x # nparams
    *(p++) = 0x6200; *(p++) = body; # ld x, body
    *(p++) = 0x5a00; # push x # body
    *(p++) = 0x5b00 + grlen(LOCALS); # push framesz
    *(p++) = 0x4f00; *(p++) = eval_function; # call eval_function
    *(p++) = 0x5d00; # pop x
    *(p++) = 0x69fe; # ld r254, x
    *(p++) = 0x9400 + nparams; # return

    if (p != code_addr+codesz) die("function body is wrong size (%d, should be %d)!\n",[p-code_addr, code_addr+codesz]);

    endscope_parsetime();

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

    var n = FunctionCallNode(name, args);
    grfree(args);
    return n;
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
        inc = -1;
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
        inc = -1;
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

eval_function = func(argbase, nparams, body, framesz) {
    var bp = newscope_runtime(framesz);

    # note we get args in reverse order
    var p = BP;
    while (nparams--)
        *(p++) = argbase[nparams];

    RETURN_jmpbuf = lsalloc(3);

    var r = 0;
    if (setjmp(RETURN_jmpbuf)) {
        r = RETURN_val;
    } else {
        eval(body);
    };

    lsfree(3); # RETURN_jmpbuf

    endscope_runtime(bp);
    return r;
};

#eval = func(node) {
#    if (node lt 256) die("tried to eval %d\n", [node]);
#    var f = node[0];
#    return f(node);
#};
eval = asm {
    ld x, 1(sp)
    jmp (x)
};

INCLUDED = grnew();
STRINGS = grnew();
GLOBALS = htnew();
OLDLOCALS = grnew();
BPS = grnew();

htgrow(GLOBALS);
htgrow(GLOBALS);
htgrow(GLOBALS);
include "rude-globals.sl";

# input buffering
var inbuf;

var args = cmdargs()+1;
if (*args) {
    inbuf = bopen(*args, O_READ);
    if (!inbuf) die("can't open %s for reading\n", [*args]);
    # now override cmdargs() so that it works for the interpreted program
    cmdargs = func() { return args; };
} else {
    inbuf = bfdopen(0, O_READ);
};

parse_init(func() {
    return bgetc(inbuf);
});
var program = parse(Program,0);

if (nextchar() != EOF) die("garbage after end of program",0);
if (LOCALS) die("expected to be left in global scope after program",0);
if (BLOCKLEVEL != 0) die("expected to be left at block level 0 after program (probably a compiler bug)",0);
if (!program) die("parsed AST is null pointer",0);

eval(program);
