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

ld sp, 0x8000

call serial_init

# 1. print hello
ld r0, welcome_s
call print

call storage_init

# 2. read magic from disk
.def MAGIC 0x5343
call inword
ld r11, r0
ld r0, wrongmagic_s
sub r11, MAGIC
jnz error

# 3. read start address from disk
call inword
ld (START), r0
ld (POINT), r0
ld x, r0
ld r0, startinrom_s
and x, 0xff00
jz error

# 4. read length from disk
call inword
ld r11, r0
ld r0, zerolength_s
ld (LENGTH), r11
jz error

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

# error message pointer in r0
error:
    call print
    jr- 1

# print the nul-terminated string pointed to by r0
print:
    ld x, (r0++)
    test x
    jz printdone
    # TODO: [bug] need to spin until tx holding register is empty
    out SERIALREG0, x
    jmp print
    printdone:
    ld x, 0x0d # '\r'
    out SERIALREG0, x
    ld x, 0x0a # '\n'
    out SERIALREG0, x
    ret

# r10 = value
# r15 = first bit to test (gets shifted-left 4)
test4bits:
    ld r8, 1 # r8 = bit to set
    ld r0, 0 # r0 = result

    ld r9, 4
    test4bits_loop:
        ld x, r10
        and x, r15
        jz test4bits_dontset
        or r0, r8

        test4bits_dontset:
        shl r8
        shl r15
        dec r9
        jnz test4bits_loop

    ret

# print hex of the word in r10, followed by '\r\n'
alphabet: .str "0123456789abcdef"
printhex:
    ld x, r254
    push x

    ld r15, 1 # bit to test
    ld r16, 0xff15 # address (start at r21 and work down)
    printhex_loop:
        call test4bits

        add r0, alphabet
        ld x, (r0)
        ld (r16--), x

        test r15
        jnz printhex_loop

    ld r22, 0
    ld r0, 0xff12
    call print

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
    ld x, r254
    push x

    # initialise LBA address to 0 by writing 0 to Sector Number, Cylinder Low,
    # and Cylinder High Registers, and 224 ("enable LBA") to the Drive/Head
    # Register
    ld r22, 0x40
    call cfwait
    ld x, 0
    out CFBLKNUMREG, x

    call cfwait
    ld x, 0
    out CFCYLLOREG, x

    call cfwait
    ld x, 0
    out CFCYLHIREG, x

    call cfwait
    ld x, 224
    out CFHEADREG, x

    # ask for 1 block
    call cfwait
    ld x, 1
    out CFBLKCNTREG, x

    # issue "read" command
    call cfwait
    ld x, CFREADCMD
    out CFSTATUSREG, x

    ld (BLKIDX), 0
    ld (BLKNUM), 0

    pop x
    ld r254, x
    ret

# spin until card status matches mask in r22
# status flags are:
#    0x01 - ERR  - the previous command ended in some time of error (see the Error Register)
#    0x02 - 0    - always 0
#    0x04 - CORR - a correctable error has occurred and the data has been corrected
#    0x08 - DRQ  - the card requires information transferred to or from the host via the Data Register
#    0x10 - DSC  - the card is ready
#    0x20 - DWF  - a write fault has occurred
#    0x40 - RDY  - the device is capable of performing card operations
#    0x80 - BUSY - the host is locked out from accessing the command register and buffer
cfwait:
    in x, CFSTATUSREG

    # first check if card is BUSY: if so, the other bits are undefined
    ld r11, x
    and x, 0x80
    jnz cfwait

    # now test whether the bits from the mask are all set
    ld x, r11
    and x, r22
    sub x, r22
    jnz cfwait

    ret

# read the next 1 word from the disk device and return it in r0
inword:
    ld x, r254
    push x

    ld r22, 0x48 # RDY | DRQ
    call cfwait

    in x, CFDATAREG

    ld r10, x
    call printhex
    ld r0, r10

    inc (BLKIDX)
    # do we need to go to the next block?
    ld x, (BLKIDX)
    and x, 0xff00 # x&0xff00 == 0 except when we need the next block
    jz inword_ret

    nextblk:
    ld r22, 0x40
    call cfwait
    inc (BLKNUM)
    ld (BLKIDX), 0
    # ask for the new block number
    out CFBLKNUMREG, (BLKNUM)

    call cfwait
    # ask for 1 block
    ld x, 1
    out CFBLKCNTREG, x

    call cfwait
    # issue "read" command
    ld x, CFREADCMD
    out CFSTATUSREG, x

    ld x, 0x2e # '.'
    out SERIALREG0, x

    inword_ret:
    pop x
    ld r254, x
    ret

welcome_s:    .str "boot\0"
ok_s:         .str "OK\0"
wrongmagic_s: .str "bad magic\0"
startinrom_s: .str "start in ROM\0"
zerolength_s: .str "0 length\0"
