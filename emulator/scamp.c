/* SCAMP emulator

   James Stanley 2021
*/

#include <errno.h>
#include <fcntl.h>
#include <getopt.h>
#include <poll.h>
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

#ifdef EMSCRIPTEN
#include <emscripten/emscripten.h>
#endif

/* this is a pretty lame 8250 emulation, it only really supports the
   parts that are used by SCAMP/os */
struct uart8250 {
    int dataready : 1;
    int txempty : 1;
    int dlab : 1; /* "divisor latch access bit"? */
    int is_console : 1;
    int infd;
    int outfd;
    uint16_t base_address;
    uint16_t clockdiv;
    uint8_t rxbuf;
    uint8_t txbuf;
    uint64_t last_rx;
    /* TODO: [bug] we should drop characters if trying to output them faster
       than the baud rate allows */
};

int test, debug, stacktrace, cyclecount, show_help, test_fail, freq=20000000, watch=-1, zero, memorylog;
int halt;
uint64_t steps;
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

#ifdef PROFILING
uint64_t pc_cycles[65536];
uint16_t last_instr[65536];
uint64_t opcode_cycles[256];
uint64_t addr_reads[65536];
uint64_t addr_writes[65536];
FILE *profile_fp;
int run_profile = 1;
uint64_t prof_cycles;

uint64_t segmented_cycles[256];
int segment = 0;
#endif

#ifdef EMSCRIPTEN
int ready;

#define UART_BUFSZ 1024
char uart_outbuf[UART_BUFSZ];
char uart_inbuf[UART_BUFSZ];
char *uart_outp;
#endif

struct uart8250 console;

#ifndef EMSCRIPTEN
struct uart8250 serialport;
#endif

void randomise_ram(void) {
    int i;

    srand(time(NULL));

    for (i = 0; i < 65536; i++)
        ram[i] = rand();
}

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

void load_ucode(char *name) {
    load_hex(ucode, 2048, name);
}

void load_bootrom(char *name) {
    load_hex(rom, 256, name);
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

#ifdef PROFILING
void open_profile(char *file) {
    if (!(profile_fp = fopen(file, "w"))) {
        fprintf(stderr, "can't write %s: %s\n", file, strerror(errno));
        exit(1);
    }
}
#endif

#ifdef PROFILING
void write_profile(int argc, char **argv, uint64_t elapsed_us) {
    int i;

    if (!profile_fp) return;

    fprintf(profile_fp, "scamp-profile\n");
    fprintf(profile_fp, "endtime: %ld\n", time(0));
    fprintf(profile_fp, "cmdline: %s", argv[0]);
    for (i = 1; i < argc; i++)
        fprintf(profile_fp, " %s", argv[i]);
    fprintf(profile_fp, "\n");
    fprintf(profile_fp, "cycles: %lu\n", prof_cycles);
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
#endif

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

#ifndef EMSCRIPTEN
int opentty(char *name) {
    int fd = open(name, O_RDWR);
    if (fd == -1) {
        fprintf(stderr, "open %s: %s\n", name, strerror(errno));
        exit(1);
    }
    return fd;
}
#endif

/* return 1 if data available to read, 0 if not, -1 if poll error */
int uart_ready(struct uart8250 *uart) {
    struct pollfd pfd;
    float chars_per_sec = 11520.0 / uart->clockdiv; /* 1/10 of baud rate */
    uint64_t steps_per_char = freq / chars_per_sec;

    /* we can't have received any more chars yet if the baud rate would't allow it */
    if (steps - uart->last_rx < steps_per_char) return 0;

    pfd.fd = uart->infd;
    pfd.events = POLLIN;

    return poll(&pfd, 1, 0);
}

#ifdef EMSCRIPTEN
void uart_poll(struct uart8250 *uart) {
    uart->dataready = *uart_inbuf ? 1 : 0;
    uart->txempty = 1;
}
#else
/* read into rx buffer, and maybe set halt flag on ctrl-\ */
void uart_poll(struct uart8250 *uart) {
    uint8_t ch;

    if (!uart_ready(uart)) return;

    if (read(uart->infd, &ch, 1) != 1) {
        halt = 1;
        return;
    }
    if (uart->is_console && ch == 28) halt = 1; /* halt on ctrl-\ */

    /* note: we deliberately drop characters if the rxbuf hasn't been
       consumed yet; this emulates real 8250 behaviour; we could consider
       setting bit 1 ("Overrun Error") of the line status register (reg 5)
       if we are setting rxbuf while dataready is already 1 */
    uart->last_rx = steps;
    uart->rxbuf = ch;
    uart->dataready = 1;
}
#endif

#ifdef EMSCRIPTEN
/* return next char from input buffer */
uint8_t uart_getchar(struct uart8250 *uart) {
    uint8_t ch = 0;
    char *p;
    if (*uart_inbuf) {
        ch = *uart_inbuf;
        p = uart_inbuf;

        // move all remaining bytes 1 step toward the front
        // XXX: O(n) but n should be small (usually n=1)
        while (*(p+1)) {
            *p = *(p+1);
            p++;
        }
        *p = 0;
    }
    return ch;
}
#else
/* return next char from input buffer */
uint8_t uart_getchar(struct uart8250 *uart) {
    uart_poll(uart);
    uart->dataready = 0;
    return uart->rxbuf;
}
#endif

uint8_t uart_in(struct uart8250 *uart, int addr) {
    switch (addr) {
        case 0:
            if (uart->dlab) return uart->clockdiv >> 8; /* divisor latch lsb */
            else            return uart_getchar(uart); /* rxbuf */
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
            return uart->dataready | ((uart->txempty&1) << 5) | ((uart->txempty&1) << 6);
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

#ifdef EMSCRIPTEN
void uart_putchar(struct uart8250 *uart, int ch) {
    *(uart_outp++) = ch;
    if (uart_outp == uart_outbuf + UART_BUFSZ - 1) uart_outp--;
    *uart_outp = 0;
}
#else
void uart_putchar(struct uart8250 *uart, int ch) {
    write(uart->outfd, &ch, 1);
}
#endif

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
        uart->txbuf = val;
        uart->txempty = 0;

        /* XXX: when we are tracking baud rate, the following can move: */
        uart_putchar(uart, uart->txbuf);
        uart->txempty = 1;
    }
}

/* input a word from addr */
uint16_t in(uint16_t addr) {
    uint16_t r = 0;
    if (addr == 1) {
        r = disk[diskptr++];
    }
    if (addr == 5) {
        if (disk)
            r = disk[512*blknum + blkidx];
        blkidx = (blkidx+1)%512;
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
#ifndef EMSCRIPTEN
    if (addr >= serialport.base_address && addr < serialport.base_address + 8) {
        r = uart_in(&serialport, addr-serialport.base_address);
    }
#endif
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
    if (addr == 3) {
        halt = 1;
    }
    if (addr == 4) {
        blknum = val;
        blkidx = 0;
    }
    if (addr == 5) {
        if (disk)
            disk[512*blknum + blkidx] = val;
        blkidx = (blkidx+1)%512;
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
#ifndef EMSCRIPTEN
    if (addr >= serialport.base_address && addr < serialport.base_address + 8) {
        uart_out(&serialport, addr-serialport.base_address, val);
    }
#endif

#ifdef PROFILING
    if (addr == 1 && run_profile) halt = 1;
    if (addr == 2) {
        /* targeted profiling: reset profiling counters to remove all the stuff we don't want */
        memset(pc_cycles, 0, sizeof(pc_cycles));
        memset(last_instr, 0, sizeof(last_instr));
        memset(opcode_cycles, 0, sizeof(opcode_cycles));
        memset(addr_reads, 0, sizeof(addr_reads));
        memset(addr_writes, 0, sizeof(addr_writes));
        memset(segmented_cycles, 0, sizeof(segmented_cycles));
        prof_cycles = 0;

        run_profile = 1;
    }
    if (addr == 6) run_profile = 0;
    if (addr == 7) run_profile = 1;
    if (addr == 10) segment = val;
#endif
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

#ifdef PROFILING
    if (run_profile) {
        prof_cycles++;
        pc_cycles[PC]++;
        last_instr[PC] = instr;
        opcode_cycles[opcode]++;
        segmented_cycles[segment]++;
    }
#endif

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
#ifdef PROFILING
        if (run_profile) addr_reads[addr]++;
#endif
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
#ifdef PROFILING
        if (run_profile) addr_writes[addr]++;
#endif
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
    printf("usage: scamp [options]\n"
"\n"
"Options:\n"
"  -c,--cycles        Print number of cycles taken\n"
"  -d,--debug         Print debug output after each clock cycle\n"
"  -f,--freq HZ       Aim to emulate a clock of the given frequency (default: 20000000)\n"
"  -i,--image FILE    Load disk image from given hex file\n"
#ifdef PROFILING
"  -m,--memorylog     Log the contents of memory to mem/frame.%%04d periodically\n"
"  -p,--profile FILE  Write profiling data to FILE\n"
#endif
"  -r,--run FILE      Load the given hex file into RAM at 0x100 and run it instead of the boot ROM\n"
"  -S,--serial FILE   Use FILE (e.g. /dev/pts/...) for the secondary serial port\n"
"  -s,--stack         Trace the stack\n"
"  -t,--test          Check whether the test ROM passes the tests\n"
"  -w,--watch ADDR    Watch for changes to the given address and print them on stderr\n"
"  -z,--zero          Initialise memory to zeroes instead of random\n"
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

#ifdef EMSCRIPTEN
/* tick N clock cycles, appending "input" to the UART input stream,
   and returning anything output from the UART
*/
EMSCRIPTEN_KEEPALIVE
char *tick(int N, char *input) {
    if (!ready) return "";

    strncat(uart_inbuf, input, UART_BUFSZ - strlen(uart_inbuf) - 1);
    uart_outp = uart_outbuf;
    *uart_outp = 0;

    while (N--) {
        negedge();
        posedge();
    }
    return uart_outbuf;
}
#endif

#ifdef PROFILING
/* dump memory contents and PC to file */
void dumpmem(int frame) {
    char name[100];
    sprintf(name, "mem/frame.%04d", frame);
    FILE *fp = fopen(name, "w");
    if (!fp) {
        fprintf(stderr, "can't write %s\n", name);
        exit(1);
    }
    for (int i = 0; i < 65536; i++) {
        fprintf(fp, "%04x\n", i<256 ? rom[i] : ram[i]);
    }
    fprintf(fp, "%04x\n", PC);
    fclose(fp);
}
#endif

int main(int argc, char **argv) {
    int jmp0x100 = 0;
    struct timeval starttime, curtime;
    uint64_t elapsed_us, target_us;

    console.is_console = 1;
    console.base_address = 136;
    console.infd = 0; /* stdin */
    console.outfd = 1; /* stdout */
    console.txempty = 1;

#ifndef EMSCRIPTEN
    serialport.is_console = 0;
    serialport.base_address = 144;
    serialport.infd = -1;
    serialport.outfd = -1;
    serialport.txempty = 1;
#endif

#ifdef EMSCRIPTEN
    load_disk("os.disk");
    load_ucode("ucode.hex");
    load_bootrom("bootrom.hex");

    ready = 1;
#else
    setbuf(stdout, NULL);

    /* parse options */
    while (1) {
        static struct option opts[] = {
            {"cycles",  no_argument, &cyclecount,1},
            {"debug",   no_argument, &debug,     1},
            {"freq",    required_argument, 0, 'f'},
            {"image",   required_argument, 0, 'i'},
#ifdef PROFILING
            {"memorylog",no_argument,      0, 1},
            {"profile", required_argument, 0, 'p'},
#endif
            {"run",     required_argument, 0, 'r'},
            {"serial",  required_argument, 0, 'S'},
            {"stack",   no_argument, &stacktrace,1},
            {"test",    no_argument, &test,   1},
            {"watch",   required_argument, 0, 'w'},
            {"zero",    no_argument,   &zero, 1},
            {"help",    no_argument, &show_help, 1},
            {0, 0, 0, 0},
        };

        int optidx = 0;
        int c = getopt_long(argc, argv, "cdf:i:hp:r:stw:", opts, &optidx);

        if (c == -1) break;
        if (c == 'c') cyclecount = 1;
        if (c == 'd') debug = 1;
        if (c == 'f') freq = atoi(optarg);
        if (c == 'i') load_disk(optarg);
#ifdef PROFILING
        if (c == 'm') memorylog = 1;
        if (c == 'p') open_profile(optarg);
#endif
        if (c == 'r') {
            load_ram(0x100, optarg);
            jmp0x100 = 1;
        }
        if (c == 'S') serialport.infd = serialport.outfd = opentty(optarg);
        if (c == 's') stacktrace = 1;
        if (c == 't') test = 1;
        if (c == 'w') watch = atoi(optarg);
        if (c == 'z') zero = 1;

        if (c == 'h') show_help = 1;
    }

    if (show_help) help();

    /* load ROMs */
    load_ucode("../ucode.hex");
    if (!jmp0x100) {
        if (test) load_bootrom("../testrom.hex");
        else      load_bootrom("../bootrom.hex");
    } else {
        PC = 0x100;
    }

    if (!zero) randomise_ram();

    signal(SIGINT, sighandler);
    rawmode();
    gettimeofday(&starttime, NULL);

#ifdef PROFILING
    int frame = 0;
#endif

    /* run the clock */
    while (!halt) {
        if ((steps & 0xffff) == 0) /* console_poll() is slow, only call it very occasionally */
            uart_poll(&console);

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

#ifdef PROFILING
        if (memorylog && steps % 200 == 0) dumpmem(frame++);
#endif
    }

    if (cyclecount)
        fprintf(stderr, "[cycles] Halted after %lu cycles.\r\n", steps);

#ifdef PROFILING
    if (profile_fp)
        write_profile(argc, argv, elapsed_us);

    int i;
    uint64_t totalcycles = 0;
    int numsegments = 0;
    for (i = 0; i < 256; i++) {
        if (segmented_cycles[i] > 0) {
            fprintf(stderr, "[cycles] segment %d: %lu\r\n", i, segmented_cycles[i]);
            totalcycles += segmented_cycles[i];
            numsegments++;
        }
    }
    if (numsegments > 1) {
        fprintf(stderr, "[cycles] total: %lu\r\n", totalcycles);
    }
#endif

#endif /* EMSCRIPTEN */
    return test_fail;
}
