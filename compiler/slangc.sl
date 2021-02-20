# SLANG Compiler by jes
#
# Reads SLANG source from stdin, produces SCAMP assembly code on stdout. In the
# event of a compile error, there'll be a message on stderr and a non-zero exit
# status, and the code on stdout should be ignored.
#
# Recursive descent parser based on https://www.youtube.com/watch?v=Ytq0GQdnChg
# Each Foo() parses a rule from the grammar; if the rule matches it returns 1,
# else it returns 0.
#
# Rather than turning the source code into an abstract syntax tree and then
# turning the AST into code, we treat the compiler's call graph as an implicit
# AST and generate code as we "walk the call graph", i.e. as the compiler parses
# the source.
#
# TODO: optionally annotate generated assembly code with the source code that
#       generated it
# TODO: provide unsigned mangitude comparison?
# TODO: fix &/| precedence
# TODO: some way to include assembly code
# TODO: some way to include files only the first time (maybe *only* work that way? how
#       often is it actually useful to be able to include a file multiple times?)
# TODO: array indexing syntax

include "stdio.sl";
include "stdlib.sl";
include "string.sl";
include "list.sl";
include "parse.sl";

var Reject = func(x) { return 0; };

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
var Constant;
var NumericLiteral;
var HexLiteral;
var DecimalLiteral;
var CharacterLiteral;
var StringLiteral;
var StringLiteralText;
var FunctionDeclaration;
var Parameters;
var FunctionCall;
var Arguments;
var PreOp;
var PostOp;
var AddressOf;
var UnaryExpression;
var ParenExpression;
var Identifier;

# store identifier value parsed by Identifier()
var maxidentifier = 128;
var IDENTIFIER = malloc(maxidentifier);

var STRINGS;
# EXTERNS and GLOBALS are lists of pointers variable names
var EXTERNS;
var GLOBALS;
# LOCALS is a list of pointers to tuples of (name,bp_rel)
var LOCALS;
var BP_REL;
var NPARAMS;
var BLOCKLEVEL = 0;
var BREAKLABEL;
var CONTLABEL;
var LABELNUM = 1;

var label = func() { return LABELNUM++; };
var plabel = func(l) { puts("l__"); puts(itoa(l)); };

# return 1 if "name" is a global or extern, 0 otherwise
var findglobal = func(name) {
    if (lstfind(GLOBALS, name, func(a,b) { return strcmp(a,b)==0 })) return 1;
    if (lstfind(EXTERNS, name, func(a,b) { return strcmp(a,b)==0 })) return 1;
    return 0;
};

var addextern = func(name) {
    if (findglobal(name)) die("duplicate global: $name"); # TODO: printf
    lstpush(EXTERNS, name);
};
var addglobal = func(name) {
    if (findglobal(name)) die("duplicate global: $name"); # TODO: printf
    lstpush(GLOBALS, name);
};

# return pointer to (name,bp_rel) if "name" is a local, 0 otherwise
var findlocal = func(name) {
    if (!LOCALS) die("can't find local in global scope");
    return lstfind(LOCALS, name, func(findname,tuple) { return strcmp(findname,*tuple)==0 });
};
var addlocal = func(name, bp_rel) {
    if (!LOCALS) die("can't add local in global scope");

    if (findlocal(name)) die("duplicate local: $name"); # TODO: printf

    var tuple = cons(name,bp_rel);
    lstpush(LOCALS, tuple);
    return tuple;
};

var addstring = func(str) {
    var v = lstfind(STRINGS, str, func(find,tuple) { return strcmp(find,*tuple)==0 });
    if (v) return *(v+1);

    var l = label();
    lstpush(STRINGS, cons(str,l));
    return l;
};

var newscope = func() {
    # save old base pointer, and put new base pointer in r253
    puts("# newscope:\n");
    puts("ld x, r253\n");
    puts("push x\n");
    puts("ld r253, sp\n");

    LOCALS = lstnew();
    BP_REL = 0;
};

var runtime_endscope = func() {
    # restore old sp and bp
    puts("# endscope:\n");
    puts("ld sp, r253\n");
    puts("pop x\n");
    puts("ld r253, x\n");
};

var compiletime_endscope = func() {
    if (!LOCALS) die("can't end the global scope");
    lstwalk(LOCALS, func(tuple) {
        var name = *tuple;
        free(*name);
        free(tuple);
    });
    lstfree(LOCALS);
};

var endscope = func() {
    runtime_endscope();
    compiletime_endscope();
};

var pushvar = func(name) {
    var v;
    var bp_rel;
    if (LOCALS) {
        v = findlocal(name);
        if (v) {
            bp_rel = *(v+1);
            puts("# pushvar: local "); puts(name); puts("\n");
            puts("ld x, r253\n");
            puts("ld x, "); puts(itoa(bp_rel)); puts("(x)\n");
            puts("push x\n");
            return 0;
        };
    };

    v = findglobal(name);
    if (v) {
        puts("# pushvar: global "); puts(name); puts("\n");
        puts("ld x, (_"); puts(name); puts(")\n");
        puts("push x\n");
        return 0;
    };

    puts("bad push: "); puts(name); puts("\n");
    die("unrecognised identifier: $name"); # TODO: printf
};
var poptovar = func(name) {
    var v;
    var bp_rel;
    if (LOCALS) {
        v = findlocal(name);
        if (v) {
            bp_rel = *(v+1);
            puts("# poptovar: local "); puts(name); puts("\n");
            puts("ld r252, r253\n");
            puts("add r252, "); puts(itoa(bp_rel)); puts("\n");
            puts("pop x\n");
            puts("ld (r252), x\n");
            return 0;
        };
    };

    v = findglobal(name);
    if (v) {
        puts("# poptovar: global "); puts(name); puts("\n");
        puts("pop x\n");
        puts("ld (_"); puts(name); puts("), x\n");
        return 0;
    };

    puts("bad pop: "); puts(name); puts("\n");
    die("unrecognised identifier: $name"); # TODO: printf
};

var genliteral = func(v) {
    puts("# genliteral:\n");
    if ((v&0xff00)==0 || (v&0xff00)==0xff00) {
        puts("push "); puts(itoa(v)); puts("\n");
    } else {
        puts("ld x, "); puts(itoa(v)); puts("\n");
        puts("push x\n");
    };
};

var genop = func(op) {

    puts("# operator: "); puts(op); puts("\n");
    puts("pop x\n");
    puts("ld r0, x\n");
    puts("pop x\n");

    var signstest = func(wantlt, end) {
        var wantgt = !wantlt;
        var cont = label();

        puts("ld r1, r0\n");
        puts("ld r2, x\n");
        puts("ld r3, x\n");
        puts("and r1, 32768 #peepopt:test\n"); # r1 = r0 & 0x8000
        puts("and r2, 32768 #peepopt:test\n"); # r2 = x & 0x8000
        puts("sub r1, r2 #peepopt:test\n");
        puts("ld x, r3\n"); # restore x (doesn't clobber flags)
        puts("jz "); plabel(cont); puts("\n");

        puts("test r2\n");
        puts("ld x, "); puts(itoa(wantlt)); puts("\n"); # doesn't clobber flags
        puts("jnz "); plabel(end); puts("\n");
        puts("ld x, "); puts(itoa(wantgt)); puts("\n");
        puts("jmp "); plabel(end); puts("\n");

        plabel(cont); puts(":\n");
    };

    var end;

    if (strcmp(op,"+") == 0) {
        puts("add x, r0\n");
    } else if (strcmp(op,"-") == 0) {
        puts("sub x, r0\n");
    } else if (strcmp(op,"&") == 0) {
        puts("and x, r0\n");
    } else if (strcmp(op,"|") == 0) {
        puts("or x, r0\n");
    } else if (strcmp(op,"^") == 0) {
        puts("ld y, r0\n");
        puts("xor x, y\n");
    } else if (strcmp(op,"!=") == 0) {
        end = label();
        puts("sub x, r0 #peepopt:test\n");
        puts("jz "); plabel(end); puts("\n");
        puts("ld x, 1\n");
        plabel(end); puts(":\n");
    } else if (strcmp(op,"==") == 0) {
        end = label();
        puts("sub x, r0 #peepopt:test\n");
        puts("ld x, 0\n"); # doesn't clobber flags
        puts("jnz "); plabel(end); puts("\n");
        puts("ld x, 1\n");
        plabel(end); puts(":\n");
    } else if (strcmp(op,">=") == 0) {
        end = label();
        signstest(0, end);
        puts("sub x, r0 #peepopt:test\n");
        puts("ld x, 0\n"); # doesn't clobber flags
        puts("jlt "); plabel(end); puts("\n");
        puts("ld x, 1\n");
        plabel(end); puts(":\n");
    } else if (strcmp(op,"<=") == 0) {
        end = label();
        signstest(1, end);
        puts("sub r0, x #peepopt:test\n");
        puts("ld x, 0\n"); # doesn't clobber flags
        puts("jlt "); plabel(end); puts("\n");
        puts("ld x, 1\n");
        plabel(end); puts(":\n");
    } else if (strcmp(op,">") == 0) {
        end = label();
        signstest(0, end);
        puts("sub r0, x #peepopt:test\n");
        puts("ld x, 1\n"); # doesn't clobber flags
        puts("jlt "); plabel(end); puts("\n");
        puts("ld x, 0\n");
        plabel(end); puts(":\n");
    } else if (strcmp(op,"<") == 0) {
        end = label();
        signstest(1, end);
        puts("sub x, r0 #peepopt:test\n");
        puts("ld x, 1\n"); # doesn't clobber flags
        puts("jlt "); plabel(end); puts("\n");
        puts("ld x, 0\n");
        plabel(end); puts(":\n");
    } else if (strcmp(op,"&&") == 0) {
        end = label();
        puts("test x\n");
        puts("ld x, 0\n"); # doesn't clobber flags
        puts("jz "); plabel(end); puts("\n");
        puts("test r0\n");
        puts("jz "); plabel(end); puts("\n");
        puts("ld x, 1\n"); # both args true: x=1
        plabel(end); puts(":\n");
    } else if (strcmp(op,"||") == 0) {
        end = label();
        puts("test x\n");
        puts("ld x, 1\n"); # doesn't clobber flags
        puts("jnz "); plabel(end); puts("\n");
        puts("test r0\n");
        puts("jnz "); plabel(end); puts("\n");
        puts("ld x, 0\n"); # both args false: x=0
        plabel(end); puts(":\n");
    } else {
        puts("bad op: "); puts(op); puts("\n");
        die("unrecognised binary operator $op (probably a compiler bug)");
    };

    puts("push x\n");
};

var funcreturn = func() {
    if (!LOCALS) die("can't return from global scope");
    runtime_endscope();

    puts("# function had "); puts(itoa(NPARAMS)); puts(" parameters:\n");
    puts("add sp, "); puts(itoa(NPARAMS)); puts("\n");
    puts("ret\n");
};

Program = func(x) {
    skip();
    parse(Statements,0);
    return 1;
};

Statements = func(x) {
    while (1) {
        if (!parse(Statement,0)) return 1;
        if (!parse(CharSkip,';')) return 1;
    };
};

Statement = func(x) {
    if (parse(Include,0)) return 1;
    if (parse(Block,0)) return 1;
    if (parse(Extern,0)) return 1;
    if (parse(Declaration,0)) return 1;
    if (parse(Conditional,0)) return 1;
    if (parse(Loop,0)) return 1;
    if (parse(Break,0)) return 1;
    if (parse(Continue,0)) return 1;
    if (parse(Return,0)) return 1;
    if (parse(Assignment,0)) return 1;
    if (parse(Expression,0)) {
        puts("# discard expression value\n");
        puts("pop x\n");
        return 1;
    };
    return 0;
};

# TODO: we can't implement "include" until we have a filesystem
Include = Reject;

Block = func(x) {
    if (!parse(CharSkip,'{')) return 0;
    parse(Statements,0);
    if (!parse(CharSkip,'}')) die("block needs closing brace");
    return 1;
};

Extern = func(x) {
    if (!parse(Keyword,"extern")) return 0;
    if (!parse(Identifier,0)) die("extern needs identifier");
    addextern(strdup(IDENTIFIER));
    return 1;
};

Declaration = func(x) {
    if (!parse(Keyword,"var")) return 0;
    if (!parse(Identifier,0)) die("var needs identifier");
    var name = strdup(IDENTIFIER);
    if (!LOCALS) {
        addglobal(name);
    } else {
        addlocal(name, BP_REL--);
        puts("# allocate space for "); puts(name); puts("\n");
        puts("dec sp\n");
    };
    if (!parse(CharSkip,'=')) return 1;
    if (!parse(Expression,0)) die("initialisation needs expression");
    poptovar(name);
    return 1;
};

Conditional = func(x) {
    if (!parse(Keyword,"if")) return 0;
    BLOCKLEVEL++;
    if (!parse(CharSkip,'(')) die("if condition needs open paren");
    puts("# if condition\n");
    if (!parse(Expression,0)) die("if condition needs expression");

    # if top of stack is 0, jmp falselabel
    var falselabel = label();
    puts("pop x\n");
    puts("test x\n");
    puts("jz "); plabel(falselabel); puts("\n");

    if (!parse(CharSkip,')')) die("if condition needs close paren");
    puts("# if body\n");
    if (!parse(Statement,0)) die("if needs body");

    var endiflabel;
    if (parse(Keyword,"else")) {
        endiflabel = label();
        puts("jmp l__"); puts(itoa(endiflabel)); puts("\n");
        puts("# else body\n");
        plabel(falselabel); puts(":\n");
        if (!parse(Statement,0)) die("else needs body");
        plabel(endiflabel); puts(":\n");
    } else {
        plabel(falselabel); puts(":\n");
    };
    BLOCKLEVEL--;
    return 1;
};

Loop = func(x) {
    if (!parse(Keyword,"while")) return 0;
    BLOCKLEVEL++;
    if (!parse(CharSkip,'(')) die("while condition needs open paren");

    var oldbreaklabel = BREAKLABEL;
    var oldcontlabel = CONTLABEL;
    var loop = label();
    var endloop = label();

    BREAKLABEL = endloop;
    CONTLABEL = loop;

    puts("# while loop\n");
    plabel(loop); puts(":\n");

    if (!parse(Expression,0)) die("while condition needs expression");

    # if top of stack is 0, jmp endloop
    puts("pop x\n");
    puts("test x\n");
    puts("jz "); plabel(endloop); puts("\n");

    if (!parse(CharSkip,')')) die("while condition needs close paren");

    parse(Statement,0); # optional
    puts("jmp "); plabel(loop); puts("\n");
    plabel(endloop); puts(":\n");

    BREAKLABEL = oldbreaklabel;
    CONTLABEL = oldcontlabel;
    BLOCKLEVEL--;
    return 1;
};

Break = func(x) {
    if (!parse(Keyword,"break")) return 0;
    if (!BREAKLABEL) die("can't break here");
    puts("# break\n");
    puts("jmp "); plabel(BREAKLABEL); puts("\n");
    return 1;
};

Continue = func(x) {
    if (!parse(Keyword,"continue")) return 0;
    if (!CONTLABEL) die("can't continue here");
    puts("# continue\n");
    puts("jmp "); plabel(CONTLABEL); puts("\n");
    return 1;
};

Return = func(x) {
    if (!parse(Keyword,"return")) return 0;
    if (!parse(Expression,0)) die("return needs expression");
    puts("# return\n");
    puts("pop x\n");
    puts("ld r0, x\n");
    funcreturn();
    return 1;
};

Assignment = func(x) {
    var id = 0;
    if (parse(Identifier,0)) {
        id = strdup(IDENTIFIER);
    } else {
        if (!parse(CharSkip,'*')) return 0;
        if (!parse(Term,0)) die("can't dereference non-expression");
    };
    if (!parse(CharSkip,'=')) return 0;
    if (!parse(Expression,0)) die("assignment needs rvalue");

    if (id) {
        poptovar(id);
        free(id);
    } else {
        puts("# store to pointer:\n");
        puts("pop x\n");
        puts("ld r0, x\n");
        puts("pop x\n");
        puts("ld (x), r0\n");
    };
    return 1;
};

Expression = func(x) { return parse(ExpressionLevel,0); };

# TODO: this would be a lot tidier if we had some better syntax for arrays
var operators = malloc(4);
*(operators+0) = malloc(4);
*(*(operators+0)+0) = "&";
*(*(operators+0)+1) = "|";
*(*(operators+0)+2) = "^";
*(*(operators+0)+3) = 0;
*(operators+1) = malloc(3);
*(*(operators+1)+0) = "&&";
*(*(operators+1)+1) = "||";
*(*(operators+1)+2) = 0;
*(operators+2) = malloc(7);
*(*(operators+2)+0) = "==";
*(*(operators+2)+1) = "!=";
*(*(operators+2)+2) = ">=";
*(*(operators+2)+3) = "<=";
*(*(operators+2)+4) = ">";
*(*(operators+2)+5) = "<";
*(*(operators+2)+6) = 0;
*(operators+3) = malloc(3);
*(*(operators+3)+0) = "+";
*(*(operators+3)+1) = "-";
*(*(operators+3)+2) = 0;
var oplevels = 4;

ExpressionLevel = func(lvl) {
    if (lvl == oplevels) return parse(Term,0);

    var apply_op = 0;
    var p;
    var match;
    while (1) {
        match = parse(ExpressionLevel, lvl+1);
        if (apply_op) {
            if (!match) die("operator $apply_op needs a second operand"); # TODO: sprintf
            genop(apply_op);
        } else {
            if (!match) return 0;
        };

        p = *(operators+lvl); # p points to a list of pointers to strings
        while (*p) {
            if (parse(String,*p)) break;
            p++;
        };
        if (!*p) return 1;
        apply_op = *p;
        skip();
    };
};

Term = func(x) {
    if (parse(Constant,0)) return 1;
    if (parse(FunctionCall,0)) return 1;
    if (parse(AddressOf,0)) return 1;
    if (parse(PreOp,0)) return 1;
    if (parse(PostOp,0)) return 1;
    if (parse(UnaryExpression,0)) return 1;
    if (parse(ParenExpression,0)) return 1;
    if (!parse(Identifier,0)) return 0;
    pushvar(IDENTIFIER);
    return 1;
};

Constant = func(x) {
    if (parse(NumericLiteral,0)) return 1;
    if (parse(StringLiteral,0)) return 1;
    if (parse(FunctionDeclaration,0)) return 1;
    return 0;
};

NumericLiteral = func(x) {
    if (parse(HexLiteral,0)) return 1;
    if (parse(CharacterLiteral,0)) return 1;
    if (parse(DecimalLiteral,0)) return 1;
    return 0;
};

# TODO: use the same buffer for literals and identifiers
var maxliteral = 512; # used to store numeric and string literals
var literal_buf = malloc(maxliteral);

var NumLiteral = func(alphabet,base,neg) {
    *literal_buf = peekchar();
    if (!parse(AnyChar,alphabet)) return 0;
    var i = 1;
    while (i < maxliteral) {
        *(literal_buf+i) = peekchar();
        if (!parse(AnyChar,alphabet)) {
            *(literal_buf+i) = 0;
            if (neg) genliteral(-atoibase(literal_buf,base))
            else     genliteral( atoibase(literal_buf,base));
            skip();
            return 1;
        };
        i++;
    };
    die("numeric literal too long");
};

HexLiteral = func(x) {
    if (!parse(String,"0x")) return 0;
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
    if (!parse(Char,'\'')) return 0;
    var ch = nextchar();
    if (ch == '\\') {
        genliteral(escapedchar(nextchar()));
    } else {
        genliteral(ch);
    };
    if (parse(CharSkip,'\'')) return 1;
    die("illegal character literal");
};

StringLiteral = func(x) {
    if (!parse(Char,'"')) return 0;
    var str = StringLiteralText();
    var strlabel = addstring(str);
    puts("ld x, "); plabel(strlabel); puts("\n");
    puts("push x\n");
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
    die("string literal too long");
};

var maxparams = 32;
var PARAMS = malloc(maxparams);
# TODO: bounds check
Parameters = func(x) {
    var p = PARAMS;
    while (1) {
        if (!parse(Identifier,0)) break;
        *(p++) = strdup(IDENTIFIER);
        if (p == PARAMS+maxparams) die("too many params for function");
        if (!parse(CharSkip,',')) break;
    };
    *p = 0;
    return PARAMS;
};

FunctionDeclaration = func(x) {
    if (!parse(Keyword,"func")) return 0;
    if (!parse(CharSkip,'(')) die("func needs open paren");

    var params = Parameters(0);
    var functionlabel = label();
    var functionend = label();
    puts("\n# parseFunctionDeclaration:\n");
    puts("jmp "); plabel(functionend); puts("\n");
    plabel(functionlabel); puts(":\n");

    var oldscope = LOCALS;
    var old_bp_rel = BP_REL;
    var oldnparams = NPARAMS;
    newscope();

    var bp_rel = 2; # parameters (grows up)
    var p = params;
    while (*p) p++;
    # p now points past the last param
    NPARAMS = p - params;
    while (p-- > params) {
        addlocal(*p, bp_rel++);
    };

    if (!parse(CharSkip,')')) die("func needs close paren");
    parse(Statement,0); # optional
    funcreturn();
    compiletime_endscope();
    LOCALS = oldscope;
    BP_REL = old_bp_rel;
    NPARAMS = oldnparams;

    puts("# end function declaration\n\n");
    plabel(functionend); puts(":\n");
    puts("ld x, "); plabel(functionlabel); puts("\n");
    puts("push x\n");
    return 1;
};

FunctionCall = func(x) {
    if (!parse(Identifier,0)) return 0;
    if (!parse(CharSkip,'(')) return 0;

    var name = strdup(IDENTIFIER);

    puts("# parseFunctionCall:\n");
    puts("ld x, r254\n");
    puts("push x\n");

    parse(Arguments,0);
    if (!parse(CharSkip,')')) die("argument list needs closing paren");

    pushvar(name);
    free(name);
    # call function
    puts("pop x\n");
    puts("call x\n");
    # restore return address
    puts("pop x\n");
    puts("ld r254, x\n");
    # push return value
    puts("ld x, r0\n");
    puts("push x\n");

    return 1;
};

Arguments = func(x) {
    while (1) {
        if (!parse(Expression,0)) return 1;
        if (!parse(CharSkip,',')) return 1;
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
    skip();
    if (!parse(Identifier,0)) return 0;
    skip();
    puts("# pre-"); puts(op); puts("\n");
    pushvar(IDENTIFIER);
    puts("pop x\n");
    puts(op); puts(" x\n");
    puts("push x\n");
    poptovar(IDENTIFIER);
    puts("push x\n");
    return 1;
};

PostOp = func(x) {
    if (!parse(Identifier,0)) return 0;
    skip();
    var op;
    if (parse(String,"++")) {
        op = "inc";
    } else if (parse(String,"--")) {
        op = "dec";
    } else {
        return 0;
    };
    skip();
    puts("# post-"); puts(op); puts("\n");
    pushvar(IDENTIFIER);
    puts("pop x\n");
    puts("push x\n");
    puts(op); puts(" x\n");
    puts("push x\n");
    poptovar(IDENTIFIER);
    return 1;
};

AddressOf = func(x) {
    if (!parse(CharSkip,'&')) return 0;
    if (!parse(Identifier,0)) die("address-of (&) needs identifier");

    var v = findlocal(IDENTIFIER);
    var bp_rel;
    if (v) {
        bp_rel = *(v+1);
        puts("# &"); puts(IDENTIFIER); puts(" (local)\n");
        puts("ld x, r253\n");
        puts("add x, "); puts(itoa(bp_rel)); puts("\n");
        puts("push x\n");
        return 1;
    };

    v = findglobal(IDENTIFIER);
    if (v) {
        puts("# &"); puts(IDENTIFIER); puts(" (global)\n");
        puts("ld x, _"); puts(IDENTIFIER); puts("\n");
        puts("push x\n");
        return 1;
    };

    puts("bad address-of: "); puts(IDENTIFIER); puts("\n");
    die("unrecognised identifier: $name"); # TODO: printf

    return 1;
};

UnaryExpression = func(x) {
    var op = peekchar();
    if (!parse(AnyChar,"!~*+-")) return 0;
    skip();
    if (!parse(Term,0)) die("unary operator $op needs operand"); # TODO: sprintf

    var end;

    puts("# unary "); putchar(op); puts("\n");
    puts("pop x\n");
    if (op == '~') {
        puts("not x\n");
    } else if (op == '-') {
        puts("neg x\n");
    } else if (op == '!') {
        end = label();
        puts("test x\n");
        puts("ld x, 0\n"); # doesn't clobber flags
        puts("jnz "); plabel(end); puts("\n");
        puts("ld x, 1\n");
        plabel(end); puts(":\n");
    } else if (op == '+') {
        # no-op
    } else if (op == '*') {
        puts("# pointer dereference:\n");
        puts("ld x, (x)\n");
    } else {
        die("unrecognised unary operator $op (probably a compiler bug)"); # TODO: sprintf
    };

    puts("push x\n");
    return 1;
};

ParenExpression = func(x) {
    if (!parse(CharSkip,'(')) return 0;
    if (parse(Expression,0)) return parse(CharSkip,')');
    return 0;
};

Identifier = func(x) {
    *IDENTIFIER = peekchar();
    if (!parse(AlphaUnderChar,0)) return 0;
    var i = 1;
    while (i < maxidentifier) {
        *(IDENTIFIER+i) = peekchar();
        if (!parse(AlphanumUnderChar,0)) {
            *(IDENTIFIER+i) = 0;
            skip();
            return 1;
        };
        if (*(IDENTIFIER+i) == '\\') *(IDENTIFIER+i) = escapedchar(nextchar());
        i++;
    };
    die("identifier too long");
};

STRINGS = lstnew();
EXTERNS = lstnew();
GLOBALS = lstnew();

parse_init();
parse(Program,0);

if (nextchar() != EOF) die("garbage after end of program");
if (LOCALS) die("expected to be left in global scope");
if (BLOCKLEVEL != 0) die("expected to be left at block level 0 (probably a compiler bug)");

# jump over the globals
var end = label();
puts("jmp "); plabel(end); puts("\n");

lstwalk(GLOBALS, func(name) {
    putchar('_'); puts(name); puts(": .word 0\n");
});

lstwalk(STRINGS, func(tuple) {
    var str = *tuple;
    var label = *(tuple+1);
    plabel(label); puts(":\n");
    var p = str;
    while (*p) {
        puts(".word "); puts(itoa(*p)); puts("\n");
        p++;
    };
    puts(".word 0\n");
});

lstfree(STRINGS);
lstfree(EXTERNS);
lstfree(GLOBALS);

plabel(end); puts(":\n");
