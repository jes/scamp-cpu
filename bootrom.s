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

.def DISKBLK   4
.def DISKDEV   5
.def SERIALREG0 64
.def SERIALREG1 65
.def SERIALREG3 67
.def SERIALREG5 69
.def SERIALCLKDIV 12 # 115200/12 = 9600 baud
.def START 0xff01
.def POINT 0xff02
.def LENGTH 0xff03

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
    out SERIALREG0, x
    jmp print
    printdone:
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


.def BLKNUM 0xff0a
.def BLKIDX 0xff0b
storage_init:
    # TODO: initialise a real storage device
    ld x, 0
    out DISKBLK, x
    ld (BLKNUM), 0
    ld (BLKIDX), 0
    ret

# read the next 1 word from the disk device and return it in r0
# TODO: support a real disk device
inword:
    # high byte
    in x, DISKDEV
    inc (BLKIDX)
    shl3 x
    shl3 x
    shl2 x
    # low byte
    in r0, DISKDEV
    or r0, x
    inc (BLKIDX)
    # do we need to go to the next block?
    ld x, (BLKIDX)
    sub x, 512
    jz nextblk
    ret

    nextblk:
    inc (BLKNUM)
    ld (BLKIDX), 0
    out DISKBLK, (BLKNUM)

    ld x, 0x2e # '.'
    out SERIALREG0, x
    ret

welcome_s:    .str "SCAMP boot...\r\n\0"
ok_s:         .str "OK\r\n\0"
wrongmagic_s: .str "Disk error: wrong magic\r\n\0"
startinrom_s: .str "Disk error: start address points to ROM\r\n\0"
zerolength_s: .str "Disk error: length is 0\r\n\0"
