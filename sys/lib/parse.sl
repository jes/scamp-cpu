# Parsing routines
#
# TODO: [nice] better-namespaced globals

include "malloc.sl";

var pos;
var readpos;
var line;
var parse_getchar;
var parse_filename;

var ringbufsz = 256; # check the "too much backtrack" test, and peekchar(), before changing this
var ringbuf = malloc(ringbufsz);

var die = func(fmt, args) {
    fprintf(2, "error: ", 0);
    if (parse_filename)
        fprintf(2, "%s: ", [parse_filename]);
    fprintf(2, "line %d: ", [line]);
    fprintf(2, fmt, args);
    fputc(2, '\n');
    exit(1);
};

var warn = func(fmt, args) {
    fprintf(2, "warning: ", 0);
    if (parse_filename)
        fprintf(2, "%s: ", [parse_filename]);
    fprintf(2, "line %d: ", [line]);
    fprintf(2, fmt, args);
    fputc(2, '\n');
};

# setup parser state ready to parse the given string
var parse_init = func(getchar_func) {
    pos = 0;
    readpos = 0;
    line = 1;
    parse_getchar = getchar_func;
    parse_filename = 0;
};

# call a parsing function and return whatever it returned
# if it returned 0, reset input position before returning
# the parsing function should expect exactly 1 argument
#var slang_parse = func(f, arg) {
#    var pos0 = pos;
#    var line0 = line;
#
#    var r = f(arg);
#    if (r) return r;
#
#    # die if pos-pos0 >= 256 (update this if ringbufsz changes)
#    if ((pos-pos0) & 0xff00) die("too much backtrack",0);
#
#    pos = pos0;
#    line = line0;
#    return 0;
#};

var asm_parse = asm {
    pop x
    ld r0, x # r0 = arg
    pop x
    ld r1, x # r1 = f

    ld x, (_pos) # pos0
    push x
    ld x, (_line) # line0
    push x

    ld x, r254
    push x # save return address

    ld x, r0
    push x # push arg
    call r1 # r0 = f(arg)
    pop x
    ld r254, x # restore return address

    test r0
    jz parsereset
    ret 2 # skip over line0,pos0

    parsereset:
    pop x
    ld (_line), x # line0
    pop x
    ld r4, x # pos0

    ld r1, (_pos)
    sub r1, r4
    and r1, 0xff00
    jz parsereturn

    ld x, tmb_s
    push x
    push 0
    ld x, (_die)
    call x

    parsereturn:
    ld (_pos), r4
    ret

    tmb_s: .str "too much backtrack\0"
};

var parse = asm_parse;

# look at the next input char without advancing the cursor
#var slang_peekchar = func() {
#    var lookpos = pos&0xff; # 0xff == ringbufsz-1
#    if (lookpos == readpos) {
#        *(ringbuf+readpos) = parse_getchar();
#        readpos = (readpos+1)&0xff; # 0xff == ringbufsz-1
#    };
#    return ringbuf[lookpos];
#};
var asm_peekchar = asm {
    ld r0, (_pos)
    and r0, 0xff # 0xff == ringbufsz-1
    ld (peekchar_lookpos), r0
    sub r0, (_readpos)
    jnz peekchar_good

    ld x, r254
    push x
    call (_parse_getchar)
    pop x
    ld r254, x
    ld r1, (_ringbuf)
    ld r2, (_readpos)
    add r1, r2
    ld x, r0
    ld (r1), x
    inc r2
    and r2, 0xff # 0xff == ringbufsz-1
    ld (_readpos), r2

    peekchar_good:
    ld x, (_ringbuf)
    add x, (peekchar_lookpos)
    ld r0, (x)
    ret

    peekchar_lookpos: .word 0
};
var peekchar = asm_peekchar;

#var slang_nextchar = func() {
#    var ch = peekchar();
#    if (ch == EOF) return EOF;
#    if (ch == '\n') line++;
#    pos++;
#    return ch;
#};
var asm_nextchar = asm {
    ld x, r254
    push x
    call (_peekchar)
    pop x
    ld r254, x

    cmp r0, 10 # '\n'
    jnz nextchar_notnl
    inc (_line)
    inc (_pos)
    ret
    nextchar_notnl:

    ld x, r0
    not x
    jz nextchar_eof
    inc (_pos)

    nextchar_eof:
    ret
};
var nextchar = asm_nextchar;

# accept only character ch
var Char = func(ch) {
    if (nextchar() != ch) return 0;
    return 1;
};

# accept any character except ch
var NotChar = func(ch) {
    if (nextchar() == ch) return 0;
    return 1;
};

# accept any character from s
#var slang_AnyChar = func(s) {
#    var ch = nextchar();
#    if (ch == EOF) return 0;
#    while (*s)
#        if (ch == *(s++)) return 1;
#    return 0;
#};
var asm_AnyChar = asm {
    ld x, r254
    push x
    call (_nextchar) # r0 is the character of input
    pop x
    ld r254, x

    pop x
    ld r1, x # r1 is string pointer

    test r0
    jlt AnyChar_ret0 # EOF?

    AnyChar_loop:
        ld x, (r1) # x is current character from string
        test x
        jz AnyChar_ret0 # end of string?
        sub x, r0
        jz AnyChar_ret1 # matched the character?
        inc r1
        jmp AnyChar_loop

    AnyChar_ret0:
    ld r0, 0
    ret
    AnyChar_ret1:
    ld r0, 1
    ret
};
var AnyChar = asm_AnyChar;

# accept any character not from s
var NotAnyChar = func(s) {
    var ch = nextchar();
    if (ch == EOF) return 0;
    while (*s)
        if (ch == *(s++)) return 0;
    return 1;
};

# accept precisely the string s
#var slang_String = func(s) {
#    while (*s)
#        if (nextchar() != *(s++)) return 0;
#    return 1;
#};
var asm_String = asm {
    ld x, r254
    ld (String_ret), x

    pop x
    ld (String_str), x # String_str is string pointer

    String_loop:
        ld x, ((String_str)) # x is current character from string
        test x
        jz String_ret1 # end of string?

        push x
        call (_nextchar) # r0 is next character of input
        pop x
        sub x, r0
        jnz String_ret0 # didn't match the character?
        inc (String_str)
        jmp String_loop

    String_ret0:
    ld r0, 0
    jmp (String_ret)
    String_ret1:
    ld r0, 1
    jmp (String_ret)

    String_ret: .word 0
    String_str: .word 0
};
var String = asm_String;


# skip over whitespace and comments
var skip = func() {
    while (1) {
        if (parse(Char,'#')) { # skip comment
            while (parse(NotChar,'\n'));
        } else if (!parse(AnyChar," \t\r\n")) { # done if not whitespace
            return 1;
        }
    }
};

# accept string s if it ends at a word boundary
var Keyword = func(s) {
    if (!parse(String,s)) return 0;
    var ch = peekchar();
    var alnumunder = isalnum(ch) || ch == '_';
    if (ch == 0 || !alnumunder) {
        skip();
        return 1;
    };
    return 0;
};

# accept alpha and underscore
var AlphaUnderChar = func(x) {
    var ch = nextchar();
    if (isalpha(ch) || ch == '_') return 1;
    return 0;
};

# accept alphanumeric and underscore
var AlphanumUnderChar = func(x) {
    var ch = nextchar();
    if (isalnum(ch) || ch == '_') return 1;
    return 0;
};

# accept only character ch, skip whitespace and comments
var CharSkip = func(ch) {
    if (nextchar() != ch) return 0;
    skip();
    return 1;
};


