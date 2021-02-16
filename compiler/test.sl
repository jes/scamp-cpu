# Test program for SLANG

include "stdio.sl";

extern mul;
extern pwr2;
extern powers_of_2;

# compute:
#   *pdiv = num / denom
#   *pmod = num % denom
# Pass a null pointer if you want to discard one of the results
# https://en.wikipedia.org/wiki/Division_algorithm#Integer_division_(unsigned)_with_remainder
var divmod = func(num, denom, pdiv, pmod) {
    var Q = 0;
    var R = 0;
    var i = 15;

    if (denom == 0)
        return 0;

    while (i >= 0) {
        R = R+R;
        if (num & *(powers_of_2+i)) {
            R = R + 1;
        };
        if (R >= denom) {
            R = R - denom;
            Q = Q | *(powers_of_2+i);
        };
        i = i - 1;
    };

    *pdiv = Q;
    *pmod = R;

    return 0;
};

var itoa_alphabet = "0123456789abcdefghijklmnopqrstuvwxyz";

var itoabase = func(num, base) {
    var s = 0x4000; # TODO: malloc()?
    var d;
    var m;

    *s = 0;

    # special case when num == 0
    if (num == 0) {
        s = s - 1;
        *s = '0';
        return s;
    };

    while (num != 0) {
        s = s - 1;
        divmod(num, base, &d, &m);
        *s = *(itoa_alphabet + m);
        num = d;
    };

    return s;
};

var itoa = func(num) return itoabase(num, 10);

# recursive fibonacci
var rfib = func(n) {
    if (n <= 2)
        return 1
    else
        return rfib(n-1)+rfib(n-2);
};

# reverse the given string in-place
var strrev = func(s) {
    var ss = s;
    var p = s;

    while (*(p+1)) {
        p = p + 1;
    };

    var ch;

    while (s < p) {
        ch = *p;
        *p = *s;
        *s = ch;
        p = p-1;
        s = s+1;
    };

    return ss;
};

var optest = func() {
    var a = 0xaaaa;
    var b = 0x55aa;

    puts("Operators test:\n");

    puts("a="); puts(itoa(a)); puts("\n");
    puts("b="); puts(itoa(b)); puts("\n");
    puts("~a="); puts(itoa(~a)); puts("\n");
    puts("-b="); puts(itoa(-b)); puts("\n");
    puts("+a="); puts(itoa(+a)); puts("\n");
    puts("&a="); puts(itoa(&a)); puts("\n");
    puts("a+b="); puts(itoa(a+b)); puts("\n");
    puts("a-b="); puts(itoa(a-b)); puts("\n");
    puts("a&b="); puts(itoa(a&b)); puts("\n");
    puts("a|b="); puts(itoa(a|b)); puts("\n");
    puts("a^b="); puts(itoa(a^b)); puts("\n");
    puts("a&&b="); puts(itoa(a&&b)); puts("\n");
    puts("a||b="); puts(itoa(a||b)); puts("\n");
    puts("a&&0="); puts(itoa(a&&0)); puts("\n");
    puts("a||0="); puts(itoa(a||0)); puts("\n");
    puts("(-1 > 0)="); puts(itoa(-1>0)); puts("\n");
    puts("(-1 >= 0)="); puts(itoa(-1>=0)); puts("\n");
    puts("(-1 < 0)="); puts(itoa(-1<0)); puts("\n");
    puts("(-1 <= 0)="); puts(itoa(-1<=0)); puts("\n");
    puts("(32767>0)="); puts(itoa(32767>0)); puts("\n");
    puts("(32767>=0)="); puts(itoa(32767>=0)); puts("\n");
    puts("(32767<0)="); puts(itoa(32767<0)); puts("\n");
    puts("(32767<=0)="); puts(itoa(32767<=0)); puts("\n");
    puts("(32767>-2)="); puts(itoa(32767>-2)); puts("\n");
    puts("(32767>=-2)="); puts(itoa(32767>=-2)); puts("\n");
    puts("(32767<-2)="); puts(itoa(32767<-2)); puts("\n");
    puts("(32767<=-2)="); puts(itoa(32767<=-2)); puts("\n");

    var x = 5;
    var y = 10;
    puts("x="); puts(itoa(x)); puts("\n");
    puts("y="); puts(itoa(y)); puts("\n");
    puts("x>y-6="); puts(itoa(x>y-6)); puts("\n");

    puts("\n");
};

var fibtest = func() {
    var n = 0;
    var f1 = 1;
    var f2 = 0;
    var f3 = 0;

    puts("Fibonacci numbers:\n");

    while (n <= 22) {
        f3 = f1 + f2;
        f1 = f2;
        f2 = f3;
        n = n + 1;

        # TODO: putsf()
        puts("fib("); puts(itoa(n)); puts(") = ");
        puts(itoa(f3));
        puts("\n");

        puts("rfib("); puts(itoa(n)); puts(") = ");
        puts(itoa(rfib(n)));
        puts("\n");
    };

    puts("\n");
};

var strtest = func() {
    var s1 = "Hello, world!";

    puts("string: "); puts(s1); puts("\n");
    puts("reversed: "); puts(strrev(s1)); puts("\n");
    puts("re-reversed: "); puts(strrev(s1)); puts("\n");
};

var callputs = func(f) {
    puts(f());
};

var globule = 1;

var functest = func() {
    puts("Nested function calls/declarations:\n");

    callputs(func() { return "1. Hello, world\n" });

    var f = func(x) {
        return x() + x();
    };

    puts("2. 5 = "); puts(itoa(f(func() {
        globule = globule + 1;
        return globule;
    })));
    puts("\n");

    # this function produces no output, but will leave the sp incorrect if
    # vars inside the function body interact poorly with early returns
    var inlinevars = func(x) {
        var y = x;
        if (y > 100)
            return 1;
        var z = x+2;
        if (z > 100)
            return 1;
        return 0;
    };

    inlinevars(97);
    inlinevars(99);
    inlinevars(101);
};

var ptrtest = func() {
    var x = 5;
    var p = &x;
    var y = 10;

    puts("Pointers to locals:\n");

    puts("1. x = "); puts(itoa(x)); puts("\n");
    puts("1. y = "); puts(itoa(y)); puts("\n");
    puts("1. *p = "); puts(itoa(*p)); puts("\n");
    *p = 7;
    puts("2. x = "); puts(itoa(x)); puts("\n");
    puts("2. y = "); puts(itoa(y)); puts("\n");
    puts("2. *p = "); puts(itoa(*p)); puts("\n");
    p = &y;
    puts("3. x = "); puts(itoa(x)); puts("\n");
    puts("3. y = "); puts(itoa(y)); puts("\n");
    puts("3. *p = "); puts(itoa(*p)); puts("\n");
    *p = 11;
    puts("4. x = "); puts(itoa(x)); puts("\n");
    puts("4. y = "); puts(itoa(y)); puts("\n");
    puts("4. *p = "); puts(itoa(*p)); puts("\n");
};

var sp = 0xffff;
puts("Initial sp=0x"); puts(itoabase(*sp, 16)); puts("\n");
optest();
fibtest();
strtest();
functest();
ptrtest();
puts("Final sp=0x"); puts(itoabase(*sp, 16)); puts("\n");
