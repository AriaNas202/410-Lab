	.data

prompt_gameStart:        	.string "Would You Like to Test This Function?", 0xA, 0xD
							.string "Hit y to test again, Hit any other key to Quit", 0xA, 0xD, 0
gameStateFlag:				.word	0x0





	.text

	.global keypad_init
	.global keypad_project
	.global UART0_Handler
	.global uart_init ;Library
	.global uart_interrupt_init ;Library
	.global output_string ;Library
	.global output_character ;Library
	.global simple_read_character ;Library

ptr_prompt_gameStart:   .word prompt_gameStart
ptr_gameStateFlag:		.word gameStateFlag


;this is first called by MAIN
;inits the keypad to be used on the Aliceboard IG
;RIGHT NOW Im just gonna use the init Functions I already Have
keypad_init:
	PUSH {lr}	; Store register lr on stack


    BL uart_init ;init the UART to recieve inputs (for the game printing)
	BL uart_interrupt_init ;init the UART to interrupt (so we can register a "game continue")

	POP {lr}
	MOV pc, lr


;This is the second function to be called by MAIN
;actually does the little game or whatever
;this should ultimately be the overall "Game" printer which controls replay
keypad_project:
	PUSH {r4-r5, lr}	; Store register lr on stack

GameInit:
	;Prints Initial Game Start Screen
	ldr r0, ptr_prompt_gameStart
	bl output_string
	;make gamestate flag 0 (to indicate start of the test)
	MOV r5, #0
	LDR r4, ptr_gameStateFlag ;r4 has address of flag
	STR r5, [r4] ;stores 0 into address where flag is
GameContinuePolling:
	;get game state flag
	LDR r4, ptr_gameStateFlag ;r4 has address of flag
	LDR r4, [r4] ;r4 has content where address is
	CMP r4, #1 ;if game state flag is 1, then we test the funtion
	BEQ GameStart
	CMP r4, #2 ;if game state flag is 2 then we quit
	BEQ GameQuit
	B GameContinuePolling ;else keep polling


GameStart:
	;this is where I call the other Function, but not right now (thats a tomorrow deal)

	B GameInit


GameQuit:
	;this is where I will put an ending message

	POP {r4-r5, lr}
	MOV pc, lr


	;will write another function which actually deal with the button pushes


UART0_Handler:
	PUSH {r4-r12,lr} ; Spill registers to stack

	;Clear the interrupt
    MOV r2, #0xC000
    MOVT r2, #0x4000
    LDR r3, [r2, #0x044]
    ORR r3, #0x10
    STR r3, [r2, #0x044]

	;read the character
    BL simple_read_character ;character returned in r0

	;CHECK IF ITS Y OR NOT!!! CHANGE FLAG ACCORDINGLY
	CMP r0, #'y'
	BEQ SetPlayAgain
	B DontSetPlayAgain

SetPlayAgain: ;set flag to 1 (GO!)
	MOV r0, #1
	LDR r1, ptr_gameStateFlag
	STR r0, [r1]
	B EndUartHandler

DontSetPlayAgain: ;set flag to 2 (QUIT!)
	MOV r0, #2
	LDR r1, ptr_gameStateFlag
	STR r0, [r1]

EndUartHandler:
	POP {r4-r12,lr} ; Spill registers to stack
	BX lr       	; Return







	.end
