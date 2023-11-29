# Regex implementation for SCAMP, based on pikevm from re1 ( https://code.google.com/archive/p/re1/source )

include "grarr.sl";
include "parse.sl";

# Forward declarations:

# Parsing
var _reparse;
var _reparse1;

# Compiling
var _recompile;

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
# starting at i=0;
# note this can modify 1 character of the matched string in-place,
# to insert a trailing nul;
# call recap(-1) to explicitly undo the modifications
var recap_sub = asm { .gap 20 }; # TODO: more than 10 capture groups? at least give an error instead of silently breaking
var recap_mod;
var recap_char;
var recap = func(i) {
    # first, restore previous modification
    if (recap_mod) *recap_mod = recap_char;
    if (i == -1) return 0;
    
    # grab out the captures
    var start = recap_sub[i+i];
    var end = recap_sub[i+i+1];

    # insert a trailing nul that we can undo later
    recap_mod = end+1;
    recap_char = *recap_mod;
    *recap_mod = 0;

    return start;
};

## PARSING

# a tree element is 3 words: a node type, plus 2 others depending
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
const RE_CAP = 4;
var typname = ["lit", "alt", "cat", "star", "cap"];

# turn the given regex into an AST
var reparse_str;
var reparse_caps;
_reparse = func(str) {
    reparse_str = str;
    reparse_caps = 0;
    return _reparse1();
};

var capture = func(a) {
    return cons3(RE_CAP, a, reparse_caps++);
};

var literal = func(ch) {
    return cons3(RE_LIT, ch, 0);
};

var concat = func(a, b) {
    if (!a) return b;
    return cons3(RE_CAT, a, b);
};

var alternate = func(a, b) {
    return cons3(RE_ALT, a, b);
};

var maybestar = func(a) {
    if (*reparse_str == '*') {
        reparse_str++;
        return cons3(RE_STAR, a, 0);
    } else {
        return a;
    };
};

_reparse1 = func() {
    var ch;
    var node = 0;
    while (1) {
        ch = *(reparse_str++);
        if (!ch) break;
        if (ch == '|') {
            return maybestar(alternate(node, _reparse1()));
        } else if (ch == '(') {
            node = maybestar(concat(node, capture(_reparse1())));
        } else if (ch == ')') {
            return node;
        } else {
            node = concat(node, maybestar(literal(ch)));
        };
    };
    return node;
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

# return the number of VM instructions the given tree will turn into
var _recount = func(tree) {
    if (!tree) return 0;

    var typ = tree[RE_TYPE];

    if (typ == RE_LIT) return 1
    else if (typ == RE_ALT) return 2 + _recount(tree[RE_LEFT]) + _recount(tree[RE_RIGHT])
    else if (typ == RE_CAT) return _recount(tree[RE_LEFT]) + _recount(tree[RE_RIGHT])
    else if (typ == RE_STAR) return 2 + _recount(tree[RE_LEFT])
    else if (typ == RE_CAP) return 2 + _recount(tree[RE_LEFT])
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
    } else if (typ == RE_CAP) {
        _PC[RE_OP] = RE_SAVE;
        _PC[RE_X] = tree[RE_RIGHT] + tree[RE_RIGHT];
        _PC = _PC + 4;
        _reemit(tree[RE_LEFT]);
        _PC[RE_OP] = RE_SAVE;
        _PC[RE_X] = tree[RE_RIGHT] + tree[RE_RIGHT] + 1;
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
        sub2 = malloc(20);
        memcpy(sub2, sub, 20);
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

    # TODO: malloc(20) needs some way to track subs allocations so we can free them later
    addthread(clist, re, malloc(20), str);
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
            } else if (op == RE_MATCH) {
                memcpy(recap_sub, sub, 20);
                grfree(clist); grfree(nlist);
                # TODO: free allocated subs
                return 1;
            } else {
                die("_pikevm: unimplemented opcode: %d\n", [op]);
            };
        };
        swap(&clist, &nlist);
        grtrunc(nlist, 0);
        if (!*str) break; # XXX: this loop deliberately examines the trailing nul
        str++;
    };

    memset(recap_sub, 0, 20);
    grfree(clist); grfree(nlist);
    # TODO: free allocated subs
    return 0;
};
