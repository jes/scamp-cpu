# generic scanf() implementation

include "stdlib.sl";

# usage: xscanf(fmt, [ptr1, ptr2, ...], getc_cb);
# format string:
#  - whitespace skips over any whitespace
#  - literal characters have to match literally
#  - %c writes a literal character into the corresponding pointer
#  - %s matches non-whitespace characters, and writes an unbounded
#    (!) string into memory starting at the corresponding pointer
#  - %d writes an integer
#  - %% matches a literal "%" and doesn't write it anywhere
# return the number of items matched (not counting "%%")
# TODO: [nice] automatically allocate buffer for string?
# TODO: [nice] field width specifier
# TODO: [nice] %x?
# TODO: [nice] can we support extensible formats like with xpreg()?
# TODO: [bug] always consumes 1 character more than requested
var xscanf_bufsz = 64;
var xscanf_buf = asm { .gap 64 };
var xscanf = func(fmt, args, getc_cb) {
    var ch = getc_cb();
    var fmtch;
    var nmatch = 0;
    var p;
    var ok;

    while (*fmt && (ch != EOF)) {
        fmtch = *(fmt++);

        if (iswhite(fmtch)) {
            while (iswhite(ch)) ch = getc_cb();
        } else if (fmtch == '%') {
            if (!*fmt) break;
            fmtch = *(fmt++);

            if (fmtch == '%') {
                if (ch != '%') break;
                ch = getc_cb();
            } else if (fmtch == 'c') {
                **(args++) = ch;
                ch = getc_cb();
                nmatch++;
            } else if (fmtch == 'd') {
                p = xscanf_buf;
                if (ch == '-') {
                    *(p++) = ch;
                    ch = getc_cb();
                } else if (isdigit(ch)) {
                    ok = 1;
                    *(p++) = ch;
                    ch = getc_cb();
                };
                # TODO: [bug] buffer overflow of xscanf_buf
                while (isdigit(ch)) {
                    ok = 1;
                    *(p++) = ch;
                    ch = getc_cb();
                };
                if (!ok) break;
                *p = 0;
                **(args++) = atoi(xscanf_buf);
                nmatch++;
            } else if (fmtch == 's') {
                p = *args;
                while (!iswhite(ch) && (ch != EOF)) {
                    *(p++) = ch;
                    ch = getc_cb();
                };
                *p = 0;
                args++;
                nmatch++;
            };
        } else if (fmtch == ch) {
            ch = getc_cb();
        } else {
            break;
        };
    };

    return nmatch;
};
