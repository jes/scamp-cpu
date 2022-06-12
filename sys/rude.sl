# RUDE Ultimate Development Environment for SLANG

include "hash.sl";
include "stdio.sl";
include "string.sl";

var repl;
var eval;
var kilo;
var list;
var savesrc;
var savebin;
var varname;
var compile;
var compilefile;
var addglobal;
var forget;

var globals = htnew();

var bufsz = 512;

repl = func() {
    var buf = malloc(bufsz);
    printf("> ", 0);
    var val;
    while (gets(buf, bufsz)) {
        # TODO: savebin(project binary file, repl)
        val = eval(buf);
        printf("%d 0x%04x\n", [val, val]);
        printf("> ", 0);
    }
};

# evaluate the code; return its evaluation, or 0 if there
# was an error
# TODO: [bug] distinguish 0 from error?
# TODO: [bug] support include statements (should add their globals to our globals table, I think?)
# TODO: [nice] for simple statements (no loops, no functions, etc.) just evaluate them instead of compiling
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
        if (!addglobal(name)) {
            fprintf(2, "%s: already declared\n", [name]);
            return 0;
        };
        # TODO: [nice] write the code to a tmp file
        addr = compile(code);
        # TODO: [bug] if the compile failed, remove the name from globals table
        if (!addr) return 0;
        # TODO: [nice] copy name.sl to name.sl.1, tmpfile to name.sl
        return addr();
    } else {
        addr = compile(code);
        if (!addr) return 0;
        return addr();
    }
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
    fprintf(2, "unimplemented\n", 0);

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

compile = func(code) {
    printf("compile [%s]\n", [code]);
    return func() { printf("[compiled code goes here]\n", 0) };
    #var fd,tmpname = open temp file
    #fputs(fd, "include \"lib.h\"\n");
    #writeglobals_h(fd);
    #fputs(fd, "func() {");
    #fputs(fd, code);
    #fputs(fd, "}");
    #close(fd);
#
#    system("slangc") < tmpname > tmpname2
#
#    unlink tmpname
#
#    var codesz = how many words the code takes up, from slangc
#
#    var addr = malloc(codesz);
#
#    var fd,tmpname3 = open temp file
#    fprintf(fd, ".at %d", [addr]);
#    writeglobals_s(fd);
#    copy file tmpname2 into fd
#    close fd
#    unlink tmpname2
#    system("asm") < tmpname3 > tmpname4
#
#    read tmpname4 into addr
#    panic if the size does not match codesz
#
#    return addr;
};

compilefile = func(filename) {
};

# add "name" to the globals table, return 1 if successful
# and 0 otherwise
addglobal = func(name) {
    if (htget(globals, name)) {
        return 0;
    } else {
        htput(globals, name, malloc(1));
        return 1;
    }
};

# grab project name from command line?
repl();
