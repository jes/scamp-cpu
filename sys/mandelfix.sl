# Mandelbrot set renderer, using 6.10 fixed-point arithmetic
# jes 2021

include "sys.sl";
include "stdio.sl";
include "getopt.sl";
include "fixed.sl";

# 10 bits of fractional part
fixinit(10);

var xmin = fixatof("-2.5");
var xmax = fixatof("1.5");
var ymin = fixatof("-1.5");
var ymax = fixatof("1.5");

var help = func(rc) {
    puts("usage: mandelfix [optons]

options:

    -h            Show this text.
    -x XMIN       Set x minimum.
    -X XMAX       Set x maximum.
    -y YMIN       Set y minimum.
    -Y YMAX       Set y maximum.
");
    exit(rc);
};

var fixtwo = fixitof(2);
var fixfour = fixitof(4);

var complexsquare = func(x, y) {
    # (x + yi)^2 == (x^2 - y^2) + (2xy)i
    return [fixmul(x,x) - fixmul(y,y), mul(fixmul(x,y), 2)];
};

# return (abs(z) >= 2)
var complexgt = func(x,y) {
    if (x >= fixtwo) return 1;
    if (y >= fixtwo) return 1;
    return (fixmul(x,x)+fixmul(y,y) >= fixfour);
};

var maxiters = 8;
var alphabet = ".,-'\":=# ";
var mandel = func(x, y) {
    var k = 0;
    var zx = 0;
    var zy = 0;

    var c;

    while (k < maxiters) {
        # z = z*z + c
        c = complexsquare(zx, zy);
        zx = c[0] + x;
        zy = c[1] + y;

        # if (abs(z) >= 2) break;
        if (complexgt(zx, zy)) break;

        k++;
    };

    return k;
};

var m = getopt(cmdargs()+1, "xXyY", func(ch, arg) {
    if (ch == 'x') xmin = fixatof(arg)
    else if (ch == 'X') xmax = fixatof(arg)
    else if (ch == 'y') ymin = fixatof(arg)
    else if (ch == 'Y') ymax = fixatof(arg)
    else if (ch == 'h') help(0)
    else help(1);
});

if (*m) help(1);

var xrange = xmax - xmin;
var yrange = ymax - ymin;

var x = xmin;
var y = ymin;
var xstep = div(xrange, 80);
var ystep = div(yrange, 24);

var n;
while (y < ymax) {
    x = xmin;
    while (x < xmax) {
        n = mandel(x, y);
        putchar(alphabet[n]);
        x = x + xstep;
    };
    putchar('\n');
    y = y + ystep;
};
