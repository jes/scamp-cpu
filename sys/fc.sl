# fixed-point rpn calculator

include "bufio.sl";
include "fixed.sl";
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
        push(a + b);
    } else if (ch == '-') {
        b = pop();
        a = pop();
        push(a - b);
    } else if (ch == '*') {
        b = pop();
        a = pop();
        push(fixmul(a, b));
    } else if (ch == '/') {
        b = pop();
        a = pop();
        push(fixdiv(a, b));
    } else if (ch == 's') {
        a = pop();
        push(fixsin(a));
    } else if (ch == 'c') {
        a = pop();
        push(fixcos(a));
    } else if (ch == 't') {
        a = pop();
        push(fixtan(a));
    } else if (ch == 'r') {
        a = pop();
        push(fixsqrt(a));
    } else if (!iswhite(ch)) {
        fprintf(2, "%c: unrecognised operator\n", [ch]);
    };
};

var args = cmdargs()+1;
if (*args) fixinit(atoi(*args));

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
    } else if (isdigit(ch) || ch == '_' || ch == '.') {
        if ((bufp - buf) >= (bufsz-1)) {
            fprintf(2, "input buffer overflow\n", 0);
            exit(1);
        };
        if (ch == '_') ch = '-'; # underscore prefix for negative numbers
        *(bufp++) = ch;
        *bufp = 0;
    } else {
        if (*buf) {
            push(fixatof(buf));
            bufp = buf;
            *bufp = 0;
        };

        if (ch == '\n') {
            printf("%f\n", [stacktop()]);
        } else {
            operator(ch);
        };
    };
};
