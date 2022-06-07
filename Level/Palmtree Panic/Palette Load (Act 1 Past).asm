; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Palmtree Panic Act 1 Past palette loading functions
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Load a palette into the fade buffer
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Palette ID
; -------------------------------------------------------------------------

LoadFadePal:
	lea	PaletteTable,a1			; Get pointer to palette metadata
	lsl.w	#3,d0
	adda.w	d0,a1

	movea.l	(a1)+,a2			; Get palette pointer
	movea.w	(a1)+,a3			; Get palette buffer pointer
	adda.w	#fadePalette-palette,a3
	move.w	(a1)+,d7			; Get palette length

.Load:
	move.l	(a2)+,(a3)+
	dbf	d7,.Load			; Loop until palette is loaded

	rts

; -------------------------------------------------------------------------
; Load a palette into the palette buffer
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Palette ID
; -------------------------------------------------------------------------

LoadPalette:
	lea	PaletteTable,a1			; Get pointer to palette metadata
	lsl.w	#3,d0
	adda.w	d0,a1

	movea.l	(a1)+,a2			; Get palette pointer
	movea.w	(a1)+,a3			; Get palette buffer pointer
	move.w	(a1)+,d7			; Get palette length

.Load:
	move.l	(a2)+,(a3)+
	dbf	d7,.Load			; Loop until palette is loaded

	rts

; -------------------------------------------------------------------------
; Load a palette into the water palette buffer
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Palette ID
; -------------------------------------------------------------------------

LoadWaterPal:
	lea	PaletteTable,a1			; Get pointer to palette metadata
	lsl.w	#3,d0
	adda.w	d0,a1

	movea.l	(a1)+,a2			; Get palette pointer
	movea.w	(a1)+,a3			; Get palette buffer pointer
	suba.w	#palette-waterPalette,a3
	move.w	(a1)+,d7			; Get palette length

.Load:
	move.l	(a2)+,(a3)+
	dbf	d7,.Load			; Loop until palette is loaded

	rts

; -------------------------------------------------------------------------
; Palette table
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
	dc.l	Pal_PPZPastProto		; Palmtree Panic Past (prototype)
	dc.w	palette+$20
	dc.w	$17
	dc.l	Pal_PPZPast			; Palmtree Panic Past
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

; Palmtree Panic Past palette
Pal_PPZPast:
	incbin	"Level/Palmtree Panic/Data/Palette (Past).bin"
	even

; Palmtree Panic Past palette (prototype)
Pal_PPZPastProto:
	incbin	"Level/Palmtree Panic/Data/Palette (Past, Prototype).bin"
	even

; -------------------------------------------------------------------------
