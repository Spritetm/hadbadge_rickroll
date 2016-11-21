;Firmware for the three video player badges.

;THE BEER-WARE LICENSE" (Revision 42): Sprite_tm <jeroen@spritesmods.com> wrote most of this file. As long as 
;you retain this notice you can do whatever you want with this stuff. If we meet some day, and you think 
;this stuff is worth it, you can buy me a beer in return

;Modified from the original badge code by Voja Antonic

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

;Current index into planesel
plane
;Position in flash of the current movie frame
movposh
movposl
;Frame counter. Increases every time a plane gets displayed; if
;this overflows the next movie frame is displayed.
framectr
;If !0, the movie stays at the first frame.
noanim


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
	;First, check if we got anything over the UART that's connected to the IR receiver.
	btfss   PIR1,RCIF,access    ; is RX register empty?
	 bra     no.rx              ; RX register is empty; ignore rx code.
	
	;We received something over infrared. See if it's the magic start character 0xA5.
	movlw	0xa5
	cpfseq RCREG1
	 bra no.rx
	;Yep. Clear the noanim flag so the movie starts playing.
	movlw	0
	movwf	noanim

no.rx
	;This probably is a timer interrupt. No real need to check that, it 
	;comes in really frequently anyway...

	;Select next row of pixes
	incf	AnodeCount,f,access	; 0...7
; rotates with no carry BitMask (slower than single RLNCF, but more safe)
	rcf							; clear Carry
	rlcf	BitMask,f,access	; Shift Right BitMask      0 ---> 10000000 --->
	bnz		no.reconstruction	; If we shifted out the bit, we're done with this plane.
	;Yep, we're done with the plane. Clear AnodeCount, move in new bit for 1st row.
	clrf	AnodeCount,access
	bsf		BitMask,0,access	; bit reconstruction BitMask
	bsf		Flag,2,access		; 150 Hz full scan handshaking flag

	;Display next plane. We have 64 entries in planecnt; do an and to make the plane
	;variable loop back to 0 when it's 64.
	incf	plane,f,access
	movlw	.63
	andwf	plane,f,access

	;If noanim is set, we do not advance the movie.
	tstfsz	noanim
	 bra no.reconstruction

	;We advance the movie every 256 planes, or when the framectr variable overflows.
	incf	framectr,f,access
	bnz		no.reconstruction	;Skip if framectr hasn't overflown yet.

	;Each frame is 0x60 bytes, so we add that to movpos[h|l] to advance the frame by one.
	movlw	0x60
	addwf	movposl,f,access
	movlw	.0
	addwfc	movposh,f,access

no.reconstruction
	;Make GPreg reg zero
	movlw	.0
	movwf	GPreg, access
	;Grab planesel[plane]
	movlw	low (planesel)
	addwf	plane, w, access
	movwf	TBLPTRL
	movlw	high (planesel)
	addwfc	GPreg,w,access
	movwf	TBLPTRH
	tblrd*
	;planesel[plane] now is in TBLAT.

	;Calculate plane address by adding the plane selector
	;to movpos[h|l].
	movf	movposl,w,access
	addwf	TABLAT,w
	movwf	TBLPTRL
	movf	movposh,w,access
	addwfc	GPreg,w,access
	movwf	TBLPTRH

	bcf		decoderena			; turn on anode drivers

	;Original image code from kernel: for each byte in the plane data, extract the bit belonging
	;to the current row and send it to the shift register.
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
	;E_NOCLUE. Probably isn't hooked up.
	bra hang

thingstart
	bcf		RXFlag,0,access	; disable RX
	bsf		Flag,5,access	; bit 5 set = Only two steps for key 0, without pause

	;Don't start the animation yet.
	movlw	1
	movwf	noanim

	;Point movie frame pointer at first frame of movie
	movlw	low (img)
	movwf	movposl
	movlw	high (img)
	movwf	movposh

	;Reset frame counter to 0. Not very useful, but eh.
	movlw	.0
	movwf	framectr

	
	movlw	b'11000000'		; T0 on, 8 bit, prescaler=1
	movwf	T0CON,access
	;This makes a new plane appear every 256*8 clock ticks, or about 6000 times per second. With
	;the plane selector table looping every 64 planes, th frame rate is about 100Hz. Which would flicker
	;pretty badly if we would not use the BAM scheme used here :)

	;Just hang. From here, the interrupt handler will take care of the rest.
hang
	bra hang


	;Array of bytes indicating the order of planes to display. This table is pre-multiplied by 0x10
	;so we can add it directly to the movie pointer (planes have a data size of 0x10; one byte per 
	;row)
planesel: 
	db 0x00, 0x00, 0x10, 0x00, 0x20, 0x00, 0x10, 0x00, 0x30, 0x00, 0x10, 0x00, 0x20, 0x00, 0x10, 0x00
	db 0x00, 0x40, 0x00, 0x10, 0x00, 0x20, 0x00, 0x10, 0x00, 0x30, 0x00, 0x10, 0x00, 0x20, 0x00, 0x10
	db 0x00, 0x50, 0x00, 0x10, 0x00, 0x20, 0x00, 0x10, 0x00, 0x30, 0x00, 0x10, 0x00, 0x20, 0x00, 0x10
	db 0x00, 0x40, 0x00, 0x10, 0x00, 0x20, 0x00, 0x10, 0x00, 0x30, 0x00, 0x10, 0x00, 0x20, 0x00, 0x10

	;Movie data.
img:
	#include "mov.inc"

	END

