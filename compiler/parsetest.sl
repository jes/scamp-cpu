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

Program = func(x) {
    skip();
    parse(Statements,0);
    if (nextchar() != EOF) return 0;
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
    if (!parse(CharSkip,'}')) return 0;
    return 1;
};

Extern = Reject;
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

var buf = malloc(16384);
while (gets(buf, 16384)) {
    parse_init(buf);
    if (parse(Program,0)) {
        puts("ok\n");
    } else {
        puts("bad\n");
    };
};
