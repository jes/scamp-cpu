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
var gets = func(s, size) {
    var ch = 0;
    var len = 0;

    while (ch != EOF && ch != '\n') {
        ch = getchar();
        if (ch != EOF) {
            *(s+len) = ch;
            len = len + 1;
        }
    };

    *(s+len) = 0;

    return s;
};

var puts = func(s) {
    while (*s) {
        putchar(*(s++));
    }
};
