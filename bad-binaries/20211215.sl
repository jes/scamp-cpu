include "bufio.sl";
include "grarr.sl";

var in = bfdopen(0, O_READ);

var grid = vzmalloc([100,128]);

var w = 0;
var h;
var y = 0;
var x;
while (bgets(in, grid[y], 128)) {
	w = strlen(grid[y])-1;
	y++;
};
h = y;

var bestpath = 0x7fff;
var lastbestpath = 0x7fff;

var risk = vzmalloc([h,w]);

printf("%dx%d\n", [w,h]);

var update = func(x,y) {
	var g = grid[y][x] - '0';
	var gx = 0; var gy = 0;
	if (x > 0) gx = g + risk[y][x-1];
	if (y > 0) gy = g + risk[y-1][x];
	if ((x < w-1) && risk[y][x+1])
		if ((g + risk[y][x+1]) < gx)
			gx = g + risk[y][x+1];
	if ((y < h-1) && risk[y+1][x])
		if ((g + risk[y+1][x]) < gy)
			gy = g + risk[y+1][x];

	if (gx) g = gx;
	if (gy && gy < gx) g = gy;

	if ((risk[y][x] == 0) || (g < risk[y][x]))
		risk[y][x] = g;
};

while (1) {
	y = 0;
	while (y < h) {
		x = 0;
		while (x < w) {
			update(x,y);
			x++;
		};
		y++;
	};
	bestpath = risk[h-1][w-1];
	printf("%d\n", [bestpath]);
	if (bestpath < lastbestpath) {
		lastbestpath = bestpath;
	} else {
		printf("%d\n", [bestpath-(grid[0][0]-'0')]);
		break;
	};
};
