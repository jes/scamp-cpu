include "stdio.sl";
include "sys.sl";

puts("init: cat /etc/motd:\n");
system(["/bin/cat", "/etc/motd"]);

puts("init: sh:\n");
system(["/bin/sh"]);

puts("init halts.\n");
