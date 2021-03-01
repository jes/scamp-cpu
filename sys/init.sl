include "stdio.sl";
include "sys.sl";

puts("init: cat /etc/motd:\n");
system(["/bin/cat", "/etc/motd"]);

puts("init: ls /proc:\n");
system(["/bin/ls", "/proc"]);

puts("init halts.\n");
