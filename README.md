# nano6502
6502 SoC for the [Tang Nano 20k FPGA Board](https://wiki.sipeed.com/hardware/en/tang/tang-nano-20k/nano-20k.html).

Planned features for the first version are:  
* 64 k RAM (currently implemented with block RAM)
* 8k ROM which can be switched out (also block RAM)
* UART (implemented)
* SD card storage (implemented)
* 80-column text mode HDMI video output, 640x480 60 Hz (implemented)
* USB keyboard support (not implemented yet)

A port of [CP/M-65](https://github.com/venomix666/cpm65/tree/nano6502) is just about the only software that exists for this SoC right now. It currently uses the UART for input as the USB keyboard support is not yet implemented but is otherwise fully functional with a SCREEN driver and 16x1 MB partitions on the SD-card. The port is not yet submitted to the main repoistory but currently exists as a branch in my fork of the project.
![nano6502_screenshot](https://github.com/venomix666/nano6502/assets/106430829/0e64418e-a7e4-47c8-bef7-8a85b2532d55)


## Set up PLL
In order to set up the PLL on the Tang Nano 20K for generation of the 25.175 MHz video clock, do the following:
* Open a serial terminal connection to the board
* Press Ctrl+x, Ctrl+c, enter
* Enter the command: pll_clk O0=25175K -s
* Enter the command: reboot

## Peripherals and IO model
In order to maximize the amount of available RAM, a simple banked IO model is used.   
The IO select register (address 0x0000) performs banking of the IO page (0xfe00-0xfeff) and can be set to the following values:  
0x00: ROM on IO page.  
0x01: UART on IO page.  
0x02: LED control on IO page.  
0x03: SD card control on IO page.  
    
### UART registers   
0xfe00:  TX data - write to initiate transmission  
0xfe01:  TX ready - UART is ready to accept a new TX byte  
0xfe02:  RX data  
0xfe03:  RX data available - high if a new byte is available in RX data  
  
### LED registers 
0xfe00:  LEDs - byte 0-6 connected to the on board LEDs  
0xfe01:  WS2812 Red - On board RGB led is automatically updated on write  
0xfe02:  WS2812 Green - On board RGB led is automatically updated on write  
0xfe03:  WS2812 Blue - On board RGB led is automatically updated on write  
  
### SD-card:
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

### Video/TTY:
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
0xfe80 - 0xfeff: Active line data, for direct access  
