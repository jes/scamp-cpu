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
