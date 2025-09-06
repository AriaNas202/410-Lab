	.data

prompt_gameStart:        	.string "Would You Like to Test This Function?", 0xA, 0xD
							.string "Hit Y to test again, Hit any other key to Quit", 0xA, 0xD, 0






	.text

	.global keypad_init
	.global keypad_project
	.global uart_init ;Library
	.global output_string ;Library
	.global output_character ;Library

ptr_prompt_gameStart:     .word prompt_gameStart


;this is first called by MAIN
;inits the keypad to be used on the Aliceboard IG
;RIGHT NOW Im just gonna use the init Functions I already Have
keypad_init:
	PUSH {lr}	; Store register lr on stack

    ;init the UART to recieve inputs (for the game printing)
    BL uart_init

	POP {lr}
	MOV pc, lr


;This is the second function to be called by MAIN
;actually does the little game or whatever
;this should ultimately be the overall "Game" printer which controls replay
keypad_project:
	PUSH {lr}	; Store register lr on stack

	;Setup Game Screen

	;prints BOARD
	ldr r0, ptr_prompt_gameStart
	bl output_string






	POP {lr}
	MOV pc, lr


	;will write another function which actually deal with the button pushes


	.end
