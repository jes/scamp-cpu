# SCAMP boot monitor inspired by WozMon
#
# Input addresses and values as hex (e.g. "0f12")
#
# addr               Examine single address (done)
# addr-addr          Examine range
# addr: val          Write to single address (done)
# addr: val val...   Write to consecutive addresses
# addr R             Run program from address (done)

.at 0

.def SERIALDEV 136
.def SERIALDEVLSR 141

ld sp, 0x8000

# initialise serial port
ld x, 0x80
out 139, x # dlab = 1
ld x, 0
out 137, x
ld x, 1
out 136, x # 115200/1 = 115200 baud
ld x, 0x03
out 139, x # dlab = 0, mode 8n1

loop:
	# read line of input
	ld r1, 0xff80
	call gets

	# parse address from string in 0xff80 into r0
	ld r1, 0xff80
	call scanhex

	# skip over spaces
	call skipspaces

	# if the next char is a colon, this is an assignment
	cmp (r1), 0x3a # ':'
	jz assignment

	# if the next char is an 'R', we want to jmp to this address
	cmp (r1), 0x52 # 'R'
	jz r0

printvalue:
	# print address from r0
	call printhex

	# print ": "
	ld x, 0x3a # ':'
	out SERIALDEV, x
	ld x, 0x20 # ' '
	out SERIALDEV, x

	# print value of address
	ld x, r0
	ld r0, (x)
	call printhex

	# print newline
	ld x, 0x0d
	out SERIALDEV, x
	ld x, 0x0a
	out SERIALDEV, x
	jmp loop

assignment:
	inc r1 # skip ':'
	ld r4, r0
	call skipspaces
	call scanhex
	ld x, r0
	ld (r4), x
	ld r0, r4
	jmp printvalue

# inc r1 while (r1) == ' '
skipspaces:
	cmp (r1), 0x20
	jnz r254 # return if it's not a space
	inc r1
	jmp skipspaces

# return char in r0
getchar:
	# spin until a char is available
	in x, SERIALDEVLSR
	and x, 1
	jz getchar

	in x, SERIALDEV
	ld r0, x
	ret

# print char from r0
#putchar:
#	# TODO: spin until ready for a char?
#	out SERIALDEV, r0
#	ret

# r1 should point to buffer
# clobbers r2
# leaves r1 pointing at 0-terminator of string
gets:
	ld r2, r254
gets_loop:
	call getchar
	cmp r0, 8
	jz gets_backspace
	cmp r0, 127
	jz gets_backspace
	ld x, r0
	out SERIALDEV, x
	ld (r1++), x
	cmp r0, 0x0d
	jnz gets_loop
	dec r1
	ld (r1), 0
	ld x, 0x0a
	out SERIALDEV, x
	jmp r2
gets_backspace:
	dec r1 # TODO: disallow backspace at start of line
	ld x, 8
	out SERIALDEV, x
	ld x, 0x1b
	out SERIALDEV, x
	ld x, 0x5b
	out SERIALDEV, x
	ld x, 0x4b
	out SERIALDEV, x
	jmp gets_loop

# print 0-terminated string from r1
# clobbers r2
# leaves r1 pointing past 0-terminator of string
puts:
	ld r2, r254
puts_loop:
	ld x, (r1++)
	ld r0, x
	cmp r0, 0
	jz r2
	out SERIALDEV, r0
	jmp puts_loop

# take string pointer in r1
# return parsed value in r0, update r1 to point past the parsed value
# clobbers: r2, r3
scanhex:
	zero r0
	ld r3, 5
scanhex_loop:
	dec r3
	jz r254
	# each loop iteration:
	# multiply r0 by 16
	# take character pointer in r1
	# interpret it as a hex digit and add it to r0
	# increment r1
	shl2 r0
	shl2 r0
	ld x, (r1++)
	add r0, x
	cmp x, 0x30 # '0'
	jlt scanhex1_bad
	cmp x, 0x39 # '9'
	jle scanhex1_digit
	cmp x, 0x41 # 'A'
	jlt scanhex1_bad
	cmp x, 0x46 # 'F'
	jle scanhex1_ucase
	cmp x, 0x61 # 'a'
	jlt scanhex1_bad
	cmp x, 0x66 # 'f'
	jle scanhex1_lcase
	# fall-thru
scanhex1_bad:
	sub r0, x
	jmp scanhex_loop
scanhex1_digit:
	sub r0, 0x30
	jmp scanhex_loop
scanhex1_ucase:
	sub r0, 55 # 'A' - 10
	jmp scanhex_loop
scanhex1_lcase:
	sub r0, 87 # 'a' - 10
	jmp scanhex_loop

# take hex value in r0
# clobbers: r2, r3
printhex:
	ld r2, r254
	ld r3, r0
	call shr8
	call byteshr4
	call printhex1
	ld r0, r3
	call shr8
	call printhex1
	ld r0, r3
	call byteshr4
	call printhex1
	ld r0, r3
	call printhex1
	jmp r2

# print the single hex digit from lsb of r0
printhex1:
	ld x, r0
	and x, 0x0f
	add x, 0x30
	cmp x, 58
	jlt printhex1_out
	add x, 39
printhex1_out:
	out SERIALDEV, x
	ret

# shr r0 by 4 places, but result is truncated at byte width
# clobbers: r5,r6,r7,r8
byteshr4:
	ld r5, 0x10
	jmp shifter

# shr r0 by 8 places
# clobbers: r5,r6,r7,r8
shr8:
	ld r5, 0x0100
	# jmp shifter
#     fall-thru
#
# shr r0 by some places
# initialise r5 to the first bit you want to test
# clobbers: r6,r7,r8
shifter:
	ld r6, 0x01
	zero r8
	ld r7, 8
shifter_loop:
	ld x, r0
	and x, r5
	jz shifter_noset
	or r8, r6
shifter_noset:

	# shift bits left by 1
	shl r5
	shl r6

	dec r7
	jnz shifter_loop

	ld r0, r8
	ret

# need to fit in 256 words
#.at 0x100
