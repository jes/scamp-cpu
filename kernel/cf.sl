# CompactFlash device handling
#
# TODO: [nice] currently we assume the bootrom initialised the card, maybe
#       should explicitly set the state we assume?
# TODO: [nice] support multiple cards, so that one can be used as removable
#       storage?

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

    kpanic("CompactFlash timeout");
};

var cf_blkselect = func(num) {
    # least-significant byte
    cf_wait(CFRDY);
    outp(CFBLKNUMREG, num&0xff);

    # most-significant byte
    cf_wait(CFRDY);
    outp(CFCYLLOREG, shr8(num));
};

var cf_blkread = func(num, buf) {
    cf_blkselect(num);

    # only 1 block
    cf_wait(CFRDY);
    outp(CFBLKCNTREG, 1);

    # issue "read" command
    cf_wait(CFRDY);
    outp(CFCMDREG, CFREADCMD);

    # wait for CFRDY and CFDRQ
    cf_wait(CFRDY | CFDRQ);

    var n = BLKSZ;
    while (n--) {
        # TODO: [perf] could we instead work out exactly how fast we can read,
        # and just do a bunch of "slownop" instead of properly polling the
        # card status?

        # TODO: [bug] do we need to cf_wait(CFRDY | CFDRQ) each time?
        *(buf++) = inp(CFDATAREG);
    };
};

var cf_blkwrite = func(num, buf) {
    cf_blkselect(num);

    # only 1 block
    cf_wait(CFRDY);
    outp(CFBLKCNTREG, 1);

    # issue "write" command
    cf_wait(CFRDY);
    outp(CFCMDREG, CFWRITECMD);

    # wait for CFRDY and CFDRQ
    cf_wait(CFRDY | CFDRQ);

    var n = BLKSZ;
    while (n--) {
        # TODO: [perf] could we instead work out exactly how fast we can write,
        # and just do a bunch of "slownop" instead of properly polling the
        # card status?

        # TODO: [bug] do we need to cf_wait(CFRDY | CFDRQ) each time?
        outp(CFDATAREG, *(buf++));
    };
};
