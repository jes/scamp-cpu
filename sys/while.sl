# while CONDITION BODY

include "sys.sl";
include "stdio.sl";
include "malloc.sl";

var usage = func() {
    fputs(2, "usage: while CONDITION BODY\n");
    exit(1);
};

var args = cmdargs()+1;
if (!args[0] || !args[1] || args[2]) usage();
var condition = strdup(args[0]);
var body = strdup(args[1]);

while (system(["/bin/sh", "-c", condition]) == 0)
    system(["/bin/sh", "-c", body]);
