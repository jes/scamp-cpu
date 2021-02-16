extern inp;
extern outp;

var SERIALDEV = 2;

var getchar = func() {
    return inp(SERIALDEV);
};

var putchar = func(ch) {
    outp(SERIALDEV, ch);
};
