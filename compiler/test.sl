# Test program for scamplang

extern print;
extern mul;

var mod = func(num, denom) {
    var c = 0;

    while (num >= denom) {
        c = c + 1;
        num = num - 1;
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
    var s = 0x8000;

    *s = 0;

    while (num != 0) {
        s = s - 1;
        *s = '0' + mod(num, 10);
        num = div(num, 10);
    };

    return s;
};

var a = ~42;
var b = !100;

var result;

print(num2str(mul(a,b)));
result = mul(a,b);
if (result == 4200)
    print(" - OK\n")
else
    print(" - not OK\n");

while (1) {};
