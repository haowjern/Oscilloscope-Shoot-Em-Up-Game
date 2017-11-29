# Oscilloscope-Shoot-Em-Up-Game

A Shoot ’Em Up game was successfully programmed and implemented using a 8 bit Atmel Microcontroller
- ATmega128. The program was written in AVR Assembler and displayed onto an oscilloscope using its XY
mode. A spaceship can be controlled to move any direction in 2D, and interact with up to 4 enemies
using a bullet. Movement is implemented using a joystick and an Analog to Digital Converter. Display is
implemented using an Oscilloscope’s XY mode, hence two pairs of Digital to Analog Converter & Operational
Amplifier are used to convert digital data into analog signals. A button built in the microcontroller is also
used as input to start the game and shoot a bullet. Collision condition is successfully implemented for the
ship, enemies and the bullet. 

This project was implemented within the span of 3 weeks, and I worked on this with another partner of mine. 

Video of game has also been uploaded for viewing. 

Specifications: 
- 8-bit Atmel AVR Microcontroller
- ATmega128 Microprocessor
- Screen Refresh Rate: 122s−1
- 2707 bytes SRAM Usage
- 5272 bytes Flash Program Memory Usage
- Number of Players: 1
- Number of Enemies: 4
- 2D Movement with a a Parallax 2-Axis Joystick
- 1 Bullet Shooting with Button Input
- Collision with Enemies
- Screen Boundary
- Visual Output via Hitachi V555 Oscilloscope XY
mode Display
- Death and Revival System
- Top Down View
- 2 DAC’s (TLC7524) & Op Amp (741) pair


#To Run
I ran the program using AtmelStudio 7, and just running the 'main' file is sufficient. 
