delay: 
		push XH
		push XL
        ldi XH, HIGH(50)
        ldi XL, LOW (50)
		rjmp count

delay25: 
		push XH
		push XL
        ldi XH, HIGH(25)
        ldi XL, LOW (25)
		rjmp count

delay1800: 
		push XH
		push XL
        ldi XH, HIGH(1800)
        ldi XL, LOW (1800)
		rjmp count
		
delay60000: 
		push XH
		push XL
        ldi XH, HIGH(60000)
        ldi XL, LOW (60000)
		rjmp count

delaycorner: 
		push XH
		push XL
        ldi XH, HIGH(100)
        ldi XL, LOW (100)
		rjmp count

delaybullet: 
		push XH
		push XL
        ldi XH, HIGH(300)
        ldi XL, LOW (300)
		rjmp count

count:  
		sbiw XL, 1
		brne count
		pop XL
		pop XH
        ret