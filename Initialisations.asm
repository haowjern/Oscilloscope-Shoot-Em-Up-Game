GameSystemInit:
		ldi FlagReg, $00

		ldi TempR1, $FF
		mov PrevButtonState, TempR1

		ldi TempR1, $00
		mov Col_Reg, TempR1

		ldi TempR1, $00
		mov BlinkCounterH, TempR1
		mov BlinkCounterL, TempR1

		ldi TempR1, $03					; Number of lives left
		mov Lives_left, TempR1	
			
		rcall InitSShip					; Initialise ship's, 4 enemies' and lives' positions and graphics
		rcall InitEnemy1				
		rcall InitEnemy2
		rcall InitEnemy3
		rcall InitEnemy4
		rcall InitHearts

		rcall BC_RegionInit				; Initalise boundary walls of the screen

		ret
		
;-------------------------------------------------------------------------------	
; y is position, dy is velocity. Later during computation, addition will take place in y 'lowbyte', and carries over to y 'highbyte', same for dy 'low' and 'high' bytes registers.
InitSShip:							
		ldi TempR1, 0b11000000		; y low byte
		sts B_SShipPos_YL, TempR1
		sts A_SShipPos_YL, TempR1
		ldi TempR1, 0b00011111		; y high byte
		sts B_SShipPos_YH, TempR1
		sts A_SShipPos_YH, TempR1
		ldi TempR1, 0b00000000		; dy low byte
		sts A_SShipVel_YL, TempR1
		sts B_SShipVel_YL, TempR1
		ldi TempR1, 0b00000000		; dy high byte
		sts B_SShipVel_YH, TempR1
		sts A_SShipVel_YH, TempR1

		ldi TempR1, 0b11000000		; x low byte
		sts B_SShipPos_XL, TempR1
		sts A_SShipPos_XL, TempR1
		ldi TempR1, 0b00011111		; x high byte
		sts B_SShipPos_XH, TempR1
		sts A_SShipPos_XH, TempR1
		ldi TempR1, 0b00000000		; dx low byte
		sts B_SShipVel_XL, TempR1
		sts A_SShipVel_XL, TempR1
		ldi TempR1, 0b00000000		; dx high byte
		sts B_SShipVel_XH, TempR1
		sts A_SShipVel_XH, TempR1
		ret
;-------------------------------------------------------------------------------


InitEnemy1:
		ldi TempR1, 0b00000000		; y low byte
		sts B_Enemy1Pos_YL, TempR1
		sts A_Enemy1Pos_YL, TempR1
		ldi TempR1, 0b01100000		; y high byte
		sts B_Enemy1Pos_YH, TempR1
		sts A_Enemy1Pos_YH, TempR1
		ldi TempR1, 0b11101111		; dy low byte
		sts A_Enemy1Vel_YL, TempR1
		sts B_Enemy1Vel_YL, TempR1
		ldi TempR1, 0b11111111		; dy high byte
		sts B_Enemy1Vel_YH, TempR1
		sts A_Enemy1Vel_YH, TempR1

		ldi TempR1, 0b10000000		; x low byte
		sts B_Enemy1Pos_XL, TempR1
		sts A_Enemy1Pos_XL, TempR1
		ldi TempR1, 0b00001111		; x high byte
		sts B_Enemy1Pos_XH, TempR1
		sts A_Enemy1Pos_XH, TempR1
		ldi TempR1, 0b00000000		; dx low byte
		sts B_Enemy1Vel_XL, TempR1
		sts A_Enemy1Vel_XL, TempR1
		ldi TempR1, 0b00000000		; dx high byte
		sts B_Enemy1Vel_XH, TempR1
		sts A_Enemy1Vel_XH, TempR1
		ret	
;-------------------------------------------------------------------------------

InitEnemy2:
		ldi TempR1, 0b00000000		; y low byte
		sts B_Enemy2Pos_YL, TempR1
		sts A_Enemy2Pos_YL, TempR1
		ldi TempR1, 0b01100111		; y high byte
		sts B_Enemy2Pos_YH, TempR1
		sts A_Enemy2Pos_YH, TempR1
		ldi TempR1, 0b11101011		; dy low byte
		sts A_Enemy2Vel_YL, TempR1
		sts B_Enemy2Vel_YL, TempR1
		ldi TempR1, 0b11111111		; dy high byte
		sts B_Enemy2Vel_YH, TempR1
		sts A_Enemy2Vel_YH, TempR1

		ldi TempR1, 0b10000000		; x low byte
		sts B_Enemy2Pos_XL, TempR1
		sts A_Enemy2Pos_XL, TempR1
		ldi TempR1, 0b00011100		; x high byte
		sts B_Enemy2Pos_XH, TempR1
		sts A_Enemy2Pos_XH, TempR1
		ldi TempR1, 0b00000000		; dx low byte
		sts B_Enemy2Vel_XL, TempR1
		sts A_Enemy2Vel_XL, TempR1
		ldi TempR1, 0b00000000		; dx high byte
		sts B_Enemy2Vel_XH, TempR1
		sts A_Enemy2Vel_XH, TempR1

		ret
;-------------------------------------------------------------------------------

InitEnemy3:
		ldi TempR1, 0b00000000		; y low byte
		sts B_Enemy3Pos_YL, TempR1
		sts A_Enemy3Pos_YL, TempR1
		ldi TempR1, 0b01100111		; y high byte
		sts B_Enemy3Pos_YH, TempR1
		sts A_Enemy3Pos_YH, TempR1
		ldi TempR1, 0b11110111		; dy low byte
		sts A_Enemy3Vel_YL, TempR1
		sts B_Enemy3Vel_YL, TempR1
		ldi TempR1, 0b11111111		; dy high byte
		sts B_Enemy3Vel_YH, TempR1
		sts A_Enemy3Vel_YH, TempR1

		ldi TempR1, 0b10000000		; x low byte
		sts B_Enemy3Pos_XL, TempR1
		sts A_Enemy3Pos_XL, TempR1
		ldi TempR1, 0b00101100		; x high byte
		sts B_Enemy3Pos_XH, TempR1
		sts A_Enemy3Pos_XH, TempR1
		ldi TempR1, 0b00000000		; dx low byte
		sts B_Enemy3Vel_XL, TempR1
		sts A_Enemy3Vel_XL, TempR1
		ldi TempR1, 0b00000000		; dx high byte
		sts B_Enemy3Vel_XH, TempR1
		sts A_Enemy3Vel_XH, TempR1

		ret
;-------------------------------------------------------------------------------

InitEnemy4:
		ldi TempR1, 0b00000000		; y low byte
		sts B_Enemy4Pos_YL, TempR1
		sts A_Enemy4Pos_YL, TempR1
		ldi TempR1, 0b01100111		; y high byte
		sts B_Enemy4Pos_YH, TempR1
		sts A_Enemy4Pos_YH, TempR1
		ldi TempR1, 0b11101111		; dy low byte
		sts A_Enemy4Vel_YL, TempR1
		sts B_Enemy4Vel_YL, TempR1
		ldi TempR1, 0b11111111		; dy high byte
		sts B_Enemy4Vel_YH, TempR1
		sts A_Enemy4Vel_YH, TempR1

		ldi TempR1, 0b10000000		; x low byte
		sts B_Enemy4Pos_XL, TempR1
		sts A_Enemy4Pos_XL, TempR1
		ldi TempR1, 0b00111001		; x high byte
		sts B_Enemy4Pos_XH, TempR1
		sts A_Enemy4Pos_XH, TempR1
		ldi TempR1, 0b00000000		; dx low byte
		sts B_Enemy4Vel_XL, TempR1
		sts A_Enemy4Vel_XL, TempR1
		ldi TempR1, 0b00000000		; dx high byte
		sts B_Enemy4Vel_XH, TempR1
		sts A_Enemy4Vel_XH, TempR1

		ret

;--------------------------------------------------------------	
initBullet:
		lds TempR1, A_SShipPos_YL	; bullet is initially shot from the ship's centre of mass position
        sts A_BulletPos_YL, TempR1	
		lds TempR1, B_SShipPos_YL
		sts B_BulletPos_YL, TempR1

		lds TempR1, A_SShipPos_YH
		sts A_BulletPos_YH, TempR1
		lds TempR1, B_SShipPos_YH
		sts B_BulletPos_YH, TempR1

    	ldi TempR1, 0b10111111		; Bullet Velocity
        sts BulletVel_YL, TempR1

    	lds TempR1, 0b00000000
        sts BulletVel_YH, TempR1

    	lds TempR1, A_SShipPos_XL	; Doesnt matter data from A or B scheme, negligible error.
		lds TempR2, A_SShipPos_XH
		rol TempR1
		rol TempR2
		rol TempR1
		rol TempR2 
		sts BulletPos_X, TempR2
		 		
		sbr ObjectStatus, 0b10000000	; Set status of bullet as alive
   		ret
;---------------------------------------------------------------
EnemySystemInit:	
		ldi TempR1, 1
		mov EnemyCount, TempR1			; Current no. of enemies alive
		ldi TempR1, 4
		mov EnemyCountThreshold, TempR1	; Max possible enemies
		ldi TempR1, 0b00000010
		mov ObjectStatus, TempR1		; Enemy status, each ith bit represents the ith enemy alive / dead
		ret
;--------------------------------------------------------------------

InitHearts:

		ldi TempR4, 0b00110110       	; y center of mass (lower quarter of screen)
		ldi TempR3, 0b11000000 
		ldi ZL, low(TableHeart1_Y*2)	; points to table
		ldi ZH, high(TableHeart1_Y*2)
		ldi XL, low(Heart1_Y)			; points to memory block
		ldi XH, high(Heart1_Y)	 
		rcall Storage_Loop				; vector graphic + CoM --> memory block

		ldi TempR4, 0b00110010        	; X center of mass (lower quarter of screen)
		ldi TempR3, 0b00000000 
		ldi ZL, low(TableHeart1_X*2)	; points to table
		ldi ZH, high(TableHeart1_X*2)
		ldi XL, low(Heart1_X)			; points to memory block
		ldi XH, high(Heart1_X)
		rcall Storage_Loop				

		ldi TempR4, 0b00110110       	; y center of mass (lower quarter of screen)
		ldi TempR3, 0b11000000 
		ldi ZL, low(TableHeart2_Y*2)	; points to table
		ldi ZH, high(TableHeart2_Y*2)
		ldi XL, low(Heart2_Y)			; points to memory block
		ldi XH, high(Heart2_Y)	 
		rcall Storage_Loop

		ldi TempR4, 0b00110010        	; X center of mass (lower quarter of screen)
		ldi TempR3, 0b00000000 
		ldi ZL, low(TableHeart2_X*2)	; points to table
		ldi ZH, high(TableHeart2_X*2)
		ldi XL, low(Heart2_X)			; points to memory block
		ldi XH, high(Heart2_X)
		rcall Storage_Loop
		ret
;--------------------------------------------------------------------
BC_RegionInit:
		mov Boundary_Reg, ZeroReg	
	
		ldi TempR1, 0b00001000			; coordinates of the walls, experimentally tested on oscilloscope to fit our game 
		sts BC_Y_L, TempR1	
		ldi TempR1, 0b00111000
		sts BC_Y_H, TempR1

		ldi TempR1, 0b00001010
		sts BC_X_L, TempR1
		ldi TempR1, 0b00110111
		sts BC_X_H, TempR1
		ret