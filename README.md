# nano6502
nano6502 is a 6502 SoC for the [Tang Nano 20k FPGA Board](https://wiki.sipeed.com/hardware/en/tang/tang-nano-20k/nano-20k.html).

Current features:
* 64 k RAM (currently implemented with block RAM)
* 8k ROM which can be switched out (also block RAM)
* UART (on the built in USB-C connector, and the UART header on the carrier board)
* SD card storage 
* 80-column text mode HDMI video output, 640x480 60 Hz 
* USB keyboard support (with [nanoComp](https://github.com/venomix666/nanoComp/) carrier board)  

Everything is clocked of the pixel clock, so the 65C02 core is running at 25.175 MHz which gives a rather speedy user experience.

A port of [CP/M-65](https://github.com/davidgiven/cpm65) is just about the only software that exists for this SoC right now. The on-board USB UART or a USB keyboard can be used for input and it has a fully functional with a SCREEN driver, a SERIAL driver for UART B and 15x1 MB partitions on the SD-card.  
  
<img src="https://github.com/venomix666/nano6502/assets/106430829/0e64418e-a7e4-47c8-bef7-8a85b2532d55" width=400>
<img src="https://github.com/user-attachments/assets/3e07c907-8239-404c-9a14-ae273194528e" width=400>


## Gettings started

### Set up PLL
In order to set up the external PLL on the Tang Nano 20K for generation of the 25.175 MHz video clock and the 12 MHz USB clock, do the following:
* Open a serial terminal connection to the board
* Press Ctrl+x, Ctrl+c, enter
* Enter the command: `pll_clk O0=25175K -s`
* Enter the command: `pll_clk O1=12M -s`
* Enter the command: `reboot`

### Program the FPGA
If you don't want to synthesize the project yourself, you can download the [bitstream file](https://github.com/venomix666/nano6502/releases/download/v0.3.4/nano6502.fs) and program it to the FPGA configuration flash memory using [openFPGAloader](https://github.com/trabucayre/openFPGALoader):  
```console
openFPGAloader -b tangnano20k -f ./nano6502.fs
```
## Peripherals and IO model
In order to maximize the amount of available RAM, a simple banked IO model is used.   
The IO select register (address 0x0000) performs banking of the IO page (0xfe00-0xfeff) and can be set to the following values:  
0x00: ROM or RAM on IO page.  
0x01: UART on IO page.  
0x02: LED control on IO page.  
0x03: SD card control on IO page.  
0x04: Video control IO page.  
0x05: Timer IO page.  
0x06: USB HID page.

The boot ROM normally resides at 0xe000 - 0xffff, but can be switched out by writing 0x01 to address 0x0002 in order to have RAM from 0x0000 - 0xfeff. The last page is always assigned to ROM so that the reset vector is correct.
    
### UART registers   
0xfe00:  TX data UART A - write to initiate transmission  
0xfe01:  TX ready UART A - UART is ready to accept a new TX byte  
0xfe02:  RX data UART A   
0xfe03:  RX data available UART A - high if a new byte is available in RX data  
0xfe04:  TX data UART B - write to initiate transmission  
0xfe05:  TX ready UART B - UART is ready to accept a new TX byte  
0xfe06:  RX data UART B  
0xfe07:  RX data available UART B - high if a new byte is available in RX data  
0xfe08:  Baudrate UART B - 0: 4800, 1: 9600, 2: 19200, 3: 38400, 4: 57600, 5: 115200  
   
### LED registers 
0xfe00:  LEDs - byte 0-6 connected to the on board LEDs  
0xfe01:  WS2812 Red - On board RGB led is automatically updated on write  
0xfe02:  WS2812 Green - On board RGB led is automatically updated on write  
0xfe03:  WS2812 Blue - On board RGB led is automatically updated on write  
  
### SD-card registers
0xfe00:  SD card sector address (LSB)  
0xfe01:  SD card sector address  
0xfe02:  SD card sector address  
0xfe03:  SD card sector address (MSB)  
0xfe04:  SD card busy  
0xfe05:  SD card read strobe (write any value to initiate a sector read)  
0xfe06:  SD card write strobe (write any value to initiate a sector write)  
0xfe07:  Sector data page register (0-3), selects which 128 bytes of the sector are availabe on 0xfe80-0xfeff  
0xfe08:  SD card status (debug only)  
0xfe09:  SD card type (debug only)  
0xfe80 - 0xfeff: 128 byte data page, paged by the page register so that all 512 bytes can be accessed  

### Video/TTY registers
0xfe00:  Active line - selects which line in memory that is available at 0xfe80  
0xfe01:  Cursor X position  
0xfe02:  Cursor Y position  
0xfe03:  Cursor visible  
0xfe04:  Scroll up strobe  
0xfe05:  Scroll down strobe  
0xfe06:  TTY write character  
0xfe07:  Busy flag - no registers can be changed when this is high  
0xfe08:  Clear to end-of-line strobe  
0xfe09:  Clear screen strobe  
0xfe0a:  TTY enabled  
0xfe0b:  Scrolling enabled  
0xfe10:  Foreground Red  
0xfe11:  Foreground Green  
0xfe12:  Foreground Blue  
0xfe13:  Background Red  
0xfe14:  Background Green  
0xfe15:  Background Blue  
0xfe80 - 0xfeff: Active line data, for direct access

### Timer registers
0xfe00: Timer idle - 1 when idle, 0 when busy  
0xfe01: Timer start strobe  
0xfe02: Timer time in centiseconds LSB  
0xfe03: Timer time in centiseconds MSB  
0xfe04: Timer reset strobe  

### USB host registers
0xfe00: New key available - clears on read  
0xfe01: Keypress ASCII data  
0xfe02: Key modifier  
0xfe03: Mouse button  
0xfe04: Mouse dX  
0xfe05: Mouse dY  
0xfe06: Gamepad direction {4'b0000, game_d, game_u, game_r, game_l}  
0xfe07: Gamepad buttons {2'b00, game_sta, game_sel, game_y, game_x, game_b, game_a}  
0xfe08: New USB report available - clears on read  
0xfe09: Device type - 0: no device, 1: keyboard, 2: mouse, 3: gamepad  
0xfe0a: USB error code  

### Known bugs
* Direct writing / reading to the video memory is glitchy due to some timing issue in the FPGA.

### Credits
Some parts in this project are reused from other projects:  
The 6502 Core used is [Arlet's 6502 core](https://github.com/Arlet/verilog-6502) with [65C02 instruction extension](https://github.com/hoglet67/verilog-6502)   
The low-level SD-card state-machine is reused from [MiSTeryNano](https://github.com/harbaum/MiSTeryNano/)  
The USB HID host core was made by [nand2mario](https://github.com/nand2mario/usb_hid_host/)  
The font used is from this [romfont](https://github.com/spacerace/romfont) repository  


