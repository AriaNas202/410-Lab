	.data
	.global floatString1

prompt_example:        	.string "Example Prompt", 0xA, 0xD, 0
floatString1:        	.string "999.2578", 0

exampleFlag:				.word	0x0






;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.text

	.global floating_init
	.global floating
	.global gpio_init ;Library
	.global uart_init ;Library
	.global uart_interrupt_init ;Library
	.global output_string ;Library
	.global output_character ;Library
	.global simple_read_character ;Library

ptr_prompt_example:   			.word prompt_example
ptr_exampleFlag:				.word exampleFlag
ptr_floatString1:				.word floatString1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;This is the second function to be called by MAIN
;actually does the little game or whatever
;this should ultimately be the overall "Game" printer which controls replay
floating:
	PUSH {lr}	; Store register lr on stack


	;Init the FPU
	BL floating_init ;Initialize the FPU for calulations

tempLoop:
	LDR r0, ptr_floatString1
	BL string2float



	B tempLoop


	POP {lr}
	MOV pc, lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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



	.end
