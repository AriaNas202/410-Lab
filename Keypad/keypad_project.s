	.data

prompt_gameStart:        	.string "Would You Like to Test This Function?", 0xA, 0xD
							.string "Hold down a Keypad Button and then Hit y to run test", 0xA, 0xD
							.string "Hit any other key to Quit", 0xA, 0xD, 0
gameStateFlag:				.word	0x0

prompt_gameEnd:				.string "Quit Test. Thanks for Testing!", 0xA, 0xD, 0

prompt_noButtonPushed:		.string "You did not push a button! (You must push and hold the button before pressing y)", 0xA, 0xD, 0xA, 0xD, 0

prompt_buttonPush:			.string " was the button you pushed!", 0xA, 0xD, 0xA, 0xD, 0




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.text

	.global keypad_init
	.global keypad_project
	.global UART0_Handler
	.global find_keypad_push
	.global gpio_init ;Library
	.global uart_init ;Library
	.global uart_interrupt_init ;Library
	.global output_string ;Library
	.global output_character ;Library
	.global simple_read_character ;Library

ptr_prompt_gameStart:   		.word prompt_gameStart
ptr_gameStateFlag:				.word gameStateFlag
ptr_prompt_gameEnd:				.word prompt_gameEnd
ptr_prompt_noButtonPushed:		.word prompt_noButtonPushed
ptr_prompt_buttonPush:			.word prompt_buttonPush

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;this is first called by MAIN
;inits the keypad to be used on the Aliceboard IG
;RIGHT NOW Im just gonna use the init Functions I already Have
keypad_init:
	PUSH {lr}	; Store register lr on stack

	BL uart_init ;init the UART to recieve inputs (for the game printing)
	BL gpio_init ;init to Read/Write Keypad
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
	;clear game menu off the screen
	MOV r0, #0xC
	BL output_character


	BL find_keypad_push ;calls the function to actually do the Button Stuff




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
	PUSH {r4-r9, lr}
	;r4- Acc
	;r5- Port A
	;r6- Trash (for Register Info LDR)
	;r7- Port D
	;r8- Also Trash (For masking)
	;r9- Polling Bit


	;Init Values
	MOV r4, #16		;r4 is "accumulator" for current button pushed (init to Decimal 16, impossible value)
	MOV r5,#0x4000
	MOVT r5, #0x4000 	;r5 is Port A address
	MOV r7,#0x7000
	MOVT r7, #0x4000 	;r7 is Port D address
	MOV r9, #0


	;Set Column 0
	LDR r6, [r5, #0x3FC]	;get Data in Port A
	BIC r6, #0x3C			;set all other columns low
	ORR r6, #0x4			;Set 2nd bit as 1
	STR r6, [r5, #0x3FC]	;Set PA2 High
	ADD r0,r0, #0
	ADD r0,r0, #0
	ADD r0,r0, #0
	ADD r0,r0, #0
	ADD r0,r0, #0
	ADD r0,r0, #0
	ADD r0,r0, #0
	ADD r0,r0, #0
	ADD r0,r0, #0		;no ops for pins to catch up

	;Read Rows
	LDRB r6, [r7, #0x3FC]	;r6 is Port D data

	;pin 0
	AND r8, r6, #1  		;r8 is masked value
	CMP r8, #1
	ITTT EQ 				;is r8 == 1? If yes then Button Pushed!
	MOVEQ r4, #0			;Move Button into r4
	MOVEQ r0, #'0'
	BLEQ output_character	;Print to screen the button Pushed!

	;pin 1
	AND r8, r6, #2  		;r8 is masked value
	CMP r8, #2
	ITTT EQ 				;If equal then Button Pushed!
	MOVEQ r4, #4			;Move Button into r4
	MOVEQ r0, #'4'
	BLEQ output_character	;Print to screen the button Pushed!

	;pin 2
	AND r8, r6, #4  		;r8 is masked value
	CMP r8, #4
	ITTT EQ 				;If equal then Button Pushed!
	MOVEQ r4, #8			;Move Button into r4
	MOVEQ r0, #'8'
	BLEQ output_character	;Print to screen the button Pushed!

	;pin 3
	AND r8, r6, #8  		;r8 is masked value
	CMP r8, #8
	ITTT EQ 				;If equal then Button Pushed!
	MOVEQ r4, #12			;Move Button into r4
	MOVEQ r0, #'1'
	BLEQ output_character	;Print to screen the button Pushed!
	CMP r8, #8
	ITT EQ
	MOVEQ r0, #'2'
	BLEQ output_character	;Print to screen the button Pushed!


	;Set Column 1
	LDR r6, [r5, #0x3FC]	;get Data in Port A
	BIC r6, #0x3C			;set all other columns low
	ORR r6, #0x8			;Set 3ed bit as 1
	STR r6, [r5, #0x3FC]	;Set PA3 High
	ADD r0,r0, #0
	ADD r0,r0, #0
	ADD r0,r0, #0
	ADD r0,r0, #0
	ADD r0,r0, #0
	ADD r0,r0, #0
	ADD r0,r0, #0
	ADD r0,r0, #0
	ADD r0,r0, #0		;no ops for pins to catch up

	;Read Rows
	LDRB r6, [r7, #0x3FC]	;r6 is Port D data

	;pin 0
	AND r8, r6, #1  		;r8 is masked value
	CMP r8, #1
	ITTT EQ 				;is r8 == 1? If yes then Button Pushed!
	MOVEQ r4, #1			;Move Button into r4
	MOVEQ r0, #'1'
	BLEQ output_character	;Print to screen the button Pushed!

	;pin 1
	AND r8, r6, #2  		;r8 is masked value
	CMP r8, #2
	ITTT EQ 				;If equal then Button Pushed!
	MOVEQ r4, #5			;Move Button into r4
	MOVEQ r0, #'5'
	BLEQ output_character	;Print to screen the button Pushed!

	;pin 2
	AND r8, r6, #4  		;r8 is masked value
	CMP r8, #4
	ITTT EQ 				;If equal then Button Pushed!
	MOVEQ r4, #9			;Move Button into r4
	MOVEQ r0, #'9'
	BLEQ output_character	;Print to screen the button Pushed!

	;pin 3
	AND r8, r6, #8  		;r8 is masked value
	CMP r8, #8
	ITTT EQ 				;If equal then Button Pushed!
	MOVEQ r4, #13			;Move Button into r4
	MOVEQ r0, #'1'
	BLEQ output_character	;Print to screen the button Pushed!
	CMP r8, #8
	ITT EQ
	MOVEQ r0, #'3'
	BLEQ output_character	;Print to screen the button Pushed!


	;Set Column 2
	LDR r6, [r5, #0x3FC]	;get Data in Port A
	BIC r6, #0x3C			;set all other columns low
	ORR r6, #0x10			;Set 4th bit as 1
	STR r6, [r5, #0x3FC]	;Set PA4 High
	ADD r0,r0, #0
	ADD r0,r0, #0
	ADD r0,r0, #0
	ADD r0,r0, #0
	ADD r0,r0, #0
	ADD r0,r0, #0
	ADD r0,r0, #0
	ADD r0,r0, #0
	ADD r0,r0, #0		;no ops for pins to catch up

	;Read Rows
	LDRB r6, [r7, #0x3FC]	;r6 is Port D data

	;pin 0
	AND r8, r6, #1  		;r8 is masked value
	CMP r8, #1
	ITTT EQ 				;is r8 == 1? If yes then Button Pushed!
	MOVEQ r4, #2			;Move Button into r4
	MOVEQ r0, #'2'
	BLEQ output_character	;Print to screen the button Pushed!

	;pin 1
	AND r8, r6, #2  		;r8 is masked value
	CMP r8, #2
	ITTT EQ 				;If equal then Button Pushed!
	MOVEQ r4, #6			;Move Button into r4
	MOVEQ r0, #'6'
	BLEQ output_character	;Print to screen the button Pushed!

	;pin 2
	AND r8, r6, #4  		;r8 is masked value
	CMP r8, #4
	ITTT EQ 				;If equal then Button Pushed!
	MOVEQ r4, #10			;Move Button into r4
	MOVEQ r0, #'1'
	BLEQ output_character	;Print to screen the button Pushed!
	ITT EQ
	MOVEQ r0, #'0'
	BLEQ output_character	;Print to screen the button Pushed!

	;pin 3
	AND r8, r6, #8  		;r8 is masked value
	CMP r8, #8
	ITTT EQ 				;If equal then Button Pushed!
	MOVEQ r4, #14			;Move Button into r4
	MOVEQ r0, #'1'
	BLEQ output_character	;Print to screen the button Pushed!
	CMP r8, #8
	ITT EQ
	MOVEQ r0, #'4'
	BLEQ output_character	;Print to screen the button Pushed!


	;Set Column 3
	LDR r6, [r5, #0x3FC]	;get Data in Port A
	BIC r6, #0x3C			;set all other columns low
	ORR r6, #0x20			;Set 5th bit as 1
	STR r6, [r5, #0x3FC]	;Set PA5 High
	ADD r0,r0, #0
	ADD r0,r0, #0
	ADD r0,r0, #0
	ADD r0,r0, #0
	ADD r0,r0, #0
	ADD r0,r0, #0
	ADD r0,r0, #0
	ADD r0,r0, #0
	ADD r0,r0, #0		;no ops for pins to catch up

	;Read Rows
	LDRB r6, [r7, #0x3FC]	;r6 is Port D data

	;pin 0
	AND r8, r6, #1  		;r8 is masked value
	CMP r8, #1
	ITTT EQ 				;is r8 == 1? If yes then Button Pushed!
	MOVEQ r4, #3			;Move Button into r4
	MOVEQ r0, #'3'
	BLEQ output_character	;Print to screen the button Pushed!

	;pin 1
	AND r8, r6, #2  		;r8 is masked value
	CMP r8, #2
	ITTT EQ 				;If equal then Button Pushed!
	MOVEQ r4, #7			;Move Button into r4
	MOVEQ r0, #'7'
	BLEQ output_character	;Print to screen the button Pushed!

	;pin 2
	AND r8, r6, #4  		;r8 is masked value
	CMP r8, #4
	ITTT EQ 				;If equal then Button Pushed!
	MOVEQ r4, #11			;Move Button into r4
	MOVEQ r0, #'1'
	BLEQ output_character	;Print to screen the button Pushed!
	ITT EQ
	MOVEQ r0, #'1'
	BLEQ output_character	;Print to screen the button Pushed!

	;pin 3
	AND r8, r6, #8  		;r8 is masked value
	CMP r8, #8
	ITTT EQ 				;If equal then Button Pushed!
	MOVEQ r4, #15			;Move Button into r4
	MOVEQ r0, #'1'
	BLEQ output_character	;Print to screen the button Pushed!
	CMP r8, #8
	ITT EQ
	MOVEQ r0, #'5'
	BLEQ output_character	;Print to screen the button Pushed!


	;Print out Final Message
	CMP r4, #16	;No button was pushed message
	ITT EQ
	LDREQ r0, ptr_prompt_noButtonPushed
	BLEQ output_string
	CMP r4, #16	;No button was pushed message
	ITT NE
	LDRNE r0, ptr_prompt_buttonPush
	BLNE output_string

	;Put Button Pushed in r0 (returned Value)
	MOV r0, r4





	POP {r4-r9, lr}
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
