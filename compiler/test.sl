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

    printf("a=%d\n", [a]);
    printf("b=%d\n", [b]);
    printf("~a=%d\n", [~a]);
    printf("-b=%d\n", [-b]);
    printf("+a=%d\n", [+a]);
    printf("a+b=%d\n", [a+b]);
    printf("a-b=%d\n", [a-b]);
    printf("a&b=%d\n", [a&b]);
    printf("a|b=%d\n", [a|b]);
    printf("a^b=%d\n", [a^b]);
    printf("a&&b=%d\n", [a&&b]);
    printf("a||b=%d\n", [a||b]);
    printf("a&&0=%d\n", [a&&0]);
    printf("a||0=%d\n", [a||0]);
    printf("(-1 > 0)=%d\n", [-1>0]);
    printf("(-1 >= 0)=%d\n", [-1>=0]);
    printf("(-1 < 0)=%d\n", [-1<0]);
    printf("(-1 <= 0)=%d\n", [-1<=0]);
    printf("(32767>0)=%d\n", [32767>0]);
    printf("(32767>=0)=%d\n", [32767>=0]);
    printf("(32767<0)=%d\n", [32767<0]);
    printf("(32767<=0)=%d\n", [32767<=0]);
    printf("(32767>-2)=%d\n", [32767>-2]);
    printf("(32767>=-2)=%d\n", [32767>=-2]);
    printf("(32767<-2)=%d\n", [32767<-2]);
    printf("(32767<=-2)=%d\n", [32767<=-2]);

    var x = 5;
    var y = 10;
    printf("x=%d\n", [x]);
    printf("y=%d\n", [y]);
    printf("x>y-6=%d\n", [x>y-6]);

    puts("\n");
    puts("unsigned magnitude comparison:\n");
    a = 0;
    while (a != 0xff00) {
        b = a;
        while (b != 0xff00) {
            printf("%d < %d = %d\n", [a, b, a < b]);
            printf("%d > %d = %d\n", [a, b, a > b]);
            printf("%d <= %d = %d\n", [a, b, a <= b]);
            printf("%d >= %d = %d\n", [a, b, a >= b]);

            printf("%d lt %d = %d\n", [a, b, a lt b]);
            printf("%d gt %d = %d\n", [a, b, a gt b]);
            printf("%d le %d = %d\n", [a, b, a le b]);
            printf("%d ge %d = %d\n", [a, b, a ge b]);

            b = b + 16320;
        };
        a = a + 16320;
    };

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

        printf("fib(%d) = %d\n", [n,f3]);
        if (n <= 18) printf("rfib(%d) = %d\n", [n,rfib(n)]);
    };

    puts("\n");
};

var strtest = func() {
    var s1 = "Hello, world!";

    printf("string: %s\n", [s1]);
    printf("reversed: %s\n", [strrev(s1)]);
    printf("re-reversed: %s\n", [strrev(s1)]);

    printf("cmp self: %d\n", [strcmp(s1,s1)]);
    printf("cmp hello world: %d\n", [strcmp(s1,"Hello, world!")]);
    printf("cmp foo: %d\n", [strcmp(s1,"foo")]);

    printf("length: %d\n", [strlen(s1)]);

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

    printf("2. 5 = %d\n", [f(func() {
        globule++;
        return globule;
    })]);

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

    printf("1. x = %d\n", [x]);
    printf("1. y = %d\n", [y]);
    printf("1. *p = %d\n", [*p]);
    *p = 7;
    printf("2. x = %d\n", [x]);
    printf("2. y = %d\n", [y]);
    printf("2. *p = %d\n", [*p]);
    p = &y;
    printf("3. x = %d\n", [x]);
    printf("3. y = %d\n", [y]);
    printf("3. *p = %d\n", [*p]);
    *p = 11;
    printf("4. x = %d\n", [x]);
    printf("4. y = %d\n", [y]);
    printf("4. *p = %d\n", [*p]);

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
    printf("x-prime=%d\n\n", [x-prime]);

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
        if (*(prime+i)) printf(" %d", [i]);
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

var arraytest = func() {
    puts("array:\n");
    var arr;
    var p;
    var i = 0;
    while (i++ < 10) {
        arr = ["Hello, ", "world! ", "For time no. ", itoa(i), "\n"];
        p = arr;
        while (*p) {
            puts(*(p++));
        };

        puts("arr[3]="); puts(arr[3]); puts("\n");
        puts("strcmp(arr[0],\"Hello, \")="); puts(itoa(strcmp(arr[0], "Hello, "))); puts("\n");
        puts("strcmp(arr[0],\"foo\")="); puts(itoa(strcmp(arr[0], "foo"))); puts("\n");
    };
    puts("\n");
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
arraytest();
var new_sp = *sp;
puts("sp change="); puts(itoa(new_sp-initial_sp)); puts("\n");
