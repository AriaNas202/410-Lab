	.data

	.global floatString1
	.global calcState


floatString1:        	.string "67.6891", 0
calcState:				.word 0x0







;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.text

	.global pwmTimer
	.global Timer_Handler
	;.global gpio_init ;Library
	;.global uart_init ;Library
	;.global uart_interrupt_init ;Library
	;.global output_string ;Library
	;.global output_character ;Library
	;.global simple_read_character ;Library
    ;.global modified_int2string ;Library
    ;.global string2int ;Library



ptr_floatString1:				.word floatString1
ptr_calcState:					.word calcState


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This is the second function to be called by MAIN
;actually does the little game or whatever
;this should ultimately be the overall "Game" printer which controls replay
pwmTimer:
	PUSH {r4-r12, lr}	; Store register lr on stack

	;Init the UART so we can print to Putty
	;BL uart_init
	;BL uart_interrupt_init

infinLoopTemp:
	B infinLoopTemp





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



	POP {r4-r12,lr}
	BX lr       	; Return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;






	.end
