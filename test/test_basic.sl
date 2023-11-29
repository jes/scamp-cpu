var _test_basic_foo = func(x) {
    printf("foo(%d)\n", [x]);
};

var test_basic = func() {
    _test_basic_foo(0);
    _test_basic_foo(-1);
    _test_basic_foo(-2);
    _test_basic_foo(-5);
    _test_basic_foo(1);
    _test_basic_foo(2);
    _test_basic_foo(5);
    _test_basic_foo(-200);
    _test_basic_foo(-300);
    _test_basic_foo(-1);
    _test_basic_foo(1);
    _test_basic_foo(200);
    _test_basic_foo(300);
};
