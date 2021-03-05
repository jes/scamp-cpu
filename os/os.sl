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

kputs("fsck...\n");
fsck();

kputs("loading init...\n");

# TODO: [bug] we should make separate kernel vs user entry points for system
#       calls, so that we only catch() once each time!

# We just need to start init to boot the system.
sys_exec(["/bin/init"]);

kpanic("return from init");
