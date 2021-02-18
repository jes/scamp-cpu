# Dumb parsing program in slang
#
# TODO: accept multi-line input
# TODO: die instead of returning -1 when we find a failure
# TODO: generate code

include "stdio.sl";
include "stdlib.sl";
include "string.sl";
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

Program = func(x) {
    skip();
    parse(Statements,0);
    if (nextchar() != EOF) return 0; # die "garbage after end of program"
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
    if (!parse(CharSkip,'}')) return 0; # die "block needs closing brace"
    return 1;
};

Extern = func(x) {
    if (!parse(Keyword,"extern")) return 0;
    if (!parse(Identifier,0)) return 0; # die "extern needs identifier"
    return 1;
};

Declaration = Reject;
Conditional = Reject;
Loop = Reject;

Break = func(x) {
    if (!parse(Keyword,"break")) return 0;
    return 1;
};

Continue = func(x) {
    if (!parse(Keyword,"continue")) return 0;
    return 1;
};

Return = Reject;
Assignment = Reject;
Expression = Reject;
ExpressionLevel = Reject;
Term = Reject;
Constant = Reject;
NumericLiteral = Reject;
HexLiteral = Reject;
DecimalLiteral = Reject;
CharacterLiteral = Reject;
StringLiteral = Reject;
StringLiteralText = Reject;
FunctionDeclaration = Reject;
Parameters = Reject;
FunctionCall = Reject;
Arguments = Reject;
PreOp = Reject;
PostOp = Reject;
AddressOf = Reject;
UnaryExpression = Reject;
ParenExpression = Reject;

Identifier = func(x) {
    var pos0 = pos;
    if (!parse(AlphaUnderChar,0)) return 0;
    while (parse(AlphanumUnderChar,0));
    # now IDENTIFIER = substr(s, pos0, pos-pos0)
    skip();
    return 1;
};

var buf = malloc(16384);
while (gets(buf, 16384)) {
    parse_init(buf);
    if (parse(Program,0)) {
        puts("ok\n");
    } else {
        puts("bad\n");
    };
};
