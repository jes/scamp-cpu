# ASM-in-SLANG by jes
#
# TODO: [nice] -v "annotated hex" mode
# TODO: [nice] tidy up variable names and code layout, comment stuff that's not clear

include "asmparser.sl";
include "bufio.sl";
include "hash.sl";
include "stdio.sl";
include "stdlib.sl";
include "string.sl";

var asm_constant;
var pc_start = 0;
var asm_pc;

var maxliteral = 128;
var literal_buf = malloc(maxliteral);
var maxidentifier = maxliteral;
var IDENTIFIER = literal_buf; # reuse literal_buf for identifiers

var IDENTIFIERS;
var INTERN_CONST = 0xface;
var code_filename;
var code_fd;
var code_bio;
var unbounds_filename;
var unbounds_fd;
var unbounds_bio;

var lookup = func(name) {
    return htgetkv(IDENTIFIERS, name);
};

var store = func(name,val) {
    htput(IDENTIFIERS, name, val);
};

# return a pointer to an existing stored copy of "name", or strdup() one if there is none
var intern = func(name) {
    var p = htfind(IDENTIFIERS, name);
    if (*p) return *p;
    # TODO: [bug?] we abuse IDENTIFIERS as a string interning table; currently
    #       don't think it matters because the only time we intern() a string is
    #       when we either already have it in IDENTIFIERS, or we're about to put
    #       it in
    name = strdup(name);
    htputp(IDENTIFIERS, p, name, INTERN_CONST);
    return name;
};

var add_unbound = func(name,addr) {
    # TODO: [perf] when we buffer writes, we'll sometimes have to add_unbound()
    #       for some address that is still in the buffer; we can just update it
    #       in memory instead of writing it to disk
    bwrite(unbounds_bio, [name,addr], 2);
};

var reserved = func(name) {
    if (strcmp(name,"x") == 0) return 1;
    if (strcmp(name,"y") == 0) return 1;
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
    if (!AlphaUnderChar(0)) return 0;
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
    if (!AnyChar(alphabet)) return 0;
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
    if (!String("0x")) return 0;
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
    if (!Identifier(0)) return 0;
    var v = lookup(IDENTIFIER);
    if (!v) return 0;
    # we don't accept identifiers equal to INTERN_CONST because they might
    # just be intern()'d strings rather than actual known values (but
    # ignoring them should normally not be a problem)
    if (cdr(v) == INTERN_CONST) return 0;
    asm_constant = cdr(v);
    return 1;
};

I8l = func(x) {
    if (!Constant(0)) return 0;
    if (asm_constant gt 0x00ff) return 0;
    asm_i8 = asm_constant;
    return 1;
};

I8h = func(x) {
    if (!Constant(0)) return 0;
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
    if (!Identifier(0)) return 0;
    i16_identifier = intern(IDENTIFIER);
    return 1;
};

# "Endline" is similar to "skip" except it doesn't match if it stops before
# reaching the end of the line
var Endline = func(x) {
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
        i16_identifier = 0;
        asm_i16 = val;
    } else {
        die("invalid indirection width: %d",[width]);
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

    if (!Char('(')) return 0;
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

IndirectionEquals = func(val) {
    # XXX: abuse Indirection(16)
    var asm_i16_bak = asm_i16;
    if (!Indirection(16)) return 0;
    if (i16_identifier || asm_i16 != val) return 0;
    asm_i16 = asm_i16_bak;
    return 1;
};

var Def = func(x) {
    # TODO: [nice] this should maybe allow arbitrary string replacement, not just numeric constants
    if (!String(".d")) return 0;
    String("ef"); # allow ".def"

    skip();
    if (!Identifier(0)) die(".def needs identifier",0);
    # we strdup() rather than intern() because names ought to be unique anyway
    var name = strdup(IDENTIFIER);
    skip();
    if (!Constant(0)) die(".def needs constant",0);
    store(name,asm_constant);
    return 1;
};

var At = func(x) {
    if (!String(".at")) return 0;
    skip();
    if (!Constant(0)) die(".at needs constant",0);
    skip();

    var at = asm_constant;

    if (at lt asm_pc) die(".at %d but we're already at %d",[at,asm_pc]);

    if (asm_pc == 0) {
        pc_start = at;
        asm_pc = at;
    } else {
        while (asm_pc != at) {
            emit(0);
        };
    };

    return 1;
};

var Gap = func(x) {
    if (!String(".g")) return 0;
    String("ap"); # allow ".gap"

    skip();
    if (!Constant(0)) die(".gap needs constant",0);
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
    if (!String(".str")) return 0;
    skip();
    if (!Char('"')) return 0;

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
    if (!String(".w")) return 0;
    String("ord"); # allow ".word"

    skip();
    if (!I16(0)) return 0;
    skip();

    emit_i16();

    return 1;
};

var emitblob = func(name) {
    var fd = open(name, O_READ);
    if (fd < 0) die("open %s: %s", [name, strerror(fd)]);

    var bufsz = 1024;
    var buf = malloc(bufsz);
    var n;
    var p;
    while (1) {
        n = read(fd, buf, bufsz);
        if (n == 0) break;
        if (n < 0) die("read %s: %s", [name, strerror(fd)]);
        if (bwrite(code_bio, buf, n) != n) die("write() didn't write enough",0);
        if ((asm_pc + n) lt asm_pc) die(".blob %s: overflows address space", [name]);
        asm_pc = asm_pc + n;
    };

    free(buf);
};

var Blob = func(x) {
    if (!String(".blob")) return 0;
    skip();

    if (parse(AnyChar," \t\r\n")) return 0;
    *IDENTIFIER = nextchar();
    var i = 1;
    while (i < maxidentifier) {
        if (parse(AnyChar," \t\r\n")) {
            *(IDENTIFIER+i) = 0;
            # TODO: [perf] instead of emitting the blob now, since we know it
            #       doesn't contain any labels, we could just remember the name
            #       of it and the current asm_pc, and emit it during the 2nd
            #       pass, to save time writing it out and reading it in again
            emitblob(IDENTIFIER);
            skip();
            return 1;
        };
        *(IDENTIFIER+i) = nextchar();
        i++;
    };
    die("blob name too long",0);
};

var Label = func(x) {
    if (!Identifier(0)) return 0;
    skip();
    if (!CharSkip(':')) return 0;

    # we strdup() rather than intern() because labels ought to be unique anyway
    store(strdup(IDENTIFIER), asm_pc);
    return 1;
};

var Assembly = func(x) {
    while (1) {
        skip();

        if (peekchar() == '.') {
            if (parse(Def,0)) continue;
            if (parse(At,0)) continue;
            if (parse(Gap,0)) continue;
            if (parse(Str,0)) continue;
            if (parse(Word,0)) continue;
            if (parse(Blob,0)) continue;
        } else {
            if (parse(Label,0)) continue;
            if (parse(Instr,0)) continue;
        };

        return 1;
    };
};

Instr_args = func(v) {
    var emit_val = v[0];
    v++;
    var f;
    var arg;
    while (*v) {
        f = *(v++);
        arg = *(v++);
        if (!f(arg)) return 0;
    };
    if (!Endline(0)) return 0;
    skip();
    if (emit_val & 1) emit(opcode | asm_i8)
    else emit(opcode);
    if (emit_val & 2) emit_i16();
    return 1;
};

Instr_anyargs = func(v) {
    var name = *(v++);
    if (!String(name)) return 0;
    if (parse(NotAnyChar," \t\r\n")) return 0;
    while(parse(AnyChar," \t\r"));
    while (*v) {
        opcode = *(v+1);
        if (parse(Instr_args,*v)) return 1;
        v = v + 2;
    };
    die("illegal %s instruction", [name]);
};

emit = func(v) {
    bputc(code_bio, v);
    asm_pc++;
    if (asm_pc == 0) die("address space overflows",0);
};

emit_i16 = func() {
    var v;
    if (i16_identifier) {
        add_unbound(i16_identifier, asm_pc);
        emit(0);
    } else {
        emit(asm_i16);
    };
};

# read code from "code_filename", resolve unbound names using "unbounds_bio", and
# write resulting code to stdout
var resolve_unbounds = func() {
    # "unbounds" are created in-order, so we can just read one at a time and get
    # the next every time we reach the address of the next unbound
    var name;
    var addr = -1;
    var v;
    var val;

    name = bgetc(unbounds_bio);
    addr = bgetc(unbounds_bio);

    var fd = open(code_filename, O_READ);
    if (fd < 0) die("open %s: %s", [code_filename, strerror(fd)]);

    var code = malloc(254);

    var n;
    var pc = pc_start;
    while (1) {
        # 1. read a block of code
        n = read(fd, code, 254);
        fputc(2, '.');
        if (n < 0) die("read code: %s\n", [strerror(n)]);
        if (n == 0) break;

        # 2. while next unbound addr lies within the block:
        while (addr lt pc+n) {
            # 3. replace the unbound
            v = lookup(name);
            if (!v) die("unrecognised name %s at addr 0x%x", [name, addr]);
            *(code+addr-pc) = cdr(v);

            # 4. grab the next unbound
            name = bgetc(unbounds_bio);
            addr = bgetc(unbounds_bio);
        };

        pc = pc + n;

        # 5. write the block of code
        n = write(1, code, n);
        if (n <= 0) die("write code: %s\n", [strerror(n)]);
    };
    fputc(2, '\n');
    close(fd);
    free(code);
};

IDENTIFIERS = htnew();

code_filename = strdup(tmpnam());
code_fd = open(code_filename, O_WRITE|O_CREAT);
if (code_fd < 0) die("open %s: %s", [code_filename, strerror(code_fd)]);
code_bio = bfdopen(code_fd, O_WRITE);

unbounds_filename = strdup(tmpnam());
unbounds_fd = open(unbounds_filename, O_WRITE|O_CREAT);
if (unbounds_fd < 0) die("open %s: %s", [unbounds_filename, strerror(unbounds_fd)]);
unbounds_bio = bfdopen(unbounds_fd, O_WRITE);

fprintf(2, "1st pass...\n", 0);
var inbuf = bfdopen(0, O_READ);
var charcount = 0;
parse_init(func() {
    charcount++;
    if ((charcount & 0x3ff) == 0) fputc(2, '.');
    return bgetc(inbuf);
});
parse(Assembly,0);
if (nextchar() != EOF) die("garbage after end",0);
bclose(code_bio);

# reopen unbounds file for reading
bclose(unbounds_bio);
unbounds_fd = open(unbounds_filename, O_READ);
if (unbounds_fd < 0) die("open %s: %s", [unbounds_filename, strerror(unbounds_fd)]);
unbounds_bio = bfdopen(unbounds_fd, O_READ);

fputc(2, '\n');
fprintf(2, "2nd pass...\n", 0);
resolve_unbounds();
unlink(code_filename);
bclose(unbounds_bio);
unlink(unbounds_filename);
