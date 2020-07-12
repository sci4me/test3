.include "io.inc"

.zeropage
leds_value: 	.res 1
leds_enabled: 	.res 1
leds_ctr: 		.res 1

.exportzp leds_value
.exportzp leds_enabled


.code
.export leds_init
.proc leds_init
	pha
	
	stz LEDS1
	stz LEDS2

	stz leds_value
	stz leds_ctr

	lda #1
	sta leds_enabled

	pla
	rts
.endproc


.export leds_update
.proc leds_update
	pha
	phx

	lda leds_enabled
	beq @disabled


	lda leds_ctr
	inc a
	cmp #35
	bne :+
	lda #0
: 	sta leds_ctr

	tax
	lda duty_lut,x
	beq :+
	jsr leds_set_value
	bra @end
:	stz LEDS1
	stz LEDS2
	bra @end

@disabled:
	stz LEDS1
	stz LEDS2
	stz leds_ctr

@end:
	plx
	pla
	rts
.endproc


.export leds_set_value
.proc leds_set_value
	pha
	phx

	lda leds_value
	and #$0F
	tax
	lda s_7seg_lut,x
	sta LEDS2

	lda leds_value
	and #$F0
	lsr
	lsr
	lsr
	lsr
	tax
	lda s_7seg_lut,x
	sta LEDS1

	plx
	pla
	rts
.endproc


.rodata
s_7seg_lut:
	.byte %00111111
	.byte %00000110
	.byte %01011011
	.byte %01001111
	.byte %01100110
	.byte %01101101
	.byte %01111101
	.byte %00000111
	.byte %01111111
	.byte %01101111
	.byte %01110111
	.byte %01111100
	.byte %00111001
	.byte %01011110
	.byte %01111001
	.byte %01110001

; NOTE: Yes this is kind of silly, but, yknow. Originally I did it with a counter and comparison,
; as you'd expect, but then I decided I didn't care about having the ability to change the duty cycle
; at runtime, and this felt simpler at the time.
duty_lut:
	.byte 1
	.repeat 34
	.byte 0
	.endrepeat