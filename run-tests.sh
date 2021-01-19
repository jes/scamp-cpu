#!/bin/sh

TESTS=alu

for t in $TESTS; do
    echo $t...
    iverilog ${t}_tb.v
    ./a.out | grep -i bad
done

rm a.out
