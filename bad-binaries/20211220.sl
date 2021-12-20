include "bufio.sl";

var in = bfdopen(0, O_READ);

var enhance = malloc(513);
bgets(in, enhance, 513);
assert(bgetc(in) == '\n', "need newline after enhancement spec\n", 0);

var grid = vzmalloc([108,108]);
var grid2 = vzmalloc([108,108]);
var y = 4;
var x;
var i = 0;
while (i < 108) {
	memset(grid[y], '.', 108);
	memset(grid2[y], '#', 108);
	i++;
};

while (bgets(in, grid[y]+3, 108)) {
	y++;
};

var h = 108;
var w = 108;

var getnum = func(g, x, y) {
	var n = 0;
	var dy = 1;
	var dx;
	var bit = 1;
	while (dy >= -1) {
		dx = 1;
		while (dx >= -1) {
			if (g[y+dy][x+dx] == '#') n = n | bit;
			bit = bit + bit;
			dx--;
		};
		dy--;
	};
	return n;
};

var step = func(g, g2) {
	var y = 1;
	var x;
	var n;
	puts("step");
	while (y < h-1) {
		putchar('.');
		x = 1;
		while (x < w-1) {
			n = getnum(g, x, y);
			g2[y][x] = enhance[n];
			x++;
		};
		y++;
	};
	putchar('\n');
};

var countlit = func(g) {
	var y = 1;
	var x;
	var n = 0;
	while (y < h-1) {
		x = 1;
		while (x < w-1) {
			if (g[y][x] == '#') n++;
			x++;
		};
		y++;
	};
	return n;
};

step(grid,grid2);
step(grid2,grid);
printf("%d\n", [countlit(grid)]);
