;Firmware for the music playing / start badge

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
;Phase of output. Only LSB is used to flip the pins the speaker is connected to every
;time the timer0 isr is called.
pwmph
;Reload values for music PWM. Indicates frequency of note played.
pwmrelh
pwmrell
;>0 if we need to send an IR start command
sendstart

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
	;Load reload values into timer
	movf pwmrelh,0,access
	movwf TMR0H
	movf pwmrell,0,access
	movwf TMR0L

	;Increase pwmph.
	incf pwmph,f,access
	;We use the toggling LSB of pwmph to output our square wave.
	btfss pwmph,0,access
	 bra inthilo
	
	;B5 positive, B3 negative
	bcf LATB,3,access
	bsf LATB,5,access

	;Return from interrupt.
	bcf		INTCON,TMR0IF,access
	retfie	FAST
inthilo:

	;B5 negative, B3 positive
	bcf LATB,5,access
	bsf LATB,3,access

	;Return from interrupt.
	bcf		INTCON,TMR0IF,access
	retfie	FAST


intlo
	;We don't use the lower interrupt.
	bra hang

thingstart
	;Don't do anything until user presses the power button.
	bcf		INTCON,TMR0IE,access
	btfsc PORTB,2
	 bra thingstart
	;Okay, let's go!
	bsf		INTCON,TMR0IE,access

	;Make pwmrel[l|h] some value that won't lead to trouble. This will be overwritten as
	;soon as the first note starts playing.
	movlw 0
	movwf pwmrell
	movlw .253
	movwf pwmrelh

	;Set TBLPTR to start of music table.
	movlw	low (music)
	movwf	TBLPTRL
	movlw	high (music)
	movwf	TBLPTRH

	;Timer 0 is used to generate tones.
	movlw	b'10000010'		; T0 on, 16 bit, prescaler=4
	movwf	T0CON,access

	;Timer 1 is used to keep track of the 60Hz ticks.
	movlw	b'00100001'
	movwf	T3CON,access	; Timer 3 runs at 12MHz
	
	;We want to send 6 start IR commands
	movlw	.6
	movwf	sendstart
	
hang
	;Wait until a 60Hz tick has completed.
	movlw	.195
	cpfseq	TMR3H,access
	  bra hang

	;Clear timer3 for next 60Hz tick
	movlw	.0
	movwf	TMR3H,access
	movwf	TMR3L,access

	;Read next reload value
	tblrd*+
	movf	TABLAT,w,access
	movwf	pwmrelh
	tblrd*+
	movf	TABLAT,w,access
	movwf	pwmrell

	;If sendstart is >0, send IR command.
	tstfsz sendstart,access
	 bra dosendstart
	;Not the case -> loop.
	bra hang

dosendstart
	;Send a start command.
	movlw 0xA5
	movwf TXREG1,access
	
	;One less start command left to send.
	decf sendstart,f,access
	
	;Jump to main loop.
	bra hang

;Music table. Starts out with 6 NOPs, to give the IR commands time to be sent.
;(Not really useful in practice, but hey...)
music:
	db 0xff, 0xf0
	db 0xff, 0xf0
	db 0xff, 0xf0
	db 0xff, 0xf0
	db 0xff, 0xf0
	#include "music.inc"

	END

