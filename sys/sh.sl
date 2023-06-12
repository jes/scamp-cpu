# SCAMP shell

include "getopt.sl";
include "glob.sl";
include "grarr.sl";
include "malloc.sl";
include "parse.sl";
include "stdio.sl";
include "strbuf.sl";
include "string.sl";
include "sys.sl";
include "bitmap.sl";

var sherr;

# return static "path/name" if name exists in path, otherwise return 0
var tryname_sz = 128;
var tryname = malloc(tryname_sz);
var try = func(path, name) {
    var lenpath = strlen(path);
    var lenname = strlen(name);

    if (lenpath+1+lenname+1 > tryname_sz) return 0;

    strcpy(tryname, path);
    *(tryname + lenpath) = '/';
    strcpy(tryname+lenpath+1, name);
    *(tryname + lenpath + 1 + lenname) = 0;

    # if we can open the name for reading, we'll allow it
    var fd = open(tryname, O_READ);
    if (fd < 0) return 0;
    close(fd);
    return tryname;
};

# search for path to "name"
# return pointer to static buffer
var search = func(name) {
    var s;

    # if "name" contains slashes, leave it alone
    s = name;
    while (*s) {
        if (*s == '/') return name;
        s++;
    };

    # look under "/bin"
    s = try("/bin", name);
    if (s) return s;

    # TODO: take path from $PATH?

    return 0;
};

# see if args[0] is an internal command - if so, run it and return 1;
# if not, return 0
var internal = func(args) {
    var n;

    if (strcmp(args[0], "cd") == 0) {
        if (args[1]) n = chdir(args[1])
        else n = chdir("/home"); # TODO: [nice] take from $HOME?
        if (n < 0) fprintf(2, "sh: %s: %s\n", [args[1], strerror(n)]);
    } else if (strcmp(args[0], "exit") == 0) {
        n = 0;
        if (args[1]) n = atoi(args[1]);
        exit(n);
    } else {
        return 0;
    };

    return 1;
};

# redirect "name" to "fd" with the given "mode"; return an fd that stores
# the previous state, suitable for use with "unredirect()";
# if "name" is a null pointer, do nothing and return -1
var redirect = func(fd, name, mode) {
    if (name == 0) return -1;

    var filefd = open(name, mode);
    if (filefd < 0) die("can't open %s: %s", [name, strerror(filefd)]);

    var prev = copyfd(-1, fd); # backup the current configuration of "fd"
    copyfd(fd, filefd); # overwrite it with the new file
    close(filefd);

    return prev;
};

# close the "fd" and restore "prev"
# if "fd" is -1, do nothing
var unredirect = func(fd, prev) {
    if (prev == -1) return 0;

    close(fd);
    copyfd(fd, prev);
    close(prev);
};

# TODO: [nice] communicate parse errors better

var parse_strp;
var parse_args;

var in_redirect;
var in_is_tmp;
var out_redirect;
var err_redirect;

var maxargument = 2048;
var ARGUMENT = malloc(maxargument);

# forward declarations
var execute_parse_args;

var StringExcept = func(except) {
    *ARGUMENT = peekchar();
    if (!parse(NotAnyChar, except)) return 0;
    var i = 1;
    while (i < maxargument) {
        *(ARGUMENT+i) = peekchar();
        if (!parse(NotAnyChar, except)) {
            *(ARGUMENT+i) = 0;
            skip();
            return 1;
        };
        if (ARGUMENT[i] == '\\') *(ARGUMENT+i) = nextchar();
        i++;
    };
    die("argument too long:%d,%d,%d",[ARGUMENT[0],ARGUMENT[4], ARGUMENT[7]]);
};
var BareWord = func(x) return StringExcept("|<> \t\r\n`'\"");

# TODO: [nice] implement backticks
var Backticks = func(x) { return 0; };
var SingleQuotes = func(x) {
    if (!parse(Char,'\'')) return 0;
    if (!parse(StringExcept,"'")) return 0;
    if (!parse(Char,'\'')) return 0;
    grpush(parse_args, strdup(ARGUMENT));
    return 1;
};
var DoubleQuotes = func(x) {
    if (!parse(Char,'"')) return 0;
    if (!parse(StringExcept,"\"")) return 0;
    if (!parse(Char,'"')) return 0;
    grpush(parse_args, strdup(ARGUMENT));
    return 1;
};

var Argument = func(x) {
    var g;

    if (parse(BareWord,0)) {
        g = glob(ARGUMENT);
        if (g) {
            grwalk(g, func(word) {
                grpush(parse_args, strdup(word));
            });
            globfree(g);
        }; # if (!g), most likely a directory doesn't exist
        return 1;
    };
    if (parse(Backticks,0)) return 1;
    if (parse(SingleQuotes,0)) return 1;
    if (parse(DoubleQuotes,0)) return 1;
    return 0;
};

# TODO: [nice] support appending with ">>"
var IORedirection = func(x) {
    if (parse(CharSkip,'<')) {
        if (!parse(BareWord,0)) die("< needs argument",0);
        in_redirect = strdup(ARGUMENT);
        in_is_tmp = 0;
        return 1;
    } else if (parse(CharSkip,'>')) {
        if (!parse(BareWord,0)) die("> needs argument",0);
        out_redirect = strdup(ARGUMENT);
        return 1;
    } else if (parse(String,"2>")) { # TODO: [nice] should support more generic fd redirection
        skip();
        if (!parse(BareWord,0)) die("2> needs argument",0);
        err_redirect = strdup(ARGUMENT);
        return 1;
    };
    return 0;
};

var Pipe = func(x) {
    if (parse(CharSkip,'|')) return 1;
    return 0;
};

var CommandLine = func(x) {
    while (1) {
        if (parse(Argument,0)) {
            # ...
        } else if (parse(IORedirection,0)) {
            # ...
        } else if (parse(Pipe,0)) {
            out_redirect = strdup(tmpnam());
            execute_parse_args();
            parse_args = grnew();
            in_redirect = out_redirect;
            in_is_tmp = 1;
            out_redirect = 0;
        } else {
            return 1;
        };
    };
};

var execute_arr = func(args) {
    # handle internal commands
    var p;
    if (internal(args)) {
        return 0;
    };

    # search for binaries and set absolute path
    var path = search(args[0]);
    if (!path) {
        fprintf(2, "sh: %s: not found in path\n", [args[0]]);
        return 1;
    };
    var oldargs0 = args[0];
    *args = strdup(path);
    free(oldargs0);

    # setup io redirection
    var prev_in = redirect(0, in_redirect, O_READ);
    var prev_out = redirect(1, out_redirect, O_WRITE|O_CREAT);
    var prev_err = redirect(2, err_redirect, O_WRITE|O_CREAT);

    # execute binaries
    var rc = system(args);

    # undo io redirection
    unredirect(0, prev_in);
    unredirect(1, prev_out);
    unredirect(2, prev_err);

    if (rc < 0) fprintf(2, "sh: %s: %s\n", [args[0], strerror(rc)]);

    return rc;
};

execute_parse_args = func() {
    if (grlen(parse_args) == 0) {
        grfree(parse_args);
        return 0;
    };

    grpush(parse_args, 0);

    var args_arr = malloc(grlen(parse_args));
    memcpy(args_arr, grbase(parse_args), grlen(parse_args));
    grfree(parse_args);

    var rc = execute_arr(args_arr);

    var p = args_arr;
    while (*p) free(*(p++));
    free(args_arr);

    return rc;
};

# parse the input string and return an array of args
# caller needs to free the returned array and each of
# the strings in it
var parse_input = func(str) {
    parse_strp = str;
    parse_args = grnew();

    in_redirect = 0;
    in_is_tmp = 0;
    out_redirect = 0;
    err_redirect = 0;

    parse_init(func() {
        if (*parse_strp) return *(parse_strp++);
        return EOF;
    });

    skip();
    if (!parse(CommandLine,0)) {
        grfree(parse_args);
        sherr = "parse error";
        return 1;
    };
    if (nextchar() != EOF) {
        grfree(parse_args);
        sherr = "parse error";
        return 1;
    };

    var rc = execute_parse_args();

    # free names of redirection filenames
    if (in_is_tmp) unlink(in_redirect);
    free(in_redirect);
    free(out_redirect);
    free(err_redirect);

    return rc;
};

# parse & execute the given string
var execute = func(str) {
    sherr = 0;
    var rc = parse_input(str);
    if (sherr) fprintf(2, "sh: %s\n", [sherr]);
    return rc;
};

var in_fd = 0; # stdin

var dashc = 0;
var args = getopt(cmdargs()+1, "", func(ch, arg) {
    if (ch == 'c') {
        dashc = 1;
    } else {
        fprintf(2, "sh: error: unrecognised option -%c\n", [ch]);
        exit(1);
    };
});

# sh -c ... : concatenate the args and execute them
var sb;
if (dashc) {
    sb = sbnew();
    while (*args) {
        sbputs(sb, *args);
        sbputc(sb, ' ');
        args++;
    };
    exit(execute(sbbase(sb)));
};

if (*args) {
    in_fd = open(*args, O_READ);
    if (in_fd < 0) die("sh: open %s: %s", [*args, strerror(in_fd)]);
};

var buf = malloc(256);

var SP = 0xffff;
var trap_sp = *SP;
var restarted = 0;
var restart = asm { }; # we'll return to here when ^C is typed
if (restarted) {
    fputc(2, '\n');
};
restarted = 1;
trap(restart);
*SP = trap_sp;

# override the die() from parse.sl so that it is non-fatal
die = func(fmt, args){
    fprintf(2, fmt, args);
    restart();
};

while (1) {
    if (in_fd == 0) {
        if (getcwd(buf, 256) == 0)
            fputs(2, buf);
        fputs(2, " $ ");
    };
    if (fgets(in_fd, buf, 256) == 0) break;
    outp(2,1);
    execute(buf);
    outp(1,1);
};
