 A_Compute:

	rcall A_SShip				; A scheme uses data from block B and stores it into block A

	sbrc ObjectStatus, 1		; if enemy1 is alive
	rcall A_Enemy1
	sbrc ObjectStatus, 2		; if enemy2 is alive and so on... 
	rcall A_Enemy2
	sbrc ObjectStatus, 3
	rcall A_Enemy3
	sbrc ObjectStatus, 4
	rcall A_Enemy4
	sbrc ObjectStatus, 7  
    rcall A_Bullet
	
	sbr FlagReg, 0b00001000		; Set RAMReg to alternate between A and B Scheme
	rjmp Game
	
B_Compute:

	rcall B_SShip

	sbrc ObjectStatus, 1
		rcall B_Enemy1
	sbrc ObjectStatus, 2
		rcall B_Enemy2
	sbrc ObjectStatus, 3
		rcall B_Enemy3
	sbrc ObjectStatus, 4
		rcall B_Enemy4
	sbrc ObjectStatus, 7
		rcall B_Bullet

	cbr FlagReg, 0b00001000		; Clear RAMReg
	rjmp Game

;########################################################
; Revival System
;########################################################
Enemy_Revive:	

	sbrs ObjectStatus, 1		; if dead,
	rcall Enemy1Create			; init enemy 
	sbrs ObjectStatus, 2
	rcall Enemy2Create
	sbrs ObjectStatus, 3
	rcall Enemy3Create
	sbrs ObjectStatus, 4
	rcall Enemy4Create
	ret
		
	Enemy1Create:
		cpse EnemyCount, EnemyCountThreshold	; ensure number of enemies do not exceed total number of enemies allowed
		sbr ObjectStatus, 0b00000010
		cpse EnemyCount, EnemyCountThreshold
		rcall InitEnemy1
		cpse EnemyCount, EnemyCountThreshold
		inc EnemyCount
		ret
		
	Enemy2Create:
		cpse EnemyCount, EnemyCountThreshold
		sbr ObjectStatus, 0b00000100
		cpse EnemyCount, EnemyCountThreshold
		rcall InitEnemy2
		cpse EnemyCount, EnemyCountThreshold
		inc EnemyCount
		ret	
	
	Enemy3Create:
		cpse EnemyCount, EnemyCountThreshold
		sbr ObjectStatus, 0b00001000
		cpse EnemyCount, EnemyCountThreshold
		rcall InitEnemy3
		cpse EnemyCount, EnemyCountThreshold
		inc EnemyCount
		ret
	Enemy4Create:
		cpse EnemyCount, EnemyCountThreshold
		sbr ObjectStatus, 0b00010000
		cpse EnemyCount, EnemyCountThreshold
		rcall InitEnemy4
		cpse EnemyCount, EnemyCountThreshold
		inc EnemyCount
		ret

;############################################################

A_SShip:							; Data extracted from block B
	lds TempR1, B_SShipPos_YL		; y low byte
	lds TempR2, B_SShipPos_YH		; y highbyte
	lds TempR3, B_SShipVel_YL		; dy low byte
	lds TempR4, B_SShipVel_YH		; dy high byte
	rcall TwoByteAddition			; carry from low byte is handled into high byte	
	mov Boundary_Reg, ZeroReg		; clear boundary_reg that determines the boundary walls of the ship
	lds TempR4, BC_Y_L				; load bottom wall boundary 
	cp TempR2, TempR4				
	brlo A_BC_Flag_0				; if y position is lower than this, set a value for boundary_reg, boundary_reg will be compared with in Inputs to change velocity to 0 to stop object moving

A_Done_YL:
	lds TempR4, BC_Y_H				; load upper wall boundary
	cp TempR2, TempR4
	brsh A_BC_Flag_1 

A_Done_YH:
	sts A_SShipPos_YL, TempR1		; Latest position stored into block A
	sts A_SShipPos_YH, TempR2

	lds TempR1, B_SShipPos_XL		; identical operation for X axis
	lds TempR2, B_SShipPos_XH
	lds TempR3, B_SShipVel_XL
	lds TempR4, B_SShipVel_XH
	rcall TwoByteAddition

	lds TempR4, BC_X_L				; load left wall boundary
	cp TempR2, TempR4
	brlo A_BC_Flag_2

A_Done_XL:
	lds TempR4, BC_X_H				; load right wall boundary
	cp TempR2, TempR4
	brsh A_BC_Flag_3 

A_Done_XH:	
	sts A_SShipPos_XL, TempR1		; latest position stored into block A
	sts A_SShipPos_XH, TempR2


A_DrawSShip:
	ldi ZL, low(SShip_y*2)			; Points to vector graphic 
	ldi ZH, high(SShip_y*2)
	ldi XL, low(A_SShipPeri_y)		; Prepare to store in RAM block A
	ldi XH, high(A_SShipPeri_y) 
	lds TempR3, A_SShipPos_YL		; load freshly calculated CoM values from above
	lds TempR4, A_SShipPos_YH
	rcall Storage_Loop				; vector graphic + CoM --> memory block

	ldi ZL, low(SShip_x*2)			; repeat for X axis
	ldi ZH, high(SShip_x*2)
	ldi XL, low(A_SShipPeri_x)
	ldi XH, high(A_SShipPeri_x)
	lds TempR3, A_SShipPos_XL 
	lds TempR4, A_SShipPos_XH
	rcall Storage_Loop

	ret	
;-----------------------------------------
;Boundary conditions, A Scheme
A_BC_Flag_0:
	sbr Boundary_Reg, 0b00000001
	rjmp A_Done_YL

A_BC_Flag_1:
	sbr Boundary_Reg, 0b00000010
	rjmp A_Done_YH

A_BC_Flag_2:
	sbr Boundary_Reg, 0b00000100
	rjmp A_Done_XL

A_BC_Flag_3:
	sbr Boundary_Reg, 0b00001000
	rjmp A_Done_XH
;##################################################################################
B_SShip:							; identical to A Scheme but different memory block
	lds TempR1, A_SShipPos_YL
	lds TempR2, A_SShipPos_YH
	lds TempR3, A_SShipVel_YL	
	lds TempR4, A_SShipVel_YH	
	rcall TwoByteAddition
	mov Boundary_Reg, ZeroReg
	lds TempR4, BC_Y_L
	cp TempR2, TempR4
	brlo B_BC_Flag_0

B_Done_YL:
	lds TempR4, BC_Y_H
	cp TempR2, TempR4
	brsh B_BC_Flag_1 

B_Done_YH:
	sts B_SShipPos_YL, TempR1	
	sts B_SShipPos_YH, TempR2

	lds TempR1, A_SShipPos_XL
	lds TempR2, A_SShipPos_XH
	lds TempR3, A_SShipVel_XL
	lds TempR4, A_SShipVel_XH
	rcall TwoByteAddition

	lds TempR4, BC_X_L
	cp TempR2, TempR4
	brlo B_BC_Flag_2

B_Done_XL:
	lds TempR4, BC_X_H
	cp TempR2, TempR4
	brsh B_BC_Flag_3 

B_Done_XH:	
	sts B_SShipPos_XL, TempR1
	sts B_SShipPos_XH, TempR2

B_DrawSShip:
	ldi ZL, low(SShip_y*2)
	ldi ZH, high(SShip_y*2)
	ldi XL, low(B_SShipPeri_y)
	ldi XH, high(B_SShipPeri_y) 
	lds TempR3, B_SShipPos_YL
	lds TempR4, B_SShipPos_YH
	rcall Storage_Loop

	ldi ZL, low(SShip_x*2)
	ldi ZH, high(SShip_x*2)
	ldi XL, low(B_SShipPeri_x)
	ldi XH, high(B_SShipPeri_x)
	lds TempR3, B_SShipPos_XL
	lds TempR4, B_SShipPos_XH
	rcall Storage_Loop
	
	ret
;-----------------------------------------
;Boundary conditions, B Scheme
B_BC_Flag_0:
	sbr Boundary_Reg, 0b00000001
	rjmp B_Done_YL

B_BC_Flag_1:
	sbr Boundary_Reg, 0b00000010
	rjmp B_Done_YH

B_BC_Flag_2:
	sbr Boundary_Reg, 0b00000100
	rjmp B_Done_XL

B_BC_Flag_3:
	sbr Boundary_Reg, 0b00001000
	rjmp B_Done_XH

;--------------------------------------------------------------
; **** Enemy1 ****
A_Enemy1:							; Compute centre of mass position
	lds TempR1, B_Enemy1Pos_YL		
	lds TempR2, B_Enemy1Pos_YH		
	lds TempR3, B_Enemy1Vel_YL	
	lds TempR4, B_Enemy1Vel_YH	
	rcall TwoByteAddition

	sbrc TempR2, 7					; if enemy1 reach below the 'screen', remove enemy1
	rcall _Enemy1Dead		

	sbrs ObjectStatus, 1			; if enemy is not alive
	ret

	sts A_Enemy1Pos_YL, TempR1		; change A scheme values as display is currently using values from B
	sts A_Enemy1Pos_YH, TempR2		

	lds TempR1, B_Enemy1Pos_XL	
	lds TempR2, B_Enemy1Pos_XH	
	lds TempR3, B_Enemy1Vel_XL	
	lds TempR4, B_Enemy1Vel_XH	
	rcall TwoByteAddition
	sts A_Enemy1Pos_XL, TempR1
	sts A_Enemy1Pos_XH, TempR2



A_DrawEnemy1:						; Compute relative position from a center of mass for the drawing of the object
	ldi ZL, low(Enemy1_y*2)			; Load CoM of object
	ldi ZH, high(Enemy1_y*2)
	ldi XL, low(A_Enemy1Peri_y)		; Vector graphic of the object
	ldi XH, high(A_Enemy1Peri_y) 
	lds TempR3, A_Enemy1Pos_YL
	lds TempR4, A_Enemy1Pos_YH
	rcall Storage_Loop

	ldi ZL, low(Enemy1_x*2)
	ldi ZH, high(Enemy1_x*2)
	ldi XL, low(A_Enemy1Peri_x)
	ldi XH, high(A_Enemy1Peri_x)
	lds TempR3, A_Enemy1Pos_XL 
	lds TempR4, A_Enemy1Pos_XH
	rcall Storage_Loop				; Store back into 

	rcall A_E1_x_region				; Extract information for x-region occupied
	rcall A_E1_y_region				; y-region ; for collisional condition
	ret	

	A_E1_x_region:
		ldi XL, low(A_Enemy1Peri_x)	; Only take X value of points
		ldi XH, high(A_Enemy1Peri_x)
	
		ld TempR1, X+				; Takes the first point from memory block
		sts Enemy1X_Left, TempR1	; it corresponds to the top row, left most point

		ld TempR1, X 				; Takes the 2nd point, top row, right most point
		sts Enemy1X_Right, TempR1 
		ret

	A_E1_y_region:
		ldi YL, low(A_Enemy1Peri_y)
		ldi YH, high(A_Enemy1Peri_y)
	
		ld TempR1, Y				; Y value of top most point
		sts Enemy1Y_Top, TempR1

		ldi TempR1, $1E 			; The 31st point is the last point
		add YL, TempR1				; found out through the python graphics( len(y) )
		adc YH, ZeroReg				; Increments YH if YL has carry bit
		
		ld TempR1, Y 
		sts Enemy1Y_Bottom, TempR1	; Y value of bottom most point
		ret
	
_Enemy1Dead:
	cbr ObjectStatus, 0b00000010
	dec EnemyCount
	rcall E1_Clear_ColRegion
	ret		
	
	
B_Enemy1:							; repeat above for B scheme, and later for successive objects. 
	lds TempR1, A_Enemy1Pos_YL		
	lds TempR2, A_Enemy1Pos_YH	
	lds TempR3, A_Enemy1Vel_YL	
	lds TempR4, A_Enemy1Vel_YH	
	rcall TwoByteAddition

	sbrc TempR2, 7					 
	rcall _Enemy1Dead		

	sbrs ObjectStatus, 1		
	ret
	sts B_Enemy1Pos_YL, TempR1
	sts B_Enemy1Pos_YH, TempR2
	lds TempR1, A_Enemy1Pos_XL	
	lds TempR2, A_Enemy1Pos_XH	
	lds TempR3, A_Enemy1Vel_XL	
	lds TempR4, A_Enemy1Vel_XH	
	rcall TwoByteAddition
	sts B_Enemy1Pos_XL, TempR1
	sts B_Enemy1Pos_XH, TempR2

B_DrawEnemy1:
	ldi ZL, low(Enemy1_y*2)
	ldi ZH, high(Enemy1_y*2)
	ldi XL, low(B_Enemy1Peri_y)
	ldi XH, high(B_Enemy1Peri_y) 
	lds TempR3, B_Enemy1Pos_YL
	lds TempR4, B_Enemy1Pos_YH
	rcall Storage_Loop

	ldi ZL, low(Enemy1_x*2)
	ldi ZH, high(Enemy1_x*2)
	ldi XL, low(B_Enemy1Peri_x)
	ldi XH, high(B_Enemy1Peri_x)
	lds TempR3, B_Enemy1Pos_XL 
	lds TempR4, B_Enemy1Pos_XH
	rcall Storage_Loop

	rcall B_E1_x_region				
	rcall B_E1_y_region
	ret	

	B_E1_x_region:
		ldi XL, low(B_Enemy1Peri_x)	; prepare to replace table of (vector graphic + CoM) 
		ldi XH, high(B_Enemy1Peri_x)
	
		ld TempR1, X+
		sts Enemy1X_Left, TempR1

		ld TempR1, X 
		sts Enemy1X_Right, TempR1 
		ret

	B_E1_y_region:
		ldi YL, low(B_Enemy1Peri_y)	; prepare to replace table of (vector graphic + CoM) 
		ldi YH, high(B_Enemy1Peri_y)
	
		ld TempR1, Y
		sts Enemy1Y_Top, TempR1

		ldi TempR1, $1E ;30 in dec 
		add YL, TempR1
		adc YH, ZeroReg	
		
		ld TempR1, Y 
		sts Enemy1Y_Bottom, TempR1 
		ret
	

;----------------------------------------------------------------------------
; **** Enemy2 ****
A_Enemy2:
	lds TempR1, B_Enemy2Pos_YL	
	lds TempR2, B_Enemy2Pos_YH		
	lds TempR3, B_Enemy2Vel_YL	
	lds TempR4, B_Enemy2Vel_YH	
	rcall TwoByteAddition

	sbrc TempR2, 7					 
	rcall _Enemy2Dead		
	sbrs ObjectStatus, 2		
	ret

	sts A_Enemy2Pos_YL, TempR1
	sts A_Enemy2Pos_YH, TempR2
	lds TempR1, B_Enemy2Pos_XL	
	lds TempR2, B_Enemy2Pos_XH		
	lds TempR3, B_Enemy2Vel_XL	
	lds TempR4, B_Enemy2Vel_XH	
	rcall TwoByteAddition
	sts A_Enemy2Pos_XL, TempR1
	sts A_Enemy2Pos_XH, TempR2



A_DrawEnemy2:
	ldi ZL, low(Enemy2_y*2)		
	ldi ZH, high(Enemy2_y*2)
	ldi XL, low(A_Enemy2Peri_y)	
	ldi XH, high(A_Enemy2Peri_y) 
	lds TempR3, A_Enemy2Pos_YL	
	lds TempR4, A_Enemy2Pos_YH
	rcall Storage_Loop

	ldi ZL, low(Enemy2_x*2)
	ldi ZH, high(Enemy2_x*2)
	ldi XL, low(A_Enemy2Peri_x)
	ldi XH, high(A_Enemy2Peri_x)
	lds TempR3, A_Enemy2Pos_XL 
	lds TempR4, A_Enemy2Pos_XH
	rcall Storage_Loop

	rcall A_E2_x_region				; Extract information for x-region occupied
	rcall A_E2_y_region				; y-region ; for collisional condition
	ret	

	A_E2_x_region:
		ldi XL, low(A_Enemy2Peri_x)	; Only take X value of points
		ldi XH, high(A_Enemy2Peri_x)
	
		ld TempR1, X+				; Takes the first point from memory block
		sts Enemy2X_Left, TempR1	; it corresponds to the top row, left most point

		ld TempR1, X 				; Takes the 2nd point, top row, right most point
		sts Enemy2X_Right, TempR1 
		ret

	A_E2_y_region:
		ldi YL, low(A_Enemy2Peri_y)
		ldi YH, high(A_Enemy2Peri_y)
	
		ld TempR1, Y				; Y value of top most point
		sts Enemy2Y_Top, TempR1

		ldi TempR1, $1E 			; The 31st point is the last point
		add YL, TempR1				; found out through the python graphics( len(y) )
		adc YH, ZeroReg				; Increments YH if YL has carry bit
		
		ld TempR1, Y 
		sts Enemy2Y_Bottom, TempR1	; Y value of bottom most point
		ret

	
_Enemy2Dead:
	cbr ObjectStatus, 0b00000100
	dec EnemyCount
	rcall E2_Clear_ColRegion
	ret		
	
	
B_Enemy2:	
	lds TempR1, A_Enemy2Pos_YL		
	lds TempR2, A_Enemy2Pos_YH	
	lds TempR3, A_Enemy2Vel_YL	
	lds TempR4, A_Enemy2Vel_YH		
	rcall TwoByteAddition

	sbrc TempR2, 7					 
		rcall _Enemy2Dead		
	sbrs ObjectStatus, 2		
		ret
	sts B_Enemy2Pos_YL, TempR1
	sts B_Enemy2Pos_YH, TempR2
	lds TempR1, A_Enemy2Pos_XL	
	lds TempR2, A_Enemy2Pos_XH		
	lds TempR3, A_Enemy2Vel_XL		
	lds TempR4, A_Enemy2Vel_XH		
	rcall TwoByteAddition
	sts B_Enemy2Pos_XL, TempR1
	sts B_Enemy2Pos_XH, TempR2

B_DrawEnemy2:
	ldi ZL, low(Enemy2_y*2)
	ldi ZH, high(Enemy2_y*2)
	ldi XL, low(B_Enemy2Peri_y)
	ldi XH, high(B_Enemy2Peri_y) 
	lds TempR3, B_Enemy2Pos_YL
	lds TempR4, B_Enemy2Pos_YH
	rcall Storage_Loop

	ldi ZL, low(Enemy2_x*2)
	ldi ZH, high(Enemy2_x*2)
	ldi XL, low(B_Enemy2Peri_x)
	ldi XH, high(B_Enemy2Peri_x)
	lds TempR3, B_Enemy2Pos_XL 
	lds TempR4, B_Enemy2Pos_XH
	rcall Storage_Loop

	rcall B_E2_x_region
	rcall B_E2_y_region

	ret	

	B_E2_x_region:
		ldi XL, low(B_Enemy2Peri_x)	; prepare to replace table of (vector graphic + CoM) 
		ldi XH, high(B_Enemy2Peri_x)
	
		ld TempR1, X+
		sts Enemy2X_Left, TempR1

		ld TempR1, X 
		sts Enemy2X_Right, TempR1 
		ret

	B_E2_y_region:
		ldi YL, low(B_Enemy2Peri_y)	; prepare to replace table of (vector graphic + CoM) 
		ldi YH, high(B_Enemy2Peri_y)
	
		ld TempR1, Y
		sts Enemy2Y_Top, TempR1

		ldi TempR1, $1E ;30 in dec 
		add YL, TempR1
		adc YH, ZeroReg	
		
		ld TempR1, Y 
		sts Enemy2Y_Bottom, TempR1 
		ret	
;----------------------------------------------------------------------------
; **** Enemy3 ****
A_Enemy3:
	lds TempR1, B_Enemy3Pos_YL		
	lds TempR2, B_Enemy3Pos_YH		
	lds TempR3, B_Enemy3Vel_YL	
	lds TempR4, B_Enemy3Vel_YH		
	rcall TwoByteAddition

	sbrc TempR2, 7					 
	rcall _Enemy3Dead		
	sbrs ObjectStatus, 3		
	ret

	sts A_Enemy3Pos_YL, TempR1
	sts A_Enemy3Pos_YH, TempR2
	lds TempR1, B_Enemy3Pos_XL		
	lds TempR2, B_Enemy3Pos_XH	
	lds TempR3, B_Enemy3Vel_XL	
	lds TempR4, B_Enemy3Vel_XH	
	rcall TwoByteAddition
	sts A_Enemy3Pos_XL, TempR1
	sts A_Enemy3Pos_XH, TempR2



A_DrawEnemy3:
	ldi ZL, low(Enemy3_y*2)		
	ldi ZH, high(Enemy3_y*2)
	ldi XL, low(A_Enemy3Peri_y)	 
	ldi XH, high(A_Enemy3Peri_y) 
	lds TempR3, A_Enemy3Pos_YL	
	lds TempR4, A_Enemy3Pos_YH
	rcall Storage_Loop

	ldi ZL, low(Enemy3_x*2)
	ldi ZH, high(Enemy3_x*2)
	ldi XL, low(A_Enemy3Peri_x)
	ldi XH, high(A_Enemy3Peri_x)
	lds TempR3, A_Enemy3Pos_XL 
	lds TempR4, A_Enemy3Pos_XH
	rcall Storage_Loop

	rcall A_E3_x_region				; Extract information for x-region occupied
	rcall A_E3_y_region				; y-region ; for collisional condition
	ret	

	A_E3_x_region:
		ldi XL, low(A_Enemy3Peri_x)	; Only take X value of points
		ldi XH, high(A_Enemy3Peri_x)
	
		ld TempR1, X+				; Takes the first point from memory block
		sts Enemy3X_Left, TempR1	; it corresponds to the top row, left most point

		ld TempR1, X 				; Takes the 2nd point, top row, right most point
		sts Enemy3X_Right, TempR1 
		ret

	A_E3_y_region:
		ldi YL, low(A_Enemy3Peri_y)
		ldi YH, high(A_Enemy3Peri_y)
	
		ld TempR1, Y				; Y value of top most point
		sts Enemy3Y_Top, TempR1

		ldi TempR1, $1E 			; The 31st point is the last point
		add YL, TempR1				; found out through the python graphics( len(y) )
		adc YH, ZeroReg				; Increments YH if YL has carry bit
		
		ld TempR1, Y 
		sts Enemy3Y_Bottom, TempR1	; Y value of bottom most point
		ret

	
_Enemy3Dead:
	cbr ObjectStatus, 0b00001000
	dec EnemyCount
	rcall E3_Clear_ColRegion
	ret		
	
	
B_Enemy3:	
	lds TempR1, A_Enemy3Pos_YL		
	lds TempR2, A_Enemy3Pos_YH	
	lds TempR3, A_Enemy3Vel_YL	
	lds TempR4, A_Enemy3Vel_YH
	rcall TwoByteAddition

	sbrc TempR2, 7					 
	rcall _Enemy3Dead		
	sbrs ObjectStatus, 2		
	ret
	sts B_Enemy3Pos_YL, TempR1
	sts B_Enemy3Pos_YH, TempR2
	lds TempR1, A_Enemy3Pos_XL	
	lds TempR2, A_Enemy3Pos_XH		
	lds TempR3, A_Enemy3Vel_XL	
	lds TempR4, A_Enemy3Vel_XH
	rcall TwoByteAddition
	sts B_Enemy3Pos_XL, TempR1
	sts B_Enemy3Pos_XH, TempR2

B_DrawEnemy3:
	ldi ZL, low(Enemy3_y*2)
	ldi ZH, high(Enemy3_y*2)
	ldi XL, low(B_Enemy3Peri_y)
	ldi XH, high(B_Enemy3Peri_y) 
	lds TempR3, B_Enemy3Pos_YL
	lds TempR4, B_Enemy3Pos_YH
	rcall Storage_Loop

	ldi ZL, low(Enemy3_x*2)
	ldi ZH, high(Enemy3_x*2)
	ldi XL, low(B_Enemy3Peri_x)
	ldi XH, high(B_Enemy3Peri_x)
	lds TempR3, B_Enemy3Pos_XL 
	lds TempR4, B_Enemy3Pos_XH
	rcall Storage_Loop

	rcall B_E3_x_region
	rcall B_E3_y_region

	ret	

	B_E3_x_region:
		ldi XL, low(B_Enemy3Peri_x)	; prepare to replace table of (vector graphic + CoM) 
		ldi XH, high(B_Enemy3Peri_x)
	
		ld TempR1, X+
		sts Enemy3X_Left, TempR1

		ld TempR1, X 
		sts Enemy3X_Right, TempR1 
		ret

	B_E3_y_region:
		ldi YL, low(B_Enemy3Peri_y)	; prepare to replace table of (vector graphic + CoM) 
		ldi YH, high(B_Enemy3Peri_y)
	
		ld TempR1, Y
		sts Enemy3Y_Top, TempR1

		ldi TempR1, $1E ;30 in dec 
		add YL, TempR1
		adc YH, ZeroReg	
		
		ld TempR1, Y 
		sts Enemy3Y_Bottom, TempR1 
		ret

;----------------------------------------------------------------------------
; **** Enemy4 ****
A_Enemy4:
	lds TempR1, B_Enemy4Pos_YL	
	lds TempR2, B_Enemy4Pos_YH		
	lds TempR3, B_Enemy4Vel_YL	
	lds TempR4, B_Enemy4Vel_YH	
	rcall TwoByteAddition

	sbrc TempR2, 7					 
	rcall _Enemy4Dead		
	sbrs ObjectStatus, 4	
	ret

	sts A_Enemy4Pos_YL, TempR1
	sts A_Enemy4Pos_YH, TempR2
	lds TempR1, B_Enemy4Pos_XL
	lds TempR2, B_Enemy4Pos_XH
	lds TempR3, B_Enemy4Vel_XL	
	lds TempR4, B_Enemy4Vel_XH	
	rcall TwoByteAddition
	sts A_Enemy4Pos_XL, TempR1
	sts A_Enemy4Pos_XH, TempR2



A_DrawEnemy4:
	ldi ZL, low(Enemy4_y*2)		
	ldi ZH, high(Enemy4_y*2)
	ldi XL, low(A_Enemy4Peri_y)
	ldi XH, high(A_Enemy4Peri_y) 
	lds TempR3, A_Enemy4Pos_YL	
	lds TempR4, A_Enemy4Pos_YH
	rcall Storage_Loop

	ldi ZL, low(Enemy4_x*2)
	ldi ZH, high(Enemy4_x*2)
	ldi XL, low(A_Enemy4Peri_x)
	ldi XH, high(A_Enemy4Peri_x)
	lds TempR3, A_Enemy4Pos_XL 
	lds TempR4, A_Enemy4Pos_XH
	rcall Storage_Loop

	rcall A_E4_x_region				; Extract information for x-region occupied
	rcall A_E4_y_region				; y-region ; for collisional condition
	ret	

	A_E4_x_region:
		ldi XL, low(A_Enemy4Peri_x)	; Only take X value of points
		ldi XH, high(A_Enemy4Peri_x)
	
		ld TempR1, X+				; Takes the first point from memory block
		sts Enemy4X_Left, TempR1	; it corresponds to the top row, left most point

		ld TempR1, X 				; Takes the 2nd point, top row, right most point
		sts Enemy4X_Right, TempR1 
		ret

	A_E4_y_region:
		ldi YL, low(A_Enemy4Peri_y)
		ldi YH, high(A_Enemy4Peri_y)
	
		ld TempR1, Y				; Y value of top most point
		sts Enemy4Y_Top, TempR1

		ldi TempR1, $1E 			; The 31st point is the last point
		add YL, TempR1				; found out through the python graphics( len(y) )
		adc YH, ZeroReg				; Increments YH if YL has carry bit
		
		ld TempR1, Y 
		sts Enemy4Y_Bottom, TempR1	; Y value of bottom most point
		ret

	
_Enemy4Dead:
	cbr ObjectStatus, 0b00010000
	dec EnemyCount
	rcall E4_Clear_ColRegion
	ret		
	
	
B_Enemy4:	
	lds TempR1, A_Enemy4Pos_YL	
	lds TempR2, A_Enemy4Pos_YH	
	lds TempR3, A_Enemy4Vel_YL		
	lds TempR4, A_Enemy4Vel_YH	
	rcall TwoByteAddition

	sbrc TempR2, 7					 
	rcall _Enemy4Dead		
	sbrs ObjectStatus, 2		
	ret
	sts B_Enemy4Pos_YL, TempR1
	sts B_Enemy4Pos_YH, TempR2
	lds TempR1, A_Enemy4Pos_XL		
	lds TempR2, A_Enemy4Pos_XH		
	lds TempR3, A_Enemy4Vel_XL		
	lds TempR4, A_Enemy4Vel_XH		
	rcall TwoByteAddition
	sts B_Enemy4Pos_XL, TempR1
	sts B_Enemy4Pos_XH, TempR2

B_DrawEnemy4:
	ldi ZL, low(Enemy4_y*2)
	ldi ZH, high(Enemy4_y*2)
	ldi XL, low(B_Enemy4Peri_y)
	ldi XH, high(B_Enemy4Peri_y) 
	lds TempR3, B_Enemy4Pos_YL
	lds TempR4, B_Enemy4Pos_YH
	rcall Storage_Loop

	ldi ZL, low(Enemy4_x*2)
	ldi ZH, high(Enemy4_x*2)
	ldi XL, low(B_Enemy4Peri_x)
	ldi XH, high(B_Enemy4Peri_x)
	lds TempR3, B_Enemy4Pos_XL 
	lds TempR4, B_Enemy4Pos_XH
	rcall Storage_Loop

	rcall B_E4_x_region
	rcall B_E4_y_region

	ret	

	B_E4_x_region:
		ldi XL, low(B_Enemy4Peri_x)	; prepare to replace table of (vector graphic + CoM) 
		ldi XH, high(B_Enemy4Peri_x)
	
		ld TempR1, X+
		sts Enemy4X_Left, TempR1

		ld TempR1, X 
		sts Enemy4X_Right, TempR1 
		ret

	B_E4_y_region:
		ldi YL, low(B_Enemy4Peri_y)	; prepare to replace table of (vector graphic + CoM) 
		ldi YH, high(B_Enemy4Peri_y)
	
		ld TempR1, Y
		sts Enemy4Y_Top, TempR1

		ldi TempR1, $1E ;30 in dec 
		add YL, TempR1
		adc YH, ZeroReg	
		
		ld TempR1, Y 
		sts Enemy4Y_Bottom, TempR1 
		ret
;--------------------------------------------------------------------------
Storage_Loop:
		lpm TempR2, Z+				; Load vector graphics values from program memory table
		cpi TempR2, $7F				; Marker of end of table data
		breq _store_exit			; if so, store as $FF (another marker) then exit subroutine
		add TempR2, TempR4			; Calculate each Vector + CoM position
		bst TempR2, 7				; copy HighByte signed bit to Tflag
		brts _OffScreen				; if new position is Under screen ( 00...00 become 11..11) 
		bst TempR2, 6				; ( 001..1 become 010...0) 
		brts _OffScreen				; if new position is Above screen

	_Store: 
		cpi TempR2, $00			; If point is offscreen
		breq _OffScreenStore
		mov TempR1, TempR3		; 8 bits extracted from 16 bit data
		rol TempR1				; low byte
		rol TempR2				; high byte
		rol TempR1				; low byte
		rol TempR2				; high byte
		st X+, TempR2
		rjmp Storage_Loop

		_OffScreenStore: 
		st X+, TempR2			; This point is to be skipped in the display routine
		rjmp Storage_Loop

	_OffScreen:
		ldi TempR2, $00
		rjmp _Store

	_store_exit:
		ldi TempR2, $FF
		st X, TempR2
		ret

;--------------------------------------------------------------------------
A_Bullet:
		lds TempR1, B_BulletPos_YL
		lds TempR2, B_BulletPos_YH	
		lds TempR3, BulletVel_YL
		ldi TempR4, $00					; Bullet_Vel_YH which is always 0
		rcall TwoByteAddition
		sbrc TempR2, 6              	; Bullet destroyed if reach top of screen           	 
   		rcall _BulletDead 
		 
	A_StoreBullet:
		sts A_BulletPos_YL, TempR1		; 16bit --> 8 bit done in ISR
		sts A_BulletPos_YH, TempR2
		ret

	_BulletDead:
		cbr ObjectStatus, 0b10000000	
		ret   	 
    
B_Bullet:
		lds TempR1, A_BulletPos_YL
		lds TempR2, A_BulletPos_YH	
		lds TempR3, BulletVel_YL
		ldi TempR4, $00					; Bullet_Vel_YH which is always 0
		rcall TwoByteAddition
		sbrc TempR2, 6              	; bullet kill if reach top of screen           	 
   		rcall _BulletDead 
		 
	B_StoreBullet:
		sts B_BulletPos_YL, TempR1
		sts B_BulletPos_YH, TempR2
		ret
	
;----------------------------------------------------------------------------
TwoByteAddition:
		add TempR1,TempR3	;add low byte first
		adc TempR2,TempR4	;add up both high byte with carry
		ret
;------------------------------------------------------------------------------

E1_Clear_ColRegion:						; return collision region values back to 0 
	sts Enemy1X_Left, ZeroReg
	sts Enemy1X_Right, ZeroReg
	sts Enemy1Y_Top, ZeroReg
	sts Enemy1Y_Bottom, ZeroReg
	ret

E2_Clear_ColRegion:
	sts Enemy2X_Left, ZeroReg
	sts Enemy2X_Right, ZeroReg
	sts Enemy2Y_Top, ZeroReg
	sts Enemy2Y_Bottom, ZeroReg
	ret

E3_Clear_ColRegion:
	sts Enemy3X_Left, ZeroReg
	sts Enemy3X_Right, ZeroReg
	sts Enemy3Y_Top, ZeroReg
	sts Enemy3Y_Bottom, ZeroReg
	ret

E4_Clear_ColRegion:
	sts Enemy4X_Left, ZeroReg
	sts Enemy4X_Right, ZeroReg
	sts Enemy4Y_Top, ZeroReg
	sts Enemy4Y_Bottom, ZeroReg
	ret
