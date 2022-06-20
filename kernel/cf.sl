# CompactFlash device handling
#
# TODO: [nice] currently we assume the bootrom initialised the card, maybe
#       should explicitly set the state we assume?
# TODO: [nice] support multiple cards, so that one can be used as removable
#       storage?

include "util.sl";

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

var CFREADCMD  = 0x20;
var CFWRITECMD = 0x30;

var CFERR  = 0x01;
var CFCORR = 0x04;
var CFDRQ  = 0x08;
var CFDSC  = 0x10;
var CFDWF  = 0x20;
var CFRDY  = 0x40;
var CFBUSY = 0x80;

# wait until CF status matches "mask"
# usage: cf_wait(mask)
var cf_wait = asm {
    .def CFSTATUSREG 271
    .def CFBUSY 0x80

    pop x
    ld r1, x # r1 = mask
    ld r2, 1000 # r2 = timeout (XXX: is 1000 sensible?)

    inc (_rngstate)

    cf_wait_loop:
        # panic if timed out
        test r2
        jz cf_wait_timeout

        # read state
        in r3, CFSTATUSREG

        # if CFBUSY, other bits are undefined, so check again
        ld x, r3
        and x, CFBUSY
        jnz cf_wait_loop

        # check if "(state & mask) == mask", if not then check again
        ld x, r3
        and x, r1
        sub x, r1
        jnz cf_wait_loop

        # otherwise we're done
        ld r0, r3
        ret

    cf_wait_timeout:
        ld x, cf_timeout_str
        push x
        call (_kpanic)

    cf_timeout_str: .str "CompactFlash timeout\0"
};

var cf_blkselect = func(num) {
    # least-significant byte
    cf_wait(CFRDY);
    outp(CFBLKNUMREG, num&0xff);

    # most-significant byte
    cf_wait(CFRDY);
    outp(CFCYLLOREG, shr8(num));
};

# usage: asm_cf_blkread(headbuf, bodybuf)
var asm_cf_blkread = asm {
    .def CFDATAREG 264

    ld r0, 16 # number of loop iterations (BLKSZ/16 == 256/16 == 16)
    pop x
    ld r3, x # pointer to write body to
    pop x
    ld r4, x # pointer to write header to

    # read the header (first 2 words)
    in x, CFDATAREG
    ld (r4++), x
    in x, CFDATAREG
    ld (r4), x

    ld x, r3
    jmp asm_cf_blkread_begin

    # read the body
    asm_cf_blkread_loop:
        in (x++), CFDATAREG
        in (x++), CFDATAREG
    asm_cf_blkread_begin:
        in (x++), CFDATAREG
        in (x++), CFDATAREG
        in (x++), CFDATAREG
        in (x++), CFDATAREG
        in (x++), CFDATAREG
        in (x++), CFDATAREG
        in (x++), CFDATAREG
        in (x++), CFDATAREG
        in (x++), CFDATAREG
        in (x++), CFDATAREG
        in (x++), CFDATAREG
        in (x++), CFDATAREG
        in (x++), CFDATAREG
        in (x++), CFDATAREG
        dec r0
        jnz asm_cf_blkread_loop
    ret
};

var cf_blkread = func(num, headbuf, bodybuf) {
    cf_blkselect(num);

    # only 1 block
    cf_wait(CFRDY);
    outp(CFBLKCNTREG, 1);

    # issue "read" command
    cf_wait(CFRDY);
    outp(CFCMDREG, CFREADCMD);

    # wait for CFRDY and CFDRQ
    cf_wait(CFRDY | CFDRQ);

    return asm_cf_blkread(headbuf, bodybuf);
};

# read the header from the given block number into the given buf
# TODO: [bug] is this legit? is this a violation of the CF spec or whatever?
var cf_blkread_head = func(num, buf) {
    cf_blkselect(num);

    # only 1 block
    cf_wait(CFRDY);
    outp(CFBLKCNTREG, 1);

    # issue "read" command
    cf_wait(CFRDY);
    outp(CFCMDREG, CFREADCMD);

    # wait for CFRDY and CFDRQ
    cf_wait(CFRDY | CFDRQ);

    buf[0] = inp(CFDATAREG);
    buf[1] = inp(CFDATAREG);
};

# usage: asm_cf_blkwrite(headbuf, bodybuf)
var asm_cf_blkwrite = asm {
    ld r0, 16 # number of loop iterations (BLKSZ/16 == 256/16 == 16)
    pop x
    ld r3, x # pointer to read body from
    pop x
    ld r4, x # pointer to read header from

    # write header (first 2 words)
    out CFDATAREG, (x++)
    out CFDATAREG, (x++)

    ld x, r3
    jmp asm_cf_blkwrite_begin

    asm_cf_blkwrite_loop:
        out CFDATAREG, (x++)
        out CFDATAREG, (x++)
    asm_cf_blkwrite_begin:
        out CFDATAREG, (x++)
        out CFDATAREG, (x++)
        out CFDATAREG, (x++)
        out CFDATAREG, (x++)
        out CFDATAREG, (x++)
        out CFDATAREG, (x++)
        out CFDATAREG, (x++)
        out CFDATAREG, (x++)
        out CFDATAREG, (x++)
        out CFDATAREG, (x++)
        out CFDATAREG, (x++)
        out CFDATAREG, (x++)
        out CFDATAREG, (x++)
        out CFDATAREG, (x++)
        dec r0
        jnz asm_cf_blkwrite_loop
    ret
};

var cf_blkwrite = func(num, headbuf, bodybuf) {
    cf_blkselect(num);

    # only 1 block
    cf_wait(CFRDY);
    outp(CFBLKCNTREG, 1);

    # issue "write" command
    cf_wait(CFRDY);
    outp(CFCMDREG, CFWRITECMD);

    # wait for CFRDY and CFDRQ
    cf_wait(CFRDY | CFDRQ);

    return asm_cf_blkwrite(headbuf, bodybuf);
};
