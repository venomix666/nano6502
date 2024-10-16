; nano6502 register definitions
; Copyright © 2024 Henrik Löfgren
; This file is licensed under the terms of the 2-clause BSD license. 
;
; Only registers which make sense to write directly to from a CP/M-65
; application are included, e.g. no registers for raw SD card access included.
;

IO_page_reg         = $00

IO_page_uart        = $01
IO_page_led        = $02
IO_page_video       = $04
IO_page_timer       = $05
IO_page_gpio        = $07
IO_page_snd         = $08

uart_b_tx_data      = $fe04
uart_b_tx_done      = $fe05
uart_b_rx_data      = $fe06
uart_b_rx_avail     = $fe07
uart_b_baudrate     = $fe08

led_row             = $fe00
led_rgb_r           = $fe01
led_rgb_g           = $fe02
led_rgb_b           = $fe03

video_line          = $fe00
video_cursor_x      = $fe01
video_cursor_y      = $fe02
video_curvis        = $fe03
video_scroll_up     = $fe04
video_scroll_down   = $fe05
tty_write           = $fe06
tty_busy            = $fe07
video_clear_to_eol  = $fe08
tty_cls             = $fe09
video_tty_enable    = $fe0a
video_scroll_enable = $fe0b
video_fg_r          = $fe10
video_fg_g          = $fe11
video_fg_b          = $fe12
video_bg_r          = $fe13
video_bg_g          = $fe14
video_bg_b          = $fe15
video_line_data     = $fe80

timer_idle          = $fe00
timer_start_strobe  = $fe01
timer_set_lsb       = $fe02
timer_set_msb       = $fe03
timer_reset_strobe  = $fe04

gpio_data_1         = $fe00
gpio_data_2         = $fe01
gpio_dir_1          = $fe02
gpio_dir_2          = $fe03

snd_osc1_f          = $fe00 ; 2 bytes
snd_osc1_pw         = $fe02 ; 2 bytes (12 bits)
snd_osc1_ctrl       = $fe04
snd_adsr1_ad        = $fe05
snd_adsr1_sr        = $fe06

snd_osc2_f          = $fe07 ; 2 bytes
snd_osc2_pw         = $fe09 ; 2 bytes (12 bits)
snd_osc2_ctrl       = $fe0b
snd_adsr2_ad        = $fe0c
snd_adsr2_sr        = $fe0d

snd_osc3_f          = $fe0e ; 2 bytes
snd_osc3_pw         = $fe10 ; 2 bytes (12 bits)
snd_osc3_ctrl       = $fe12
snd_adsr3_ad        = $fe13
snd_adsr3_sr        = $fe14
snd_master_vol      = $fe15

