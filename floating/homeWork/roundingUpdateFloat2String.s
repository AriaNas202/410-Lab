;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

float2string:
	PUSH {r4-r5, lr}	; Store register lr on stack

	;r0- floating point number
	;r1- address of the string
	;r2- Number of decimal places to round to

	;Multiply the Float 10^r2 times
	
	MOV r3, #10				;10X ACC (r3) 
	MOV r4, #1				;^n ACC (r4) 
	MOV r5, #10 			;Static 10 int (r5) 
	;VMOV.f32 s1, #10.0		;put 10.0 in s1
	;MOV r3, #1	;ACC for 10^r3

	;build the 10^r2 multiplier 
float2stringRoundingMult:
	;check if we're done Multipling 10^r2 
	CMP r2, r4
	BEQ float2stringRoundingMultDone
	ADD r4, r4, #1		;Add 1 to ^n
	MUL r3, r3, r5		;Mult 10X ACC (r3) by 10 (r5) 
	B float2stringRoundingMult

	


float2stringRoundingMultDone:
	;10X result (r3) 
	;Multiply float with 10X result  
	VMOV s0, r0				;put original float in s0 
	VCVT.f32.s32 s1, r3		;put 10X result into s1
	vMUL.f32 s0, s0, s1 	;Mult original float (s0) with 10X buffer (s1), store in s0 

	;Convert float*10X to int (and then back to float) (s0) 
	vcvt.s32.f32 s0, s0
	vcvt.f32.s32 s0, s0 ;will trunkcate the decimal 

	;Divide the float*10X by 10X to get the original float (this time all uncessesary digits are trunkcated)
	VCVT.f32.s32 s1, r3		;put 10X result into s1
	vdiv.f32 s0, s0, s1			; DIV float*10X (s0) by 10X (s1) 

	;Store updated float in r0
	VMOV r0, s1























	MOV r5, r1 ;needs to persist across a subroutine, so storing it in r5




    ;CHECK FOR NEGATIVE
    AND r2, r0, #0x80000000 ;mask float (r2) 
    CMP r2, #0 
    BEQ float2stringNonNegative

    ;Its Negative 
    MOV r2, #0x2D           ;put "-" into r2
    STRB r2, [r5],#1        ;store "-" into string
    ADD r1, r1, #1          ;Update both address registers (r0 and r1) (remind me again why I made 2 address registers?)
    BIC r0, #0x80000000     ;make float positive (bit clear MSB)


float2stringNonNegative:

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
