# Test program for scamplang

extern print;
extern mul;

# compute:
#   *pdiv = num / denom
#   *pmod = num % denom
# Pass a null pointer if you want to discard one of the results
var divmod = func(num, denom, pdiv, pmod) {
    var c = 0;

    while (num >= denom) {
        c = c + 1;
        num = num - denom;
    };

    if (pdiv)
        *pdiv = c;
    if (pmod)
        *pmod = num;

    return 0;
};

var num2str = func(num) {
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
        divmod(num, 10, &d, &m);
        *s = '0' + m;
        num = d;
    };

    return s;
};

var n = 0;
var f1 = 1;
var f2 = 0;
var f3 = 0;

while (n <= 20) {
    f3 = f1 + f2;
    f1 = f2;
    f2 = f3;
    n = n + 1;

    # TODO: printf()
    print("fib("); print(num2str(n)); print(") = ");
    print(num2str(f3));
    print("\n");
};
