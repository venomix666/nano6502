;-----------------------------------------------------------------------------
; sdcard.s
; Copyright (C) 2020 Frank van den Hoef
;
; Converted to use nano6502 SD-card interface by Henrik Löfgren
;-----------------------------------------------------------------------------

	;.include "lib.inc"
	;.include "sdcard.inc"

	;.export sector_buffer, sector_buffer_end, sector_lba


	.bss
cmd_idx = sdcard_param
cmd_arg = sdcard_param + 1
cmd_crc = sdcard_param + 5

; nano6502 registers
IO_page_reg = $00
IO_page_sdcard = $03

sd_base = $fe00
sd_addr_0 = $fe00
sd_addr_1 = $fe01
sd_addr_2 = $fe02
sd_addr_3 = $fe03
sd_busy = $fe04
sd_read_strobe = $fe05
sd_write_strobe = $fe06
sd_page = $fe07
sd_data = $fe80


sector_buffer:
	.res 512
sector_buffer_end:

sdcard_param:
	.res 1
sector_lba:
	.res 4 ; dword (part of sdcard_param) - LBA of sector to read/write
	.res 1

	.code

;-----------------------------------------------------------------------------
; wait ready
;
; clobbers: A,X,Y
;-----------------------------------------------------------------------------
wait_ready:
    ; Set sd-card IO-page
    lda #IO_page_sdcard
    sta IO_page_reg

    ldy #$ff

@wait_loop_outer:

    ; Check busy flag
    lda sd_busy
    beq @done

    ldx #$ff
@wait_loop_inner:
    dex
    bne @wait_loop_inner

    dey
    bne @wait_loop_outer

	; Timeout error
	clc
	rts

@done:	sec
	rts

;-----------------------------------------------------------------------------
; sdcard_init
; result: C=0 -> error, C=1 -> success
;-----------------------------------------------------------------------------
sdcard_init:
	; Success - no error checking for now
	sec
	rts

;@error:	jsr deselect

	; Error
;	clc
;	rts


sdcard_set_sector:
    ; Sets the active sector to sector_lba
    jsr wait_ready
    lda sector_lba+0
    sta sd_addr_0
    lda sector_lba+1
    sta sd_addr_1
    lda sector_lba+2
    sta sd_addr_2
    lda sector_lba+3
    sta sd_addr_3
    rts

;-----------------------------------------------------------------------------
; sdcard_read_sector
; Set sector_lba prior to calling this function.
; result: C=0 -> error, C=1 -> success
;-----------------------------------------------------------------------------
sdcard_read_sector:
	; Set sd-card sector
    jsr sdcard_set_sector

    ; Perform read
    lda #0
    sta sd_read_strobe
    
    ; Wait until read is finished
    jsr wait_ready

    ; Copy data to sector buffer
    ldx #0
    ldy #$80
    
    lda #0
    sta sd_page
@1:
    lda sd_base,Y
    sta sector_buffer+0,X
    inx
    iny
    bne @1

    ldy #$80
    lda #1
    sta sd_page
@2:
    lda sd_base,Y
    sta sector_buffer+0,X
    inx
    iny
    bne @2

    ldy #$80
    lda #2
    sta sd_page
@3:
    lda sd_base,Y
    sta sector_buffer+256,X
    inx
    iny
    bne @3

    ldy #$80
    lda #3
    sta sd_page
@4:
    lda sd_base,Y
    sta sector_buffer+256,X
    inx
    iny
    bne @3

	sec
	rts

;-----------------------------------------------------------------------------
; sdcard_write_sector
; Set sector_lba prior to calling this function.
; result: C=0 -> error, C=1 -> success
;-----------------------------------------------------------------------------
sdcard_write_sector:
    ; Set sdcard sector
    jsr sdcard_set_sector

    ; Copy data to write buffer
    lda #0
    sta sd_page

    ldx #$0
    ldy #$80
@1:
    lda sector_buffer+0,X
    sta sd_base,Y
    inx
    iny
    bne @1

    ldy #$80
    lda #1
    sta sd_page
@2:
    lda sector_buffer+0,X
    sta sd_base,Y
    inx
    iny
    bne @2

    ldy #$80
    lda #2
    sta sd_page
@3:
    lda sector_buffer+256,X
    sta sd_base,Y
    inx
    iny
    bne @3

    lda #$80
    lda #3
    sta sd_page
@4:
    lda sector_buffer+256,X
    sta sd_base,Y
    inx
    iny
    bne @4

    ; Perform write
    lda #0
    sta sd_write_strobe
    jsr wait_ready
    
	sec
	rts

;-----------------------------------------------------------------------------
; sdcard_check_alive
;
; Check whether the current SD card is still present, or whether it has been
; removed or replaced with a different card.
;
; Out:  c  =1: SD card is alive
;          =0: SD card has been removed, or replaced with a different card
;
; The SEND_STATUS command (CMD13) sends 16 error bits:
;  byte 0: 7  always 0
;          6  parameter error
;          5  address error
;          4  erase sequence error
;          3  com crc error
;          2  illegal command
;          1  erase reset
;          0  in idle state
;  byte 1: 7  out of range | csd overwrite
;          6  erase param
;          5  wp violation
;          4  card ecc failed
;          3  CC error
;          2  error
;          1  wp erase skip | lock/unlock cmd failed
;          0  Card is locked
; Under normal circumstances, all 16 bits should be zero.
; This command is not legal before the SD card has been initialized.
; Tests on several cards have shown that this gets respected in practice;
; the test cards all returned $1F, $FF if sent before CMD0.
; So we use CMD13 to detect whether we are still talking to the same SD
; card, or a new card has been attached.
;-----------------------------------------------------------------------------
sdcard_check_alive:
	; save sector
	;ldx #0
;@1:	lda sector_lba, x
	;pha
	;inx
	;cpx #4
	;bne @1

	;send_cmd_inline 13, 0 ; CMD13: SEND_STATUS
	;bcc @no ; card did not react -> no card
	;tax
	;bne @no ; first byte not $00 -> different card
	;jsr spi_read
	;tax
	;bne @no ; second byte not $00 -> different card
	;sec
	;bra @yes

;@no:	clc

;@yes:	; restore sector
	; (this code preserves the C flag!)
	;ldx #3
;@2:	pla
;	sta sector_lba, x
;	dex
;	bpl @2

;	php
;	jsr deselect
;	plp
    sec
	rts
