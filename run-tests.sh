#!/bin/sh

TESTS="alu ttl-alu"

# TODO: come up with a way to use the alu_tb.v on ttl-alu
# to save copy-pasting all the test benches

for t in $TESTS; do
    echo $t...
    iverilog ${t}_tb.v
    ./a.out | grep -i bad
done

rm a.out
