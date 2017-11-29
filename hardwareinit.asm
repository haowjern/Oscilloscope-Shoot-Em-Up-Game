HardwareInit:                
	; ******* Stack Pointer Setup Code   ***************************************
		ldi r16, $0F		; Stack Pointer Setup
		out SPH,r16			; Stack Pointer High Byte 
		ldi r16, $FF		; Stack Pointer Setup 
		out SPL,r16			; Stack Pointer Low Byte 
			
	; ******* RAMPZ Setup Code *************************************************  
		ldi r16, $00		; 1 = EPLM acts on upper 64K
		out RAMPZ, r16		; 0 = EPLM acts on lower 64K
			
	; ******* Timer0 Setup Code ************************************************
		ldi r16,0b00000110	; Normal operation, timer continuously increment, then once overflows, repeat
		out TCCR0, r16		; Timer - PRESCALE TCK0 BY 256
		ldi r16,$0F			; load OCR0
		out OCR0,r16		; The compare will go every 255*1024*125 nsec (255 because of overflow, 1024 because of prescaler) 
			
	; ******* Interrupts Setup Code ********************************************
		ldi r16, 0b10000011	; OCIE0 & TOIE0
		out TIMSK, r16		; T0: Output compare match and Overflow

	; ******* ADC Init *******************************************
		ldi TempR1, 0b10000011	; check ADCSR register
		out ADCSRA, TempR1		; ADC Free Run Mode, Prescaler:CK/8

	; ******* Port A,B & D Setup Code *********************************************  
		ldi TempR1, $FF		; Port A & B as Output
		out DDRA, TempR1	
		ldi TempR1, $FF			
		out DDRB, TempR1
		ldi TempR1, $00
        out DDRD, TempR1	; Port D input
			
	; ******* RegInit *****************************************************   
		ldi TempR1, $00
		mov ZeroReg, TempR1
		ldi TempR1, $01
		mov OneReg, TempR1
		ldi TempR1, $02
		mov TwoReg, TempR1
			
	; ******* Interrupt ****  
		sei
		
	rjmp startgame