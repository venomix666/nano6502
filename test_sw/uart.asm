UART_tx_data    =     $fe00
UART_tx_done    =     $fe01
UART_rx_data    =     $fe02
UART_rx_avail   =     $fe03

IO_bank         =     $00
IO_bank_val     =     $01
IO_bank_temp    =     $04
;
; input chr from UART (waiting)
;
UART_Input:	
    ; Preserve current IO bank
    lda IO_bank
    sta IO_bank_temp
    ; Set IO bank
    lda #IO_bank_val
    sta IO_bank
    ; Check if data is available
UART_Input_wait:
    lda UART_rx_avail
    beq UART_Input_wait    
UART_Input_done:
    lda UART_rx_data
    pha
    lda IO_bank_temp
    sta IO_bank
    pla	
    rts
;
; non-waiting get character routine 
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
	beq UART_Scan_Done
    lda UART_rx_data
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
    lda IO_bank_temp
    sta IO_bank
    rts

;end of file
