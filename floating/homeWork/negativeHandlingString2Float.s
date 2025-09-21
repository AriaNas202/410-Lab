


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;NOTE this function seems to work HOWEVER
; (1) does NOT work with negatives (yet) (but im making all the floats signed)
; (2) it breaks if you put too many funky decimals, but I think that may just be computer hardware limitations, so its still functional in my book
string2float:
	PUSH {r4, lr}	; Store register lr on stack

	;r0 -address of string which is a float

    ;NEGATIVE HANDLING
    LDR r4, [r0]        ;get first char in string
    CMP r4, #0x2D       ;is first char negative sign "-"?
    ITTE EQ
    MOVEQ r4, #1        ;If first char negative ->Store 1 in r4
    ADDEQ r0, r0, #1    ;Imcrement address (r0) to be one space after negative
    MOVNE r4, #0        ;If first char NOT -> store 0 in r4





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

	;Turn result negative if necessary 
    CMP r4, #1  ;if r4 is 1, then number should be negative 
    BNE string2floatNonNegative
    VNEG.f32 s0,s0    ;turn result negative if needed
string2floatNonNegative:

    ;Put the Floating ACC (s0) into r0
	vmov r0, s0



	POP {r4, lr}
	MOV pc, lr
