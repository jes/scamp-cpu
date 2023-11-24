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
../emulator/scamp -i os.disk | sed '1,/BEGIN TEST OUTPUT/d' > test.out

# check the results
diff --strip-trailing-cr -u test.expect test.out | less
