include "hash.sl";

var test_hash = func() {
    var ht = htnew();
    htput(ht, "onetwothree", 123);
    htput(ht, "fourfivesix", 456);
    printf("get onetwothree=%d\n", [htget(ht, "onetwothree")]);
    printf("get fourfivesix=%d\n", [htget(ht, "fourfivesix")]);
    printf("get seveneightnine=%d\n", [htget(ht, "seveneightnine")]);
    var i = 0;
    while (i < 50) {
        htput(ht, sprintf("key%d", [i]), i);
        i++;
    };

    printf("get key42=%d\n", [htget(ht, "key42")]);
    htfree(ht);
};
