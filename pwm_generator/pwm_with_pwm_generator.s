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

	;GOING TO ENABLE THIS ON:
	;M1PWM5 (Module 1, OUTPUT 5)-> PF1 (port F, Pin 1)

	;!Enable PWM Clock
	;RCGCPWM (QUESTION: the instructions use a legacy register, HOW did he find THIS register???)
	;Module PWM 1
	;(r0-address; r1-data)
	MOV r0, #0xE000
	MOVT r0, #0x400F
	ADD r0, r0, #0x640	;get effective address
	MOV r1, #0x2		;Set 2nd Bit for PWM Module #1
	STR r1, [r0]		;Update Register Data

	;XEnable GPIO Clock (Im gonna use non legacy for this one)
	;Port F
	;(r0-address; r1-data)
	;SEEMS TO WORK
	MOV r0, #0xE000
	MOVT r0, #0x400F
	ADD r0, r0, #0x608	;get effective address
	MOV r1, #0x20		;set fifth bit (Port F)
	STR r1, [r0]		;Update Register Data

	;XEnable Pins for Alt Function
	;PORT F (APBee, first one)
	;Pin 1
	;(r0-address, r1-data)
	;UPDATES GPIO_AFSEL successfully
	MOV r0, #0x5000
	MOVT r0, #0x4002
	ADD r0, r0, #0x420	;get effective address
	MOV r1, #0x2		;set 1st pin
	STR r1, [r0]		;Update Register Data

	;XTell the Pins WHICH Alt Function
	;Need to write #5 in field
	;PMC0-7 is the pin (we want Pin 1)
	;Port F
	;(r0-address; r1-data)
		;(I cannot see where this is updating)
	MOV r0, #0x5000
	MOVT r0, #0x4002
	ADD r0, r0, #0x52C		;Get effective address
	MOV r1, #0x50			;Set Pin 1 area as #5
	STR r1, [r0]			;Update Register Data

	;SKIP setting RCC Data because I legit Do not Care about modifying the 16MHz clock
	;controls how fast it counts down
	;he says we need to use this but Do we really? IDk?

	;;;;;EVERYTHING UP TO HERE DOESNT BREAK THE TIVA (which means if i do break it then the error is after this);;;;;;;;;;;;;;;;

	;XConfigure the PWM Generator for coun DOWN  Mode/ Immediate Updates
	;The Default 0x0 setting is DOWN/Immediate Updates, so Im just writing 0x0 to this to be safe
	;he does NOT do anything about this in the slides, probably because it's all default, but Im keeping
	;(r0-address; r1-data)
	MOV r0, #0x9000
	MOVT r0, #0x4002
	ADD r0, r0, #0x0C0	;Get effective address (we're on output 5, so using generator 2)
	MOV r1, #0x0		;Set to clear to default settings
	STR r1, [r0]		;Update Register Data

	;!Configure Output A
	;(r0-address; r1-data)
	MOV r0, #0x9000
	MOVT r0, #0x4002
	ADD r0, r0, #0x0E4	;Get effective address (we're on output 5, so using generator 2)
		;00  B Down (NO B)
		;00  B Up (NO UP)
		;10 A Down --> DRIVE A LOW
		;00 A Up (NO UP)
		;11 When Counter == PWMnLOAD --> DRIVE A HIGH
		;00 When counter == 0 --> NOTHING
	MOV r1, #0x008C		;USING SAME AS DOCS (idk if its right)
	STR r1, [r0]		;Update Register Data


	;Do NOT need to configure output B (there is only 1 output and its an A pin)

	;!SET THE PERIOD (Frequency) (How often it's "interrupted")
	;For the Advanced Value, we dont particularly care how fast it is (I THINKKK), but blinky is every half second, so Period of 8 million (16MHz Clock)
	;(r0-address; r1-data)

	MOV r0, #0x9000
	MOVT r0, #0x4002
	ADD r0, r0, #0x0D0 		;Get effective address (we're on output 5, so using generator 2)
	;set the value to the required period minus 1
	;OK the problem here is that the load value is NOT big enough to store 8 million, so temporarily Im gonna make it as big as i can to see if i can just get it working
	MOV r1, #0xFFFF	;temp value (looks like i DO need to set rcc After all!!!)
	STR r1, [r0]	;Update Register Data

	;set the Pulse (duty Cycle)
	MOV r0, #0x9000
	MOVT r0, #0x4002
	ADD r0, r0, #0x0D8
	MOV r1, #0x7FFF	;this is totally wrong, but its 50% than the messed up value above
	STR r1, [r0]

	;Enable outputs
	MOV r0, #0x9000
	MOVT r0, #0x4002
	ADD r0, r0, #0x0C0
	MOV r1, #0x1		;set to enable the output
	STR r1, [r0]

	;The NOTES dont say to do this, but the DOCs do so im doing it
	;Idk if it matters or not (can delete later) (Im so tired, PLEASE WORK)
	;MOV r0, #0x9000
	;MOVT r0, #0x4002
	;ADD r0, r0, #0x8	;get address
	;MOV r1, #0x20		;turn on 5th output
	;STR r1, [r0]









	POP {r4-r12, lr}
	MOV pc, lr























































	.end
