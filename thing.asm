
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

plane

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
	incf	AnodeCount,f,access	; 0...7
; rotates with no carry BitMask (slower than single RLNCF, but more safe)
	rcf							; clear Carry
	rlcf	BitMask,f,access	; Shift Right BitMask      0 ---> 10000000 --->
	bnz		no.reconstruction
	clrf	AnodeCount,access
	bsf		BitMask,0,access	; bit reconstruction BitMask
	bsf		Flag,2,access		; 150 Hz full scan handshaking flag

	incf	plane,f,access
	movlw	.63
	andwf	plane,f,access
no.reconstruction
	;Make a reg zero
	movlw	.0
	movwf	GPreg, access
	;Grab plane selector
	movlw	low (planesel)
	addwf	plane, w, access
	movwf	TBLPTRL
	movlw	high (planesel)
	addwfc	GPreg,w,access
	movwf	TBLPTRH
	tblrd*

	;Calculate plane address
	movlw	low (img)
	addwf	TABLAT,w
	movwf	TBLPTRL
	movlw	high (img)
	addwfc	GPreg,w,access
	movwf	TBLPTRH

	bcf		decoderena			; turn on anode drivers


	variable xx
xx=0
	while xx<.16
		bcf		sdo,ACCESS
		tblrd*+
		movf	BitMask,w,ACCESS
		andwf	TABLAT,w
		ifnz
		bsf		sdo,ACCESS		; Transfer "BitMask" state in POSTDEC0 to "sdo" pin
		bcf		clk,ACCESS		; ^^^\___	generate "clk" pulse
		bsf		clk,ACCESS		; ___/^^^	shift out one bit
xx+=1
	endw

; Sets anode decoder, depended on AnodeCount
	movf	LATA,w,access
	andlw	b'11111000'			; mask out bits 210 (hardware dependent!)
	iorwf	AnodeCount,w,access
	movwf	LATA,access			; set decoder
	bsf		decoderena			; turn on andode drivers
; Exit interrupt routine														
	movff	FSR0temp+0,FSR0L		; restore FSR0
	movff	FSR0temp+1,FSR0H		; restore FSR0
exit2
	bsf		Flag,1,access			; 150x8 Hz handshaking flag
	bcf		INTCON,TMR0IF,access
	retfie	FAST
;	
it.was.int0
	bcf		INTCON,INT0IF,access	; reset INT0IF flag also, to avoid int retrigering
	retfie	FAST


intlo
	;E_NOCLUE
	bra hang

thingstart
	bcf		RXFlag,0,access	; disable RX
	bsf		Flag,5,access	; bit 5 set = Only two steps for key 0, without pause

	movlw	b'11000000'		; T0 on, 8 bit, prescaler=128
	movwf	T0CON,access
	movlw	.1				; int on  78*128t = 9984T  (1202 Hz)
	movwf	T0period,access

hang
	bra hang


planesel: 
	db 0x00, 0x00, 0x10, 0x00, 0x20, 0x00, 0x10, 0x00, 0x30, 0x00, 0x10, 0x00, 0x20, 0x00, 0x10, 0x00
	db 0x00, 0x40, 0x00, 0x10, 0x00, 0x20, 0x00, 0x10, 0x00, 0x30, 0x00, 0x10, 0x00, 0x20, 0x00, 0x10
	db 0x00, 0x50, 0x00, 0x10, 0x00, 0x20, 0x00, 0x10, 0x00, 0x30, 0x00, 0x10, 0x00, 0x20, 0x00, 0x10
	db 0x00, 0x40, 0x00, 0x10, 0x00, 0x20, 0x00, 0x10, 0x00, 0x30, 0x00, 0x10, 0x00, 0x20, 0x00, 0x10

;	db 0*0x10,3*16,0*16,1*16,0*16,2*16,0*16,1*16,0*16,0*16,1*16,0*16,2*16,0*16,1*16,0*16,0*16
;	db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;	db 16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16
img:
	#include "img.inc"

	END

