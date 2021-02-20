# Parsing routines
#
# TODO: don't require entire input to be loaded into memory
# TODO: better-namespaced globals
# TODO: some exception-handling mechanism

var input;
var pos;
var line;
var col;

# setup parser state ready to parse the given string
var parse_init = func(s) {
    input = s;
    pos = 0;
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

    pos = pos0;
    line = line0;
    col = col0;
    return 0;
};

# look at the next char without advancing the cursor
var peekchar = func() {
    return *(input+pos);
};

var nextchar = func() {
    var ch = peekchar();
    if (ch == 0) return EOF;
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


