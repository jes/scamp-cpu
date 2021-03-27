# string buffer

include "grarr.sl";

var sbnew = grnew;
var sbfree = grfree;
var sbbase = func(sb) {
    grpush(sb,0); grpop(sb); # make sure string is nul-terminated
    return grbase(sb);
};
var sblen = grlen;
var sbputc = grpush;
var sbclear = func(sb) {
    grtrunc(sb, 0);
};

var sbputs = func(sb, s) {
    while (*s) {
        sbputc(sb, *s);
        s++;
    };
};

var sbprintf_sb;
var sbprintf = func(sb, fmt, args) {
    sbprintf_sb = sb;
    return xprintf(fmt, args, func(ch) {
        sbputc(sbprintf_sb, ch);
    });
};
