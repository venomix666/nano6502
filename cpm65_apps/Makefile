export LLVM = /opt/pkg/llvm-mos/bin

export CC6502 = $(LLVM)/mos-cpm65-clang
export AR6502 = $(LLVM)/llvm-ar

export CFLAGS6502 = -Os -g \
	-Wno-main-return-type \
	-I ./include -I ./lib 

export CFLAGS_LIB = -Os -g -c \
	-I ./include

export LDFLAGS6502 = \
	-mlto-zp=0

export LIBS = \
	./lib/bdos.a \
	./lib/printi.a \
	./lib/screen.a \
	./lib/serial.a \
	./lib/xfcb.a \
	./lib/nano6502_timer.a

.PHONY: all
all: $(LIBS) ledtest.com hello.com baudrate.com colorfg.com colorbg.com \
	sndtest.com

%.com: %.S
	$(CC6502) $(CFLAGS6502) $(LDFLAGS6502) -o $@ $^

%.com: %.c
	$(CC6502) $(CFLAGS6502) $(LDFLAGS6502) -o $@ $^ $(LIBS)

%.o: %.S
	$(CC6502) $(CFLAGS_LIB) -o $@ $^

%.a: %.o
	$(AR6502) cqs $@ $^

.PHONY: clean
clean:
	rm -f *.com
	rm -f *.elf
	rm -f ./lib/*.a

