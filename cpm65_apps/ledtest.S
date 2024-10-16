; ---------------------------------------------------------------------------
;
; nano6502 LED tester, blinks onboard LEDs for 2 seconds
;
; Copyright (C) 2024 Henrik Löfgren
; This file is licensed under the terms of the 2-cluse BSD license. Please
; see the COPYING file in the root project directory for the full test.
;
; ---------------------------------------------------------------------------

#include "zif.inc"
#include "cpm65.inc"
#include "nano6502.inc"

ZEROPAGE

leds: .fill 1

zproc main
    ldx #$0a 
    lda #$11
    sta leds
loop:
    lda #IO_page_led
    sta IO_page_reg

    lda #30
    sta led_rgb_b

    lda leds
    sta led_row
    ror
    sta leds
    jsr delay
    lda #IO_page_led
    sta IO_page_reg

    lda #00
    sta led_rgb_b

    lda leds
    sta led_row
    ror
    sta leds

    jsr delay

    dex
    bne loop

    lda #IO_page_led
    sta IO_page_reg    

    lda #00
    sta led_row
     
	rts
zendproc

zproc delay
    lda #IO_page_timer
    sta IO_page_reg
    lda #$0A ; 0.1 sec
    sta timer_set_lsb
    lda #$00
    sta timer_set_msb
    sta timer_reset_strobe
    sta timer_start_strobe
delaywait:
    lda timer_idle
    beq delaywait
    rts 
zendproc
