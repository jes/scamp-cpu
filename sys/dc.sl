# bigint rpn calculator

include "bigint.sl";
include "bufio.sl";
include "grarr.sl";
include "malloc.sl";
include "stdio.sl";

var stack = grnew();

var push = func(val) {
    grpush(stack, val);
};

var pop = func() {
    return grpop(stack);
};

var stacktop = func() {
    return grget(stack, grlen(stack)-1);
};

var operator = func(ch) {
    var a;
    var b;
    if (ch == '+') {
        b = pop();
        a = pop();
        push(bigadd(a, b));
        bigfree(b);
    } else if (ch == '-') {
        b = pop();
        a = pop();
        push(bigsub(a, b));
        bigfree(b);
    } else if (ch == '*') {
        b = pop();
        a = pop();
        push(bigmul(a, b));
        bigfree(b);
    } else if (ch == '/') {
        b = pop();
        a = pop();
        push(bigdiv(a, b));
        bigfree(b);
    } else if (ch == '%') {
        b = pop();
        a = pop();
        push(bigmod(a, b));
        bigfree(b);
    } else if (!iswhite(ch)) {
        fprintf(2, "%c: unrecognised operator\n", [ch]);
    };
};

var in = bfdopen(0, O_READ);

var bufsz = 256;
var buf = malloc(bufsz);
*buf = 0;
var bufp = buf;

var ch;
while (1) {
    ch = bgetc(in);
    if (ch == EOF) {
        break;
    } else if (isdigit(ch) || ch == '_') {
        if ((bufp - buf) >= (bufsz-1)) {
            fprintf(2, "input buffer overflow\n", 0);
            exit(1);
        };
        if (ch == '_') ch = '-'; # underscore prefix for negative numbers
        *(bufp++) = ch;
        *bufp = 0;
    } else {
        if (*buf) {
            push(bigatoi(buf));
            bufp = buf;
            *bufp = 0;
        };

        if (ch == '\n') {
            printf("%b\n", [stacktop()]);
        } else {
            operator(ch);
        };
    };
};
