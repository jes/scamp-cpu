# Test program for scamplang

extern print;
extern mul;

var mod = func(num, denom) {
    var c = 0;

    while (num >= denom) {
        c = c + 1;
        num = num - denom;
    };
    return num;
};

var div = func(num, denom) {
    var c = 0;

    while (num >= denom) {
        c = c + 1;
        num = num - denom;
    };

    return c;
};

var num2str = func(num) {
    var s = 0x4000;

    *s = 0;

    if (num == 0) {
        s = s - 1;
        *s = '0';
        return s;
    };

    while (num != 0) {
        s = s - 1;
        *s = '0' + mod(num, 10);
        num = div(num, 10);
    };

    return s;
};

var n = 0;
var f1 = 1;
var f2 = 0;
var f3 = 0;
while (20 >= n) {
    f3 = f1 + f2;
    print("fib("); print(num2str(n)); print(") = ");
    print(num2str(f3));
    print("\n");
    f1 = f2;
    f2 = f3;
    n = n + 1;
};
