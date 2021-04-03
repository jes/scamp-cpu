# Text editor
# Based on https://viewsourcecode.org/snaptoken/kilo/
#
# TODO: [bug] use less memory - currently can't open slangc.sl; stop using grarrs?
# TODO: [perf] needs to be usable at 1 MHz

include "grarr.sl";
include "stdio.sl";
include "stdlib.sl";
include "strbuf.sl";
include "string.sl";
include "sys.sl";

# definitions
var ESC = 0x1b;
var ROWS = 23; # rows of file content - should be 2 rows short of total screen rows
var COLS = 80;
var CTRL_KEY = func(k) return k&0x1f;
var WELCOME = "~     Kilo editor -- SCAMP edition";
var TABSTOP = 4; # must be a power of 2 !
var QUIT_TIMES = 3;
var WAIT_STEPS = 1000; # number of loop iterations to wait for escaped characters

# key constants
var BACKSPACE = 127;
var ARROW_LEFT = 1000;
var ARROW_RIGHT = 1001;
var ARROW_UP = 1002;
var ARROW_DOWN = 1003;
var PAGE_UP = 1004;
var PAGE_DOWN = 1005;
var HOME_KEY = 1006;
var END_KEY = 1007;
var DEL_KEY = 1008;

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

# terminal
var quit;
var fatal;
var rawmode;
var unrawmode;
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

### editor operations
var insertchar;
var insertnewline;
var truncaterow;
var delchar;

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
var scroll;

# input
var prompt_cursor = -1;
var prompt;
var move;
var processkey;
var waitread;

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
    consoleflags = serflags(3, 0);

    writeesc("[2J"); # clear screen
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

    if (n == 0) fatal("read: eof on stdin, but should be in raw mode ??? (is stdin a file?)", 0);
    if (n < 0) fatal("read: %s", [strerror(n)]);

    var seq = [0,0,0];
    if (c == ESC) {
        if (waitread(0, seq+0, 1, WAIT_STEPS) != 1) return ESC;
        if (waitread(0, seq+1, 1, WAIT_STEPS) != 1) return ESC;

        if (seq[0] == '[') {
            if (seq[1] >= '0' && seq[1] <= '9') {
                if (waitread(0, seq+2, 1, WAIT_STEPS) != 1) return ESC;
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

rowlen = func(r) return grlen(r);
row2chars = func(r) return grbase(r);

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

rx2cx = func(row, rx) {
    var s = row2chars(row);
    var x = 0;
    var i;
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
        grset(row, at, grget(row, at));
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
    memset(need_redraw, 1, ROWS);
};

markallclean = func() {
    memset(need_redraw, 0, ROWS);
};

### EDITOR OPERATIONS

insertchar = func(c) {
    var gr;
    if (cy == grlen(rows)) {
        gr = grnew();
        appendrow(gr);
    };

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
    var row = grget(rows, cy);
    grtrunc(row, cx);
    markrowdirty(cy);
    dirty = 1;
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

### FILE I/O

openfile = func(filename) {
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
    var buf = malloc(257);
    setbuf(fd, buf);

    var ch;
    while (1) {
        ch = fgetc(fd);
        if (ch == EOF) break;
        if (ch == '\n') {
            appendrow(row);
            row = grnew();
        } else {
            grpush(row, ch);
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

    var fd = open(openfilename, O_WRITE|O_CREAT);
    if (fd < 0) fatal("open %s: %s", [openfilename, strerror(fd)]);
    free(openfilename);

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

    var str = prompt("Search: ", " (ESC/arrows/enter)", 0, func(query, key) {
        if (key == 0) {
            # finished searching, reset state for next time
            find_last = -1;
            find_dir = 1;
            return 0;
        } else if (key == ARROW_RIGHT || key == ARROW_DOWN) {
            find_dir = 1;
        } else if (key == ARROW_LEFT || key == ARROW_UP) {
            find_dir = -1;
        } else {
            find_last = -1;
            find_dir = 1;
        };

        if (find_last == -1) find_dir = 1;
        var cur = find_last;

        var i = 0;
        var match;
        var line;
        while (i < grlen(rows)) {
            cur = cur + find_dir;
            if (cur == -1) cur = grlen(rows)-1;
            if (cur == grlen(rows)) cur = 0;

            line = row2chars(grget(rows, cur));
            match = strstr(line, query);
            if (match) {
                find_last = cur;
                cy = cur;
                cx = rx2cx(grget(rows, cur), match - line);
                rowoff = grlen(rows);
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

var outbuf = sbnew();

var flush = func() {
    write(1, sbbase(outbuf), sblen(outbuf));
    sbclear(outbuf);
};

writeesc = func(s) {
    sbputc(outbuf, ESC);
    sbputs(outbuf, s);
};

refresh = func() {
    scroll();
    writeesc("[?25l"); # hide cursor
    writeesc("[H"); # position cursor
    drawrows();
    drawstatus();
    drawstatusmsg();
    if (prompt_cursor == -1)
        sbprintf(outbuf, "%c[%d;%dH", [ESC, cy-rowoff+1, rx-coloff+1]) # position cursor
    else
        sbprintf(outbuf, "%c[%d;%dH", [ESC, ROWS+2, prompt_cursor]); # position cursor
    writeesc("[?25h"); # show cursor
    flush();
};

var rowbuf_col;
drawrow = func(row) {
    rowbuf_col = 0;
    var addchar = func(ch) {
        if (rowbuf_col >= coloff && rowbuf_col < coloff+COLS)
            sbputc(outbuf, ch);
        rowbuf_col++;
    };

    # turn the chars into something renderable:
    #  - turn tabs into 4 spaces
    #  - turn control characters into "^A" type stuff?
    var i = 0;
    var ch;
    while (i != rowlen(row)) {
        ch = grget(row, i++);
        if (ch == '\t') {
            addchar(' ');
            while (rowbuf_col & (TABSTOP-1))
                addchar(' ');
        } else if (iscntrl(ch)) {
            addchar('^');
            addchar(ch+'A');
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
            if (grlen(rows) == 0 && y == 8) sbputs(outbuf, WELCOME)
            else sbputc(outbuf, '~');
            writeesc("[K"); # clear to end of line
        } else if (rowdirty(filerow)) {
            drawrow(grget(rows,filerow));
        };

        sbputs(outbuf, "\r\n");
        y++;
    };
    markallclean();
};

drawstatus = func() {
    var name = openfilename;
    if (!name) name = "[No Name]";

    var dirtymsg = "";
    if (dirty) dirtymsg = "(modified)";

    var status = sprintf("%20s - %d lines %s", [name, grlen(rows), dirtymsg]);
    if (strlen(status) > COLS) *(status+COLS-1) = 0;
    var rstatus = sprintf("%d/%d ", [cy+1, grlen(rows)]);

    var len = strlen(status);
    var rlen = strlen(rstatus);

    writeesc("[7m"); # inverse video

    sbputs(outbuf, status);
    while (len < COLS) {
        if (COLS-len == rlen) {
            sbputs(outbuf, rstatus);
            break;
        } else {
            sbputc(outbuf, ' ');
            len++;
        };
    };
    writeesc("[m"); # un-inverse video
    sbputs(outbuf, "\r\n");

    free(status);
    free(rstatus);
};

drawstatusmsg = func() {
    writeesc("[K"); # clear line
    if (statusmsg) sbputs(outbuf, statusmsg);
};

setstatusmsg = func(fmt, args) {
    if (statusmsg) free(statusmsg);
    statusmsg = sprintf(fmt, args);
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
            sbfree(sb);
            break;
        } else if (c == '\r') {
            if (sblen(sb)) result = strdup(sbbase(sb));
            setstatusmsg("", 0);
            sbfree(sb);
            break;
        } else if (!iscntrl(c) && c < 128) {
            sbputc(sb, c);
        };

        # call callback only if there is no input waiting
        if (callback && (read(0,0,0)==0))
            callback(sbbase(sb), c);
    };

    prompt_cursor = -1;
    if (callback) callback(result, 0);
    return result;
};

move = func(k) {
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

processkey = func() {
    var c = readkey();

    var n;
    var times_str;

    # TODO: [nice] ctrl- arrow keys to jump left/right a word, and up/down a paragraph (?)
    if (c == CTRL_KEY('q')) {
        if (dirty && quit_times) {
            times_str = "times";
            if (quit_times == 1) times_str = "time";
            setstatusmsg("WARNING!!! File has unsaved changes. Press Ctrl-Q %d more %s to quit.", [quit_times, times_str]);
            quit_times--;
            return 0;
        };
        quit(0);
    } else if (c == CTRL_KEY('s')) {
        savefile();
    } else if (c == CTRL_KEY('f')) {
        find();
    } else if (c == CTRL_KEY('h')) {
        # TODO: [nice] show a full help screen
    } else if (c == CTRL_KEY('k')) {
        truncaterow();
    } else if (c == CTRL_KEY('z')) {
        unrawmode();
        if (dirty) puts("[No write since last change]\n");
        system(["/bin/sh"]);
        rawmode();
        markalldirty();
    } else if (c == PAGE_UP) {
        cy = rowoff;
        n = ROWS;
        while (n--) move(ARROW_UP);
    } else if (c == PAGE_DOWN) {
        cy = rowoff + ROWS-1;
        n = ROWS;
        while (n--) move(ARROW_DOWN);
    } else if (c == HOME_KEY) {
        cx = 0;
    } else if (c == END_KEY) {
        if (cy < grlen(rows))
            cx = rowlen(grget(rows,cy));
    } else if (c == ARROW_UP || c == ARROW_DOWN || c == ARROW_LEFT || c == ARROW_RIGHT) {
        move(c);
    } else if (c == '\r') {
        insertnewline();
    } else if (c == BACKSPACE || c == CTRL_KEY('h') || c == DEL_KEY) {
        if (c == DEL_KEY) move(ARROW_RIGHT);
        delchar();
    } else if (c == CTRL_KEY('l') || c == ESC) {
        markalldirty();
    } else {
        insertchar(c);
    };

    quit_times = QUIT_TIMES;
};

# wait for "timeout" loop iterations, read() if anything is available,
# otherwise return 0
waitread = func(fd, buf, bufsz, timeout) {
    while (timeout--) {
        if (read(fd, 0, 0))
            return read(fd, buf, bufsz);
    };

    return 0;
};

### INIT

markalldirty();
rawmode();
setstatusmsg("HELP: ^S save  ^Q quit  ^Z shell  ^K del line  ^F find", 0);

var args = cmdargs()+1;
if (*args) openfile(*args);

while (1) {
    # refresh the screen if there are no keystrokes waiting
    if (read(0, 0, 0) == 0)
        refresh();

    # handle a keystroke
    processkey();
};
