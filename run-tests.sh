#!/bin/sh

TESTS="register alu"

if [ "$1" ]; then
    TESTS=$1
fi

for t in $TESTS; do
    echo $t...
    iverilog ${t}_tb.v
    ./a.out | grep -i bad

    echo ttl-$t...
    cat ${t}_tb.v | sed "s/include \"${t}.v\"/include \"ttl-${t}.v\"/" > ttl-${t}_tb.v
    iverilog ttl-${t}_tb.v
    ./a.out | grep -i bad
    rm ttl-${t}_tb.v
done

rm a.out
