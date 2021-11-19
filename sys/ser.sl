include "bufio.sl";
include "serial.sl";
include "strbuf.sl";

var usage = func() {
    fputs(2, "usage: ser get REMOTEPATH LOCALPATH\n");
    fputs(2, "       ser put LOCALPATH REMOTEPATH\n");
    exit(1);
};

var slurp = func(name) {
    var b = bopen(name, O_READ);
    var sb = sbnew();
    var ch;
    while (1) {
        ch = bgetc(b);
        if (ch == EOF) break;
        sbputc(sb, ch);
    };
    bclose(b);
    return sbbase(sb);
};

var args = cmdargs()+1;
if (!args[0] || !args[1] || !args[2]) usage();

var rc = 0;

var localfile;
var bputs_cb = func(ok, chunklen, content) {
    if (ok) {
        while (chunklen--)
            bputc(localfile, *(content++));
    } else {
        rc = 1;
        while (chunklen--)
            fputc(2, *(content++));
    };
};

var r;

if (strcmp(args[0], "get") == 0) {
    localfile = bopen(args[2], O_WRITE|O_CREAT);
    ser_get_p("file", args[1], 0, bputs_cb);
    bclose(localfile);
} else if (strcmp(args[0], "put") == 0) {
    r = ser_put("file", args[2], slurp(args[1]));
    if (!r[0]) {
        fputs(2, r[1]);
        rc = 1;
    };
    free(r[1]);
} else {
    usage();
};

if (rc != 0) fputc(2, '\n');

exit(rc);
