#!/bin/sh

TESTS=alu_tb.v

for t in $TESTS; do
    iverilog $t
    ./a.out | grep -i bad | while read line; do
        echo "$t: $line"
    done
done

rm a.out
