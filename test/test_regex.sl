include "regex.sl";

var re;

var test1 = func(str) {
    printf("%s: ", [str]);
    if (rematch(re, str)) printf("matched (captured %s)\n", [recap(0)])
    else puts("didn't match\n");
};

var test_regex = func() {
    var restr = "a(b|c)*d";
    re = renew("a(b|c)*d");
    printf("%s should match:\n", [restr]);
    test1("abcd");
    test1("abbbbbbbd");
    test1("acccccccd");
    test1("ad");
    test1("abcbcbbbbbcccbcbcbcccbcbcbcbcd");
    test1("abd");
    test1("acd");
    printf("%s should not match:\n", [restr]);
    test1("aadd");
    test1("");
    test1("abbbcc");
    test1("bbccd");
    test1("aad");
    test1("ddddd");
};
