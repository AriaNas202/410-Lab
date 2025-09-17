	.data
	.global prompt_example
	.global floatString1
	.global floatfloat1
	.global mainMenu
	.global calcState

prompt_example:        	.string "Example Prompt I Will Use as An Example!", 0xA, 0xD, 0
floatString1:        	.string "-10.0", 0
floatfloat1:			.float 67.6891

exampleFlag:				.word	0x0

mainMenu:				.string "WELCOME TO THE CALCULATOR!!!", 0xA, 0xD
						.string "1) Add", 0xA, 0xD
						.string "2) Sub", 0xA, 0xD
						.string "3) Mult", 0xA, 0xD
						.string "4) Div", 0xA, 0xD
						.string "5) Sqrt", 0xA, 0xD
						.string "6) Raise to Two", 0xA, 0xD
						.string "Hit Any other Key to Quit!", 0xA, 0xD, 0

calcState:				.word 0x0









;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.text

	.global floating
	.global UART0_Handler
	.global string2float
	.global float2string
	.global floating_init
	.global gpio_init ;Library
	.global uart_init ;Library
	.global uart_interrupt_init ;Library
	.global output_string ;Library
	.global output_character ;Library
	.global simple_read_character ;Library
    .global modified_int2string ;Library

ptr_prompt_example:   			.word prompt_example
ptr_exampleFlag:				.word exampleFlag
ptr_floatString1:				.word floatString1
ptr_floatfloat1:				.word floatfloat1
ptr_mainMenu:					.word mainMenu
ptr_calcState:					.word calcState





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This is the second function to be called by MAIN
;actually does the little game or whatever
;this should ultimately be the overall "Game" printer which controls replay
floating:
	PUSH {r4-r5, lr}	; Store register lr on stack

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
	MOV r0, #0xC
	BL output_character
	MOV r0, #'a'
	BL output_character
	B startCalc

subbing:
	MOV r0, #0xC
	BL output_character
	MOV r0, #'s'
	BL output_character
	B startCalc
	
multing:
	MOV r0, #0xC
	BL output_character
	MOV r0, #'m'
	BL output_character
	B startCalc
	
diving:
	MOV r0, #0xC
	BL output_character
	MOV r0, #'d'
	BL output_character
	B startCalc
	
sqrting:
	MOV r0, #0xC
	BL output_character
	MOV r0, #'q'
	BL output_character
	B startCalc
	
squaring:
	MOV r0, #0xC
	BL output_character
	MOV r0, #'^'
	BL output_character
	B startCalc
	
quitting:
	MOV r0, #0xC
	BL output_character
	MOV r0, #'!'
	BL output_character
	B startCalc



	POP {r4-r5, lr}
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

    ;Are we Currently in Main Menu?
    CMP r5, #0
    BNE EndUartHandler		;Flag is not Main Menu (0), do not process input

    ;Process Input (r0)
    CMP r0, #0x31			;1 Hit, Flag Updates to 1
    IT EQ
    MOVEQ r5, #1
    CMP r0, #0x32			;2 Hit, Flag Updates to 2
    IT EQ
    MOVEQ r5, #2
    CMP r0, #0x33			;3 Hit, Flag Updates to 3
    IT EQ
    MOVEQ r5, #3
    CMP r0, #0x34			;4 Hit, Flag Updates to 4
    IT EQ
    MOVEQ r5, #4
    CMP r0, #0x35			;5 Hit, Flag Updates to 5
    IT EQ
    MOVEQ r5, #5
    CMP r0, #0x36			;6 Hit, Flag Updates to 6
    IT EQ
    MOVEQ r5, #6
    CMP r5, #0				;Else, Random Key Hit, Flag Updates to 7
    IT EQ					;Note We're comparing r5 to 0 here because, if we made it this far then we KNOW r5 started off as 0 (Main Menu)
    MOVEQ r5, #7    		;which means if the other operations didnt trigger, then r5 would still be 0, meaning "Else" we quit





EndUartHandler:

	;Store Updated Flag Back
    STR r5, [r4]	;Note: If original flag wasn't 0, then we're just storing 0 back

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
