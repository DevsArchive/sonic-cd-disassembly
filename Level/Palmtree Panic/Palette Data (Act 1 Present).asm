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
	dc.l	Pal_LevelProto			; Level (prototype)
	dc.w	palette+$20
	dc.w	$17
	dc.l	Pal_Level			; Level
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

; Level palette
Pal_Level:
	incbin	"Level/Palmtree Panic/Data/Palette (Present).bin"
	even

; Level palette (prototype)
Pal_LevelProto:
	incbin	"Level/Palmtree Panic/Data/Palette (Present, Prototype).bin"
	even

; Level palette (loaded at the end of the level after going past Amy)
Pal_LevelEnd:
	incbin	"Level/Palmtree Panic/Data/Palette (Present).bin"
	even

; -------------------------------------------------------------------------
