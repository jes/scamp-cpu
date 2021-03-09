/* SCAMP emulator

   James Stanley 2021
*/

#include <errno.h>
#include <fcntl.h>
#include <getopt.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <termios.h>
#include <time.h>
#include <unistd.h>

int test, debug, stacktrace, cyclecount, show_help, test_fail, freq, watch=-1;
int halt;
struct termios orig_termios;

uint8_t DI, DO, AI, MI, MO, II, IOH, IOL, JMP, PO, PP, XI, EO, YI, RT;
uint8_t EX, NX, EY, NY, F, NO;

uint16_t rom[256];
uint16_t ucode[2048];
uint16_t ram[65536];
uint16_t bus;

uint16_t X, Y, PC, instr, uinstr, addr;
uint8_t JZ, JLT, JGT;
uint8_t T, Z, LT;

uint16_t diskptr = 0;
uint8_t *disk;
uint16_t blknum = 0;
uint16_t blkidx = 0;

uint64_t pc_cycles[65536];
uint16_t last_instr[65536];
uint64_t opcode_cycles[256];
uint64_t addr_reads[65536];
uint64_t addr_writes[65536];
FILE *profile_fp;

void load_hex(uint16_t *buf, int maxlen, char *name) {
    FILE *fp;
    int i = 0;

    if (!(fp = fopen(name, "r"))) {
        fprintf(stderr, "can't read %s: %s\n", name, strerror(errno));
        exit(1);
    }

    for (i = 0; i < maxlen; i++)
        if (fscanf(fp, "%04hx", buf+i) != 1)
            break;

    fclose(fp);
}

void load_ucode(void) {
    load_hex(ucode, 2048, "../ucode.hex");
}

void load_bootrom(void) {
    if (test)
        load_hex(rom, 256, "../testrom.hex");
    else
        load_hex(rom, 256, "../bootrom.hex");
}

void load_ram(uint16_t addr, char *file) {
    load_hex(ram+addr, 65536-addr, file);
}

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

void open_profile(char *file) {
    if (!(profile_fp = fopen(file, "w"))) {
        fprintf(stderr, "can't write %s: %s\n", file, strerror(errno));
        exit(1);
    }
}

void write_profile(int argc, char **argv, int cycles, uint64_t elapsed_us) {
    int i;

    fprintf(profile_fp, "scamp-profile\n");
    fprintf(profile_fp, "endtime: %ld\n", time(0));
    fprintf(profile_fp, "cmdline: %s", argv[0]);
    for (i = 1; i < argc; i++)
        fprintf(profile_fp, " %s", argv[i]);
    fprintf(profile_fp, "\n");
    fprintf(profile_fp, "cycles: %d\n", cycles);
    fprintf(profile_fp, "elapsed_us: %lu\n", elapsed_us);
    fprintf(profile_fp, "pc_cycles:\n");
    for (i = 0; i < 65536; i++)
        fprintf(profile_fp, "%lu\n", pc_cycles[i]);
    fprintf(profile_fp, "last_instr:\n");
    for (i = 0; i < 65536; i++)
        fprintf(profile_fp, "%d\n", last_instr[i]);
    fprintf(profile_fp, "opcode_cycles:\n");
    for (i = 0; i < 256; i++)
        fprintf(profile_fp, "%lu\n", opcode_cycles[i]);
    fprintf(profile_fp, "addr_reads:\n");
    for (i = 0; i < 65536; i++)
        fprintf(profile_fp, "%lu\n", addr_reads[i]);
    fprintf(profile_fp, "addr_writes:\n");
    for (i = 0; i < 65536; i++)
        fprintf(profile_fp, "%lu\n", addr_writes[i]);
    fclose(profile_fp);
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
    uint16_t r = 0;
    if (addr == 1) {
        r = disk[diskptr++];
    }
    if (addr == 2) {
        /* TODO: don't block */
        r = getchar();
        if (r == 28) halt = 1; /* halt on ctrl-\ */
    }
    if (addr == 5) {
        r = disk[512*blknum + blkidx];
        blkidx = (blkidx+1)%512;
    }
    return r;
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
        putchar(val);
    }
    if (addr == 3) {
        halt = 1;
    }
    if (addr == 4) {
        blknum = val;
        blkidx = 0;
    }
    if (addr == 5) {
        disk[512*blknum + blkidx] = val;
        blkidx = (blkidx+1)%512;
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

    pc_cycles[PC]++;
    last_instr[PC] = instr;
    opcode_cycles[opcode]++;

    if (T == 1 && debug)
        fprintf(stderr, "[trace] PC=%04x\n", PC);

    if (T == 3 && stacktrace) {
        if (opcode == 0xb7)
            fprintf(stderr, "[stack] PC=%04x: push x: %04x\n", PC, X);
        if (opcode == 0xb8)
            fprintf(stderr, "[stack] PC=%04x: push i8l: %02x\n", PC, instr&0xff);
        if (opcode == 0xb9)
            fprintf(stderr, "[stack] PC=%04x: push i8h: %02x\n", PC, 0xff00|(instr&0xff));
        if (opcode == 0xba)
            fprintf(stderr, "[stack] PC=%04x: pop x: %04x\n", PC, ram[ram[0xffff]+1]);
    }

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
    if (MO) {
        bus = (addr < 256 ? rom[addr] : ram[addr]);
        addr_reads[addr]++;
    }
    if (DO)  bus = in(addr);
}

/* positive edge of clock: update register contents */
void posedge(void) {
    if (AI)  addr = bus;
    if (II)  instr = bus;
    if (MI) {
        if (watch == addr)
            fprintf(stderr, "[watch] PC=%04x: M[%04x] was %04x, now %04x\n", PC, addr, ram[addr], bus);
        ram[addr] = bus;
        addr_writes[addr]++;
        if (stacktrace && addr == 0xffff)
            fprintf(stderr, "[stack] PC=%04x: sp=%04x: stack = %04x %04x %04x %04x %04x...\n", PC, ram[0xffff], ram[ram[0xffff]+1], ram[ram[0xffff]+2], ram[ram[0xffff]+3], ram[ram[0xffff]+4], ram[ram[0xffff]+5]);
    }
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
"  -c,--cycles        Print number of cycles taken\n"
"  -d,--debug         Print debug output after each clock cycle\n"
"  -f,--freq HZ       Aim to emulate a clock of the given frequency\n"
"  -i,--image FILE    Load disk image from given hex file\n"
"  -p,--profile FILE  Write profiling data to FILE\n"
"  -r,--run FILE      Load the given hex file into RAM at 0x100 and run it instead of the boot ROM\n"
"  -s,--stack         Trace the stack\n"
"  -t,--test          Check whether the test ROM passes the tests\n"
"  -w,--watch ADDR    Watch for changes to the given address and print them on stderr\n"
"  -h,--help          Show this help text\n"
"\n"
"This emulator loads the microcode from ../ucode.hex and boot ROM from ../bootrom.hex.\n"
"If --test, boot ROM is replaced with a test ROM from ../testrom.hex.\n"
"\n"
"By James Stanley <james@incoherency.co.uk>\n");
    exit(1);
}

void sighandler(int sig) {
    (void)sig; /* suppress warning: unused parameter ‘sig’ [-Wunused-parameter] */
    halt = 1;
}

void unrawmode(void) {
    tcsetattr(STDIN_FILENO, TCSAFLUSH, &orig_termios);
}

/* https://viewsourcecode.org/snaptoken/kilo/02.enteringRawMode.html */
void rawmode(void) {
    if (!isatty(STDIN_FILENO))
        return;

    if (tcgetattr(STDIN_FILENO, &orig_termios) == -1) {
        fprintf(stderr, "tcgetattr: %s\n", strerror(errno));
        exit(1);
    }

    atexit(unrawmode);

    struct termios raw = orig_termios;
    raw.c_iflag &= ~(BRKINT | ICRNL | INPCK | ISTRIP | IXON);
    raw.c_oflag &= ~(OPOST);
    raw.c_cflag |= (CS8);
    raw.c_lflag &= ~(ECHO | ICANON | IEXTEN | ISIG);

    if (tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw) == -1) {
        fprintf(stderr, "tcsetattr: %s\n", strerror(errno));
        exit(1);
    }
}

int main(int argc, char **argv) {
    int steps = 0;
    int jmp0x100 = 0;
    struct timeval starttime, curtime;
    uint64_t elapsed_us, target_us;

    setbuf(stdout, NULL);

    /* parse options */
    while (1) {
        static struct option opts[] = {
            {"cycles",no_argument, &cyclecount,1},
            {"debug", no_argument, &debug,     1},
            {"freq",  required_argument,  0, 'f'},
            {"image", required_argument,  0, 'i'},
            {"profile",required_argument, 0, 'p'},
            {"run",   required_argument,  0, 'r'},
            {"stack", no_argument, &stacktrace,1},
            {"test",  no_argument, &test,      1},
            {"watch", required_argument,  0, 'w'},
            {"help",  no_argument, &show_help, 1},
            {0, 0, 0, 0},
        };

        int optidx = 0;
        int c = getopt_long(argc, argv, "cdf:i:hp:r:stw:", opts, &optidx);

        if (c == -1) break;
        if (c == 'c') cyclecount = 1;
        if (c == 'd') debug = 1;
        if (c == 'f') freq = atoi(optarg);
        if (c == 'i') load_disk(optarg);
        if (c == 'p') open_profile(optarg);
        if (c == 'r') {
            load_ram(0x100, optarg);
            jmp0x100 = 1;
        }
        if (c == 's') stacktrace = 1;
        if (c == 't') test = 1;
        if (c == 'w') watch = atoi(optarg);

        if (c == 'h') show_help = 1;
    }

    if (show_help) help();

    /* load ROMs */
    load_ucode();
    if (!jmp0x100) {
        load_bootrom();
    } else {
        PC = 0x100;
    }

    signal(SIGINT, sighandler);
    rawmode();
    gettimeofday(&starttime, NULL);

    /* run the clock */
    while (!halt) {
        negedge();
        posedge();
        steps++;
        if (test && steps > 3000)
            halt = 1;

        gettimeofday(&curtime, NULL);
        elapsed_us = ((curtime.tv_sec * 1000000) + curtime.tv_usec) - ((starttime.tv_sec * 1000000) + starttime.tv_usec);

        if (freq) {
            target_us = (steps * 1000000ull) / freq;
            if (elapsed_us < target_us)
                usleep(target_us - elapsed_us);
        }
    }

    if (cyclecount)
        fprintf(stderr, "[cycles] Halted after %d cycles.\n", steps);

    if (profile_fp)
        write_profile(argc, argv, steps, elapsed_us);

    return test_fail;
}
