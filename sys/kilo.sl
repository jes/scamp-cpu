# Text editor
# Based on https://viewsourcecode.org/snaptoken/kilo/
#
# TODO: [bug] use less memory - currently can't open slangc.sl; stop using grarrs?
# TODO: [nice] delete prev/next word

include "grarr.sl";
include "stdio.sl";
include "stdlib.sl";
include "strbuf.sl";
include "string.sl";
include "sys.sl";

# definitions
var ESC = 0x1b;
var ROWS = 23; # rows of file content - should be 2 rows short of total screen rows
var HALFROWS = div(ROWS, 2);
var COLS = 80;
var CTRL_KEY = func(k) return k&0x1f;
var WELCOME = "~     Kilo editor -- SCAMP edition";
var TABSTOP = 4; # must be a power of 2 !
var QUIT_TIMES = 3;
var INSERT_MODE = 0;
var NAV_MODE = 1;

# key constants
var BACKSPACE = 127;
var BACKSPACE2 = 8;
var ARROW_LEFT = 1000;
var ARROW_RIGHT = 1001;
var ARROW_UP = 1002;
var ARROW_DOWN = 1003;
var PAGE_UP = 1004;
var PAGE_DOWN = 1005;
var HOME_KEY = 1006;
var END_KEY = 1007;
var DEL_KEY = 1008;
var MOVE_WORD = 1009;
var MOVE_BACK = 1010;

# data
var cx = 0;
var rx = 0;
var cy = 0;
# "rows" is a grarr of rows in the file; each row is a grarr of the characters
# on that line
var rows = grnew();
var rowoff = 0;
var coloff = 0;
var openfilename = 0;
var statusmsg = 0;
var dirty = 0;
var quit_times = QUIT_TIMES;
var mode = INSERT_MODE;

# terminal
var quit;
var fatal;
var rawmode;
var unrawmode;
var readable;
var readbyte;
var waitreadbyte;
var readkey;

# row operations
var rowlen;
var row2chars;
var cx2rx;
var rx2cx;
var appendrow;
var insertrow;
var rowinsertchar;
var rowappendstr;
var rowdelchar;
var freerow;
var delrow;
var rowdirty;
var markrowdirty;
var markbelowdirty;
var markalldirty;
var markallclean;
var need_redraw = malloc(ROWS);
var full_redraw;

### editor operations
var navchar;
var insertchar;
var insertnewline;
var truncaterow;
var delchar;
var delchars;
var charat;
var curchar;
var joinline;

# file i/o
var openfile;
var savefile;

# find
var find;

# output
var writeesc;
var refresh;
var drawrow;
var drawrows;
var drawstatus;
var drawstatusmsg;
var setstatusmsg;
var setdefaultstatus;
var scroll;
var helpscreen;

# input
var prompt_cursor = -1;
var prompt;
var wordsmove;
var move;
var multimove;
var findchar;
var gotoline;
var processkey;

### TERMINAL

quit = func(rc) {
    unrawmode();
    exit(rc);
};

fatal = func(fmt, args) {
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
    consoleflags = serflags(3, SER_DISABLE);

    writeesc("[2J"); # clear screen
    writeesc("[H"); # cursor at top left
};

unrawmode = func() {
    printf("%c[%d;0H\n", [ESC, ROWS+2]); # position cursor below bottom

    serflags(0, stdinflags);
    serflags(1, stdoutflags);
    serflags(3, consoleflags);
};

# XXX: a lot of the keyboard handling code is written in assembly language
# for performance; this is not a premature optimisation! At 115200 baud with
# a 1 MHz CPU, we only have ~86 cycles to handle each character if we don't want
# to drop any, and handling the characters at full speed is mandatory otherwise
# escape sequences don't work

# usage: readable() - return 1 if there is at least 1 byte waiting
var SERIALDEV = 136;
var SERIALDEVLSR = 141;
readable = func() {
    return inp(SERIALDEVLSR)&1;
};
# slow alternative using kernel serial support:
#    readable = func() { return read(0,0,0) };

# usage: readkeyraw(seq); return the key code; if it was ESC, then the other
# characters of the sequence go into the buffer pointed to by "seq"
var readkeyraw = asm {
    .def SERIALDEV 136
    .def SERIALDEVLSR 141

    pop x
    ld r1, x
    ld r2, 3

    # r0 = first char
    # r1 = pointer to sequence buffer (need at most 3 slots)
    # r2 = number of bytes left to read
    # r3 = timeout counter for spinlock

    readkeyraw:
    # spin until first byte is available
    in x, SERIALDEVLSR
    and x, 1
    jz readkeyraw

    # read first byte
    in x, SERIALDEV
    and x, 0xff
    ld r0, x

    # if it's not ESC, return it
    cmp x, 0x1b # ESC
    jnz readkeyraw_done

    # if the first char was ESC, then we need to wait to read up to 3 more bytes
    readkeyraw_esc:
        # we only want to try up to 3 times
        test r2
        jz readkeyraw_done
        dec r2

        ld r3, 1000
        readkeyraw_loop:
            test r3
            # timeout if no more bytes
            jz readkeyraw_done
            dec r3

            # keep looping until there's a byte available
            in x, SERIALDEVLSR
            and x, 1
            jz readkeyraw_loop

            # read the character, put it in the buffer, increment pointer
            in x, SERIALDEV
            and x, 0xff
            ld (r1++), x
            jmp readkeyraw_loop

    readkeyraw_done:
        ret
};
# TODO: [nice] implementation of slow alternative using kernel serial support

readkey = func() {
    var seq = [0,0,0];
    var c = readkeyraw(seq);

    if (c == ESC) {
        if (seq[0] == '[') {
            if (seq[1] >= '0' && seq[1] <= '9') {
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
                if (seq[1] == 'K') return END_KEY;
            };
        } else if (seq[0] == 'O') {
            if (seq[1] == 'H') return HOME_KEY;
            if (seq[1] == 'F') return END_KEY;
        };

        return ESC;
    };

    if (c == BACKSPACE2) c = BACKSPACE;
    return c;
};

### ROW OPERATIONS

rowlen = func(r) return grlen(r);
row2chars = func(r) return grbase(r);

cx2rx = func(row, cx) {
    var s = row2chars(row);
    var x = 0;
    var i = 0;
    while (i < cx) {
        if (s[i] == '\t') x = x + TABSTOP-1 - (x & (TABSTOP-1));
        x++;
        i++;
    };
    return x;
};

rx2cx = func(row, rx) {
    var s = row2chars(row);
    var x = 0;
    var i = 0;
    while (x < rx) {
        if (s[i] == '\t') x = x + TABSTOP-1 - (x & (TABSTOP-1));
        x++;
        i++;
    };
    return i;
};

appendrow = func(gr) {
    insertrow(grlen(rows), gr);
};

insertrow = func(at, gr) {
    if (at < 0 || at > grlen(rows)) return 0;

    var n = grlen(rows);
    grpush(rows, 0);
    while (n != at) {
        grset(rows, n, grget(rows, n-1));
        n--;
    };
    grset(rows, at, gr);
    dirty = 1;
};

rowinsertchar = func(row, at, c) {
    if (at < 0 || at > rowlen(row)) at = rowlen(row);
    var n = rowlen(row);
    grpush(row, 0);
    while (n != at) {
        grset(row, n, grget(row, n-1));
        n--;
    };
    grset(row, at, c);
    dirty = 1;
};

rowappendstr = func(row, s, len) {
    while (len--)
        grpush(row, *(s++));
    dirty = 1;
};

rowdelchar = func(row, at) {
    if (at < 0 || at > rowlen(row)) return 0;
    var len = rowlen(row);
    while (at != len-1) {
        grset(row, at, grget(row, at+1));
        at++;
    };
    grpop(row);
    dirty = 1;
};

freerow = func(row) {
    grfree(row);
};

delrow = func(at) {
    if (at < 0 || at >= grlen(rows)) return 0;
    var row = grget(rows,at);
    freerow(row);
    var len = grlen(rows);
    while (at != len-1) {
        grset(rows, at, grget(rows, at+1));
        at++;
    };
    grpop(rows);
    dirty = 1;
};

rowdirty = func(at) {
    var top = rowoff;
    var bottom = rowoff+ROWS-1;
    if (at < top || at > bottom) return 0;
    return *(need_redraw+at-top);
};

markrowdirty = func(at) {
    var top = rowoff;
    var bottom = rowoff+ROWS-1;
    if (at < top || at > bottom) return 0;
    *(need_redraw+at-top) = 1;
};

markbelowdirty = func(at) {
    var top = rowoff;
    var bottom = rowoff+ROWS-1;
    if (at < top || at > bottom) return 0;
    while (at != bottom+1) {
        *(need_redraw+at-top) = 1;
        at++;
    };
};

markalldirty = func() {
    full_redraw = 1;
    memset(need_redraw, 1, ROWS);
};

markallclean = func() {
    memset(need_redraw, 0, ROWS);
};

### EDITOR OPERATIONS

var movecount = 0;

# basic vi-style movement in navigation mode
navchar = func(c) {
    var maxcol = 0;
    var row = 0;
    if (cy < grlen(rows)) row = grget(rows,cy);
    if (row) maxcol = rowlen(row);

    # TODO: [nice] and d.. and c.. on movements, e.g. "d3w", "cf."
    if (c == 'h') multimove(ARROW_LEFT, movecount)
    else if (c == 'j') multimove(ARROW_DOWN, movecount)
    else if (c == 'k') multimove(ARROW_UP, movecount)
    else if (c == 'l') multimove(ARROW_RIGHT, movecount)
    else if (c == '0') cx = 0
    else if (c == '$') cx = maxcol
    else if (c == 'i') mode = INSERT_MODE
    else if (c == 'a') { mode = INSERT_MODE; move(ARROW_RIGHT); }
    else if (c == 'A') { mode = INSERT_MODE; cx = maxcol; }
    else if (c == 'o') { mode = INSERT_MODE; cx = maxcol; insertnewline(); }
    else if (c == 'O') { mode = INSERT_MODE; cx = 0; insertnewline(); move(ARROW_UP); }
    else if (c == '/') find()
    else if (c == 'w') multimove(MOVE_WORD, movecount)
    else if (c == 'b') multimove(MOVE_BACK, movecount)
    else if (c == 'x') delchars(movecount)
    else if (c == 'g') gotoline(movecount)
    else if ((c == 'G') && movecount) gotoline(movecount)
    else if (c == 'G') gotoline(grlen(rows)+1)
    else if (c == 'D') truncaterow()
    else if (c == 'C') { truncaterow(); mode = INSERT_MODE; }
    else if (c == 'f') findchar(readkey(), ARROW_RIGHT)
    else if (c == 'F') findchar(readkey(), ARROW_LEFT)
    else if (c == 'J') joinline(cy)
    else if (c == 'd') {
        c = readkey();
        if (c == 'd') {
            delrow(cy);
            markbelowdirty(cy);
            if (cy < grlen(rows)) {
                if (cx >= rowlen(grget(rows, cy))) cx = rowlen(grget(rows,cy));
            } else cx = 0;
        };
    } else if (c == 'c') {
        c = readkey();
        if (c == 'c') {
            cx = 0;
            truncaterow();
            mode = INSERT_MODE;
        };
    } else if (c == ':') {
        c = readkey();
        if (c == 'w') savefile();
    } else if (c == 'r') {
        c = readkey();
        if (c < 32) return 0; # reject escape, CR, LF, etc.
        move(ARROW_RIGHT);
        delchar();
        insertchar(c);
        move(ARROW_LEFT);
    } else if (c == 'z') {
        c = readkey();
        if (c == 't') rowoff = cy
        else if (c == 'z') rowoff = cy-HALFROWS
        else if (c == 'b') rowoff = cy-ROWS;

        if (rowoff < 0) rowoff = 0;
        markalldirty();
    };
};

insertchar = func(c) {
    if (cy == grlen(rows)) appendrow(grnew());

    markrowdirty(cy);
    rowinsertchar(grget(rows,cy), cx, c);
    cx++;
};

insertnewline = func() {
    markbelowdirty(cy);

    var gr = grnew();
    if (cx == 0) {
        insertrow(cy, gr);
        cy++;
        return 0;
    };

    if (cy == grlen(rows)) appendrow(grnew());

    var row = grget(rows,cy);
    var chars = row2chars(row);

    # copy chars into new row
    var len = rowlen(row);
    var at = cx;
    while (at != len) {
        grpush(gr, chars[at]);
        at++;
    };
    insertrow(cy+1, gr);

    # truncate old row
    grtrunc(row, cx);

    cy++;
    cx = 0;
};

truncaterow = func() {
    if (cy == grlen(rows)) return 0;

    var row = grget(rows, cy);
    if (rowlen(row)) {
        grtrunc(row, cx);
        markrowdirty(cy);
        dirty = 1;
    } else {
        delrow(cy);
        markbelowdirty(cy);
    };
};

delchar = func() {
    if (cx == 0 && cy == 0) return 0;
    if (cy == grlen(rows)) return 0;

    var row;
    var row2;
    if (cx != 0) {
        row = grget(rows, cy);
        rowdelchar(row, cx-1);
        markrowdirty(cy);
        cx--;
    } else {
        row = grget(rows,cy-1);
        row2 = grget(rows,cy);
        cx = rowlen(row);
        rowappendstr(row, row2chars(row2), rowlen(row2));
        delrow(cy);
        cy--;
        markbelowdirty(cy);
    };
};

delchars = func(n) {
    if (!n) n = 1;
    while (n--) {
        move(ARROW_RIGHT);
        scroll();
        delchar();
        scroll();
    };
};

charat = func(x, y) {
    if (y == grlen(rows)) return 0;
    var row = grget(rows, y);
    if (x == rowlen(row)) return 0;
    return grget(row, x);
};

curchar = func() {
    return charat(cx, cy);
};

joinline = func(y) {
    if (cy >= grlen(rows)-1) return 0;

    # TODO: [nice] insert a space at the end of the line, trim the whitespace
    #       from the start of the next line
    cy++;
    cx = 0;
    delchar();
};

### FILE I/O

openfile = func(filename) {
    printf("Loading %s...", [filename]);
    var fd = open(filename, O_READ);
    if (fd == NOTFOUND) {
        # filename doesn't exist yet
        if (openfilename) free(openfilename);
        openfilename = strdup(filename);
        dirty = 1;
        return 0;
    };
    if (fd < 0) fatal("open %s: %s", [filename, strerror(fd)]);

    var row = grnew();
    var buf = malloc(1024);

    var n;
    var ch;
    var p;
    while (1) {
        n = read(fd, buf, 1024);
        if (n <= 0) break;
        p = buf;
        while (n--) {
            ch = *(p++);
            if (ch == EOF) break;
            if (ch == '\n') {
                appendrow(row);
                row = grnew();
            } else {
                grpush(row, ch);
            };
        };
    };
    close(fd);
    free(buf);

    if (grlen(row))
        appendrow(row);

    if (openfilename) free(openfilename);
    openfilename = strdup(filename);
    dirty = 0;
};

savefile = func() {
    if (!openfilename) openfilename = prompt("Save as: ", " (ESC to cancel)", 1, 0);
    if (!openfilename) {
        setstatusmsg("Save aborted", 0);
        return 0;
    };

    # TODO: [bug] on errors from open() or write(), setstatusmsg() to say
    #       what happened
    # TODO: [nice] write something like "Writing %s..." to the status bar
    #       while saving

    var fd = open(openfilename, O_WRITE|O_CREAT);
    if (fd < 0) fatal("open %s: %s", [openfilename, strerror(fd)]);

    var buf = malloc(257);
    setbuf(fd, buf);

    var i = 0;
    var row;
    var chars = 0;
    while (i < grlen(rows)) {
        row = grget(rows, i);
        write(fd, row2chars(row), rowlen(row));
        write(fd, "\n", 1);
        chars = chars + rowlen(row) + 1;
        i++;
    };
    close(fd);
    free(buf);

    setstatusmsg("%d characters written to disk", [chars]);
    dirty = 0;
};

### FIND

var find_last = -1;
var find_dir = 1;
find = func() {
    var cx0 = cx;
    var cy0 = cy;
    var rowoff0 = rowoff;
    var coloff0 = coloff;

    find_last = -1;
    find_dir = 1;
    var str = prompt("Search: ", " (ESC/arrows/enter)", 0, func(query, key) {
        if (key == 0) {
            return 0;
        } else if (key == ARROW_RIGHT || key == ARROW_DOWN) {
            find_dir = 1;
        } else if (key == ARROW_LEFT || key == ARROW_UP) {
            find_dir = -1;
        } else {
            find_last = -1;
            find_dir = 1;
        };

        var cur = find_last;

        var i = 0;
        var match;
        var line;
        var row;
        while (i != grlen(rows)) {
            cur = cur + find_dir;
            if (cur == -1) cur = grlen(rows)-1;
            if (cur == grlen(rows)) cur = 0;

            row = grget(rows, cur);
            line = row2chars(row);
            match = strnstr(line, query, rowlen(row));
            if (match) {
                find_last = cur;
                cy = cur;
                cx = rx2cx(row, match - line);
                rowoff = grlen(rows);
                coloff = 0;
                break;
            };
            i++;
        };
    });

    if (str) {
        free(str);
    } else { # cancelled search
        cx = cx0;
        cy = cy0;
        rowoff = rowoff0;
        coloff = coloff0;
        markalldirty();
    };
};

### OUTPUT

# usage: raw_writech(ch)
var raw_writech = asm {
    pop x
    ld r1, x # r1 = ch

    # wait for tx holding register empty
    raw_writech_spin:
        in x, SERIALDEVLSR
        and x, 0x20
        jz raw_writech_spin

    # output character
    ld x, r1
    out SERIALDEV, x
    ret
};

# usage: raw_write(str)
var raw_write = asm {
    pop x
    ld r2, x # r2 = str

    raw_write_next:
        # do nothing if *str == 0
        test (r2)
        jz raw_write_done

    raw_write_spin:
        # wait for tx holding register empty
        in x, SERIALDEVLSR
        and x, 0x20
        jz raw_write_spin

    # output the character
    ld x, (r2++)
    out SERIALDEV, x
    jmp raw_write_next

    raw_write_done:
        ret
};

var raw_printf = func(fmt, args) return xprintf(fmt, args, raw_writech);

writeesc = func(s) {
    raw_writech(ESC);
    raw_write(s);
};

refresh = func() {
    scroll();
    writeesc("[?25l"); # hide cursor
    writeesc("[H"); # position cursor
    drawrows();
    drawstatus();
    drawstatusmsg();
    if (prompt_cursor == -1)
        raw_printf("%c[%d;%dH", [ESC, cy-rowoff+1, rx-coloff+1]) # position cursor
    else
        raw_printf("%c[%d;%dH", [ESC, ROWS+2, prompt_cursor]); # position cursor
    writeesc("[?25h"); # show cursor

    full_redraw = 0;
};

var rowbuf_col;
drawrow = func(row) {
    rowbuf_col = 0;
    var addchar = func(ch) {
        if (rowbuf_col >= coloff && rowbuf_col < coloff+COLS)
            raw_writech(ch);
        rowbuf_col++;
    };

    # turn the chars into something renderable:
    #  - turn tabs into 4 spaces
    #  - turn control characters into "^A" type stuff?
    var i = 0;
    var ch;
    var rowstr = grbase(row);
    var len = rowlen(row);
    while (i != len) {
        ch = rowstr[i++];
        if (ch == '\t') {
            addchar(' ');
            while (rowbuf_col & (TABSTOP-1))
                addchar(' ');
        } else if (iscntrl(ch)) {
            addchar('^');
            addchar(ch+'A'-1);
        } else {
            addchar(ch);
        };
    };

    writeesc("[K"); # clear to end of line
};

drawrows = func() {
    var y = 0;
    var filerow;
    while (y < ROWS) {
        filerow = y + rowoff;
        if (filerow >= grlen(rows)) {
            if (grlen(rows) == 0 && y == 8) raw_write(WELCOME)
            else raw_writech('~');
            writeesc("[K"); # clear to end of line
        } else if (rowdirty(filerow)) {
            drawrow(grget(rows,filerow));
        };

        raw_write("\r\n");
        y++;
    };
    markallclean();
};

var last_name;
var last_dirty;
var last_lines;
var last_cy;
var last_mode;

drawstatus = func() {
    # don't redraw status if it hasn't changed
    if (openfilename == last_name && dirty == last_dirty && grlen(rows) == last_lines && cy == last_cy && mode == last_mode && !full_redraw) {
        raw_write("\r\n");
        return 0;
    };
    last_name = openfilename;
    last_dirty = dirty;
    last_lines = grlen(rows);
    last_cy = cy;
    last_mode = mode;

    var name = openfilename;
    if (!name) name = "[No Name]";

    var dirtymsg = "";
    if (dirty) dirtymsg = "(modified)";

    var status = sprintf("%20s - %d lines %s", [name, grlen(rows), dirtymsg]);
    var len = strlen(status);

    if (len > COLS) *(status+COLS-1) = 0;
    var modestr = "INS";
    if (mode == NAV_MODE) modestr = "NAV";
    var rstatus = sprintf("%s %d/%d ", [modestr, cy+1, grlen(rows)]);

    var rlen = strlen(rstatus);

    writeesc("[7m"); # inverse video

    raw_write(status);
    while (len < COLS) {
        if (COLS-len == rlen) {
            raw_write(rstatus);
            break;
        } else {
            raw_writech(' ');
            len++;
        };
    };
    writeesc("[m"); # un-inverse video
    raw_write("\r\n");

    free(status);
    free(rstatus);
};

drawstatusmsg = func() {
    writeesc("[K"); # clear line
    if (statusmsg) raw_write(statusmsg);
};

setstatusmsg = func(fmt, args) {
    if (statusmsg) free(statusmsg);
    statusmsg = sprintf(fmt, args);
};

setdefaultstatus = func() {
    setstatusmsg("^O save  ^X exit  ^Z shell  ^K del line  ^F find  ^N nav  ^E help", 0);
};

scroll = func() {
    rx = 0;
    if (cy < grlen(rows)) rx = cx2rx(grget(rows, cy), cx);

    if (rx < coloff) {
        coloff = rx;
        markalldirty();
    };
    if (rx >= coloff + COLS) {
        coloff = rx - COLS + 1;
        markalldirty();
    };
    if (cy < rowoff) {
        rowoff = cy;
        markalldirty();
    };
    if (cy >= rowoff + ROWS) {
        rowoff = cy - ROWS + 1;
        markalldirty();
    };
};

helpscreen = func() {
    markalldirty();
    writeesc("[2J"); # clear screen
    writeesc("[H"); # position cursor

    puts(" Kilo editor -- SCAMP edition\r
\r
 * Text at bottom right indicates insert/navigation mode as INS/NAV.\r
 * Ctrl-keys are the same in both modes\r
 * In insert mode, ordinary characters insert that character.\r
 * In navigation mode, some ordinary characters perform navigation or other\r
   actions.\r
 * In navigation mode, typing digits is number input for rapid movements.\r
\r
    CTRL KEYS                         |   NAV KEYS\r
    ----------------------------------+-----------------------------------\r
    ^X quit                           |   h/j/k/l  vim style movement\r
    ^O save file                      |   0 goto start of line\r
    ^Z spawn child shell              |   $ goto end of line\r
    ^K delete to end of line          |   i enter insert mode\r
    ^F find text                      |   a enter insert mode 1 char right\r
    ^N toggle navigation mode         |   / find text\r
    ^E show this help                 |   w move forward a word\r
    ^U page up                        |   b move back a word\r
    ^D page down                      |   x delete character\r
    ^L redraw screen                  |   g/G goto line\r
                                      |   z[tzb] reposition screen offset\r
\r
         PRESS ANY KEY TO CLOSE\r
");

    readkey();
};

### INPUT

prompt = func(beforemsg, aftermsg, wantcursor, callback) {
    var c;
    var sb = sbnew();
    var result = 0;

    while (1) {
        setstatusmsg("%s%s%s", [beforemsg, sbbase(sb), aftermsg]);

        if (wantcursor)
            prompt_cursor = strlen(beforemsg) + sblen(sb) + 1;
        refresh();
        c = readkey();
        if (c == DEL_KEY || c == CTRL_KEY('h') || c == BACKSPACE) {
            sbpop(sb);
        } else if (c == ESC) {
            setstatusmsg("", 0);
            break;
        } else if (c == '\r') {
            if (sblen(sb)) result = strdup(sbbase(sb));
            setstatusmsg("", 0);
            break;
        } else if (!iscntrl(c) && c < 128) {
            sbputc(sb, c);
        };

        # call callback only if there is no input waiting
        if (callback && !readable())
            callback(sbbase(sb), c);
    };

    sbfree(sb);

    prompt_cursor = -1;
    return result;
};

# move in direction "k" until either:
#  - we reach the end of the file
#  - we find the next word
wordsmove = func(k) {
    var cx0;
    var cy0;

    # states:
    # 0 - waiting for end of starting word
    # 1 - looking for start of next word
    var state ;
    if (isalnum(curchar())) state = 0
    else state = 1;

    while (1) {
        cx0 = cx;
        cy0 = cy;

        move(k);
        scroll();

        # stop if we've stopped making progress (e.g. end of file)
        if (cx == cx0 && cy == cy0) return 0;

        if (state == 0) {
            if (!isalnum(curchar())) state++;
        } else {
            if (isalnum(curchar())) return 0;
        };
    };

    return 0;
};

move = func(k) {
    var d;
    if ((k == MOVE_WORD) || (k == MOVE_BACK)) {
        d = ARROW_RIGHT;
        if (k == MOVE_BACK) d = ARROW_LEFT;
        return wordsmove(d);
    };

    if (k == ARROW_LEFT) cx--;
    if (k == ARROW_RIGHT) cx++;
    if (k == ARROW_UP) cy--;
    if (k == ARROW_DOWN) cy++;

    var maxrow = grlen(rows);

    if (cy < 0) cy = 0;
    if (cy > maxrow) cy = maxrow;

    var maxcol = 0;
    var row = 0;
    if (cy < maxrow) row = grget(rows, cy);
    if (row) maxcol = rowlen(row);

    if (cx < 0) {
        cx = 0;
        if (cy != 0) {
            move(ARROW_UP);
            row = grget(rows, cy);
            cx = rowlen(row);
        };
    } else if (cx > maxcol) {
        cx = maxcol;
        if ((k == ARROW_RIGHT || k == ARROW_LEFT) && cy != maxrow) {
            cx = 0;
            move(ARROW_DOWN);
        };
    };
};

multimove = func(k, n) {
    if (!n) n = 1;
    while (n--) {
        move(k);
        scroll();
    };
};

findchar = func(c, dir) {
    var cx0 = cx;
    var cy0 = cy;
    var cx1;
    var cy1;

    while (1) {
        cx1 = cx;
        cy1 = cy;
        move(dir);
        if ((cy!=cy0) || ((cx==cx1) && (cy==cy1))) {
            cx = cx0;
            cy = cy0;
            break;
        };
        if (curchar() == c) break;
    };
};

gotoline = func(n) {
    cy = n-1;
    if (cy < 0) cy = 0;
    if (cy >= grlen(rows)) cy = grlen(rows)-1;
    markalldirty();
    move(0);
};

processkey = func() {
    var c = readkey();

    setdefaultstatus();

    var n;
    var times_str;
    var reset_movecount = 1;

    if (c == CTRL_KEY('x')) {
        if (dirty && quit_times) {
            times_str = "times";
            if (quit_times == 1) times_str = "time";
            setstatusmsg("WARNING!!! File has unsaved changes. Press Ctrl-X %d more %s to quit.", [quit_times, times_str]);
            quit_times--;
            return 0;
        };
        quit(0);
    } else if (c == CTRL_KEY('o')) {
        savefile();
    } else if (c == CTRL_KEY('f')) {
        find();
    } else if (c == CTRL_KEY('e')) {
        helpscreen();
    } else if (c == CTRL_KEY('k')) {
        truncaterow();
    } else if (c == CTRL_KEY('z')) {
        unrawmode();
        if (dirty) puts("[No write since last change]\n");
        system(["/bin/sh"]);
        rawmode();
        markalldirty();
    } else if (c == CTRL_KEY('n')) {
        mode = !mode;
    } else if (c == PAGE_UP || c == CTRL_KEY('u')) {
        cy = cy - ROWS;
        rowoff = rowoff - ROWS;
        if (cy < 0) cy = 0;
        if (rowoff < 0) rowoff = 0;
        move(0);
        markalldirty();
    } else if (c == PAGE_DOWN || c == CTRL_KEY('d')) {
        cy = cy + ROWS;
        rowoff = rowoff + ROWS;
        if (cy >= grlen(rows)) cy = grlen(rows)-1;
        if (rowoff >= grlen(rows)) rowoff = grlen(rows)-1;
        move(0);
        markalldirty();
    } else if (c == HOME_KEY) {
        cx = 0;
    } else if (c == END_KEY) {
        if (cy < grlen(rows))
            cx = rowlen(grget(rows,cy));
    } else if (c == ARROW_UP || c == ARROW_DOWN || c == ARROW_LEFT || c == ARROW_RIGHT) {
        move(c);
    } else if (c == '\r') {
        insertnewline();
    } else if (c == BACKSPACE || c == DEL_KEY) {
        if (c == DEL_KEY) move(ARROW_RIGHT);
        delchar();
    } else if (c == CTRL_KEY('l')) {
        markalldirty();
    } else if (c == ESC) {
        mode = NAV_MODE;
    } else {
        if (mode == NAV_MODE) {
            if (isdigit(c) && ((c != '0') || (movecount != 0))) {
                movecount = mul(movecount,10) + (c - '0');
                reset_movecount = 0;
                setstatusmsg("%d", [movecount]);
            } else {
                navchar(c);
            };
        } else if (mode == INSERT_MODE) {
            insertchar(c);
        };
    };

    if (reset_movecount) movecount = 0;
    quit_times = QUIT_TIMES;
};

### INIT

markalldirty();
rawmode();
setdefaultstatus();

var args = cmdargs()+1;
if (*args) openfile(*args);

while (1) {
    # refresh the screen if there are no keystrokes waiting
    if (!readable())
        refresh();

    # handle a keystroke
    processkey();
};
