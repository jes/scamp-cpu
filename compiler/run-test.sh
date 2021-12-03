#!/bin/sh

echo test.sl...
./run test.sl > test.out.new
diff test.out test.out.new && echo "ok"
