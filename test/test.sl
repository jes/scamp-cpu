include "stdio.sl";

include "test_bigint.sl";
include "test_grarr.sl";
include "test_hash.sl";

chdir("/home");

var recurse = 1;
var running_under = "(top)";

var args = cmdargs()+1;
if (*args) {
    recurse = 0;
    running_under = sprintf("(%s)", [*args]);
};

printf("BEGIN TEST OUTPUT %s\n", [running_under]);

puts("test_bigint:\n"); test_bigint();
puts("test_grarr:\n"); test_grarr();
puts("test_hash:\n"); test_hash();

puts("END TEST OUTPUT\n");

if (recurse) {
    puts("----\nrun test again under slc:\n");
    system(["/bin/slc", "-lbigint", "test.sl"]);
    system(["./test", "slc"]);

    puts("----\nrun test again under slangi:\n");
    system(["/bin/slangi", "test.sl", "slangi"]);

    outp(3, 1); # halt
};
