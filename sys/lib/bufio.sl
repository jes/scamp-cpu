# buffered i/o lib
#
# bio structure:
# 0:   fd (length = 1)
# 1:   buflen (1)
# 2:   bufpos (1)
# 3:   mode (1)
# 4..: buffer (BIO_BUFSZ)
#
# TODO: [nice] line-buffer on terminals

include "malloc.sl";
include "stdio.sl";
include "xprintf.sl";
include "xscanf.sl";

var BIO_BUFSZ = 254; # align with block size on disk
var buf_EOF = 0;

# "mode" should be O_READ or O_WRITE
var bfdopen = func(fd, mode) {
    var bio = malloc(BIO_BUFSZ + 4);
    *bio = fd;
    bio[1] = 0;
    bio[2] = 0;
    bio[3] = mode;

    return bio;
};

# "mode" should be O_READ or O_WRITE
var bopen = func(file, mode) {
    var fd = open(file, mode);
    if (fd < 0) return 0;
    return bfdopen(fd, mode);
};

var bflush = func(bio) {
    var fd = bio[0];
    var bufpos = bio[2];
    var mode = bio[3];

    if (!(mode & O_WRITE)) return 0;

    # TODO: [bug] error-check?
    write(fd, bio+4, bufpos);
    bio[2] = 0;
};

# free without closing the underlying fd
var bfree = func(bio) {
    bflush(bio);
    free(bio);
};

var bclose = func(bio) {
    var fd = bio[0];
    bfree(bio);
    close(fd);
};

# grab a new block of data from bio (internal; not for library users)
var _bslurp = func(bio) {
    var fd = bio[0];

    bio[2] = 0; # bufpos
    bio[1] = read(fd, bio+4, BIO_BUFSZ);
    if (bio[1] < 0) {
        fprintf(2, "bread %d: %s\n", [fd, strerror(bio[1])]);
        bio[1] = 0;
    };
};

#var bgetc = func(bio) {
#    var buflen = bio[1];
#    var bufpos = bio[2];
#    if (bufpos == buflen) _bslurp(bio);
#    buflen = bio[1];
#    bufpos = bio[2];
#    if (buflen == 0) { buf_EOF=1; return EOF; };
#    var ch = *(bio+4+bufpos);
#    bio[2] = bufpos+1;
#    return ch;
#};
#
# usage: bgetc(bio)
var bgetc = asm {
    pop x
    ld (bgetc_bio), x # bio

    inc x
    ld r2, (x) # buflen
    inc x
    ld r3, (x) # bufpos

    # if (bufpos == buflen)
    cmp r2, r3
    jnz bgetc_nextchar
    #   _bslurp(bio);
    ld x, r254
    push x
    ld x, (bgetc_bio)
    push x
    call (__bslurp)
    pop x
    ld r254, x
    ld x, (bgetc_bio)

    # refresh buflen,bufpos
    inc x
    ld r2, (x) # buflen
    inc x
    ld r3, (x) # bufpos

    bgetc_nextchar:
    # if (buflen == 0) buf_EOF=1; return EOF;
    test r2
    jnz bgetc_not_eof
    ld (_buf_EOF), 1
    ld r0, (_EOF)
    ret

    bgetc_not_eof:

    # ch = *(bio+4+bufpos)
    ld x, (bgetc_bio)
    add x, 4
    add x, r3
    ld r0, (x)

    # bufpos++
    inc r3
    ld x, (bgetc_bio)
    add x, 2
    ld (x), r3

    ret

    bgetc_bio: .word 0
};

# read at most size-1 characters into s, and terminate with a 0
# return s if any chars were read
# return 0 if EOF was reached with no chars
#var bgets = func(bio, s, size) {
#    var ch = 0;
#    var len = 0;
#
#    while (ch != '\n' && len < size) {
#        ch = bgetc(bio);
#        if (ch < 0) break;
#        s[len++] = ch;
#    };
#
#    s[len] = 0;
#
#    if (len == 0)
#        return 0;
#
#    return s;
#};
var bgets = asm {
    pop x
    ld (bgets_size), x
    pop x
    ld (bgets_s), x
    pop x
    ld (bgets_bio), x

    ld r0, 0 # ch
    ld (bgets_len), 0

    # stash return address
    ld x, r254
    push x

    bgets_loop:
        # ch = bgetc(bio);
        ld x, (bgets_bio)
        push x
        call (_bgetc)

        # if (ch < 0) break;
        test r0
        jlt bgets_done

        # s[len++] = ch;
        ld x, (bgets_s)
        add x, (bgets_len)
        ld (x), r0
        inc (bgets_len)

        # if (ch == '\n') break;
        cmp r0, 10
        jz bgets_done

        # if (len < size) continue;
        ld x, (bgets_len)
        cmp x, (bgets_size)
        jlt bgets_loop
    bgets_done:

    # s[len] = 0;
    ld x, (bgets_s)
    add x, (bgets_len)
    ld (x), 0

    # if (len == 0)
    test (bgets_len)
    jnz bgets_ret_s
    #   return 0;
    ld r0, 0
    pop x
    jmp x

    bgets_ret_s:

    # return s;
    ld r0, (bgets_s)
    pop x
    jmp x

    bgets_s: .word 0
    bgets_len: .word 0
    bgets_bio: .word 0
    bgets_size: .word 0
};

#var bputc = func(bio, ch) {
#    var bufpos = bio[2];
#    *(bio+4+bufpos) = ch;
#    bufpos++;
#    bio[2] = bufpos;
#    if (bufpos == BIO_BUFSZ) bflush(bio);
#};
#
# usage: bputc(bio, ch)
var bputc = asm {
    pop x
    ld r2, x # ch
    pop x
    ld r1, x # bio

    ld r3, r1
    add r3, 2 # r3 is bio+2, i.e. pointer to bufpos
    # dereference bufpos pointer into r5
    ld x, (r3)
    ld r5, x

    ld r4, r1
    add r4, 4
    add r4, r5
    # r4 = address for next char (bio+4+bufpos)

    # write char to buffer
    ld x, r2
    ld (r4), x

    # increment bufpos and store back to bio object
    ld x, r5
    inc x
    ld (r3), x

    # if (bufpos == BIO_BUFSZ) bflush(bio)
    sub x, 254 # BIO_BUFSZ
    jz bputc_bflush
    ret

    bputc_bflush:
        # tail call bflush(bio)
        ld x, r1
        push x
        jmp (_bflush)
};

#var bputs = func(bio, str) {
#    while (*str)
#        bputc(bio, *(str++));
#};
var bputs = asm {
    pop x # str
    ld (bputs_str), x
    pop x # bio
    ld (bputs_bio), x

    ld x, r254
    push x # backup return address

    bputs_loop:
        ld x, (bputs_str)
        test (x)
        jz bputs_ret

        ld x, (bputs_bio)
        push x

        ld x, ((bputs_str))
        push x

        call (_bputc)

        inc (bputs_str)
        jmp bputs_loop

    bputs_ret:
        pop x
        jmp x

    bputs_str: .word 0
    bputs_bio: .word 0
};

var bread = func(bio, buf, sz) {
    var n = 0;
    var ch;

    while (sz--) {
        buf_EOF = 0;
        ch = bgetc(bio);
        if (ch == EOF && buf_EOF) return n;
        *(buf++) = ch;
        n++;
    };

    return n;
};

#var bwrite = func(bio, buf, sz) {
#    var n = sz;
#    while (n--) bputc(bio, *(buf++));
#    return sz; # TODO: [bug] what if there's an error?
#};
var bwrite = asm {
    pop x
    ld (bwrite_sz), x
    ld (bwrite_n), x
    pop x
    ld (bwrite_buf), x
    pop x
    ld (bwrite_bio), x # bio

    # stash return address
    ld x, r254
    push x

    # do nothing if sz == 0
    test (bwrite_sz)
    jz bwrite_ret

    bwrite_loop:
        ld x, (bwrite_bio)
        push x

        ld x, ((bwrite_buf))
        push x

        call (_bputc)

        inc (bwrite_buf)
        dec (bwrite_n)
        jnz bwrite_loop

    bwrite_ret:
        ld r0, (bwrite_sz)
        pop x
        jmp x

    bwrite_n: .word 0
    bwrite_sz: .word 0
    bwrite_buf: .word 0
    bwrite_bio: .word 0
};

var bprintf_bio;
var bprintf = func(bio, fmt, args) {
    bprintf_bio = bio;
    return xprintf(fmt, args, func(ch) {
        bputc(bprintf_bio, ch);
    });
};

var bscanf_bio;
var bscanf = func(bio, fmt, args) {
    bscanf_bio = bio;
    return xscanf(fmt, args, func() {
        return bgetc(bscanf_bio);
    });
};
