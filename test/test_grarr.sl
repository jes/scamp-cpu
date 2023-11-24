include "grarr.sl";

var test_grarr = func() {
    var gr = grnew();

    var i = 0;
    while (i < 100) {
        grpush(gr, i);
        i++;
    };

    i = 0;
    var n;
    while (i < 40) {
        printf("%d: grshift=%d, grpop=%d\n", [i, grshift(gr), grpop(gr)]);
        i++;
    };

    printf("grlen=%d\n", [grlen(gr)]);

    i = 0;
    while (i < 10) {
        grunshift(gr, 500+i);
        grpush(gr, 1000+i);
        i++;
    };
    puts("grwalk: ");
    grwalk(gr, func(v) {
        printf("%d ", [v]);
    });
    putchar('\n');
};
