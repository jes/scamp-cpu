.PHONY: all test clean

all: scamp

scamp: scamp.c
	cc -o scamp $< -Wall -Wextra -DPROFILING

test: scamp
	./scamp -t

clean:
	rm -f scamp
