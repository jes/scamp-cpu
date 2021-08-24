# Kernel for SCAMP by jes

include "util.sl";

kputs("starting kernel...\r\n");

kputs("data ");
include "data.sl";
kputs("serial ");
include "serial.sl";
kputs("blkdev ");
include "blkdev.sl";
kputs("dir ");
include "dir.sl";
kputs("fs ");
include "fs.sl";

# Each of the included sys_*.sl modules initialises itself and writes the correct addresses
# to the system call vectors that it is responsible for.
kputs("sys_fs ");
include "sys_fs.sl";
kputs("sys_dir ");
include "sys_dir.sl";
kputs("sys_io ");
include "sys_io.sl";
kputs("sys_proc ");
include "sys_proc.sl";
kputs("sys_random ");
include "sys_random.sl";

# setup serial port fds
kputs("ser_init()\r\n");
ser_init();

kputs("loading init...\r\n");

# We just need to start init to boot the system.
sys_exec(["/bin/init"]);

kpanic("return from exec([\"/bin/init\"]) (probably /bin/init doesn't exist)");
