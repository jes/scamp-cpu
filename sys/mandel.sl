# Mandelbrot set renderer
# jes 2021

include "bigint.sl";
include "sys.sl";
include "stdio.sl";
include "getopt.sl";

biginit(2);

var xmin = bignew(-2500);
var xmax = bignew(1500);
var ymin = bignew(-1500);
var ymax = bignew(1500);

var help = func(rc) {
	puts("usage: mandel [optons]

options:

    -h			  Show this text.
    -x XMIN       Set x minimum.
    -X XMAX       Set x maximum.
    -y YMIN       Set y minimum.
    -Y YMAX       Set y maximum.
");
	exit(rc);
};

var complexsquare = func(x, y) {
	# (x + yi)^2 == (x^2 - y^2) + (2xy)i
	var t = bigclone(x);
	bigmul(t,y);
	bigmulw(t,2);
	bigdivw(t,1000);

	bigmul(x,x);
	bigdivw(x,1000);
	bigmul(y,y);
	bigdivw(y,1000);
	bigsub(x,y);
	bigset(y,t);
	bigfree(t);
};

var four_big = bigatoi("4000000");
var r = bignew(0);
var t = bignew(0);
var complexgt = func(x,y) {
    bigset(r, x);
	bigmul(r, x);

    bigset(t, y);
	bigmul(t, y);

	bigadd(r, t);

	return bigcmp(r, four_big) >= 0;
};

var maxiters = 8;
var alphabet = ".,-'\":=# ";
var zx = bignew(0);
var zy = bignew(0);
var mandel = func(x, y) {
	var k = 0;
    bigsetw(zx, 0);
    bigsetw(zy, 0);

	while (k < maxiters) {
		# z = z*z + c
		complexsquare(zx, zy);
		bigadd(zx, x);
		bigadd(zy, y);

		# if (abs(z) >= 2) break;
		if (complexgt(zx, zy)) break;

		k++;
	};

	return k;
};

var m = getopt(cmdargs()+1, "xXyY", func(ch, arg) {
	if (ch == 'x') xmin = bigatoi(arg)
	else if (ch == 'X') xmax = bigatoi(arg)
	else if (ch == 'y') ymin = bigatoi(arg)
	else if (ch == 'Y') ymax = bigatoi(arg)
	else if (ch == 'h') help(0)
	else help(1);
});

if (*m) help(1);

var xrange = bigsub(bigclone(xmax), xmin);
var yrange = bigsub(bigclone(ymax), ymin);

var x = bigclone(xmin);
var y = bigclone(ymin);
var xstep = bigdiv(bigclone(xrange), bignew(80));
var ystep = bigdiv(bigclone(yrange), bignew(24));

var n;
while (bigcmp(y, ymax) < 0) {
	bigset(x, xmin);
	while (bigcmp(x, xmax) < 0) {
		n = mandel(x, y);
		putchar(alphabet[n]);
		bigadd(x, xstep);
	};
	putchar('\n');
	bigadd(y, ystep);
};
