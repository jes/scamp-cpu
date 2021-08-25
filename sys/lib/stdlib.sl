include "sys.sl";

# multiply 2 numbers from stack and return result in r0
# If this ever turns out to be a bottleneck, then we could potentially create
# a "tbso" instruction (along the lines of "tbsz" but with the test inverted), and:
#   tbso r2, 0x0001
#   jr+ 2 # skip over the "add"
#   add r0, r1
#   shl r1
#   tbso r2, 0x0002
#   jr+ 2 # skip over the "add"
#   add r0, r1
#   shl r1
#   ... etc. ...
var mul = asm {
    pop x
    ld r2, x # r2 = arg1
    pop x
    ld r1, x # r1 = arg2
    ld r0, 0 # result
    ld r3, 1 # (1 << i)

    mul_loop:
        ld x, r2 # x = arg1
        and x, r3 # x = arg1 & (1 << i)
        jz mul_cont # skip the "add" if this bit is not set
        add r0, r1 # result += resultn
    mul_cont:
        shl r1 # resultn += resultn
        shl r3 # i++
        jnz mul_loop # loop again if the mask has not overflowed

    ret
};

var powers_of_2 = asm {
    powers_of_2:
    .word 0x0001
    .word 0x0002
    .word 0x0004
    .word 0x0008
    .word 0x0010
    .word 0x0020
    .word 0x0040
    .word 0x0080
    .word 0x0100
    .word 0x0200
    .word 0x0400
    .word 0x0800
    .word 0x1000
    .word 0x2000
    .word 0x4000
    .word 0x8000
};

# compute:
#   *pdiv = num / denom
#   *pmod = num % denom
# Pass a null pointer if you want to discard one of the results
# https://en.wikipedia.org/wiki/Division_algorithm#Integer_division_(unsigned)_with_remainder
# usage: divmod(num, denom, pdiv, pmod)
var divmod = asm {
    ld x, sp
    ld r7, 1(x) # r7 = pmod
    ld r8, 2(x) # r8 = pdiv
    ld r9, 3(x) # r9 = denom
    ld r10, 4(x) # r10 = num

    ld r13, 0 # numerator negative?
    ld r14, 0 # denominator negative?

    # is numerator negative? Set r13 and make it positive
    test r10
    jge num_not_neg
    inc r13
    neg r10
    num_not_neg:

    # is denominator negative? Set r14 and make it positive
    test r9
    jge denom_not_neg
    inc r14
    neg r9
    denom_not_neg:

    ld r4, 0 # r4 = Q
    ld r5, 0 # r5 = R
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

    # if exactly one of numerator and denominator are negative, quotient is negative
    sub r14, r13
    jz positive_quotient
    neg r4
    positive_quotient:

    # if numerator is negative, remainder is negative
    test r13
    jz positive_numerator
    neg r5
    positive_numerator:

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

var div = func(num, denom) {
    var d;
    divmod(num, denom, &d, 0);
    return d;
};

var mod = func(num, denom) {
    var m;
    divmod(num, denom, 0, &m);
    return m;
};

# >>8 1 arg from the stack and return the result in r0
var shr8 = asm {
    pop x
    ld r0, x
    ld r1, r254 # stash return address
    ld r254, 0
    tbsz r0, 0x8000
    sb r254, 0x80
    tbsz r0, 0x4000
    sb r254, 0x40
    tbsz r0, 0x2000
    sb r254, 0x20
    tbsz r0, 0x1000
    sb r254, 0x10
    tbsz r0, 0x0800
    sb r254, 0x08
    tbsz r0, 0x0400
    sb r254, 0x04
    tbsz r0, 0x0200
    sb r254, 0x02
    tbsz r0, 0x0100
    sb r254, 0x01
    ld r0, r254
    jmp r1 # return
};

# usage: shl(i,n)
# compute "i << n", return it in r0
var shl = asm {
    pop x
    ld r1, 15
    sub r1, x # r1 = 15 - n

    pop x
    ld r0, x # r0 = i

    # kind of "Duff's device" way to get a variable
    # number of left shifts
    jr+ r1

    shl r0
    shl r0
    shl r0
    shl r0
    shl r0
    shl r0
    shl r0
    shl r0
    shl r0
    shl r0
    shl r0
    shl r0
    shl r0
    shl r0
    shl r0

    ret
};

var itoa_alphabet = "0123456789abcdefghijklmnopqrstuvwxyz";
var itoa_space = "................."; # static 18-word buffer

# returns pointer to static buffer
# "base" should range from 2 to 36
# unsigned itoa
var utoabase = func(num, base) {
    var s = itoa_space+17;
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
        *--s = itoa_alphabet[m];
        num = d;
    };

    return s;
};

# signed itoa
var itoabase = func(num, base) {
    var neg = 0;

    if (num < 0) {
        neg = 1;
        num = -num;
    };

    var s = utoabase(num, base);

    if (neg) *--s = '-'; # XXX: abuse knowledge that utoabase() returns static pointer in itoa_space

    return s;
};

# these return pointers into a static buffer (itoa_space)
var itoa = func(num) return itoabase(num, 10);
var utoa = func(num) return utoabase(num, 10);

var islower = func(ch) return ch >= 'a' && ch <= 'z';
var isupper = func(ch) return ch >= 'A' && ch <= 'Z';
var isalpha = func(ch) return (ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z');
var isdigit = func(ch) return ch >= '0' && ch <= '9';
var isalnum = func(ch) {
    if (ch >= 'a' && ch <= 'z') return 1;
    if (ch >= 'A' && ch <= 'Z') return 1;
    return (ch >= '0' && ch <= '9');
};
var iswhite = func(ch) return ch == ' ' || ch == '\t' || ch == '\r' || ch == '\n';
var iscntrl = func(ch) return ch < ' ' || ch == 127;
var tolower = func(ch) {
    if (isupper(ch)) return ch - 'A' + 'a';
    return ch;
};

# return index of ch in alphabet, or 0 if not present; note 0 is indistinguishable
# from "present at index 0"
#var stridx = func(alphabet, ch) {
#    var i = 0;
#    while (alphabet[i])) {
#        if (alphabet[i]) == ch) return i;
#        i++;
#    };
#    return 0;
#};
#
# usage: stridx(alphabet, ch)
var stridx = asm {
    pop x
    ld r1, x # ch
    pop x
    ld r2, x # alphabet

    ld r0, 0xffff # i (start at -1, increment to 0 on first loop)

    stridx_loop:
        inc r0
        ld x, (r2++)

        # if (r2) is 0, we didn't find r1
        test x
        jz stridx_notfound

        # if x != r1, loop again
        sub x, r1
        jnz stridx_loop

    # x == r1, return r0
    ret

    stridx_notfound:
        ld r0, 0
        ret
};

var atoibase = func(s, base) {
    var v = 0;
    var neg = 0;
    if (*s == '-') {
        neg = 1;
        s++;
    };
    var n;
    while (*s) {
        n = stridx(itoa_alphabet, tolower(*s));
        if (n == 0 && *s != *itoa_alphabet) break; # digit doesn't exist
        if (n >= base) break; # digit out of range for base
        v = mul(v, base) + n;
        s++;
    };
    if (neg) v = -v;
    return v;
};

var atoi = func(s) return atoibase(s, 10);

# usage: inp(addr)
var inp = asm {
    pop x
    in r0, x
    ret
};

# usage: outp(addr, value)
var outp = asm {
    pop x
    ld r0, x
    pop x
    out x, r0
    ret
};

var car = func(tuple) { return *tuple; };
var cdr = func(tuple) { return tuple[1]; };
var setcar = func(tuple,a) { *tuple = a; };
var setcdr = func(tuple,b) { tuple[1] = b; };

# internal, used for quicksort;
# return the index of the pivot element
# XXX: we assume len>1
var _partition = func(arr, len, cmp) {
    # TODO: [perf] what's the best way to choose a pivot? Wikipedia says:
    #
    # Specifically, the expected number of comparisons needed to sort n elements
    # with random pivot selection is 1.386 n log n. Median-of-three pivoting
    # brings this down to Cn,2 = 1.188 n log n, at the expense of a three-
    # percent increase in the expected number of swaps. An even stronger
    # pivoting rule, for larger arrays, is to pick the ninther, a recursive
    # median-of-three (Mo3), defined as
    # ninther(a) = median(Mo3(first 1/3 of a), Mo3(middle 1/3 of a), Mo3(final 1/3 of a))
    #
    # https://en.wikipedia.org/wiki/Quicksort#Choice_of_pivot
    #
    # It's likely that the best choice in SCAMP depends on how efficiently
    # we can calculate the pivot, more than on the actual number of comparisons
    # required. (And calculating mod(random(),len) is bad).

    # XXX: pivot choice must avoid the final element to ensure termination
    var pivot;
    if (len <= 8)
        pivot = arr[len-2]
    else
        pivot = arr[mod(random(),len-1)];

    var l = -1;
    var r = len;
    var tmp;
    while (1) {
        l++;
        while (cmp(arr[l], pivot) < 0) l++;

        r--;
        while (cmp(arr[r], pivot) > 0) r--;

        if (l >= r) return r;

        tmp = arr[r];
        arr[r] = arr[l];
        arr[l] = tmp;
    };
};

# sort array "arr" of "len" 1-word elements in-place;
# cmp(a,b) should be a function that returns a value less than, equal to, or
# greater than 0 if a is respectively less than, equal to, or greater than b;
# e.g. sort an array of 10 string pointers with:
#   sort(strings, 10, strcmp);
var sort = func(arr, len, cmp) {
    if (len <= 1) return 0;

    var p = _partition(arr, len, cmp);

    sort(arr, p+1, cmp);
    sort(arr+p+1, len-p-1, cmp);
};
