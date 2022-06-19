# RUDE Ultimate Development Environment for SLANG

include "bufio.sl";
include "hash.sl";
include "stdio.sl";
include "string.sl";
include "lib.sl";

var repl;
var eval;
var kilo;
var list;
var savesrc;
var savebin;
var varname;
var writesrcfile;
var writeglobalsfile;
var redirect;
var unredirect;
var cat;
var compile;
var compilefile;
var newglobal;
var addglobal;
var forget;

var globals = htnew();

var bufsz = 512;
var buf = malloc(bufsz);

var projectfile;
var historyfile;
var history;

repl = func() {
    puts("> ");
    var val;
    while (gets(buf, bufsz)) {
        bputs(history, buf);
        bflush(history);
        val = eval(buf);
        printf("%d 0x%04x\n", [val, val]);

        puts("> ");
    };
    exit(0);
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
    var addr;
    if (strncmp(code, "var ", 4) == 0) {
        # variable declaration: turn it into an assignment,
        # and add the name to the globals table
        code = code + 4;
        name = varname(code);
        if (!name) {
            fprintf(2, "can't parse variable name\n", 0);
            return 0;
        };
        printf("you declared '%s'\n", [name]);
        if (!newglobal(name)) {
            fprintf(2, "%s: already declared\n", [name]);
            return 0;
        };
        # TODO: [nice] don't bother trying to compile declarations without initialisation (just return now)
    };

    addr = compile(code);
    # TODO: [bug] if the compile failed, remove the name from the globals table if we created a new global
    if (!addr) return 0;
    # TODO: [nice] copy name.sl to name.sl.1, tmpfile to name.sl
    return addr();
};

kilo = func(funcname) {
    fprintf(2, "unimplemented\n", 0);
};

list = func(funcname) {
    fprintf(2, "unimplemented\n", 0);
};

savesrc = func(filename) {
    fprintf(2, "unimplemented\n", 0);
};

savebin = func(filename, entrypoint) {
    # TODO: [nice] writing instructions by opcode is a bit unpleasant

    # 1. initialise the stack pointer
    # TODO: [nice] instead of the current stack pointer, this should
    # really initialise to the "real" initial stack pointer, otherwise
    # repeated application of savebin() will result in progressively
    # smaller stack space available
    *0x100 = 0x85ff; # ld sp, i16
    *0x101 = *0xffff; # current stack pointer value

    # 2. write a "jmp entrypoint" instruction, so that we
    # don't reinitialise anything or re-enter the REPL
    *0x102 = 0xb900; # jmp i16
    *0x103 = entrypoint;

    # use the kernel to save the TPA to the file
    savetpa(filename);
};

# parse the variable name out of the start of code, return a
# pointer to a copy of it, or return 0 if none
varname = func(code) {
    var p = code;
    while (iswhite(*p)) p++; # skip whitespace
    if (!isalpha(*p) && *p != '_') return 0;
    p++;
    while (isalnum(*p) || *p == '_') p++; # skip over acceptable variable name characters
    var len = p - code;
    var s = malloc(len+1);
    memcpy(s, code, len); # copy the name
    s[len] = 0;
    return s;
};

# write the given source into a temporary file ready to compile;
# return a static string containing its name, or 0 on error
writesrcfile = func(code) {
    var name = "/tmp/rude.sl";
    var b = bopen(name, O_WRITE|O_CREAT);
    if (!b) {
        fprintf(2, "can't write %s\n", [name]);
        return 0;
    };

    bputs(b, code);
    bclose(b);

    return name;
};

var writeglobals_b;
writeglobalsfile = func() {
    var name = "/tmp/rude-globals.sl";
    var b = bopen(name, O_WRITE|O_CREAT);
    if (!b) {
        fprintf(2, "can't write %s\n", [name]);
        return 0;
    };

    writeglobals_b = b;
    htwalk(globals, func(k,v) {
        bputc(writeglobals_b, v);
        bputs(writeglobals_b, k);
        bputc(writeglobals_b, '\n');
    });

    bclose(b);

    return name;
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
    var globalsfile = writeglobalsfile();

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

    # write asm head now
    puts(".at 0x");
    printf("%04x", [addr]);
    puts("\njmp proceed\nreturn_address: .word 0\nproceed:\nld x, r254\nld (return_address), x\n");

    # compile!
    var rc = system(["/bin/slangc", "-e", globalsfile, "-f", "jmp (return_address)\n"]);
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
    rc = system(["/bin/asm", "-e", globalsfile]);
    unredirect(0, prev_in);
    unredirect(1, prev_out);
    #unlink(fullasm);
    if (rc != 0) {
        #unlink(binary);
        return 0;
    };

    var b = bopen(binary, O_READ);
    if (!b) {
        fprintf(2, "can't read %s\n", [binary]);
        return 0;
    };
    var filesz = bread(b, addr, codesz);
    assert(filesz lt codesz, "panic: compiled size exceeds 2K allocation\n", 0);
    var addr2 = realloc(addr, filesz); # this should shrink in-place
    assert(addr == addr2, "panic: realloc() changed code address\n", 0);
    #unlink(binary);

    return addr;
};

compilefile = func(filename) {
    fprintf(2, "compilefile() unimplemented\n", 0);
};

# add "name" to the globals table, return 1 if successful
# and 0 otherwise
newglobal = func(name) {
    var p = malloc(1);
    if (addglobal(name, p)) {
        return 1;
    } else {
        free(p);
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
        return 1;
    }
};

include "rude-globals.sl";

addglobal("savebin", &savebin);

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
