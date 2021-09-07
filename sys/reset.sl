# reset the terminal

include "stdio.sl";

var esc = func() { putchar(0x1b); };

esc(); puts("[2J"); # clear screen
esc(); puts("[H"); # home cursor
esc(); puts("[?25h"); # show cursor
esc(); puts("[?12h"); # enable blinking
