# open a shell on the 2nd serial port

include "sys.sl";

copyfd(0, 4);
copyfd(1, 4);
copyfd(2, 4);
exec(["/bin/sh"]);
