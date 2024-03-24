
build:
	sjasmplus src/main.asm --syntax=F --inc="src"

flash:
	PCProg.exe COM18 build/out.bin

clean:
	rm -f build/*.bin

.PHONY: all build clean