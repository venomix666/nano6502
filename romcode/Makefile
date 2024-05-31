all:	nano6502.bin

nano6502.bin: nano6502.o
	ld65 -C nano6502.cfg -vm -m nano6502.map -o nano6502.bin nano6502.o

nano6502.o:	nano6502.asm
	ca65 -i --cpu 65C02 -l nano6502.lst nano6502.asm

clean:
	$(RM) *.o *.lst *.map *.bin

distclean: clean
	$(RM) *.mon
