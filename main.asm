.DEVICE ATmega128
.include "m128def.inc"

; Definitions
.def PrevButtonState 		= r4	; Check with curront button state prevent taking in values when the button is held
.def CurrentButtonState		= r5	; Take in button 
.def Col_Reg				= r6	; Register to indicate collision region with different objects, if value is 2, indicates collision, else it doesn't indicate collision. 
.def Lives_left				= r7
.def BlinkCounterL			= r8	; Lower blink counter
.def BlinkCounterH			= r9	; BlinkCounterL carries over to BlinkCounterH
.def EnemyCount  			= r10	; Number of enemies
.def EnemyCountThreshold 	= r11	; Number of maximum enemies - up to 4 enemies for this game. 

.def TwoReg		= r13				; Register with value $02
.def OneReg		= r14				; Register with value $01
.def ZeroReg 	= r15				; Register with value $00
.def TempR1		= r16				; 6 temporary registers for general use 
.def TempR2		= r17
.def TempR3		= r18
.def TempR4		= r19
.def TempR5		= r20
.def TempR6		= r21

.def Boundary_Reg = r23				; Register to indicate boundaries for the ship
.def ObjectStatus = r24				; Status of objects in game including enemies and bullets. 
.def FlagReg	  = r25				; Flagreg, different bits are used to indicate game start, game over etc. 


; ObjectStatus bit definitions 
; If set, object is alive, else dead.
; Bit 1: Enemy1 
; Bit 2: Enemy2
; Bit 3: Enemy3
; Bit 4: Enemy4


; Bit 7: Bullet
; FlagReg bit definitions 
; Bit 0: If set, go to Game routine, else, loop start screen
; Bit 1: If set, go to Game Over routine, else, loop Game routine. 
; Bit 2: If set, go to RestartGame initialisation, else, stay in Game Over routine. 
; Bit 3: If set, output from Compute Routine is stored in B addresses, else stored in A addresses - AB Buffer routine. 
; Bit 4: None 
; Bit 5: Blinking routine, if set display, else don't display. 
; Bit 6: Button state, if set, button is pressed, and execute routine.


.org		$0000
		jmp initialiseSystem
.org		$001E
		jmp DisplayISR				; Interrupt - timer 0 Compare Vector, to display screen 
.org		$0020
		jmp Joystick_Button_Inputs	; Interrupt - timer 0 Overflow Handler, to take in joystick & button inputs
.org		$0080

jmp InitialiseSystem				
	
;############################
; Open files
.include "VectorTable.asm"			; Stored in SRAM location, the drawings of the spaceship, 4 enemies, game title, 'press to start' sign and 'hearts' for lives remaining.    
.include "Initialisations.asm"	
.include "MemoryLocations.asm"		; Memory address for every object in the game, including velocity, position, collision points and perimeter (each point in the address is the sum of the centre of mass position + displacement from center of the drawing).
.include "Delays.asm"				; Various delay functions 
.include "HardwareInit.asm"			; Initialises ports, SRAM, ADC
.include "DisplayISR.asm"			; Display routine 
.include "InputISR.asm"				; Joystick and Button interrupt routine
.include "Collision.asm"			; Collision condition routine 
.include "A_B_BufferScheme.asm"		; Computation for velocity and position for every object. First computation stores in A addresses, then display interrupt takes A values, while second computation stores in B addresses and vice versa. 
.include "StartScreen.asm"			; Start screen routine 
;############################

InitialiseSystem:
	rjmp HardwareInit				; Init hardware, (rjmp as stack pointer has not been set up yet)
	

StartGame:
	call GameSystemInit				; Init software


StartScreen:
    call ComputeStartScreen			; Create start screen graphic and store in SRAM
    call EnemySystemInit    		; Set values for maximum number of enemies, initial number of enemies, and which enemies to display first. 


	call Button_StartGame			; Continuously check button input, if pressed - start the game. 


    sbrs FlagReg, 0					; Stays in StartScreen unless flag 0 is set
    rjmp StartScreen
    rjmp Game


Game:
	rcall Enemy_Revive				; Continuosly recreate enemies
	rcall Collision					; Check for collision
	rcall Lives						; Triggers into Game Over Flag by checking lives_left
	sbrc FlagReg, 1					; Bit 1 is Game Over Flag, if Bit 1 is set, 
	rjmp GameOverProtocol			; then Game Over, screen freezes and blinks before returning back to start game. 

	rcall Button_Shooting			; If button is pressed (a flag that is set in the interrupt), then only one bullet will be shot. 


	sbrc FlagReg, 3					; flag to choose between storing in A or B addresses in SRAM.
	rjmp B_Compute
	rjmp A_Compute
		

GameOverProtocol:					; activate blinking in sship display							
	call delay60000					; Displays blinking SShip before restarting the game
    call delay60000
	call delay60000
	call delay60000
	call delay60000
	call delay60000
	call delay60000		
    call delay60000
	call delay60000
	call delay60000
	call delay60000
	call delay60000
	call delay60000			
    call delay60000
	call delay60000
	call delay60000
	call delay60000
	call delay60000
	call delay60000					
 
	jmp StartGame				


Lives:
	cpse Lives_left, ZeroReg	; If zero lives left
    ret							
	sbr FlagReg, 0b00000010		; Set flag to trigger Game Over routine
	ret

		
Button_StartGame:				
	sbrc FlagReg, 6				; If bit 6 of FlagReg is raised, 
	rcall Start					; Start the game by setting bit 0 of FlagReg
	cbr FlagReg, 6
	ret

Button_Shooting:
	sbrc FlagReg, 6
	rcall Shoot	
	cbr FlagReg, 6
	ret

Shoot:
	sbrs ObjectStatus, 7		; if bullet status is not alive 
	call InitBullet  			; make a bullet at the ship's position
	ret
	
Start:
	sbr FlagReg, 0b00000001		; During compute cycle it will go into game mode
	ret






