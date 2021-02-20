
# "halt"
ld x, 0
out 3, x

# take a pointer to a nul-terminated string, and print it
puts:
    pop x
    print_loop:
        out 2, (x)
        inc x
        test (x)
        jnz print_loop
    ret

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

# compute:
#   *pdiv = num / denom
#   *pmod = num % denom
# Pass a null pointer if you want to discard one of the results
# https://en.wikipedia.org/wiki/Division_algorithm#Integer_division_(unsigned)_with_remainder
divmod:
    ld x, sp
    ld r7, 1(x) # r7 = pmod
    ld r8, 2(x) # r8 = pdiv
    ld r9, 3(x) # r9 = denom
    ld r10, 4(x) # r10 = num
    add sp, 4

    ld r4, 0 # r4 = Q
    ld r5, 0 # r5 = R
    ld r6, 15 # r6 = i

    # while (i >= 0) {
    divmod_loop:
        # R = R+R
        shl r5

        # r11 = powers_of_2[i]
        ld x, powers_of_2
        add x, r6
        ld r11, (x)

        # if (num & powers_of_2[i]) R++;
        ld r12, r10
        and r12, r11
        jz divmod_cont1
        inc r5
        divmod_cont1:

        # if (R >= denom) {
        ld r12, r5
        sub r12, r9 # r12 = R - denom
        jlt divmod_cont2
            # R = R - denom
            ld r5, r12
            # Q = Q | powers_of_2[i]
            or r4, r11
        # }
        divmod_cont2:

        # i--
        dec r6
        jge divmod_loop
    # }

    # if pdiv or pmod are null, they'll point to rom, so writing to them is a no-op
    # *pdiv = Q
    ld x, r8
    ld (x), r4
    # *pmod = R
    ld x, r7
    ld (x), r5
    # return
    ret

# return a value:
#  <0  if s1 < s2
#   0  if s1 == s2
#  >0  if s1 > s2
strcmp:
    pop x
    ld r2, x # r2 = s2
    pop x
    ld r1, x # r1 = s1

    # while (*s1 && *s2)
    strcmp_loop:
        ld x, (r1)
        and x, (r2)
        jz strcmp_done

        # if (*s1 != *s2) return *s1-*s2
        ld x, (r1)
        sub x, (r2)
        jz strcmp_cont
        ld r0, x
        ret

        strcmp_cont:
        inc r1
        inc r2
        jmp strcmp_loop
    strcmp_done:

    # return *s1-*s2
    ld x, (r1)
    sub x, (r2)
    ld r0, x
    ret

_puts: .word puts
_mul: .word mul
_shl: .word shl
_pwr2: .word pwr2
_powers_of_2: .word powers_of_2
_inp: .word inp
_outp: .word outp
_divmod: .word divmod
_strcmp: .word strcmp
_TOP: .word TOP

# leave a gap for the stack to live in
.gap STACKSZ
INITIAL_SP: .word 0

# top of program address
TOP:
