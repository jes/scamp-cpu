.at 0x100

# initialise sp and TOP
.def STACKSZ 2048
ld sp, TOP
add sp, STACKSZ

# stack grows down, _TOP grows up;
# make _TOP point 1 byte past the initial stack pointer
ld (_TOP), sp
inc (_TOP)

