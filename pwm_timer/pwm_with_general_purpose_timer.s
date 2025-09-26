	.data

	.global mainMenu
	.global blinkyMenu
	.global advancedMenu
	.global lightState


mainMenu:        	.string "What would you like to test?", 0xA, 0xD
					.string "1-Blinky", 0xA, 0xD
					.string "2-Advanced",0xA, 0xD
					.string "Press Any Other Button to Quit", 0xA, 0xD, 0
blinkyMenu:			.string "You are currently testing Blinky", 0xA, 0xD
					.string "Press any Key to Go Back to Main Menu", 0
advancedMenu:		.string "This is a temp advanced menu, eventually we will need to get a user inputted color", 0
lightState:			.word 0x0







;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.text

	.global pwmTimer
	.global Timer_Handler
	.global UART0_Handler
	.global timer_interrupt_init ;Library
	.global gpio_init ;Library
	.global uart_init ;Library
	.global uart_interrupt_init ;Library
	.global output_string ;Library
	.global output_character ;Library
	.global simple_read_character ;Library
    .global modified_int2string ;Library
    .global string2int ;Library



ptr_mainMenu:				.word mainMenu
ptr_blinkyMenu:				.word blinkyMenu
ptr_advancedMenu:			.word advancedMenu
ptr_lightState:				.word lightState




blinky:
	PUSH  {r4-r12, lr}	; Store register lr on stack
	;change timer interrupt speed (not right now)

	;change state flag to 1 (we're testing Blinky)
	ldr r0, ptr_lightState
	MOV r1, #1
	STR r1, [r0]

	POP  {r4-r12, lr}	; Store register lr on stack
	MOV pc, lr
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
	bl timer_interrupt_init		;configures timer to interrupt

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
	;print blinky menu
	ldr r0, ptr_blinkyMenu
	bl output_string

blinkyPoll:
	B blinkyPoll	;normally we would try to exit this at a certain point but im putting infin loop here to test it


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

	;just using this to test uart handler
	LDR r0, ptr_lightState
	ldr r0, [r0]
	ADD r0, r0, #0x30
	BL output_character



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
    BEQ uart0State
    CMP r2, #1
    BEQ uart1State
    CMP r2, #2
    BEQ uart2State
    B EndUartHandler

uart0State:
	;check input to see what we do
	CMP r0, #0x31 ;user hit 1
	BEQ state01
	B state0else

state01:
	BL blinky
	B EndUartHandler

state02:
state0else:

uart1State:
uart2State:





EndUartHandler:


	;End
	POP {r4-r12,lr} ; Pop registers from stack
	BX lr       	; Return





	.end
