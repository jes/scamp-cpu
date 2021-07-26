# rpn calculator

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
        push(pop() + pop());
    } else if (ch == '-') {
        b = pop();
        a = pop();
        push(a - b);
    } else if (ch == '*') {
        push(mul(pop(), pop()));
    } else if (ch == '/') {
        b = pop();
        a = pop();
        push(div(a, b));
    } else if (ch == '%') {
        b = pop();
        a = pop();
        push(mod(a, b));
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
    } else if (isdigit(ch)) {
        # TODO: [bug] buffer overflow
        *(bufp++) = ch;
        *bufp = 0;
    } else {
        if (*buf) {
            push(atoi(buf));
            bufp = buf;
            *bufp = 0;
        };

        if (ch == '\n') {
            printf("%d\n", [stacktop()]);
        } else {
            operator(ch);
        };
    };
};
