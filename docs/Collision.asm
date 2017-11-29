; Collision routine with enemies & bullets, enemies & ship 
; Each enemy is treated with 4 points at the corner (like a rectangle), and these 4 points are used to form a collision region. 
; Bullet is treated as a point, and if this point falls into the collision region of the enemy, collision takes place.
; For a ship, the ship is treated with three points, and those points follow the same routine as the bullet. 


Collision:
		sbrc ObjectStatus, 7			; Check collision with bullet if bullet is alive
		rcall Bullet_Collide			; 
		rcall SShip_Collide				; Check for ship collision with enemy 
		ret
	
;---------------------------------------------------------------------------------------------
	Bullet_Collide:						; Check bullet collision with all enemies
		
		sbrc ObjectStatus, 1			; If Enemy1 is alive
		rcall B_E1_Col
		rcall B_E1_Col_Occur_Check
		mov Col_Reg, ZeroReg
		
		sbrc ObjectStatus, 2			; if Enemy2 is alive
		rcall B_E2_Col
		rcall B_E2_Col_Occur_Check
		mov Col_Reg, ZeroReg	
		
		sbrc ObjectStatus, 3
		rcall B_E3_Col
		rcall B_E3_Col_Occur_Check
		mov Col_Reg, ZeroReg	
		
		sbrc ObjectStatus, 4
		rcall B_E4_Col
		rcall B_E4_Col_Occur_Check
		mov Col_Reg, ZeroReg		
		
		ret

		B_E1_Col:
			lds TempR1, Enemy1Y_Bottom	; Lower bound
			lds TempR2, Enemy1Y_Top		; Upper bound
			lds TempR3, BulletPos_Y		; Bullet y point
			rcall Col_Region_Check		; If it's in the region, inc Col_Reg by one
			
			lds TempR1, Enemy1X_Left	; Lower bound
			lds TempR2, Enemy1X_Right	; Upper bound
			lds TempR3, BulletPos_X		; Bullet x point
			rcall Col_Region_Check		; If it's in the region, inc Col_Reg by one
			ret
				
		B_E1_Col_Occur_Check:
			cpse TwoReg, Col_Reg		; Col occurs if 2 region checks are positive
			ret							; This line is skipped if both region returns positive
			rcall _Enemy1Dead			; If collided, enemy dies
			rcall _BulletDead			; Bullet disappears
			mov Col_Reg, ZeroReg		; Clear Col Reg
			ret

		B_E2_Col:
			lds TempR1, Enemy2Y_Bottom
			lds TempR2, Enemy2Y_Top
			lds TempR3, BulletPos_Y
			rcall Col_Region_Check		; If its in the region, inc Col_Reg by one
			
			lds TempR1, Enemy2X_Left
			lds TempR2, Enemy2X_Right
			lds TempR3, BulletPos_X
			rcall Col_Region_Check
			
			ret
		
		B_E2_Col_Occur_Check:
			cpse TwoReg, Col_Reg		; Col occurs if 2 region checks are positive
			ret							; This line is skipped if both region returns positive
			rcall _Enemy2Dead
			rcall _BulletDead
			mov Col_Reg, ZeroReg
			ret

		B_E3_Col:
			lds TempR1, Enemy3Y_Bottom
			lds TempR2, Enemy3Y_Top
			lds TempR3, BulletPos_Y
			rcall Col_Region_Check		; If its in the region, inc Col_Reg by one
			
			lds TempR1, Enemy3X_Left
			lds TempR2, Enemy3X_Right
			lds TempR3, BulletPos_X
			rcall Col_Region_Check
			
			ret
		
		B_E3_Col_Occur_Check:
			cpse TwoReg, Col_Reg		; Col occurs if 2 region checks are positive
			ret							; This line is skipped if both region returns positive
			rcall _Enemy3Dead
			rcall _BulletDead
			mov Col_Reg, ZeroReg
			ret

		B_E4_Col:
			lds TempR1, Enemy4Y_Bottom
			lds TempR2, Enemy4Y_Top
			lds TempR3, BulletPos_Y
			rcall Col_Region_Check		; If its in the region, inc Col_Reg by one
			
			lds TempR1, Enemy4X_Left
			lds TempR2, Enemy4X_Right
			lds TempR3, BulletPos_X
			rcall Col_Region_Check
			
			ret
		
		B_E4_Col_Occur_Check:
			cpse TwoReg, Col_Reg		; Col occurs if 2 region checks are positive
			ret							; This line is skipped if both region returns positive
			rcall _Enemy4Dead
			rcall _BulletDead
			mov Col_Reg, ZeroReg
			ret
		
		
;-----------------------------------------------------------------------------------------------
	SShip_Collide:						; Check collision with each enemy 

		sbrc ObjectStatus, 1			; Enemy1
		rcall SShip_E1_Col

		sbrc ObjectStatus, 2			; Enemy2
		rcall SShip_E2_Col

		sbrc ObjectStatus, 3			; Enemy3 
		rcall SShip_E3_Col

		sbrc ObjectStatus, 4			; Enemy4
		rcall SShip_E4_Col
	
    	ret
		
;------------------------------------------
		SShip_E1_Col:					; Repeat routine for bullet checking (which was for only one point), for three points - top, left and right. 
			rcall SShip_Top_E1_Col		; Check for top point, if in collision region, will increment col_reg twice. 
			rcall SShip_E1_Col_Check	; Check if col_reg = $2, if so kill the enemy, and dec lives. 
			mov Col_Reg, ZeroReg		; Clear col_reg

			rcall SShip_Left_E1_Col		; Check for left point
			rcall SShip_E1_Col_Check	; The same outcome whether any of the 3 points collided
			mov Col_Reg, ZeroReg
			
			rcall SShip_Right_E1_Col	; Check for right point 
			rcall SShip_E1_Col_Check	; The same outcome whether any of the 3 points collided
			mov Col_Reg, ZeroReg
			ret

			SShip_E1_Col_Check:			; Check with Enemy1 and so on for subsequent similar named subroutines 
				cpse TwoReg, Col_Reg	; Collision only takes place when Col_Reg = $2
				ret
				rcall _Enemy1Dead
				rcall Ship_Collided		; Decrement the lives remaining
				ret
		
			SShip_Top_E1_Col:				; Check top point of the ship for collision
				lds TempR1, Enemy1Y_Bottom
				lds TempR2, Enemy1Y_Top
				lds TempR3, SShip_TopY
				rcall Col_Region_Check
				
				lds TempR1, Enemy1X_Left
				lds TempR2, Enemy1X_Right
				lds TempR3, SShip_TopX
				rcall Col_Region_Check
				ret

			SShip_Left_E1_Col:				; Check	left point of the ship for collision
				lds TempR1, Enemy1Y_Bottom
				lds TempR2, Enemy1Y_Top
				lds TempR3, SShip_LeftY
				rcall Col_Region_Check
				
				lds TempR1, Enemy1X_Left
				lds TempR2, Enemy1X_Right
				lds TempR3, SShip_LeftX
				rcall Col_Region_Check
				ret

			SShip_Right_E1_Col:				; Check right point of the ship for collision
				lds TempR1, Enemy1Y_Bottom
				lds TempR2, Enemy1Y_Top
				lds TempR3, SShip_RightY
				rcall Col_Region_Check
				
				lds TempR1, Enemy1X_Left
				lds TempR2, Enemy1X_Right
				lds TempR3, SShip_RightX
				rcall Col_Region_Check
				ret
		;-----------------------------------
;------------------------------------------ Above is repeated for every enemy
		SShip_E2_Col:						
			rcall SShip_Top_E2_Col			
			rcall SShip_E2_Col_Check	
			mov Col_Reg, ZeroReg

			rcall SShip_Left_E2_Col
			rcall SShip_E2_Col_Check		; The same outcome whether its any of the 3 points collided
			mov Col_Reg, ZeroReg
			
			rcall SShip_Right_E2_Col
			rcall SShip_E2_Col_Check		; The same outcome whether its any of the 3 points collided
			mov Col_Reg, ZeroReg
			ret

			SShip_E2_Col_Check:
				cpse TwoReg, Col_Reg
				ret
				rcall _Enemy2Dead
				rcall Ship_Collided			; decrement the lives remaining
				ret
		
			SShip_Top_E2_Col:
				lds TempR1, Enemy2Y_Bottom
				lds TempR2, Enemy2Y_Top
				lds TempR3, SShip_TopY
				rcall Col_Region_Check
				
				lds TempR1, Enemy2X_Left
				lds TempR2, Enemy2X_Right
				lds TempR3, SShip_TopX
				rcall Col_Region_Check
				ret

			SShip_Left_E2_Col:
				lds TempR1, Enemy2Y_Bottom
				lds TempR2, Enemy2Y_Top
				lds TempR3, SShip_LeftY
				rcall Col_Region_Check
				
				lds TempR1, Enemy2X_Left
				lds TempR2, Enemy2X_Right
				lds TempR3, SShip_LeftX
				rcall Col_Region_Check
				ret

			SShip_Right_E2_Col:
				lds TempR1, Enemy2Y_Bottom
				lds TempR2, Enemy2Y_Top
				lds TempR3, SShip_RightY
				rcall Col_Region_Check
				
				lds TempR1, Enemy2X_Left
				lds TempR2, Enemy2X_Right
				lds TempR3, SShip_RightX
				rcall Col_Region_Check
				ret
		;-----------------------------------
		;------------------------------------------
		SShip_E3_Col:						
			rcall SShip_Top_E3_Col			
			rcall SShip_E3_Col_Check	
			mov Col_Reg, ZeroReg

			rcall SShip_Left_E3_Col
			rcall SShip_E3_Col_Check		; The same outcome whether its any of the 3 points collided
			mov Col_Reg, ZeroReg
			
			rcall SShip_Right_E3_Col
			rcall SShip_E3_Col_Check		; The same outcome whether its any of the 3 points collided
			mov Col_Reg, ZeroReg
			ret

			SShip_E3_Col_Check:
				cpse TwoReg, Col_Reg
				ret
				rcall _Enemy3Dead
				rcall Ship_Collided			; decrement the lives remaining
				ret
		
			SShip_Top_E3_Col:
				lds TempR1, Enemy3Y_Bottom
				lds TempR2, Enemy3Y_Top
				lds TempR3, SShip_TopY
				rcall Col_Region_Check
				
				lds TempR1, Enemy3X_Left
				lds TempR2, Enemy3X_Right
				lds TempR3, SShip_TopX
				rcall Col_Region_Check
				ret

			SShip_Left_E3_Col:
				lds TempR1, Enemy3Y_Bottom
				lds TempR2, Enemy3Y_Top
				lds TempR3, SShip_LeftY
				rcall Col_Region_Check
				
				lds TempR1, Enemy3X_Left
				lds TempR2, Enemy3X_Right
				lds TempR3, SShip_LeftX
				rcall Col_Region_Check
				ret

			SShip_Right_E3_Col:
				lds TempR1, Enemy3Y_Bottom
				lds TempR2, Enemy3Y_Top
				lds TempR3, SShip_RightY
				rcall Col_Region_Check
				
				lds TempR1, Enemy3X_Left
				lds TempR2, Enemy3X_Right
				lds TempR3, SShip_RightX
				rcall Col_Region_Check
				ret
		;-----------------------------------
		;------------------------------------------
		SShip_E4_Col:						
			rcall SShip_Top_E4_Col			
			rcall SShip_E4_Col_Check	
			mov Col_Reg, ZeroReg

			rcall SShip_Left_E4_Col
			rcall SShip_E4_Col_Check		; The same outcome whether its any of the 3 points collided
			mov Col_Reg, ZeroReg
			
			rcall SShip_Right_E4_Col
			rcall SShip_E4_Col_Check		; The same outcome whether its any of the 3 points collided
			mov Col_Reg, ZeroReg
			ret

			SShip_E4_Col_Check:
				cpse TwoReg, Col_Reg
				ret
				rcall _Enemy4Dead
				rcall Ship_Collided			; decrement the lives remaining
				ret
		
			SShip_Top_E4_Col:
				lds TempR1, Enemy4Y_Bottom
				lds TempR2, Enemy4Y_Top
				lds TempR3, SShip_TopY
				rcall Col_Region_Check
				
				lds TempR1, Enemy4X_Left
				lds TempR2, Enemy4X_Right
				lds TempR3, SShip_TopX
				rcall Col_Region_Check
				ret

			SShip_Left_E4_Col:
				lds TempR1, Enemy4Y_Bottom
				lds TempR2, Enemy4Y_Top
				lds TempR3, SShip_LeftY
				rcall Col_Region_Check
				
				lds TempR1, Enemy4X_Left
				lds TempR2, Enemy4X_Right
				lds TempR3, SShip_LeftX
				rcall Col_Region_Check
				ret

			SShip_Right_E4_Col:
				lds TempR1, Enemy4Y_Bottom
				lds TempR2, Enemy4Y_Top
				lds TempR3, SShip_RightY
				rcall Col_Region_Check
				
				lds TempR1, Enemy4X_Left
				lds TempR2, Enemy4X_Right
				lds TempR3, SShip_RightX
				rcall Col_Region_Check
				ret
		;-----------------------------------		

	Ship_Collided:
			dec Lives_left
			ret
		
;------------------------------------------------------------
;GENERAL COL_REGIONCHECK
;TempR1,TempR2,TempR3 : lower bound, upper bound, point of interest

Col_Region_Check:
	Col_Within_LowerBound:
		cp TempR3, TempR1
		brsh Col_UpperBound_Check		; point >= lowerbound
		ret								; proceeds to next region check
		
		Col_UpperBound_Check:
			cp TempR3, TempR2
			brlo Col_True				; point < upperbound
			ret							; proceeds to next region check
		
		Col_True:
			inc Col_Reg					; This region returns true
			ret							; proceeds to next region check
			
		
;-------------------------------------
