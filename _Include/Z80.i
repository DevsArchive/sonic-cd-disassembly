; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Z80 definitions
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Addresses
; -------------------------------------------------------------------------

; RAM
Z80RAM		EQU	0000h			; RAM start
Z80RAME		EQU	2000h			; RAM end
Z80RAMS		EQU	Z80RAME-Z80RAM		; RAM size

; Sound
YMADDR0		EQU	4000h			; YM2612 address port 0
YMDATA0		EQU	4001h			; YM2612 data port 0
YMADDR1		EQU	4002h			; YM2612 address port 1
YMDATA1		EQU	4003h			; YM2612 data port 1
PSGCTRL		EQU	7F11h			; PSG control port

; Bank
BANKSET		EQU	6000h			; Bank set
BANKWND		EQU	8000h			; Bank window

; -------------------------------------------------------------------------
; 128 = 80h = z80, 32988 = 80DCh = z80unDoC 
; -------------------------------------------------------------------------

notZ80 function cpu,(cpu<>128)&&(cpu<>32988)

; -------------------------------------------------------------------------
; Make ds work in Z80 code without creating a new segment
; -------------------------------------------------------------------------

ds macro
	if notZ80(MOMCPU)
		!ds.ATTRIBUTE ALLARGS
	else
		rept ALLARGS
			db 0
		endm
	endif
	endm

; -------------------------------------------------------------------------
