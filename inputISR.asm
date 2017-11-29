Joystick_Button_Inputs:		; joystick takes in a value of 0 - 2.5V (0b0000000000 - 0b1111111111) for each axis.
		push TempR4
		in TempR4, SREG
		push TempR1
		push TempR2
		push TempR3

		; take in x coordinates (left right)
		ldi TempR1, 0b00100000	; take in x input, and want to look at only ADCH 
        out ADMUX, TempR1		; open channel 0, and set 1 to dslar

		SBI ADCSR, 6			; start conversion to take in ADCH
		in TempR2, ADCH
		rcall delay
ADCCLR1:
		SBI ADCSRA, 4			; clears the interrupt flag, if flag is already set
		SBIC ADCSRA, 4			; repeat until conversion is finished
		RJMP ADCCLR1

		bst TempR2, 7			; 7 bit indicates if the direction of the joystick (left, right, top, bottom) 
		brts pos_vel_x			; if set, joystick is in the positive x direction

neg_vel_x:						
		sbrc TempR2, 6			; check 6th bit, if it is set, indicates zero velocity 
		jmp zero_vel_x
		
	neg_vel_x_cont:					; else is negative
		ldi TempR3, $FF				; from our velocity scheme, we don't want too big of a negative velocity
		sbrc Boundary_Reg, 2		; check if spaceship is at left wall
   		ldi TempR3, $00

		sts A_SShipVel_XH, TempR3	; negative velocity is $0xxxxxxx
		sts B_SShipVel_XH, TempR3

		ldi TempR2, $C3				; set a small speed for spaceship
		sbrc Boundary_Reg, 2		; check if spaceship is at left wall
   		ldi TempR2, $00
		sts A_SShipVel_XL, TempR2
		sts B_SShipVel_XL, TempR2
		jmp vel_y

zero_vel_x:							; ideally, joystick input should be 10000000 at centre position
		ldi TempR3, $00				; but this joystick gives an input of 01xxxxxx instead
		sts A_SShipVel_XH, TempR3	; hence set both vel to 0 to indicate 0 velocity
		sts B_SShipVel_XH, TempR3

		sts A_SShipVel_XL, TempR3
		sts B_SShipVel_XL, TempR3
		jmp vel_y					; jmp to calculate for y velocity

pos_vel_x:
	pos_vel_x_cont:
		ldi TempR3, $00				; from our velocity scheme, we don't want too big of a positive velocity
		sts A_SShipVel_XH, TempR3
		sts B_SShipVel_XH, TempR3
		ldi TempR2, $3C				; set a small speed for our spaceship
   		sbrc Boundary_Reg, 3		; check if spaceship is at right wall
   		ldi TempR2, $00				
		sts A_SShipVel_XL, TempR2
		sts B_SShipVel_XL, TempR2

;-------------
vel_y: 
		; take in y coordinates (up down)
		ldi TempR1, 0b00100001		; take in y input, and want to look at only ADCH 
        out ADMUX, TempR1			; open channel 1, and set 1 to dslar

		; put in sign bit
		SBI ADCSR, 6				; start conversion to take in ADCH
		in TempR2, ADCH
		rcall delay
ADCCLR2:
		SBI ADCSR, 4				; clears the interrupt flag, if flag is already set
		SBIC ADCSRA, 4				; repeat until conversion is finished
		RJMP ADCCLR2				

		bst TempR2, 7				; 7 bit indicates if the direction of the joystick (left, right, top, bottom) 
		brts pos_vel_y				; if set, joystick is in the positive y direction
		
neg_vel_y: 
		sbrc TempR2, 6				; check 6th bit, if it is set, indicates zero velocity 
		jmp zero_vel_y

	neg_vel_y_cont:					; else is negative
		ldi TempR3, $FF
		sbrc Boundary_Reg, 0		; check if spaceship is at bottom wall
   		ldi TempR3, $00

		sts A_SShipVel_YH, TempR3
		sts B_SShipVel_YH, TempR3

		ldi TempR2, $C3
   		sbrc Boundary_Reg, 0		; check if spaceship is at bottom wall
   		ldi TempR2, $00

		sts A_SShipVel_YL, TempR2
		sts B_SShipVel_YL, TempR2
		jmp exit_JoyStick

zero_vel_y:
		ldi TempR3, $00
		sts A_SShipVel_YH, TempR3
		sts B_SShipVel_YH, TempR3

		sts A_SShipVel_YL, TempR3
		sts B_SShipVel_YL, TempR3
		jmp exit_Joystick

pos_vel_y:
		ldi TempR3, $00
		sts A_SShipVel_YH, TempR3
		sts B_SShipVel_YH, TempR3

		ldi TempR2, $3C
   		sbrc Boundary_Reg, 1		 ; check if spaceship is at top wall
   		ldi TempR2, $00

		sts A_SShipVel_YL, TempR2
		sts B_SShipVel_YL, TempR2
		
exit_Joystick:		
		rcall CheckButton
		pop TempR3
		pop TempR2
		pop TempR1
		out SREG, TempR4
		pop TempR4
		
		reti 
		
CheckButton:										; Check if button is pressed, which raises bit 6 of FlagReg
		cbr FlagReg, 0b01000000
		in CurrentButtonState, PIND
		cpse PrevButtonState, CurrentButtonState	; flag only sets if button is is 'pressed', and doesn't take in input if button is held
		rcall ButtonChanged
		mov PrevButtonState, CurrentButtonState
		ret

	ButtonChanged:
		ldi TempR1, 0b11111111	
		cpse CurrentButtonState, TempR1
    		rcall Trigger_Event
		mov CurrentButtonState, TempR1
		ret
		
	Trigger_Event:
		sbr FlagReg, 0b01000000
		ret
