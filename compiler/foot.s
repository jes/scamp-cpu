
# "halt"
ld x, 0
out 3, x

# take a pointer to a nul-terminated string, and print it
print:
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
printnum:
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

# multiply 2 numbers from stack and return result in r0
mul:
    pop x
    ld r2, x # r2 = arg1
    pop x
    ld r1, x # r1 = arg2
    ld r0, 0 # result
    ld r3, 1 # (1 << i)

    mul_loop:
        ld x, r2 # x = arg1
        and x, r3 # x = arg1 & (1 << i)
        jz mul_cont # skip the "add" if this bit is not set
        add r0, r1 # result += resultn
    mul_cont:
        shl r1 # resultn += resultn
        shl r3 # i++
        jnz mul_loop # loop again if the mask has not overflowed

    ret

# compute "i << n", return it in r0
shl:
    pop x
    ld r1, 15
    sub r1, x # r1 = 15 - n

    pop x
    ld r0, x # r0 = i

    # kind of "Duff's device" way to get a variable
    # number of left shifts
    jr+ r1

    shl r0
    shl r0
    shl r0
    shl r0
    shl r0
    shl r0
    shl r0
    shl r0
    shl r0
    shl r0
    shl r0
    shl r0
    shl r0
    shl r0
    shl r0

    ret

powers_of_2:
.word 0x0001
.word 0x0002
.word 0x0004
.word 0x0008
.word 0x0010
.word 0x0020
.word 0x0040
.word 0x0080
.word 0x0100
.word 0x0200
.word 0x0400
.word 0x0800
.word 0x1000
.word 0x2000
.word 0x4000
.word 0x8000
pwr2:
    pop x
    add x, powers_of_2
    ld r0, (x)
    ret

inp:
    pop x
    in r0, x
    ret

outp:
    pop x
    ld r0, x
    pop x
    out x, r0
    ret

_print: .word print
_printnum: .word printnum
_mul: .word mul
_shl: .word shl
_pwr2: .word pwr2
_powers_of_2: .word powers_of_2
_inp: .word inp
_outp: .word outp
_TOP: .word TOP

# leave a gap for the stack to live in
.gap STACKSZ
INITIAL_SP: .word 0

# top of program address
TOP:
