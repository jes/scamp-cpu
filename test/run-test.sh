#!/bin/bash

set -e
set -o pipefail

# build the test binary
../compiler/slangc test.sl | ../compiler/peepopt | ../compiler/peepopt > test.s
cat ../sys/lib/head.s test.s ../sys/lib/foot.s | ../asm/asm > test.hex
../util/hex2bin test.hex > test.bin

# get a filesystem image
make -C ../kernel/ os.disk
cp ../kernel/os.disk .

# add the test binary to the filesystem
../fs/fs os.disk < fs.in

# run the test
../emulator/scamp -i os.disk > test.out

# check the results
./split-output < test.out
cmp test.expect test-top.out || (diff -u test.expect test-top.out | less)
cmp test.expect test-slc.out || (diff -u test.expect test-slc.out | less)
cmp test.expect test-slangi.out || (diff -u test.expect test-slangi.out | less)
cmp test.expect test-top.out && cmp test.expect test-slc.out && cmp test.expect test-slangi.out && echo "All tests PASSED."
