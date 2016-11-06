
;******************************************************************
;	system flags

ifz		macro
	btfsc	STATUS,Z,ACCESS
		endm
ifnz	macro
	btfss	STATUS,Z,ACCESS
		endm
ifc		macro
	btfsc	STATUS,C,ACCESS
		endm
ifnc	macro
	btfss	STATUS,C,ACCESS
		endm
rcf		macro
	bcf		STATUS,C,ACCESS
		endm
scf		macro
	bsf		STATUS,C,ACCESS
		endm

;******************************************************************

; macro sync150
sync150	macro
	btfss	Flag,2,ACCESS		; 150 Hz handshaking sync
	bra		$-2
	bcf		Flag,2,ACCESS		; reset sync flag
		endm

; macro sync150x8
sync150x8	macro
	btfss	Flag,1,ACCESS		; 150x8 Hz handshaking sync
	bra		$-2
	bcf		Flag,1,ACCESS		; reset sync flag
		endm

;******************************************************************

; macro iorbuf
iorbuf	macro	bufaddress
	movf	Buffer2+bufaddress,w,BANKED
	iorwf	Buffer+bufaddress,f,BANKED
		endm

;******************************************************************

; macro iorbuf3
iorbuf3	macro	buf3address
	movf	Buffer2+buf3address,w,BANKED
	iorwf	Buffer3+buf3address,f,BANKED
		endm

;******************************************************************

; macro overlap
overlap	macro	overaddress
	movf	Buffer2+overaddress,w,BANKED
	andwf	Buffer+overaddress,w,BANKED
	bnz		ovl.found
		endm

;******************************************************************

; macro test.new
test.new	macro
	movf	RXpatience,f,access


		endm

;******************************************************************

serialx2	macro
	rcf
	rlcf	RXserial+0,f,access
	rlcf	RXserial+1,f,access
	bc		preset.pat			; number overflow, ignore it
		endm
;******************************************************************

; accelerometer support
writreg			macro regdata
	movlw	regdata
	call	tx.i2c.ack
					endm

datahi			macro
	bsf		accsda.ts,ACCESS	; MCU data pin hi imp
	call	t38
					endm
datalo			macro
	bcf		accsda.ts,ACCESS	; MCU data pin low
	call	t38
					endm
clockhi			macro
	bsf		accscl.ts,ACCESS	; MCU clock pin hi imp
	call	t38
					endm
clocklo			macro
	bcf		accscl.ts,ACCESS	; MCU clock pin low
	call	t38
					endm
