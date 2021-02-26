#!/bin/sh

echo "naive fs..."
./mkfs > test-disk < /dev/null
./fs test-disk < test.in > test.out.new
cmp test.out test.out.new

echo "fast fs..."
./mkfs > test-disk < /dev/null
./fs --fast test-disk < test.in > test.out.new2
cmp test.out test.out.new2
