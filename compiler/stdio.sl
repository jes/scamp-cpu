extern inp;
extern outp;

var SERIALDEV = 2;
var EOF = -1;

var getchar = func() {
    return inp(SERIALDEV);
};

var putchar = func(ch) {
    outp(SERIALDEV, ch);
};

# read at most size-1 characters into s, and terminate with a 0
# return s if any chars were read
# return 0 if EOF was reached with no chars
var gets = func(s, size) {
    var ch = 0;
    var len = 0;

    while (ch != EOF && ch != '\n' && len < size) {
        ch = getchar();
        if (ch != EOF)
            *(s+(len++)) = ch;
    };

    if (ch == EOF && len == 0)
        return 0;

    *(s+len) = 0;

    return s;
};

var puts = func(s) {
    while (*s)
        putchar(*(s++));
};
