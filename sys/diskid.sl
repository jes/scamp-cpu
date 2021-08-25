# identify disk

# XXX: lots of copy-and-paste from kernel's "cf.sl"

include "malloc.sl";
include "stdlib.sl";
include "stdio.sl";

var CFBASE = 264;

var CFDATAREG   = CFBASE+0;
var CFERRREG    = CFBASE+1;
var CFBLKCNTREG = CFBASE+2;
var CFBLKNUMREG = CFBASE+3;
var CFCYLLOREG  = CFBASE+4;
var CFCYLHIREG  = CFBASE+5;
var CFHEADREG   = CFBASE+6;
var CFSTATUSREG = CFBASE+7;
var CFCMDREG    = CFBASE+7;

var CFIDCMD = 0xec;

var CFERR  = 0x01;
var CFCORR = 0x04;
var CFDRQ  = 0x08;
var CFDSC  = 0x10;
var CFDWF  = 0x20;
var CFRDY  = 0x40;
var CFBUSY = 0x80;

# wait until CF status matches "mask"
var cf_wait = func(mask) {
    var state;
    var timeout = 1000; # XXX: is this sensible?

    while (timeout--) {
        state = inp(CFSTATUSREG);

        # if CFBUSY, the other bits are undefined
        if (state & CFBUSY)
            continue;

        if ((state & mask) == mask)
            return state;
    };

    fputs(2, "CompactFlash timeout");
    exit(1);
};

var cf_identify = func(buf) {
    # issue "identify" command
    cf_wait(CFRDY);
    outp(CFCMDREG, CFIDCMD);

    # wait for CFRDY and CFDRQ
    cf_wait(CFRDY | CFDRQ);

    var n = 256;
    while (n--)
        *(buf++) = inp(CFDATAREG);
};

var strbuf = malloc(256);
var grabstr = func(p, nbytes) {
    var strp = strbuf;

    while (nbytes > 0) {
        *(strp++) = shr8(*(p++));
        if (--nbytes == 0) break;
        *(strp++) = *(p++) & 0xff;
        if (--nbytes == 0) break;
    };

    *strp = 0;

    return strbuf;
};

var strcapab = func(v) {
    if (v & 0x080) puts(" DMA");
    if (v & 0x100) puts(" LBA");
};

var buf = malloc(256);
cf_identify(buf);

write(1, buf, 256);
printf("\n\n\n", 0);
printf("General configuration bit-significant information: 0x%04x\n", [buf[0]]);
printf("Default number of cylinders: %d\n", [buf[1]]);
printf("Default number of heads: %d\n", [buf[3]]);
printf("Number of unformatted bytes per track: %d\n", [buf[4]]);
printf("Number of unformatted bytes per sector: %d\n", [buf[5]]);
printf("Default number of sectors per track: %d\n", [buf[6]]);
printf("Number of sectors per card MSW: %d\n", [buf[7]]);
printf("Number of sectors per card LSW: %d\n", [buf[8]]);
printf("Serial number: %s\n", [grabstr(buf+10, 20)]);
printf("Buffer type (dual ported): 0x%04x\n", [buf[20]]);
printf("Buffer size in 512 byte increments: %d\n", [buf[21]]);
printf("Number of ECC bytes passed on Read/Write Long Commands: %d\n", [buf[22]]);
printf("Firmware revision: %s\n", [grabstr(buf+23, 8)]);
printf("Model number: %s\n", [grabstr(buf+27, 40)]);
printf("Maximum No. of Sectors on Read/Write Multiple command: %d\n", [buf[47]]);
printf("Double-word not supported: 0x%04x\n", [buf[48]]);
printf("Capabilities: 0x%04x", [buf[49]]); strcapab(buf[49]); putchar('\n');
printf("PIO data transfer cycle timing mode: 0x%04x\n", [buf[51]]);
printf("Single word DMA data transfer cycle timing mode: 0x%04x\n", [buf[52]]);
printf("Field validity: 0x%04x\n", [buf[53]]);
printf("Current number of cylinders: %d\n", [buf[54]]);
printf("Current number of heads: %d\n", [buf[55]]);
printf("Current sectors per track: %d\n", [buf[56]]);
printf("Current capacity in sectors (LBAs) MSW: %d\n", [buf[57]]);
printf("Current capacity in sectors (LBAs) LSW: %d\n", [buf[58]]);
printf("Multiple sector setting is valid: 0x%04x\n", [buf[59]]);
printf("Total number of sectors addressable in LBA Mode: 0x%04x%04x\n", [buf[60], buf[61]]);
printf("Single word DMA transfer: 0x%04x\n", [buf[62]]);
printf("Multiword DMA modes: 0x%04x\n", [buf[63]]);
printf("Advanced PIO modes supported: 0x%04x\n", [buf[64]]);
printf("Minimum multiword DMA transfer cycle time per word in ns: %d\n", [buf[65]]);
printf("Recommended multiword DMA transfer cycle time per word in ns: %d\n", [buf[66]]);
printf("Minimum PIO transfer without flow control: 0x%04x\n", [buf[67]]);
printf("Minimum PIO transfer with IORDY flow control: 0x%04x\n", [buf[68]]);
printf("Major ATA version: %d\n", [buf[80]]);
printf("Minor ATA version: %d\n", [buf[81]]);
printf("Features/command sets supported (82): 0x%04x\n", [buf[82]]);
printf("Features/command sets supported (83): 0x%04x\n", [buf[83]]);
printf("Features/command sets supported (84): 0x%04x\n", [buf[84]]);
printf("Features/command sets enabled (85): 0x%04x\n", [buf[85]]);
printf("Features/command sets enabled (86): 0x%04x\n", [buf[86]]);
printf("Features/command sets enabled (87): 0x%04x\n", [buf[87]]);
printf("Ultra DMA Mode supported and selected: 0x%04x\n", [buf[88]]);
printf("Time required for security erase-unit completion: 0x%04x\n", [buf[89]]);
printf("Time required for enhanced security erase-unit completion: 0x%04x\n", [buf[90]]);
printf("Current advanced power management value: 0x%04x\n", [buf[91]]);
printf("Power requirement description: 0x%04x\n", [buf[160]]);
printf("Key management schemes supported: 0x%04x\n", [buf[162]]);
printf("CF Advanced True IDE Timing Mode Capability and Setting: 0x%04x\n", [buf[163]]);
printf("CF Advanced PCMCIA I/O and Memory Timing Mode Capability: 0x%04x\n", [buf[164]]);
