SRCS=scamp.c ucode.c rom.c

all: scamp.js

scamp.js: $(SRCS) os.disk
	emcc -o scamp.js $(SRCS) --preload-file os.disk -s WASM=1 -O3 -s NO_EXIT_RUNTIME=1 -s EXPORTED_RUNTIME_METHODS=['ccall'] -s ALLOW_MEMORY_GROWTH=1
	cp scamp.data scamp.wasm scamp.js public/

ucode.c: ../ucode.hex
	./hex2c ucode 2048 < $< > $@.tmp
	mv $@.tmp $@

rom.c: ../bootrom.hex
	./hex2c rom 256 < $< > $@.tmp
	mv $@.tmp $@

os.disk: ../kernel/os.disk
	cp ../kernel/os.disk os.disk

clean:
	-rm -f scamp.js scamp.wasm scamp.data ucode.c rom.c os.disk
