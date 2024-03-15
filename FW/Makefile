
build:
	sjasmplus main.asm --syntax=F --inc

flash:
	PCProg.exe COM18 out.bin

flash48:
	PCProg.exe COM18 48.bin

flashff:
	PCProg.exe COM18 0xff.bin

clean:
	rm -f *.bin
	#rm -f user.l

.PHONY: all build clean