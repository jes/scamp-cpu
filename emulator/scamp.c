/* SCAMP emulator

   James Stanley 2021
*/

#include <errno.h>
#include <getopt.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int test, debug, show_help, test_fail;

uint8_t DI, DO, AI, MI, MO, II, IOH, IOL, JMP, PO, PP, XI, EO, YI, RT;
uint8_t EX, NX, EY, NY, F, NO;

uint16_t rom[256];
uint16_t ucode[2048];
uint16_t ram[65536];
uint16_t bus;

uint16_t X, Y, PC, instr, uinstr, addr;
uint8_t JZ, JLT, JGT;
uint8_t T, Z, LT;

void load_hex(uint16_t *buf, int len, char *name) {
    FILE *fp;
    int i = 0;

    if (!(fp = fopen(name, "r"))) {
        fprintf(stderr, "can't read %s: %s\n", name, strerror(errno));
        exit(1);
    }

    for (i = 0; i < len; i++) {
        if (!fscanf(fp, "%04hx", buf+i)) {
            fprintf(stderr, "can't read enough data from %s\n", name);
            exit(1);
        }
    }

    fclose(fp);
}

void load_ucode(void) {
    load_hex(ucode, 2048, "../ucode.hex");
}

void load_bootrom(void) {
    load_hex(rom, 256, "../bootrom.hex");
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

/* input a word from addr */
uint16_t in(uint16_t addr) {
    return 0;
}

/* output a word to addr */
int expect_output = 0;
void out(uint16_t val, uint16_t addr) {
    if (test && addr == 0) {
        if (val != expect_output) {
            printf("Out %d: got %d\n", expect_output, val);
            test_fail = 1;
        }
        expect_output++;
    }
    if (addr == 2) {
        printf("%c", val);
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
        EO = !(uinstr >> 15) & 0x1;
        EX = (uinstr >> 14) & 1;
        NX = (uinstr >> 13) & 1;
        EY = (uinstr >> 12) & 1;
        NY = (uinstr >> 11) & 1;
         F = (uinstr >> 10) & 1;
        NO = (uinstr >>  9) & 1;
        bus_out = (uinstr >> 12) & 0x7;
        RT = !EO && ((uinstr >> 11) & 0x1);
        PP = !EO && ((uinstr >> 10) & 0x1);
        bus_in = (uinstr >> 5) & 0x7;
        JZ = (uinstr >> 4) & 0x1;
        JGT = (uinstr >> 3) & 0x1;
        JLT = (uinstr >> 2) & 0x1;

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
    DI = (bus_in == 6);
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

    /* debug output */
    if (debug) {
        printf("PC = %04x\n", PC);
        printf("instr = %04x\n", instr);
        printf("T = %d\n", T);
        printf("uinstr = %04x\n", uinstr);
        printf("bus = %04x\n", bus);
        printf("addr = %04x\n", addr);
        printf("X = %04x\n", X);
        printf("Y = %04x\n", Y);
        printf("Z = %d, LT = %d\n", Z, LT);
        if (EO)
            printf(" EO%s%s%s%s%s%s", (EX?" EX":""), (NX?" NX":""), (EY?" EY":""), (NY?" NY":""), (F?" F":""), (NO?" NO":""));
        if (PO) printf(" PO");
        if (IOH) printf(" IOH");
        if (IOL) printf(" IOL");
        if (MO) printf(" MO");
        if (DO) printf(" DO");
        if (RT) printf(" RT");
        if (PP) printf(" P+");
        if (AI) printf(" AI");
        if (II) printf(" II");
        if (MI) printf(" MI");
        if (XI) printf(" XI");
        if (YI) printf(" YI");
        if (DI) printf(" DI");
        if (JGT) printf(" JGT");
        if (JLT) printf(" JLT");
        printf("\n\n");
    }
}

void help(void) {
    printf("usage: scamp [-d]\n"
"\n"
"Options:\n"
"  -d,--debug    Print debug output after each clock cycle\n"
"  -h,--help     Show this help text\n"
"\n"
"This emulator loads the microcode from ../ucode.hex and boot ROM from ../bootrom.hex.\n"
"\n"
"By James Stanley <james@incoherency.co.uk>\n");
    exit(1);
}

int main(int argc, char **argv) {
    int steps = 0;

    /* parse options */
    while (1) {
        static struct option opts[] = {
            {"debug", no_argument, &debug,     1},
            {"test",  no_argument, &test,      1},
            {"help",  no_argument, &show_help, 1},
            {0, 0, 0, 0},
        };

        int optidx = 0;
        int c = getopt_long(argc, argv, "dht", opts, &optidx);

        if (c == -1) break;
        if (c == 'd') debug = 1;
        if (c == 'h') show_help = 1;
        if (c == 't') test = 1;
    }

    if (show_help) help();

    /* load ROMs */
    load_ucode();
    load_bootrom();

    /* run the clock */
    while (!test || (steps++ < 2000)) {
        negedge();
        posedge();
    }

    return test_fail;
}
