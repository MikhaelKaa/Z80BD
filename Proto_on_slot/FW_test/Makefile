
build:
	mkdir -p build
	sjasmplus --syntax=af --dirbol --fullpath ./src/main.asm

clean:
	rm -f build/*.bin

flash:
	PCProg.exe COM18 build/test.bin

.PHONY: all build clean