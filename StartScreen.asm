ComputeStartScreen:
	rcall PressToStart				; store 'press the start' graphic to sram	
	rcall GameTitle					; store 'Game Title' graphic to sram

	ret
;-------------------------------------------------------
PressToStart:
	ldi TempR4, 0b00011110        	; y center of mass (lower quarter of screen)
	ldi TempR3, 0b00000000 
	ldi ZL, low(PressToStart_y*2)	; points to table
	ldi ZH, high(PressToStart_y*2)
	ldi XL, low(Press_Start_PeriY)	; points to memory block
	ldi XH, high(Press_Start_PeriY)	 
	rcall Storage_Loop

	ldi TempR4, 0b00100000        	; X center of mass (lower quarter of screen)
	ldi TempR3, 0b00000000 
	ldi ZL, low(PressToStart_x*2)	; points to table
	ldi ZH, high(PressToStart_x*2)
	ldi XL, low(Press_Start_PeriX)	; points to memory block
	ldi XH, high(Press_Start_PeriX)
	rcall Storage_Loop
    
	ret

	
GameTitle:
	ldi TempR4, 0b00101100        	; Y center of mass (lower quarter of screen)
	ldi TempR3, 0b00000000 
	ldi ZL, low(GameTitle_y*2)		; points to table
	ldi ZH, high(GameTitle_y*2)
	ldi XL, low(GameTitle_PeriY)	; points to memory block
	ldi XH, high(GameTitle_PeriY)	 
	rcall Storage_Loop
    
	ldi TempR4, 0b00100000        	; Y center of mass (lower quarter of screen)
	ldi TempR3, 0b00000000 
	ldi ZL, low(GameTitle_x*2)		; points to table
	ldi ZH, high(GameTitle_x*2)
	ldi XL, low(GameTitle_PeriX)	; points to memory block
	ldi XH, high(GameTitle_PeriX)
	rcall Storage_Loop    
    
	ret
;---------------------------------------------------------   	 