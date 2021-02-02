ld sp, 0xff80

loop:
    in r4, 0

    ld (0xffa0), 0

    push 0xffa0
    push 0x0f
    push 8
    call setbits

    push 0xffa0
    push 0xf0
    push 4
    call setbits

    not (0xffa0)
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

    not (0xffa0)
    out 0, (0xffa0)
    out 1, (0xffa0)

    jmp loop

setbits:
    #ld x, sp
    #ld r19, 2(x)
    #ld r18, 1(x)
    #ld r20, (x)

    pop x
    ld r20, x # bit to test
    pop x
    ld r19, x # bits to set
    pop x
    ld r18, x # address to write

    ld x, r4
    and x, r20
    jz end

    ld x, r19
    or (r18), x # set bits in address

end:
    ret 0
