jmp_addr_l = $50
jmp_addr_h = $51

boot:
    lda #<bootstring
    sta MSGL
    lda #>bootstring
    sta MSGH
    jsr SHWMSG
    
    jsr UART_Input
    cmp #'b'
    beq boot_sd
    cmp #'B'
    beq boot_sd
    rts
boot_sd:
    ; Load bootsector into SD-buffer
    lda #IO_bank_SD
    sta IO_bank

    lda #0
    sta sd_base
    sta sd_base+1
    sta sd_base+2
    sta sd_base+3
    sta sd_bank
    sta sd_read_strobe

boot_wait:
    lda sd_busy
    bne boot_wait

    ; Check magic number
    lda $fe80
    cmp #'n'
    bne sd_fail
    
    lda $fe81
    cmp #'a'
    bne sd_fail

    lda $fe82
    cmp #'n'
    bne sd_fail
    
    lda $fe83
    cmp #'o'
    bne sd_fail

    lda $fe84 
    sta start_sec_l + 3
    
    lda $fe85
    sta start_sec_l + 2
    
    lda $fe86
    sta start_sec_l + 1
    
    lda $fe87
    sta start_sec_l

    lda $fe88
    sta num_sec

    lda $fe89
    sta start_addr_h
    sta jmp_addr_h 
    lda #0
    sta start_addr_l
    sta jmp_addr_l
    sta curr_bank

    jsr SD_load

    jmp (jmp_addr_l) 

sd_fail:
    lda #<failstring
    sta MSGL
    lda #>failstring
    sta MSGH
    jsr SHWMSG
        
    rts

bootstring: .byte "nano6502 boot",13,10,13,10,"Press B to boot from SD-card or any other key for monitor", 13, 10, 0
failstring: .byte "Not a valid SD-card, dropping to monitor", 13, 10, 0
     
