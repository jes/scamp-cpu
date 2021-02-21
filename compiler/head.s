.at 0x100

# initialise sp and TOP
.def STACKSZ 1024
ld sp, TOP
add sp, STACKSZ
ld (_TOP), sp
inc (_TOP)

