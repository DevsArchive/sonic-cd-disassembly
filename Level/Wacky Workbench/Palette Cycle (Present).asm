; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Wacky Workbench Present palette cycle
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Handle palette cycling
; -------------------------------------------------------------------------

PaletteCycle:
	lea	palCycleTimers.w,a5		; Prepare palette cycle variables
	lea	palCycleSteps.w,a4

	lea	PalCycleScript1,a1		; Cycle color 1
	lea	PalCycleColors1,a2
	bsr.w	CycleColor

	lea	PalCycleScript2,a1		; Cycle color 2
	lea	PalCycleColors2,a2
	bsr.w	CycleColor

	lea	PalCycleScript3,a1		; Cycle color 3
	lea	PalCycleColors3,a2
	bsr.w	CycleColor

	lea	PalCycleScript4,a1		; Cycle color 4
	lea	PalCycleColors4,a2

; -------------------------------------------------------------------------

	include	"Level/Palette Cycle Script.asm"

; -------------------------------------------------------------------------

; Color 1
PalCycleScript1:
	dc.b	$21, 3				; Palette index, number of frames
	dc.b	1, 0				; Frame length, color index
	dc.b	1, 1
	dc.b	1, 2
PalCycleColors1:
	dc.w	$0EE, $00E, $000

; Color 2
PalCycleScript2:
	dc.b	$22, 3
	dc.b	1, 0
	dc.b	1, 1
	dc.b	1, 2
PalCycleColors2:
	dc.w	$00E, $000, $0EE

; Color 3
PalCycleScript3:
	dc.b	$23, 3
	dc.b	1, 0
	dc.b	1, 1
	dc.b	1, 2
PalCycleColors3:
	dc.w	$000, $0EE, $00E

; Color 4
PalCycleScript4:
	dc.b	$31, $5B
	dc.b	1, 1
	dc.b	1, 0
	dc.b	1, 2
	dc.b	1, 0
	dc.b	1, 3
	dc.b	1, 0
	dc.b	1, 1
	dc.b	1, 0
	dc.b	1, 2
	dc.b	1, 0
	dc.b	1, 3
	dc.b	1, 0
	dc.b	1, 1
	dc.b	1, 0
	dc.b	1, 2
	dc.b	1, 0
	dc.b	1, 3
	dc.b	1, 0
	dc.b	1, 1
	dc.b	1, 0
	dc.b	1, 2
	dc.b	1, 0
	dc.b	1, 3
	dc.b	1, 0
	dc.b	1, 1
	dc.b	1, 0
	dc.b	1, 2
	dc.b	1, 0
	dc.b	1, 3
	dc.b	1, 0
	dc.b	1, 1
	dc.b	1, 0
	dc.b	1, 2
	dc.b	1, 0
	dc.b	1, 3
	dc.b	1, 0
	dc.b	1, 1
	dc.b	1, 0
	dc.b	1, 2
	dc.b	1, 0
	dc.b	1, 3
	dc.b	1, 0
	dc.b	1, 1
	dc.b	1, 0
	dc.b	1, 2
	dc.b	1, 0
	dc.b	1, 3
	dc.b	1, 0
	dc.b	1, 1
	dc.b	1, 0
	dc.b	1, 2
	dc.b	1, 0
	dc.b	1, 3
	dc.b	1, 0
	dc.b	1, 1
	dc.b	1, 0
	dc.b	1, 2
	dc.b	1, 0
	dc.b	1, 3
	dc.b	1, 0
	dc.b	1, 1
	dc.b	1, 0
	dc.b	1, 2
	dc.b	1, 0
	dc.b	1, 3
	dc.b	1, 0
	dc.b	1, 1
	dc.b	1, 0
	dc.b	1, 2
	dc.b	1, 0
	dc.b	1, 3
	dc.b	1, 0
	dc.b	1, 1
	dc.b	1, 0
	dc.b	1, 2
	dc.b	1, 0
	dc.b	1, 3
	dc.b	1, 0
	dc.b	1, 1
	dc.b	1, 0
	dc.b	1, 2
	dc.b	1, 0
	dc.b	1, 3
	dc.b	1, 0
	dc.b	1, 1
	dc.b	1, 0
	dc.b	1, 2
	dc.b	1, 0
	dc.b	1, 3
	dc.b	1, 0
	dc.b	$1E, 1
PalCycleColors4:
	dc.w	$000, $C28, $0EE, $EEE

; -------------------------------------------------------------------------
