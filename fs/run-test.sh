#!/bin/sh

./mkfs > test-disk < /dev/null
./fs test-disk < test.in > test.out.new
cmp test.out test.out.new
