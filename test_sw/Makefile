all:	leds.bin

leds.bin: leds.o
	ld65 -C leds.cfg -vm -m leds.map -o leds.bin leds.o

leds.o:	leds.asm
	ca65 -i --cpu 65C02 -l leds.lst leds.asm

clean:
	$(RM) *.o *.lst *.map *.bin

distclean: clean
	$(RM) *.mon
