.setcpu "65C02"
.segment "DATA"

MSGL    = $2C
MSGH    = $2D

LEDS = $FE00
RED =$FE01
BLUE = $FE02
GREEN = $FE03

IO_bank_sel = $00
IO_bank_led = $02

ROM_sel = $02

    lda #<MSG1
    sta MSGL
    lda #>MSG2
    sta MSGH
    jsr STROUT
    lda #01
    sta ROM_sel
    lda #<MSG2
    sta MSGL
    lda #>MSG2
    sta MSGH
    jsr STROUT

    lda #$11
    sta LEDS
    lda #$00
    sta RED

    lda #$01
    sta BLUE

    lda #$88
    sta GREEN

    lda #IO_bank_led
    sta IO_bank_sel

ledloop:
    lda RED
    clc
    adc #$08
    sta RED

    jsr delay

    lda BLUE
    rol
    sta BLUE

    jsr delay

    lda GREEN
    ror
    ror
    sta GREEN
    
    lda LEDS
    rol
    sta LEDS
    
    jsr delay
    jmp ledloop

STROUT:
    ldy #0
STRLOOP:
    lda (MSGL),Y
    beq STRDONE
    jsr UART_Output
    iny
    bne strloop 
STRDONE:
    rts

delay:
    ldx #$ff
delay_x:
    ldy #$ff
delay_y:
    dey
    bne delay_y

    dex
    bne delay_x

    rts

MSG1:
    .byte 13,10,"Running code from SD-card",13,10,0

MSG2:
    .byte "ROM switched out",13,10,0
.include "uart.asm"
