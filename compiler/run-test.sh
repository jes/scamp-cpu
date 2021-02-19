#!/bin/sh

echo test.sl...
./run test.sl > test.out.new
diff test.out test.out.new && echo "ok"

echo "self-hosted test.sl..."
./minify test.sl | ./run slangc.sl > test.s
./srun test.s > test.out.new2
diff test.out test.out.new && echo "ok"

echo "self-compilation..."
./selfhost-test
