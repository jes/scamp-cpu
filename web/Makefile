all: scamp.js

scamp.js: ../emulator/scamp.c os.disk ucode.hex bootrom.hex
	emcc -o scamp.js ../emulator/scamp.c --preload-file os.disk --preload-file ucode.hex --preload-file bootrom.hex -s WASM=1 -O3 -s NO_EXIT_RUNTIME=1 -s EXPORTED_RUNTIME_METHODS=['ccall'] -s ALLOW_MEMORY_GROWTH=1 -DEMSCRIPTEN
	cp scamp.data scamp.wasm scamp.js public/

ucode.hex: ../ucode.hex
	cp ../ucode.hex .

bootrom.hex: ../bootrom.hex
	cp ../bootrom.hex .

os.disk: ../kernel/os.disk
	cp ../kernel/os.disk os.disk

clean:
	-rm -f scamp.js scamp.wasm scamp.data os.disk ucode.hex bootrom.hex
