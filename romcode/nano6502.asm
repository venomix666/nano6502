.setcpu "65C02"

.ZEROPAGE
fat32_bufptr: .res 2
fat32_lfn_bufptr: .res 2
fat32_ptr: .res 2
fat32_ptr2: .res 2

.globalzp fat32_bufptr, fat32_lfn_bufptr, fat32_ptr, fat32_ptr2 

.segment "JUMPTBL"
.include "jumptable.asm"

.segment "CODE"
.include "uart.asm"
;.include "sdload.asm"
;.include "boot.asm"
.include "text_input.s"
.include "sdcard.s"
.include "match.s"
.include "fat32.s"
.include "wozmon.asm"
