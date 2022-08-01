var b = func(name, fn) {
    htput(SYMBOLS, name, name);
    htput(GLOBALS, name, cons(BUILTIN, fn));
};
b("null?", func(args) {
    needargs(1, args);
    if (car(args) == _NIL) return _T else return _NIL;
});
b("symbol?", func(args) {
    needargs(1, args);
    if (type(car(args)) == SYMBOL) return _T else return _NIL;
});
b("int?", func(args) {
    needargs(1, args);
    if (type(car(args)) == INT) return _T else return _NIL;
});
b("bigint?", func(args) {
    needargs(1, args);
    if (type(car(args)) == BIGINT) return _T else return _NIL;
});
b("vector?", func(args) {
    needargs(1, args);
    if (type(car(args)) == VECTOR) return _T else return _NIL;
});
b("string?", func(args) {
    needargs(1, args);
    if (type(car(args)) == STRING) return _T else return _NIL;
});
b("hash?", func(args) {
    needargs(1, args);
    if (type(car(args)) == HASH) return _T else return _NIL;
});
b("procedure?", func(args) {
    needargs(1, args);
    if (type(car(args)) == CLOSURE || type(car(args)) == BUILTIN) return _T else return _NIL;
});
b("pair?", func(args) {
    needargs(1, args);
    if (type(car(args)) == PAIR) return _T else return _NIL;
});
b("port?", func(args) {
    needargs(1, args);
    if (type(car(args)) == PORT) return _T else return _NIL;
});
b("eof-object?", func(args) {
    needargs(1, args);
    if (car(args) == _EOF) return _T else return _NIL;
});
b("cons", func(args) {
    needargs(2, args);
    return cons(car(args), car(cdr(args)));
});
b("car", func(args) {
    needargs(1, args);
    assert(car(args), "can't take car of empty list\n", 0);
    assert(type(car(args)) == PAIR, "can't take car of non-list\n", 0);
    return car(car(args));
});
b("cdr", func(args) {
    needargs(1, args);
    assert(car(args), "can't take cdr of empty list\n", 0);
    assert(type(car(args)) == PAIR, "can't take cdr of non-list\n", 0);
    return cdr(car(args));
});
b("+", func(args) {
    var n = 0;
    while (args) {
        assert(type(car(args)) == INT, "can't apply + to non-int\n", 0);
        n = n + intval(car(args));
        args = cdr(args);
    };
    return newint(n);
});
b("-", func(args) {
    if (!args) return newint(0);
    assert(type(car(args)) == INT, "can't apply - to non-int\n", 0);
    var n = intval(car(args));
    args = cdr(args);
    while (args) {
        assert(type(car(args)) == INT, "can't apply - to non-int\n", 0);
        n = n - intval(car(args));
        args = cdr(args);
    };
    return newint(n);
});
b("*", func(args) {
    var n = 1;
    while (args) {
        assert(type(car(args)) == INT, "can't apply * to non-int\n", 0);
        n = mul(n,intval(car(args)));
        args = cdr(args);
    };
    return newint(n);
});
b("/", func(args) {
    if (!args) return newint(0);
    assert(type(car(args)) == INT, "can't apply / to non-int\n", 0);
    var n = intval(car(args));
    args = cdr(args);
    while (args) {
        assert(type(car(args)) == INT, "can't apply / to non-int\n", 0);
        n = div(n,intval(car(args)));
        args = cdr(args);
    };
    return newint(n);
});
b("=", func(args) {
    if (!args) return _T;
    assert(type(car(args)) == INT, "can't apply = to non-int\n", 0);
    var a = intval(car(args));
    args = cdr(args);
    while (args) {
        assert(type(car(args)) == INT, "can't apply = to non-int\n", 0);
        if (intval(car(args)) != a) return _NIL;
        args = cdr(args);
    };
    return _T;
});
b(">", func(args) {
    if (!args) return _T;
    assert(type(car(args)) == INT, "can't apply > to non-int\n", 0);
    var a = intval(car(args));
    args = cdr(args);
    while (args) {
        assert(type(car(args)) == INT, "can't apply > to non-int\n", 0);
        if (a <= intval(car(args))) return _NIL;
        a = intval(car(args));
        args = cdr(args);
    };
    return _T;
});
b("<", func(args) {
    if (!args) return _T;
    assert(type(car(args)) == INT, "can't apply < to non-int\n", 0);
    var a = intval(car(args));
    args = cdr(args);
    while (args) {
        assert(type(car(args)) == INT, "can't apply < to non-int\n", 0);
        if (a >= intval(car(args))) return _NIL;
        a = intval(car(args));
        args = cdr(args);
    };
    return _T;
});
b(">=", func(args) {
    if (!args) return _T;
    assert(type(car(args)) == INT, "can't apply >= to non-int\n", 0);
    var a = intval(car(args));
    args = cdr(args);
    while (args) {
        assert(type(car(args)) == INT, "can't apply >= to non-int\n", 0);
        if (a < intval(car(args))) return _NIL;
        a = intval(car(args));
        args = cdr(args);
    };
    return _T;
});
b("<=", func(args) {
    if (!args) return _T;
    assert(type(car(args)) == INT, "can't apply <= to non-int\n", 0);
    var a = intval(car(args));
    args = cdr(args);
    while (args) {
        assert(type(car(args)) == INT, "can't apply <= to non-int\n", 0);
        if (a > intval(car(args))) return _NIL;
        a = intval(car(args));
        args = cdr(args);
    };
    return _T;
});
b("read", func(args) {
    var port = in;
    if (args) { # optional input port
        needargs(1, args);
        port = car(args);
        assert(type(port)==PORT, "can't read non-port\n", 0);
    };
    return READ(port);
});
b("open-input-file", func(args) {
    needargs(1, args);
    var name = car(args);
    assert(type(name) == STRING, "filename should be string\n", 0);
    var buf = bopen(stringstring(name), O_READ);
    if (!buf) return _NIL;
    return newport(buf);
});
b("close-input-port", func(args) {
    needargs(1, args);
    var port = car(args);
    assert(type(port) == PORT, "port should be port\n", 0);
    bclose(portbuf(port));
    portsetbuf(port, 0);
    return _NIL;
});
b("display", func(args) {
    needargs(1, args);
    PRINT(car(args));
    return _NIL;
});
b("newline", func(args) {
    needargs(0, args);
    puts("\n");
    return _NIL;
});
b("load", func(args) {
    needargs(1, args);
    var name = car(args);
    assert(type(name) == STRING, "filename should be string\n", 0);
    load(stringstring(name));
    return RET;
});
