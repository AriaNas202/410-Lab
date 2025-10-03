	.data

	.global mainMenu
	.global lightState
	.global blinkAlternateFlag
	.global rgbCode
	.global rgbCodeGetMenu
	.global pwmCycles


mainMenu:        	.string "What would you like to test?", 0xA, 0xD
					.string "1-Blinky", 0xA, 0xD
					.string "2-Advanced",0xA, 0xD
					.string "Press Any Other Button to Quit", 0xA, 0xD, 0
blinkyMenu:			.string "You are currently testing Blinky", 0xA, 0xD
					.string "Press any Key to Go Back to Main Menu", 0
advancedMenu:		.string "You are currently testing Advanced_RGB_LED", 0xA, 0xD
					.string "Press any Key to Go Back to Main Menu", 0
lightState:			.word 0x0
blinkAlternateFlag:	.word 0x0
rgbCode:			.word 0x0
rgbCodeGetMenu:		.string "Please Input RGB Code in format 0xRRGGBB:", 0xA, 0xD
					.string "0x",0
pwmCycles:			.word 0x1		;The number interrupt we're on (ex. First interrupt is 1, Second is 2, etc)
									;(1-255, after that gets reset back to 1)
									;For Advanced Function ONLY







;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.text

	.global pwmGen
	.global timer_interrupt_init ;Library
	.global gpio_init ;Library
	.global uart_init ;Library
	.global uart_interrupt_init ;Library
	.global output_string ;Library
	.global output_character ;Library
	.global simple_read_character ;Library
    .global modified_int2string ;Library
    .global modified_illuminate_RGB_LED ;Library
    ;.global string2int ;Library



ptr_mainMenu:				.word mainMenu
ptr_blinkyMenu:				.word blinkyMenu
ptr_advancedMenu:			.word advancedMenu
ptr_lightState:				.word lightState
ptr_blinkAlternateFlag:		.word blinkAlternateFlag
ptr_rgbCode:				.word rgbCode
ptr_rgbCodeGetMenu:			.word rgbCodeGetMenu
ptr_pwmCycles:				.word pwmCycles





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This is the second function to be called by MAIN
;actually does the little game or whatever
;this should ultimately be the overall "Game" printer which controls replay
pwmGen:
	PUSH {r4-r12, lr}	; Store register lr on stack

	;Init
	;BL uart_init				;Print Menu and Test Functions
	;bl uart_interrupt_init		;config to uart interrupt to get inputs
	;BL gpio_init				;configs GPIO so we can use light
	;bl timer_interrupt_init		;configures timer to interrupt

	BL blinky

infinLoop:
	B infinLoop


quitMain:

	POP {r4-r12, lr}
	MOV pc, lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
init_pwm_generator:
	PUSH {r4-r12, lr}








	POP {r4-r12, lr}
	MOV pc, lr





;I JUST HAD THE REALIZATION THAT IVE BEEN WORKING ON THE WRONG PIN THIS ENTIRE TIME
;THE SETUP IS THERE BUT I MUST FIX EVERYTHINGGGGGGG!!!!!
blinky:
	PUSH {r4-r12, lr}

	;GOING TO ENABLE THIS ON PWM MODULE 0, GENERATOR 0, PIN 0(A)
	;M0PWM0 (Module 0)-> PB6 (port B, Pin 6)

	;Enable PWM Clock
	;RCG0 (CURRENTLY USING LEGACY REGISTER--Actually notes say to use this, so okay)
	;(r0-address; r1-data)
	;SEEMS TO WORK
	MOV r0, #0xE000
	MOVT r0, #0x400F
	ADD r0, r0, #0x100	;get effective address
	MOV r1, #0x100000	;Set 20th bit on
	STR r1, [r0]		;Update Register Data

	;Enable GPIO Clock (Im gonna use non legacy for this one)
	;Port B
	;(r0-address; r1-data)
	;SEEMS TO WORK
	MOV r0, #0xE000
	MOVT r0, #0x400F
	ADD r0, r0, #0x608	;get effective address
	MOV r1, #0x2		;set second bit (Port B)
	STR r1, [r0]		;Update Register Data

	;Enable Pins for Alt Functio n
	;PORT B (APB, first one)
	;Pin 6
	;(r0-address, r1-data)
	;(i cannot find where this is updating)
	MOV r0, #0x5000
	MOVT r0, #0x4000
	ADD r0, r0, #0x420	;get effective address
	MOV r1, #0x40		;set 6th pin
	STR r1, [r0]		;Update Register Data

	;Tell the Pins WHICH Alt Function
	;Need to write #4 in field
	;PMC0-7 is the pin (we want Pin 6)
	;Port B
	;(r0-address; r1-data)
	;This seems to update GPIO_PCTL successfully
	MOV r0, #0x5000
	MOVT r0, #0x4000
	ADD r0, r0, #0x52C		;Get effective address
	MOV r1, #0x4000000		;Set Pin 6 area as #4
	STR r1, [r0]			;Update Register Data

	;SKIP setting RCC Data because I legit Do not Care about modifying the 16MHz clock
	;controls how fast it counts down
	;he says we need to use this but Do we really? IDk?

	;;;;;EVERYTHING UP TO HERE DOESNT BREAK THE TIVA (which means if i do break it then the error is after this);;;;;;;;;;;;;;;;

	;Configure the PWM Generator for coun DOWN  Mode/ Immediate Updates
	;The Default 0x0 setting is DOWN/Immediate Updates, so Im just writing 0x0 to this to be safe
	;(r0-address; r1-data)
	;(i cannot find where this is updating)
	MOV r0, #0x8000
	MOVT r0, #0x4002
	ADD r0, r0, #0x40	;Get effective address
	MOV r1, #0x0		;Set to clear to default settings
	STR r1, [r0]		;Update Register Data

	;Configure Output A
	;(r0-address; r1-data)
	;This seems to be updating PWM_0_GENA successfully
	MOV r0, #0x8000
	MOVT r0, #0x4002
	ADD r0, r0, #0x60	;Get effective address
		;00  B Down (NO B)
		;00  B Up (NO UP)
		;10 A Down --> DRIVE A LOW
		;00 A Up (NO UP)
		;11 When Counter == PWMnLOAD --> DRIVE A HIGH
		;00 When counter == 0 --> NOTHING
	MOV r1, #0x008C		;Im pretty sure the variable we're doing is literally the exact same as the docs
	STR r1, [r0]		;Update Register Data


	;Do NOT need to configure output B (there is only 1 output and its an A pin)

	;SET THE PERIOD! (Frequency) (How often it's "interrupted")
	;For the Advanced Value, we dont particularly care how fast it is (I THINKKK), but blinky is every half second, so Period of 8 million (16MHz Clock)
	;(r0-address; r1-data)

	MOV r0, #0x







	POP {r4-r12, lr}
	MOV pc, lr























































	.end
