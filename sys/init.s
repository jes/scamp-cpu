#sym:mul
jmp l__1
l__2:
#peepopt:off
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

#peepopt:on
l__1:
ld x, l__2
push x
#nosym
# poptovar: global mul
pop x
ld (_mul), x
#sym:powers_of_2
jmp l__3
l__4:
#peepopt:off
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

#peepopt:on
l__3:
ld x, l__4
push x
#nosym
# poptovar: global powers_of_2
pop x
ld (_powers_of_2), x
#sym:divmod
jmp l__5
l__6:
#peepopt:off
ld x, sp
    ld r7, 1(x) # r7 = pmod
    ld r8, 2(x) # r8 = pdiv
    ld r9, 3(x) # r9 = denom
    ld r10, 4(x) # r10 = num
    add sp, 4

    ld r4, 0 # r4 = Q
    ld r5, 0 # r5 = R
    ld r6, 15 # r6 = i

    # while (i >= 0)
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

        # if (R >= denom)
        ld r12, r5
        sub r12, r9 # r12 = R - denom
        jlt divmod_cont2
            # R = R - denom
            ld r5, r12
            # Q = Q | powers_of_2[i]
            or r4, r11
        divmod_cont2:

        # i--
        dec r6
        jge divmod_loop

    # if pdiv or pmod are null, they'll point to rom, so writing to them is a no-op
    # *pdiv = Q
    ld x, r8
    ld (x), r4
    # *pmod = R
    ld x, r7
    ld (x), r5
    # return
    ret

#peepopt:on
l__5:
ld x, l__6
push x
#nosym
# poptovar: global divmod
pop x
ld (_divmod), x
#sym:shr8
jmp l__7
l__8:
#peepopt:off
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

#peepopt:on
l__7:
ld x, l__8
push x
#nosym
# poptovar: global shr8
pop x
ld (_shr8), x
#sym:shl
jmp l__9
l__10:
#peepopt:off
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

#peepopt:on
l__9:
ld x, l__10
push x
#nosym
# poptovar: global shl
pop x
ld (_shl), x
#sym:itoa_alphabet
ld x, l__11
push x
#nosym
# poptovar: global itoa_alphabet
pop x
ld (_itoa_alphabet), x
#sym:itoa_space
ld x, l__12
push x
#nosym
# poptovar: global itoa_space
pop x
ld (_itoa_space), x
#sym:itoabase

# parseFunctionDeclaration:
jmp l__14
l__13:
# allocate space for s
dec sp
# pushvar: global itoa_space
ld x, (_itoa_space)
push x
# genliteral:
push 16
# operator: +
pop x
ld r0, x
pop x
add x, r0
push x
# poptovar: local s
ld r252, sp
add r252, 2
pop x
ld (r252), x
# allocate space for d
dec sp
# allocate space for m
dec sp
# pushvar: local s
ld x, 3(sp)
push x
# genliteral:
push 0
# store to pointer:
pop x
ld r0, x
pop x
ld (x), r0
# if condition
# pushvar: local num
ld x, 5(sp)
push x
# genliteral:
push 0
# operator: ==
pop x
ld r0, x
pop x
sub x, r0 #peepopt:test
ld x, 0
jnz l__15
ld x, 1
l__15:
push x
pop x
test x
jz l__16
# if body
# pre-dec
# pushvar: local s
ld x, 3(sp)
push x
pop x
dec x
push x
# poptovar: local s
ld r252, sp
add r252, 4
pop x
ld (r252), x
push x
# genliteral:
push 48
# store to pointer:
pop x
ld r0, x
pop x
ld (x), r0
# pushvar: local s
ld x, 3(sp)
push x
# return
pop x
ld r0, x
# function had 2 parameters and 3 locals:
ret 5
l__16:
# while loop
l__17:
# pushvar: local num
ld x, 5(sp)
push x
# genliteral:
push 0
# operator: !=
pop x
ld r0, x
pop x
sub x, r0 #peepopt:test
jz l__19
ld x, 1
l__19:
push x
pop x
test x
jz l__18
# parseFunctionCall:
ld x, r254
push x
# pushvar: local num
ld x, 6(sp)
push x
# pushvar: local base
ld x, 6(sp)
push x
# &d (local)
ld x, sp
add x, 5
push x
# &m (local)
ld x, sp
add x, 5
push x
# pushvar: global divmod
ld x, (_divmod)
push x
pop x
call x
pop x
ld r254, x
ld x, r0
push x
# discard expression value
pop x
# pre-dec
# pushvar: local s
ld x, 3(sp)
push x
pop x
dec x
push x
# poptovar: local s
ld r252, sp
add r252, 4
pop x
ld (r252), x
push x
# pushvar: global itoa_alphabet
ld x, (_itoa_alphabet)
push x
# pushvar: local m
ld x, 3(sp)
push x
# operator: +
pop x
ld r0, x
pop x
add x, r0
push x
# unary *
pop x
# pointer dereference:
ld x, (x)
push x
# store to pointer:
pop x
ld r0, x
pop x
ld (x), r0
# pushvar: local d
ld x, 2(sp)
push x
# poptovar: local num
ld r252, sp
add r252, 6
pop x
ld (r252), x
jmp l__17
l__18:
# pushvar: local s
ld x, 3(sp)
push x
# return
pop x
ld r0, x
# function had 2 parameters and 3 locals:
ret 5
# function had 2 parameters and 3 locals:
ret 5
# end function declaration

l__14:
ld x, l__13
push x
#nosym
# poptovar: global itoabase
pop x
ld (_itoabase), x
#sym:itoa

# parseFunctionDeclaration:
jmp l__21
l__20:
# parseFunctionCall:
ld x, r254
push x
# pushvar: local num
ld x, 2(sp)
push x
# genliteral:
push 10
# pushvar: global itoabase
ld x, (_itoabase)
push x
pop x
call x
pop x
ld r254, x
ld x, r0
push x
# return
pop x
ld r0, x
# function had 1 parameters and 0 locals:
ret 1
# function had 1 parameters and 0 locals:
ret 1
# end function declaration

l__21:
ld x, l__20
push x
#nosym
# poptovar: global itoa
pop x
ld (_itoa), x
#sym:islower

# parseFunctionDeclaration:
jmp l__23
l__22:
# pushvar: local ch
ld x, 1(sp)
push x
# genliteral:
push 97
# operator: >=
pop x
ld r0, x
pop x
ld r1, r0
ld r2, x
ld r3, x
and r1, 32768 #peepopt:test
and r2, 32768 #peepopt:test
sub r1, r2 #peepopt:test
ld x, r3
jz l__25
test r2
ld x, 0
jnz l__24
ld x, 1
jmp l__24
l__25:
sub x, r0 #peepopt:test
ld x, 0
jlt l__24
ld x, 1
l__24:
push x
# pushvar: local ch
ld x, 2(sp)
push x
# genliteral:
push 122
# operator: <=
pop x
ld r0, x
pop x
ld r1, r0
ld r2, x
ld r3, x
and r1, 32768 #peepopt:test
and r2, 32768 #peepopt:test
sub r1, r2 #peepopt:test
ld x, r3
jz l__27
test r2
ld x, 1
jnz l__26
ld x, 0
jmp l__26
l__27:
sub r0, x #peepopt:test
ld x, 0
jlt l__26
ld x, 1
l__26:
push x
# operator: &&
pop x
ld r0, x
pop x
test x
ld x, 0
jz l__28
test r0
jz l__28
ld x, 1
l__28:
push x
# return
pop x
ld r0, x
# function had 1 parameters and 0 locals:
ret 1
# function had 1 parameters and 0 locals:
ret 1
# end function declaration

l__23:
ld x, l__22
push x
#nosym
# poptovar: global islower
pop x
ld (_islower), x
#sym:isupper

# parseFunctionDeclaration:
jmp l__30
l__29:
# pushvar: local ch
ld x, 1(sp)
push x
# genliteral:
push 65
# operator: >=
pop x
ld r0, x
pop x
ld r1, r0
ld r2, x
ld r3, x
and r1, 32768 #peepopt:test
and r2, 32768 #peepopt:test
sub r1, r2 #peepopt:test
ld x, r3
jz l__32
test r2
ld x, 0
jnz l__31
ld x, 1
jmp l__31
l__32:
sub x, r0 #peepopt:test
ld x, 0
jlt l__31
ld x, 1
l__31:
push x
# pushvar: local ch
ld x, 2(sp)
push x
# genliteral:
push 90
# operator: <=
pop x
ld r0, x
pop x
ld r1, r0
ld r2, x
ld r3, x
and r1, 32768 #peepopt:test
and r2, 32768 #peepopt:test
sub r1, r2 #peepopt:test
ld x, r3
jz l__34
test r2
ld x, 1
jnz l__33
ld x, 0
jmp l__33
l__34:
sub r0, x #peepopt:test
ld x, 0
jlt l__33
ld x, 1
l__33:
push x
# operator: &&
pop x
ld r0, x
pop x
test x
ld x, 0
jz l__35
test r0
jz l__35
ld x, 1
l__35:
push x
# return
pop x
ld r0, x
# function had 1 parameters and 0 locals:
ret 1
# function had 1 parameters and 0 locals:
ret 1
# end function declaration

l__30:
ld x, l__29
push x
#nosym
# poptovar: global isupper
pop x
ld (_isupper), x
#sym:isalpha

# parseFunctionDeclaration:
jmp l__37
l__36:
# parseFunctionCall:
ld x, r254
push x
# pushvar: local ch
ld x, 2(sp)
push x
# pushvar: global islower
ld x, (_islower)
push x
pop x
call x
pop x
ld r254, x
ld x, r0
push x
# parseFunctionCall:
ld x, r254
push x
# pushvar: local ch
ld x, 3(sp)
push x
# pushvar: global isupper
ld x, (_isupper)
push x
pop x
call x
pop x
ld r254, x
ld x, r0
push x
# operator: ||
pop x
ld r0, x
pop x
test x
ld x, 1
jnz l__38
test r0
jnz l__38
ld x, 0
l__38:
push x
# return
pop x
ld r0, x
# function had 1 parameters and 0 locals:
ret 1
# function had 1 parameters and 0 locals:
ret 1
# end function declaration

l__37:
ld x, l__36
push x
#nosym
# poptovar: global isalpha
pop x
ld (_isalpha), x
#sym:isdigit

# parseFunctionDeclaration:
jmp l__40
l__39:
# pushvar: local ch
ld x, 1(sp)
push x
# genliteral:
push 48
# operator: >=
pop x
ld r0, x
pop x
ld r1, r0
ld r2, x
ld r3, x
and r1, 32768 #peepopt:test
and r2, 32768 #peepopt:test
sub r1, r2 #peepopt:test
ld x, r3
jz l__42
test r2
ld x, 0
jnz l__41
ld x, 1
jmp l__41
l__42:
sub x, r0 #peepopt:test
ld x, 0
jlt l__41
ld x, 1
l__41:
push x
# pushvar: local ch
ld x, 2(sp)
push x
# genliteral:
push 57
# operator: <=
pop x
ld r0, x
pop x
ld r1, r0
ld r2, x
ld r3, x
and r1, 32768 #peepopt:test
and r2, 32768 #peepopt:test
sub r1, r2 #peepopt:test
ld x, r3
jz l__44
test r2
ld x, 1
jnz l__43
ld x, 0
jmp l__43
l__44:
sub r0, x #peepopt:test
ld x, 0
jlt l__43
ld x, 1
l__43:
push x
# operator: &&
pop x
ld r0, x
pop x
test x
ld x, 0
jz l__45
test r0
jz l__45
ld x, 1
l__45:
push x
# return
pop x
ld r0, x
# function had 1 parameters and 0 locals:
ret 1
# function had 1 parameters and 0 locals:
ret 1
# end function declaration

l__40:
ld x, l__39
push x
#nosym
# poptovar: global isdigit
pop x
ld (_isdigit), x
#sym:isalnum

# parseFunctionDeclaration:
jmp l__47
l__46:
# parseFunctionCall:
ld x, r254
push x
# pushvar: local ch
ld x, 2(sp)
push x
# pushvar: global isalpha
ld x, (_isalpha)
push x
pop x
call x
pop x
ld r254, x
ld x, r0
push x
# parseFunctionCall:
ld x, r254
push x
# pushvar: local ch
ld x, 3(sp)
push x
# pushvar: global isdigit
ld x, (_isdigit)
push x
pop x
call x
pop x
ld r254, x
ld x, r0
push x
# operator: ||
pop x
ld r0, x
pop x
test x
ld x, 1
jnz l__48
test r0
jnz l__48
ld x, 0
l__48:
push x
# return
pop x
ld r0, x
# function had 1 parameters and 0 locals:
ret 1
# function had 1 parameters and 0 locals:
ret 1
# end function declaration

l__47:
ld x, l__46
push x
#nosym
# poptovar: global isalnum
pop x
ld (_isalnum), x
#sym:tolower

# parseFunctionDeclaration:
jmp l__50
l__49:
# if condition
# parseFunctionCall:
ld x, r254
push x
# pushvar: local ch
ld x, 2(sp)
push x
# pushvar: global isupper
ld x, (_isupper)
push x
pop x
call x
pop x
ld r254, x
ld x, r0
push x
pop x
test x
jz l__51
# if body
# pushvar: local ch
ld x, 1(sp)
push x
# genliteral:
push 65
# operator: -
pop x
ld r0, x
pop x
sub x, r0
push x
# genliteral:
push 97
# operator: +
pop x
ld r0, x
pop x
add x, r0
push x
# return
pop x
ld r0, x
# function had 1 parameters and 0 locals:
ret 1
l__51:
# pushvar: local ch
ld x, 1(sp)
push x
# return
pop x
ld r0, x
# function had 1 parameters and 0 locals:
ret 1
# function had 1 parameters and 0 locals:
ret 1
# end function declaration

l__50:
ld x, l__49
push x
#nosym
# poptovar: global tolower
pop x
ld (_tolower), x
#sym:stridx

# parseFunctionDeclaration:
jmp l__53
l__52:
# allocate space for i
dec sp
# genliteral:
push 0
# poptovar: local i
ld r252, sp
add r252, 2
pop x
ld (r252), x
# while loop
l__54:
# pushvar: local alphabet
ld x, 3(sp)
push x
# pushvar: local i
ld x, 2(sp)
push x
# operator: +
pop x
ld r0, x
pop x
add x, r0
push x
# unary *
pop x
# pointer dereference:
ld x, (x)
push x
pop x
test x
jz l__55
# if condition
# pushvar: local alphabet
ld x, 3(sp)
push x
# pushvar: local i
ld x, 2(sp)
push x
# operator: +
pop x
ld r0, x
pop x
add x, r0
push x
# unary *
pop x
# pointer dereference:
ld x, (x)
push x
# pushvar: local ch
ld x, 3(sp)
push x
# operator: ==
pop x
ld r0, x
pop x
sub x, r0 #peepopt:test
ld x, 0
jnz l__56
ld x, 1
l__56:
push x
pop x
test x
jz l__57
# if body
# pushvar: local i
ld x, 1(sp)
push x
# return
pop x
ld r0, x
# function had 2 parameters and 1 locals:
ret 3
l__57:
# post-inc
# pushvar: local i
ld x, 1(sp)
push x
pop x
push x
inc x
push x
# poptovar: local i
ld r252, sp
add r252, 3
pop x
ld (r252), x
# discard expression value
pop x
jmp l__54
l__55:
# genliteral:
push 0
# return
pop x
ld r0, x
# function had 2 parameters and 1 locals:
ret 3
# function had 2 parameters and 1 locals:
ret 3
# end function declaration

l__53:
ld x, l__52
push x
#nosym
# poptovar: global stridx
pop x
ld (_stridx), x
#sym:atoibase

# parseFunctionDeclaration:
jmp l__59
l__58:
# allocate space for v
dec sp
# genliteral:
push 0
# poptovar: local v
ld r252, sp
add r252, 2
pop x
ld (r252), x
# while loop
l__60:
# pushvar: local s
ld x, 3(sp)
push x
# unary *
pop x
# pointer dereference:
ld x, (x)
push x
pop x
test x
jz l__61
# parseFunctionCall:
ld x, r254
push x
# pushvar: local v
ld x, 2(sp)
push x
# pushvar: local base
ld x, 4(sp)
push x
# pushvar: global mul
ld x, (_mul)
push x
pop x
call x
pop x
ld r254, x
ld x, r0
push x
# parseFunctionCall:
ld x, r254
push x
# pushvar: global itoa_alphabet
ld x, (_itoa_alphabet)
push x
# parseFunctionCall:
ld x, r254
push x
# pushvar: local s
ld x, 7(sp)
push x
# unary *
pop x
# pointer dereference:
ld x, (x)
push x
# pushvar: global tolower
ld x, (_tolower)
push x
pop x
call x
pop x
ld r254, x
ld x, r0
push x
# pushvar: global stridx
ld x, (_stridx)
push x
pop x
call x
pop x
ld r254, x
ld x, r0
push x
# operator: +
pop x
ld r0, x
pop x
add x, r0
push x
# poptovar: local v
ld r252, sp
add r252, 2
pop x
ld (r252), x
# post-inc
# pushvar: local s
ld x, 3(sp)
push x
pop x
push x
inc x
push x
# poptovar: local s
ld r252, sp
add r252, 5
pop x
ld (r252), x
# discard expression value
pop x
jmp l__60
l__61:
# pushvar: local v
ld x, 1(sp)
push x
# return
pop x
ld r0, x
# function had 2 parameters and 1 locals:
ret 3
# function had 2 parameters and 1 locals:
ret 3
# end function declaration

l__59:
ld x, l__58
push x
#nosym
# poptovar: global atoibase
pop x
ld (_atoibase), x
#sym:atoi

# parseFunctionDeclaration:
jmp l__63
l__62:
# parseFunctionCall:
ld x, r254
push x
# pushvar: local s
ld x, 2(sp)
push x
# genliteral:
push 10
# pushvar: global atoibase
ld x, (_atoibase)
push x
pop x
call x
pop x
ld r254, x
ld x, r0
push x
# return
pop x
ld r0, x
# function had 1 parameters and 0 locals:
ret 1
# function had 1 parameters and 0 locals:
ret 1
# end function declaration

l__63:
ld x, l__62
push x
#nosym
# poptovar: global atoi
pop x
ld (_atoi), x
#sym:inp
jmp l__64
l__65:
#peepopt:off
pop x
    in r0, x
    ret

#peepopt:on
l__64:
ld x, l__65
push x
#nosym
# poptovar: global inp
pop x
ld (_inp), x
#sym:outp
jmp l__66
l__67:
#peepopt:off
pop x
    ld r0, x
    pop x
    out x, r0
    ret

#peepopt:on
l__66:
ld x, l__67
push x
#nosym
# poptovar: global outp
pop x
ld (_outp), x
#sym:car

# parseFunctionDeclaration:
jmp l__69
l__68:
# pushvar: local tuple
ld x, 1(sp)
push x
# unary *
pop x
# pointer dereference:
ld x, (x)
push x
# return
pop x
ld r0, x
# function had 1 parameters and 0 locals:
ret 1
# function had 1 parameters and 0 locals:
ret 1
# end function declaration

l__69:
ld x, l__68
push x
#nosym
# poptovar: global car
pop x
ld (_car), x
#sym:cdr

# parseFunctionDeclaration:
jmp l__71
l__70:
# pushvar: local tuple
ld x, 1(sp)
push x
# genliteral:
push 1
# operator: +
pop x
ld r0, x
pop x
add x, r0
push x
# unary *
pop x
# pointer dereference:
ld x, (x)
push x
# return
pop x
ld r0, x
# function had 1 parameters and 0 locals:
ret 1
# function had 1 parameters and 0 locals:
ret 1
# end function declaration

l__71:
ld x, l__70
push x
#nosym
# poptovar: global cdr
pop x
ld (_cdr), x
#sym:setcar

# parseFunctionDeclaration:
jmp l__73
l__72:
# pushvar: local tuple
ld x, 2(sp)
push x
# pushvar: local a
ld x, 2(sp)
push x
# store to pointer:
pop x
ld r0, x
pop x
ld (x), r0
# function had 2 parameters and 0 locals:
ret 2
# end function declaration

l__73:
ld x, l__72
push x
#nosym
# poptovar: global setcar
pop x
ld (_setcar), x
#sym:setcdr

# parseFunctionDeclaration:
jmp l__75
l__74:
# pushvar: local tuple
ld x, 2(sp)
push x
# genliteral:
push 1
# operator: +
pop x
ld r0, x
pop x
add x, r0
push x
# pushvar: local b
ld x, 2(sp)
push x
# store to pointer:
pop x
ld r0, x
pop x
ld (x), r0
# function had 2 parameters and 0 locals:
ret 2
# end function declaration

l__75:
ld x, l__74
push x
#nosym
# poptovar: global setcdr
pop x
ld (_setcdr), x
#sym:cmdargs
# pushvar: global sys_cmdargs
ld x, (_sys_cmdargs)
push x
#nosym
# poptovar: global cmdargs
pop x
ld (_cmdargs), x
#sym:osbase
# pushvar: global sys_osbase
ld x, (_sys_osbase)
push x
#nosym
# poptovar: global osbase
pop x
ld (_osbase), x
#sym:copyfd
# pushvar: global sys_copyfd
ld x, (_sys_copyfd)
push x
#nosym
# poptovar: global copyfd
pop x
ld (_copyfd), x
#sym:unlink
# pushvar: global sys_unlink
ld x, (_sys_unlink)
push x
#nosym
# poptovar: global unlink
pop x
ld (_unlink), x
#sym:stat
# pushvar: global sys_stat
ld x, (_sys_stat)
push x
#nosym
# poptovar: global stat
pop x
ld (_stat), x
#sym:readdir
# pushvar: global sys_readdir
ld x, (_sys_readdir)
push x
#nosym
# poptovar: global readdir
pop x
ld (_readdir), x
#sym:mkdir
# pushvar: global sys_mkdir
ld x, (_sys_mkdir)
push x
#nosym
# poptovar: global mkdir
pop x
ld (_mkdir), x
#sym:chdir
# pushvar: global sys_chdir
ld x, (_sys_chdir)
push x
#nosym
# poptovar: global chdir
pop x
ld (_chdir), x
#sym:tell
# pushvar: global sys_tell
ld x, (_sys_tell)
push x
#nosym
# poptovar: global tell
pop x
ld (_tell), x
#sym:seek
# pushvar: global sys_seek
ld x, (_sys_seek)
push x
#nosym
# poptovar: global seek
pop x
ld (_seek), x
#sym:close
# pushvar: global sys_close
ld x, (_sys_close)
push x
#nosym
# poptovar: global close
pop x
ld (_close), x
#sym:open
# pushvar: global sys_open
ld x, (_sys_open)
push x
#nosym
# poptovar: global open
pop x
ld (_open), x
#sym:read
# pushvar: global sys_read
ld x, (_sys_read)
push x
#nosym
# poptovar: global read
pop x
ld (_read), x
#sym:write
# pushvar: global sys_write
ld x, (_sys_write)
push x
#nosym
# poptovar: global write
pop x
ld (_write), x
#sym:system
# pushvar: global sys_system
ld x, (_sys_system)
push x
#nosym
# poptovar: global system
pop x
ld (_system), x
#sym:exec
# pushvar: global sys_exec
ld x, (_sys_exec)
push x
#nosym
# poptovar: global exec
pop x
ld (_exec), x
#sym:exit
# pushvar: global sys_exit
ld x, (_sys_exit)
push x
#nosym
# poptovar: global exit
pop x
ld (_exit), x
#sym:EOF
# genliteral:
push 65535
#nosym
# poptovar: global EOF
pop x
ld (_EOF), x
#sym:getchar

# parseFunctionDeclaration:
jmp l__77
l__76:
# allocate space for ch
dec sp
# if condition
# parseFunctionCall:
ld x, r254
push x
# genliteral:
push 0
# &ch (local)
ld x, sp
add x, 3
push x
# genliteral:
push 1
# pushvar: global read
ld x, (_read)
push x
pop x
call x
pop x
ld r254, x
ld x, r0
push x
# genliteral:
push 0
# operator: ==
pop x
ld r0, x
pop x
sub x, r0 #peepopt:test
ld x, 0
jnz l__78
ld x, 1
l__78:
push x
pop x
test x
jz l__79
# if body
# pushvar: global EOF
ld x, (_EOF)
push x
# return
pop x
ld r0, x
# function had 0 parameters and 1 locals:
ret 1
l__79:
# pushvar: local ch
ld x, 1(sp)
push x
# return
pop x
ld r0, x
# function had 0 parameters and 1 locals:
ret 1
# function had 0 parameters and 1 locals:
ret 1
# end function declaration

l__77:
ld x, l__76
push x
#nosym
# poptovar: global getchar
pop x
ld (_getchar), x
#sym:putchar

# parseFunctionDeclaration:
jmp l__81
l__80:
# allocate space for chs
dec sp
# pushvar: local ch
ld x, 2(sp)
push x
ld r0, l__82
add r0, 0
pop x
ld (r0), x
# genliteral:
push 0
ld r0, l__82
add r0, 1
pop x
ld (r0), x
ld x, l__82
push x
# poptovar: local chs
ld r252, sp
add r252, 2
pop x
ld (r252), x
# parseFunctionCall:
ld x, r254
push x
# genliteral:
push 1
# &chs (local)
ld x, sp
add x, 3
push x
# genliteral:
push 1
# pushvar: global write
ld x, (_write)
push x
pop x
call x
pop x
ld r254, x
ld x, r0
push x
# return
pop x
ld r0, x
# function had 1 parameters and 1 locals:
ret 2
# function had 1 parameters and 1 locals:
ret 2
# end function declaration

l__81:
ld x, l__80
push x
#nosym
# poptovar: global putchar
pop x
ld (_putchar), x
#sym:gets

# parseFunctionDeclaration:
jmp l__84
l__83:
# allocate space for ch
dec sp
# genliteral:
push 0
# poptovar: local ch
ld r252, sp
add r252, 2
pop x
ld (r252), x
# allocate space for len
dec sp
# genliteral:
push 0
# poptovar: local len
ld r252, sp
add r252, 2
pop x
ld (r252), x
# while loop
l__85:
# pushvar: local ch
ld x, 2(sp)
push x
# pushvar: global EOF
ld x, (_EOF)
push x
# operator: !=
pop x
ld r0, x
pop x
sub x, r0 #peepopt:test
jz l__87
ld x, 1
l__87:
push x
# pushvar: local ch
ld x, 3(sp)
push x
# genliteral:
push 10
# operator: !=
pop x
ld r0, x
pop x
sub x, r0 #peepopt:test
jz l__88
ld x, 1
l__88:
push x
# operator: &&
pop x
ld r0, x
pop x
test x
ld x, 0
jz l__89
test r0
jz l__89
ld x, 1
l__89:
push x
# pushvar: local len
ld x, 2(sp)
push x
# pushvar: local size
ld x, 5(sp)
push x
# operator: <
pop x
ld r0, x
pop x
ld r1, r0
ld r2, x
ld r3, x
and r1, 32768 #peepopt:test
and r2, 32768 #peepopt:test
sub r1, r2 #peepopt:test
ld x, r3
jz l__91
test r2
ld x, 1
jnz l__90
ld x, 0
jmp l__90
l__91:
sub x, r0 #peepopt:test
ld x, 1
jlt l__90
ld x, 0
l__90:
push x
# operator: &&
pop x
ld r0, x
pop x
test x
ld x, 0
jz l__92
test r0
jz l__92
ld x, 1
l__92:
push x
pop x
test x
jz l__86
# parseFunctionCall:
ld x, r254
push x
# pushvar: global getchar
ld x, (_getchar)
push x
pop x
call x
pop x
ld r254, x
ld x, r0
push x
# poptovar: local ch
ld r252, sp
add r252, 3
pop x
ld (r252), x
# if condition
# pushvar: local ch
ld x, 2(sp)
push x
# pushvar: global EOF
ld x, (_EOF)
push x
# operator: !=
pop x
ld r0, x
pop x
sub x, r0 #peepopt:test
jz l__93
ld x, 1
l__93:
push x
pop x
test x
jz l__94
# if body
# pushvar: local s
ld x, 4(sp)
push x
# post-inc
# pushvar: local len
ld x, 2(sp)
push x
pop x
push x
inc x
push x
# poptovar: local len
ld r252, sp
add r252, 4
pop x
ld (r252), x
# operator: +
pop x
ld r0, x
pop x
add x, r0
push x
# pushvar: local ch
ld x, 3(sp)
push x
# store to pointer:
pop x
ld r0, x
pop x
ld (x), r0
l__94:
jmp l__85
l__86:
# if condition
# pushvar: local ch
ld x, 2(sp)
push x
# pushvar: global EOF
ld x, (_EOF)
push x
# operator: ==
pop x
ld r0, x
pop x
sub x, r0 #peepopt:test
ld x, 0
jnz l__95
ld x, 1
l__95:
push x
# pushvar: local len
ld x, 2(sp)
push x
# genliteral:
push 0
# operator: ==
pop x
ld r0, x
pop x
sub x, r0 #peepopt:test
ld x, 0
jnz l__96
ld x, 1
l__96:
push x
# operator: &&
pop x
ld r0, x
pop x
test x
ld x, 0
jz l__97
test r0
jz l__97
ld x, 1
l__97:
push x
pop x
test x
jz l__98
# if body
# genliteral:
push 0
# return
pop x
ld r0, x
# function had 2 parameters and 2 locals:
ret 4
l__98:
# pushvar: local s
ld x, 4(sp)
push x
# pushvar: local len
ld x, 2(sp)
push x
# operator: +
pop x
ld r0, x
pop x
add x, r0
push x
# genliteral:
push 0
# store to pointer:
pop x
ld r0, x
pop x
ld (x), r0
# pushvar: local s
ld x, 4(sp)
push x
# return
pop x
ld r0, x
# function had 2 parameters and 2 locals:
ret 4
# function had 2 parameters and 2 locals:
ret 4
# end function declaration

l__84:
ld x, l__83
push x
#nosym
# poptovar: global gets
pop x
ld (_gets), x
#sym:puts

# parseFunctionDeclaration:
jmp l__100
l__99:
# allocate space for ss
dec sp
# pushvar: local s
ld x, 2(sp)
push x
# poptovar: local ss
ld r252, sp
add r252, 2
pop x
ld (r252), x
# allocate space for len
dec sp
# genliteral:
push 0
# poptovar: local len
ld r252, sp
add r252, 2
pop x
ld (r252), x
# while loop
l__101:
# post-inc
# pushvar: local ss
ld x, 2(sp)
push x
pop x
push x
inc x
push x
# poptovar: local ss
ld r252, sp
add r252, 4
pop x
ld (r252), x
# unary *
pop x
# pointer dereference:
ld x, (x)
push x
pop x
test x
jz l__102
# post-inc
# pushvar: local len
ld x, 1(sp)
push x
pop x
push x
inc x
push x
# poptovar: local len
ld r252, sp
add r252, 3
pop x
ld (r252), x
# discard expression value
pop x
jmp l__101
l__102:
# parseFunctionCall:
ld x, r254
push x
# genliteral:
push 1
# pushvar: local s
ld x, 5(sp)
push x
# pushvar: local len
ld x, 4(sp)
push x
# pushvar: global write
ld x, (_write)
push x
pop x
call x
pop x
ld r254, x
ld x, r0
push x
# discard expression value
pop x
# function had 1 parameters and 2 locals:
ret 3
# end function declaration

l__100:
ld x, l__99
push x
#nosym
# poptovar: global puts
pop x
ld (_puts), x
#sym:printf

# parseFunctionDeclaration:
jmp l__104
l__103:
# allocate space for p
dec sp
# pushvar: local fmt
ld x, 3(sp)
push x
# poptovar: local p
ld r252, sp
add r252, 2
pop x
ld (r252), x
# allocate space for argidx
dec sp
# genliteral:
push 0
# poptovar: local argidx
ld r252, sp
add r252, 2
pop x
ld (r252), x
# while loop
l__105:
# pushvar: local p
ld x, 2(sp)
push x
# unary *
pop x
# pointer dereference:
ld x, (x)
push x
pop x
test x
jz l__106
# if condition
# pushvar: local p
ld x, 2(sp)
push x
# unary *
pop x
# pointer dereference:
ld x, (x)
push x
# genliteral:
push 37
# operator: ==
pop x
ld r0, x
pop x
sub x, r0 #peepopt:test
ld x, 0
jnz l__107
ld x, 1
l__107:
push x
pop x
test x
jz l__108
# if body
# post-inc
# pushvar: local p
ld x, 2(sp)
push x
pop x
push x
inc x
push x
# poptovar: local p
ld r252, sp
add r252, 4
pop x
ld (r252), x
# discard expression value
pop x
# if condition
# pushvar: local p
ld x, 2(sp)
push x
# unary *
pop x
# pointer dereference:
ld x, (x)
push x
# unary !
pop x
test x
ld x, 0
jnz l__109
ld x, 1
l__109:
push x
pop x
test x
jz l__110
# if body
# genliteral:
push 0
# return
pop x
ld r0, x
# function had 2 parameters and 2 locals:
ret 4
l__110:
# if condition
# pushvar: local p
ld x, 2(sp)
push x
# unary *
pop x
# pointer dereference:
ld x, (x)
push x
# genliteral:
push 37
# operator: ==
pop x
ld r0, x
pop x
sub x, r0 #peepopt:test
ld x, 0
jnz l__111
ld x, 1
l__111:
push x
pop x
test x
jz l__112
# if body
# parseFunctionCall:
ld x, r254
push x
# genliteral:
push 37
# pushvar: global putchar
ld x, (_putchar)
push x
pop x
call x
pop x
ld r254, x
ld x, r0
push x
# discard expression value
pop x
jmp l__113
# else body
l__112:
# if condition
# pushvar: local p
ld x, 2(sp)
push x
# unary *
pop x
# pointer dereference:
ld x, (x)
push x
# genliteral:
push 99
# operator: ==
pop x
ld r0, x
pop x
sub x, r0 #peepopt:test
ld x, 0
jnz l__114
ld x, 1
l__114:
push x
pop x
test x
jz l__115
# if body
# parseFunctionCall:
ld x, r254
push x
# pushvar: local args
ld x, 4(sp)
push x
# post-inc
# pushvar: local argidx
ld x, 3(sp)
push x
pop x
push x
inc x
push x
# poptovar: local argidx
ld r252, sp
add r252, 5
pop x
ld (r252), x
pop x
ld r0, x
pop x
add x, r0
ld x, (x)
push x
# pushvar: global putchar
ld x, (_putchar)
push x
pop x
call x
pop x
ld r254, x
ld x, r0
push x
# discard expression value
pop x
jmp l__116
# else body
l__115:
# if condition
# pushvar: local p
ld x, 2(sp)
push x
# unary *
pop x
# pointer dereference:
ld x, (x)
push x
# genliteral:
push 115
# operator: ==
pop x
ld r0, x
pop x
sub x, r0 #peepopt:test
ld x, 0
jnz l__117
ld x, 1
l__117:
push x
pop x
test x
jz l__118
# if body
# parseFunctionCall:
ld x, r254
push x
# pushvar: local args
ld x, 4(sp)
push x
# post-inc
# pushvar: local argidx
ld x, 3(sp)
push x
pop x
push x
inc x
push x
# poptovar: local argidx
ld r252, sp
add r252, 5
pop x
ld (r252), x
pop x
ld r0, x
pop x
add x, r0
ld x, (x)
push x
# pushvar: global puts
ld x, (_puts)
push x
pop x
call x
pop x
ld r254, x
ld x, r0
push x
# discard expression value
pop x
jmp l__119
# else body
l__118:
# if condition
# pushvar: local p
ld x, 2(sp)
push x
# unary *
pop x
# pointer dereference:
ld x, (x)
push x
# genliteral:
push 100
# operator: ==
pop x
ld r0, x
pop x
sub x, r0 #peepopt:test
ld x, 0
jnz l__120
ld x, 1
l__120:
push x
pop x
test x
jz l__121
# if body
# parseFunctionCall:
ld x, r254
push x
# parseFunctionCall:
ld x, r254
push x
# pushvar: local args
ld x, 5(sp)
push x
# post-inc
# pushvar: local argidx
ld x, 4(sp)
push x
pop x
push x
inc x
push x
# poptovar: local argidx
ld r252, sp
add r252, 6
pop x
ld (r252), x
pop x
ld r0, x
pop x
add x, r0
ld x, (x)
push x
# pushvar: global itoa
ld x, (_itoa)
push x
pop x
call x
pop x
ld r254, x
ld x, r0
push x
# pushvar: global puts
ld x, (_puts)
push x
pop x
call x
pop x
ld r254, x
ld x, r0
push x
# discard expression value
pop x
jmp l__122
# else body
l__121:
# if condition
# pushvar: local p
ld x, 2(sp)
push x
# unary *
pop x
# pointer dereference:
ld x, (x)
push x
# genliteral:
push 120
# operator: ==
pop x
ld r0, x
pop x
sub x, r0 #peepopt:test
ld x, 0
jnz l__123
ld x, 1
l__123:
push x
pop x
test x
jz l__124
# if body
# parseFunctionCall:
ld x, r254
push x
# parseFunctionCall:
ld x, r254
push x
# pushvar: local args
ld x, 5(sp)
push x
# post-inc
# pushvar: local argidx
ld x, 4(sp)
push x
pop x
push x
inc x
push x
# poptovar: local argidx
ld r252, sp
add r252, 6
pop x
ld (r252), x
pop x
ld r0, x
pop x
add x, r0
ld x, (x)
push x
# genliteral:
push 16
# pushvar: global itoabase
ld x, (_itoabase)
push x
pop x
call x
pop x
ld r254, x
ld x, r0
push x
# pushvar: global puts
ld x, (_puts)
push x
pop x
call x
pop x
ld r254, x
ld x, r0
push x
# discard expression value
pop x
jmp l__125
# else body
l__124:
# parseFunctionCall:
ld x, r254
push x
ld x, l__126
push x
# pushvar: global puts
ld x, (_puts)
push x
pop x
call x
pop x
ld r254, x
ld x, r0
push x
# discard expression value
pop x
l__125:
l__122:
l__119:
l__116:
l__113:
jmp l__127
# else body
l__108:
# parseFunctionCall:
ld x, r254
push x
# pushvar: local p
ld x, 3(sp)
push x
# unary *
pop x
# pointer dereference:
ld x, (x)
push x
# pushvar: global putchar
ld x, (_putchar)
push x
pop x
call x
pop x
ld r254, x
ld x, r0
push x
# discard expression value
pop x
l__127:
# post-inc
# pushvar: local p
ld x, 2(sp)
push x
pop x
push x
inc x
push x
# poptovar: local p
ld r252, sp
add r252, 4
pop x
ld (r252), x
# discard expression value
pop x
jmp l__105
l__106:
# function had 2 parameters and 2 locals:
ret 4
# end function declaration

l__104:
ld x, l__103
push x
#nosym
# poptovar: global printf
pop x
ld (_printf), x
# parseFunctionCall:
ld x, r254
push x
ld x, l__128
push x
# pushvar: global puts
ld x, (_puts)
push x
pop x
call x
pop x
ld r254, x
ld x, r0
push x
# discard expression value
pop x
jmp l__129
_mul: .word 0
_powers_of_2: .word 0
_divmod: .word 0
_shr8: .word 0
_shl: .word 0
_itoa_alphabet: .word 0
_itoa_space: .word 0
_itoabase: .word 0
_itoa: .word 0
_islower: .word 0
_isupper: .word 0
_isalpha: .word 0
_isdigit: .word 0
_isalnum: .word 0
_tolower: .word 0
_stridx: .word 0
_atoibase: .word 0
_atoi: .word 0
_inp: .word 0
_outp: .word 0
_car: .word 0
_cdr: .word 0
_setcar: .word 0
_setcdr: .word 0
_cmdargs: .word 0
_osbase: .word 0
_copyfd: .word 0
_unlink: .word 0
_stat: .word 0
_readdir: .word 0
_mkdir: .word 0
_chdir: .word 0
_tell: .word 0
_seek: .word 0
_close: .word 0
_open: .word 0
_read: .word 0
_write: .word 0
_system: .word 0
_exec: .word 0
_exit: .word 0
_EOF: .word 0
_getchar: .word 0
_putchar: .word 0
_gets: .word 0
_puts: .word 0
_printf: .word 0
l__11:
.word 48
.word 49
.word 50
.word 51
.word 52
.word 53
.word 54
.word 55
.word 56
.word 57
.word 97
.word 98
.word 99
.word 100
.word 101
.word 102
.word 103
.word 104
.word 105
.word 106
.word 107
.word 108
.word 109
.word 110
.word 111
.word 112
.word 113
.word 114
.word 115
.word 116
.word 117
.word 118
.word 119
.word 120
.word 121
.word 122
.word 0
l__12:
.word 46
.word 46
.word 46
.word 46
.word 46
.word 46
.word 46
.word 46
.word 46
.word 46
.word 46
.word 46
.word 46
.word 46
.word 46
.word 46
.word 46
.word 0
l__126:
.word 60
.word 63
.word 63
.word 63
.word 62
.word 0
l__128:
.word 72
.word 101
.word 108
.word 108
.word 111
.word 44
.word 32
.word 119
.word 111
.word 114
.word 108
.word 100
.word 33
.word 10
.word 0
l__82:
.gap 2
.word 0
l__129:
