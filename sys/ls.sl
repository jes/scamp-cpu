include "getopt.sl";
include "grarr.sl";
include "hash.sl";
include "malloc.sl";
include "stdio.sl";
include "string.sl";
include "sys.sl";

# TODO: align in neat columns like GNU ls?

var bufsz = 256;
var buf = malloc(bufsz);

var rc = 0;

var single_column = 0;
var show_hidden = 0;
var long_output = 0;
var reverse = 0;
var size_sort = 0;

var COLUMNS = 80;
var ls_col;

var statbufs = 0;

var memostat = func(name) {
    if (!statbufs) statbufs = htnew();

    var r = htget(statbufs, name);
    if (r) return cdr(r);

    var statbuf = malloc(4);
    var n = stat(name, statbuf);
    if (n < 0) {
        fprintf("stat %s: %s\n", [name, strerror(n)]);
        statbuf = 0;
    };
    htput(statbufs, name, statbuf);

    return statbuf;
};

var ls_single = func(names) {
    grwalk(names, func(s) {
        puts(s);
        putchar('\n');
    });
};

var ls_long = func(names) {
    grwalk(names, func(s) {
        var typch = '?';
        var size = 0;

        var statbuf = memostat(s);
        if (statbuf) {
            typch = '-';
            if (*statbuf == 0) typch = 'd';
            size = statbuf[1];
        };
        printf("%c %5u %s\n", [typch, size, s]);
    });
};

var ls_short = func(names) {
    ls_col = 0;
    grwalk(names, func(s) {
        var len = strlen(s);
        var extra = 8-(len & 7);
        if (ls_col && (ls_col + len + extra >= COLUMNS)) {
            putchar('\n');
            ls_col = 0;
        };
        puts(s);
        ls_col = ls_col + len + extra;
        while (extra--) putchar(' ');
    });

    if (ls_col) putchar('\n');
};

var sizecmp = func(a, b) {
    var sizea = 0;
    var sizeb = 0;

    var statbuf = memostat(a);
    if (statbuf) {
        sizea = statbuf[1];
    };
    statbuf = memostat(b);
    if (statbuf) {
        sizeb = statbuf[1];
    };

    # we can't just "return sizeb-sizea" because it overflows on values
    # larger than 32K
    if (sizeb == sizea) return 0
    else if (sizeb lt sizea) return -1
    else return 1;
};

var ls = func(name) {
    var fd = opendir(name);
    if (fd < 0) {
        fprintf(2, "ls: opendir %s: %s\n", [name, strerror(fd)]);
        rc = 1;
        return 0;
    };

    var n;
    var p;
    var names = grnew();
    while (1) {
        n = readdir(fd, buf, bufsz);
        if (n == 0) break;
        if (n < 0) {
            fprintf(2, "ls: readdir %s: %s\n", [name, strerror(n)]);
            rc = 1;
            break;
        };

        p = buf;
        while (n--) {
            if (show_hidden || (*p != '.'))
                grpush(names, strdup(p));
            p = p + strlen(p)+1;
        };
    };
    close(fd);

    # change directory so that we can stat() the files in sizecmp(),ls_long()
    # TODO: [bug] getcwd() can fail if the path is too long
    getcwd(buf, bufsz);
    chdir(name);

    if (size_sort) grsort(names, sizecmp)
    else grsort(names, strcmp);

    if (reverse) grrev(names);

    if (single_column) ls_single(names)
    else if (long_output) ls_long(names)
    else ls_short(names);

    if (statbufs) {
        htwalk(statbufs, func(k,v) free(v));
        htfree(statbufs);
        statbufs = 0;
    };

    grwalk(names, free);
    grfree(names);

    chdir(buf);
};

var help = func(rc) {
    puts("usage: ls [options] [DIR]...

options:
    -1    single-column output
    -a    show hidden files
    -h    show this text
    -l    long output
    -r    reverse order
    -S    sort by size, largest first
");
    exit(rc);
};

var args = getopt(cmdargs()+1, "", func(ch,arg) {
    if (ch == '1') single_column = 1
    else if (ch == 'a') show_hidden = 1
    else if (ch == 'h') help(0)
    else if (ch == 'l') long_output = 1
    else if (ch == 'r') reverse = 1
    else if (ch == 'S') size_sort = 1
    else help(1);
});

var nargs = 0;
var p = args;
while (*(p++)) nargs++;

if (nargs == 0) {
    ls(".");
} else {
    while (*args) {
        if (nargs > 1) printf("%s:\n", [*args]);
        ls(*args);
        args++;
    };
};

exit(rc);
