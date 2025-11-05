	.data

	.global mainMenu
	.global rgbCode







mainMenu:        	.string "What would you like to test?", 0xA, 0xD
					.string "1-Blinky", 0xA, 0xD
					.string "2-Advanced",0xA, 0xD
					.string "Press Any Other Button to Quit", 0xA, 0xD, 0

rgbCode:			.word 0x0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.text

	.global spiStart
	.global spiInit
	.global testSSE
	.global illuminate_LEDs ;Library
	.global alice_LED_gpio_init	;Library
	.global timer_interrupt_init ;Library
	.global rgb_gpio_init ;Library
	.global uart_init ;Library
	.global uart_interrupt_init ;Library
	.global output_string ;Library
	.global output_character ;Library
	.global simple_read_character ;Library
    .global modified_int2string ;Library
    .global modified_illuminate_RGB_LED ;Library
    ;.global string2int ;Library



ptr_mainMenu:				.word mainMenu
ptr_rgbCode:				.word rgbCode










;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;currently trying to just make the 7 segment display pop up
spiStart:
	PUSH {r4-r12, lr}	; Store register lr on stack

	;Init the GPIO
		;Pins Port B (4-SRCLK of SPI, 7-MOSI of SPI) / Port C (7-Latch, Chip Select for 7 segment)
		;PB4 (SSI2)
		;PB7 (SSI2)
		;PC7 (none?)

	;Init the SPI Modue
	bl spiInit

	bl testSSE






	;Enter the infinite loop (for now) to test to see if working
infinLoop:
	b infinLoop


	POP {r4-r12, lr}
	MOV pc, lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

spiInit:
	PUSH {r4-r12, lr}	; Store register lr on stack



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;!	Enable clock to Appropriate GPIO Module
	;RCGCGPIO (pg 340) (400FE608)
	;(r0-address; r1-data)
	;Port B
	;Port C
	MOV r0, #0xE000
	movt r0, #0x400F
	add r0, r0, #0x608		;get effective address

	MOV r1, #0x6			;turn on Port B/C clock

	str r1, [r0]			;update register

	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;! Configure Pins to be in Alt Function Mode
	;GPIOAFSEL (pg 671) (Port B APB: 40005420)
	;(r0-address; r1-data)
	;Port B4/B7
	;NOTE: CURRENTLY NOT SETTING PORT C (because that's a latch for alice board, not spi)
	mov r0, #0x5000
	movt r0, #0x4000
	add r0, r0, #0x420		;get effective address

	MOV r1, #0x90 			;set pins 4 and 7 to be in alt function mode

	str r1, [r0]			;update register

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;!	Tell GPIO Which alt Function to use
	;GPIOPCTL (pg 688) (Port B APB 4000552C)
	;(r0-address; r1-data)
	;Port B4/B7
	;NOTE: CURRENTLY NOT SETTING PORT C (because that's a latch for alice board, not spi)
	mov r0, #0x5000
	movt r0, #0x4000
	add r0, r0, #0x52C		;get effective address

	MOV r1, #0x0000
	movt r1, #0x2002		;write Pins 4 and 7 to be the value (2)

	str r1, [r0]			;update register

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;!	Set Pins as Digital
	;GPIODEN (pg 682)
	;(r0-address; r1-data)

	;!	Port B, Pins 4/7 (4000551C)
	MOV r0, #0x5000
	movt r0, #0x4000
	add r0, r0, #0x51C		;get effective address

	MOV r1, #0x90			;set pins 4/7

	str r1, [r0]			;update register

	;Port C, Pin 7 (4000651C)
	;For some reason this regiser seems to be init t 0xF which turns into 0x8f, idk if that's an issue (i dont think so)
	MOV r0, #0x6000
	movt r0, #0x4000
	add r0, r0, #0x51C		;get effective address

	MOV r1, #0x80			;set pins 7

	str r1, [r0]			;update register

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Set Pins as Output
	;GPIODIR  (pg 663)
	;(r0-address; r1-data)


	;!	Port B, Pins 4/7 (40005400)
	MOV r0, #0x5000
	movt r0, #0x4000
	add r0, r0, #0x400		;get effective address

	MOV r1, #0x90			;set pins 4/7 as output

	str r1, [r0]			;update register

	;!	Port C, Pins 7 (40006400)
	MOV r0, #0x6000
	movt r0, #0x4000
	add r0, r0, #0x400		;get effective address

	MOV r1, #0x80			;set pin 7 as output

	str r1, [r0]			;update register


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Configure SSI Module

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;!	Turn On SSI Module
	;RCGCSSI (pg 346) (400FE61C)
	;(r0-address; r1-data)
	mov r0, #0xE000
	movt r0, #0x400F
	add r0, r0, #0x61C		;get effective address

	MOV r1, #0x4			;enable ssi module 2 (notes say so)

	str r1, [r0]			;update register
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;!	Disable SSI2 to be able to config it (is off by default I think, but doing it anyways)
	;SSICR1 (pg 971) (Using SSI2: 4000A004)
	;(r0-address; r1-data)
	MOV r0, #0xA000
	movt r0, #0x4000
	add r0, r0, #0x4	;get effective address

	ldr r1, [r0]		;get current data
	BIC r1, #0x2		;write 0 to bit to disable

	str r1, [r0]		;update register
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Set SSI as Leader (pretty sure it's that by default but just making sure)
	;SSICR1 (pg 971) (Using SSI2: 4000A004)
	;(r0-address; r1-data)
	MOV r0, #0xA000
	movt r0, #0x4000
	add r0, r0, #0x4	;get effective address

	ldr r1, [r0]		;get current data
	BIC r1, #0x4		;write 0 to bit to select leader mode

	str r1, [r0]		;update register

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Configure SSI Clock (pretty sure it's set to system clock on default but just making sure)
	;SSICC (pg 984) (Using SSI2: 4000AFC8)
	;(r0-address; r1-data)
	MOV r0, #0xA000
	MOVT r0, #0x4000
	add r0, r0, #0xFC8		;get effective address

	MOV r1, #0x0			;set to use system clock

	str r1, [r0]			;update register
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Set SSI Clock Prescale Divisor
	;SSICPSR (pg 976) (Using SSI2: 4000A010)
	;Note: SSInClk = SysClk/ (CPSDVSR * (1+SCR)) BUT we're making SRC 0, so it doesn't affect anything (Default is 0, I don't need to touch it and I wont)
	;(r0-address; r1-data)
	MOV r0, #0xA000
	movt r0, #0x4000
	add r0, r0, #0x010		;get effective address

	mov r1, #0x4			;16MHz/4=4MHz

	STR r1, [r0]			;update register

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;?Select the 16-Bit Data Size
	;SSICR0 (pg 969) (Using SSI2: 4000A000)
	;IS THIS 8-BIT OR 16-BIT?????????????????
	;(r0-address; r1-data)
	MOV r0, #0xA000
	movt r0, #0x4000	;get effective address

	MOV r1, #0xF		;set SSI Data size to 16-bit

	STR r1, [r0]		;update register

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Enable Loopback
	;SSICR1 (pg 971) (Using SSI2: 4000A004)
	;(r0-address; r1-data)
	MOv r0, #0xA000
	movt r0, #0x4000
	add r0, r0, #0x004		;get effective address

	LDR r1, [r0]			;get current data
	ORR r1, #0x1			;set the LSB to 1 (turns on loopback mode)

	STR r1, [r0]			;update register

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Enable SSE (Synchronous Serial Port)
	;SSICR1 (pg 971) (Using SSI2: 4000A004)
	;(r0-address; r1-data)
	MOv r0, #0xA000
	movt r0, #0x4000
	add r0, r0, #0x004		;get effective address

	ldr r1, [r0]			;get current data
	ORR r1, #0x2			;set bit 1 to enable SSE

	STR r1, [r0]			;update Register
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop


	POP {r4-r12, lr}
	MOV pc, lr



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;The purpose of this it to make something appear on one of the ssi 7-segments
testSSE:
	PUSH {r4-r12, lr}	; Store register lr on stack

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Unlatch Shift Reg
	;GPIODATA (pg 662) (Port C APB: 40006000)
	;(r0-address; r1-data)
	MOv r0, #0x6000
	movt r0, #0x4000
	add r0, r0, #0x3FC		;get effective address

	ldr r1, [r0]			;get current data
	BIC r1, #0x80			;set bit 7 low

	STR r1, [r0]			;update Register

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Wait for Previous Transmission to Complete
	;SSISR (pg 974) (Using SSI2: 4000A00C)
	;(r0-address; r1-data)
	Mov r0, #0xA000
	Movt r0, #0x4000
	add r0, r0, #0x00C		;get effective address

PrevTransPoll:
	ldr r1, [r0]			;get register data
	AND r1, r1, #0x10		;mask bit 4 (the busy flag)
	CMP r1, #0				;compare to 0
	BNE PrevTransPoll		;If r1 ISNT 0, then it's still busy, so poll

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Send Data
	;SSIDR (pg 973) (Using SSI2: 4000A008)
	;(r0-address; r1-data)
	MOV r0, #0xA000
	MOVT r0, #0x4000
	add r0, r0, #0x008		;get effective address

	;FOR NOW,,,,, INSTEAD OF GETTING USER INPUT VALUE
	;			  JUST GOING TO HARDCODE A RANDOM VALUE
	Mov r1, #0xA402		;displayes 2 on screen 3


	STR r1, [r0]			;update register



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Wait for Current Transmission to Complete
	;SSISR (pg 974) (Using SSI2: 4000A00C)
	;(r0-address; r1-data)
	Mov r0, #0xA000
	Movt r0, #0x4000
	add r0, r0, #0x00C		;get effective address

CurrTransPoll:
	ldr r1, [r0]			;get register data
	AND r1, r1, #0x10		;mask bit 4 (the busy flag)
	CMP r1, #0				;compare to 0
	BNE CurrTransPoll		;If r1 ISNT 0, then it's still busy, so poll

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Latch Shift Reg
	;GPIODATA (pg 662) (Port C APB: 40006000)
	;(r0-address; r1-data)
	MOv r0, #0x6000
	movt r0, #0x4000
	add r0, r0, #0x3FC		;get effective address

	ldr r1, [r0]			;get current data
	ORR r1, #0x80			;set bit 7 High

	STR r1, [r0]			;update Register

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



	POP {r4-r12, lr}
	MOV pc, lr


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.end
