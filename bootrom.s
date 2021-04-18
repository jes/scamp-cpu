# SCAMP bootloader
# The first 3 words from the disk device should be:
#  1. magic number (0x5343)
#  2. start address
#  3. length
# Once the given number of words have been loaded into memory at the
# given address, the address will be jumped to.
# Apart from the loaded code and the program counter, all machine state is
# undefined, including flags, contents of X, and all pseudo-registers including sp

.at 0

.def CFDATAREG   264
.def CFERRREG    265
.def CFBLKCNTREG 266
.def CFBLKNUMREG 267
.def CFCYLLOREG  268
.def CFCYLHIREG  269
.def CFHEADREG   270
.def CFSTATUSREG 271
.def CFREADCMD 0x20

.def SERIALREG0 136
.def SERIALREG1 137
.def SERIALREG3 139
.def SERIALREG5 141
.def SERIALCLKDIV 1 # 115200/1 = 115200 baud

.def START 0xff01 # r1
.def POINT 0xff02 # r2
.def LENGTH 0xff03 # r3

# put stack pointer in pseudoregs page, to minimise chances of collision
# with the loaded data
ld sp, 0xfffd # r253

call serial_init

# 1. print hello
ld r0, welcome_s
call print

call storage_init

# 2. read magic from disk
.def MAGIC 0x5343
call inword
sub r0, MAGIC
jz read_startaddr

ld r0, wrongmagic_s
call print
jr- 1

# 3. read start address from disk
read_startaddr:
    call inword
    ld (START), r0
    ld (POINT), r0
    ld x, r0
    and x, 0xff00
    jnz read_length

    ld r0, startinrom_s
    call print
    jr- 1

# 4. read length from disk
read_length:
    call inword
    ld (LENGTH), r0
    jnz read_data

    ld r0, zerolength_s
    call print
    jr- 1

# 5. read data from disk
read_data:
    call inword
    ld x, r0
    ld ((POINT)++), x
    dec (LENGTH)
    jnz read_data

ld r0, ok_s
call print

# 6. jump to the loaded code
jmp (START)

# print the nul-terminated string pointed to by r0
print:
    ld x, (r0++)
    test x
    jz printdone
    # TODO: [bug] need to spin until tx holding register is empty
    out SERIALREG0, x
    jmp print
    printdone:
    ret

# usage: test4bits(val, start)
# where "start" contains the right-most bit to test
test4bits:
    pop x
    ld r6, x # r6 = bit to test
    pop x
    ld r7, x # r7 = val

    ld r8, 1 # r8 = bit to set
    ld r0, 0 # r0 = result

    ld r9, 4
    test4bits_loop:
        ld x, r7
        and x, r6
        jz test4bits_dontset
        or r0, r8

        test4bits_dontset:
        shl r8
        shl r6
        dec r9
        jnz test4bits_loop

    ret

# print hex of the word on the stack, followed by '\r\n'
alphabet: .str "0123456789abcdef"
printhex:
    pop x
    ld r10, x # r10 = value

    ld x, r254
    push x

    ld r15, 1 # bit to test
    ld r16, 0xff12 # address (start at r18)
    printhex_loop:
        ld x, r10 # value
        push x
        ld x, r15 # bit to test
        push x
        call test4bits

        add r0, alphabet
        ld x, (r0)
        ld (r16++), x

        shl2 r15
        shl2 r15
        jnz printhex_loop

    out SERIALREG0, (0xff15) # r21
    out SERIALREG0, (0xff14) # r20
    out SERIALREG0, (0xff13) # r19
    out SERIALREG0, (0xff12) # r18
    ld x, 0x0d # '\r'
    out SERIALREG0, x
    ld x, 0x0a # '\n'
    out SERIALREG0, x

    pop x
    ld r254, x
    ret

serial_init:
    # select divisor latches:
    # write 0x80 to line control register
    ld x, 0x80
    out SERIALREG3, x

    # set high byte of divisor latch = 0
    ld x, 0
    out SERIALREG1, x
    # set low byte of divisor latch = SERIALCLKDIV
    ld x, SERIALCLKDIV
    out SERIALREG0, x

    # select data register instead of divisor latches, and set 8-bit words, no parity, 1 stop:
    # write 0x03 to line control register (addr 3)
    ld x, 0x03
    out SERIALREG3, x

    ret


.def BLKNUM 0xff04 # r4
.def BLKIDX 0xff05 # r5
storage_init:
    # initialise LBA address to 0 by writing 0 to Sector Number, Cylinder Low,
    # and Cylinder High Registers, and 224 ("enable LBA") to the Drive/Head
    # Register
    ld x, 0
    out CFBLKNUMREG, x
    out CFCYLLOREG, x
    out CFCYLHIREG, x
    ld x, 224
    out CFHEADREG, x

    # ask for 1 block
    ld x, 1
    out CFBLKCNTREG, x

    # issue "read" command
    ld x, CFREADCMD
    out CFSTATUSREG, x

    ld (BLKIDX), 0
    ld (BLKNUM), 0

    ret

# spin until card is ready for data transfer
cfwait:
    in x, CFSTATUSREG
    and x, 0x08 # test for "DRQ" bit
    jz cfwait
    ret

# read the next 1 word from the disk device and return it in r0
inword:
    ld x, r254
    push x
    call cfwait
    pop x
    ld r254, x

    in r0, CFDATAREG
    inc (BLKIDX)
    # do we need to go to the next block?
    ld x, (BLKIDX)
    sub x, 256
    jz nextblk

    ld x, r254
    push x
    ld x, r0
    push x
    push x
    call printhex
    pop x
    ld r0, x
    pop x
    ld r254, x
    ret

    nextblk:
    inc (BLKNUM)
    ld (BLKIDX), 0
    # ask for the new block number
    out CFBLKNUMREG, (BLKNUM)

    # ask for 1 block
    ld x, 1
    out CFBLKCNTREG, x

    # issue "read" command
    ld x, CFREADCMD
    out CFSTATUSREG, x

    ld x, 0x2e # '.'
    out SERIALREG0, x
    ret

welcome_s:    .str "boot:\r\n\0"
ok_s:         .str "OK\r\n\0"
wrongmagic_s: .str "bad magic\r\n\0"
startinrom_s: .str "start in ROM\r\n\0"
zerolength_s: .str "0 length\r\n\0"
