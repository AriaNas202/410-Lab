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




;New Attempt Using the Notes
blinky:
	PUSH {r4-r12, lr}

	;GOING TO ENABLE THIS ON:
	;M1PWM5 (Module 1, OUTPUT 5 [B], Generator 2)-> PF1 (port F, Pin 1)

	;!Enable Clock for GPIO Pins
	;RCGCGPIO (340) (400FE608)
	;(r0-address; r1-data)
	;Port F
	MOV r0, #0xE000
	MOVT r0, #0x400F
	ADD r0, r0, #0x608	;get effective address

	MOV r1, #0x20		;Turn on Port F (bit 5)

	STR r1, [r0]		;Update Register

	;!Setup GPIO pins to be in Alternate Function Mode
	;GPIO_AFSEL (671) (40025420)
	;(r0-address; r1-data)
	;Port F (APBee); Pin 1
	MOV r0, #0x5000
	MOVT r0, #0x4002
	ADD r0, r0, #0x420		;Get effective address

	MOV r1, #0x2			;Set pin 1 (2nd bit)

	STR r1, [r0]			;Update Register

	;!Select Alternate Function to be PWM
	;GPIO_PCTL (688) (4002552C)
	;(r0-address; r1-data)
	;Port F (APBee); Pin 1
	MOV r0, #0x5000
	MOVT r0, #0x4002
	ADD r0, r0, #0x52C		;Get effective address

	MOV r1, #0x50			;Write #5 to the second Hex value (GPIO Pin 1)

	STR r1, [r0]			;Update Register

	;!Enable Clock for PWM Module
	;RCGCPWM (354) (400FE640)
	;(r0-address; r1-data)
	;PWM Module 1
	MOV r0, #0xE000
	MOVT r0, #0x400F
	ADD r0, r0, #0x640		;Get effective address

	MOV r1, #0x2			;Turn on PWM Module 1 (2nd bit)

	STR r1, [r0]			;Update Register

	;!Set PWM Divisor
	;RCC (254) (400FE060)
	;(r0-address; r1-data)
	MOV r0, #0xE000
	MOVT r0, #0x400F
	ADD r0, r0, #0x060		;Get Effective Address

		;16 MHz clock
		;RCC set to /64 (default divisor)
		; --> 250,000 clock speed
	LDR r1, [r0]					;Get current data in register
	ORR	r1, r1, #0x100000			;set the 20th bit to 1 (USEPWMDIV turn on the PWM clock)

	STR r1, [r0]			;Update Register

	;!?Set Generator Actions
	;Module 1, Generator 2
	;PWM2GENB (1285) (400290E4)
	;(r0-address; r1-data;r2-trash)
	;
	MOV r0, #0x9000
	MOVT r0, #0x4002
	ADD r0, r0, #0x0E4	;get effective address (generator 2)


		;B Comparator going down -> Drive B High
		;==LOAD -> Drive B Low
	LDR r1, [r0]		;get current configurations
	MOV r2, #0xFFF
	BIC r1,r1, r2		;clear current configurations
	MOV r2, #0xC08
	ORR r1,r1,r2		;set current configure compare values

	STR r1, [r0]		;Update Register

	;!?Set Load Value
	;PWM2LOAD (1278) (400290d0)
	;Module 1, Generator 2
	;(r0-address; r1-data;r2-trash)
	MOV r0, #0x9000
	MOVT r0, #0x4002
	ADD r0, r0, #0x0D0		;get effective address (generator 2)

	LDR r1, [r0]			;get current configurations
	MOV r2, #0xFFFD
	ORR r1, r1, r2			;Set desired load value 65,534-1

	STR r1, [r0]			;Update register

	;!?Set Compare Value
	;PWM2CMPB (1281) (400290DC)
	;Module 1, Generator 2
	;(r0-address; r1-data;r2-trash)
	MOV r0, #0x9000
	MOVT r0, #0x4002
	Add r0, r0, #0x0DC		;get effective address (generator 2)

	LDR r1, [r0]			;get current configs
	MOV r2, #0x7FFE
	ORR r1, r1, r2			;set desired compB value 32,767-1

	STR r1, [r0]			;Update Register

	;!Enable Output to the PWM Pins
	;PWM2CTL (1266) (400290C0)
	;Module 1, Generator 2
	;(r0-address; r1-data;r2-trash)
	MOV r0, #0x9000
	MOVT r0, #0x4002
	ADD r0, r0, #0x0C0		;Get effective address (Generator 2)

	LDR r1, [r0]			;get current configs
	ORR r1, r1, #0x1		;set bit 0 to "1" to enable PWM

	STR r1, [r0]			;Update Register

	;!Doing (seeminly wrong/optional) enable the bits (he didnt put this in notes)
	; PWMENABLE (1247) (40029008)
	MOV r0, #0x9000
	MOVT r0, #0x4002
	ADD r0, r0, #0x008	;get effective address

	;Want to enable pwm2B (signal 5) (MnPWM5)
	LDR r1, [r0]
	ORR r1, r1, #0x20	;set 5th bit

	STR r1, [r0]		;Update Register








	POP {r4-r12, lr}
	MOV pc, lr























































	.end
