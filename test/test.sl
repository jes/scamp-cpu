include "stdio.sl";

include "test_basic.sl";
include "test_bigint.sl";
include "test_bitmap.sl";
include "test_grarr.sl";
include "test_grep.sl";
include "test_hash.sl";
include "test_regex.sl";
include "test_sh.sl";

chdir("/home");

var recurse = 1;
var running_under = "(top)";

var args = cmdargs()+1;
if (*args) {
    recurse = 0;
    running_under = sprintf("(%s)", [*args]);
};

printf("BEGIN TEST OUTPUT %s\n", [running_under]);

puts("test_basic:\n"); test_basic();
puts("test_bigint:\n"); test_bigint();
puts("test_bitmap:\n"); test_bitmap();
puts("test_grarr:\n"); test_grarr();
puts("test_grep:\n"); test_grep();
puts("test_hash:\n"); test_hash();
puts("test_regex:\n"); test_regex();
puts("test_sh:\n"); test_sh();

puts("END TEST OUTPUT\n");

if (recurse) {
    puts("----\nrun test again under slc:\n");
    system(["/bin/slc", "-lbigint", "test.sl"]);
    system(["./test", "slc"]);

    puts("----\nrun test again under slangi:\n");
    system(["/bin/slangi", "test.sl", "slangi"]);

    outp(3, 1); # halt
};
