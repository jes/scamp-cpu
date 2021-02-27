
# return to os
push 0
call (_sys_exit)

# top of program address (initialised by head.s)
_TOP: .word 0
TOP:
