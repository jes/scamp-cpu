# ASM-in-SLANG by jes
#
# TODO: [nice] -v "annotated hex" mode
# TODO: [nice] tidy up variable names and code layout, comment stuff that's not clear
# TODO: [bug] the assembler currently runs out of memory on large programs

include "grarr.sl";
include "hash.sl";
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
var STRINGS;
var code_filename;
var code_fd;
var code_buf = malloc(257);
var unbounds_filename;
var unbounds_fd;
var unbounds_buf = malloc(257);

var lookup = func(name) {
    return htget(IDENTIFIERS, name);
};

var store = func(name,val) {
    htput(IDENTIFIERS, name, val);
};

# return a pointer to an existing stored copy of "name", or strdup() one if there is none
var intern = func(name) {
    var v = grfind(STRINGS, name, func(a,b) { return strcmp(a,b)==0 });
    if (v) return v;

    name = strdup(name);
    grpush(STRINGS, name);
    return name;
};

var add_unbound = func(name,addr) {
    write(unbounds_fd, [name,addr], 2);
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
        i16_identifier = intern(IDENTIFIER);
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
    var name = intern(IDENTIFIER);
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
        if (write(code_fd, buf, n) != n) die("write() didn't write enough",0);
        asm_pc = asm_pc + n;
    };

    free(buf);
};

var Blob = func(x) {
    if (!parse(String,".blob")) return 0;
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
    if (!parse(Identifier,0)) return 0;
    skip();
    if (!parse(CharSkip,':')) return 0;

    store(intern(IDENTIFIER), asm_pc);
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
        if (parse(Blob,0)) continue;
        if (parse(Label,0)) continue;
        if (parse(Instr,0)) continue;

        return 1;
    };
};

emit = func(v) {
    # TODO: [perf] buffer writes
    fputc(code_fd, v);
    asm_pc++;
};

emit_i16 = func() {
    var v;
    if (i16_identifier) {
        v = lookup(i16_identifier);
        if (v) {
            emit(cdr(v));
        } else {
            add_unbound(i16_identifier, asm_pc);
            emit(0);
        };
    } else {
        emit(asm_i16);
    };
};

# read code from "code_filename", resolve unbound names using "unbounds_fd", and
# write resulting code to stdout
var resolve_unbounds = func() {
    # "unbounds" are created in-order, so we can just read one at a time and get
    # the next every time we reach the address of the next unbound
    var tuple = [0,0];
    var name;
    var addr = -1;
    var v;
    var val;

    if (read(unbounds_fd, tuple, 2)) {
        name = car(tuple);
        addr = cdr(tuple);
    };

    var fd = open(code_filename, O_READ);
    if (fd < 0) die("open %s: %s", [code_filename, strerror(code_fd)]);

    setbuf(fd, code_buf);

    var n;
    var w;
    var pc = pc_start;
    var buf = malloc(254);
    var bufend = buf;
    var bufp = buf;
    while (1) {
        if (bufp == bufend) {
            n = read(fd, buf, 254);
            if (n == 0) break;
            if (n < 0) die("read %s: %s", [code_filename, strerror(n)]);
            bufp = buf;
            bufend = buf+n;
        };

        w = *(bufp++);

        if (pc == addr) { # resolve an unbound address here
            v = lookup(name);
            if (!v) die("unrecognised name %s at addr 0x%x", [name, addr]);
            val = cdr(v);
            w = val;

            if (read(unbounds_fd, tuple, 2)) {
                name = car(tuple);
                addr = cdr(tuple);
            };
        };

        putchar(w);
        pc++;
    };
    close(fd);
};

IDENTIFIERS = htnew();
STRINGS = grnew();

code_filename = strdup(tmpnam());
code_fd = open(code_filename, O_WRITE|O_CREAT);
if (code_fd < 0) die("open %s: %s", [code_filename, strerror(code_fd)]);

unbounds_filename = strdup(tmpnam());
unbounds_fd = open(unbounds_filename, O_WRITE|O_CREAT);
if (unbounds_fd < 0) die("open %s: %s", [unbounds_filename, strerror(unbounds_fd)]);

setbuf(0,malloc(257));
setbuf(1,malloc(257));
setbuf(code_fd,code_buf);
setbuf(unbounds_fd,unbounds_buf);

fprintf(2, "1st pass...\n", 0);
var inbufsz = 1024;
var inbuf = malloc(inbufsz);
var inbuflen = 0;
var inpos = 0;
parse_init(func() {
    var n;
    if (inpos == inbuflen) {
        n = read(0, inbuf, inbufsz);
        if (n < 0) die("read stdin: %s", [strerror(n)]);
        if (n == 0) return EOF;
        inbuflen = n;
        inpos = 0;
    };

    return inbuf[inpos++];
});
parse(Assembly,0);
if (nextchar() != EOF) die("garbage after end",0);
close(code_fd);

# reopen unbounds file for reading
close(unbounds_fd);
unbounds_fd = open(unbounds_filename, O_READ);
if (unbounds_fd < 0) die("open %s: %s", [unbounds_filename, strerror(unbounds_fd)]);
setbuf(unbounds_fd,unbounds_buf);

fprintf(2, "2nd pass...\n", 0);
resolve_unbounds();
unlink(code_filename);
close(unbounds_fd);
unlink(unbounds_filename);
