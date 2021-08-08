include "stdio.sl";
include "bigint.sl";

var args = cmdargs()+1;
if (!*args) {
	fprintf(2, "usage: isprime N\n", 0);
	exit(1);
};

biginit(2);

var N = bigatoi(*args);
var m = bigclone(N);

# special case: divisible by 2?
bigmodw(m, 2);
if (bigcmpw(m, 0) == 0) {
	printf("%b is divisible by 2\n", [N]);
	exit(0);
};

var i = bignew(3);
var isquared = bignew(9);
while (bigcmp(isquared, N) <= 0) {
	bigset(m, N);
	bigmod(m, i);
	if (bigcmpw(m, 0) == 0) {
		printf("%b is divisible by %b\n", [N, i]);
		exit(0);
	};

	# (i+2)*(i+2) = i^2 + 4i + 2
	bigadd(isquared, i);
	bigadd(isquared, i);
	bigadd(isquared, i);
	bigadd(isquared, i);
	bigaddw(isquared, 4);

	bigaddw(i, 2);
};

printf("%b is prime\n", [N]);
