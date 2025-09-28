	.data

	.global mainMenu
	.global blinkyMenu
	.global advancedMenu
	.global lightState
	.global blinkAlternateFlag
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
blinkAlternateFlag:	.word 0x0
rgbCode:			.word 0x0
rgbCodeGetMenu:		.string "Please Input RGB Code in format 0xRRGGBB:", 0xA, 0xD
					.string "0x",0







;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.text

	.global pwmTimer
	.global Timer_Handler
	.global UART0_Handler
	.global Advanced_RGB_LED
	.global blinky
	.global ascii2rgb
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





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This is the second function to be called by MAIN
;actually does the little game or whatever
;this should ultimately be the overall "Game" printer which controls replay
pwmTimer:
	PUSH {r4-r12, lr}	; Store register lr on stack

	;Init
	BL uart_init				;Print Menu and Test Functions
	bl uart_interrupt_init		;config to uart interrupt to get inputs
	BL gpio_init				;configs GPIO so we can use light
	;bl timer_interrupt_init		;configures timer to interrupt

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
Timer_Handler:

	PUSH {r4-r12,lr} ; Spill registers to stack

	;Clear interrupt
	MOV r0, #0x0000
	MOVT r0, #0x4003
	LDRB r1, [r0, #0x24]
	ORR r1, r1, #0x1
	STRB r1, [r0, #0x24]

	;read light state flag (r0)
	LDR r0, ptr_lightState
	LDR r0, [r0]

	;See which function we're testing based on LightState Flag
	CMP r0, #0
	BEQ noneTimerHandler		;if 0, turn off all lights
	CMP r0, #1
	BEQ blinkyTimerHandler		;if 1 blink lights
	CMP r0, #2
	BEQ advancedTimerHandler	;if 2 do advanced processing
	B endTimerHandler


noneTimerHandler:
	;Testing No Function- turn all lights off
	MOV r0, #0
	BL modified_illuminate_RGB_LED
	B endTimerHandler

blinkyTimerHandler: ;Testing Blinky
	;Get Alternate Flag (r1-addres, r0-data)
	LDR r1, ptr_blinkAlternateFlag
	LDR r0, [r1]

	;Change Alt Flag to opposite
	EOR r0, r0, #1

	;Store New Flag
	STR r0, [r1]

	;Change the light to the new flag state
	BL modified_illuminate_RGB_LED

	;end
	B endTimerHandler





advancedTimerHandler:
endTimerHandler:

	POP {r4-r12,lr}
	BX lr       	; Return


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
	;Change flag to #0
	MOV r2, #0
	str r2, [r1]
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

	B EndUartHandler

;;;;;;;;;;;;;;;
uart4State: ;We're in the Process of Getting Hex Code for Advanced


	;Is char (r0) Enter? (Ie are we done now?)
	CMP r0, #0xD
	BEQ state4enter		;if ENTER Handle End of State 4 (Getting RGB Code)
	B state4notenter	;If not, keep processing RGB Code



state4enter:	;We're done processing RGB Code input, time to test Advanced
	bl Advanced_RGB_LED	;Handles Changing State to #2 (from #4) and Interrupt Speed
	B EndUartHandler


state4notenter:		;Process Current Keypush as part of RGB Code
fuck
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
Advanced_RGB_LED:
	PUSH  {r4-r12, lr}	; Store register lr on stack
	;change timer interrupt speed to interrupt 100 times a second
	MOV r0, #1
	bl timer_interrupt_init

	;change state flag to 1 (we're testing Blinky)
	ldr r0, ptr_lightState
	MOV r1, #2
	STR r1, [r0]

	POP  {r4-r12, lr}	; Store register lr on stack
	MOV pc, lr


blinky:
	PUSH  {r4-r12, lr}	; Store register lr on stack
	;change timer interrupt speed to interrupt 2 times a second
	MOV r0, #0
	bl timer_interrupt_init

	;change state flag to 1 (we're testing Blinky)
	ldr r0, ptr_lightState
	MOV r1, #1
	STR r1, [r0]

	POP  {r4-r12, lr}	; Store register lr on stack
	MOV pc, lr

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


















	.end
