; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Title screen secret variables
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Variables
; -------------------------------------------------------------------------

	rsset	WORKRAM+$FF008000
VARSSTART	rs.b	0			; Start of variables
		rs.b	$4000
nemBuffer	rs.b	$200			; Nemesis decompression buffer
		rs.b	$3700
palette		rs.w	$40			; Palette buffer
fadePalette	rs.w	$40			; Fade palette buffer
fadedOut	rs.b	1			; Faded out flag
		rs.b	$45
savedSR		rs.w	1			; Saved status register
		rs.b	$1B8
VARSLEN		EQU	__rs-VARSSTART		; Size of variables area

ctrlData	EQU	GACOMCMDE		; Controller data
ctrlHold	EQU	ctrlData		; Controller held buttons data
ctrlTap		EQU	ctrlData+1		; Controller tapped buttons data

; -------------------------------------------------------------------------
