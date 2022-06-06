; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Palmtree Panic Act 1 Present palette data
; -------------------------------------------------------------------------

PaletteTable:
	dc.l	Pal_S1SegaBG			; Sonic 1 SEGA screen background (leftover)
	dc.w	palette
	dc.w	$1F
	dc.l	Pal_S1Title			; Sonic 1 title screen (leftover)
	dc.w	palette
	dc.w	$1F
	dc.l	Pal_S1LevSel			; Sonic 1 level select screen (leftover)
	dc.w	palette
	dc.w	$1F
	dc.l	Pal_Sonic			; Sonic
	dc.w	palette
	dc.w	7
	dc.l	Pal_PPZPresentProto		; Palmtree Panic Present (leftover from the v0.02 prototype)
	dc.w	palette+$20
	dc.w	$17
	dc.l	Pal_PPZPresent			; Palmtree Panic Present
	dc.w	palette+$20
	dc.w	$17

; -------------------------------------------------------------------------

; Sonic 1 SEGA screen background (leftover, data completely removed)
Pal_S1SegaBG:

; Sonic 1 title screen (leftover)
Pal_S1Title:
	incbin	"Level/_Data/Palette (Sonic 1 Title).bin"
	even

; Sonic 1 level select screen (leftover)
Pal_S1LevSel:
	incbin	"Level/_Data/Palette (Sonic 1 Level Select).bin"
	even

; Sonic palette
Pal_Sonic:
	incbin	"Level/_Objects/Sonic/Data/Palette.bin"
	even

; Palmtree Panic Present palette
Pal_PPZPresent:
	incbin	"Level/Palmtree Panic/Data/Palette (Present).bin"
	even

; Palmtree Panic Present palette (leftover from the v0.02 prototype)
Pal_PPZPresentProto:
	incbin	"Level/Palmtree Panic/Data/Palette (Present, Prototype).bin"
	even

; Palmtree Panic Present palette (loaded at the end of the level after going past Amy)
Pal_PPZPresentEnd:
	incbin	"Level/Palmtree Panic/Data/Palette (Present).bin"
	even

; -------------------------------------------------------------------------
