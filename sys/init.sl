include "sys.sl";

system(["/bin/cat", "/etc/motd"]);
exec(["/bin/sh"]);
