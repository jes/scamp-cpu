# glob matching

include "grarr.sl";
include "string.sl";
include "sys.sl";

# return 1 if "name" matches "pattern", 0 otherwise
var glob_match = func(pattern, name) {
    while (*name && *pattern) {
        if (*pattern == '*') {
            # skip over whatever the "*" could match and recurse to try to match the rest
            pattern++;
            while (*name) {
                if (*name == *pattern) {
                    if (glob_match(pattern, name)) return 1;
                };
                name++;
            };
            break;
        } else if (*pattern == '?' || *name == *pattern) {
            name++;
            pattern++;
        } else {
            return 0;
        };
    };

    # "*" can happily match 0 characters
    while (*pattern == '*') pattern++;

    if (*name || *pattern) return 0;
    return 1;
};

var globfree = func(g) {
    grwalk(g, free); # free each of the strdup()'d names
    grfree(g); # free the grarr
};

# expand "pattern"; return pointer to grarr of names, or 0 on error
# TODO: [nice] some way to report the actual error
# you should use globfree() to free the allocated memory
var glob = func(pattern) {
    var g = grnew();

    var p = pattern;
    var has_star = 0;
    var last_slash = 0;
    while (*p && !has_star) {
        if (*p == '*') has_star = 1;
        if (*p == '/') last_slash = p;
        p++;
    };
    # if "pattern" doesn't contain "*", then we don't need to expand anything
    if (!has_star) {
        grpush(g, strdup(pattern));
        return g;
    };

    # TODO: [nice] support "*" in directory names
    var fd;
    var dir = 0;
    if (last_slash) {
        # open the directory specified
        dir = pattern;
        *last_slash = 0;
        fd = opendir(pattern);
        pattern = last_slash+1;
    } else {
        # open the current working directory
        fd = opendir(".");
    };
    if (fd < 0) {
        globfree(g);
        return fd;
    };

    var dirbuf = malloc(254);
    var n;
    var i;
    var s;
    while (1) {
        n = readdir(fd, dirbuf, 254);
        if (n < 0) {
            globfree(g);
            free(dirbuf);
            return n;
        };
        if (n == 0) break;

        i = 0;
        p = dirbuf;
        while (i != n) {
            if ((*pattern != '*') || (*p != '.')) { # don't let '*' match a leading '.'
                if (glob_match(pattern, p)) {
                    if (dir) {
                        grpush(g, sprintf("%s/%s", [dir, p]));
                    } else {
                        grpush(g, strdup(p));
                    };
                };
            };
            # skip to the next name
            p = p + strlen(p) + 1;
            i++;
        };
    };

    free(dirbuf);
    close(fd);

    if (last_slash) *last_slash = '/'; # restore the "/"

    return g;
};
