# Kernel for SCAMP by jes

include "util.sl";

kputs("starting kernel...\r\n");

kputs("data:\r\n");
include "data.sl";
kputs("serial:\r\n");
include "serial.sl";
kputs("blkdev:\r\n");
include "blkdev.sl";
kputs("dir:\r\n");
include "dir.sl";
kputs("fs:\r\n");
include "fs.sl";

# Each of the included sys_*.sl modules initialises itself and writes the correct addresses
# to the system call vectors that it is responsible for.
kputs("sys_fs:\r\n");
include "sys_fs.sl";
kputs("sys_dir:\r\n");
include "sys_dir.sl";
kputs("sys_io:\r\n");
include "sys_io.sl";
kputs("sys_proc:\r\n");
include "sys_proc.sl";

# setup serial port fds
kputs("ser_init():\r\n");
ser_init();

kputs("loading init...\r\n");

# We just need to start init to boot the system.
sys_exec(["/bin/init"]);

kpanic("return from exec([\"/bin/init\"]) (probably /bin/init doesn't exist)");
