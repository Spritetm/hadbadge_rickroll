
Offset	equ	0x2B00

#define	keyint		PORTB,2		; key "INT" in
#define	clk			LATC,0		; cathode driver CLOCK
#define	sdo			LATA,6		; cathode driver DATA
#define	vdd			LATA,7		; Vdd ON/OFF switch
#define	keys		PORTB,7		; PGC / SW3...6 input
#define	usbv		PORTA,5		; USB V detect
#define	decoderena	LATB,6		; HI = anode decoder enable
#define	accsda		LATA,4
#define	accsda.port	PORTA,4
#define	accscl		LATA,3
#define	accsda.ts	TRISA,4
#define	accscl.ts	TRISA,3

DispBuf		equ	0x600

Buffer		equ	0x700	; display buffer, upper row first, bit 7 = left column, bit set = LED on
Buffer2		equ	0x710	; aux buffer (not displayed by interrupt display refresh)
BufferPause	equ	0x720	; pause buffer (displayed only during pause)
Ma0			equ	0x730	; rnd seed
Ma1			equ	0x731
Ma2			equ	0x732
Ma3			equ	0x733
Mc0			equ	0x734	; rnd acc
Mc1			equ	0x735
Mc2			equ	0x736
Mc3			equ	0x737

	CBLOCK		0

KeyEdge			; bits 3,2,1,0 are flags, set when keys 3,2,1,0 are JUST pressed
				; must be cleared in user routine
				; bit 0 set if key 0 (INT) just pressed
				; bit 1 set if key 1 (left) just pressed
				; bit 2 set if key 2 (up) just pressed
				; bit 3 set if key 3 (down) just pressed
				; bit 4 set if key 4 (right) just pressed

Rotor0			; used for key 0 (INT) debouncer   (rotate left, bit=0 if key pressed)
Rotor1			; used for key 1 (left) debouncer  (rotate left, bit=0 if key pressed)
Rotor2			; used for key 2 (up) debouncer    (rotate left, bit=0 if key pressed)
Rotor3			; used for key 3 (down) debouncer  (rotate left, bit=0 if key pressed)
Rotor4			; used for key 4 (right) debouncer (rotate left, bit=0 if key pressed)

Flag			; bit 0 set = pause mode
				; bit 1 set = Timer interrupt (1200 Hz) handshaking (set only)
				; bit 2 set = full scan (150 Hz) handshaking (set only)
				; bit 3 set = EEPROM buffer function disabled
				; bit 4 set = INT in second cycle (OFF period)
				; bit 5 set = Only two steps for key 0, without pause
				; bit 6 set = Display message received
				; bit 7 set = 

RXFlag			; bit 0 set = RX enable
				; bit 1 set = RX header reception in progress
				; bit 2 set = RX in progress
				; bit 3 set = RX message recived, flag to write terminator to EEPROM after timeout
				; bit 4 set = 
				; bit 5 set = 
				; bit 6 set = 
				; bit 7 set = 

Brightness		; display ON time, 0...15, used for dimming (15 = max brightness)
GPreg			; general purpose register
AnodeCount		; display multiplex counter 0...7
BitMask			; 10000000...00000001, shift right
T0period		; total (OFF+ON) period for T0
InnerInt		; inner loop counter
OuterInt		; outer loop counter
OutPlusInt		; one more outer loop counter
RXptr			; low RXD buffer pointer, high is always =6
RXpatience		; Patience counter, preset to 200 ms when byte received, count down
PowerOff		; Auto Power Off period (*6sec)
PowerCount		; Auto Power Off count down
Inner 			; inner loop counter (used outside int routine)
Outer			; outer loop counter (used outside int routine)
Uniform:2		; 150Hz freerunning uniform count up for 6 sec timing
RXserial:2		; received serial number BINARY, ready for comparison
MYserial:2		; serial number from ROM addr 0x100E
FSR0temp:2		; temporary FSR0 during INT

AccX:2			; Accelerometer X	(keep order!)
AccY:2			; Accelerometer Y	(keep order!)
AccZ:2			; Accelerometer Z	(keep order!)


