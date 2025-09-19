	.data

	.global floatString1
	.global floatfloat1
	.global mainMenu
	.global calcState
    .global calcSubState
    .global firstFloat
    .global secondFloat
    .global firstFloatString
    .global secondFloatString
    .global floatStringIndex
    .global rounding
    .global firstNumberMenu
    .global secondNumberMenu
    .global roundingMenu
    .global roundingString
    .global resultString

floatString1:        	.string "67.6891", 0
floatfloat1:			.float 67.6891

exampleFlag:				.word	0x0

mainMenu:				.string 0xA, 0xD, 0xA, 0xD, "WELCOME TO THE CALCULATOR!!!", 0xA, 0xD
						.string "1) Add", 0xA, 0xD
						.string "2) Sub", 0xA, 0xD
						.string "3) Mult", 0xA, 0xD
						.string "4) Div", 0xA, 0xD
						.string "5) Sqrt", 0xA, 0xD
						.string "6) Raise to Two", 0xA, 0xD
						.string "Hit Any other Key to Quit!", 0xA, 0xD, 0
firstNumberMenu:        .string "Please Insert First Float:", 0xA, 0xD, 0
secondNumberMenu:       .string "Please Insert Second Float:", 0xA, 0xD, 0
roundingMenu:           .string "How many decimal places to round to?", 0xA, 0xD, 0

calcState:				.word 0x0
calcSubState:           .word 0x0
firstFloat:             .float 0.0
secondFloat:            .float 0.0
firstFloatString:       .string "                                                               ",0x0
secondFloatString:      .string "                                                               ",0x0
roundingString:			.string "                                                               ",0x0
resultString:			.string "                                                               ",0x0
floatStringIndex:       .word 0x0
rounding:               .word 0x0









;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.text

	.global floating
	.global UART0_Handler
	.global string2float
	.global float2string
	.global floating_init
	.global floatTester ;temp WILL DELETE!!!!
	.global string2round
	.global gpio_init ;Library
	.global uart_init ;Library
	.global uart_interrupt_init ;Library
	.global output_string ;Library
	.global output_character ;Library
	.global simple_read_character ;Library
    .global modified_int2string ;Library
    .global string2int ;Library


ptr_exampleFlag:				.word exampleFlag
ptr_floatString1:				.word floatString1
ptr_floatfloat1:				.word floatfloat1
ptr_mainMenu:					.word mainMenu
ptr_calcState:					.word calcState
ptr_calcSubState:				.word calcSubState
ptr_firstFloat:                 .word firstFloat
ptr_secondFloat:                .word secondFloat
ptr_floatStringIndex:           .word floatStringIndex
ptr_rounding:                   .word rounding
ptr_firstNumberMenu:            .word firstNumberMenu
ptr_secondNumberMenu:           .word secondNumberMenu
ptr_roundingMenu:               .word roundingMenu
ptr_firstFloatString:			.word firstFloatString
ptr_secondFloatString:			.word secondFloatString
ptr_roundingString:				.word roundingString
ptr_resultString:				.word resultString

floatTester:
	PUSH {r4-r12,s16-s20, lr}	; Store register lr on stack
	LDR r0, ptr_floatString1
	MOV r1, #4
	BL string2round


	POP {r4-r12,s16-s20, lr}
	MOV pc, lr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

string2round:
	PUSH {r4-r12, lr}	; Store register lr on stack

	;GET ARGUMENTS MYSELF (it will always be pulling from the same place)

	;r1-# of decimals we're rounding to (int)
	LDR r0, ptr_roundingString
	BL string2int
	MOV r1, r0
	;r0-address of string
	LDR r0, ptr_resultString



decimalFinder:
	ldrb r2, [r0],#1		;get current char in r2
	CMP r2, #0x2E		;is the current char a "."
	BNE decimalFinder	;If NOT decimal then keep polling

	;Now we're right AFTER the decimal
	MOV r2, #1			;initialize ACC for how far in the string we've gone (r2-ACC; init 1)
processRounding:
	;are we at the appropriate decimal place?
	CMP r1, r2					;compare argument int (r1) with ACC (r2)
	BEQ doRoundingFunction		;We're at the appropriate decimal place! Go to do rounding!
	ADD r2, r2, #1				;increase ACC
	ADD r0, r0, #1				;increase Address

	;check if new spot is null
	LDRb r3, [r0]		;get current char
	CMP r3, #0			;IS current char null?
	ITTTT EQ
	MOVEQ r3, #0x30
	STRbEQ r3, [r0]		;if yes then we store "0" at the current address
	MOVEQ r3, #0
	STRbEQ r3, [r0, #1]		;store NULL at next address

	B processRounding

doRoundingFunction:
	;were on the LAST digit in accepted string
	;which way are we rounding? (less than 5, do nothing)
	LDRB r3, [r0, #1]		;get char AFTER current char (r3)
	CMP r3, #0x35
	BLT finishRounding	;branch if less than 5 (either 0-4 or NULL)

	;Increase the number
	LDRB r3, [r0]
	ADD r3,r3,#1	;increase current char by 1
	STRB r3, [r0]	;store updated char back

finishRounding:
	MOV r3, #0			;store NULL in next char over
	STRB r3, [r0,#1]






	POP {r4-r12, lr}
	MOV pc, lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This is the second function to be called by MAIN
;actually does the little game or whatever
;this should ultimately be the overall "Game" printer which controls replay
floating:
	PUSH {r4-r12,s16-s20, lr}	; Store register lr on stack

	;Init the UART so we can print to Putty
	BL uart_init
	BL uart_interrupt_init
	;Init the FPU
	BL floating_init ;Initialize the FPU for calulations

startCalc:
	;Set Calc State Flag to 0 (Waiting) (r4-address; r5-Flag Data)
	LDR r4, ptr_calcState
	MOV r5, #0
	STR r5, [r4]

    ;Set Calc SubState Flag to 0 (r6-address; r7-Flag Data)
    LDR r6, ptr_calcSubState
    MOV r7, #0
    STR r7, [r6]

	;Print Menu to Screen
	LDR r0, ptr_mainMenu
	BL output_string

	;Loop to Wait for response
calcPoll:
	LDR r5, [r4]	;get flag
	CMP r5, #0
	BEQ calcPoll	;Flag 0-Keep Polling
	CMP r5, #1
	BEQ adding		;Flag 1- Add
	CMP r5, #2
	BEQ subbing		;Flag 2- Sub
	CMP r5, #3
	BEQ multing		;Flag 3- Mult
	CMP r5, #4
	BEQ diving 		;Flag 4- Div
	CMP r5, #5
	BEQ sqrting		;Flag 5- Sqrt
	CMP r5, #6
	BEQ squaring	;Flag 6- Squaring

	B quitting		;Else Quit


adding:
    ;FIRST NUMBER GET!
    MOV r0, #0xC    ;Clear Screen
    BL output_character
    LDR r0, ptr_firstNumberMenu ;print Menu
    BL output_string
addingPoll1:
    LDR r7, [r6]    ;get substate?
    CMP r7, #2      ;see if we're done getting first number?
    BNE addingPoll1

    ;SECOND NUMBER GET!
    MOV r0, #0xC    ;Clear Screen
    BL output_character
    LDR r0, ptr_secondNumberMenu ;print Menu
    BL output_string
addingPoll2:
    LDR r7, [r6]    ;get substate?
    CMP r7, #3      ;see if we're done getting first number?
    BNE addingPoll2

    ;ROUNDING GET!
    MOV r0, #0xC    ;Clear Screen
    BL output_character
    LDR r0, ptr_roundingMenu ;print Menu
    BL output_string
addingPoll3:
    LDR r7, [r6]    ;get substate?
    CMP r7, #4      ;see if we're done getting first number?
    BNE addingPoll3

    ;Do Equation (WILL EVENTUALLY DO ROUNDING, BUT NOT RIGHT NOW!!!!)
    MOV r0, #0xC    ;Clear Screen
    BL output_character
    ;Get First Number
    LDR r0, ptr_firstFloatString	;First Float (r0-address
    BL string2float
    VMOV s16, r0						;Float 1 get (s16- float1)
    ;Get Second Number
    LDR r0, ptr_secondFloatString
    BL string2float
    VMOV s17, r0						;Float 2 get (s17-float2)
	;Do calculations
    vadd.f32 s18,s17,s16				;Do Calculation (s18-Floating Result)
    VMOV r0,s18						;Put result in r0 (argument)
    LDR r1, ptr_resultString		;Address to result string in r1 (argument)
    BL float2string					;Turns float into String

    ;Round
    bl string2round


    ;Print result
    LDR r0, ptr_resultString
    BL output_string



    B startCalc


subbing:
    ;FIRST NUMBER GET!
    MOV r0, #0xC    ;Clear Screen
    BL output_character
    LDR r0, ptr_firstNumberMenu ;print Menu
    BL output_string
subbingPoll1:
    LDR r7, [r6]    ;get substate?
    CMP r7, #2      ;see if we're done getting first number?
    BNE subbingPoll1

    ;SECOND NUMBER GET!
    MOV r0, #0xC    ;Clear Screen
    BL output_character
    LDR r0, ptr_secondNumberMenu ;print Menu
    BL output_string
subbingPoll2:
    LDR r7, [r6]    ;get substate?
    CMP r7, #3      ;see if we're done getting first number?
    BNE subbingPoll2

    ;ROUNDING GET!
    MOV r0, #0xC    ;Clear Screen
    BL output_character
    LDR r0, ptr_roundingMenu ;print Menu
    BL output_string
subbingPoll3:
    LDR r7, [r6]    ;get substate?
    CMP r7, #4      ;see if we're done getting first number?
    BNE subbingPoll3

    ;Do Equation (WILL EVENTUALLY DO ROUNDING, BUT NOT RIGHT NOW!!!!)
    MOV r0, #0xC    ;Clear Screen
    BL output_character
    ;Get First Number
    LDR r0, ptr_firstFloatString	;First Float (r0-address)
    BL string2float
    VMOV s16, r0						;Float 1 get (s16- float1)
    ;Get Second Number
    LDR r0, ptr_secondFloatString
    BL string2float
    VMOV s17, r0						;Float 2 get (s17-float2)
	;Do calculations
    vsub.f32 s18,s16,s17				;Do Calculation (s18-Floating Result)
    VMOV r0,s18						;Put result in r0 (argument)
    LDR r1, ptr_resultString		;Address to result string in r1 (argument)
    BL float2string					;Turns float into String

    ;Round
    bl string2round

    ;Print result
    LDR r0, ptr_resultString
    BL output_string



    B startCalc

multing:
    ;FIRST NUMBER GET!
    MOV r0, #0xC    ;Clear Screen
    BL output_character
    LDR r0, ptr_firstNumberMenu ;print Menu
    BL output_string
multPoll1:
    LDR r7, [r6]    ;get substate?
    CMP r7, #2      ;see if we're done getting first number?
    BNE multPoll1

    ;SECOND NUMBER GET!
    MOV r0, #0xC    ;Clear Screen
    BL output_character
    LDR r0, ptr_secondNumberMenu ;print Menu
    BL output_string
multPoll2:
    LDR r7, [r6]    ;get substate?
    CMP r7, #3      ;see if we're done getting first number?
    BNE multPoll2

    ;ROUNDING GET!
    MOV r0, #0xC    ;Clear Screen
    BL output_character
    LDR r0, ptr_roundingMenu ;print Menu
    BL output_string
multPoll3:
    LDR r7, [r6]    ;get substate?
    CMP r7, #4      ;see if we're done getting first number?
    BNE multPoll3

    ;Do Equation (WILL EVENTUALLY DO ROUNDING, BUT NOT RIGHT NOW!!!!)
    MOV r0, #0xC    ;Clear Screen
    BL output_character
    ;Get First Number
    LDR r0, ptr_firstFloatString	;First Float (r0-address)
    BL string2float
    VMOV s16, r0						;Float 1 get (s16- float1)
    ;Get Second Number
    LDR r0, ptr_secondFloatString
    BL string2float
    VMOV s17, r0						;Float 2 get (s17-float2)
	;Do calculations
    vmul.f32 s18,s16,s17				;Do Calculation (s18-Floating Result)
    VMOV r0,s18						;Put result in r0 (argument)
    LDR r1, ptr_resultString		;Address to result string in r1 (argument)
    BL float2string					;Turns float into String

    ;Round
    bl string2round

    ;Print result
    LDR r0, ptr_resultString
    BL output_string



    B startCalc

diving:
    ;FIRST NUMBER GET!
    MOV r0, #0xC    ;Clear Screen
    BL output_character
    LDR r0, ptr_firstNumberMenu ;print Menu
    BL output_string
divPoll1:
    LDR r7, [r6]    ;get substate?
    CMP r7, #2      ;see if we're done getting first number?
    BNE divPoll1

    ;SECOND NUMBER GET!
    MOV r0, #0xC    ;Clear Screen
    BL output_character
    LDR r0, ptr_secondNumberMenu ;print Menu
    BL output_string
divPoll2:
    LDR r7, [r6]    ;get substate?
    CMP r7, #3      ;see if we're done getting first number?
    BNE divPoll2

    ;ROUNDING GET!
    MOV r0, #0xC    ;Clear Screen
    BL output_character
    LDR r0, ptr_roundingMenu ;print Menu
    BL output_string
divPoll3:
    LDR r7, [r6]    ;get substate?
    CMP r7, #4      ;see if we're done getting first number?
    BNE divPoll3

    ;Do Equation (WILL EVENTUALLY DO ROUNDING, BUT NOT RIGHT NOW!!!!)
    MOV r0, #0xC    ;Clear Screen
    BL output_character
    ;Get First Number
    LDR r0, ptr_firstFloatString	;First Float (r0-address)
    BL string2float
    VMOV s16, r0						;Float 1 get (s16- float1)
    ;Get Second Number
    LDR r0, ptr_secondFloatString
    BL string2float
    VMOV s17, r0						;Float 2 get (s17-float2)
	;Do calculations
    vdiv.f32 s18,s16,s17				;Do Calculation (s18-Floating Result)
    VMOV r0,s18						;Put result in r0 (argument)
    LDR r1, ptr_resultString		;Address to result string in r1 (argument)
    BL float2string					;Turns float into String

    ;Round
    bl string2round

    ;Print result
    LDR r0, ptr_resultString
    BL output_string



    B startCalc

sqrting:
    ;FIRST NUMBER GET!
    MOV r0, #0xC    ;Clear Screen
    BL output_character
    LDR r0, ptr_firstNumberMenu ;print Menu
    BL output_string
sqrtPoll1:
    LDR r7, [r6]    ;get substate?
    CMP r7, #2      ;see if we're done getting first number?
    BNE sqrtPoll1

    ;ROUNDING GET!
    MOV r0, #0xC    ;Clear Screen
    BL output_character
    LDR r0, ptr_roundingMenu ;print Menu
    BL output_string
sqrtPoll2:
    LDR r7, [r6]    ;get substate?
    CMP r7, #3      ;see if we're done getting first number?
    BNE sqrtPoll2

    ;Do Equation (WILL EVENTUALLY DO ROUNDING, BUT NOT RIGHT NOW!!!!)
    MOV r0, #0xC    ;Clear Screen
    BL output_character
    ;Get First Number
    LDR r0, ptr_firstFloatString	;First Float (r0-address
    BL string2float
    VMOV s16, r0						;Float 1 get (s16- float1)
	;Do calculations
    vsqrt.f32 s18,s16				;Do Calculation (s18-Floating Result)
    VMOV r0,s18						;Put result in r0 (argument)
    LDR r1, ptr_resultString		;Address to result string in r1 (argument)
    BL float2string					;Turns float into String

    ;Round
    bl string2round

    ;Print result
    LDR r0, ptr_resultString
    BL output_string



    B startCalc

squaring:
    ;FIRST NUMBER GET!
    MOV r0, #0xC    ;Clear Screen
    BL output_character
    LDR r0, ptr_firstNumberMenu ;print Menu
    BL output_string
squarePoll1:
    LDR r7, [r6]    ;get substate?
    CMP r7, #2      ;see if we're done getting first number?
    BNE squarePoll1

    ;ROUNDING GET!
    MOV r0, #0xC    ;Clear Screen
    BL output_character
    LDR r0, ptr_roundingMenu ;print Menu
    BL output_string
squarePoll2:
    LDR r7, [r6]    ;get substate?
    CMP r7, #3      ;see if we're done getting first number?
    BNE squarePoll2

    ;Do Equation (WILL EVENTUALLY DO ROUNDING, BUT NOT RIGHT NOW!!!!)
    MOV r0, #0xC    ;Clear Screen
    BL output_character
    ;Get First Number
    LDR r0, ptr_firstFloatString	;First Float (r0-address
    BL string2float
    VMOV s16, r0						;Float 1 get (s16- float1)
	;Do calculations
    vmult.f32 s18,s16,s16				;Do Calculation (s18-Floating Result)
    VMOV r0,s18						;Put result in r0 (argument)
    LDR r1, ptr_resultString		;Address to result string in r1 (argument)
    BL float2string					;Turns float into String

    ;Round
    bl string2round

    ;Print result
    LDR r0, ptr_resultString
    BL output_string



    B startCalc


quitting:




	POP {r4-r12,s16-s20, lr}
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

    ;get Current Flag Data (r4-address; r5-Flag Data)
    LDR r4, ptr_calcState
    LDR r5, [r4]
    ;get Current SubFlag Data (r6-address; r7-SubFlag Data)
    LDR r6, ptr_calcSubState
    LDR r7, [r6]


    ;Which MAIN State are We currently In? (Main State)
    CMP r5, #0
    BEQ flagHandler0
    CMP r5, #1
    BEQ flagHandler1
    CMP r5, #2
    BEQ flagHandler2
    CMP r5, #3
    BEQ flagHandler3
    CMP r5, #4
    BEQ flagHandler4
    CMP r5, #5
    BEQ flagHandler5
    CMP r5, #6
    BEQ flagHandler6
    B EndUartHandler    ;Should Only Trigger if user is currently Quitting (FLag==7)

flagHandler0: ;Main Menu
    ;Process Input (r0)
    CMP r0, #0x31			;1 Hit, Flag Updates to 1
    ITT EQ
    MOVEQ r5, #1
    MOVEQ r7, #1
    CMP r0, #0x32			;2 Hit, Flag Updates to 2
    ITT EQ
    MOVEQ r5, #2
    MOVEQ r7, #1
    CMP r0, #0x33			;3 Hit, Flag Updates to 3
    ITT EQ
    MOVEQ r5, #3
    MOVEQ r7, #1
    CMP r0, #0x34			;4 Hit, Flag Updates to 4
    ITT EQ
    MOVEQ r5, #4
    MOVEQ r7, #1
    CMP r0, #0x35			;5 Hit, Flag Updates to 5
    ITT EQ
    MOVEQ r5, #5
    MOVEQ r7, #1
    CMP r0, #0x36			;6 Hit, Flag Updates to 6
    ITT EQ
    MOVEQ r5, #6
    MOVEQ r7, #1
    CMP r5, #0				;Else, Random Key Hit, Flag Updates to 7
    IT EQ					;Note We're comparing r5 to 0 here because, if we made it this far then we KNOW r5 started off as 0 (Main Menu)
    MOVEQ r5, #7    		;which means if the other operations didnt trigger, then r5 would still be 0, meaning "Else" we quit

    B EndUartHandler        ;Branch to End

flagHandler1: ;Addition
    ;Which SubString (1)
    CMP r7, #1 ;Dealing with First Float String
    BEQ fH11
    CMP r7, #2 ;Dealing with Second Float String
    BEQ fH12
    CMP r7, #3 ;Inputing Rounding Dec
    BEQ fH13
    B EndUartHandler
fH11:
    ;NEED TO COMPARE CURRENT CHAR TO ENTER
    CMP r0, #0xD    ;Is Enter the current char?
    ITTTT EQ
    LDREQ r8, ptr_firstFloatString          ;get first float string (r8-Address)
    LDREQ r9, ptr_floatStringIndex          ;get current index (r9-address, r10-data)
    LDREQ r10, [r9]
    ADDEQ r8, r8, r10                       ;do math to get where we have to store this first FLOAT char
    ITTT EQ
    MOVEQ r0, #0                            ;Move NULL into Current Char Hit
    STREQ r0, [r8]                          ;store Hit Button in address
    MOVEQ r7, #2                            ;Change to Subflag 2 (we're done with first number, going to second)
    ;STREQ r7, [r6]
    ITTT EQ
    MOVEQ r10, #0                           ;Clear index
    STREQ r10, [r9]
    BEQ EndUartHandler                      ;Branch to end




    LDR r8, ptr_firstFloatString                ;get first float string (r8-Address)
    LDR r9, ptr_floatStringIndex            ;get current index (r9-address, r10-data)
    LDR r10, [r9]
    ADD r8, r8, r10                          ;do math to get where we have to store this first FLOAT char
    STR r0, [r8]                            ;store Hit Button in address
    BL output_character                     ;Print the Current Character (feedback Input)
    ADD r10, r10, #1                        ;Add 1 to current index
    STR r10, [r9]                           ;Store current index back
    B EndUartHandler

fH12:
    ;NEED TO COMPARE CURRENT CHAR TO ENTER
    CMP r0, #0xD    ;Is Enter the current char?
    ITTTT EQ
    LDREQ r8, ptr_secondFloatString          ;get second float string (r8-Address)
    LDREQ r9, ptr_floatStringIndex          ;get current index (r9-address, r10-data)
    LDREQ r10, [r9]
    ADDEQ r8, r8, r10                       ;do math to get where we have to store this char
    ITTT EQ
    MOVEQ r0, #0                            ;Move NULL into Current Char Hit
    STREQ r0, [r8]                          ;store Hit Button in address
    MOVEQ r7, #3                            ;Change to Subflag 3 (we're done with second number, going to 3ed)
    ;STREQ r7, [r6]
    ITTT EQ
    MOVEQ r10, #0                           ;Clear index
    STREQ r10, [r9]
    BEQ EndUartHandler                      ;Branch to end




    LDR r8, ptr_secondFloatString                ;get first float string (r8-Address)
    LDR r9, ptr_floatStringIndex            ;get current index (r9-address, r10-data)
    LDR r10, [r9]
    ADD r8, r8, r10                          ;do math to get where we have to store this char
    STR r0, [r8]                            ;store Hit Button in address
    BL output_character                     ;Print the Current Character (feedback Input)
    ADD r10, r10, #1                        ;Add 1 to current index
    STR r10, [r9]                           ;Store current index back
    B EndUartHandler



fH13:
    ;NEED TO COMPARE CURRENT CHAR TO ENTER
    CMP r0, #0xD    ;Is Enter the current char?
    ITTTT EQ
    LDREQ r8, ptr_roundingString          	;get rounding string (r8-Address)
    LDREQ r9, ptr_floatStringIndex          ;get current index (r9-address, r10-data)
    LDREQ r10, [r9]
    ADDEQ r8, r8, r10                       ;do math to get where we have to store this  char
    ITTT EQ
    MOVEQ r0, #0                            ;Move NULL into Current Char Hit
    STREQ r0, [r8]                          ;store Hit Button in address
    MOVEQ r7, #4                            ;Change to Subflag 4 (we're done with 3ed  number, end adding)
    ;STREQ r7, [r6]
    ITTT EQ
    MOVEQ r10, #0                           ;Clear index
    STREQ r10, [r9]
    BEQ EndUartHandler                      ;Branch to end




    LDR r8, ptr_roundingString              ;get first float string (r8-Address)
    LDR r9, ptr_floatStringIndex            ;get current index (r9-address, r10-data)
    LDR r10, [r9]
    ADD r8, r8, r10                          ;do math to get where we have to store this char
    STR r0, [r8]                            ;store Hit Button in address
    BL output_character                     ;Print the Current Character (feedback Input)
    ADD r10, r10, #1                        ;Add 1 to current index
    STR r10, [r9]                           ;Store current index back
    B EndUartHandler



flagHandler2: ;Subtracting
    ;Which SubString (1)
    CMP r7, #1 ;Dealing with First Float String
    BEQ fH21
    CMP r7, #2 ;Dealing with Second Float String
    BEQ fH22
    CMP r7, #3 ;Inputing Rounding Dec
    BEQ fH23
    B EndUartHandler
fH21:
    ;NEED TO COMPARE CURRENT CHAR TO ENTER
    CMP r0, #0xD    ;Is Enter the current char?
    ITTTT EQ
    LDREQ r8, ptr_firstFloatString          ;get first float string (r8-Address)
    LDREQ r9, ptr_floatStringIndex          ;get current index (r9-address, r10-data)
    LDREQ r10, [r9]
    ADDEQ r8, r8, r10                       ;do math to get where we have to store this first FLOAT char
    ITTT EQ
    MOVEQ r0, #0                            ;Move NULL into Current Char Hit
    STREQ r0, [r8]                          ;store Hit Button in address
    MOVEQ r7, #2                            ;Change to Subflag 2 (we're done with first number, going to second)
    ;STREQ r7, [r6]
    ITTT EQ
    MOVEQ r10, #0                           ;Clear index
    STREQ r10, [r9]
    BEQ EndUartHandler                      ;Branch to end




    LDR r8, ptr_firstFloatString                ;get first float string (r8-Address)
    LDR r9, ptr_floatStringIndex            ;get current index (r9-address, r10-data)
    LDR r10, [r9]
    ADD r8, r8, r10                          ;do math to get where we have to store this first FLOAT char
    STR r0, [r8]                            ;store Hit Button in address
    BL output_character                     ;Print the Current Character (feedback Input)
    ADD r10, r10, #1                        ;Add 1 to current index
    STR r10, [r9]                           ;Store current index back
    B EndUartHandler

fH22:
    ;NEED TO COMPARE CURRENT CHAR TO ENTER
    CMP r0, #0xD    ;Is Enter the current char?
    ITTTT EQ
    LDREQ r8, ptr_secondFloatString          ;get second float string (r8-Address)
    LDREQ r9, ptr_floatStringIndex          ;get current index (r9-address, r10-data)
    LDREQ r10, [r9]
    ADDEQ r8, r8, r10                       ;do math to get where we have to store this char
    ITTT EQ
    MOVEQ r0, #0                            ;Move NULL into Current Char Hit
    STREQ r0, [r8]                          ;store Hit Button in address
    MOVEQ r7, #3                            ;Change to Subflag 3 (we're done with second number, going to 3ed)
    ;STREQ r7, [r6]
    ITTT EQ
    MOVEQ r10, #0                           ;Clear index
    STREQ r10, [r9]
    BEQ EndUartHandler                      ;Branch to end




    LDR r8, ptr_secondFloatString                ;get first float string (r8-Address)
    LDR r9, ptr_floatStringIndex            ;get current index (r9-address, r10-data)
    LDR r10, [r9]
    ADD r8, r8, r10                          ;do math to get where we have to store this char
    STR r0, [r8]                            ;store Hit Button in address
    BL output_character                     ;Print the Current Character (feedback Input)
    ADD r10, r10, #1                        ;Add 1 to current index
    STR r10, [r9]                           ;Store current index back
    B EndUartHandler



fH23:
    ;NEED TO COMPARE CURRENT CHAR TO ENTER
    CMP r0, #0xD    ;Is Enter the current char?
    ITTTT EQ
    LDREQ r8, ptr_roundingString          	;get rounding string (r8-Address)
    LDREQ r9, ptr_floatStringIndex          ;get current index (r9-address, r10-data)
    LDREQ r10, [r9]
    ADDEQ r8, r8, r10                       ;do math to get where we have to store this  char
    ITTT EQ
    MOVEQ r0, #0                            ;Move NULL into Current Char Hit
    STREQ r0, [r8]                          ;store Hit Button in address
    MOVEQ r7, #4                            ;Change to Subflag 4 (we're done with 3ed  number, end adding)
    ;STREQ r7, [r6]
    ITTT EQ
    MOVEQ r10, #0                           ;Clear index
    STREQ r10, [r9]
    BEQ EndUartHandler                      ;Branch to end




    LDR r8, ptr_roundingString              ;get first float string (r8-Address)
    LDR r9, ptr_floatStringIndex            ;get current index (r9-address, r10-data)
    LDR r10, [r9]
    ADD r8, r8, r10                          ;do math to get where we have to store this char
    STR r0, [r8]                            ;store Hit Button in address
    BL output_character                     ;Print the Current Character (feedback Input)
    ADD r10, r10, #1                        ;Add 1 to current index
    STR r10, [r9]                           ;Store current index back
    B EndUartHandler

flagHandler3:; multiplying
    ;Which SubString (1)
    CMP r7, #1 ;Dealing with First Float String
    BEQ fH31
    CMP r7, #2 ;Dealing with Second Float String
    BEQ fH32
    CMP r7, #3 ;Inputing Rounding Dec
    BEQ fH33
    B EndUartHandler
fH31:
    ;NEED TO COMPARE CURRENT CHAR TO ENTER
    CMP r0, #0xD    ;Is Enter the current char?
    ITTTT EQ
    LDREQ r8, ptr_firstFloatString          ;get first float string (r8-Address)
    LDREQ r9, ptr_floatStringIndex          ;get current index (r9-address, r10-data)
    LDREQ r10, [r9]
    ADDEQ r8, r8, r10                       ;do math to get where we have to store this first FLOAT char
    ITTT EQ
    MOVEQ r0, #0                            ;Move NULL into Current Char Hit
    STREQ r0, [r8]                          ;store Hit Button in address
    MOVEQ r7, #2                            ;Change to Subflag 2 (we're done with first number, going to second)
    ;STREQ r7, [r6]
    ITTT EQ
    MOVEQ r10, #0                           ;Clear index
    STREQ r10, [r9]
    BEQ EndUartHandler                      ;Branch to end




    LDR r8, ptr_firstFloatString                ;get first float string (r8-Address)
    LDR r9, ptr_floatStringIndex            ;get current index (r9-address, r10-data)
    LDR r10, [r9]
    ADD r8, r8, r10                          ;do math to get where we have to store this first FLOAT char
    STR r0, [r8]                            ;store Hit Button in address
    BL output_character                     ;Print the Current Character (feedback Input)
    ADD r10, r10, #1                        ;Add 1 to current index
    STR r10, [r9]                           ;Store current index back
    B EndUartHandler

fH32:
    ;NEED TO COMPARE CURRENT CHAR TO ENTER
    CMP r0, #0xD    ;Is Enter the current char?
    ITTTT EQ
    LDREQ r8, ptr_secondFloatString          ;get second float string (r8-Address)
    LDREQ r9, ptr_floatStringIndex          ;get current index (r9-address, r10-data)
    LDREQ r10, [r9]
    ADDEQ r8, r8, r10                       ;do math to get where we have to store this char
    ITTT EQ
    MOVEQ r0, #0                            ;Move NULL into Current Char Hit
    STREQ r0, [r8]                          ;store Hit Button in address
    MOVEQ r7, #3                            ;Change to Subflag 3 (we're done with second number, going to 3ed)
    ;STREQ r7, [r6]
    ITTT EQ
    MOVEQ r10, #0                           ;Clear index
    STREQ r10, [r9]
    BEQ EndUartHandler                      ;Branch to end




    LDR r8, ptr_secondFloatString                ;get first float string (r8-Address)
    LDR r9, ptr_floatStringIndex            ;get current index (r9-address, r10-data)
    LDR r10, [r9]
    ADD r8, r8, r10                          ;do math to get where we have to store this char
    STR r0, [r8]                            ;store Hit Button in address
    BL output_character                     ;Print the Current Character (feedback Input)
    ADD r10, r10, #1                        ;Add 1 to current index
    STR r10, [r9]                           ;Store current index back
    B EndUartHandler



fH33:
    ;NEED TO COMPARE CURRENT CHAR TO ENTER
    CMP r0, #0xD    ;Is Enter the current char?
    ITTTT EQ
    LDREQ r8, ptr_roundingString          	;get rounding string (r8-Address)
    LDREQ r9, ptr_floatStringIndex          ;get current index (r9-address, r10-data)
    LDREQ r10, [r9]
    ADDEQ r8, r8, r10                       ;do math to get where we have to store this  char
    ITTT EQ
    MOVEQ r0, #0                            ;Move NULL into Current Char Hit
    STREQ r0, [r8]                          ;store Hit Button in address
    MOVEQ r7, #4                            ;Change to Subflag 4 (we're done with 3ed  number, end adding)
    ;STREQ r7, [r6]
    ITTT EQ
    MOVEQ r10, #0                           ;Clear index
    STREQ r10, [r9]
    BEQ EndUartHandler                      ;Branch to end




    LDR r8, ptr_roundingString              ;get first float string (r8-Address)
    LDR r9, ptr_floatStringIndex            ;get current index (r9-address, r10-data)
    LDR r10, [r9]
    ADD r8, r8, r10                          ;do math to get where we have to store this char
    STR r0, [r8]                            ;store Hit Button in address
    BL output_character                     ;Print the Current Character (feedback Input)
    ADD r10, r10, #1                        ;Add 1 to current index
    STR r10, [r9]                           ;Store current index back
    B EndUartHandler


flagHandler4:;dividing
    ;Which SubString (1)
    CMP r7, #1 ;Dealing with First Float String
    BEQ fH41
    CMP r7, #2 ;Dealing with Second Float String
    BEQ fH42
    CMP r7, #3 ;Inputing Rounding Dec
    BEQ fH43
    B EndUartHandler
fH41:
    ;NEED TO COMPARE CURRENT CHAR TO ENTER
    CMP r0, #0xD    ;Is Enter the current char?
    ITTTT EQ
    LDREQ r8, ptr_firstFloatString          ;get first float string (r8-Address)
    LDREQ r9, ptr_floatStringIndex          ;get current index (r9-address, r10-data)
    LDREQ r10, [r9]
    ADDEQ r8, r8, r10                       ;do math to get where we have to store this first FLOAT char
    ITTT EQ
    MOVEQ r0, #0                            ;Move NULL into Current Char Hit
    STREQ r0, [r8]                          ;store Hit Button in address
    MOVEQ r7, #2                            ;Change to Subflag 2 (we're done with first number, going to second)
    ;STREQ r7, [r6]
    ITTT EQ
    MOVEQ r10, #0                           ;Clear index
    STREQ r10, [r9]
    BEQ EndUartHandler                      ;Branch to end




    LDR r8, ptr_firstFloatString                ;get first float string (r8-Address)
    LDR r9, ptr_floatStringIndex            ;get current index (r9-address, r10-data)
    LDR r10, [r9]
    ADD r8, r8, r10                          ;do math to get where we have to store this first FLOAT char
    STR r0, [r8]                            ;store Hit Button in address
    BL output_character                     ;Print the Current Character (feedback Input)
    ADD r10, r10, #1                        ;Add 1 to current index
    STR r10, [r9]                           ;Store current index back
    B EndUartHandler

fH42:
    ;NEED TO COMPARE CURRENT CHAR TO ENTER
    CMP r0, #0xD    ;Is Enter the current char?
    ITTTT EQ
    LDREQ r8, ptr_secondFloatString          ;get second float string (r8-Address)
    LDREQ r9, ptr_floatStringIndex          ;get current index (r9-address, r10-data)
    LDREQ r10, [r9]
    ADDEQ r8, r8, r10                       ;do math to get where we have to store this char
    ITTT EQ
    MOVEQ r0, #0                            ;Move NULL into Current Char Hit
    STREQ r0, [r8]                          ;store Hit Button in address
    MOVEQ r7, #3                            ;Change to Subflag 3 (we're done with second number, going to 3ed)
    ;STREQ r7, [r6]
    ITTT EQ
    MOVEQ r10, #0                           ;Clear index
    STREQ r10, [r9]
    BEQ EndUartHandler                      ;Branch to end




    LDR r8, ptr_secondFloatString                ;get first float string (r8-Address)
    LDR r9, ptr_floatStringIndex            ;get current index (r9-address, r10-data)
    LDR r10, [r9]
    ADD r8, r8, r10                          ;do math to get where we have to store this char
    STR r0, [r8]                            ;store Hit Button in address
    BL output_character                     ;Print the Current Character (feedback Input)
    ADD r10, r10, #1                        ;Add 1 to current index
    STR r10, [r9]                           ;Store current index back
    B EndUartHandler



fH43:
    ;NEED TO COMPARE CURRENT CHAR TO ENTER
    CMP r0, #0xD    ;Is Enter the current char?
    ITTTT EQ
    LDREQ r8, ptr_roundingString          	;get rounding string (r8-Address)
    LDREQ r9, ptr_floatStringIndex          ;get current index (r9-address, r10-data)
    LDREQ r10, [r9]
    ADDEQ r8, r8, r10                       ;do math to get where we have to store this  char
    ITTT EQ
    MOVEQ r0, #0                            ;Move NULL into Current Char Hit
    STREQ r0, [r8]                          ;store Hit Button in address
    MOVEQ r7, #4                            ;Change to Subflag 4 (we're done with 3ed  number, end adding)
    ;STREQ r7, [r6]
    ITTT EQ
    MOVEQ r10, #0                           ;Clear index
    STREQ r10, [r9]
    BEQ EndUartHandler                      ;Branch to end




    LDR r8, ptr_roundingString              ;get first float string (r8-Address)
    LDR r9, ptr_floatStringIndex            ;get current index (r9-address, r10-data)
    LDR r10, [r9]
    ADD r8, r8, r10                          ;do math to get where we have to store this char
    STR r0, [r8]                            ;store Hit Button in address
    BL output_character                     ;Print the Current Character (feedback Input)
    ADD r10, r10, #1                        ;Add 1 to current index
    STR r10, [r9]                           ;Store current index back
    B EndUartHandler


flagHandler5:; square root
    ;Which SubString (1)
    CMP r7, #1 ;Dealing with First Float String
    BEQ fH51

    CMP r7, #2 ;Inputing Rounding Dec
    BEQ fH53
    B EndUartHandler
fH51:
    ;NEED TO COMPARE CURRENT CHAR TO ENTER
    CMP r0, #0xD    ;Is Enter the current char?
    ITTTT EQ
    LDREQ r8, ptr_firstFloatString          ;get first float string (r8-Address)
    LDREQ r9, ptr_floatStringIndex          ;get current index (r9-address, r10-data)
    LDREQ r10, [r9]
    ADDEQ r8, r8, r10                       ;do math to get where we have to store this first FLOAT char
    ITTT EQ
    MOVEQ r0, #0                            ;Move NULL into Current Char Hit
    STREQ r0, [r8]                          ;store Hit Button in address
    MOVEQ r7, #2                         ;Change to Subflag 2 (we're done with first number, going to rounding BECAUSE THERES NO SECOND OPERAND)
    ;STREQ r7, [r6]
    ITTT EQ
    MOVEQ r10, #0                           ;Clear index
    STREQ r10, [r9]
    BEQ EndUartHandler                      ;Branch to end




    LDR r8, ptr_firstFloatString                ;get first float string (r8-Address)
    LDR r9, ptr_floatStringIndex            ;get current index (r9-address, r10-data)
    LDR r10, [r9]
    ADD r8, r8, r10                          ;do math to get where we have to store this first FLOAT char
    STR r0, [r8]                            ;store Hit Button in address
    BL output_character                     ;Print the Current Character (feedback Input)
    ADD r10, r10, #1                        ;Add 1 to current index
    STR r10, [r9]                           ;Store current index back
    B EndUartHandler

fH53:
    ;NEED TO COMPARE CURRENT CHAR TO ENTER
    CMP r0, #0xD    ;Is Enter the current char?
    ITTTT EQ
    LDREQ r8, ptr_roundingString          	;get rounding string (r8-Address)
    LDREQ r9, ptr_floatStringIndex          ;get current index (r9-address, r10-data)
    LDREQ r10, [r9]
    ADDEQ r8, r8, r10                       ;do math to get where we have to store this  char
    ITTT EQ
    MOVEQ r0, #0                            ;Move NULL into Current Char Hit
    STREQ r0, [r8]                          ;store Hit Button in address
    MOVEQ r7, #3                            ;Change to Subflag 3 (done with rounding, finish)
    ;STREQ r7, [r6]
    ITTT EQ
    MOVEQ r10, #0                           ;Clear index
    STREQ r10, [r9]
    BEQ EndUartHandler                      ;Branch to end




    LDR r8, ptr_roundingString              ;get first float string (r8-Address)
    LDR r9, ptr_floatStringIndex            ;get current index (r9-address, r10-data)
    LDR r10, [r9]
    ADD r8, r8, r10                          ;do math to get where we have to store this char
    STR r0, [r8]                            ;store Hit Button in address
    BL output_character                     ;Print the Current Character (feedback Input)
    ADD r10, r10, #1                        ;Add 1 to current index
    STR r10, [r9]                           ;Store current index back
    B EndUartHandler


flagHandler6:;squaring
    ;Which SubString (1)
    CMP r7, #1 ;Dealing with First Float String
    BEQ fH61

    CMP r7, #2 ;Inputing Rounding Dec
    BEQ fH63
    B EndUartHandler
fH61:
    ;NEED TO COMPARE CURRENT CHAR TO ENTER
    CMP r0, #0xD    ;Is Enter the current char?
    ITTTT EQ
    LDREQ r8, ptr_firstFloatString          ;get first float string (r8-Address)
    LDREQ r9, ptr_floatStringIndex          ;get current index (r9-address, r10-data)
    LDREQ r10, [r9]
    ADDEQ r8, r8, r10                       ;do math to get where we have to store this first FLOAT char
    ITTT EQ
    MOVEQ r0, #0                            ;Move NULL into Current Char Hit
    STREQ r0, [r8]                          ;store Hit Button in address
    MOVEQ r7, #2                         ;Change to Subflag 2 (we're done with first number, going to rounding BECAUSE THERES NO SECOND OPERAND)
    ;STREQ r7, [r6]
    ITTT EQ
    MOVEQ r10, #0                           ;Clear index
    STREQ r10, [r9]
    BEQ EndUartHandler                      ;Branch to end




    LDR r8, ptr_firstFloatString                ;get first float string (r8-Address)
    LDR r9, ptr_floatStringIndex            ;get current index (r9-address, r10-data)
    LDR r10, [r9]
    ADD r8, r8, r10                          ;do math to get where we have to store this first FLOAT char
    STR r0, [r8]                            ;store Hit Button in address
    BL output_character                     ;Print the Current Character (feedback Input)
    ADD r10, r10, #1                        ;Add 1 to current index
    STR r10, [r9]                           ;Store current index back
    B EndUartHandler

fH63:
    ;NEED TO COMPARE CURRENT CHAR TO ENTER
    CMP r0, #0xD    ;Is Enter the current char?
    ITTTT EQ
    LDREQ r8, ptr_roundingString          	;get rounding string (r8-Address)
    LDREQ r9, ptr_floatStringIndex          ;get current index (r9-address, r10-data)
    LDREQ r10, [r9]
    ADDEQ r8, r8, r10                       ;do math to get where we have to store this  char
    ITTT EQ
    MOVEQ r0, #0                            ;Move NULL into Current Char Hit
    STREQ r0, [r8]                          ;store Hit Button in address
    MOVEQ r7, #3                            ;Change to Subflag 3 (done with rounding, finish)
    ;STREQ r7, [r6]
    ITTT EQ
    MOVEQ r10, #0                           ;Clear index
    STREQ r10, [r9]
    BEQ EndUartHandler                      ;Branch to end




    LDR r8, ptr_roundingString              ;get first float string (r8-Address)
    LDR r9, ptr_floatStringIndex            ;get current index (r9-address, r10-data)
    LDR r10, [r9]
    ADD r8, r8, r10                          ;do math to get where we have to store this char
    STR r0, [r8]                            ;store Hit Button in address
    BL output_character                     ;Print the Current Character (feedback Input)
    ADD r10, r10, #1                        ;Add 1 to current index
    STR r10, [r9]                           ;Store current index back
    B EndUartHandler

EndUartHandler:

	;Store Updated Flags Back
    STR r5, [r4]	;Note: If original flag wasn't 0, then we're just storing 0 back
    STR r7, [r6]
	;End
	POP {r4-r12,lr} ; Pop registers from stack
	BX lr       	; Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;































;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;NOTE this function seems to work HOWEVER
; (1) does NOT work with negatives (yet) (but im making all the floats signed)
; (2) it breaks if you put too many funky decimals, but I think that may just be computer hardware limitations, so its still functional in my book
string2float:
	PUSH {lr}	; Store register lr on stack

	;r0 -address of string which is a float

	;initialize accumulator
	;MOV r0, #0
	;vmov s0, r0				;s0 -> 0.0 (ACC)
	;vmov.f32 s1, #10.0		;s1 -> 10.0


	MOV r2, #0				;r2 -> ACC
	MOV r3, #10				;r3 -> 10


	;BEFORE the Decimal Place (working with all ints)
BeforeDec:
	LDRB r1, [r0]		;get the current char at the address
	ADD r0, r0, #1		;Add 1 to address to move to next char
	CMP r1, #0x2E		;is current char a decimal place?
	BEQ HitDecimal		;if yes then branch to next phase
	SUB r1, #0x30		;convert r1 char into INT
	MUL r2,r2, r3		;multiply ACC by 10
	ADD r2, r2, r1		;Add ACC to current int
	B BeforeDec

HitDecimal:
	;we are right AFTER The decimal Place rn

	;turn (r2) acc into float
	vmov s0, r2				;Copy Contents of r2 into s0
	vcvt.f32.S32 s0,s0		;Covert s0 into actual float format (SIGNED!!!!!!!!!!!)
							;s0 -> ACC

	;turn Divisor into float (init 10.0)
	vmov.f32 s1, #10.0		;s1 -> Divisor

	;put 10.0 as a constant variable in s3
	vmov.f32 s3, #10.0

PostDecimal:
	LDRB r1, [r0]				;get the current char at the address
	ADD r0, r0, #1				;Add 1 to address to move to next char
	CMP r1, #0x0				;is current char NULL?
	BEQ DoneString2Float		;if yes then branch We branch to end!

	SUB r1, #0x30				;convert r1 char into INT
	vmov s2, r1					;Convert r1 INT into FLOAT (s2)
	vcvt.f32.S32 s2,s2			;Covert s2 into actual float format (SIGNED!!!!)

	vdiv.f32 s2, s2, s1 		;Divide current char by s1 (which will be 10, 100, 1000, etc) and store in current char


	vmul.f32 s1, s1, s3 		;multiply the divisor by 10 (to make it 100, 1000, 10000, etc)

	vadd.f32 s0, s0, s2			;Add ACC to current float

	B PostDecimal





DoneString2Float:
	;Put the Floating ACC (s0) into r0
	vmov r0, s0



	POP {lr}
	MOV pc, lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Doesnt work with negatives (yes) (but im making all the floats signed)
float2string:
	PUSH {r4-r5, lr}	; Store register lr on stack

	;r0- floating point number
	MOV r4, r0 ;needs to persist across a subroutine, so storing it in r4
	;r1- address of the string
	MOV r5, r1 ;needs to persist across a subroutine, so storing it in r5

	;separate the number -> (FRONT).(BACK)
		;get the FRONT (s0)
	vmov s0, r0				;Put full r0 into s0
	vcvt.s32.f32 s0,s0		;turn s0 into a int (without rounding) (will trunkate the decimal) (SIGNED!!!!)
	vcvt.f32.s32 s0,s0		;turn it BACK into a float (decimal will be trunkated but will be in float format) (SIGNED)

		;get the BACK (s1)
	vmov s1, r0				;Put full r0 into s0
	vsub.f32 s1, s1, s0		;Sub full number with trunkated number to get just decimal bit


	;TURN THE (FRONT) INTO A STRING!!!!
	mov r0, r5				;put address of string (r1) into r0 (for int2string)
	vcvt.s32.f32 s0,s0		;turn floating number into an int again so we can feed it into int2string
	vmov r1, s0				;store Int FRONT (s0) into r1 (for int2string)
	bl modified_int2string	;stores FRONT in memory, will return new base of string into r0 (currently set to null terminator, but i will override wil a decimal point)


	;PUT THE PERIOD IN THE STRING!
	MOV r5, r0		;int2string returns the new base address of the string into r0, store in r5 for consistancy
	MOV r0, #0x2E	;store "." into r0
	STRB r0, [r5]
	ADD r5, r5, #1	;increment to the address right after the period


	;TURN THE (BACK) (s1) INTO A STRING!!!!
	vmov.f32 s2, #10.0			;put 10.0 into s2 so i can use it bellow

float2stringFractionBit:
	vmul.f32 s1, s1, s2			;multiply FULL (BACK-s1) by 10 (s2)
	;get head of the (BACK-s1)
	vcvt.s32.f32 s3,s1			;Turn Float (BACK-s1) into Int, store in s3 as current int placeholder (SIGNED)
	vmov r3, s3					;put the current char into r# register (I am arbitrarily using r3)
	add r3, r3, #0x30			;turn Raw int (r3) into char
	;store char at address
	STRB r3, [r5]				;store current char (r3) into address (r5)
	add r5, r5, #1				;imcrement address by 1
	;subtract current int (s3) from the overall (BACK-s1) float
	vcvt.f32.s32 s3,s3			;turn s3 into a float again (fractional bits have been trunkated)
	vsub.f32 s1, s1, s3			;subtract the current int (s3) from the overall (BACK-s1) float, storing in (BACK-s1)
	;see if we're done with fraction bit
	vmov r3, s1					;i cant figure out vcmp, so im putting the (BACK-s1) regitser in r3 for temporary to do regular cmp
	CMP r3, #0					;is the (BACK-r3) finished?
	BNE float2stringFractionBit	;if NOT then we loop back to start



	;END OF STORING THE ENTIRE FLOAT
	MOV r3, #0x0				;store null terminator in r3
	STRB r3, [r5]				;store null terminator at end of string



	;end
	POP {r4-r5, lr}
	MOV pc, lr



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;THIS WHOLE FUNCTION IS UNCESSESARY BECAUSE CSS DOES THE INIT FOR YOU BUT IM KEEPING IT HERE AS PROOF I READ THE DOCS THAT SAID YOU NEED TO DO IT
;this is first called by MAIN
;inits the keypad to be used on the Aliceboard IG
;RIGHT NOW Im just gonna use the init Functions I already Have
floating_init:
	PUSH {lr}	; Store register lr on stack

	;initialize the FPU :)
	MOV r0, #0xED88
	MOVT r0, #0xE000			;CPACR address in r0
	LDR r1, [r0]				;CPACR data in r1
	ORR r1, r1, #(0xF << 20)	;set bits 20-23 to enable CP10 and CP11
	STR r1, [r0]				;store CPAC back
	DSB							;wait for store to complete
	ISB							;reset pipeline now the FPU is enabled

	POP {lr}
	MOV pc, lr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.end
