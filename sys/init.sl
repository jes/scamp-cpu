include "sys.sl";

# TODO: [nice] init should become a shell script once they're supported
# TODO: [nice] init should clear out /tmp

system(["/bin/cat", "/etc/motd"]);
chdir("/home");
while (1)
    system(["/bin/sh"]);
