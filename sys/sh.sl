# SCAMP shell

include "grarr.sl";
include "malloc.sl";
include "stdio.sl";
include "string.sl";
include "sys.sl";

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

var internal = func(args) {
    var n;

    if (strcmp(args[0], "cd") == 0) {
        if (!args[1]) *(args+1) = "/"; # TODO: take from $HOME?
        n = chdir(args[1]);
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

# parse the input string and return an array of args
# caller needs to free the returned array
var parse_input = func(str) {
    var p = str;
    while (*p && iswhite(*p)) p++;
    if (!*p) return 0;

    var args = grnew();

    grpush(args, p);
    while (*p) {
        while (*p && !iswhite(*p)) p++;
        if (*p) {
            *(p++) = 0;
            while (*p && iswhite(*p)) p++;
            if (*p) grpush(args, p);
        };
    };
    grpush(args, 0);

    var args_arr = malloc(grlen(args));
    memcpy(args_arr, grbase(args), grlen(args));
    grfree(args);

    return args_arr;
};

# parse & execute the given string
var execute = func(str) {
    var args = parse_input(str);

    # handle internal commands
    if (internal(args)) {
        free(args);
        return 0;
    };

    # search for binaries and set absolute path
    var path = search(args[0]);
    if (!path) {
        fprintf(2, "sh: %s: not found in path\n", [args[0]]);
        free(args);
        return 0;
    };
    *args = path;

    # execute binaries
    var n = system(args);
    if (n < 0) fprintf(2, "sh: %s: %s\n", [args[0], strerror(n)]);

    free(args);
};

# TODO: [nice] if "-c", then just execute() the cmdargs()?
# TODO: [nice] execute files passed in cmdargs()

var buf = malloc(256);
while (1) {
    fputs(2, "$ "); # TODO: [nice] not if stderr is not a terminal
    if (gets(buf, 256) == 0) break;
    execute(buf);
};
