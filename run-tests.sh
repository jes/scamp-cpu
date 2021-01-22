#!/bin/sh

TESTS="register pc control tstate ir alu cpu"

if [ "$1" ]; then
    TESTS=$1
fi

# TODO: need a way to run a test using all its *dependencies* in ttl- version,
# not just the immediate file being tested replaced to use the ttl- version

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
