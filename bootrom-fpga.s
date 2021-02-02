ld sp, 0xff80

loop:
    in r4, 0

    ld (0xffa0), 0

    push 0xffa0 # address to update
    push 0x0f   # bits to set
    push 8      # bit to test
    call setbits

    push 0xffa0
    push 0xf0
    push 4
    call setbits

    out 2, (0xffa0)
    out 3, (0xffa0)

    ld (0xffa0), 0

    push 0xffa0
    push 0x0f
    push 2
    call setbits

    push 0xffa0
    push 0xf0
    push 1
    call setbits

    out 0, (0xffa0)
    out 1, (0xffa0)

    jmp loop

setbits:
    ld x, sp
    ld r20, 1(x) # bit to test
    ld r19, 2(x) # bits to set
    ld r18, 3(x) # address to update

    and r20, r4
    jz end

    ld x, r19
    or (r18), x # set bits in address

end:
    ret 3
