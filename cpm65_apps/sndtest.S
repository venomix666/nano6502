; ---------------------------------------------------------------------------
;
; nano6502 Sound test, plays a few chords i C-major
;
; Copyright (C) 2024 Henrik Löfgren
; This file is licensed under the terms of the 2-cluse BSD license. Please
; see the COPYING file in the root project directory for the full test.
;
; ---------------------------------------------------------------------------

#include "zif.inc"
#include "cpm65.inc"
#include "nano6502.inc"

; Freqency values

note_c3  = $05b7
note_cs3 = $060e
note_d3  = $066a
note_ds3 = $06cc
note_e3  = $0733
note_f3  = $07A1
note_fs3 = $0815
note_g3  = $0890
note_gs3 = $0913
note_a3  = $099d
note_as3 = $0a2f
note_b3  = $0aca
note_c4  = $0b6e

ZEROPAGE

leds: .fill 1

zproc main
    lda #IO_page_snd
    sta IO_page_reg
    
    ; Setup voices
    lda #$a0
    sta snd_adsr1_ad
    lda #$f0
    sta snd_adsr1_sr
    lda #$11
    sta snd_osc1_ctrl

    lda #$a0
    sta snd_adsr2_ad
    lda #$f0
    sta snd_adsr2_sr
    lda #$11
    sta snd_osc2_ctrl

    lda #$a0
    sta snd_adsr3_ad
    lda #$f0
    sta snd_adsr3_sr
    lda #$11
    sta snd_osc3_ctrl

    lda #$0f
    sta snd_master_vol

    ; C-major
    lda #>note_c3
    sta snd_osc1_f
    lda #<note_c3
    sta snd_osc1_f+1

    lda #>note_e3
    sta snd_osc2_f
    lda #<note_e3
    sta snd_osc2_f+1

    lda #>note_g3
    sta snd_osc3_f
    lda #<note_e3
    sta snd_osc3_f+1

    jsr delay

    ; D-minor
    lda #>note_d3
    sta snd_osc1_f
    lda #<note_d3
    sta snd_osc1_f+1

    lda #>note_f3
    sta snd_osc2_f
    lda #<note_f3
    sta snd_osc2_f+1

    lda #>note_a3
    sta snd_osc3_f
    lda #<note_a3
    sta snd_osc3_f+1

    jsr delay
 
    ; G-major
    lda #>note_g3
    sta snd_osc1_f
    lda #<note_g3
    sta snd_osc1_f+1

    lda #>note_b3
    sta snd_osc2_f
    lda #<note_b3
    sta snd_osc2_f+1

    lda #>note_d3
    sta snd_osc3_f
    lda #<note_d3
    sta snd_osc3_f+1

    jsr delay

    ; C-major
    lda #>note_c3
    sta snd_osc1_f
    lda #<note_c3
    sta snd_osc1_f+1

    lda #>note_e3
    sta snd_osc2_f
    lda #<note_e3
    sta snd_osc2_f+1

    lda #>note_g3
    sta snd_osc3_f
    lda #<note_e3
    sta snd_osc3_f+1

    jsr delay
    jsr delay
    jsr delay
    jsr delay  
 
    ; turn off sound
    lda #0
    sta snd_osc1_ctrl
    sta snd_osc2_ctrl
    sta snd_osc3_ctrl
    sta snd_master_vol

	rts
zendproc

zproc delay
    lda #IO_page_timer
    sta IO_page_reg
    lda #$64 ; 1.0 sec
    sta timer_set_lsb
    lda #$00
    sta timer_set_msb
    sta timer_reset_strobe
    sta timer_start_strobe
delaywait:
    lda timer_idle
    beq delaywait

    lda #IO_page_snd
    sta IO_page_reg
  
    rts 
zendproc
