# Kernel for SCAMP by jes

include "util.sl";

kputs("starting kernel...\r\n");

include "data.sl";
include "serial.sl";
include "blkdev.sl";
include "dir.sl";
include "fs.sl";

# Each of the included sys_*.sl modules initialises itself and writes the correct addresses
# to the system call vectors that it is responsible for.
include "sys_fs.sl";
include "sys_dir.sl";
include "sys_io.sl";
include "sys_proc.sl";

# setup serial port fds
ser_init();

kputs("loading init...\r\n");

# We just need to start init to boot the system.
sys_exec(["/bin/init"]);

kpanic("return from exec([\"/bin/init\"]) (probably /bin/init doesn't exist)");
