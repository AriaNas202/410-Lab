	.data

	.global mainMenu
	.global blinkyMenu
	.global advancedMenu
	.global lightState
	.global rgbCode
	.global rgbCodeGetMenu



mainMenu:        	.string "What would you like to test?", 0xA, 0xD
					.string "1-Blinky", 0xA, 0xD
					.string "2-Advanced",0xA, 0xD
					.string "Press Any Other Button to Quit", 0xA, 0xD, 0
blinkyMenu:			.string "You are currently testing Blinky", 0xA, 0xD
					.string "Press any Key to Go Back to Main Menu", 0
advancedMenu:		.string "You are currently testing Advanced_RGB_LED", 0xA, 0xD
					.string "Press any Key to Go Back to Main Menu", 0
lightState:			.word 0x0
rgbCode:			.word 0x0
rgbCodeGetMenu:		.string "Please Input RGB Code in format 0xRRGGBB:", 0xA, 0xD
					.string "0x",0







;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.text

	.global pwmGen
	.global UART0_Handler
	.global Advanced_RGB_LED
	.global blinky
	.global ascii2rgb
	.global reset_RGB
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
ptr_rgbCode:				.word rgbCode
ptr_rgbCodeGetMenu:			.word rgbCodeGetMenu






;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;This is the second function to be called by MAIN
;actually does the little game or whatever
;this should ultimately be the overall "Game" printer which controls replay
pwmGen:
	PUSH {r4-r12, lr}	; Store register lr on stack

	;Init
	BL uart_init				;Print Menu and Test Functions
	bl uart_interrupt_init		;config to uart interrupt to get inputs
	BL gpio_init				;configs GPIO so we can use light


resetPwmTimer:
	;Clear screen
	MOV r0, #0xC
	BL output_character

	;Print Main Menu to Screen
	LDR r0, ptr_mainMenu
	bl output_string



mainMenuPoll:
	;get State of the Test (r4)
	ldr r4, ptr_lightState
	ldr r4, [r4]
	;Figure out what to do based on state
	CMP r4, #1
	BEQ blinkyMain
	CMP r4, #4
	BEQ advancedGetCode
	CMP r4, #3
	BEQ quitMain
	B mainMenuPoll

blinkyMain:; Currently Testing Blinky
	;clear screen
	MOV r0, #0xC
	BL output_character

	;print blinky menu
	ldr r0, ptr_blinkyMenu
	bl output_string

blinkyPoll:
	;The Light is blinking, State Currently #1
	;Wait for state #0 to do anything
	ldr r4, ptr_lightState
	ldr r4, [r4]
	CMP r4, #0
	BEQ resetPwmTimer
	B blinkyPoll

advancedGetCode:
	;clear screen
	MOV r0, #0xC
	BL output_character
	;Print RGB Menu To Screen to prompt user to input code
	ldr r0, ptr_rgbCodeGetMenu
	bl output_string

advancedGetCodePoll:	;State Flag is Currently #4 while we're getting the RGB Code
	;Wait for State Flag to be #2
	ldr r4, ptr_lightState
	ldr r4, [r4]
	CMP r4, #2
	BEQ advancedMain
	B advancedGetCodePoll

advancedMain: ;Now we're done getting the code, Currently Testing Advanced
	;clear screen
	MOV r0, #0xC
	BL output_character

	;print Advanced menu
	ldr r0, ptr_advancedMenu
	bl output_string

advancedPoll:
	;The Light is strobing, State Currently #2
	;Wait for state #0 to do anything
	ldr r4, ptr_lightState
	ldr r4, [r4]
	CMP r4, #0
	BEQ resetPwmTimer
	B advancedPoll



quitMain:

	POP {r4-r12, lr}
	MOV pc, lr




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
UART0_Handler:
	PUSH {r4-r12,lr} ; Spill registers to stack

	;Clear the interrupt
    MOV r2, #0xC000
    MOVT r2, #0x4000
    LDR r3, [r2, #0x044]
    ORR r3, #0x10
    STR r3, [r2, #0x044]

	;read the character
    BL simple_read_character ;character returned in (r0)

    ;get light state for where we are in the testing process (r1-address, r2-data)
    ldr r1, ptr_lightState
    ldr r2, [r1]

    ;do something based on what the state is
    CMP r2, #0
    BEQ uart0State	;We're On Main Menu
    CMP r2, #1
    BEQ uart1State	;We're Testing Blinky
    CMP r2, #2
    BEQ uart2State	;We're in the middle of Testing Advanced
    CMP r2, #4
    BEQ uart4State
    B EndUartHandler ;Else the state should be #3 to Quit
;;;;;;;;;;;;;;;
uart0State:	;We're on Main Menu

	;check user input to see what we do
	CMP r0, #0x31 ;user hit 1
	BEQ state01
	CMP r0, #0x32 ;user hit 2
	BEQ state04
	B state0else

state01:	;must test Blinky
	;change light state to 1 (we're testing Blinky)
	ldr r0, ptr_lightState
	MOV r1, #1
	STR r1, [r0]
	;Call blinky
	BL blinky
	B EndUartHandler
state04:	;must test Advanced, need to get Hex Code Color next
	;We need to transition into collecting the hex code before we can call Advanced
	;Change State to #4
	MOV r2, #4
	str r2, [r1]
	B EndUartHandler
state0else:	;must Quit
	;change flag to #3
	MOV r2, #3
	str r2, [r1]
	B EndUartHandler




;;;;;;;;;;;;;;;
uart1State: ;We're In the Middle Of Testing Blinky
	;Change flag to #0 (go back to main Menu)
	MOV r2, #0
	str r2, [r1]
	;Clear the RB Light
	BL reset_RGB

	B EndUartHandler


;;;;;;;;;;;;;;;
uart2State: ;We're In the Middle of Testing Advanced
	;Change flag to #0
	MOV r2, #0
	str r2, [r1]
	;Clear rgbCode (r1- address, r2-data)
	LDR r1, ptr_rgbCode
	MOV r2, #0
	STR r2, [r1]
	;Clear the RB Light
	BL reset_RGB

	B EndUartHandler

;;;;;;;;;;;;;;;
uart4State: ;We're in the Process of Getting Hex Code for Advanced


	;Is char (r0) Enter? (Ie are we done now?)
	CMP r0, #0xD
	BEQ state4enter		;if ENTER Handle End of State 4 (Getting RGB Code)
	B state4notenter	;If not, keep processing RGB Code



state4enter:	;We're done processing RGB Code input, time to test Advanced
	;change state flag to 2 (we're testing Advanced)
	ldr r0, ptr_lightState
	MOV r1, #2
	STR r1, [r0]
	;Call Advanced
	bl Advanced_RGB_LED
	B EndUartHandler


state4notenter:		;Process Current Keypush as part of RGB Code

	;Temp Put User-entered Char into r4 to save it (so doesnt get overwritten with output_character)
	MOV r4, r0
	;Print User-Entered Char (for feedback)
	bl output_character
	;Turn Keypush string into hex rgb
	MOV r0, r4		;get User-Entered Char back from r4
	bl ascii2rgb	;new keypush in r0

	;get current hexcode (r1- address, r2-data)
	LDR r1, ptr_rgbCode
	LDR r2, [r1]

	;Push the hexcode (r2) left by 1 hex code (4 bits)
	LSL r2, r2, #4	;push hexcode (r2) left by 4 bits (1 hex value) (THE BITS BEING SHIFTED IN SHOULD BE
	;Put the Keypush bits (r0) in left part of hexcode (r2) and store in (r2)
	ORR r2, r0, r2

	;store updated hexcode (r2) back
	STR r2, [r1]

	B EndUartHandler



EndUartHandler:
	;End
	POP {r4-r12,lr} ; Pop registers from stack
	BX lr       	; Return




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Takes User Input in r0
;Returns actual hex RGB value in r0
;Ex) 0x46 (8 bit value) -> 0xF (4 bit value)
;defaults to 0x10 as return value (impossible value because we're only returning 4 bit values)
ascii2rgb:
	PUSH  {r4, lr}	; Store register lr on stack

	;Use r4 as accumulator for what value is
	MOV r4, #0x10

	;Compare User Input (r0) and Update Accumulator (r4) Appropriately
	CMP r0, #0x30		;0
	IT EQ
	MOVEQ r4, #0x0
	CMP r0, #0x31		;1
	IT EQ
	MOVEQ r4, #0x1
	CMP r0, #0x32		;2
	IT EQ
	MOVEQ r4, #0x2
	CMP r0, #0x33		;3
	IT EQ
	MOVEQ r4, #0x3
	CMP r0, #0x34		;4
	IT EQ
	MOVEQ r4, #0x4
	CMP r0, #0x35		;5
	IT EQ
	MOVEQ r4, #0x5
	CMP r0, #0x36		;6
	IT EQ
	MOVEQ r4, #0x6
	CMP r0, #0x37		;7
	IT EQ
	MOVEQ r4, #0x7
	CMP r0, #0x38		;8
	IT EQ
	MOVEQ r4, #0x8
	CMP r0, #0x39		;9
	IT EQ
	MOVEQ r4, #0x9
	CMP r0, #0x41		;A
	IT EQ
	MOVEQ r4, #0xA
	CMP r0, #0x42		;B
	IT EQ
	MOVEQ r4, #0xB
	CMP r0, #0x43		;C
	IT EQ
	MOVEQ r4, #0xC
	CMP r0, #0x44		;D
	IT EQ
	MOVEQ r4, #0xD
	CMP r0, #0x45		;E
	IT EQ
	MOVEQ r4, #0xE
	CMP r0, #0x46		;F
	IT EQ
	MOVEQ r4, #0xF
	CMP r0, #0x61		;a
	IT EQ
	MOVEQ r4, #0xA
	CMP r0, #0x62		;b
	IT EQ
	MOVEQ r4, #0xB
	CMP r0, #0x63		;c
	IT EQ
	MOVEQ r4, #0xC
	CMP r0, #0x64		;d
	IT EQ
	MOVEQ r4, #0xD
	CMP r0, #0x65		;e
	IT EQ
	MOVEQ r4, #0xE
	CMP r0, #0x66		;f
	IT EQ
	MOVEQ r4, #0xF
	;There shoudn't be any other Inputs, in a Well-formatted RGB String (not handling non-well formatted strings rn)

	;Move Acc (r4) into return (r0)
	MOV r0, r4


	POP  {r4, lr}	; Store register lr on stack
	MOV pc, lr



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Advanced_RGB_LED:
	PUSH  {r4-r12, lr}

	;M1PWM5 (Module 1, Gen 2, Output B)		-> RED
	;M1PWM6 (Module 1, Gen 3, Output A)		->BLUE
	;M1PWM7 (Module 1, Gen 3, Output B)		->GREEN
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;!enable clock for GPIO Pins (calling gpio init before this, SO FOR NOW, assume this is already done)


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;!Setup GPIO Pins to be in Alt Function Mode
	;GPIO_AFSEL (671) (40025420)
	;(r0-address; r1-data)
	;Port F (APBee); Pin 1,2,3
	MOV r0, #0x5000
	MOVT r0, #0x4002
	ADD r0, r0, #0x420		;Get effective address

	MOV r1, #0xE			;Set pin 1,2,3

	STR r1, [r0]			;Update Register

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;!Select Alternate Function to be PWM
	;GPIO_PCTL (688) (4002552C)
	;(r0-address; r1-data)
	;Port F (APBee); Pin 1,2,3
	MOV r0, #0x5000
	MOVT r0, #0x4002
	Add r0, r0, #0x52C		;Get effective address

	MOV r1, #0x5550			;Write #5 to GPIO Pin 1,2,3

	STR r1, [r0]			;Update Register

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;!Enable Clock for PWM Module
	;RCGCPWM (354) (400FE640)
	;(r0-address; r1-data)
	;PWM Module 1
	MOV r0, #0xE000
	MOVT r0, #0x400F
	ADD r0, r0, #0x640		;Get effective address

	MOV r1, #0x2			;Turn on PWM Module 1 (2nd bit)

	STR r1, [r0]			;Update Register

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;!?Set PWM Divisor
	;RCC (254) (400FE060)
	;(r0-address; r1-data)
	MOV r0, #0xE000
	MOVT r0, #0x400F
	ADD r0, r0, #0x060		;Get Effective Address

		;16 MHz clock
		;RCC set to /64 (default divisor)
		; --> 250,000 clock speed
		;IS THIS TOO SLOW FOR ADVANCED? MAYBE!
	LDR r1, [r0]					;Get current data in register
	ORR	r1, r1, #0x100000			;set the 20th bit to 1 (USEPWMDIV turn on the PWM clock)

	STR r1, [r0]			;Update Register


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;!?Set Generator Actions
	;(r0-address; r1-data;r2-trash)

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;!?
	;M1PWM5 (Module 1, Gen 2, Output B)
	;PWM2GENB (1285) (400290E4) (B)
	MOV r0, #0x9000
	MOVT r0, #0x4002
	ADD r0, #0x0E4			;Get effective address (Gen 2, B)

		;11-00-00-00-10-00
		;B Comparator going down -> Drive B High
		;==LOAD -> Drive B Low
	LDR r1, [r0]			;get current configurations
	MOV r2, #0xFFF
	BIC r1,r1,r2			;clear current configurations
	MOV r2, #0xC08
	ORR r1,r1,r2			;set current configure compare values
	STR r1, [r0]			;Update Register

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;!?
	;M1PWM6 (Module 1, Gen 3, Output A)
	;PWM3GENA (1282) (40029120) (A)
	MOV r0, #0x9000
	MOVT r0, #0x4002
	ADD r0, r0, #0x120		;Get effective address  (Gen 3, A)

		;00-00-11-00-10-00
		;A Comp Down -> Drive A High
		;==LOAD -> Drive A Low
	LDR r1, [r0]			;get current configurations
	MOV r2, #0xFFF
	BIC r1,r1,r2			;clear current configurations
	MOV r2, #0x0C8
	ORR r1,r1,r2			;set current configure compare values
	STR r1, [r0]			;Update Register

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;!?
	;M1PWM7 (Module 1, Gen 3, Output B)
	;PWM3GENB (1285) (40029124) (B)
	MOV r0, #0x9000
	MOVT r0, #0x4002
	ADD r0, r0, #0x124		;Get effective address (Gen 3, B)

		;11-00-00-00-10-00
		;B Comparator going down -> Drive B High
		;==LOAD -> Drive B Low
	LDR r1, [r0]			;get current configurations
	MOV r2, #0xFFF
	BIC r1,r1,r2			;clear current configurations
	MOV r2, #0xC08
	ORR r1,r1,r2			;set current configure compare values
	STR r1, [r0]			;Update Register


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;!?
	;Set Load Value
	;Should be the same for every color (SET TO 255 FOR NOW!!!!!!)
	;(r0-address; r1-data;r2-trash)

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;!?
	;M1PWM5 (Module 1, Gen 2)
	;PWM2GENB (1278) (400290d0)
	MOV r0, #0x9000
	MOVT r0, #0x4002
	ADD r0, r0, #0x0D0		;get effective address (generator 2)

	MOV r1, #0xFE			;Set Load Val to 255-1

	STR r1, [r0]			;Update Register


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;!?
	;M1PWM6/M1PWM7 (Module 1, Gen 3)
	;PWM3GENA (1278) (40029110)
	MOV r0, #0x9000
	MOVT r0, #0x4002
	ADD r0, r0, #0x110		;get effective address (generator 3)

	MOV r1, #0xFE			;Set Load Val to 255-1

	STR r1, [r0]			;Update Register

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	;!?
	;Set Compare Value
	;(r0-address; r1-data;r2-trash)
	;0xRRGGBB

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;!?
	;RED
	;M1PWM5 (Module 1, Gen 2, Output B)
	;PWM2CMPB (1281) (400290DC) (B)
	MOV r0, #0x9000
	MOVT r0, #0x4002
	ADD r0, r0, #0x0DC		;Get effective address (Gen 2, B)


	ldr r1, ptr_rgbCode
	ldr r1, [r1]
	MOV r2, #0xFF0000
	AND r1,r1,r2			;mask Red bits of code
	LSR r1,r1, #16			;Shift Red 16 bits right
	SUB r1,r1, #1			;Set Comp Value to Desired Value-1

	STR r1, [r0]




;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;!?
	;BLUE
	;M1PWM6 (Module 1, Gen 3, Output A)
	;PWM3CMPA (1280) (40029118) (A)
	MOV r0, #0x9000
	MOVT r0, #0x4002
	ADD r0, r0, #0x118		;Get effective address (Gen 3, A)


	ldr r1, ptr_rgbCode
	ldr r1, [r1]
	MOV r2, #0xFF
	AND r1,r1,r2			;mask Blue bits of code
	SUB r1,r1, #1			;Set Comp Value to Desired Value-1

	STR r1, [r0]


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;!?
	;GREEN
	;M1PWM7 (Module 1, Gen 3, Output B)
	;PWM2CMPB (1281) (4002911C) (B)
	MOV r0, #0x9000
	MOVT r0, #0x4002
	ADD r0, r0, #0x11C		;Get effective address (Gen 3, B)


	ldr r1, ptr_rgbCode
	ldr r1, [r1]
	MOV r2, #0xFF00
	AND r1,r1,r2			;mask Green bits of code
	LSR r1,r1, #8			;Shift Green 8 bits right
	SUB r1,r1, #1			;Set Comp Value to Desired Value-1

	STR r1, [r0]


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;!Enable Output to the PWM Pins
	;(r0-address; r1-data)
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;!?
	;M1PWM5 (Module 1, Gen 2)
	;PWM2CTL (1266) (400290C0)
	MOV r0, #0x9000
	MOVT r0, #0x4002
	ADD r0, r0, #0x0C0		;get effective address (Gen 2)

	LDR r1, [r0]			;get current configs
	ORR r1, r1, #0x1		;set bit 0 to "1" to enable PWM

	STR r1, [r0]			;Update Register


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;!?
	;M1PWM6/M1PWM7 (Module 1, Gen 3)
	;PWM2CTL (1266) (40029100)
	MOV r0, #0x9000
	MOVT r0, #0x4002
	ADD r0, r0, #0x100		;get effective address (Gen 3)

	LDR r1, [r0]			;get current configs
	ORR r1, r1, #0x1		;set bit 0 to "1" to enable PWM

	STR r1, [r0]			;Update Register


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;!(NOT in notes, but necessary I think) enable the bits
	; PWMENABLE (1247) (40029008)
	MOV r0, #0x9000
	MOVT r0, #0x4002
	ADD r0, r0, #0x008	;get effective address

	;Want to enable outputs 5,6,7 (M1PWM5/M1PWM6/M1PWM6)
	LDR r1, [r0]
	ORR r1, r1, #0xE0	;set 5th,6th,7th bit

	STR r1, [r0]		;Update Register




	;NOTE: count (1279) (400290D4)




;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	POP  {r4-r12, lr}
	MOV pc, lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
reset_RGB:
	PUSH  {r4-r12, lr}



	POP  {r4-r12, lr}
	MOV pc, lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

	;!(NOT in notes, but necessary I think) enable the bits
	; PWMENABLE (1247) (40029008)
	MOV r0, #0x9000
	MOVT r0, #0x4002
	ADD r0, r0, #0x008	;get effective address

	;Want to enable pwm2B (signal 5) (MnPWM5)
	LDR r1, [r0]
	ORR r1, r1, #0x20	;set 5th bit

	STR r1, [r0]		;Update Register

	;NOTE: count (1279) (400290D4)








	POP {r4-r12, lr}
	MOV pc, lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



















	.end
