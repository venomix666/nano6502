; nano6502 Timer libary functions
; Copyright © 2024 Henrik Löfgren
; This file is licensed under the terms of the 2-clause BSD license. 

#include "nano6502.inc"

.global sleep_cs

.section .text.sleep_cs
; void sleep_cs(uint16_t delay)
sleep_cs:
    ldy #IO_page_timer
    sty IO_page_reg
    
    sta timer_set_lsb
    stx timer_set_msb
    sta timer_start_strobe

sleep_loop:
    lda timer_idle
    beq sleep_loop

    rts

