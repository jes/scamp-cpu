#!/bin/sh

TESTS="register pc decode control tstate ir fr memory alu"

if [ "$1" ]; then
    TESTS=$1
fi

for t in $TESTS; do
    echo $t...
    iverilog ${t}_tb.v
    ./a.out
    rm -f a.out

    echo ttl-$t...
    cat ${t}_tb.v | sed "s/include \"${t}.v\"/include \"ttl-${t}.v\"/" > ttl-${t}_tb.v
    iverilog ttl-${t}_tb.v
    ./a.out
    rm -f ttl-${t}_tb.v a.out
done
