include "sys.sl";
include "stdio.sl";

# disable cooked mode on stdin+stdout
serflags(0, 0);
serflags(1, 0);

var ch;
while (1) {
    ch = getchar();
    if (ch == 'q') break;
    printf("[%d]", [ch]);
};
