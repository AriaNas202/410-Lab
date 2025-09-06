 .text
	.global uart_init
    .global uart_interrupt_init
	.global output_string
	.global output_character
    .global simple_read_character






;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
uart_init:
	PUSH {r4-r12,lr} ; Spill registers to stack


    ; Provide clock to UART0
    MOV r4, #0xE618
    MOVT r4, #0x400F
    MOV r1, #1
    STR r1, [r4]

    ; Enable clock to PortA
    MOV r4, #0xE608
    MOVT r4, #0x400F
    MOV r1, #1
    STR r1, [r4]

    ; Disable UART0 Control
    MOV r4, #0xC030
    MOVT r4, #0x4000
    MOV r1, #0
    STR r1, [r4]

    ; Set UART0_IBRD_R for 115,200 baud
    MOV r4, #0xC024
    MOVT r4, #0x4000
    MOV r1, #8
    STR r1, [r4]

    ; Set UART0_FBRD_R for 115,200 baud
    MOV r4, #0xC028
    MOVT r4, #0x4000
    MOV r1, #44
    STR r1, [r4]

    ; Use System Clock
    MOV r4, #0xCFC8
    MOVT r4, #0x4000
    MOV r1, #0
    STR r1, [r4]

    ; Use 8-bit word length, 1 stop bit, no parity
    MOV r4, #0xC02C
    MOVT r4, #0x4000
    MOV r1, #0x60
    STR r1, [r4]

    ; Enable UART0 Control
    MOV r4, #0xC030
    MOVT r4, #0x4000
    MOV r1, #0x301
    STR r1, [r4]

    ; Make PA0 and PA1 as Digital Ports
    MOV r4, #0x451C
    MOVT r4, #0x4000  ;r4 - address
    LDR r0, [r4] ;r0- address value
    ;LDR r1, [r0]
    ORR r1, r0, #0x03 ;masked value
    STR r1, [r4]



    ; Change PA0,PA1 to Use an Alternate Function
    MOV r4, #0x4420
    MOVT r4, #0x4000
    LDR r0, [r4] ;r0- address value
    ;LDR r1, [r0]
    ORR r1, r0, #0x03 ;masked value
    STR r1, [r4]

    ; Configure PA0 and PA1 for UART
    MOV r4, #0x452C
    MOVT r4, #0x4000
    LDR r0, [r4] ;r0- address value
    ;LDR r1, [r0]
    ORR r1, r0, #0x11 ;masked value
    STR r1, [r4]

	POP {r4-r12,lr}   ; Restore registers from stack
	MOV pc, lr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
uart_interrupt_init:
	PUSH {r4-r12,lr}

	MOV r0, #0xC000
	MOVT r0, #0x4000
	LDR r1, [r0, #0x038]

	ORR r1,r1, #0x10	;set 5th bit

	STR r1, [r0, #0x038]


	;Config Processor to Allow UART Interrupts
	MOV r0, #0xE000
	MOVT r0, #0xE000
	LDR r1, [r0, #0x100]

	ORR r1,r1,#0x20

	STR r1, [r0, #0x100]

	POP {r4-r12,lr}
	MOV pc, lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
output_string:
	PUSH {r4-r12,lr} ; Spill registers to stack

;ARGUMENTS
    ;r0    - Original Base of string address
    ;      - Will turn into "current char" argument
    ;r4    - New base of String Address

    MOV r4, r0              ;copy base address into r4

GetChar:
    LDRB r0, [r4]           ;load current char into r0

    CMP r0, #0              ;compare current char to NULL (Is this the End of the String?)
    BEQ EndOutputString     ;If current char is NULL, were done printing the string, branch to end

    BL output_character     ;call function to print char in r0 as argument

    ADD r4,r4,#1            ;incrament base address to the next char

    B GetChar               ;Branch to handle the next char


EndOutputString:

	POP {r4-r12,lr}   ; Restore registers from stack
	MOV pc, lr



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
output_character:
	PUSH {r4-r12,lr} ; Spill registers to stack


        MOV r1, #0xC018
        MOVT r1, #0x4000    ;load flag reg address in r1
        MOV r3, #0x20       ;load mask 5th bit in r3

Polling:
        LDRB r2, [r1]       ;load flag into r2
        AND r2,r2,r3        ;mask r2 to the 5th bit

        CMP r2, #0          ;does the mask flag == 0?
        BNE Polling         ;If r2!=0 (r2==1) then we keep polling until we get 1

        MOV r1, #0xC000
        MOVT r1, #0x4000    ;Load data address into r1

        STRB r0, [r1]       ;store argument in r0 into data register at r1

	POP {r4-r12,lr}   ; Restore registers from stack
	MOV pc, lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
simple_read_character:
	PUSH {r4-r12,lr} ; Spill registers to stack

    MOV r4, #0xC000     ;UART base address
    MOVT r4, #0x4000
    LDRB r5, [r4, #0x18] ;Load from memory
    LDRB r0, [r4]       ;Store in r0

	POP {r4-r12,lr}   ; Restore registers from stack

	MOV pc, lr	; Return


.end
