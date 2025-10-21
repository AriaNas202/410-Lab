	.data

	.global mainMenu
	.global rgbCode
	.global lightByte
	.global dma_control






mainMenu:        	.string "What would you like to test?", 0xA, 0xD
					.string "1-Blinky", 0xA, 0xD
					.string "2-Advanced",0xA, 0xD
					.string "Press Any Other Button to Quit", 0xA, 0xD, 0

rgbCode:			.word 0x0

lightByte:			.byte 0x01	;init to 0 (values range from 0x0-0xF)
dma_control:
	.align 1024
	.space 1024






;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.text

	.global dmaStart
	.global Timer_Handler
	.global dma_init
	.global increment_lightByte
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
ptr_lightByte:				.word lightByte
ptr_dma_control:			.word dma_control










;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;This is the second function to be called by MAIN
;actually does the little game or whatever
;this should ultimately be the overall "Game" printer which controls replay
dmaStart:
	PUSH {r4-r12, lr}	; Store register lr on stack

	;Init
	bl alice_LED_gpio_init			;init alice board lights to be able to be set
	bl timer_interrupt_init			;init timer to interrupt every second
	bl dma_init						;init the dma transfer




		;enter an infinite loop to test dma (pausing in here, the dma should still work)
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
increment_lightByte:
	PUSH {r4-r12,lr}
	;Increment lightByte (or back to zero if 0xF)

	;Get lightByte data
	;(r0-addres, r1-data)
	LDR r0, ptr_lightByte
	LDRB r1, [r0]

	;What do we need to do to lightByte?
	CMP r1, #0xF
	BEQ resetLightByte
	B incLightByte			;if lightByte is 0xF (max), reset to 0; otherwise increase

resetLightByte:
	;reset lightByte to 0x0
	MOV r1, #0x0
	;store back
	STRB r1, [r0]
	;branch to end
	B endTimerHandler

incLightByte:
	;increase lightByte
	add r1, r1, #1
	;store back
	STRB r1, [r0]


	;branch to end
	B endTimerHandler



	POP {r4-r12,lr}
	MOV pc, lr





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





Timer_Handler:

	PUSH {r4-r12,lr}

	;Must prep for a regular periodical interrupt AND dma interrupt



	;Check Which interrupt
	;DMACHIS (pg 635) (400FF504)
	;(r0-addres, r1-data)
	MOV r0, #0xF000
	MOVT r0, #0x400F
	add r0, r0, #0x504		;get effective address

	LDR r1, [r0]			;get data in DMA Channel Interrupt Reg (THIS CAUSES A FAULT!!!)

	CMP r1, #0x40000
	BEQ dmaInterr
	B periodInterr			;if DMA Interrupt Reg indicates DMA trigger, Branch to DMA; Otherwise Period




periodInterr:

	;Clear Period interrupt
	MOV r0, #0x0000
	MOVT r0, #0x4003
	LDRB r1, [r0, #0x24]
	ORR r1, r1, #0x1
	STRB r1, [r0, #0x24]

	;increment lightByte (temp getting rid of this, the other handler does the incrementing from now on)
	;bl increment_lightByte








dmaInterr:

	;!Clear DMA interrupt
	MOV r0, #0xF000
	MOVT r0, #0x400F
	LDR r1, [r0, #0x504]	;get effective address
	ORR r1, r1, #0x40000	;set 18th bit to clear interrupt
	STR r1, [r0, #0x504]	;store back


	;Inc LightByte (interrupt shoots every second, so every time we must interrupt it (THIS IS NEW!!!)
	bl increment_lightByte



	; Enable Channel in in DMA Enable Set Register
	;DMAENASET (pg 627) (400FF028)
	MOV r0, #0xF000
	MOVT r0, #0x400F
	add r0, r0, #0x028		;get effective address

	MOV r1, #0x40000		;set 18th bit to enable

	str r1, [r0]			;update register


	;!Reset the Control Word
	;Docs for Control: "Controler updates transfer size [0] and transfer mode [stop] fields...it must be reconfigured before each new transfer"
	;DMACHCTL (pg 611) (For Channel 18:	20000528) (0x8 offset)
	MOV r0, #0x0520
	MOVT r0, #0x2000
	add r0, r0, #0x8		;get effective address

	MOV r1, #0xCC000000
	add r1,r1,#1			;Reset All Channel Configs (including setting up basic mode again)

	str r1, [r0]			;Update register

	;End




endTimerHandler:

	POP {r4-r12,lr}
	BX lr       	; Retu










;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dma_init:
	PUSH {r4-r12,lr} ; Spill registers to stack
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;!	Turn on DMA clock
	;RCGCDMA (pg 342) (400FE60C)
	;(r0-addres, r1-data)
	;Must turn this on to access module registers, otherwise bus fault
	MOV r0, #0xE000
	MOVT r0, #0x400F
	ADD r0, r0, #0x60C		;Get effective address

	LDR r1, [r0]
	ORR r1, r1, #0x1		;turn clock on

	STR r1, [r0]			;Update register



;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	;!~	Enable DMA Controller
	;DMACFG (pg 618) (400FF004)
	;(r0-addres, r1-data)
	;DOESNT WORK CURRENTLY!!!!



	mov r0, #0xF000
	movt r0, #0x400F
	add r0, r0, #0x4	;Get effective address

	;LDR r1, [r0]
	;ORR r1, r1, #0x1		;turn dma controller on
	mov r1, #0x1


	STR r1, [r0]			;Update register


	;LDR r1, [r0] ;put this here to test, for some reason it keeps reading 0x0 dispite setting the register as 0x1




;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	;!?	Set Base Address of Pointer
	;DMACTLBASE (pg 619) (400FF008)
	;(r0-addres, r1-data)
	mov r0, #0xF000
	movt r0, #0x400F
	add r0, r0, #0x8		 	;get effective address

	ldr r1, ptr_dma_control  	;put address of dma_control in r1

	str r1, [r0]				;update address



;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;SET UP DMA CHANNEL CONTROL STRUCTURE
	;(r0-addres, r1-data)


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;!?	Set Up Source Address (STARTING)
	;DMASRCENDP (pg 609) (For Channel 18:	20000520) (0x0 offset)
	;"If the source address is not incrementing, then this field points at the source location itself (such as a peripheral data register)."

	MOV r0, #0x0520
	MOVT r0, #0x2000		;get effective address

	ldr r1, ptr_lightByte	;get lightByte (light color code)

	str r1, [r0]			;update register

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;!?	Set Up Desination Address (ENDING)
	;DMADSTENDP (pg 610) (For Channel 18:	20000524) (0x4 offset)

	MOV r0, #0x0520
	MOVT r0, #0x2000
	add r0, r0, #0x4		;get effective address

	mov r1, #0x503C
	movt r1, #0x4000		;get LEDs data reg on Port B (ony reading 4 bits so bit mask reflects that) (4000503C)

	str r1, [r0]			;Update register

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;!?		Set Up Channel Control Word
	;DMACHCTL (pg 611) (For Channel 18:	20000528) (0x8 offset)

	MOV r0, #0x0520
	MOVT r0, #0x2000
	add r0, r0, #0x8		;get effective address

	MOV r1, #0xCC000000		;put channel control configs into r1 (Note to Self: see my google doc notes for full breakdown)

	str r1, [r0]			;Update register


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;Determine Request Type
	;I GUESS we're only doing burst requests cause the table says Single has No events which trigger it using general timers
	;I do not think it matters right now? I do not care which we use when we're only transfering 1 byte (IM GOING TO SKIP THIS FOR NOW)
	;I could use the DMAUSEBURSTSET/ DMAUSEBURSTCLR to disable single requests but I DO NOT really care to do that? I dont know ? Maybe I should cause like then the burst requests will trigger the interrupt?
	;Also do i set the useBurst bit on the control channel word?

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;Setup DMA Trigger
	;Im pretty sure channel 18 is default set to Timer 0A, so Im gonna skip this too


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;!~ Clear DMA Channel Primary Alternate Clear Register (For Basic & Auto Transfer Modes )
	;DMAALTCLR (pg 630) (400FF034)
	;(r0-addres, r1-data)
	MOV r0, #0xF000
	MOVT r0, #0x400F
	add r0, r0, #0x034		;get effective address

	MOV r1, #0x40000		;clear 18th bit, 18th channel is not alt select

	str r1, [r0]			;update register

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;Set Priority
	;He said it wasn't necesary sincle there's only 1 transfer, so Im skipping for now

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;!?~ Allow DMA Requests
	;DMAREQMASKCLR (pg 626) (400FF024)
	;(r0-addres, r1-data)

	MOV r0, #0xF000
	MOVT r0, #0x400F
	add r0, r0, #0x024		;get effective address

	MOV r1, #0x40000		;clear 18th bit, 18th channel is not alt select

	str r1, [r0]			;update register



;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;Start Transfer
	;(r0-addres, r1-data)


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;!? Enable Transfer Mode in DMA Control Register
	;Setting to basic transfer mode
	;DMACHCTL (pg 611) (For Channel 18:	20000528) (0x8 offset)

	MOV r0, #0x0520
	MOVT r0, #0x2000
	add r0, r0, #0x8		;get effective address

	ldr r1, [r0] 			;read stuff already in reg so we dont override
	ADD r1, r1, #0x1		;set basic transfer mode (0x1)

	str r1, [r0]			;Update register


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;! Enable Channel in in DMA Enable Set Register
	;DMAENASET (pg 627) (400FF028)
	MOV r0, #0xF000
	MOVT r0, #0x400F
	add r0, r0, #0x028		;get effective address

	MOV r1, #0x40000		;set 18th bit to enable

	str r1, [r0]





	POP {r4-r12,lr}
    MOV pc, lr       	; Return













;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;












	.end
