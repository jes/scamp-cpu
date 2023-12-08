# Regex implementation for SCAMP, based on pikevm from re1 ( https://code.google.com/archive/p/re1/source )

include "grarr.sl";
include "parse.sl";
include "malloc.sl";

# Forward declarations:

# Parsing
var _reparse;
var _reparse1;
var capture;
var maybestar;

# Compiling
var _recompile;

const SUBSZ = 20;

# NFA matching
var _pikevm;

## API

# compile the given regex
var renew = func(str) {
    var tree = _reparse(str);
    if (!tree) return 0;
    var vm = _recompile(tree);
    # TODO: free the tree
    # TODO: do we need any more data structures?
    return vm;
};

# free the given regex
var refree = func(re) {
    # TODO: how do we free this?
    free(re);
};

# try to match the given regex against the string;
# return 1 if it matched, 0 otherwise
var rematch = func(re, str) {
    return _pikevm(re, str);
};

# return a pointer to the i'th capture from the last match,
# full match is i=0
var recap_sub = malloc(SUBSZ);
var recap = func(i) {
    return recap_sub[i+i];
};
# return a pointer to the character immediately after the i'th
# capture from the last match
# full match is i=0
var recapend = func(i) {
    return recap_sub[i+i+1];
};

## PARSING

# a tree element is a node type, plus other fields depending
# on the node type

# field indexes
const RE_TYPE = 0;
const RE_LEFT = 1;
const RE_RIGHT = 2;

# node types
const RE_LIT = 0;
const RE_ALT = 1;
const RE_CAT = 2;
const RE_STAR = 3;
const RE_PLUS = 4;
const RE_CAP = 5;
const RE_SPECIAL = 6;

# turn the given regex into an AST
var reparse_str;
var reparse_caps;
_reparse = func(str) {
    reparse_str = str;
    reparse_caps = 1;
    # TODO: support anchoring
    return cons3(RE_CAP, _reparse1(), 0);
};

capture = func(a) {
    return cons3(RE_CAP, a, reparse_caps++);
};

var literal = func(ch) {
    return cons(RE_LIT, ch);
};

var concat = func(a, b) {
    b = maybestar(b);
    if (!a) return b;
    return cons3(RE_CAT, a, b);
};

var alternate = func(a, b) {
    return cons3(RE_ALT, a, b);
};

maybestar = func(a) {
    if (*reparse_str == '*') {
        reparse_str++;
        return cons(RE_STAR, a);
    } else if (*reparse_str == '+') {
        reparse_str++;
        return cons(RE_PLUS, a);
    } else {
        return a;
    };
};

var is_oneof = func(ch, s) {
    while (*s) {
        if (*s == ch) return 1;
        s++;
    };
    return 0;
};

var charset = func() {
    var fn = is_oneof;
    if (*reparse_str == '^') {
        reparse_str++;
        fn = func(ch, s) return !is_oneof(ch, s);
    };
    var ch;
    var chars = grnew();
    while (1) {
        ch = *(reparse_str++);
        if (!ch || ch == ']') break;
        # TODO: ranges, escapes?
        grpush(chars, ch);
    };
    grpush(chars, 0);
    return cons3(RE_SPECIAL, grbase(chars), fn);
};

var DOT = [RE_SPECIAL, 0, func(ch, s) return 1];
var DIGIT = [RE_SPECIAL, 0, func(ch, s) return isdigit(ch) ];
var WORD = [RE_SPECIAL, 0, func(ch, s) {
    if (ch == '_') return 1;
    return isalnum(ch);
}];
var SPACE = [RE_SPECIAL, 0, func(ch, s) return iswhite(ch) ];
var NOTDIGIT = [RE_SPECIAL, 0, func(ch, s) return !isdigit(ch)];
var NOTWORD = [RE_SPECIAL, 0, func(ch, s) {
    if (ch == '_') return 0;
    return !isalnum(ch);
}];
var NOTSPACE = [RE_SPECIAL, 0, func(ch, s) return !iswhite(ch)];

_reparse1 = func() {
    var ch;
    var node = 0;
    var next;
    while (1) {
        ch = *(reparse_str++);
        if (!ch || ch == ')') return node
        else if (ch == '|') return alternate(node, _reparse1())
        else if (ch == '(') {
            if (reparse_str[0] == '?' && reparse_str[1] == ':') {
                # (?:...) non-capturing grouping
                reparse_str = reparse_str + 2;
                next = _reparse1();
            } else {
                next = capture(_reparse1())
            };
        } else if (ch == '[') next = charset()
        else if (ch == '.') next = DOT
        else if (ch == '\\') {
            ch = *(reparse_str++);
            if (!ch) break;
            if (ch == 'd') next = DIGIT
            else if (ch == 'w') next = WORD
            else if (ch == 's') next = SPACE
            else if (ch == 'D') next = NOTDIGIT
            else if (ch == 'W') next = NOTWORD
            else if (ch == 'S') next = NOTSPACE
            else next = literal(ch);
        } else next = literal(ch);
        node = concat(node, next);
    };
};

## COMPILING

var _GEN;

# instruction fields
const RE_OP = 0;
const RE_X = 1;
const RE_Y = 2;
const RE_GEN = 3;

# opcodes
const RE_CHAR = 0;
const RE_SPLIT = 1;
const RE_JMP = 2;
const RE_SAVE = 3;
const RE_MATCH = 4;
# RE_SPECIAL = 6;

# return the number of VM instructions the given tree will turn into
var _recount = func(tree) {
    if (!tree) return 0;

    var typ = tree[RE_TYPE];

    if (typ == RE_LIT) return 1
    else if (typ == RE_ALT) return 2 + _recount(tree[RE_LEFT]) + _recount(tree[RE_RIGHT])
    else if (typ == RE_CAT) return _recount(tree[RE_LEFT]) + _recount(tree[RE_RIGHT])
    else if (typ == RE_STAR) return 2 + _recount(tree[RE_LEFT])
    else if (typ == RE_PLUS) return 1 + _recount(tree[RE_LEFT])
    else if (typ == RE_CAP) return 2 + _recount(tree[RE_LEFT])
    else if (typ == RE_SPECIAL) return 1
    else {
        die("_recount: unimplemented node type: %d\n", [typ]);
    };
};

var _PC;
# emit code (into _PC) to implement the given tree
var _reemit = func(tree) {
    if (!tree) return 0;

    var typ = tree[RE_TYPE];

    var p1; var p2;

    if (typ == RE_LIT) {
        _PC[RE_OP] = RE_CHAR;
        _PC[RE_X] = tree[RE_LEFT];
        _PC = _PC + 4;
    } else if (typ == RE_ALT) {
        _PC[RE_OP] = RE_SPLIT;
        p1 = _PC; _PC = _PC + 4;
        p1[RE_X] = _PC;
        _reemit(tree[RE_LEFT]);
        _PC[RE_OP] = RE_JMP;
        p2 = _PC; _PC = _PC + 4;
        p1[RE_Y] = _PC;
        _reemit(tree[RE_RIGHT]);
        p2[RE_X] = _PC;
    } else if (typ == RE_CAT) {
        _reemit(tree[RE_LEFT]);
        _reemit(tree[RE_RIGHT]);
    } else if (typ == RE_STAR) {
        _PC[RE_OP] = RE_SPLIT;
        p1 = _PC; _PC = _PC + 4;
        p1[RE_X] = _PC;
        _reemit(tree[RE_LEFT]);
        _PC[RE_OP] = RE_JMP;
        _PC[RE_X] = p1;
        _PC = _PC + 4;
        p1[RE_Y] = _PC;
    } else if (typ == RE_PLUS) {
        p1 = _PC;
        _reemit(tree[RE_LEFT]);
        _PC[RE_OP] = RE_SPLIT;
        _PC[RE_X] = p1;
        _PC[RE_Y] = _PC + 4;
        _PC = _PC + 4;
    } else if (typ == RE_CAP) {
        _PC[RE_OP] = RE_SAVE;
        _PC[RE_X] = tree[RE_RIGHT] + tree[RE_RIGHT];
        _PC = _PC + 4;
        _reemit(tree[RE_LEFT]);
        _PC[RE_OP] = RE_SAVE;
        _PC[RE_X] = tree[RE_RIGHT] + tree[RE_RIGHT] + 1;
        _PC = _PC + 4;
    } else if (typ == RE_SPECIAL) {
        _PC[RE_OP] = RE_SPECIAL;
        _PC[RE_X] = tree[RE_LEFT];
        _PC[RE_Y] = tree[RE_RIGHT];
        _PC = _PC + 4;
    } else {
        die("_reemit: unimplemented node type: %d\n", [typ]);
    };
};

# turn the given AST into VM code
_recompile = func(tree) {
    var n = _recount(tree) + 1;
    # each instruction is 4 words: an opcode, plus 2 words whose
    # meaning depends on the opcode (TODO: could easily be
    # variable-length), and a "generation" counter for efficiency
    var code = malloc(n+n+n+n);
    _PC = code;
    _reemit(tree);
    _PC[RE_OP] = RE_MATCH;
    return code;
};

## NFA MATCHING

var subs2free = grnew();

var subnew = func() {
    var p = zmalloc(SUBSZ);
    grpush(subs2free, p);
    return p;
};

var freesubs = func() {
    grwalk(subs2free, free);
    grtrunc(subs2free, 0);
};

var addthread = func(list, pc, sub, strp) {
    # TODO: is 16-bit generation counter big enough?
    if (pc[RE_GEN] == _GEN) return 0;
    pc[RE_GEN] = _GEN;
    var sub2;
    var op = pc[RE_OP];
    if (op == RE_JMP) {
        addthread(list, pc[RE_X], sub, strp);
    } else if (op == RE_SPLIT) {
        addthread(list, pc[RE_X], sub, strp);
        addthread(list, pc[RE_Y], sub, strp);
    } else if (op == RE_SAVE) {
        sub2 = subnew();
        memcpy(sub2, sub, SUBSZ);
        sub2[pc[RE_X]] = strp;
        addthread(list, pc+4, sub2, strp);
    } else {
        grpush(list, pc);
        grpush(list, sub);
    }
};

_pikevm = func(re, str) {
    var clist = grnew();
    var nlist = grnew();

    # TODO: do we need to reset all the _GEN now, if 16 bits is
    # not enough?
    # note the only _GEN that matter are in the instructions
    # that can actually get added to clist, which are only 'match'
    # and 'char', and the number of those instructions also
    # puts an upper bound on the size of clist, so long-term we
    # may prefer to preallocate clist/nlist as part of the
    # compilation step, and not have to allocate them at
    # match time - and the same for 'subs' because there are a
    # bounded number of subs needed, and at compile time we
    # also know the number of capturing groups instead of guessing
    # at 10

    _GEN++;

    var i;
    var pc;
    var sub;
    var op;

    var fn;
    var arg;

    # TODO: zmalloc(SUBSZ) needs some way to track subs allocations so we can free them later
    addthread(clist, re, subnew(), str);
    while (1) {
        if (grlen(clist) == 0) break;
        _GEN++;
        i = 0;
        while (i != grlen(clist)) {
            pc = grget(clist, i);
            sub = grget(clist, i+1);
            i = i + 2;
            op = *pc;

            if (op == RE_CHAR) {
                if (*str == pc[RE_X])
                    addthread(nlist, pc+4, sub, str+1);
            } else if (op == RE_SPECIAL) {
                arg = pc[RE_X];
                fn = pc[RE_Y];
                if (fn(*str, arg))
                    addthread(nlist, pc+4, sub, str+1);
            } else if (op == RE_MATCH) {
                memcpy(recap_sub, sub, SUBSZ);
                grfree(clist); grfree(nlist);
                freesubs();
                return 1;
            } else {
                die("_pikevm: unimplemented opcode: %d at pc=%04x\n", [op, pc]);
            };
        };
        swap(&clist, &nlist);
        grtrunc(nlist, 0);
        if (!*str) break; # XXX: this loop deliberately examines the trailing nul
        str++;
    };

    memset(recap_sub, 0, SUBSZ);
    grfree(clist); grfree(nlist);
    freesubs();
    return 0;
};
