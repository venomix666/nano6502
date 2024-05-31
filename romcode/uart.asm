UART_tx_data    =     $fe00
UART_tx_done    =     $fe01
UART_rx_data    =     $fe02
UART_rx_avail   =     $fe03

IO_bank         =     $00
IO_bank_val     =     $01

;
; input chr from UART (waiting)
;
UART_Input:	
    ; Set IO bank
    lda #IO_bank_val
    sta IO_bank
    ; Check if data is available
UART_Input_wait:
    lda UART_rx_avail
    beq UART_Input_wait    
UART_Input_done:
    lda UART_rx_data	
    rts
;
; non-waiting get character routine 
;
UART_Scan:	
	; Set IO bank
    lda #IO_bank_val
    sta IO_bank
    clc
    lda UART_rx_avail 
	beq UART_Scan_Done
    lda UART_rx_data
    sec
UART_Scan_Done:
    rts
;
; output to OutPut Port
;
UART_Output:
    ; Save data
    pha
    ; Set IO bank
    lda #IO_bank_val
    sta IO_bank
UART_Output_Wait:
    lda UART_tx_done
    beq UART_Output_Wait
    pla
    sta UART_tx_data
    rts

;end of file
