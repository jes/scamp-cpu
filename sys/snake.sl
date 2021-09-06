# Snake game

include "stdio.sl";
include "malloc.sl";

var COLS = 80;
var ROWS = 25;
var ESC = 0x1b;
var DIR_LEFT = 0;
var DIR_DOWN = 1;
var DIR_UP = 2;
var DIR_RIGHT = 3;
var DELAY = 300;
var quit = 0;

var snakexs = malloc(512);
var snakeys = malloc(512);
var snakelen = 3;
snakexs[0] = 40; snakeys[0] = 11;
snakexs[1] = 40; snakeys[1] = 11;
snakexs[2] = 40; snakeys[2] = 11;
var dx = [-1, 0, 0, 1];
var dy = [0, 1, -1, 0];
var snakedir = DIR_RIGHT;
var snakehead = 0;
var applex = 0;
var appley = 0;

var input;
var move;
var growsnake;
var checkapple;
var goto;
var drawhead;
var cleartail;
var placeapple;
var drawapple;
var wait;

input = func() {
	var n = read(0, 0, 0);
	if (!n) return 0;

	var ch;
	read(0, &ch, 1);
	if (ch == 'q') quit = 1
	else if ((ch == 'h') && (snakedir != DIR_RIGHT)) snakedir = DIR_LEFT
	else if ((ch == 'j') && (snakedir != DIR_UP)) snakedir = DIR_DOWN
	else if ((ch == 'k') && (snakedir != DIR_DOWN)) snakedir = DIR_UP
	else if ((ch == 'l') && (snakedir != DIR_LEFT)) snakedir = DIR_RIGHT
	;
};

move = func() {
	var hx = snakexs[snakehead] + dx[snakedir];
	var hy = snakeys[snakehead] + dy[snakedir];

	if (hx < 0) hx = COLS-1;
	if (hy < 0) hy = ROWS-1;
	if (hx >= COLS) hx = 0;
	if (hy >= ROWS) hy = 0;

	snakehead--;
	if (snakehead < 0) snakehead = snakelen-1;
	snakexs[snakehead] = hx;
	snakeys[snakehead] = hy;

	var i = 0;
	while (i < snakelen) {
		if ((i != snakehead) && (snakexs[i] == hx) && (snakeys[i]== hy)) {
			quit = 1;
		};
		i++;
	};
};

checkapple = func() {
	if ((applex == snakexs[snakehead]) &&
	    (appley == snakeys[snakehead])) {
		growsnake();
		placeapple();
	};
};

growsnake = func() {
	snakexs[snakelen] = snakexs[0];
	snakeys[snakelen] = snakeys[0];
	snakelen++;
	if (DELAY >= 25) DELAY = DELAY - 25;
};

goto = func(x,y) {
	printf("%c[%d;%dH", [ESC, y+1, x+1]);
};

drawhead = func() {
	goto(snakexs[snakehead], snakeys[snakehead]);
	putchar('#');
};

cleartail = func() {
	var tail = snakehead-1;
	if (tail < 0) tail = snakelen-1;
	goto(snakexs[tail], snakeys[tail]);
	putchar(' ');
};

placeapple = func() {
	applex = mod(random(), COLS);
	appley = mod(random(), ROWS);
};

drawapple = func() {
	goto(applex, appley);
	putchar('@');
};

wait = func() {
	var i = DELAY;
	while (i--);
};

var stdinflags = serflags(0, 0);
var stdoutflags = serflags(1, 0);
var consoleflags = serflags(3, 0);

printf("%c[2J", [ESC]); # clear screen
printf("%c[?25l", [ESC]); # hide cursor

placeapple();
while (!quit) {
	input();
	cleartail();
	move();
	drawhead();
	checkapple();
	drawapple();
	wait();
};

printf("%c[2J", [ESC]); # clear screen
printf("%c[H", [ESC]); # home cursor
printf("%c[?25h", [ESC]); # show cursor

# restore serial flags
serflags(0, stdinflags);
serflags(1, stdoutflags);
serflags(3, consoleflags);

printf("Snake length was %d segments\n", [snakelen]);
