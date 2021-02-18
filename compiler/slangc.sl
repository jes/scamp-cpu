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
# TODO: fix all of the magnitude-comparison operators, and provide both signed
#       and unsigned versions?
# TODO: some way to include assembly code
# TODO: some way to include files only the first time (maybe *only* work that way? how
#       often is it actually useful to be able to include a file multiple times?)
# TODO: array indexing syntax
#
# TODO: generate code

include "stdio.sl";
include "stdlib.sl";
include "string.sl";
include "parse.sl";

var die = func(s) {
    puts("error: line "); puts(itoa(line)); puts(": col "); puts(itoa(col)); puts(": ");
    puts(s); putchar('\n');
    outp(3,0); # halt the emulator
};

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

Program = func(x) {
    skip();
    parse(Statements,0);
    if (nextchar() != EOF) die("garbage after end of program");
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
        return 1;
    };
    return 0;
};

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
    return 1;
};

Declaration = func(x) {
    if (!parse(Keyword,"var")) return 0;
    if (!parse(Identifier,0)) die("var needs identifier");
    if (!parse(CharSkip,'=')) return 1;
    if (!parse(Expression,0)) die("initialisation needs expression");
    return 1;
};

Conditional = func(x) {
    if (!parse(Keyword,"if")) return 0;
    if (!parse(CharSkip,'(')) die("if condition needs open paren");
    if (!parse(Expression,0)) die("if condition needs expression");
    if (!parse(CharSkip,')')) die("if condition needs close paren");
    if (!parse(Statement,0)) die("if needs body");
    if (parse(Keyword,"else")) {
        if (!parse(Statement,0)) die("else needs body");
    } else {
    };
    return 1;
};

Loop = func(x) {
    if (!parse(Keyword,"while")) return 0;
    if (!parse(CharSkip,'(')) die("while condition needs open paren");
    if (!parse(Expression,0)) die("while condition needs expression");
    if (!parse(CharSkip,')')) die("while condition needs close paren");
    parse(Statement,0); # optional
    return 1;
};

Break = func(x) {
    if (!parse(Keyword,"break")) return 0;
    return 1;
};

Continue = func(x) {
    if (!parse(Keyword,"continue")) return 0;
    return 1;
};

Return = func(x) {
    if (!parse(Keyword,"return")) return 0;
    if (!parse(Expression,0)) die("return needs expression");
    return 1;
};

Assignment = func(x) {
    if (parse(Identifier,0)) {
    } else {
        if (!parse(CharSkip,'*')) return 0;
        if (!parse(Term,0)) die("can't dereference non-expression");
    };
    if (!parse(CharSkip,'=')) return 0;
    if (!parse(Expression,0)) die("assignment needs rvalue");
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

HexLiteral = func(x) {
    if (!parse(String,"0x")) return 0;
    if (!parse(AnyChar,"0123456789abcdefABCDEF")) return 0;
    while (parse(AnyChar,"0123456789abcdefABCDEF"));
    #var val = 0;
    #while (pos0 != pos) {
    #    val = val * 10;
    #    val += s[pos0++] - '0';
    #};
    #genliteral(val);
    skip();
    return 1;
};

DecimalLiteral = func(x) {
    var pos0 = pos;
    parse(AnyChar,"+-");
    if (!parse(AnyChar,"0123456789")) return 0;
    while (parse(AnyChar,"0123456789"));
    #var val = 0;
    #while (pos0 != pos) {
    #    val = val * 10;
    #    val += s[pos0++] - '0';
    #};
    #genliteral(val);
    skip();
    return 1;
};

CharacterLiteral = func(x) {
    if (!parse(Char,'\'')) return 0;
    var ch = nextchar();
    if (ch == '\\') {
        nextchar();
    } else {
    };
    if (parse(CharSkip,'\'')) return 1;
    die("illegal character literal");
};

StringLiteral = func(x) {
    if (!parse(Char,'"')) return 0;
    var str = StringLiteralText();
    return 1;
};

# expects you to have already parsed the opening quote; consumes the closing quote
StringLiteralText = func(x) {
    var pos0 = pos;
    while (1) {
        if (parse(CharSkip,'"')) {
            # allocate a string by copying input between pos0 and pos
            return 1;
        };
        if (parse(Char,'\\')) {
            nextchar();
        } else {
            nextchar();
        };
    };
    die("unterminated string literal");
};

var maxparams = 32;
var PARAMS = malloc(maxparams);
# TODO: bounds check
Parameters = func(x) {
    var p = PARAMS;
    while (1) {
        if (!parse(Identifier,0)) break;
        # *(p++) = IDENTIFIER;
        if (!parse(CharSkip,',')) break;
    };
    *p = 0;
    return PARAMS;
};

FunctionDeclaration = func(x) {
    if (!parse(Keyword,"func")) return 0;
    if (!parse(CharSkip,'(')) die("func needs open paren");
    var params = Parameters(0);
    if (!parse(CharSkip,')')) die("func needs close paren");
    parse(Statement,0); # optional
    return 1;
};

FunctionCall = func(x) {
    if (!parse(Identifier,0)) return 0;
    if (!parse(CharSkip,'(')) return 0;
    parse(Arguments,0);
    if (!parse(CharSkip,')')) die("argument list needs closing paren");
    return 1;
};

Arguments = func(x) {
    while (1) {
        if (!parse(Expression,0)) return 1;
        if (!parse(CharSkip,',')) return 1;
    }
};

PreOp = func(x) {
    if (parse(String,"++")) {
    } else if (parse(String,"--")) {
    } else {
        return 0;
    };
    skip();
    if (!parse(Identifier,0)) return 0;
    skip();
    return 1;
};

PostOp = func(x) {
    if (!parse(Identifier,0)) return 0;
    skip();
    if (parse(String,"++")) {
    } else if (parse(String,"--")) {
    } else {
        return 0;
    };
    skip();
    return 1;
};

AddressOf = func(x) {
    if (!parse(CharSkip,'&')) return 0;
    if (!parse(Identifier,0)) die("address-of (&) needs identifier");
    return 1;
};

UnaryExpression = func(x) {
    if (!parse(AnyChar,"!~*+-")) return 0;
    skip();
    if (!parse(Term,0)) die("unary operator $op needs operand"); # TODO: sprintf
    return 1;
};

ParenExpression = func(x) {
    if (!parse(CharSkip,'(')) return 0;
    if (parse(Expression,0)) return parse(CharSkip,')');
    return 0;
};

Identifier = func(x) {
    var pos0 = pos;
    if (!parse(AlphaUnderChar,0)) return 0;
    while (parse(AlphanumUnderChar,0));
    # now IDENTIFIER = substr(s, pos0, pos-pos0)
    skip();
    return 1;
};

var buf = malloc(16384);
*buf = 0;
while (gets(buf+strlen(buf), 16384)); # XXX: bad

parse_init(buf);
if (parse(Program,0)) {
    puts("ok\n");
} else {
    puts("bad\n");
};
