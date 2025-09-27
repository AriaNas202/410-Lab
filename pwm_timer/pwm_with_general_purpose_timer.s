	.data

	.global mainMenu
	.global blinkyMenu
	.global advancedMenu
	.global lightState
	.global blinkAlternateFlag


mainMenu:        	.string "What would you like to test?", 0xA, 0xD
					.string "1-Blinky", 0xA, 0xD
					.string "2-Advanced",0xA, 0xD
					.string "Press Any Other Button to Quit", 0xA, 0xD, 0
blinkyMenu:			.string "You are currently testing Blinky", 0xA, 0xD
					.string "Press any Key to Go Back to Main Menu", 0
advancedMenu:		.string "This is a temp advanced menu, eventually we will need to get a user inputted color", 0
lightState:			.word 0x0
blinkAlternateFlag:	.word 0x0







;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.text

	.global pwmTimer
	.global Timer_Handler
	.global UART0_Handler
	.global Advanced_RGB_LED
	.global blinky
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
	CMP r4, #2
	BEQ advancedMain
	CMP r4, #3
	BEQ quitMain
	B mainMenuPoll

blinkyMain:
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


advancedMain:
advancedPoll:
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
    BEQ uart2State	;We're Testing Advanced
    B EndUartHandler
;;;;;;;;;;;;;;;
uart0State:
	;check input to see what we do
	CMP r0, #0x31 ;user hit 1
	BEQ state01
	CMP r0, #0x32 ;user hit 2
	BEQ state02
	B state0else

state01:	;test Blinky
	BL blinky
	B EndUartHandler
state02:	;test Advanced
	BL Advanced_RGB_LED
	B EndUartHandler
state0else:	;Quit
	;change flag to #3
	MOV r2, #3
	str r2, [r1]
	B EndUartHandler




;;;;;;;;;;;;;;;
uart1State:
	;Change flag to #0
	MOV r2, #0
	str r2, [r1]
	B EndUartHandler


;;;;;;;;;;;;;;;
uart2State:
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




















	.end
