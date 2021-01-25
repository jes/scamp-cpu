# Note: currently this has to be assembled manually

# 0
ldx(0)    # load X with immediate 0
out       # output X

# 1
ldx(1)    # load X with immediate 1
out       # output X

# 2
ldx(2)    # load X with immediate 2
out       # output X

# 3
ldx(3)    # load X with immediate 3
out       # output X

# 4: add 1+3
ldx(1)    # load X with immediate 1
ldy(3)    # load Y with immediate 3
add       # X = X + Y
out       # output X

# 5: sub 100-95
ldx(100)  # load X with immediate 100
ldy(95)   # load Y with immediate 95
sub       # X = X - Y
out       # output X

# 6: inc 5+1
ldx(5)
inc
out

# 7: dec 8-1
ldx(8)
dec
out

# 8: shl 4
ldx(4)
shl
out

# 9: 1001 == 1000 | 0001
ldx(8)
ldy(1)
or
out

# 10: 1010 == 1110 & 1011
ldx(14)
ldy(11)
and
out

# 11: 1011 == 11101 ^ 10110
ldx(29)
ldy(22)
xor
out

# 12,13: push 13, push 12, pop, out, pop, out
ldx(128)   # X = 128
shl        # X = 256
shl        # X = 512
stx 0xffff # M[0xffff] = 512 (set SP = 512)
ldx(13)    # X = 13
clc        # XXX: clear carry, for push (we should add a carry-enable bit to ucode)
push(255)  # push X
ldx(12)    # X = 12
clc        # XXX: clear carry, for push (we should add a carry-enable bit to ucode)
push(255)  # push X
ldx(42)    # (clobber X)
pop(255)   # pop 12 into X
out        # output X
pop(255)   # pop 13 into X
out        # output X

# 14: unconditional jump
ldx(14)    # X = 14
jmp L      # jmp to L
ldx(42)    # (clobber X)
L: out     # output X

# 15: conditional jump
ldx(0)     # X = 0
stx 0xffff # M[0xffff] = 0
ldx(15)    # X = 15
L:
stx 0xfffe # M[0xfffe] = X
ldx 0xffff # X = M[0xffff]
inc        # X = X+1
stx 0xffff # M[0xffff] = X
ldx 0xfffe # X = M[0xfffe]
djnz L
ldx 0xffff # X = M[0xffff]
out
