# RNG

var shr9 = asm {
    pop x
    ld r0, x
    ld r1, r254 # stash return address
    ld r254, 0
    tbsz r0, 0x8000
    sb r254, 0x40
    tbsz r0, 0x4000
    sb r254, 0x20
    tbsz r0, 0x2000
    sb r254, 0x10
    tbsz r0, 0x1000
    sb r254, 0x08
    tbsz r0, 0x0800
    sb r254, 0x04
    tbsz r0, 0x0400
    sb r254, 0x02
    tbsz r0, 0x0200
    sb r254, 0x01
    ld r0, r254
    jmp r1 # return
};

sys_random = func() {
    # XXX: output 0 after 0x1234 to get up to full 2^16 period
    if (rngstate == 0x1234) return 0;
    if (rngstate == 0) rngstate = 0x1234;

    rngstate = rngstate ^ shl(rngstate, 13);
    rngstate = rngstate ^ shr9(rngstate);
    rngstate = rngstate ^ shl(rngstate, 7);

    return rngstate & 0x7fff;
};
