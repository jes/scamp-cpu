include "bitmap.sl";

var test_bitmap = func() {
    var bm = bmnew(200, 200);
    bmset(bm, 42, 42, 1);
    printf("count=%d\n", [bmcount(bm)]);
    bmset(bm, 42, 50, 1);
    printf("count=%d\n", [bmcount(bm)]);
    bmset(bm, 42, 50, 0);
    printf("count=%d\n", [bmcount(bm)]);

    bmset(bm, 100,100, 1);

    printf("bmwalk:",0);
    bmwalk(bm, func(x,y) {
        printf("%d,%d ", [x,y]);
    });
    putchar('\n');

    bmfree(bm);
};
