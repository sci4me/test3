.include "io.inc"
.include "macros.inc"


.import leds_init
.import leds_update
.importzp leds_enabled
.importzp leds_value

.import acia_init
.import acia_putc
.import acia_puts
.import acia_put_hex_byte
.importzp acia_puts_ptr


LEDS_TIMER_INTERVAL = 100
MSEC_TIMER_INTERVAL = 50000


.zeropage
msec_counter: .res 1


.segment "VECTORS"
.addr nmi
.addr reset
.addr irq


.code
.proc nmi
	rti
.endproc

.macro endisr
	ply
	plx
	pla
	rti
.endmacro

.proc irq
	pha
	phx
	phy

	ldx IRQSRC
	jmp (isrs,x)
.endproc

.rodata
.align 256 ; Not needed? *shrugs* Not really sure how ld65's alignment is handled so.. ehh.
isrs:
.addr isr_invalid
.addr isr_invalid
.addr isr_invalid
.addr isr_invalid
.addr isr_invalid
.addr isr_via2
.addr isr_via1
.addr isr_acia
.repeat 120
.addr isr_invalid
.endrepeat
.code

.proc isr_acia
	lda ACIA_STATUS
	; TODO
	endisr
.endproc

.proc isr_via1
	jsr leds_update
	lda VIA1_T1C_L
	endisr
.endproc

.proc isr_via2
	lda msec_counter
	inc a
	cmp #20
	bne :+
	lda #0
		inc leds_value
:	sta msec_counter

	lda VIA2_T1C_L
	endisr
.endproc

.proc isr_invalid
	; TODO
	endisr
.endproc


.proc reset
	sei
	cld
	ldx #$FF
	txs


	jsr leds_init

	jsr acia_init


	;lda #%01000000
	;sta VIA1_ACR
	;lda #%11000000
	;sta VIA1_IER
	;lda #<LEDS_TIMER_INTERVAL
	;sta VIA1_T1C_L
	;lda #>LEDS_TIMER_INTERVAL
	;sta VIA1_T1C_H

	lda #%01000000
	sta VIA2_ACR
	lda #%11000000
	sta VIA2_IER
	lda #<MSEC_TIMER_INTERVAL
	sta VIA2_T1C_L
	lda #>MSEC_TIMER_INTERVAL
	sta VIA2_T1C_H

	cli

loop:
	jsr leds_update
	bra loop
.endproc