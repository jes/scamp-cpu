ld x, 1
out x, 0xaa
inc x
out x, 0x55
inc x
out x, 0xaa
loop:
    in x, 0
    out 0, x
    jmp loop
