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

var nextchar = func() {
    var ch = *(input+pos);
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

# accept only character ch, skip whitespace and comments
var CharSkip = func(ch) {
    if (nextchar() != ch) return 0;
    skip();
    return 1;
};


