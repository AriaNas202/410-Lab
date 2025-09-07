	.data

prompt_gameStart:        	.string "Would You Like to Test This Function?", 0xA, 0xD
							.string "Hold down a Keypad Button and then Hit y to run test", 0xA, 0xD
							.string "Hit any other key to Quit", 0xA, 0xD, 0
gameStateFlag:				.word	0x0

prompt_gameEnd:				.string "Quit Test. Thanks for Testing!", 0xA, 0xD, 0




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.text

	.global keypad_init
	.global keypad_project
	.global UART0_Handler
	.global gpio_init ;Library
	.global uart_init ;Library
	.global uart_interrupt_init ;Library
	.global output_string ;Library
	.global output_character ;Library
	.global simple_read_character ;Library

ptr_prompt_gameStart:   .word prompt_gameStart
ptr_gameStateFlag:		.word gameStateFlag
ptr_prompt_gameEnd:		.word prompt_gameEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;this is first called by MAIN
;inits the keypad to be used on the Aliceboard IG
;RIGHT NOW Im just gonna use the init Functions I already Have
keypad_init:
	PUSH {lr}	; Store register lr on stack

	BL gpio_init ;init to Read/Write Keypad
    BL uart_init ;init the UART to recieve inputs (for the game printing)
	BL uart_interrupt_init ;init the UART to interrupt (so we can register a "game continue")

	POP {lr}
	MOV pc, lr



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
	BL find_keypad_push ;calls the function to actually do the Button Stuff
	;ORRR LIKE shit man idk, Should we do this with interrupts. I literally dont even know what Im doing here. Shit
	;OK so like it SEEMS like he wants a function to see which button is CURRENTLY being held down. Not like "poll until I hit a button and see if its interrupted?
	;idk itll be simplier to just READ the buttons not interrupt, so ill start with that first and then maybe ask (if time) to see what he wants
	;What about multiple button pushes? It says "key being pressed" not "keys" but idk, lets get 1 key working FIRST IG



	B GameInit


GameQuit:
	;Print Ending Message
	MOV r0, #0xC
	BL output_character 	;clear screen
	LDR r0, ptr_prompt_gameEnd
	BL output_string

	POP {r4-r5, lr}
	MOV pc, lr



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
find_keypad_push:
	PUSH {r4-r8, lr}
	;r4- Acc
	;r5- Port A
	;r6- Trash (for Register Info LDR)
	;r7- Port D
	;r8- Also Trash (For masking)


	;Init Values
	MOV r4, #16		;r4 is "accumulator" for current button pushed (init to Decimal 16, impossible value)
	MOV r5,#0x4000
	MOVT r5, #0x4000 	;r5 is Port A address
	MOV r7,#0x7000
	MOVT r7, #0x4000 	;r7 is Port D address

	;Check Column 1 (PA2)

	;Set Column 0
	LDR r6, [r5, #0x3FC]	;get Data in Port A
	ORR r6, #0x4	;Set 2nd bit as 1
	STR r6, [r5, #0x3FC]	;Set PA2 High
	NOP
	NOP
	NOP
	NOP
	NOP				;Wait for D Pins to Catch Up

	;Read Rows
	LDR r6, [r7, #0x3FC]	;r6 is Port D data (IT FAULTS WHEN I GET HERE!!!!)
	;pin 0
	AND r8, r6, #1  ;r8 is masked value
	CMP r8, #0
	IT NE 			;is r8 == 0? If NO Than Button Pushed!
	MOVNE r4, #0	;Move Button "0" into r4

	;pin 1
	;pin 2
	;pin 3




	;Set PA2 High (1)


	;Put Button Pushed in r0 (returned Value)
	MOV r0, r4


	POP {r4-r8, lr}
	MOV pc, lr

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




	.end
