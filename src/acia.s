.include "io.inc"
.include "macros.inc"


.zeropage
acia_puts_ptr: .res 2

.exportzp acia_puts_ptr


.code

.export acia_init
.proc acia_init
    pha
	lda #%00001011
    sta ACIA_COMMAND
    lda #%00011111
    sta ACIA_CONTROL
    pla
    rts
.endproc


.export acia_putc
.proc acia_putc
	phx
	ldx #$68
:	dex
	bne :-
	plx
	sta ACIA_DATA
	rts
.endproc


.export acia_getc
.proc acia_getc
:	lda ACIA_STATUS
	and #$08
	beq :-
	lda ACIA_DATA
	rts
.endproc


.export acia_puts
.proc acia_puts
	pha
:	lda (acia_puts_ptr)
	beq :+
	jsr acia_putc
	inc16 acia_puts_ptr
	bra :-
:	pla
	rts
.endproc


.export acia_put_hex_byte
.proc acia_put_hex_byte
    pha
    pha
    lsr
    lsr
    lsr
    lsr
    and #$0F
    tax
    lda s_hex_lut,x
    jsr acia_putc
    pla
    and #$0F
    tax
    lda s_hex_lut,x
    jsr acia_putc
    pla
    rts
.endproc


.rodata
s_hex_lut: .byte "0123456789ABCDEF"