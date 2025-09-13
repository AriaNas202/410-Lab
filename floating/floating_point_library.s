




 .text
 	.global gpio_init
	.global uart_init
    .global uart_interrupt_init
	.global output_string
	.global output_character
    .global simple_read_character
    .global modified_int2string



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

gpio_init:
	PUSH {r4-r12,lr} ; Spill registers to stack

;INIT for keypad

    ;(1) SETUP Enable Clock (Port A, Pins 5-2) (Port D, Pins 3-0)
    MOV r1, #0xE608
    MOVT r1, #0x4000
    ADD r1, #0xF0000      ;put clock register in r1
    LDR r2, [r1]        ;loads current clock info into r2
    ORR r2, r2, #0x1       ;Set 0th bit to 1 (Port A)
    ORR r2, r2, #0x8       ;Set 3ed bit to 1 (Port D)
    STR r2, [r1]        ;store new clock with Port A/D enabled

    ;CHECK to see if clock is enabled (PRGPIO)
    ;Check A Port
CheckAClock:
	MOV r0, #0xE000
	MOVT r0, #0x400F
	LDR r1, [r0, #0xA08]	;Get PRGPIO Reg data in r1
	AND r1, r1, #1			;mask 0th bit for Port A
	CMP r1, #0				;if r1==0, then Port is NOT ready
	BEQ CheckAClock			;if r1==0, then we keep looping

;Check D Port
CheckDClock:
	MOV r0, #0xE000
	MOVT r0, #0x400F
	LDR r1, [r0, #0xA08]	;Get PRGPIO Reg data in r1
	AND r1, r1, #0x8		;mask 3ed bit for Port D
	CMP r1, #0				;if r1==0, then Port is NOT ready
	BEQ CheckDClock			;if r1==0, then we keep looping



    ;Port A, Pin 5,4,3,2
    ;Enable Direction for Pins (offset 0x400)
    MOV r1, #0x4000
    MOVT r1, #0x4000        ;Move base address for Port A in r1
    LDR r2, [r1, #0x400]    ;load pin direction register into r2
    ORR r2, r2, #0x3C      	;sets Pin 2-5 bit to Output (WRITING TO THOSE PINS)
    STR r2, [r1, #0x400]    ;stores the masked value back in directional register

    ;Set as Digital
    LDR r2, [r1, #0x51C]    ;Loads Digital Mode Register into r2
    ORR r2, r2, #0x3C        ;sets Pin 2,3,4,5 Bit with Mask to 1 (Enables Digital Mode)
    STR r2, [r1, #0x51C]    ;stores masked register back

    ;Port D, Pin 0,1,2,3
    ;Enable Direction for Pins (offset 0x400)
    MOV r1, #0x7000
    MOVT r1, #0x4000        ;Move base address for Port D in r1
    LDR r2, [r1, #0x400]    ;load pin direction register into r2
    BIC r2, r2, #0xF        ;sets Pin 0,1,2,3 bit to input (READING THOSE PINS)
    STR r2, [r1, #0x400]    ;stores the masked value back in directional register

    ;Set as Digital
    LDR r2, [r1, #0x51C]    ;Loads Digital Mode Register into r2
    ORR r2, r2, #0xF        ;sets Pin 0,1,2,3 Bit with Mask to 1 (Enables Digital Mode)
    STR r2, [r1, #0x51C]    ;stores masked register back



    ;do we need Pull Up Register? I really dont think So (it was for Tiva Buttons, not Alice) (Anthony said it doesnt! YAY!)


	POP {r4-r12,lr}   ; Restore registers from stack
	MOV pc, lr

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
    STR r1, [r4] ;(THIS PART BREAKS THE CODE, HUH? This disables Port D, Omg, I cannot believe I found it, im so tired)

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
modified_int2string:
    PUSH {r4-r12,lr}        ; Store any registers in the range of r4 through r12
                            ; that are used in your routine. Include lr if this
                            ; routine calls another routine.


	;Modifications for CSE 479
	;Commas are gone
	;returns base address of end of string in r0
	;(rn we assume no negative numbers, but i MAYYYYY fix that either here or in float2string)

    ;Arguments
    ;r0- base address to store string	*
    ;r1- int to convert 				*
    ;r2- will become current digit argument
    ;r3- comma counter (init to 0)
    ;r4- comma address (has comma hex value stored in it)
    ;r5- has 10 stored for mod operations
    ;r6- trash
    ;;;;;;;Converts all Digits (as ints) in stack to a string
    ;MOV r3, #0       ;init comma counter to 0
    ;MOV r4, #','     ;init comma register to ','
    MOV r5, #10  ;stores 10





    ;;;;;;;;Push a terminator so stack knows when to stop
    MOV r2, #0xFF   ;using 0xFF as stack terminator
    PUSH {r2}       ;push terminator to stack



    ;;;;;;;;Handle Base Case 0 (if number were converting is 0 originally)
    CMP r1, #0              ;Is originally in == 0?
    BNE ConvertToDigits     ;If out int isnt originally 0 we need to convert it to digits, so branch

    MOV r2, r1              ;Moves r1 (0 int) into r2 so CovertToString works
    PUSH {r2}               ;Pushes r2 (0 int) to stack
    B ConvertToString       ;Branches to covert 0 into a string



    ;;;;;;;;Converts all digits to stack until r1 (original int) is 0
ConvertToDigits:

    ;Check if r1 is 0 yet
    CMP r1, #0              ;Is r1 0 yet?
    BEQ ConvertToString     ;If r1 is 0 then its time to convert into a string

    ;Modulo by 10 (To get rightmost digit)
    UDIV r2,r1, r5          ;r2=r1/10
    MUL r2, r2, r5         ; r2=r2*10
    SUB r2, r1, r2          ; r2=r1-r2 (this should store rightmost digit in r2)

    ;CMP r3, #3 ;compare comma counter to 3
   ; BNE NoComma1            ;compare comma counter to 3
    ;MOV r6, r2              ;if comma counter isnt 3, we can skip adding a comma
   ; MOV r2, r4              ;temporarily store digit in r2 into r6
   ; PUSH {r2}               ;store ',' in r2
   ; MOV r2, r6              ;restore digit in r2


;NoComma1:
    PUSH {r2}               ;push current digit (as an int) to stack
    ;ADD r3,r3,#1 ;increment comma counter
    UDIV r1, r1, r5        ;move the whole int right by 1 digit (ex. 123 -> 12)
    B ConvertToDigits       ;branch back to loop to continure to convert r1 until its 0




;;;;;
ConvertToString:

    POP {r2}                ;get digit to convert into string


    CMP r2, #0xFF           ;Did we reach the stack terminator yet?
    BEQ EndInt2Str          ;If weve hit the stack terminator, were at the EndInt2Str

    ;CMP r2, r4
    ;BNE NoComma2

    ;STRB r4, [r0]            ;add a comma (which is in r4) at memory address in r0


    ;ADD r0, r0, #1           ;increment address for next char
    ;POP {r2}


;NoComma2:
    ADD r2,r2,#0x30         ;Turn r2 int into ascii
    STRB r2, [r0]           ;Stores current char (r2) into r0 address
    ADD r0,r0,#1            ;Increment address for next char
    ;ADD r3, r3, #1          ;Increment comma counter by 1
    B ConvertToString


    ;;;;;;;
EndInt2Str:

    MOV r2,#0               ;Stores null terminator in r2
    STRB r2, [r0]           ;Stores null terminator in memory

    ;i BELIEVE that r0 is being returned WITH the null terminator already in r0, but I will test this to be sure!



    POP {r4-r12,lr}         ; Restore registers all registers preserved in the
                            ; PUSH at the top of this routine from the stack.
    mov pc, lr


















.end
