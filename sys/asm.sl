# ASM-in-SLANG by jes
#
# TODO: [nice] -v "annotated hex" mode
# TODO: [nice] tidy up variable names and code layout, comment stuff that's not clear
# TODO: [bug] the assembler can't currently assemble its own code because it runs out of
#       memory - maybe move "CODE" onto the disk?

include "grarr.sl";
include "stdlib.sl";
include "stdio.sl";
include "string.sl";
include "asmparser.sl";

var asm_constant;
var pc_start = 0;
var asm_pc;

var maxliteral = 512;
var literal_buf = malloc(maxliteral);
var maxidentifier = maxliteral;
var IDENTIFIER = literal_buf; # reuse literal_buf for identifiers

var IDENTIFIERS;
var UNBOUNDS;
var CODE;

var lookup = func(name) {
    return grfind(IDENTIFIERS, name, func(findname,tuple) { return strcmp(findname,car(tuple))==0; });
};

var store = func(name,val) {
    grpush(IDENTIFIERS, cons(name,val));
};

var add_unbound = func(name,addr) {
    grpush(UNBOUNDS, cons(name,addr));
};

var reserved = func(name) {
    if (strcmp(name,"x") == 0) return 1;
    if (strcmp(name,"sp") == 0) return 1;
    if (*name == 'r') {
        name++;
        while (*name) {
            if (!isdigit(*name)) return 0;
            name++;
        };
        return 1;
    };
    return 0;
};

var Identifier = func(x) {
    *IDENTIFIER = peekchar();
    if (!parse(AlphaUnderChar,0)) return 0;
    var i = 1;
    while (i < maxidentifier) {
        *(IDENTIFIER+i) = peekchar();
        if (!parse(AlphanumUnderChar,0)) {
            *(IDENTIFIER+i) = 0;
            if (reserved(IDENTIFIER)) return 0;
            return 1;
        };
        i++;
    };
    die("identifier too long",0);
};

var NumLiteral = func(alphabet,base,neg) {
    *literal_buf = peekchar();
    if (!parse(AnyChar,alphabet)) return 0;
    var i = 1;
    while (i < maxliteral) {
        *(literal_buf+i) = peekchar();
        if (!parse(AnyChar,alphabet)) {
            *(literal_buf+i) = 0;
            if (neg) asm_constant = -atoibase(literal_buf,base)
            else     asm_constant =  atoibase(literal_buf,base);
            return 1;
        };
        i++;
    };
    die("numeric literal too long",0);
};

var HexLiteral = func(x) {
    if (!parse(String,"0x")) return 0;
    return NumLiteral("0123456789abcdefABCDEF",16,0);
};

var DecimalLiteral = func(x) {
    var neg = peekchar() == '-';
    parse(AnyChar,"+-");
    return NumLiteral("0123456789",10,neg);
};

var Constant = func(x) {
    if (parse(HexLiteral,0)) return 1;
    if (parse(DecimalLiteral,0)) return 1;
    if (!parse(Identifier,0)) return 0;
    var v = lookup(IDENTIFIER);
    if (!v) return 0;
    asm_constant = cdr(v);
    return 1;
};

I8l = func(x) {
    if (!parse(Constant,0)) return 0;
    if (asm_constant gt 0x00ff) return 0;
    asm_i8 = asm_constant;
    return 1;
};

I8h = func(x) {
    if (!parse(Constant,0)) return 0;
    if (asm_constant lt 0xff00) return 0;
    asm_i8 = asm_constant & 0xff;
    return 1;
};

I16 = func(x) {
    if (parse(Constant,0)) {
        i16_identifier = 0;
        asm_i16 = asm_constant;
        return 1;
    };
    if (parse(Identifier,0)) {
        i16_identifier = strdup(IDENTIFIER);
        return 1;
    };
    return 0;
};

# "Endline" is similar to "skip" except it doesn't match if it stops before
# reaching the end of the line
Endline = func(x) {
    while (parse(AnyChar," \t\r")); # skip over whitespace
    if (parse(Char,'#')) { # skip comment
        while (parse(NotChar,'\n'));
    };
    if (parse(Char,'\n')) return 1;
    return 0;
};

var set_indirection = func(val,width) {
    if (width == 8) {
        asm_i8 = val & 0xff;
    } else if (width == 16) {
        asm_i16 = val;
    };
};

# "sp" or "rN" or "(i8h)" or "(i16)"
Indirection = func(width) {
    if (parse(String,"sp")) {
        set_indirection(0xffff, width);
        return 1;
    };
    if (parse(Char,'r')) {
        if (!parse(DecimalLiteral,0)) return 0;
        set_indirection(0xff00 | asm_constant, width);
        return 1;
    };

    if (!parse(Char,'(')) return 0;
    if (width == 8) {
        if (!parse(I8h,0)) return 0;
    } else if (width == 16) {
        if (!parse(I16,0)) return 0;
    } else {
        die("invalid indirection width: %d",[width]);
    };
    if (!parse(Char,')')) return 0;

    return 1;
};

var Def = func(x) {
    # TODO: [nice] this should maybe allow arbitrary string replacement, not just numeric constants
    if (!parse(String,".def")) return 0;
    skip();
    if (!parse(Identifier,0)) die(".def needs identifier",0);
    var name = strdup(IDENTIFIER);
    skip();
    if (!parse(Constant,0)) die(".def needs constant",0);
    store(name,asm_constant);
    return 1;
};

var At = func(x) {
    if (!parse(String,".at")) return 0;
    skip();
    if (!parse(Constant,0)) die(".at needs constant",0);
    skip();

    var at = asm_constant;

    if (at lt asm_pc) die(".at %d but we're already at %d",[at,asm_pc]);

    if (asm_pc == 0) {
        pc_start = at;
        asm_pc = at;
    } else {
        while (asm_pc != at) {
            emit(0);
            asm_pc++;
        };
    };

    return 1;
};

var Gap = func(x) {
    if (!parse(String,".gap")) return 0;
    skip();
    if (!parse(Constant,0)) die(".gap needs constant",0);
    skip();

    while (asm_constant--) emit(0);

    return 1;
};

var escapedchar = func(ch) {
    if (ch == 'r') return '\r';
    if (ch == 'n') return '\n';
    if (ch == 't') return '\t';
    if (ch == '0') return '\0';
    if (ch == ']') return '\]';
    return ch;
};

var Str = func(x) {
    if (!parse(String,".str")) return 0;
    skip();
    if (!parse(Char,'"')) return 0;

    while (1) {
        if (parse(Char,'"')) {
            skip();
            return 1;
        };
        if (parse(Char,'\\')) {
            emit(escapedchar(nextchar()));
        } else {
            emit(nextchar());
        };
    };
};

var Word = func(x) {
    if (!parse(String,".word")) return 0;
    skip();
    if (!parse(I16,0)) return 0;
    skip();

    emit_i16();

    return 1;
};

var Label = func(x) {
    if (!parse(Identifier,0)) return 0;
    skip();
    if (!parse(CharSkip,':')) return 0;

    var label = strdup(IDENTIFIER);
    store(label, asm_pc);
    return 1;
};

var Assembly = func(x) {
    while (1) {
        skip();

        if (parse(Def,0)) continue;
        if (parse(At,0)) continue;
        if (parse(Gap,0)) continue;
        if (parse(Str,0)) continue;
        if (parse(Word,0)) continue;
        if (parse(Label,0)) continue;
        if (parse(Instr,0)) continue;

        return 1;
    };
};

emit = func(v) {
    grpush(CODE,v);
    asm_pc++;
};

emit_i16 = func() {
    if (i16_identifier) {
        add_unbound(i16_identifier, asm_pc);
        emit(0);
    } else {
        emit(asm_i16);
    };
};

IDENTIFIERS = grnew();
UNBOUNDS = grnew();
CODE = grnew();

parse_init(getchar);
parse(Assembly,0);

if (nextchar() != EOF) die("garbage after end",0);

# resolve unbounds
var codebase = grbase(CODE)-pc_start;
grwalk(UNBOUNDS, func(tuple) {
    var name = car(tuple);
    var addr = cdr(tuple);
    var v = lookup(name);
    if (!v) die("unrecognised name %s at addr %x", [name, addr]);
    var val = cdr(v);
    *(codebase+addr) = val;
});

# emit code
grwalk(CODE, func(word) {
    putchar(word);
});
