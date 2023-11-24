include "stdio.sl";

include "test_grarr.sl";

chdir("/home");

var recurse = 1;
var running_under = "(top-level)";

var args = cmdargs()+1;
if (*args) {
    recurse = 0;
    running_under = sprintf("(under %s)", [*args]);
};

printf("BEGIN TEST OUTPUT %s\n", [running_under]);

puts("test_grarr:\n");
test_grarr();

puts("END TEST OUTPUT\n");

if (recurse) {
    puts("----\nrun test again under slc:\n");
    system(["/bin/slc", "test.sl"]);
    system(["./test", "slc"]);

    puts("----\nrun test again under slangi:\n");
    system(["/bin/slangi", "test.sl", "slangi"]);

    outp(3, 1); # halt
};
