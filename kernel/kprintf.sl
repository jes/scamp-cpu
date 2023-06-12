# kernel printf: this should not be compiled into the "real" kernel because
# it takes up quite a lot of space, but it can be included as needed for
# debugging

include "util.sl";

# compute:
#   *pdiv = num / denom
#   *pmod = num % denom
# Pass a null pointer if you want to discard one of the results
# https://en.wikipedia.org/wiki/Division_algorithm#Integer_division_(unsigned)_with_remainder
var divmod = asm {
    ld x, sp
    ld r7, 1(x) # r7 = pmod
    ld r8, 2(x) # r8 = pdiv
    ld r9, 3(x) # r9 = denom
    ld r10, 4(x) # r10 = num

    zero r4 # r4 = Q
    zero r5 # r5 = R
    ld r6, 15 # r6 = i

    # while (i >= 0)
    divmod_loop:
        # R = R+R
        shl r5

        # r11 = powers_of_2[i]
        ld x, powers_of_2
        add x, r6
        ld r11, (x)

        # if (num & powers_of_2[i]) R++;
        ld r12, r10
        and r12, r11
        jz divmod_cont1
        inc r5
        divmod_cont1:

        # if (R >= denom)
        ld r12, r5
        sub r12, r9 # r12 = R - denom
        jlt divmod_cont2
            # R = R - denom
            ld r5, r12
            # Q = Q | powers_of_2[i]
            or r4, r11
        divmod_cont2:

        # i--
        dec r6
        jge divmod_loop

    # if pdiv or pmod are null, they'll point to rom, so writing to them is a no-op
    # *pdiv = Q
    ld x, r8
    ld (x), r4
    # *pmod = R
    ld x, r7
    ld (x), r5
    # return
    ret 4
};

var itoa_alphabet = "0123456789abcdefghijklmnopqrstuvwxyz";
var itoa_space = "................."; # static 17-word buffer

# returns pointer to static buffer
# "base" should range from 2 to 36
var itoabase = func(num, base) {
    var s = itoa_space+16;
    var d;
    var m;

    *s = 0;

    # special case when num == 0
    if (num == 0) {
        *--s = '0';
        return s;
    };

    while (num != 0) {
        divmod(num, base, &d, &m);
        *--s = *(itoa_alphabet + m);
        num = d;
    };

    return s;
};

# returns pointer to static buffer
var itoa = func(num) return itoabase(num, 10);

var kprintf = func(fmt, args) {
    var p = fmt;
    var argidx = 0;

    while (*p) {
        if (*p == '%') {
            p++;
            if (!*p) return 0;
            if (*p == '%') {
                kputc('%');
            } else if (*p == 'c') {
                kputc(args[argidx++]);
            } else if (*p == 's') {
                kputs(args[argidx++]);
            } else if (*p == 'd') {
                kputs(itoa(args[argidx++]));
            } else if (*p == 'x') {
                kputs(itoabase(args[argidx++],16));
            } else {
                kputs("<???>");
            }
        } else {
            if (*p == '\n') kputc('\r');
            kputc(*p);
        };
        p++;
    };
};
