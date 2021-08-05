include "stdio.sl";

serflags(0, 0);

var ch;
while (1) {
	ch = getchar();
	printf("%d ", [ch]);
};
