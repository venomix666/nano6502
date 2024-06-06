start_addr_l = $40
start_addr_h = $41

start_sec_l = $42
; Up to 0x45

num_sec = $46
curr_bank = $47

IO_bank_SD = $03

sd_base = $fe00
sd_sector_l = $fe00
sd_bank = $fe07
sd_busy = $fe04
sd_read_strobe = $fe05
sd_done = $fe0a

SD_load:
    ; Set IO bank
    lda #IO_bank_SD
    sta IO_bank

    lda #0
    sta curr_bank
set_sector:
    ; wait until not busy
    lda sd_busy
    bne set_sector

    ; Set start sector
    lda start_sec_l
    sta sd_sector_l
    lda start_sec_l+1
    sta sd_sector_l+1
    lda start_sec_l+2
    sta sd_sector_l+2
    lda start_sec_l+3
    sta sd_sector_l+3

    lda curr_bank
    sta sd_bank

    ldy #0
sector_read:
    ; read strobe
    lda #1
    sta sd_read_strobe
read_wait:
    ldx #$ff
read_wait_inner:
    dex
    bne read_wait_inner
    ; wait until done
    lda sd_done
    cmp #0
    beq read_wait
    
    ; Extra read just to clear flag?
    lda sd_done

    ; copy sector data to ram    
bank_loop:
    ldx #$80
copy_loop:
    lda sd_base,X
    sta (start_addr_l),Y
    iny
    bne copy_cont
    inc start_addr_h
copy_cont:
    inx
    bne copy_loop

    inc curr_bank
    lda curr_bank
    sta sd_bank
    cmp #04
    beq copy_done    

    jmp bank_loop 
copy_done:    
    dec num_sec
    bmi all_done
      
    ; Increase sector address
    inc start_sec_l
    bne inc_done
    inc start_sec_l+1
    bne inc_done
    inc start_sec_l+2
    bne inc_done
    inc start_sec_l+3

inc_done:
    lda #$0
    sta curr_bank
    jmp set_sector
       
all_done:
    ; Clear done flag (not sure why this is needed...)
    lda sd_done
    jmp RESET

