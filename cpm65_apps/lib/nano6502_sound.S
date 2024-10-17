; nano6502 Sound libary functions
; Copyright © 2024 Henrik Löfgren
; This file is licensed under the terms of the 2-clause BSD license. 

#include "nano6502.inc"
#include "zif.inc"

zproc snd_set_osc1_f, .text.snd_set_osc1_f
    sta snd_osc1_f
    stx snd_osc1_f+1
    rts
zendproc

zproc snd_set_osc1_pw, .text.snd_set_osc1_pw
    sta snd_osc1_pw
    stx snd_osc1_pw+1
    rts
zendproc

zproc _snd_set_adsr1_ad, .text.snd_set_adsr1_ad
    sta snd_adsr1_ad
    rts
zendproc

zproc _snd_set_adsr1_sr, .text.snd_set_adsr1_sr
    sta snd_adsr1_sr
    rts
zendproc

zproc _snd_set_osc1_ctrl, .text.snd_set_osc1_ctrl
    sta snd_osc1_ctrl
    rts
zendproc

zproc snd_set_osc2_f, .text.snd_set_osc2_f
    sta snd_osc2_f
    stx snd_osc2_f+1
    rts
zendproc

zproc snd_set_osc2_pw, .text.snd_set_osc2_pw
    sta snd_osc2_pw
    stx snd_osc2_pw+1
    rts
zendproc

zproc _snd_set_adsr2_ad, .text.snd_set_adsr2_ad
    sta snd_adsr2_ad
    rts
zendproc

zproc _snd_set_adsr2_sr, .text.snd_set_adsr2_sr
    sta snd_adsr2_sr
    rts
zendproc

zproc _snd_set_osc2_ctrl, .text.snd_set_osc2_ctrl
    sta snd_osc2_ctrl
    rts
zendproc

zproc snd_set_osc3_f, .text.snd_set_osc3_f
    sta snd_osc3_f
    stx snd_osc3_f+1
    rts
zendproc

zproc snd_set_osc3_pw, .text.snd_set_osc3_pw
    sta snd_osc3_pw
    stx snd_osc3_pw+1
    rts
zendproc

zproc _snd_set_adsr3_ad, .text.snd_set_adsr3_ad
    sta snd_adsr3_ad
    rts
zendproc

zproc _snd_set_adsr3_sr, .text.snd_set_adsr3_sr
    sta snd_adsr3_sr
    rts
zendproc

zproc _snd_set_osc3_ctrl, .text.snd_set_osc3_ctrl
    sta snd_osc3_ctrl
    rts
zendproc

zproc snd_set_master_vol, .text.snd_set_master_vol
    sta snd_master_vol
    rts
zendproc


