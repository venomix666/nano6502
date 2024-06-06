.setcpu "65C02"
.segment "DATA"

MSGL    = $2C
MSGH    = $2D

LEDS = $FE00
RED =$FE01
BLUE = $FE02
GREEN = $FE03

test_addr = $E100 ; This is only writable if the ROM is switched out

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

    lda #'*'
    sta test_addr

    lda #$00
    sta LEDS
    lda #$00
    sta RED

    lda #$ff
    sta BLUE

    lda #$88
    sta GREEN

    lda #IO_bank_led
    sta IO_bank_sel

ledloop:
    inc RED
    jsr delay


    dec BLUE
    jsr delay

    inc GREEN
    inc GREEN
    
    inc LEDS
 
    jsr delay
    
    lda test_addr
    jsr UART_Output

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
