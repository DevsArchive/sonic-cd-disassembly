; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------

	include	"_Include/Common.i"

; -------------------------------------------------------------------------
; Header
; -------------------------------------------------------------------------

	dc.b	"SEGADISCSYSTEM  "		; Disk type ID
	dc.b	"SEGASONICCD", 0		; Volume ID
	dc.w	$0100				; Volume version
	dc.w	$0001				; CD-ROM = $0001
	dc.b	"SONICCD    ", 0		; System name
	dc.w	$0000				; System version
	dc.w	$0000				; Always 0
	if filesize("_Built/System/IP.BIN")<=$600
		dc.l	$00000200		; IP disk address
		dc.l	$00000600		; IP load size
	else
		dc.l	$00000800		; IP disk address
		dc.l	SPStart-$800		; IP load size
	endif
	dc.l	$00000000			; IP entry offset
	dc.l	$00000000			; IP work RAM size
	dc.l	SPStart				; SP disk address
	dc.l	$8000-SPStart			; SP load size
	dc.l	$00000000			; SP entry offset
	dc.l	$00000000			; SP work RAM size
	dc.b	"10061993"			; Build date
	align	$100, $20

	dc.b	"SEGA GENESIS    "		; Hardware ID
	dc.b	"(C)SEGA 1993.OCT"		; Release date
	dc.b	"SONIC THE HEDGEHOG-CD                           "
	dc.b	"SONIC THE HEDGEHOG-CD                           "
	dc.b	"GM MK-4407 -00  "		; Game version
	dc.b	"J               "		; I/O support
	dc.b	"                "		; Space
	align	$1F0, $20
	if REGION=JAPAN				; Region
		dc.b	"J"
	elseif REGION=USA
		dc.b	"U"
	elseif REGION=EUROPE
		dc.b	"E"
	endif
	align	$200, $20

; -------------------------------------------------------------------------
; Programs
; -------------------------------------------------------------------------

	incbin	"_Built/System/IP.BIN"
	align	$800
SPStart:
	incbin	"_Built/System/SP.BIN"
	align	$8000

; -------------------------------------------------------------------------
; File data
; -------------------------------------------------------------------------

	incbin	"_Built/System/FILES.BIN", $8000
	align	$800

; -------------------------------------------------------------------------