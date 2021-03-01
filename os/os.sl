# OS for SCAMP by jes

# "Kernel" utilities
include "util.sl";

kputs("starting kernel...\n");

include "data.sl";
include "serial.sl";
include "blkdev.sl";
include "dir.sl";
include "fs.sl";

# Each of the included os_*.sl modules initialises itself and writes the correct addresses
# to the system call vectors that it is responsible for.
include "os_fs.sl";
include "os_dir.sl";
include "os_io.sl";
include "os_proc.sl";
include "kprintf.sl";

kputs("loading init...\n");

# We just need to start init to boot the system.
sys_exec(["/bin/init"]);

kpanic("return from init");
