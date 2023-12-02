include "regex.sl";

var re;

var test1 = func(str) {
    printf("%s: ", [str]);
    if (rematch(re, str)) {
        *(recapend(0)) = 0;
        printf("matched (captured %s)\n", [recap(0)])
    }
    else puts("didn't match\n");
};

var checkre = func(restr, matchstr, nomatchstr) {
    printf("renew: %s\n", [restr]);
    re = renew(restr);
    printf("%s should match:\n", [restr]);
    test1(matchstr);
    printf("%s shouldn't match:\n", [restr]);
    test1(nomatchstr);
    refree(re);
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

    refree(re);

    checkre("...\\w+...foo", "..._1234f348_43...foo", "...1234-1234...foo");
    checkre("\\d+", "12345", "abcde");
    checkre("\\s*foo", "      foo", "123foo");
    checkre("[abc]*-end", "abcbcbabcbabcbbabc-end", "abd-end");
    checkre("...\\W+...", "...-;[]'...", "...12345...");
    checkre("\\D+", "abcde", "12345");
    checkre("\\S*foo", "1234fsdfsdfsd---foo", " foo");
    checkre("[^abc]*-end", "def-end", "abc-end");
};
