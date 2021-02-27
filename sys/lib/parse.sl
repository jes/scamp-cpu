# Parsing routines
#
# TODO: better-namespaced globals

var pos;
var readpos;
var line;

var ringbufsz = 256; # check the "too much backtrack" test, and peekchar(), before changing this
var ringbuf = malloc(ringbufsz);

var die = func(fmt, args) {
    printf("error: line %d: ", [line]);
    if (args) printf(fmt, args);
    putchar('\n');
    exit(1);
};

# setup parser state ready to parse the given string
var parse_init = func() {
    pos = 0;
    readpos = 0;
    line = 1;
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
    ld r3, x # line0
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
    ld (_line), r3
    ret

    tmb_s: .str "too much backtrack\0"
};

var parse = asm_parse;

# look at the next input char without advancing the cursor
var peekchar = func() {
    var lookpos = pos&0xff; # 0xff == ringbufsz-1
    if (lookpos == readpos) {
        *(ringbuf+readpos) = getchar();
        readpos = (readpos+1)&0xff; # 0xff == ringbufsz-1
    };
    return ringbuf[lookpos];
};

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

    ld x, r0
    sub x, 10 # '\n'
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
var AnyChar = func(s) {
    var ch = nextchar();
    while (*s) {
        if (ch == *s) return 1;
        s++;
    };
    return 0;
};

# accept precisely the string s
var String = func(s) {
    while (*s)
        if (nextchar() != *(s++))
            return 0;
    return 1;
};

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


