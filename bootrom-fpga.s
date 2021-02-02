ld sp, 0xff80

loop:
    in r4, 0

    ld r100, 0

    push 0x0f   # bits to set
    push 8      # bit to test
    call setbits

    push 0xf0
    push 4
    call setbits

    out 2, r100
    out 3, r100

    ld r100, 0

    push 0x0f
    push 2
    call setbits

    push 0xf0
    push 1
    call setbits

    out 0, r100
    out 1, r100

    jmp loop

setbits:
    ld x, sp
    ld r20, 1(x) # bit to test
    ld r19, 2(x) # bits to set

    and r20, r4
    jz end

    or r100, r19

end:
    ret 2
