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


quitMain:

	POP {r4-r12, lr}
	MOV pc, lr



	.end
