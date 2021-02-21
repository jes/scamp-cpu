var EOF = -1;

# usage: inp(addr)
var inp = asm {
    pop x
    in r0, x
    ret
};

# usage: outp(addr, value)
var outp = asm {
    pop x
    ld r0, x
    pop x
    out x, r0
    ret
};

var getchar = func() {
    return inp(2);
};

var putchar = func(ch) {
    outp(2, ch);
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

# take a pointer to a nul-terminated string, and print it
var puts = asm {
    pop x
    print_loop:
        out 2, (x)
        inc x
        test (x)
        jnz print_loop
    ret
};
