# SCAMP shell

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

var buf = malloc(256);

var args = malloc(32);
var i;
var p;
var path;

while (1) {
    fputs(2, "$ ");

    i = gets(buf, 256);
    if (i == 0) break;

    p = buf;
    i = 0;
    while (*p && iswhite(*p)) p++;
    if (!*p) continue;

    *args = p;
    i = 1;
    while (*p) {
        while (*p && !iswhite(*p)) p++;
        if (*p) {
            *(p++) = 0;
            while (*p && iswhite(*p)) p++;
            if (*p) *(args+i) = p
            else *(args+i) = 0;
        } else {
            *(args+i) = 0;
        };
        i++;
    };

    if (internal(args)) continue;

    path = search(args[0]);

    if (!path) {
        fprintf(2, "sh: %s: not found in path\n", [args[0]]);
        continue;
    };

    *args = path;

    i = system(args);
    if (i < 0) fprintf(2, "sh: %s: %s\n", [args[0], strerror(i)]);
};
