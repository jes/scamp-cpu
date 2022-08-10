# RUDE Ultimate Development Environment for SLANG

include "bigint.sl";
include "bufio.sl";
include "hash.sl";
include "stdio.sl";
include "string.sl";
include "lib.sl";

var repl;
var internal;
var eval;
var evalfile;
var kilo;
var newimpl;
var revert;
var list;
var savesrc;
var savebin;
var varname;
var writesrcfile;
var writeglobals;
var redirect;
var unredirect;
var compile;
var newglobal;
var addglobal;
var exists;
var filesize;
var copy;
var interpret;

var RETURN;

var initial_sp = *0xffff;

var globals = htnew();

var bufsz = 512;
var buf = malloc(bufsz);

var projectfile;
var historyfile;
var history;
var autosave = 1;

var writeglobals_b;
var globalsfile = "/tmp/rude-globals.list";

repl = func() {
    writeglobals_b = bopen(globalsfile, O_WRITE|O_CREAT);
    if (!writeglobals_b) {
        fprintf(2, "can't write %s\n", [globalsfile]);
        return 0;
    };
    writeglobals(writeglobals_b);
    # we keep writeglobals_b open so that we can add new globals as they're declared

    if (!autosave) putchar('!');
    puts("> ");
    var val;
    while (gets(buf, bufsz)) {
        bputs(history, buf);
        bflush(history);
        if (buf[0] == '.') {
            val = internal(buf);
        } else {
            val = eval(buf);
        };
        printf("%d 0x%04x\n", [val, val]);

        if (autosave) savebin("project", repl);

        if (!autosave) putchar('!');
        puts("> ");
    };
    exit(0);
};

internal = func(str) {
    var name;
    var val;
    if (strncmp(str, ".kilo ", 6) == 0) {
        name = varname(str+6, 0);
        val = kilo(name);
        free(name);
    } else if (strncmp(str, ".list ", 6) == 0) {
        name = varname(str+6, 0);
        val = list(name);
        free(name);
    } else if (strncmp(str, ".revert ", 8) == 0) {
        name = varname(str+6, 0);
        val = revert(name);
        free(name);
    };

    return val;
};

# evaluate the code; return its evaluation, or 0 if there
# was an error
# TODO: [bug] distinguish 0 from error?
# TODO: [bug] support include statements (should add their globals to our globals table, I think?)
# TODO: [nice] for simple expressions (no loops, no functions, etc.) just evaluate them instead of compiling
# TODO: [nice] notice assignments and handle them specially by writing the source code to function_name.sl, and backing up to function_name.sl.1
eval = func(code) {
    while (iswhite(*code)) code++; # skip whitespace
    var name;
    var addr = 0;
    if (strncmp(code, "var ", 4) == 0) {
        # variable declaration: turn it into an assignment,
        # and add the name to the globals table
        code = code + 4;
        name = varname(code, 0);
        if (!name) {
            fprintf(2, "can't parse variable name\n", 0);
            return 0;
        };
        newglobal(name);
        # TODO: [nice] don't bother trying to compile declarations without initialisation (just return now)
    } else {
        # detect non-declaration assignments, because we still need to newimpl()
        name = varname(code, '=');
    };

    if (interpret(code)) {
        if (name) free(name);
        return RETURN;
    };

    addr = compile(code);

    var global;
    if (name) {
        newimpl(name, "/tmp/rude.sl");
        global = htget(globals, name);
        if (global) {
            global[1] = global[0]; # copy the current assignment into the "revert" slot
        };
        free(name);
    };

    if (addr) return addr()
    else return 0;
};

evalfile = func(filename) {
    var fd = open(filename, O_READ);
    if (fd < 0) {
        fprintf(2, "can't write %s: %s\n", [filename, strerror(fd)]);
        return 0;
    };
    var srcsz = filesize(filename);
    var srcbuf = malloc(srcsz+1);
    var n = read(fd, srcbuf, srcsz+1);
    if (n > srcsz) {
        fprintf(2, "%s: too much data!\n", [filename]);
    };
    srcbuf[srcsz] = 0;
    close(fd);

    var v = eval(srcbuf);
    free(srcbuf);
    return v;
};

kilo = func(funcname) {
    var filename = "/tmp/rude-kilo.sl";

    var fd;

    var implname = sprintf("%s.sl", [funcname]);
    if (exists(implname)) {
        copy(implname, filename);
    } else {
        fd = open(filename, O_WRITE|O_CREAT);
        if (fd < 0) {
            fprintf(2, "can't write %s: %s\n", [filename, strerror(fd)]);
            return 0;
        };
        fprintf(fd, "var %s = ", [funcname]);
        close(fd);
    };

    free(implname);

    # TODO: [perf] get kilo to return a status that says whether the file was
    #       modified; if not modified, don't re-eval
    system(["/bin/kilo", filename]);

    return evalfile(filename);
};

# there's a new implementation of "name" in "filename";
# do some book-keeping so that we keep track of it;
# XXX: a side-effect is removal of "filename" (it gets renamed into place)
newimpl = func(name, filename) {
    var implname = sprintf("%s.sl", [name]);
    var implname1 = sprintf("%s.sl.1", [name]);

    # backup the old implementation
    unlink(implname1);
    rename(implname, implname1);
    # move the new implementation into palce
    unlink(implname);
    rename(filename, implname);

    free(implname);
    free(implname1);
};

revert = func(name) {
    var implname = sprintf("%s.sl", [name]);
    var implname1 = sprintf("%s.sl.1", [name]);
    var implname2 = sprintf("%s.sl.2", [name]);

    var t;
    var global;
    if (!exists(implname1)) {
        fprintf(2, "%s: does not exist\n", [implname1]);
    } else {
        unlink(implname2);
        rename(implname, implname2);
        unlink(implname);
        rename(implname1, implname);
        unlink(implname1);
        rename(implname2, implname1);

        # swap the new/old pointers
        global = htget(globals, name);
        if (global) {
            t = global[1];
            global[1] = global[0];
            global[0] = t;
        };
    };

    free(implname);
    free(implname1);
    free(implname2);
};

list = func(funcname) {
    var implname = sprintf("%s.sl", [funcname]);

    var b;
    if (!exists(implname)) {
        fprintf(2, "%s: does not exist\n", [implname]);
    } else {
        b = bopen(implname, O_READ);
        if (!b) {
            fprintf(2, "%s: does not exist (???)\n", [implname]);
        } else {
            while (bgets(b, buf, bufsz)) {
                puts(buf);
            };
            bclose(b);
        };
    };

    free(implname);
};

savesrc = func(filename) {
    fprintf(2, "unimplemented\n", 0);
};

savebin = func(filename, entrypoint) {
    # TODO: [nice] writing instructions by opcode is a bit unpleasant

    # 1. initialise the stack pointer
    *0x100 = 0x85ff; # ld sp, i16
    *0x101 = initial_sp;

    # 2. write a "call entrypoint" instruction, so that we
    # don't reinitialise anything or re-enter the REPL
    *0x102 = 0x4f00; # call i16
    *0x103 = entrypoint;

    # 3. exit(0)
    *0x104 = 0x5b00; # push 0
    *0x105 = 0x1f00; # call (i16)
    *0x106 = 0xfeff; # sys_exit

    # use the kernel to save the TPA to the file
    savetpa(filename);
};

# parse the variable name out of the start of code, return a
# pointer to a copy of it, or return 0 if none;
# if "seekch" is nonzero, skip whitespace and require a "seekch" next,
# otherwise return 0 instead of the name (e.g. use seekch='=' to detect
# assignments)
varname = func(code, seekch) {
    var p = code;
    while (iswhite(*p)) p++; # skip whitespace
    if (!isalpha(*p) && *p != '_') return 0;
    p++;
    while (isalnum(*p) || *p == '_') p++; # skip over acceptable variable name characters
    var len = p - code;
    var s = malloc(len+1);
    memcpy(s, code, len); # copy the name
    s[len] = 0;

    # if we have a seekch, check that we find it
    if (seekch) {
        while (iswhite(*p)) p++; # skip whitespace
        if (*p != seekch) {
            free(s);
            return 0;
        };
    };

    return s;
};

# write the given source into a temporary file ready to compile;
# return a static string containing its name, or 0 on error
writesrcfile = func(code) {
    var name = "/tmp/rude.sl";
    var fd = open(name, O_WRITE|O_CREAT);
    if (fd < 0) {
        fprintf(2, "can't write %s\n", [name]);
        return 0;
    };

    write(fd,code,strlen(code));
    close(fd);

    return name;
};

writeglobals = func() {
    htwalk(globals, func(k,v) {
        bputc(writeglobals_b, v);
        bputs(writeglobals_b, k);
        bputc(writeglobals_b, '\n');
    });
    bflush(writeglobals_b);
};

# redirect "name" to "fd" with the given "mode"; return an fd that stores
# the previous state, suitable for use with "unredirect()";
# if "name" is a null pointer, do nothing and return -1
redirect = func(fd, name, mode) {
    if (name == 0) return -1;

    var filefd = open(name, mode);
    if (filefd < 0) {
        fprintf(2, "can't open %s: %s\n", [name, strerror(filefd)]);
        exit(1);
    };

    var prev = copyfd(-1, fd); # backup the current configuration of "fd"
    copyfd(fd, filefd); # overwrite it with the new file
    close(filefd);

    return prev;
};

# close the "fd" and restore "prev"
# if "fd" is -1, do nothing
unredirect = func(fd, prev) {
    if (prev == -1) return 0;

    close(fd);
    copyfd(fd, prev);
    close(prev);
};

# TODO: [perf] if we've already compiled this code already then we can
# just re-execute the previous copy, because compilation is idempotent
# provided the addresses of globals don't change; we could take a hash
# of the source and create a hash table mapping those hashes to the
# addresses of their binaries; maybe not worth the memory footprint?
# shouldn't be too big though, just a single table entry per input line
compile = func(code) {
    #printf("compile [%s]\n", [code]);
    var srcfile = writesrcfile(code);

    var prev_in;
    var prev_out;

    # redirect stdin to read the source file
    prev_in = redirect(0, srcfile, O_READ);

    # redirect stdout to capture the asm output
    var compiledasm = "/tmp/rude.s";
    prev_out = redirect(1, compiledasm, O_WRITE|O_CREAT);

    # allocate a 2K buffer at first, we'll realloc() it down once we know
    # how much space we need
    var codesz = 2048;
    var addr = malloc(codesz);

    # XXX: make sure there are no memory allocations between the malloc(codesz)
    # and the realloc(addr, filesz) - otherwise we'll fragment memory and run
    # out very quickly!

    # write asm head now
    puts(".at 0x");
    printf("%04x", [addr]);
    puts("\njmp proceed\nreturn_address: .word 0\nproceed:\nld x, r254\nld (return_address), x\n");

    # compile!
    var rc = system(["/bin/slangc", "-q", "-g", "-f", "jmp (return_address)\n"]);
    unredirect(0, prev_in);
    unredirect(1, prev_out);

    #unlink(srcfile);

    if (rc != 0) {
        #unlink(compiledasm);
        return 0;
    };

    prev_in = redirect(0, compiledasm, O_READ);
    var binary = "/tmp/rude.bin";
    prev_out = redirect(1, binary, O_WRITE|O_CREAT);
    rc = system(["/bin/asm", "-q", "-e", globalsfile]);
    unredirect(0, prev_in);
    unredirect(1, prev_out);
    #unlink(fullasm);
    if (rc != 0) {
        #unlink(binary);
        return 0;
    };

    var fd = open(binary, O_READ);
    if (fd < 0) {
        fprintf(2, "can't read %s\n", [binary]);
        return 0;
    };
    var filesz = read(fd, addr, codesz);
    close(fd);
    assert(filesz lt codesz, "panic: compiled size exceeds 2K allocation\n", 0);
    var addr2 = realloc(addr, filesz); # this should shrink in-place
    assert(addr == addr2, "panic: realloc() changed code address\n", 0);
    #unlink(binary);

    return addr;
};

# add "name" to the globals table, return 1 if successful
# and 0 otherwise
newglobal = func(name) {
    var p = malloc(2); # the 2nd slot is for the "old" implementation of a function, if any
    name = strdup(name);
    if (addglobal(name, p)) {
        return 1;
    } else {
        free(p);
        free(name);
        return 0;
    };
};

# add "name" to the globals table with the given value,
# return 1 if successful and 0 otherwise
addglobal = func(name, val) {
    if (htget(globals, name)) {
        return 0;
    } else {
        htput(globals, name, val);
        if (writeglobals_b) {
            bputc(writeglobals_b, val);
            bputs(writeglobals_b, name);
            bputc(writeglobals_b, '\n');
            bflush(writeglobals_b);
        };
        return 1;
    }
};

# return 1 if filename exists, 0 otherwise
exists = func(name) {
    var fd = open(name, O_READ);
    close(fd);
    return fd >= 0;
};

# return the number of words in the file
filesize = func(name) {
    var statbuf = [0,0,0,0];
    if (stat(name, statbuf) < 0) return 0;
    return statbuf[1];
};

# copy file from src to dst
copy = func(src, dst) {
    var bs = bopen(src, O_READ);
    if (!bs) return -1;
    var bd = bopen(dst, O_WRITE|O_CREAT);
    if (!bd) {
        bclose(bs);
        return -1;
    };

    var n;
    while (1) {
        n = bread(bs, buf, bufsz);
        if (bwrite(bd, buf, n) != n) {
            fprintf(2, "copy: short write (???)", 0);
        };
        if (n < 0) {
            fprintf(2, "copy: bread: %s\n", [strerror(n)]);
        };
        if (n == 0) break;
    };
    bclose(bs);
    bclose(bd);

    return 0;
};

# TODO: [nice] this function is overly-complex and underly-complete;
#       we should instead parse the code into an AST and evaluate it
interpret = func(code) {
    var name;

    var is_call = 0;
    var s = code;

    var assign = 0;

    while (iswhite(*s)) s++;

    if (!*s) return 1; # empty string

    name = varname(code, 0);
    if (!name) return 0;
    s = s + strlen(name);

    var v = htget(globals,name);
    free(name);
    if (!v) return 0;
    v = *v;

    while (iswhite(*s)) s++;
    if (*s == '=') {
        # assignment
        assign = v;

        s++;
        while (iswhite(*s)) s++;

        # get new varname
        name = varname(s, 0);
        if (!name) return 0;
        s = s + strlen(name);

        v = htget(globals,name);
        free(name);
        if (!v) return 0;
        v = *v;
    };

    var v2;
    while (iswhite(*s)) s++;
    while (*s == '[') {
        # array indexing
        s++;
        while (iswhite(*s)) s++;

        if (isdigit(*s)) {
            v2 = atoi(s);
            while (isdigit(*s)) s++;
        } else {
            # get new varname
            name = varname(s, 0);
            if (!name) return 0;
            s = s + strlen(name);

            v2 = htget(globals,name);
            free(name);
            if (!v2) return 0;
            v2 = *v2;
        };

        v = *(v+v2);

        while (iswhite(*s)) s++;
        if (*s != ']') return 0;
        s++;
        while (iswhite(*s)) s++;
    };

    if (*s == '(') {
        # function call
        s++;
        is_call = 1;

        # look for close paren
        while (iswhite(*s)) s++;
        if (*s != ')') return 0;
        s++;
    };

    # if there's more string, then it's something we can't interpret
    while (iswhite(*s)) s++;
    if (*s) return 0;

    RETURN = v;
    if (is_call) RETURN = RETURN();

    if (assign) *assign = RETURN;

    return 1;
};

include "rude-globals.sl";

addglobal("savebin", &savebin);
addglobal("kilo", &kilo);
addglobal("repl", &repl);
addglobal("revert", &revert);
addglobal("list", &list);
addglobal("autosave", &autosave);

# TODO: [nice] grab project name from command line?

projectfile = "project";
historyfile = sprintf("%s.sl", [projectfile]);

history = bopen(historyfile, O_WRITE|O_CREAT);
# TODO: [bug] when we reload a saved binary project, the "history" will refer to a non-open file descriptor,
# we'd need to reopen it in append mode or something?
if (!history) {
    fprintf(2, "project.sl: can't open for writing\n", 0);
    exit(1);
};

# this prints when we load up a fresh project, but not
# when we load up a saved project, because then we are
# jumping straight to repl()
puts("RUDE AWAKENING\n");

repl();
