include "stdio.sl";

serflags(0, 0);

var ch;
while (1) {
	ch = getchar();
	printf("%d ", [ch]);
    if (ch == 3) break; # ctrl-c
};
