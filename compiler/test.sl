# Test program for SLANG

include "stdio.sl";
include "stdlib.sl";
include "string.sl";
include "list.sl";

# recursive fibonacci
var rfib = func(n) {
    if (n <= 2)
        return 1
    else
        return rfib(n-1)+rfib(n-2);
};

# reverse the given string in-place
var strrev = func(s) {
    var ss = s;
    var p = s;

    while (*(p+1))
        p++;

    var ch;

    while (s < p) {
        ch = *p;
        *p = *s;
        *s = ch;
        --p;
        ++s;
    };

    return ss;
};

var optest = func() {
    var a = 0xaaaa;
    var b = 0x55aa;

    puts("Operators test:\n");

    puts("a="); puts(itoa(a)); puts("\n");
    puts("b="); puts(itoa(b)); puts("\n");
    puts("~a="); puts(itoa(~a)); puts("\n");
    puts("-b="); puts(itoa(-b)); puts("\n");
    puts("+a="); puts(itoa(+a)); puts("\n");
    puts("a+b="); puts(itoa(a+b)); puts("\n");
    puts("a-b="); puts(itoa(a-b)); puts("\n");
    puts("a&b="); puts(itoa(a&b)); puts("\n");
    puts("a|b="); puts(itoa(a|b)); puts("\n");
    puts("a^b="); puts(itoa(a^b)); puts("\n");
    puts("a&&b="); puts(itoa(a&&b)); puts("\n");
    puts("a||b="); puts(itoa(a||b)); puts("\n");
    puts("a&&0="); puts(itoa(a&&0)); puts("\n");
    puts("a||0="); puts(itoa(a||0)); puts("\n");
    puts("(-1 > 0)="); puts(itoa(-1>0)); puts("\n");
    puts("(-1 >= 0)="); puts(itoa(-1>=0)); puts("\n");
    puts("(-1 < 0)="); puts(itoa(-1<0)); puts("\n");
    puts("(-1 <= 0)="); puts(itoa(-1<=0)); puts("\n");
    puts("(32767>0)="); puts(itoa(32767>0)); puts("\n");
    puts("(32767>=0)="); puts(itoa(32767>=0)); puts("\n");
    puts("(32767<0)="); puts(itoa(32767<0)); puts("\n");
    puts("(32767<=0)="); puts(itoa(32767<=0)); puts("\n");
    puts("(32767>-2)="); puts(itoa(32767>-2)); puts("\n");
    puts("(32767>=-2)="); puts(itoa(32767>=-2)); puts("\n");
    puts("(32767<-2)="); puts(itoa(32767<-2)); puts("\n");
    puts("(32767<=-2)="); puts(itoa(32767<=-2)); puts("\n");

    var x = 5;
    var y = 10;
    puts("x="); puts(itoa(x)); puts("\n");
    puts("y="); puts(itoa(y)); puts("\n");
    puts("x>y-6="); puts(itoa(x>y-6)); puts("\n");

    puts("\n");
};

var fibtest = func() {
    var n = 0;
    var f1 = 1;
    var f2 = 0;
    var f3 = 0;

    puts("Fibonacci numbers:\n");

    while (n++ <= 22) {
        f3 = f1 + f2;
        f1 = f2;
        f2 = f3;

        # TODO: printf()
        puts("fib("); puts(itoa(n)); puts(") = ");
        puts(itoa(f3));
        puts("\n");

        puts("rfib("); puts(itoa(n)); puts(") = ");
        puts(itoa(rfib(n)));
        puts("\n");
    };

    puts("\n");
};

var strtest = func() {
    var s1 = "Hello, world!";

    puts("string: "); puts(s1); puts("\n");
    puts("reversed: "); puts(strrev(s1)); puts("\n");
    puts("re-reversed: "); puts(strrev(s1)); puts("\n");

    puts("cmp self: "); puts(itoa(strcmp(s1,s1))); puts("\n");
    puts("cmp hello world: "); puts(itoa(strcmp(s1,"Hello, world!"))); puts("\n");
    puts("cmp foo: "); puts(itoa(strcmp(s1,"foo"))); puts("\n");

    puts("length: "); puts(itoa(strlen(s1))); puts("\n");

    puts("\n");
};

var callputs = func(f) {
    puts(f());
};

var globule = 1;

var functest = func() {
    puts("Nested function calls/declarations:\n");

    callputs(func() { return "1. Hello, world\n" });

    var f = func(x) {
        return x() + x();
    };

    puts("2. 5 = "); puts(itoa(f(func() {
        globule++;
        return globule;
    })));
    puts("\n");

    # this function produces no output, but will leave the sp incorrect if
    # vars inside the function body interact poorly with early returns
    var inlinevars = func(x) {
        var y = x;
        if (y > 100)
            return 1;
        var z = x+2;
        if (z > 100)
            return 1;
        return 0;
    };

    inlinevars(97);
    inlinevars(99);
    inlinevars(101);

    puts("\n");
};

var ptrtest = func() {
    var x = 5;
    var p = &x;
    var y = 10;

    puts("Pointers to locals:\n");

    puts("1. x = "); puts(itoa(x)); puts("\n");
    puts("1. y = "); puts(itoa(y)); puts("\n");
    puts("1. *p = "); puts(itoa(*p)); puts("\n");
    *p = 7;
    puts("2. x = "); puts(itoa(x)); puts("\n");
    puts("2. y = "); puts(itoa(y)); puts("\n");
    puts("2. *p = "); puts(itoa(*p)); puts("\n");
    p = &y;
    puts("3. x = "); puts(itoa(x)); puts("\n");
    puts("3. y = "); puts(itoa(y)); puts("\n");
    puts("3. *p = "); puts(itoa(*p)); puts("\n");
    *p = 11;
    puts("4. x = "); puts(itoa(x)); puts("\n");
    puts("4. y = "); puts(itoa(y)); puts("\n");
    puts("4. *p = "); puts(itoa(*p)); puts("\n");

    puts("\n");
};

var looptest = func() {
    var i = 0;

    puts("loop break/continue:\n");

    while (i++ < 100) {
        puts(itoa(i));
        puts(": ");
        if (i >= 20) {
            puts("i >= 20\n");
            break;
        };
        if (i >= 10) {
            puts("i >= 10\n");
            continue;
        };
        puts("i < 10\n");
    };

    puts("\n");
};

var fizzbuzz = func() {
    var count3 = 1;
    var count5 = 1;
    var i = 0;

    puts("fizzbuzz:\n");

    while (++i < 100) {
        if (count3==0 && count5==0)
            puts("fizzbuzz")
        else if (count3==0)
            puts("fizz")
        else if (count5==0)
            puts("buzz")
        else
            puts(itoa(i));
        puts(" ");

        count3 = count3+1;
        if (count3 == 3)
            count3 = 0;
        count5 = count5+1;
        if (count5 == 5)
            count5 = 0;
    };

    puts("\n");
    puts("\n");
};

var primestest = func() {
    var maxprime = 1000;
    var prime = malloc(maxprime);
    memset(prime, 1, maxprime);

    # output the difference between "prime" and the next malloc, to highlight any changes
    var x = malloc(1);
    puts("x-prime="); puts(itoa(x-prime)); puts("\n\n");

    puts("primes:\n");

    *(prime+0) = 0;
    *(prime+1) = 0;
    *(prime+2) = 1;

    var i = 1;
    var isqr;
    var j;
    while (i < maxprime) {
        if (*(prime+i)) {
            j = i+i;
            while (j < maxprime) {
                *(prime+j) = 0;
                j = j + i;
            };
        };
        i = i + 2;
    };

    puts("2");
    i = 3;
    while (i < maxprime) {
        if (*(prime+i)) {
            puts(" ");
            puts(itoa(i));
        };
        i = i + 2;
    };

    puts("\n");
    puts("\n");

    free(prime);
};

var l2;
var listtest = func() {
    var l = lstnew();

    puts("list:\n");

    lstpush(l, 3);
    lstpush(l, 4);
    lstunshift(l, 2);
    lstunshift(l, 1);

    lstwalk(l, func(v) { puts(itoa(v)); puts(" "); });
    puts("\nlength = "); puts(itoa(lstlen(l)));
    puts("\npop "); puts(itoa(lstpop(l)));
    puts("\nlength = "); puts(itoa(lstlen(l))); puts("\n");

    # reverse l into l2 (l2 has to be a global because the callback can't access
    # the local stack frame)
    l2 = lstnew();
    lstwalk(l, func(v) {
        lstunshift(l2, v);
    });

    lstwalk(l2, func(v) { puts(itoa(v)); puts(" "); });
    puts("\nlength = "); puts(itoa(lstlen(l2)));
    puts("\nshift "); puts(itoa(lstshift(l2)));
    puts("\nlength = "); puts(itoa(lstlen(l2))); puts("\n");

    puts("\n");

    lstfree(l);
    lstfree(l2);
};

var sp = 0xffff;
var initial_sp = *sp;
optest();
fibtest();
strtest();
functest();
ptrtest();
looptest();
fizzbuzz();
primestest();
listtest();
var new_sp = *sp;
puts("sp change="); puts(itoa(new_sp-initial_sp)); puts("\n");
