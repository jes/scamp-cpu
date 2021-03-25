# Text editor
# Based on https://viewsourcecode.org/snaptoken/kilo/

include "grarr.sl";
include "stdio.sl";
include "stdlib.sl";
include "string.sl";
include "sys.sl";

# definitions
var ESC = 0x1b;
var ROWS = 23; # rows of file content - should be 2 rows short of total screen rows
var COLS = 80;
var CTRL_KEY = func(k) return k&0x1f;
var WELCOME = "~     Kilo editor -- SCAMP edition";
var ARROW_LEFT = 1000;
var ARROW_RIGHT = 1001;
var ARROW_UP = 1002;
var ARROW_DOWN = 1003;
var PAGE_UP = 1004;
var PAGE_DOWN = 1005;
var HOME_KEY = 1006;
var END_KEY = 1007;
var DEL_KEY = 1008;
var TABSTOP = 4; # must be a power of 2 !

# data
var cx = 0;
var rx = 0;
var cy = 0;
# "rows" is a grarr of rows in the file; each row is a cons(grarr, str) where
# the grarr is the characters on that line, and the str is a string describing
# how to render it
var rows = grnew(); # grarr of rows; each row is a cons(grarr, str) where the grarr is the
var rowoff = 0;
var coloff = 0;
var openfilename = 0;
var statusmsg = 0;

# terminal
var quit;
var die;
var rawmode;
var unrawmode;
var readkey;

# row operations
var rowlen;
var row2chars;
var row2render;
var cx2rx;
var updaterow;
var appendrow;

# file i/o
var openfile;

# output
var writeesc;
var refresh;
var drawrow;
var drawrows;
var drawstatus;
var drawstatusmsg;
var setstatusmsg;
var scroll;

# input
var move;
var processkey;

### TERMINAL

quit = func(rc) {
    unrawmode();
    exit(rc);
};

die = func(fmt, args) {
    fprintf(2, fmt, args);
    fputc(2, '\n');
    quit(1);
};

var stdinflags;
var stdoutflags;
var consoleflags;

rawmode = func() {
    stdinflags = serflags(0, 0);
    stdoutflags = serflags(1, 0);
    consoleflags = serflags(3, 0);
};

unrawmode = func() {
    printf("%c[%d;0H\n", [ESC, ROWS+2]); # position cursor below bottom

    serflags(0, stdinflags);
    serflags(1, stdoutflags);
    serflags(3, consoleflags);
};

readkey = func() {
    var c;
    var n = read(0, &c, 1);

    if (n == 0) die("read: eof on stdin, but should be in raw mode ??? (is stdin a file?)", 0);
    if (n < 0) die("read: %s", [strerror(n)]);

    var seq = [0,0,0];
    if (c == ESC) {
        # TODO: [bug] we want read() to return 0 if there is no key pressed
        #       quickly so that a single ESC can be detected
        if (read(0, seq+0, 1) != 1) return ESC;
        if (read(0, seq+1, 1) != 1) return ESC;

        if (seq[0] == '[') {
            if (seq[1] >= '0' && seq[1] <= '9') {
                if (read(0, seq+2, 1) != 1) return ESC;
                if (seq[2] == '~') {
                    if (seq[1] == '1') return HOME_KEY;
                    if (seq[1] == '3') return DEL_KEY;
                    if (seq[1] == '4') return END_KEY;
                    if (seq[1] == '5') return PAGE_UP;
                    if (seq[1] == '6') return PAGE_DOWN;
                    if (seq[1] == '7') return HOME_KEY;
                    if (seq[1] == '8') return END_KEY;
                };
            } else {
                if (seq[1] == 'A') return ARROW_UP;
                if (seq[1] == 'B') return ARROW_DOWN;
                if (seq[1] == 'C') return ARROW_RIGHT;
                if (seq[1] == 'D') return ARROW_LEFT;
                if (seq[1] == 'H') return HOME_KEY;
                if (seq[1] == 'F') return END_KEY;
            };
        } else if (seq[0] == 'O') {
            if (seq[1] == 'H') return HOME_KEY;
            if (seq[1] == 'F') return END_KEY;
        };

        return ESC;
    };

    return c;
};

### ROW OPERATIONS

rowlen = func(r) return grlen(car(r));
row2chars = func(r) return grbase(car(r));
row2render = func(r) return cdr(r);

cx2rx = func(row, cx) {
    var s = row2chars(row);
    var x = 0;
    var i;
    while (i < cx) {
        if (s[i] == '\t') x = x + TABSTOP-1 - (x & (TABSTOP-1));
        x++;
        i++;
    };
    return x;
};

updaterow = func(row) {
    var s = row2render(row);
    if (s) free(s);

    var r = grnew();
    var p = row2chars(row);
    var ch;
    var n;
    while (*p) {
        ch = *(p++);
        if (ch == '\t') {
            grpush(r, ' ');
            while (grlen(r) & (TABSTOP-1))
                grpush(r, ' ');
        } else {
            grpush(r, ch);
        };
    };
    grpush(r, 0);

    var render = strdup(grbase(r));
    grfree(r);

    setcdr(row, render);
};

appendrow = func(gr) {
    grpush(rows, cons(gr, 0));
    updaterow(grget(rows, grlen(rows)-1));
};

### FILE I/O

openfile = func(filename) {
    var fd = open(filename, O_READ);
    if (fd < 0) die("open %s: %s", [filename, strerror(fd)]);

    var row = grnew();

    var ch;
    while (1) {
        ch = fgetc(fd);
        if (ch == EOF) break;
        if (ch == '\n') {
            grpush(row, 0);
            appendrow(row);
            row = grnew();
        } else {
            grpush(row, ch);
        };
    };
    close(fd);

    if (grlen(row)) {
        grpush(row, 0);
        appendrow(row);
    };

    if (openfilename) free(openfilename);
    openfilename = strdup(filename);
};

### OUTPUT

writeesc = func(s) {
    putchar(ESC);
    puts(s);
};

refresh = func() {
    # TODO: [bug] fix flickering
    scroll();
    writeesc("[?25l"); # hide cursor
    writeesc("[H"); # position cursor
    drawrows();
    drawstatus();
    drawstatusmsg();
    printf("%c[%d;%dH", [ESC, cy-rowoff+1, rx-coloff+1]); # position cursor
    writeesc("[?25h"); # show cursor
};

drawrow = func(filerow) {
    var row = grget(rows, filerow);
    var s = row2render(row);

    var len = strlen(s) - coloff;
    if (len > COLS) len = COLS;
    if (len > 0) write(1, s+coloff, len);
};

drawrows = func() {
    var y = 0;
    var filerow;
    while (y < ROWS) {
        filerow = y + rowoff;
        if (filerow >= grlen(rows)) {
            if (grlen(rows) == 0 && y == 8) puts(WELCOME)
            else puts("~");
        } else {
            drawrow(filerow);
        };

        writeesc("[K"); # clear to end of line
        puts("\r\n");
        y++;
    };
};

drawstatus = func() {
    var name = openfilename;
    if (!name) name = "[No Name]";

    var status = sprintf("%20s - %d lines", [name, grlen(rows)]);
    if (strlen(status) > COLS) *(status+COLS-1) = 0;
    var rstatus = sprintf("%d/%d", [cy+1, grlen(rows)]);

    var len = strlen(status);
    var rlen = strlen(rstatus);

    writeesc("[7m"); # inverse video

    puts(status);
    while (len < COLS) {
        if (COLS-len == rlen) {
            puts(rstatus);
            break;
        } else {
            putchar(' ');
            len++;
        };
    };
    writeesc("[m"); # un-inverse video
    puts("\r\n");

    free(status);
    free(rstatus);
};

drawstatusmsg = func() {
    writeesc("[K"); # clear line
    if (statusmsg) puts(statusmsg);
};

setstatusmsg = func(fmt, args) {
    if (statusmsg) free(statusmsg);
    statusmsg = sprintf(fmt, args);
};

scroll = func() {
    rx = 0;
    if (cy < grlen(rows)) rx = cx2rx(grget(rows, cy), cx);

    if (rx < coloff) coloff = rx;
    if (rx >= coloff + COLS) coloff = rx - COLS + 1;
    if (cy < rowoff) rowoff = cy;
    if (cy >= rowoff + ROWS) rowoff = cy - ROWS + 1;
};

### INPUT

move = func(k) {
    if (k == ARROW_LEFT) cx--;
    if (k == ARROW_RIGHT) cx++;
    if (k == ARROW_UP) cy--;
    if (k == ARROW_DOWN) cy++;

    var maxrow = grlen(rows);

    if (cy < 0) cy = 0;
    if (cy > maxrow) cy = maxrow;

    var maxcol = 0;
    var row = grget(rows, cy);
    if (row) maxcol = rowlen(row)-1;

    if (cx < 0) {
        cx = 0;
        if (cy != 0) {
            move(ARROW_UP);
            row = grget(rows, cy);
            cx = rowlen(row)-1;
        };
    } else if (cx > maxcol) {
        cx = maxcol;
        if (cy != maxrow) {
            cx = 0;
            move(ARROW_DOWN);
        };
    };
};

processkey = func() {
    var c = readkey();

    var n;

    if (c == CTRL_KEY('q')) quit(0);
    if (c == PAGE_UP) {
        cy = rowoff;
        n = ROWS;
        while (n--) move(ARROW_UP);
    };
    if (c == PAGE_DOWN) {
        cy = rowoff + ROWS-1;
        n = ROWS;
        while (n--) move(ARROW_DOWN);
    };
    if (c == HOME_KEY) cx = 0;
    if (c == END_KEY) {
        if (cy < grlen(rows))
            cx = rowlen(grget(rows,cy))-1;
    };
    if (c == ARROW_UP || c == ARROW_DOWN || c == ARROW_LEFT || c == ARROW_RIGHT) move(c);
};

### INIT

rawmode();
setstatusmsg("HELP: Ctrl-Q = quit", 0);

var args = cmdargs()+1;
if (*args) openfile(*args);

while (1) {
    refresh();
    processkey();
};
