
	LIST P=18LF25K50
	#include <p18lf25k50.inc>
	#include <macros 2.inc>

access		equ	0
banked		equ	1

rnd			set	Offset+0x000c
reset.i2c	set	Offset+0x0010
get.accel	set	Offset+0x0014
get.1.byte	set Offset+0x001c
put.1.byte	set Offset+0x0020

dispbuf	equ	0x600

;***************************************************************************************************
;	KERNEL RAM DEFINITIONS																			
;***************************************************************************************************

	#include	<RAMdef.inc>

;***********************************************************
;	DEMO RAM DEFINITIONS									
;***********************************************************
pwmph
pwmrelh
pwmrell

	ENDC

;*******************************************************************************
;						D E M O   F A R M	 									
;*******************************************************************************

demo.ept
;Start addr
	org		Offset+0x0800
	goto	thingstart

;Inthi
	org		Offset+0x0808
	goto	inthi

;IntLo
	org		Offset+0x0818
	goto	intlo



inthi
	movf pwmrelh,0,access
	movwf TMR0H
	movf pwmrell,0,access
	movwf TMR0L

	incf pwmph,f,access
	btfss pwmph,0,access
	 bra inthilo
	
	bcf LATB,3,access
	bsf LATB,5,access

	bcf		INTCON,TMR0IF,access
	retfie	FAST
inthilo:

	bcf LATB,5,access
	bsf LATB,3,access

	bcf		INTCON,TMR0IF,access
	retfie	FAST


intlo
	;E_NOCLUE
	bra hang

thingstart

	movlw 0
	movwf pwmrell
	movlw .253
	movwf pwmrelh

	movlw	low (music)
	movwf	TBLPTRL
	movlw	high (music)
	movwf	TBLPTRH

	movlw	b'10000010'		; T0 on, 16 bit, prescaler=4
	movwf	T0CON,access

	movlw	b'00100001'
	movwf	T3CON,access	; Timer 3 runs at 12MHz
	
hang
	movlw	.195
	cpfseq	TMR3H,access
	  bra hang

	movlw	.0
	movwf	TMR3H,access
	movwf	TMR3L,access

	tblrd*+
	movf	TABLAT,w,access
	movwf	pwmrelh
	tblrd*+
	movf	TABLAT,w,access
	movwf	pwmrell

	bra hang


music:
	#include "music.inc"

	END

