UART_tx_data    =     $fe00
UART_tx_done    =     $fe01
UART_rx_data    =     $fe02
UART_rx_avail   =     $fe03

keyb_data_avail =     $fe00
keyb_data       =     $fe01

TTY_busy        =     $fe07
TTY_out         =     $fe06

IO_bank         =     $00
IO_bank_val     =     $01
IO_bank_keyb    =     $06
IO_bank_temp    =     $04

IO_bank_tty     =     $04
;
; input chr from UART (waiting)
;
; Also checks for USB keyboard data
;
UART_Input:	
    ; Preserve current IO bank
    lda IO_bank
    sta IO_bank_temp
UART_input_wait:
    ; Set UART IO bank
    lda #IO_bank_val
    sta IO_bank
    ; Check if data is available
    lda UART_rx_avail
    beq UART_Input_keyb
    lda UART_rx_data
    bne UART_Input_done
UART_input_keyb: 
    ; Set keyboard IO bank
    lda #IO_bank_keyb
    sta IO_bank
    lda keyb_data_avail
    beq UART_input_wait
    lda keyb_data
    bne UART_input_done
    jmp UART_input_wait
UART_input_done:
    pha
    lda IO_bank_temp
    sta IO_bank
    pla	
    rts
;
; non-waiting get character routine 
;
; Also checks for USB keyboard data
;
UART_Scan:	
	; Preserve current IO bank
    lda IO_bank
    sta IO_bank_temp
    ; Set IO bank
    lda #IO_bank_val
    sta IO_bank
    clc
    lda UART_rx_avail 
	beq UART_Scan_keyb
    lda UART_rx_data
    pha
    lda IO_bank_temp
    sta IO_bank
    pla
    sec
    rts
UART_Scan_keyb:
    lda #IO_bank_keyb
    sta IO_bank
    lda keyb_data_avail
    beq UART_Scan_Done
    lda keyb_data
    beq UART_Scan_Done
    pha
    lda IO_bank_temp
    sta IO_bank
    pla
    sec
    rts
UART_Scan_Done:
    lda IO_bank_temp
    sta IO_bank
    rts
;
; output to OutPut Port
;
UART_Output:
    ; Save data
    pha
    ; Preserve current IO bank
    lda IO_bank
    sta IO_bank_temp
    ; Set IO bank
    lda #IO_bank_val
    sta IO_bank
UART_Output_Wait:
    lda UART_tx_done
    beq UART_Output_Wait
    pla
    sta UART_tx_data
    
    pha

    lda #IO_bank_tty
    sta IO_bank
TTY_Output_Wait:
    lda TTY_busy
    bne TTY_Output_Wait
    pla
    sta TTY_out       
    
    lda IO_bank_temp
    sta IO_bank
    rts

;end of file
