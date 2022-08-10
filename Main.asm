; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------

	include	"_Include/Common.i"

; -------------------------------------------------------------------------
; Header
; -------------------------------------------------------------------------

	dc.b	"SEGADISCSYSTEM  "		; Disk type ID
	if REGION=JAPAN				; Volume ID
		dc.b	"SEGAIPSAMP ", 0
	else
		dc.b	"SEGASONICCD", 0
	endif
	dc.w	$0100				; Volume version
	dc.w	$0001				; CD-ROM = $0001
	dc.b	"SONICCD    ", 0		; System name
	dc.w	$0000				; System version
	dc.w	$0000				; Always 0
	dc.l	$00000800			; IP disk address
	dc.l	$00000800			; IP load size
	dc.l	$00000000			; IP entry offset
	dc.l	$00000000			; IP work RAM size
	dc.l	$00001000			; SP disk address
	dc.l	$00007000			; SP load size
	dc.l	$00000000			; SP entry offset
	dc.l	$00000000			; SP work RAM size
	if REGION=JAPAN				; Build date
		dc.b	"08061993"
	elseif REGION=USA
		dc.b	"10061993"
	else
		dc.b	"08271993"
	endif
	align	$100, $20

	if REGION=JAPAN
		dc.b	"SEGA MEGA DRIVE "	; Hardware ID
		dc.b	"(C)SEGA 1993.AUG"	; Release date
	elseif REGION=USA
		dc.b	"SEGA GENESIS    "	; Hardware ID
		dc.b	"(C)SEGA 1993.OCT"	; Release date
	else
		dc.b	"SEGA MEGA DRIVE "	; Hardware ID
		dc.b	"(C)SEGA 1993.AUG"	; Release date
	endif
	dc.b	"SONIC THE HEDGEHOG-CD                           "
	dc.b	"SONIC THE HEDGEHOG-CD                           "
	if REGION=JAPAN				; Game version
		dc.b	"GM G-6021  -00  "
	elseif REGION=USA
		dc.b	"GM MK-4407 -00  "
	else
		dc.b	"GM MK-4407-00   "
	endif
	dc.b	"J               "		; I/O support
	dc.b	"                "		; Space
	align	$1F0, $20
	if REGION=JAPAN				; Region
		dc.b	"J"
	elseif REGION=USA
		dc.b	"U"
	else
		dc.b	"E"
	endif
	align	$200, $20

; -------------------------------------------------------------------------
; Initial program
; -------------------------------------------------------------------------

	incbin	"_Built/Misc/IP.BIN"

; -------------------------------------------------------------------------
; Version number?	
; -------------------------------------------------------------------------

	align	$FFE
	if REGION=JAPAN
		dc.w	$0106
	else
		dc.w	$0109
	endif

; -------------------------------------------------------------------------
; System program
; -------------------------------------------------------------------------

SPStart:
	incbin	"_Built/Misc/SP.BIN"
	align	$8000

; -------------------------------------------------------------------------
; File data
; -------------------------------------------------------------------------

	incbin	"_Built/Misc/FILES.BIN", $8000
	align	$800

; -------------------------------------------------------------------------