;.segment "JUMPTBL"
; 0xE000
jmp_mon:        jmp RESET
; 0xE003
jmp_scan:       jmp UART_Input
; 0xE006
jmp_inp:        jmp UART_Scan
; 0xE009
jmp_out:        jmp UART_Output
; 0xE00C
;jmp_sdload:     jmp SD_load
; 0xE00F    
; 0xE012
; 0xE015
; 0xE018
; 0xE01B
; 0xE01E
; 0xE021
; 0xE024  
; 0xE027
; 0xE02A
; 0xE02D
; 0xE030
; 0xE033
; 0xE036
; 0xE039
; 0xE03C
; 0xE03F
; 0xE042
; 0xE045
; 0xE048
; 0xE04B
; 0xE04E
; 0xE051
; 0xE054
; 0xE057
; 0xE05A
; 0xE05D
; 0xE060
; 0xE063
; ...
