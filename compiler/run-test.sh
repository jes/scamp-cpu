#!/bin/sh

./run test.sl > test.out.new
diff test.out test.out.new && echo "ok"
