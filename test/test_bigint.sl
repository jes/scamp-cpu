include "bigint.sl";

var test_bigint = func() {
    biginit(4);

    var a = bignew(1234);
    var b = bignew(5678);
    var c = bignew(0);
    bigset(c, b);
    bigmul(c, a);
    printf("a=%b, b=%b, c=%b\n", [a, b, c]);

    bigdiv(c, b);
    printf("div b: c=%b\n", [c]);
    bigdiv(c, a);
    printf("div a: c=%b\n", [c]);

    var d = bigatoi("1234567890");
    printf("d=%b\n", [d]);
    bigaddw(d, 1);
    printf("add 1: d=%b\n", [d]);
    bigsubw(d, 1000);
    printf("sub 1000: d=%b\n", [d]);

    bigadd(d, a);
    printf("add a: d=%b\n", [d]);
};
