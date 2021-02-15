# Test program for SLANG

extern print;
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

    print("Operators test:\n");

    print("a="); print(itoa(a)); print("\n");
    print("b="); print(itoa(b)); print("\n");
    print("a+b="); print(itoa(a+b)); print("\n");
    print("a-b="); print(itoa(a-b)); print("\n");
    print("a&b="); print(itoa(a&b)); print("\n");
    print("a|b="); print(itoa(a|b)); print("\n");
    print("a^b="); print(itoa(a^b)); print("\n");
    print("a&&b="); print(itoa(a&&b)); print("\n");
    print("a||b="); print(itoa(a||b)); print("\n");
    print("a&&0="); print(itoa(a&&0)); print("\n");
    print("a||0="); print(itoa(a||0)); print("\n");

    print("\n");
};

var fibtest = func() {
    var n = 0;
    var f1 = 1;
    var f2 = 0;
    var f3 = 0;

    print("Fibonacci numbers:\n");

    while (n <= 22) {
        f3 = f1 + f2;
        f1 = f2;
        f2 = f3;
        n = n + 1;

        # TODO: printf()
        print("fib("); print(itoa(n)); print(") = ");
        print(itoa(f3));
        print("\n");

        print("rfib("); print(itoa(n)); print(") = ");
        print(itoa(rfib(n)));
        print("\n");
    };

    print("\n");
};

var strtest = func() {
    var s1 = "Hello, world!";

    print("string: "); print(s1); print("\n");
    print("reversed: "); print(strrev(s1)); print("\n");
    print("re-reversed: "); print(strrev(s1)); print("\n");
};

var callprint = func(f) {
    print(f());
};

var globule = 1;

var fnctest = func() {
    print("Nested function calls/declarations:\n");

    callprint(func() { return "1. Hello, world\n" });

    var f = func(x) {
        return x() + x();
    };

    print("2. 5 = "); print(itoa(f(func() {
        globule = globule + 1;
        return globule;
    })));
    print("\n");
};

var sp = 0xffff;
print("Initial sp=0x"); print(itoabase(*sp, 16)); print("\n");
optest();
fibtest();
strtest();
fnctest();
print("Final sp=0x"); print(itoabase(*sp, 16)); print("\n");
