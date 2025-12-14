readingLCD:
    PUSH {r4-r12, lr}

    ;init values
                                ;(each line in lcd screen has 16 squares, count to know where to take it to the next line)
    MOV r4, #0                  ;(r4-how many chars have been written to the screen already)

    ldr r5, ptr_to_messbuffer   ;(r5-address where message is stored )

    ;Start reading letters 
keepPrintingLcd:
    CMP r4, #16             ;when we write 16 chars to the screen, it's time to go to next line
    BEQ goToNextLine

    ;Print next char 
    ldrb r0, [r5]    ;get next char and put as argument 
    CMP r0, #0x0
    BEQ endOfPrint   ;if we're at the end, then stop printing 
    MOV r1, #1       ;flag argument as char data 
    bl lcdSendByte

    ;Increment the lcd counter
    add r4,r4, #1 

    ;Increment to the next char address 
    add r5, r5, #1 

    B keepPrintingLcd                  




goToNextLine:
    ;move cursor to next line after 16 prints
    MOV r0, #0xc0
    mov r1, #0x0
    bl lcdSendByte

    ;reset the char counter 
    MOV r4, #0 

    ;go back to the print loop 
    B keepPrintingLcd







endOfPrint:


    POP {r4-r12, lr}
    MOV pc, lr 
