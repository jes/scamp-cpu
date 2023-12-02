include "regex.sl";

var re;

var test1 = func(str) {
    printf("%s: ", [str]);
    var cap = 0;
    if (rematch(re, str)) {
        if (recap(1)) cap = 1;
        *(recapend(cap)) = 0;
        printf("matched (captured %s)\n", [recap(cap)])
    }
    else puts("didn't match\n");
};

var checkre = func(restr, matchstr, nomatchstr) {
    re = renew(restr);
    printf("%s should match:\n", [restr]);
    test1(matchstr);
    printf("%s shouldn't match:\n", [restr]);
    test1(nomatchstr);
    refree(re);
};

var test_regex = func() {
    var restr = "a((?:b|c)*)d";
    re = renew(restr);

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

    refree(re);

    checkre("...\\w+...foo", "..._1234f348_43...foo", "...1234-1234...foo");
    checkre("\\d+foo", "12345foo", "abcdefoo");
    checkre("\\s*foo", "      foo", "123foo");
    checkre("[abc]*-end", "abcbcbabcbabcbbabc-end", "abd-end");
    checkre("...\\W+...", "...-;[]'...", "...12345...");
    checkre("\\D+foo", "abcdefoo", "12345foo");
    checkre("\\S*foo", "1234fsdfsdfsd---foo", " foo");
    checkre("[^abc]*-end", "def-end", "abc-end");
};
