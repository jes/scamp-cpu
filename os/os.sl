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

kputs("\nWelcome to SCAMP OS.\n\n");

# fd 3 is always the console
sys_write(3, "sys_write works\n", 16);

# Try to read a file
var fd = sys_open("/etc/motd", O_READ);
if (fd < 0) kpanic("no motd");
var ch = ".";
while (sys_read(fd, ch, 1)) kputs(ch);
sys_close(fd);

# We just need to start init to boot the system.
sys_exec(["/bin/init.x", 0]);

kpanic("return from init");
