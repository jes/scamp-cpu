# Snake game

include "stdio.sl";
include "malloc.sl";
include "grarr.sl";
include "strbuf.sl";

var COLS = 80;
var ROWS = 25;
var ESC = 0x1b;
var DIR_LEFT = 0;
var DIR_DOWN = 1;
var DIR_UP = 2;
var DIR_RIGHT = 3;
var DELAY = 2000;
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
var itoamap = grnew();
var outbuf;

var init_itoamap;
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

init_itoamap = func() {
    var i = 0;
    while ((i <= COLS) || (i <= ROWS)) {
        grpush(itoamap, strdup(itoa(i)));
        i++;
    };
};

input = func() {
    var n = read(0, 0, 0);
    if (!n) return 0;

    var ch;
    read(0, &ch, 1);
    if (ch == 'q') quit = 1
    else if ((ch == 'a') && (snakedir != DIR_RIGHT)) snakedir = DIR_LEFT
    else if ((ch == 's') && (snakedir != DIR_UP)) snakedir = DIR_DOWN
    else if ((ch == 'w') && (snakedir != DIR_DOWN)) snakedir = DIR_UP
    else if ((ch == 'd') && (snakedir != DIR_LEFT)) snakedir = DIR_RIGHT
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
    DELAY = DELAY - 50;
    if (DELAY < 0) DELAY = 0;
};

goto = func(x,y) {
    sbputc(outbuf, ESC);
    sbputc(outbuf, '[');
    sbputs(outbuf, grget(itoamap,y+1));
    sbputc(outbuf, ';');
    sbputs(outbuf, grget(itoamap,x+1));
    sbputc(outbuf, 'H');
};

drawhead = func() {
    goto(snakexs[snakehead], snakeys[snakehead]);
    sbputc(outbuf, '#');
};

cleartail = func() {
    var tail = snakehead-1;
    if (tail < 0) tail = snakelen-1;
    goto(snakexs[tail], snakeys[tail]);
    sbputc(outbuf, ' ');
};

placeapple = func() {
    applex = mod(random(), COLS);
    appley = mod(random(), ROWS);
};

drawapple = func() {
    goto(applex, appley);
    sbputc(outbuf, '@');
};

wait = func() {
    var i = DELAY;
    while (i--);
};

puts("   SNAKE\n");
puts("\n");
puts(" Use W/A/S/D to move\n");
puts(" Use Q to quit\n");
puts("\n");
puts("Press any key to start\n");
while (!read(0,0,0));

var stdinflags = serflags(0, 0);
var stdoutflags = serflags(1, 0);
var consoleflags = serflags(3, 0);

printf("%c[2J", [ESC]); # clear screen
printf("%c[?25l", [ESC]); # hide cursor

init_itoamap();
placeapple();
outbuf = sbnew();
while (!quit) {
    sbclear(outbuf);
    input();
    cleartail();
    move();
    drawhead();
    checkapple();
    drawapple();
    puts(sbbase(outbuf));
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
