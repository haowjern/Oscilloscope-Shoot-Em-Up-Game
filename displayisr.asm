; In DisplayISR, are routines to display objects including the ship, 4 enemies, a bullet, the start screen and the gameover routine. In general, the displaying for each object uses the same method, that is to load data from SRAM,
; and output to PORTA and PORTB. 


DisplayISR:								
		push TempR1
		push TempR2
		push TempR3
		push TempR4
		in TempR4 ,SREG					; for SREG storage
		push YL
		push YH
		push XL
		push XH
		
		rcall Blink_Counter				
		rcall Check_Blink_Counter

		sbrs FlagReg, 0					; show Start Screen if bit 0 is clear
		rcall StartScreenDisplay
		sbrc FlagReg, 0					; Display Game if bit 0 is set
		rcall GameDisplay

		pop XH
		pop XL
		pop YH
		pop YL
		out SREG ,TempR4
		pop TempR4
		pop TempR3
		pop TempR2
		pop TempR1

		reti
		
	Blink_Counter:
		add BlinkCounterL, OneReg		; add 1 to blinkcounterL
		adc BlinkCounterH, ZeroReg		; carry over to blinkcounterH once blinkcounterL overflows 
		ret
			 
	Check_Blink_Counter:
		sbrc BlinkCounterL, 5			; every 16384 times it enters displayISR
		rcall Change_Blink_Flag
		ret

	Change_Blink_Flag:
		bst FlagReg, 5    				; copies into T flag
		mov TempR1, ZeroReg				; make TempR1 into zero
		bld TempR1, 0					; place data on TempR1
		inc TempR1						; 0 --> 1 or 1 --> 0
		bst TempR1, 0					; data placed back to FlagReg 5th bit
		bld FlagReg, 5
		mov BlinkCounterL, ZeroReg	    ; clear the counter after each bit inversion
		ret

;###############################################################################
;StartScreenDisplay
;###############################################################################
StartScreenDisplay:
	ldi YL, low(GameTitle_PeriY)		; load from SRAM which contains the center of mass + relative positions of each point  
	ldi YH, high(GameTitle_PeriY)
	ldi XL, low(GameTitle_PeriX)
	ldi XH, high(GameTitle_PeriX)
	rcall DisplayLoop					; output data to PORTA and PORTB for displaying

	sbrc FlagReg, 5						; display screen border
	rcall Corner_Disp
	sbrc FlagReg, 5	
	rcall Corner_Disp

	ldi YL, low(Press_Start_PeriY)		; repeat above
	ldi YH, high(Press_Start_PeriY)
	ldi XL, low(Press_Start_PeriX)
	ldi XH, high(Press_Start_PeriX)
	sbrs FlagReg, 5						; If blinking, don't display
	rcall DisplayLoop
	rcall Corner_Disp					; display screen border
	rcall delaycorner					; adjust the screen border's brightness 
	ret
		
;###############################################################################
;GameDisplay
;###############################################################################
GameDisplay:
	rcall Corner_Disp
	rcall Lives_Display			; display lives remaining by drawing hearts
	sbrc FlagReg, 1				; if game over
	rjmp GameOverDispMode		; freeze screen and blink a few times 
	
	; A/B Buffer system, to allow display interrupt to display a complete set of data e.g. from A, while processor computes for the other set of data, e.g. B. 
	sbrs FlagReg, 3				; skip B_mode if bit 3 set ---> displayA
	rcall A_DispMode
	sbrc FlagReg, 3				; skip A_mode if bit 3 clear 
	rcall B_DispMode

	ret

A_DispMode:
	rcall A_DisplaySShip		; Follow above method to display ship - load SRAM values and call DisplayLoop 
	sbrc ObjectStatus, 1		; If enemy1 is alive
	rcall A_DispEnemy1
	sbrc ObjectStatus, 2		; If enemy2 is alive
	rcall A_DispEnemy2
	sbrc ObjectStatus, 3		; If enemy3 is alive
	rcall A_DispEnemy3		
	sbrc ObjectStatus, 4		; If enemy4 is alive
	rcall A_DispEnemy4

	sbrc ObjectStatus, 7		; If bullet is alive
	rcall A_DispBullet
	rcall delaybullet
	ret
	
B_DispMode:
	rcall B_DisplaySShip
	sbrc ObjectStatus, 1
	rcall B_DispEnemy1
	sbrc ObjectStatus, 2
	rcall B_DispEnemy2
	sbrc ObjectStatus, 3
	rcall B_DispEnemy3
	sbrc ObjectStatus, 4
	rcall B_DispEnemy4

	sbrc ObjectStatus, 7
	rcall B_DispBullet
	rcall delaybullet
	ret
	
A_DisplaySShip:
		ldi YL, low(A_SShipPeri_Y)		; Sets the pointer to memory block for data retrieval
		ldi YH, high(A_SShipPeri_Y)
		ldi XL, low(A_SShipPeri_X)
		ldi XH, high(A_SShipPeri_X)
		
		rcall TopPoint					; store TopPoint of ship in SRAM 
		rcall SidePoints				; store 2 side points - left and right of ship in SRAM
										; used to identify collisions
		rcall DisplayLoop
		ret

B_DisplaySShip:
		ldi YL, low(B_SShipPeri_Y)
		ldi YH, high(B_SShipPeri_Y)
		ldi XL, low(B_SShipPeri_X)
		ldi XH, high(B_SShipPeri_X)

		rcall TopPoint
		rcall SidePoints

		rcall DisplayLoop
		ret
		
A_DispEnemy1:
		ldi YL, low(A_Enemy1Peri_Y)
		ldi YH, high(A_Enemy1Peri_Y)
		ldi XL, low(A_Enemy1Peri_X)
		ldi XH, high(A_Enemy1Peri_X)
		rcall DisplayLoop
		ret

B_DispEnemy1:
		ldi YL, low(B_Enemy1Peri_Y)
		ldi YH, high(B_Enemy1Peri_Y)
		ldi XL, low(B_Enemy1Peri_X)
		ldi XH, high(B_Enemy1Peri_X)
		rcall DisplayLoop
		ret
		
A_DispEnemy2:
		ldi YL, low(A_Enemy2Peri_Y)
		ldi YH, high(A_Enemy2Peri_Y)
		ldi XL, low(A_Enemy2Peri_X)
		ldi XH, high(A_Enemy2Peri_X)
		rcall DisplayLoop
		ret

B_DispEnemy2:
		ldi YL, low(B_Enemy2Peri_Y)
		ldi YH, high(B_Enemy2Peri_Y)
		ldi XL, low(B_Enemy2Peri_X)
		ldi XH, high(B_Enemy2Peri_X)
		rcall DisplayLoop
		ret

A_DispEnemy3:
		ldi YL, low(A_Enemy3Peri_Y)
		ldi YH, high(A_Enemy3Peri_Y)
		ldi XL, low(A_Enemy3Peri_X)
		ldi XH, high(A_Enemy3Peri_X)
		rcall DisplayLoop
		ret

B_DispEnemy3:
		ldi YL, low(B_Enemy3Peri_Y)
		ldi YH, high(B_Enemy3Peri_Y)
		ldi XL, low(B_Enemy3Peri_X)
		ldi XH, high(B_Enemy3Peri_X)
		rcall DisplayLoop
		ret

A_DispEnemy4:
		ldi YL, low(A_Enemy4Peri_Y)
		ldi YH, high(A_Enemy4Peri_Y)
		ldi XL, low(A_Enemy4Peri_X)
		ldi XH, high(A_Enemy4Peri_X)
		rcall DisplayLoop
		ret

B_DispEnemy4:
		ldi YL, low(B_Enemy4Peri_Y)
		ldi YH, high(B_Enemy4Peri_Y)
		ldi XL, low(B_Enemy4Peri_X)
		ldi XH, high(B_Enemy4Peri_X)
		rcall DisplayLoop
		ret
	
DisplayLoop:						; Tiny delay before displaying the next point
		rcall delay25				; makes the points brighter, dimmer lines in between points
		ld tempR1, Y+
		cpi tempR1, $FF				; End of memory block marker during storage
		breq DisplayEscape
		cpi tempR1, $00				; Skip displaying this point since it is out of screen
		breq SkipPoint
		out PORTA, tempR1 			; y axis output

		ld tempR1, X+ 
		cpi tempR1, $00				; Escape condition not needed here as len(y) = len(x)
		breq SkipPoint
		out PORTB, tempR1 			; x axis output
		
		rjmp displayloop			; loop again for the next point
		
	SkipPoint:
		ld tempR1, X+				; Since Y has incremented by one and not displayed,
		rjmp displayloop			; X must increment by one and not display as well

	DisplayEscape:
		ret

A_DispBullet:
	lds TempR1, A_BulletPos_YL		; Coversion of 16 bit data
	lds TempR2, A_BulletPos_YH		; to 8 bit data
	rol TempR1						; low byte
	rol TempR2						; high byte
	rol TempR1						; low byte
	rol TempR2						; high byte
	sts BulletPos_Y, TempR2			; this information is for collision checking
   	out PORTA, TempR2

   	lds TempR1, BulletPos_X
   	out PORTB, TempR1    
   	ret
	 
B_DispBullet:
	lds TempR1, B_BulletPos_YL
	lds TempR2, B_BulletPos_YH
	rol TempR1	; low byte
	rol TempR2	; high byte
	rol TempR1	; low byte
	rol TempR2	; high byte
	sts BulletPos_Y, TempR2
   	out PORTA, TempR2    

   	lds TempR1, BulletPos_X
   	out PORTB, TempR1
   	ret
	
;----------------------------------------------------------------------------------------------
GameOverDispMode:
	sbrs FlagReg, 5				; If not blinking, display game
	rcall A_DispMode			; Any display A/B is fine
	sbrc FlagReg, 5				; If blinking, display blinking screen border
	rcall Corner_Disp
	ret
	
Corner_Disp:
	out PORTA, ZeroReg
	out PORTB, ZeroReg
	rcall delay1800
	ldi TempR1, 0b11111111
	out PORTA, ZeroReg
	out PORTB, TempR1
	rcall delay1800
	out PORTA, TempR1
	out PORTB, TempR1
	rcall delay1800
	out PORTA, TempR1
	out PORTB, ZeroReg
	ret

Corner_Disp_Short:
	out PORTA, ZeroReg
	out PORTB, ZeroReg
	rcall delaycorner
	ldi TempR1, 0b11111111
	out PORTA, ZeroReg
	out PORTB, TempR1
	rcall delaycorner
	out PORTA, TempR1
	out PORTB, TempR1
	rcall delaycorner
	out PORTA, TempR1
	out PORTB, ZeroReg
	ret
;---------------------------------------------------------------------------------------------

	toppoint:
		ld TempR1, Y				; Takes the first point from memory block
		sts SShip_TopY, TempR1		; it corresponds to the top row, left most point

		ld TempR1, X 				; Takes the 2nd point, top row, right most point
		sts SShip_TopX, TempR1 
		ret

	SidePoints:						; storing of points in SRAM, location of points is determined by selecting the point we need from the actual data
		mov TempR3, YL
		mov TempR4, YH
		mov TempR5, XL
		mov TempR6, XH

		ldi TempR2, $08
		add YL, TempR2
		adc YH, ZeroReg
		ld TempR1, Y
		sts SShip_LeftY, TempR1

		add XL, TempR2
		adc XH, ZeroReg
		ld TempR1, X 
		sts SShip_LeftX, TempR1 

		ldi TempR2, $03
		add YL, TempR2
		adc YH, ZeroReg
		ld TempR1, Y				; Takes the first point from memory block
		sts SShip_RightY, TempR1	; it corresponds to the top row, left most point

		add XL, TempR2
		adc XH, ZeroReg
		ld TempR1, X 				
		sts SShip_RightX, TempR1	; Takes the 2nd point, top row, right most point
		mov YL, TempR3
		mov YH, TempR4
		mov XL, TempR5
		mov XH, TempR6
		ret

;----------------------------------------------------------------------------------------------
LLives_Display:
	ldi TempR1, $03					; load 3 lives
	cp Lives_Left, TempR1			; if 3 lives left, 
	breq Display2Heart				; display 2 hearts only
	cp Lives_Left, TwoReg			; if 2 lives left, 
	breq Display1Heart				; display 1 heart only
	ret
	
DDisplay2Heart:	
	ldi YL, low(Heart2_Y)
	ldi YH, high(Heart2_Y)
	ldi XL, low(Heart2_X)
	ldi XH, high(Heart2_X)
	rcall DisplayLoop
	ret

DDisplay1Heart:	
	ldi YL, low(Heart1_Y)
	ldi YH, high(Heart1_Y)
	ldi XL, low(Heart1_X)
	ldi XH, high(Heart1_X)
	rcall DisplayLoop
	ret
