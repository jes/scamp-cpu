# Parsing routines
#
# TODO: better-namespaced globals

var pos;
var readpos;
var line;
var col;

var ringbufsz = 256; # check the "too much backtrack" test before changing this!
var ringbuf = malloc(ringbufsz);

var die = func(s) {
    puts("error: line "); puts(itoa(line)); puts(": col "); puts(itoa(col)); puts(": ");
    puts(s); putchar('\n');
    outp(3,0); # halt the emulator
};

# setup parser state ready to parse the given string
var parse_init = func() {
    pos = 0;
    readpos = 0;
    line = 1;
    col = 1;
};

# call a parsing function and return whatever it returned
# if it returned 0, reset input position before returning
# the parsing function should expect exactly 1 argument
var parse = func(f, arg) {
    var pos0 = pos;
    var line0 = line;
    var col0 = col;

    var r = f(arg);
    if (r) return r;

    # die if pos-pos0 >= 256 (update this if ringbufsz changes)
    if ((pos-pos0) & 0xff00) die("too much backtrack\n");

    pos = pos0;
    line = line0;
    col = col0;
    return 0;
};

# look at the next input char without advancing the cursor
var peekchar = func() {
    var lookpos = pos&(ringbufsz-1);
    if (lookpos == readpos) {
        *(ringbuf+readpos) = getchar();
        readpos = (readpos+1)&(ringbufsz-1);
    };
    return *(ringbuf+lookpos);
};

var nextchar = func() {
    var ch = peekchar();
    if (ch == EOF) return EOF;
    if (ch == '\n') {
        line++;
        col = 0;
    };
    pos++;
    col++;

    return ch;
};

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

# TODO: put these somewhere more useful
# TODO: ...and better-organise the standard library in general
var isalpha = func(ch) return (ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z');
var isdigit = func(ch) return ch >= '0' && ch <= '9';
var isalnum = func(ch) return isalpha(ch) || isdigit(ch);

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


