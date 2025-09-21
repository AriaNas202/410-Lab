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
    BEQ flagHandler1
    CMP r5, #3
    BEQ flagHandler1
    CMP r5, #4
    BEQ flagHandler1
    CMP r5, #5
    BEQ flagHandler2
    CMP r5, #6
    BEQ flagHandler2
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


flagHandler1: ;Add, Sub, Mult, Div
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




flagHandler2:;sqrt/square 
    ;Which SubString (1)
    CMP r7, #1 ;Dealing with First Float String
    BEQ fH21
    CMP r7, #2 ;Inputing Rounding Dec
    BEQ fH22
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

fH22:
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



