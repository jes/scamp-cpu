/* SCAMP emulator for web

   Lots of this is copy-and-pasted from ../emulator/scamp.c - ideally we'd
   turn the common parts into a library that is used by both.

   James Stanley 2021 
*/

#include <emscripten/emscripten.h>
#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <fcntl.h>
#include <sys/stat.h>

/* this is a pretty lame 8250 emulation, it only really supports the
   parts that are used by SCAMP/os */
struct uart8250 {
    int dataready : 1;
    int txempty : 1;
    int dlab : 1; /* "divisor latch access bit"? */
    uint16_t base_address;
    uint16_t clockdiv;
    /* TODO: [bug] we should drop characters if trying to output them faster
       than the baud rate allows */
};

uint8_t DI, DO, AI, MI, MO, II, IOH, IOL, JMP, PO, PP, XI, EO, YI, RT;
uint8_t EX, NX, EY, NY, F, NO;

extern uint16_t rom[256];
extern uint16_t ucode[2048];
uint16_t ram[65536];
uint16_t bus;

uint16_t X, Y, PC, instr, uinstr, addr;
uint8_t JZ, JLT, JGT;
uint8_t T, Z, LT;

uint16_t diskptr = 0;
uint8_t *disk;
uint16_t blknum = 0;
uint16_t blkidx = 0;
int ready = 0;

#define UART_OUT_SZ 1024
char uart_outbuf[UART_OUT_SZ];
char *uart_outp;
char *uart_inbuf;

struct uart8250 console;

void load_disk(char *file) {
    int fd = open(file, O_RDWR, 0);
    if (fd < 0) {
        fprintf(stderr, "can't open %s: %s\n", file, strerror(errno));
        exit(1);
    }

    disk = mmap(NULL, 65536 * 512, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
    if (disk == MAP_FAILED) {
        fprintf(stderr, "can't mmap %s: %s\n", file, strerror(errno));
        exit(1);
    }
    close(fd);
}

/* compute ALU operation */
uint16_t alu(uint16_t argx, uint16_t argy) {
    uint16_t val;

    if (!EX) argx = 0;
    if (!EY) argy = 0;

    if (NX) argx = ~argx;
    if (NY) argy = ~argy;

    if (F) val = argx + argy;
    else   val = argx & argy;

    if (NO) val = ~val;

    return val;
}

void uart_poll(struct uart8250 *uart) {
    uart->dataready = *uart_inbuf ? 1 : 0;
    uart->txempty = 1;
}

/* return next char from input buffer */
uint8_t uart_getchar(struct uart8250 *uart) {
    if (*uart_inbuf) return *(uart_inbuf++);
    else return 0;
}

uint8_t uart_in(struct uart8250 *uart, int addr) {
    switch (addr) {
        case 0:
            if (uart->dlab) return uart->clockdiv >> 8; /* divisor latch lsb */
            else            return uart_getchar(&console); /* rxbuf */
        case 1:
            if (uart->dlab) return uart->clockdiv & 0xff; /* divisor latch msb */
            else            return 0; /* interrupt enable register */
        case 2: /* interrupt ident register */
            /* TODO */
            return 0;
        case 3: /* line control register */
            /* TODO */
            return 0;
        case 4: /* modem control register */
            /* TODO */
            return 0;
        case 5: /* line status register */
            /* TODO: [nice] there are potentially more bits that might be useful */
            uart_poll(uart);
            return uart->dataready | (uart->txempty << 5) | (uart->txempty << 6);
        case 6: /* modem status register */
            /* TODO */
            return 0;
        case 7: /* scratch register */
            /* TODO */
            return 0;
        default:
            return -1;
    }
}

void uart_out(struct uart8250 *uart, int addr, uint8_t val) {
    /* TODO: [nice] implement more of this, in particular we should really keep
             track of the configured baud rate and drop characters if we try to
             output too fast */
    if (addr == 3) {
        uart->dlab = !!(val & 0x80);
    }
    if (addr == 0 && uart->dlab) {
        uart->clockdiv = (uart->clockdiv & 0xff00) | val;
    }
    if (addr == 1 && uart->dlab) {
        uart->clockdiv = (uart->clockdiv & 0x00ff) | (val << 8);
    }
    if (addr == 0 && !uart->dlab) {
        *(uart_outp++) = val;
        if (uart_outp == uart_outbuf + UART_OUT_SZ - 1) uart_outp--;
        *uart_outp = 0;
    }
}

/* input a word from addr */
uint16_t in(uint16_t addr) {
    uint16_t r = 0;
    if (addr == 1) {
        r = disk[diskptr++];
    }
    if (addr == 264) { /* Data Register */
        if (disk)
            r = (disk[512*blknum + blkidx] << 8) | (disk[512*blknum + blkidx + 1]);
        blkidx = (blkidx+2)%512;
    }
    if (addr == 271) { /* Status Register */
        r = 0x58; /* RDY | DSC | DRQ */
    }
    if (addr >= console.base_address && addr < console.base_address + 8) {
        r = uart_in(&console, addr-console.base_address);
    }
    return r;
}

/* output a word to addr */
void out(uint16_t val, uint16_t addr) {
    if (addr == 4) {
        blknum = val;
        blkidx = 0;
    }
    if (addr == 264) { /* Data Register */
        if (disk) {
            disk[512*blknum + blkidx] = val >> 8;
            disk[512*blknum + blkidx + 1] = val & 0xff;
        }
        blkidx = (blkidx+2)%512;
    }
    if (addr == 267) { /* Sector Number Register */
        blknum = (blknum & 0xff00) | (val & 0x00ff);
        blkidx = 0;
    }
    if (addr == 268) { /* Cylinder Low Register */
        blknum = (blknum & 0x00ff) | ((val & 0x00ff) << 8);
        blkidx = 0;
    }
    if (addr >= console.base_address && addr < console.base_address + 8) {
        uart_out(&console, addr-console.base_address, val);
    }
}

/* negative edge of clock: update control lines and outputs to bus */
void negedge(void) {
    uint16_t uPC;
    uint8_t opcode;
    uint8_t bus_in, bus_out;

    do {
        /* look up uinstr */
        opcode = (instr >> 8) & 0xff;
        uPC = (opcode << 3) | T;
        uinstr = ucode[uPC];

        /* decode uinstr */
        EO = (!(uinstr >> 15)) & 0x1;
        EX = (uinstr >> 14) & 1;
        NX = (uinstr >> 13) & 1;
        EY = (uinstr >> 12) & 1;
        NY = (uinstr >> 11) & 1;
         F = (uinstr >> 10) & 1;
        NO = (uinstr >>  9) & 1;
        bus_out = (uinstr >> 12) & 0x7;
        PP = !EO && ((uinstr >> 10) & 0x1);
        bus_in = (uinstr >> 5) & 0x7;
        JZ = (uinstr >> 4) & 0x1;
        JGT = (uinstr >> 3) & 0x1;
        JLT = (uinstr >> 2) & 0x1;
        RT = (uinstr >> 1) & 1;
        DI = uinstr & 1;

        /* increment t-state */
        if (RT) T = 0;
        else    T = (T+1) % 8;
    } while (RT); /* loop until !RT because RT resets T-state immediately */

    /* calculate JMP */
    JMP = (JZ&Z) | (JLT&LT) | (JGT&!Z&!LT);

    /* decode bus_in */
    AI = (bus_in == 1);
    II = (bus_in == 2);
    MI = (bus_in == 3);
    XI = (bus_in == 4);
    YI = (bus_in == 5);
    /* spare: .. = (bus_in == 7); */

    /* decode bus_out */
    PO = (!EO && bus_out == 0);
    IOH = (!EO && bus_out == 1);
    IOL = (!EO && bus_out == 2);
    MO = (!EO && bus_out == 3);
    /* spare: .. = (!EO && bus_out == 4); */
    /* spare: .. = (!EO && bus_out == 5); */
    DO = (!EO && bus_out == 6);
    /* spare: .. = (!EO && bus_out == 7); */

    /* decide who is outputting to bus */
    if (EO)  bus = alu(X, Y), Z = (bus == 0), LT = !!(bus & 0x8000);
    if (PO)  bus = PC;
    if (IOH) bus = 0xff00 | (instr&0xff);
    if (IOL) bus = instr&0xff;
    if (MO)  bus = (addr < 256 ? rom[addr] : ram[addr]);
    if (DO)  bus = in(addr);
}

/* positive edge of clock: update register contents */
void posedge(void) {
    if (AI)  addr = bus;
    if (II)  instr = bus;
    if (MI)  ram[addr] = bus;
    if (XI)  X = bus;
    if (YI)  Y = bus;
    if (DI)  out(bus, addr);
    if (PP)  PC++;
    if (JMP) PC = bus;
}

/* tick one clock cycle, appending "input" to the UART input stream,
   and returning anything output from the UART
*/
EMSCRIPTEN_KEEPALIVE
char *tick(int N, char *input) {
    if (!ready) return "";

    /* TODO: [nice] append "input" to our own array for uart_inbuf, instead of
             assigning the pointer, so that characters aren't dropped if we don't
             consume them within N cycles? */
    uart_inbuf = input;
    uart_outp = uart_outbuf;
    *uart_outp = 0;

    while (N--) {
        negedge();
        posedge();
    }
    return uart_outbuf;
}

int main() {
    console.base_address = 136;
    console.txempty = 1;
    load_disk("/os.disk");
    ready = 1;
}
