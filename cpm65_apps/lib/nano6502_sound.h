/* Library for using the nano6502 sound from C
 * Copyright © 2024 Henrik Löfgren
 * This file is licensed under the terms of the 2-clause BSD license. 
 */

#ifndef NANO6502_SOUND_H
#define NANO6502_SOUND_H

extern void snd_set_osc1_f(uint16_t freq);
extern void snd_set_osc1_pw(uint16_t pw);
extern void _snd_set_adsr1_ad(uint8_t ad);
extern void _snd_set_adsr1_sr(uint8_t sr);
extern void _snd_set_osc1_ctrl(uint8_t ctrl);

extern void snd_set_osc2_f(uint16_t freq);
extern void snd_set_osc2_pw(uint16_t pw);
extern void _snd_set_adsr2_ad(uint8_t ad);
extern void _snd_set_adsr2_sr(uint8_t sr);
extern void _snd_set_osc2_ctrl(uint8_t ctrl);

extern void snd_set_osc3_f(uint16_t freq);
extern void snd_set_osc3_pw(uint16_t pw);
extern void _snd_set_adsr3_ad(uint8_t ad);
extern void _snd_set_adsr3_sr(uint8_t sr);
extern void _snd_set_osc3_ctrl(uint8_t ctrl);

extern void snd_set_master_vol (uint8_t vol);

#define snd_set_adsr1(uint8_t attack, uint8_t decay, \
                      uint8_t sustain, uint8_t release) \
        do { \
                _snd_set_adsr1_ad((a<<4) | (d & 0x0f)); \
                _snd_set_adsr1_sr((s<<4) | (d & 0x0f)); \
        } while(0)

#define snd_set_osc1_ctrl(uint8_t gate, uint8_t triangle, uint8_t sawtooth, \
                          uint8_t pulse, uint8_t noise) \
        do { \
                _snd_set_osc1_ctrl((noise<<7 ) | (pulse<<6) | (sawtooth<<5) | \
                                   (trangle<<4) | gate); \
        } while (0)

#define snd_set_adsr2(uint8_t attack, uint8_t decay, \
                      uint8_t sustain, uint8_t release) \
        do { \
                _snd_set_adsr2_ad((a<<4) | (d & 0x0f)); \
                _snd_set_adsr2_sr((s<<4) | (d & 0x0f)); \
        } while(0)

#define snd_set_osc2_ctrl(uint8_t gate, uint8_t triangle, uint8_t sawtooth, \
                          uint8_t pulse, uint8_t noise) \
        do { \
                _snd_set_osc2_ctrl((noise<<7 ) | (pulse<<6) | (sawtooth<<5) | \
                                   (trangle<<4) | gate); \
        } while (0)

#define snd_set_adsr3(uint8_t attack, uint8_t decay, \
                      uint8_t sustain, uint8_t release) \
        do { \
                _snd_set_adsr3_ad((a<<4) | (d & 0x0f)); \
                _snd_set_adsr3_sr((s<<4) | (d & 0x0f)); \
        } while(0)

#define snd_set_osc3_ctrl(uint8_t gate, uint8_t triangle, uint8_t sawtooth, \
                          uint8_t pulse, uint8_t noise) \
        do { \
                _snd_set_osc3_ctrl((noise<<7 ) | (pulse<<6) | (sawtooth<<5) | \
                                   (trangle<<4) | gate); \
        } while (0)

#endif

