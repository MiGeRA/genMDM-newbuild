;=========================================================================
; SEGA MEGA DRIVE/GENESIS - genMDM-3-newbuild (based on disassembled dump)
;=========================================================================
;
; To assemble this program with ASM68K.EXE:
;    ASM68K.EXE /p genMDM-3-newbuild.asm,genMDM-3-newbuild.bin,genMDM-3-newbuild.map,genMDM-3-newbuild.lst
;
; genMDM-3-newbuild.asm = this source file
; genMDM-3-newbuild.bin = the binary file, fire this up in your cart!
; genMDM-3-newbuild.lst = listing file, shows assembled addresses alongside your source code
; genMDM-3-newbuild.map = symbol map file for linking (unused)
;
;=========================================================================

; A label defining the start of ROM so we can compute the total size.
ROM_Start:
	dc.l   $00FFFE00			; Initial stack pointer value
	dc.l   Start_Point			; Start of program
	dc.l   Interrupt	 		; Bus error
	dc.l   Interrupt 			; Address error
	dc.l   Interrupt		 	; Illegal instruction
	dc.l   Interrupt 			; Division by zero
	dc.l   Interrupt 			; CHK Interrupt
	dc.l   Interrupt 			; TRAPV Interrupt
	dc.l   Interrupt 			; Privilege violation
	dc.l   Interrupt			; TRACE exception
	dc.l   Interrupt			; Line-A emulator
	dc.l   Interrupt			; Line-F emulator
	dc.l   Interrupt			; Unused (reserved)
	dc.l   Interrupt			; Unused (reserved)
	dc.l   Interrupt			; Unused (reserved)
	dc.l   Interrupt			; Unused (reserved)
	dc.l   Interrupt			; Unused (reserved)
	dc.l   Interrupt			; Unused (reserved)
	dc.l   Interrupt			; Unused (reserved)
	dc.l   Interrupt			; Unused (reserved)
	dc.l   Interrupt			; Unused (reserved)
	dc.l   Interrupt			; Unused (reserved)
	dc.l   Interrupt			; Unused (reserved)
	dc.l   Interrupt			; Unused (reserved)
	dc.l   Interrupt			; Spurious exception
	dc.l   Interrupt			; IRQ level 1
	dc.l   Interrupt			; IRQ level 2
	dc.l   Interrupt			; IRQ level 3
	dc.l   Int_HSync ;INT_HInterrupt	; IRQ level 4 (horizontal retrace interrupt)
	dc.l   Interrupt	  		; IRQ level 5
	dc.l   Int_VSync ;INT_VInterrupt	; IRQ level 6 (vertical retrace interrupt)
	dc.l   Interrupt			; IRQ level 7
	dc.l   Interrupt			; TRAP #00 exception
	dc.l   Interrupt			; TRAP #01 exception
	dc.l   Interrupt			; TRAP #02 exception
	dc.l   Interrupt			; TRAP #03 exception
	dc.l   Interrupt			; TRAP #04 exception
	dc.l   Interrupt			; TRAP #05 exception
	dc.l   Interrupt			; TRAP #06 exception
	dc.l   Interrupt			; TRAP #07 exception
	dc.l   Interrupt			; TRAP #08 exception
	dc.l   Interrupt			; TRAP #09 exception
	dc.l   Interrupt			; TRAP #10 exception
	dc.l   Interrupt			; TRAP #11 exception
	dc.l   Interrupt			; TRAP #12 exception
	dc.l   Interrupt			; TRAP #13 exception
	dc.l   Interrupt			; TRAP #14 exception
	dc.l   Interrupt			; TRAP #15 exception
	dc.l   Interrupt			; Unused (reserved)
	dc.l   Interrupt			; Unused (reserved)
	dc.l   Interrupt			; Unused (reserved)
	dc.l   Interrupt			; Unused (reserved)
	dc.l   Interrupt			; Unused (reserved)
	dc.l   Interrupt			; Unused (reserved)
	dc.l   Interrupt			; Unused (reserved)
	dc.l   Interrupt			; Unused (reserved)
	dc.l   Interrupt			; Unused (reserved)
	dc.l   Interrupt			; Unused (reserved)
	dc.l   Interrupt			; Unused (reserved)
	dc.l   Interrupt			; Unused (reserved)
	dc.l   Interrupt			; Unused (reserved)
	dc.l   Interrupt			; Unused (reserved)
	dc.l   Interrupt			; Unused (reserved)
	dc.l   Interrupt			; Unused (reserved)

	dc.b "SEGA MEGA DRIVE "                                 ; Console name
	dc.b "GPL 2022.MAY    "                                 ; Copyright holder and release date
	dc.b "genMDM newbuild for Ext-Port                    " ; Domestic name
	dc.b "genMDM newbuild for Ext-Port                    " ; International name
	dc.b "AL 15526278-11"                                   ; Version number
	dc.w 0x45EA                                             ; Checksum
	dc.b "F               "                                 ; I/O support
	dc.l ROM_Start                                          ; Start address of ROM
	dc.l ROM_End-1                                          ; End address of ROM
	dc.l 0x00FF0000                                         ; Start address of RAM
	dc.l 0x00FF0000+0x0000FFFF                              ; End address of RAM
	dc.l 0x00000000                                         ; SRAM enabled
	dc.l 0x00000000                                         ; Unused
	dc.l 0x00000000                                         ; Start address of SRAM
	dc.l 0x00000000                                         ; End address of SRAM
	dc.l 0x00000000                                         ; Unused
	dc.l 0x00000000                                         ; Unused
	dc.b "                                        "         ; Notes (unused)
	dc.b "JUE             "                                 ; Country codes
	
Start_Point:
Cold_Start:
	MOVE.W  #$2700, SR		;Disable IRQs for now
;***************************************
	MOVE.b	$00A10001, D0		;Version Register - TMSS check
	ANDI.b	#$0F, D0                ;TMSS detect
	BEQ.w	loc_01  	        ; ... skip security init
	MOVE.l	#$53454741, $00A14000	;Unlock TMSS
loc_01:
;*************************************** Clear registers
	MOVE.w	$00C00004, D0
	SUB.l	D0, D0
	SUB.l	D1, D1
	SUB.l	D2, D2
	SUB.l	D3, D3
	MOVEA.l	D0, A6
	MOVE.l	A6, USP
;*************************************** VDP Init
	LEA	VDP_init, A0
	MOVE.w	#$0018, D1		;24 register values ...
loc_02:
	MOVE.w	(A0)+, $00C00004	; ... to be copied to the VDP during initialisation
	DBF	D1, loc_02
;*************************************** VDP Clear Screen
	MOVE.l	#$40000080, $00C00004
	MOVE.w	#0, $00C00000
;*************************************** Z80 Stop
	MOVE.w	#$0100, $00A11100
	MOVE.w	#$0100, $00A11200
loc_03:                                 ;Wait for Z80 to halt
	BTST.b	#0, $00A11100
	BNE.w	loc_03
;*************************************** Copy z80_sub to Z80 memory area
	LEA	z80_sub, A0
	LEA	$00A00000, A1
	MOVE.w	#$00E2, D1
loc_04:
	MOVE.b	(A0)+, (A1)+
	DBF	D1, loc_04
;*************************************** Z80 Reset -> Start
	MOVE.w	#0, $00A11200
	MOVE.w	#0, $00A11100
	MOVE.w	#$0100, $00A11200
;*************************************** PSG Init
	MOVE.b	#$9F, $00C00011
	MOVE.b	#$BF, $00C00011
	MOVE.b	#$DF, $00C00011
	MOVE.b	#$FF, $00C00011
;*************************************** Prepare to read port 68k (BUS REQ)
Hot_Start:
	MOVE.w	#$0100, $00A11100
	MOVE.b	#0, $00A1000D		;$00A1000B - Port2, $00A1000D - Port3
	MOVE.b	#0, D6
;*************************************** Init YM2612
	LEA	YM_Data_Set, A0
	MOVE.l	#$0000002A, D7          ;Size block (/2)
	MOVE.b	#0, D6			;Select Bank P1 (inside logic for select subroutine)		
loc_05:
	MOVE.b	(A0)+, D0		;for "YM-A0"
	MOVE.b	(A0)+, D1		;for "YM-D0"
	BSR.w	YM_Load			;Call subroutine
	DBF	D7, loc_05
;*************************************** What do we expect to read?
;
; z0xx xxxx - nop
; z100 xxxx - low half-byte of data (lD)
; z101 xxxx - hi half-byte of data (hD)
; z110 xxxx - low half-byte of addr (lA)
; z111 xxxx - hi half-byte of addr (hA) and goto next
;
;*************************************** Read port 68k
Main:
	MOVE.b	$00A10007, D0		;$00A10005 - Port2, $00A10007 - Port3
	BTST.l	#6, D0
	BNE.w	loc_06                  ;goto if D0[6] == 1 (always = 1, becouse pin not use)
	BRA.w	Main			;Come back ...
loc_06:
	BTST.l	#5, D0
	BNE.w	loc_08			;goto if D0[5] == 1
	BTST.l	#4, D0	
	BNE.w	loc_07                  ;goto if D0[4] == 1
;*************************************** We are here because D0[5] == 0, D0[4] == 0
	MOVE.b	D0, D2			
	ANDI.b	#$0F, D2		;D0[3-0] -> D2[3-0] (lD)
	BRA.w	Main			;Come back ...
;*************************************** We are here because D0[5] == 0, D0[4] == 1
loc_07:
	MOVE.b	D0, D3	
	ANDI.b	#$0F, D3
	LSL.b	#4, D3			;D0[3-0] -> D3[7-4] (hD)
	BRA.w	Main			;Come back ...
;*************************************** We are here because D0[5] == 1 for addr receiving
loc_08:
	BTST.l	#4, D0
	BNE.w	loc_09                  ;goto if D0[4] == 1 (hA) recieved
;*************************************** We are here because D0[5] == 1, D0[4] == 0
	MOVE.b	D0, D4	
	ANDI.b	#$0F, D4                ;D0[3-0] -> D4[3-0] (lA)
	BRA.w	Main			;Come back ...
;*************************************** We are here because D0[5] == 1, D0[4] == 1
loc_09:					
	ANDI.b	#$0F, D0		;D0[3-0] (hA) recieved and parse next
	CMPI.b	#$0B, D0
	BHI.w	loc_10			;goto if D0 > 0x0B (D0[5],D0[4] == 1) - addr over YM
	MOVE.b	D0, D5			
	LSL.b	#4, D5                  ;D0[3-0] -> D5[7-4] (hA)
	OR.b	D2, D3			;D2 | D3 -> D3 ("YM-Dx") - receive with D0[5] stays zero and changing D0[4]
	OR.b	D4, D5			;D4 | D5 -> D5 ("YM-Ax") - receive with D0[5] stays one and changing D0[4]
	MOVE.b	D5, D0                  ;D5 ->  D0 ("YM-Ax")
	MOVE.b	D3, D1                  ;D3 ->  D1 ("YM-Dx")
;*************************************** Transfer to YM2612
	BSR.w	YM_Load			;Call subroutine
	BRA.w	Main
;*************************************** "notYM-Ax" == 0xC0 | 0xD0 | 0xE0
loc_10:
	CMPI.w	#$000C, D0
	BEQ.w	loc_11
	CMPI.w	#$000D, D0
	BEQ.w	loc_12
	CMPI.w	#$000E, D0
	BEQ.w	loc_13
	BRA.w	Main			;Come back ...
;*************************************** We are here because "notYM-Ax" == 0xCx (low part of addr - any)
loc_11:
	OR.b	D2, D3			;D2 | D3 -> D3 ("notYM-Dx") - receive with D0[5] stays zero and changing D0[4]
	MOVE.b	D3, $00C00011		;PSG Write
	BRA.w	Main			;Come back ...
;*************************************** We are here because "notYM-Ax" == 0xDx (low part of addr - any)
loc_12:
	MOVE.b	#0, D6			;Pre-select Bank P1 (inside logic for select subroutine)
	BRA.w	Main			;Come back ...
;*************************************** We are here because "notYM-Ax" == 0xEx (low part of addr - any)
loc_13:					
	MOVE.b	#1, D6			;Pre-select Bank P2 (inside logic for select subroutine)
	BRA.w	Main			;Come back ...
;*************************************** YM2612 Registry-Bank loading ...
YM_Load:
	MOVE.b	$00A04000, D2
	BTST.l	#7, D2
	BNE.b	YM_Load
	MOVE.l	#$00A04000, A2		;Bank P1 pre-select
	BTST.l	#0, D6                  ;Need Bank P2 select?
	BEQ.w	loc_14			;If "Zero" then not
	ADDI.l	#2, A2                  ;Bank P2 select (+2 to YM-addr)
loc_14:
	MOVE.b	D0, (A2)+		;"YM-A0|1"
	NOP
	NOP
	NOP
loc_15:
	MOVE.b	$00A04000, D2
	BTST.l	#7, D2
	BNE.b	loc_15
	MOVE.b	D1, (A2)		;"YM-D0|1"
	RTS
;*************************************** Interrupt 68k
Interrupt:
	RTE
Int_HSync:
	RTE
Int_VSync:
	RTE
;*************************************** VDP Init sequence
VDP_init:
	dc.w	$8004			;9-bit palette = 1 (otherwise would be 3-bit), HBlank = 0
	dc.w	$8134			;Genesis display = 1, DMA = 1, VBlank = 1, display = 0
	dc.w	$8230			;Scroll A - $C000
	dc.w	$8338			;Window   - $E000
	dc.w	$8407			;Scroll B - $E000
	dc.w	$857C			;Sprites  - $F800
	dc.w	$8600			;Unused
	dc.w	$8700			;Backdrop color - $00
	dc.w	$8800			;Unused
	dc.w	$8900			;Unused
	dc.w	$8A00			;H Interrupt register
	dc.w	$8B00			;Full screen scroll, no external interrupts
	dc.w	$8C81			;40 cells display
	dc.w	$8D3F			;H Scroll - $FC00
	dc.w	$8E00			;Unused
	dc.w	$8F02			;VDP auto increment
	dc.w	$9001			;64 cells scroll
	dc.w	$9100			;Window H position
	dc.w	$9200			;Window V position
	dc.w	$93FF			;DMA stuff (off)
	dc.w	$94FF			;DMA stuff (off)
	dc.w	$9500			;DMA stuff (off)
	dc.w	$9600			;DMA stuff (off)
	dc.w	$9780			;DMA stuff (off)
;
;*************************************** YM2612 Init sequence (YM-A0, YM-D0) - from public example
YM_Data_Set:
	dc.b	$22, $00 		;LFO off
	dc.b	$27, $00		;Channel 3 mode normal
	dc.b	$28, $00		;All channels off 
	dc.b	$28, $01		;
	dc.b	$28, $02		;
	dc.b	$28, $04		;
	dc.b	$28, $05		;
	dc.b	$28, $06		;
	dc.b	$2B, $00		;DAC off
	dc.b	$30, $71		;DT1/MUL
	dc.b	$34, $0D		;
	dc.b	$38, $33		;
	dc.b	$3C, $01		;
	dc.b	$40, $23		;Total Level
	dc.b	$44, $2D		;
	dc.b	$48, $26		;
	dc.b	$4C, $00		;
	dc.b	$50, $5F		;RS/AR
	dc.b	$54, $99		;
	dc.b	$58, $5F		;
	dc.b	$5C, $94		;
	dc.b	$60, $05		;AM/D1R
	dc.b	$64, $05		;
	dc.b	$68, $05		;
	dc.b	$6C, $07		;
	dc.b	$70, $02		;D2R
	dc.b	$74, $02		;
	dc.b	$78, $02		;
	dc.b	$7C, $02		;
	dc.b	$80, $11		;D1L/RR
	dc.b	$84, $11		;
	dc.b	$88, $11		;
	dc.b	$8C, $A6		;
	dc.b	$90, $00		;Proprietary
	dc.b	$94, $00		;
	dc.b	$98, $00		;
	dc.b	$9C, $00		;
	dc.b	$B0, $32		;Feedback/algorithm
	dc.b	$B4, $C0		;Both speakers on
	dc.b	$A4, $22		;Set frequency
	dc.b	$A0, $68		;
	dc.b	$28, $F0		;Key on
;
;*************************************** Z80 Subroutine
z80_sub:
	dc.b	$C3, $46, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;0x00
	dc.b	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;0x20
	dc.b	$00, $00, $00, $00, $00, $00, $F3, $ED, $56, $31, $00, $20, $3A, $39, $00, $B7, $CA, $4C, $00, $21, $3A, $00, $11, $40, $00, $01, $06, $00, $ED, $B0, $3E, $00 ;0x40
	dc.b	$32, $39, $00, $3E, $B4, $32, $02, $40, $3E, $C0, $32, $03, $40, $3E, $2B, $32, $00, $40, $3E, $80, $32, $01, $40, $3A, $43, $00, $4F, $3A, $44, $00, $47, $3E ;0x60
	dc.b	$06, $3D, $C2, $81, $00, $21, $00, $60, $3A, $41, $00, $07, $77, $3A, $42, $00, $77, $0F, $77, $0F, $77, $0F, $77, $0F, $77, $0F, $77, $0F, $77, $0F, $77, $3A ;0x80
	dc.b	$40, $00, $6F, $3A, $41, $00, $F6, $80, $67, $3E, $2A, $32, $00, $40, $7E, $32, $01, $40, $21, $40, $00, $7E, $C6, $01, $77, $23, $7E, $CE, $00, $77, $23, $7E ;0xA0
	dc.b	$CE, $00, $77, $3A, $39, $00, $B7, $C2, $4C, $00, $0B, $78, $B1, $C2, $7F, $00, $3A, $45, $00, $B7, $CA, $4C, $00, $3D, $3A, $45, $00, $06, $FF, $0E, $FF, $C3 ;0xC0
	dc.b	$7F, $00 ;0xE0
;
; A label defining the end of ROM so we can compute the total size.
ROM_End:
