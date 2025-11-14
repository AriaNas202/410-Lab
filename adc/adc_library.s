




 .text
 	.global illuminate_LEDs
 	.global alice_LED_gpio_init
 	.global timer_interrupt_init
 	.global rgb_gpio_init
	.global uart_init
    .global uart_interrupt_init
	.global output_string
	.global output_character
    .global simple_read_character
    .global modified_int2string
    .global modified_illuminate_RGB_LED

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
illuminate_LEDs:


    PUSH {r4-r12,lr} ; Spill registers to stack


    ;r0 bit pattern

    ;r1 - address of port B
    ;r2- data reg



    MOV r1, #0x5000
    MOVT r1, #0x4000    ;Move base address for Port B in r1

    ;Get Register which controls the light
    LDRb r2, [r1, #0x3FC]    ;Puts the data from reg into r2



	MOV r7, #0xF
	BIC r2, r2, r7

    ORR r2,r2,r0    ;store bits into data reg

    ;store the updated data reg BACK
    STRb r2, [r1, #0x3FC]    ;Puts the data BACK with Appropriate Lights



    POP {r4-r12,lr}   ; Restore registers from stack
    MOV pc, lr


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alice_LED_gpio_init:
	PUSH {r4-r12, lr}

    ;INIT for LEDs ALICE (Port B)

    ;SETUP Enable Clock (Port B, 1st bit)
    MOV r1, #0xE608
    MOVT r1, #0x4000
    ADD r1, #0xF0000		;Get effective address of clock
    LDR r2, [r1]        	;Get current clock info (r2)
    ORR r2, r2, #0x02   	;Ors the clock value with mask to set 1st bit to 1
    STR r2, [r1]        	;store new clock with Port B enabled

    ;Port B, Pins 0,1,2,3 ;!!!!!!
    ;Enable Direction for Pins (offset 0x400)
    MOV r1, #0x5000
    MOVT r1, #0x4000    	;Move base address for Port B in r1
    LDR r2, [r1, #0x400]    ;load pin direction register into r2
    ORR r2,r2, #0xF         ;sets 0,1,2,3 to 1 (output)
    STR r2, [r1, #0x400]    ;stores the masked value back in directional register

    ;Set as Digital
    LDR r2, [r1, #0x51C]    ;Loads Digital Mode Register into r2
    ORR r2, r2, #0x0F      	;sets 1st  Bit with Mask to 1 (Enables Digital Mode)
    STR r2, [r1, #0x51C]    ;stores masked register back





	POP {r4-r12, lr}
	MOV pc, lr



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
timer_interrupt_init:
	PUSH {r4-r12, lr}

    ;Connect Clock to timer
    MOV r0, #0xE000
    MOVT r0, #0x400F
    LDR r1, [r0, #0x604]

    ORR r1, r1, #0x1

    STR r1, [r0, #0x604]

    ;Disable timer
    MOV r0, #0x0000
    MOVT r0, #0x4003

    LDR r1, [r0, #0xC]
    BIC r1, r1, #0x1

    STR r1, [r0, #0xC]

    ;Put timer in 32 bit mode
    MOV r0, #0x0000
    MOVT r0, #0x4003

    LDR r1, [r0]

    BIC r1, r1, #0x7

    STR r1, [r0]

    ;Put timer in periodic mode
    MOV r0, #0x0000
    MOVT r0, #0x4003

    LDR r1, [r0, #0x4]
    BIC r1, r1, #0x1
    ORR r1, r1, #0x2

    STR r1, [r0, #0x4]

    ;Set up interval period
    MOV r0, #0x0000
    MOVT r0, #0x4003

    LDR r1, [r0, #0x028]

			;How many clicks should we go before we interrupt?
			; 16 MHz clock (16 million clock cycles/second)
			;FOR NOW!!!!!! Im going to do every half second to test (will be MUCH faster for the real thing)
    ;MOV r1, #0x1200
    ;MOVT r1, #0x7A
    mov r1, #0xF00		;making this just a REALLY fast value to see what works (either 0xF00 to 0xFFF is good)


	STR r1, [r0, #0x028]

    ;Enable timer to interrupt processor
	MOV r0, #0x0000
    MOVT r0, #0x4003

    LDR r1, [r0, #0x018]

    ORR r1, r1, #0x01

    STR r1, [r0, #0x018]

    ;Configure processer to allow interrupts
    MOV r0, #0xE000
    MOVT r0, #0xE000

    LDR r1, [r0, #0x100]

    ORR r1, r1, #0x80000

    STR r1, [r0, #0x100]

	;Enable timer
	MOV r0, #0x0000
    MOVT r0, #0x4003

    LDR r1, [r0, #0xC]

    ORR r1, r1, #0x1

    STR r1, [r0, #0xC]

	POP {r4-r12,lr}   		;Restore registers from stack
	MOV pc, lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
rgb_gpio_init:
	PUSH {r4-r12,lr} ; Spill registers to stack

	;Init for Tiva RGB LED (Port F)

    ;SETUP Enable Clock (Port F, 5th bit)
    MOV r1, #0xE608
    MOVT r1, #0x4000      ;put clock register in r1
    ADD r1, #0xF0000
    LDR r2, [r1]        ;loads current clock info into r2
    ORR r2, r2, #0x20       ;Ors the clock value with mask to set 5th bit to 1
    STR r2, [r1]        ;store new clock with Port F enabled


    ;Port F, Pin 1,2,3
    ;Enable Direction for Pins (offset 0x400)
    MOV r1, #0x5000
    MOVT r1, #0x4002        ;Move base address for Port F in r1
    LDR r2, [r1, #0x400]    ;load pin direction register into r2

    ORR r2,r2, #0xE 		;sets 1,2,3 bit to 1 (output)
    STR r2, [r1, #0x400]    ;stores the masked value back in directional register

    ;Set as Digital
    LDR r2, [r1, #0x51C]    ;Loads Digital Mode Register into r2
    ORR r2,r2, #0xE 		;set 1,2,3 bit to 1 (Enables Digital Mode)
    STR r2, [r1, #0x51C]    ;stores masked register back


	POP {r4-r12,lr}   		;Restore registers from stack
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







;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;modified to NOT include purple, yellow, white; only RGB and OFF
modified_illuminate_RGB_LED:
	PUSH {r4-r12,lr} ; Spill registers to stack


    ;ro- Color to be displayed

    ;r1- address bucket
    ;r2- regsiter data bucket
    ;r3 - trash

	;OFF r0==0x000
	;RED r0==0x001
	;GREEN r0==0x010
	;BLUE r0==0x100
	;(Any combos of the following also acceptable)




    ;Get Register which controls the light
    MOV r1, #0x5000
    MOVT r1, #0x4002 ; base address for GPIO Port F
    LDR r2, [r1, #0x3FC]    ;Puts the data from reg into r2

    ;Figure out what color the light is supposed to be
    CMP r0, #0x001
    BEQ Red     ;If red branch to red
    CMP r0, #0x010
    BEQ Green    ;If Green branch to Green
    CMP r0, #0x100
    BEQ Blue   ;If Blue branch to Blue
    CMP r0, #0x011
    BEQ RedGreen
    MOV r3, #0x101		;only doing this to fix illegal constant error
    CMP r0, r3
    BEQ RedBlue
    CMP r0, #0x110
    BEQ GreenBlue
    MOV r3, #0x111		;only doing this to fix illegal constant error
	CMP r0, r3
    BEQ RedGreenBlue
    B LEDOff     ;None of the other colors were right, so it must be OFF



    ;Set r2 to appropriate value for color
Red:
    BIC r2, r2, #0xE     	;clears all pins (1-3)
    ORR r2, r2, #0x2        ;set Pin 1
    B IllDone

Blue:
	BIC r2, r2, #0xE     	;clears all pins (1-3)
    ORR r2, r2, #0x4        ;set Pin 2
    B IllDone

Green:
	BIC r2, r2, #0xE     	;clears all pins (1-3)
    ORR r2, r2, #0x8    	;set Pin 3
    B IllDone

RedGreen:
	BIC r2, r2, #0xE     	;clears all pins (1-3)
    ORR r2, r2, #0x2        ;set Pin 1
    ORR r2, r2, #0x8    	;set Pin 3
    B IllDone

RedBlue:
	BIC r2, r2, #0xE     	;clears all pins (1-3)
    ORR r2, r2, #0x2        ;set Pin 1
    ORR r2, r2, #0x4        ;set Pin 2
    B IllDone

GreenBlue:
	BIC r2, r2, #0xE     	;clears all pins (1-3)
    ORR r2, r2, #0x8    	;set Pin 3
    ORR r2, r2, #0x4        ;set Pin 2
    B IllDone

RedGreenBlue:
	BIC r2, r2, #0xE     	;clears all pins (1-3)
    ORR r2, r2, #0x8    	;set Pin 3
    ORR r2, r2, #0x4        ;set Pin 2
    ORR r2, r2, #0x2        ;set Pin 1
    B IllDone

LEDOff:
    BIC r2, r2, #0xE        ;set Pin 1 and 2 and 3
    B IllDone

IllDone:
    STR r2, [r1, #0x3FC]    ;Puts the data BACK with Appropriate color


	POP {r4-r12,lr}   ; Restore registers from stack
	MOV pc, lr


















.end
