# peephole optimiser
# TODO: [perf] optimise more of the cases that the Perl-based peepopt handles

include "bufio.sl";

var bin = bfdopen(0, O_READ);
var bout = bfdopen(1, O_WRITE);

var bufsz = 1024;
var buf = malloc(bufsz);

var pushx = 0;

while (bgets(bin, buf, bufsz)) {
    if (strcmp(buf, "push x\n") == 0) pushx++
    else if ((strcmp(buf, "pop x\n") == 0) && pushx) pushx--
    else {
        while (pushx) {
            bputs(bout, "push x\n");
            pushx--;
        };
        bputs(bout, buf);
    };
};

bfree(bin);
bfree(bout);
