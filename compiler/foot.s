
# "halt"
ld x, 0
out 3, x

# take a pointer to a nul-terminated string, and print it
fprint:
    pop x
    ld r0, x
    print_loop:
        out 2, (r0)
        inc r0
        test (r0)
        jnz print_loop
    ret

# print a number (in hex, with digits reversed...)
alphabet: .str "0123456789abcdef"
fprintnum:
    pop x
    ld r0, x

    # stash return address
    ld x, r254
    push x

    printnum_loop:
        # low nybble
        ld x, r0
        and x, 0x0f
        add x, alphabet
        ld x, (x)
        out 2, x

        # high nybble
        ld r1, 0
        ld x, r0
        and x, 0x10
        jz b2
        add r1, 1

        b2: ld x, r0
        and x, 0x20
        jz b3
        add r1, 2

        b3: ld x, r0
        and x, 0x40
        jz b4
        add r1, 4

        b4: ld x, r0
        and x, 0x80
        jz b5
        add r1, 8

        b5:
        ld x, r1
        add x, alphabet
        ld x, (x)
        out 2, x

        ld x, r0
        push x
        call shr8 # return goes to r0

        test r0
        jnz printnum_loop

    # return
    pop x
    jmp x

# >>8 1 arg from the stack and return the result in r0
shr8:
    pop x
    ld r0, x
    ld r1, r254 # stash return address
    ld r254, 0
    tbsz r0, 0x8000
    sb r254, 0x80
    tbsz r0, 0x4000
    sb r254, 0x40
    tbsz r0, 0x2000
    sb r254, 0x20
    tbsz r0, 0x1000
    sb r254, 0x10
    tbsz r0, 0x0800
    sb r254, 0x08
    tbsz r0, 0x0400
    sb r254, 0x04
    tbsz r0, 0x0200
    sb r254, 0x02
    tbsz r0, 0x0100
    sb r254, 0x01
    ld r0, r254
    jmp r1 # return

print: .word fprint
printnum: .word fprintnum
