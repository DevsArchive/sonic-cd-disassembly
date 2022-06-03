; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Level
; -------------------------------------------------------------------------
; Special thanks to flamewing and TheStoneBanana for help on this!
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Includes
; -------------------------------------------------------------------------

	include	"_inc/common.i"
	include	"_inc/maincpu.i"
	include	"_inc/mainvars.i"
	include	"_inc/sound.i"
	include	"_inc/mmd.i"
	include	"level/variables.i"

; -------------------------------------------------------------------------
; MMD header
; -------------------------------------------------------------------------

	MMD	0, &
		WORDRAM2M, 0, &
		JmpTo_Start, JmpTo_HInt, JmpTo_VInt

; -------------------------------------------------------------------------
; Program start
; -------------------------------------------------------------------------

JmpTo_Start:
	jmp	Start

; -------------------------------------------------------------------------
; Error trap
; -------------------------------------------------------------------------

JmpTo_Error:
	jmp	ErrorTrap

; -------------------------------------------------------------------------
; H-INT routine
; -------------------------------------------------------------------------

JmpTo_HInt:
	jmp	HInterrupt

; -------------------------------------------------------------------------
; V-INT routine
; -------------------------------------------------------------------------

JmpTo_VInt:
	jmp	VInterrupt

; -------------------------------------------------------------------------
; Error trap loop
; -------------------------------------------------------------------------

ErrorTrap:
	nop
	nop
	bra.s	ErrorTrap

; -------------------------------------------------------------------------
; Entry point
; -------------------------------------------------------------------------

Start:
	btst	#6,IOCTRL3			; Have the controller ports been initialized?
	beq.s	.DoInit				; If so, do start RAM clear
	cmpi.l	#'init',lvlInitFlag		; Have we already initialized?
	beq.w	.GameInit			; If so, branch

.DoInit:
	lea	unkLvlBuffer,a6			; Clear RAM section starting at $FF1000
	moveq	#0,d7
	move.w	#$FF,d6				; Clear $400 bytes...
	move.w	#$7F,d6				; ...or actually $200 bytes!

.ClearRAM:
	move.l	d7,(a6)+
	dbf	d6,.ClearRAM			; Clear until finished

	move.b	VERSION,d0			; Get hardware region
	andi.b	#$C0,d0
	move.b	d0,versionCache

	move.l	#'init',lvlInitFlag		; Mark as done

.GameInit:
	bsr.w	InitVDP				; Initialize VDP
	bsr.w	InitJoypads			; Initialize joypads

	move.b	#0,gameMode.w			; Set game mode to "level"

	move.b	gameMode.w,d0			; Go to the current game mode routine
	andi.w	#$1C,d0
	jmp	GameModes(pc,d0.w)

; -------------------------------------------------------------------------
; Game modes
; -------------------------------------------------------------------------

GameModes:
	bra.w	LevelStart			; Level

; -------------------------------------------------------------------------
; Handle palette cycling
; -------------------------------------------------------------------------

PalCycle:
	bra.w	PalCycle_Do			; Skip over prototype code

; Dead code: this is the palette cycling routine from the v0.02 prototype

	lea	PPZ_ProtoPalCyc1,a0		; Prepare first palette data set
	subq.b	#1,palCycleTimers.w		; Decrement timer
	bpl.s	.SkipCycle1			; If this cycle's timer isn't done, branch
	move.b	#7,palCycleTimers.w		; Reset the timer

	moveq	#0,d0				; Get the current palette cycle frame
	move.b	palCycleSteps.w,d0
	cmpi.b	#2,d0				; Should we wrap it back to 0?
	bne.s	.IncCycle1			; If not, don't worry about it
	moveq	#0,d0				; If so, then do it
	bra.s	.ApplyCycle1

.IncCycle1:
	addq.b	#1,d0				; Increment the palette cycle frame

.ApplyCycle1:
	move.b	d0,palCycleSteps.w

	lsl.w	#3,d0				; Store the currnent palette cycle data in palette RAM
	lea	palette+$6A.w,a1
	move.l	(a0,d0.w),(a1)+
	move.l	4(a0,d0.w),(a1)

.SkipCycle1:
						; Prepare second palette data set
	adda.w	#PPZ_ProtoPalCyc2-PPZ_ProtoPalCyc1,a0
	subq.b	#1,palCycleTimers+1.w		; Decrement timer
	bpl.s	.End				; If this cycle's timer isn't done, branch
	move.b	#5,palCycleTimers+1.w		; Reset the timer

	moveq	#0,d0				; Get the current palette cycle frame
	move.b	palCycleSteps+1.w,d0
	cmpi.b	#2,d0				; Should we wrap it back to 0?
	bne.s	.IncCycle2			; If not, don't worry about it
	moveq	#0,d0				; If so, then do it
	bra.s	.ApplyCycle2

.IncCycle2:
	addq.b	#1,d0				; Increment the palette cycle frame

.ApplyCycle2:
	move.b	d0,palCycleSteps+1.w

	andi.w	#3,d0				; Store the currnent palette cycle data in palette RAM
	lsl.w	#3,d0
	lea	palette+$58.w,a1
	move.l	(a0,d0.w),(a1)+
	move.l	4(a0,d0.w),(a1)

.End:
	rts

; -------------------------------------------------------------------------
; Prototype palette cycle data
; -------------------------------------------------------------------------

PPZ_ProtoPalCyc1:
	dc.w	$ECC, $ECA, $EEE, $EA8
	dc.w	$EA8, $ECC, $ECC, $ECA
	dc.w	$ECA, $EA8, $ECA, $ECC

PPZ_ProtoPalCyc2:
	dc.w	$ECA, $EA8, $C60, $E86
	dc.w	$EA8, $E86, $C60, $ECA
	dc.w	$E86, $ECA, $C60, $EA8

; -------------------------------------------------------------------------
; The actual final palette cycling function
; -------------------------------------------------------------------------

PalCycle_Do:
	lea	palCycleTimers.w,a5		; Prepare palette cycle variables
	lea	palCycleSteps.w,a4

	lea	PPZ_PalCyc_Script1,a1		; Cycle color 1
	lea	PPZ_PalCyc_Colors1,a2
	bsr.s	PalCycle_OneColor

	lea	PPZ_PalCyc_Script2,a1		; Cycle color 2
	lea	PPZ_PalCyc_Colors2,a2
	bsr.s	PalCycle_OneColor

	lea	PPZ_PalCyc_Script3,a1		; Cycle color 3
	lea	PPZ_PalCyc_Colors3,a2
	bsr.s	PalCycle_OneColor

	lea	PPZ_PalCyc_Script4,a1		; Cycle color 4
	lea	PPZ_PalCyc_Colors4,a2
	bsr.s	PalCycle_OneColor

	lea	PPZ_PalCyc_Script5,a1		; Cycle color 5
	lea	PPZ_PalCyc_Colors5,a2
	bsr.s	PalCycle_OneColor

	lea	PPZ_PalCyc_Script6,a1		; Cycle color 6
	lea	PPZ_PalCyc_Colors6,a2

; -------------------------------------------------------------------------
; Cycle a color in the palette
; -------------------------------------------------------------------------
; PARAMETERS:
;	a4.l - Pointer to cycle frame
;	a5.l - Pointer to timer
; -------------------------------------------------------------------------

PalCycle_OneColor:
	subq.b	#1,(a5)				; Decrement timer
	bpl.s	.End				; If it hasn't run out, branch

	moveq	#0,d0
	move.b	(a1)+,d0			; Get palette index
	move.b	(a1)+,d1			; Get total number of cycle frames

	add.w	d0,d0				; Get pointer to palette entry
	lea	palette.w,a3
	lea	(a3,d0.w),a3

	moveq	#0,d0				; Get current cycle frame
	move.b	(a4),d0
	addq.b	#1,d0				; Increment it
	cmp.b	d1,d0				; Should we wrap it back to 0?
	bcs.s	.NoReset			; If not, don't worry about it
	moveq	#0,d0				; If so, then do it

.NoReset:
	move.b	d0,(a4)

	add.w	d0,d0
	move.b	(a1,d0.w),(a5)			; Get cycle frame length
	move.b	1(a1,d0.w),d0			; Get cycle color index
	ext.w	d0
	add.w	d0,d0
	move.w	(a2,d0.w),(a3)			; Store the color in palette RAM

.End:
	adda.w	#1,a4				; Go to next cycle frame and timer
	adda.w	#1,a5
	rts

; -------------------------------------------------------------------------

; Color 1
PPZ_PalCyc_Script1:
	dc.b	$31, 3				; Palette index, number of frames
	dc.b	8, 0				; Frame length, color index
	dc.b	8, 1
	dc.b	8, 2
PPZ_PalCyc_Colors1:
	dc.w	$EEE, $CC6, $EEA

; Color 2
PPZ_PalCyc_Script2:
	dc.b	$32, 3
	dc.b	8, 0
	dc.b	8, 1
	dc.b	8, 2
PPZ_PalCyc_Colors2:
	dc.w	$EEA, $EEE, $CC6

; Color 3
PPZ_PalCyc_Script3:
	dc.b	$33, 3
	dc.b	8, 0
	dc.b	8, 1
	dc.b	8, 2
PPZ_PalCyc_Colors3:
	dc.w	$CC6, $EEA, $EEE

; Color 4
PPZ_PalCyc_Script4:
	dc.b	$2C, 3
	dc.b	6, 0
	dc.b	6, 1
	dc.b	6, 2
PPZ_PalCyc_Colors4:
	dc.w	$ECA, $EA8, $E86

; Color 5
PPZ_PalCyc_Script5:
	dc.b	$2D, 3
	dc.b	6, 0
	dc.b	6, 1
	dc.b	6, 2
PPZ_PalCyc_Colors5:
	dc.w	$EA8, $E86, $ECA

; Color 6
PPZ_PalCyc_Script6:
	dc.b	$2F, 3
	dc.b	6, 0
	dc.b	6, 1
	dc.b	6, 2
PPZ_PalCyc_Colors6:
	dc.w	$C86, $ECA, $EA8

; -------------------------------------------------------------------------
; Fade the screen from black
; -------------------------------------------------------------------------

FadeFromBlack:
	moveq	#0,d0				; Get starting palette fill location
	lea	palette.w,a0
	move.b	palFadeStart.w,d0
	adda.w	d0,a0
	moveq	#0,d1				; Get palette fill value (black)
	move.b	palFadeLen.w,d0			; Get palette fill length

.Clear:
	move.w	d1,(a0)+
	dbf	d0,.Clear			; Fill until finished

	move.w	#(7*3),d4			; Prepare to do fading

.Fade:
	move.b	#$12,vintRoutine.w		; VSync
	bsr.w	VSync
	bsr.s	FadeColorsFromBlack		; Fade colors once
	bsr.w	ProcessPLCs			; Process PLCs
	dbf	d4,.Fade			; Loop until fading is done

	rts

; -------------------------------------------------------------------------

FadeColorsFromBlack:
	moveq	#0,d0				; Get starting palette fade locations
	lea	palette.w,a0
	lea	fadePalette.w,a1
	move.b	palFadeStart.w,d0
	adda.w	d0,a0
	adda.w	d0,a1
	move.b	palFadeLen.w,d0			; Get palette fade length

.Loop:
	bsr.s	FadeColorFromBlack		; Fade a color
	dbf	d0,.Loop			; Loop until finished

	cmpi.b	#1,levelZone			; Are we in level ID 1 (Labyrinth Zone in Sonic 1)?
	bne.s	.End				; If not, branch

	moveq	#0,d0				; Get starting palette fade locations for water
	lea	waterPalette.w,a0
	lea	waterFadePal.w,a1
	move.b	palFadeStart.w,d0
	adda.w	d0,a0
	adda.w	d0,a1
	move.b	palFadeLen.w,d0			; Get palette fade length

.LoopWater:
	bsr.s	FadeColorFromBlack		; Fade a color
	dbf	d0,.LoopWater			; Loop until finished

.End:
	rts

; -------------------------------------------------------------------------

FadeColorFromBlack:
	move.w	(a1)+,d2			; Get target color
	move.w	(a0),d3				; Get current color
	cmp.w	d2,d3				; Are they the same?
	beq.s	.Skip				; If so, branch

.Blue:
	move.w	d3,d1				; Fade blue
	addi.w	#$200,d1
	cmp.w	d2,d1				; Is the blue component done?
	bhi.s	.Green				; If so, start fading green
	move.w	d1,(a0)+			; Update color
	rts

.Green:
	move.w	d3,d1				; Fade green
	addi.w	#$20,d1
	cmp.w	d2,d1				; Is the green component done?
	bhi.s	.Red				; If so, start fading red
	move.w	d1,(a0)+			; Update color
	rts

.Red:
	addq.w	#2,(a0)+			; Fade red
	rts


.Skip:
	addq.w	#2,a0				; Skip over this color
	rts

; -------------------------------------------------------------------------
; Fade the screen to black
; -------------------------------------------------------------------------

FadeToBlack:
	move.w	#$3F,palFadeInfo.w		; Set palette fade start and length

	move.w	#(7*3),d4			; Prepare to do fading

.Fade:
	move.b	#$12,vintRoutine.w		; VSync
	bsr.w	VSync
	bsr.s	FadeColorsToBlack		; Fade colors once
	bsr.w	ProcessPLCs			; Process PLCs
	dbf	d4,.Fade			; Loop until fading is done

	rts

; -------------------------------------------------------------------------

FadeColorsToBlack:
	moveq	#0,d0				; Get starting palette fade location
	lea	palette.w,a0
	move.b	palFadeStart.w,d0
	adda.w	d0,a0
	move.b	palFadeLen.w,d0			; Get palette fade length

.Loop:
	bsr.s	FadeColorToBlack		; Fade a color
	dbf	d0,.Loop			; Loop until finished

	moveq	#0,d0				; Get starting palette fade location for water
	lea	waterPalette.w,a0
	move.b	palFadeStart.w,d0
	adda.w	d0,a0
	move.b	palFadeLen.w,d0			; Get palette fade length

.LoopWater:
	bsr.s	FadeColorToBlack		; Fade a color
	dbf	d0,.LoopWater			; Loop until finished

	rts

; -------------------------------------------------------------------------

FadeColorToBlack:
	move.w	(a0),d2				; Get color
	beq.s	.Skip				; If it's already black, branch

.Red:
	move.w	d2,d1				; Get red component
	andi.w	#$E,d1				; Is it already 0?
	beq.s	.Green				; If so, check green
	subq.w	#2,(a0)+			; Fade red
	rts

.Green:
	move.w	d2,d1				; Get green component
	andi.w	#$E0,d1				; Is it already 0?
	beq.s	.Blue				; If so, check blue
	subi.w	#$20,(a0)+			; Fade green
	rts

.Blue:
	move.w	d2,d1				; Get blue component
	andi.w	#$E00,d1			; Is it already 0?
	beq.s	.Skip				; If so, we're done
	subi.w	#$200,(a0)+			; Fade blue
	rts

.Skip:
	addq.w	#2,a0				; Skip over this color
	rts

; -------------------------------------------------------------------------
; Fade the screen from white
; -------------------------------------------------------------------------

FadeFromWhite:
	move.w	#$3F,palFadeInfo.w		; Set palette fade start and length

	moveq	#0,d0				; Get starting palette fill location
	lea	palette.w,a0
	move.b	palFadeStart.w,d0
	adda.w	d0,a0
	move.w	#$EEE,d1			; Get palette fill value (whiyte)
	move.b	palFadeLen.w,d0			; Get palette fill length

.Fill:
	move.w	d1,(a0)+
	dbf	d0,.Fill			; Fill until finished

	move.w	#(7*3),d4			; Prepare to do fading

.Fade:
	move.b	#$12,vintRoutine.w		; VSync
	bsr.w	VSync
	bsr.s	FadeColorsFromWhite		; Fade colors once
	bsr.w	ProcessPLCs			; Process PLCs
	dbf	d4,.Fade			; Loop until fading is done

	rts

; -------------------------------------------------------------------------

FadeColorsFromWhite:
	moveq	#0,d0				; Get starting palette fade locations
	lea	palette.w,a0
	lea	fadePalette.w,a1
	move.b	palFadeStart.w,d0
	adda.w	d0,a0
	adda.w	d0,a1
	move.b	palFadeLen.w,d0			; Get palette fade length

.Loop:
	bsr.s	FadeColorFromWhite		; Fade a color
	dbf	d0,.Loop			; Loop until finished

	cmpi.b	#1,levelZone			; Are we in level ID 1 (Labyrinth Zone in Sonic 1)?
	bne.s	.End				; If not, branch

	moveq	#0,d0				; Get starting palette fade locations for water
	lea	waterPalette.w,a0
	lea	waterFadePal.w,a1
	move.b	palFadeStart.w,d0
	adda.w	d0,a0
	adda.w	d0,a1
	move.b	palFadeLen.w,d0			; Get palette fade length

.LoopWater:
	bsr.s	FadeColorFromWhite		; Fade a color
	dbf	d0,.LoopWater			; Loop until finished

.End:
	rts

; -------------------------------------------------------------------------

FadeColorFromWhite:
	move.w	(a1)+,d2			; Get target color
	move.w	(a0),d3				; Get current color
	cmp.w	d2,d3				; Are they the same?
	beq.s	.Skip				; If so, branch

	move.w	d3,d1				; Fade blue
	subi.w	#$200,d1			; Is it already 0?
	bcs.s	.Green				; If so, start fading green
	cmp.w	d2,d1				; Is the blue component done?
	bcs.s	.Green				; If so, start fading green
	move.w	d1,(a0)+			; Update color
	rts

.Green:
	move.w	d3,d1				; Fade green
	subi.w	#$20,d1				; Is it already 0?
	bcs.s	.Red				; If so, start fading red
	cmp.w	d2,d1				; Is the green component done?
	bcs.s	.Red				; If so, start fading red
	move.w	d1,(a0)+			; Update color
	rts

.Red:
	subq.w	#2,(a0)+			; Fade red
	rts

.Skip:
	addq.w	#2,a0				; Skip over this color
	rts

; -------------------------------------------------------------------------
; Fade the screen to white
; -------------------------------------------------------------------------

FadeToWhite:
	move.w	#$3F,palFadeInfo.w		; Set palette fade start and length

	move.w	#(7*3),d4			; Prepare to do fading

.Fade:
	move.b	#$12,vintRoutine.w		; VSync
	bsr.w	VSync
	bsr.s	FadeColorsToWhite		; Fade colors once
	bsr.w	ProcessPLCs			; Process PLCs
	dbf	d4,.Fade			; Loop until fading is done

	rts

; -------------------------------------------------------------------------

FadeColorsToWhite:
	moveq	#0,d0				; Get starting palette fade location
	lea	palette.w,a0
	move.b	palFadeStart.w,d0
	adda.w	d0,a0
	move.b	palFadeLen.w,d0			; Get palette fade length

.Loop:
	bsr.s	FadeColorToWhite		; Fade a color
	dbf	d0,.Loop			; Loop until finished

	moveq	#0,d0				; Get starting palette fade location for water
	lea	waterPalette.w,a0
	move.b	palFadeStart.w,d0
	adda.w	d0,a0
	move.b	palFadeLen.w,d0			; Get palette fade length

.LoopWater:
	bsr.s	FadeColorToWhite		; Fade a color
	dbf	d0,.LoopWater			; Loop until finished
	rts

; -------------------------------------------------------------------------

FadeColorToWhite:
	move.w	(a0),d2				; Get color
	cmpi.w	#$EEE,d2			; Is it already white?
	beq.s	.Skip				; If so, branch

.Red:
	move.w	d2,d1				; Get red component
	andi.w	#$E,d1				; Is it already 0?
	cmpi.w	#$E,d1
	beq.s	.Green				; If so, check green
	addq.w	#2,(a0)+			; Fade red
	rts

.Green:
	move.w	d2,d1				; Get green component
	andi.w	#$E0,d1				; Is it already 0?
	cmpi.w	#$E0,d1
	beq.s	.Blue				; If so, check blue
	addi.w	#$20,(a0)+			; Fade green
	rts

.Blue:
	move.w	d2,d1				; Get blue component
	andi.w	#$E00,d1			; Is it already 0?
	cmpi.w	#$E00,d1
	beq.s	.Skip				; If so, we're done
	addi.w	#$200,(a0)+			; Fade blue
	rts

.Skip:
	addq.w	#2,a0				; Skip over this color
	rts

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
	adda.w	#$80,a3
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
; Palette index
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

Pal_S1SegaBG:					; Sonic 1 SEGA screen background (leftover, data completely removed)

Pal_S1Title:					; Sonic 1 title screen (leftover)
	incbin	"level/r1/unused/palettes/s1title.bin"
	even

Pal_S1LevSel:					; Sonic 1 level select screen (leftover)
	incbin	"level/r1/unused/palettes/s1levsel.bin"
	even

Pal_Sonic:					; Sonic palette
	incbin	"level/r1/objects/sonic/palette.bin"
	even

Pal_PPZPresent:					; Palmtree Panic Present palette
	incbin	"level/r1/data/palette.bin"
	even

Pal_PPZPresentProto:				; Palmtree Panic Present palette (leftover from the v0.02 prototype)
	incbin	"level/r1/data/palproto.bin"
	even

Pal_PPZPresentEnd:				; Palmtree Panic Present palette (loaded at the end of the level after going past Amy)
	incbin	"level/r1/data/palette.bin"
	even

; -------------------------------------------------------------------------
; Check if an object should despawn offscreen
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Object RAM
; -------------------------------------------------------------------------

CheckObjDespawn:
	move.w	oX(a0),d0			; Get the object's chunk position
	andi.w	#$FF80,d0
	move.w	cameraX.w,d1			; Get the camera's chunk position
	subi.w	#$80,d1
	andi.w	#$FF80,d1

	sub.w	d1,d0				; Has the object gone offscreen?
	cmpi.w	#$80+(320+$40)+$80,d0
	bhi.w	.NoDraw				; If so, mark it as "gone offscreen"
	bra.w	DrawObject			; If not, draw the object's sprite

.NoDraw:
	lea	lvlObjRespawns,a2		; Prepare object respawn table
	moveq	#0,d0
	move.b	oRespawn(a0),d0			; Get the object's respawn index
	beq.s	.NoClear			; If it doesn't have one, branch
	bclr	#7,2(a2,d0.w)			; Mark it as "gone offscreen"

.NoClear:
	bra.w	DeleteObject			; Delete the object

; -------------------------------------------------------------------------
; Perform VSync
; -------------------------------------------------------------------------

VSync:
	move	#$2300,sr			; Enable interrupts

.Wait:
	tst.b	vintRoutine.w			; Has the V-INT routine run?
	bne.s	.Wait				; If not, wait for it to
	
	rts

; -------------------------------------------------------------------------
; Get the sine and cosine of an angle
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.b - Angle
; RETURNS:
;	d0.w - Sine
;	d1.w - Cosine
; -------------------------------------------------------------------------

CalcSine:
	andi.w	#$FF,d0				; Convert angle into table index
	add.w	d0,d0
	addi.w	#$80,d0				; Get cosine
	move.w	SineTable(pc,d0.w),d1
	subi.w	#$80,d0				; Get sine
	move.w	SineTable(pc,d0.w),d0
	rts

; -------------------------------------------------------------------------

SineTable:
	dc.w	$0000, $0006, $000C, $0012, $0019, $001F, $0025, $002B, $0031, $0038, $003E, $0044, $004A, $0050, $0056, $005C
	dc.w	$0061, $0067, $006D, $0073, $0078, $007E, $0083, $0088, $008E, $0093, $0098, $009D, $00A2, $00A7, $00AB, $00B0
	dc.w	$00B5, $00B9, $00BD, $00C1, $00C5, $00C9, $00CD, $00D1, $00D4, $00D8, $00DB, $00DE, $00E1, $00E4, $00E7, $00EA
	dc.w	$00EC, $00EE, $00F1, $00F3, $00F4, $00F6, $00F8, $00F9, $00FB, $00FC, $00FD, $00FE, $00FE, $00FF, $00FF, $00FF
	dc.w	$0100, $00FF, $00FF, $00FF, $00FE, $00FE, $00FD, $00FC, $00FB, $00F9, $00F8, $00F6, $00F4, $00F3, $00F1, $00EE
	dc.w	$00EC, $00EA, $00E7, $00E4, $00E1, $00DE, $00DB, $00D8, $00D4, $00D1, $00CD, $00C9, $00C5, $00C1, $00BD, $00B9
	dc.w	$00B5, $00B0, $00AB, $00A7, $00A2, $009D, $0098, $0093, $008E, $0088, $0083, $007E, $0078, $0073, $006D, $0067
	dc.w	$0061, $005C, $0056, $0050, $004A, $0044, $003E, $0038, $0031, $002B, $0025, $001F, $0019, $0012, $000C, $0006
	dc.w	$0000, $FFFA, $FFF4, $FFEE, $FFE7, $FFE1, $FFDB, $FFD5, $FFCF, $FFC8, $FFC2, $FFBC, $FFB6, $FFB0, $FFAA, $FFA4
	dc.w	$FF9F, $FF99, $FF93, $FF8B, $FF88, $FF82, $FF7D, $FF78, $FF72, $FF6D, $FF68, $FF63, $FF5E, $FF59, $FF55, $FF50
	dc.w	$FF4B, $FF47, $FF43, $FF3F, $FF3B, $FF37, $FF33, $FF2F, $FF2C, $FF28, $FF25, $FF22, $FF1F, $FF1C, $FF19, $FF16
	dc.w	$FF14, $FF12, $FF0F, $FF0D, $FF0C, $FF0A, $FF08, $FF07, $FF05, $FF04, $FF03, $FF02, $FF02, $FF01, $FF01, $FF01
	dc.w	$FF00, $FF01, $FF01, $FF01, $FF02, $FF02, $FF03, $FF04, $FF05, $FF07, $FF08, $FF0A, $FF0C, $FF0D, $FF0F, $FF12
	dc.w	$FF14, $FF16, $FF19, $FF1C, $FF1F, $FF22, $FF25, $FF28, $FF2C, $FF2F, $FF33, $FF37, $FF3B, $FF3F, $FF43, $FF47
	dc.w	$FF4B, $FF50, $FF55, $FF59, $FF5E, $FF63, $FF68, $FF6D, $FF72, $FF78, $FF7D, $FF82, $FF88, $FF8B, $FF93, $FF99
	dc.w	$FF9F, $FFA4, $FFAA, $FFB0, $FFB6, $FFBC, $FFC2, $FFC8, $FFCF, $FFD5, $FFDB, $FFE1, $FFE7, $FFEE, $FFF4, $FFFA
	; Extra data for cosine
	dc.w	$0000, $0006, $000C, $0012, $0019, $001F, $0025, $002B, $0031, $0038, $003E, $0044, $004A, $0050, $0056, $005C
	dc.w	$0061, $0067, $006D, $0073, $0078, $007E, $0083, $0088, $008E, $0093, $0098, $009D, $00A2, $00A7, $00AB, $00B0
	dc.w	$00B5, $00B9, $00BD, $00C1, $00C5, $00C9, $00CD, $00D1, $00D4, $00D8, $00DB, $00DE, $00E1, $00E4, $00E7, $00EA
	dc.w	$00EC, $00EE, $00F1, $00F3, $00F4, $00F6, $00F8, $00F9, $00FB, $00FC, $00FD, $00FE, $00FE, $00FF, $00FF, $00FF

; -------------------------------------------------------------------------
; Calculate an angle from (0,0) to (x,y)
; -------------------------------------------------------------------------
; PARAMETERS:
;	d1.w - X position
;	d2.w - Y position
; -------------------------------------------------------------------------
; RETURNS:
;	d0.w - Angle
; -------------------------------------------------------------------------

CalcAngle:
	movem.l	d3-d4,-(sp)
	moveq	#0,d3
	moveq	#0,d4
	move.w	d1,d3
	move.w	d2,d4
	or.w	d3,d4
	beq.s	.AngleZero			; Special case when both x and y are zero
	move.w	d2,d4

	tst.w	d3				; Get absolute value of X
	bpl.w	.NotNeg1
	neg.w	d3

.NotNeg1:
	tst.w	d4				; Get absolute value of Y
	bpl.w	.NotNeg2
	neg.w	d4

.NotNeg2:
	cmp.w	d3,d4
	bcc.w	.YGreater			; If |y| >= |x|
	lsl.l	#8,d4
	divu.w	d3,d4
	moveq	#0,d0
	move.b	ArcTanTable(pc,d4.w),d0
	bra.s	.CheckQuadrant

.YGreater:
	lsl.l	#8,d3
	divu.w	d4,d3
	moveq	#$40,d0
	sub.b	ArcTanTable(pc,d3.w),d0		; arctan(y/x) = 90 - arctan(x/y)

.CheckQuadrant:
	tst.w	d1
	bpl.w	.GotHalf
	neg.w	d0
	addi.w	#$80,d0				; Place angle in appropriate quadrant

.GotHalf:
	tst.w	d2
	bpl.w	.GotQuadrant
	neg.w	d0
	addi.w	#$100,d0			; Place angle in appropriate quadrant

.GotQuadrant:
	movem.l	(sp)+,d3-d4
	rts

.AngleZero:
	move.w	#$40,d0				; Angle = 90 degrees
	movem.l	(sp)+,d3-d4
	rts

; -------------------------------------------------------------------------

ArcTanTable:
	dc.b	$00, $00, $00, $00, $01, $01
	dc.b	$01, $01, $01, $01, $02, $02
	dc.b	$02, $02, $02, $02, $03, $03
	dc.b	$03, $03, $03, $03, $03, $04
	dc.b	$04, $04, $04, $04, $04, $05
	dc.b	$05, $05, $05, $05, $05, $06
	dc.b	$06, $06, $06, $06, $06, $06
	dc.b	$07, $07, $07, $07, $07, $07
	dc.b	$08, $08, $08, $08, $08, $08
	dc.b	$08, $09, $09, $09, $09, $09
	dc.b	$09, $0A, $0A, $0A, $0A, $0A
	dc.b	$0A, $0A, $0B, $0B, $0B, $0B
	dc.b	$0B, $0B, $0B, $0C, $0C, $0C
	dc.b	$0C, $0C, $0C, $0C, $0D, $0D
	dc.b	$0D, $0D, $0D, $0D, $0D, $0E
	dc.b	$0E, $0E, $0E, $0E, $0E, $0E
	dc.b	$0F, $0F, $0F, $0F, $0F, $0F
	dc.b	$0F, $10, $10, $10, $10, $10
	dc.b	$10, $10, $11, $11, $11, $11
	dc.b	$11, $11, $11, $11, $12, $12
	dc.b	$12, $12, $12, $12, $12, $13
	dc.b	$13, $13, $13, $13, $13, $13
	dc.b	$13, $14, $14, $14, $14, $14
	dc.b	$14, $14, $14, $15, $15, $15
	dc.b	$15, $15, $15, $15, $15, $15
	dc.b	$16, $16, $16, $16, $16, $16
	dc.b	$16, $16, $17, $17, $17, $17
	dc.b	$17, $17, $17, $17, $17, $18
	dc.b	$18, $18, $18, $18, $18, $18
	dc.b	$18, $18, $19, $19, $19, $19
	dc.b	$19, $19, $19, $19, $19, $19
	dc.b	$1A, $1A, $1A, $1A, $1A, $1A
	dc.b	$1A, $1A, $1A, $1B, $1B, $1B
	dc.b	$1B, $1B, $1B, $1B, $1B, $1B
	dc.b	$1B, $1C, $1C, $1C, $1C, $1C
	dc.b	$1C, $1C, $1C, $1C, $1C, $1C
	dc.b	$1D, $1D, $1D, $1D, $1D, $1D
	dc.b	$1D, $1D, $1D, $1D, $1D, $1E
	dc.b	$1E, $1E, $1E, $1E, $1E, $1E
	dc.b	$1E, $1E, $1E, $1E, $1F, $1F
	dc.b	$1F, $1F, $1F, $1F, $1F, $1F
	dc.b	$1F, $1F, $1F, $1F, $20, $20
	dc.b	$20, $20, $20, $20, $20, $00

; -------------------------------------------------------------------------
; Handle the player's collision on the ground
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

Player_GroundCol:
	btst	#3,oStatus(a0)			; Are we standing on an object?
	beq.s	.OnGround			; If not, then we are on the ground

	moveq	#0,d0				; Reset angle buffers
	move.b	d0,primaryAngle.w
	move.b	d0,secondaryAngle.w
	rts

.OnGround:
	moveq	#3,d0				; Reset angle buffers
	move.b	d0,primaryAngle.w
	move.b	d0,secondaryAngle.w

	move.b	oAngle(a0),d0			; Get the quadrant that we are in
	addi.b	#$20,d0
	bpl.s	.HighAngle
	move.b	oAngle(a0),d0
	bpl.s	.SkipSub
	subq.b	#1,d0

.SkipSub:
	addi.b	#$20,d0
	bra.s	.GotAngle

.HighAngle:
	move.b	oAngle(a0),d0
	bpl.s	.SkipAdd
	addq.b	#1,d0

.SkipAdd:
	addi.b	#$1F,d0

.GotAngle:
	andi.b	#$C0,d0

	cmpi.b	#$40,d0				; Are we on a left wall?
	beq.w	Player_WalkVertL		; If so, branch
	cmpi.b	#$80,d0				; Are we on a ceiling?
	beq.w	Player_WalkCeiling		; If so, branch
	cmpi.b	#$C0,d0				; Are we on a right wall?
	beq.w	Player_WalkVertR		; If so, branch

; -------------------------------------------------------------------------
; Move the player along a floor
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

Player_WalkFloor:
	move.w	oY(a0),d2			; Get primary sensor position
	move.w	oX(a0),d3
	moveq	#0,d0
	move.b	oYRadius(a0),d0
	ext.w	d0
	add.w	d0,d2
	move.b	oXRadius(a0),d0
	ext.w	d0
	add.w	d0,d3
	lea	primaryAngle.w,a4		; Get floor information from this sensor
	movea.w	#$10,a3
	move.w	#0,d6
	moveq	#$D,d5
	bsr.w	FindLevelFloor
	move.w	d1,-(sp)

	move.w	oY(a0),d2			; Get secondary sensor position
	move.w	oX(a0),d3
	moveq	#0,d0
	move.b	oYRadius(a0),d0
	ext.w	d0
	add.w	d0,d2
	move.b	oXRadius(a0),d0
	ext.w	d0
	neg.w	d0
	add.w	d0,d3

	lea	secondaryAngle.w,a4		; Get floor information from this sensor
	movea.w	#$10,a3
	move.w	#0,d6
	moveq	#$D,d5
	bsr.w	FindLevelFloor
	move.w	(sp)+,d0

	bsr.w	Player_PickSensor		; Choose which height and angle to go with
	tst.w	d1				; Are we perfectly aligned to the ground?
	beq.s	.End				; If so, branch
	bpl.s	.CheckLedge			; If we are outside the floor, branch
	cmpi.w	#-$E,d1				; Have we hit a wall?
	blt.s	Player_AnglePos_Done		; If so, branch
	add.w	d1,oY(a0)			; Align outselves onto the floor

.End:
	rts

.CheckLedge:
	cmpi.w	#$E,d1				; Are we about to fall off?
	bgt.s	.CheckStick			; If so, branch

.SetY:
	add.w	d1,oY(a0)			; Align ourselves onto the floor
	rts

.CheckStick:
	tst.b	oPlayerStick(a0)		; Are we sticking to a surface?
	bne.s	.SetY				; If so, align to the floor anyways

	bset	#1,oStatus(a0)			; Fall off the ground
	bclr	#5,oStatus(a0)
	move.b	#1,oPrevAnim(a0)
	rts

; -------------------------------------------------------------------------

Player_AnglePos_Done:
	rts

; -------------------------------------------------------------------------
; Some kind of unsued (and broken) object movement with gravity routine
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

BrokenObjMoveGrv:
	move.l	oX(a0),d2			; Apply X velocity
	move.w	oXVel(a0),d0
	ext.l	d0
	asl.l	#8,d0
	sub.l	d0,d2
	move.l	d2,oX(a0)

	move.w	#$38,d0				; Apply gravity without first applying Y velocity
	ext.l	d0				; ...and getting the Y position first
	asl.l	#8,d0
	sub.l	d0,d3
	move.l	d3,oY(a0)
	rts

; -------------------------------------------------------------------------

Player_WalkVert_Done:
	rts

; -------------------------------------------------------------------------
; Unused routine to apply Y velocity and reverse gravity onto an object
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

ObjMoveYRevGrv:
	move.l	oY(a0),d3			; Apply Y velocity
	move.w	oYVel(a0),d0
	subi.w	#$38,d0				; ...and reversed gravity
	move.w	d0,oYVel(a0)
	ext.l	d0
	asl.l	#8,d0
	sub.l	d0,d3
	move.l	d3,oY(a0)
	rts
	rts

; -------------------------------------------------------------------------
; Apply X and Y velocity onto an object (unused)
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

ObjMoveUnused:
	move.l	oX(a0),d2			; Get position
	move.l	oY(a0),d3

	move.w	oXVel(a0),d0			; Apply X velocity
	ext.l	d0
	asl.l	#8,d0
	sub.l	d0,d2

	move.w	oYVel(a0),d0			; Apply Y velocity
	ext.l	d0
	asl.l	#8,d0
	sub.l	d0,d3

	move.l	d2,oX(a0)			; Update position
	move.l	d3,oY(a0)
	rts

; -------------------------------------------------------------------------
; Pick a sensor to use to align the player to the ground
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

Player_PickSensor:
	move.b	secondaryAngle.w,d2		; Use secondary angle
	cmp.w	d0,d1				; Is the primary sensor on the higher ground?
	ble.s	.GotAngle			; If not, branch
	move.b	primaryAngle.w,d2		; Use primary angle
	move.w	d0,d1				; Use primary floor height

.GotAngle:
	btst	#0,d2				; Was the level block found a flat surface?
	bne.s	.FlatSurface			; If so, branch
	move.b	d2,oAngle(a0)			; Update angle
	rts

.FlatSurface:
	move.b	oAngle(a0),d2			; Shift ourselves to the next quadrant
	addi.b	#$20,d2
	andi.b	#$C0,d2
	move.b	d2,oAngle(a0)
	rts

; -------------------------------------------------------------------------
; Move the player along a right wall
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

Player_WalkVertR:
	move.w	oY(a0),d2			; Get primary sensor position
	move.w	oX(a0),d3
	moveq	#0,d0
	move.b	oXRadius(a0),d0
	ext.w	d0
	neg.w	d0
	add.w	d0,d2
	move.b	oYRadius(a0),d0
	ext.w	d0
	add.w	d0,d3
	lea	primaryAngle.w,a4		; Get floor information from this sensor
	movea.w	#$10,a3
	move.w	#0,d6
	moveq	#$D,d5
	bsr.w	FindLevelWall
	move.w	d1,-(sp)

	move.w	oY(a0),d2			; Get secondary sensor position
	move.w	oX(a0),d3
	moveq	#0,d0
	move.b	oXRadius(a0),d0
	ext.w	d0
	add.w	d0,d2
	move.b	oYRadius(a0),d0
	ext.w	d0
	add.w	d0,d3
	lea	secondaryAngle.w,a4		; Get floor information from this sensor
	movea.w	#$10,a3
	move.w	#0,d6
	moveq	#$D,d5
	bsr.w	FindLevelWall
	move.w	(sp)+,d0

	bsr.w	Player_PickSensor		; Choose which height and angle to go with
	tst.w	d1				; Are we perfectly aligned to the ground?
	beq.s	.End				; If so, branch
	bpl.s	.CheckLedge			; If we are outside the wall, branch
	cmpi.w	#-$E,d1				; Have we hit a wall?
	blt.w	Player_WalkVert_Done		; If so, branch
	add.w	d1,oX(a0)			; Align outselves onto the wall

.End:
	rts

.CheckLedge:
	cmpi.w	#$E,d1				; Are we about to fall off?
	bgt.s	.CheckStick			; If so, branch

.SetX:
	add.w	d1,oX(a0)			; Align ourselves onto the wall
	rts

.CheckStick:
	tst.b	oPlayerStick(a0)		; Are we sticking to a surface?
	bne.s	.SetX				; If so, align to the wall anyways

	bset	#1,oStatus(a0)			; Fall off the ground
	bclr	#5,oStatus(a0)
	move.b	#1,oPrevAnim(a0)
	rts

; -------------------------------------------------------------------------
; Move the player along a ceiling
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

Player_WalkCeiling:
	move.w	oY(a0),d2			; Get primary sensor position
	move.w	oX(a0),d3
	moveq	#0,d0
	move.b	oYRadius(a0),d0
	ext.w	d0
	sub.w	d0,d2
	eori.w	#$F,d2
	move.b	oXRadius(a0),d0
	ext.w	d0
	add.w	d0,d3
	lea	primaryAngle.w,a4		; Get floor information from this sensor
	movea.w	#-$10,a3
	move.w	#$1000,d6
	moveq	#$D,d5
	bsr.w	FindLevelFloor
	move.w	d1,-(sp)

	move.w	oY(a0),d2			; Get secondary sensor position
	move.w	oX(a0),d3
	moveq	#0,d0
	move.b	oYRadius(a0),d0
	ext.w	d0
	sub.w	d0,d2
	eori.w	#$F,d2
	move.b	oXRadius(a0),d0
	ext.w	d0
	sub.w	d0,d3
	lea	secondaryAngle.w,a4		; Get floor information from this sensor
	movea.w	#-$10,a3
	move.w	#$1000,d6
	moveq	#$D,d5
	bsr.w	FindLevelFloor
	move.w	(sp)+,d0

	bsr.w	Player_PickSensor		; Choose which height and angle to go with
	tst.w	d1				; Are we perfectly aligned to the ground?
	beq.s	.End				; If so, branch
	bpl.s	.CheckLedge			; If we are outside the ceiling, branch
	cmpi.w	#-$E,d1				; Have we hit a ceiling?
	blt.w	Player_AnglePos_Done		; If so, branch
	sub.w	d1,oY(a0)			; Align outselves onto the ceiling

.End:
	rts

.CheckLedge:
	cmpi.w	#$E,d1				; Are we about to fall off?
	bgt.s	.CheckStick			; If so, branch

.SetY:
	sub.w	d1,oY(a0)			; Align ourselves onto the ceiling
	rts

.CheckStick:
	tst.b	oPlayerStick(a0)		; Are we sticking to a surface?
	bne.s	.SetY				; If so, align to the ceiling anyways

	bset	#1,oStatus(a0)			; Fall off the ground
	bclr	#5,oStatus(a0)
	move.b	#1,oPrevAnim(a0)
	rts

; -------------------------------------------------------------------------
; Move the player along a left wall
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

Player_WalkVertL:
	move.w	oY(a0),d2			; Get primary sensor position
	move.w	oX(a0),d3
	moveq	#0,d0
	move.b	oXRadius(a0),d0
	ext.w	d0
	sub.w	d0,d2
	move.b	oYRadius(a0),d0
	ext.w	d0
	sub.w	d0,d3
	eori.w	#$F,d3
	lea	primaryAngle.w,a4		; Get floor information from this sensor
	movea.w	#-$10,a3
	move.w	#$800,d6
	moveq	#$D,d5
	bsr.w	FindLevelWall
	move.w	d1,-(sp)

	move.w	oY(a0),d2			; Get secondary sensor position
	move.w	oX(a0),d3
	moveq	#0,d0
	move.b	oXRadius(a0),d0
	ext.w	d0
	add.w	d0,d2
	move.b	oYRadius(a0),d0
	ext.w	d0
	sub.w	d0,d3
	eori.w	#$F,d3
	lea	secondaryAngle.w,a4		; Get floor information from this sensor
	movea.w	#-$10,a3
	move.w	#$800,d6
	moveq	#$D,d5
	bsr.w	FindLevelWall
	move.w	(sp)+,d0

	bsr.w	Player_PickSensor		; Choose which height and angle to go with
	tst.w	d1				; Are we perfectly aligned to the ground?
	beq.s	.End				; If so, branch
	bpl.s	.CheckLedge			; If we are outside the wall, branch
	cmpi.w	#-$E,d1				; Have we hit a wall?
	blt.w	Player_WalkVert_Done		; If so, branch
	sub.w	d1,oX(a0)			; Align outselves onto the wall

.End:
	rts

.CheckLedge:
	cmpi.w	#$E,d1				; Are we about to fall off?
	bgt.s	.CheckStick			; If so, branch

.SetX:
	sub.w	d1,oX(a0)			; Align ourselves onto the wall
	rts

.CheckStick:
	tst.b	oPlayerStick(a0)		; Are we sticking to a surface?
	bne.s	.SetX				; If so, align to the wall anyways

	bset	#1,oStatus(a0)			; Fall off the ground
	bclr	#5,oStatus(a0)
	move.b	#1,oPrevAnim(a0)
	rts

; -------------------------------------------------------------------------
; Get level Block metadata at a position
; -------------------------------------------------------------------------
; PARAMETERS:
;	d2.w - Y position
;	d3.w - X position
;	a0.l - Object RAM
; RETURNS:
;	a1.l - Block metadata pointer
; -------------------------------------------------------------------------

GetLevelBlock:
	move.w	d2,d0				; Get Y position
	lsr.w	#1,d0
	andi.w	#$780,d0			; Limit from 0 to $EFF in most levels
	cmpi.b	#2,levelZone			; Are we in Tidal Tempest?
	bne.s	.NotTTZ				; If not, branch
	andi.w	#$380,d0			; Limit from 0 to $6FF in Tidal Tempest

.NotTTZ:
	move.w	d3,d1				; Get X position
	lsr.w	#8,d1
	andi.w	#$7F,d1
	add.w	d1,d0				; Combine the X and Y into a level layout data index value

	move.l	#LevelChunks,d1			; Get base chunk data pointer
	lea	levelLayout.w,a1		; Get chunk that the block we want is in
	move.b	(a1,d0.w),d1
	beq.s	.Blank				; If it's a blank chunk, branch
	bmi.s	.LoopChunk			; If it's a loop chunk, branch

	cmpi.b	#5,levelZone			; Are we in Stardust Speedway?
	beq.s	.SSZ				; If so, branch
	cmpi.b	#6,levelZone			; Are we in Metallic Madness?
	bne.s	.NotMMZ				; If not, branch

.SSZ:
	andi.w	#$7FFF,oTile(a0)		; Set the object's sprite to be low priority

.NotMMZ:
	cmpi.b	#4,levelZone			; Are we in Wacky Workbench?
	bne.s	.NotWWZ				; If not, branch
	bclr	#6,oRender(a0)			; Move the object onto the lower path layer

.NotWWZ:
	subq.b	#1,d1				; Prepare chunk data index value from X and Y position
	ext.w	d1
	ror.w	#7,d1
	move.w	d2,d0
	add.w	d0,d0
	andi.w	#$1E0,d0
	add.w	d0,d1
	move.w	d3,d0
	lsr.w	#3,d0
	andi.w	#$1E,d0
	add.w	d0,d1

.Blank:
	movea.l	d1,a1				; Get pointer to block
	rts

; -------------------------------------------------------------------------

.LoopChunk:
	andi.w	#$7F,d1				; Get chunk ID

	cmpi.b	#4,levelZone			; Are we in Wacky Workbench?
	bne.s	.NotWWZ2			; If not, branch

	btst	#6,oRender(a0)			; Is the object on the higher path layer?
	bne.s	.LowPlane			; If so, branch
	cmpi.b	#$14,d1				; Is this chunk $14?
	bne.w	.GetBlock			; If not, branch
	bset	#6,oRender(a0)			; Move the object onto the higher path layer
	andi.b	#$7F,oTile(a0)			; Set the object's sprite to be low priority
	bra.w	.GetBlock

.LowPlane:
	cmpi.b	#$15,d1				; Is this chunk $15?
	bne.s	.Not15				; If not, branch
	move.w	#$60,d1				; Change it to chunk $60
	bra.w	.GetBlock

.Not15:
	cmpi.b	#$1E,d1				; Is this chunk $1E?
	bne.s	.Not1E				; If not, branch
	move.w	#$61,d1				; Change it to chunk $61
	bra.w	.GetBlock

.Not1E:
	cmpi.b	#$1F,d1				; Is this chunk $1F?
	bne.s	.Not1F				; If not, branch
	move.w	#$62,d1				; Change it to chunk $62
	bra.w	.GetBlock

.Not1F:
	cmpi.b	#$32,d1				; Is this chunk $32?
	bne.w	.GetBlock			; If not, branch
	move.w	#$63,d1				; Change it to chunk $63
	bra.w	.GetBlock

; -------------------------------------------------------------------------

.NotWWZ2:
	cmpi.b	#5,levelZone			; Are we in Stardust Speedway?
	bne.w	.NotSSZ				; If not, branch

	ori.w	#$8000,oTile(a0)		; Set the object's sprite to be high priority
	cmpi.b	#4,d1				; Is this chunk 4?
	beq.s	.SwapChunkIfLow			; If so, branch
	cmpi.b	#6,d1				; Is this chunk 6?
	beq.s	.SwapChunkIfLow			; If so, branch

	tst.b	lvlDrawLowPlane			; Should things be on the high plane?
	beq.w	.GetBlock			; If so, branch
	andi.w	#$7FFF,oTile(a0)		; Set the object's sprite to be low priority
	cmpi.b	#$28,d1				; Is this chunk $28?
	beq.s	.SwapChunk			; If so, branch
	cmpi.b	#$3C,d1				; Is this chunk $3C?
	beq.s	.SwapChunk			; If so, branch
	cmpi.b	#$37,d1				; Is this chunk $37?
	beq.s	.SwapChunk			; If so, branch
	cmpi.b	#$2F,d1				; Is this chunk $2F?
	beq.s	.SwapChunk			; If so, branch
	cmpi.b	#$16,d1				; Is this chunk $16?
	beq.s	.SwapChunk			; If so, branch
	bra.w	.GetBlock

.SwapChunkIfLow:
	andi.w	#$7FFF,oTile(a0)		; Set the object's sprite to be low priority
	btst	#6,oRender(a0)			; Is the object on the lower path layer?
	beq.w	.GetBlock			; If so, branch

.SwapChunk:
	addq.b	#1,d1				; Swap chunks
	bra.w	.GetBlock

; -------------------------------------------------------------------------

.NotSSZ:
	cmpi.b	#6,levelZone			; Are we in Metallic Madness?
	bne.s	.NotMMZ2			; If not, branch
	cmpi.b	#3,oID(a0)			; Is this a player object?
	bcc.w	.GetBlock			; If not, branch

	ori.w	#$8000,oTile(a0)		; Set the object's sprite to be high priority
	tst.b	lvlDrawLowPlane			; Should things be on the high plane?
	beq.s	.GetBlock			; If so, branch
	andi.w	#$7FFF,oTile(a0)		; Set the object's sprite to be low priority

	cmpi.b	#$46,d1				; Is this chunk $28?
	bne.s	.Not46
	move.w	#$6A,d1
	bra.s	.GetBlock

.Not46:
	cmpi.b	#$48,d1				; Is this chunk $48?
	bne.s	.Not48				; If not, branch
	move.w	#$6B,d1				; Change it to chunk $6B
	bra.s	.GetBlock

.Not48:
	cmpi.b	#$4A,d1				; Is this chunk $4A?
	bne.s	.Not4A				; If not, branch
	move.w	#$6C,d1				; Change it to chunk $6C
	bra.s	.GetBlock

.Not4A:
	cmpi.b	#$10,d1				; Is this chunk $10?
	bne.s	.Not10				; If not, branch
	move.w	#$6D,d1				; Change it to chunk $6D
	bra.s	.GetBlock

.Not10:
	cmpi.b	#$63,d1				; Is this chunk $63?
	bne.s	.Not63				; If not, branch
	move.w	#$6E,d1				; Change it to chunk $6E
	bra.s	.GetBlock

.Not63:
	cmpi.b	#$43,d1				; Is this chunk $43?
	bne.s	.GetBlock			; If not, branch
	move.w	#$6F,d1				; Change it to chunk $6F
	bra.s	.GetBlock

; -------------------------------------------------------------------------

.NotMMZ2:
	btst	#6,oRender(a0)			; Is the object on the lower path layer?
	beq.s	.GetBlock			; If so, branch

	addq.w	#1,d1				; Swap chunks
	cmpi.w	#$29,d1				; Are we now on chunk $29?
	bne.s	.GetBlock			; If not, branch
	move.w	#$51,d1				; If so, change it to chunk $51

; -------------------------------------------------------------------------

.GetBlock:
	subq.b	#1,d1				; Prepare chunk data index value from X and Y position
	ror.w	#7,d1
	move.w	d2,d0
	add.w	d0,d0
	andi.w	#$1E0,d0
	add.w	d0,d1
	move.w	d3,d0
	lsr.w	#3,d0
	andi.w	#$1E,d0
	add.w	d0,d1

	movea.l	d1,a1				; Get pointer to block
	rts

; -------------------------------------------------------------------------
; Get the distance to the nearest block vertically
; -------------------------------------------------------------------------
; PARAMETERS:
;	d2.w - Y position
;	d3.w - X position
;	d5.w - Bit to check for solidity
;	d6.w - Flip bits
;	a3.w - Distance in pixels to check for a nearby block
;	a4.w - Pointer to where the angle will be stored
; RETURNS:
;	d1.w - Distance from the block
;	a1.l - Block metadata pointer
;	(a4).b - Angle
; -------------------------------------------------------------------------

FindLevelFloor:
	bsr.w	GetLevelBlock			; Get block at position
	cmpi.l	#LevelChunks,d1			; Is it a blank block?
	beq.s	.IsBlank			; If so, branch

	move.w	(a1),d0				; Get block ID
	move.w	d0,d4
	andi.w	#$7FF,d0
	beq.s	.IsBlank			; If it's blank, branch
	btst	d5,d4				; Is the block solid?
	bne.s	.IsSolid			; If so, branch

.IsBlank:
	add.w	a3,d2				; Check the nearby block
	bsr.w	FindLevelFloor2
	sub.w	a3,d2				; Restore Y position
	addi.w	#$10,d1				; Increment height
	rts

.IsSolid:
	movea.l	collisionPtr.w,a2		; Get collision block ID
	move.b	(a2,d0.w),d0
	andi.w	#$FF,d0
	beq.s	.IsBlank			; If it's blank, branch

	lea	ColAngleMap,a2			; Get collision angle
	move.b	(a2,d0.w),(a4)

	lsl.w	#4,d0				; Get base collision block height map index
	move.w	d3,d1				; Get X position
	btst	#$B,d4				; Is this block horizontally flipped?
	beq.s	.NoXFlip			; If not, branch
	not.w	d1				; Flip the X position
	neg.b	(a4)				; Flip the angle

.NoXFlip:
	btst	#$C,d4				; Is this block vertically flipped?
	beq.s	.NoYFlip			; If not, branch
	addi.b	#$40,(a4)			; Flip the angle
	neg.b	(a4)
	subi.b	#$40,(a4)

.NoYFlip:
	andi.w	#$F,d1				; Get block column height
	add.w	d0,d1
	lea	ColHeightMap,a2
	move.b	(a2,d1.w),d0
	ext.w	d0

	eor.w	d6,d4				; Is this block vertically flipped?
	btst	#$C,d4
	beq.s	.NoYFlip2			; If not, branch
	neg.w	d0				; Flip the height

.NoYFlip2:
	tst.w	d0				; Check the height
	beq.s	.IsBlank			; If it's 0, branch
	bmi.s	.CheckNegFloor			; If it's negative, branch
	cmpi.b	#$10,d0				; Is this a full height?
	beq.s	.MaxFloor			; If so, branch

.FoundFloor:
	move.w	d2,d1				; Get how deep the object is into the block
	andi.w	#$F,d1
	add.w	d1,d0
	move.w	#$F,d1
	sub.w	d0,d1
	rts

.CheckNegFloor:
	cmpa.w	#$10,a3				; Is the next block above?
	bne.s	.NegFloor			; If so, branch
	move.w	#$10,d0				; Force height to be full
	move.b	#0,(a4)				; Set angle to 0
	bra.s	.FoundFloor

.NegFloor:
	move.w	d2,d1				; Get how deep the object is into the block
	andi.w	#$F,d1
	add.w	d1,d0
	bpl.w	.IsBlank			; If the object is outside of the block, branch

.MaxFloor:
	sub.w	a3,d2				; Check the nearby block
	bsr.w	FindLevelFloor2
	add.w	a3,d2				; Restore Y position
	subi.w	#$10,d1				; Decrement height
	rts

; -------------------------------------------------------------------------

FindLevelFloor2:
	bsr.w	GetLevelBlock			; Get block at position
	cmpi.l	#LevelChunks,d1			; Is it a blank block?
	beq.s	.IsBlank			; If so, branch

	move.w	(a1),d0				; Get block ID
	move.w	d0,d4
	andi.w	#$7FF,d0
	beq.s	.IsBlank			; If it's blank, branch
	btst	d5,d4				; Is the block solid?
	bne.s	.IsSolid			; If so, branch

.IsBlank:
	move.w	#$F,d1				; Get how deep the object is into the block
	move.w	d2,d0
	andi.w	#$F,d0
	sub.w	d0,d1
	rts

.IsSolid:
	movea.l	collisionPtr.w,a2		; Get collision block ID
	move.b	(a2,d0.w),d0
	andi.w	#$FF,d0
	beq.s	.IsBlank			; If it's blank, branch

	lea	ColAngleMap,a2			; Get collision angle
	move.b	(a2,d0.w),(a4)

	lsl.w	#4,d0				; Get base collision block height map index
	move.w	d3,d1				; Get X position
	btst	#$B,d4				; Is this block horizontally flipped?
	beq.s	.NoXFlip			; If not, branch
	not.w	d1				; Flip the X position
	neg.b	(a4)				; Flip the angle

.NoXFlip:
	btst	#$C,d4				; Is this block vertically flipped?
	beq.s	.NoYFlip			; If not, branch
	addi.b	#$40,(a4)			; Flip the angle
	neg.b	(a4)
	subi.b	#$40,(a4)

.NoYFlip:
	andi.w	#$F,d1				; Get block column height
	add.w	d0,d1
	lea	ColHeightMap,a2
	move.b	(a2,d1.w),d0
	ext.w	d0

	eor.w	d6,d4				; Is this block vertically flipped?
	btst	#$C,d4
	beq.s	.NoYFlip2			; If not, branch
	neg.w	d0				; Flip the height

.NoYFlip2:
	tst.w	d0				; Check the height
	beq.s	.IsBlank			; If it's 0, branch
	bmi.s	.CheckNegFloor			; If it's negative, branch

.FoundFloor:
	move.w	d2,d1				; Get how deep the object is into the block
	andi.w	#$F,d1
	add.w	d1,d0
	move.w	#$F,d1
	sub.w	d0,d1
	rts

.CheckNegFloor:
	cmpa.w	#$10,a3				; Were we checking above the last block?
	bne.s	.NegFloor			; If so, branch
	move.w	#$10,d0				; Force height to be full
	move.b	#0,(a4)				; Set angle to 0
	bra.s	.FoundFloor

.NegFloor:
	move.w	d2,d1				; Get how deep the object is into the block
	andi.w	#$F,d1
	add.w	d1,d0
	bpl.w	.IsBlank			; If the object is outside of the block, branch
	not.w	d1				; Flip the height
	rts

; -------------------------------------------------------------------------
; Get the distance to the nearest block horizontally
; -------------------------------------------------------------------------
; PARAMETERS:
;	d2.w - Y position
;	d3.w - X position
;	d5.w - Bit to check for solidity
;	d6.w - Flip bits
;	a3.w - Distance in pixels to check for a nearby block
;	a4.w - Pointer to where the angle will be stored
; RETURNS:
;	d1.w - Distance from the block
;	a1.l - Block metadata pointer
;	(a4).b - Angle
; -------------------------------------------------------------------------

FindLevelWall:
	bsr.w	GetLevelBlock			; Get block at position
	cmpi.l	#LevelChunks,d1			; Is it a blank block?
	beq.s	.IsBlank			; If so, branch

	move.w	(a1),d0				; Get block ID
	move.w	d0,d4
	andi.w	#$7FF,d0
	beq.s	.IsBlank			; If it's blank, branch
	btst	d5,d4				; Is the block solid?
	bne.s	.IsSolid			; If so, branch

.IsBlank:
	add.w	a3,d3				; Check the nearby block
	bsr.w	FindLevelWall2
	sub.w	a3,d3				; Restore Y position
	addi.w	#$10,d1				; Increment width
	rts

.IsSolid:
	movea.l	collisionPtr.w,a2		; Get collision block ID
	move.b	(a2,d0.w),d0
	andi.w	#$FF,d0
	beq.s	.IsBlank			; If it's blank, branch

	lea	ColAngleMap,a2			; Get collision angle
	move.b	(a2,d0.w),(a4)

	lsl.w	#4,d0				; Get base collision block width map index
	move.w	d2,d1				; Get Y position
	btst	#$C,d4				; Is this block vertically flipped?
	beq.s	.NoYFlip			; If not, branch
	not.w	d1				; Flip the Y position
	addi.b	#$40,(a4)			; Flip the angle
	neg.b	(a4)
	subi.b	#$40,(a4)

.NoYFlip:
	btst	#$B,d4				; Is this block horizontally flipped?
	beq.s	.NoXFlip			; If not, branch
	neg.b	(a4)				; Flip the angle

.NoXFlip:
	andi.w	#$F,d1				; Get block row width
	add.w	d0,d1
	lea	ColWidthMap,a2
	move.b	(a2,d1.w),d0
	ext.w	d0

	eor.w	d6,d4				; Is this block horizontally flipped?
	btst	#$B,d4
	beq.s	.NoYFlip2			; If not, branch
	neg.w	d0				; Flip the width

.NoYFlip2:
	tst.w	d0				; Check the width
	beq.s	.IsBlank			; If it's 0, branch
	bmi.s	.NegWall			; If it's negative, branch
	cmpi.b	#$10,d0				; Is this a full width?
	beq.s	.MaxWall			; If so, branch
	move.w	d3,d1				; Get how deep the object is into the block
	andi.w	#$F,d1
	add.w	d1,d0
	move.w	#$F,d1
	sub.w	d0,d1
	rts

.NegWall:
	move.w	d3,d1				; Get how deep the object is into the block
	andi.w	#$F,d1
	add.w	d1,d0
	bpl.w	.IsBlank			; If the object is outside of the block, branch

.MaxWall:
	sub.w	a3,d3				; Check the nearby block
	bsr.w	FindLevelWall2
	add.w	a3,d3				; Restore Y position
	subi.w	#$10,d1				; Decrement width
	rts

; -------------------------------------------------------------------------

FindLevelWall2:
	bsr.w	GetLevelBlock			; Get block at position
	cmpi.l	#LevelChunks,d1			; Is it a blank block?
	beq.s	.IsBlank			; If so, branch

	move.w	(a1),d0				; Get block ID
	move.w	d0,d4
	andi.w	#$7FF,d0
	beq.s	.IsBlank			; If it's blank, branch
	btst	d5,d4				; Is the block solid?
	bne.s	.IsSolid			; If so, branch

.IsBlank:
	move.w	#$F,d1				; Get how deep the object is into the block
	move.w	d3,d0
	andi.w	#$F,d0
	sub.w	d0,d1
	rts

.IsSolid:
	movea.l	collisionPtr.w,a2		; Get collision block ID
	move.b	(a2,d0.w),d0
	andi.w	#$FF,d0
	beq.s	.IsBlank			; If it's blank, branch

	lea	ColAngleMap,a2			; Get collision angle
	move.b	(a2,d0.w),(a4)

	lsl.w	#4,d0				; Get base collision block width map index
	move.w	d2,d1				; Get Y position
	btst	#$C,d4				; Is this block vertically flipped?
	beq.s	.NoYFlip			; If not, branch
	not.w	d1				; Flip the Y position
	addi.b	#$40,(a4)			; Flip the angle
	neg.b	(a4)
	subi.b	#$40,(a4)

.NoYFlip:
	btst	#$B,d4				; Is this block horizontally flipped?
	beq.s	.NoXFlip			; If not, branch
	neg.b	(a4)				; Flip the angle

.NoXFlip:
	andi.w	#$F,d1				; Get block row width
	add.w	d0,d1
	lea	ColWidthMap,a2
	move.b	(a2,d1.w),d0
	ext.w	d0

	eor.w	d6,d4				; Is this block horizontally flipped?
	btst	#$B,d4
	beq.s	.NoYFlip2			; If not, branch
	neg.w	d0				; Flip the width

.NoYFlip2:
	tst.w	d0				; Check the width
	beq.s	.IsBlank			; If it's 0, branch
	bmi.s	.NegWall			; If it's negative, branch
	move.w	d3,d1				; Get how deep the object is into the block
	andi.w	#$F,d1
	add.w	d1,d0
	move.w	#$F,d1
	sub.w	d0,d1
	rts

.NegWall:
	move.w	d3,d1				; Get how deep the object is into the block
	andi.w	#$F,d1
	add.w	d1,d0
	bpl.w	.IsBlank			; If the object is outside of the block, branch
	not.w	d1				; Flip the width
	rts

; -------------------------------------------------------------------------
; This subroutine takes 'raw' bitmap-like collision block data as input and
; converts it into the proper collision arrays. Pointers to said raw data
; are dummied out.
; -------------------------------------------------------------------------

RawColBlocks		EQU	ColHeightMap
ConvRowColBlocks	EQU	ColHeightMap

ConvColArray:
	rts

	lea	RawColBlocks,a1			; Source of "raw" collision array
	lea	ConvRowColBlocks,a2		; Destination of converted collision array

	move.w	#$100-1,d3			; Number of blocks in collision array

.BlockLoop:
	moveq	#16,d5				; Start on the leftmost pixel
	move.w	#16-1,d2			; Width of a block in pixels

.ColumnLoop:
	moveq	#0,d4
	move.w	#16-1,d1			; Height of a block of pixels

.RowLoop:
	move.w	(a1)+,d0			; Get row of collision bits
	lsr.l	d5,d0				; Push the selected bit of this row into the extended flag
	addx.w	d4,d4				; Shift d4 to the left, and append the selected bit
	dbf	d1,.RowLoop

	move.w	d4,(a2)+			; Store the column of collision bits
	suba.w	#2*16,a1			; Back to the start of the block
	subq.w	#1,d5				; Get next bit in the row
	dbf	d2,.ColumnLoop			; Loop for each column of pixels in a block

	adda.w	#2*16,a1			; Next block
	dbf	d3,.BlockLoop			; Loop for each block in the collision array

	lea	ConvRowColBlocks,a1		; Convert widths
	lea	ColWidthMap,a2
	bsr.s	.ConvToColBlocks
	lea	RawColBlocks,a1			; Convert heights
	lea	ColHeightMap,a2

; -------------------------------------------------------------------------

.ConvToColBlocks:
	move.w	#$1000-1,d3			; Size of a standard collision arary

.ProcCollision:
	moveq	#0,d2				; Base height
	move.w	#16-1,d1			; Column height
	move.w	(a1)+,d0			; Get current column of collision pixels
	beq.s	.NoCollision			; If there's no collision in this column, branch
	bmi.s	.InvertedCol			; If the collision is inverted, branch

.ProcColumnLoop:
	lsr.w	#1,d0				; Is there a solid pixel?
	bcc.s	.NotSolid			; If not, branch
	addq.b	#1,d2				; Increment height

.NotSolid:
	dbf	d1,.ProcColumnLoop		; Loop until finished
	bra.s	.ColumnProcessed

.InvertedCol:
	cmpi.w	#$FFFF,d0			; Is the entire column solid?
	beq.s	.FullColumn			; If so, branch

.ProcColumnLoop2:
	lsl.w	#1,d0				; Is there a solid pixel?
	bcc.s	.NotSolid2			; If not, branch
	subq.b	#1,d2				; Decrement height

.NotSolid2:
	dbf	d1,.ProcColumnLoop2		; Loop until finished
	bra.s	.ColumnProcessed

.FullColumn:
	move.w	#16,d0				; Set height to 16 pixels

.NoCollision:
	move.w	d0,d2				; Set fill height

.ColumnProcessed:
	move.b	d2,(a2)+			; Store column height
	dbf	d3,.ProcCollision		; Loop until finished
	rts

; -------------------------------------------------------------------------
; Leftover music ID list from Sonic 1
; -------------------------------------------------------------------------

LevelMusicIDs_S1:
	dc.b	$81, $82, $83, $84, $85, $86, $8D
	even

; -------------------------------------------------------------------------
; Level game mode
; -------------------------------------------------------------------------

LevelStart:
	clr.w	demoMode			; Clear demo mode flag

	cmpi.b	#$7F,timeStones			; Did we get all of the time stones?
	bne.s	.NotGoodFuture			; If not, branch
	tst.b	timeAttackMode			; Are we in time attack mode?
	bne.s	.NotGoodFuture			; If not, branch
	move.b	#1,goodFuture			; Force a good future

.NotGoodFuture:
	move.b	#0,levelStarted			; Mark the level as not started yet
	clr.b	vintRoutine.w			; Reset V-INT routine ID
	clr.b	usePlayer2			; Clear unused "use player 2" flag
	move.b	#0,paused.w			; Clear pause flag

	bset	#0,plcLoadFlags			; Mark PLCs as loaded
	bne.s	.NoReset			; If they were loaded before, branch

	clr.b	palFadeFlags			; Mark palette fading as inactive
	clr.b	lastCheckpoint			; Reset checkpoint
	move.l	#5000,nextLifeScore		; Reset next score for 1-UP

	bsr.w	ResetRespawnTable		; Clear respawn table

	clr.b	resetLevelFlags			; Clear level reset flags
	clr.b	goodFutureFlags			; Clear good future flags
	clr.l	levelScore			; Clear score

	move.b	#3,lifeCount			; Reset life count to 3
	tst.b	timeAttackMode			; Are we in time attack mode?
	beq.s	.NoReset			; If not, branch
	move.b	#1,lifeCount			; Reset life count to 1

.NoReset:
	bset	#7,gameMode.w			; Mark level as initializing
	bsr.w	ClearPLCs			; Clear PLCs

	tst.b	enteredBigRing			; Have we entered a big ring before?
	bne.s	.EnteredBigRing			; If so, branch
	btst	#7,timeZone			; Were we time travelling before?
	beq.s	.FadeToBlack			; If not, branch

	bset	#0,palFadeFlags			; Mark palette fading as active
	beq.s	.SkipFade			; If it was active before, branch

.EnteredBigRing:
	bsr.w	FadeToWhite			; Fade to white
	bclr	#0,palFadeFlags			; Mark palette fading as inactive

.SkipFade:
	clr.b	timeWarpDir.w			; Reset time travel direction
	tst.w	levelRestart			; Was the level restart flag set?
	beq.w	.CheckNormalLoad		; If not, branch
	move.w	#0,levelRestart			; Clear level restart flag
	cmpi.b	#2,levelAct			; Are we in act 3?
	bne.s	.End				; If not, branch
	bclr	#7,timeZone			; Clear time travel flag

.End:
	rts

; -------------------------------------------------------------------------

.FadeToBlack:
	bset	#0,palFadeFlags			; Mark palette fading as active
	beq.s	.SkipFade2			; If it was active before, branch
	bsr.w	FadeToBlack			; Fade to black

.SkipFade2:
	cmpi.w	#2,levelRestart			; Were we going to the next level?
	bne.s	.CheckNoLives			; If not, branch
	move.w	#0,levelRestart			; Clear level restart flag
	move.b	#0,palFadeFlags			; Mark palette fading as inactive
	bra.s	.ClearPal			; Get out of here

.CheckNoLives:
	tst.b	lifeCount			; Do we have any lives?
	bne.s	.CheckNormalLoad		; If so, branch
	move.b	#0,plcLoadFlags			; Mark PLCs as not loaded
	move.b	#0,lastCheckpoint		; Clear checkpoint
	move.b	#0,resetLevelFlags		; Clear level level flags
	move.b	#0,palFadeFlags			; Mark palette fading as inactive

.ClearPal:
	lea	palette.w,a1			; Fill the palette with black
	move.w	#$80/4-1,d6

.ClearPalLoop:
	move.l	#0,(a1)+
	dbf	d6,.ClearPalLoop

	move.b	#$C,vintRoutine.w		; Process the palette clear in V-INT
	bsr.w	VSync
	rts

; -------------------------------------------------------------------------

.CheckNormalLoad:
	cmpi.w	#$800,demoTimer.w		; Was a demo running?
	bne.s	.NormalLoad			; If not, branch
	move.w	#0,demoTimer.w			; Reset demo timer
	clr.w	demoMode			; Clear demo mode flag
	move.b	#0,palFadeFlags			; Mark palette fading as inactive
	rts

; -------------------------------------------------------------------------

.NormalLoad:
	moveq	#0,d0				; Fill palette with black
	btst	#0,palClearFlags		; Should we fill the palette with white?
	bne.s	.UseWhite			; If so, branch
	btst	#7,timeZone			; Were we time travelling before?
	beq.s	.ClearPal2			; If not, branch

.UseWhite:
	move.l	#$0EEE0EEE,d0			; Fill palette with white

.ClearPal2:
	lea	palette.w,a1			; Fill the palette with black or white
	move.w	#$80/4-1,d6

.ClearPalLoop2:
	move.l	d0,(a1)+
	dbf	d6,.ClearPalLoop2		; Loop until finished

.WaitPLC:
	move.b	#$C,vintRoutine.w		; VSync
	bsr.w	VSync
	bsr.w	ProcessPLCs			; Process PLCs
	bne.s	.WaitPLC			; If the queue isn't empty, wait
	tst.l	plcBuffer.w

	bsr.w	PlayLevelMusic			; Play level music

	moveq	#0,d0				; Get level PLCs
	lea	LevelDataIndex,a2
	moveq	#0,d0
	move.b	(a2),d0
	beq.s	.LoadStdPLCs
	bsr.w	LoadPLCImm			; Load it immediately

.LoadStdPLCs:
	moveq	#1,d0				; Load standard PLCs immediately
	bsr.w	LoadPLCImm

	clr.b	lvlLoadShieldArt		; Reset shield art load flag
	clr.l	flowerCount			; Clear flower count

	lea	objDrawQueue.w,a1		; Clear object sprite draw queue
	moveq	#0,d0
	move.w	#$400/4-1,d1

.ClearObjSprites:
	move.l	d0,(a1)+
	dbf	d1,.ClearObjSprites

	lea	flowerPosBuf,a1			; Clear flower position buffer and other misc. variables
	moveq	#0,d0
	move.w	#$A00/4-1,d1

.ClearFlowers:
	move.l	d0,(a1)+
	dbf	d1,.ClearFlowers

	lea	objects.w,a1			; Clear object RAM
	moveq	#0,d0
	move.w	#$2000/4-1,d1

.ClearObjects:
	move.l	d0,(a1)+
	dbf	d1,.ClearObjects

	lea	unkLvlBuffer2,a1		; Clear an unknown buffer
	moveq	#0,d0
	move.w	#$1000/4-1,d1

.ClearunkLvlBuffer:
	move.l	d0,(a1)+
	dbf	d1,.ClearunkLvlBuffer

	lea	miscVariables.w,a1		; Clear misc. variables
	moveq	#0,d0
	move.w	#$58/4-1,d1

.ClearMiscVars:
	move.l	d0,(a1)+
	dbf	d1,.ClearMiscVars

	lea	cameraX.w,a1			; Clear camera RAM
	moveq	#0,d0
	move.w	#$100/4-1,d1

.ClearCamera:
	move.l	d0,(a1)+
	dbf	d1,.ClearCamera

	move	#$2700,sr			; Disable interrupts
	move.l	#LevelChunks+$6C00,demoPtr.w	; Set demo data pointer (in DEMO11A, part of the chunk data
						; is overwritten with the demo input data. Here, it's unused)
	move.w	#0,demoTimer.w			; Reset demo timer

	bsr.w	ClearScreen			; Clear the screen
	lea	VDPCTRL,a6
	move.w	#$8B03,(a6)			; HScroll by line, VScroll by screen
	move.w	#$8230,(a6)			; Plane A at $C000
	move.w	#$8407,(a6)			; Plane B at $E000
	move.w	#$857C,(a6)			; Sprite table at $F800
	move.w	#$9001,(a6)			; Plane size 64x32
	move.w	#$8004,(a6)			; Disable H-INT
	move.w	#$8720,(a6)			; Background color at line 2, color 0
	move.w	#$8ADF,vdpReg0A.w		; Set H-INT counter to 233
	move.w	vdpReg0A.w,(a6)

	move.w	#30,playerAirLeft		; Set air timer

	move	#$2300,sr			; Enable interrupts
	moveq	#3,d0				; Load Sonic's palette into both palette buffers
	bsr.w	LoadPalette
	moveq	#3,d0
	bsr.w	LoadFadePal

	bsr.w	LevelSizeLoad			; Get level size and start position
	bsr.w	LevelScroll			; Initialize level scrolling
	bset	#2,scrollFlags.w		; Force draw a block column on the left side of the screen
	bsr.w	LoadLevelData			; Load level data
	bsr.w	LevelDraw_Start			; Begin level drawing
	jsr	ConvColArray			; Convert collision data (dummied out)
	bsr.w	LoadLevelCollision		; Load collision block IDs

.WaitPLC2:
	move.b	#$C,vintRoutine.w		; VSync
	bsr.w	VSync
	bsr.w	ProcessPLCs			; Process PLCs
	bne.s	.WaitPLC2			; If the queue isn't empty, wait
	tst.l	plcBuffer.w			; Is the queue empty?
	bne.s	.WaitPLC2			; If not, wait

	bsr.w	LoadPlayer			; Load the player
	move.b	#$1C,objHUDScoreSlot.w		; Load HUD score object
	move.b	#$1C,objHUDLivesSlot.w		; Load HUD lives object
	move.b	#1,objHUDLivesSlot+oSubtype.w
	move.b	#$1C,objHUDRingsSlot.w		; Load HUD rings object
	move.b	#1,objHUDRingsSlot+oSubtype2.w
	bsr.w	LoadLifeIcon
	move.b	#$19,objHUDIconSlot.w		; Load HUD time icon object
	move.b	#$A,objHUDIconSlot+oSubtype.w

	bset	#1,plcLoadFlags			; Mark title card as loaded
	bne.s	.SkipTitleCard			; If it was already loaded, branch
	move.b	#$3C,objTtlCardSlot.w		; Load the title card
	move.b	#1,ctrlLocked.w			; Lock controls
	clr.b	lastCamPLC			; Reset last camera PLC

.SkipTitleCard:
	move.w	#0,playerCtrl.w			; Clear controller data
	move.w	#0,p1CtrlData.w
	move.w	#0,p2CtrlData.w
	move.w	#0,boredTimer.w			; Reset boredom timers
	move.w	#0,boredTimerP2.w
	move.b	#0,unkLevelFlag			; Clear unknown flag

	moveq	#0,d0
	tst.b	resetLevelFlags			; Was the level reset?
	bne.s	.SkipClear			; If so, branch
	move.w	d0,levelRings			; Reset ring count
	move.l	d0,levelTime			; Reset time
	move.b	d0,lifeFlags			; Reset 1UP flags

.SkipClear:
	move.b	d0,lvlTimeOver			; Clear time over flag
	move.b	d0,shieldFlag			; Clear shield flag
	move.b	d0,invincibleFlag		; Clear invincible  flag
	move.b	d0,speedShoesFlag		; Clear speed shoes flag
	move.b	d0,timeWarpFlag			; Clear time warp flag
	move.w	d0,lvlDebugMode			; Clear debug mode flag
	move.w	d0,levelRestart			; Clear level restart flag
	move.w	d0,lvlFrameTimer		; Reset frame timer
	move.b	d0,resetLevelFlags		; Clear level reset flags
	move.b	#1,updateScore			; Update the score in the HUD
	move.b	#1,updateRings			; Update the ring count in the HUD
	move.b	#1,updateTime			; Update the time in the HUD
	move.b	#1,updateLives			; Update the life counter in the HUD
	move.b	#$80,updateRings		; Initialize the score in the HUD
	move.b	#$80,updateScore		; Initialize the score in the HUD

	move.w	#0,demoS1Index.w		; Clear demo data index (Sonic 1 leftover)
	move.w	#$202F,palFadeInfo.w		; Set to fade palette lines 1-3

	jsr	JmpTo_LoadShieldArt		; Load shield art

	move.b	#1,lvlEnableDisplay		; Set to enable display on palette fade
	bclr	#7,timeZone			; Stop time travelling
	beq.s	.ChkPalFade			; If we weren't to begin with, branch

.FromWhite:
	bsr.w	FadeFromWhite			; Fade from white
	bra.s	.BeginLevel

.ChkPalFade:
	bclr	#0,palClearFlags		; Did we fill the palette with white?
	bne.s	.FromWhite			; If so, branch
	bsr.w	FadeFromBlack			; Fade from black

.BeginLevel:
	bclr	#7,gameMode.w			; Mark level as initialized
	move.b	#1,levelStarted			; Mark level as started

; -------------------------------------------------------------------------

Level_MainLoop:
	move.b	#8,vintRoutine.w		; VSync
	bsr.w	VSync

	if REGION=USA				; Did the player die?
		cmpi.b	#6,objPlayerSlot+oRoutine.w	
		bcc.s	.CheckPaused		; If so, branch
	endif
	tst.b	ctrlLocked.w			; Are controls locked?
	bne.s	.CheckPaused			; If so, branch
	btst	#7,p1CtrlTap.w			; Was the start button pressed?
	beq.s	.CheckPaused			; If not, branch
	eori.b	#1,paused.w			; Do pause/unpause

.CheckPaused:
	btst	#0,paused.w			; Is the game paused?
	beq.w	.NotPaused			; If not, branch

	bsr.w	PauseMusic			; Pause music

	move.b	p1CtrlTap.w,d0			; Get pressed buttons
	tst.b	timeAttackMode			; Are we in time attack mode?
	bne.s	.CheckReset			; If so, branch

	andi.b	#$70,d0				; Get A, B, or C
	if REGION=USA
		beq.s	Level_MainLoop		; If none of them were pressed, branch
	else
		cmpi.b	#$70,d0			; Were A, B, and C pressed?
		bne.s	Level_MainLoop		; If not, branch
	endif
	subq.b	#1,lifeCount			; Take away a life
	bpl.s	.GotLives			; If we haven't run out, branch
	clr.b	lifeCount			; Cap lives at 0

.GotLives:
	move.w	#$E,d0				; Fade out music
	jsr	SubCPUCmd

	bsr.w	ResetRespawnTable		; Clear respawn table
	clr.b	resetLevelFlags			; Clear level reset flags
	move.w	#1,levelRestart			; Restart the level
	bra.s	.DoReset

.CheckReset:
	andi.b	#$70,d0				; Was A, B, or C pressed?
	beq.w	Level_MainLoop			; If not, branch
	clr.b	lifeCount			; Set lives to 0

.DoReset:
	clr.b	paused.w			; Clear pause flag
	clr.w	demoMode			; Clear demo mode flag
	clr.b	lastCheckpoint			; Clear checkpoint flag
	bra.w	LevelStart			; Restart the level

.NotPaused:
	bsr.w	UnpauseMusic			; Unpause music

	addq.w	#1,lvlFrameTimer		; Increment frame timer

	jsr	LevelObjManager			; Load level objects
	jsr	RunObjects			; Run objects

	cmpi.w	#$800,demoTimer.w		; Has the demo time run out (not applicable here)?
	beq.w	LevelStart			; If so, restart the level
	tst.w	levelRestart			; Is the level restarting?
	bne.w	LevelStart			; If so, restart the level
	tst.w	lvlDebugMode			; Are we in debug mode?
	bne.s	.DoScroll			; If so, branch
	cmpi.b	#6,objPlayerSlot+oRoutine.w	; Is the player dead?
	bcs.s	.DoScroll			; If not, branch
	move.w	cameraY.w,bottomBound.w		; Set the bottom boundary of the level to wherever the camera is
	move.w	cameraY.w,destBottomBound.w
	bra.s	.DrawObjects			; Don't handle level scrolling

.DoScroll:
	bsr.w	LevelScroll			; Handle level scrolling

.DrawObjects:
	jsr	DrawObjects			; Draw objects

	tst.w	timeStopTimer			; Is the time stop timer active?
	bne.s	.SkipPalCycle			; If so, branch
	bsr.w	PalCycle			; Handle palette cycling

.SkipPalCycle:
	jsr	LoadCameraPLC_Incr		; Load camera based PLCs
	bsr.w	ProcessPLCs			; Process PLCs
	bsr.w	HandleGlobalAnims		; Handle global animations

	bra.w	Level_MainLoop			; Loop

; -------------------------------------------------------------------------
; Load the player object
; -------------------------------------------------------------------------

LoadPlayer:
	lea	objPlayerSlot.w,a1		; Player object
	moveq	#1,d0				; Set player object ID
	move.b	d0,oID(a1)
	tst.b	resetLevelFlags			; Was the level reset midway?
	beq.s	.End				; If not, branch
	move.w	#$78,oPlayerHurt(a1)		; If so, make the player invulnerable for a bit

.End:
	rts

; -------------------------------------------------------------------------
; Restore zone flowers
; -------------------------------------------------------------------------

RestoreZoneFlowers:
	lea	flowerCount,a1			; Get flower count bsaed on time zone
	moveq	#0,d0
	move.b	timeZone,d0
	bclr	#7,d0
	move.b	(a1,d0.w),d0
	beq.s	.End				; There are no flowers, exit

	subq.b	#1,d0				; Fix flower count for DBF
	lea	dynObjects.w,a2			; Dynamic object RAM
	moveq	#0,d1				; Flower ID

.Loop:
	move.b	#$1F,oID(a2)			; Load a flower
	move.w	d1,d2				; Get flower position buffer index based on time zone
	add.w	d2,d2
	add.w	d2,d2
	moveq	#0,d3
	move.b	timeZone,d3
	bclr	#7,d3
	lsl.w	#8,d3
	add.w	d3,d2
	lea	flowerPosBuf,a3			; Get flower position
	move.w	(a3,d2.w),oX(a2)
	move.w	2(a3,d2.w),oY(a2)

	adda.w	#oSize,a2			; Next object
	addq.b	#1,d1				; Next flower
	dbf	d0,.Loop			; Loop until finished

.End:
	rts

; -------------------------------------------------------------------------
; Load level collision
; -------------------------------------------------------------------------

LoadLevelCollision:
	moveq	#0,d0				; Get level collision pointer
	move.b	levelZone,d0
	lsl.w	#2,d0
	move.l	LevelColIndex(pc,d0.w),collisionPtr.w
	rts

; -------------------------------------------------------------------------

LevelColIndex:
	dc.l	LevelCollision			; They are all the same. For some reason,
	dc.l	LevelCollision			; the Sonic CD team decided to keep this table
	dc.l	LevelCollision			; instead of just directly setting the pointer
	dc.l	LevelCollision
	dc.l	LevelCollision
	dc.l	LevelCollision
	dc.l	LevelCollision
	dc.l	LevelCollision

; -------------------------------------------------------------------------
; Handle global animations
; -------------------------------------------------------------------------

HandleGlobalAnims:
	subq.b	#1,logSpikeAnimTimer		; Decrement Sonic 1 spiked log animation timer
	bpl.s	.Rings				; If it hasn't run out, branch
	move.b	#$B,logSpikeAnimTimer		; Reset animation timer
	subq.b	#1,logSpikeAnimFrame		; Decrement frame
	andi.b	#7,logSpikeAnimFrame		; Keep the frame in range

.Rings:
	subq.b	#1,ringAnimTimer		; Decrement ring animation timer
	bpl.s	.Unknown			; If it hasn't run out, branch
	move.b	#7,ringAnimTimer		; Reset animation timer
	addq.b	#1,ringAnimFrame		; Increment frame
	andi.b	#3,ringAnimFrame		; Keep the frame in range

.Unknown:
	subq.b	#1,lvlUnkAnimTimer		; Decrement Sonic 1 unused animation timer
	bpl.s	.RingSpill			; If it hasn't run out, branch
	move.b	#7,lvlUnkAnimTimer		; Reset animation timer
	addq.b	#1,lvlUnkAnimFrame		; Increment frame
	cmpi.b	#6,lvlUnkAnimFrame		; Keep the frame in range
	bcs.s	.RingSpill
	move.b	#0,lvlUnkAnimFrame

.RingSpill:
	tst.b	ringLossAnimTimer		; Has the ring spill timer run out?
	beq.s	.End				; If so, branch
	moveq	#0,d0				; Increment frame accumulator
	move.b	ringLossAnimTimer,d0
	add.w	ringLossAnimAccum,d0
	move.w	d0,ringLossAnimAccum
	rol.w	#7,d0				; Set ring spill frame
	andi.w	#3,d0
	move.b	d0,ringLossAnimFrame
	subq.b	#1,ringLossAnimTimer		; Decrement ring spill timer

.End:
	rts

; -------------------------------------------------------------------------
; Play level music
; -------------------------------------------------------------------------

PlayLevelMusic:
	moveq	#0,d0				; Get time zone
	moveq	#0,d1
	move.b	timeZone,d0
	bclr	#7,d0
	tst.b	timeAttackMode			; Are we in time attack mode?
	bne.s	.Notfuture			; If so, branch
	cmpi.b	#2,d0				; Are we in the future?
	bne.s	.NotFuture			; If not, branch
	add.b	goodFuture,d0			; Apply good future flag

.NotFuture:
	move.b	levelZone,d1			; Send music play Sub CPU command
	add.w	d1,d1
	add.w	d1,d1
	add.w	d0,d1
	moveq	#0,d0
	move.b	MusicPlayCmds(pc,d1.w),d0
	jmp	SubCPUCmd

; -------------------------------------------------------------------------

MusicPlayCmds:
	dc.b	$80, $F, $11, $10		; PPZ
	dc.b	$80, $12, $14, $13		; CCZ
	dc.b	$80, $15, $17, $16		; TTZ
	dc.b	$80, $18, $1A, $19		; QQZ
	dc.b	$80, $1B, $1D, $1C		; WWZ
	dc.b	$80, $1E, $20, $1F		; SSZ
	dc.b	$80, $21, $66, $22		; MMZ

; -------------------------------------------------------------------------
; Play Palmtree Panic present music
; -------------------------------------------------------------------------

PlayLevelMusic2:
	move.w	#$F,d0				; Play PPZ present music
	jsr	SubCPUCmd
; Continue to load the life icon

; -------------------------------------------------------------------------
; Load life icon
; -------------------------------------------------------------------------

LoadLifeIcon:
	move.l	#$74200002,d0			; Set VDP write command

	moveq	#0,d2				; Get pointer to life icon
	move.b	timeZone,d2
	bclr	#7,d2
	lsl.w	#7,d2
	move.l	d0,4(a6)
	lea	ArtUnc_LifeIcon,a1
	lea	(a1,d2.w),a3

	rept	32
		move.l	(a3)+,(a6)		; Load life icon
	endr

	rts

; -------------------------------------------------------------------------
; Pause the music
; -------------------------------------------------------------------------

PauseMusic:
	move.w	#$AB,d0				; Stop FM sound
	jsr	PlayFMSound

	bset	#7,paused.w			; Set the music as paused
	bne.s	.End				; If it was already paused, branch

	move.b	timeZone,d0			; Get time zone
	bclr	#7,d0
	tst.b	d0				; Are we in the past?
	beq.s	.Past				; If so, branch

.PauseMusic:
	move.w	#$D5,d0				; Pause CD music
	jmp	SubCPUCmd

.Past:
	tst.b	invincibleFlag			; Are we invincible?
	bne.s	.PauseMusic			; If so, pause the invincibility music
	tst.b	speedShoesFlag			; Do we have speed shoes?
	bne.s	.PauseMusic			; If so, pause the speed shoes music

	move.w	#$90,d0				; Pause PCM music
	jmp	SubCPUCmd

.End:
	rts

; -------------------------------------------------------------------------
; Unpause music
; -------------------------------------------------------------------------

UnpauseMusic:
	bclr	#7,paused.w			; Set the music as unpaused
	beq.s	.End				; If it was already unpaused, branch

	move.b	timeZone,d0			; Get time zone
	bclr	#7,d0
	tst.b	d0				; Are we in the past?
	beq.s	.Past				; If so, branch

.UnpauseMusic:
	move.w	#$D6,d0				; Unpause CD music
	jmp	SubCPUCmd

.Past:
	tst.b	invincibleFlag			; Are we invincible?
	bne.s	.UnpauseMusic			; If so, unpause the invincibility music
	tst.b	speedShoesFlag			; Do we have speed shoes?
	bne.s	.UnpauseMusic			; If so, unpause the speed shoes music

	move.w	#$91,d0				; Unpause PCM music
	jmp	SubCPUCmd

.End:
	rts

; -------------------------------------------------------------------------
; Vertical interrupt routine
; -------------------------------------------------------------------------

VInterrupt:
	bset	#0,GAIRQ2			; Send Sub CPU IRQ2 request
	movem.l	d0-a6,-(sp)			; Save registers

	tst.b	vintRoutine.w			; Are we lagging?
	beq.s	VInt_Lag			; If so, branch

	move.w	VDPCTRL,d0	
	move.l	#$40000010,VDPCTRL		; Update VScroll
	move.l	vscrollScreen.w,VDPDATA

	btst	#6,versionCache			; Is this a PAL console?
	beq.s	.NotPAL				; If not, branch
	move.w	#$700,d0			; Delay for a bit
	dbf	d0,*

.NotPAL:
	move.b	vintRoutine.w,d0		; Get V-INT routine ID
	move.b	#0,vintRoutine.w		; Mark V-INT as run
	andi.w	#$3E,d0
	move.w	VInt_Index(pc,d0.w),d0		; Run the current V-INT routine
	jsr	VInt_Index(pc,d0.w)

VInt_Finish:
	jsr	UpdateFMQueues			; Update FM driver queues
	tst.b	paused.w			; Is the game paused?
	bne.s	VInt_Done			; If so, branch
	bsr.w	RunBoredTimer			; Run boredom timer
	bsr.w	RunTimeWarp			; Run time warp timer

VInt_Done:
	addq.l	#1,lvlFrameCount		; Increment frame counter

	movem.l	(sp)+,d0-a6			; Restore registers
	rte

; -------------------------------------------------------------------------

VInt_Index:
	dc.w	VInt_Lag-VInt_Index		; Lag
	dc.w	VInt_General-VInt_Index		; General
	dc.w	VInt_S1Title-VInt_Index		; Sonic 1 title screen (leftover)
	dc.w	VInt_Unk6-VInt_Index		; Unknown (leftover)
	dc.w	VInt_Level-VInt_Index		; Level
	dc.w	VInt_S1SpecStg-VInt_Index	; Sonic 1 special stage (leftover)
	dc.w	VInt_LevelLoad-VInt_Index	; Level load
	dc.w	VInt_UnkE-VInt_Index		; Unknown (leftover)
	dc.w	VInt_Pause-VInt_Index		; Sonic 1 pause (leftover)
	dc.w	VInt_PalFade-VInt_Index		; Palette fade
	dc.w	VInt_S1SegaScr-VInt_Index	; Sonic 1 SEGA screen (leftover)
	dc.w	VInt_S1ContScr-VInt_Index	; Sonic 1 continue screen (leftover)
	dc.w	VInt_LevelLoad-VInt_Index	; Level load

; -------------------------------------------------------------------------
; V-INT lag routine
; -------------------------------------------------------------------------

VInt_Lag:
	tst.b	levelStarted			; Has the level started?
	beq.w	VInt_Finish			; If not, branch
	cmpi.b	#2,levelZone			; Are we in Tidal Tempest?
	bne.w	VInt_Finish			; If not, branch

	move.w	VDPCTRL,d0
	btst	#6,versionCache			; Is this a PAL console?
	beq.s	.NotPAL				; If not, branch
	move.w	#$700,d0			; Delay for a bit
	dbf	d0,*

.NotPAL:
	move.w	#1,hintFlag.w			; Set H-INT flag
	jsr	StopZ80				; Stop the Z80

	tst.b	waterFullscreen.w		; Is water filling the screen?
	bne.s	.WaterPal			; If so, branch
	lea	VDPCTRL,a5			; DMA palette buffer
	move.l	#$94009340,(a5)
	move.l	#$96FD9580,(a5)
	move.w	#$977F,(a5)
	move.w	#$C000,(a5)
	move.w	#$80,dmaCmdLow.w
	move.w	dmaCmdLow.w,(a5)
	bra.s	.Done

.WaterPal:
	lea	VDPCTRL,a5			; DMA water palette buffer
	move.l	#$94009340,(a5)
	move.l	#$96FD9540,(a5)
	move.w	#$977F,(a5)
	move.w	#$C000,(a5)
	move.w	#$80,dmaCmdLow.w
	move.w	dmaCmdLow.w,(a5)

.Done:
	move.w	vdpReg0A.w,(a5)			; Update H-INT counter
	jsr	StartZ80			; Start the Z80


	bra.w	VInt_Finish			; Finish V-INT

; -------------------------------------------------------------------------
; V-INT general routine
; -------------------------------------------------------------------------

VInt_General:
	bsr.w	DoVIntUpdates			; Do V-INT updates

VInt_S1SegaScr:					; Pointer to here is leftover from Sonic 1's
						; SEGA screen V-INT routine

	tst.w	vintTimer.w			; Is the V-INT timer running?
	beq.w	.End				; If not, branch
	subq.w	#1,vintTimer.w			; Decrement V-INT timer

.End:
	rts

; -------------------------------------------------------------------------
; Leftover dead code from Sonic 1's title screen V-INT routine
; -------------------------------------------------------------------------

VInt_S1Title:
	bsr.w	DoVIntUpdates			; Do V-INT updates
	bsr.w	LevelDraw_UpdateBG		; Draw level BG
	bsr.w	ProcessPLCDec			; Process PLC art decompression

	tst.w	vintTimer.w			; Is the V-INT timer running?
	beq.w	.End				; If not, branch
	subq.w	#1,vintTimer.w			; Decrement V-INT timer

.End:
	rts

; -------------------------------------------------------------------------
; Leftover dead code from Sonic 1's V-INT
; -------------------------------------------------------------------------

VInt_Unk6:
	bsr.w	DoVIntUpdates			; Do V-INT updates
	rts

; -------------------------------------------------------------------------
; Leftover dead code from Sonic 1's pause V-INT routine
; -------------------------------------------------------------------------

VInt_Pause:
	cmpi.b	#$10,gameMode.w			; Are we in the Sonic 1 special stage?
	beq.w	VInt_S1SpecStg			; If so, branch

; -------------------------------------------------------------------------
; V-INT level routine
; -------------------------------------------------------------------------

VInt_Level:
	jsr	StopZ80				; Stop the Z80
	bsr.w	ReadJoypads			; Read joypads

	lea	VDPCTRL,a5			; DMA palette
	move.l	#$94009340,(a5)
	move.l	#$96FD9580,(a5)
	move.w	#$977F,(a5)
	move.w	#$C000,(a5)
	move.w	#$80,dmaCmdLow.w
	move.w	dmaCmdLow.w,(a5)

	lea	VDPCTRL,a5			; DMA HScroll
	move.l	#$940193C0,(a5)
	move.l	#$96E69500,(a5)
	move.w	#$977F,(a5)
	move.w	#$7C00,(a5)
	move.w	#$83,dmaCmdLow.w
	move.w	dmaCmdLow.w,(a5)

	lea	VDPCTRL,a5			; DMA sprites
	move.l	#$94019340,(a5)
	move.l	#$96FC9500,(a5)
	move.w	#$977F,(a5)
	move.w	#$7800,(a5)
	move.w	#$83,dmaCmdLow.w
	move.w	dmaCmdLow.w,(a5)

	lea	objPlayerSlot.w,a0		; Load player sprite art
	bsr.w	LoadSonicDynPLC
	tst.b	updateSonicArt.w
	beq.s	.NoArtLoad
	lea	VDPCTRL,a5
	move.l	#$94019370,(a5)
	move.l	#$96E49500,(a5)
	move.w	#$977F,(a5)
	move.w	#$7000,(a5)
	move.w	#$83,dmaCmdLow.w
	move.w	dmaCmdLow.w,(a5)
	move.b	#0,updateSonicArt.w

.NoArtLoad:
	jsr	JmpTo_LoadShieldArt		; Load shield art
	jsr	StartZ80			; Start the Z80

	movem.l	cameraX.w,d0-d7			; Draw level
	movem.l	d0-d7,lvlCamXCopy
	movem.l	scrollFlags.w,d0-d1
	movem.l	d0-d1,lvlScrollFlagsCopy
	bsr.w	LevelDraw_Update

	bsr.w	ProcessPLCDec_Small		; Process PLC art decompression
	jmp	UpdateHUD			; Update the HUD

; -------------------------------------------------------------------------
; Emptied out code from Sonic 1's special stage V-INT routine
; -------------------------------------------------------------------------

VInt_S1SpecStg:
	rts

; -------------------------------------------------------------------------
; V-INT level load routine
; -------------------------------------------------------------------------

VInt_LevelLoad:
	jsr	StopZ80				; Stop the Z80
	bsr.w	ReadJoypads			; Read joypads

	lea	VDPCTRL,a5			; DMA palette
	move.l	#$94009340,(a5)
	move.l	#$96FD9580,(a5)
	move.w	#$977F,(a5)
	move.w	#$C000,(a5)
	move.w	#$80,dmaCmdLow.w
	move.w	dmaCmdLow.w,(a5)

	lea	VDPCTRL,a5			; DMA HScroll
	move.l	#$940193C0,(a5)
	move.l	#$96E69500,(a5)
	move.w	#$977F,(a5)
	move.w	#$7C00,(a5)
	move.w	#$83,dmaCmdLow.w
	move.w	dmaCmdLow.w,(a5)

	lea	VDPCTRL,a5			; DMA sprites
	move.l	#$94019340,(a5)
	move.l	#$96FC9500,(a5)
	move.w	#$977F,(a5)
	move.w	#$7800,(a5)
	move.w	#$83,dmaCmdLow.w
	move.w	dmaCmdLow.w,(a5)

	jsr	StartZ80			; Start the Z80

	movem.l	cameraX.w,d0-d7			; Draw level
	movem.l	d0-d7,lvlCamXCopy
	movem.l	scrollFlags.w,d0-d1
	movem.l	d0-d1,lvlScrollFlagsCopy
	bsr.w	LevelDraw_Update

	bra.w	ProcessPLCDec			; Process PLC art decompression

; -------------------------------------------------------------------------
; Leftover dead code from Sonic 1's V-INT
; -------------------------------------------------------------------------

VInt_UnkE:
	bsr.w	DoVIntUpdates			; Do V-INT updates

	addq.b	#1,vintECount.w			; Increment counter
	move.b	#$E,vintRoutine.w		; Set to run this routine again next VBlank

	rts

; -------------------------------------------------------------------------
; V-INT palette fade routine
; -------------------------------------------------------------------------

VInt_PalFade:
	bsr.w	DoVIntUpdates			; Do V-INT updates

	cmpi.b	#1,lvlEnableDisplay		; Should we enable display?
	bne.s	.SetHIntCounter			; If not, branch
	addq.b	#1,lvlEnableDisplay		; Set display as enabled

	move.w	vdpReg01.w,d0			; Enable display
	ori.b	#$40,d0
	move.w	d0,VDPCTRL

.SetHIntCounter:
	move.w	vdpReg0A.w,(a5)			; Set H-INT counter
	bra.w	ProcessPLCDec			; Process PLC art decompression

; -------------------------------------------------------------------------
; Leftover dead code from Sonic 1's continue screen V-INT routine
; -------------------------------------------------------------------------

VInt_S1ContScr:
	jsr	StopZ80				; Stop the Z80
	bsr.w	ReadJoypads			; Read joypads

	lea	VDPCTRL,a5			; DMA palette
	move.l	#$94009340,(a5)
	move.l	#$96FD9580,(a5)
	move.w	#$977F,(a5)
	move.w	#$C000,(a5)
	move.w	#$80,dmaCmdLow.w
	move.w	dmaCmdLow.w,(a5)

	lea	VDPCTRL,a5			; DMA sprites
	move.l	#$94019340,(a5)
	move.l	#$96FC9500,(a5)
	move.w	#$977F,(a5)
	move.w	#$7800,(a5)
	move.w	#$83,dmaCmdLow.w
	move.w	dmaCmdLow.w,(a5)

	lea	VDPCTRL,a5			; DMA HScroll
	move.l	#$940193C0,(a5)
	move.l	#$96E69500,(a5)
	move.w	#$977F,(a5)
	move.w	#$7C00,(a5)
	move.w	#$83,dmaCmdLow.w
	move.w	dmaCmdLow.w,(a5)

	jsr	StartZ80			; Start the Z80

	lea	objPlayerSlot.w,a0		; Load player sprite art
	bsr.w	LoadSonicDynPLC
	tst.b	updateSonicArt.w
	beq.s	.NoArtLoad
	lea	VDPCTRL,a5
	move.l	#$94019370,(a5)
	move.l	#$96E49500,(a5)
	move.w	#$977F,(a5)
	move.w	#$7000,(a5)
	move.w	#$83,dmaCmdLow.w
	move.w	dmaCmdLow.w,(a5)
	move.b	#0,updateSonicArt.w

.NoArtLoad:
	tst.w	vintTimer.w			; Is the V-INT timer running?
	beq.w	.End				; If not, branch
	subq.w	#1,vintTimer.w			; Decrement V-INT timer

.End:
	rts

; -------------------------------------------------------------------------
; Do common V-INT updates
; -------------------------------------------------------------------------

DoVIntUpdates:
	jsr	StopZ80				; Stop the Z80
	bsr.w	ReadJoypads			; Read joypads

	tst.b	waterFullscreen.w		; Is water filling the screen?
	bne.s	.WaterPal			; If so, branch
	lea	VDPCTRL,a5			; DMA palette buffer
	move.l	#$94009340,(a5)
	move.l	#$96FD9580,(a5)
	move.w	#$977F,(a5)
	move.w	#$C000,(a5)
	move.w	#$80,dmaCmdLow.w
	move.w	dmaCmdLow.w,(a5)
	bra.s	.LoadedPal

.WaterPal:
	lea	VDPCTRL,a5			; DMA water palette buffer
	move.l	#$94009340,(a5)
	move.l	#$96FD9540,(a5)
	move.w	#$977F,(a5)
	move.w	#$C000,(a5)
	move.w	#$80,dmaCmdLow.w
	move.w	dmaCmdLow.w,(a5)

.LoadedPal:
	lea	VDPCTRL,a5			; DMA sprites
	move.l	#$94019340,(a5)
	move.l	#$96FC9500,(a5)
	move.w	#$977F,(a5)
	move.w	#$7800,(a5)
	move.w	#$83,dmaCmdLow.w
	move.w	dmaCmdLow.w,(a5)

	lea	VDPCTRL,a5			; DMA HScroll
	move.l	#$940193C0,(a5)
	move.l	#$96E69500,(a5)
	move.w	#$977F,(a5)
	move.w	#$7C00,(a5)
	move.w	#$83,dmaCmdLow.w
	move.w	dmaCmdLow.w,(a5)

	jmp	StartZ80			; Start the Z80

; -------------------------------------------------------------------------
; Horizontal interrupt routine
; -------------------------------------------------------------------------

HInterrupt:
	rte

; -------------------------------------------------------------------------
; Run time warp timer
; -------------------------------------------------------------------------

RunTimeWarp:
	tst.b	objPlayerSlot+oPlayerCharge.w	; Is the player charging?
	bne.s	.End				; If so, branch
	tst.w	timeWarpTimer.w			; Is the time warp timer active?
	beq.s	.End				; If not, branch	
	addq.w	#1,timeWarpTimer.w		; Increment time warp timer

.End:
	rts

; -------------------------------------------------------------------------
; Run boredom timer
; -------------------------------------------------------------------------

RunBoredTimer:
	tst.w	boredTimer.w			; Is the bored timer active?
	beq.s	.CheckP2Timer			; If not, branch
	addq.w	#1,boredTimer.w			; Increment bored timer

.CheckP2Timer:
	tst.w	boredTimerP2.w			; Is the player 2 bored timer active?
	beq.s	.End				; If not, branch
	addq.w	#1,boredTimerP2.w		; Increment player 2 bored timer

.End:
	rts

; -------------------------------------------------------------------------
; Get a random number
; -------------------------------------------------------------------------
; RETURNS:
;	d0.l - Random number
; -------------------------------------------------------------------------

RandomNumber:
	move.l	d1,-(sp)
	move.l	rngSeed.w,d1			; Get RNG seed
	bne.s	.GotSeed			; If it's set, branch
	move.l	#$2A6D365A,d1			; Reset RNG seed otherwise

.GotSeed:
	move.l	d1,d0				; Get random number
	asl.l	#2,d1
	add.l	d0,d1
	asl.l	#3,d1
	add.l	d0,d1
	move.w	d1,d0
	swap	d1
	add.w	d1,d0
	move.w	d0,d1
	swap	d1
	move.l	d1,rngSeed.w			; Update RNG seed
	move.l	(sp)+,d1
	rts

; -------------------------------------------------------------------------
; Initialize joypads
; -------------------------------------------------------------------------

InitJoypads:
	bsr.w	StopZ80				; Stop the Z80

	moveq	#$40,d0				; Initialize controller ports
	move.b	d0,IOCTRL1
	move.b	d0,IOCTRL2
	move.b	d0,IOCTRL3

	bra.w	StartZ80			; Start the Z80

; -------------------------------------------------------------------------
; Read joypad data
; -------------------------------------------------------------------------

ReadJoypads:
	lea	p1CtrlData.w,a0			; Read player 1 controller
	lea	IODATA1,a1
	bsr.s	ReadJoypad
	addq.w	#p2CtrlData-p1CtrlData,a1	; Read player 2 controller

; -------------------------------------------------------------------------
; Read a joypad's data
; -------------------------------------------------------------------------

ReadJoypad:
	move.b	#0,(a1)				; Pull TH low
	nop
	nop
	move.b	(a1),d0				; Get start and A button
	lsl.b	#2,d0
	andi.b	#$C0,d0
	move.b	#$40,(a1)			; Pull TH high
	nop
	nop
	move.b	(a1),d1				; Get B, C, and directional buttons
	andi.b	#$3F,d1
	or.b	d1,d0				; Combine buttons
	not.b	d0				; Swap bits
	move.b	(a0),d1				; Prepare previously held buttons
	eor.b	d0,d1
	move.b	d0,(a0)+			; Store new held buttons
	and.b	d0,d1				; Update pressed buttons
	move.b	d1,(a0)+
	rts

; -------------------------------------------------------------------------
; Initialize the VDP
; -------------------------------------------------------------------------

InitVDP:
	lea	VDPCTRL,a0			; Get VDP ports
	lea	VDPDATA,a1

	lea	VDPInitRegs,a2			; Prepare VDP registers
	moveq	#$13-1,d7

.InitRegs:
	move.w	(a2)+,(a0)			; Set VDP register
	dbf	d7,.InitRegs			; Loop until finished

	move.w	VDPInitReg1,d0			; Set VDP register 1
	move.w	d0,vdpReg01.w
	move.w	#$8ADF,vdpReg0A.w		; Set H-INT counter

	moveq	#0,d0				; Clear CRAM
	move.l	#$C0000000,VDPCTRL
	move.w	#$3F,d7

.ClearCRAM:
	move.w	d0,(a1)
	dbf	d7,.ClearCRAM			; Loop until finished

	clr.l	vscrollScreen.w			; Clear scroll values
	clr.l	hscrollScreen.w

	move.l	d1,-(sp)			; Clear VRAM via DMA fill
	lea	VDPCTRL,a5
	move.w	#$8F01,(a5)
	move.l	#$94FF93FF,(a5)
	move.w	#$9780,(a5)
	move.l	#$40000080,(a5)
	move.w	#0,VDPDATA

.WaitVRAMClear:
	move.w	(a5),d1
	btst	#1,d1
	bne.s	.WaitVRAMClear
	move.w	#$8F02,(a5)
	move.l	(sp)+,d1

	rts

; -------------------------------------------------------------------------

VDPInitRegs:
	dc.w	$8004				; H-INT disabled
VDPInitReg1:
	dc.w	$8134				; DMA and V-INT enabled, display disabled
	dc.w	$8230				; Plane A at $C000
	dc.w	$8328				; Window plane at $A000
	dc.w	$8407				; Plane B at $E000
	dc.w	$857C				; Sprite table at $F800
	dc.w	$8600				; Unused
	dc.w	$8700				; Background color at line 0 color 0
	dc.w	$8800				; Unused
	dc.w	$8900				; Unused
	dc.w	$8A00				; H-INT counter 0
	dc.w	$8B00				; HScroll by screen, VScroll by screen
	dc.w	$8C81				; H40 mode
	dc.w	$8D3F				; HScroll at $FC00
	dc.w	$8E00				; Unused
	dc.w	$8F02				; Auto-increment by 2
	dc.w	$9001				; Plane size 64x32
	dc.w	$9100				; Window X at 0
	dc.w	$9200				; Window Y at 0

; -------------------------------------------------------------------------
; Clear the screen
; -------------------------------------------------------------------------

ClearScreen:
	lea	VDPCTRL,a5			; Clear plane A
	move.w	#$8F01,(a5)
	move.l	#$940F93FF,(a5)
	move.w	#$9780,(a5)
	move.l	#$40000083,(a5)
	move.w	#0,VDPDATA

.WaitPlane1Clear:
	move.w	(a5),d1
	btst	#1,d1
	bne.s	.WaitPlane1Clear
	move.w	#$8F02,(a5)

	lea	VDPCTRL,a5			; Clear plane B
	move.w	#$8F01,(a5)
	move.l	#$940F93FF,(a5)
	move.w	#$9780,(a5)
	move.l	#$60000083,(a5)
	move.w	#0,VDPDATA

.WaitPlane2Clear:
	move.w	(a5),d1
	btst	#1,d1
	bne.s	.WaitPlane2Clear
	move.w	#$8F02,(a5)

	clr.l	vscrollScreen.w			; Reset scroll values
	clr.l	hscrollScreen.w

	lea	sprites.w,a1			; Clear sprite buffer
	moveq	#0,d0
	move.w	#$280/4,d1			; Should be $280/4-1

.ClearSprites:
	move.l	d0,(a1)+
	dbf	d1,.ClearSprites

	lea	hscroll.w,a1			; Clear horizontal scroll buffer
	moveq	#0,d0
	move.w	#$400/4,d1			; Should be $400/4-1

.ClearHScroll:
	move.l	d0,(a1)+
	dbf	d1,.ClearHScroll

	rts

; -------------------------------------------------------------------------
; Stop the Z80
; -------------------------------------------------------------------------

StopZ80:
	move	sr,savedSR.w			; Save SR
	move	#$2700,sr			; Disable interrupts
	move.w	#$100,Z80BUS			; Stop the Z80

.Wait:
	btst	#0,Z80BUS
	bne.s	.Wait
	rts

; -------------------------------------------------------------------------
; Start the Z80
; -------------------------------------------------------------------------

StartZ80:
	move.w	#0,Z80BUS			; Start the Z80
	move	savedSR.w,sr			; Restore SR
	rts

; -------------------------------------------------------------------------
; Dead code to initialize the Z80 with dummy code
; -------------------------------------------------------------------------

InitZ80_Dummy:
	move.w	#$100,Z80RESET			; Stop Z80 reset
	jsr	StopZ80(pc)			; Stop the Z80

	lea	Z80RAM,a1			; Prepare Z80 RAM
	move.b	#$F3,(a1)+			; di
	move.b	#$F3,(a1)+			; di
	move.b	#$C3,(a1)+			; jp $0000
	move.b	#0,(a1)+
	move.b	#0,(a1)+

	move.w	#0,Z80RESET			; Reset the Z80
	ror.b	#8,d0				; Wait
	move.w	#$100,Z80RESET			; Stop Z80 reset
	jmp	StartZ80(pc)			; Start the Z80
	rts

; -------------------------------------------------------------------------
; Play an FM sound
; -------------------------------------------------------------------------

PlayFMSound:
	tst.b	fmSndQueue1.w			; Is queue 1 full?
	bne.s	.CheckQueue2			; If so, branch
	move.b	d0,fmSndQueue1.w		; Set ID in queue 1
	rts


.CheckQueue2:
	tst.b	fmSndQueue2.w			; Is queue 2 full?
	bne.s	.CheckQueue3			; If so, branch
	move.b	d0,fmSndQueue2.w		; Set ID in queue 2
	rts


.CheckQueue3:
	tst.b	fmSndQueue3.w			; Is queue 3 full?
	bne.s	.End				; If so, branch
	move.b	d0,fmSndQueue3.w		; Set ID in queue 3

.End:
	rts

; -------------------------------------------------------------------------
; Update FM driver queues
; -------------------------------------------------------------------------

UpdateFMQueues:
	jsr	StopZ80				; Stop the Z80

	tst.b	fmSndQueue1.w			; Is queue 1 full?
	beq.s	.CheckQueue2			; If not, branch
	move.b	fmSndQueue1.w,FMDrvQueue1	; Update Z80 queue 1
	move.b	#0,fmSndQueue1.w		; Empty out queue 1

.CheckQueue2:
	tst.b	fmSndQueue2.w			; Is queue 2 full?
	beq.s	.CheckQueue3			; If not, branch
	move.b	fmSndQueue2.w,FMDrvQueue2	; Update Z80 queue 2
	move.b	#0,fmSndQueue2.w		; Empty out queue 2

.CheckQueue3:
	tst.b	fmSndQueue3.w			; Is queue 3 full?
	beq.s	.End				; If not, branch
	move.b	fmSndQueue3.w,FMDrvQueue3	; Update Z80 queue 3
	move.b	#0,fmSndQueue3.w		; Empty out queue 3

.End:
	bra.w	StartZ80			; Start the Z80

; -------------------------------------------------------------------------
; Draw a tilemap
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - Base VDP command
;	d1.w - Tilemap width (minus 1)
;	d2.w - Tilemap height (minus 1)
;	a1.l - Tilemap data pointer
; -------------------------------------------------------------------------

DrawTilemap:
	lea	VDPDATA,a6			; Prepare VDP data
	move.l	#$800000,d4			; VDP command line delta

.RowLoop:
	move.l	d0,4(a6)			; Set VDP command
	move.w	d1,d3				; Prepare row width

.TileLoop:
	move.w	(a1)+,(a6)			; Copy tile data
	dbf	d3,.TileLoop			; Loop until row is drawn

	add.l	d4,d0				; Next row
	dbf	d2,.RowLoop			; Loop until tilemap is drawn
	rts

; -------------------------------------------------------------------------
; Decompress Nemesis art into VRAM (Note: VDP write command must be
; set beforehand)
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Nemesis art pointer
; -------------------------------------------------------------------------

NemDec:
	movem.l	d0-a1/a3-a5,-(sp)
	lea	NemPCD_WriteRowToVDP,a3		; Write all data to the same location
	lea	VDPDATA,a4			; VDP data port
	bra.s	NemDecMain

; -------------------------------------------------------------------------
; Decompress Nemesis data into RAM
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Nemesis data pointer
;	a4.l - Destination buffer pointer
; -------------------------------------------------------------------------

NemDecToRAM:
	movem.l	d0-a1/a3-a5,-(sp)
	lea	NemPCD_WriteRowToRAM,a3		; Advance to the next location after each write

; -------------------------------------------------------------------------

NemDecMain:
	lea	nemBuffer.w,a1			; Prepare decompression buffer
	move.w	(a0)+,d2			; Get number of patterns
	lsl.w	#1,d2
	bcc.s	.NormalMode			; Branch if not in XOR mode
	adda.w	#NemPCD_WriteRowToVDP_XOR-NemPCD_WriteRowToVDP,a3

.NormalMode:
	lsl.w	#2,d2				; Get number of 8-pixel rows in the uncompressed data
	movea.w	d2,a5				; and store it in a5
	moveq	#8,d3				; 8 pixels in a pattern row
	moveq	#0,d2
	moveq	#0,d4
	bsr.w	NemDec_BuildCodeTable
	move.b	(a0)+,d5			; Get first word of compressed data
	asl.w	#8,d5
	move.b	(a0)+,d5
	move.w	#16,d6				; Set initial shift value
	bsr.s	NemDec_ProcessCompressedData
	movem.l	(sp)+,d0-a1/a3-a5
	rts

; -------------------------------------------------------------------------

NemDec_ProcessCompressedData:
	move.w	d6,d7
	subq.w	#8,d7				; Get shift value
	move.w	d5,d1
	lsr.w	d7,d1				; Shift so that the high bit of the code is in bit 7
	cmpi.b	#%11111100,d1			; Are the high 6 bits set?
	bcc.s	NemPCD_InlineData		; If they are, it signifies inline data
	andi.w	#$FF,d1
	add.w	d1,d1
	move.b	(a1,d1.w),d0			; Get the length of the code in bits
	ext.w	d0
	sub.w	d0,d6				; Subtract from shift value so that the next code is read next time around
	cmpi.w	#9,d6				; Does a new byte need to be read?
	bcc.s	.GotEnoughBits			; If not, branch
	addq.w	#8,d6
	asl.w	#8,d5
	move.b	(a0)+,d5			; Read next byte

.GotEnoughBits:
	move.b	1(a1,d1.w),d1
	move.w	d1,d0
	andi.w	#$F,d1				; Get palette index for pixel
	andi.w	#$F0,d0

NemDec_GetRunLength:
	lsr.w	#4,d0				; Get repeat count

NemDec_RunLoop:
	lsl.l	#4,d4				; Shift up by a nibble
	or.b	d1,d4				; Write pixel
	subq.w	#1,d3				; Has an entire 8-pixel row been written?
	bne.s	NemPCD_WritePixel_Loop		; If not, loop
	jmp	(a3)				; Otherwise, write the row to its destination

; -------------------------------------------------------------------------

NemPCD_NewRow:
	moveq	#0,d4				; Reset row
	moveq	#8,d3				; Reset nibble counter

NemPCD_WritePixel_Loop:
	dbf	d0,NemDec_RunLoop
	bra.s	NemDec_ProcessCompressedData

; -------------------------------------------------------------------------

NemPCD_InlineData:
	subq.w	#6,d6				; 6 bits needed to signal inline data
	cmpi.w	#9,d6
	bcc.s	.GotEnoughBits
	addq.w	#8,d6
	asl.w	#8,d5
	move.b	(a0)+,d5

.GotEnoughBits:
	subq.w	#7,d6				; And 7 bits needed for the inline data itself
	move.w	d5,d1
	lsr.w	d6,d1				; Shift so that the low bit of the code is in bit 0
	move.w	d1,d0
	andi.w	#$F,d1				; Get palette index for pixel
	andi.w	#$70,d0				; High nibble is repeat count for pixel
	cmpi.w	#9,d6
	bcc.s	NemDec_GetRunLength
	addq.w	#8,d6
	asl.w	#8,d5
	move.b	(a0)+,d5
	bra.s	NemDec_GetRunLength

; -------------------------------------------------------------------------

NemPCD_WriteRowToVDP:
	move.l	d4,(a4)				; Write 8-pixel row
	subq.w	#1,a5
	move.w	a5,d4				; Have all the 8-pixel rows been written?
	bne.s	NemPCD_NewRow			; If not, branch
	rts

; -------------------------------------------------------------------------

NemPCD_WriteRowToVDP_XOR:
	eor.l	d4,d2				; XOR the previous row with the current row
	move.l	d2,(a4)				; and store it
	subq.w	#1,a5
	move.w	a5,d4				; Have all the 8-pixel rows been written?
	bne.s	NemPCD_NewRow			; If not, branch
	rts

; -------------------------------------------------------------------------

NemPCD_WriteRowToRAM:
	move.l	d4,(a4)+			; Write 8-pixel row
	subq.w	#1,a5
	move.w	a5,d4				; Have all the 8-pixel rows been written?
	bne.s	NemPCD_NewRow			; If not, branch
	rts

; -------------------------------------------------------------------------

NemPCD_WriteRowToRAM_XOR:
	eor.l	d4,d2				; XOR the previous row with the current row
	move.l	d2,(a4)+			; and store it
	subq.w	#1,a5
	move.w	a5,d4				; Have all the 8-pixel rows been written?
	bne.s	NemPCD_NewRow			; If not, branch
	rts

; -------------------------------------------------------------------------

NemDec_BuildCodeTable:
	move.b	(a0)+,d0			; Read first byte

NemBCT_ChkEnd:
	cmpi.b	#$FF,d0				; Has the end of the code table description been reached?
	bne.s	NemBCT_NewPALIndex		; If not, branch
	rts

NemBCT_NewPALIndex:
	move.w	d0,d7

NemBCT_Loop:
	move.b	(a0)+,d0			; Read next byte
	cmpi.b	#$80,d0				; Sign bit signifies a new palette index
	bcc.s	NemBCT_ChkEnd

	move.b	d0,d1
	andi.w	#$F,d7				; Get palette index
	andi.w	#$70,d1				; Get repeat count for palette index
	or.w	d1,d7				; Combine the 2
	andi.w	#$F,d0				; Get the length of the code in bits
	move.b	d0,d1
	lsl.w	#8,d1
	or.w	d1,d7				; Combine with palette index and repeat count to form code table entry
	moveq	#8,d1
	sub.w	d0,d1				; Is the code 8 bits long?
	bne.s	NemBCT_ShortCode		; If not, a bit of extra processing is needed
	move.b	(a0)+,d0			; Get code
	add.w	d0,d0				; Each code gets a word sized entry in the table
	move.w	d7,(a1,d0.w)			; Store the entry for the code

	bra.s	NemBCT_Loop			; Loop

NemBCT_ShortCode:
	move.b	(a0)+,d0			; Get code
	lsl.w	d1,d0				; Get index into code table
	add.w	d0,d0				; Shift so that the high bit is in bit 7
	moveq	#1,d5
	lsl.w	d1,d5
	subq.w	#1,d5				; d5 = 2^d1 - 1

NemBCT_ShortCode_Loop:
	move.w	d7,(a1,d0.w)			; Store entry
	addq.w	#2,d0				; Increment index
	dbf	d5,NemBCT_ShortCode_Loop	; Repeat for required number of entries

	bra.s	NemBCT_Loop			; Loop

; -------------------------------------------------------------------------
; Load a PLC list
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - PLC list ID
; -------------------------------------------------------------------------

LoadPLC:
	movem.l	a1-a2,-(sp)
	lea	PLCIndex,a1			; Prepare PLC list index
	add.w	d0,d0				; Get pointer to PLC list
	move.w	(a1,d0.w),d0
	lea	(a1,d0.w),a1
	lea	plcBuffer.w,a2			; Prepare PLC buffer

.Loop:
	tst.l	(a2)				; Is this PLC entry free?
	beq.s	.FoundFree			; If so, branch
	addq.w	#6,a2				; Check next entry
	bra.s	.Loop

.FoundFree:
	move.w	(a1)+,d0			; Get number of PLC entries
	bmi.s	.Restore			; If it's 0 (or less), branch

.Load:
	move.l	(a1)+,(a2)+			; Copy art pointer
	move.w	(a1)+,(a2)+			; Copy VRAM location
	dbf	d0,.Load			; Loop until all entries are queued

.Restore:
	movem.l	(sp)+,a1-a2
	rts

; -------------------------------------------------------------------------
; Clear PLCs and load a PLC list
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - PLC list ID
; -------------------------------------------------------------------------


ClearAndLoadPLC:
	movem.l	a1-a2,-(sp)
	lea	PLCIndex,a1			; Prepare PLC list index
	add.w	d0,d0				; Get pointer to PLC list
	move.w	(a1,d0.w),d0
	lea	(a1,d0.w),a1

	bsr.s	ClearPLCs			; Clear PLCs

	lea	plcBuffer.w,a2			; Prepare PLC buffer

	move.w	(a1)+,d0			; Get number of PLC entries
	bmi.s	.Restore			; If it's 0 (or less), branch

.Load:
	move.l	(a1)+,(a2)+			; Copy art pointer
	move.w	(a1)+,(a2)+			; Copy VRAM location
	dbf	d0,.Load			; Loop until all entries are queued

.Restore:
	movem.l	(sp)+,a1-a2
	rts

; -------------------------------------------------------------------------
; Clear PLCs
; -------------------------------------------------------------------------

ClearPLCs:
	lea	plcBuffer.w,a2			; Clear PLC buffer
	moveq	#$80/4-1,d0

.Clear:
	clr.l	(a2)+
	dbf	d0,.Clear			; Loop until finished
	rts

; -------------------------------------------------------------------------
; Process PLC queue in RAM
; -------------------------------------------------------------------------

ProcessPLCs:
	tst.l	plcBuffer.w			; Is the PLC queue empty?
	beq.s	.End				; If so, branch
	tst.w	plcTileCount.w			; Is there a decompression in process already?
	bne.s	.End				; If so, branch

	movea.l	plcBuffer.w,a0			; Get art pointer
	lea	NemPCD_WriteRowToVDP,a3		; Write to VRAM
	lea	nemBuffer.w,a1			; Prepare Nemesis buffer
	move.w	(a0)+,d2
	bpl.s	.NotXOR				; Branch if not in XOR mode
	adda.w	#NemPCD_WriteRowToVDP_XOR-NemPCD_WriteRowToVDP,a3

.NotXOR:
	andi.w	#$7FFF,d2			; Store number of tiles to decompress
	move.w	d2,plcTileCount.w

	bsr.w	NemDec_BuildCodeTable		; Build code table for this art

	move.b	(a0)+,d5			; Get first word of compressed data
	asl.w	#8,d5
	move.b	(a0)+,d5
	moveq	#$10,d6				; Set initial shift value

	moveq	#0,d0				; Prepare decompression registers
	move.l	a0,plcBuffer.w
	move.l	a3,plcNemWrite.w
	move.l	d0,plcRepeat.w
	move.l	d0,plcPixel.w
	move.l	d0,plcRow.w
	move.l	d5,plcRead.w
	move.l	d6,plcShift.w

.End:
	rts

; -------------------------------------------------------------------------
; Process PLC decompression
; -------------------------------------------------------------------------

ProcessPLCDec:
	tst.w	plcTileCount.w			; Is there anything to decompress?
	beq.w	ProcessPLCDec_Done		; If not, branch

; -------------------------------------------------------------------------

ProcessPLCDec_Large:
	move.w	#18,plcProcTileCnt.w		; Decompress 18 tiles in this batch
	moveq	#0,d0				; Get VRAM address
	move.w	plcBuffer+4.w,d0
	addi.w	#18*$20,plcBuffer+4.w		; Advance VRAM address
	bra.s	ProcessPLCDec_Main

; -------------------------------------------------------------------------
; Process PLC decompression (smaller batch)
; -------------------------------------------------------------------------

ProcessPLCDec_Small:
	tst.w	plcTileCount.w			; Is there anything to decompress?
	beq.s	ProcessPLCDec_Done		; If not, branch
	tst.b	scrollLock.w			; Is scrolling locked?
	bne.s	ProcessPLCDec_Large		; If so, go with the large batch instead

	move.w	#3,plcProcTileCnt.w		; Decompress 3 tiles in this batch
	moveq	#0,d0				; Get VRAM address
	move.w	plcBuffer+4.w,d0
	addi.w	#3*$20,plcBuffer+4.w		; Advance VRAM address

; -------------------------------------------------------------------------

ProcessPLCDec_Main:
	lea	VDPCTRL,a4			; Set VDP write command
	lsl.l	#2,d0
	lsr.w	#2,d0
	ori.w	#$4000,d0
	swap	d0
	move.l	d0,(a4)
	subq.w	#4,a4				; Prepare data port

	movea.l	plcBuffer.w,a0			; Get decompression registers
	movea.l	plcNemWrite.w,a3
	move.l	plcRepeat.w,d0
	move.l	plcPixel.w,d1
	move.l	plcRow.w,d2
	move.l	plcRead.w,d5
	move.l	plcShift.w,d6
	lea	nemBuffer.w,a1

.Decomp:
	movea.w	#8,a5				; Store decompressed tile in VRAM
	bsr.w	NemPCD_NewRow
	subq.w	#1,plcTileCount.w		; Decrement total tile count
	beq.s	ProcessPLCDec_Pop		; If this art is finished being decompressed, branch
	subq.w	#1,plcProcTileCnt.w		; Decrement number of tiles left to decompress in this batch
	bne.s	.Decomp				; If we are not done, branch

	move.l	a0,plcBuffer.w			; Update decompression registers
	move.l	a3,plcNemWrite.w
	move.l	d0,plcRepeat.w
	move.l	d1,plcPixel.w
	move.l	d2,plcRow.w
	move.l	d5,plcRead.w
	move.l	d6,plcShift.w

ProcessPLCDec_Done:
	rts

; -------------------------------------------------------------------------

ProcessPLCDec_Pop:
; This code is bugged. Due to the fact that 15 PLC queue entries = $5A bytes,
; which is not divisible by 4, this code only copies over $58 bytes, which means
; the last VRAM address in the queue is left out. It also doesn't properly
; clear out the popped entry, so if the queue is full, then it'll constantly
; queue the last entry over and over again.
	lea	plcBuffer.w,a0			; Pop a PLC queue entry out
	moveq	#($60-6)/4-1,d0			; Copy $58 bytes (instead of the proper $5A)

.Pop:
	move.l	6(a0),(a0)+
	dbf	d0,.Pop
	rts

; -------------------------------------------------------------------------
; Load and decompress a PLC list immediately
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - PLC list ID
; -------------------------------------------------------------------------

LoadPLCImm:
	lea	PLCIndex,a1			; Prepare PLC list index
	add.w	d0,d0				; Get pointer to PLC list
	move.w	(a1,d0.w),d0
	lea	(a1,d0.w),a1

	move.w	(a1)+,d1			; Get number of entries

.Load:
	movea.l	(a1)+,a0			; Get art pointer

	moveq	#0,d0				; Get VRAM address
	move.w	(a1)+,d0
	lsl.l	#2,d0				; Convert VRAM address to VDP write command and set it
	lsr.w	#2,d0
	ori.w	#$4000,d0
	swap	d0
	move.l	d0,VDPCTRL

	bsr.w	NemDec				; Decompress the art

	dbf	d1,.Load
	rts

; -------------------------------------------------------------------------
; Decompress Enigma tilemap data into RAM
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Enigma data pointer
;	a1.l - Destination buffer pointer
;	d0.w - Base tile
; -------------------------------------------------------------------------

EniDec:
	movem.l	d0-d7/a1-a5,-(sp)
	movea.w	d0,a3				; Store base tile
	move.b	(a0)+,d0
	ext.w	d0
	movea.w	d0,a5				; Store number of bits in inline copy value
	move.b	(a0)+,d4
	lsl.b	#3,d4				; Store PCCVH flags bitfield
	movea.w	(a0)+,a2
	adda.w	a3,a2				; Store incremental copy word
	movea.w	(a0)+,a4
	adda.w	a3,a4				; Store literal copy word
	move.b	(a0)+,d5
	asl.w	#8,d5
	move.b	(a0)+,d5			; Get first word in format list
	moveq	#16,d6				; Initial shift value

EniDec_Loop:
	moveq	#7,d0				; Assume a format list entry is 7 bits
	move.w	d6,d7
	sub.w	d0,d7
	move.w	d5,d1
	lsr.w	d7,d1
	andi.w	#$7F,d1				; Get format list entry
	move.w	d1,d2				; and copy it
	cmpi.w	#$40,d1				; Is the high bit of the entry set?
	bcc.s	.SevenBitEntry
	moveq	#6,d0				; If it isn't, the entry is actually 6 bits
	lsr.w	#1,d2

.SevenBitEntry:
	bsr.w	EniDec_ChkGetNextByte
	andi.w	#$F,d2				; Get repeat count
	lsr.w	#4,d1
	add.w	d1,d1
	jmp	EniDec_JmpTable(pc,d1.w)

; -------------------------------------------------------------------------

EniDec_Sub0:
	move.w	a2,(a1)+			; Copy incremental copy word
	addq.w	#1,a2				; Increment it
	dbf	d2,EniDec_Sub0			; Repeat
	bra.s	EniDec_Loop

; -------------------------------------------------------------------------

EniDec_Sub4:
	move.w	a4,(a1)+			; Copy literal copy word
	dbf	d2,EniDec_Sub4			; Repeat
	bra.s	EniDec_Loop

; -------------------------------------------------------------------------

EniDec_Sub8:
	bsr.w	EniDec_GetInlineCopyVal

.Loop:
	move.w	d1,(a1)+			; Copy inline value
	dbf	d2,.Loop			; Repeat
	bra.s	EniDec_Loop

; -------------------------------------------------------------------------

EniDec_SubA:
	bsr.w	EniDec_GetInlineCopyVal

.Loop:
	move.w	d1,(a1)+			; Copy inline value
	addq.w	#1,d1				; Increment it
	dbf	d2,.Loop			; Repeat
	bra.s	EniDec_Loop

; -------------------------------------------------------------------------

EniDec_SubC:
	bsr.w	EniDec_GetInlineCopyVal

.Loop:
	move.w	d1,(a1)+			; Copy inline value
	subq.w	#1,d1				; Decrement it
	dbf	d2,.Loop			; Repeat
	bra.s	EniDec_Loop

; -------------------------------------------------------------------------

EniDec_SubE:
	cmpi.w	#$F,d2
	beq.s	EniDec_End

.Loop4:
	bsr.w	EniDec_GetInlineCopyVal		; Fetch new inline value
	move.w	d1,(a1)+			; Copy it
	dbf	d2,.Loop4			; Repeat
	bra.s	EniDec_Loop

; -------------------------------------------------------------------------

EniDec_JmpTable:
	bra.s	EniDec_Sub0
	bra.s	EniDec_Sub0
	bra.s	EniDec_Sub4
	bra.s	EniDec_Sub4
	bra.s	EniDec_Sub8
	bra.s	EniDec_SubA
	bra.s	EniDec_SubC
	bra.s	EniDec_SubE

; -------------------------------------------------------------------------

EniDec_End:
	subq.w	#1,a0				; Go back by one byte
	cmpi.w	#16,d6				; Were we going to start a completely new byte?
	bne.s	.NotNewByte			; If not, branch
	subq.w	#1,a0				; And another one if needed

.NotNewByte:
	move.w	a0,d0
	lsr.w	#1,d0				; Are we on an odd byte?
	bcc.s	.Even				; If not, branch
	addq.w	#1,a0				; Ensure we're on an even byte

.Even:
	movem.l	(sp)+,d0-d7/a1-a5
	rts

; -------------------------------------------------------------------------

EniDec_GetInlineCopyVal:
	move.w	a3,d3				; Copy base tile
	move.b	d4,d1				; Copy PCCVH bitfield
	add.b	d1,d1				; Is the priority bit set?
	bcc.s	.NoPriority			; If not, branch
	subq.w	#1,d6
	btst	d6,d5				; Is the priority bit set in the inline render flags?
	beq.s	.NoPriority			; If not, branch
	ori.w	#$8000,d3			; Set priority bit in the base tile

.NoPriority:
	add.b	d1,d1				; Is the high palette line bit set?
	bcc.s	.NoPal1				; If not, branch
	subq.w	#1,d6
	btst	d6,d5				; Is the high palette line bit set in the inline render flags?
	beq.s	.NoPal1				; If not, branch
	addi.w	#$4000,d3			; Set second palette line bit

.NoPal1:
	add.b	d1,d1				; Is the low palette line bit set?
	bcc.s	.NoPal0				; If not, branch
	subq.w	#1,d6
	btst	d6,d5				; Is the low palette line bit set in the inline render flags?
	beq.s	.NoPal0				; If not, branch
	addi.w	#$2000,d3			; Set first palette line bit

.NoPal0:
	add.b	d1,d1				; Is the Y flip bit set?
	bcc.s	.NoYFlip			; If not, branch
	subq.w	#1,d6
	btst	d6,d5				; Is the Y flip bit set in the inline render flags?
	beq.s	.NoYFlip			; If not, branch
	ori.w	#$1000,d3			; Set Y flip bit

.NoYFlip:
	add.b	d1,d1				; Is the X flip bit set?
	bcc.s	.NoXFlip			; If not, branch
	subq.w	#1,d6
	btst	d6,d5				; Is the X flip bit set in the inline render flags?
	beq.s	.NoXFlip			; If not, branch
	ori.w	#$800,d3			; Set X flip bit

.NoXFlip:
	move.w	d5,d1
	move.w	d6,d7
	sub.w	a5,d7				; Subtract length in bits of inline copy value
	bcc.s	.GotEnoughBits			; Branch if a new word doesn't need to be read
	move.w	d7,d6
	addi.w	#16,d6
	neg.w	d7				; Calculate bit deficit
	lsl.w	d7,d1				; and make space for that many bits
	move.b	(a0),d5				; Get next byte
	rol.b	d7,d5				; and rotate the required bits into the lowest positions
	add.w	d7,d7
	and.w	EniDec_Masks-2(pc,d7.w),d5
	add.w	d5,d1				; Combine upper bits with lower bits

.AddBits:
	move.w	a5,d0				; Get length in bits of inline copy value
	add.w	d0,d0
	and.w	EniDec_Masks-2(pc,d0.w),d1	; Mask value
	add.w	d3,d1				; Add base tile
	move.b	(a0)+,d5
	lsl.w	#8,d5
	move.b	(a0)+,d5
	rts

.GotEnoughBits:
	beq.s	.JustEnough			; If the word has been exactly exhausted, branch
	lsr.w	d7,d1				; Get inline copy value
	move.w	a5,d0
	add.w	d0,d0
	and.w	EniDec_Masks-2(pc,d0.w),d1	; Mask it
	add.w	d3,d1				; Add base tile
	move.w	a5,d0
	bra.s	EniDec_ChkGetNextByte

.JustEnough:
	moveq	#16,d6				; Reset shift value
	bra.s	.AddBits

; -------------------------------------------------------------------------

EniDec_Masks:
	dc.w	1,     3,     7,     $F
	dc.w	$1F,   $3F,   $7F,   $FF
	dc.w	$1FF,  $3FF,  $7FF,  $FFF
	dc.w	$1FFF, $3FFF, $7FFF, $FFFF

; -------------------------------------------------------------------------

EniDec_ChkGetNextByte:
	sub.w	d0,d6				; Subtract length of current entry from shift value so that next entry is read next time around
	cmpi.w	#9,d6				; Does a new byte need to be read?
	bcc.s	.End				; If not, branch
	addq.w	#8,d6
	asl.w	#8,d5
	move.b	(a0)+,d5

.End:
	rts

; -------------------------------------------------------------------------
; Decompress Kosinski data into RAM
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Kosinski data pointer
;	a1.l - Destination buffer pointer
; -------------------------------------------------------------------------

KosDec:
	subq.l	#2,sp				; Allocate 2 bytes on the stack
	move.b	(a0)+,1(sp)
	move.b	(a0)+,(sp)
	move.w	(sp),d5				; Get first description field
	moveq	#$F,d4				; Set to loop for 16 bits

KosDec_Loop:
	lsr.w	#1,d5				; Shift bit into the C flag
	move	sr,d6
	dbf	d4,.ChkBit
	move.b	(a0)+,1(sp)
	move.b	(a0)+,(sp)
	move.w	(sp),d5
	moveq	#$F,d4

.ChkBit:
	move	d6,ccr				; Was the bit set?
	bcc.s	KosDec_RLE			; If not, branch

	move.b	(a0)+,(a1)+			; Copy byte as is
	bra.s	KosDec_Loop

; -------------------------------------------------------------------------

KosDec_RLE:
	moveq	#0,d3
	lsr.w	#1,d5				; Get next bit
	move	sr,d6
	dbf	d4,.ChkBit
	move.b	(a0)+,1(sp)
	move.b	(a0)+,(sp)
	move.w	(sp),d5
	moveq	#$F,d4

.ChkBit:
	move	d6,ccr				; Was the bit set?
	bcs.s	KosDec_SeparateRLE		; If yes, branch

	lsr.w	#1,d5				; Shift bit into the X flag
	dbf	d4,.Loop
	move.b	(a0)+,1(sp)
	move.b	(a0)+,(sp)
	move.w	(sp),d5
	moveq	#$F,d4

.Loop:
	roxl.w	#1,d3				; Get high repeat count bit
	lsr.w	#1,d5
	dbf	d4,.Loop2
	move.b	(a0)+,1(sp)
	move.b	(a0)+,(sp)
	move.w	(sp),d5
	moveq	#$F,d4

.Loop2:
	roxl.w	#1,d3				; Get low repeat count bit
	addq.w	#1,d3				; Increment repeat count
	moveq	#$FFFFFFFF,d2
	move.b	(a0)+,d2			; Calculate offset
	bra.s	KosDec_RLELoop

; -------------------------------------------------------------------------

KosDec_SeparateRLE:
	move.b	(a0)+,d0			; Get first byte
	move.b	(a0)+,d1			; Get second byte
	moveq	#$FFFFFFFF,d2
	move.b	d1,d2
	lsl.w	#5,d2
	move.b	d0,d2				; Calculate offset
	andi.w	#7,d1				; Does a third byte need to be read?
	beq.s	KosDec_SeparateRLE2		; If yes, branch
	move.b	d1,d3				; Copy repeat count
	addq.w	#1,d3				; Increment

KosDec_RLELoop:
	move.b	(a1,d2.w),d0			; Copy appropriate byte
	move.b	d0,(a1)+			; Repeat
	dbf	d3,KosDec_RLELoop
	bra.s	KosDec_Loop

; -------------------------------------------------------------------------

KosDec_SeparateRLE2:
	move.b	(a0)+,d1
	beq.s	KosDec_Done			; 0 indicates end of compressed data
	cmpi.b	#1,d1
	beq.w	KosDec_Loop			; 1 indicates new description to be read
	move.b	d1,d3				; Otherwise, copy repeat count
	bra.s	KosDec_RLELoop

; -------------------------------------------------------------------------

KosDec_Done:
	addq.l	#2,sp				; Deallocate the 2 bytes
	rts

; -------------------------------------------------------------------------
; Get player object
; -------------------------------------------------------------------------
; RETURNS:
;	a6.l - Player object RAM
; -------------------------------------------------------------------------

GetPlayerObject:
	lea	objPlayerSlot.w,a6		; Player 1
	tst.b	usePlayer2			; Are we using player 2?
	beq.s	.Done				; If not, branch
	lea	objPlayerSlot2.w,a6		; Player 2

.Done:
	rts

; -------------------------------------------------------------------------
; Get level size and start position
; -------------------------------------------------------------------------

LevelSizeLoad:
	moveq	#0,d0				; Clear unused variables
	move.b	d0,unusedF740.w
	move.b	d0,unusedF741.w
	move.b	d0,unusedF746.w
	move.b	d0,unusedF748.w
	move.b	d0,eventRoutine.w		; Clear level event routine

	lea	LevelSize,a0			; Prepare level size information
	move.w	(a0)+,d0			; Get unused word
	move.w	d0,unusedF730.w
	move.l	(a0)+,d0			; Get left and right boundaries
	move.l	d0,leftBound.w
	move.l	d0,destLeftBound.w
	move.l	(a0)+,d0			; Get top and bottom boundaries
	move.l	d0,topBound.w
	move.l	d0,destTopBound.w
	move.w	leftBound.w,d0			; Get left boundary + $240
	addi.w	#$240,d0
	move.w	d0,leftBound3.w
	move.w	#$1010,horizBlkCrossed.w	; Initialize horizontal block crossed flags
	move.w	(a0)+,d0			; Get camera Y center
	move.w	d0,camYCenter.w
	move.w	#320/2,camXCenter.w		; Get camera X center

	bra.w	LevelSizeLoad_StartPos

; -------------------------------------------------------------------------

LevelSize:
	dc.w	4, 0, $2897, 0, $710, $60

; -------------------------------------------------------------------------

; Leftover ending demo start positions from Sonic 1
EndingStLocsS1:
	dc.w	$50, $3B0
	dc.w	$EA0, $46C
	dc.w	$1750, $BD
	dc.w	$A00, $62C
	dc.w	$BB0, $4C
	dc.w	$1570, $16C
	dc.w	$1B0, $72C
	dc.w	$1400, $2AC

; -------------------------------------------------------------------------

LevelSizeLoad_StartPos:
	tst.b	resetLevelFlags			; Was the level reset midway?
	beq.s	.DefaultStart			; If not, branch

	jsr	ObjCheckpoint_LoadData		; Load checkpoint data
	moveq	#0,d0				; Get player position
	moveq	#0,d1
	move.w	objPlayerSlot+oX.w,d1
	move.w	objPlayerSlot+oY.w,d0
	bpl.s	.SkipCap			; If the Y position is positive, branch
	moveq	#0,d0				; Cap the Y position at 0 if negative

.SkipCap:
	bra.s	.SetupCamera

.DefaultStart:
	lea	LevelStartLoc,a1		; Prepare level start position
	moveq	#0,d1				; Get starting X position
	move.w	(a1)+,d1
	move.w	d1,objPlayerSlot+oX.w
	moveq	#0,d0				; Get starting Y position
	move.w	(a1),d0
	move.w	d0,objPlayerSlot+oY.w

.SetupCamera:
	subi.w	#320/2,d1			; Get camera X position
	bcc.s	.SkipXLeftBnd			; If it doesn't need to be capped, branch
	moveq	#0,d1				; If it does, cap at 0

.SkipXLeftBnd:
	move.w	rightBound.w,d2			; Is the camera past the right boundary?
	cmp.w	d2,d1
	bcs.s	.SkipXRightBnd			; If not, branch
	move.w	d2,d1				; If so, cap it

.SkipXRightBnd:
	move.w	d1,cameraX.w			; Set camera X position

	subi.w	#$60,d0				; Get camera Y position
	bcc.s	.SkipYTopBnd			; If it doesn't need to be capped, branch
	moveq	#0,d0				; If it does, cap at 0

.SkipYTopBnd:
	cmp.w	bottomBound.w,d0		; Is the camera past the bottom boundary?
	blt.s	.SkipYBtmBnd			; If not, branch
	move.w	bottomBound.w,d0		; If so, cap it

.SkipYBtmBnd:
	move.w	d0,cameraY.w			; Set camera Y position

	bsr.w	InitLevelScroll			; Initialize level scrolling

	lea	LoopChunks,a1			; Get loop chunks
	move.l	(a1),specialChunks.w
	rts

; -------------------------------------------------------------------------

LevelStartLoc:
	incbin	"level/r1/data/startpos.bin"
	even

LoopChunks:
	dc.b	$7F, $7F, $7F, $7F

; -------------------------------------------------------------------------
; Initialize level scrollings
; -------------------------------------------------------------------------

InitLevelScroll:
	cmpi.w	#$800,objPlayerSlot+oX.w	; Has the player gone past the first 3D ramp?
	bcs.s	.No3DRamp			; If not, branch
	subi.w	#$1E0,d0			; Get background Y position after first 3D ramp
	bcs.s	.ChgDir
	lsr.w	#1,d0

.ChgDir:
	addi.w	#$1E0,d0			; Get background Y position

.No3DRamp:
	swap	d0				; Set background Y positions
	move.l	d0,cameraBgY.w
	swap	d0
	move.w	d0,cameraBg2Y.w
	move.w	d0,cameraBg3Y.w

	lsr.w	#1,d1				; Get background X positions
	move.w	d1,cameraBgX.w
	lsr.w	#2,d1
	move.w	d1,d2
	add.w	d2,d2
	add.w	d1,d2
	move.w	d2,cameraBg3X.w
	lsr.w	#1,d1
	move.w	d1,d2
	add.w	d2,d2
	add.w	d1,d2
	move.w	d2,cameraBg2X.w

	lea	lvlLayerSpeeds,a2		; Clear cloud speeds
	moveq	#$12,d6

.ClearSpeeds:
	clr.l	(a2)+
	dbf	d6,.ClearSpeeds
	rts

; -------------------------------------------------------------------------
; Handle level scrolling
; -------------------------------------------------------------------------

LevelScroll:
	tst.b	scrollLock.w			; Is scrolling locked?
	beq.s	.DoScroll			; If not, branch
	rts

.DoScroll:
	clr.w	scrollFlags.w			; Clear scroll flags
	clr.w	scrollFlagsBg.w
	clr.w	scrollFlagsBg2.w
	clr.w	scrollFlagsBg3.w

	if REGION=USA
		bsr.w	RunLevelEvents		; Run level events
		bsr.w	ScrollCamX		; Scroll camera horizontally
		bsr.w	ScrollCamY		; Scroll camera vertically
	else
		bsr.w	ScrollCamX		; Scroll camera horizontally
		bsr.w	ScrollCamY		; Scroll camera vertically
		bsr.w	RunLevelEvents		; Run level events
	endif

	move.w	cameraY.w,vscrollScreen.w	; Update VScroll values
	move.w	cameraBgY.w,vscrollScreen+2.w

	moveq	#0,d5				; Reset scroll speed offset
	btst	#1,objPlayerSlot+oPlayerCtrl.w	; Is the player on a 3D ramp?
	beq.s	.GotSpeed			; If not, branch
	tst.w	scrollXDiff.w			; Is the camera scrolling horizontally?
	beq.s	.GotSpeed			; If not, branch
	move.w	objPlayerSlot+oXVel.w,d5	; Set scroll speed offset to the player's X velocity
	ext.l	d5
	asl.l	#8,d5

.GotSpeed:
	move.w	scrollXDiff.w,d4		; Set scroll offset and flags for the clouds
	ext.l	d4
	asl.l	#5,d4
	add.l	d5,d4
	moveq	#6,d6
	bsr.w	SetHorizScrollFlagsBG3

	move.w	scrollXDiff.w,d4		; Set scroll offset and flags for the mountains
	ext.l	d4
	asl.l	#4,d4
	move.l	d4,d3
	add.l	d3,d3
	add.l	d3,d4
	add.l	d5,d4
	add.l	d5,d4
	moveq	#4,d6
	bsr.w	SetHorizScrollFlagsBG2

	lea	deformBuffer.w,a1		; Prepare deformation buffer

	move.w	scrollXDiff.w,d4		; Set scroll offset and flags for the bushes and water
	ext.l	d4
	asl.l	#7,d4
	add.l	d5,d4
	moveq	#2,d6
	bsr.w	SetHorizScrollFlagsBG

	move.w	cameraY.w,d0			; Get background Y position
	cmpi.w	#$800,objPlayerSlot+oX.w	; Has the player gone past the first 3D ramp?
	bcs.s	.No3DRamp			; If not, branch
	subi.w	#$1E0,d0			; Get background Y position past the first 3D ramp
	bcs.s	.ChgDir
	lsr.w	#1,d0

.ChgDir:
	addi.w	#$1E0,d0			; Get background Y position before the first 3D ramp

.No3DRamp:
	bsr.w	SetVertiScrollFlagsBG2		; Set BG2 vertical scroll flags

	move.w	cameraBgY.w,vscrollScreen+2.w	; Update background Y positions
	move.w	cameraBgY.w,cameraBg2Y.w
	move.w	cameraBgY.w,cameraBg3Y.w

	move.b	scrollFlagsBg3.w,d0		; Combine background scroll flags for the level drawing routine
	or.b	scrollFlagsBg2.w,d0
	or.b	d0,scrollFlagsBg.w
	clr.b	scrollFlagsBg3.w
	clr.b	scrollFlagsBg2.w

	lea	lvlLayerSpeeds,a2		; Set speeds for the clouds
	addi.l	#$10000,(a2)+
	addi.l	#$E000,(a2)+
	addi.l	#$C000,(a2)+
	addi.l	#$A000,(a2)+
	addi.l	#$8000,(a2)+
	addi.l	#$6000,(a2)+
	addi.l	#$4800,(a2)+
	addi.l	#$4000,(a2)+
	addi.l	#$2800,(a2)+
	addi.l	#$2000,(a2)+
	addi.l	#$2000,(a2)+
	addi.l	#$4000,(a2)+
	addi.l	#$8000,(a2)+
	addi.l	#$C000,(a2)+
	addi.l	#$10000,(a2)+
	addi.l	#$C000,(a2)+
	addi.l	#$8000,(a2)+
	addi.l	#$4000,(a2)+
	addi.l	#$2000,(a2)+

	move.w	cameraX.w,d0			; Prepare scroll buffer entry
	neg.w	d0
	swap	d0

	lea	lvlLayerSpeeds,a2		; Prepare cloud speeds
	moveq	#10-1,d6			; Number of cloud sections

.CloudsScroll:
	move.l	(a2)+,d1			; Get cloud section scroll offset
	swap	d1
	add.w	cameraBg3X.w,d1
	neg.w	d1

	moveq	#0,d5				; Get number of lines in this section
	lea	CloudSectSizes,a3
	move.b	(a3,d6.w),d5

.CloudsScrollSect:
	move.w	d1,(a1)+			; Store scroll offset
	dbf	d5,.CloudsScrollSect		; Loop until this section is stored
	dbf	d6,.CloudsScroll		; Loop until the clouds are finished being processed

	move.w	cameraBg2X.w,d0			; Scroll top mountains
	neg.w	d0
	moveq	#20-1,d6

.ScrollMountains:
	move.w	d0,(a1)+
	dbf	d6,.ScrollMountains

	move.w	cameraBgX.w,d0			; Scroll top bushes
	neg.w	d0
	moveq	#4-1,d6

.ScrollBushes:
	move.w	d0,(a1)+
	dbf	d6,.ScrollBushes

	move.w	cameraBgX.w,d0			; Scroll water (top and upside down)
	neg.w	d0
	move.w	#(28*2)-1,d6

.ScrollWater:
	move.w	d0,(a1)+
	dbf	d6,.ScrollWater

	move.w	cameraBgX.w,d0			; Scroll upside down bushes
	neg.w	d0
	moveq	#4-1,d6

.ScrollUpsideDownBushes:
	move.w	d0,(a1)+
	dbf	d6,.ScrollUpsideDownBushes

	move.w	cameraBg2X.w,d0			; Scroll upside down mountains
	neg.w	d0
	moveq	#20-1,d6

.ScrollUpsideDownMountains:
	move.w	d0,(a1)+
	dbf	d6,.ScrollUpsideDownMountains

	moveq	#9-1,d6				; Number of cloud sections

.UpsideDownCloudsScroll:
	move.l	(a2)+,d1			; Get cloud section scroll offset
	swap	d1
	add.w	cameraBg3X.w,d1
	neg.w	d1

	moveq	#0,d5				; Get number of lines in this section
	lea	CloudUpsideDownSectSizes,a3
	move.b	(a3,d6.w),d5

.UpsideDownCloudsScrollSect:
	move.w	d1,(a1)+			; Store scroll offset
	dbf	d5,.UpsideDownCloudsScrollSect	; Loop until this section is stored
	dbf	d6,.UpsideDownCloudsScroll	; Loop until the clouds are finished being processed

	move.w	cameraBg2X.w,d0			; Scroll bottom mountains
	neg.w	d0
	moveq	#20-1,d6

.ScrollBtmMountains:
	move.w	d0,(a1)+
	dbf	d6,.ScrollBtmMountains

	move.w	cameraBgX.w,d0			; Scroll bottom bushes
	neg.w	d0
	moveq	#4-1,d6

.ScrollBtmBushes:
	move.w	d0,(a1)+
	dbf	d6,.ScrollBtmBushes

	move.w	cameraBgX.w,d0			; Scroll bottom water
	neg.w	d0
	move.w	#16-1,d6

.ScrollBtmWater:
	move.w	d0,(a1)+
	dbf	d6,.ScrollBtmWater

	lea	hscroll.w,a1			; Prepare horizontal scroll buffer
	lea	deformBuffer.w,a2		; Prepare deformation buffer

	move.w	cameraBgY.w,d0			; Get background Y position
	move.w	d0,d2
	move.w	d0,d4
	andi.w	#$7F8,d0
	lsr.w	#2,d0
	moveq	#(240/8)-1,d1			; Max number of blocks to scroll
	lea	(a2,d0.w),a2			; Get starting scroll block
	lea	WaterDeformSects,a3		; Prepare water deformation section information
	bra.w	ApplyBGHScroll			; Apply HScroll

; -------------------------------------------------------------------------

CloudSectSizes:					; Top cloud section sizes
	dc.b	2-1
	dc.b	4-1
	dc.b	6-1
	dc.b	8-1
	dc.b	8-1
	dc.b	8-1
	dc.b	4-1
	dc.b	6-1
	dc.b	6-1
	dc.b	4-1

CloudUpsideDownSectSizes:			; Upside down and bottom cloud section sizes
	dc.b	2-1
	dc.b	4-1
	dc.b	6-1
	dc.b	8-1
	dc.b	16-1
	dc.b	4-1
	dc.b	10-1
	dc.b	4-1
	dc.b	2-1
	even

WaterDeformSects:				; Water deform section positions and sizes
	dc.w	$280, $E0
	dc.w	$780, $80
	dc.w	$7FFF, $360

; -------------------------------------------------------------------------

ApplyBGHScroll:
	cmp.w	(a3),d4				; Is the background scrolled past the current water section?
	bcc.s	.FoundWaterSection		; If so, branch

.ScrollUnmodified:
	andi.w	#7,d2				; Get the number of lines to scroll for the first block of lines
	sub.w	d2,d4
	addq.w	#8,d4
	add.w	d2,d2

	move.w	(a2)+,d0			; Start scrolling
	jmp	.ScrollBlock(pc,d2.w)

.ScrollLoop:
	tst.w	d1				; Are we done scrolling?
	bmi.s	.End				; If so, branch
	cmp.w	(a3),d4				; Is the background scrolled past the current water section?
	bcc.s	.FoundWaterSection		; If so, branch

	addq.w	#8,d4				; Scroll another block of lines
	move.w	(a2)+,d0

.ScrollBlock:
	rept	8				; Scroll a block of 8 lines
		move.l	d0,(a1)+
	endr
	dbf	d1,.ScrollLoop			; Loop until finished

.End:
	rts

.FoundWaterSection:
	move.w	d4,d5				; Determine how deep we are into the section
	sub.w	(a3),d5
	move.w	2(a3),d6			; Get number of scanlines to scroll
	sub.w	d5,d6
	bcs.s	.SectOffscreen			; If the section is offscreen now, branch
	beq.s	.NextSection

	move.w	#224,d3				; Get base water deformation speed
	move.w	cameraBgX.w,d0
	move.w	cameraX.w,d2
	sub.w	d0,d2
	ext.l	d2
	asl.l	#8,d2
	divs.w	d3,d2
	ext.l	d2
	asl.l	#8,d2
	moveq	#0,d3
	move.w	d0,d3

	subq.w	#1,d5				; Get number of scanlines in which the section is offscreen
	bmi.s	.GotStartWaterSpeed		; to help get the starting water deformation speed

.GetStartWaterSpeed:
	move.w	d3,d0				; Increment starting water deformation speed
	swap	d3
	add.l	d2,d3
	swap	d3
	dbf	d5,.GetStartWaterSpeed		; Loop until we got it

.GotStartWaterSpeed:
	move.w	d6,d5				; Decrement section size from scroll block count
	lsr.w	#3,d5
	sub.w	d5,d1
	bcc.s	.StartWaterDeform		; If we still have some scroll blocks left over, branch

	move.w	d1,d5				; Shrink the size of the section down to fit only up to the bottom of the screen
	neg.w	d5
	lsl.w	#3,d5
	sub.w	d5,d6
	beq.s	.NextSection			; If the size of the section shrinks down to 0 pixels, branch

.StartWaterDeform:
	subq.w	#1,d6				; Prepare section size

.DoWaterDeform:
	move.w	d3,d0				; Scroll line
	neg.w	d0
	move.l	d0,(a1)+

	swap	d3				; Increment water deformation speed
	add.l	d2,d3
	swap	d3

	addq.w	#1,d4				; Next line
	move.w	d4,d0
	andi.w	#7,d0				; Have we crossed a block?
	bne.s	.NextLine			; If not, branch
	addq.w	#2,a2				; Skip block in the deformation buffer

.NextLine:
	dbf	d6,.DoWaterDeform		; Loop until section is scrolled

.NextSection:
	addq.w	#4,a3				; Next section
	bra.w	.ScrollLoop			; Start scrolling regular blocks of lines again

.SectOffscreen:
	addq.w	#4,a3				; Next section
	move.w	d4,d2				; Start scrolling regular blocks of lines again
	bra.w	.ScrollUnmodified

; -------------------------------------------------------------------------
; Scroll the camera horizontally
; -------------------------------------------------------------------------

ScrollCamX:
	move.w	cameraX.w,d4			; Handle camera movement
	bsr.s	MoveScreenHoriz

	move.w	cameraX.w,d0			; Check if a block has been crossed and set flags accordingly
	andi.w	#$10,d0
	move.b	horizBlkCrossed.w,d1
	eor.b	d1,d0
	bne.s	.End
	eori.b	#$10,horizBlkCrossed.w
	move.w	cameraX.w,d0
	sub.w	d4,d0
	bpl.s	.Forward
	bset	#2,scrollFlags.w
	rts

.Forward:
	bset	#3,scrollFlags.w

.End:
	rts

; -------------------------------------------------------------------------

MoveScreenHoriz:
	move.w	objPlayerSlot+oX.w,d0		; Get the distance scrolled
	sub.w	cameraX.w,d0
	sub.w	camXCenter.w,d0
	beq.s	.AtDest				; If not scrolled at all, branch
	bcs.s	MoveScreenHoriz_CamBehind	; If scrolled to the left, branch
	bra.s	MoveScreenHoriz_CamAhead	; If scrolled to the right, branch

.AtDest:
	clr.w	scrollXDiff.w			; Didn't scroll at all
	rts

MoveScreenHoriz_CamAhead:
	cmpi.w	#16,d0				; Have we scrolled past 16 pixels?
	blt.s	.CapSpeed			; If not, branch
	move.w	#16,d0				; Cap at 16 pixels

.CapSpeed:
	add.w	cameraX.w,d0			; Have we gone past the right boundary?
	cmp.w	rightBound.w,d0
	blt.s	MoveScreenHoriz_MoveCam		; If not, branch
	move.w	rightBound.w,d0			; Cap at the right boundary

MoveScreenHoriz_MoveCam:
	move.w	d0,d1				; Update camera position
	sub.w	cameraX.w,d1
	asl.w	#8,d1
	move.w	d0,cameraX.w
	move.w	d1,scrollXDiff.w		; Get scroll delta
	rts

MoveScreenHoriz_CamBehind:
	cmpi.w	#-16,d0				; Have we scrolled past 16 pixels?
	bge.s	.CapSpeed			; If not, branch
	move.w	#-16,d0				; Cap at 16 pixels

.CapSpeed:
	add.w	cameraX.w,d0			; Have we gone past the left boundary?
	cmp.w	leftBound.w,d0
	bgt.s	MoveScreenHoriz_MoveCam		; If not, branch
	move.w	leftBound.w,d0			; Cap at the left boundary
	bra.s	MoveScreenHoriz_MoveCam

; -------------------------------------------------------------------------
; Shift the camera horizontally
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Scroll direction
; -------------------------------------------------------------------------

ShiftCameraHoriz:
	tst.w	d0				; Are we shifting to the right?
	bpl.s	.MoveRight			; If so, branch
	move.w	#-2,d0				; Shift to the left
	bra.s	MoveScreenHoriz_CamBehind

.MoveRight:
	move.w	#2,d0				; Shift to the right
	bra.s	MoveScreenHoriz_CamAhead

; -------------------------------------------------------------------------
; Scroll the camera vertically
; -------------------------------------------------------------------------

ScrollCamY:
	moveq	#0,d1				; Get how far we have scrolled vertically
	move.w	objPlayerSlot+oY.w,d0
	sub.w	cameraY.w,d0
	btst	#2,objPlayerSlot+oStatus.w	; Is the player rolling?
	beq.s	.NoRoll				; If not, branch
	subq.w	#5,d0				; Account for the different height

.NoRoll:
	btst	#1,objPlayerSlot+oStatus.w	; Is the player in the air?
	beq.s	.OnGround			; If not, branch

	addi.w	#$20,d0
	sub.w	camYCenter.w,d0
	bcs.s	.DoScrollFast			; If the player is above the boundary, scroll to catch up
	subi.w	#$20*2,d0
	bcc.s	.DoScrollFast			; If the player is below the boundary, scroll to catch up

	tst.b	btmBoundShift.w			; Is the bottom boundary shifting?
	bne.s	.StopCam			; If it is, branch
	bra.s	.DoNotScroll

.OnGround:
	sub.w	camYCenter.w,d0			; Subtract center position
	bne.s	.CamMoving			; If the player has moved, scroll to catch up
	tst.b	btmBoundShift.w			; Is the bottom boundary shifting?
	bne.s	.StopCam			; If it is, branch

.DoNotScroll:
	clr.w	scrollYDiff.w			; Didn't scroll at all
	rts

; -------------------------------------------------------------------------

.CamMoving:
	cmpi.w	#$60,camYCenter.w		; Is the camera center normal?
	bne.s	.DoScrollSlow			; If not, branch
	move.w	objPlayerSlot+oPlayerGVel.w,d1	; Get the player's ground velocity
	bpl.s	.DoScrollMedium
	neg.w	d1

.DoScrollMedium:
	cmpi.w	#8<<8,d1			; Is the player moving very fast?
	bcc.s	.DoScrollFast			; If they are, branch
	move.w	#6<<8,d1			; If the player is going too fast, cap the movement to 6 pixels/frame
	cmpi.w	#6,d0				; Is the player going down too fast?
	bgt.s	.MovingDown			; If so, move the camera at the capped speed
	cmpi.w	#-6,d0				; Is the player going up too fast?
	blt.s	.MovingUp			; If so, move the camera at the capped speed
	bra.s	.GotCamSpeed			; Otherwise, move the camera at the player's speed

.DoScrollSlow:
	move.w	#2<<8,d1			; If the player is going too fast, cap the movement to 2 pixels/frame
	cmpi.w	#2,d0				; Is the player going down too fast?
	bgt.s	.MovingDown			; If so, move the camera at the capped speed
	cmpi.w	#-2,d0				; Is the player going up too fast?
	blt.s	.MovingUp			; If so, move the camera at the capped speed
	bra.s	.GotCamSpeed			; Otherwise, move the camera at the player's speed

.DoScrollFast:
	move.w	#16<<8,d1			; If the player is going too fast, cap the movement to 16 pixels/frame
	cmpi.w	#16,d0				; Is the player going down too fast?
	bgt.s	.MovingDown			; If so, move the camera at the capped speed
	cmpi.w	#-16,d0				; Is the player going up too fast?
	blt.s	.MovingUp			; If so, move the camera at the capped speed
	bra.s	.GotCamSpeed			; Otherwise, move the camera at the player's speed

; -------------------------------------------------------------------------

.StopCam:
	moveq	#0,d0				; Stop the camera
	move.b	d0,btmBoundShift.w		; Clear bottom boundary shifting flag

.GotCamSpeed:
	moveq	#0,d1
	move.w	d0,d1				; Get position difference
	add.w	cameraY.w,d1			; Add old camera Y position
	tst.w	d0				; Is the camera scrolling down?
	bpl.w	.ChkBottom			; If so, branch
	bra.w	.ChkTop

.MovingUp:
	neg.w	d1				; Make the value negative
	ext.l	d1
	asl.l	#8,d1				; Move this into the upper word to align with the camera's Y position variable
	add.l	cameraY.w,d1			; Shift the camera over
	swap	d1				; Get the proper Y position

.ChkTop:
	cmp.w	topBound.w,d1			; Is the new position past the top boundary?
	bgt.s	.MoveCam			; If not, branch
	cmpi.w	#-$100,d1			; Is Y wrapping enabled?
	bgt.s	.CapTop				; If not, branch
	andi.w	#$7FF,d1			; Apply wrapping
	andi.w	#$7FF,objPlayerSlot+oY.w
	andi.w	#$7FF,cameraY.w
	andi.w	#$3FF,cameraBgY.w
	bra.s	.MoveCam

; -------------------------------------------------------------------------

.CapTop:
	move.w	topBound.w,d1			; Cap at the top boundary
	bra.s	.MoveCam

.MovingDown:
	ext.l	d1
	asl.l	#8,d1				; Move this into the upper word to align with the camera's Y position variable
	add.l	cameraY.w,d1			; Shift the camera over
	swap	d1				; Get the proper Y position

.ChkBottom:
	cmp.w	bottomBound.w,d1		; Is the new position past the bottom boundary?
	blt.s	.MoveCam			; If not, branch
	subi.w	#$800,d1			; Should we wrap?
	bcs.s	.CapBottom			; If not, branch
	andi.w	#$7FF,objPlayerSlot+oY.w	; Apply wrapping
	subi.w	#$800,cameraY.w
	andi.w	#$3FF,cameraBgY.w
	bra.s	.MoveCam

; -------------------------------------------------------------------------

.CapBottom:
	move.w	bottomBound.w,d1		; Cap at the bottom boundary

.MoveCam:
	move.w	cameraY.w,d4			; Update the camera position and get the scroll delta
	swap	d1
	move.l	d1,d3
	sub.l	cameraY.w,d3
	ror.l	#8,d3
	move.w	d3,scrollYDiff.w
	move.l	d1,cameraY.w

	move.w	cameraY.w,d0			; Check if a block has been crossed and set flags accordingly
	andi.w	#$10,d0
	move.b	vertiBlkCrossed.w,d1
	eor.b	d1,d0
	bne.s	.End
	eori.b	#$10,vertiBlkCrossed.w
	move.w	cameraY.w,d0
	sub.w	d4,d0
	bpl.s	.Downward
	bset	#0,scrollFlags.w
	rts

.Downward:
	bset	#1,scrollFlags.w

.End:
	rts

; -------------------------------------------------------------------------
; Set scroll flags for the background while scrolling the position
; -------------------------------------------------------------------------
; PARAMETERS:
;	d4.w - X scroll offset
;	d5.w - Y scroll offset
; -------------------------------------------------------------------------

SetScrollFlagsBG:
	move.l	cameraBgX.w,d2			; Scroll horizontally
	move.l	d2,d0
	add.l	d4,d0
	move.l	d0,cameraBgX.w

	move.l	d0,d1				; Check if a block has been crossed and set flags accordingly
	swap	d1
	andi.w	#$10,d1
	move.b	horizBlkCrossedBg.w,d3
	eor.b	d3,d1
	bne.s	.ChkY
	eori.b	#$10,horizBlkCrossedBg.w
	sub.l	d2,d0
	bpl.s	.MoveRight
	bset	#2,scrollFlagsBg.w
	bra.s	.ChkY

.MoveRight:
	bset	#3,scrollFlagsBg.w

; -------------------------------------------------------------------------

.ChkY:
	move.l	cameraBgY.w,d3			; Scroll vertically
	move.l	d3,d0
	add.l	d5,d0
	move.l	d0,cameraBgY.w

	move.l	d0,d1				; Check if a block has been crossed and set flags accordingly
	swap	d1
	andi.w	#$10,d1
	move.b	vertiBlkCrossedBg.w,d2
	eor.b	d2,d1
	bne.s	.End
	eori.b	#$10,vertiBlkCrossedBg.w
	sub.l	d3,d0
	bpl.s	.MoveDown
	bset	#0,scrollFlagsBg.w
	rts

.MoveDown:
	bset	#1,scrollFlagsBg.w

.End:
	rts

; -------------------------------------------------------------------------
; Set vertical scroll flags for the background camera while scrolling the
; position
; -------------------------------------------------------------------------
; PARAMETERS:
;	d5.w - Y scroll offset
; -------------------------------------------------------------------------

SetVertiScrollFlagsBG:
	move.l	cameraBgY.w,d3			; Scroll vertically
	move.l	d3,d0
	add.l	d5,d0
	move.l	d0,cameraBgY.w

	move.l	d0,d1				; Check if a block has been crossed and set flags accordingly
	swap	d1
	andi.w	#$10,d1
	move.b	vertiBlkCrossedBg.w,d2
	eor.b	d2,d1
	bne.s	.End
	eori.b	#$10,vertiBlkCrossedBg.w
	sub.l	d3,d0
	bpl.s	.MoveDown
	bset	#4,scrollFlagsBg.w
	rts

.MoveDown:
	bset	#5,scrollFlagsBg.w

.End:
	rts

; -------------------------------------------------------------------------
; Set vertical scroll flags for the background camera while setting the
; position directly
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - New Y position
; -------------------------------------------------------------------------

SetVertiScrollFlagsBG2:
	move.w	cameraBgY.w,d3			; Set new position
	move.w	d0,cameraBgY.w

	move.w	d0,d1				; Check if a block has been crossed and set flags accordingly
	andi.w	#$10,d1
	move.b	vertiBlkCrossedBg.w,d2
	eor.b	d2,d1
	bne.s	.End
	eori.b	#$10,vertiBlkCrossedBg.w
	sub.w	d3,d0
	bpl.s	.MoveDown
	bset	#0,scrollFlagsBg.w
	rts

.MoveDown:
	bset	#1,scrollFlagsBg.w

.End:
	rts

; -------------------------------------------------------------------------
; Set horizontal scroll flags for the background camera while scrolling the
; position
; -------------------------------------------------------------------------
; PARAMETERS:
;	d4.w - X scroll offset
;	d6.b - Base scroll flag bit
; -------------------------------------------------------------------------

SetHorizScrollFlagsBG:
	move.l	cameraBgX.w,d2			; Scroll horizontally
	move.l	d2,d0
	add.l	d4,d0
	move.l	d0,cameraBgX.w

	move.l	d0,d1				; Check if a block has been crossed and set flags accordingly
	swap	d1
	andi.w	#$10,d1
	move.b	horizBlkCrossedBg.w,d3
	eor.b	d3,d1
	bne.s	.End
	eori.b	#$10,horizBlkCrossedBg.w
	sub.l	d2,d0
	bpl.s	.MoveRight
	bset	d6,scrollFlagsBg.w
	bra.s	.End

.MoveRight:
	addq.b	#1,d6
	bset	d6,scrollFlagsBg.w

.End:
	rts

; -------------------------------------------------------------------------
; Set horizontal scroll flags for the background camera #2 while scrolling the
; position
; -------------------------------------------------------------------------
; PARAMETERS:
;	d4.w - X scroll offset
;	d6.b - Base scroll flag bit
; -------------------------------------------------------------------------

SetHorizScrollFlagsBG2:
	move.l	cameraBg2X.w,d2			; Scroll horizontally
	move.l	d2,d0
	add.l	d4,d0
	move.l	d0,cameraBg2X.w

	move.l	d0,d1				; Check if a block has been crossed and set flags accordingly
	swap	d1
	andi.w	#$10,d1
	move.b	horizBlkCrossedBg2.w,d3
	eor.b	d3,d1
	bne.s	.End
	eori.b	#$10,horizBlkCrossedBg2.w
	sub.l	d2,d0
	bpl.s	.MoveRight
	bset	d6,scrollFlagsBg2.w
	bra.s	.End


.MoveRight:
	addq.b	#1,d6
	bset	d6,scrollFlagsBg2.w

.End:
	rts

; -------------------------------------------------------------------------
; Set horizontal scroll flags for the background camera #3 while scrolling the
; position
; -------------------------------------------------------------------------
; PARAMETERS:
;	d4.w - X scroll offset
;	d6.b - Base scroll flag bit
; -------------------------------------------------------------------------

SetHorizScrollFlagsBG3:
	move.l	cameraBg3X.w,d2			; Scroll horizontally
	move.l	d2,d0
	add.l	d4,d0
	move.l	d0,cameraBg3X.w

	move.l	d0,d1				; Check if a block has been crossed and set flags accordingly
	swap	d1
	andi.w	#$10,d1
	move.b	horizBlkCrossedBg3.w,d3
	eor.b	d3,d1
	bne.s	.End
	eori.b	#$10,horizBlkCrossedBg3.w
	sub.l	d2,d0
	bpl.s	.MoveRight
	bset	d6,scrollFlagsBg3.w
	bra.s	.End

.MoveRight:
	addq.b	#1,d6
	bset	d6,scrollFlagsBg3.w

.End:
	rts

; -------------------------------------------------------------------------
; Update level background drawing
; -------------------------------------------------------------------------

LevelDraw_UpdateBG:
	lea	VDPCTRL,a5			; Prepare VDP ports
	lea	VDPDATA,a6

	lea	scrollFlagsBg.w,a2		; Update background section 1
	lea	cameraBgX.w,a3
	lea	levelLayout+$40.w,a4
	move.w	#$6000,d2
	bsr.w	DrawLevelBG1

	lea	scrollFlagsBg2.w,a2		; Update background section 2
	lea	cameraBg2X.w,a3
	bra.w	DrawLevelBG2

; -------------------------------------------------------------------------
; Update level drawing
; -------------------------------------------------------------------------

LevelDraw_Update:
	lea	VDPCTRL,a5			; Prepare VDP ports
	lea	VDPDATA,a6

	lea	lvlScrollFlagsCopy+2,a2		; Update background
	lea	lvlCamXBgCopy,a3
	lea	levelLayout+$40.w,a4
	move.w	#$6000,d2
	bsr.w	DrawLevelBG1

	lea	lvlScrollFlagsCopy,a2		; Update foreground
	lea	lvlCamXCopy,a3
	lea	levelLayout.w,a4
	move.w	#$4000,d2

; -------------------------------------------------------------------------
; Draw foreground
; -------------------------------------------------------------------------
; PARAMETERS:
;	d2.w - Base high VDP write command
;	a2.l - Scroll flags pointer
;	a3.l - Camera position pointer
;	a4.l - Layout data pointer
;	a5.l - VDP control port
;	a6.l - VDP data port
; -------------------------------------------------------------------------

DrawLevelFG:
	tst.b	(a2)				; Are any scroll flags set?
	beq.s	.End				; If not, branch

	bclr	#0,(a2)				; Should we draw a row at the top?
	beq.s	.ChkBottomRow			; If not, branch
	moveq	#-16,d4				; Draw a row at (-16, -16)
	moveq	#-16,d5
	bsr.w	GetBlockVDPCmd
	moveq	#-16,d4
	moveq	#-16,d5
	bsr.w	DrawBlockRow

.ChkBottomRow:
	bclr	#1,(a2)				; Should we draw a row at the bottom?
	beq.s	.ChkLeftCol			; If not, branch
	move.w	#224,d4				; Draw a row at (-16, 224)
	moveq	#-16,d5
	bsr.w	GetBlockVDPCmd
	move.w	#224,d4
	moveq	#-16,d5
	bsr.w	DrawBlockRow

.ChkLeftCol:
	bclr	#2,(a2)				; Should we draw a column on the left?
	beq.s	.ChkRightCol			; If not, branch
	moveq	#-16,d4				; Draw a column at (-16, -16)
	moveq	#-16,d5
	bsr.w	GetBlockVDPCmd
	moveq	#-16,d4
	moveq	#-16,d5
	bsr.w	DrawBlockCol

.ChkRightCol:
	bclr	#3,(a2)				; Should we draw a column on the right?
	beq.s	.End				; If not, branch
	moveq	#-16,d4				; Draw a column at (320, -16)
	move.w	#320,d5
	bsr.w	GetBlockVDPCmd
	moveq	#-16,d4
	move.w	#320,d5
	bsr.w	DrawBlockCol

.End:
	rts

; -------------------------------------------------------------------------
; Draw background section #1
; -------------------------------------------------------------------------
; PARAMETERS:
;	d2.w - Base high VDP write command
;	a2.l - Scroll flags pointer
;	a3.l - Camera position pointer
;	a4.l - Layout data pointer
;	a5.l - VDP control port
;	a6.l - VDP data port
; -------------------------------------------------------------------------

DrawLevelBG1:
	lea	BGCameraSectIDs,a0		; Prepare background section camera IDs
	adda.w	#1,a0

	moveq	#-$10,d4			; Prepare to draw a row at the top

	bclr	#0,(a2)				; Should we draw a row at the top?
	bne.s	.GotRowPos			; If so, branch
	bclr	#1,(a2)				; Should we draw a row at the bottom?
	beq.s	.ChkHorizScroll			; If not, branch

	move.w	#224,d4				; Prepare to draw a row at the bottom

.GotRowPos:
	move.w	cameraBgY.w,d0			; Get which camera the current block section is using
	add.w	d4,d0
	andi.w	#$FFF0,d0
	asr.w	#4,d0
	move.b	(a0,d0.w),d0
	ext.w	d0
	add.w	d0,d0
	movea.l	.CameraSects(pc,d0.w),a3
	beq.s	.StaticRow			; If it's a statically drawn row of blocks, branch

	moveq	#-$10,d5			; Draw a row of blocks
	move.l	a0,-(sp)
	movem.l	d4-d5,-(sp)
	bsr.w	GetBlockVDPCmd
	movem.l	(sp)+,d4-d5
	bsr.w	DrawBlockRow
	movea.l	(sp)+,a0

	bra.s	.ChkHorizScroll

.StaticRow:
	moveq	#0,d5				; Draw a full statically drawn row of blocks
	move.l	a0,-(sp)
	movem.l	d4-d5,-(sp)
	bsr.w	GetBlockVDPCmdAbsX
	movem.l	(sp)+,d4-d5
	moveq	#(512/16)-1,d6
	bsr.w	DrawBlockRowAbsX
	movea.l	(sp)+,a0

.ChkHorizScroll:
	tst.b	(a2)				; Did the screen background horizontally at all?
	bne.s	.DidScrollHoriz			; If so, branch
	rts

.DidScrollHoriz:
	moveq	#-$10,d4			; Prepare to draw a column on the left
	moveq	#-$10,d5
	move.b	(a2),d0				; Should we draw a column on the right?
	andi.b	#%10101000,d0
	beq.s	.GotScrollDir			; If not, branch
	lsr.b	#1,d0				; Shift scroll flags to fit camera ID array later on
	move.b	d0,(a2)
	move.w	#320,d5				; Prepare to draw a column on the right

.GotScrollDir:
	move.w	cameraBgY.w,d0			; Prepare background section camera ID array
	andi.w	#$FFF0,d0
	asr.w	#4,d0
	suba.w	#1,a0
	lea	(a0,d0.w),a0

	bra.w	.DrawColumn

; -------------------------------------------------------------------------

.CameraSects:
	dc.l	lvlCamXBgCopy			; BG1 (static)
	dc.l	lvlCamXBgCopy			; BG1 (dynamic)
	dc.l	lvlCamXBg2Copy			; BG2 (dynamic)
	dc.l	lvlCamXBg3Copy			; BG3 (dynamic)

; -------------------------------------------------------------------------

.DrawColumn:
	moveq	#((224+(16*2))/16)-1,d6		; 16 blocks in a column
	move.l	#$800000,d7			; VDP command row delta

.Loop:
	moveq	#0,d0				; Get camera ID for this block section
	move.b	(a0)+,d0
	beq.s	.NextBlock			; If this is a static row of blocks, branch
	btst	d0,(a2)				; Has this block section scrolled enough to warrant a new block to be drawn?
	beq.s	.NextBlock			; If not, branch

	add.w	d0,d0				; Draw a block
	movea.l	.CameraSects(pc,d0.w),a3
	movem.l	d4-d5/a0,-(sp)
	movem.l	d4-d5,-(sp)
	bsr.w	GetBlockData
	movem.l	(sp)+,d4-d5
	bsr.w	GetBlockVDPCmd
	bsr.w	DrawBlock
	movem.l	(sp)+,d4-d5/a0

.NextBlock:
	addi.w	#16,d4				; Shift down
	dbf	d6,.Loop			; Loop until finished

	clr.b	(a2)				; Clear scroll flags
	rts

; -------------------------------------------------------------------------
; Draw background section #2 (unused)
; -------------------------------------------------------------------------
; PARAMETERS:
;	d2.w - Base high VDP write command
;	a2.l - Scroll flags pointer
;	a3.l - Camera position pointer
;	a4.l - Layout data pointer
;	a5.l - VDP control port
;	a6.l - VDP data port
; -------------------------------------------------------------------------

DrawLevelBG2:
	rts

; -------------------------------------------------------------------------
; Draw background section #3 (unused)
; -------------------------------------------------------------------------
; PARAMETERS:
;	d2.w - Base high VDP write command
;	a2.l - Scroll flags pointer
;	a3.l - Camera position pointer
;	a4.l - Layout data pointer
;	a5.l - VDP control port
;	a6.l - VDP data port
; -------------------------------------------------------------------------

DrawLevelBG3:
	rts

; -------------------------------------------------------------------------
; Draw a row of blocks
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - Swapped VDP write command
;	d4.w - Y position
;	d5.w - X position
;	a3.l - Camera position pointer
;	a4.l - Layout data pointer
;	a5.l - VDP control port
;	a6.l - VDP data port
; -------------------------------------------------------------------------

DrawBlockRow:
	moveq	#((320+(16*2))/16)-1,d6		; 22 blocks in a row

DrawBlockRow2:
	move.l	#$800000,d7			; VDP command row delta
	move.l	d0,d1				; Copy VDP command

.Loop:
	movem.l	d4-d5,-(sp)			; Draw a block
	bsr.w	GetBlockData
	move.l	d1,d0
	bsr.w	DrawBlock
	addq.b	#4,d1				; Set up VDP command for next block
	andi.b	#$7F,d1
	movem.l	(sp)+,d4-d5

	addi.w	#16,d5				; Move right
	dbf	d6,.Loop			; Loop until finished

	rts

; -------------------------------------------------------------------------
; Draw a static row of blocks
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - Swapped VDP write command
;	d4.w - Y position
;	d5.w - X position
;	a3.l - Camera position pointer
;	a4.l - Layout data pointer
;	a5.l - VDP control port
;	a6.l - VDP data port
; -------------------------------------------------------------------------

DrawBlockRowAbsX:
	move.l	#$800000,d7			; VDP command row delta
	move.l	d0,d1				; Copy VDP command

.Draw:
	movem.l	d4-d5,-(sp)			; Draw a block
	bsr.w	GetBlockDataAbsX
	move.l	d1,d0
	bsr.w	DrawBlock
	addq.b	#4,d1				; Set up VDP command for next block
	andi.b	#$7F,d1
	movem.l	(sp)+,d4-d5

	addi.w	#16,d5				; Move right
	dbf	d6,.Draw			; Loop until finished

	rts

; -------------------------------------------------------------------------
; Draw a column of blocks
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - Swapped VDP write command
;	d4.w - Y position
;	d5.w - X position
;	a3.l - Camera position pointer
;	a4.l - Layout data pointer
;	a5.l - VDP control port
;	a6.l - VDP data port
; -------------------------------------------------------------------------

DrawBlockCol:
	moveq	#((224+(16*2))/16)-1,d6		; 16 blocks in a column
	move.l	#$800000,d7			; VDP command row delta
	move.l	d0,d1				; Copy VDP command

.Draw:
	movem.l	d4-d5,-(sp)			; Draw a block
	bsr.w	GetBlockData
	move.l	d1,d0
	bsr.w	DrawBlock
	addi.w	#$100,d1			; Set up VDP command for next block
	andi.w	#$FFF,d1
	movem.l	(sp)+,d4-d5

	addi.w	#16,d4				; Move down
	dbf	d6,.Draw			; Loop until finished

	rts

; -------------------------------------------------------------------------
; Draw a block
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - Swapped VDP write command
;	d4.w - Y position
;	d5.w - X position
;	a0.l - Block metadata pointer
;	a1.l - Block data pointer
;	a5.l - VDP control port
;	a6.l - VDP data port
; -------------------------------------------------------------------------

DrawBlock:
	or.w	d2,d0				; Add base high VDP word
	swap	d0

	btst	#4,(a0)				; Is this block flipped vertically?
	bne.s	.FlipY				; If so, branch
	btst	#3,(a0)				; Is this block flipped horizontally?
	bne.s	.FlipX				; If so, branch

	move.l	d0,(a5)				; Draw a block
	move.l	(a1)+,(a6)
	add.l	d7,d0
	move.l	d0,(a5)
	move.l	(a1)+,(a6)
	rts

; -------------------------------------------------------------------------

.FlipX:
	move.l	d0,(a5)				; Draw a block (flipped horizontally)
	move.l	(a1)+,d4
	eori.l	#$8000800,d4
	swap	d4
	move.l	d4,(a6)
	add.l	d7,d0
	move.l	d0,(a5)
	move.l	(a1)+,d4
	eori.l	#$8000800,d4
	swap	d4
	move.l	d4,(a6)
	rts

; -------------------------------------------------------------------------

.FlipY:
	btst	#3,(a0)				; Is this block flipped horizontally?
	bne.s	.FlipXY				; If so, branch

	move.l	d0,(a5)				; Draw a block (flipped vertically)
	move.l	(a1)+,d5
	move.l	(a1)+,d4
	eori.l	#$10001000,d4
	move.l	d4,(a6)
	add.l	d7,d0
	move.l	d0,(a5)
	eori.l	#$10001000,d5
	move.l	d5,(a6)
	rts

; -------------------------------------------------------------------------

.FlipXY:
	move.l	d0,(a5)				; Draw a block (flipped both ways)
	move.l	(a1)+,d5
	move.l	(a1)+,d4
	eori.l	#$18001800,d4
	swap	d4
	move.l	d4,(a6)
	add.l	d7,d0
	move.l	d0,(a5)
	eori.l	#$18001800,d5
	swap	d5
	move.l	d5,(a6)
	rts

; -------------------------------------------------------------------------
; Get the addresses of a block's metadata and data at a position relative
; to a camera
; -------------------------------------------------------------------------
; PARAMETERS:
;	d4.w - Y position
;	d5.w - X position
;	a3.l - Camera position pointer
;	a4.l - Layout data pointer
; RETURNS:
;	a0.l - Block metadata pointer
;	a1.l - Block data pointer
; -------------------------------------------------------------------------

GetBlockData:
	add.w	(a3),d5				; Add camera X position

GetBlockDataAbsX:
	add.w	4(a3),d4			; Add camera Y position

GetBlockDataAbsXY:
	lea	levelBlocks,a1			; Prepare block data pointer

	move.w	d4,d3				; Get the chunk that the block we want is in
	lsr.w	#1,d3
	andi.w	#$380,d3
	lsr.w	#3,d5
	move.w	d5,d0
	lsr.w	#5,d0
	andi.w	#$7F,d0
	add.w	d3,d0
	move.l	#LevelChunks,d3
	move.b	(a4,d0.w),d3
	beq.s	.End				; If it's a blank chunk, branch out of here

	subq.b	#1,d3				; Get pointer to block metadata in the chunk
	andi.w	#$7F,d3
	ror.w	#7,d3
	add.w	d4,d4
	andi.w	#$1E0,d4
	andi.w	#$1E,d5
	add.w	d4,d3
	add.w	d5,d3
	movea.l	d3,a0

	move.w	(a0),d3				; Get pointer to block data
	andi.w	#$3FF,d3
	lsl.w	#3,d3
	adda.w	d3,a1

	moveq	#1,d0				; Mark block as retrieved

.End:
	rts

; -------------------------------------------------------------------------
; Get the address of a block's metadata at a position
; -------------------------------------------------------------------------
; PARAMETERS:
;	d4.w - Y position
;	d5.w - X position
;	a4.l - Layout data pointer
; RETURNS:
;	a0.l - Block metadata pointer
;	a1.l - Block data pointer
; -------------------------------------------------------------------------

GetBlockMetadata:
	move.w	d4,d3				; Get the chunk that the block we want is in
	lsr.w	#1,d3
	andi.w	#$380,d3
	lsr.w	#3,d5
	move.w	d5,d0
	lsr.w	#5,d0
	andi.w	#$7F,d0
	add.w	d3,d0
	move.l	#LevelChunks,d3
	move.b	(a4,d0.w),d3

	subq.b	#1,d3				; Get pointer to block metadata in the chunk
	andi.w	#$7F,d3
	ror.w	#7,d3
	add.w	d4,d4
	andi.w	#$1E0,d4
	andi.w	#$1E,d5
	add.w	d4,d3
	add.w	d5,d3
	movea.l	d3,a0

	rts

; -------------------------------------------------------------------------
; Place a block at a position in the level
; -------------------------------------------------------------------------
; NOTE: Be wary of using this function. It also overwrites chunk data in
; order for Sonic to interact with the block placed. It will affect
; every instance of the chunk affected.
; -------------------------------------------------------------------------
; PARAMETERS:
;	d3.w - Block metadata
;	d4.w - Y position
;	d5.w - X position
; -------------------------------------------------------------------------

PlaceBlockAtPos:
	move.l	a0,-(sp)

	lea	levelLayout.w,a4		; Prepare level layout
	lea	VDPCTRL,a5			; Prepare VDP ports
	lea	VDPDATA,a6
	move.w	#$4000,d2			; Set to draw on plane A
	move.l	#$800000,d7			; VDP command row delta

	movem.l	d3-d5,-(sp)
	bsr.w	GetBlockDataAbsXY		; Get the pointer to the block at our position
	bne.s	.GotBlock			; If we ended up getting a block, branch
	movem.l	(sp)+,d3-d5
	bra.s	.End

.GotBlock:
	movem.l	(sp)+,d3-d5

	move.w	d3,(a0)				; Overwrite the block in the chunk found
	bsr.w	ChkBlockPosOnscreen		; Check if this block is onscreen
	bne.s	.End				; If it's not, branch

	movem.l	d3-d5,-(sp)			; Draw the block
	lea	levelBlocks,a1
	andi.w	#$3FF,d3
	lsl.w	#3,d3
	adda.w	d3,a1
	bsr.w	GetBlockVDPCmdAbsXY
	bsr.w	DrawBlock
	movem.l	(sp)+,d3-d5

.End:
	movea.l	(sp)+,a0
	rts

; -------------------------------------------------------------------------
; Check if a block position is onscreen
; -------------------------------------------------------------------------
; PARAMETERS:
;	d4.w - Y position
;	d5.w - X position
; RETURNS:
;	d0.w - Return status
;	z/nz - Onscreen/offscreen
; -------------------------------------------------------------------------

ChkBlockPosOnscreen:
	move.w	cameraY.w,d0			; Is the block above the top of the screen?
	move.w	d0,d1
	andi.w	#$FFF0,d0
	subi.w	#16,d0
	cmp.w	d0,d4
	bcs.s	.Offscreen			; If so, branch

	addi.w	#224+16,d1			; Is the block below the bottom of the screen?
	andi.w	#$FFF0,d1
	cmp.w	d1,d4
	bgt.s	.Offscreen			; If so, branch

	move.w	cameraX.w,d0			; Is the block left of the left side of the screen?
	move.w	d0,d1
	andi.w	#$FFF0,d0
	subi.w	#16,d0
	cmp.w	d0,d5
	bcs.s	.Offscreen			; If so, branch

	addi.w	#320+16,d1			; Is the block right of the right side of the screen?
	andi.w	#$FFF0,d1
	cmp.w	d1,d5
	bgt.s	.Offscreen			; If so, branch

	moveq	#0,d0				; Mark as onscreen
	rts

.Offscreen:
	moveq	#1,d0				; Mark as offscreen
	rts

; -------------------------------------------------------------------------
; Calculate the base VDP command for drawing blocks with
; (For VRAM addresses $C000-$FFFF)
; -------------------------------------------------------------------------
; PARAMETERS:
;	d4.w - Y position
;	d5.w - X position
;	a3.l - Camera position pointer
; RETURNS:
;	d0.l - Base VDP command 
; -------------------------------------------------------------------------

GetBlockVDPCmd:
	add.w	(a3),d5				; Add camera X position

GetBlockVDPCmdAbsX:
	add.w	4(a3),d4			; Add camera Y position

GetBlockVDPCmdAbsXY:
	andi.w	#$F0,d4				; Calculate VDP command
	andi.w	#$1F0,d5
	lsl.w	#4,d4
	lsr.w	#2,d5
	add.w	d5,d4
	moveq	#3,d0
	swap	d0
	move.w	d4,d0

	rts

; -------------------------------------------------------------------------
; Calculate the base VDP command for drawing blocks with
; (For VRAM addresses $8000-$BFFF)
; -------------------------------------------------------------------------
; PARAMETERS:
;	d4.w - Y position
;	d5.w - X position
;	a3.l - Camera position pointer
; RETURNS:
;	d0.l - Base VDP command 
; -------------------------------------------------------------------------

GetBlockVDPCmd2:
	add.w	4(a3),d4			; Add camera Y position
	add.w	(a3),d5				; Add camera X position

	andi.w	#$F0,d4				; Calculate VDP command
	andi.w	#$1F0,d5
	lsl.w	#4,d4
	lsr.w	#2,d5
	add.w	d5,d4
	moveq	#2,d0
	swap	d0
	move.w	d4,d0

	rts

; -------------------------------------------------------------------------
; Start level drawing
; -------------------------------------------------------------------------

LevelDraw_Start:
	lea	VDPCTRL,a5			; Prepare VDP ports
	lea	VDPDATA,a6

	lea	cameraX.w,a3			; Initialize foreground
	lea	levelLayout.w,a4
	move.w	#$4000,d2
	bsr.s	LevelDraw_StartFG

	lea	cameraBgX.w,a3			; Initialize background
	lea	levelLayout+$40.w,a4
	move.w	#$6000,d2
	bra.w	LevelDraw_StartBG

; -------------------------------------------------------------------------
; Draw foreground
; -------------------------------------------------------------------------
; PARAMETERS:
;	d2.w - Base high VDP write command
;	a3.l - Camera position pointer
;	a4.l - Layout data pointer
;	a5.l - VDP control port
;	a6.l - VDP data port
; -------------------------------------------------------------------------

LevelDraw_StartFG:
	moveq	#-16,d4				; Start drawing at the top of the screen
	moveq	#((224+(16*2))/16)-1,d6		; 16 blocks in a column

.Draw:
	movem.l	d4-d6,-(sp)			; Draw a full row of blocks
	moveq	#0,d5
	move.w	d4,d1
	bsr.w	GetBlockVDPCmd
	move.w	d1,d4
	moveq	#0,d5
	moveq	#(512/16)-1,d6
	bsr.w	DrawBlockRow2
	movem.l	(sp)+,d4-d6

	addi.w	#16,d4				; Move down
	dbf	d6,.Draw			; Loop until finished

	rts

; -------------------------------------------------------------------------
; Draw background
; -------------------------------------------------------------------------
; PARAMETERS:
;	d2.w - Base high VDP write command
;	a3.l - Camera position pointer
;	a4.l - Layout data pointer
;	a5.l - VDP control port
;	a6.l - VDP data port
; -------------------------------------------------------------------------

LevelDraw_StartBG:
	moveq	#-16,d4				; Start drawing at the top of the screen
	moveq	#((224+(16*2))/16)-1,d6		; 16 blocks in a column

.Draw:
	movem.l	d4-d6/a0,-(sp)			; Draw a row of blocks
	lea	BGCameraSectIDs,a0
	adda.w	#1,a0
	move.w	cameraBgY.w,d0
	add.w	d4,d0
	andi.w	#$7F0,d0
	bsr.w	DrawBGBlockRow
	movem.l	(sp)+,d4-d6/a0

	addi.w	#16,d4				; Move down
	dbf	d6,.Draw			; Loop until finished

	rts

; -------------------------------------------------------------------------
; Background camera sections
; -------------------------------------------------------------------------
; Each row of blocks is assigned a background camera section to help determine
; how to draw it
; -------------------------------------------------------------------------
; 0 = Background 1 (Static)
; 2 = Background 1 (Dynamic)
; 4 = Background 2 (Dynamic)
; 6 = Background 3 (Dynamic)
; -------------------------------------------------------------------------

BGSTATIC	EQU	0
BGDYNAMIC1	EQU	2
BGDYNAMIC2	EQU	4
BGDYNAMIC3	EQU	6

BG_CAM_SECT macros size, id

	dcb.b	(\size)/16, \id

; -------------------------------------------------------------------------

BGCameraSectIDs:
	BG_CAM_SECT 16,  BGSTATIC		; Offscreen top row, required to be here

	BG_CAM_SECT 16,	 BGSTATIC		; Top clouds
	BG_CAM_SECT 32,	 BGSTATIC
	BG_CAM_SECT 48,	 BGSTATIC
	BG_CAM_SECT 64,	 BGSTATIC
	BG_CAM_SECT 64,	 BGSTATIC
	BG_CAM_SECT 64,	 BGSTATIC
	BG_CAM_SECT 32,	 BGSTATIC
	BG_CAM_SECT 48,	 BGSTATIC
	BG_CAM_SECT 48,	 BGSTATIC
	BG_CAM_SECT 32,	 BGSTATIC
	BG_CAM_SECT 160, BGSTATIC		; Top mountains
	BG_CAM_SECT 32,	 BGSTATIC		; Top bushes
	BG_CAM_SECT 224, BGSTATIC		; Top water

	BG_CAM_SECT 224, BGSTATIC		; Upside down water
	BG_CAM_SECT 32,  BGSTATIC		; Upside down bushes
	BG_CAM_SECT 160, BGDYNAMIC2		; Upside down mountains
	BG_CAM_SECT 16,  BGSTATIC		; Upside down clouds
	BG_CAM_SECT 32,  BGSTATIC
	BG_CAM_SECT 48,  BGSTATIC
	BG_CAM_SECT 64,  BGSTATIC
	BG_CAM_SECT 64,  BGSTATIC

	BG_CAM_SECT 64,  BGSTATIC		; Bottom clouds
	BG_CAM_SECT 32,  BGSTATIC
	BG_CAM_SECT 80,  BGSTATIC
	BG_CAM_SECT 32,  BGSTATIC
	BG_CAM_SECT 16,  BGSTATIC
	BG_CAM_SECT 160, BGDYNAMIC2		; Bottom mountains
	BG_CAM_SECT 32,  BGSTATIC		; Bottom bushes
	BG_CAM_SECT 144, BGSTATIC		; Bottom water

	even

; -------------------------------------------------------------------------

BGCameraSects:
	dc.l	cameraBgX&$FFFFFF		; BG1 (static)
	dc.l	cameraBgX&$FFFFFF		; BG1 (dynamic)
	dc.l	cameraBg2X&$FFFFFF		; BG2 (dynamic)
	dc.l	cameraBg3X&$FFFFFF		; BG3 (dynamic)

; -------------------------------------------------------------------------
; Draw row of blocks for the background
; -------------------------------------------------------------------------
; PARAMETERS:
;	d2.w - Base high VDP write command
;	a0.l - Background camera sections
;	a3.l - Camera position pointer
;	a4.l - Layout data pointer
;	a5.l - VDP control port
;	a6.l - VDP data port
; -------------------------------------------------------------------------

DrawBGBlockRow:
	lsr.w	#4,d0				; Get camera section ID
	move.b	(a0,d0.w),d0
	add.w	d0,d0
	movea.l	BGCameraSects(pc,d0.w),a3
	beq.s	.StaticRow			; If it's a statically drawn row of blocks, branch

	moveq	#-16,d5				; Draw a row of blocks
	movem.l	d4-d5,-(sp)
	bsr.w	GetBlockVDPCmd
	movem.l	(sp)+,d4-d5
	bsr.w	DrawBlockRow
	bra.s	.End

.StaticRow:
	moveq	#0,d5				; Draw a full statically drawn row of blocks
	movem.l	d4-d5,-(sp)
	bsr.w	GetBlockVDPCmdAbsX
	movem.l	(sp)+,d4-d5
	moveq	#(512/16)-1,d6
	bsr.w	DrawBlockRowAbsX

.End:
	rts

; -------------------------------------------------------------------------
; Load level data
; -------------------------------------------------------------------------

LoadLevelData:
	moveq	#0,d0				; Prepare level data index
	lea	LevelDataIndex,a2
	move.l	a2,-(sp)

	addq.l	#4,a2				; Skip over level art pointer (art is loaded in PLCs instead)

	move.l	(a2)+,d1			; Load level blocks
	andi.l	#$3FFFFF,d1
	movea.l	d1,a0
	lea	levelBlocks,a4
	bsr.w	NemDecToRAM

	movea.l	(a2)+,a0			; Skip over level chunks (chunks are uncompressed, and are referenced directly
						; by collision and drawing routines)

	bsr.w	LoadLevelLayout			; Load level layout

	move.w	(a2)+,d0			; Load level palette
	move.w	(a2),d0
	andi.w	#$FF,d0
	bsr.w	LoadFadePal

	movea.l	(sp)+,a2			; Skip over to PLC ID
	addq.w	#4,a2

	tst.b	resetLevelFlags			; Was the level reset midway?
	beq.s	.ChkStdPLC			; If not, branch

	jmp	LoadCameraPLC_Full		; Reload camera based PLCs

.ChkStdPLC:
	btst	#1,plcLoadFlags			; Was the title card marked as loaded?
	beq.s	.End				; If not, branch

	moveq	#0,d0				; Load PLCs
	move.b	(a2),d0
	beq.s	.End				; If the PLC ID is 0, branch
	bsr.w	LoadPLC

.End:
	rts

; -------------------------------------------------------------------------
; Load a level layout
; -------------------------------------------------------------------------

LoadLevelLayout:
	lea	levelLayout.w,a3		; Clear layout RAM
	move.w	#$1FF,d1
	moveq	#0,d0

.Clear:
	move.l	d0,(a3)+
	dbf	d1,.Clear			; Loop until finished

	lea	levelLayout.w,a3		; Load foreground layout
	moveq	#0,d1
	bsr.w	.LoadPlane

	lea	levelLayout+$40.w,a3		; Load background layout
	moveq	#2,d1

; -------------------------------------------------------------------------

.LoadPlane:
	moveq	#0,d0				; Get pointer to layout data
	add.w	d1,d0
	lea	LevelLayoutIndex,a1
	move.w	(a1,d0.w),d0
	lea	(a1,d0.w),a1

	moveq	#0,d1				; Get layout size
	move.w	d1,d2
	move.b	(a1)+,d1
	move.b	(a1)+,d2

.RowLoop:
	move.w	d1,d0				; Prepare to copy row
	movea.l	a3,a0

.ChunkLoop:
	move.b	(a1)+,(a0)+			; Copy row of layout data
	dbf	d0,.ChunkLoop			; Loop until finished

	lea	$80(a3),a3			; Next row
	dbf	d2,.RowLoop			; Loop until finished

	rts

; -------------------------------------------------------------------------
; Run level events
; -------------------------------------------------------------------------

RunLevelEvents:
	moveq	#0,d0				; Run level events
	move.b	levelZone,d0
	add.w	d0,d0
	move.w	.Events(pc,d0.w),d0
	jsr	.Events(pc,d0.w)

	cmpi.b	#$2B,objPlayerSlot+oAnim.w	; Is the player giving up from boredom?
	bne.s	.NotGivingUp			; If not, branch
	move.w	cameraY.w,bottomBound.w		; Set the bottom boundary of the level to wherever the camera is
	move.w	cameraY.w,destBottomBound.w

.NotGivingUp:
	moveq	#4,d1				; Bottom boundary shift speed
	move.w	destBottomBound.w,d0		; Is the bottom boundary shifting?
	sub.w	bottomBound.w,d0
	beq.s	.End				; If not, branch
	bcc.s	.MoveDown			; If it's scrolling down, branch

	neg.w	d1				; Set the speed to go up
	move.w	cameraY.w,d0			; Is the camera past the target bottom boundary?
	cmp.w	destBottomBound.w,d0
	bls.s	.ShiftUp			; If not, branch
	move.w	d0,bottomBound.w		; Set the bottom boundary to be where the camera id
	andi.w	#$FFFE,bottomBound.w

.ShiftUp:
	add.w	d1,bottomBound.w		; Shift the boundary up
	move.b	#1,btmBoundShift.w		; Mark as shifting

.End:
	rts

.MoveDown:
	move.w	cameraY.w,d0			; Is the camera near the bottom boundary?
	addq.w	#8,d0
	cmp.w	bottomBound.w,d0
	bcs.s	.ShiftDown			; If not, branch
	btst	#1,objPlayerSlot+oStatus.w	; Is the player in the air?
	beq.s	.ShiftDown			; If not, branch
	add.w	d1,d1				; If so, quadruple the shift speed
	add.w	d1,d1

.ShiftDown:
	add.w	d1,bottomBound.w		; Shift the boundary down
	move.b	#1,btmBoundShift.w		; Mark as shifting
	rts

; -------------------------------------------------------------------------

.Events:
	dc.w	LevEvents_PPZ-.Events		; PPZ
	dc.w	LevEvents_CCZ-.Events		; CCZ
	dc.w	LevEvents_TTZ-.Events		; TTZ
	dc.w	LevEvents_QQZ-.Events		; QQZ
	dc.w	LevEvents_WWZ-.Events		; WWZ
	dc.w	LevEvents_SSZ-.Events		; SSZ
	dc.w	LevEvents_MMZ-.Events		; MMZ

; -------------------------------------------------------------------------
; Palmtree Panic level events
; -------------------------------------------------------------------------

LevEvents_PPZ:
	moveq	#0,d0				; Run act specific level events
	move.b	levelAct,d0
	add.w	d0,d0
	move.w	LevEvents_PPZ_Index(pc,d0.w),d0
	jmp	LevEvents_PPZ_Index(pc,d0.w)

; -------------------------------------------------------------------------

LevEvents_PPZ_Index:
	dc.w	LevEvents_PPZ1-LevEvents_PPZ_Index
	dc.w	LevEvents_PPZ2-LevEvents_PPZ_Index
	dc.w	LevEvents_PPZ3-LevEvents_PPZ_Index

; -------------------------------------------------------------------------

LevEvents_PPZ1:
	cmpi.b	#1,timeZone			; Are we in the present?
	bne.s	LevEvents_PPZ2			; If not, branch

	cmpi.w	#$1C16,objPlayerSlot+oX.w	; Is the player within the second 3D ramp?
	bcs.s	.Not3DRamp			; If not, branch
	cmpi.w	#$21C6,objPlayerSlot+oX.w
	bcc.s	.Not3DRamp			; If not, branch
	move.w	#$88,camYCenter.w		; If so, change the camera Y center

.Not3DRamp:
	move.w	#$710,destBottomBound.w		; Set bottom boundary before the first 3D ramp

	cmpi.w	#$840,cameraX.w			; Is the camera's X position < $840?
	bcs.s	.End				; If so, branch

	tst.b	updateTime			; Is the level timer running?
	beq.s	.AlreadySet			; If not, branch

	cmpi.w	#$820,leftBound.w		; Has the left boundary been set
	bcc.s	.AlreadySet			; If not, branch
	move.w	#$820,leftBound.w		; Set the left boundary so that the player can't go back to the first 3D ramp
	move.w	#$820,destLeftBound.w

.AlreadySet:
	move.w	#$410,destBottomBound.w		; Set bottom boundary after the first 3D ramp
	cmpi.w	#$E00,cameraX.w			; Is the camera's X position < $E00?
	bcs.s	.End				; If so, branch
	move.w	#$310,destBottomBound.w		; Update the bottom boundary

.End:
	rts

; -------------------------------------------------------------------------

LevEvents_PPZ2:
	move.w	#$310,destBottomBound.w		; Set default bottom boundary
	rts

; -------------------------------------------------------------------------

LevEvents_PPZ3:
	tst.b	bossFlags.w			; Is the boss active?
	bne.s	.End				; If so, branch

	move.w	#$310,destBottomBound.w		; Set default bottom boundary
	move.w	#$D70,d0			; Handle end of act 3 boundary
	move.w	#$310,d1
	bsr.w	ChkSetAct3EndBounds

.End:
	rts

; -------------------------------------------------------------------------
; Collision Chaos level events
; -------------------------------------------------------------------------

LevEvents_CCZ:
	moveq	#0,d0				; Run act specific level events
	move.b	levelAct,d0
	add.w	d0,d0
	move.w	LevEvents_CCZ_Index(pc,d0.w),d0
	jmp	LevEvents_CCZ_Index(pc,d0.w)

; -------------------------------------------------------------------------

LevEvents_CCZ_Index:
	dc.w	LevEvents_CCZ12-LevEvents_CCZ_Index
	dc.w	LevEvents_CCZ12-LevEvents_CCZ_Index
	dc.w	LevEvents_CCZ3-LevEvents_CCZ_Index

; -------------------------------------------------------------------------

LevEvents_CCZ12:
	move.w	#$510,destBottomBound.w		; Set default bottom boundary
	rts

; -------------------------------------------------------------------------

LevEvents_CCZ3:
	tst.b	bossFlags.w			; Was the boss defeated?
	bne.w	.ChkLock			; If so, branch
	move.w	#$510,destBottomBound.w		; Set default bottom boundary
	rts

.ChkLock:
	move.w	#$60,d1				; Handle end of act 3 boundary
	bra.w	SetAct3EndBounds

; -------------------------------------------------------------------------
; Wacky Workbench level events
; -------------------------------------------------------------------------

LevEvents_WWZ:
	btst	#4,bossFlags.w			; Is the boss active?
	bne.s	.BossActive			; If so, branch
	move.w	#$710,destBottomBound.w		; Set default bottom boundary
	rts

.BossActive:
	move.w	#$BA0,d0			; Handle end of act 3 boundary
	move.w	#$1D0,d1
	bsr.w	ChkSetAct3EndBounds
	bne.w	.End				; If the boundary was set, branch

	lea	objPlayerSlot.w,a1		; Check where the player is
	cmpi.w	#$298,oY(a1)			; Are they at the top of the boss arena?
	ble.s	.BoundTop			; If so, branch
	cmpi.w	#$498,oY(a1)			; Are they in the middle of the boss arena?
	ble.s	.BoundMiddle			; If so, branch

.BoundBottom:
	move.w	#$5D0,d0			; Set the bottom boundary at the bottom
	bra.s	.SetBound

.BoundMiddle:
	move.w	#$3D0,d0			; Set the bottom boundary in the middle
	bra.s	.SetBound

.BoundTop:
	move.w	#$1D0,d0			; Set the bottom boundary at the top

.SetBound:
	move.w	d0,d1				; Set target bottom boundary
	move.w	d0,destBottomBound.w

	sub.w	bottomBound.w,d0		; Is the current bottom boundary near the target?
	bge.s	.CheckNearBound
	neg.w	d0

.CheckNearBound:
	cmpi.w	#2,d0
	bgt.s	.End				; If not, branch
	move.w	d1,bottomBound.w		; Update bottom boundary

.End:
	rts

; -------------------------------------------------------------------------
; Quartz Quadrant level events
; -------------------------------------------------------------------------

LevEvents_QQZ:
	moveq	#0,d0				; Run act specific level events
	move.b	levelAct,d0
	add.w	d0,d0
	move.w	LevEvents_QQZ_Index(pc,d0.w),d0
	jmp	LevEvents_QQZ_Index(pc,d0.w)

; -------------------------------------------------------------------------

LevEvents_QQZ_Index:
	dc.w	LevEvents_QQZ12-LevEvents_QQZ_Index
	dc.w	LevEvents_QQZ12-LevEvents_QQZ_Index
	dc.w	LevEvents_QQZ3-LevEvents_QQZ_Index

; -------------------------------------------------------------------------

LevEvents_QQZ12:
	move.w	#$310,destBottomBound.w		; Set default bottom boundary
	rts

; -------------------------------------------------------------------------

LevEvents_QQZ3:
	move.w	#$E10,d0			; Handle end of act 3 boundary
	move.w	#$1F8,d1
	bsr.w	ChkSetAct3EndBounds
	bne.s	.End				; If the boundary was set, branch

	tst.b	bossFlags.w			; Is the boss active?
	bne.s	.BossActive			; If so, branch
	move.w	#$320,destBottomBound.w		; Set default bottom boundary

.End:
	rts

.BossActive:
	move.w	#$1F8,bottomBound.w		; Set bottom boundary for the boss
	move.w	#$1F8,destBottomBound.w
	rts

; -------------------------------------------------------------------------
; Metallic Madness level events
; -------------------------------------------------------------------------

LevEvents_MMZ:
	moveq	#0,d0				; Run act specific level events
	move.b	levelAct,d0
	add.w	d0,d0
	move.w	LevEvents_MMZ_Index(pc,d0.w),d0
	jmp	LevEvents_MMZ_Index(pc,d0.w)

; -------------------------------------------------------------------------

LevEvents_MMZ_Index:
	dc.w	LevEvents_MMZ12-LevEvents_MMZ_Index
	dc.w	LevEvents_MMZ12-LevEvents_MMZ_Index
	dc.w	LevEvents_MMZ3-LevEvents_MMZ_Index

; -------------------------------------------------------------------------

LevEvents_MMZ12:
	move.w	#$710,destBottomBound.w		; Set default bottom boundary
	rts

; -------------------------------------------------------------------------

LevEvents_MMZ3:
	tst.b	bossFlags.w			; Is the boss active?
	bne.s	.BossActive			; If so, branch
	move.w	#$310,destBottomBound.w		; Set default bottom boundary
	rts

.BossActive:
	move.w	#$10C,d0			; Set boundaries for the boss
	move.w	d0,topBound.w
	move.w	d0,destTopBound.w
	move.w	d0,bottomBound.w
	move.w	d0,destBottomBound.w
	rts

; -------------------------------------------------------------------------
; Tidal Tempest level events
; -------------------------------------------------------------------------

LevEvents_TTZ:
	moveq	#0,d0				; Run act specific level events
	move.b	levelAct,d0
	add.w	d0,d0
	move.w	LevEvents_TTZ_Index(pc,d0.w),d0
	jmp	LevEvents_TTZ_Index(pc,d0.w)

; -------------------------------------------------------------------------

LevEvents_TTZ_Index:
	dc.w	LevEvents_TTZ1-LevEvents_TTZ_Index
	dc.w	LevEvents_TTZ2-LevEvents_TTZ_Index
	dc.w	LevEvents_TTZ3-LevEvents_TTZ_Index

; -------------------------------------------------------------------------

LevEvents_TTZ1:
	move.w	#$510,destBottomBound.w		; Set default bottom boundary
	rts

; -------------------------------------------------------------------------

LevEvents_TTZ2:
	cmpi.b	#$2B,objPlayerSlot+oAnim.w	; Is the player giving up from boredom?
	beq.s	.NoWrap				; If so, branch
	cmpi.b	#6,objPlayerSlot+oRoutine.w	; Is the player dead?
	bcc.s	.NoWrap				; If so, branch

	move.w	#$800,bottomBound.w		; Set bottom boundary for wrapping section
	move.w	#$800,destBottomBound.w
	cmpi.w	#$200,cameraX.w			; Is the camera's X position < $200?
	bcs.s	.End				; If so, branch

.NoWrap:
	move.w	#$710,bottomBound.w		; Set bottom boundary after the wrapping section
	move.w	#$710,destBottomBound.w

.End:
	rts

; -------------------------------------------------------------------------

LevEvents_TTZ3:
	move.w	#$AF8,d0			; Handle end of act 3 boundary
	move.w	#$4C0,d1
	bsr.w	ChkSetAct3EndBounds
	bne.s	.End				; If the boundary was set, branch

	tst.b	bossFlags.w			; Has the boss fight been started?
	bne.s	.BossActive			; If so, branch

.End:
	rts

.BossActive:
	move.w	#$4F0,bottomBound.w		; Set bottom boundary for the boss fight
	move.w	#$4F0,destBottomBound.w
	rts

; -------------------------------------------------------------------------
; Stardust Speedway level events
; -------------------------------------------------------------------------

LevEvents_SSZ:
	moveq	#0,d0				; Run act specific level events
	move.b	levelAct,d0
	add.w	d0,d0
	move.w	LevEvents_SSZ_Index(pc,d0.w),d0
	jmp	LevEvents_SSZ_Index(pc,d0.w)

; -------------------------------------------------------------------------

LevEvents_SSZ_Index:
	dc.w	LevEvents_SSZ1-LevEvents_SSZ_Index
	dc.w	LevEvents_SSZ2-LevEvents_SSZ_Index
	dc.w	LevEvents_SSZ3-LevEvents_SSZ_Index

; -------------------------------------------------------------------------

LevEvents_SSZ1:
	move.w	#$510,destBottomBound.w		; Set default bottom boundary
	rts

; -------------------------------------------------------------------------

LevEvents_SSZ2:
	move.w	#$710,destBottomBound.w		; Set default bottom boundary
	rts

; -------------------------------------------------------------------------

LevEvents_SSZ3:
	lea	objPlayerSlot.w,a1		; Have we reached Metal Sonic?
	cmpi.w	#$930,oX(a1)
	bge.s	.FoundMetalSonic		; If so, branch
	move.w	#$210,destBottomBound.w		; If not, set default bottom boundary
	rts

.FoundMetalSonic:
	cmpi.w	#$DC0,oX(a1)			; Has the race started?
	blt.s	.RaceStarted			; If so, branch
	move.w	#$210,destBottomBound.w		; If not, set default bottom boundary
	rts

.RaceStarted:
	move.w	#$120,d0			; Set bottom boundary for the race
	move.w	d0,d1
	move.w	d0,destBottomBound.w

	sub.w	bottomBound.w,d1		; Is the current bottom boundary near the target?
	bpl.s	.CheckNearBound
	neg.w	d1

.CheckNearBound:
	cmpi.w	#4,d1
	bge.s	.End				; If not, branch
	move.w	d0,bottomBound.w		; Update bottom boundary

.End:
	rts

; -------------------------------------------------------------------------
; Check if the end of act 3 boundaries should be set
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - X position in which boundaries are set
;	d1.w - Bottom boundary value
; -------------------------------------------------------------------------

ChkSetAct3EndBounds:
	cmp.w	objPlayerSlot+oX.w,d0		; Has the player reached the point where boundaries should be set?
	ble.s	SetAct3EndBounds		; If so, branch

	moveq	#0,d0				; Mark boundaries as not set
	rts

; -------------------------------------------------------------------------

SetAct3EndBounds:
	move.w	d1,destBottomBound.w		; Set bottom boundary

	sub.w	bottomBound.w,d1		; Is the current bottom boundary near the target?
	bpl.s	.CheckNearBound
	neg.w	d1

.CheckNearBound:
	cmpi.w	#4,d1
	bge.s	.NoYLock			; If not, branch
	move.w	destBottomBound.w,bottomBound.w; Update bottom boundary

.NoYLock:
	move.w	objPlayerSlot+oX.w,d0		; Get player's position
	subi.w	#320/2,d0
	cmp.w	leftBound.w,d0			; Has the left boundary already been set?
	blt.s	.BoundsSet			; If so, branch
	cmp.w	rightBound.w,d0			; Have we reached the right boundary?
	ble.s	.NoBoundSet			; If not, branch
	move.w	rightBound.w,d0			; Set to bound at the right boundary

.NoBoundSet:
	move.w	d0,leftBound.w			; Update the left boundary
	move.w	d0,destLeftBound.w

.BoundsSet:
	moveq	#1,d0				; Mark boundaries as set
	rts

; -------------------------------------------------------------------------
; Run objects
; -------------------------------------------------------------------------

RunObjects:
	lea	objects.w,a0			; Prepare objects
	moveq	#(objectsEnd-objects)/oSize-1,d7

	moveq	#0,d0				; Prepare to get object ID

.Loop:
	move.b	(a0),d0				; Get object ID
	beq.s	.NextObj			; If it's 0, branch

	add.w	d0,d0				; Run object
	add.w	d0,d0
	lea	ObjectIndex,a1
	movea.l -4(a1,d0.w),a1
	jsr	(a1)

	moveq	#0,d0				; Prepare to get object ID

.NextObj:
	lea	oSize(a0),a0			; Get next object
	dbf	d7,.Loop			; Loop until finished

	rts

; -------------------------------------------------------------------------
; Handle player movement with gravity
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

ObjMoveGrv:
	move.l	oX(a0),d2			; Get position
	move.l	oY(a0),d3

	move.w	oXVel(a0),d0			; Apply X velocity
	ext.l	d0
	asl.l	#8,d0
	add.l	d0,d2

	move.w	oYVel(a0),d0			; Get Y velocity

	btst	#3,oPlayerCtrl(a0)		; Is gravity disabled (ignores the 3D ramp)?
	bne.s	.NoGravity			; If so, branch

	bpl.s	.CheckGravity			; If we are moving downwards, branch

	btst	#1,oPlayerCtrl(a0)		; Are we on a 3D ramp?
	beq.s	.CheckGravity			; If not, branch
	cmpi.w	#-$800,oYVel(a0)		; Are we going fast enough?
	bcs.s	.NoGravity			; If so, branch

.CheckGravity:
	btst	#2,oPlayerCtrl(a0)		; Is gravity disabled?
	bne.s	.NoGravity			; If so, branch
	addi.w	#$38,oYVel(a0)			; Apply gravity

.NoGravity:
	tst.w	oYVel(a0)			; Are we moving up?
	bmi.s	.NoDownVelCap			; If so, branch
	cmpi.w	#$1000,oYVel(a0)		; Are we falling down too fast?
	bcs.s	.NoDownVelCap			; If not, branch
	move.w	#$1000,oYVel(a0)		; Cap the fall speed

.NoDownVelCap:
	ext.l	d0				; Apply Y velocity
	asl.l	#8,d0
	add.l	d0,d3

	move.l	d2,oX(a0)			; Update position
	move.l	d3,oY(a0)
	rts

; -------------------------------------------------------------------------
; Handle player movement
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

ObjMove:
	move.l	oX(a0),d2			; Get position
	move.l	oY(a0),d3

	move.w	oXVel(a0),d0			; Get X velocity

	btst	#3,oStatus(a0)			; Are we standing on an object?
	beq.s	.NotOnObj			; If not, branch

	moveq	#0,d1				; Get the object we are standing on
	move.b	oPlayerStandObj(a0),d1
	lsl.w	#6,d1
	addi.l	#objects&$FFFFFF,d1
	movea.l	d1,a1
	cmpi.b	#$1E,oID(a1)			; Is it a pinball flipper from CCZ?
	bne.s	.NotOnObj			; If not, branch

	move.w	#-$100,d1			; Get resistance value
	btst	#0,oStatus(a1)			; Is the object flipped?
	beq.s	.NotNeg				; If not, branch
	neg.w	d1				; Flip the resistance value

.NotNeg:
	add.w	d1,d0				; Apply resistance on the X velocity

.NotOnObj:
	ext.l	d0				; Apply X velocity
	asl.l	#8,d0
	add.l	d0,d2

	move.w	oYVel(a0),d0			; Apply Y velocity
	ext.l	d0
	asl.l	#8,d0
	add.l	d0,d3

	move.l	d2,oX(a0)			; Update position
	move.l	d3,oY(a0)
	rts

; -------------------------------------------------------------------------
; Draw an object's sprite
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Object RAM
; -------------------------------------------------------------------------

DrawObject:
	bclr	#7,oRender(a0)			; Mark this object as offscreen

	move.b	oRender(a0),d0			; Is this object to be drawn relative to a camera?
	andi.w	#$C,d0
	beq.w	.DrawObj			; If not, branch

	move.b	oWidth(a0),d0			; Is this object onscreen horizontally?
	move.w	oX(a0),d3
	sub.w	cameraX.w,d3
	move.w	d3,d1
	add.w	d0,d1
	bmi.s	.End				; If not, branch
	move.w	d3,d1
	sub.w	d0,d1
	cmpi.w	#320,d1
	bge.s	.End				; If not, branch

	move.b	oYRadius(a0),d0			; Get object Y position and radius
	move.w	oY(a0),d3

	cmpi.w	#$100,cameraY.w			; Are we near the top of the screen?
	bcc.s	.ChkBottomWrap			; If not, branch
	cmpi.w	#$800,d3			; Is this object at the bottom of the level?
	bcs.s	.CheckY				; If not, branch
	subi.w	#$800,d3			; Wrap to the top of the screen
	bra.s	.CheckY

.ChkBottomWrap:
	cmpi.w	#$700,cameraY.w			; Are we near the bottom of the screen?
	bcs.s	.CheckY				; If not, branch
	cmpi.w	#$100,d3			; Is this object at the top of the level?
	bcc.s	.CheckY				; If not, branch
	addi.w	#$800,d3			; Wrap to the bottom of the screen

.CheckY:
	sub.w	cameraY.w,d3			; Is this object onscreen vertically?
	move.w	d3,d1
	add.w	d0,d1
	bmi.s	.End				; If not, branch
	move.w	d3,d1
	sub.w	d0,d1
	cmpi.w	#$E0,d1
	bge.s	.End				; If not, branch

.DrawObj:
	lea	objDrawQueue.w,a1		; Get the object draw queue for this object's priority level
	move.w	oPriority(a0),d0
	lsr.w	#1,d0
	andi.w	#$380,d0
	adda.w	d0,a1

	cmpi.w	#$7E,(a1)			; Is the queue full?
	bcc.s	.End				; If so, branch
	addq.w	#2,(a1)				; Add this object to the queue
	adda.w	(a1),a1
	move.w	a0,(a1)

.End:
	rts

; -------------------------------------------------------------------------
; Draw another object's sprite
; -------------------------------------------------------------------------
; PARAMETERS:
;	a1.l - Object RAM
; -------------------------------------------------------------------------

DrawOtherObject:
	lea	objDrawQueue.w,a2		; Get the object draw queue for this object's priority level
	move.w	$18(a1),d0
	lsr.w	#1,d0
	andi.w	#$380,d0
	adda.w	d0,a2

	cmpi.w	#$7E,(a2)			; Is the queue full?
	bcc.s	.End				; If so, branch
	addq.w	#2,(a2)				; Add this object to the queue
	adda.w	(a2),a2
	move.w	a1,(a2)

.End:
	rts

; -------------------------------------------------------------------------
; Make an object delete itself
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Object RAM
; -------------------------------------------------------------------------

DeleteObject:
	movea.l	a0,a1				; Clear object slot RAM
	moveq	#0,d1
	moveq	#oSize/4-1,d0

.Clear:
	move.l	d1,(a1)+
	dbf	d0,.Clear

	rts

; -------------------------------------------------------------------------
; Draw all of the queued object sprites
; -------------------------------------------------------------------------

ObjDrawCameras:
	dc.l	0				; Absolute position
	dc.l	cameraX&$FFFFFF			; Relative to FG camera
	dc.l	cameraBgX&$FFFFFF		; Relative to BG camera
	dc.l	cameraBg3X&$FFFFFF		; Relative to BG3 camera

; -------------------------------------------------------------------------

DrawObjects:
	lea	sprites.w,a2			; Prepare sprite table buffer
	moveq	#0,d5				; Prepare sprite counter
	lea	objDrawQueue.w,a4		; Prepare object draw queue

	moveq	#8-1,d7				; Number of priority levels

.LevelLoop:
	tst.w	(a4)				; Does this priority level's queue have any entries?
	beq.w	.NextLevel			; If not, branch
	moveq	#2,d6				; Prepare to go through the queue

.ObjLoop:
	movea.w	(a4,d6.w),a0			; Get entry object RAM

	tst.b	(a0)				; Is this object loaded?
	beq.w	.NextObj			; If not, branch

	move.b	oRender(a0),d0			; Is this object to be drawn relative to a camera?
	move.b	d0,d4
	andi.w	#$C,d0
	beq.w	.ScreenPos			; If not, branch

	movea.l	ObjDrawCameras(pc,d0.w),a1	; Get camera that the object is relative to

	moveq	#0,d0				; Get object's X position onscreen
	move.b	oWidth(a0),d0
	move.w	oX(a0),d3
	sub.w	(a1),d3
	addi.w	#128,d3

	moveq	#0,d0				; Get object's Y position
	move.b	oYRadius(a0),d0
	move.w	oY(a0),d2
	cmpi.w	#$100,4(a1)			; Is the camera near the top of the level?
	bcc.s	.ChkBottomWrap			; If not, branch
	cmpi.w	#$800,d2			; Is this object near the bottom of the level?
	bcs.s	.EndWrap			; If not, branch
	subi.w	#$800,d2			; Wrap the object to the top of the screen
	bra.s	.EndWrap

.ChkBottomWrap:
	cmpi.w	#$700,4(a1)			; Is the camera near the bottom of the level?
	bcs.s	.EndWrap			; If not, branch
	cmpi.w	#$100,d2			; Is this object near the top of the level?
	bcc.s	.EndWrap			; If not, branch
	addi.w	#$800,d2			; Wrap the object to the bottom of the screen

.EndWrap:
	sub.w	4(a1),d2			; Get object's Y position onscreen
	addi.w	#128,d2
	bra.s	.DrawSprite

.ScreenPos:
	move.w	oYScr(a0),d2			; The object's position is an absolute screen position
	move.w	oX(a0),d3
	bra.s	.DrawSprite

; -------------------------------------------------------------------------
; Dead code. It's a leftover from Sonic 1, in which if bit 4 of the object's
; render flags is clear, it ignores the object's Y radius for its Y position
; onscreen check. However, since DrawObject handles the onscreen check now, this
; is left unused.
; -------------------------------------------------------------------------


.NoYRadChk:
	move.w	oY(a0),d2			; Get object's Y position onscreen
	sub.w	4(a1),d2
	addi.w	#128,d2
	cmpi.w	#0-32+128,d2			; Is it onscreen?
	bcs.s	.NextObj			; If not, branch
	cmpi.w	#224+32+128,d2
	bcc.s	.NextObj			; If not, branch

; -------------------------------------------------------------------------

.DrawSprite:
	movea.l	oMap(a0),a1			; Get object mappings
	moveq	#0,d1
	btst	#5,d4				; Is the pointer to the mappings a pointer to static mappings data?
	bne.s	.StaticMap			; If so, branch

	move.b	oMapFrame(a0),d1		; Get pointer to the object's frame mappings
	add.w	d1,d1
	adda.w	(a1,d1.w),a1

	moveq	#0,d1				; Get number of pieces to draw
	move.b	(a1)+,d1
	subq.b	#1,d1
	bmi.s	.DrawDone			; If there are no pieces to draw, branch

.StaticMap:
	bsr.w	DrawSprite			; Draw the sprite

.DrawDone:
	bset	#7,oRender(a0)			; Mark the object as onscreen

.NextObj:
	addq.w	#2,d6				; Next entry in the draw queue
	subq.w	#2,(a4)				; Decrement queue entry count
	bne.w	.ObjLoop			; If we haven't run out, branch

.NextLevel:
	lea	$80(a4),a4			; Next priority level draw queue
	dbf	d7,.LevelLoop			; Loop until all the priority levels have been gone through

	move.b	d5,spriteCount.w		; Save sprite count
	cmpi.b	#80,d5				; Is the sprite table full?
	beq.s	.TableFull			; If so, branch

	move.l	#0,(a2)				; Mark the current sprite table entry as the last
	rts

.TableFull:
	move.b	#0,-5(a2)			; Mark the last sprite table entry as the last
	rts

; -------------------------------------------------------------------------
; Draw a sprite from mappings data
; -------------------------------------------------------------------------
; PARAMETERS:
;	d1.w - Sprite piece count
;	d2.w - Y position
;	d3.w - X position
;	d4.b - Render flags
;	d5.b - Previous sprite link value
;	a0.l - Object RAM
;	a1.l - Sprite mappings data pointer
;	a2.l - Sprite table buffer pointer
; -------------------------------------------------------------------------

DrawSprite:
	movea.w	oTile(a0),a3			; Get base tile

	btst	#0,d4				; Is the sprite flipped horizontally?
	bne.s	DrawSprite_FlipX		; If so, branch
	btst	#1,d4				; Is the sprite flipped vertically?
	bne.w	DrawSprite_FlipY		; If so, branch

.Loop:
	cmpi.b	#80,d5				; Is the sprite table full?
	beq.s	.End				; If so, branch

	move.b	(a1)+,d0			; Set Y position
	ext.w	d0
	add.w	d2,d0
	move.w	d0,(a2)+

	move.b	(a1)+,(a2)+			; Set sprite size

	addq.b	#1,d5				; Set sprite link
	move.b	d5,(a2)+

	move.b	(a1)+,d0			; Set sprite tile
	lsl.w	#8,d0
	move.b	(a1)+,d0
	add.w	a3,d0
	move.w	d0,(a2)+

	move.b	(a1)+,d0			; Set X position
	ext.w	d0
	add.w	d3,d0
	andi.w	#$1FF,d0
	bne.s	.SetX
	addq.w	#1,d0

.SetX:
	move.w	d0,(a2)+

	dbf	d1,.Loop			; Loop until all pieces are drawn

.End:
	rts

; -------------------------------------------------------------------------

DrawSprite_FlipX:
	btst	#1,d4				; Is the sprite flipped vertically?
	bne.w	DrawSprite_FlipXY

.Loop:
	cmpi.b	#80,d5				; Is the sprite table full?
	beq.s	.End				; If so, branch

	move.b	(a1)+,d0			; Set Y position
	ext.w	d0
	add.w	d2,d0
	move.w	d0,(a2)+

	move.b	(a1)+,d4			; Set sprite size
	move.b	d4,(a2)+

	addq.b	#1,d5				; Set sprite link
	move.b	d5,(a2)+

	move.b	(a1)+,d0			; Set sprite tile
	lsl.w	#8,d0
	move.b	(a1)+,d0
	add.w	a3,d0
	eori.w	#$800,d0
	move.w	d0,(a2)+

	move.b	(a1)+,d0			; Set X position
	ext.w	d0
	neg.w	d0
	add.b	d4,d4
	andi.w	#$18,d4
	addq.w	#8,d4
	sub.w	d4,d0
	add.w	d3,d0
	andi.w	#$1FF,d0
	bne.s	.SetX
	addq.w	#1,d0

.SetX:
	move.w	d0,(a2)+

	dbf	d1,.Loop			; Loop until all pieces are drawn

.End:
	rts

; -------------------------------------------------------------------------

DrawSprite_FlipY:
.Loop:
	cmpi.b	#80,d5				; Is the sprite table full?
	beq.s	.End				; If so, branch

	move.b	(a1)+,d0			; Set Y position
	move.b	(a1),d4
	ext.w	d0
	neg.w	d0
	lsl.b	#3,d4
	andi.w	#$18,d4
	addq.w	#8,d4
	sub.w	d4,d0
	add.w	d2,d0
	move.w	d0,(a2)+

	move.b	(a1)+,(a2)+			; Set sprite size

	addq.b	#1,d5				; Set sprite link
	move.b	d5,(a2)+

	move.b	(a1)+,d0			; Set sprite tile
	lsl.w	#8,d0
	move.b	(a1)+,d0
	add.w	a3,d0
	eori.w	#$1000,d0
	move.w	d0,(a2)+

	move.b	(a1)+,d0			; Set X position
	ext.w	d0
	add.w	d3,d0
	andi.w	#$1FF,d0
	bne.s	.SetX
	addq.w	#1,d0

.SetX:
	move.w	d0,(a2)+

	dbf	d1,.Loop			; Loop until all pieces are drawn

.End:
	rts

; -------------------------------------------------------------------------

DrawSprite_FlipXY:
.Loop:
	cmpi.b	#80,d5				; Is the sprite table full?
	beq.s	.End				; If so, branch

	move.b	(a1)+,d0			; Set Y position
	move.b	(a1),d4
	ext.w	d0
	neg.w	d0
	lsl.b	#3,d4
	andi.w	#$18,d4
	addq.w	#8,d4
	sub.w	d4,d0
	add.w	d2,d0
	move.w	d0,(a2)+

	move.b	(a1)+,d4			; Set sprite size
	move.b	d4,(a2)+

	addq.b	#1,d5				; Set sprite link
	move.b	d5,(a2)+

	move.b	(a1)+,d0			; Set sprite tile
	lsl.w	#8,d0
	move.b	(a1)+,d0
	add.w	a3,d0
	eori.w	#$1800,d0
	move.w	d0,(a2)+

	move.b	(a1)+,d0			; Set X position
	ext.w	d0
	neg.w	d0
	add.b	d4,d4
	andi.w	#$18,d4
	addq.w	#8,d4
	sub.w	d4,d0
	add.w	d3,d0
	andi.w	#$1FF,d0
	bne.s	.SetX
	addq.w	#1,d0

.SetX:
	move.w	d0,(a2)+

	dbf	d1,.Loop			; Loop until all pieces are drawn

.End:
	rts

; -------------------------------------------------------------------------
; Check if an object is onscreen
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Object RAM
; -------------------------------------------------------------------------

ChkObjOnScreen:
	move.w	oX(a0),d0			; Is the object onscreen horizontally?
	sub.w	cameraX.w,d0
	bmi.s	.OffScreen			; If not, branch
	cmpi.w	#320,d0
	bge.s	.OffScreen			; If not, branch

	move.w	oY(a0),d1			; Is the object onscreen vertically?
	sub.w	cameraY.w,d1
	bmi.s	.OffScreen			; If not, branch
	cmpi.w	#224,d1
	bge.s	.OffScreen			; If not, branch

	moveq	#0,d0				; Mark as onscreen
	rts

.OffScreen:
	moveq	#1,d0				; Mark as offscreen
	rts

; -------------------------------------------------------------------------

ChkObjOnScrWidth:
	moveq	#0,d1				; Is the object onscreen horizontally?
	move.b	oWidth(a0),d1
	move.w	oX(a0),d0
	sub.w	cameraX.w,d0
	add.w	d1,d0
	bmi.s	.OffScreen			; If not, branch
	add.w	d1,d1
	sub.w	d1,d0
	cmpi.w	#320,d0
	bge.s	.OffScreen			; If not, branch

	move.w	oY(a0),d1			; Is the object onscreen vertically?
	sub.w	cameraY.w,d1
	bmi.s	.OffScreen			; If not, branch
	cmpi.w	#224,d1
	bge.s	.OffScreen			; If not, branch

	moveq	#0,d0				; Mark as onscreen
	rts

.OffScreen:
	moveq	#1,d0				; Mark as offscreen
	rts

; -------------------------------------------------------------------------
; Object index
; -------------------------------------------------------------------------

ObjectIndex:
	dc.l	ObjSonic			; 01 - Sonic
	dc.l	ObjSonic			; 02 - Player 2 Sonic
	dc.l	ObjPowerup			; 03 - Power up
	dc.l	ObjWaterfall			; 04 - Unused (broken) waterfall generator
	dc.l	ObjNull5			; 05 - Blank
	dc.l	ObjUnusedBadnik			; 06 - Unused badnik
	dc.l	ObjSpinTunnel			; 07 - Spin tunnel
	dc.l	ObjNull8			; 08 - Blank
	dc.l	ObjRotPlatform			; 09 - Rotating platform
	dc.l	ObjSpring			; 0A - Spring
	dc.l	ObjWaterSplash			; 0B - Water splash
	dc.l	ObjUnkC				; 0C - Unknown
	dc.l	ObjFlapDoorH			; 0D - Horizontal flap door
	dc.l	ObjWaterfallSplash		; 0E - Waterfall splash
	dc.l	ObjMovingSpring			; 0F - Moving spring
	dc.l	ObjRing				; 10 - Ring
	dc.l	ObjLostRing			; 11 - Lost ring
	dc.l	ObjSmallPlatform		; 12 - Small platform
	dc.l	ObjCheckpoint			; 13 - Checkpoint
	dc.l	ObjBigRing			; 14 - Big ring
	dc.l	ObjCapsule			; 15 - Flower capsule
	dc.l	ObjGoalPost			; 16 - Goal post
	dc.l	ObjSignpost			; 17 - Signpost
	dc.l	ObjExplosion			; 18 - Explosion
	dc.l	ObjMonitor_Timepost		; 19 - Monitor/Time post
	dc.l	ObjMonitorContents		; 1A - Monitor contents
	dc.l	ObjGrayRock			; 1B - Gray rock
	dc.l	ObjHUD_Points			; 1C - HUD/Points
	dc.l	ObjDelete			; 1D - Blank
	dc.l	ObjDelete			; 1E - Blank (CCZ flipper)
	dc.l	ObjFlower			; 1F - Flower
	dc.l	ObjCollapsePlatform		; 20 - Collaping platform
	dc.l	ObjPlatform			; 21 - Platform
	dc.l	ObjTamabboh			; 22 - Tamabboh badnik/projectiles
	dc.l	ObjNull23			; 23 - Blank
	dc.l	ObjAnimal			; 24 - Animal
	dc.l	ObjDelete			; 25 - Blank
	dc.l	ObjSpikes			; 26 - Spikes
	dc.l	ObjDelete			; 27 - Blank
	dc.l	ObjSpringBoard			; 28 - Springboard
	dc.l	ObjDelete			; 29 - Blank
	dc.l	Obj3DRamp			; 2A - 3D ramp marker
	dc.l	ObjDelete			; 2B - Blank
	dc.l	Obj3DPlant			; 2C - Plant surrounding 3D ramp
	dc.l	ObjRobotGenerator		; 2D - Robot generator
	dc.l	ObjProjector			; 2E - Metal Sonic holographic projector
	dc.l	ObjAmyRose			; 2F - Amy Rose
	dc.l	ObjAmyHeart			; 30 - Amy Rose heart
	dc.l	ObjSonicHole			; 31 - Sonic hole
	dc.l	ObjDelete			; 32 - Blank
	dc.l	ObjHollowLogBG			; 33 - Hollow log background
	dc.l	ObjForceSpin			; 34 - Force spin marker
	dc.l	ObjFlapDoorV			; 35 - Vertical flap door
	dc.l	ObjBreakableWall		; 36 - Breakable wall
	dc.l	ObjDelete			; 37 - Blank
	dc.l	ObjDelete			; 38 - Blank
	dc.l	ObjDelete			; 39 - Blank
	dc.l	ObjResults			; 3A - End of level results
	dc.l	ObjGameOver			; 3B - Game over text
	dc.l	ObjTitleCard			; 3C - Title card
	dc.l	ObjMosqui			; 3D - Mosqui badnik
	dc.l	ObjPataBata			; 3E - Pata-Bata badnik
	dc.l	ObjAnton			; 3F - Anton badnik
	dc.l	ObjTagaTaga			; 40 - Taga-Taga badnik

; -------------------------------------------------------------------------
; An object that deletes itself
; -------------------------------------------------------------------------

ObjDelete:
	move.b	#0,(a0)
	rts

; -------------------------------------------------------------------------
; Sonic object
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Check to see if Sonic should give up from boredom
; -------------------------------------------------------------------------

ObjSonic_ChkBoredom:
	lea	boredTimer.w,a1			; Get boredom timer

	cmpi.b	#5,oAnim(a0)			; Is the player idle?
	beq.s	.WaitAnim			; If so, branch

	move.w	#0,(a1)				; Reset the boredom timer
	rts

.WaitAnim:
	tst.w	(a1)				; Is the timer active?
	bne.s	.TimerGoing			; If so, branch
	move.b	#1,1(a1)			; Make the timer active

.TimerGoing:
	cmpi.w	#3*60*60,(a1)			; Have 3 minutes passed?
	bcs.s	.End				; If not, branch

	move.w	#0,(a1)				; Stop the timer

	move.b	#$2B,oAnim(a0)			; Set the player's animation accordingly
	ori.b	#$80,oTile(a0)
	move.b	#0,oPriority(a0)

	move.b	#1,lifeCount			; Make it so a game over happens

	move.w	#-$500,oYVel(a0)		; Make the player jump
	move.w	#$100,oXVel(a0)
	btst	#0,oStatus(a0)
	beq.s	.GotXVel
	neg.w	oXVel(a0)

.GotXVel:
	move.w	#0,oPlayerGVel(a0)

	move.w	#$79,d0				; Play "I'm outta here" sound
	bra.w	SubCPUCmd

.End:
	rts

; -------------------------------------------------------------------------
; Main Sonic object code
; -------------------------------------------------------------------------

ObjSonic:
	tst.b	timeAttackMode			; Are we in time attack mode?
	bne.s	.NormalMode			; If so, branch
	cmpa.w	#objPlayerSlot2,a0		; Are we the second player?
	beq.s	.NormalMode			; If so, branch
	tst.b	lvlDebugMode			; Are we in debug mode?
	beq.s	.NormalMode			; If not, branch
	jmp	DebugMode			; Handle debug mode

.NormalMode:
	move.b	oPlayerCharge(a0),d0		; Get charge time
	beq.s	.RunRoutines			; If it's 0, branch
	addq.b	#1,d0				; Increment the charge time
	btst	#2,oStatus(a0)			; Are we spindashing?
	beq.s	.Peelout			; If not, branch
	cmpi.b	#45,d0				; Is the spindash fully charged?
	bcs.s	.SetChargeTimer			; If not, branch
	move.b	#45,d0				; Cap the charge time
	bra.s	.SetChargeTimer

.Peelout:
	cmpi.b	#30,d0				; Is the peelout fully charged?
	bcs.s	.SetChargeTimer			; If not, branch
	move.b	#30,d0				; Cap the charge time

.SetChargeTimer:
	move.b	d0,oPlayerCharge(a0)		; Update the charge time

.RunRoutines:
	moveq	#0,d0				; Run object routine
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d1
	jmp	.Index(pc,d1.w)

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjSonic_Init-.Index		; Initialization
	dc.w	ObjSonic_Main-.Index		; Main
	dc.w	ObjSonic_Hurt-.Index		; Hurt
	dc.w	ObjSonic_Dead-.Index		; Death
	dc.w	ObjSonic_Restart-.Index		; Death delay and level restart

; -------------------------------------------------------------------------
; Create time warp stars
; -------------------------------------------------------------------------

ObjSonic_MakeTimeWarpStars:
	tst.b	objTimeStar1Slot.w		; Are they already loaded?
	bne.s	.End				; If so, branch

	move.b	#1,timeWarpFlag			; Set time warp flag

	move.b	#3,objTimeStar1Slot.w		; Load time warp stars
	move.b	#5,objTimeStar1Slot+oAnim.w
	move.b	#3,objTimeStar2Slot.w
	move.b	#6,objTimeStar2Slot+oAnim.w
	move.b	#3,objTimeStar3Slot.w
	move.b	#7,objTimeStar3Slot+oAnim.w
	move.b	#3,objTimeStar4Slot.w
	move.b	#8,objTimeStar4Slot+oAnim.w

.End:
	rts
	rts

; -------------------------------------------------------------------------
; Sonic's initialization routine
; -------------------------------------------------------------------------

ObjSonic_Init:
	addq.b	#2,oRoutine(a0)			; Advance routine

	move.b	#$13,oYRadius(a0)		; Default hitbox size
	move.b	#9,oXRadius(a0)
	tst.b	miniSonic			; Are we miniature?
	beq.s	.NotMini			; If not, branch
	move.b	#$A,oYRadius(a0)		; Mini hitbox size
	move.b	#5,oXRadius(a0)

.NotMini:
	move.l	#MapSpr_Sonic,oMap(a0)		; Set mappings
	move.w	#$780,oTile(a0)			; Set base tile
	move.b	#2,oPriority(a0)		; Set priority
	move.b	#$18,oWidth(a0)			; Set width
	move.b	#4,oRender(a0)			; Set render flags

	move.w	#$600,sonicTopSpeed.w		; Set physics values
	move.w	#$C,sonicAcceleration.w
	move.w	#$80,sonicDeceleration.w
	rts

; -------------------------------------------------------------------------
; Create waterfall splashes
; -------------------------------------------------------------------------

ObjSonic_MakeWaterfallSplash:
	tst.b	levelZone			; Are we in Palmtree Panic zone?
	bne.s	.End				; If not, branch

	move.b	lvlFrameTimer+1,d0		; Are we on an odd numbered frame?
	andi.b	#1,d0
	bne.s	.End				; If so, branch

	move.b	oYRadius(a0),d2			; Are we behind a waterfall?
	ext.w	d2
	add.w	oY(a0),d2
	move.w	oX(a0),d3
	bsr.w	ObjSonic_GetChunkAtPos
	cmpi.b	#$2F,d1
	bne.s	.End2				; If not, branch

	cmpi.w	#$15C0,oX(a0)			; Are we too far into the level?
	bcc.s	.End				; If so, branch
	tst.b	oPlayerCtrl(a0)			; Are we in a spin tunnel?
	beq.s	.End				; If not, branch

	jsr	FindObjSlot			; Create a waterfall splash at our position
	bne.s	.End
	move.b	#$E,oID(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)

	moveq	#1,d0				; Set splash direction
	tst.w	oXVel(a0)
	bmi.s	.SetFlip
	moveq	#0,d0

.SetFlip:
	move.b	d0,oRender(a1)
	move.b	d0,oStatus(a1)

.End:
	rts

.End2:
	rts

; -------------------------------------------------------------------------
; Get the chunk at a specific position
; -------------------------------------------------------------------------
; PARAMETERS:
;	d2.w - Y position
;	d3.w - X position
; RETURNS:
;	d1.b - Chunk ID
; -------------------------------------------------------------------------

ObjSonic_GetChunkAtPos:
	move.w	d2,d0				; Get the chunk at the given position
	lsr.w	#1,d0
	andi.w	#$380,d0
	move.w	d3,d1
	lsr.w	#8,d1
	andi.w	#$7F,d1
	add.w	d1,d0
	move.l	#LevelChunks,d1
	lea	levelLayout.w,a1
	move.b	(a1,d0.w),d1
	andi.b	#$7F,d1
	rts

; -------------------------------------------------------------------------
; Handle the extended camera
; -------------------------------------------------------------------------

ObjSonic_ExtCamera:
	move.w	camXCenter.w,d1			; Get camera X center position

	move.w	oPlayerGVel(a0),d0		; Get how fast we are moving
	bpl.s	.PosInertia
	neg.w	d0

.PosInertia:
	btst	#1,oPlayerCtrl(a0)		; Are we on a 3D ramp?
	beq.s	.No3DRamp			; If not, branch
	cmpi.w	#$1B00,oX(a0)			; Are we on the 3D ramp at the start of the level?
	bcs.s	.ResetPan			; If so, branch

.No3DRamp:
	cmpi.w	#$600,d0			; Are we going at max regular speed?
	bcs.s	.ResetPan			; If not, branch

	tst.w	oPlayerGVel(a0)			; Are we moving right?
	bpl.s	.MovingRight			; If so, branch

.MovingLeft:
	addq.w	#2,d1				; Pan the camera to the right
	cmpi.w	#(320/2)+64,d1			; Has it panned far enough?
	bcs.s	.SetPanVal			; If not, branch
	move.w	#(320/2)+64,d1			; Cap the camera's position
	bra.s	.SetPanVal

.MovingRight:
	subq.w	#2,d1				; Pan the camera to the left
	cmpi.w	#(320/2)-64,d1			; Has it panned far enough
	bcc.s	.SetPanVal			; If not, branch
	move.w	#(320/2)-64,d1			; Cap the camera's position
	bra.s	.SetPanVal

.ResetPan:
	cmpi.w	#320/2,d1			; Has the camera panned back to the middle?
	beq.s	.SetPanVal			; If so, branch
	bcc.s	.ResetLeft			; If it's panning back left

.ResetRight:
	addq.w	#2,d1				; Pan back to the right
	bra.s	.SetPanVal

.ResetLeft:
	subq.w	#2,d1				; Pan back to the left

.SetPanVal:
	move.w	d1,camXCenter.w			; Update camera X center position
	rts

; -------------------------------------------------------------------------
; Sonic's main routine
; -------------------------------------------------------------------------

ObjSonic_Main:
	bsr.s	ObjSonic_ExtCamera		; Handle extended camera
	bsr.w	ObjSonic_MakeWaterfallSplash	; Handle waterfall splash creation

	tst.w	debugCheat			; Is debug mode enabled?
	beq.s	.NoDebug			; If not, branch
	btst	#4,p1CtrlTap.w			; Was the B button pressed?
	beq.s	.NoDebug			; If not, branch
	move.b	#1,lvlDebugMode			; Enter debug mode
	rts

.NoDebug:
	tst.b	ctrlLocked.w			; Are controls locked?
	bne.s	.CtrlLock			; If so, branch
	move.w	p1CtrlData.w,playerCtrl.w	; Copy controller data

.CtrlLock:
	btst	#0,oPlayerCtrl(a0)		; Are we being controlled by another object?
	beq.s	.NormalCtrl			; If not, branch
	cmpi.b	#6,levelZone			; Are we in Metallic Madness?
	bne.s	.NotMMZ				; If not, branch

	clr.w	timeWarpTimer.w			; Disable time warping
	clr.b	timeWarpFlag
	bra.s	.SkipControl


.NotMMZ:
	bsr.w	ObjSonic_TimeWarp		; Handle time warping
	bra.s	.SkipControl

.NormalCtrl:
	moveq	#0,d0				; Run player mode routine
	move.b	oStatus(a0),d0
	andi.w	#6,d0
	move.w	ObjSonic_ModeIndex(pc,d0.w),d1
	jsr	ObjSonic_ModeIndex(pc,d1.w)

	jsr	ObjSonic_Null			; Some kind of nulled out function

.SkipControl:
	bsr.s	ObjSonic_Display		; Draw sprite and handle timers
	bsr.w	ObjSonic_RecordPos		; Save current position into the position buffer
	bsr.w	ObjSonic_Water			; Handle water

						; Update our angle buffers
	move.b	primaryAngle.w,oPlayerPriAngle(a0)
	move.b	secondaryAngle.w,oPlayerSecAngle(a0)

	tst.b	windTunnelFlag.w		; Are we in a wind tunnel?
	beq.s	.NoWindTunnel			; If not, branch
	tst.b	oAnim(a0)			; Are we in the walking animation?
	bne.s	.NoWindTunnel			; If not, branch
	move.b	oPrevAnim(a0),oAnim(a0)		; Set animation to the previously saved animation ID

.NoWindTunnel:
	bsr.w	ObjSonic_Animate		; Animate sprite

	tst.b	oPlayerCtrl(a0)			; Has object collision been disabled?
	bmi.s	.NoObjCol			; If so, branch
	cmpi.b	#$2B,oAnim(a0)			; Are we giving up from boredom?
	beq.s	.NoObjCol			; If so, branch

	jsr	Player_ObjCollide		; Handle object collision

.NoObjCol:
	bsr.w	ObjSonic_SpecialChunks		; Handle special chunks
	rts

; -------------------------------------------------------------------------

ObjSonic_ModeIndex:
	dc.w	ObjSonic_MdGround-ObjSonic_ModeIndex
	dc.w	ObjSonic_MdAir-ObjSonic_ModeIndex
	dc.w	ObjSonic_MdRoll-ObjSonic_ModeIndex
	dc.w	ObjSonic_MdJump-ObjSonic_ModeIndex

; -------------------------------------------------------------------------
; Leftover music ID list from Sonic 1
; -------------------------------------------------------------------------

LevelMusicIDs2_S1:
	dc.b	$81, $82, $83, $84, $85, $86
	even

; -------------------------------------------------------------------------
; Display Sonic's sprite and update timers
; -------------------------------------------------------------------------

ObjSonic_Display:
	cmpi.w	#210,timeWarpTimer.w		; Are we about to time travel?
	bcc.s	.SkipDisplay			; If so, branch

	move.w	oPlayerHurt(a0),d0		; Get current hurt time
	beq.s	.NotFlashing			; If we are not hurting, branch
	subq.w	#1,oPlayerHurt(a0)		; Decrement hurt time
	lsr.w	#3,d0				; Should we flash our sprite?
	bcc.s	.SkipDisplay			; If so, branch

.NotFlashing:
	btst	#6,oPlayerCtrl(a0)		; Is our sprite disabled?
	bne.s	.SkipDisplay			; If so, branch
	jsr	DrawObject			; Draw sprite

.SkipDisplay:
	tst.b	invincibleFlag			; Are we invincible?
	beq.s	.NotInvincible			; If not, branch
	tst.w	oPlayerInvinc(a0)		; Is the invincibility timer active?
	beq.s	.NotInvincible			; If not, branch

	subq.w	#1,oPlayerInvinc(a0)		; Decrement invincibility time
	bne.s	.NotInvincible			; If it hasn't run out, branch

	tst.b	speedShoesFlag			; Is the speed shoes music playing?
	bne.s	.StopInvinc			; If so, branch
	tst.b	bossMusicPlaying		; Is the boss music playing?
	bne.s	.StopInvinc			; If so, branch
	tst.b	timeZone			; Are we in the past?
	bne.s	.NotPast			; If not, branch
	move.w	#$E,d0				; Fade out music
	jsr	SubCPUCmd

.NotPast:
	jsr	PlayLevelMusic			; Play level music

.StopInvinc:
	move.b	#0,invincibleFlag		; Stop invincibility

.NotInvincible:
	tst.b	speedShoesFlag			; Do we have speed shoes?
	beq.s	.End				; If not, branch
	tst.w	oPlayerShoes(a0)		; Is the speed shoes timer active?
	beq.s	.End				; If not, branch

	subq.w	#1,oPlayerShoes(a0)		; Decrement speed shoes time
	bne.s	.End				; If it hasn't run out, branch

	move.w	#$600,sonicTopSpeed.w		; Return physics back to normal
	move.w	#$C,sonicAcceleration.w
	move.w	#$80,sonicDeceleration.w

	tst.b	invincibleFlag			; Is the invincibility music playing?
	bne.s	.StopSpeedShoes			; If so, branch
	tst.b	bossMusicPlaying		; Is the boss music playing?
	bne.s	.StopSpeedShoes			; If so, branch
	tst.b	timeZone			; Are we in the past?
	bne.s	.NotPast2			; If not, branch
	move.w	#$E,d0				; Fade out music
	jsr	SubCPUCmd

.NotPast2:
	jsr	PlayLevelMusic			; Play level music

.StopSpeedShoes:
	move.b	#0,speedShoesFlag		; Stop speed shoes

.End:
	rts

; -------------------------------------------------------------------------
; Save Sonic's current position into the position buffer
; -------------------------------------------------------------------------

ObjSonic_RecordPos:
	move.w	sonicRecordIndex.w,d0		; Get pointer to current position buffer index
	lea	sonicRecordBuf.w,a1
	lea	(a1,d0.w),a1

	move.w	oX(a0),(a1)+			; Save our position
	move.w	oY(a0),(a1)+

	addq.b	#4,sonicRecordIndex+1.w		; Advance position buffer index
	rts

; -------------------------------------------------------------------------
; Handle Sonic underwater
; -------------------------------------------------------------------------

ObjSonic_Water:
	cmpi.b	#2,levelZone			; Are we in Tidal Tempest?
	beq.s	.HasWater			; If so, branch

.End:
	rts

.HasWater:
	cmpi.b	#1,levelAct			; Are we in act 2 of Tidal Tempest?
	bne.s	.NotAct2			; If not, branch
	cmpi.w	#$C8,oX(a0)			; Are we in the wrapping section?
	bcs.s	.End				; If so, branch

.NotAct2:
	move.w	waterHeight.w,d0		; Are we in the water?
	cmp.w	oY(a0),d0
	bge.s	.OutWater			; If not, branch

	bset	#6,oStatus(a0)			; Mark as underwater
	bne.s	.End				; If we were already marked as such, branch

	bsr.w	ResumeMusicS1			; In Sonic 1, this routine would resume the background music from the drowning music

	move.b	#$21,objBubblesSlot.w		; Create bubbles that come out of our mouth
	move.b	#$81,objBubblesSlot+oSubtype.w

	move.w	#$300,sonicTopSpeed.w		; Set to water physics
	move.w	#6,sonicAcceleration.w
	move.w	#$40,sonicDeceleration.w

	asr	oXVel(a0)			; Slow ourselves down in the water
	asr	oYVel(a0)
	asr	oYVel(a0)
	beq.s	.End				; If we entered the water slowly, branch
	bra.s	.LoadSplash			; Go create a water splash

; -------------------------------------------------------------------------

.OutWater:
	tst.w	oYVel(a0)			; Are we moving vertically?
	beq.s	.LeaveWater			; If not, branch
	bpl.s	.End				; If we are moving downwards, branch

.LeaveWater:
	bclr	#6,oStatus(a0)			; Mark as not underwater
	beq.s	.End				; If we were already marked as such, branch

	move.w	#$600,sonicTopSpeed.w		; Return physics back to normal
	move.w	#$C,sonicAcceleration.w
	move.w	#$80,sonicDeceleration.w

	asl	oYVel(a0)			; Accelerate ourselves out of the water
	beq.w	.End				; If we are still moving up too slowly, branch
	cmpi.w	#-$1000,oYVel(a0)		; Are we moving up too fast?
	bgt.s	.LoadSplash			; If not, branch
	move.w	#-$1000,oYVel(a0)		; Cap our speed

.LoadSplash:
	jsr	FindObjSlot			; Create a water splash at our position
	bne.s	.End2
	move.b	#$B,oID(a1)
	move.w	oX(a0),oX(a1)

.End2:
	rts

; -------------------------------------------------------------------------
; Save various variables for time travel
; -------------------------------------------------------------------------

TimeTravel_SaveData:				; Save some values
	move.b	resetLevelFlags,travelResetLvlFlags
	move.w	oX(a0),travelX
	move.w	oY(a0),travelY
	move.w	oPlayerGVel(a0),travelGVel
	move.w	oXVel(a0),travelXVel
	move.w	oYVel(a0),travelYVel
	move.b	oStatus(a0),travelStatus
	bclr	#3,travelStatus			; Don't be marked as standing on an object
	bclr	#6,travelStatus			; Don't be marked as being underwater
	move.b	waterRoutine.w,travelWaterRout
	move.w	bottomBound.w,travelBtmBound
	move.w	cameraX.w,travelCamX
	move.w	cameraY.w,travelCamY
	move.w	cameraBgX.w,travelCamBgX
	move.w	cameraBgY.w,travelCamBgY
	move.w	cameraBg2X.w,travelCamBg2X
	move.w	cameraBg2Y.w,travelCamBg2Y
	move.w	cameraBg3X.w,travelCamBg3X
	move.w	cameraBg3Y.w,travelCamBg3Y
	move.w	waterHeight2.w,travelWaterHeight
	move.b	waterRoutine.w,travelWaterRout
	move.b	waterFullscreen.w,travelWaterFull
	move.w	levelRings,travelRingCnt
	move.b	lifeFlags,travelLifeFlags

	move.l	levelTime,d0			; Move the level timer to 5:00 if we are past that
	cmpi.l	#$50000,d0
	bcs.s	.CapTime
	move.l	#$50000,d0

.CapTime:
	move.l	d0,travelTime

	move.b	miniSonic,travelMiniSonic
	rts

; -------------------------------------------------------------------------
; Handle time warping for Sonic
; -------------------------------------------------------------------------

ObjSonic_TimeWarp:
	cmpi.w	#0,levelZone			; Are we in Palmtree Panic act 1?
	bne.s	.NotPPZ1			; If not, branch
	tst.b	timeZone			; Are we in the past?
	beq.s	.Past				; If so, branch
	cmpi.b	#2,timeZone			; Are we in the future?
	bne.s	.NotPPZ1			; If not, branch

.Past:
	cmpi.w	#$900,oX(a0)			; Are we in the first 3D ramp section?
	bcs.w	.StopTimeWarp			; If so, branch

.NotPPZ1:
	tst.b	oPlayerCharge(a0)		; Are we charging a peelout or spindash?
	bne.w	.End2				; If so, branch
	tst.b	timeWarpDir.w			; Have we touched a time post?
	beq.w	.End2				; If not, branch

	move.w	#$600,d2			; Minimum speed in which to keep the time warp going

	moveq	#0,d0				; Get current ground velocity
	move.w	oPlayerGVel(a0),d0
	bpl.s	.PosInertia
	neg.w	d0

.PosInertia:
	tst.w	timeWarpTimer.w			; Is the time warp timer active?
	bne.s	.TimerGoing			; If so, branch
	move.w	#1,timeWarpTimer.w		; Make the time warp timer active

.TimerGoing:
	move.w	timeWarpTimer.w,d1		; Get current time warp time
	cmpi.w	#230,d1				; Should we time travel now?
	bcs.s	.KeepGoing			; If not, branch

	move.b	#1,levelRestart			; Set to go to the time travel cutscene
	bra.w	FadeOutMusic

.KeepGoing:
	cmpi.w	#210,d1				; Are we about to time travel soon?
	bcs.s	.CheckStars			; If not, branch

	cmpi.b	#2,resetLevelFlags		; Are we already in the process of time travelling?
	beq.s	.End				; If so, branch

	move.b	#1,scrollLock.w			; Lock the screen in place

	move.b	timeZone,d0			; Get current time zone
	bne.s	.GetNewTime			; If we are not in the past, branch

	move.w	#$82,d0				; Fade out music
	jsr	SubCPUCmd

	moveq	#0,d0				; We are currently in the past

.GetNewTime:
	add.b	timeWarpDir.w,d0		; Set the new time period
	bpl.s	.NoUnderflow			; If we aren't trying to go past the past, branch
	moveq	#0,d0				; Stay in this game's "past" time period
	bra.s	.GotNewTime

.NoUnderflow:
	cmpi.b	#3,d0				; Are we trying to go forward past the future?
	bcs.s	.GotNewTime			; If not, branch
	moveq	#2,d0				; Stay in this game's "future" time period

.GotNewTime:
	bset	#7,d0				; Mark time travel as active
	move.b	d0,timeZone

	bsr.w	TimeTravel_SaveData		; Save time travel data

	move.b	#2,resetLevelFlags		; Mark that we are now in the process of time travelling

.End:
	rts

.CheckStars:
	cmpi.w	#90,d1				; Have we tried time travelling for a bit already?
	bcc.s	.CheckStop			; If so, branch

	cmp.w	d2,d0				; Are we going fast enough?
	bcc.w	ObjSonic_MakeTimeWarpStars	; If so, branch
	clr.w	timeWarpTimer.w			; If not, reset time warping until we go fast again
	clr.b	timeWarpFlag
	rts

.CheckStop:
	cmp.w	d2,d0				; Are we going fast enough?
	bcc.s	.End2				; If so, branch

.StopTimeWarp:
	clr.w	timeWarpTimer.w			; Disable time warping until the next time post is touched
	clr.b	timeWarpDir.w
	clr.b	timeWarpFlag

.End2:
	rts

; -------------------------------------------------------------------------
; Sonic's ground mode routine
; -------------------------------------------------------------------------

ObjSonic_MdGround:
	bsr.w	ObjSonic_ChkBoredom		; Check boredom timer

	cmpi.b	#$2B,oAnim(a0)			; Are we giving up from boredom?
	bne.s	.NotGivingUp			; If not, branch
	tst.b	miniSonic			; Are we miniature?
	beq.s	.NotMini			; If not, branch
	cmpi.b	#$79,oMapFrame(a0)		; Are we jumping?
	bne.s	.End				; If not, branch
	bra.s	.GivingUp

.NotMini:
	cmpi.b	#$17,oMapFrame(a0)		; Are we jumping?
	bcs.s	.End				; If not, branch

.GivingUp:
	bsr.w	ObjSonic_LevelBound		; Handle level boundary collision
	jmp	ObjMoveGrv			; Apply velocity

.NotGivingUp:
	bsr.w	ObjSonic_Handle3DRamp		; Check for a 3D ramp
	bsr.w	ObjSonic_TimeWarp		; Handle time warp
	bsr.w	ObjSonic_CheckJump		; Check for jumping
	bsr.w	ObjSonic_SlopeResist		; Handle slope resistance
	bsr.w	ObjSonic_MoveGround		; Handle movement
	bsr.w	ObjSonic_CheckRoll		; Check for rolling
	bsr.w	ObjSonic_LevelBound		; Handle level boundary collision
	jsr	ObjMove				; Apply velocity
	bsr.w	Player_GroundCol		; Handle level collision
	bsr.w	ObjSonic_CheckFallOff		; Check for falling off a steep slope or ceiling

.End:
	rts

; -------------------------------------------------------------------------
; Sonic's air mode routine
; -------------------------------------------------------------------------

ObjSonic_MdAir:
	tst.b	windTunnelFlag.w		; Are we in a wind tunnel?
	bne.s	.NotMovingDown			; If so, branch
	cmpi.b	#$15,oAnim(a0)			; Were we breathing in a bubble?
	beq.s	.NotMovingDown			; If so, branch
	tst.w	oYVel(a0)			; Are we moving upwards?
	bmi.s	.NotMovingDown			; If so, branch
	move.b	#0,oAnim(a0)			; Reset animation to walking animation

.NotMovingDown:
	bsr.w	ObjSonic_Handle3DRamp		; Check for a 3D ramp
	bsr.w	ObjSonic_TimeWarp		; Handle time warp
	bsr.w	ObjSonic_JumpHeight		; Handle jump height
	bsr.w	ObjSonic_MoveAir		; Handle movement
	bsr.w	ObjSonic_LevelBound		; Handle level boundary collision
	jsr	ObjMoveGrv			; Apply velocity
	btst	#6,oStatus(a0)			; Are we underwater?
	beq.s	.NoWater			; If not, branch
	subi.w	#$28,oYVel(a0)			; Apply water gravity resistance

.NoWater:
	bsr.w	ObjSonic_JumpAngle		; Reset angle
	bsr.w	Player_LevelColInAir		; Handle level collision
	rts

; -------------------------------------------------------------------------
; Sonic's roll mode routine
; -------------------------------------------------------------------------

ObjSonic_MdRoll:
	bsr.w	ObjSonic_Handle3DRamp		; Check for  3D ramp
	bsr.w	ObjSonic_TimeWarp		; Handle time warp
	bsr.w	ObjSonic_CheckJump		; Check for jumping
	bsr.w	ObjSonic_SlopeResistRoll	; Handle slope resistance
	bsr.w	ObjSonic_MoveRoll		; Handle movement
	bsr.w	ObjSonic_LevelBound		; Handle level boundary collision
	tst.b	oPlayerCharge(a0)		; Are we spindashing?
	bne.s	.IsCharging			; If so, branch
	jsr	ObjMove				; Apply velocity

.IsCharging:
	bsr.w	Player_GroundCol		; Handle level collision
	bsr.w	ObjSonic_CheckFallOff		; Check for falling off a steep slope or ceiling
	rts

; -------------------------------------------------------------------------
; Sonic's jump mode routine
; -------------------------------------------------------------------------

ObjSonic_MdJump:
	bsr.w	ObjSonic_Handle3DRamp		; Check for a 3D ramp
	bsr.w	ObjSonic_TimeWarp		; Handle time warp
	bsr.w	ObjSonic_JumpHeight		; Handle jump height
	bsr.w	ObjSonic_MoveAir		; Handle movement
	bsr.w	ObjSonic_LevelBound		; Handle level boundary collision
	jsr	ObjMoveGrv			; Apply velocity
	btst	#6,oStatus(a0)			; Are we underwater?
	beq.s	.NoWater			; If not, branch
	subi.w	#$28,oYVel(a0)			; Apply water gravity resistance

.NoWater:
	bsr.w	ObjSonic_JumpAngle		; Reset angle
	bsr.w	Player_LevelColInAir		; Handle level collision
	rts

; -------------------------------------------------------------------------
; Check for a 3D ramp for Sonic
; -------------------------------------------------------------------------

ObjSonic_Handle3DRamp:
	cmpi.b	#1,timeZone			; Are we in the present?
	bne.s	.End				; If not, branch
	tst.w	level				; Are we in Palmtree Panic act 1?
	bne.s	.End				; If not, branch

	move.w	oY(a0),d0			; Get current chunk that we are in
	lsr.w	#1,d0
	andi.w	#$380,d0
	move.b	oX(a0),d1
	andi.w	#$7F,d1
	add.w	d1,d0
	lea	levelLayout.w,a1
	move.b	(a1,d0.w),d1

	lea	.ChunkList,a2			; Get list of 3D ramp chunks

.CheckChunk:
	move.b	(a2)+,d0			; Are we in a 3D ramp chunk at all?
	bmi.s	.NotFound			; If not, branch
	cmp.b	d0,d1				; Have we found the 3D ramp chunk that we are in?
	bne.s	.CheckChunk			; If not, keep searching
	bset	#1,oPlayerCtrl(a0)		; Mark as on a 3D ramp
	rts

.NotFound:
	bclr	#1,oPlayerCtrl(a0)		; Mark as not on a 3D ramp
	beq.s	.End				; If we weren't on one to begin with, branch
	tst.w	oYVel(a0)			; Are we moving upwards?
	bpl.s	.End				; If not, branch
	cmpi.w	#-$800,oYVel(a0)		; Are we launching off the 3D ramp?
	bcc.s	.End				; If not, branch

	move.w	#$600,oXVel(a0)			; Gain a horizontal boost off the 3D ramp
	btst	#0,oStatus(a0)
	beq.s	.End
	neg.w	oXVel(a0)

.End:
	rts

; -------------------------------------------------------------------------

.ChunkList:
	dc.b	6
	dc.b	7
	dc.b	8
	dc.b	$49
	dc.b	$4C
	dc.b -1

; -------------------------------------------------------------------------
; Handle Sonic's movement on the ground
; -------------------------------------------------------------------------

ObjSonic_MoveGround:
	move.w	sonicTopSpeed.w,d6		; Get top speed
	move.w	sonicAcceleration.w,d5		; Get acceleration
	move.w	sonicDeceleration.w,d4		; Get deceleration

	tst.b	waterSlideFlag.w		; Are we on a water slide?
	bne.w	.CalcXYVels			; If so, branch
	tst.w	oPlayerMoveLock(a0)		; Is our movement locked temporarily?
	bne.w	.ResetScreen			; If so, branch

	btst	#2,playerCtrlHold.w		; Are we holding left?
	beq.s	.NotLeft			; If not, branch
	bsr.w	ObjSonic_MoveGndLeft		; Move left

.NotLeft:
	btst	#3,playerCtrlHold.w		; Are we holding right
	beq.s	.NotRight			; If not, branch
	bsr.w	ObjSonic_MoveGndRight		; Move right

.NotRight:
	move.b	oAngle(a0),d0			; Are we on firm on the ground?
	addi.b	#$20,d0
	andi.b	#$C0,d0
	bne.w	.ResetScreen			; If not, branch
	tst.w	oPlayerGVel(a0)			; Are we moving at all?
	beq.s	.Stand				; If not, branch
	tst.b	oPlayerCharge(a0)		; Are we charging a peelout or spindash?
	beq.w	.ResetScreen			; If not, branch
	bra.s	.CheckBalance			; Check for balancing

.Stand:
	bclr	#5,oStatus(a0)			; Stop pushing
	move.b	#5,oAnim(a0)			; Set animation to idle animation

; -------------------------------------------------------------------------

.CheckBalance:
	btst	#3,oStatus(a0)			; Are we standing on an object?
	beq.s	.BalanceGround			; If not, branch

	moveq	#0,d0				; Get the object we are standing on
	move.b	oPlayerStandObj(a0),d0
	lsl.w	#6,d0
	lea	objects.w,a1
	lea	(a1,d0.w),a1
	tst.b	oStatus(a1)			; Is it a special hazardous object?
	bmi.w	.CheckCharge			; If so, branch
	cmpi.b	#$1E,oID(a1)			; Is it a pinball flipper from CCZ?
	bne.s	.CheckObjBalance		; If not, branch
	move.b	#0,oAnim(a0)			; Set animation to walking animation
	bra.w	.ResetScreen			; Reset screen position

.CheckObjBalance:
	moveq	#0,d1				; Get distance from an edge of the object
	move.b	oWidth(a1),d1
	move.w	d1,d2
	add.w	d2,d2
	subq.w	#4,d2
	add.w	oX(a0),d1
	sub.w	oX(a1),d1
	cmpi.w	#4,d1				; Are we at least 4 pixels away from the left edge?
	blt.s	.BalanceLeft			; If so, branch
	cmp.w	d2,d1				; Are we at least 4 pixels away from the right edge?
	bge.s	.BalanceRight			; If so, branch
	bra.s	.CheckCharge			; Check for peelout/spindash charge

.BalanceGround:
	jsr	CheckFloorEdge			; Are we leaning near a ledge on either side?
	cmpi.w	#$C,d1
	blt.s	.CheckCharge			; If not, branch

	move.w	#$AB,d0				; Stop any charging
	jsr	PlayFMSound
	move.b	#0,oPlayerCharge(a0)
	move.w	#0,oPlayerGVel(a0)

	cmpi.b	#3,oPlayerPriAngle(a0)		; Are we leaning near a ledge on the right?
	bne.s	.CheckLeft			; If not, branch

.BalanceRight:
	btst	#0,oStatus(a0)			; Are we facing left?
	bne.s	.BalanceAniBackwards		; If so, use the backwards animation
	bra.s	.BalanceAniForwards		; Use the forwards animation

.CheckLeft:
	cmpi.b	#3,oPlayerSecAngle(a0)		; Are we leaning near a ledge on the left?
	bne.s	.CheckCharge			; If not, branch

.BalanceLeft:
	btst	#0,oStatus(a0)			; Are we facing left?
	bne.s	.BalanceAniForwards		; If so, use the forwards animation

.BalanceAniBackwards:
	move.b	#$32,oAnim(a0)			; Set animation to balancing backwards animation
	bra.w	.ResetScreen			; Reset screen position

.BalanceAniForwards:
	move.b	#6,oAnim(a0)			; Set animation to balancing forwards animation
	bra.w	.ResetScreen			; Reset screen position

; -------------------------------------------------------------------------

.CheckCharge:
	move.b	lookMode.w,d0			; Get double tap timer
	andi.b	#$F,d0
	beq.s	.DblTapNotInit			; If it's not active, branch
	addq.b	#1,lookMode.w			; Increment timer
	andi.b	#$CF,lookMode.w			; Cap the timer properly

.DblTapNotInit:
	btst	#7,lookMode.w			; Is the look up flag set?
	bne.w	.LookUp				; If so, branch
	btst	#6,lookMode.w			; Is the look down flag set?
	bne.w	.CheckForSpindash		; If so, branch

	btst	#1,playerCtrlHold.w		; Is down being held?
	bne.w	.CheckForSpindash		; If so, branch
	andi.b	#$F,lookMode.w			; Clear out look flags
	beq.s	.CheckUpPress			; If the double tap timer wasn't set, branch

	btst	#0,playerCtrlTap.w		; Have we double tapped up?
	beq.s	.CheckUpHeld			; If not, branch
	bset	#7,lookMode.w			; Set the look up flag
	bra.w	.Settle				; Settle movement

.CheckUpPress:
	btst	#0,playerCtrlTap.w		; Have we just pressed up?
	beq.w	.CheckUpHeld			; If not, branch
	move.b	#1,lookMode.w			; Set the double tap timer to be active
	bra.w	.Settle				; Settle movement

.CheckUpHeld:
	btst	#0,playerCtrlHold.w		; Are we holding up?
	beq.s	.CheckUnleashPeelout		; If not, branch

	move.b	#7,oAnim(a0)			; Set animation to looking up animation
	tst.b	oPlayerCharge(a0)		; Are we charging a peelout?
	beq.s	.CheckStartCharge		; If not, branch

; -------------------------------------------------------------------------

.Peelout:
	move.b	#0,oAnim(a0)			; Set animation to charging peelout animation

	moveq	#100,d0				; Get charge speed increment value
	move.w	sonicTopSpeed.w,d1		; Get max charge speed (top speed * 2)
	move.w	d1,d2
	asl.w	#1,d1
	tst.b	speedShoesFlag			; Do we have speed shoes?
	beq.s	.NoSpeedShoes			; If not, branch
	asr.w	#1,d2				; Get max charge speed for speed shoes ((top speed * 2) - (top speed / 2))
	sub.w	d2,d1

.NoSpeedShoes:
	btst	#0,oStatus(a0)			; Are we facing left?
	beq.s	.IncPeeloutCharge		; If not, branch
	neg.w	d0				; Negate the charge speed increment value
	neg.w	d1				; Negate the max charge speed

.IncPeeloutCharge:
	add.w	d0,oPlayerGVel(a0)		; Increment charge speed

	move.w	oPlayerGVel(a0),d0		; Get current charge speed
	btst	#0,oStatus(a0)			; Are we facing left?
	beq.s	.CheckMaxRight			; If not, branch
	cmp.w	d0,d1				; Have we reached the max charge speed?
	ble.s	.SetChargeSpeed			; If not, branch
	bra.s	.CapCharge			; If so, cap it

.CheckMaxRight:
	cmp.w	d1,d0				; Have we reached the max charge speed?
	ble.s	.SetChargeSpeed			; If not, branch

.CapCharge:
	move.w	d1,d0				; Cap the charge speed

.SetChargeSpeed:
	move.w	d0,oPlayerGVel(a0)		; Update the charge speed
	rts

.CheckStartCharge:
	move.b	playerCtrlTap.w,d0		; Did we press A, B, or C while we were holding up?
	andi.b	#$70,d0
	beq.s	.DontCharge			; If not, branch

	move.b	#1,oPlayerCharge(a0)		; Set the look double tap timer to be active
	move.w	#$9C,d0				; Play charge sound
	jsr	PlayFMSound

.DontCharge:
	bra.w	.Settle				; Settle movement

.CheckUnleashPeelout:
	cmpi.b	#30,oPlayerCharge(a0)		; Have we fully charged the peelout?
	beq.s	.UnleashPeelout			; If so, branch

	move.w	#$AB,d0				; Play charge stop sound
	jsr	PlayFMSound
	move.b	#0,oPlayerCharge(a0)		; Stop charging
	move.w	#0,oPlayerGVel(a0)
	bra.s	.CheckForSpindash		; Check for spindash

.UnleashPeelout:
	move.b	#0,oPlayerCharge(a0)		; Stop charging
	move.w	#$91,d0				; Play charge release sound
	jsr	PlayFMSound
	bra.w	.ResetScreen			; Reset screen position

; -------------------------------------------------------------------------

	bsr.w	ObjSonic_MoveGndLeft		; Move left
	bra.w	.ResetScreen			; Reset screen position

; -------------------------------------------------------------------------

.LookUp:
	btst	#0,playerCtrlHold.w		; Are we holding up?
	beq.s	.CheckForSpindash		; If not, branch

	move.b	#7,oAnim(a0)			; Set animation to looking up animation
	cmpi.w	#$C8,camYCenter.w		; Has the screen scrolled up all the way?
	beq.w	.Settle				; If so, branch
	addq.w	#2,camYCenter.w			; Move the screen up
	bra.w	.Settle				; Settle movement

; -------------------------------------------------------------------------

.CheckForSpindash:
	btst	#6,lookMode.w			; Is the look down flag set?
	bne.w	.Duck				; If so, branch
	andi.b	#$F,lookMode.w			; Clear out the look flags
	beq.s	.CheckDownPress			; If the double tap timer wasn't set, branch

	btst	#1,playerCtrlTap.w		; Have we double tapped down?
	beq.s	.CheckSpindash			; If not, branch
	bset	#6,lookMode.w			; Set the look down flag
	bra.w	.Settle				; Settle movement

.CheckDownPress:
	btst	#1,playerCtrlTap.w		; Have we just pressed down?
	beq.s	.CheckSpindash			; If not, branch
	move.b	#1,lookMode.w			; Set the double tap timer to be active
	bra.w	.Settle				; Settle movement

.CheckSpindash:
	btst	#1,playerCtrlHold.w		; Are we holding down?
	beq.s	.ResetScreen			; If not, branch

	move.b	#8,oAnim(a0)			; Set animation to ducking animation
	tst.b	oPlayerCharge(a0)		; Are we charging a spindash?
	bne.s	.DoSettle			; If so, branch

	move.b	playerCtrlTap.w,d0		; Did we press A, B, or C while we were holding down?
	andi.b	#$70,d0
	beq.s	.DoSettle			; If not, branch

	move.b	#1,oPlayerCharge(a0)		; Set the look double tap timer to be active
	move.w	#$16,oPlayerGVel(a0)		; Set initial spindash charge speed
	btst	#0,oStatus(a0)
	beq.s	.PlaySpindashSound
	neg.w	oPlayerGVel(a0)

.PlaySpindashSound:
	move.w	#$9C,d0				; Play charge sound
	jsr	PlayFMSound
	bsr.w	ObjSonic_StartRoll		; Start rolling for the spindash

.DoSettle:
	bra.s	.Settle				; Settle movement

; -------------------------------------------------------------------------

.Duck:
	btst	#1,playerCtrlHold.w		; Are we holding down?
	beq.s	.ResetScreen			; If not, branch

	move.b	#8,$1C(a0)			; Set animation to ducking animation
	cmpi.w	#8,camYCenter.w			; Has the screen scrolled dowm all the way?
	beq.s	.Settle				; If so, branch
	subq.w	#2,camYCenter.w			; Move the screen down
	bra.s	.Settle				; Settle movement

; -------------------------------------------------------------------------

.ResetScreen:
	cmpi.w	#$60,camYCenter.w		; Is the screen centered?
	bne.s	.CheckIncShift			; If not, branch

	move.b	lookMode.w,d0			; Get look double tap timer
	andi.b	#$F,d0
	bne.s	.Settle				; If it's active, branch
	move.b	#0,lookMode.w			; Reset double tap timer and charge lock flags
	bra.s	.Settle				; Settle movement

.CheckIncShift:
	bcc.s	.DecShift			; If the screen needs to move back down, branch
	addq.w	#4,camYCenter.w			; Move the screen back up

.DecShift:
	subq.w	#2,camYCenter.w			; Move the screen back down

; -------------------------------------------------------------------------

.Settle:
	move.b	playerCtrlHold.w,d0		; Are we holding left or right?
	andi.b	#$C,d0
	bne.s	.CalcXYVels			; If so, branch

	move.w	oPlayerGVel(a0),d0		; Get current ground velocity
	beq.s	.CalcXYVels			; If we aren't moving at all, branch
	bmi.s	.SettleLeft			; If we are moving left, branch

	sub.w	d5,d0				; Settle right
	bcc.s	.SetGVel			; If we are still moving, branch
	move.w	#0,d0				; Stop moving

.SetGVel:
	move.w	d0,oPlayerGVel(a0)		; Update ground velocity
	bra.s	.CalcXYVels			; Calculate X and Y velocities

.SettleLeft:
	add.w	d5,d0				; Settle left
	bcc.s	.SetGVel2			; If we are still moving, branch
	move.w	#0,d0				; Stop moving

.SetGVel2:
	move.w	d0,oPlayerGVel(a0)		; Update ground velocity

.CalcXYVels:
	move.b	oAngle(a0),d0			; Get sine and cosine of our current angle
	jsr	CalcSine
	muls.w	oPlayerGVel(a0),d1		; Get X velocity (ground velocity * cos(angle))
	asr.l	#8,d1
	move.w	d1,oXVel(a0)
	muls.w	oPlayerGVel(a0),d0		; Get Y velocity (ground velocity * sin(angle))
	asr.l	#8,d0
	move.w	d0,oYVel(a0)

; -------------------------------------------------------------------------
; Handle wall collision for Sonic
; -------------------------------------------------------------------------

ObjSonic_CheckWallCol:
	move.b	oAngle(a0),d0			; Are we moving on a ceiling?
	addi.b	#$40,d0
	bmi.s	.End				; If so, branch

	move.b	#$40,d1				; Get angle to point the sensor towards (angle +/- 90 degrees)
	tst.w	oPlayerGVel(a0)
	beq.s	.End
	bmi.s	.RotAngle
	neg.w	d1

.RotAngle:
	move.b	oAngle(a0),d0
	add.b	d1,d0

	move.w	d0,-(sp)			; Get distance from wall
	bsr.w	Player_CalcRoomInFront
	move.w	(sp)+,d0
	tst.w	d1
	bpl.s	.End				; If we aren't colliding with a wall, branch
	asl.w	#8,d1				; Get zip distance

	addi.b	#$20,d0				; Get the angle of the wall
	andi.b	#$C0,d0
	beq.s	.ZipUp				; If we are facing a wall downwards, branch
	cmpi.b	#$40,d0				; Are we facing a wall on the left?
	beq.s	.ZipRight			; If so, branch
	cmpi.b	#$80,d0				; Are we facing a wall upwards?
	beq.s	.ZipDown			; If so, branch

.ZipLeft:
	add.w	d1,oXVel(a0)			; Zip to the left
	bset	#5,oStatus(a0)			; Mark as pushing
	move.w	#0,oPlayerGVel(a0)		; Stop moving
	rts

.ZipDown:
	sub.w	d1,oYVel(a0)			; Zip downwards
	rts

.ZipRight:
	sub.w	d1,oXVel(a0)			; Zip to the right
	bset	#5,oStatus(a0)			; Mark as pushing
	move.w	#0,oPlayerGVel(a0)		; Stop moving
	rts

.ZipUp:
	add.w	d1,oYVel(a0)			; Zip upwards

.End:
	rts

; -------------------------------------------------------------------------
; Move Sonic left on the ground
; -------------------------------------------------------------------------

ObjSonic_MoveGndLeft:
	tst.b	oPlayerCharge(a0)		; Are we charging a peelout or spindash?
	bne.s	.End				; If so, branch

	move.w	oPlayerGVel(a0),d0		; Get current ground velocity
	beq.s	.Normal				; If we aren't moving at all, branch
	bpl.s	.Skid				; If we are moving right, branch

.Normal:
	bset	#0,oStatus(a0)			; Face left
	bne.s	.Accelerate			; If we were already facing left, branch
	bclr	#5,oStatus(a0)			; Stop pushing
	move.b	#1,oPrevAnim(a0)		; Reset animation

.Accelerate:
	move.w	d6,d1				; Get top speed
	neg.w	d1
	cmp.w	d1,d0				; Have we already reached it?
	ble.s	.SetGVel			; If so, branch
	sub.w	d5,d0				; Apply acceleration
	cmp.w	d1,d0				; Have we reached top speed?
	bgt.s	.SetGVel			; If not, branch
	move.w	d1,d0				; Cap our velocity

.SetGVel:
	move.w	d0,oPlayerGVel(a0)		; Update ground velocity
	move.b	#0,oAnim(a0)			; Set animation to walking animation
	rts

.Skid:
	sub.w	d4,d0				; Apply deceleration
	bcc.s	.SetGVel2			; If we are still moving right, branch
	move.w	#-$80,d0			; If we are now moving left, set velocity to -0.5

.SetGVel2:
	move.w	d0,oPlayerGVel(a0)		; Update ground velocity

	move.b	oAngle(a0),d0			; Are we on a floor?
	addi.b	#$20,d0
	andi.b	#$C0,d0
	bne.s	.End				; If not, branch
	cmpi.w	#$400,d0			; Is our ground velocity at least 4?
	blt.s	.End				; If not, branch

	move.b	#$D,oAnim(a0)			; Set animation to skidding animation
	bclr	#0,oStatus(a0)			; Face right
	move.w	#$90,d0				; Play skidding sound
	jsr	PlayFMSound

.End:
	rts

; -------------------------------------------------------------------------
; Move Sonic right on the ground
; -------------------------------------------------------------------------

ObjSonic_MoveGndRight:
	tst.b	oPlayerCharge(a0)		; Are we charging a peelout or spindash?
	bne.s	.End				; If so, branch

	move.w	oPlayerGVel(a0),d0		; Get current ground velocity
	bmi.s	.Skid

.Normal:
	bclr	#0,oStatus(a0)			; Face right
	beq.s	.Accelerate			; If we were already facing right, branch
	bclr	#5,oStatus(a0)			; Stop pushing
	move.b	#1,oPrevAnim(a0)		; Reset animation

.Accelerate:
	cmp.w	d6,d0				; Have we already reached top speed?
	bge.s	.SetGVel			; If so, branch
	add.w	d5,d0				; Apply acceleration
	cmp.w	d6,d0				; Have we reached top speed?
	blt.s	.SetGVel			; If not, branch
	move.w	d6,d0				; Cap our velocity

.SetGVel:
	move.w	d0,oPlayerGVel(a0)		; Update ground velocity
	move.b	#0,oAnim(a0)			; Set animation to walking animation
	rts

.Skid:
	add.w	d4,d0				; Apply deceleration
	bcc.s	.SetGVel2			; If we are still moving left, branch
	move.w	#$80,d0				; If we are now moving right, set velocity to 0.5

.SetGVel2:
	move.w	d0,oPlayerGVel(a0)		; Update ground velocity

	move.b	oAngle(a0),d0			; Are we on a floor?
	addi.b	#$20,d0
	andi.b	#$C0,d0
	bne.s	.End				; If not, branch
	cmpi.w	#-$400,d0			; Is our ground velocity at least -4?
	bgt.s	.End				; If not, branch

	move.b	#$D,oAnim(a0)			; Set animation to skidding animation
	bset	#0,oStatus(a0)			; Face left
	move.w	#$90,d0				; Play skidding sound
	jsr	PlayFMSound

.End:
	rts

; -------------------------------------------------------------------------
; Handle Sonic's movement while rolling on the ground
; -------------------------------------------------------------------------

ObjSonic_MoveRoll:
	move.w	sonicTopSpeed.w,d6		; Get top speed (multiplied by 2)
	asl.w	#1,d6
	move.w	sonicAcceleration.w,d5		; Get acceleration (divided by 2)
	asr.w	#1,d5
	move.w	sonicDeceleration.w,d4		; Get deceleration (divided by 4)
	asr.w	#2,d4

	tst.b	waterSlideFlag.w		; Are we on a water slide?
	bne.w	.CalcXYVels			; If so, branch
	tst.w	oPlayerMoveLock(a0)		; Is our movement locked temporarily?
	bne.s	.NotRight			; If so, branch

	btst	#2,playerCtrlHold.w		; Are we holding left?
	beq.s	.NotLeft			; If not, branch
	bsr.w	ObjSonic_MoveRollLeft		; Move left

.NotLeft:
	btst	#3,playerCtrlHold.w		; Are we holding right
	beq.s	.NotRight			; If not, branch
	bsr.w	ObjSonic_MoveRollRight		; Move right

.NotRight:
	tst.b	oPlayerCharge(a0)		; Are we charging a spindash?
	beq.w	.Settle				; If not, branch

; -------------------------------------------------------------------------

.Spindash:
	move.w	#75,d0				; Get charge speed increment value
	move.w	sonicTopSpeed.w,d1		; Get max charge speed (top speed * 2)
	move.w	d1,d2
	asl.w	#1,d1
	tst.b	speedShoesFlag			; Do we have speed shoes?
	beq.s	.NoSpeedShoes			; If not, branch
	asr.w	#1,d2				; Get max charge speed for speed shoes ((top speed * 2) - (top speed / 2))
	sub.w	d2,d1

.NoSpeedShoes:
	btst	#0,oStatus(a0)			; Are we facing left?
	beq.s	.IncSpindashCharge		; If not, branch
	neg.w	d0				; Negate the charge speed increment value
	neg.w	d1				; Negate the max charge speed

.IncSpindashCharge:
	add.w	d0,oPlayerGVel(a0)		; Increment charge speed

	move.w	oPlayerGVel(a0),d0		; Get current charge speed
	btst	#0,oStatus(a0)			; Are we facing left?
	beq.s	.CheckMaxRight			; If not, branch
	cmp.w	d0,d1				; Have we reached the max charge speed?
	ble.s	.SetChargeSpeed			; If not, branch
	bra.s	.CapCharge			; If so, cap it

.CheckMaxRight:
	cmp.w	d1,d0				; Have we reached the max charge speed?
	ble.s	.SetChargeSpeed			; If not, branch

.CapCharge:
	move.w	d1,d0				; Cap the charge speed

.SetChargeSpeed:
	move.w	d0,oPlayerGVel(a0)		; Update the charge speed

	btst	#1,playerCtrlHold.w		; Are we holding down?
	beq.s	.NotDown			; If not, branch
	rts

.ChargeNotFull:
	move.w	#$AB,d0				; Play charge stop sound
	jsr	PlayFMSound

	move.b	#0,oPlayerCharge(a0)		; Stop charging
	move.w	#0,oPlayerGVel(a0)
	move.w	#0,oXVel(a0)
	move.w	#0,oYVel(a0)

	bra.w	.StopRolling			; Stop rolling

.NotDown:
	cmpi.b	#45,oPlayerCharge(a0)		; Have we fully charged the spindash?
	bne.s	.ChargeNotFull			; If not, branch

	move.b	#0,oPlayerCharge(a0)		; Stop charging
	move.w	#$91,d0				; Play charge release sound
	jsr	PlayFMSound

	btst	#0,oStatus(a0)			; Are we facing left?
	bne.s	.ChargeLeft			; If so, branch
	bsr.w	ObjSonic_MoveRollRight		; Charge towards the right
	bra.s	.Settle				; Settle movement

.ChargeLeft:
	bsr.w	ObjSonic_MoveRollLeft		; Charge towards the left
	bra.s	.Settle				; Settle movement
	rts

; -------------------------------------------------------------------------

.Settle:
	move.w	oPlayerGVel(a0),d0		; Get current ground velocity
	beq.s	.CheckStopRoll			; If we aren't moving at all, branch
	bmi.s	.SettleLeft			; If we are moving left, branch

	sub.w	d5,d0				; Settle right
	bcc.s	.SetGVel			; If we are still moving, branch
	move.w	#0,d0				; Stop moving

.SetGVel:
	move.w	d0,oPlayerGVel(a0)		; Update ground velocity
	bra.s	.CheckStopRoll			; Calculate X and Y velocities

.SettleLeft:
	add.w	d5,d0				; Settle left
	bcc.s	.SetGVel2			; If we are still moving, branch
	move.w	#0,d0				; Stop moving

.SetGVel2:
	move.w	d0,oPlayerGVel(a0)		; Update ground velocity

.CheckStopRoll:
	tst.w	oPlayerGVel(a0)			; Are we still moving?
	bne.s	.CalcXYVels			; If so, branch
	move.w	#$AB,d0				; Play charge stop sound
	jsr	PlayFMSound

.StopRolling:
	bclr	#2,oStatus(a0)			; Stop rolling

	tst.b	miniSonic			; Are we miniature?
	beq.s	.NotMini			; If not, branch
	move.b	#$A,oYRadius(a0)		; Restore miniature hitbox size
	move.b	#5,oXRadius(a0)
	subq.w	#2,oY(a0)
	bra.s	.ResetAnim

.NotMini:
	move.b	#$13,oYRadius(a0)		; Restore hitbox size
	move.b	#9,oXRadius(a0)
	subq.w	#5,oY(a0)

.ResetAnim:
	move.b	#5,oAnim(a0)			; Set animation to idle animation

.CalcXYVels:
	move.b	oAngle(a0),d0			; Get sine and cosine of our current angle
	jsr	CalcSine
	muls.w	oPlayerGVel(a0),d0		; Get Y velocity (ground velocity * sin(angle))
	asr.l	#8,d0
	move.w	d0,oYVel(a0)
	muls.w	oPlayerGVel(a0),d1		; Get X velocity (ground velocity * cos(angle))
	asr.l	#8,d1
	cmpi.w	#$1000,d1			; Is the X velocity greater than 16?
	ble.s	.CheckCapLeft			; If not, branch
	move.w	#$1000,d1			; Cap the X velocity at 16

.CheckCapLeft:
	cmpi.w	#-$1000,d1			; Is the X velocity less than -16?
	bge.s	.SetXVel			; If not, branch
	move.w	#-$1000,d1			; Cap the X velocity at -16

.SetXVel:
	move.w	d1,oXVel(a0)			; Set X velocity

	bra.w	ObjSonic_CheckWallCol		; Handle wall collision

; -------------------------------------------------------------------------
; Move Sonic left on the ground while rolling
; -------------------------------------------------------------------------

ObjSonic_MoveRollLeft:
	move.w	oPlayerGVel(a0),d0		; Get current ground velocity
	beq.s	.StartRoll			; If we aren't moving at all, branch
	bpl.s	.DecelRoll			; If we are moving right, branch

.StartRoll:
	bset	#0,oStatus(a0)			; Face left
	move.b	#2,oAnim(a0)			; Set animation to rolling animation
	rts

.DecelRoll:
	sub.w	d4,d0				; Apply deceleration
	bcc.s	.SetGVel			; If we are still moving right, branch
	move.w	#-$80,d0			; If we are now moving left, set velocity to -0.5

.SetGVel:
	move.w	d0,oPlayerGVel(a0)		; Update ground velocity
	rts

; -------------------------------------------------------------------------
; Move Sonic right on the ground while rolling
; -------------------------------------------------------------------------

ObjSonic_MoveRollRight:
	move.w	oPlayerGVel(a0),d0		; Get current ground velocity
	bmi.s	.DecelRoll			; If we are moving left, branch

.StartRoll:
	bclr	#0,oStatus(a0)			; Face right
	move.b	#2,oAnim(a0)			; Set animation to rolling animation
	rts

.DecelRoll:
	add.w	d4,d0				; Apply deceleration
	bcc.s	.SetGVel			; If we are still moving left, branch
	move.w	#$80,d0				; If we are now moving left, set velocity to 0.5

.SetGVel:
	move.w	d0,oPlayerGVel(a0)		; Update ground velocity
	rts

; -------------------------------------------------------------------------
; Handle Sonic's movement in the air
; -------------------------------------------------------------------------

ObjSonic_MoveAir:
	move.w	sonicTopSpeed.w,d6		; Get top speed
	move.w	sonicAcceleration.w,d5		; Get acceleration (multiplied by 2)
	asl.w	#1,d5

	move.w	oXVel(a0),d0			; Get current X velocity

	cmpi.b	#1,timeZone			; Are we in the present?
	bne.s	.CheckLeft			; If not, branch
	tst.w	level				; Are we in Palmtree Panic act 1?
	bne.s	.CheckLeft			; If not, branch

	cmpi.w	#$6C8,oX(a0)			; Are we left of the first 3D ramp launch area?
	bcs.s	.Check3DRamp			; If so, branch
	cmpi.w	#$840,oX(a0)			; Are we right of the first 3D ramp launch area?
	bcc.s	.Check3DRamp			; If so, branch
	rts					; Lock our horizontal movement while we launch off the first 3D ramp

.Check3DRamp:
	btst	#1,oPlayerCtrl(a0)		; Are we on a 3D ramp?
	bne.s	.SetXVel			; If so, branch

.CheckLeft:
	btst	#2,playerCtrlHold.w		; Are we holding left?
	beq.s	.CheckRight			; If not, branch
	bset	#0,oStatus(a0)			; Face left
	sub.w	d5,d0				; Apply acceleration
	move.w	d6,d1				; Get top speed
	neg.w	d1
	cmp.w	d1,d0				; Have we reached top speed?
	bgt.s	.CheckRight			; If not, branch
	move.w	d1,d0				; Cap at top speed

.CheckRight:
	btst	#3,playerCtrlHold.w		; Are we holding right?
	beq.s	.SetXVel			; If not, branch
	bclr	#0,oStatus(a0)			; Face right
	add.w	d5,d0				; Apply acceleration
	cmp.w	d6,d0				; Have we reached top speed?
	blt.s	.SetXVel			; If not, branch
	move.w	d6,d0				; Cap at top speed

.SetXVel:
	move.w	d0,oXVel(a0)			; Update X velocity

; -------------------------------------------------------------------------

.ResetScreen:
	cmpi.w	#$60,camYCenter.w		; Is the screen centered?
	beq.s	.CheckDrag			; If not, branch
	bcc.s	.DecShift			; If the screen needs to move back down, branch
	addq.w	#4,camYCenter.w			; Move the screen back up

.DecShift:
	subq.w	#2,camYCenter.w			; Move the screen back down

; -------------------------------------------------------------------------

.CheckDrag:
	cmpi.w	#-$400,oYVel(a0)		; Are we moving upwards at a velocity greater than -4?
	bcs.s	.End				; If not, branch

	move.w	oXVel(a0),d0			; Get air drag value (X velocity / $20)
	move.w	d0,d1
	asr.w	#5,d1
	beq.s	.End				; If there is no air drag to apply, branch
	bmi.s	.DecLXVel			; If we are moving left, branch

.DecRXVel:
	sub.w	d1,d0				; Apply air drag
	bcc.s	.SetRAirDrag			; If we haven't stopped horizontally, branch
	move.w	#0,d0				; Stop our horizontal movement

.SetRAirDrag:
	move.w	d0,oXVel(a0)			; Update X velocity
	rts

.DecLXVel:
	sub.w	d1,d0				; Apply air drag
	bcs.s	.SetLAirDrag			; If we haven't stopped horizontally, branch
	move.w	#0,d0				; Stop our horizontal movement

.SetLAirDrag:
	move.w	d0,oXVel(a0)			; Update X velocity

.End:
	rts

; -------------------------------------------------------------------------
; Leftover unused function from Sonic 1 that handles squashing Sonic
; -------------------------------------------------------------------------

ObjSonic_CheckSquash:
	move.b	oAngle(a0),d0			; Are we on the floor?
	addi.b	#$20,d0
	andi.b	#$C0,d0
	bne.s	.End				; If not, branch

	bsr.w	Player_CheckCeiling		; Are we also colliding with the ceiling?
	tst.w	d1
	bpl.s	.End				; If not, branch

	move.w	#0,oPlayerGVel(a0)		; Stop movement
	move.w	#0,oXVel(a0)
	move.w	#0,oYVel(a0)
	move.b	#$B,oAnim(a0)			; Set animation to squished/warping animation (leftover from Sonic 1)

.End:
	rts

; -------------------------------------------------------------------------
; Handle level boundaries for Sonic
; -------------------------------------------------------------------------

ObjSonic_LevelBound:
	move.l	oX(a0),d1			; Get X position for horizontal boundary checking (X position + X velocity)
	move.w	oXVel(a0),d0
	ext.l	d0
	asl.l	#8,d0
	add.l	d0,d1
	swap	d1

	move.w	leftBound.w,d0			; Have we crossed the left boundary?
	addi.w	#16,d0
	cmp.w	d1,d0
	bhi.s	.Sides				; If so, branch

	move.w	rightBound.w,d0			; Get right boundary
	addi.w	#320-16,d0
	tst.b	bossFight.w			; Are we in a boss fight?
	bne.s	.ScreenLocked			; If so, branch
	addi.w	#56,d0				; If not, extend the boundary beyond the screen

.ScreenLocked:
	cmp.w	d1,d0				; Have we crossed the right boundary?
	bls.s	.Sides				; If so, branch

.CheckBottom:
	move.w	bottomBound.w,d0		; Have we crossed the bottom boundary?
	addi.w	#224,d0
	cmp.w	$C(a0),d0
	blt.s	.Bottom				; If so, branch
	rts

.Bottom:
	cmpi.b	#$2B,oAnim(a0)			; Is the player giving up from boredom?
	bne.w	KillPlayer			; If not, kill Sonic as normal
	move.b	#6,oRoutine(a0)			; If so, just set the routine to death
	rts

.Sides:
	move.w	d0,oX(a0)			; Stop at the boundary
	move.w	#0,oXSub(a0)
	move.w	#0,oXVel(a0)
	move.w	#0,oPlayerGVel(a0)
	bra.s	.CheckBottom			; Continue checking for bottom boundary collision

; -------------------------------------------------------------------------
; Check for rolling for Sonic
; -------------------------------------------------------------------------

ObjSonic_CheckRoll:
	tst.b	waterSlideFlag.w		; Are we on a water slide?
	bne.s	.End				; If so, branch

	move.w	oPlayerGVel(a0),d0		; Get absolute value of our ground velocity
	bpl.s	.PosInertia
	neg.w	d0

.PosInertia:
	cmpi.w	#$80,d0				; Is it at least 0.5?
	bcs.s	.End				; If not, branch
	move.b	playerCtrlHold.w,d0		; Are we holding left or right?
	andi.b	#$C,d0
	bne.s	.End				; If not, branch
	btst	#1,playerCtrlHold.w		; Are we holding down?
	bne.s	ObjSonic_StartRoll		; If so, branch

.End:
	rts

; -------------------------------------------------------------------------
; Make Sonic start rolling
; -------------------------------------------------------------------------

ObjSonic_StartRoll:
	btst	#2,oStatus(a0)			; Are we already rolling?
	beq.s	.DoRoll				; If not, branch
	bra.s	.SetRollAnim			; If so, don't worry about fixing the hitbox size

.DoRoll:
	bset	#2,oStatus(a0)			; Mark as rolling
	tst.b	miniSonic			; Are we miniature?
	beq.s	.NotMini			; If not, branch
	move.b	#8,oYRadius(a0)			; Set miniature rolling hitbox size
	move.b	#5,oXRadius(a0)
	addq.w	#2,oY(a0)
	bra.s	.SetRollAnim			; Set animatiion

.NotMini:
	move.b	#$E,oYRadius(a0)		; Set rolling hitbox size
	move.b	#7,oXRadius(a0)
	addq.w	#5,oY(a0)

.SetRollAnim:
	move.b	#2,oAnim(a0)			; Set animation to rolling animation

	tst.w	oPlayerGVel(a0)			; Are we moving left?
	bmi.s	.End				; If not, branch
	cmpi.w	#$200,oPlayerGVel(a0)		; Is our ground velocity less than 2?
	bcc.s	.End				; If not, branch
	move.w	#$200,oPlayerGVel(a0)		; If so, cap our ground velocity at 2

.End:
	rts

; -------------------------------------------------------------------------
; Check for jumping for Sonic
; -------------------------------------------------------------------------

ObjSonic_CheckJump:
	tst.b	oPlayerCharge(a0)		; Are we charging a peelout or spindash?
	beq.s	.CanJump			; If not, branch
	rts

.CanJump:
	move.b	playerCtrlHold.w,d0		; Are we holding up or down?
	andi.b	#3,d0
	beq.s	.NotUpDown			; If not, branch
	tst.w	oPlayerGVel(a0)			; Are we moving at all?
	beq.w	.End				; If not, branch

.NotUpDown:
	move.b	playerCtrlTap.w,d0		; Have we pressed A, B, or C?
	andi.b	#$70,d0
	beq.w	.End				; If not, branch

	btst	#3,oStatus(a0)			; Are we standing on an object?
	beq.s	.NotOnObj			; If not, branch
	jsr	ObjSonic_ChkFlipper		; Check if we are on a pinball flipper, and if so, get the angle and speed to launch at
	beq.s	.GotAngle			; If we were on a pinball flipper, branch

.NotOnObj:
	moveq	#0,d0				; Get the amount of space over our head
	move.b	oAngle(a0),d0
	addi.b	#$80,d0
	bsr.w	Player_CalcRoomOverHead
	cmpi.w	#6,d1				; Is there at least 6 pixels of space?
	blt.w	.End				; If not, branch

	move.w	#$680,d2			; Get jump speed (6.5)
	btst	#6,oStatus(a0)			; Are we underwater?
	beq.s	.NoWater			; If not, branch
	move.w	#$380,d2			; Get underwater jump speed (3.5)

.NoWater:
	moveq	#0,d0				; Get our angle on the ground
	move.b	oAngle(a0),d0
	subi.b	#$40,d0

.GotAngle:
	jsr	CalcSine			; Get the sine and cosine of our angle
	muls.w	d2,d1				; Get X velocity to jump at (jump speed * cos(angle))
	asr.l	#8,d1
	add.w	d1,oXVel(a0)
	muls.w	d2,d0				; Get Y velocity to jump at (jump speed * sin(angle))
	asr.l	#8,d0
	add.w	d0,oYVel(a0)

	bset	#1,oStatus(a0)			; Mark as in air
	bclr	#5,oStatus(a0)			; Stop pushing
	addq.l	#4,sp				; Stop handling ground specific routines after this
	move.b	#1,oPlayerJump(a0)		; Mark as jumping
	clr.b	oPlayerStick(a0)		; Mark as not sticking to terrain
	clr.b	lookMode.w			; Reset look double tap timer and flags

	move.w	#$92,d0				; Play jump sound
	jsr	PlayFMSound

	btst	#2,oStatus(a0)			; Were we rolling?
	bne.s	.RollJump			; If so, branch
	tst.b	miniSonic			; Are we miniature?
	beq.s	.SetJumpSize			; If not, branch
	move.b	#8,oYRadius(a0)			; Set miniature jumping hitbox size
	move.b	#5,oXRadius(a0)
	addq.w	#2,oY(a0)
	bra.s	.StartJump			; Mark as jumping

.SetJumpSize:
	move.b	#$E,oYRadius(a0)		; Set jumping hitbox size
	move.b	#7,oXRadius(a0)
	addq.w	#5,oY(a0)

.StartJump:
	bset	#2,oStatus(a0)			; Mark as rolling
	move.b	#2,oAnim(a0)			; Set animation to rolling animation

.End:
	rts

.RollJump:
	bset	#4,oStatus(a0)			; Mark as roll-jumping
	rts

; -------------------------------------------------------------------------
; Handle Sonic's jump height
; -------------------------------------------------------------------------

ObjSonic_JumpHeight:
	tst.b	oPlayerJump(a0)			; Are we jumping?
	beq.s	.NotJump			; If not, branch

	move.w	#-$400,d1			; Get minimum jump velocity
	btst	#6,oStatus(a0)			; Are we underwater?
	beq.s	.GotCapVel			; If not, branch
	move.w	#-$200,d1			; Get minimum underwater jump velocity

.GotCapVel:
	cmp.w	oYVel(a0),d1			; Are we going up faster than the minimum jump velocity?
	ble.s	.End				; If so, branch
	move.b	playerCtrlHold.w,d0		; Are we holding A, B, or C?
	andi.b	#$70,d0
	bne.s	.End				; If so, branch

	move.b	#0,oPlayerCharge(a0)		; Stop charging
	move.w	d1,oYVel(a0)			; Cap our Y velocity at the minimum jump velocity

.End:
	rts

.NotJump:
	cmpi.w	#-$FC0,oYVel(a0)		; Is our Y velocity less than -15.75?
	bge.s	.End2				; If not, branch
	move.w	#-$FC0,oYVel(a0)		; Cap our Y velocity at -15.75

.End2:
	rts

; -------------------------------------------------------------------------
; Handle slope resistance for Sonic
; -------------------------------------------------------------------------

ObjSonic_SlopeResist:
	tst.b	oPlayerCharge(a0)		; Are we charging a peelout or spindash?
	bne.s	.End2				; If so, branch

	move.b	oAngle(a0),d0			; Are we on a ceiling?
	addi.b	#$60,d0
	cmpi.b	#$C0,d0
	bcc.s	.End2				; If so, branch

	move.b	oAngle(a0),d0			; Get slope resistance value (sin(angle) / 8)
	jsr	CalcSine
	muls.w	#$20,d0
	asr.l	#8,d0

	tst.w	oPlayerGVel(a0)			; Are we moving at all?
	beq.s	.End2				; If not, branch
	bmi.s	.MovingLeft			; If we are moving left, branch
	tst.w	d0				; Is the slope resistance value 0?
	beq.s	.End				; If so, branch
	add.w	d0,oPlayerGVel(a0)		; Apply slope resistance

.End:
	rts

.MovingLeft:
	add.w	d0,oPlayerGVel(a0)		; Apply slope resistance

.End2:
	rts

; -------------------------------------------------------------------------
; Handle slope resistance for Sonic while rolling
; -------------------------------------------------------------------------

ObjSonic_SlopeResistRoll:
	tst.b	oPlayerCharge(a0)		; Are we charging a peelout or spindash?
	bne.s	.End				; If so, branch

	move.b	oAngle(a0),d0			; Are we on a ceiling?
	addi.b	#$60,d0
	cmpi.b	#$C0,d0
	bcc.s	.End				; If so, branch

	move.b	oAngle(a0),d0			; Get slope resistance value (sin(angle) / 3.2)
	jsr	CalcSine
	muls.w	#$50,d0
	asr.l	#8,d0

	tst.w	oPlayerGVel(a0)			; Are we moving at all?
	bmi.s	.MovingLeft			; If we are moving left, branch
	tst.w	d0				; Is the slope resistance value positive?
	bpl.s	.ApplyResist			; If so, branch
	asr.l	#2,d0				; If it's negative, divide it by 4

.ApplyResist:
	add.w	d0,oPlayerGVel(a0)		; Apply slope resistance
	rts

.MovingLeft:
	tst.w	d0				; Is the slope resistance value negatie?
	bmi.s	.ApplyResist2			; If so, branch
	asr.l	#2,d0				; If it's positive, divide it by 4

.ApplyResist2:
	add.w	d0,oPlayerGVel(a0)		; Apply slope resistance

.End:
	rts

; -------------------------------------------------------------------------
; Check if Sonic should fall off a steep slope or ceiling
; -------------------------------------------------------------------------

ObjSonic_CheckFallOff:
	nop
	tst.b	oPlayerStick(a0)		; Are we stuck to the terrain?
	bne.s	.End				; If so, branch
	tst.w	oPlayerMoveLock(a0)		; Is our movement currently temporarily locked?
	bne.s	.RunMoveLock			; If so, branch

	move.b	oAngle(a0),d0			; Are we on a steep enough slope or ceiling?
	addi.b	#$20,d0
	andi.b	#$C0,d0
	beq.s	.End				; If not, branch

	move.w	oPlayerGVel(a0),d0		; Get current ground speed
	bpl.s	.CheckSpeed
	neg.w	d0

.CheckSpeed:
	cmpi.w	#$280,d0			; Is our ground speed less than 2.5?
	bcc.s	.End				; If not, branch

	clr.w	oPlayerGVel(a0)			; Set ground velocity to 0
	nop
	nop
	nop
	nop
	bset	#1,oStatus(a0)			; Mark as in air
	move.w	#30,oPlayerMoveLock(a0)		; Set movement lock timer

.End:
	rts

.RunMoveLock:
	subq.w	#1,oPlayerMoveLock(a0)		; Decrement movement lock timer
	rts

; -------------------------------------------------------------------------
; Reset Sonic's angle in the air
; -------------------------------------------------------------------------

ObjSonic_JumpAngle:
	btst	#1,oPlayerCtrl(a0)		; Are we on a 3D ramp?
	bne.s	.End				; If so, branch

	move.b	oAngle(a0),d0			; Get current angle
	beq.s	.End				; If it's 0, branch
	bpl.s	.DecPosAngle			; If it's positive, branch

	addq.b	#2,d0				; Slowly set angle back to 0
	bcc.s	.DontCap
	moveq	#0,d0

.DontCap:
	bra.s	.SetNewAngle			; Update the angle value

.DecPosAngle:
	subq.b	#2,d0				; Slowly set angle back to 0
	bcc.s	.SetNewAngle
	moveq	#0,d0

.SetNewAngle:
	move.b	d0,oAngle(a0)			; Update angle

.End:
	rts

; -------------------------------------------------------------------------
; Handle level collision while in the air
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

Player_LevelColInAir:
	move.w	oXVel(a0),d1			; Get the angle that we are moving at
	move.w	oYVel(a0),d2
	jsr	CalcAngle

	move.b	d0,angleBuffer			; Update debug angle buffers
	subi.b	#$20,d0
	move.b	d0,angleNormalBuf
	andi.b	#$C0,d0
	move.b	d0,quadrantNormalBuf

	cmpi.b	#$40,d0				; Are we moving left?
	beq.w	Player_LvlColAir_Left		; If so, branch
	cmpi.b	#$80,d0				; Are we moving up?
	beq.w	Player_LvlColAir_Up		; If so, branch
	cmpi.b	#$C0,d0				; Are we moving right?
	beq.w	Player_LvlColAir_Right		; If so, branch

; -------------------------------------------------------------------------
; Handle level collision while moving downwards in the air
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

Player_LvlColAir_Down:
	bsr.w	Player_GetLWallDist		; Are we colliding with a wall on the left?
	tst.w	d1
	bpl.s	.NotLeftWall			; If not, branch

	sub.w	d1,oX(a0)			; Move outside of the wall
	move.w	#0,oXVel(a0)			; Stop moving horizontally

.NotLeftWall:
	bsr.w	Player_GetRWallDist		; Are we colliding with a wall on the right?
	tst.w	d1
	bpl.s	.NotRightWall			; If not, branch

	add.w	d1,oX(a0)			; Move outside of the wall
	move.w	#0,oXVel(a0)			; Stop moving horizontally

.NotRightWall:
	bsr.w	Player_CheckFloor		; Are we colliding with the floor?
	move.b	d1,floorDist
	tst.w	d1
	bpl.s	.End				; If not, branch

	move.b	oYVel(a0),d2			; Are we moving too fast downwards?
	addq.b	#8,d2
	neg.b	d2
	cmp.b	d2,d1
	bge.s	.NotFallThrough			; If not, branch
	cmp.b	d2,d0
	blt.s	.End				; If so, branch

.NotFallThrough:
	add.w	d1,oY(a0)			; Move outside of the floor
	move.b	d3,oAngle(a0)			; Set angle
	bsr.w	Player_ResetOnFloor		; Reset flags
	move.b	#0,oAnim(a0)			; Set animation to walking animation

	move.b	d3,d0				; Did we land on a steep slope?
	addi.b	#$20,d0
	andi.b	#$40,d0
	bne.s	.LandSteepSlope			; If so, branch

	move.b	d3,d0				; Did we land on a more flat surface?
	addi.b	#$10,d0
	andi.b	#$20,d0
	beq.s	.LandFloor			; If so, branch

.LandSlope:
	asr	oYVel(a0)			; Halve the landing speed
	bra.s	.KeepYVel

.LandFloor:
	move.w	#0,oYVel(a0)			; Stop moving vertically
	move.w	oXVel(a0),oPlayerGVel(a0)	; Set landing speed
	rts

.LandSteepSlope:
	move.w	#0,oXVel(a0)			; Stop moving horizontally
	cmpi.w	#$FC0,oYVel(a0)			; Is our landing speed greater than 15.75?
	ble.s	.KeepYVel			; If not, branch
	move.w	#$FC0,oYVel(a0)			; Cap it at 15.75

.KeepYVel:
	move.w	oYVel(a0),oPlayerGVel(a0)	; Set landing speed
	tst.b	d3				; Is our angle 0-$7F?
	bpl.s	.End				; If so, branch
	neg.w	oPlayerGVel(a0)			; If not, negate our landing speed

.End:
	rts

; -------------------------------------------------------------------------
; Handle level collision while moving left in the air
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

Player_LvlColAir_Left:
	bsr.w	Player_GetLWallDist		; Are we colliding with a wall on the left?
	tst.w	d1
	bpl.s	.NotLeftWall			; If not, branch

	sub.w	d1,oX(a0)			; Move outside of the wall
	move.w	#0,oXVel(a0)			; Stop moving horizontally
	move.w	oYVel(a0),oPlayerGVel(a0)	; Set landing speed
	rts

.NotLeftWall:
	bsr.w	Player_CheckCeiling		; Are we colliding with a ceiling?
	tst.w	d1
	bpl.s	.NotCeiling			; If not, branch

	sub.w	d1,oY(a0)			; Move outside of the ceiling
	tst.w	oYVel(a0)			; Were we moving upwards?
	bpl.s	.End				; If not, branch
	move.w	#0,oYVel(a0)			; If so, stop moving vertically

.End:
	rts

.NotCeiling:
	tst.w	oYVel(a0)			; Are we moving upwards?
	bmi.s	.End2				; If so, branch

	bsr.w	Player_CheckFloor		; Are we colliding with the floor?
	tst.w	d1
	bpl.s	.End2				; If not, branch

	add.w	d1,oY(a0)			; Move outside of the floor
	move.b	d3,oAngle(a0)			; Set angle
	bsr.w	Player_ResetOnFloor		; Reset flags
	move.b	#0,oAnim(a0)			; Set animation to walking animation
	move.w	#0,oYVel(a0)			; Stop moving vertically
	move.w	oXVel(a0),oPlayerGVel(a0)	; Set landing speed

.End2:
	rts

; -------------------------------------------------------------------------
; Handle level collision while moving upwards in the air
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

Player_LvlColAir_Up:
	bsr.w	Player_GetLWallDist		; Are we colliding with a wall on the left?
	tst.w	d1
	bpl.s	.NotLeftWall			; If not, branch

	sub.w	d1,oX(a0)			; Move outside of the wall
	move.w	#0,oXVel(a0)			; Stop moving horizontally

.NotLeftWall:
	bsr.w	Player_GetRWallDist		; Are we colliding with a wall on the right?
	tst.w	d1
	bpl.s	.NotRightWall			; If not, branch

	add.w	d1,oX(a0)			; Move outside of the wall
	move.w	#0,oXVel(a0)			; Stop moving horizontally

.NotRightWall:
	bsr.w	Player_CheckCeiling		; Are we colliding with a ceiling?
	tst.w	d1
	bpl.s	.End				; If not, branch

	sub.w	d1,oY(a0)			; Move outside of the ceiling

	move.b	d3,d0				; Did we land on a steep slope?
	addi.b	#$20,d0
	andi.b	#$40,d0
	bne.s	.LandSteepSlope			; If so, branch

.LandCeiling:
	move.w	#0,oYVel(a0)			; Stop moving vertically
	rts

.LandSteepSlope:
	move.b	d3,oAngle(a0)			; Set angle
	bsr.w	Player_ResetOnSteepSlope	; Reset flags
	move.w	oYVel(a0),oPlayerGVel(a0)	; Set landing speed

	tst.b	d3				; Is our angle 0-$7F?
	bpl.s	.End				; If so, branch
	neg.w	oPlayerGVel(a0)			; If not, negate our landing speed

.End:
	rts

; -------------------------------------------------------------------------
; Handle level collision while moving right in the air
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

Player_LvlColAir_Right:
	bsr.w	Player_GetRWallDist		; Are we colliding with a wall on the right?
	tst.w	d1
	bpl.s	.NotRightWall			; If not, branch

	add.w	d1,oX(a0)			; Move outside of the wall
	move.w	#0,oXVel(a0)			; Stop moving horizontally
	move.w	oYVel(a0),oPlayerGVel(a0)	; Set landing speed
	rts

.NotRightWall:
	bsr.w	Player_CheckCeiling		; Are we colliding with a ceiling?
	tst.w	d1
	bpl.s	.NotCeiling			; If not, branch

	sub.w	d1,oY(a0)			; Move outside of the ceiling
	tst.w	oYVel(a0)			; Were we moving upwards?
	bpl.s	.End				; If not, branch
	move.w	#0,oYVel(a0)			; If so, stop moving vertically

.End:
	rts

.NotCeiling:
	tst.w	oYVel(a0)			; Are we moving upwards?
	bmi.s	.End2				; If so, branch

	bsr.w	Player_CheckFloor		; Are we colliding with the floor?
	tst.w	d1
	bpl.s	.End2				; If not, branch

	add.w	d1,oY(a0)			; Move outside of the floor
	move.b	d3,oAngle(a0)			; Set angle
	bsr.w	Player_ResetOnFloor		; Reset flags
	move.b	#0,oAnim(a0)			; Set animation to walking animation
	move.w	#0,oYVel(a0)			; Stop moving vertically
	move.w	oXVel(a0),oPlayerGVel(a0)	; Set landing speed

.End2:
	rts

; -------------------------------------------------------------------------
; Reset flags for when the player lands on the floor
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

Player_ResetOnFloor:
	btst	#4,oStatus(a0)			; Did we jump after rolling?
	beq.s	.NoRollJump			; If not, branch
	nop

.NoRollJump:
	bclr	#5,oStatus(a0)			; Stop puishing
 	bclr	#1,oStatus(a0)			; Mark as on the ground
	bclr	#4,oStatus(a0)			; Clear roll jump flag

	btst	#2,oStatus(a0)			; Did we land from a jump?
	beq.s	.NotJumping			; If not, branch
	bclr	#2,oStatus(a0)			; Mark as not jumping

	tst.b	miniSonic			; Are we miniature?
	beq.s	.NormalSize			; If not, branch

	move.b	#$A,oYRadius(a0)		; Restore miniature hitbox size
	move.b	#5,oXRadius(a0)
	subq.w	#2,oY(a0)
	bra.s	.LandSound			; Continue resetting more flags

.NormalSize:
	move.b	#$13,oYRadius(a0)		; Restore hitbox size
	move.b	#9,oXRadius(a0)
	subq.w	#5,oY(a0)

.LandSound:
	move.b	#0,oAnim(a0)			; Set animation to walking animation
	move.w	#$AB,d0				; Play charge stop sound
	jsr	PlayFMSound

.NotJumping:
	move.b	#0,oPlayerJump(a0)		; Clear jumping flag
	move.w	#0,scoreChain.w			; Clear chain bonus counter
	rts

; -------------------------------------------------------------------------
; Reset flags for when the player lands on a steep slope
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

Player_ResetOnSteepSlope:
	bclr	#5,oStatus(a0)			; Stop puishing
 	bclr	#1,oStatus(a0)			; Mark as on the ground
	bclr	#4,oStatus(a0)			; Clear roll jump flag
	move.b	#0,oPlayerJump(a0)		; Clear jumping flag
	move.w	#0,scoreChain.w			; Clear chain bonus counter
	rts

; -------------------------------------------------------------------------
; Sonic's hurt routine
; -------------------------------------------------------------------------

ObjSonic_Hurt:
	jsr	ObjMove				; Apply velocity

	addi.w	#$30,oYVel(a0)			; Make gravity stronger
	btst	#6,oStatus(a0)			; Is Sonic underwater?
	beq.s	.NoWater			; If not, branch
	subi.w	#$20,oYVel(a0)			; Make the gravity less strong underwater

.NoWater:
	jsr	ObjSonic_Null			; Some kind of nulled out function

	bsr.w	ObjSonic_HurtChkLand		; Check for landing on the ground
	bsr.w	ObjSonic_LevelBound		; Handle level boundary collision
	bsr.w	ObjSonic_RecordPos		; Save current position into the position buffer
	bsr.w	ObjSonic_Animate		; Animate sprite

	jmp	DrawObject			; Draw sprite

; -------------------------------------------------------------------------
; Check for Sonic landing on the ground while hurting
; -------------------------------------------------------------------------

ObjSonic_HurtChkLand:
	move.w	bottomBound.w,d0		; Have we gone past the bottom level boundary?
	addi.w	#224,d0
	cmp.w	oY(a0),d0
	bcs.w	KillPlayer			; If so, branch

	bsr.w	Player_LevelColInAir		; Handle level collision
	btst	#1,oStatus(a0)			; Are we still in the air?
	bne.s	.End				; If so, branch

	moveq	#0,d0				; Stop movement
	move.w	d0,oYVel(a0)
	move.w	d0,oXVel(a0)
	move.w	d0,oPlayerGVel(a0)
	move.b	#0,oAnim(a0)			; Set animation to walking animation
	subq.b	#2,oRoutine(a0)			; Go back to the main routine
	move.w	#120,oPlayerHurt(a0)		; Set hurt time

.End:
	rts

; -------------------------------------------------------------------------
; Sonic's death routine
; -------------------------------------------------------------------------

ObjSonic_Dead:
	bsr.w	ObjSonic_DeadChkGone		; Check if we have gone offscreen

	jsr	ObjMoveGrv			; Apply velocity
	bsr.w	ObjSonic_RecordPos		; Save current position into the position buffer
	bsr.w	ObjSonic_Animate		; Animate sprite

	jmp	DrawObject			; Draw sprite

; -------------------------------------------------------------------------
; Check for Sonic going offscreen when he's dead
; -------------------------------------------------------------------------

ObjSonic_DeadChkGone:
	move.w	bottomBound.w,d0		; Have we gone past the bottom level boundary?
	addi.w	#256,d0
	cmp.w	oY(a0),d0
	bcc.w	.End				; If not, branch

	move.w	#-$38,oYVel(a0)			; Make us go upwards a little
	addq.b	#2,oRoutine(a0)			; Set routine to gone

	clr.b	updateTime			; Stop the level timer
	addq.b	#1,updateLives			; Decrement life counter
	subq.b	#1,lifeCount
	bpl.s	.CapLives			; If we still have lives left, branch
	clr.b	lifeCount			; Cap lives at 0

.CapLives:
	cmpi.b	#$2B,oAnim(a0)			; Were we giving up from boredom?
	beq.s	.LoadGameOver			; If so, branch

	tst.b	timeAttackMode			; Are we in time attack mode?
	beq.s	.LoadGameOver			; If not, branch

	move.b	#0,lifeCount			; Set lives to 0
	bra.s	.ResetDelay			; Continue setting the delay timer

.LoadGameOver:
	jsr	FindObjSlot			; Load the game over text object
	move.b	#$3B,oID(a1)

	move.w	#8*60,oPlayerReset(a0)		; Set game over delay timer to 8 seconds
	tst.b	lifeCount			; Do we still have lives left?
	beq.s	.End				; If not, branch

.ResetDelay:
	move.w	#60,oPlayerReset(a0)		; Set delay timer to 1 second

.End:
	rts

; -------------------------------------------------------------------------
; Handle Sonic's death delay timer and handle level reseting
; -------------------------------------------------------------------------

ObjSonic_Restart:
	tst.w	oPlayerReset(a0)		; Is the delay timer active?
	beq.w	.End				; If not, branch
	subq.w	#1,oPlayerReset(a0)		; Decrement the delay timer
	bne.w	.End				; If it hasn't run out, branch

	move.w	#1,levelRestart			; Set to restart the level

	jsr	StopZ80				; Allow conditional jumps to jump in FM sound effects
	move.b	#1,Z80RAM+$1C3E
	jsr	StartZ80

	bsr.w	ResetRespawnTable		; Reset the respawn table
	clr.l	flowerCount			; Reset flower count

	tst.b	lastCheckpoint			; Have we hit a checkpoint?
	bne.s	.Skip				; If so, branch
	cmpi.b	#1,timeZone			; Are we in the present?
	bne.s	.Skip				; If not, branch
	bclr	#1,plcLoadFlags			; Set to reload the title card upon restarting

.Skip:
	move.w	#$E,d0				; Set to fade out music

	tst.b	lifeCount			; Are we out of lives?
	beq.s	.SendCmd			; If so, branch
	cmpi.b	#1,timeZone			; Are we in the present?
	bne.s	.ClearFlag			; If not, branch
	tst.b	lastCheckpoint			; Have we hit a checkpoint?
	beq.s	.SendCmd			; If not, branch

	move.b	#1,resetLevelFlags		; Mark as restarted midway through the level
	bra.s	.SendCmd			; Continue setting the fade out command

.ClearFlag:
	clr.b	resetLevelFlags			; Set to fully restart the level

.SendCmd:
	bra.w	SubCPUCmd			; Set the fade out command

.End:
	rts

; -------------------------------------------------------------------------
; Handle special chunks for Sonic
; -------------------------------------------------------------------------

ObjSonic_SpecialChunks:
	cmpi.b	#3,levelZone			; Are we in Quartz Quadrant?
	beq.s	.HasSpecChunks			; If so, branch
	cmpi.b	#5,levelZone			; Are we in Stardust Speedway?
	beq.s	.HasSpecChunks			; If so, branch
	cmpi.b	#2,levelZone			; Are we in Tidal Tempest?
	beq.s	.HasSpecChunks			; If so, branch
	tst.b	levelZone			; Are we in Palmtree Panic?
	bne.w	.End				; If not, branch

.HasSpecChunks:
	move.w	oY(a0),d0			; Get current chunk that we are in
	lsr.w	#1,d0
	andi.w	#$380,d0
	move.b	oX(a0),d1
	andi.w	#$7F,d1
	add.w	d1,d0
	lea	levelLayout.w,a1
	move.b	(a1,d0.w),d1

; -------------------------------------------------------------------------

	cmp.b	specialChunks+2.w,d1		; Are we in a special roll tunnel?
	bne.s	.NotRoll			; If not, branch
	tst.b	levelZone			; Are we in Palmtree Panic?
	bne.w	.RollTunnel			; If not, branch

	move.w	oY(a0),d0			; Is our Y position greater than or equal to $90?
	andi.w	#$FF,d0
	cmpi.w	#$90,d0
	bcc.w	.RollTunnel			; If so, branch

	bra.s	.CheckIfLoop			; Continue checking other chunks

.NotRoll:
	cmp.b	specialChunks+3.w,d1		; Are we in a regular roll tunnel?
	beq.w	.RollTunnel			; If so, branch

; -------------------------------------------------------------------------

.CheckIfLoop:
	cmp.b	specialChunks.w,d1		; Are we on a loop?
	beq.s	.CheckIfLeft			; If so, branch
	cmp.b	specialChunks+1.w,d1		; Are we on a special loop?
	beq.s	.CheckIfInAir			; If so, branch

	bclr	#6,oRender(a0)			; Set to lower path layer
	rts

.CheckIfInAir:
	cmpi.b	#5,levelZone			; Are we in Stardust Speedway?
	beq.w	.SSZ				; If so, branch

	btst	#1,oStatus(a0)			; Are we in the air?
	beq.s	.CheckIfLeft			; If not, branch
	bclr	#6,oRender(a0)			; Set to lower path layer
	rts

.CheckIfLeft:
	move.w	oX(a0),d2			; Are we left of the loop check section?
	cmpi.b	#$2C,d2
	bcc.s	.CheckIfRight			; If not, branch
	bclr	#6,oRender(a0)			; Set to lower path layer
	rts

.CheckIfRight:
	cmpi.b	#$E0,d2				; Are we right of the loop check section?
	bcs.s	.CheckAngle			; If not, branch
	bset	#6,oRender(a0)			; Set to higher path layer
	rts

.CheckAngle:
	btst	#6,oRender(a0)			; Are we on the higher path layer?
	bne.s	.HighPath			; If so, branch

	move.b	oAngle(a0),d1			; Get angle
	beq.s	.End				; If we are flat on the floor, branch

	cmpi.b	#$80,d1				; Are right of the path swap position?
	bhi.s	.End				; If so, branch
	bset	#6,oRender(a0)			; Set to higher path layer
	rts

.HighPath:
	move.b	oAngle(a0),d1			; Are left of the path swap position?
	cmpi.b	#$80,d1
	bls.s	.End				; If so, branch
	bclr	#6,oRender(a0)			; Set to lower path layer

.End:
	rts

; -------------------------------------------------------------------------

.RollTunnel:
	if REGION<>USA
		btst	#2,oStatus(a0)		; Are we already rolling?
		bne.s	.Roll			; If so, branch
		move.w	#$9C,d0			; Play roll sound
		jsr	PlayFMSound
		
.Roll:
	endif
	jmp	ObjSonic_StartRoll		; Start rolling

; -------------------------------------------------------------------------

.SSZ:
	tst.w	oYVel(a0)			; Are we moving upwards?
	bmi.s	.End2				; If so, branch

	move.w	oY(a0),d1			; Get position within chunk
	andi.w	#$FF,d1
	move.w	oX(a0),d0
	andi.w	#$FF,d0

	cmpi.w	#$80,d0				; Are we on the right side of the chunk?
	bcc.s	.CheckIfAbove			; If so, branch
	cmpi.w	#$38,d1				; Are we at the top of the chunk?
	bcs.s	.SetLowPlane			; If so, branch
	cmpi.w	#$80,d1				; Are we on the top side of the chunk?
	bcs.s	.End2				; If so, branch

.SetHighPlane:
	bclr	#6,oRender(a0)			; Set to lower path layer
	rts

.SetLowPlane:
	bset	#6,oRender(a0)			; Set to higher path layer
	rts

.CheckIfAbove:
	cmpi.w	#$38,d1				; Are we at the top of the chunk?
	bcs.s	.SetHighPlane			; If so, branch
	cmpi.w	#$80,d1				; Are we on the bottom side of the chunk?
	bcc.s	.SetLowPlane			; If so, branch

.End2:
	rts

; -------------------------------------------------------------------------
; Animate Sonic's sprite
; -------------------------------------------------------------------------

ObjSonic_Animate:
	lea	Ani_Sonic,a1			; Get animation script

	moveq	#0,d0				; Get current animation
	move.b	oAnim(a0),d0
	cmp.b	oPrevAnim(a0),d0		; Are we changing animations?
	beq.s	.Do				; If not, branch

	move.b	d0,oPrevAnim(a0)		; Reset animation flags
	move.b	#0,oAnimFrame(a0)
	move.b	#0,oAnimTime(a0)

.Do:
	bsr.w	ObjSonic_GetMiniAnim		; If we are miniature, get the mini version of the current animation

	add.w	d0,d0				; Get pointer to animation data
	adda.w	(a1,d0.w),a1
	move.b	(a1),d0				; Get animation speed/special flag
	bmi.s	.SpecialAnim			; If it's a special flag, branch

	move.b	oStatus(a0),d1			; Apply status flip flags to render flip flags
	andi.b	#1,d1
	andi.b	#$FC,oRender(a0)
	or.b	d1,oRender(a0)

	subq.b	#1,oAnimTime(a0)		; Decrement frame duration time
	bpl.s	.AniDelay			; If it hasn't run out, branch
	move.b	d0,oAnimTime(a0)		; Reset frame duration time

; -------------------------------------------------------------------------

.RunAnimScript:
	moveq	#0,d1				; Get animation frame
	move.b	oAnimFrame(a0),d1
	move.b	1(a1,d1.w),d0
	beq.s	.AniNext			; If it's a frame ID, branch
	bpl.s	.AniNext
	cmpi.b	#$FD,d0				; Is it a flag?
	bge.s	.AniFF				; If so, branch

.AniNext:
	move.b	d0,oMapFrame(a0)		; Update animation frame
	addq.b	#1,oAnimFrame(a0)

.AniDelay:
	rts

.AniFF:
	addq.b	#1,d0				; Is the flag $FF (loop)?
	bne.s	.AniFE				; If not, branch

	move.b	#0,oAnimFrame(a0)		; Set animation script frame back to 0
	move.b	1(a1),d0			; Get animation frame at that point
	bra.s	.AniNext

.AniFE:
	addq.b	#1,d0				; Is the flag $FE (loop back to frame)?
	bne.s	.AniFD

	move.b	2(a1,d1.w),d0			; Get animation script frame to go back to
	sub.b	d0,oAnimFrame(a0)
	sub.b	d0,d1				; Get animation frame at that point
	move.b	1(a1,d1.w),d0
	bra.s	.AniNext

.AniFD:
	addq.b	#1,d0				; Is the flag $FD (new animation)?
	bne.s	.End
	move.b	2(a1,d1.w),oAnim(a0)		; Set new animation ID

.End:
	rts

; -------------------------------------------------------------------------

.SpecialAnim:
	subq.b	#1,oAnimTime(a0)		; Decrement frame duration time
	bpl.s	.AniDelay			; If it hasn't run out, branch

	addq.b	#1,d0				; Is this special animation $FF (walking/running)?
	bne.w	.RollAnim			; If not, branch

	tst.b	miniSonic			; Are we minature?
	bne.w	.MiniSonicRun			; If so, branch

	moveq	#0,d1				; Initialize flip flags
	move.b	oAngle(a0),d0			; Get angle
	move.b	oStatus(a0),d2			; Are we flipped horizontally?
	andi.b	#1,d2
	bne.s	.Flipped			; If so, branch
	not.b	d0				; If not, flip the angle

.Flipped:
	btst	#1,oPlayerCtrl(a0)		; Are we on a 3D ramp?
	bne.s	.3DRamp				; If so, branch
	addi.b	#$10,d0				; Center the angle
	bra.s	.CheckInvert			; Continue setting up the animation

.3DRamp:
	addq.b	#8,d0				; Center the angle for the 3D ramp

.CheckInvert:
	bpl.s	.NoInvert			; If we aren't on an angle where we should flip the sprite, branch
	moveq	#3,d1				; If we are, set the flip flags accordingly

.NoInvert:
	andi.b	#$FC,oRender(a0)		; Apply angle flip flags to render flip flags
	eor.b	d1,d2
	or.b	d2,oRender(a0)

	btst	#5,oStatus(a0)			; Are we pushing on something?
	bne.w	.PushAnim			; If so, branch

	move.w	oPlayerGVel(a0),d2		; Get ground speed
	bpl.s	.CheckSpeed
	neg.w	d2

.CheckSpeed:
	btst	#1,oPlayerCtrl(a0)		; Are we on a 3D ramp?
	beq.s	.No3DRamp			; If not, branch

	lsr.b	#4,d0				; Get offset of the angled sprites we need for 3D running
	lsl.b	#1,d0				; ((((angle + 8) / 8) & 0xE) * 2)
	andi.b	#$E,d0				; (angle is NOT'd if we are facing right)

	lea	SonAni_Run3D,a1			; Get 3D running sprites
	bra.s	.GotRunAnim			; Continue setting up animation

.No3DRamp:
	lsr.b	#4,d0				; Get offset of the angled sprites we need for running and peelout
	andi.b	#6,d0				; ((((angle + 16) / 16) & 6) * 2)
						; (angle is NOT'd if we are facing right)

	lea	SonAni_Peelout,a1		; Get peelout sprites
	cmpi.w	#$A00,d2			; Are we running at peelout speed?
	bcc.s	.GotRunAnim			; If so, branch
	lea	SonAni_Run,a1			; Get running sprites
	cmpi.w	#$600,d2			; Are we running at running speed?
	bcc.s	.GotRunAnim			; If so, branch
	lea	SonAni_Walk,a1			; Get walking sprites

	move.b	d0,d1				; Get offset of the angled sprites we need for walking
	lsr.b	#1,d1				; ((((angle + 16) / 16) & 6) * 3)
	add.b	d1,d0				; (angle is NOT'd if we are facing right)

.GotRunAnim:
	add.b	d0,d0

	move.b	d0,d3				; Get animation duration
	neg.w	d2				; max(-ground speed + 8, 0)
	addi.w	#$800,d2
	bpl.s	.BelowMax
	moveq	#0,d2

.BelowMax:
	lsr.w	#8,d2
	move.b	d2,oAnimTime(a0)

	bsr.w	.RunAnimScript			; Run animation script
	add.b	d3,oMapFrame(a0)		; Add angle offset
	rts

; -------------------------------------------------------------------------

.RollAnim:
	addq.b	#1,d0				; Is this special animation $FE (rolling)?
	bne.s	.CheckPush			; If not, branch

	move.w	oPlayerGVel(a0),d2		; Get ground speed
	bpl.s	.CheckSpeed2
	neg.w	d2

.CheckSpeed2:
	lea	SonAni_RollMini,a1		; Get mini rolling sprites
	tst.b	miniSonic			; Are we miniature?
	bne.s	.GotRollAnim			; If so, branch

	lea	SonAni_RollFast,a1		; Get fast rolling sprites
	btst	#1,oPlayerCtrl(a0)		; Are we on a 3D ramp?
	beq.s	.No3DRoll			; If not, branch
	move.b	oAngle(a0),d0			; Are we going upwards on the ramp?
	addi.b	#$10,d0
	andi.b	#$C0,d0
	beq.s	.GotRollAnim			; If not, branch
	lea	SonAni_Roll3D,a1		; Get 3D rolling sprites
	bra.s	.GotRollAnim			; Continue setting up animation

.No3DRoll:
	cmpi.w	#$600,d2			; Are we rolling fast?
	bcc.s	.GotRollAnim			; If so, branch
	lea	SonAni_Roll,a1			; If not, use the regular rolling sprites

.GotRollAnim:
	neg.w	d2				; Get animation duration
	addi.w	#$400,d2			; max(-ground speed + 4, 0)
	bpl.s	.BelowMax2
	moveq	#0,d2

.BelowMax2:
	lsr.w	#8,d2
	move.b	d2,oAnimTime(a0)

	move.b	oStatus(a0),d1			; Apply status flip flags to render flip flags
	andi.b	#1,d1
	andi.b	#$FC,oRender(a0)
	or.b	d1,oRender(a0)

	bra.w	.RunAnimScript			; Run animation script

; -------------------------------------------------------------------------

.CheckPush:
	addq.b	#1,d0				; Is this special animation $FD (pushing)?
	bne.s	.FrozenAnim			; If not, branch

.PushAnim:
	move.w	oPlayerGVel(a0),d2		; Get ground speed (negated)
	bmi.s	.CheckSpeed3
	neg.w	d2

.CheckSpeed3:
	addi.w	#$800,d2			; Get animation duration
	bpl.s	.BelowMax3			; max(-ground speed + 8, 0) * 4
	moveq	#0,d2

.BelowMax3:
	lsr.w	#6,d2
	move.b	d2,oAnimTime(a0)

	lea	SonAni_PushMini,a1		; Get mini pushing sprites
	tst.b	miniSonic			; Are we miniature?
	bne.s	.GotPushAnim			; If so, branch
	lea	SonAni_Push,a1			; Get normal pushing sprites

.GotPushAnim:
	move.b	oStatus(a0),d1			; Apply status flip flags to render flip flags
	andi.b	#1,d1
	andi.b	#$FC,oRender(a0)
	or.b	d1,oRender(a0)

	bra.w	.RunAnimScript			; Run animation script

; -------------------------------------------------------------------------

.FrozenAnim:
	moveq	#0,d1				; This is special animation $FC (frozen animation)
	move.b	oAnimFrame(a0),d1		; Get animation frame
	move.b	1(a1,d1.w),oMapFrame(a0)
	move.b	#0,oAnimTime(a0)		; Keep duration at 0 and don't advance the animation frame
	rts

; -------------------------------------------------------------------------

.MiniSonicRun:
	moveq	#0,d1				; Initialize flip flags
	move.b	oAngle(a0),d0			; Get angle
	move.b	oStatus(a0),d2			; Are we flipped horizontally?
	andi.b	#1,d2
	bne.s	.Flipped2			; If so, branch
	not.b	d0				; If not, flip the angle

.Flipped2:
	addi.b	#$10,d0				; Center the angle
	bpl.s	.NoFlip2			; If we aren't on an angle where we should flip the sprite, branch
	moveq	#0,d1				; If we are, then don't set the flags anyways

.NoFlip2:
	andi.b	#$FC,oRender(a0)		; Apply status horizontal flip flag to render flip flags
	or.b	d2,oRender(a0)

	addi.b	#$30,d0				; Are we running on the floor?
	cmpi.b	#$60,d0
	bcs.s	.MiniOnFloor			; If so, branch

	bset	#2,oStatus(a0)			; Mark as rolling
	move.b	#$A,oYRadius(a0)		; Set miniature rolling hitbox size
	move.b	#5,oXRadius(a0)
	move.b	#$FF,d0				; Go run the rolling animation instead
	bra.w	.RollAnim

.MiniOnFloor:
	move.w	oPlayerGVel(a0),d2		; Get ground speed
	bpl.s	.CheckSpeed4
	neg.w	d2

.CheckSpeed4:
	lea	SonAni_RunMini,a1		; Get mini running sprites
	cmpi.w	#$600,d2			; Are we running at running speed?
	bcc.s	.GotRunAnim2			; If so, branch
	lea	SonAni_WalkMini,a1		; Get mini walking sprites

.GotRunAnim2:
	neg.w	d2				; Get animation duration
	addi.w	#$800,d2			; max(-ground speed + 8, 0)
	bpl.s	.BelowMax4
	moveq	#0,d2

.BelowMax4:
	lsr.w	#8,d2
	move.b	d2,oAnimTime(a0)

	bra.w	.RunAnimScript			; Run animation script

; -------------------------------------------------------------------------
; Get the mini version of Sonic's animation if Sonic is miniature
; -------------------------------------------------------------------------

ObjSonic_GetMiniAnim:
	tst.b	miniSonic			; Are we miniature?
	beq.s	.End				; If not, branch
	move.b	.MiniAnims(pc,d0.w),d0		; Get mini animation ID

.End:
	rts

; -------------------------------------------------------------------------

.MiniAnims:
	dc.b	$21				; $00
	dc.b	$18				; $01
	dc.b	$23				; $02
	dc.b	$23				; $03
	dc.b	$27				; $04
	dc.b	$1F				; $05
	dc.b	$26				; $06
	dc.b	$28				; $07
	dc.b	$20				; $08
	dc.b	$09				; $09
	dc.b	$0A				; $0A
	dc.b	$0B				; $0B
	dc.b	$0C				; $0C
	dc.b	$24				; $0D
	dc.b	$0E				; $0E
	dc.b	$0F				; $0F
	dc.b	$28				; $10
	dc.b	$11				; $11
	dc.b	$12				; $12
	dc.b	$13				; $13
	dc.b	$14				; $14
	dc.b	$15				; $15
	dc.b	$16				; $16
	dc.b	$17				; $17
	dc.b	$18				; $18
	dc.b	$19				; $19
	dc.b	$25				; $1A
	dc.b	$25				; $1B
	dc.b	$1C				; $1C
	dc.b	$1D				; $1D
	dc.b	$1E				; $1E
	dc.b	$1F				; $1F
	dc.b	$20				; $20
	dc.b	$21				; $21
	dc.b	$22				; $22
	dc.b	$23				; $23
	dc.b	$24				; $24
	dc.b	$25				; $25
	dc.b	$26				; $26
	dc.b	$27				; $27
	dc.b	$28				; $28
	dc.b	$29				; $29
	dc.b	$2A				; $2A
	dc.b	$30				; $2B
	dc.b	$2C				; $2C
	dc.b	$2D				; $2D
	dc.b	$2E				; $2E
	dc.b	$2F				; $2F
	dc.b	$00				; $30
	dc.b	$00				; $31
	dc.b	$00				; $32
	dc.b	$00				; $33
	dc.b	$00				; $34
	dc.b	$00				; $35
	dc.b	$00				; $36
	dc.b	$00				; $37
	dc.b	$39				; $38
	dc.b	$00				; $39
	dc.b	$00				; $3A
	dc.b	$00				; $3B
	dc.b	$00				; $3C
	dc.b	$00				; $3D
	dc.b	$00				; $3E
	dc.b	$00				; $3F
	dc.b	$00				; $40
	dc.b	$00				; $41
	dc.b	$00				; $42
	dc.b	$00				; $43
	dc.b	$00				; $44
	dc.b	$00				; $45
	dc.b	$00				; $46
	dc.b	$00				; $47
	dc.b	$00				; $48
	dc.b	$00				; $49
	dc.b	$00				; $4A
	dc.b	$00				; $4B
	dc.b	$00				; $4C
	dc.b	$00				; $4D
	dc.b	$00				; $4E
	dc.b	$00				; $4F

; -------------------------------------------------------------------------
; Sonic's animation script
; -------------------------------------------------------------------------

Ani_Sonic:
	include	"level/r1/objects/sonic/anim.asm"
	even

; -------------------------------------------------------------------------
; Load the tiles for Sonic's current sprite frame
; -------------------------------------------------------------------------

LoadSonicDynPLC:
	tst.b	(a0)				; Are we even loaded at all?
	beq.w	.End				; If not, branch

	lea	sonicLastFrame.w,a2		; Get the ID of the last sprite frame that was loaded
	moveq	#0,d0
	move.b	oMapFrame(a0),d0		; Get current sprite frame ID
	cmp.b	(a2),d0				; Has our sprite frame changed?
	beq.s	.End				; If not, branch
	move.b	d0,(a2)				; Update last sprite frame ID

	lea	DPLC_Sonic,a2			; Get DPLC data for our current sprite frame
	add.w	d0,d0
	adda.w	(a2,d0.w),a2

	moveq	#0,d1				; Get number of DPLC entries
	move.w	(a2)+,d1
	subq.b	#1,d1
	bmi.s	.End				; If there are none, branch

	lea	sonicArtBuf.w,a3		; Get sprite frame tile buffer
	move.b	#1,updateSonicArt.w		; Mark buffer as updated

.PieceLoop:
	moveq	#0,d2				; Get number of tiles to load
	move.b	(a2)+,d2
	move.w	d2,d0
	lsr.b	#4,d0

	lsl.w	#8,d2				; Get starting tile to load
	move.b	(a2)+,d2
	andi.w	#$FFF,d2
	lsl.l	#5,d2
	lea	ArtUnc_Sonic,a1
	adda.l	d2,a1

.CopyPieceLoop:
	movem.l	(a1)+,d2-d6/a4-a6		; Load tile data for this entry
	movem.l	d2-d6/a4-a6,(a3)
	lea	$20(a3),a3
	dbf	d0,.CopyPieceLoop		; Loop until all tiles in this entry are loaded

	dbf	d1,.PieceLoop			; Loop until all entries are processed

.End:
	rts

; -------------------------------------------------------------------------
; Check if Sonic is on a pinball flipper, and if so, get the angle to launch
; Sonic at when jumping off of it
; -------------------------------------------------------------------------
; RETURNS:
;	d0.b - Angle to launch at
;	d2.w - Speed to launch at
;	eq/ne - Was on flipper/Was not on flipper
; -------------------------------------------------------------------------

ObjSonic_ChkFlipper:
	moveq	#0,d0				; Get object we are standing on
	move.b	oPlayerStandObj(a0),d0
	lsl.w	#6,d0
	addi.l	#objPlayerSlot&$FFFFFF,d0
	movea.l	d0,a1

	cmpi.b	#$1E,oID(a1)			; Is it a pinball flipper from CCZ?
	bne.s	.End				; If not, branch

	move.w	#$98,d0				; Play spring sound
	jsr	PlayFMSound
	move.b	#1,oAnim(a1)			; Set flipper animation to move

	move.w	oX(a1),d1			; Get angle in which to launch at
	move.w	oY(a1),d2			; arctan((object Y + 24 - player Y) / (object X - player X))
	addi.w	#24,d2
	sub.w	oX(a0),d1
	sub.w	oY(a0),d2
	jsr	CalcAngle

	moveq	#0,d2				; Get the amount of force used to get the speed to launch us at, depending on
	move.b	oWidth(a1),d2			; the distance we are from the flipper's rotation pivot
	move.w	oX(a0),d3			; (object width + (player X - object X))
	sub.w	oX(a1),d3
	add.w	d2,d3

	btst	#0,oStatus(a1)			; Is the flipper object flipped horizontally?
	bne.s	.XFlip				; If so, branch

	move.w	#64,d1				; Invert the force to account for the horizontal flip
	sub.w	d3,d1				; (64 - (object width + (player X - object X)))
	move.w	d1,d3

.XFlip:
	move.w	#-$A00,d2			; Get the speed to launch us at
	move.w	d2,d1				; (-10 + ((-10 * force) / 64))
	ext.l	d1
	muls.w	d3,d1
	divs.w	#64,d1
	add.w	d1,d2

	moveq	#0,d1				; Mark as having been on the flipper

.End:
	rts

; -------------------------------------------------------------------------
; Fade out music
; -------------------------------------------------------------------------

FadeOutMusic:
	move.w	#$E,d0

; -------------------------------------------------------------------------
; Send a command to the Sub CPU
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Command ID
; -------------------------------------------------------------------------

SubCPUCmd:
	cmpi.w	#$67,d0				; Is this the command to play the boss music?
	bne.s	.NotBossMusic			; If not, branch
	move.b	#1,bossMusicPlaying		; Mark boss music as being played

.NotBossMusic:
	move.w	d0,GACOMCMD0			; Set command ID

.WaitSubCPU:
	move.w	GACOMSTAT0,d0			; Has the Sub CPU received the command?
	beq.s	.WaitSubCPU			; If not, wait
	cmp.w	GACOMSTAT0,d0
	bne.s	.WaitSubCPU			; If not, wait

	move.w	#0,GACOMCMD0			; Mark as ready to send commands again

.WaitSubCPUDone:
	move.w	GACOMSTAT0,d0			; Is the Sub CPU done processing the command?
	bne.s	.WaitSubCPUDone			; If not, wait
	move.w	GACOMSTAT0,d0
	bne.s	.WaitSubCPUDone			; If not, wait
	rts

; -------------------------------------------------------------------------

	dc.w	0

; -------------------------------------------------------------------------
; Animate an object's sprite
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Object RAM
; -------------------------------------------------------------------------

AnimateObject:
	moveq	#0,d0				; Get current animation
	move.b	oAnim(a0),d0
	cmp.b	oPrevAnim(a0),d0		; Are we changing animations?
	beq.s	.Do				; If not, branch

	move.b	d0,oPrevAnim(a0)		; Reset animation flags
	move.b	#0,oAnimFrame(a0)
	move.b	#0,oAnimTime(a0)

.Do:
	subq.b	#1,oAnimTime(a0)
	bpl.s	.End
	add.w	d0,d0				; Get pointer to animation data
	adda.w	(a1,d0.w),a1
	move.b	(a1),oAnimTime(a0)		; Get animation speed

	moveq	#0,d1				; Get animation frame
	move.b	oAnimFrame(a0),d1
	move.b	1(a1,d1.w),d0
	bmi.s	.AniFF				; If it's a flag, branch

.AniNext:
	move.b	d0,d1				; Copy flip flags
	andi.b	#$1F,d0				; Set sprite frame
	move.b	d0,oMapFrame(a0)

	move.b	oStatus(a0),d0			; Apply status flip flags to render flip flags
	rol.b	#3,d1
	eor.b	d0,d1
	andi.b	#3,d1
	andi.b	#$FC,oRender(a0)
	or.b	d1,oRender(a0)

	addq.b	#1,oAnimFrame(a0)		; Update animation frame

.End:
	rts

; -------------------------------------------------------------------------

.AniFF:
	addq.b	#1,d0				; Is the flag $FF (loop)?
	bne.s	.AniFE				; If not, branch

	move.b	#0,oAnimFrame(a0)		; Set animation script frame back to 0
	move.b	1(a1),d0			; Get animation frame at that point
	bra.s	.AniNext

.AniFE:
	addq.b	#1,d0				; Is the flag $FE (loop back to frame)?
	bne.s	.AniFD

	move.b	2(a1,d1.w),d0			; Get animation script frame to go back to
	sub.b	d0,oAnimFrame(a0)
	sub.b	d0,d1				; Get animation frame at that point
	move.b	1(a1,d1.w),d0
	bra.s	.AniNext

.AniFD:
	addq.b	#1,d0				; Is the flag $FD (new animation)?
	bne.s	.AniFC
	move.b	2(a1,d1.w),oAnim(a0)		; Set new animation ID

.AniFC:
	addq.b	#1,d0				; Is the flag $FC (increment routine ID)?
	bne.s	.AniFB				; If not, branch
	addq.b	#2,oRoutine(a0)			; Increment routine ID

.AniFB:
	addq.b	#1,d0				; Is the flag $FB (loop and reset secondary routine ID)?
	bne.s	.AniFA				; If not, branch
	move.b	#0,oAnimFrame(a0)		; Set animation script frame back to 0
	clr.b	oRoutine2(a0)			; Reset secondary routine ID

.AniFA:
	addq.b	#1,d0				; Is the flag $FA (increment secondary routine ID)?
	bne.s	.End2				; If not, branch
	addq.b	#2,oRoutine2(a0)		; Increment secondary routine ID

.End2:
	rts

; -------------------------------------------------------------------------
; Save data at a checkpoint
; -------------------------------------------------------------------------

ObjCheckpoint_SaveData:				; Save some values
	move.b	resetLevelFlags,savedResetLvlFlags
	move.w	objPlayerSlot+oX.w,savedX
	move.w	objPlayerSlot+oY.w,savedY
	move.b	waterRoutine.w,savedWaterRout
	move.w	bottomBound.w,savedBtmBound
	move.w	cameraX.w,savedCamX
	move.w	cameraY.w,savedCamY
	move.w	cameraBgX.w,savedCamBgX
	move.w	cameraBgY.w,savedCamBgY
	move.w	cameraBg2X.w,savedCamBg2X
	move.w	cameraBg2Y.w,savedCamBg2Y
	move.w	cameraBg3X.w,savedCamBg3X
	move.w	cameraBg3Y.w,savedCamBg3Y
	move.w	waterHeight2.w,savedWaterHeight
	move.b	waterRoutine.w,savedWaterRout
	move.b	waterFullscreen.w,savedWaterFull

	move.l	levelTime,d0			; Move the level timer to 5:00 if we are past that
	cmpi.l	#$50000,d0
	bcs.s	.StoreTime
	move.l	#$50000,d0

.StoreTime:
	move.l	d0,savedTime

	move.b	miniSonic,savedMiniSonic
	rts

; -------------------------------------------------------------------------
; Checkpoint object
; -------------------------------------------------------------------------

oChkPntBallX		EQU	oVar2A		; Ball X origin
oChkPntBallY		EQU	oVar2C		; Ball Y origin
oChkPntActive		EQU	oVar2E		; Activated flag
oChkPntParent		EQU	oVar30		; Parent object
oChkPntBallAngle	EQU	oVar34		; Ball angle

; -------------------------------------------------------------------------

ObjCheckpoint:
	moveq	#0,d0				; Run object routine
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	jsr	DrawObject			; Draw sprite
	jmp	CheckObjDespawnTime		; Check if we should despawn

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjCheckpoint_Init-.Index	; Initialization
	dc.w	ObjCheckpoint_Main-.Index	; Main
	dc.w	ObjCheckpoint_Ball-.Index	; Ball main
	dc.w	ObjCheckpoint_Animate-.Index	; Animation

; -------------------------------------------------------------------------
; Checkpoint initialization routine
; -------------------------------------------------------------------------

ObjCheckpoint_Init:
	addq.b	#2,oRoutine(a0)			; Advance routine

	move.l	#MapSpr_Checkpoint,oMap(a0)	; Set mappings
	move.w	#$6CB,oTile(a0)			; Set base tile
	move.b	#4,oRender(a0)			; Set render flags
	move.b	#8,oWidth(a0)			; Set width
	move.b	#$18,oYRadius(a0)		; Set Y radius
	move.b	#4,oPriority(a0)		; Set priority

	move.b	lastCheckpoint,d0		; Has a later checkpoint already been activated?
	cmp.b	oSubtype(a0),d0
	bcs.s	.Unactivated			; If not, branch

	move.b	#1,oChkPntActive(a0)		; Mark as activated
	bra.s	.GenBall			; Continue initialization

.Unactivated:
	move.b	#$E3,oColType(a0)		; Enable collision

.GenBall:
	jsr	FindObjSlot			; Find a free object slot
	bne.s	.Delete				; If one was not found, don't bother having the checkpoint loaded at all

	move.b	#$13,oID(a1)			; Load the checkpoint ball object
	addq.b	#4,oRoutine(a1)			; Set ball routine to the main ball routine
	tst.b	oChkPntActive(a0)		; Were we already activated?
	beq.s	.Unactivated2			; If not, branch
	addq.b	#2,oRoutine(a1)			; Set ball routine to just animate

.Unactivated2:
	move.l	#MapSpr_Checkpoint,oMap(a1)	; Set ball mappings
	move.w	#$6CB,oTile(a1)			; Set ball base tile
	move.b	#4,oRender(a1)			; Set ball render flags
	move.b	#8,oWidth(a1)			; Set ball width
	move.b	#8,oYRadius(a1)			; Set ball Y radius
	move.b	#3,oPriority(a1)		; Set ball priority
	move.b	#1,oMapFrame(a1)		; Set ball sprite frame
	move.l	a0,oChkPntParent(a1)		; Set ball parent object to us

	move.w	oX(a0),oX(a1)			; Set ball position to our position
	move.w	oY(a0),oY(a1)
	subi.w	#32,oY(a1)			; Offset ball Y position up by 32 pixels

	move.w	oX(a0),oChkPntBallX(a1)		; Set ball center position
	move.w	oY(a0),oChkPntBallY(a1)
	subi.w	#32-8,oChkPntBallY(a1)
	rts

.Delete:
	jmp	DeleteObject			; Delete ourselves

; -------------------------------------------------------------------------
; Main checkpoint routine
; -------------------------------------------------------------------------

ObjCheckpoint_Main:
	tst.b	oChkPntActive(a0)		; Have we been activated?
	bne.s	.End				; If so, branch
	tst.b	oColStatus(a0)			; Has the player touched us yet?
	beq.s	.End				; If not, branch

	clr.b	oColType(a0)			; Disable collision
	move.b	#1,oChkPntActive(a0)		; Mark as activated
	move.b	oSubtype(a0),lastCheckpoint	; Set current checkpoint ID to ours

	move.b	#1,resetLevelFlags		; Mark checkpoint as active in the level
	bsr.w	ObjCheckpoint_SaveData		; Save level data at this point

	move.w	#$AE,d0				; Play checkpoint sound
	jmp	PlayFMSound

.End:
	rts

; -------------------------------------------------------------------------
; Main checkpoint ball routine
; -------------------------------------------------------------------------

ObjCheckpoint_Ball:
	tst.b	oChkPntActive(a0)		; Have we been activated?
	bne.s	.Spin				; If not, branch

	movea.l	oChkPntParent(a0),a1		; Has the main checkpoint object been touched by the player?
	tst.b	oChkPntActive(a1)
	beq.s	.End				; If not, branch

	move.b	#1,oChkPntActive(a0)		; Mark as activated

.Spin:
	addq.b	#8,oChkPntBallAngle(a0)		; Increment angle

	moveq	#0,d0				; Get sine and cosine of our angle
	move.b	oChkPntBallAngle(a0),d0
	jsr	CalcSine

	muls.w	#8,d0				; Get X offset (center X + (sin(angle) * 8))
	lsr.l	#8,d0
	move.w	oChkPntBallX(a0),oX(a0)
	add.w	d0,oX(a0)

	muls.w	#-8,d1				; Get Y offset (center Y + (cos(angle) * -8))
	lsr.l	#8,d1
	move.w	oChkPntBallY(a0),oY(a0)
	add.w	d1,oY(a0)

	tst.b	oChkPntBallAngle(a0)		; Have we fully spun around?
	bne.s	.End				; If not, branch
	addq.b	#2,oRoutine(a0)			; Set routine to just animate now

.End:
	rts

; -------------------------------------------------------------------------
; Checkpoint animation routine
; -------------------------------------------------------------------------

ObjCheckpoint_Animate:
	lea	Ani_Checkpoint,a1		; Animate sprite
	bra.w	AnimateObject

; -------------------------------------------------------------------------
; Dummied out function that originally resumed the music from the drowning
; music in Sonic 1
; -------------------------------------------------------------------------

ResumeMusicS1:
	rts

; -------------------------------------------------------------------------
; Some kind of unused badnik of sorts. Just sits completely still with the
; shield sprite mappings.
; -------------------------------------------------------------------------

oUnusedBadX	EQU	oVar30			; X position copy

; -------------------------------------------------------------------------

ObjUnusedBadnik:
	moveq	#0,d0				; Run object routine
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jmp	.Index(pc,d0.w)

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjUnusedBadnik_Init-.Index	; Initialization
	dc.w	ObjUnusedBadnik_Main-.Index	; Main

; -------------------------------------------------------------------------
; Unused badnik initialization routine
; -------------------------------------------------------------------------

ObjUnusedBadnik_Init:
	btst	#7,oStatus(a0)			; Are we offscreen?
	bne.w	DeleteObject			; If so, delete ourselves

	addq.b	#2,oRoutine(a0)			; Advance routine

	move.b	#4,oRender(a0)			; Set render flags
	move.b	#1,oPriority(a0)		; Set priority
	move.l	#MapSpr_Powerup,oMap(a0)	; Set mappings
	move.w	#$541,oTile(a0)			; Set base tile
	move.w	oX(a0),oUnusedBadX(a0)		; Copy X position
	move.b	#6,oColType(a0)			; Enable collision

; -------------------------------------------------------------------------
; Main unused badnik routine
; -------------------------------------------------------------------------

ObjUnusedBadnik_Main:
	move.w	oUnusedBadX(a0),d0		; Get the object's chunk position
	andi.w	#$FF80,d0
	move.w	cameraX.w,d1			; Get the camera's chunk position
	subi.w	#$80,d1
	andi.w	#$FF80,d1

	sub.w	d1,d0				; Has the object gone offscreen?
	cmpi.w	#$80+(320+$40)+$80,d0
	bhi.w	DeleteObject			; If so, delete ourselves

	lea	Ani_Powerup,a1			; Animate sprite
	bsr.w	AnimateObject
	jmp	DrawObject			; Draw sprite

; -------------------------------------------------------------------------
; Explosion object
; -------------------------------------------------------------------------

oExplodeBadnik	EQU	oRoutine2		; Explosion from badnik flag
oExplodeLoPrio	EQU	oSubtype2		; Low priority sprite flag
oExplodePoints	EQU	oVar3E			; Sprite ID for points object

; -------------------------------------------------------------------------
; Create a points object from an explosion object
; -------------------------------------------------------------------------

ObjExplosion_MakePoints:
	tst.b	oExplodeBadnik(a0)		; Was this explosion from a badnik?
	bne.s	.End				; If not, branch

	moveq	#0,d1				; Get points sprite to display
	move.w	oExplodePoints(a0),d1
	lsr.b	#1,d1
	ori.b	#$80,d1

	jsr	FindObjSlot			; Find a free object slot
	bne.s	.End				; If one was not found, branch

	move.b	#$1C,oID(a1)			; Load points object
	move.w	oX(a0),oX(a1)			; Set the points position to ours
	move.w	oY(a0),oY(a1)
	move.b	d1,oSubtype(a1)			; Set points sprite frame ID

.End:
	rts

; -------------------------------------------------------------------------
; Main explosion object code
; -------------------------------------------------------------------------

ObjExplosion:
	moveq	#0,d0				; Run object routine
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jmp	.Index(pc,d0.w)

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjExplosion_Init-.Index	; Initialization
	dc.w	ObjExplosion_Main-.Index	; Main
	dc.w	ObjExplosion_Done-.Index	; Finished

; -------------------------------------------------------------------------
; Explosion initialization routine
; -------------------------------------------------------------------------

ObjExplosion_Init:
	addq.b	#2,oRoutine(a0)			; Advance routine

	ori.b	#4,oRender(a0)			; Set render flags
	move.b	#1,oPriority(a0)		; Set priority
	move.w	#$8680,oTile(a0)		; Set base tile
	tst.b	oExplodeLoPrio(a0)		; Should our sprite be low priority?
	beq.s	.HighPriority			; If not, branch
	andi.b	#$7F,oTile(a0)			; Clear tile priority bit

.HighPriority:
	move.l	#MapSpr_Explosion,oMap(a0)	; Set mappings

	bsr.s	ObjExplosion_MakePoints		; Make points object if it should

	move.b	#0,oColType(a0)			; Disable collision
	move.b	#0,oAnimFrame(a0)		; Initialize animation
	move.b	#0,oAnimTime(a0)
	move.w	#0,oAnim(a0)
	tst.b	oSubtype(a0)			; Should we use the alternate animation?
	beq.s	ObjExplosion_Main		; If not, branch
	move.w	#$100,oAnim(a0)			; If so, use it

; -------------------------------------------------------------------------
; Main explosion routine
; -------------------------------------------------------------------------

ObjExplosion_Main:
	lea	Ani_Explosion,a1		; Animate sprite
	bsr.w	AnimateObject
	jmp	DrawObject			; Draw sprite

; -------------------------------------------------------------------------
; Explosion finished routine
; -------------------------------------------------------------------------

ObjExplosion_Done:
	tst.b	oExplodeBadnik(a0)		; Was this explosion from a badnik?
	beq.s	.MakeFlower			; If so, branch
	jmp	DeleteObject			; If not, just delete ourselves

.MakeFlower:
	move.b	#$1F,oID(a0)			; Change into a flower object
	move.b	#0,oRoutine(a0)
	rts

; -------------------------------------------------------------------------
; Flower object
; -------------------------------------------------------------------------

oFlowerLoPrio	EQU	oSubtype2		; Low priority sprite flag

; -------------------------------------------------------------------------

ObjFlower:
	moveq	#0,d0				; Run object routine
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	jmp	DrawObject			; Draw sprite

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjFlower_Init-.Index		; Initialization
	dc.w	ObjFlower_Seed-.Index		; Seed
	dc.w	ObjFlower_Animate-.Index	; Animation
	dc.w	ObjFlower_Growing-.Index	; Growth
	dc.w	ObjFlower_Done-.Index		; Finish

; -------------------------------------------------------------------------
; Flower initialization routine
; -------------------------------------------------------------------------

ObjFlower_Init:
	ori.b	#4,oRender(a0)			; Set render flags
	move.b	#1,oPriority(a0)		; Set priority
	move.b	#0,oYRadius(a0)			; Set Y radius
	move.w	#$A6D7,oTile(a0)		; Set base tile
	tst.b	oFlowerLoPrio(a0)		; Should our sprite be low priority?
	beq.s	.GotPriority			; If not, branch
	andi.b	#$7F,oTile(a0)			; Clear tile priority bit

.GotPriority:
	move.l	#MapSpr_Flower,oMap(a0)		; Set mappings

	tst.b	oSubtype(a0)			; Should we be able to respawn?
	bne.s	.NoRespawn			; If not, branch

	bsr.w	ObjFlower_GetRespawnAddr	; Get respawn flags
	move.b	(a1),d0
	move.b	#4,oRoutine(a0)			; Set routine to animate
	move.b	#3,oAnim(a0)			; Set animation to flower animation
	btst	#6,d0				; Have we already spawned?
	bne.s	ObjFlower_Animate		; If so, branch

.NoRespawn:
	move.w	#2,oAnim(a0)			; Set animation to seed animation (and have it reset)
	move.b	#2,oRoutine(a0)			; Set routine to seed
	move.w	#$6D7,oTile(a0)			; Set base tile to use palette line 0

; -------------------------------------------------------------------------
; Flower seed routine
; -------------------------------------------------------------------------

ObjFlower_Seed:
	jsr	CheckFloorEdge			; Have we touched the floor yet?
	tst.w	d1
	bpl.s	.Fall				; If not, branch
	add.w	d1,oY(a0)			; Align to the floor

	tst.b	oSubtype(a0)			; Should we be able to respawn?
	bne.s	.TouchDown			; If not, branch

	bsr.w	ObjFlower_GetRespawnAddr	; Get flower index and increment flower count in this time zone
	lea	flowerCount,a2
	move.b	(a2,d1.w),d0
	addq.b	#1,(a2,d1.w)

	bsr.w	ObjFlower_GetPosBuffer		; Mark our position
	move.w	oX(a0),(a1,d0.w)
	move.w	oY(a0),2(a1,d0.w)

.TouchDown:
	move.b	#4,oRoutine(a0)			; Set routine to animate
	move.b	#1,oAnim(a0)			; Set animation to seed planted animation
	move.b	#$30,oYRadius(a0)		; Set Y radius
	bra.w	ObjFlower_Animate		; Continue to animate sprite

.Fall:
	addq.w	#2,oY(a0)			; Fall down slowly

; -------------------------------------------------------------------------
; Flower animation routine
; -------------------------------------------------------------------------

ObjFlower_Animate:
	lea	Ani_Flower,a1			; Animate sprite
	bra.w	AnimateObject

; -------------------------------------------------------------------------
; Get a flower object's respawn table entry
; -------------------------------------------------------------------------
; RETURNS:
;	d1.w - Offset in table
;	a1.l - Address of table entry
; -------------------------------------------------------------------------

ObjFlower_GetRespawnAddr:
	moveq	#0,d0				; Get base respawn table entry offset
	move.b	oRespawn(a0),d0
	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,d0

	moveq	#0,d1				; Add time zone to the offset
	move.b	timeZone,d1
	bclr	#7,d1
	add.w	d1,d0

	lea	lvlObjRespawns,a1		; Get respawn table entry address
	lea	2(a1,d0.w),a1
	rts

; -------------------------------------------------------------------------
; Get a flower object's respawn table entry
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Flower index
; RETURNS:
;	a1.l - Flower position table address
; -------------------------------------------------------------------------

ObjFlower_GetPosBuffer:
	andi.w	#$3F,d0				; Get flower position table offset
	add.w	d0,d0
	add.w	d0,d0

	moveq	#0,d1				; Add time zone to the offset
	move.b	timeZone,d1
	bclr	#7,d1
	lsl.w	#8,d1
	add.w	d1,d0

	lea	flowerPosBuf,a1			; Get flower position table address
	rts

; -------------------------------------------------------------------------
; Flower growth routine
; -------------------------------------------------------------------------

ObjFlower_Growing:
	move.w	#$26D7,oTile(a0)		; Set base tile to use palette line 1
	move.b	#2,oAnim(a0)			; Set animation to growing animation
	bra.s	ObjFlower_Animate		; Continue to animate sprite

; -------------------------------------------------------------------------
; Flower finished routine
; -------------------------------------------------------------------------

ObjFlower_Done:
	move.b	#3,oAnim(a0)			; Set animation to flower animation
	move.b	#4,oRoutine(a0)			; Set routine to animation
	bra.s	ObjFlower_Animate		; Continue to animate sprite

; -------------------------------------------------------------------------
; Splash object that appears when the player goes past a waterfall in
; a spin tunnel
; -------------------------------------------------------------------------

ObjWaterfallSplash:
	moveq	#0,d0				; Run object routine
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jmp	.Index(pc,d0.w)

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjWaterfallSplash_Init-.Index	; Initialization
	dc.w	ObjWaterfallSplash_Main-.Index	; Main
	dc.w	ObjWaterfallSplash_Destroy-.Index; Destruction

; -------------------------------------------------------------------------
; Waterfall splash object initialization routine
; -------------------------------------------------------------------------

ObjWaterfallSplash_Init:
	addq.b	#2,oRoutine(a0)			; Advance routine

	ori.b	#4,oRender(a0)
	move.l	#MapSpr_WaterfallSplash,oMap(a0)
	move.w	#$3E4,oTile(a0)
	tst.b	timeZone
	bne.s	.NotPast
	move.w	#$39E,oTile(a0)

.NotPast:
	move.b	#1,oPriority(a0)

; -------------------------------------------------------------------------
; Main waterfall splash object routine
; -------------------------------------------------------------------------

ObjWaterfallSplash_Main:
	lea	Ani_WaterfallSplash,a1		; Animate sprite
	bsr.w	AnimateObject
	jmp	DrawObject			; Draw sprite

; -------------------------------------------------------------------------
; Waterfall splash object destruction routine
; -------------------------------------------------------------------------

ObjWaterfallSplash_Destroy:
	jmp	DeleteObject			; Delete ourselves

; -------------------------------------------------------------------------

ObjFlapDoorH:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjFlapDoorH_Index(pc,d0.w),d0
	jsr	ObjFlapDoorH_Index(pc,d0.w)
	jsr	DrawObject
	jmp	CheckObjDespawnTime
; End of function ObjFlapDoorH

; -------------------------------------------------------------------------
ObjFlapDoorH_Index:dc.w	ObjFlapDoorH_Init-ObjFlapDoorH_Index
	dc.w	ObjFlapDoorH_Main-ObjFlapDoorH_Index
	dc.w	ObjFlapDoorH_Animate-ObjFlapDoorH_Index
	dc.w	ObjFlapDoorH_Reset-ObjFlapDoorH_Index
; -------------------------------------------------------------------------

ObjFlapDoorH_ChkPlayer:
	tst.w	oYVel(a1)
	bpl.s	.Solid
	bsr.w	ObjFlapDoorH_ChkCollision
	beq.s	.Solid
	move.b	#4,oRoutine(a0)
	tst.b	oSubtype(a0)
	bne.s	.End
	jsr	FindObjSlot
	bne.s	.End
	move.b	#$B,oID(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	subq.w	#4,oY(a1)
	move.w	#$A4,d0
	jmp	PlayFMSound

; -------------------------------------------------------------------------

.End:
	rts

; -------------------------------------------------------------------------

.Solid:
	move.w	oX(a0),d3
	move.w	oY(a0),d4
	jmp	SolidObject1
; End of function ObjFlapDoorH_ChkPlayer

; -------------------------------------------------------------------------

ObjFlapDoorH_Init:
	addq.b	#2,oRoutine(a0)
	move.l	#MapSpr_FlapDoorH,oMap(a0)
	move.b	#1,oPriority(a0)
	ori.b	#4,oRender(a0)
	move.b	#$2C,oWidth(a0)
	cmpi.b	#2,oSubtype(a0)
	bne.s	.NotNarrow
	move.b	#$18,oWidth(a0)

.NotNarrow:
	move.b	#8,oYRadius(a0)
	moveq	#$C,d0
	jsr	LevelObj_SetBaseTile
; End of function ObjFlapDoorH_Init

; -------------------------------------------------------------------------

ObjFlapDoorH_Main:
	lea	objPlayerSlot.w,a1
	bsr.w	ObjFlapDoorH_ChkPlayer
	lea	objPlayerSlot2.w,a1
	bra.w	ObjFlapDoorH_ChkPlayer
; End of function ObjFlapDoorH_Main

; -------------------------------------------------------------------------

ObjFlapDoorH_Animate:
	lea	Ani_FlapDoorH,a1
	bra.w	AnimateObject
; End of function ObjFlapDoorH_Animate

; -------------------------------------------------------------------------

ObjFlapDoorH_Reset:
	move.b	#1,oPrevAnim(a0)
	move.b	#0,oMapFrame(a0)
	subq.b	#4,oRoutine(a0)
	rts
; End of function ObjFlapDoorH_Reset

; -------------------------------------------------------------------------

ObjUnkC:

; -------------------------------------------------------------------------

ObjFlapDoorH_ChkCollision:
	move.w	oX(a1),d0
	sub.w	oX(a0),d0
	moveq	#0,d1
	move.b	oWidth(a0),d1
	add.w	d1,d0
	bmi.s	.NoCollision
	add.w	d1,d1
	cmp.w	d1,d0
	bcc.s	.NoCollision
	move.w	oY(a1),d0
	sub.w	oY(a0),d0
	moveq	#0,d1
	move.b	oYRadius(a0),d1
	add.w	d1,d0
	bmi.s	.NoCollision
	add.w	d1,d1
	cmp.w	d1,d0
	bcc.s	.NoCollision
	moveq	#1,d0
	rts

; -------------------------------------------------------------------------

.NoCollision:
	moveq	#0,d0
	rts
; End of function ObjFlapDoorH_ChkCollision

; -------------------------------------------------------------------------

ObjWaterSplash:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjWaterSplash_Index(pc,d0.w),d0
	jmp	ObjWaterSplash_Index(pc,d0.w)
; End of function ObjWaterSplash

; -------------------------------------------------------------------------
ObjWaterSplash_Index:dc.w	ObjWaterSplash_Init-ObjWaterSplash_Index
	dc.w	ObjWaterSplash_Main-ObjWaterSplash_Index
	dc.w	ObjWaterSplash_Destroy-ObjWaterSplash_Index
; -------------------------------------------------------------------------

ObjWaterSplash_Init:
	addq.b	#2,oRoutine(a0)
	move.b	#4,oRender(a0)
	move.b	#1,oPriority(a0)
	move.l	#MapSpr_WaterSplash,oMap(a0)
	move.b	oSubtype(a0),oAnim(a0)
	moveq	#$D,d0
	jsr	LevelObj_SetBaseTile
	move.w	#$A2,d0
	cmpi.b	#2,oSubtype(a0)
	bcs.s	.PlaySound
	move.w	#$A1,d0

.PlaySound:
	jsr	PlayFMSound
; End of function ObjWaterSplash_Init

; -------------------------------------------------------------------------

ObjWaterSplash_Main:
	lea	Ani_WaterSplash,a1
	bsr.w	AnimateObject
	jmp	DrawObject
; End of function ObjWaterSplash_Main

; -------------------------------------------------------------------------

ObjWaterSplash_Destroy:
	jmp	DeleteObject
; End of function ObjWaterSplash_Destroy

; -------------------------------------------------------------------------

ObjPowerup:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjPowerup_Index(pc,d0.w),d1
	jmp	ObjPowerup_Index(pc,d1.w)
; End of function ObjPowerup

; -------------------------------------------------------------------------
ObjPowerup_Index:dc.w	ObjPowerup_Init-ObjPowerup_Index
	dc.w	ObjPowerup_Shield-ObjPowerup_Index
	dc.w	ObjPowerup_InvStars-ObjPowerup_Index
	dc.w	ObjPowerup_TimeStars-ObjPowerup_Index
; -------------------------------------------------------------------------

ObjPowerup_Init:
	addq.b	#2,oRoutine(a0)
	move.l	#MapSpr_Powerup,oMap(a0)
	move.b	#4,oRender(a0)
	move.b	#1,oPriority(a0)
	move.b	#$10,oWidth(a0)
	move.w	#$544,oTile(a0)
	tst.b	oAnim(a0)
	beq.s	.End
	addq.b	#2,oRoutine(a0)
	cmpi.b	#5,oAnim(a0)
	bcs.s	.End
	addq.b	#2,oRoutine(a0)

.End:
	rts
; End of function ObjPowerup_Init

; -------------------------------------------------------------------------

ObjPowerup_Shield:

; FUNCTION CHUNK AT 00206540 SIZE 0000002E BYTES

	tst.b	shieldFlag
	beq.s	.Delete
	tst.b	timeWarpFlag
	bne.s	.End
	tst.b	invincibleFlag
	bne.s	.End
	move.w	objPlayerSlot+oX.w,oX(a0)
	move.w	objPlayerSlot+oY.w,oY(a0)
	move.b	objPlayerSlot+oStatus.w,oStatus(a0)
	cmpi.b	#6,levelZone
	bne.s	.Animate
	ori.b	#$80,2(a0)
	tst.b	lvlDrawLowPlane
	beq.s	.Animate
	andi.b	#$7F,2(a0)

.Animate:
	lea	Ani_Powerup,a1
	jsr	AnimateObject
	bra.w	ObjPowerup_ChkSaveRout

; -------------------------------------------------------------------------

.End:
	rts

; -------------------------------------------------------------------------

.Delete:
	jmp	DeleteObject
; End of function ObjPowerup_Shield

; -------------------------------------------------------------------------

ObjPowerup_InvStars:

; FUNCTION CHUNK AT 002064CE SIZE 00000072 BYTES

	tst.b	timeWarpFlag
	beq.s	.NoTimeWarp
	rts

; -------------------------------------------------------------------------

.NoTimeWarp:
	tst.b	invincibleFlag
	bne.s	ObjPowerup_ShowStars
	jmp	DeleteObject
; End of function ObjPowerup_InvStars

; -------------------------------------------------------------------------

ObjPowerup_TimeStars:
	tst.b	timeWarpFlag
	bne.s	ObjPowerup_ShowStars
	jmp	DeleteObject
; End of function ObjPowerup_TimeStars

; -------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR ObjPowerup_InvStars

ObjPowerup_ShowStars:
	cmpi.b	#6,levelZone
	bne.s	.GotPriority
	ori.b	#$80,oTile(a0)
	tst.b	lvlDrawLowPlane
	beq.s	.GotPriority
	andi.b	#$7F,oTile(a0)

.GotPriority:
	move.w	sonicRecordIndex.w,d0
	move.b	oAnim(a0),d1
	subq.b	#1,d1
	cmpi.b	#4,d1
	bcs.s	.GotDelta
	subq.b	#4,d1

.GotDelta:
	lsl.b	#3,d1
	move.b	d1,d2
	add.b	d1,d1
	add.b	d2,d1
	addq.b	#4,d1
	sub.b	d1,d0
	move.b	oVar30(a0),d1
	sub.b	d1,d0
	addq.b	#4,d1
	cmpi.b	#$18,d1
	bcs.s	.NoCap
	moveq	#0,d1

.NoCap:
	move.b	d1,oVar30(a0)
	lea	sonicRecordBuf.w,a1
	lea	(a1,d0.w),a1
	move.w	(a1)+,oX(a0)
	move.w	(a1)+,oY(a0)
	move.b	objPlayerSlot+oStatus.w,oStatus(a0)
	lea	Ani_Powerup,a1
	jsr	AnimateObject
; END OF FUNCTION CHUNK	FOR ObjPowerup_InvStars
; START	OF FUNCTION CHUNK FOR ObjPowerup_Shield

ObjPowerup_ChkSaveRout:
	move.b	lvlLoadShieldArt,d0
	andi.b	#$F,d0
	cmpi.b	#8,d0
	bcs.s	.SaveRout
	rts

; -------------------------------------------------------------------------

.SaveRout:
	cmp.b	oRoutine(a0),d0
	beq.s	.Display
	move.b	oRoutine(a0),lvlLoadShieldArt
	bset	#7,lvlLoadShieldArt

.Display:
	jmp	DrawObject
; END OF FUNCTION CHUNK	FOR ObjPowerup_Shield
; -------------------------------------------------------------------------

LoadShieldArt:
	bclr	#7,lvlLoadShieldArt
	beq.s	.End
	moveq	#0,d0
	move.b	lvlLoadShieldArt,d0
	subq.b	#2,d0
	add.w	d0,d0
	movea.l	ShieldArtIndex(pc,d0.w),a1
	lea	lvlDMABuffer,a2
	move.w	#$FF,d0

.Loop:
	move.l	(a1)+,(a2)+
	dbf	d0,.Loop
	lea	VDPCTRL,a5
	move.l	#$94029340,(a5)
	move.l	#$968C95C0,(a5)
	move.w	#$977F,(a5)
	move.w	#$6880,(a5)
	move.w	#$82,dmaCmdLow.w
	move.w	dmaCmdLow.w,(a5)

.End:
	rts
; End of function LoadShieldArt

; -------------------------------------------------------------------------
ShieldArtIndex:	dc.l	ArtUnc_Shield
	dc.l	ArtUnc_InvStars
	dc.l	ArtUnc_TimeStars
	dc.l	ArtUnc_GameOver
	dc.l	ArtUnc_TimeOver
; -------------------------------------------------------------------------

ObjForceSpin:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjForceSpin_Index(pc,d0.w),d0
	jsr	ObjForceSpin_Index(pc,d0.w)
	tst.b	debugCheat
	beq.s	.NoDisplay
	jsr	DrawObject

.NoDisplay:
	jmp	CheckObjDespawnTime
; End of function ObjForceSpin

; -------------------------------------------------------------------------
ObjForceSpin_Index:dc.w	ObjForceSpin_Init-ObjForceSpin_Index
	dc.w	ObjForceSpin_Main-ObjForceSpin_Index
; -------------------------------------------------------------------------

ObjForceSpin_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oRender(a0)
	move.w	#$544,oTile(a0)
	move.l	#MapSpr_Powerup,oMap(a0)
	move.b	oSubtype(a0),oMapFrame(a0)
	addq.b	#1,oMapFrame(a0)
; End of function ObjForceSpin_Init

; -------------------------------------------------------------------------

ObjForceSpin_Main:
	lea	objPlayerSlot.w,a1
	cmpi.b	#$2B,oAnim(a1)
	beq.w	.End
	cmpi.b	#6,oRoutine(a1)
	bcc.w	.End
	bsr.w	ObjForceSpin_CheckInRange
	beq.w	.End
	tst.b	oSubtype(a0)
	bne.s	.ChkSubtype1
	move.w	oXVel(a1),d0
	bpl.s	.AbsVX
	neg.w	d0

.AbsVX:
	move.w	#$A00,d1
	cmpi.b	#5,levelZone
	bne.s	.GotXCap
	move.w	#$D00,d1

.GotXCap:
	cmp.w	d1,d0
	bcc.s	.CheckXSign
	move.w	d1,d0

.CheckXSign:
	tst.w	oXVel(a1)
	bpl.s	.GotSpeed
	neg.w	d0

.GotSpeed:
	move.w	d0,oXVel(a1)
	move.w	d0,oPlayerGVel(a1)
	move.b	oAngle(a1),d0
	addi.b	#$20,d0
	andi.b	#$C0,d0
	cmpi.b	#$80,d0
	bne.s	.SetRoll
	neg.w	oPlayerGVel(a1)
	bra.s	.SetRoll

; -------------------------------------------------------------------------

.ChkSubtype1:
	cmpi.b	#2,oSubtype(a0)
	bcc.s	.HighSubtype

.Subtype1:
	move.w	oYVel(a1),d0
	bpl.s	.AbsVY
	neg.w	d0

.AbsVY:
	cmpi.w	#$D00,d0
	bcc.s	.GotYCap
	move.w	#$D00,d0

.GotYCap:
	tst.w	oYVel(a1)
	bpl.s	.CheckYSign
	neg.w	d0

.CheckYSign:
	move.w	d0,oYVel(a1)
	move.w	d0,oPlayerGVel(a1)
	bset	#1,oStatus(a1)

.SetRoll:
	bset	#2,oStatus(a1)
	bne.s	.End
	move.b	#$E,oYRadius(a1)
	move.b	#7,oXRadius(a1)
	addq.w	#5,oY(a1)
	move.b	#2,oAnim(a1)

.End:
	rts

; -------------------------------------------------------------------------

.HighSubtype:
	move.b	p1CtrlHold.w,d1
	cmpi.b	#4,oSubtype(a0)
	beq.s	.Subtype4
	cmpi.b	#2,oSubtype(a0)
	bne.s	.Subtype3

.Subtype2:
	tst.w	oYVel(a1)
	bpl.s	.SetRoll
	bra.s	.ChkLaunch

; -------------------------------------------------------------------------

.Subtype3:
	tst.w	oYVel(a1)
	bmi.s	.SetRoll

.ChkLaunch:
	move.w	#$D00,d0
	btst	#3,d1
	bne.s	.GotLaunch
	btst	#2,d1
	beq.s	.SetRoll
	neg.w	d0

.GotLaunch:
	cmpi.b	#2,oSubtype(a0)
	beq.s	.SkipAir
	bset	#1,oStatus(a1)

.SkipAir:
	move.w	d0,oXVel(a1)
	move.w	d0,oPlayerGVel(a1)
	bra.s	.SetRoll

; -------------------------------------------------------------------------

.Subtype4:
	tst.w	oXVel(a1)
	bmi.s	.SetRoll
	btst	#0,d1
	beq.w	.SetRoll
	move.w	#-$A00,d0
	bra.w	.CheckYSign
; End of function ObjForceSpin_Main

; -------------------------------------------------------------------------

ObjForceSpin_CheckInRange:
	tst.b	lvlDebugMode
	bne.s	.NotInRange
	move.w	oX(a1),d0
	sub.w	oX(a0),d0
	addi.w	#$28,d0
	bmi.s	.NotInRange
	cmpi.w	#$50,d0
	bcc.s	.NotInRange
	move.w	oY(a1),d0
	sub.w	oY(a0),d0
	addi.w	#$28,d0
	bmi.s	.NotInRange
	cmpi.w	#$50,d0
	bcc.s	.NotInRange
	moveq	#1,d0
	rts

; -------------------------------------------------------------------------

.NotInRange:
	moveq	#0,d0
	rts
; End of function ObjForceSpin_CheckInRange

; -------------------------------------------------------------------------

ObjSonic_Null:
	rts
; End of function ObjSonic_Null

; -------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR ObjCheckpoint_LoadData

TimeTravel_LoadData:
	move.w	travelX,oX(a6)
	move.w	travelY,oY(a6)
	move.b	travelStatus,oStatus(a6)
	move.w	travelGVel,oPlayerGVel(a6)
	move.w	travelXVel,oXVel(a6)
	move.w	travelYVel,oYVel(a6)
	move.w	travelRingCnt,levelRings
	move.b	travelLifeFlags,lifeFlags
	move.l	travelTime,levelTime
	move.b	travelWaterRout,waterRoutine.w
	move.w	travelBtmBound,bottomBound.w
	move.w	travelBtmBound,destBottomBound.w
	move.w	travelCamX,cameraX.w
	move.w	travelCamY,cameraY.w
	move.w	travelCamBgX,cameraBgX.w
	move.w	travelCamBgY,cameraBgY.w
	move.w	travelCamBg2X,cameraBg2X.w
	move.w	travelCamBg2Y,cameraBg2Y.w
	move.w	travelCamBg3X,cameraBg3X.w
	move.w	travelCamBg3Y,cameraBg3Y.w
	cmpi.b	#6,levelZone
	bne.s	.NoMini2
	move.b	travelMiniSonic,miniSonic

.NoMini2:
	tst.b	resetLevelFlags
	bpl.s	.End2
	move.w	travelX,d0
	subi.w	#320/2,d0
	move.w	d0,leftBound.w

.End2:
	rts
; END OF FUNCTION CHUNK	FOR ObjCheckpoint_LoadData
; -------------------------------------------------------------------------

ObjCheckpoint_LoadData:
	lea	objPlayerSlot.w,a6
	cmpi.b	#2,resetLevelFlags
	beq.w	TimeTravel_LoadData
	move.b	savedResetLvlFlags,resetLevelFlags
	move.w	savedX,oX(a6)
	move.w	savedY,oY(a6)
	clr.w	levelRings
	clr.b	lifeFlags
	move.l	savedTime,levelTime
	move.b	#59,levelTime+3
	subq.b	#1,levelTime+2
	move.b	savedWaterRout,waterRoutine.w
	move.w	savedBtmBound,bottomBound.w
	move.w	savedBtmBound,destBottomBound.w
	move.w	savedCamX,cameraX.w
	move.w	savedCamY,cameraY.w
	move.w	savedCamBgX,cameraBgX.w
	move.w	savedCamBgY,cameraBgY.w
	move.w	savedCamBg2X,cameraBg2X.w
	move.w	savedCamBg2Y,cameraBg2Y.w
	move.w	savedCamBg3X,cameraBg3X.w
	move.w	savedCamBg3Y,cameraBg3Y.w
	cmpi.b	#6,levelZone
	bne.s	.NoMini
	move.b	savedMiniSonic,miniSonic

.NoMini:
	cmpi.b	#2,levelZone
	bne.s	.NoWater
	move.w	savedWaterHeight,waterHeight2.w
	move.b	savedWaterRout,waterRoutine.w
	move.b	savedWaterFull,waterFullscreen.w

.NoWater:
	tst.b	resetLevelFlags
	bpl.s	.End
	move.w	savedX,d0
	subi.w	#320/2,d0
	move.w	d0,leftBound.w

.End:
	rts
; End of function ObjCheckpoint_LoadData

; -------------------------------------------------------------------------
; Calculate the amount of room in front of the player
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

Player_CalcRoomInFront:
	move.l	oX(a0),d3
	move.l	oY(a0),d2
	move.w	oXVel(a0),d1
	ext.l	d1
	asl.l	#8,d1
	add.l	d1,d3
	move.w	oYVel(a0),d1
	ext.l	d1
	asl.l	#8,d1
	add.l	d1,d2
	swap	d2
	swap	d3
	move.b	d0,primaryAngle.w
	move.b	d0,secondaryAngle.w
	move.b	d0,d1
	addi.b	#$20,d0
	bpl.s	.HighAngle
	move.b	d1,d0
	bpl.s	.SkipSub
	subq.b	#1,d0

.SkipSub:
	addi.b	#$20,d0
	bra.s	.GotQuadrant

; -------------------------------------------------------------------------

.HighAngle:
	move.b	d1,d0
	bpl.s	.SkipAdd
	addq.b	#1,d0

.SkipAdd:
	addi.b	#$1F,d0

.GotQuadrant:
	andi.b	#$C0,d0
	beq.w	Player_GetFloorDist_Part2
	cmpi.b	#$80,d0
	beq.w	Player_GetCeilDist_Part2
	andi.b	#$38,d1
	bne.s	.CheckWalls
	addq.w	#8,d2

.CheckWalls:
	cmpi.b	#$40,d0
	beq.w	Player_GetLWallDist_Part2
	bra.w	Player_GetRWallDist_Part2
; End of function Player_CalcRoomInFront

; -------------------------------------------------------------------------

Player_CalcRoomOverHead:
	move.b	d0,primaryAngle.w
	move.b	d0,secondaryAngle.w
	addi.b	#$20,d0
	andi.b	#$C0,d0
	cmpi.b	#$40,d0
	beq.w	Player_CheckLCeil
	cmpi.b	#$80,d0
	beq.w	Player_CheckCeiling
	cmpi.b	#$C0,d0
	beq.w	Player_CheckRCeil

Player_CheckFloor:
	move.w	oY(a0),d2
	move.w	oX(a0),d3
	moveq	#0,d0
	move.b	oYRadius(a0),d0
	ext.w	d0
	add.w	d0,d2
	move.b	oXRadius(a0),d0
	ext.w	d0
	add.w	d0,d3
	lea	primaryAngle.w,a4
	movea.w	#$10,a3
	move.w	#0,d6
	moveq	#$D,d5
	jsr	FindLevelFloor
	move.w	d1,-(sp)
	move.w	oY(a0),d2
	move.w	oX(a0),d3
	moveq	#0,d0
	move.b	oYRadius(a0),d0
	ext.w	d0
	add.w	d0,d2
	move.b	oXRadius(a0),d0
	ext.w	d0
	sub.w	d0,d3
	lea	secondaryAngle.w,a4
	movea.w	#$10,a3
	move.w	#0,d6
	moveq	#$D,d5
	jsr	FindLevelFloor
	move.w	(sp)+,d0
	move.b	#0,d2

Player_ChooseAngle:
	move.b	secondaryAngle.w,d3
	cmp.w	d0,d1
	ble.s	.NoExchange
	move.b	primaryAngle.w,d3
	exg	d0,d1

.NoExchange:
	btst	#0,d3
	beq.s	.End
	move.b	d2,d3

.End:
	rts
; End of function Player_CalcRoomOverHead

; -------------------------------------------------------------------------

Player_GetFloorDist:
	move.w	$C(a0),d2
	move.w	8(a0),d3
; End of function Player_GetFloorDist

; START	OF FUNCTION CHUNK FOR Player_CalcRoomInFront

Player_GetFloorDist_Part2:
	addi.w	#$A,d2
	lea	primaryAngle.w,a4
	movea.w	#$10,a3
	move.w	#0,d6
	moveq	#$E,d5
	jsr	FindLevelFloor
	move.b	#0,d2

Player_GetPriAngle:
	move.b	primaryAngle.w,d3
	btst	#0,d3
	beq.s	.End
	move.b	d2,d3

.End:
	rts
; END OF FUNCTION CHUNK	FOR Player_CalcRoomInFront
; -------------------------------------------------------------------------

CheckFloorEdge:
	move.w	oX(a0),d3
	move.w	oY(a0),d2
	moveq	#0,d0
	move.b	oYRadius(a0),d0
	ext.w	d0
	add.w	d0,d2
	lea	primaryAngle.w,a4
	move.b	#0,(a4)
	movea.w	#$10,a3
	move.w	#0,d6
	moveq	#$D,d5
	jsr	FindLevelFloor
	move.b	primaryAngle.w,d3
	btst	#0,d3
	beq.s	.End
	move.b	#0,d3

.End:
	rts
; End of function CheckFloorEdge

; -------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR Player_CalcRoomOverHead

Player_CheckRCeil:
	move.w	oY(a0),d2
	move.w	oX(a0),d3
	moveq	#0,d0
	move.b	oXRadius(a0),d0
	ext.w	d0
	sub.w	d0,d2
	move.b	oYRadius(a0),d0
	ext.w	d0
	add.w	d0,d3
	lea	primaryAngle.w,a4
	movea.w	#$10,a3
	move.w	#0,d6
	moveq	#$E,d5
	jsr	FindLevelWall
	move.w	d1,-(sp)
	move.w	oY(a0),d2
	move.w	oX(a0),d3
	moveq	#0,d0
	move.b	oXRadius(a0),d0
	ext.w	d0
	add.w	d0,d2
	move.b	oYRadius(a0),d0
	ext.w	d0
	add.w	d0,d3
	lea	secondaryAngle.w,a4
	movea.w	#$10,a3
	move.w	#0,d6
	moveq	#$E,d5
	jsr	FindLevelWall
	move.w	(sp)+,d0
	move.b	#$C0,d2
	bra.w	Player_ChooseAngle
; END OF FUNCTION CHUNK	FOR Player_CalcRoomOverHead
; -------------------------------------------------------------------------

Player_GetRWallDist:
	move.w	oY(a0),d2
	move.w	oX(a0),d3
; End of function Player_GetRWallDist

; START	OF FUNCTION CHUNK FOR Player_CalcRoomInFront

Player_GetRWallDist_Part2:
	addi.w	#$A,d3
	lea	primaryAngle.w,a4
	movea.w	#$10,a3
	move.w	#0,d6
	moveq	#$E,d5
	jsr	FindLevelWall
	move.b	#$C0,d2
	bra.w	Player_GetPriAngle
; END OF FUNCTION CHUNK	FOR Player_CalcRoomInFront
; -------------------------------------------------------------------------

ObjGetRWallDist:
	add.w	oX(a0),d3
	move.w	oY(a0),d2
	lea	primaryAngle.w,a4
	move.b	#0,(a4)
	movea.w	#$10,a3
	move.w	#0,d6
	moveq	#$E,d5
	jsr	FindLevelWall
	move.b	primaryAngle.w,d3
	btst	#0,d3
	beq.s	.End
	move.b	#$C0,d3

.End:
	rts
; End of function ObjGetRWallDist

; -------------------------------------------------------------------------

Player_CheckCeiling:
	move.w	oY(a0),d2
	move.w	oX(a0),d3
	moveq	#0,d0
	move.b	oYRadius(a0),d0
	ext.w	d0
	sub.w	d0,d2
	eori.w	#$F,d2
	move.b	oXRadius(a0),d0
	ext.w	d0
	add.w	d0,d3
	lea	primaryAngle.w,a4
	movea.w	#-$10,a3
	move.w	#$1000,d6
	moveq	#$E,d5
	jsr	FindLevelFloor
	move.w	d1,-(sp)
	move.w	oY(a0),d2
	move.w	oX(a0),d3
	moveq	#0,d0
	move.b	oYRadius(a0),d0
	ext.w	d0
	sub.w	d0,d2
	eori.w	#$F,d2
	move.b	oXRadius(a0),d0
	ext.w	d0
	sub.w	d0,d3
	lea	secondaryAngle.w,a4
	movea.w	#-$10,a3
	move.w	#$1000,d6
	moveq	#$E,d5
	jsr	FindLevelFloor
	move.w	(sp)+,d0
	move.b	#$80,d2
	bra.w	Player_ChooseAngle
; End of function Player_CheckCeiling

; -------------------------------------------------------------------------

Player_GetCeilDist:
	move.w	oY(a0),d2
	move.w	oX(a0),d3
; End of function Player_GetCeilDist

; START	OF FUNCTION CHUNK FOR Player_CalcRoomInFront

Player_GetCeilDist_Part2:
	subi.w	#$A,d2
	eori.w	#$F,d2
	lea	primaryAngle.w,a4
	movea.w	#-$10,a3
	move.w	#$1000,d6
	moveq	#$E,d5
	jsr	FindLevelFloor
	move.b	#$80,d2
	bra.w	Player_GetPriAngle
; END OF FUNCTION CHUNK	FOR Player_CalcRoomInFront
; -------------------------------------------------------------------------

ObjGetCeilDist:
	move.w	oY(a0),d2
	move.w	oX(a0),d3
	moveq	#0,d0
	move.b	oYRadius(a0),d0
	ext.w	d0
	sub.w	d0,d2
	eori.w	#$F,d2
	lea	primaryAngle.w,a4
	movea.w	#-$10,a3
	move.w	#$1000,d6
	moveq	#$E,d5
	jsr	FindLevelFloor
	move.b	primaryAngle.w,d3
	btst	#0,d3
	beq.s	.End
	move.b	#$80,d3

.End:
	rts
; End of function ObjGetCeilDist

; -------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR Player_CalcRoomOverHead

Player_CheckLCeil:
	move.w	oY(a0),d2
	move.w	oX(a0),d3
	moveq	#0,d0
	move.b	oXRadius(a0),d0
	ext.w	d0
	sub.w	d0,d2
	move.b	oYRadius(a0),d0
	ext.w	d0
	sub.w	d0,d3
	eori.w	#$F,d3
	lea	primaryAngle.w,a4
	movea.w	#-$10,a3
	move.w	#$800,d6
	moveq	#$E,d5
	jsr	FindLevelWall
	move.w	d1,-(sp)
	move.w	oY(a0),d2
	move.w	oX(a0),d3
	moveq	#0,d0
	move.b	oXRadius(a0),d0
	ext.w	d0
	add.w	d0,d2
	move.b	oYRadius(a0),d0
	ext.w	d0
	sub.w	d0,d3
	eori.w	#$F,d3
	lea	secondaryAngle.w,a4
	movea.w	#-$10,a3
	move.w	#$800,d6
	moveq	#$E,d5
	jsr	FindLevelWall
	move.w	(sp)+,d0
	move.b	#$40,d2
	bra.w	Player_ChooseAngle
; END OF FUNCTION CHUNK	FOR Player_CalcRoomOverHead
; -------------------------------------------------------------------------

Player_GetLWallDist:
	move.w	oY(a0),d2
	move.w	oX(a0),d3
; End of function Player_GetLWallDist

; START	OF FUNCTION CHUNK FOR Player_CalcRoomInFront

Player_GetLWallDist_Part2:
	subi.w	#$A,d3
	eori.w	#$F,d3
	lea	primaryAngle.w,a4
	movea.w	#-$10,a3
	move.w	#$800,d6
	moveq	#$E,d5
	jsr	FindLevelWall
	move.b	#$40,d2
	bra.w	Player_GetPriAngle
; END OF FUNCTION CHUNK	FOR Player_CalcRoomInFront
; -------------------------------------------------------------------------

ObjGetLWallDist:
	add.w	oX(a0),d3
	move.w	oY(a0),d2
	lea	primaryAngle.w,a4
	move.b	#0,(a4)
	movea.w	#-$10,a3
	move.w	#$800,d6
	moveq	#$E,d5
	jsr	FindLevelWall
	move.b	primaryAngle.w,d3
	btst	#0,d3
	beq.s	.End
	move.b	#$40,d3

.End:
	rts
; End of function ObjGetLWallDist

; -------------------------------------------------------------------------

Player_ObjCollide:
	nop
	move.w	oX(a0),d2
	move.w	oY(a0),d3
	subq.w	#8,d2
	moveq	#0,d5
	move.b	oYRadius(a0),d5
	subq.b	#3,d5
	sub.w	d5,d3
	cmpi.b	#$39,oMapFrame(a0)
	bne.s	.NoDuck
	addi.w	#$C,d3
	moveq	#$A,d5

.NoDuck:
	move.w	#$10,d4
	add.w	d5,d5
	lea	dynObjects.w,a1
	move.w	#$5F,d6

.Loop:
	tst.b	oRender(a1)
	bpl.s	.Next
	move.b	oColType(a1),d0
	bne.s	.CheckWidth

.Next:
	lea	oSize(a1),a1
	dbf	d6,.Loop
	moveq	#0,d0
	rts

; -------------------------------------------------------------------------

.CheckWidth:
	andi.w	#$3F,d0
	add.w	d0,d0
	lea	ObjColSizes,a2
	lea	-2(a2,d0.w),a2
	moveq	#0,d1
	move.b	(a2)+,d1
	move.w	oX(a1),d0
	sub.w	d1,d0
	sub.w	d2,d0
	bcc.s	.TouchRight
	add.w	d1,d1
	add.w	d1,d0
	bcs.s	.CheckHeight
	bra.w	.Next

; -------------------------------------------------------------------------

.TouchRight:
	cmp.w	d4,d0
	bhi.w	.Next

.CheckHeight:
	moveq	#0,d1
	move.b	(a2)+,d1
	move.w	oY(a1),d0
	sub.w	d1,d0
	sub.w	d3,d0
	bcc.s	.TouchBottom
	add.w	d1,d1
	add.w	d0,d1
	bcs.s	.CheckColType
	bra.w	.Next

; -------------------------------------------------------------------------

.TouchBottom:
	cmp.w	d5,d0
	bhi.w	.Next

.CheckColType:
	move.b	oColType(a1),d1
	andi.b	#$C0,d1
	beq.w	Player_TouchEnemy
	cmpi.b	#$C0,d1
	beq.w	Player_TouchSpecial
	tst.b	d1
	bmi.w	Player_TouchHazard
	move.b	oColType(a1),d0
	andi.b	#$3F,d0
	cmpi.b	#6,d0
	beq.s	Player_TouchMonitor
	cmpi.w	#$5A,oPlayerHurt(a0)
	bcc.w	.End
	addq.b	#2,oRoutine(a1)

.End:
	rts

; -------------------------------------------------------------------------

Player_TouchMonitor:
	tst.w	oYVel(a0)
	bpl.s	.GoingDown
	move.w	oY(a0),d0
	subi.w	#$10,d0
	cmp.w	oY(a1),d0
	bcs.s	.End2
	neg.w	oYVel(a0)
	move.w	#-$180,oYVel(a1)
	tst.b	oRoutine2(a1)
	bne.s	.End2
	addq.b	#4,oRoutine2(a1)
	rts

; -------------------------------------------------------------------------

.GoingDown:
	cmpi.b	#2,oAnim(a0)
	bne.s	.End2
	neg.w	oYVel(a0)
	addq.b	#2,oRoutine(a1)

.End2:
	rts
; End of function ObjSonic_ObjCollide

; -------------------------------------------------------------------------

Player_TouchEnemy:
	tst.b	timeWarpFlag
	bne.s	.DamageEnemy
	tst.b	invincibleFlag
	bne.s	.DamageEnemy
	cmpi.b	#2,oAnim(a0)
	bne.w	Player_TouchHazard

.DamageEnemy:
	tst.b	oColStatus(a1)
	beq.s	.KillEnemy
	neg.w	oXVel(a0)
	neg.w	oYVel(a0)
	asr	oXVel(a0)
	asr	oYVel(a0)
	move.b	#0,oColType(a1)
	subq.b	#1,oColStatus(a1)
	bne.s	.End
	bset	#7,oStatus(a1)

.End:
	rts

; -------------------------------------------------------------------------

.KillEnemy:
	bset	#7,oStatus(a1)
	moveq	#0,d0
	move.w	scoreChain.w,d0
	addq.w	#2,scoreChain.w
	cmpi.w	#6,d0
	bcs.s	.CappedChain
	moveq	#6,d0

.CappedChain:
	move.w	d0,oVar3E(a1)
	move.w	EnemyPoints(pc,d0.w),d0
	cmpi.w	#$20,scoreChain.w
	bcs.s	.GivePoints
	move.w	#$3E8,d0
	move.w	#$A,oVar3E(a1)

.GivePoints:
	bsr.w	AddPoints
	move.w	#$96,d0
	jsr	PlayFMSound
	move.b	#$18,oID(a1)
	move.b	#0,oRoutine(a1)
	move.b	#1,oSubtype(a1)
	tst.w	oYVel(a0)
	bmi.s	.BounceDown
	move.w	oY(a0),d0
	cmp.w	oY(a1),d0
	bcc.s	.BounceUp
	neg.w	oYVel(a0)
	rts

; -------------------------------------------------------------------------

.BounceDown:
	addi.w	#$100,oYVel(a0)
	rts

; -------------------------------------------------------------------------

.BounceUp:
	subi.w	#$100,oYVel(a0)
	rts

; -------------------------------------------------------------------------
EnemyPoints:
	dc.w	10
	dc.w	20
	dc.w	50
	dc.w	100

; -------------------------------------------------------------------------

Player_TouchHazard2:
	bset	#7,oStatus(a1)

Player_TouchHazard:
	tst.b	timeWarpFlag
	bne.s	.NoHurt
	tst.b	invincibleFlag
	beq.s	.ChkHurt

.NoHurt:
	moveq	#-1,d0
	rts

; -------------------------------------------------------------------------

.ChkHurt:
	nop
	tst.w	oPlayerHurt(a0)
	bne.s	.NoHurt
	movea.l	a1,a2

HurtPlayer:
	tst.b	shieldFlag
	bne.s	.ClearCharge
	tst.w	levelRings
	beq.w	.CheckKill
	jsr	FindObjSlot
	bne.s	.ClearCharge
	move.b	#$11,oID(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)

.ClearCharge:
	clr.b	oPlayerCharge(a0)
	bclr	#0,shieldFlag
	bne.s	.SetHurt
	move.b	#0,blueRing

.SetHurt:
	move.b	#4,oRoutine(a0)
	bsr.w	Player_ResetOnFloor
	bset	#1,oStatus(a0)
	move.w	#-$400,oYVel(a0)
	move.w	#-$200,oXVel(a0)
	btst	#6,oStatus(a0)
	beq.s	.NoWater
	move.w	#-$200,oYVel(a0)
	move.w	#-$100,oXVel(a0)

.NoWater:
	move.w	oX(a0),d0
	cmp.w	oX(a2),d0
	bcs.s	.GotXVel
	neg.w	oXVel(a0)

.GotXVel:
	move.w	#0,oPlayerGVel(a0)
	move.b	#$1A,oAnim(a0)
	move.w	#$78,oPlayerHurt(a0)
	moveq	#-1,d0
	rts

; -------------------------------------------------------------------------

.CheckKill:
	tst.w	debugCheat
	bne.w	.ClearCharge
; End of function Player_TouchEnemy

; -------------------------------------------------------------------------

KillPlayer:
	tst.w	lvlDebugMode
	bne.s	.End
	move.b	#0,invincibleFlag
	move.b	#6,oRoutine(a0)
	bsr.w	Player_ResetOnFloor
	bset	#1,oStatus(a0)
	move.w	#-$700,oYVel(a0)
	move.w	#0,oXVel(a0)
	move.w	#0,oPlayerGVel(a0)
	move.w	oY(a0),oPlayerStick(a0)
	move.b	#$18,oAnim(a0)
	bset	#7,oTile(a0)
	move.b	#0,oPriority(a0)
	move.w	#$93,d0
	jsr	PlayFMSound

.End:
	moveq	#-1,d0
	rts
; End of function KillPlayer

; -------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR ObjSonic_ObjCollide

Player_TouchSpecial:
	move.b	oColType(a1),d1
	andi.b	#$3F,d1
	cmpi.b	#$1F,d1
	beq.w	.FlagCollision
	cmpi.b	#$B,d1
	beq.w	.TouchHazard
	cmpi.b	#$C,d1
	beq.w	.TouchMechaBlu
	cmpi.b	#$17,d1
	beq.w	.FlagCollision
	cmpi.b	#$21,d1
	beq.w	.FlagCollision
	cmpi.b	#$23,d1
	beq.w	.FlagCollision
	cmpi.b	#$2F,d1
	beq.w	.CheckIfRoll
	cmpi.b	#$3A,d1
	beq.w	.CheckIfRoll
	cmpi.b	#$3B,d1
	beq.w	.CheckIfRoll
	cmpi.b	#1,bossFight.w
	bne.s	.End3
	cmpi.b	#$3C,d1
	blt.s	.End3
	cmpi.b	#$3F,d1
	bgt.s	.End3
	bsr.w	Player_TouchEnemy
	tst.b	oColType(a1)
	bne.s	.NoResetHits
	addq.b	#3,oColStatus(a1)

.NoResetHits:
	clr.b	oColType(a1)
	bra.w	.FlagCollision

; -------------------------------------------------------------------------

.End3:
	rts

; -------------------------------------------------------------------------

.TouchHazard:
	bra.w	Player_TouchHazard2

; -------------------------------------------------------------------------

.TouchMechaBlu:
	sub.w	d0,d5
	cmpi.w	#8,d5
	bcc.s	.TouchEnemy
	move.w	oX(a1),d0
	subq.w	#4,d0
	btst	#0,oStatus(a1)
	beq.s	.NotFlipped
	subi.w	#$10,d0

.NotFlipped:
	sub.w	d2,d0
	bcc.s	.CheckIfRight
	addi.w	#$18,d0
	bcs.s	.TouchHazard2
	bra.s	.TouchEnemy

; -------------------------------------------------------------------------

.CheckIfRight:
	cmp.w	d4,d0
	bhi.s	.TouchEnemy

.TouchHazard2:
	bra.w	Player_TouchHazard

; -------------------------------------------------------------------------

.TouchEnemy:
	bra.w	Player_TouchEnemy

; -------------------------------------------------------------------------

.FlagCollision:
	addq.b	#1,oColStatus(a1)
	rts

; -------------------------------------------------------------------------

.CheckIfRoll:
	cmpi.b	#2,oAnim(a0)
	bne.s	.End4
	addq.b	#1,oColStatus(a1)

.End4:
	rts
; END OF FUNCTION CHUNK	FOR ObjSonic_ObjCollide

; -------------------------------------------------------------------------
ObjColSizes:	dc.b	$14, $14
	dc.b	$12, $C
	dc.b	$C, $10
	dc.b	4,	$10
	dc.b	$C, $12
	dc.b	$10, $10
	dc.b	6,	6
	dc.b	$18, $C
	dc.b	$C, $10
	dc.b	$10, $C
	dc.b	8,	8
	dc.b	$14, $10
	dc.b	$14, 8
	dc.b	$E, $E
	dc.b	$18, $18
	dc.b	$28, $10
	dc.b	$10, $18
	dc.b	8,	$10
	dc.b	$20, $70
	dc.b	$40, $20
	dc.b	$80, $20
	dc.b	$20, $20
	dc.b	8,	8
	dc.b	4,	4
	dc.b	$20, 8
	dc.b	$C, $C
	dc.b	8,	4
	dc.b	$18, 4
	dc.b	$28, 4
	dc.b	4,	8
	dc.b	4,	$18
	dc.b	4,	$28
	dc.b	4,	$20
	dc.b	$18, $18
	dc.b	$C, $18
	dc.b	$48, 8
	dc.b	8,	$C
	dc.b	$10, 8
	dc.b	$20, $10
	dc.b	$20, $10
	dc.b	8,	$10
	dc.b	$10, $10
	dc.b	$C, $C
	dc.b	$10, $10
	dc.b	4,	4
	dc.b	$10, $10
	dc.b	$16, $1A
	dc.b	0,	0
	dc.b	0,	0
	dc.b	0,	0
	dc.b	0,	0
	dc.b	0,	0
	dc.b	0,	0
	dc.b	0,	0
	dc.b	0,	0
	dc.b	0,	0
	dc.b	0,	0
	dc.b	$28, $24
	dc.b	$12, $11
	dc.b	$20, $18
	dc.b	$C, $14
	dc.b	$20, $C
	dc.b	$C, $10

; -------------------------------------------------------------------------

ObjWaterfall:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjWaterfall_Index(pc,d0.w),d0
	jsr	ObjWaterfall_Index(pc,d0.w)
	lea	Ani_Waterfall,a1
	jsr	AnimateObject
	jmp	DrawObject

; -------------------------------------------------------------------------
ObjWaterfall_Index:
	dc.w	ObjWaterfall_Init-ObjWaterfall_Index
	dc.w	ObjWaterfall_Main-ObjWaterfall_Index
; -------------------------------------------------------------------------

ObjWaterfall_Init:
	addq.b	#2,oRoutine(a0)
	move.l	#MapSpr_Waterfall,oMap(a0)
	move.b	#4,oRender(a0)
	move.b	#1,oPriority(a0)
	move.b	#$10,oWidth(a0)
	move.w	#$3BA,oTile(a0)
	andi.w	#$FFF0,oY(a0)
	move.w	$C(a0),oVar2A(a0)
	addi.w	#$180,oVar2A(a0)
	rts

; -------------------------------------------------------------------------

ObjWaterfall_Main:
	move.w	oY(a0),d0
	addq.w	#4,d0
	cmp.w	oVar2A(a0),d0
	bcs.s	.NoDel
	jmp	DeleteObject

.NoDel:
	move.w	d0,oY(a0)
	moveq	#2,d3
	bset	#$D,d3
	move.w	oY(a0),d4
	move.w	oX(a0),d5
	subi.w	#$60,d5
	move.w	d4,d6
	andi.w	#$F,d6
	bne.s	.End
	moveq	#$B,d6

.Loop:
	jsr	PlaceBlockAtPos
	addi.w	#$10,d5
	dbf	d6,.Loop

.End:
	rts

; -------------------------------------------------------------------------

ObjNull8:
	rts
; End of function ObjWaterfall_Main

; -------------------------------------------------------------------------

ObjNull5:
	rts
; End of function ObjNull5

; -------------------------------------------------------------------------
Ani_Waterfall:
	include	"level/r1/objects/waterfall/anim.asm"
	even
		
MapSpr_Waterfall:
	include	"level/r1/objects/waterfall/map.asm"
	even

; -------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR ObjSonic

DebugMode:
	move.b	p1CtrlHold.w,d0
	andi.b	#$F,d0
	bne.s	.Accel
	move.l	#$4000,debugSpeed
	bra.s	.GotSpeed

; -------------------------------------------------------------------------

.Accel:
	addi.l	#$2000,debugSpeed
	cmpi.l	#$80000,debugSpeed
	bls.s	.GotSpeed
	move.l	#$80000,debugSpeed

.GotSpeed:
	move.l	debugSpeed,d0
	btst	#0,p1CtrlHold.w
	beq.s	.ChkDown
	sub.l	d0,oY(a0)

.ChkDown:
	btst	#1,p1CtrlHold.w
	beq.s	.ChkLeft
	add.l	d0,oY(a0)

.ChkLeft:
	btst	#2,p1CtrlHold.w
	beq.s	.ChkRight
	sub.l	d0,oX(a0)

.ChkRight:
	btst	#3,p1CtrlHold.w
	beq.s	.SetPos
	add.l	d0,oX(a0)

.SetPos:
	move.w	oY(a0),d2
	move.b	oYRadius(a0),d0
	ext.w	d0
	add.w	d0,d2
	move.w	oX(a0),d3
	jsr	GetLevelBlock
	move.w	(a1),lvlDebugBlock
	lea	DebugItemIndex,a2
	btst	#6,p1CtrlTap.w
	beq.s	.NoInc
	moveq	#0,d1
	move.b	lvlDebugObject,d1
	addq.b	#1,d1
	cmp.b	(a2),d1
	bcs.s	.NoWrap
	move.b	#0,d1

.NoWrap:
	move.b	d1,lvlDebugObject

.NoInc:
	btst	#7,p1CtrlTap.w
	beq.s	.NoDec
	moveq	#0,d1
	move.b	lvlDebugObject,d1
	subq.b	#1,d1
	cmpi.b	#$FF,d1
	bne.s	.NoWrap2
	add.b	(a2),d1

.NoWrap2:
	move.b	d1,lvlDebugObject

.NoDec:
	moveq	#0,d1
	move.b	lvlDebugObject,d1
	mulu.w	#$C,d1
	move.l	4(a2,d1.w),oMap(a0)
	move.w	8(a2,d1.w),oTile(a0)
	move.b	3(a2,d1.w),oPriority(a0)
	move.b	$D(a2,d1.w),oMapFrame(a0)
	move.b	$C(a2,d1.w),lvlDebugSubtype2
	move.b	$B(a2,d1.w),d0
	ori.b	#4,d0
	move.b	d0,oRender(a0)
	move.b	#0,oAnim(a0)
	btst	#5,p1CtrlTap.w
	beq.s	.NoPlace
	bsr.w	FindObjSlot
	bne.s	.NoPlace
	moveq	#0,d1
	move.b	lvlDebugObject,d1
	mulu.w	#$C,d1
	move.b	2(a2,d1.w),oID(a1)
	move.b	$A(a2,d1.w),oSubtype(a1)
	move.b	$C(a2,d1.w),oSubtype2(a1)
	move.b	$D(a2,d1.w),oMapFrame(a1)
	move.w	8(a0),oX(a1)
	move.w	$C(a0),oY(a1)
	move.b	oRender(a0),d0
	andi.b	#3,d0
	move.b	d0,oRender(a1)
	move.b	d0,oStatus(a1)

.NoPlace:
	btst	#4,p1CtrlTap.w
	beq.s	.NoRevert
	move.b	#0,lvlDebugMode
	move.l	#MapSpr_Sonic,oMap(a0)
	move.w	#$780,oTile(a0)
	move.b	#2,oPriority(a0)
	move.b	#0,oMapFrame(a0)
	move.b	#4,oRender(a0)

.NoRevert:
	jmp	DrawObject
; END OF FUNCTION CHUNK	FOR ObjSonic

; -------------------------------------------------------------------------
debugSpeed:	dc.l	$4000

DebugItemIndex:
	dc.b	$34 ; 4
	dc.b	0
	dc.b	$35
	dc.b	1
	dc.l	MapSpr_FlapDoorV
	dc.w	$328
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	$2F
	dc.b	1
	dc.l	MapSpr_AmyRose
	dc.w	$2370
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	$F
	dc.b	$2D
	dc.b	1
	dc.l	MapSpr_RobotGenerator
	dc.w	$409
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	$1B
	dc.b	1
	dc.l	MapSpr_GrayRock
	dc.w	$374
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	$26
	dc.b	1
	dc.l	MapSpr_Spikes
	dc.w	$320
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	$D
	dc.b	1
	dc.l	MapSpr_FlapDoorH
	dc.w	$328
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	9
	dc.b	1
	dc.l	MapSpr_RotPlatform
	dc.w	$334
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	$21
	dc.b	1
	dc.l	MapSpr_Platform
	dc.w	$44BE
	dc.b	1
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	$A
	dc.b	1
	dc.l	MapSpr_Spring1
	dc.w	$520
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	$A
	dc.b	1
	dc.l	MapSpr_Spring1
	dc.w	$520
	dc.b	0
	dc.b	2
	dc.b	0
	dc.b	0
	dc.b	$A
	dc.b	1
	dc.l	MapSpr_Spring2
	dc.w	$520
	dc.b	4
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	$A
	dc.b	1
	dc.l	MapSpr_Spring2
	dc.w	$520
	dc.b	4
	dc.b	1
	dc.b	0
	dc.b	0
	dc.b	$A
	dc.b	1
	dc.l	MapSpr_Spring3
	dc.w	$490
	dc.b	8
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	$A
	dc.b	1
	dc.l	MapSpr_Spring3
	dc.w	$490
	dc.b	8
	dc.b	2
	dc.b	0
	dc.b	0
	dc.b	$A
	dc.b	1
	dc.l	MapSpr_Spring3
	dc.w	$490
	dc.b	8
	dc.b	1
	dc.b	0
	dc.b	0
	dc.b	$A
	dc.b	1
	dc.l	MapSpr_Spring3
	dc.w	$490
	dc.b	8
	dc.b	3
	dc.b	0
	dc.b	0
	dc.b	$A
	dc.b	1
	dc.l	MapSpr_Spring1
	dc.w	$2520
	dc.b	2
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	$A
	dc.b	1
	dc.l	MapSpr_Spring1
	dc.w	$2520
	dc.b	2
	dc.b	2
	dc.b	0
	dc.b	0
	dc.b	$A
	dc.b	1
	dc.l	MapSpr_Spring2
	dc.w	$2520
	dc.b	6
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	$A
	dc.b	1
	dc.l	MapSpr_Spring2
	dc.w	$2520
	dc.b	6
	dc.b	1
	dc.b	0
	dc.b	0
	dc.b	$A
	dc.b	1
	dc.l	MapSpr_Spring3
	dc.w	$2490
	dc.b	$A
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	$A
	dc.b	1
	dc.l	MapSpr_Spring3
	dc.w	$2490
	dc.b	$A
	dc.b	2
	dc.b	0
	dc.b	0
	dc.b	$A
	dc.b	1
	dc.l	MapSpr_Spring3
	dc.w	$2490
	dc.b	$A
	dc.b	1
	dc.b	0
	dc.b	0
	dc.b	$A
	dc.b	1
	dc.l	MapSpr_Spring3
	dc.w	$2490
	dc.b	$A
	dc.b	3
	dc.b	0
	dc.b	0
	dc.b	$24
	dc.b	3
	dc.l	MapSpr_FlyingAnimal
	dc.w	$388
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	$24
	dc.b	3
	dc.l	MapSpr_GroundAnimal
	dc.w	$388
	dc.b	1
	dc.b	0
	dc.b	0
	dc.b	3
	dc.b	$3D
	dc.b	4
	dc.l	MapSpr_Mosqui1
	dc.w	$23A0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	$3E
	dc.b	4
	dc.l	MapSpr_PataBata1
	dc.w	$23B0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	$3F
	dc.b	4
	dc.l	MapSpr_Anton
	dc.w	$2409
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	$22
	dc.b	4
	dc.l	MapSpr_Tamabboh1
	dc.w	$2428
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	$19
	dc.b	4
	dc.l	MapSpr_MonitorTimePost
	dc.w	$5A8
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	$19
	dc.b	4
	dc.l	MapSpr_MonitorTimePost
	dc.w	$5A8
	dc.b	1
	dc.b	0
	dc.b	0
	dc.b	1
	dc.b	$19
	dc.b	4
	dc.l	MapSpr_MonitorTimePost
	dc.w	$5A8
	dc.b	2
	dc.b	0
	dc.b	0
	dc.b	2
	dc.b	$19
	dc.b	4
	dc.l	MapSpr_MonitorTimePost
	dc.w	$5A8
	dc.b	3
	dc.b	0
	dc.b	0
	dc.b	3
	dc.b	$19
	dc.b	4
	dc.l	MapSpr_MonitorTimePost
	dc.w	$5A8
	dc.b	4
	dc.b	0
	dc.b	0
	dc.b	4
	dc.b	$19
	dc.b	4
	dc.l	MapSpr_MonitorTimePost
	dc.w	$5A8
	dc.b	5
	dc.b	0
	dc.b	0
	dc.b	5
	dc.b	$19
	dc.b	4
	dc.l	MapSpr_MonitorTimePost
	dc.w	$5A8
	dc.b	6
	dc.b	0
	dc.b	0
	dc.b	6
	dc.b	$19
	dc.b	4
	dc.l	MapSpr_MonitorTimePost
	dc.w	$5A8
	dc.b	7
	dc.b	0
	dc.b	0
	dc.b	7
	dc.b	$E
	dc.b	1
	dc.l	MapSpr_WaterfallSplash
	dc.w	$3E4
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	$20
	dc.b	3
	dc.l	MapSpr_CollapsePlatform1
	dc.w	$44BE
	dc.b	$10
	dc.b	1
	dc.b	0
	dc.b	0
	dc.b	$20
	dc.b	3
	dc.l	MapSpr_CollapsePlatform1
	dc.w	$44BE
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	$20
	dc.b	3
	dc.l	MapSpr_CollapsePlatform2
	dc.w	$44BE
	dc.b	$80
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	$20
	dc.b	3
	dc.l	MapSpr_CollapsePlatform2
	dc.w	$44BE
	dc.b	$81
	dc.b	0
	dc.b	0
	dc.b	1
	dc.b	$20
	dc.b	3
	dc.l	MapSpr_CollapsePlatform2
	dc.w	$44BE
	dc.b	$82
	dc.b	0
	dc.b	0
	dc.b	2
	dc.b	$20
	dc.b	3
	dc.l	MapSpr_CollapsePlatform2
	dc.w	$44BE
	dc.b	$83
	dc.b	0
	dc.b	0
	dc.b	3
	dc.b	$20
	dc.b	3
	dc.l	MapSpr_CollapsePlatform2
	dc.w	$44BE
	dc.b	$84
	dc.b	0
	dc.b	0
	dc.b	4
	dc.b	$20
	dc.b	3
	dc.l	MapSpr_CollapsePlatform2
	dc.w	$44BE
	dc.b	$85
	dc.b	0
	dc.b	0
	dc.b	5
	dc.b	$19
	dc.b	4
	dc.l	MapSpr_MonitorTimePost
	dc.w	$5A8
	dc.b	8
	dc.b	0
	dc.b	0
	dc.b	$A
	dc.b	$19
	dc.b	4
	dc.l	MapSpr_MonitorTimePost
	dc.w	$5A8
	dc.b	9
	dc.b	0
	dc.b	0
	dc.b	$C
	dc.b	$13
	dc.b	3
	dc.l	MapSpr_Checkpoint
	dc.w	$6CB
	dc.b	1
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	$34
	dc.b	3
	dc.l	MapSpr_Powerup
	dc.w	$544
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	1
	dc.b	$34
	dc.b	3
	dc.l	MapSpr_Powerup
	dc.w	$544
	dc.b	1
	dc.b	0
	dc.b	0
	dc.b	2
; -------------------------------------------------------------------------

ResetRespawnTable:
	lea	lvlObjRespawns,a2
	move.w	#$101,(a2)+
	move.w	#$BE,d0

.Clear:
	clr.l	(a2)+
	dbf	d0,.Clear
	rts
; End of function ResetRespawnTable

; -------------------------------------------------------------------------

LevelObjManager:
	moveq	#0,d0
	move.b	objManagerRout.w,d0
	move.w	LvlObjMan_Index(pc,d0.w),d0
	jmp	LvlObjMan_Index(pc,d0.w)
; End of function LevelObjManager

; -------------------------------------------------------------------------
LvlObjMan_Index:dc.w	LvlObjMan_Init-LvlObjMan_Index
	dc.w	LvlObjMan_Main-LvlObjMan_Index
; -------------------------------------------------------------------------

LvlObjMan_Init:
	addq.b	#2,objManagerRout.w
	lea	LevelObjectIndex,a0
	movea.l	a0,a1
	adda.w	(a0),a0
	move.l	a0,objLoadAddrR.w
	move.l	a0,objLoadAddrL.w
	adda.w	2(a1),a1
	move.l	a1,objLoadAddr2R.w
	move.l	a1,objLoadAddr2L.w
	lea	lvlObjRespawns,a2
	move.w	#$101,(a2)
	moveq	#0,d2
	move.w	cameraX.w,d6
	subi.w	#$80,d6
	bcc.s	.SkipLCap
	moveq	#0,d6

.SkipLCap:
	andi.w	#$FF80,d6
	movea.l	objLoadAddrR.w,a0

.ScanRight:
	cmp.w	(a0),d6
	bls.s	.FoundRightmost
	tst.b	4(a0)
	bpl.s	.NextObj
	move.b	(a2),d2
	addq.b	#1,(a2)

.NextObj:
	addq.w	#8,a0
	bra.s	.ScanRight

; -------------------------------------------------------------------------

.FoundRightmost:
	move.l	a0,objLoadAddrR.w
	movea.l	objLoadAddrL.w,a0
	subi.w	#$80,d6
	bcs.s	.FoundRightmost2

.ScanRight2:
	cmp.w	(a0),d6
	bls.s	.FoundRightmost2
	tst.b	4(a0)
	bpl.s	.NextObj2
	addq.b	#1,1(a2)

.NextObj2:
	addq.w	#8,a0
	bra.s	.ScanRight2

; -------------------------------------------------------------------------

.FoundRightmost2:
	move.l	a0,objLoadAddrL.w
	move.w	#-1,objPrevCamX.w
; End of function LvlObjMan_Init

; -------------------------------------------------------------------------

LvlObjMan_Main:
	lea	lvlObjRespawns,a2
	moveq	#0,d2
	move.w	cameraX.w,d6
	andi.w	#$FF80,d6
	cmp.w	objPrevCamX.w,d6
	beq.w	LvlObjMan_SameXRange
	bge.s	LvlObjMan_Forward
	nop
	nop
	nop
	nop
	move.w	d6,objPrevCamX.w
	movea.l	objLoadAddrL.w,a0
	subi.w	#$80,d6
	bcs.s	.ScanLeft

.Loop:
	cmp.w -8(a0),d6
	bge.s	.ScanLeft
	subq.w	#8,a0
	tst.b	4(a0)
	bpl.s	.NoRespawn
	subq.b	#1,1(a2)
	move.b	1(a2),d2

.NoRespawn:
	bsr.w	LevelLoadObj
	bne.s	.ScanDone
	subq.w	#8,a0
	bra.s	.Loop

; -------------------------------------------------------------------------

.ScanDone:
	tst.b	4(a0)
	bpl.s	.NoRespawn2
	addq.b	#1,1(a2)
	bclr	#7,2(a2,d3.w)

.NoRespawn2:
	addq.w	#8,a0

.ScanLeft:
	move.l	a0,objLoadAddrL.w
	movea.l	objLoadAddrR.w,a0
	addi.w	#$300,d6

.Loop2:
	cmp.w -8(a0),d6
	bgt.s	.End
	tst.b -4(a0)
	bpl.s	.NextObj
	subq.b	#1,(a2)

.NextObj:
	subq.w	#8,a0
	bra.s	.Loop2

; -------------------------------------------------------------------------

.End:
	move.l	a0,objLoadAddrR.w
	rts

; -------------------------------------------------------------------------

LvlObjMan_Forward:
	nop
	nop
	nop
	nop
	move.w	d6,objPrevCamX.w
	movea.l	objLoadAddrR.w,a0
	addi.w	#$280,d6

.Loop3:
	cmp.w	(a0),d6
	bls.s	.ScanDone2
	tst.b	4(a0)
	bpl.s	.NoRespawn3
	move.b	(a2),d2
	addq.b	#1,(a2)

.NoRespawn3:
	bsr.w	LevelLoadObj
	beq.s	.Loop3
	tst.b	4(a0)
	bpl.s	.ScanDone2
	subq.b	#1,(a2)
	bclr	#7,2(a2,d3.w)

.ScanDone2:
	move.l	a0,objLoadAddrR.w
	movea.l	objLoadAddrL.w,a0
	subi.w	#$300,d6
	bcs.s	.End2

.ScanRight:
	cmp.w	(a0),d6
	bls.s	.End2
	tst.b	4(a0)
	bpl.s	.NextObj2
	addq.b	#1,1(a2)

.NextObj2:
	addq.w	#8,a0
	bra.s	.ScanRight

; -------------------------------------------------------------------------

.End2:
	move.l	a0,objLoadAddrL.w

LvlObjMan_SameXRange:
	rts
; End of function LvlObjMan_Main

; -------------------------------------------------------------------------

CheckObjOccurs:
	moveq	#0,d0
	move.b	timeZone,d0
	bclr	#7,d0
	move.w	d2,d3
	add.w	d3,d3
	add.w	d2,d3
	add.w	d0,d3
	move.b	6(a0),d1
	rol.b	#3,d1
	andi.b	#7,d1
	btst	d0,d1
	rts
; End of function CheckObjOccurs

; -------------------------------------------------------------------------

LevelLoadObj:
	bsr.s	CheckObjOccurs
	beq.s	.SkipObj
	tst.b	4(a0)
	bpl.s	.Load
	bset	#7,2(a2,d3.w)
	beq.s	.Load

.SkipObj:
	addq.w	#8,a0
	moveq	#0,d0
	rts

; -------------------------------------------------------------------------

.Load:
	bsr.w	FindObjSlot
	bne.s	.End
	move.w	(a0)+,oX(a1)
	move.w	(a0)+,d0
	move.w	d0,d1
	andi.w	#$FFF,d0
	move.w	d0,oY(a1)
	rol.w	#2,d1
	andi.b	#3,d1
	move.b	d1,oRender(a1)
	move.b	d1,oStatus(a1)
	move.b	(a0)+,d0
	bpl.s	.NoRespawn
	andi.b	#$7F,d0
	move.b	d2,oRespawn(a1)

.NoRespawn:
	move.b	d0,oID(a1)
	cmpi.b	#$31,d0
	bne.s	.SetFields
	nop
	nop
	nop
	nop

.SetFields:
	move.b	(a0)+,oSubtype(a1)
	move.b	(a0)+,d0
	move.b	(a0)+,oSubtype2(a1)
	moveq	#0,d0

.End:
	rts
; End of function LevelLoadObj

; -------------------------------------------------------------------------

FindObjSlot:
	lea	dynObjects.w,a1
	move.w	#$5F,d0

.Find:
	tst.b	(a1)
	beq.s	.End
	lea	oSize(a1),a1
	dbf	d0,.Find

.End:
	rts
; End of function FindObjSlot

; -------------------------------------------------------------------------

FindNextObjSlot:
	movea.l	a0,a1
	lea	oSize(a1),a1
	move.w	#objectsEnd,d0
	sub.w	a0,d0
	lsr.w	#6,d0
	subq.w	#2,d0
	bcs.s	.End

.Find:
	tst.b	(a1)
	beq.s	.End
	lea	oSize(a1),a1
	dbf	d0,.Find

.End:
	rts
; End of function FindNextObjSlot

; -------------------------------------------------------------------------

CheckObjDespawnTime:
	move.w	8(a0),d0
; End of function CheckObjDespawnTime

; START	OF FUNCTION CHUNK FOR ObjAnton

CheckObjDespawn2Time:
	tst.b	oRender(a0)
	bmi.s	CheckObjDespawn_OnScreen
	andi.w	#$FF80,d0
	move.w	cameraX.w,d1
	subi.w	#$80,d1
	andi.w	#$FF80,d1
	sub.w	d1,d0
	cmpi.w	#$280,d0
	bls.s	CheckObjDespawn_OnScreen

CheckObjDespawnTime_Despawn:
	moveq	#0,d0
	move.b	oRespawn(a0),d0
	beq.s	.DelObj
	lea	lvlObjRespawns,a1
	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,d0
	moveq	#0,d1
	move.b	timeZone,d1
	bclr	#7,d1
	beq.s	.SetRespawn
	move.b	timeWarpDir.w,d2
	ext.w	d2
	neg.w	d2
	add.w	d2,d1
	bpl.s	.NoCap
	moveq	#0,d1
	bra.s	.SetRespawn

; -------------------------------------------------------------------------

.NoCap:
	cmpi.w	#3,d1
	bcs.s	.SetRespawn
	moveq	#2,d1

.SetRespawn:
	add.w	d1,d0
	bclr	#7,2(a1,d0.w)

.DelObj:
	jsr	DeleteObject
	moveq	#1,d0
	rts

; -------------------------------------------------------------------------

CheckObjDespawn_OnScreen:
	btst	#7,timeZone
	bne.s	CheckObjDespawnTime_Despawn
	moveq	#0,d0
	rts
; END OF FUNCTION CHUNK	FOR ObjAnton

; -------------------------------------------------------------------------
LevelObjectIndex:dc.w	Objects_PPZ1A-LevelObjectIndex
	dc.w	Objects_Null-LevelObjectIndex
	dc.w	$FFFF, 0, 0, 0
Objects_PPZ1A:
	incbin	"level/r1/data/objects.bin"
	even
Objects_Null:	dc.w	$FFFF, 0, 0
; -------------------------------------------------------------------------

ObjScenery:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjScenery_Index(pc,d0.w),d0
	jsr	ObjScenery_Index(pc,d0.w)
	jsr	DrawObject
	jmp	CheckObjDespawnTime
; End of function ObjScenery

; -------------------------------------------------------------------------
ObjScenery_Index:dc.w	ObjScenery_Init-ObjScenery_Index
	dc.w	ObjScenery_Main-ObjScenery_Index
; -------------------------------------------------------------------------

ObjScenery_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oRender(a0)
	move.l	#MapSpr_Scenery,oMap(a0)
	move.b	oSubtype(a0),oMapFrame(a0)
	move.b	#$10,oWidth(a0)
	move.b	#$18,oYRadius(a0)
	bsr.w	ObjScenery_SetBaseTile
; End of function ObjScenery_Init

; -------------------------------------------------------------------------

ObjScenery_Main:
	rts
; End of function ObjScenery_Main

; -------------------------------------------------------------------------

ObjScenery_SetBaseTile:
	moveq	#0,d0
	move.b	timeZone,d0
	andi.b	#$7F,d0
	cmpi.b	#2,d0
	bne.s	.NotFuture
	moveq	#1,d0
	add.b	goodFuture,d0

.NotFuture:
	add.w	d0,d0
	add.b	levelAct,d0
	add.w	d0,d0
	move.w	ObjScenery_BaseTileList(pc,d0.w),oTile(a0)
	ori.w	#$4000,oTile(a0)
	rts
; End of function ObjScenery_SetBaseTile

; -------------------------------------------------------------------------
ObjScenery_BaseTileList:
	dc.w	$3DB
	dc.w	$46E
	dc.w	$438
	dc.w	$39F
	dc.w	$438
	dc.w	$38F
MapSpr_Scenery:
	include	"level/r1/objects/scenery/map.asm"
	even
; -------------------------------------------------------------------------

ObjHollowLogBG:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjHollowLogBG_Index(pc,d0.w),d0
	jsr	ObjHollowLogBG_Index(pc,d0.w)
	jsr	DrawObject
	jmp	CheckObjDespawnTime
; End of function ObjHollowLogBG

; -------------------------------------------------------------------------
ObjHollowLogBG_Index:
	dc.w	ObjHollowLogBG_Init-ObjHollowLogBG_Index
	dc.w	ObjHollowLogBG_Main-ObjHollowLogBG_Index
; -------------------------------------------------------------------------

ObjHollowLogBG_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oRender(a0)
	move.b	#6,oPriority(a0)
	move.l	#MapSpr_HollowLogBG,oMap(a0)
	move.b	oSubtype(a0),oMapFrame(a0)
	move.b	#$10,oWidth(a0)
	move.b	#$10,oYRadius(a0)
	bsr.w	ObjHollowLogBG_SetBaseTile
; End of function ObjHollowLogBG_Init

; -------------------------------------------------------------------------

ObjHollowLogBG_Main:
	rts
; End of function ObjHollowLogBG_Main

; -------------------------------------------------------------------------

ObjHollowLogBG_SetBaseTile:
	moveq	#0,d0
	move.b	timeZone,d0
	andi.b	#$7F,d0
	cmpi.b	#2,d0
	bne.s	.NotFuture
	add.b	goodFuture,d0

.NotFuture:
	add.w	d0,d0
	add.b	levelAct,d0
	add.w	d0,d0
	move.w	ObjHollowLogBG_BaseTileList(pc,d0.w),oTile(a0)
	ori.w	#$4000,oTile(a0)
	rts
; End of function ObjHollowLogBG_SetBaseTile

; -------------------------------------------------------------------------
ObjHollowLogBG_BaseTileList:
	dc.w	$3CB, $45E
	dc.w	$418, $3F0
	dc.w	$428, $38F
	dc.w	$428, $37F
MapSpr_HollowLogBG:
	include	"level/r1/objects/logbg/map.asm"
	even
; -------------------------------------------------------------------------

ObjSonicHole:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjSonicHole_Index(pc,d0.w),d0
	jsr	ObjSonicHole_Index(pc,d0.w)
	jmp	CheckObjDespawnTime

; -------------------------------------------------------------------------
ObjSonicHole_Index:dc.w	ObjSonicHole_Init-ObjSonicHole_Index
	dc.w	ObjSonicHole_Main-ObjSonicHole_Index
	dc.w	ObjSonicHole_Display-ObjSonicHole_Index
; -------------------------------------------------------------------------

ObjSonicHole_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oRender(a0)
	move.w	#$3A0,oTile(a0)
	tst.b	timeZone
	bne.s	.NotPast
	move.w	#$3BB,oTile(a0)

.NotPast:
	move.l	#MapSpr_SonicHole,4(a0)
	move.b	#$10,oWidth(a0)
	move.b	#$10,oYRadius(a0)
	move.b	#6,oPriority(a0)
	bsr.w	ObjSonicHole_SetDisplay
	beq.s	.ClearDisplay
	addq.b	#2,oRoutine(a0)
	bra.w	ObjSonicHole_Display

; -------------------------------------------------------------------------

.ClearDisplay:
	bclr	#6,2(a1,d0.w)
; End of function ObjSonicHole_Init

; -------------------------------------------------------------------------

ObjSonicHole_Main:
	lea	objPlayerSlot.w,a6
	tst.b	oPlayerCtrl(a6)
	beq.s	.End
	move.w	oX(a6),d0
	sub.w	oX(a0),d0
	addi.w	#$20,d0
	bmi.s	.End
	cmpi.w	#$40,d0
	bcc.s	.End
	move.w	oY(a6),d0
	sub.w	oY(a0),d0
	addi.w	#$20,d0
	bmi.s	.End
	cmpi.w	#$40,d0
	bcc.s	.End
	bsr.s	ObjSonicHole_SetDisplay
	move.w	#$A3,d0
	jsr	PlayFMSound
	addq.b	#2,oRoutine(a0)
	bra.s	ObjSonicHole_Display

; -------------------------------------------------------------------------

.End:
	rts

; -------------------------------------------------------------------------

ObjSonicHole_Display:
	jmp	DrawObject
; End of function ObjSonicHole_Main

; -------------------------------------------------------------------------

ObjSonicHole_SetDisplay:
	moveq	#0,d0
	move.b	oRespawn(a0),d0
	lea	lvlObjRespawns,a1
	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,d0
	moveq	#0,d1
	move.b	timeZone,d1
	add.w	d1,d0
	bset	#6,2(a1,d0.w)
	rts
; End of function ObjSonicHole_SetDisplay

; -------------------------------------------------------------------------
MapSpr_SonicHole:
	include	"level/r1/objects/sonichole/map.asm"
	even
; -------------------------------------------------------------------------

ObjSpinTunnel:
	btst	#7,timeZone
	beq.s	.NoRespawn
	moveq	#0,d0
	move.b	oRespawn(a0),d0
	beq.s	.NoRespawn
	lea	lvlObjRespawns,a1
	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,d0
	moveq	#0,d1
	move.b	timeZone,d1
	bclr	#7,d1
	move.b	timeWarpDir.w,d2
	ext.w	d2
	neg.w	d2
	add.w	d2,d1
	bpl.s	.NoCap
	moveq	#0,d1
	bra.s	.GetRespawn

; -------------------------------------------------------------------------

.NoCap:
	cmpi.w	#3,d1
	bcs.s	.GetRespawn
	moveq	#2,d1

.GetRespawn:
	add.w	d1,d0
	bclr	#7,2(a1,d0.w)

.NoRespawn:
	lea	objPlayerSlot.w,a6
	cmpi.b	#$2B,oAnim(a6)
	beq.s	.End
	cmpi.b	#6,oRoutine(a6)
	bcc.s	.End
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjSpinTunnel_Index(pc,d0.w),d1
	jsr	ObjSpinTunnel_Index(pc,d1.w)
	cmpi.b	#4,oRoutine(a0)
	bcc.s	.End
	jmp	CheckObjDespawnTime

; -------------------------------------------------------------------------

.End:
	rts
; End of function ObjSpinTunnel

; -------------------------------------------------------------------------
ObjSpinTunnel_Index:
	dc.w	ObjSpinTunnel_Init-ObjSpinTunnel_Index
	dc.w	ObjSpinTunnel_Main-ObjSpinTunnel_Index
	dc.w	ObjSpinTunnel_InitPlayer-ObjSpinTunnel_Index
	dc.w	ObjSpinTunnel_CtrlPlayer-ObjSpinTunnel_Index
; -------------------------------------------------------------------------

ObjSpinTunnel_Init:
	move.l	#MapSpr_Powerup,oMap(a0)
	move.b	#4,oRender(a0)
	move.b	#1,oPriority(a0)
	move.b	#$10,oWidth(a0)
	move.w	#$541,oTile(a0)
	addq.b	#2,oRoutine(a0)
	move.b	oSubtype(a0),d0
	add.w	d0,d0
	andi.w	#$FE,d0
	lea	ObjSpinTunnel_TargetPos(pc),a2
	adda.w	(a2,d0.w),a2
	move.w	(a2)+,oVar3A(a0)
	move.l	a2,oVar3C(a0)
	move.w	(a2)+,oVar36(a0)
	move.w	(a2)+,oVar38(a0)
; End of function ObjSpinTunnel_Init

; -------------------------------------------------------------------------

ObjSpinTunnel_Main:
	move.w	oX(a6),d0
	sub.w	oX(a0),d0
	addi.w	#$10,d0
	cmpi.w	#$20,d0
	bcc.w	.End
	move.w	oY(a6),d1
	sub.w	oY(a0),d1
	addi.w	#$10,d1
	cmpi.w	#$20,d1
	bcc.w	.End
	tst.b	oPlayerCtrl(a6)
	bne.w	.End
	cmpi.b	#4,oRoutine(a6)
	bne.s	.NotHurt
	subq.b	#2,oRoutine(a6)
	move.w	#$78,oPlayerHurt(a6)

.NotHurt:
	addq.b	#2,oRoutine(a0)
	move.b	#$81,oPlayerCtrl(a6)
	tst.b	oSubtype2(a0)
	beq.s	.SetAnimIntertia
	ori.b	#$40,oPlayerCtrl(a6)

.SetAnimIntertia:
	move.b	#2,oAnim(a6)
	bsr.w	ObjSpinTunnel_SetPlayerGVel
	move.w	#0,oXVel(a6)
	move.w	#0,oYVel(a6)
	bclr	#5,oStatus(a0)
	bclr	#5,oStatus(a6)
	bset	#1,oStatus(a6)
	clr.b	oPlayerJump(a6)
	move.w	oX(a0),oX(a6)
	move.w	oY(a0),oY(a6)
	clr.b	oVar32(a0)
	move.w	#$91,d0
	jsr	PlayFMSound

.End:
	rts
; End of function ObjSpinTunnel_Main

; -------------------------------------------------------------------------

ObjSpinTunnel_InitPlayer:
	bsr.w	ObjSpinTunnel_SetPlayerSpeeds
	addq.b	#2,oRoutine(a0)
	move.w	#$91,d0
	jsr	PlayFMSound
	rts
; End of function ObjSpinTunnel_InitPlayer

; -------------------------------------------------------------------------

ObjSpinTunnel_CtrlPlayer:
	subq.b	#1,oVar2E(a0)
	bpl.s	.MovePlayer
	move.w	oVar36(a0),oX(a6)
	move.w	oVar38(a0),oY(a6)
	moveq	#0,d1
	move.b	oVar3A(a0),d1
	addq.b	#4,d1
	cmp.b	oVar3B(a0),d1
	bcs.s	.UpdatePlayer
	moveq	#0,d1
	bra.s	.ResetObj

; -------------------------------------------------------------------------

.UpdatePlayer:
	move.b	d1,oVar3A(a0)
	movea.l	oVar3C(a0),a2
	move.w	(a2,d1.w),oVar36(a0)
	move.w	2(a2,d1.w),oVar38(a0)
	bra.w	ObjSpinTunnel_SetPlayerSpeeds

; -------------------------------------------------------------------------

.MovePlayer:
	move.l	oX(a6),d2
	move.l	oY(a6),d3
	move.w	oXVel(a6),d0
	ext.l	d0
	asl.l	#8,d0
	add.l	d0,d2
	move.w	oYVel(a6),d0
	ext.l	d0
	asl.l	#8,d0
	add.l	d0,d3
	move.l	d2,oX(a6)
	move.l	d3,oY(a6)
	rts

; -------------------------------------------------------------------------

.ResetObj:
	andi.w	#$7FF,oY(a6)
	clr.b	oRoutine(a0)
	clr.b	oPlayerCtrl(a6)
	move.w	#2,oRoutine(a0)
	rts
; End of function ObjSpinTunnel_CtrlPlayer

; -------------------------------------------------------------------------

ObjSpinTunnel_SetPlayerSpeeds:
	moveq	#0,d0
	move.w	oPlayerGVel(a6),d2
	move.w	oPlayerGVel(a6),d3
	move.w	oVar36(a0),d0
	sub.w	oX(a6),d0
	bge.s	.PlayerLeft
	neg.w	d0
	neg.w	d2

.PlayerLeft:
	moveq	#0,d1
	move.w	oVar38(a0),d1
	sub.w	oY(a6),d1
	bge.s	.PlayerAbove
	neg.w	d1
	neg.w	d3

.PlayerAbove:
	cmp.w	d0,d1
	bcs.s	.DXGreater
	moveq	#0,d1
	move.w	oVar38(a0),d1
	sub.w	oY(a6),d1
	swap	d1
	divs.w	d3,d1
	moveq	#0,d0
	move.w	oVar36(a0),d0
	sub.w	oX(a6),d0
	beq.s	.ZeroDivide
	swap	d0
	divs.w	d1,d0

.ZeroDivide:
	move.w	d0,oXVel(a6)
	move.w	d3,oYVel(a6)
	tst.w	d1
	bpl.s	.SetSign
	neg.w	d1

.SetSign:
	move.w	d1,oVar2E(a0)
	rts

; -------------------------------------------------------------------------

.DXGreater:
	moveq	#0,d0
	move.w	oVar36(a0),d0
	sub.w	oX(a6),d0
	swap	d0
	divs.w	d2,d0
	moveq	#0,d1
	move.w	oVar38(a0),d1
	sub.w	oY(a6),d1
	beq.s	.ZeroDivide2
	swap	d1
	divs.w	d0,d1

.ZeroDivide2:
	move.w	d1,oYVel(a6)
	move.w	d2,oXVel(a6)
	tst.w	d0
	bpl.s	.SetSign2
	neg.w	d0

.SetSign2:
	move.w	d0,oVar2E(a0)
	rts
; End of function ObjSpinTunnel_SetPlayerSpeeds

; -------------------------------------------------------------------------

ObjSpinTunnel_SetPlayerGVel:
	move.w	#$1000,oPlayerGVel(a6)
	moveq	#0,d0
	move.b	oSubtype(a0),d0
	bmi.s	.End
	andi.w	#$F,d0
	add.w	d0,d0
	move.w	ObjSpinTunnel_GVels(pc,d0.w),d0
	cmp.w	oPlayerGVel(a6),d0
	ble.s	.End
	move.w	d0,oPlayerGVel(a6)

.End:
	rts
; End of function ObjSpinTunnel_SetPlayerGVel

; -------------------------------------------------------------------------
ObjSpinTunnel_GVels:dc.w	$1000
	dc.w	$C00
	dc.w	$C00
	dc.w	$800
ObjSpinTunnel_TargetPos:dc.w	word_208D9E-ObjSpinTunnel_TargetPos
	dc.w	word_208E28-ObjSpinTunnel_TargetPos
	dc.w	word_208E6E-ObjSpinTunnel_TargetPos
word_208D9E:	dc.w	$88, $1440, $F0, $1478, $108, $1490, $140,	$1490
	dc.w	$1E0, $1440, $1F8,	$1400, $1E0, $13F0, $1C0, $13F0
	dc.w	$180, $1400, $170,	$1420, $168, $1440, $170, $1468
	dc.w	$1A8, $1660, $218,	$16A0, $210, $16C0, $1F8, $16D0
	dc.w	$1C8, $16C0, $1A8,	$1680, $198, $1658, $1A0, $1640
	dc.w	$1C8, $1650, $1F0,	$1680, $200, $16C0, $200, $16D0
	dc.w	$210, $16D0, $288,	$16C0, $2C0, $1680, $2D8, $1650
	dc.w	$2C0, $1650, $2A0,	$1680, $290, $1700, $290, $1728
	dc.w	$2A0, $1728, $2E0,	$1700, $2F0
word_208E28:	dc.w	$44, $F08,	$1A0, $F90, $1A0, $FC8,	$1B8, $FE0
	dc.w	$1F0, $FE0, $260, $1000, $290, $1030, $2A0, $1068
	dc.w	$288, $1080, $250,	$1068, $218, $1030, $200, $FF0
	dc.w	$220, $FE0, $260, $1000, $290, $1030, $2A0, $1068
	dc.w	$288, $1130, $1C8
word_208E6E:	dc.w	$44, $1630, $290, $1630, $318, $1638, $338, $16D0
	dc.w	$3D0, $1700, $3E0,	$1738, $3C8, $1758, $390, $1738
	dc.w	$358, $16F8, $340,	$16C0, $360, $16A8, $390, $16D0
	dc.w	$3D0, $1700, $3E0,	$1738, $3C8, $17B8, $348, $17D0
	dc.w	$320, $17D0, $268
; -------------------------------------------------------------------------

ClearObjRide:
	btst	#3,oStatus(a0)
	beq.s	.End
	btst	#3,oStatus(a1)
	beq.s	.End
	moveq	#0,d0
	move.b	oPlayerStandObj(a1),d0
	lsl.w	#6,d0
	addi.l	#objPlayerSlot&$FFFFFF,d0
	cmpa.w	d0,a0
	bne.s	.End
	tst.b	oPlayerCharge(a1)
	beq.s	.NoSound
	move.w	#$AB,d0
	jsr	PlayFMSound

.NoSound:
	clr.b	oPlayerStick(a1)
	bset	#1,oStatus(a1)
	bclr	#3,oStatus(a1)
	bclr	#3,oStatus(a0)
	btst	#6,oPlayerCtrl(a1)
	bne.s	.ReleasePlayer
	cmpi.b	#$17,oAnim(a1)
	beq.s	.ReleasePlayer
	bclr	#0,oPlayerCtrl(a1)

.ReleasePlayer:
	clr.b	oPlayerStandObj(a1)
	cmpi.b	#$2B,oAnim(a1)
	bne.s	.End
	bclr	#1,oStatus(a1)

.End:
	rts
; End of function ClearObjRide

; -------------------------------------------------------------------------

RideObject:
	cmpi.b	#4,oRoutine(a1)
	bne.s	.NotHurt
	subq.b	#2,oRoutine(a1)
	move.w	#$78,oPlayerHurt(a1)

.NotHurt:
	clr.b	oRoutine2(a0)
	clr.b	oPlayerJump(a1)
	bset	#3,oStatus(a0)
	bne.s	.SetRide
	cmpi.b	#$2B,oAnim(a1)
	bne.s	.NotGivingUp
	bclr	#3,oStatus(a0)
	bra.w	ClearObjRide

; -------------------------------------------------------------------------

.NotGivingUp:
	bclr	#4,oStatus(a1)
	bclr	#2,oStatus(a1)
	beq.s	.SetRide
	tst.b	miniSonic
	beq.s	.NotMini
	move.b	#$A,oYRadius(a1)
	move.b	#5,oXRadius(a1)
	subq.w	#2,oY(a1)
	bra.s	.SetWalk

; -------------------------------------------------------------------------

.NotMini:
	move.b	#$13,oYRadius(a1)
	move.b	#9,oXRadius(a1)
	subq.w	#5,oY(a1)

.SetWalk:
	move.b	#0,oAnim(a1)

.SetRide:
	bset	#3,oStatus(a1)
	beq.s	.SetInteract
	moveq	#0,d0
	move.b	oPlayerStandObj(a1),d0
	lsl.w	#6,d0
	addi.l	#objPlayerSlot&$FFFFFF,d0
	cmpa.w	d0,a0
	beq.s	.End
	movea.l	d0,a2
	bclr	#3,oStatus(a2)

.SetInteract:
	move.w	a0,d0
	subi.w	#objPlayerSlot,d0
	lsr.w	#6,d0
	andi.w	#$7F,d0
	move.b	d0,oPlayerStandObj(a1)
	move.b	#0,oAngle(a1)
	move.w	#0,oYVel(a1)
	cmpi.b	#$A,oID(a0)
	bne.s	.SetInertia
	cmpi.b	#2,oRoutine(a0)
	beq.s	.ClearAirBit

.SetInertia:
	move.w	oXVel(a1),oPlayerGVel(a1)

.ClearAirBit:
	bclr	#1,oStatus(a1)

.End:
	rts
; End of function RideObject

; -------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR ObjSpring_SolidObject3

SolidObject2:
	move.b	#2,oRoutine2(a0)
	bra.s	SolidObject
; END OF FUNCTION CHUNK	FOR ObjSpring_SolidObject3
; -------------------------------------------------------------------------

SolidObject1:
	move.b	#1,oRoutine2(a0)
; End of function SolidObject1

; -------------------------------------------------------------------------

SolidObject:
	cmpi.b	#$17,oAnim(a1)
	beq.w	.ClearTouch
	btst	#6,oPlayerCtrl(a1)
	bne.w	.ClearTouch
	cmpi.b	#6,oRoutine(a1)
	bcc.w	.ClearTouch
	tst.b	oID(a1)
	beq.w	.ClearTouch
	tst.b	oRender(a0)
	bpl.w	.ClearTouch
	tst.b	lvlDebugMode
	bne.w	.ClearTouch
	move.b	oWidth(a0),d1
	ext.w	d1
	addi.w	#$A,d1
	move.w	oX(a1),d0
	sub.w	oX(a0),d0
	add.w	d1,d0
	bmi.w	.ClearTouch
	move.w	d1,d2
	add.w	d2,d2
	cmp.w	d2,d0
	bcc.w	.ClearTouch
	cmpi.b	#$2B,oAnim(a1)
	bne.s	.NotGivingUp
	btst	#3,oStatus(a0)
	bne.s	.CheckYRange
	bra.w	.ClearTouch

; -------------------------------------------------------------------------

.NotGivingUp:
	cmpi.b	#1,oRoutine2(a0)
	bne.s	.CheckYRange
	tst.w	oYVel(a1)
	beq.s	.CheckYRange
	bmi.w	.ClearTouch

.CheckYRange:
	move.b	oYRadius(a0),d2
	ext.w	d2
	move.b	oYRadius(a1),d3
	ext.w	d3
	add.w	d2,d3
	addq.w	#2,d3
	move.w	oY(a1),d2
	sub.w	oY(a0),d2
	add.w	d3,d2
	bmi.w	.ClearTouch
	move.w	d3,d4
	add.w	d4,d4
	cmp.w	d4,d2
	bcc.w	.ClearTouch
	move.w	d0,d4
	cmp.w	d0,d1
	bcc.s	.GotDistToXEdge
	add.w	d1,d1
	sub.w	d1,d0
	move.w	d0,d4
	neg.w	d4

.GotDistToXEdge:
	move.w	d2,d5
	cmp.w	d2,d3
	bcc.s	.GotDistToYEdge
	add.w	d3,d3
	sub.w	d3,d2
	move.w	d2,d5
	neg.w	d5

.GotDistToYEdge:
	cmp.w	d4,d5
	bcs.w	.CollideVert
	cmpi.b	#1,oRoutine2(a0)
	beq.w	.ClearTouch
	cmpi.b	#$A,oID(a0)
	bne.s	.NotSpring
	btst	#1,oStatus(a1)
	bne.w	.ClearTouch

.NotSpring:
	cmpi.b	#4,d5
	bls.w	.ClearTouch
	bsr.w	CrushBetweenObjects
	move.l	d0,-(sp)
	bsr.w	ClearObjRide
	clr.b	oRoutine2(a0)
	move.l	(sp)+,d0
	sub.w	d0,oX(a1)
	tst.w	d0
	bmi.s	.PlayerLeft
	tst.w	oXVel(a1)
	beq.s	.LeaveXSpd
	bpl.s	.HaltOnX
	bra.s	.LeaveXSpd

; -------------------------------------------------------------------------

.PlayerLeft:
	tst.w	oXVel(a1)
	beq.s	.LeaveXSpd
	bpl.s	.LeaveXSpd

.HaltOnX:
	bsr.w	CrushAgainstWall
	btst	#1,oStatus(a1)
	bne.s	.ClearXSpd
	bset	#5,oStatus(a1)
	bset	#5,oStatus(a0)
	move.w	#0,oPlayerGVel(a1)

.ClearXSpd:
	move.w	#0,oXVel(a1)
	moveq	#0,d0
	rts

; -------------------------------------------------------------------------

.LeaveXSpd:
	bsr.w	ClearObjPush
	bsr.w	CrushAgainstWall
	bclr	#5,oStatus(a1)
	bclr	#5,oStatus(a0)
	moveq	#0,d0
	rts

; -------------------------------------------------------------------------

.CollideVert:
	cmpi.b	#$19,oID(a0)
	bne.s	.NotMonitor
	btst	#2,oStatus(a1)
	bne.w	.ClearTouch

.NotMonitor:
	move.b	oYRadius(a0),d0
	ext.w	d0
	move.b	oYRadius(a1),d1
	ext.w	d1
	add.w	d0,d1
	tst.w	d2
	beq.s	.SonicAbove
	bmi.w	.SonicBelow

.SonicAbove:
	cmpi.b	#$2B,oAnim(a1)
	beq.s	.NotGivingUp2
	tst.w	oYVel(a1)
	beq.s	.NotGivingUp2
	bmi.w	.ClearTouch

.NotGivingUp2:
	move.w	oY(a0),oY(a1)
	sub.w	d1,oY(a1)
	moveq	#0,d1
	move.w	oXVel(a0),d1
	ext.l	d1
	asl.l	#8,d1
	move.l	oX(a1),d0
	add.l	d1,d0
	move.l	d0,oX(a1)
	move.b	#$C0,d0
	tst.w	oXVel(a0)
	beq.s	.MoveOnY
	bpl.s	.AbsSpeed
	neg.b	d0

.AbsSpeed:
	movem.l	a0-a1,-(sp)
	movea.l	a1,a0
	jsr	Player_CalcRoomInFront
	movem.l	(sp)+,a0-a1
	tst.w	d1
	bpl.s	.MoveOnY
	tst.w	oXVel(a0)
	bpl.s	.MoveOutOfWall
	neg.w	d1

.MoveOutOfWall:
	add.w	d1,oX(a1)

.MoveOnY:
	moveq	#0,d1
	move.w	oYVel(a0),d1
	ext.l	d1
	asl.l	#8,d1
	move.l	oY(a1),d0
	add.l	d1,d0
	move.l	d0,oY(a1)
	cmpi.b	#$A,oID(a0)
	beq.s	.SetRide
	tst.w	oYVel(a0)
	bmi.s	.CheckCrushCeiling
	movem.l	a0-a1,-(sp)
	movea.l	a1,a0
	jsr	Player_CheckFloor
	movem.l	(sp)+,a0-a1
	tst.w	d1
	bpl.s	.CheckCrushCeiling
	add.w	d1,oY(a1)
	bra.w	.ClearTouch

; -------------------------------------------------------------------------

.CheckCrushCeiling:
	tst.w	oYVel(a0)
	bpl.s	.SetRide
	movem.l	a0-a1,-(sp)
	movea.l	a1,a0
	jsr	Player_GetCeilDist
	movem.l	(sp)+,a0-a1
	tst.w	d1
	bpl.s	.SetRide
	movem.l	a0-a1,-(sp)
	movea.l	a1,a0
	jsr	KillPlayer
	movem.l	(sp)+,a0-a1
	bra.s	.ClearTouch

; -------------------------------------------------------------------------

.SetRide:
	bsr.w	RideObject
	moveq	#1,d0
	rts

; -------------------------------------------------------------------------

.SonicBelow:
	cmpi.b	#1,oRoutine2(a0)
	beq.s	.ClearTouch
	cmpi.b	#9,oID(a0)
	beq.s	.ClearTouch
	cmpi.b	#$A,oID(a0)
	bne.s	.CheckCrushFloor
	cmpi.b	#2,oRoutine2(a0)
	beq.s	.AlignToBottom
	btst	#1,oRender(a0)
	bne.s	.AlignToBottom
	bra.s	.ClearTouch

; -------------------------------------------------------------------------

.CheckCrushFloor:
	btst	#1,oStatus(a1)
	bne.s	.AlignToBottom
	tst.w	oYVel(a0)
	beq.s	.AlignToBottom
	bmi.s	.AlignToBottom
	movem.l	a0-a1,-(sp)
	movea.l	a1,a0
	jsr	KillPlayer
	movem.l	(sp)+,a0-a1

.AlignToBottom:
	sub.w	d2,oY(a1)
	move.w	#0,oYVel(a1)
	bsr.w	ClearObjPush
	bsr.w	ClearObjRide
	clr.b	oRoutine2(a0)
	moveq	#1,d0
	rts

; -------------------------------------------------------------------------

.ClearTouch:
	bsr.w	ClearObjPush
	bsr.w	ClearObjRide
	clr.b	oRoutine2(a0)
	moveq	#0,d0
	rts
; End of function SolidObject

; -------------------------------------------------------------------------

CrushAgainstWall:
	tst.w	oXVel(a0)
	beq.s	.End
	cmpi.b	#$A,oID(a0)
	beq.s	.End
	move.b	#$C0,d0
	tst.w	oXVel(a0)
	bpl.s	.AbsSpeed
	neg.b	d0

.AbsSpeed:
	movem.l	a0-a1,-(sp)
	movea.l	a1,a0
	jsr	Player_CalcRoomInFront
	movem.l	(sp)+,a0-a1
	tst.w	d1
	bpl.s	.End
	movem.l	a0-a1,-(sp)
	movea.l	a1,a0
	jsr	KillPlayer
	movem.l	(sp)+,a0-a1

.End:
	rts
; End of function CrushAgainstWall

; -------------------------------------------------------------------------

CrushBetweenObjects:
	cmpi.b	#$A,oID(a0)
	bne.s	.NotSpring
	move.b	#0,oPlayerPushObj(a1)
	rts

; -------------------------------------------------------------------------

.NotSpring:
	moveq	#0,d1
	move.b	oPlayerPushObj(a1),d1
	beq.s	.SetIneract
	lsl.w	#6,d1
	addi.l	#objPlayerSlot&$FFFFFF,d1
	cmpa.w	d1,a0
	beq.s	.End
	movea.l	d1,a2
	tst.w	oXVel(a0)
	bne.s	.MayCrush
	tst.w	oXVel(a2)
	beq.s	.End

.MayCrush:
	move.w	oX(a1),d1
	cmp.w	oX(a0),d1
	bcc.s	.PossibleCrush
	cmp.w	oX(a2),d1
	bcs.s	.End
	bra.s	.ChkKill

; -------------------------------------------------------------------------

.PossibleCrush:
	cmp.w	oX(a2),d1
	bcc.s	.End

.ChkKill:
	cmpi.b	#$15,oID(a0)
	beq.s	.End
	movem.l	d0/a0-a1,-(sp)
	movea.l	a1,a0
	jsr	KillPlayer
	movem.l	(sp)+,d0/a0-a1
	rts

; -------------------------------------------------------------------------

.SetIneract:
	move.w	a0,d1
	subi.w	#objPlayerSlot,d1
	lsr.w	#6,d1
	andi.w	#$7F,d1
	move.b	d1,oPlayerPushObj(a1)

.End:
	rts
; End of function CrushBetweenObjects

; -------------------------------------------------------------------------

ClearObjPush:
	moveq	#0,d1
	move.b	oPlayerPushObj(a1),d1
	beq.s	.End
	lsl.w	#6,d1
	addi.l	#objPlayerSlot&$FFFFFF,d1
	cmpa.w	d1,a0
	bne.s	.End
	move.b	#0,oPlayerPushObj(a1)

.End:
	rts
; End of function ClearObjPush

; -------------------------------------------------------------------------

ObjRotPlatform_SolidObj:
	move.w	oX(a0),d3
	move.w	oY(a0),d4
	jmp	SolidObject
; End of function ObjRotPlatform_SolidObj

; -------------------------------------------------------------------------

ObjRotPlatform:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjRotPlatform_Index(pc,d0.w),d0
	jsr	ObjRotPlatform_Index(pc,d0.w)
	tst.w	timeStopTimer
	bne.s	.SkipAnim
	lea	Ani_RotPlatform,a1
	bsr.w	AnimateObject

.SkipAnim:
	jsr	DrawObject
	jmp	CheckObjDespawnTime
; End of function ObjRotPlatform

; -------------------------------------------------------------------------
ObjRotPlatform_Index:
	dc.w	ObjRotPlatform_Init-ObjRotPlatform_Index
	dc.w	ObjRotPlatform_Main-ObjRotPlatform_Index
; -------------------------------------------------------------------------

ObjRotPlatform_Init:
	addq.b	#2,oRoutine(a0)
	move.b	#4,oRender(a0)
	move.b	#4,oPriority(a0)
	move.l	#MapSpr_RotPlatform,oMap(a0)
	moveq	#6,d0
	jsr	LevelObj_SetBaseTile(pc)
	move.b	#$10,oWidth(a0)
	move.b	#8,oYRadius(a0)
; End of function ObjRotPlatform_Init

; -------------------------------------------------------------------------

ObjRotPlatform_Main:

; FUNCTION CHUNK AT 002094F8 SIZE 000000C6 BYTES

	tst.b	oRender(a0)
	bpl.w	.End
	lea	objPlayerSlot.w,a1
	bsr.s	ObjRotPlatform_SolidObj
	beq.s	.End
	bset	#0,oPlayerCtrl(a1)
	bne.s	.DidInit
	move.b	#$2D,oAnim(a1)
	moveq	#0,d0
	move.b	d0,oPlayerRotAngle(a1)
	move.w	oX(a1),d0
	sub.w	oX(a0),d0
	bcc.s	.PlayerRight
	neg.w	d0
	move.b	#$80,oPlayerRotAngle(a1)

.PlayerRight:
	move.b	d0,oPlayerRotDist(a1)

.DidInit:
	cmpi.b	#6,oRoutine(a1)
	bcc.s	.End
	bra.s	.MoveSonic

; -------------------------------------------------------------------------

.End:
	rts

; -------------------------------------------------------------------------

.MoveSonic:
	addq.b	#8,oPlayerRotAngle(a1)
	move.b	oPlayerRotAngle(a1),d0
	jsr	CalcSine
	moveq	#0,d0
	move.b	oPlayerRotDist(a1),d0
	muls.w	d1,d0
	lsr.l	#8,d0
	move.w	oX(a0),oX(a1)
	add.w	d0,oX(a1)
	moveq	#0,d0
	move.b	oPlayerRotAngle(a1),d0
	move.b	d0,d1
	andi.b	#$F0,d0
	lsr.b	#4,d0
	move.b	ObjRotPlatform_PlayerFrames(pc,d0.w),oAnimFrame(a1)
	andi.b	#$3F,d1
	bne.s	.ChkInput
	addq.b	#1,oPlayerRotDist(a1)

.ChkInput:
	move.w	p1CtrlData.w,playerCtrl.w
	bsr.w	ObjRotPlatform_CheckDirs
	bra.w	ObjRotPlatform_CheckJump
; End of function ObjRotPlatform_Main

; -------------------------------------------------------------------------
	rts

; -------------------------------------------------------------------------
ObjRotPlatform_PlayerFrames:dc.b	0, 0, 0, 1, 1,	2, 2, 2, 3, 3, 3, 4, 4,	5, 5, 5
; -------------------------------------------------------------------------

ObjRotPlatform_CheckDirs:
	move.w	oX(a1),d0
	sub.w	oX(a0),d0
	bcc.s	.ChkRight2
	btst	#2,playerCtrlHold.w
	beq.s	.ChkRight
	addq.b	#1,oPlayerRotDist(a1)
	bra.s	.End

; -------------------------------------------------------------------------

.ChkRight:
	btst	#3,playerCtrlHold.w
	beq.s	.End
	subq.b	#1,oPlayerRotDist(a1)
	bcc.s	.End
	move.b	#0,oPlayerRotDist(a1)
	bra.s	.End

; -------------------------------------------------------------------------

.ChkRight2:
	btst	#3,playerCtrlHold.w
	beq.s	.ChkLeft
	addq.b	#1,oPlayerRotDist(a1)
	bra.s	.End

; -------------------------------------------------------------------------

.ChkLeft:
	btst	#2,playerCtrlHold.w
	beq.s	.End
	subq.b	#1,oPlayerRotDist(a1)
	bcc.s	.End
	move.b	#0,oPlayerRotDist(a1)

.End:
	rts
; End of function ObjRotPlatform_CheckDirs

; -------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR ObjRotPlatform_Main

ObjRotPlatform_CheckJump:
	move.b	playerCtrlTap.w,d0
	andi.b	#$70,d0
	beq.w	.End2
	clr.b	oPlayerCtrl(a1)
	move.w	#$680,d2
	btst	#6,oStatus(a0)
	beq.s	.NoWater
	move.w	#$380,d2

.NoWater:
	moveq	#0,d0
	move.b	oAngle(a1),d0
	subi.b	#$40,d0
	jsr	CalcSine
	muls.w	d2,d1
	asr.l	#8,d1
	add.w	d1,oXVel(a1)
	muls.w	d2,d0
	asr.l	#8,d0
	add.w	d0,oYVel(a1)
	bset	#1,oStatus(a1)
	bclr	#5,oStatus(a1)
	move.b	#1,oPlayerJump(a1)
	clr.b	oPlayerStick(a1)
	move.w	#$A0,d0
	jsr	PlayFMSound
	tst.b	miniSonic
	beq.s	.NotMini
	move.b	#$A,oYRadius(a1)
	move.b	#5,oXRadius(a1)
	bra.s	.GotSize

; -------------------------------------------------------------------------

.NotMini:
	move.b	#$13,oYRadius(a1)
	move.b	#9,oXRadius(a1)

.GotSize:
	btst	#2,oStatus(a1)
	bne.s	.RollJump
	tst.b	miniSonic
	beq.s	.NotMini2
	move.b	#$A,oYRadius(a1)
	move.b	#5,oXRadius(a1)
	bra.s	.SetRoll

; -------------------------------------------------------------------------

.NotMini2:
	move.b	#$E,oYRadius(a1)
	move.b	#7,oXRadius(a1)
	addq.w	#5,oY(a1)

.SetRoll:
	bset	#2,oStatus(a1)
	move.b	#2,oAnim(a1)

.End2:
	rts

; -------------------------------------------------------------------------

.RollJump:
	bset	#4,oStatus(a1)
	rts
; END OF FUNCTION CHUNK	FOR ObjRotPlatform_Main

; -------------------------------------------------------------------------
Ani_RotPlatform:
	include	"level/r1/objects/rotatingptfm/anim.asm"
	even
MapSpr_RotPlatform:
	include	"level/r1/objects/rotatingptfm/map.asm"
	even
; -------------------------------------------------------------------------

ObjGrayRock:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjGrayRock_Index(pc,d0.w),d0
	jsr	ObjGrayRock_Index(pc,d0.w)
	jsr	DrawObject
	jmp	CheckObjDespawnTime
; End of function ObjGrayRock

; -------------------------------------------------------------------------
ObjGrayRock_Index:dc.w	ObjGrayRock_Init-ObjGrayRock_Index
	dc.w	ObjGrayRock_Main-ObjGrayRock_Index
; -------------------------------------------------------------------------

ObjGrayRock_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oRender(a0)
	move.b	#4,oPriority(a0)
	move.l	#MapSpr_GrayRock,oMap(a0)
	move.b	#$10,oWidth(a0)
	move.b	#$10,oYRadius(a0)
	move.b	#0,oMapFrame(a0)
	moveq	#$B,d0
	jsr	LevelObj_SetBaseTile
; End of function ObjGrayRock_Init

; -------------------------------------------------------------------------

ObjGrayRock_Main:
	tst.b	oRender(a0)
	bpl.s	.End
	lea	objPlayerSlot.w,a1
	move.w	oX(a0),d3
	move.w	oY(a0),d4
	jmp	SolidObject

; -------------------------------------------------------------------------

.End:
	rts
; End of function ObjGrayRock_Main

; -------------------------------------------------------------------------
MapSpr_GrayRock:
	include	"level/r1/objects/grayrock/map.asm"
	even
; -------------------------------------------------------------------------

ObjMovingSpring:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjMovingSpring_Index(pc,d0.w),d0
	jsr	ObjMovingSpring_Index(pc,d0.w)
	move.w	oVar36(a0),d0
	andi.w	#$FF80,d0
	move.w	cameraX.w,d1
	subi.w	#$80,d1
	andi.w	#$FF80,d1
	sub.w	d1,d0
	cmpi.w	#$280,d0
	bhi.w	DeleteObject
	rts

; -------------------------------------------------------------------------
ObjMovingSpring_Index:dc.w	ObjMovingSpring_Init-ObjMovingSpring_Index
	dc.w	ObjMovingSpring_AlignToGround-ObjMovingSpring_Index
	dc.w	ObjMovingSpring_Main-ObjMovingSpring_Index
; -------------------------------------------------------------------------

ObjMovingSpring_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oRender(a0)
	move.b	#4,oPriority(a0)
	move.l	#MapSpr_MovingSpring,oMap(a0)
	move.b	#8,oWidth(a0)
	move.b	#7,oYRadius(a0)
	move.w	oX(a0),oVar36(a0)
	move.w	#$180,oXVel(a0)
	moveq	#$E,d0
	jsr	LevelObj_SetBaseTile
	jsr	FindObjSlot
	beq.s	.GenSpring
	jmp	DeleteObject

; -------------------------------------------------------------------------

.GenSpring:
	move.b	#$A,oID(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	subi.w	#$10,oY(a1)
	move.b	#$F0,oVar39(a1)
	move.w	a0,oVar34(a1)
	move.b	oSubtype(a0),oSubtype(a1)
; End of function ObjMovingSpring_Init

; -------------------------------------------------------------------------

ObjMovingSpring_AlignToGround:
	jsr	CheckFloorEdge
	tst.w	d1
	bpl.s	.Sink
	add.w	d1,oY(a0)
	move.w	oY(a0),oVar32(a0)
	addq.b	#2,oRoutine(a0)
	rts

; -------------------------------------------------------------------------

.Sink:
	addq.w	#1,oY(a0)
	rts
; End of function ObjMovingSpring_AlignToGround

; -------------------------------------------------------------------------

ObjMovingSpring_Main:
	tst.w	timeStopTimer
	bne.s	.Display
	jsr	CheckFloorEdge
	add.w	d1,oY(a0)
	move.w	oVar32(a0),d0
	sub.w	oY(a0),d0
	cmpi.w	#$C,d0
	bcs.s	.NotEdge
	neg.w	oXVel(a0)

.NotEdge:
	jsr	ObjMove
	lea	Ani_MovingSpring,a1
	jsr	AnimateObject

.Display:
	jmp	DrawObject
; End of function ObjMovingSpring_Main

; -------------------------------------------------------------------------

ObjSpring2:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjSpring2_Index(pc,d0.w),d0
	jmp	ObjSpring2_Index(pc,d0.w)
; End of function ObjSpring2

; -------------------------------------------------------------------------
ObjSpring2_Index:dc.w	ObjSpring2_Init-ObjSpring2_Index
	dc.w	ObjSpring2_Main-ObjSpring2_Index
; -------------------------------------------------------------------------

ObjSpring2_Init:
	move.l	#MapSpr_Spring1,oMap(a0)
	move.w	#$8520,oTile(a0)
	ori.b	#4,oRender(a0)
	move.b	#$10,oWidth(a0)
	move.b	#8,oYRadius(a0)
	move.b	#4,oPriority(a0)
	addq.b	#2,oRoutine(a0)
; End of function ObjSpring2_Init

; -------------------------------------------------------------------------

ObjSpring2_Main:
	move.w	objPlayerSlot+oX.w,oX(a0)
	move.w	objPlayerSlot+oY.w,oY(a0)
	jmp	DrawObject
; End of function ObjSpring2_Main

; -------------------------------------------------------------------------

ObjSpring:
	cmpi.b	#5,oRoutine2(a0)
	beq.s	ObjSpring2
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	beq.s	.DoControl
	tst.b	oRender(a0)
	bpl.s	.DisplayOnly

.DoControl:
	move.w	ObjSpring_Index(pc,d0.w),d1
	jsr	ObjSpring_Index(pc,d1.w)

.DisplayOnly:
	bsr.w	DrawObject
	move.l	#$FFFF0000,d1
	move.w	oVar34(a0),d1
	beq.s	.ChkDel
	movea.l	d1,a1
	move.w	oX(a1),oX(a0)
	move.w	oY(a1),oY(a0)
	move.b	oVar38(a0),d0
	ext.w	d0
	add.w	d0,oX(a0)
	move.b	oVar39(a0),d0
	ext.w	d0
	add.w	d0,oY(a0)

.ChkDel:
	move.w	oVar36(a0),d0
	andi.w	#$FF80,d0
	move.w	cameraX.w,d1
	subi.w	#$80,d1
	andi.w	#$FF80,d1
	sub.w	d1,d0
	cmpi.w	#$280,d0
	bhi.w	DeleteObject
	rts
; End of function ObjSpring

; -------------------------------------------------------------------------
ObjSpring_Index:dc.w	ObjSpring_Init-ObjSpring_Index
	dc.w	ObjSpring_Main_Up-ObjSpring_Index
	dc.w	ObjSpring_Anim_Up-ObjSpring_Index
	dc.w	ObjSpring_Reset_Up-ObjSpring_Index
	dc.w	ObjSpring_Main_Side-ObjSpring_Index
	dc.w	ObjSpring_Anim_Side-ObjSpring_Index
	dc.w	ObjSpring_Reset_Side-ObjSpring_Index
	dc.w	ObjSpring_Main_Down-ObjSpring_Index
	dc.w	ObjSpring_Anim_Down-ObjSpring_Index
	dc.w	ObjSpring_Reset_Down-ObjSpring_Index
	dc.w	ObjSpring_Main_Diag-ObjSpring_Index
	dc.w	ObjSpring_Anim_Diag-ObjSpring_Index
	dc.w	ObjSpring_Reset_Diag-ObjSpring_Index
; -------------------------------------------------------------------------

ObjSpring_Init:
	addq.b	#2,oRoutine(a0)
	move.l	#MapSpr_Spring1,oMap(a0)
	move.w	#$520,oTile(a0)
	ori.b	#4,oRender(a0)
	move.b	#$10,oWidth(a0)
	move.b	#8,oYRadius(a0)
	move.w	oX(a0),oVar36(a0)
	move.b	#4,oPriority(a0)
	move.b	oSubtype(a0),d0
	btst	#2,d0
	beq.s	.SubtypeB2Clear
	move.b	#8,oRoutine(a0)
	move.b	#8,oWidth(a0)
	move.b	#$10,oYRadius(a0)
	move.l	#MapSpr_Spring2,oMap(a0)
	bra.s	.NoFlip

; -------------------------------------------------------------------------

.SubtypeB2Clear:
	btst	#3,d0
	beq.s	.SubtypeB3Clear
	move.b	#$14,oRoutine(a0)
	move.b	#$18,oWidth(a0)
	move.b	#$C,oYRadius(a0)
	move.l	#MapSpr_Spring3,oMap(a0)
	move.l	d0,-(sp)
	moveq	#$F,d0
	jsr	LevelObj_SetBaseTile
	move.l	(sp)+,d0
	bra.s	.NoFlip

; -------------------------------------------------------------------------

.SubtypeB3Clear:
	btst	#1,oRender(a0)
	beq.s	.NoFlip
	move.b	#$E,oRoutine(a0)
	bset	#1,oStatus(a0)

.NoFlip:
	btst	#1,d0
	beq.s	.RedSpring
	bset	#5,oTile(a0)

.RedSpring:
	andi.w	#2,d0
	move.w	ObjSpring_Speeds(pc,d0.w),oVar30(a0)
	rts
; End of function ObjSpring_Init

; -------------------------------------------------------------------------
ObjSpring_Speeds:dc.w	$F000
	dc.w	$F600
; -------------------------------------------------------------------------

ObjSpring_SolidObject:
	move.w	oX(a0),d3
	move.w	oY(a0),d4
	jmp	SolidObject
; End of function ObjSpring_SolidObject

; -------------------------------------------------------------------------

ObjSpring_Main_Up:
	tst.b	oRender(a0)
	bpl.s	.End
	lea	objPlayerSlot.w,a1
	bsr.s	ObjSpring_SolidObject
	bne.s	.Action

.End:
	rts

; -------------------------------------------------------------------------

.Action:
	move.b	#4,oRoutine(a0)
	addq.w	#8,oY(a1)
	move.w	oVar30(a0),oYVel(a1)
	bset	#1,oStatus(a1)
	bclr	#3,oStatus(a1)
	move.b	#$10,oAnim(a1)
	bclr	#3,oStatus(a0)
	move.w	#$98,d0
	jmp	PlayFMSound
; End of function ObjSpring_Main_Up

; -------------------------------------------------------------------------

ObjSpring_Anim_Up:
	lea	Ani_Spring,a1
	bra.w	AnimateObject
; End of function ObjSpring_Anim_Up

; -------------------------------------------------------------------------

ObjSpring_Reset_Up:
	bclr	#3,oStatus(a0)
	move.b	#1,oPrevAnim(a0)
	subq.b	#4,oRoutine(a0)
	move.b	#0,oMapFrame(a0)
	rts
; End of function ObjSpring_Reset_Up

; -------------------------------------------------------------------------

ObjSpring_SolidObject2:
	move.w	8(a0),d3
	move.w	$C(a0),d4
	jmp	SolidObject
; End of function ObjSpring_SolidObject2

; -------------------------------------------------------------------------

ObjSpring_Main_Side:
	tst.b	1(a0)
	bpl.s	.End
	lea	objPlayerSlot.w,a1
	bsr.s	ObjSpring_SolidObject2
	btst	#5,oStatus(a0)
	bne.s	.Action

.End:
	rts

; -------------------------------------------------------------------------

.Action:
	move.b	#$A,oRoutine(a0)
	move.w	oVar30(a0),oXVel(a1)
	addq.w	#8,oX(a1)
	bset	#0,oStatus(a1)
	btst	#0,oStatus(a0)
	bne.s	.NoFlip
	subi.w	#$10,oX(a1)
	neg.w	oXVel(a1)
	bclr	#0,oStatus(a1)

.NoFlip:
	move.w	#$F,oPlayerMoveLock(a1)
	move.w	oXVel(a1),oPlayerGVel(a1)
	btst	#2,oStatus(a1)
	bne.s	.ClearAngle
	move.b	#0,oAnim(a1)

.ClearAngle:
	clr.b	oAngle(a1)
	bclr	#5,oStatus(a0)
	bclr	#5,oStatus(a1)
	move.w	#$98,d0
	jmp	PlayFMSound
; End of function ObjSpring_Main_Side

; -------------------------------------------------------------------------

ObjSpring_Anim_Side:
	lea	Ani_Spring,a1
	bra.w	AnimateObject
; End of function ObjSpring_Anim_Side

; -------------------------------------------------------------------------

ObjSpring_Reset_Side:
	move.b	#1,oPrevAnim(a0)
	subq.b	#4,oRoutine(a0)
	move.b	#0,oMapFrame(a0)
	rts
; End of function ObjSpring_Reset_Side

; -------------------------------------------------------------------------

ObjSpring_SolidObject3:

; FUNCTION CHUNK AT 00208FF4 SIZE 00000008 BYTES

	move.w	oX(a0),d3
	move.w	oY(a0),d4
	jmp	SolidObject2
; End of function ObjSpring_SolidObject3

; -------------------------------------------------------------------------

ObjSpring_Main_Down:
	tst.b	oRender(a0)
	bpl.s	.End
	lea	objPlayerSlot.w,a1
	bsr.s	ObjSpring_SolidObject3
	bne.s	.Action

.End:
	rts

; -------------------------------------------------------------------------

.Action:
	move.b	#$10,oRoutine(a0)
	subq.w	#8,oY(a1)
	move.w	oVar30(a0),oYVel(a1)
	neg.w	oYVel(a1)
	bset	#1,oStatus(a1)
	bclr	#3,oStatus(a1)
	bclr	#3,oStatus(a0)
	move.w	#$98,d0
	jsr	PlayFMSound
; End of function ObjSpring_Main_Down

; -------------------------------------------------------------------------

ObjSpring_Anim_Down:
	lea	Ani_Spring,a1
	bra.w	AnimateObject
; End of function ObjSpring_Anim_Down

; -------------------------------------------------------------------------

ObjSpring_Reset_Down:
	move.b	#1,oPrevAnim(a0)
	subq.b	#4,oRoutine(a0)
	move.b	#0,oMapFrame(a0)
	rts
; End of function ObjSpring_Reset_Down

; -------------------------------------------------------------------------

ObjSpring_Main_Diag:
	tst.b	oRender(a0)
	bpl.s	.End
	lea	objPlayerSlot.w,a1
	bsr.w	ObjSpring_SolidObject
	bne.s	.Action
	btst	#5,oStatus(a0)
	bne.s	.Action

.End:
	rts

; -------------------------------------------------------------------------

.Action:
	move.b	#$16,oRoutine(a0)
	moveq	#0,d0
	move.b	#$E0,d0
	jsr	CalcSine
	move.w	oVar30(a0),d2
	neg.w	d2
	mulu.w	d2,d0
	mulu.w	d2,d1
	lsr.l	#8,d0
	lsr.l	#8,d1
	move.w	d0,oYVel(a1)
	move.w	d1,oXVel(a1)
	addq.w	#8,oY(a1)
	btst	#1,oRender(a0)
	beq.s	.NoVFlip
	subi.w	#$10,oY(a1)
	neg.w	oYVel(a1)

.NoVFlip:
	bclr	#0,oStatus(a1)
	subq.w	#8,oX(a1)
	btst	#0,oStatus(a0)
	beq.s	.NoHFlip
	addi.w	#$10,oX(a1)
	bset	#0,oStatus(a1)
	neg.w	oXVel(a1)

.NoHFlip:
	bset	#1,oStatus(a1)
	bclr	#3,oStatus(a1)
	bclr	#5,oStatus(a1)
	bclr	#3,oStatus(a0)
	bclr	#5,oStatus(a0)
	move.w	#$98,d0
	jsr	PlayFMSound
; End of function ObjSpring_Main_Diag

; -------------------------------------------------------------------------

ObjSpring_Anim_Diag:
	lea	Ani_Spring,a1
	bra.w	AnimateObject
; End of function ObjSpring_Anim_Diag

; -------------------------------------------------------------------------

ObjSpring_Reset_Diag:
	move.b	#1,oPrevAnim(a0)
	subq.b	#4,oRoutine(a0)
	move.b	#0,oMapFrame(a0)
	rts
; End of function ObjSpring_Reset_Diag

; -------------------------------------------------------------------------
Ani_S1Spring:
	include	"level/r1/unused/anim/s1spring.asm"
	even
MapSpr_S1Spring:
	include	"level/r1/unused/mapspr/s1spring.asm"
	even
Ani_Spring:
	include	"level/r1/objects/spring/anim.asm"
	even
	include	"level/r1/objects/spring/map.asm"
	even
Ani_MovingSpring:
	include	"level/r1/objects/spring/animwheel.asm"
	even
MapSpr_MovingSpring:
	include	"level/r1/objects/spring/mapwheel.asm"
	even
; -------------------------------------------------------------------------

ObjRing:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjRing_Index(pc,d0.w),d1
	jmp	ObjRing_Index(pc,d1.w)
; End of function ObjRing

; -------------------------------------------------------------------------
ObjRing_Index:	dc.w	ObjRing_Init-ObjRing_Index
	dc.w	ObjRing_Main-ObjRing_Index
	dc.w	ObjRing_Collect-ObjRing_Index
	dc.w	ObjRing_Sparkle-ObjRing_Index
	dc.w	ObjRing_Destroy-ObjRing_Index
ObjRing_Deltas:	dc.b	$10, 0
	dc.b	$18, 0
	dc.b	$20, 0
	dc.b	0,	$10
	dc.b	0,	$18
	dc.b	0,	$20
	dc.b	$10, $10
	dc.b	$18, $18
	dc.b	$20, $20
	dc.b	$F0, $10
	dc.b	$E8, $18
	dc.b	$E0, $20
	dc.b	$10, 8
	dc.b	$18, $10
	dc.b	$F0, 8
	dc.b	$E8, $10
; -------------------------------------------------------------------------

ObjRing_Init:
	lea	lvlObjRespawns,a2
	moveq	#0,d0
	move.b	oRespawn(a0),d0
	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,d0
	moveq	#0,d1
	move.b	timeZone,d1
	bclr	#7,d1
	beq.s	.GotTime
	move.b	timeWarpDir.w,d2
	ext.w	d2
	neg.w	d2
	add.w	d2,d1
	bpl.s	.ChkOverflow
	moveq	#0,d1
	bra.s	.GotTime

; -------------------------------------------------------------------------

.ChkOverflow:
	cmpi.w	#3,d1
	bcs.s	.GotTime
	moveq	#2,d1

.GotTime:
	add.w	d1,d0
	lea	2(a2,d0.w),a2
	move.b	(a2),d4
	move.b	oSubtype(a0),d1
	moveq	#0,d0
	move.b	d1,d0
	andi.w	#7,d1
	cmpi.w	#7,d1
	bne.s	.GotSubt
	moveq	#6,d1

.GotSubt:
	swap	d1
	move.w	#1,d1
	lsr.b	#4,d0
	add.w	d0,d0
	lea	ObjRing_Deltas,a1
	move.b	(a1,d0.w),d5
	ext.w	d5
	move.b	1(a1,d0.w),d6
	ext.w	d6
	movea.l	a0,a1
	move.w	oX(a0),d2
	move.w	oY(a0),d3
	lea	1(a2),a3
	moveq	#0,d0
	move.b	timeZone,d0
	bclr	#7,d0
	beq.s	.GotTime2
	move.b	timeWarpDir.w,d2
	ext.w	d2
	neg.w	d2
	add.w	d2,d0
	bpl.s	.ChkOverflow2
	moveq	#0,d0
	bra.s	.GotTime2

; -------------------------------------------------------------------------

.ChkOverflow2:
	cmpi.w	#3,d0
	bcs.s	.GotTime2
	moveq	#2,d0

.GotTime2:
	move.b -(a3),d4
	lsr.b	d1,d4
	bcs.w	.Next
	dbf	d0,.GotTime2
	bclr	#7,(a2)
	bra.s	.InitSubObj

; -------------------------------------------------------------------------

.Loop:
	swap	d1
	lea	1(a2),a3
	moveq	#0,d0
	move.b	timeZone,d0
	bclr	#7,d0
	beq.s	.GotTime3
	move.b	timeWarpDir.w,d2
	ext.w	d2
	neg.w	d2
	add.w	d2,d0
	bpl.s	.ChkOverflow3
	moveq	#0,d0
	bra.s	.GotTime3

; -------------------------------------------------------------------------

.ChkOverflow3:
	cmpi.w	#3,d0
	bcs.s	.GotTime3
	moveq	#2,d0

.GotTime3:
	move.b -(a3),d4
	lsr.b	d1,d4
	bcs.w	.Next
	dbf	d0,.GotTime3
	bclr	#7,(a2)
	bsr.w	FindNextObjSlot
	bne.w	.DidInit

.InitSubObj:
	move.b	#$10,oID(a1)
	move.b	#2,oRoutine(a1)
	move.w	d2,oX(a1)
	move.w	oX(a0),oVar32(a1)
	move.w	d3,oY(a1)
	move.l	#MapSpr_Ring,oMap(a1)
	move.w	#$A7AE,oTile(a1)
	move.b	#2,oPriority(a1)
	cmpi.b	#6,levelZone
	bne.s	.NotMMZ
	move.b	#0,oPriority(a1)
	move.b	oSubtype2(a0),oSubtype2(a1)
	tst.b	oSubtype2(a1)
	beq.s	.NotMMZ
	andi.b	#$7F,oTile(a1)
	move.b	#2,oPriority(a1)

.NotMMZ:
	move.b	#4,oRender(a1)
	move.b	#$47,oColType(a1)
	move.b	#8,oWidth(a1)
	move.b	#8,oYRadius(a1)
	move.b	oRespawn(a0),oRespawn(a1)
	move.b	d1,oVar34(a1)

.Next:
	addq.w	#1,d1
	add.w	d5,d2
	add.w	d6,d3
	swap	d1
	dbf	d1,.Loop

.DidInit:
	moveq	#0,d0
	move.b	timeZone,d0
	bclr	#7,d0
	beq.s	.GotTime4
	move.b	timeWarpDir.w,d2
	ext.w	d2
	neg.w	d2
	add.w	d2,d0
	bpl.s	.ChkOverflow4
	moveq	#0,d0
	bra.s	.GotTime4

; -------------------------------------------------------------------------

.ChkOverflow4:
	cmpi.w	#3,d0
	bcs.s	.GotTime4
	moveq	#2,d0

.GotTime4:
	lea	1(a2),a3

.ChkDel:
	btst	#0,-(a3)
	bne.w	DeleteObject
	dbf	d0,.ChkDel
; End of function ObjRing_Init

; -------------------------------------------------------------------------

ObjRing_Main:

; FUNCTION CHUNK AT 00209F08 SIZE 00000004 BYTES

	tst.b	1(a0)
	bmi.s	.DoAnim
	move.w	oVar32(a0),d0
	andi.w	#$FF80,d0
	move.w	cameraX.w,d1
	subi.w	#$80,d1
	andi.w	#$FF80,d1
	sub.w	d1,d0
	cmpi.w	#$280,d0
	bhi.w	ObjRing_Destroy

.DoAnim:
	tst.w	timeStopTimer
	bne.s	.Display
	move.b	ringAnimFrame,oMapFrame(a0)

.Display:
	bra.w	DrawObject
; End of function ObjRing_Main

; -------------------------------------------------------------------------

ObjRing_Collect:
	addq.b	#2,oRoutine(a0)
	move.b	#0,oColType(a0)
	move.b	#1,oPriority(a0)
	bsr.w	CollectRing
	lea	lvlObjRespawns,a2
	moveq	#0,d0
	move.b	oRespawn(a0),d0
	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,d0
	moveq	#0,d1
	move.b	timeZone,d1
	bclr	#7,d1
	beq.s	.GotTime
	move.b	timeWarpDir.w,d2
	ext.w	d2
	neg.w	d2
	add.w	d2,d1
	bpl.s	.ChkOverflow
	moveq	#0,d1
	bra.s	.GotTime

; -------------------------------------------------------------------------

.ChkOverflow:
	cmpi.w	#3,d1
	bcs.s	.GotTime
	moveq	#2,d1

.GotTime:
	add.w	d1,d0
	move.b	oVar34(a0),d1
	subq.b	#1,d1
	bset	d1,2(a2,d0.w)
; End of function ObjRing_Collect

; -------------------------------------------------------------------------

ObjRing_Sparkle:
	lea	Ani_Ring,a1
	bsr.w	AnimateObject
	bra.w	DrawObject
; End of function ObjRing_Sparkle

; -------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR ObjRing_Main

ObjRing_Destroy:
	bra.w	DeleteObject
; END OF FUNCTION CHUNK	FOR ObjRing_Main
; -------------------------------------------------------------------------

CollectRing:
	addq.w	#1,levelRings
	ori.b	#1,updateRings
	move.w	#$95,d0
	cmpi.w	#100,levelRings
	bcs.s	.PlaySound
	bset	#1,lifeFlags
	beq.s	.GainLife
	cmpi.w	#200,levelRings
	bcs.s	.PlaySound
	bset	#2,lifeFlags
	bne.s	.PlaySound

.GainLife:
	addq.b	#1,lifeCount
	addq.b	#1,updateLives
	move.w	#$7A,d0
	jmp	SubCPUCmd

; -------------------------------------------------------------------------

.PlaySound:
	jmp	PlayFMSound
; End of function CollectRing

; -------------------------------------------------------------------------

ObjLostRing:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjLostRing_Index(pc,d0.w),d1
	jmp	ObjLostRing_Index(pc,d1.w)
; End of function ObjLostRing

; -------------------------------------------------------------------------
ObjLostRing_Index:dc.w	ObjLostRing_Init-ObjLostRing_Index
	dc.w	ObjLostRing_Main-ObjLostRing_Index
	dc.w	ObjLostRing_Collect-ObjLostRing_Index
	dc.w	ObjLostRing_Sparkle-ObjLostRing_Index
	dc.w	ObjLostRing_Destroy-ObjLostRing_Index
; -------------------------------------------------------------------------

ObjLostRing_Init:
	movea.l	a0,a1
	moveq	#0,d5
	move.w	levelRings,d5
	moveq	#$20,d0
	cmp.w	d0,d5
	bcs.s	.NoCap
	move.w	d0,d5

.NoCap:
	subq.w	#1,d5
	move.w	#$288,d4
	bra.s	.DoInit

; -------------------------------------------------------------------------

.Loop:
	bsr.w	FindObjSlot
	bne.w	.DidInit

.DoInit:
	move.b	#$11,oID(a1)
	addq.b	#2,oRoutine(a1)
	move.b	#8,oYRadius(a1)
	move.b	#8,oXRadius(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	move.l	#MapSpr_Ring,oMap(a1)
	move.b	oSubtype2(a0),oSubtype2(a1)
	move.w	#$A7AE,oTile(a1)
	move.b	#3,oPriority(a1)
	cmpi.b	#6,levelZone
	bne.s	.NotMMZ
	move.b	#0,oPriority(a1)
	tst.b	oSubtype2(a0)
	beq.s	.NotMMZ
	move.b	#3,oPriority(a1)
	andi.b	#$7F,oTile(a1)

.NotMMZ:
	move.b	#4,oRender(a1)
	move.b	#$47,oColType(a1)
	move.b	#8,oWidth(a1)
	move.b	#8,oYRadius(a1)
	move.b	#$FF,ringLossAnimTimer
	tst.w	d4
	bmi.s	.SetVel
	move.w	d4,d0
	jsr	CalcSine
	move.w	d4,d2
	lsr.w	#8,d2
	asl.w	d2,d0
	asl.w	d2,d1
	move.w	d0,d2
	move.w	d1,d3
	addi.b	#$10,d4
	bcc.s	.SetVel
	subi.w	#$80,d4
	bcc.s	.SetVel
	move.w	#$288,d4

.SetVel:
	move.w	d2,oXVel(a1)
	move.w	d3,oYVel(a1)
	neg.w	d2
	neg.w	d4
	dbf	d5,.Loop

.DidInit:
	move.w	#0,levelRings
	move.b	#$80,updateRings
	move.b	#0,lifeFlags
	move.w	#$94,d0
	jsr	PlayFMSound
; End of function ObjLostRing_Init

; -------------------------------------------------------------------------

ObjLostRing_Main:

; FUNCTION CHUNK AT 0020A0EE SIZE 00000004 BYTES

	move.b	ringLossAnimFrame,oMapFrame(a0)
	bsr.w	ObjMove
	addi.w	#$18,oYVel(a0)
	bmi.s	.ChkDel
	move.b	lvlFrameCount+3,d0
	add.b	d7,d0
	andi.b	#3,d0
	bne.s	.ChkDel
	jsr	CheckFloorEdge
	tst.w	d1
	bpl.s	.ChkDel
	add.w	d1,oY(a0)
	move.w	oYVel(a0),d0
	asr.w	#2,d0
	sub.w	d0,oYVel(a0)
	neg.w	oYVel(a0)

.ChkDel:
	tst.b	ringLossAnimTimer
	beq.s	ObjLostRing_Destroy
	move.w	bottomBound.w,d0
	addi.w	#$E0,d0
	cmp.w	oY(a0),d0
	bcs.s	ObjLostRing_Destroy
	bra.w	DrawObject
; End of function ObjLostRing_Main

; -------------------------------------------------------------------------

ObjLostRing_Collect:
	addq.b	#2,oRoutine(a0)
	move.b	#0,oColType(a0)
	move.b	#1,oPriority(a0)
	bsr.w	CollectRing
; End of function ObjLostRing_Collect

; -------------------------------------------------------------------------

ObjLostRing_Sparkle:
	lea	Ani_Ring,a1
	bsr.w	AnimateObject
	bra.w	DrawObject
; End of function ObjLostRing_Sparkle

; -------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR ObjLostRing_Main

ObjLostRing_Destroy:
	bra.w	DeleteObject
; END OF FUNCTION CHUNK	FOR ObjLostRing_Main

; -------------------------------------------------------------------------
Ani_Ring:
	include	"level/r1/objects/ring/anim.asm"
	even
MapSpr_Ring:
	include	"level/r1/objects/ring/map.asm"
	even
MapSpr_S1BigRing:
	include	"level/r1/unused/mapspr/s1bigring.asm"
	even
MapSpr_S1BigRingFlash:
	include	"level/r1/unused/mapspr/s1bigringflash.asm"
	even
; -------------------------------------------------------------------------

ObjSmallPlatform:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjSmallPlatform_Index(pc,d0.w),d0
	jsr	ObjSmallPlatform_Index(pc,d0.w)
	move.w	oX(a0),d0
	andi.w	#$FF80,d0
	move.w	cameraX.w,d1
	subi.w	#$80,d1
	andi.w	#$FF80,d1
	sub.w	d1,d0
	cmpi.w	#$280,d0
	bhi.w	DeleteObject
	rts
; End of function ObjSmallPlatform

; -------------------------------------------------------------------------
ObjSmallPlatform_Index:dc.w	ObjSmallPlatform_Init-ObjSmallPlatform_Index
	dc.w	ObjSmallPlatform_Main-ObjSmallPlatform_Index
	dc.w	ObjSmallPlatform_Fall-ObjSmallPlatform_Index
	dc.w	ObjSmallPlatform_Appear-ObjSmallPlatform_Index
	dc.w	ObjSmallPlatform_Visible-ObjSmallPlatform_Index
	dc.w	ObjSmallPlatform_Vanish-ObjSmallPlatform_Index
	dc.w	ObjSmallPlatform_Reset-ObjSmallPlatform_Index
; -------------------------------------------------------------------------

ObjSmallPlatform_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oRender(a0)
	move.l	#MapSpr_SmallPlatform,oMap(a0)
	moveq	#5,d0
	jsr	LevelObj_SetBaseTile
	move.b	#1,oPriority(a0)
	move.b	#$C,oWidth(a0)
	move.b	#$C,oYRadius(a0)
	move.b	#5,oMapFrame(a0)
; End of function ObjSmallPlatform_Init

; -------------------------------------------------------------------------

ObjSmallPlatform_Main:
	bsr.w	ObjSmallPlatform_SolidObj
	tst.b	timeZone
	beq.s	.Display
	cmpi.b	#2,timeZone
	bne.s	.Appear
	btst	#3,oStatus(a0)
	bne.s	.StartFall
	bra.s	.Display

; -------------------------------------------------------------------------

.Appear:
	move.b	#0,oMapFrame(a0)
	btst	#3,oStatus(a0)
	beq.s	.Display
	move.b	#6,oRoutine(a0)
	move.b	#1,oAnim(a0)

.Display:
	jmp	DrawObject

; -------------------------------------------------------------------------

.StartFall:
	addq.b	#2,oRoutine(a0)
; End of function ObjSmallPlatform_Main

; -------------------------------------------------------------------------

ObjSmallPlatform_Fall:
	bsr.w	ObjSmallPlatform_SolidObj
	addq.w	#2,oY(a0)
	move.w	cameraY.w,d0
	addi.w	#$E0,d0
	cmp.w	oY(a0),d0
	bcc.s	.Display
	jmp	DeleteObject

; -------------------------------------------------------------------------

.Display:
	jmp	DrawObject
; End of function ObjSmallPlatform_Fall

; -------------------------------------------------------------------------

ObjSmallPlatform_Appear:
	bsr.w	ObjSmallPlatform_SolidObj
	btst	#3,oStatus(a0)
	bne.s	.Animate
	move.b	#2,oRoutine(a0)
	rts

; -------------------------------------------------------------------------

.Animate:
	lea	Ani_SmallPlatform,a1
	bsr.w	AnimateObject
	jmp	DrawObject
; End of function ObjSmallPlatform_Appear

; -------------------------------------------------------------------------

ObjSmallPlatform_Visible:
	move.b	#0,oAnim(a0)
	bsr.w	ObjSmallPlatform_SolidObj
	btst	#3,oStatus(a0)
	bne.s	.Animate
	addq.b	#2,oRoutine(a0)
	move.b	#2,oAnim(a0)
	rts

; -------------------------------------------------------------------------

.Animate:
	lea	Ani_SmallPlatform,a1
	bsr.w	AnimateObject
	jmp	DrawObject
; End of function ObjSmallPlatform_Visible

; -------------------------------------------------------------------------

ObjSmallPlatform_Vanish:
	bsr.w	ObjSmallPlatform_SolidObj
	lea	Ani_SmallPlatform,a1
	bsr.w	AnimateObject
	jmp	DrawObject
; End of function ObjSmallPlatform_Vanish

; -------------------------------------------------------------------------

ObjSmallPlatform_Reset:
	move.b	#2,oRoutine(a0)
	rts
; End of function ObjSmallPlatform_Reset

; -------------------------------------------------------------------------

ObjSmallPlatform_SolidObj:
	lea	objPlayerSlot.w,a1
	bsr.w	*+4
; End of function ObjSmallPlatform_SolidObj

; -------------------------------------------------------------------------

ObjSmallPlatform_SolidObj2:
	move.w	oX(a0),d3
	move.w	oY(a0),d4
	jmp	SolidObject1
; End of function ObjSmallPlatform_SolidObj2

; -------------------------------------------------------------------------
Ani_SmallPlatform:
	include	"level/r1/objects/smallptfm/anim.asm"
	even
MapSpr_SmallPlatform:
	include	"level/r1/objects/smallptfm/map.asm"
	even
; -------------------------------------------------------------------------

ObjTimeIcon:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjTimeIcon_Index(pc,d0.w),d0
	jsr	ObjTimeIcon_Index(pc,d0.w)
	tst.b	timeWarpDir.w
	beq.s	.End
	cmpi.w	#$5A,timeWarpTimer.w
	bcs.s	.Display
	btst	#0,lvlFrameTimer+1
	bne.s	.End

.Display:
	jmp	DrawObject

; -------------------------------------------------------------------------

.End:
	rts
; End of function ObjTimeIcon

; -------------------------------------------------------------------------
ObjTimeIcon_Index:dc.w	ObjTimeIcon_Init-ObjTimeIcon_Index
	dc.w	ObjTimeIcon_Main-ObjTimeIcon_Index
; -------------------------------------------------------------------------

ObjTimeIcon_Init:
	addq.b	#2,oRoutine(a0)
	move.l	#MapSpr_MonitorTimePost,oMap(a0)
	move.w	#$85A8,oTile(a0)
	move.w	#$C4,oX(a0)
	move.w	#$152,oYScr(a0)
; End of function ObjTimeIcon_Init

; -------------------------------------------------------------------------

ObjTimeIcon_Main:
	move.b	#$12,oMapFrame(a0)
	tst.b	timeWarpDir.w
	bmi.s	.End
	move.b	#$13,oMapFrame(a0)

.End:
	rts
; End of function ObjTimeIcon_Main

; -------------------------------------------------------------------------

ObjTimepost_TimeIcon:
	tst.b	timeAttackMode
	beq.s	.Proceed
	jmp	DeleteObject

; -------------------------------------------------------------------------

.Proceed:
	cmpi.b	#$A,oSubtype(a0)
	beq.w	ObjTimeIcon

ObjTimepost:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjTimepost_Index(pc,d0.w),d0
	jsr	ObjTimepost_Index(pc,d0.w)
	jsr	DrawObject
	jmp	CheckObjDespawnTime
; End of function ObjTimepost_TimeIcon

; -------------------------------------------------------------------------
ObjTimepost_Index:dc.w	ObjTimepost_Init-ObjTimepost_Index
	dc.w	ObjTimepost_Main-ObjTimepost_Index
	dc.w	ObjTimepost_Spin-ObjTimepost_Index
	dc.w	ObjTimepost_Done-ObjTimepost_Index
; -------------------------------------------------------------------------

ObjTimepost_Init:
	addq.b	#2,oRoutine(a0)
	move.b	#$20,oYRadius(a0)
	move.b	#$E,oXRadius(a0)
	move.l	#MapSpr_MonitorTimePost,oMap(a0)
	move.w	#$5A8,oTile(a0)
	move.b	#4,oRender(a0)
	move.b	#3,oPriority(a0)
	cmpi.b	#6,levelZone
	bne.s	.NotFront
	tst.b	oSubtype2(a0)
	bne.s	.NotFront
	move.b	#0,oPriority(a0)
	ori.b	#$80,oTile(a0)

.NotFront:
	move.b	#$F,oWidth(a0)
	move.b	oSubtype(a0),oAnim(a0)
	bsr.w	ObjMonitor_GetRespawn
	bclr	#7,2(a2,d0.w)
	move.b	#$A,oMapFrame(a0)
	cmpi.b	#8,oSubtype(a0)
	beq.s	.ChkActive
	addq.b	#2,oMapFrame(a0)

.ChkActive:
	btst	#0,2(a2,d0.w)
	beq.s	.StillActive
	addq.b	#1,oMapFrame(a0)
	move.b	#6,oRoutine(a0)
	rts

; -------------------------------------------------------------------------

.StillActive:
	move.b	#$DF,oColType(a0)
; End of function ObjTimepost_Init

; -------------------------------------------------------------------------

ObjTimepost_Main:
	tst.b	oColStatus(a0)
	beq.s	.End
	clr.b	oColStatus(a0)
	cmpi.b	#6,levelZone
	bne.s	.ChkTouch
	tst.b	oSubtype2(a0)
	beq.s	.NotBack
	tst.b	lvlDrawLowPlane
	beq.s	.End
	bra.s	.ChkTouch

; -------------------------------------------------------------------------

.NotBack:
	tst.b	lvlDrawLowPlane
	bne.s	.End

.ChkTouch:
	move.b	#$3C,oVar2A(a0)
	addq.b	#2,oRoutine(a0)
	bsr.w	ObjMonitor_GetRespawn
	bset	#0,2(a2,d0.w)
	move.w	#$77,d0
	move.b	#$FF,timeWarpDir.w
	cmpi.b	#8,oSubtype(a0)
	beq.s	.PlaySnd
	move.b	#1,timeWarpDir.w
	subq.w	#1,d0

.PlaySnd:
	jsr	SubCPUCmd

.End:
	rts
; End of function ObjTimepost_Main

; -------------------------------------------------------------------------

ObjTimepost_Spin:
	subq.b	#1,oVar2A(a0)
	beq.s	.StopSpin
	lea	Ani_Monitor,a1
	bra.w	AnimateObject

; -------------------------------------------------------------------------

.StopSpin:
	addq.b	#2,oRoutine(a0)
	move.b	#$B,oMapFrame(a0)
	cmpi.b	#8,oSubtype(a0)
	beq.s	ObjTimepost_Done
	addq.b	#2,oMapFrame(a0)
; End of function ObjTimepost_Spin

; -------------------------------------------------------------------------

ObjTimepost_Done:
	rts
; End of function ObjTimepost_Done

; -------------------------------------------------------------------------

ObjMonitor_GetRespawn:
	lea	lvlObjRespawns,a2
	moveq	#0,d0
	move.b	oRespawn(a0),d0
	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,d0
	moveq	#0,d1
	move.b	timeZone,d1
	bclr	#7,d1
	beq.s	.GotTime
	move.b	timeWarpDir.w,d2
	ext.w	d2
	neg.w	d2
	add.w	d2,d1
	bpl.s	.ChkOverflow
	moveq	#0,d1
	bra.s	.GotTime

; -------------------------------------------------------------------------

.ChkOverflow:
	cmpi.w	#3,d1
	bcs.s	.GotTime
	moveq	#2,d1

.GotTime:
	add.w	d1,d0
	rts
; End of function ObjMonitor_GetRespawn

; -------------------------------------------------------------------------

ObjMonitor_SolidObj:
	cmpi.b	#6,levelZone
	bne.s	.DoSolid
	tst.b	lvlDrawLowPlane
	beq.s	.ChkHighPlane
	tst.b	oSubtype2(a0)
	bne.s	.DoSolid
	rts

; -------------------------------------------------------------------------

.ChkHighPlane:
	tst.b	oSubtype2(a0)
	beq.s	.DoSolid
	rts

; -------------------------------------------------------------------------

.DoSolid:
	move.w	oX(a0),d3
	move.w	oY(a0),d4
	jmp	SolidObject
; End of function ObjMonitor_SolidObj

; -------------------------------------------------------------------------

ObjMonitor_Timepost:
	tst.b	oSubtype(a0)
	bne.s	ObjMonitor
	tst.b	timeAttackMode
	beq.s	ObjMonitor
	jmp	CheckObjDespawnTime

; -------------------------------------------------------------------------

ObjMonitor:
	cmpi.b	#8,oSubtype(a0)
	bcc.w	ObjTimepost_TimeIcon
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjMonitor_Index(pc,d0.w),d1
	jmp	ObjMonitor_Index(pc,d1.w)
; End of function ObjMonitor_Timepost

; -------------------------------------------------------------------------
ObjMonitor_Index:dc.w	ObjMonitor_Init-ObjMonitor_Index
	dc.w	ObjMonitor_Main-ObjMonitor_Index
	dc.w	ObjMonitor_Break-ObjMonitor_Index
	dc.w	ObjMonitor_Animate-ObjMonitor_Index
	dc.w	ObjMonitor_Display-ObjMonitor_Index
; -------------------------------------------------------------------------

ObjMonitor_Init:
	addq.b	#2,oRoutine(a0)
	move.b	#$E,oYRadius(a0)
	move.b	#$E,oXRadius(a0)
	move.l	#MapSpr_MonitorTimePost,oMap(a0)
	move.w	#$5A8,oTile(a0)
	move.b	#3,oPriority(a0)
	cmpi.b	#6,levelZone
	bne.s	.NotMMZ
	tst.b	oSubtype2(a0)
	bne.s	.NotMMZ
	ori.b	#$80,oTile(a0)
	move.b	#0,oPriority(a0)

.NotMMZ:
	move.b	#4,oRender(a0)
	move.b	#$F,oWidth(a0)
	bsr.w	ObjMonitor_GetRespawn
	bclr	#7,2(a2,d0.w)
	btst	#0,2(a2,d0.w)
	beq.s	.NotBroken
	move.b	#8,oRoutine(a0)
	move.b	#$11,oMapFrame(a0)
	rts

; -------------------------------------------------------------------------

.NotBroken:
	move.b	#$46,oColType(a0)
	move.b	oSubtype(a0),oAnim(a0)
; End of function ObjMonitor_Init

; -------------------------------------------------------------------------

ObjMonitor_Main:
	tst.b	oRender(a0)
	bpl.w	ObjMonitor_Display
	move.b	oRoutine2(a0),d0
	beq.s	.CheckSolid
	bsr.w	ObjMoveGrv
	jsr	CheckFloorEdge
	tst.w	d1
	bpl.w	ObjMonitor_Animate
	add.w	d1,oY(a0)
	clr.w	oYVel(a0)
	clr.b	oRoutine2(a0)
	bra.w	ObjMonitor_Animate

; -------------------------------------------------------------------------

.CheckSolid:
	tst.b	oRender(a0)
	bpl.s	ObjMonitor_Animate
	lea	objPlayerSlot.w,a1
	bsr.w	ObjMonitor_SolidObj
; End of function ObjMonitor_Main

; -------------------------------------------------------------------------

ObjMonitor_Animate:
	tst.w	timeStopTimer
	bne.s	ObjMonitor_Display
	lea	Ani_Monitor,a1
	bsr.w	AnimateObject
; End of function ObjMonitor_Animate

; -------------------------------------------------------------------------

ObjMonitor_Display:
	bsr.w	DrawObject
	jmp	CheckObjDespawnTime
; End of function ObjMonitor_Display

; -------------------------------------------------------------------------

ObjMonitor_Break:
	move.w	#$96,d0
	jsr	PlayFMSound
	addq.b	#4,oRoutine(a0)
	move.b	#0,oColType(a0)
	bsr.w	FindObjSlot
	bne.s	.NoContents
	move.b	#$1A,oID(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	move.b	oAnim(a0),oAnim(a1)
	move.b	oSubtype2(a0),oSubtype2(a1)

.NoContents:
	bsr.w	FindObjSlot
	bne.s	.NoExplosion
	move.b	#$18,oID(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	move.b	#1,oRoutine2(a1)
	move.b	#1,oSubtype(a1)
	move.b	oSubtype2(a0),oSubtype2(a1)

.NoExplosion:
	bsr.w	ObjMonitor_GetRespawn
	bset	#0,2(a2,d0.w)
	move.b	#$11,oMapFrame(a0)
	bra.w	DrawObject
; End of function ObjMonitor_Break

; -------------------------------------------------------------------------

ObjMonitorContents:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjMonitorContents_Index(pc,d0.w),d1
	jsr	ObjMonitorContents_Index(pc,d1.w)
	bra.w	DrawObject
; End of function ObjMonitorContents

; -------------------------------------------------------------------------
ObjMonitorContents_Index:dc.w	ObjMonitorContents_Init-ObjMonitorContents_Index
	dc.w	ObjMonitorContents_Main-ObjMonitorContents_Index
	dc.w	ObjMonitorContents_Destroy-ObjMonitorContents_Index
; -------------------------------------------------------------------------

ObjMonitorContents_Init:
	addq.b	#2,oRoutine(a0)
	move.w	#$85A8,oTile(a0)
	tst.b	oSubtype2(a0)
	beq.s	.NotPriority
	andi.b	#$7F,oTile(a0)

.NotPriority:
	move.b	#$24,oRender(a0)
	move.b	#3,oPriority(a0)
	move.b	#8,oWidth(a0)
	move.w	#-$300,oYVel(a0)
	moveq	#0,d0
	move.b	oAnim(a0),d0
	move.b	d0,oMapFrame(a0)
	movea.l	#MapSpr_MonitorTimePost,a1
	add.b	d0,d0
	adda.w	(a1,d0.w),a1
	addq.w	#1,a1
	move.l	a1,oMap(a0)
; End of function ObjMonitorContents_Init

; -------------------------------------------------------------------------

ObjMonitorContents_Main:

; FUNCTION CHUNK AT 0020A8E4 SIZE 00000006 BYTES
; FUNCTION CHUNK AT 0020A946 SIZE 00000076 BYTES

	tst.w	oYVel(a0)
	bpl.w	.GiveBonus
	bsr.w	ObjMove
	addi.w	#$18,oYVel(a0)
	rts

; -------------------------------------------------------------------------

.GiveBonus:
	addq.b	#2,oRoutine(a0)
	move.w	#$1D,oAnimTime(a0)
	move.b	oAnim(a0),d0
	bne.s	.Not1UP

.Gain1UP:
	addq.b	#1,lifeCount
	addq.b	#1,updateLives
	move.w	#$7A,d0
	jmp	SubCPUCmd

; -------------------------------------------------------------------------

.Not1UP:
	cmpi.b	#1,d0
	bne.s	.Not10Rings
	addi.w	#10,levelRings
	ori.b	#1,updateRings
	cmpi.w	#100,levelRings
	bcs.s	.RingSound
	bset	#1,lifeFlags
	beq.w	.Gain1UP
	cmpi.w	#200,levelRings
	bcs.s	.RingSound
	bset	#2,lifeFlags
	beq.w	.Gain1UP

.RingSound:
	move.w	#$95,d0
	jmp	PlayFMSound

; -------------------------------------------------------------------------

.Not10Rings:
	cmpi.b	#2,d0
	bne.s	ObjMonitorContents_NotShield
; End of function ObjMonitorContents_Main

; -------------------------------------------------------------------------

ObjMonitorContents_GainShield:
	move.b	#1,shieldFlag
	move.b	#3,objShieldSlot.w
	move.w	#$97,d0
	jmp	PlayFMSound
; End of function ObjMonitorContents_GainShield

; -------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR ObjMonitorContents_Main

ObjMonitorContents_NotShield:
	cmpi.b	#3,d0
	bne.s	ObjMonitorContents_NotInvinc
; END OF FUNCTION CHUNK	FOR ObjMonitorContents_Main
; -------------------------------------------------------------------------

ObjMonitorContents_GainInvinc:
	move.b	#1,invincibleFlag
	if REGION=USA
		move.w	#$528,objPlayerSlot+oPlayerInvinc.w
	else
		move.w	#$4B0,objPlayerSlot+oPlayerInvinc.w
	endif
	move.b	#3,objInvStar1Slot.w
	move.b	#1,objInvStar1Slot+oAnim.w
	move.b	#3,objInvStar2Slot.w
	move.b	#2,objInvStar2Slot+oAnim.w
	move.b	#3,objInvStar3Slot.w
	move.b	#3,objInvStar3Slot+oAnim.w
	move.b	#3,objInvStar4Slot.w
	move.b	#4,objInvStar4Slot+oAnim.w
	tst.b	timeZone
	bne.s	.NotPast
	move.w	#$82,d0
	jsr	SubCPUCmd

.NotPast:
	move.w	#$6D,d0
	jmp	SubCPUCmd
; End of function ObjMonitorContents_GainInvinc

; -------------------------------------------------------------------------
	rts

; -------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR ObjMonitorContents_Main

ObjMonitorContents_NotInvinc:
	cmpi.b	#4,d0
	bne.s	.NotSpeedShoes

.GainSpeedShoes:
	move.b	#1,speedShoesFlag
	if REGION=USA
		move.w	#$528,objPlayerSlot+oPlayerShoes.w
	else
		move.w	#$4B0,objPlayerSlot+oPlayerShoes.w
	endif
	move.w	#$C00,sonicTopSpeed.w
	move.w	#$18,sonicAcceleration.w
	move.w	#$80,sonicDeceleration.w
	tst.b	timeZone
	bne.s	.NotPast
	move.w	#$82,d0
	jsr	SubCPUCmd

.NotPast:
	move.w	#$6C,d0
	jmp	SubCPUCmd

; -------------------------------------------------------------------------

.NotSpeedShoes:
	cmpi.b	#5,d0
	bne.s	.NotTimeStop
	move.w	#300,timeStopTimer
	rts

; -------------------------------------------------------------------------

.NotTimeStop:
	cmpi.b	#6,d0
	bne.s	.NotBlueRing
	move.w	#$9D,d0
	jsr	PlayFMSound
	move.b	#1,blueRing
	rts

; -------------------------------------------------------------------------

.NotBlueRing:
	bsr.w	ObjMonitorContents_GainShield
	bsr.w	ObjMonitorContents_GainInvinc
	bra.s	.GainSpeedShoes
; END OF FUNCTION CHUNK	FOR ObjMonitorContents_Main
; -------------------------------------------------------------------------

ObjMonitorContents_Destroy:
	subq.w	#1,oAnimTime(a0)
	bmi.w	DeleteObject
	rts
; End of function ObjMonitorContents_Destroy

; -------------------------------------------------------------------------
Ani_Monitor:
	include	"level/r1/objects/monitor/anim.asm"
	even
MapSpr_MonitorTimePost:
	include	"level/r1/objects/monitor/map.asm"
	even
; -------------------------------------------------------------------------

ObjPoints:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjPoints_Index(pc,d0.w),d0
	jsr	ObjPoints_Index(pc,d0.w)
	jmp	DrawObject
; End of function ObjPoints

; -------------------------------------------------------------------------
ObjPoints_Index:dc.w	ObjPoints_Init-ObjPoints_Index
	dc.w	ObjPoints_Main-ObjPoints_Index
; -------------------------------------------------------------------------

ObjPoints_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oRender(a0)
	move.w	#$6C6,oTile(a0)
	move.l	#MapSpr_Points,oMap(a0)
	move.b	oSubtype(a0),oMapFrame(a0)
	andi.b	#$7F,oMapFrame(a0)
	move.b	#$18,oVar2A(a0)
; End of function ObjPoints_Init

; -------------------------------------------------------------------------

ObjPoints_Main:
	subq.b	#1,oVar2A(a0)
	bne.s	.Rise
	jmp	DeleteObject

; -------------------------------------------------------------------------

.Rise:
	subq.w	#2,oY(a0)
	rts
; End of function ObjPoints_Main

; -------------------------------------------------------------------------
MapSpr_Points:
	include	"level/r1/objects/points/map.asm"
	even
; -------------------------------------------------------------------------

ObjHUD_Points:
	tst.b	oSubtype(a0)
	bmi.w	ObjPoints

ObjHUD:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjHUD_Index(pc,d0.w),d0
	jmp	ObjHUD_Index(pc,d0.w)
; End of function ObjHUD_Points

; -------------------------------------------------------------------------
ObjHUD_Index:	dc.w	ObjHUD_Init-ObjHUD_Index
	dc.w	ObjHUD_Main-ObjHUD_Index
; -------------------------------------------------------------------------

ObjHUD_Init:
	addq.b	#2,oRoutine(a0)
	move.l	#MapSpr_HUD,oMap(a0)
	move.w	#$8568,oTile(a0)
	move.w	#$90,oX(a0)
	move.w	#$88,oYScr(a0)
	tst.b	oSubtype2(a0)
	beq.s	.NotRings
	move.b	#3,oMapFrame(a0)
	bra.s	ObjHUD_Main

; -------------------------------------------------------------------------

.NotRings:
	tst.w	debugCheat
	beq.s	.NoDebug
	move.b	#2,oMapFrame(a0)

.NoDebug:
	tst.b	oSubtype(a0)
	beq.s	ObjHUD_Main
	move.w	#$148,oYScr(a0)
	move.b	#1,oMapFrame(a0)
; End of function ObjHUD_Init

; -------------------------------------------------------------------------

ObjHUD_Main:
	tst.b	oSubtype(a0)
	bne.s	.Display
	tst.b	oSubtype2(a0)
	beq.s	.ChkDebug
	tst.w	levelRings
	beq.s	.ChkFlashRings
	bclr	#5,oTile(a0)
	bra.s	.Display

; -------------------------------------------------------------------------

.ChkFlashRings:
	move.b	lvlFrameCount+3,d0
	andi.b	#$F,d0
	bne.s	.Display
	eori.b	#$20,oTile(a0)
	bra.s	.Display

; -------------------------------------------------------------------------

.ChkDebug:
	move.b	#0,oMapFrame(a0)
	tst.w	debugCheat
	beq.s	.Display
	move.b	#2,oMapFrame(a0)

.Display:
	jmp	DrawObject
; End of function ObjHUD_Main

; -------------------------------------------------------------------------
MapSpr_HUD:
	include	"level/r1/objects/hud/map.asm"
	even
; -------------------------------------------------------------------------

AddPoints:
	move.b	#1,updateScore
	lea	levelScore,a3
	add.l	d0,(a3)
	move.l	#999999,d1
	cmp.l	(a3),d1
	bhi.s	.CappedScore
	move.l	d1,(a3)

.CappedScore:
	move.l	(a3),d0
	cmp.l	nextLifeScore,d0
	bcs.s	.End
	addi.l	#5000,nextLifeScore
	addq.b	#1,lifeCount
	addq.b	#1,updateLives
	move.w	#$7A,d0
	jmp	SubCPUCmd

; -------------------------------------------------------------------------

.End:
	rts
; End of function AddPoints

; -------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR VInt_Pause

UpdateHUD:
	tst.w	debugCheat
	beq.s	.NormalHUD
	bsr.w	HudDb_XY
	move.l	#$73600002,d0
	moveq	#0,d1
	move.b	lvlObjRespawns,d1
	move.w	objPlayerSlot+oY.w,d2
	lsr.w	#1,d2
	andi.w	#$380,d2
	move.b	objPlayerSlot+oX.w,d1
	andi.w	#$7F,d1
	add.w	d1,d2
	lea	levelLayout.w,a1
	moveq	#0,d1
	move.b	(a1,d2.w),d1
	andi.w	#$7F,d1
	move.w	lvlDebugBlock,d1
	andi.w	#$7FF,d1
	lea	Hud_100,a2
	moveq	#2,d6
	bsr.w	Hud_Digits
	bra.w	.ChkTime

; -------------------------------------------------------------------------

.NormalHUD:
	tst.b	updateScore
	beq.s	.ChkRings
	bpl.s	.UpdateScore
	bsr.w	Hud_Base

.UpdateScore:
	clr.b	updateScore
	move.l	#$70600002,d0
	move.l	levelScore,d1
	bsr.w	Hud_Score

.ChkRings:
	tst.b	updateRings
	beq.s	.ChkTime
	bpl.s	.UpdateRings
	bsr.w	Hud_InitRings

.UpdateRings:
	clr.b	updateRings
	move.l	#$73600002,d0
	moveq	#0,d1
	move.w	levelRings,d1
	cmpi.w	#1000,d1
	bcs.s	.CappedRings
	move.w	#999,d1
	move.w	d1,levelRings

.CappedRings:
	bsr.w	Hud_Rings

.ChkTime:
	tst.w	debugCheat
	bne.w	.ChkLives
	tst.b	updateTime
	beq.w	.ChkLives
	tst.w	paused.w
	bne.w	.ChkLives
	lea	levelTime,a1
	cmpi.l	#$93B3B,(a1)+
	beq.w	SetTimeOver
	tst.b	ctrlLocked.w
	bne.s	.UpdateTimer
	addq.b	#1,-(a1)
	cmpi.b	#60,(a1)
	bcs.s	.UpdateTimer
	move.b	#0,(a1)
	addq.b	#1,-(a1)
	cmpi.b	#60,(a1)
	bcs.s	.UpdateTimer
	move.b	#0,(a1)
	addq.b	#1,-(a1)
	cmpi.b	#9,(a1)
	bcs.s	.UpdateTimer
	move.b	#9,(a1)

.UpdateTimer:
	move.l	#$72200002,d0
	moveq	#0,d1
	move.b	levelTime+1,d1
	bsr.w	Hud_Mins
	move.l	#$72600002,d0
	moveq	#0,d1
	move.b	levelTime+2,d1
	bsr.w	Hud_SecsCentisecs
	move.l	#$72E00002,d0
	moveq	#0,d1
	move.b	levelTime+3,d1
	mulu.w	#100,d1
	divu.w	#60,d1
	swap	d1
	move.w	#0,d1
	swap	d1
	cmpi.l	#$93B3B,levelTime
	bne.s	.UpdateCentisecs
	move.w	#99,d1

.UpdateCentisecs:
	bsr.w	Hud_SecsCentisecs

.ChkLives:
	tst.b	updateLives
	beq.s	.ChkBonus
	clr.b	updateLives
	bsr.w	Hud_Lives

.ChkBonus:
	tst.b	updateResultsBonus.w
	beq.s	.End
	clr.b	updateResultsBonus.w
	move.l	#$47800002,d0
	cmpi.w	#$502,levelZone
	bne.s	.GotVRAMLoc
	move.l	#$6D400001,d0

.GotVRAMLoc:
	moveq	#0,d1
	move.w	bonusCount1.w,d1
	bsr.w	Hud_Bonus
	move.l	#$48C00002,d0
	cmpi.w	#$502,levelZone
	bne.s	.NotSSZ3
	move.l	#$6E800001,d0

.NotSSZ3:
	moveq	#0,d1
	move.w	bonusCount2.w,d1
	bsr.w	Hud_Bonus

.End:
	rts

; -------------------------------------------------------------------------

SetTimeOver:
	btst	#7,timeZone
	bne.s	.End2
	clr.b	updateTime
	move.l	#0,levelTime
	lea	objPlayerSlot.w,a0
	movea.l	a0,a2
	bsr.w	KillPlayer
	move.b	#1,lvlTimeOver

.End2:
	rts
; END OF FUNCTION CHUNK	FOR VInt_Pause
; -------------------------------------------------------------------------

Hud_InitRings:
	move.l	#$73600002,VDPCTRL
	lea	Hud_TilesRings(pc),a2
	move.w	#2,d2
	bra.s	Hud_InitCommon
; End of function Hud_InitRings

; -------------------------------------------------------------------------

Hud_Base:
	lea	VDPDATA,a6
	bsr.w	Hud_Lives
	move.l	#$70600002,VDPCTRL
	lea	Hud_TilesBase(pc),a2
	move.w	#6,d2

Hud_InitCommon:
	lea	ArtUnc_HUD,a1

.OuterLoop:
	move.w	#$F,d1
	move.b	(a2)+,d0
	bmi.s	.EmptyTile
	ext.w	d0
	lsl.w	#5,d0
	lea	(a1,d0.w),a3

.InnerLoop:
	move.l	(a3)+,(a6)
	dbf	d1,.InnerLoop

.Next:
	dbf	d2,.OuterLoop
	rts

; -------------------------------------------------------------------------

.EmptyTile:
	move.l	#0,(a6)
	dbf	d1,.EmptyTile
	bra.s	.Next
; End of function Hud_Base

; -------------------------------------------------------------------------
Hud_TilesBase:	dc.b	$FF, $FF, $FF, $FF, $FF, $FF, 0, 0
Hud_TilesRings:	dc.b	$FF, $FF, 0, 0
; -------------------------------------------------------------------------

HudDb_XY:
	move.l	#$70E00002,d0
	moveq	#0,d1
	move.w	objPlayerSlot+oX.w,d1
	bsr.w	Hud_Hex
	move.l	#$72600002,d0
	move.w	objPlayerSlot+oY.w,d1
	bra.w	Hud_Hex
; End of function HudDb_XY

; -------------------------------------------------------------------------

Hud_Bonus:
	lea	Hud_10000,a2
	moveq	#4,d6
	moveq	#0,d4
	lea	ArtUnc_HUD,a1

.DigitLoop:
	moveq	#0,d2
	move.l	(a2)+,d3

.Loop:
	sub.l	d3,d1
	bcs.s	.GotDigit
	addq.w	#1,d2
	bra.s	.Loop

; -------------------------------------------------------------------------

.GotDigit:
	add.l	d3,d1
	tst.w	d2
	beq.s	.NonzeroDigit
	move.w	#1,d4

.NonzeroDigit:
	move.l	d0,4(a6)
	tst.w	d4
	bne.s	.DrawDigit
	tst.w	d6
	bne.s	.BlankTile

.DrawDigit:
	lsl.w	#6,d2
	lea	(a1,d2.w),a3
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)

.Next:
	addi.l	#$400000,d0
	dbf	d6,.DigitLoop
	rts

; -------------------------------------------------------------------------

.BlankTile:
	moveq	#$F,d5

.Loop2:
	move.l	#0,(a6)
	dbf	d5,.Loop2
	bra.s	.Next
; End of function Hud_Bonus

; -------------------------------------------------------------------------

Hud_Rings:
	lea	Hud_100,a2
	moveq	#2,d6
	bra.s	Hud_LoadArt
; End of function Hud_Rings

; -------------------------------------------------------------------------

Hud_Score:
	lea	Hud_100000,a2
	moveq	#5,d6

Hud_LoadArt:
	moveq	#0,d4
	lea	ArtUnc_HUD,a1

.DigitLoop:
	moveq	#0,d2
	move.l	(a2)+,d3

.Loop:
	sub.l	d3,d1
	bcs.s	.GotDigit
	addq.w	#1,d2
	bra.s	.Loop

; -------------------------------------------------------------------------

.GotDigit:
	add.l	d3,d1
	tst.w	d2
	beq.s	.ChkDraw
	move.w	#1,d4

.ChkDraw:
	tst.w	d4
	beq.s	.SkipDigit
	lsl.w	#6,d2
	move.l	d0,4(a6)
	lea	(a1,d2.w),a3
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)

.SkipDigit:
	addi.l	#$400000,d0
	dbf	d6,.DigitLoop
	rts
; End of function Hud_Score

; -------------------------------------------------------------------------

ContScrCounter:
	move.l	#$5F800003,VDPCTRL
	lea	VDPDATA,a6
	lea	Hud_10,a2
	moveq	#1,d6
	moveq	#0,d4
	lea	ArtUnc_HUD,a1

.DigitLoop:
	moveq	#0,d2
	move.l	(a2)+,d3

.Loop:
	sub.l	d3,d1
	bcs.s	.GotDigit
	addq.w	#1,d2
	bra.s	.Loop

; -------------------------------------------------------------------------

.GotDigit:
	add.l	d3,d1
	lsl.w	#6,d2
	lea	(a1,d2.w),a3
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	dbf	d6,.DigitLoop
	rts
; End of function ContScrCounter

; -------------------------------------------------------------------------
Hud_100000:	dc.l	100000
Hud_10000:	dc.l	10000
Hud_1000:	dc.l	1000
Hud_100:	dc.l	100
Hud_10:		dc.l	10
Hud_1:		dc.l	1
Hud_1000h:	dc.l	$1000
Hud_100h:	dc.l	$100
Hud_10h:	dc.l	$10
Hud_1h:		dc.l	1
; -------------------------------------------------------------------------

Hud_Hex:
	moveq	#3,d6
	lea	Hud_1000h,a2
	bra.s	Hud_Digits
; End of function Hud_Hex

; -------------------------------------------------------------------------

Hud_Lives:
	move.l	#$74A00002,d0
	moveq	#0,d1
	move.b	lifeCount,d1
	cmpi.b	#9,d1
	bcs.s	.Max9Lives
	moveq	#9,d1

.Max9Lives:
	lea	Hud_1,a2
	moveq	#0,d6
	bra.s	Hud_Digits
; End of function Hud_Lives

; -------------------------------------------------------------------------

Hud_Mins:
	lea	Hud_1,a2
	moveq	#0,d6
	bra.s	Hud_Digits
; End of function Hud_Mins

; -------------------------------------------------------------------------

Hud_SecsCentisecs:
	lea	Hud_10,a2
	moveq	#1,d6
; End of function Hud_SecsCentisecs

; -------------------------------------------------------------------------

Hud_Digits:
	moveq	#0,d4
	lea	ArtUnc_HUD,a1

.DigitLoop:
	moveq	#0,d2
	move.l	(a2)+,d3

.Loop:
	sub.l	d3,d1
	bcs.s	.GotDigit
	addq.w	#1,d2
	bra.s	.Loop

; -------------------------------------------------------------------------

.GotDigit:
	add.l	d3,d1
	tst.w	d2
	beq.s	.DrawDigit
	move.w	#1,d4

.DrawDigit:
	lsl.w	#6,d2
	move.l	d0,4(a6)
	lea	(a1,d2.w),a3
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	move.l	(a3)+,(a6)
	addi.l	#$400000,d0
	dbf	d6,.DigitLoop
	rts
; End of function Hud_Digits

; -------------------------------------------------------------------------

ObjAnton:

; FUNCTION CHUNK AT 00207882 SIZE 00000078 BYTES

	jsr	DestroyOnGoodFuture
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjAnton_Index(pc,d0.w),d0
	jsr	ObjAnton_Index(pc,d0.w)
	jsr	DrawObject
	move.w	oVar2E(a0),d0
	jmp	CheckObjDespawn2Time
; End of function ObjAnton

; -------------------------------------------------------------------------
ObjAnton_Index:	dc.w	ObjAnton_Init-ObjAnton_Index
	dc.w	ObjAnton_Place-ObjAnton_Index
	dc.w	ObjAnton_Main-ObjAnton_Index
; -------------------------------------------------------------------------

ObjAnton_Init:
	ori.b	#4,oRender(a0)
	move.b	#4,oPriority(a0)
	move.l	#MapSpr_Anton,oMap(a0)
	move.b	#$18,oXRadius(a0)
	move.b	#$18,oWidth(a0)
	move.b	#$13,oYRadius(a0)
	move.b	#$29,oColType(a0)
	move.w	oX(a0),oVar2E(a0)
	moveq	#2,d0
	jsr	LevelObj_SetBaseTile
	tst.b	oSubtype(a0)
	bne.s	.Damaged
	move.l	#-$10000,d0
	moveq	#0,d1
	bra.s	.SetInfo

; -------------------------------------------------------------------------

.Damaged:
	move.l	#-$8000,d0
	moveq	#1,d1

.SetInfo:
	move.l	d0,oVar2A(a0)
	move.b	d1,oAnim(a0)
; End of function ObjAnton_Init

; -------------------------------------------------------------------------

ObjAnton_Place:
	move.l	#$10000,d0
	add.l	d0,oY(a0)
	jsr	CheckFloorEdge
	tst.w	d1
	bpl.s	.End
	addq.b	#2,oRoutine(a0)

.End:
	rts
; End of function ObjAnton_Place

; -------------------------------------------------------------------------

ObjAnton_Main:
	move.l	oVar2A(a0),d0
	add.l	d0,oX(a0)
	move.w	oX(a0),d0
	sub.w	oVar2E(a0),d0
	bpl.s	.AbsDX
	neg.w	d0

.AbsDX:
	cmpi.w	#$80,d0
	bge.s	.TurnAround
	jsr	CheckFloorEdge
	cmpi.w	#-7,d1
	blt.s	.TurnAround
	cmpi.w	#7,d1
	bgt.s	.TurnAround
	add.w	d1,oY(a0)
	lea	Ani_Anton(pc),a1
	jmp	AnimateObject

; -------------------------------------------------------------------------

.TurnAround:
	neg.l	oVar2A(a0)
	bchg	#0,oRender(a0)
	bchg	#0,oStatus(a0)
	bra.s	ObjAnton_Main
; End of function ObjAnton_Main

; -------------------------------------------------------------------------
Ani_Anton:
	include	"level/r1/objects/anton/anim.asm"
	even
MapSpr_Anton:
	include	"level/r1/objects/anton/map.asm"
	even
; -------------------------------------------------------------------------

ObjPataBata:
	jsr	DestroyOnGoodFuture
	tst.b	oRoutine(a0)
	bne.w	ObjPataBata_Main
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oRender(a0)
	move.b	#3,oPriority(a0)
	move.b	#$2A,oColType(a0)
	move.b	#$10,oXRadius(a0)
	move.b	#$10,oWidth(a0)
	move.b	#$10,oYRadius(a0)
	move.w	oX(a0),oVar2A(a0)
	move.w	oY(a0),oVar2C(a0)
	move.w	#$8000,oVar2E(a0)
	moveq	#1,d0
	jsr	LevelObj_SetBaseTile
	tst.b	oSubtype(a0)
	bne.s	.Damaged
	move.l	#-$8000,d0
	move.w	#-$200,d1
	moveq	#3,d2
	moveq	#0,d3
	lea	MapSpr_PataBata1(pc),a1
	bra.s	.SetInfo

; -------------------------------------------------------------------------

.Damaged:
	move.l	#-$4000,d0
	move.w	#-$100,d1
	moveq	#4,d2
	moveq	#1,d3
	lea	MapSpr_PataBata2(pc),a1

.SetInfo:
	move.l	d0,oVar30(a0)
	move.w	d1,oVar36(a0)
	move.w	d2,oVar38(a0)
	move.b	d3,oAnim(a0)
	move.l	a1,oMap(a0)

ObjPataBata_Main:
	move.l	oVar30(a0),d0
	add.l	d0,8(a0)
	move.w	oX(a0),d0
	sub.w	oVar2A(a0),d0
	bpl.s	.AbsDX
	neg.w	d0

.AbsDX:
	cmpi.w	#$80,d0
	blt.s	.NoFlip
	neg.l	oVar30(a0)
	move.l	oVar30(a0),d0
	add.l	d0,oX(a0)
	bchg	#0,oRender(a0)
	bchg	#0,oStatus(a0)
	clr.w	oVar34(a0)

.NoFlip:
	move.w	oVar36(a0),d0
	add.w	d0,oVar34(a0)
	move.b	oVar34(a0),d0
	jsr	CalcSine
	swap	d0
	move.w	oVar38(a0),d1
	asr.l	d1,d0
	add.l	oVar2C(a0),d0
	move.l	d0,oY(a0)
	lea	Ani_PataBata(pc),a1
	jsr	AnimateObject
	jsr	DrawObject
	move.w	oVar2A(a0),d0
	jmp	CheckObjDespawn2Time
; End of function ObjPataBata

; -------------------------------------------------------------------------
Ani_PataBata:
	include	"level/r1/objects/patabata/anim.asm"
	even
MapSpr_PataBata1:
	include	"level/r1/objects/patabata/mapnormal.asm"
	even
MapSpr_PataBata2:
	include	"level/r1/objects/patabata/mapdamaged.asm"
	even
; -------------------------------------------------------------------------

ObjMosqui:
	jsr	DestroyOnGoodFuture
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjMosqui_Index(pc,d0.w),d0
	jsr	ObjMosqui_Index(pc,d0.w)
	jsr	DrawObject
	move.w	oVar2A(a0),d0
	jmp	CheckObjDespawn2Time
; End of function ObjMosqui

; -------------------------------------------------------------------------
ObjMosqui_Index:dc.w	ObjMosqui_Init-ObjMosqui_Index
	dc.w	ObjMosqui_Main-ObjMosqui_Index
	dc.w	ObjMosqui_Animate-ObjMosqui_Index
	dc.w	ObjMosqui_Dive-ObjMosqui_Index
	dc.w	ObjMosqui_Wait-ObjMosqui_Index
; -------------------------------------------------------------------------

ObjMosqui_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oRender(a0)
	move.b	#3,oPriority(a0)
	move.b	#$10,oXRadius(a0)
	move.b	#$10,oWidth(a0)
	move.b	#$10,oYRadius(a0)
	move.b	#$2B,oColType(a0)
	move.w	oX(a0),oVar2A(a0)
	moveq	#0,d0
	jsr	LevelObj_SetBaseTile
	tst.b	oSubtype(a0)
	bne.s	.Damaged
	lea	MapSpr_Mosqui1(pc),a1
	lea	Ani_Mosqui1(pc),a2
	move.l	#-$10000,d0
	bra.s	.SetInfo

; -------------------------------------------------------------------------

.Damaged:
	lea	MapSpr_Mosqui2(pc),a1
	lea	Ani_Mosqui2(pc),a2
	move.l	#-$8000,d0

.SetInfo:
	move.l	a1,oMap(a0)
	move.l	a2,oVar30(a0)
	move.l	d0,oVar2C(a0)
; End of function ObjMosqui_Init

; -------------------------------------------------------------------------

ObjMosqui_Main:
	tst.w	lvlDebugMode
	bne.s	.SkipRange
	lea	objPlayerSlot.w,a1
	bsr.s	ObjMosqui_CheckInRange
	bcs.s	.StartDive

.SkipRange:
	move.l	oVar2C(a0),d0
	add.l	d0,oX(a0)
	move.w	oX(a0),d0
	sub.w	oVar2A(a0),d0
	bpl.s	.ChkTurn
	neg.w	d0

.ChkTurn:
	cmpi.w	#$80,d0
	blt.s	.Animate
	neg.l	oVar2C(a0)
	bchg	#0,oRender(a0)
	bchg	#0,oStatus(a0)
	bra.s	.SkipRange

; -------------------------------------------------------------------------

.Animate:
	movea.l	oVar30(a0),a1
	jmp	AnimateObject

; -------------------------------------------------------------------------

.StartDive:
	addq.b	#2,oRoutine(a0)
	move.b	#1,oAnim(a0)
	rts
; End of function ObjMosqui_Main

; -------------------------------------------------------------------------

ObjMosqui_CheckInRange:
	move.w	oY(a1),d0
	sub.w	oY(a0),d0
	subi.w	#-$30,d0
	subi.w	#$70,d0
	bcc.s	.End
	move.w	oX(a1),d0
	sub.w	oX(a0),d0
	move.w	d0,d1
	subi.w	#-$30,d1
	subi.w	#$60,d1

.End:
	rts
; End of function ObjMosqui_CheckInRange

; -------------------------------------------------------------------------

ObjMosqui_Animate:
	movea.l	oVar30(a0),a1
	jmp	AnimateObject
; End of function ObjMosqui_Animate

; -------------------------------------------------------------------------

ObjMosqui_Dive:
	addq.w	#6,oY(a0)
	jsr	CheckFloorEdge
	cmpi.w	#-8,d1
	bgt.s	.End
	subi.w	#-8,d1
	add.w	d1,oY(a0)
	addq.b	#2,oRoutine(a0)
	tst.b	oRender(a0)
	bpl.s	.End
	move.w	#$A7,d0
	jsr	PlayFMSound

.End:
	rts
; End of function ObjMosqui_Dive

; -------------------------------------------------------------------------

ObjMosqui_Wait:
	tst.b	oRender(a0)
	bmi.s	.End
	jmp	CheckObjDespawnTime_Despawn

; -------------------------------------------------------------------------

.End:
	rts
; End of function ObjMosqui_Wait

; -------------------------------------------------------------------------
Ani_Mosqui1:
	include	"level/r1/objects/mosqui/animnormal.asm"
	even
Ani_Mosqui2:
	include	"level/r1/objects/mosqui/animdamaged.asm"
	even
MapSpr_Mosqui1:
	include	"level/r1/objects/mosqui/mapnormal.asm"
	even
MapSpr_Mosqui2:
	include	"level/r1/objects/mosqui/mapdamaged.asm"
	even
; -------------------------------------------------------------------------

ObjTamabboh:
	cmpi.b	#1,oSubtype(a0)
	beq.w	ObjTamabbohMissile
	jsr	DestroyOnGoodFuture
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjTamabboh_Index(pc,d0.w),d0
	jsr	ObjTamabboh_Index(pc,d0.w)
	jsr	DrawObject
	move.w	oVar2A(a0),d0
	jmp	CheckObjDespawn2Time
; End of function ObjTamabboh

; -------------------------------------------------------------------------
ObjTamabboh_Index:dc.w	ObjTamabboh_Init-ObjTamabboh_Index
	dc.w	ObjTamabboh_Position-ObjTamabboh_Index
	dc.w	ObjTamabboh_Main-ObjTamabboh_Index
	dc.w	ObjTamabboh_Wait1-ObjTamabboh_Index
	dc.w	ObjTamabboh_Wait2-ObjTamabboh_Index
	dc.w	ObjTamabboh_Fire-ObjTamabboh_Index
; -------------------------------------------------------------------------

ObjTamabboh_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oRender(a0)
	move.b	#4,oPriority(a0)
	move.b	#$2C,oColType(a0)
	move.b	#$10,oXRadius(a0)
	move.b	#$10,oWidth(a0)
	move.b	#$F,oYRadius(a0)
	move.w	oX(a0),oVar2A(a0)
	moveq	#4,d0
	jsr	LevelObj_SetBaseTile
	tst.b	oSubtype(a0)
	bne.s	.AltMaps
	lea	MapSpr_Tamabboh1(pc),a1
	lea	Ani_Tamabboh1(pc),a2
	move.l	#-$A000,d0
	bra.s	.SetMaps

; -------------------------------------------------------------------------

.AltMaps:
	lea	MapSpr_Tamabboh2(pc),a1
	lea	Ani_Tamabboh2(pc),a2
	move.l	#-$5000,d0

.SetMaps:
	move.l	a1,4(a0)
	move.l	a2,oVar30(a0)
	move.l	d0,oVar2C(a0)
; End of function ObjTamabboh_Init

; -------------------------------------------------------------------------

ObjTamabboh_Position:
	move.l	#$10000,d0
	add.l	d0,oY(a0)
	jsr	CheckFloorEdge
	tst.w	d1
	bpl.s	.End
	addq.b	#2,oRoutine(a0)

.End:
	rts
; End of function ObjTamabboh_Position

; -------------------------------------------------------------------------

ObjTamabboh_Main:
	tst.w	lvlDebugMode
	bne.s	.SkipRange
	tst.b	$28(a0)
	bne.s	.SkipRange
	tst.w	$34(a0)
	beq.s	.DoRange
	subq.w	#1,$34(a0)
	bra.s	.SkipRange

; -------------------------------------------------------------------------

.DoRange:
	lea	objPlayerSlot.w,a1
	bsr.s	ObjTamabboh_CheckInRange
	bcs.s	.NextState

.SkipRange:
	move.l	oVar2C(a0),d0
	add.l	d0,oX(a0)
	move.w	oX(a0),d0
	sub.w	oVar2A(a0),d0
	bpl.s	.ChlTirm
	neg.w	d0

.ChlTirm:
	cmpi.w	#$80,d0
	bge.s	.TurnAround
	jsr	CheckFloorEdge
	cmpi.w	#-7,d1
	blt.s	.TurnAround
	cmpi.w	#7,d1
	bgt.s	.TurnAround
	add.w	d1,oY(a0)
	movea.l	oVar30(a0),a1
	jmp	AnimateObject

; -------------------------------------------------------------------------

.TurnAround:
	neg.l	oVar2C(a0)
	bchg	#0,oRender(a0)
	bchg	#0,oStatus(a0)
	bra.s	ObjTamabboh_Main

; -------------------------------------------------------------------------

.NextState:
	addq.b	#2,oRoutine(a0)
	rts
; End of function ObjTamabboh_Main

; -------------------------------------------------------------------------

ObjTamabboh_CheckInRange:
	move.w	oY(a1),d0
	sub.w	oY(a0),d0
	subi.w	#-$50,d0
	subi.w	#$A0,d0
	bcc.s	.End
	move.w	oX(a1),d0
	sub.w	oX(a0),d0
	move.w	d0,d1
	subi.w	#-$50,d1
	subi.w	#$A0,d1

.End:
	rts
; End of function ObjTamabboh_CheckInRange

; -------------------------------------------------------------------------

ObjTamabboh_Wait1:
	addq.b	#2,oRoutine(a0)
	move.b	#1,oAnim(a0)
; End of function ObjTamabboh_Wait1

; -------------------------------------------------------------------------

ObjTamabboh_Wait2:
	movea.l	oVar30(a0),a1
	jmp	AnimateObject
; End of function ObjTamabboh_Wait2

; -------------------------------------------------------------------------

ObjTamabboh_Fire:
	move.b	#4,oRoutine(a0)
	move.b	#0,oAnim(a0)
	move.w	#$78,oVar34(a0)
	tst.b	oSubtype(a0)
	bne.s	.End
	jsr	FindObjSlot
	bne.s	.End
	tst.b	oRender(a0)
	bpl.s	.SkipSound
	move.w	#$A0,d0
	jsr	PlayFMSound

.SkipSound:
	bsr.s	ObjTamabboh_InitMissile
	sf	oVar3F(a1)
	jsr	FindObjSlot
	bne.s	.End
	bsr.s	ObjTamabboh_InitMissile
	st	oVar3F(a1)

.End:
	rts
; End of function ObjTamabboh_Fire

; -------------------------------------------------------------------------

ObjTamabboh_InitMissile:
	move.b	oID(a0),oID(a1)
	move.b	#1,oSubtype(a1)
	move.w	oTile(a0),oTile(a1)
	move.b	oPriority(a0),oPriority(a1)
	addq.b	#1,oPriority(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	subi.w	#10,oY(a1)
	rts
; End of function ObjTamabboh_InitMissile

; -------------------------------------------------------------------------
Ani_Tamabboh1:
	include	"level/r1/objects/tamabboh/animnormal.asm"
	even
Ani_Tamabboh2:
	include	"level/r1/objects/tamabboh/animdamaged.asm"
	even
	include	"level/r1/objects/tamabboh/map.asm"
	even

; -------------------------------------------------------------------------

ObjTamabbohMissile:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjTamabbohMissile_Index(pc,d0.w),d0
	jsr	ObjTamabbohMissile_Index(pc,d0.w)
	jmp	DrawObject
; End of function ObjTamabbohMissile

; -------------------------------------------------------------------------
ObjTamabbohMissile_Index:dc.w	ObjTamabbohMissile_Init-ObjTamabbohMissile_Index
	dc.w	ObjTamabbohMissile_Main-ObjTamabbohMissile_Index
; -------------------------------------------------------------------------

ObjTamabbohMissile_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oRender(a0)
	move.b	#$AD,oColType(a0)
	move.b	#8,oXRadius(a0)
	move.b	#8,oWidth(a0)
	move.b	#8,oYRadius(a0)
	move.l	#MapSpr_TamabbohMissile,oMap(a0)
	move.l	#0,oVar32(a0)
	move.l	#$2000,oVar36(a0)
	tst.b	oVar3F(a0)
	bne.s	.FlipX
	move.l	#$20000,d0
	move.l	#-$40000,d1
	bra.s	.SetSpeeds

; -------------------------------------------------------------------------

.FlipX:
	move.l	#-$20000,d0
	move.l	#-$40000,d1

.SetSpeeds:
	move.l	d0,oVar2A(a0)
	move.l	d1,oVar2E(a0)
	rts
; End of function ObjTamabbohMissile_Init

; -------------------------------------------------------------------------

ObjTamabbohMissile_Main:
	tst.b	oRender(a0)
	bmi.s	.Action
	jmp	DeleteObject

; -------------------------------------------------------------------------

.Action:
	jsr	CheckFloorEdge
	tst.w	d1
	bpl.s	.MoveAnim
	jmp	DeleteObject

; -------------------------------------------------------------------------

.MoveAnim:
	move.l	oVar2A(a0),d0
	add.l	d0,oX(a0)
	move.l	oVar2E(a0),d0
	add.l	d0,oY(a0)
	move.l	oVar32(a0),d0
	add.l	d0,oVar2A(a0)
	move.l	oVar36(a0),d0
	add.l	d0,oVar2E(a0)
	lea	Ani_TamabbohMissile(pc),a1
	jmp	AnimateObject
; End of function ObjTamabbohMissile_Main

; -------------------------------------------------------------------------
Ani_TamabbohMissile:
	include	"level/r1/objects/tamabboh/animmissile.asm"
	even
MapSpr_TamabbohMissile:
	include	"level/r1/objects/tamabboh/mapmissile.asm"
	even
; -------------------------------------------------------------------------

ObjTagaTaga:
	jsr	DestroyOnGoodFuture
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjTagaTaga_Index(pc,d0.w),d0
	jsr	ObjTagaTaga_Index(pc,d0.w)
	jsr	DrawObject
	move.w	oVar2A(a0),d0
	jmp	CheckObjDespawn2Time
; End of function ObjTagaTaga

; -------------------------------------------------------------------------
ObjTagaTaga_Index:dc.w	ObTagaTaga_Init-ObjTagaTaga_Index
	dc.w	ObjTagaTaga_Init2-ObjTagaTaga_Index
	dc.w	ObjTagaTaga_Animate-ObjTagaTaga_Index
	dc.w	ObjTagaTaga_Jump-ObjTagaTaga_Index
	dc.w	ObjTagaTaga_Main-ObjTagaTaga_Index
; -------------------------------------------------------------------------

ObTagaTaga_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oRender(a0)
	move.b	#3,oPriority(a0)
	move.b	#$10,oXRadius(a0)
	move.b	#$10,oWidth(a0)
	move.b	#$16,oYRadius(a0)
	move.w	oX(a0),oVar2A(a0)
	move.w	oY(a0),oVar2C(a0)
	moveq	#3,d0
	jsr	LevelObj_SetBaseTile
	tst.b	oSubtype(a0)
	bne.s	.Damaged
	lea	MapSpr_TagaTaga1(pc),a1
	lea	Ani_TagaTaga1(pc),a2
	move.l	#-$3C000,d0
	move.l	#$1000,d1
	bra.s	.SetInfo

; -------------------------------------------------------------------------

.Damaged:
	lea	MapSpr_TagaTaga2(pc),a1
	lea	Ani_TagaTaga2(pc),a2
	move.l	#-$30000,d0
	move.l	#$1000,d1

.SetInfo:
	move.l	a1,oMap(a0)
	move.l	a2,oVar3C(a0)
	move.l	d0,oVar30(a0)
	move.l	d1,oVar38(a0)
; End of function ObTagaTaga_Init

; -------------------------------------------------------------------------

ObjTagaTaga_Init2:
	addq.b	#2,oRoutine(a0)
	move.w	#$FF,oAnim(a0)
	move.b	#0,oColType(a0)
	move.l	oVar2C(a0),oY(a0)
; End of function ObjTagaTaga_Init2

; -------------------------------------------------------------------------

ObjTagaTaga_Animate:
	movea.l	oVar3C(a0),a1
	jmp	AnimateObject
; End of function ObjTagaTaga_Animate

; -------------------------------------------------------------------------

ObjTagaTaga_Jump:
	addq.b	#2,oRoutine(a0)
	move.w	#$1FF,oAnim(a0)
	move.b	#$2E,oColType(a0)
	move.l	oVar2C(a0),oY(a0)
	move.l	oVar30(a0),oVar34(a0)
	tst.b	oRender(a0)
	bpl.s	ObjTagaTaga_Main
	move.w	#$A2,d0
	jsr	PlayFMSound
; End of function ObjTagaTaga_Jump

; -------------------------------------------------------------------------

ObjTagaTaga_Main:
	move.l	oVar34(a0),d0
	add.l	d0,oY(a0)
	move.l	oVar38(a0),d0
	add.l	d0,oVar34(a0)
	move.w	oY(a0),d0
	cmp.w	oVar2C(a0),d0
	ble.s	ObjTagaTaga_DoAnim
	move.b	#2,oRoutine(a0)
	tst.b	oRender(a0)
	bpl.s	ObjTagaTaga_DoAnim
	move.w	#$A2,d0
	jsr	PlayFMSound

ObjTagaTaga_DoAnim:
	movea.l	$3C(a0),a1
	jmp	AnimateObject
; End of function ObjTagaTaga_Main

; -------------------------------------------------------------------------
Ani_TagaTaga1:
	include	"level/r1/objects/tagataga/animnormal.asm"
	even
Ani_TagaTaga2:
	include	"level/r1/objects/tagataga/animdamaged.asm"
	even
	include	"level/r1/objects/tagataga/map.asm"
	even

; -------------------------------------------------------------------------

ObjNull23:
	rts
; End of function ObjNull23

; -------------------------------------------------------------------------

ObjSpringBoard_Platform:
	tst.b	lvlDebugMode
	bne.s	.NoTouch
	cmpi.b	#6,oRoutine(a1)
	bcc.s	.NoTouch
	tst.w	oYVel(a1)
	bmi.s	.NoTouch
	bra.s	.ChkTouch

; -------------------------------------------------------------------------

.NoTouch:
	bclr	#3,oStatus(a0)
	moveq	#0,d1
	rts

; -------------------------------------------------------------------------

.ChkTouch:
	lea	ObjSpringBoard_Size,a2
	andi.w	#7,d0
	asl.w	#2,d0
	lea	(a2,d0.w),a2
	move.w	oX(a0),d0
	move.w	oX(a1),d1
	move.b	oXRadius(a1),d3
	ext.w	d3
	move.b	0(a2),d2
	ext.w	d2
	move.w	d0,d4
	move.w	d1,d5
	add.w	d2,d4
	sub.w	d3,d5
	cmp.w	d4,d5
	bpl.s	.ClearRide
	move.b	1(a2),d2
	ext.w	d2
	neg.w	d2
	move.w	d0,d4
	move.w	d1,d5
	sub.w	d2,d4
	add.w	d3,d5
	cmp.w	d5,d4
	bpl.s	.ClearRide
	move.w	oY(a0),d0
	move.w	oY(a1),d1
	move.b	oYRadius(a1),d3
	ext.w	d3
	move.b	2(a2),d2
	ext.w	d2
	move.w	d0,d4
	move.w	d1,d5
	add.w	d2,d4
	sub.w	d3,d5
	cmp.w	d4,d5
	bpl.s	.ClearRide
	move.b	3(a2),d2
	ext.w	d2
	neg.w	d2
	move.w	d0,d4
	move.w	d1,d5
	sub.w	d2,d4
	add.w	d3,d5
	cmp.w	d5,d4
	bpl.s	.ClearRide
	bset	#3,oStatus(a0)
	moveq	#$FFFFFFFF,d1
	rts

; -------------------------------------------------------------------------

.ClearRide:
	bclr	#3,oStatus(a0)
	moveq	#0,d1
	rts
; End of function ObjSpringBoard_Platform

; -------------------------------------------------------------------------
ObjSpringBoard_Size:
	dc.b	$10, $F0, $10,	$F0
	dc.b	$10, $F0, 4, $FC
	dc.b	9,	$F7, $38, $10
	dc.b	0,	$E8, 4,	$FC
	dc.b	0,	$E8, $C, 0
	dc.b	$18, 0, 4,	$FC
	dc.b	$18, 0, $C, 0
	dc.b	$20, $E0, $20, $E0
; -------------------------------------------------------------------------

ObjSpringBoard:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjSpringBoard_Index(pc,d0.w),d0
	jsr	ObjSpringBoard_Index(pc,d0.w)
	jmp	CheckObjDespawnTime
; End of function ObjSpringBoard

; -------------------------------------------------------------------------
ObjSpringBoard_Index:dc.w	ObjSpringBoard_Init-ObjSpringBoard_Index
	dc.w	ObjSpringBoard_MainNormal-ObjSpringBoard_Index
	dc.w	ObjSpringBoard_MainFlip-ObjSpringBoard_Index
	dc.w	ObjSpringBoard_UnkNormal-ObjSpringBoard_Index
	dc.w	ObjSpringBoard_UnkFlip-ObjSpringBoard_Index
	dc.w	ObjSpringBoard_BounceNormal-ObjSpringBoard_Index
	dc.w	ObjSpringBoard_BounceFlip-ObjSpringBoard_Index
; -------------------------------------------------------------------------

ObjSpringBoard_Init:
	move.l	#MapSpr_SpringBoard,oMap(a0)
	ori.b	#4,oRender(a0)
	move.b	#3,oPriority(a0)
	move.b	#$10,oWidth(a0)
	move.b	#$18,oXRadius(a0)
	move.b	#4,oYRadius(a0)
	moveq	#7,d0
	jsr	LevelObj_SetBaseTile(pc)
	move.b	#3,d0
	move.b	#2,d1
	tst.b	oSubtype(a0)
	bne.s	.Flip
	btst	#0,oRender(a0)
	beq.s	.NoFlip

.Flip:
	move.b	#4,d0
	move.b	#4,d1
	bclr	#0,oRender(a0)
	bclr	#0,oStatus(a0)

.NoFlip:
	move.b	d0,oAnim(a0)
	move.b	d1,oRoutine(a0)
	rts
; End of function ObjSpringBoard_Init

; -------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR ObjSpringBoard_MainFlip

ObjSpringBoard_Animate:
	lea	Ani_SpringBoard(pc),a1
	jsr	AnimateObject
	jmp	DrawObject
; END OF FUNCTION CHUNK	FOR ObjSpringBoard_MainFlip
; -------------------------------------------------------------------------

ObjSpringBoard_MainFlip:

; FUNCTION CHUNK AT 0020BE64 SIZE 00000010 BYTES

	lea	objPlayerSlot.w,a1
	moveq	#3,d0
	bsr.w	ObjSpringBoard_Platform
	tst.b	d1
	beq.s	.NoTouch
	move.l	oY(a0),d0
	moveq	#0,d1
	move.b	oYRadius(a1),d1
	swap	d1
	sub.l	d1,d0
	move.l	d0,oY(a1)
	move.b	#$C,oRoutine(a0)
	move.b	#4,oAnim(a0)

.NoTouch:
	bra.w	ObjSpringBoard_Animate
; End of function ObjSpringBoard_MainFlip

; -------------------------------------------------------------------------

ObjSpringBoard_UnkFlip:
	lea	objPlayerSlot.w,a1
	moveq	#3,d0
	bsr.w	ObjSpringBoard_Platform
	tst.b	d1
	bne.w	.Touching
	move.b	#4,oRoutine(a0)
	btst	#1,oStatus(a1)
	beq.s	.ChkBounce
	move.b	#$C,oRoutine(a0)

.ChkBounce:
	cmpi.b	#$C,oRoutine(a0)
	beq.s	.IsBounce
	bra.s	.Touching

; -------------------------------------------------------------------------

.IsBounce:
	move.b	#$40,oVar2A(a0)

.Touching:
	bra.w	ObjSpringBoard_Animate
; End of function ObjSpringBoard_UnkFlip

; -------------------------------------------------------------------------

ObjSpringBoard_BounceFlip:
	move.b	#2,oAnim(a0)
	nop
	nop
	nop
	nop
	lea	objPlayerSlot.w,a1
	moveq	#4,d0
	bsr.w	ObjSpringBoard_Platform
	tst.b	d1
	beq.s	.NoTouch
	move.w	oYVel(a1),d0
	addi.w	#$100,d0
	cmpi.w	#$A00,d0
	bmi.s	.CapYVel
	move.w	#$A00,d0

.CapYVel:
	neg.w	d0
	move.w	d0,oYVel(a1)
	move.b	#$40,oVar2A(a0)
	bset	#1,oStatus(a1)
	beq.s	.ClearJump
	clr.b	oPlayerJump(a1)

.ClearJump:
	bclr	#5,oStatus(a1)
	clr.b	oPlayerStick(a1)
	move.b	#$13,oYRadius(a1)
	move.b	#9,oXRadius(a1)
	btst	#2,oStatus(a1)
	bne.s	.RollJump
	move.b	#$E,oYRadius(a1)
	move.b	#7,oXRadius(a1)
	addq.w	#5,oY(a1)
	bset	#2,oStatus(a1)
	move.b	#2,oAnim(a1)
	bra.s	.NoTouch

; -------------------------------------------------------------------------

.RollJump:
	bset	#4,oStatus(a1)

.NoTouch:
	move.b	oVar2A(a0),d0
	subq.b	#1,d0
	move.b	d0,oVar2A(a0)
	bne.s	.DoAnim
	move.b	#$40,oVar2A(a0)
	move.b	#4,oRoutine(a0)
	move.b	#4,oAnim(a0)

.DoAnim:
	bra.w	ObjSpringBoard_Animate
; End of function ObjSpringBoard_BounceFlip

; -------------------------------------------------------------------------

ObjSpringBoard_MainNormal:
	lea	objPlayerSlot.w,a1
	moveq	#5,d0
	bsr.w	ObjSpringBoard_Platform
	tst.b	d1
	beq.s	.NoTouch
	move.l	oY(a0),d0
	moveq	#0,d1
	move.b	oYRadius(a1),d1
	swap	d1
	sub.l	d1,d0
	move.l	d0,oY(a1)
	move.b	#$A,oRoutine(a0)
	move.b	#3,oAnim(a0)

.NoTouch:
	bra.w	ObjSpringBoard_Animate
; End of function ObjSpringBoard_MainNormal

; -------------------------------------------------------------------------

ObjSpringBoard_UnkNormal:
	lea	objPlayerSlot.w,a1
	moveq	#5,d0
	bsr.w	ObjSpringBoard_Platform
	tst.b	d1
	bne.w	.NoTouch
	move.b	#2,oRoutine(a0)
	btst	#1,oStatus(a1)
	beq.s	.ChkBounce
	move.b	#$A,oRoutine(a0)

.ChkBounce:
	cmpi.b	#$A,oRoutine(a0)
	beq.s	.IsBounce
	bra.s	.NoTouch

; -------------------------------------------------------------------------

.IsBounce:
	move.b	#$40,oVar2A(a0)

.NoTouch:
	bra.w	ObjSpringBoard_Animate
; End of function ObjSpringBoard_UnkNormal

; -------------------------------------------------------------------------

ObjSpringBoard_BounceNormal:
	move.b	#1,oAnim(a0)
	lea	objPlayerSlot.w,a1
	moveq	#6,d0
	bsr.w	ObjSpringBoard_Platform
	tst.b	d1
	beq.s	.Touching
	move.w	oYVel(a1),d0
	addi.w	#$100,d0
	cmpi.w	#$A00,d0
	bmi.s	.CapYVel
	move.w	#$A00,d0

.CapYVel:
	neg.w	d0
	move.w	d0,oYVel(a1)
	move.b	#$40,oVar2A(a0)
	bset	#1,oStatus(a1)
	beq.s	.ClearJump
	clr.b	oPlayerJump(a1)

.ClearJump:
	bclr	#5,oStatus(a1)
	clr.b	oPlayerStick(a1)
	move.b	#$13,oYRadius(a1)
	move.b	#9,oXRadius(a1)
	btst	#2,oStatus(a1)
	bne.s	.RollJump
	move.b	#$E,oYRadius(a1)
	move.b	#7,oXRadius(a1)
	addq.w	#5,oY(a1)
	bset	#2,oStatus(a1)
	move.b	#2,oAnim(a1)
	bra.s	.Touching

; -------------------------------------------------------------------------

.RollJump:
	bset	#4,oStatus(a1)

.Touching:
	move.b	oVar2A(a0),d0
	subq.b	#1,d0
	move.b	d0,oVar2A(a0)
	bne.s	.Animate
	move.b	#2,oRoutine(a0)
	move.b	#3,oAnim(a0)
	move.b	#$40,oVar2A(a0)

.Animate:
	bra.w	ObjSpringBoard_Animate
; End of function ObjSpringBoard_BounceNormal

; -------------------------------------------------------------------------
Ani_SpringBoard:
	include	"level/r1/objects/springboard/anim.asm"
	even
MapSpr_SpringBoard:
	include	"level/r1/objects/springboard/map.asm"
	even
; -------------------------------------------------------------------------

ObjSpikes:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjSpikes_Index(pc,d0.w),d0
	jmp	ObjSpikes_Index(pc,d0.w)
; End of function ObjSpikes

; -------------------------------------------------------------------------
ObjSpikes_Index:dc.w	ObjSpikes_Init-ObjSpikes_Index
	dc.w	ObjSpikes_Main-ObjSpikes_Index
; -------------------------------------------------------------------------

ObjSpikes_Init:
	addq.b	#2,oRoutine(a0)
	move.l	#MapSpr_Spikes,oMap(a0)
	ori.b	#4,oRender(a0)
	move.b	#3,oPriority(a0)
	moveq	#$A,d0
	jsr	LevelObj_SetBaseTile(pc)
	move.b	#$10,oWidth(a0)
	move.b	#8,oYRadius(a0)
	btst	#1,oRender(a0)
	beq.s	ObjSpikes_Main
	move.b	#$12,oWidth(a0)
	move.b	#$83,oColType(a0)
; End of function ObjSpikes_Init

; -------------------------------------------------------------------------

ObjSpikes_Main:
	lea	objPlayerSlot.w,a1
	move.w	oY(a1),d0
	sub.w	oY(a0),d0
	bcc.s	.AbsDY
	neg.w	d0

.AbsDY:
	cmpi.w	#$20,d0
	bcc.s	.Display
	btst	#1,oRender(a0)
	beq.s	.ChkStand
	lea	objPlayerSlot.w,a1
	jsr	SolidObject
	bra.s	.Display

; -------------------------------------------------------------------------

.ChkStand:
	jsr	SolidObject
	beq.s	.Display
	btst	#3,oStatus(a0)
	beq.s	.Display
	tst.b	timeWarpFlag
	bne.s	.Display
	tst.b	invincibleFlag
	bne.s	.Display
	move.l	a0,-(sp)
	movea.l	a0,a2
	lea	objPlayerSlot.w,a0
	cmpi.b	#4,oRoutine(a0)
	bcc.s	.Restore
	tst.w	oPlayerHurt(a0)
	bne.s	.Restore
	move.l	oY(a0),d3
	move.w	oYVel(a0),d0
	ext.l	d0
	asl.l	#8,d0
	sub.l	d0,d3
	move.l	d3,oY(a0)
	jsr	HurtPlayer

.Restore:
	movea.l	(sp)+,a0

.Display:
	jsr	DrawObject
	jmp	CheckObjDespawnTime
; End of function ObjSpikes_Main

; -------------------------------------------------------------------------
MapSpr_Spikes:
	include	"level/r1/objects/spikes/map.asm"
	even
; -------------------------------------------------------------------------

ObjCollapsePlatform:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjCollapsePlatform_Index(pc,d0.w),d0
	jsr	ObjCollapsePlatform_Index(pc,d0.w)
	jsr	DrawObject
	cmpi.b	#4,oRoutine(a0)
	bge.s	.End
	jmp	CheckObjDespawnTime

; -------------------------------------------------------------------------

.End:
	rts
; End of function ObjCollapsePlatform

; -------------------------------------------------------------------------
ObjCollapsePlatform_Index:
	dc.w	ObjCollapsePlatform_Init-ObjCollapsePlatform_Index
	dc.w	ObjCollapsePlatform_Main-ObjCollapsePlatform_Index
	dc.w	ObjCollapsePlatform_Delay-ObjCollapsePlatform_Index
	dc.w	ObjCollapsePlatform_Fall-ObjCollapsePlatform_Index
; -------------------------------------------------------------------------

ObjCollapsePlatform_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oRender(a0)
	move.b	#3,oPriority(a0)
	move.w	#$44BE,oTile(a0)
	lea	MapSpr_CollapsePlatform1(pc),a1
	lea	ObjCollapsePlatform_Sizes1(pc),a2
	move.b	oSubtype(a0),d0
	bpl.s	.SetMaps
	lea	MapSpr_CollapsePlatform2(pc),a1
	lea	ObjCollapsePlatform_Sizes2(pc),a2

.SetMaps:
	move.l	a1,oMap(a0)
	btst	#4,d0
	beq.s	.NoFlip
	bset	#0,oRender(a0)
	bset	#0,oStatus(a0)

.NoFlip:
	andi.w	#$F,d0
	move.b	d0,oMapFrame(a0)
	add.w	d0,d0
	move.w	(a2,d0.w),d0
	move.b	(a2,d0.w),d1
	addq.b	#1,d1
	asl.b	#3,d1
	move.b	d1,oXRadius(a0)
	move.b	d1,oWidth(a0)
	move.b	1(a2,d0.w),d1
	bpl.s	.AbsDY
	neg.b	d1

.AbsDY:
	addq.b	#1,d1
	asl.b	#3,d1
	addq.b	#2,d1
	move.b	d1,oYRadius(a0)
; End of function ObjCollapsePlatform_Init

; -------------------------------------------------------------------------

ObjCollapsePlatform_Main:

; FUNCTION CHUNK AT 0020C32C SIZE 000001F4 BYTES

	lea	objPlayerSlot.w,a1
	jsr	SolidObject1
	bne.s	.StandOn
	rts

; -------------------------------------------------------------------------

.StandOn:
	jsr	ClearObjRide
	move.w	#$A3,d0
	jsr	PlayFMSound
	addq.b	#2,oRoutine(a0)
	move.b	oSubtype(a0),d0
	bpl.w	ObjCollapsePlatform_BreakUp_MultiRow
	bra.w	ObjCollapsePlatform_BreakUp_SingleRow
; End of function ObjCollapsePlatform_Main

; -------------------------------------------------------------------------

ObjCollapsePlatform_Delay:
	addi.w	#-1,oVar2A(a0)
	bne.s	.KeepOn
	addq.b	#2,oRoutine(a0)

.KeepOn:
	move.b	oVar3E(a0),d0
	beq.s	.End
	lea	objPlayerSlot.w,a1
	jsr	SolidObject1
	beq.s	.End
	tst.w	oVar2A(a0)
	bne.s	.End
	jsr	ClearObjRide

.End:
	rts
; End of function ObjCollapsePlatform_Delay

; -------------------------------------------------------------------------

ObjCollapsePlatform_Fall:
	move.l	oVar2C(a0),d0
	add.l	d0,oY(a0)
	addi.l	#$4000,oVar2C(a0)
	move.w	oY(a0),d0
	lea	objPlayerSlot.w,a1
	sub.w	oY(a1),d0
	cmpi.w	#$200,d0
	bgt.w	.Delete
	rts

; -------------------------------------------------------------------------

.Delete:
	jmp	DeleteObject
; End of function ObjCollapsePlatform_Fall

; -------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR ObjCollapsePlatform_Main

ObjCollapsePlatform_BreakUp_MultiRow:
	move.b	oSubtype(a0),d0
	suba.l	a4,a4
	btst	#4,d0
	beq.s	.SkipThis
	lea	ObjCollapsePlatform_BreakUp_MultiRow(pc),a4

.SkipThis:
	lea	ObjCollapsePlatform_Sizes1(pc),a6
	andi.w	#$F,d0
	add.w	d0,d0
	move.w	(a6,d0.w),d0
	lea	(a6,d0.w),a6
	moveq	#0,d0
	move.b	(a6)+,d0
	movea.w	d0,a5
	asl.w	#3,d0
	move.w	#$FFF0,d1
	cmpa.w	#0,a4
	bne.s	.SkipThis2
	neg.w	d0
	neg.w	d1

.SkipThis2:
	add.w	oX(a0),d0
	movea.w	d0,a2
	movea.w	d1,a3
	moveq	#0,d6
	move.b	(a6)+,d6
	move.w	d6,d4
	asl.w	#3,d4
	add.w	$C(a0),d4
	move.w	#9,d2
	move.b	oID(a0),oVar3F(a0)

.Loop:
	move.w	a5,d5
	move.w	a2,d3
	move.w	d2,d1

.Loop2:
	jsr	FindObjSlot
	bne.w	.Solid
	move.b	(a6)+,d0
	bmi.w	.Endxt
	move.b	d0,oMapFrame(a1)
	ori.b	#4,oRender(a1)
	move.b	#3,oPriority(a1)
	move.w	#$44BE,oTile(a1)
	move.l	#MapSpr_CollapsePlatform3,oMap(a1)
	move.l	#$20000,oVar2C(a1)
	move.b	oVar3F(a0),oID(a1)
	move.b	oRoutine(a0),oRoutine(a1)
	cmpa.w	#0,a4
	beq.s	.SkipThis3
	bset	#0,oRender(a1)
	bset	#0,oStatus(a1)

.SkipThis3:
	tst.w	d6
	bne.s	.NotLast
	st	oVar3E(a1)
	move.b	#8,oXRadius(a1)
	move.b	#8,oWidth(a1)
	move.b	#9,oYRadius(a1)

.NotLast:
	move.w	d4,oY(a1)
	move.w	d3,oX(a1)
	move.w	d1,oVar2A(a1)

.Endxt:
	add.w	a3,d3
	addi.w	#$C,d1
	dbf	d5,.Loop2
	addi.w	#-$10,d4
	addq.w	#5,d2
	dbf	d6,.Loop
	bra.s	.Delete

; -------------------------------------------------------------------------

.Solid:
	lea	objPlayerSlot.w,a1
	jsr	SolidObject1
	beq.s	.Delete
	jsr	ClearObjRide

.Delete:
	jmp	DeleteObject

; -------------------------------------------------------------------------

ObjCollapsePlatform_BreakUp_SingleRow:
	move.b	oSubtype(a0),d2
	lea	ObjCollapsePlatform_Sizes2(pc),a6
	move.b	d2,d0
	andi.w	#$1F,d0
	add.w	d0,d0
	move.w	(a6,d0.w),d0
	lea	(a6,d0.w),a6
	move.b	(a6)+,d5
	move.b	(a6)+,d1
	addq.b	#1,d1
	asl.b	#3,d1
	addq.b	#2,d1
	andi.w	#$FF,d5
	move.w	d5,d4
	lsl.w	#3,d4
	neg.w	d4
	move.w	#$10,d3
	moveq	#1,d6
	btst	#6,d2
	bne.w	.GetSpeed
	lsl.b	#2,d2
	bra.s	.SkipSpeed

; -------------------------------------------------------------------------

.GetSpeed:
	lea	objPlayerSlot.w,a1
	move.w	oXVel(a1),d0
	btst	#5,d2
	beq.s	.GotSpeed
	neg.w	d0

.GotSpeed:
	tst.w	d0

.SkipSpeed:
	bpl.s	.InitX
	lea	(a6,d5.w),a6
	neg.w	d4
	neg.w	d3
	neg.w	d6

.InitX:
	add.w	oX(a0),d4
	move.w	#9,d2
	move.b	oID(a0),oVar3F(a0)

.Loop3:
	jsr	FindObjSlot
	bne.w	.Solid2
	move.b	#3,oPriority(a1)
	move.w	#$44BE,oTile(a1)
	ori.b	#4,oRender(a1)
	move.l	#MapSpr_CollapsePlatform4,oMap(a1)
	move.l	#$20000,oVar2C(a1)
	move.b	oVar3F(a0),oID(a1)
	move.b	oRoutine(a0),oRoutine(a1)
	move.w	oY(a0),oY(a1)
	st	oVar3E(a1)
	move.b	#8,oXRadius(a1)
	move.b	#8,oWidth(a1)
	move.b	d1,oYRadius(a1)
	move.b	(a6),oMapFrame(a1)
	lea	(a6,d6.w),a6
	move.w	d4,oX(a1)
	add.w	d3,d4
	move.w	d2,oVar2A(a1)
	addi.w	#$C,d2
	dbf	d5,.Loop3
	bra.s	.Delete2

; -------------------------------------------------------------------------

.Solid2:
	lea	objPlayerSlot.w,a1
	jsr	SolidObject1
	beq.s	.Delete2
	jsr	ClearObjRide

.Delete2:
	jmp	DeleteObject
; END OF FUNCTION CHUNK	FOR ObjCollapsePlatform_Main

; -------------------------------------------------------------------------
MapSpr_CollapsePlatform1:
	include	"level/r1/objects/platform/mapcollapseledge.asm"
	even
ObjCollapsePlatform_Sizes1:dc.w	byte_20C598-ObjCollapsePlatform_Sizes1
byte_20C598:	dc.b	4,	3
	dc.b	$FF, $FF
	dc.b	0,	0
	dc.b	0,	1
	dc.b	2,	3
	dc.b	3,	4
	dc.b	0,	5
	dc.b	5,	5
	dc.b	5,	6
	dc.b	6,	6
	dc.b	6,	6
MapSpr_CollapsePlatform3:
	include	"level/r1/objects/platform/mapcollapsepieces.asm"
	even
MapSpr_CollapsePlatform2:
	include	"level/r1/objects/platform/mapcollapse.asm"
	even


ObjCollapsePlatform_Sizes2:dc.w	byte_20C790-ObjCollapsePlatform_Sizes2
	dc.w	byte_20C790-ObjCollapsePlatform_Sizes2
	dc.w	byte_20C798-ObjCollapsePlatform_Sizes2
	dc.w	byte_20C79E-ObjCollapsePlatform_Sizes2
	dc.w	byte_20C7A4-ObjCollapsePlatform_Sizes2
	dc.w	byte_20C7A8-ObjCollapsePlatform_Sizes2
byte_20C790:	dc.b	5,	1
	dc.b	0,	0
	dc.b	0,	0
	dc.b	0,	0
byte_20C798:	dc.b	3,	3
	dc.b	1,	2
	dc.b	2,	2
byte_20C79E:	dc.b	3,	3
	dc.b	2,	2
	dc.b	2,	2
byte_20C7A4:	dc.b	1,	3
	dc.b	3,	5
byte_20C7A8:	dc.b	1,	3
	dc.b	5,	4
MapSpr_CollapsePlatform4:
	include	"level/r1/objects/platform/mapcollapsepieces2.asm"
	even
; -------------------------------------------------------------------------

ObjPlatform:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjPlatform_Index(pc,d0.w),d0
	jsr	ObjPlatform_Index(pc,d0.w)
	jsr	DrawObject
	rts
; End of function ObjPlatform

; -------------------------------------------------------------------------
ObjPlatform_Index:dc.w	ObjPlatform_Init-ObjPlatform_Index
	dc.w	ObjPlatform_Main-ObjPlatform_Index
; -------------------------------------------------------------------------

ObjPlatform_SolidObj:
	lea	objPlayerSlot.w,a1
	move.w	oX(a0),d3
	move.w	oY(a0),d4
	jmp	SolidObject1
; End of function ObjPlatform_SolidObj

; -------------------------------------------------------------------------

ObjPlatform_Init:
	ori.b	#4,oRender(a0)
	move.w	#$44BE,oTile(a0)
	move.b	#2,oPriority(a0)
	move.w	oX(a0),oVar38(a0)
	move.w	oY(a0),oVar3A(a0)
	move.w	oY(a0),oVar36(a0)
	move.l	#MapSpr_Platform,d0
	cmpi.w	#0,levelZone
	beq.s	.SetMaps
	move.l	#MapSpr_Platform,d0
	cmpi.w	#1,levelZone
	beq.s	.SetMaps
	move.l	#MapSpr_Platform,d0

.SetMaps:
	move.l	d0,oMap(a0)
	move.b	oSubtype(a0),d0
	move.b	d0,d1
	andi.w	#3,d0
	move.b	d0,oMapFrame(a0)
	move.b	ObjPlatform_Widths(pc,d0.w),oWidth(a0)
	move.b	#8,oYRadius(a0)
	lsr.b	#2,d1
	andi.w	#3,d1
	move.b	ObjPlatform_Ranges(pc,d1.w),oVar2D(a0)
	move.b	oSubtype2(a0),d0
	beq.s	.NoChild
	jsr	FindObjSlot
	beq.s	.MakeSpring
	jmp	ObjPlatform_Destroy

; -------------------------------------------------------------------------

.MakeSpring:
	move.b	#$A,oID(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	subi.w	#$10,oY(a1)
	move.b	#$F0,oVar39(a1)
	move.w	a0,oVar34(a1)
	move.b	oSubtype2(a0),d0
	move.b	d0,d1
	andi.b	#2,d1
	move.b	d1,oSubtype(a1)
	andi.b	#$F8,d0
	move.b	d0,oVar38(a1)
	add.w	d0,oX(a1)

.NoChild:
	addq.b	#2,oRoutine(a0)
	rts
; End of function ObjPlatform_Init

; -------------------------------------------------------------------------
ObjPlatform_Widths:dc.b	$10, $20, $30, 0
ObjPlatform_Ranges:dc.b	2, 3, 4, 6
; -------------------------------------------------------------------------

ObjPlatform_Main:
	tst.w	timeStopTimer
	beq.s	.TimeOK
	bra.w	ObjPlatform_SolidObj

; -------------------------------------------------------------------------

.TimeOK:
	move.b	oSubtype(a0),d0
	lsr.b	#4,d0
	andi.w	#$F,d0
	add.w	d0,d0
	move.w	ObjPlatform_Subtypes(pc,d0.w),d0
	jsr	ObjPlatform_Subtypes(pc,d0.w)
	move.w	$38(a0),d0
	andi.w	#$FF80,d0
	move.w	cameraX.w,d1
	subi.w	#$80,d1
	andi.w	#$FF80,d1
	sub.w	d1,d0
	cmpi.w	#$280,d0
	bhi.s	.Destroy
	rts

; -------------------------------------------------------------------------

.Destroy:
	lea	objPlayerSlot.w,a1
	jsr	ClearObjRide
	bra.w	ObjPlatform_Destroy
; End of function ObjPlatform_Main

; -------------------------------------------------------------------------
ObjPlatform_Subtypes:
	dc.w	ObjPlatform_Subtype0X-ObjPlatform_Subtypes
	dc.w	ObjPlatform_Subtype1X-ObjPlatform_Subtypes
	dc.w	ObjPlatform_Subtype2X-ObjPlatform_Subtypes
	dc.w	ObjPlatform_Subtype3X-ObjPlatform_Subtypes
	dc.w	ObjPlatform_Subtype4X-ObjPlatform_Subtypes
	dc.w	ObjPlatform_Subtype5X-ObjPlatform_Subtypes
	dc.w	ObjPlatform_Subtype6X-ObjPlatform_Subtypes
	dc.w	ObjPlatform_Subtype7X-ObjPlatform_Subtypes
	dc.w	ObjPlatform_Subtype8X-ObjPlatform_Subtypes
	dc.w	ObjPlatform_Subtype9X-ObjPlatform_Subtypes
; -------------------------------------------------------------------------

ObjPlatform_Subtype0X:
	addq.b	#1,oVar2A(a0)
	jsr	ObjPlatform_DoOsc(pc)
	add.w	oVar3A(a0),d0
	move.w	d0,oY(a0)
	jmp	ObjPlatform_SolidObj
; End of function ObjPlatform_Subtype0X

; -------------------------------------------------------------------------

ObjPlatform_Subtype1X:
	move.l	oX(a0),-(sp)
	jsr	ObjPlatform_DoOsc(pc)
	add.w	oVar38(a0),d0
	move.w	d0,oX(a0)
	addq.b	#1,oVar2A(a0)
	moveq	#0,d0
	move.b	oVar2C(a0),d0
	asr.b	#1,d0
	add.w	oVar3A(a0),d0
	move.w	d0,oY(a0)

ObjPlatform_SetXSpdAndDrop:
	move.l	(sp)+,d0
	move.l	oX(a0),d1
	sub.l	d0,d1
	asr.l	#8,d1
	move.w	d1,oXVel(a0)

ObjPlatform_DropWhenStoodOn:
	jsr	ObjPlatform_SolidObj(pc)
	beq.s	.Backup
	move.b	oVar2C(a0),d0
	cmpi.b	#8,d0
	bcc.s	.EndDropping
	addq.b	#1,oVar2C(a0)

.EndDropping:
	moveq	#1,d0
	rts

; -------------------------------------------------------------------------

.Backup:
	moveq	#0,d0
	move.b	oVar2C(a0),d0
	beq.s	.EndRising
	subq.b	#1,oVar2C(a0)

.EndRising:
	moveq	#0,d0
	rts
; End of function ObjPlatform_Subtype1X

; -------------------------------------------------------------------------

ObjPlatform_Subtype2X:
	move.l	oX(a0),-(sp)
	addq.b	#1,oVar2A(a0)
	jsr	ObjPlatform_DoOsc(pc)
	add.w	oVar3A(a0),d0
	move.w	d0,oY(a0)
	jsr	ObjPlatform_DoOsc(pc)
	add.w	oVar38(a0),d0
	move.w	d0,oX(a0)
	bra.w	ObjPlatform_SetXSpdAndDrop
; End of function ObjPlatform_Subtype2X

; -------------------------------------------------------------------------

ObjPlatform_Subtype3X:
	move.l	oX(a0),-(sp)
	addq.b	#1,oVar2A(a0)
	jsr	ObjPlatform_DoOsc(pc)
	add.w	oVar3A(a0),d0
	move.w	d0,oY(a0)
	jsr	ObjPlatform_DoOsc(pc)
	neg.w	d0
	add.w	oVar38(a0),d0
	move.w	d0,oX(a0)
	bra.w	ObjPlatform_SetXSpdAndDrop
; End of function ObjPlatform_Subtype3X

; -------------------------------------------------------------------------

ObjPlatform_Subtype4X:
	moveq	#0,d0
	move.b	oVar2C(a0),d0
	asr.b	#1,d0
	add.w	oVar3A(a0),d0
	move.w	d0,oY(a0)
	bra.w	ObjPlatform_DropWhenStoodOn
; End of function ObjPlatform_Subtype4X

; -------------------------------------------------------------------------

ObjPlatform_Subtype5X:
	move.b	oVar2B(a0),d0
	bne.s	.RunTimer
	jsr	ObjPlatform_Subtype4X(pc)
	bne.s	.InitTimer
	rts

; -------------------------------------------------------------------------

.InitTimer:
	move.b	#30,oVar2E(a0)
	addq.b	#2,oVar2B(a0)

.RunTimer:
	move.b	oVar2E(a0),d0
	beq.s	.Drop
	subq.b	#1,oVar2E(a0)
	bra.w	ObjPlatform_Subtype4X

; -------------------------------------------------------------------------

.Drop:
	jsr	ObjPlatform_SolidObj(pc)
	move.l	oY(a0),d1
	move.w	oYVel(a0),d0
	ext.l	d0
	asl.l	#8,d0
	add.l	d0,d1
	move.l	d1,oY(a0)
	move.w	oYVel(a0),d0
	cmpi.w	#$400,d0
	bcc.s	.ChkDel
	addi.w	#$40,oYVel(a0)

.ChkDel:
	move.w	cameraY.w,d0
	addi.w	#$100,d0
	cmp.w	oY(a0),d0
	bcc.s	.End
	lea	objPlayerSlot.w,a1
	jsr	ClearObjRide
	jmp	DeleteObject

; -------------------------------------------------------------------------

.End:
	rts
; End of function ObjPlatform_Subtype5X

; -------------------------------------------------------------------------

ObjPlatform_Subtype6X:
	move.b	oVar2B(a0),d0
	andi.w	#$FF,d0
	move.w	ObjPlatform_Subtype6X_Index(pc,d0.w),d0
	jmp	ObjPlatform_Subtype6X_Index(pc,d0.w)
; End of function ObjPlatform_Subtype6X

; -------------------------------------------------------------------------
ObjPlatform_Subtype6X_Index:
	dc.w	ObjPlatform_Subtype6X_Stationary1-ObjPlatform_Subtype6X_Index
	dc.w	ObjPlatform_Subtype6X_MoveDown-ObjPlatform_Subtype6X_Index
	dc.w	ObjPlatform_Subtype6X_Stationary2-ObjPlatform_Subtype6X_Index
; -------------------------------------------------------------------------

ObjPlatform_Subtype6X_Stationary1:
	jsr	ObjPlatform_Subtype4X(pc)
	bne.s	.StartMoving
	rts

; -------------------------------------------------------------------------

.StartMoving:
	addq.b	#2,oVar2B(a0)
; End of function ObjPlatform_Subtype6X_Stationary1

; -------------------------------------------------------------------------

ObjPlatform_Subtype6X_MoveDown:
	move.b	oVar2A(a0),d0
	cmpi.b	#$40,d0
	bcc.w	.StopMoving
	jsr	ObjPlatform_DoOsc(pc)
	neg.w	d0
	add.w	oVar3A(a0),d0
	move.w	d0,oY(a0)
	addq.b	#2,oVar2A(a0)
	jmp	ObjPlatform_SolidObj

; -------------------------------------------------------------------------

.StopMoving:
	move.w	oY(a0),oVar3A(a0)
	addq.b	#2,oVar2B(a0)
; End of function ObjPlatform_Subtype6X_MoveDown

; -------------------------------------------------------------------------

ObjPlatform_Subtype6X_Stationary2:
	bra.w	ObjPlatform_Subtype4X
; End of function ObjPlatform_Subtype6X_Stationary2

; -------------------------------------------------------------------------

ObjPlatform_Subtype7X:
	move.b	oVar2B(a0),d0
	andi.w	#$FF,d0
	move.w	ObjPlatform_Subtype7X_Index(pc,d0.w),d0
	jmp	ObjPlatform_Subtype7X_Index(pc,d0.w)
; End of function ObjPlatform_Subtype7X

; -------------------------------------------------------------------------
ObjPlatform_Subtype7X_Index:dc.w	ObjPlatform_Subtype7X_Stationary1-ObjPlatform_Subtype7X_Index
	dc.w	ObjPlatform_Subtype7X_Rising-ObjPlatform_Subtype7X_Index
	dc.w	ObjPlatform_Subtype7X_Stationary2-ObjPlatform_Subtype7X_Index
; -------------------------------------------------------------------------

ObjPlatform_Subtype7X_Stationary1:
	jsr	ObjPlatform_Subtype4X(pc)
	bne.s	.StartMoving
	rts

; -------------------------------------------------------------------------

.StartMoving:
	addq.b	#2,oVar2B(a0)
	move.b	#$3C,oVar2E(a0)
; End of function ObjPlatform_Subtype7X_Stationary1

; -------------------------------------------------------------------------

ObjPlatform_Subtype7X_Rising:
	move.b	oVar2E(a0),d0
	beq.s	.RiseToCeiling
	subq.b	#1,oVar2E(a0)
	bra.w	ObjPlatform_Subtype4X

; -------------------------------------------------------------------------

.RiseToCeiling:
	jsr	ObjMove
	subq.w	#8,oYVel(a0)
	jsr	ObjGetCeilDist
	tst.w	d1
	bmi.s	.StopMoving
	bra.w	ObjPlatform_DropWhenStoodOn

; -------------------------------------------------------------------------

.StopMoving:
	sub.w	d1,oY(a0)
	move.w	oY(a0),oVar3A(a0)
	addq.b	#2,oVar2B(a0)
; End of function ObjPlatform_Subtype7X_Rising

; -------------------------------------------------------------------------

ObjPlatform_Subtype7X_Stationary2:
	bra.w	ObjPlatform_Subtype4X
; End of function ObjPlatform_Subtype7X_Stationary2

; -------------------------------------------------------------------------

ObjPlatform_Subtype8X:
	move.b	oVar2B(a0),d0
	andi.w	#$FF,d0
	move.w	ObjPlatform_Subtype8X_Index(pc,d0.w),d0
	jmp	ObjPlatform_Subtype8X_Index(pc,d0.w)
; End of function ObjPlatform_Subtype8X

; -------------------------------------------------------------------------
ObjPlatform_Subtype8X_Index:dc.w	ObjPlatform_Subtype8X_Stationary1-ObjPlatform_Subtype8X_Index
	dc.w	ObjPlatform_Subtype8X_MoveX-ObjPlatform_Subtype8X_Index
	dc.w	ObjPlatform_Subtype8X_Stationary2-ObjPlatform_Subtype8X_Index
; -------------------------------------------------------------------------

ObjPlatform_Subtype8X_Stationary1:
	jsr	ObjPlatform_Subtype4X(pc)
	bne.s	.StartMoving
	rts

; -------------------------------------------------------------------------

.StartMoving:
	addq.b	#2,oVar2B(a0)
	move.b	#$3C,oVar2E(a0)
; End of function ObjPlatform_Subtype8X_Stationary1

; -------------------------------------------------------------------------

ObjPlatform_Subtype8X_MoveX:
	move.b	oVar2E(a0),d0
	beq.s	.DoMove
	subq.b	#1,oVar2E(a0)
	bra.w	ObjPlatform_Subtype4X

; -------------------------------------------------------------------------

.DoMove:
	move.b	oVar2A(a0),d0
	cmpi.b	#$40,d0
	bcc.w	.StopMoving
	move.l	oX(a0),-(sp)
	jsr	ObjPlatform_DoOsc(pc)
	add.w	oVar38(a0),d0
	move.w	d0,oX(a0)
	addq.b	#1,oVar2A(a0)
	moveq	#0,d0
	move.b	oVar2C(a0),d0
	asr.b	#1,d0
	add.w	oVar3A(a0),d0
	move.w	d0,oY(a0)
	bra.w	ObjPlatform_SetXSpdAndDrop

; -------------------------------------------------------------------------

.StopMoving:
	move.w	oX(a0),oVar38(a0)
	addq.b	#2,oVar2B(a0)
; End of function ObjPlatform_Subtype8X_MoveX

; -------------------------------------------------------------------------

ObjPlatform_Subtype8X_Stationary2:
	bra.w	ObjPlatform_Subtype4X
; End of function ObjPlatform_Subtype8X_Stationary2

; -------------------------------------------------------------------------

ObjPlatform_Subtype9X:
	move.b	oVar2B(a0),d0
	andi.w	#$FF,d0
	move.w	ObjPlatform_Subtype9X_Index(pc,d0.w),d0
	jmp	ObjPlatform_Subtype9X_Index(pc,d0.w)
; End of function ObjPlatform_Subtype9X

; -------------------------------------------------------------------------
ObjPlatform_Subtype9X_Index:dc.w	ObjPlatform_Subtype9X_Stationary1-ObjPlatform_Subtype9X_Index
	dc.w	ObjPlatform_Subtype9X_MoveX-ObjPlatform_Subtype9X_Index
	dc.w	ObjPlatform_Subtype9X_Stationary2-ObjPlatform_Subtype9X_Index
; -------------------------------------------------------------------------

ObjPlatform_Subtype9X_Stationary1:
	jsr	ObjPlatform_Subtype4X(pc)
	bne.s	.StartMoving
	rts

; -------------------------------------------------------------------------

.StartMoving:
	addq.b	#2,oVar2B(a0)
	move.b	#$3C,oVar2E(a0)
; End of function ObjPlatform_Subtype9X_Stationary1

; -------------------------------------------------------------------------

ObjPlatform_Subtype9X_MoveX:
	move.b	oVar2E(a0),d0
	beq.s	.DoMove
	subq.b	#1,oVar2E(a0)
	bra.w	ObjPlatform_Subtype4X

; -------------------------------------------------------------------------

.DoMove:
	move.b	oVar2A(a0),d0
	cmpi.b	#$40,d0
	bcc.s	.StopMoving
	move.l	oX(a0),-(sp)
	jsr	ObjPlatform_DoOsc(pc)
	neg.w	d0
	add.w	oVar38(a0),d0
	move.w	d0,oX(a0)
	addq.b	#1,oVar2A(a0)
	moveq	#0,d0
	move.b	oVar2C(a0),d0
	asr.b	#1,d0
	add.w	oVar3A(a0),d0
	move.w	d0,oY(a0)
	bra.w	ObjPlatform_SetXSpdAndDrop

; -------------------------------------------------------------------------

.StopMoving:
	move.w	oX(a0),oVar38(a0)
	addq.b	#2,oVar2B(a0)
; End of function ObjPlatform_Subtype9X_MoveX

; -------------------------------------------------------------------------

ObjPlatform_Subtype9X_Stationary2:
	bra.w	ObjPlatform_Subtype4X
; End of function ObjPlatform_Subtype9X_Stationary2

; -------------------------------------------------------------------------

ObjPlatform_DoOsc:
	moveq	#0,d0
	move.b	oVar2A(a0),d0
	jsr	CalcSine
	moveq	#0,d2
	move.b	oVar2D(a0),d2
	muls.w	d2,d0
	asr.w	#4,d0
	rts
; End of function ObjPlatform_DoOsc

; -------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR ObjPlatform_Init

ObjPlatform_Destroy:
	moveq	#0,d0
	move.b	oRespawn(a0),d0
	beq.s	.Delete
	lea	lvlObjRespawns,a1
	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,d0
	moveq	#0,d1
	move.b	timeZone,d1
	add.w	d1,d0
	bclr	#7,2(a1,d0.w)

.Delete:
	jmp	DeleteObject
; END OF FUNCTION CHUNK	FOR ObjPlatform_Init

; -------------------------------------------------------------------------
MapSpr_Platform:
	include	"level/r1/objects/platform/mapnormal.asm"
	even
MapSpr_Platform2:
	include	"level/r1/objects/platform/mapnormal2.asm"
	even
; -------------------------------------------------------------------------

ObjFlapDoorV:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjFlapDoorV_Index(pc,d0.w),d0
	jsr	ObjFlapDoorV_Index(pc,d0.w)
	jsr	DrawObject
	jmp	CheckObjDespawnTime
; End of function ObjFlapDoorV

; -------------------------------------------------------------------------
ObjFlapDoorV_Index:dc.w	ObjFlapDoorV_Init-ObjFlapDoorV_Index
	dc.w	ObjFlapDoorV_Main-ObjFlapDoorV_Index
	dc.w	ObjFlapDoorV_Reset-ObjFlapDoorV_Index

; -------------------------------------------------------------------------
	lea	objPlayerSlot.w,a1
; -------------------------------------------------------------------------

ObjFlapDoorV_SolidObj:
	move.w	8(a0),d3
	move.w	$C(a0),d4
	jmp	SolidObject
; End of function ObjFlapDoorV_SolidObj

; -------------------------------------------------------------------------

ObjFlapDoorV_Init:
	addq.b	#2,oRoutine(a0)
	move.l	#MapSpr_FlapDoorV,oMap(a0)
	move.b	#1,oPriority(a0)
	ori.b	#4,oRender(a0)
	move.b	#4,oWidth(a0)
	move.b	#$18,oYRadius(a0)
	moveq	#$C,d0
	jsr	LevelObj_SetBaseTile
; End of function ObjFlapDoorV_Init

; -------------------------------------------------------------------------

ObjFlapDoorV_Main:
	lea	objPlayerSlot.w,a1
	move.w	oY(a0),d0
	sub.w	oY(a1),d0
	bcc.s	.AbsDX
	neg.w	d0

.AbsDX:
	cmpi.w	#$20,d0
	bcc.s	.NotRange
	move.w	oX(a0),d0
	sub.w	oX(a1),d0
	bcs.s	.NotRange
	cmpi.w	#$30,d0
	bcc.s	.NotRange
	clr.w	oVar3A(a0)
	move.b	#4,oRoutine(a0)
	btst	#7,oRender(a0)
	beq.s	.NotRange
	move.w	#$A4,d0
	jsr	PlayFMSound
	move.b	#1,oMapFrame(a0)

.NotRange:
	bra.w	ObjFlapDoorV_SolidObj
; End of function ObjFlapDoorV_Main

; -------------------------------------------------------------------------

ObjFlapDoorV_Reset:
	addq.b	#8,oVar3A(a0)
	bcc.s	.End
	subq.b	#2,oRoutine(a0)
	move.b	#0,oMapFrame(a0)

.End:
	rts
; End of function ObjFlapDoorV_Reset

; -------------------------------------------------------------------------
Ani_FlapDoorV:
	include	"level/r1/objects/flapdoor/animverti.asm"
	even
MapSpr_FlapDoorV:
	include	"level/r1/objects/flapdoor/mapverti.asm"
	even
; -------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR LoadLevelData

LoadCameraPLC_Full:
	lea	CameraPLC_Ranges(pc),a1
	moveq	#0,d0
	moveq	#0,d1
	move.w	cameraX.w,d0

.Loop:
	cmp.w	(a1)+,d0
	bcs.s	.LoadPLC
	addq.b	#2,d1
	bra.s	.Loop

; -------------------------------------------------------------------------

.LoadPLC:
	move.b	d1,lastCamPLC
	move.w	CameraPLCs_Full(pc,d1.w),d0
	jmp	LoadPLC
; END OF FUNCTION CHUNK	FOR LoadLevelData
; -------------------------------------------------------------------------

LoadCameraPLC_Incr:
	lea	CameraPLC_Ranges(pc),a1
	moveq	#0,d0
	moveq	#0,d1
	move.w	cameraX.w,d0

.Loop:
	cmp.w	(a1)+,d0
	bcs.s	.FoundRange
	addq.b	#2,d1
	bra.s	.Loop

; -------------------------------------------------------------------------

.FoundRange:
	cmp.b	lastCamPLC,d1
	bne.s	.LoadPLC
	rts

; -------------------------------------------------------------------------

.LoadPLC:
	move.b	d1,lastCamPLC
	move.w	CameraPLCs_Incr(pc,d1.w),d0
	jmp	ClearAndLoadPLC
; End of function LoadCameraPLC_Incr

; -------------------------------------------------------------------------
CameraPLC_Ranges:dc.w	$680
	dc.w	$F80
	dc.w	$1980
	dc.w	$1F80
	dc.w	$FFFF
CameraPLCs_Incr:dc.w	8
	dc.w	9
	dc.w	$A
	dc.w	$B
	dc.w	$C
CameraPLCs_Full:dc.w	2
	dc.w	4
	dc.w	5
	dc.w	6
	dc.w	7
; -------------------------------------------------------------------------

LevelObj_SetBaseTile:
	lea	LevelObj_BaseTileList,a1
	add.w	d0,d0
	move.w	LevelObj_BaseTileList(pc,d0.w),d4
	lea	LevelObj_BaseTileList(pc,d4.w),a2
	moveq	#0,d1
	move.b	oSubtype2(a0),d1
	add.w	d1,d1
	move.w	(a2,d1.w),d5
	move.w	d5,oTile(a0)
	rts
; End of function LevelObj_SetBaseTile

; -------------------------------------------------------------------------
LevelObj_BaseTileList:dc.w	word_20CF6C-LevelObj_BaseTileList
	dc.w	word_20CF6E-LevelObj_BaseTileList
	dc.w	word_20CF70-LevelObj_BaseTileList
	dc.w	word_20CF74-LevelObj_BaseTileList
	dc.w	word_20CF76-LevelObj_BaseTileList
	dc.w	word_20CF78-LevelObj_BaseTileList
	dc.w	word_20CF82-LevelObj_BaseTileList
	dc.w	word_20CF7C-LevelObj_BaseTileList
	dc.w	word_20CF80-LevelObj_BaseTileList
	dc.w	word_20CF7E-LevelObj_BaseTileList
	dc.w	word_20CF7A-LevelObj_BaseTileList
	dc.w	word_20CF84-LevelObj_BaseTileList
	dc.w	word_20CF86-LevelObj_BaseTileList
	dc.w	word_20CF88-LevelObj_BaseTileList
	dc.w	word_20CF8A-LevelObj_BaseTileList
	dc.w	word_20CF8C-LevelObj_BaseTileList
	dc.w	word_20CF8E-LevelObj_BaseTileList
	dc.w	word_20CF90-LevelObj_BaseTileList
word_20CF6C:	dc.w	$23A0
word_20CF6E:	dc.w	$23B0
word_20CF70:	dc.w	$2409
	dc.w	$2370
word_20CF74:	dc.w	$2000
word_20CF76:	dc.w	$2428
word_20CF78:	dc.w	$4334
word_20CF7A:	dc.w	$320
word_20CF7C:	dc.w	0
word_20CF7E:	dc.w	$4000
word_20CF80:	dc.w	$4000
word_20CF82:	dc.w	$409
word_20CF84:	dc.w	$374
word_20CF86:	dc.w	$8328
word_20CF88:	dc.w	0
word_20CF8A:	dc.w	0
word_20CF8C:	dc.w	$490
word_20CF8E:	dc.w	$3E4
word_20CF90:	dc.w	0

; -------------------------------------------------------------------------

ObjAnimal:
	jsr	CheckAnimalPrescence
	move.b	oSubtype(a0),d0
	andi.b	#$7F,d0
	bne.w	ObjGroundAnimal

ObjFlyingAnimal:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjFlyingAnimal_Index(pc,d0.w),d0
	jmp	ObjFlyingAnimal_Index(pc,d0.w)

; -------------------------------------------------------------------------
ObjFlyingAnimal_Index:
	dc.w	ObjFlyingAnimal_Init-ObjFlyingAnimal_Index
	dc.w	ObjFlyingAnimal_Flying-ObjFlyingAnimal_Index
	dc.w	ObjFlyingAnimal_Hologram-ObjFlyingAnimal_Index
; -------------------------------------------------------------------------

ObjFlyingAnimal_Init:
	addq.b	#2,oRoutine(a0)
	move.b	#4,oRender(a0)
	move.l	#$8080408,oYRadius(a0)
	move.l	#MapSpr_FlyingAnimal,oMap(a0)
	move.w	oX(a0),oVar2A(a0)
	move.w	oY(a0),oVar2C(a0)
	bsr.w	ObjAnimal_XFlip
	bsr.w	ObjAnimal_SetBaseTile
	tst.b	oSubtype(a0)
	bmi.s	.Holographic
	move.b	#4,oPriority(a0)
	ori.w	#$8000,oTile(a0)
	move.w	#$101,oVar2E(a0)
	rts

; -------------------------------------------------------------------------

.Holographic:
	addq.b	#2,oRoutine(a0)
	move.b	#1,oAnim(a0)
	move.b	#3,oPriority(a0)
	rts
; End of function ObjFlyingAnimal_Init

; -------------------------------------------------------------------------

ObjFlyingAnimal_Flying:
	moveq	#1,d2
	moveq	#1,d3
	bsr.w	ObjFlyingAnimal_Move
	move.b	oVar2E(a0),d0
	add.b	oVar2F(a0),d0
	move.b	d0,d1
	subq.b	#1,d1
	subi.b	#$7F,d1
	bcs.s	.NoFlip
	move.b	oVar2E(a0),d0
	neg.b	oVar2F(a0)
	bsr.w	ObjAnimal_XFlip

.NoFlip:
	move.b	d0,oVar2E(a0)
	lea	Ani_FlyingAnimal(pc),a1
	jsr	AnimateObject
	jsr	DrawObject
	move.w	oVar2A(a0),d0
	jmp	CheckObjDespawn2Time
; End of function ObjFlyingAnimal_Flying

; -------------------------------------------------------------------------

ObjFlyingAnimal_Hologram:

; FUNCTION CHUNK AT 0020D17C SIZE 00000006 BYTES

	movea.w	oVar3E(a0),a1
	cmpi.b	#$2E,oID(a1)
	bne.w	ObjAnimal_Destroy
	tst.b	oVar3F(a1)
	bne.w	ObjAnimal_Destroy
	moveq	#3,d2
	moveq	#4,d3
	bsr.w	ObjFlyingAnimal_Move
	addq.b	#4,oVar2E(a0)
	move.b	oVar2E(a0),d0
	andi.b	#$7F,d0
	beq.w	ObjAnimal_XFlip
	lea	Ani_FlyingAnimal(pc),a1
	jsr	AnimateObject
	jmp	DrawObject
; End of function ObjFlyingAnimal_Hologram

; -------------------------------------------------------------------------

ObjFlyingAnimal_Move:
	move.b	oVar2E(a0),d0
	jsr	CalcSine
	asr.w	d2,d1
	asr.w	d3,d0
	add.w	oVar2A(a0),d1
	add.w	oVar2C(a0),d0
	move.w	d1,oX(a0)
	move.w	d0,oY(a0)
	rts
; End of function ObjFlyingAnimal_Move

; -------------------------------------------------------------------------

ObjGroundAnimal:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjGroundAnimal_Index(pc,d0.w),d0
	jmp	ObjGroundAnimal_Index(pc,d0.w)
; End of function ObjGroundAnimal

; -------------------------------------------------------------------------
ObjGroundAnimal_Index:dc.w	ObjGroundAnimal_Init-ObjGroundAnimal_Index
	dc.w	ObjGroundAnimal_Main-ObjGroundAnimal_Index
	dc.w	ObjGroundAnimal_Hologram-ObjGroundAnimal_Index
; -------------------------------------------------------------------------

ObjGroundAnimal_Init:
	addq.b	#2,oRoutine(a0)
	move.b	#4,oRender(a0)
	move.l	#$8080408,oYRadius(a0)
	move.l	#MapSpr_GroundAnimal,oMap(a0)
	move.w	8(a0),oVar2A(a0)
	bsr.w	ObjAnimal_SetBaseTile
	tst.b	oSubtype(a0)
	bmi.s	.Holographic
	move.l	#$10000,oVar2C(a0)
	move.l	#-$40000,oVar30(a0)
	rts

; -------------------------------------------------------------------------

.Holographic:
	move.b	#4,$24(a0)
	bra.w	ObjAnimal_XFlip
; End of function ObjGroundAnimal_Init

; -------------------------------------------------------------------------

ObjGroundAnimal_Main:
	move.l	oVar2C(a0),d0
	add.l	d0,oX(a0)
	move.l	oVar30(a0),d0
	add.l	d0,oY(a0)
	addi.l	#$2000,oVar30(a0)
	smi	d0
	addq.b	#1,d0
	move.b	d0,oMapFrame(a0)
	jsr	CheckFloorEdge
	tst.w	d1
	bpl.s	.NoFlip
	add.w	d1,oY(a0)
	move.l	#-$40000,oVar30(a0)
	neg.l	oVar2C(a0)
	bsr.s	ObjAnimal_XFlip

.NoFlip:
	jsr	DrawObject
	jmp	CheckObjDespawnTime
; End of function ObjGroundAnimal_Main

; -------------------------------------------------------------------------

ObjGroundAnimal_Hologram:
	movea.w	oVar3E(a0),a1
	cmpi.b	#$2E,oID(a1)
	bne.w	ObjAnimal_Destroy
	tst.b	oVar3F(a1)
	bne.w	ObjAnimal_Destroy
	lea	Ani_GroundAnimal(pc),a1
	jsr	AnimateObject
	jmp	DrawObject
; End of function ObjGroundAnimal_Hologram

; -------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR ObjFlyingAnimal_Hologram

ObjAnimal_Destroy:
	jmp	DeleteObject
; END OF FUNCTION CHUNK	FOR ObjFlyingAnimal_Hologram
; -------------------------------------------------------------------------

ObjAnimal_XFlip:
	bchg	#0,oRender(a0)
	bchg	#0,oStatus(a0)
	rts
; End of function ObjAnimal_XFlip

; -------------------------------------------------------------------------

ObjAnimal_SetBaseTile:
	lea	ObjAnimal_BaseTileList(pc),a1
	moveq	#0,d0
	move.b	levelAct,d0
	asl.w	#2,d0
	add.b	timeZone,d0
	add.w	d0,d0
	move.w	(a1,d0.w),oTile(a0)
	rts
; End of function ObjAnimal_SetBaseTile

; -------------------------------------------------------------------------
Ani_FlyingAnimal:
	include	"level/r1/objects/animal/animflying.asm"
	even
Ani_GroundAnimal:
	include	"level/r1/objects/animal/animground.asm"
	even
MapSpr_FlyingAnimal:
	include	"level/r1/objects/animal/mapflying.asm"
	even
MapSpr_GroundAnimal:
	include	"level/r1/objects/animal/mapground.asm"
	even
ObjAnimal_BaseTileList:dc.w	$4F7
	dc.w	$388
	dc.w	$463
	dc.w	0
	dc.w	$4F7
	dc.w	$38F
	dc.w	$461
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	$3CF
; -------------------------------------------------------------------------

ObjCapsule:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjCapsule_Index(pc,d0.w),d0
	jsr	ObjCapsule_Index(pc,d0.w)
	tst.b	oRoutine(a0)
	beq.s	.End
	cmpi.b	#$A,oRoutine(a0)
	beq.s	.Display
	cmpi.b	#6,oRoutine(a0)
	bcc.s	.End

.Display:
	jmp	DrawObject

; -------------------------------------------------------------------------

.End:
	rts
; End of function ObjCapsule

; -------------------------------------------------------------------------
ObjCapsule_Index:dc.w	ObjCapsule_Init-ObjCapsule_Index
	dc.w	ObjCapsule_Main-ObjCapsule_Index
	dc.w	ObjCapsule_Explode-ObjCapsule_Index
	dc.w	LoadEndOfAct-ObjCapsule_Index
	dc.w	ObjCapsule_Signpost_Null-ObjCapsule_Index
	dc.w	ObjCapsule_FlowerSeeds-ObjCapsule_Index
; -------------------------------------------------------------------------

ObjCapsule_Init:
	ori.b	#4,oRender(a0)
	addq.b	#2,oRoutine(a0)
	move.b	#4,oPriority(a0)
	move.l	#MapSpr_FlowerCapsule,4(a0)
	move.w	#$2481,oTile(a0)
	move.b	#$20,oXRadius(a0)
	move.b	#$20,oWidth(a0)
	move.b	#$18,oYRadius(a0)
; End of function ObjCapsule_Init

; -------------------------------------------------------------------------

ObjCapsule_Main:
	lea	Ani_FlowerCapsule,a1
	jsr	AnimateObject
	lea	objPlayerSlot.w,a6
	bsr.w	ObjCapsule_CheckCollision
	beq.s	.End
	clr.b	updateTime
	move.b	#2,oMapFrame(a0)
	move.b	#$78,oVar2A(a0)
	addq.b	#2,oRoutine(a0)
	move.w	objPlayerSlot+oX.w,d0
	move.b	objPlayerSlot+oXRadius.w,d1
	ext.w	d1
	addi.w	#$20,d1
	sub.w	8(a0),d0
	add.w	d1,d0
	bmi.s	.BounceX
	add.w	d1,d1
	cmp.w	d1,d0
	bcc.s	.BounceX
	move.w	objPlayerSlot+oYVel.w,d0
	neg.w	d0
	asr.w	#2,d0
	move.w	d0,objPlayerSlot+oYVel.w
	rts

; -------------------------------------------------------------------------

.BounceX:
	move.w	objPlayerSlot+oXVel.w,d0
	neg.w	d0
	asr.w	#2,d0
	move.w	d0,objPlayerSlot+oXVel.w

.End:
	rts
; End of function ObjCapsule_Main

; -------------------------------------------------------------------------

ObjCapsule_Explode:
	subq.b	#1,oVar2A(a0)
	bmi.s	.FinishUp
	move.b	oVar2A(a0),d0
	move.b	d0,d1
	andi.b	#3,d1
	bne.s	.End
	lsr.w	#2,d0
	andi.w	#7,d0
	add.w	d0,d0
	lea	ObjCapsule_ExplosionLocs(pc,d0.w),a2
	jsr	FindObjSlot
	bne.s	.End
	move.w	#$9E,d0
	jsr	PlayFMSound
	move.b	#$18,oID(a1)
	move.b	#1,oRoutine2(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	move.b	(a2),d0
	ext.w	d0
	add.w	d0,oX(a1)
	move.b	1(a2),d0
	ext.w	d0
	add.w	d0,oY(a1)
	rts

; -------------------------------------------------------------------------

.FinishUp:
	bsr.w	ObjCapsule_SpawnSeeds
	addq.b	#2,$24(a0)
	move.b	#$3C,$2A(a0)

.End:
	rts
; End of function ObjCapsule_Explode

; -------------------------------------------------------------------------
ObjCapsule_ExplosionLocs:dc.b	0, 0
	dc.b	$20, $F8
	dc.b	$E0, 0
	dc.b	$E8, $F8
	dc.b	$18, 8
	dc.b	$F0, 8
	dc.b	$10, 8
	dc.b	$F8, $F8
; -------------------------------------------------------------------------

ObjCapsule_SpawnSeeds:
	moveq	#0,d0
	move.b	LevelPaletteID,d0
	move.l	d7,d6
	jsr	LoadPalette
	move.l	d6,d7
	moveq	#6,d6
	moveq	#0,d1

.Loop:
	jsr	FindObjSlot
	bne.s	.End
	move.b	#$15,oID(a1)
	ori.b	#4,oRender(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	move.b	#$A,oRoutine(a1)
	move.l	#MapSpr_FlowerCapsule,oMap(a1)
	move.w	#$2481,oTile(a1)
	move.b	#1,oAnim(a1)
	move.w	#-$600,oYVel(a1)
	move.w	ObjCapsule_FlowerLocs(pc,d1.w),oXVel(a1)
	addq.w	#2,d1
	dbf	d6,.Loop

.End:
	rts
; End of function ObjCapsule_SpawnSeeds

; -------------------------------------------------------------------------
ObjCapsule_FlowerLocs:dc.w	0
	dc.w	$FF80
	dc.w	$80
	dc.w	$FF00
	dc.w	$100
	dc.w	$FE80
	dc.w	$180
	dc.w	$FE00
	dc.w	$200
	dc.w	$FD80
	dc.w	$280
; -------------------------------------------------------------------------

ObjCapsule_FlowerSeeds:
	lea	Ani_FlowerCapsule,a1
	jsr	AnimateObject
	jsr	ObjMoveGrv
	jsr	CheckFloorEdge
	tst.w	d1
	bpl.s	.End
	move.b	#$1F,oID(a0)
	move.b	#1,oSubtype(a0)
	move.b	#0,oRoutine(a0)

.End:
	rts
; End of function ObjCapsule_FlowerSeeds

; -------------------------------------------------------------------------

ObjCapsule_CheckCollision:
	btst	#2,oStatus(a6)
	beq.s	.NoCollide
	move.b	oXRadius(a6),d1
	ext.w	d1
	addi.w	#$20,d1
	move.w	oX(a6),d0
	sub.w	oX(a0),d0
	add.w	d1,d0
	bmi.s	.NoCollide
	add.w	d1,d1
	cmp.w	d1,d0
	bcc.s	.NoCollide
	move.b	oYRadius(a6),d1
	ext.w	d1
	addi.w	#$1C,d1
	move.w	oY(a6),d0
	sub.w	oY(a0),d0
	add.w	d1,d0
	bmi.s	.NoCollide
	add.w	d1,d1
	cmp.w	d1,d0
	bcc.s	.NoCollide
	moveq	#1,d0
	rts

; -------------------------------------------------------------------------

.NoCollide:
	moveq	#0,d0
	rts
; End of function ObjCapsule_CheckCollision

; -------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR ObjBigRing

ObjBigRingFlash:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjBigRingFlash_Index(pc,d0.w),d0
	jsr	ObjBigRingFlash_Index(pc,d0.w)
	jmp	DrawObject
; END OF FUNCTION CHUNK	FOR ObjBigRing

; -------------------------------------------------------------------------
ObjBigRingFlash_Index:dc.w	ObjBigRingFlash_Init-ObjBigRingFlash_Index
	dc.w	ObjBigRingFlash_Animate-ObjBigRingFlash_Index
	dc.w	ObjBigRingFlash_Destroy-ObjBigRingFlash_Index
; -------------------------------------------------------------------------

ObjBigRingFlash_Init:
	ori.b	#4,oRender(a0)
	addq.b	#2,oRoutine(a0)
	move.w	#$3EF,oTile(a0)
	move.l	#MapSpr_BigRingFlash,oMap(a0)
; End of function ObjBigRingFlash_Init

; -------------------------------------------------------------------------

ObjBigRingFlash_Animate:
	lea	Ani_BigRingFlash,a1
	jmp	AnimateObject
; End of function ObjBigRingFlash_Animate

; -------------------------------------------------------------------------

ObjBigRingFlash_Destroy:
	jmp	DeleteObject
; End of function ObjBigRingFlash_Destroy

; -------------------------------------------------------------------------

ObjBigRing:

; FUNCTION CHUNK AT 0020D4B4 SIZE 00000014 BYTES

	tst.b	oSubtype(a0)
	bne.s	ObjBigRingFlash
	cmpi.w	#50,levelRings
	bcc.s	.Proceed
	jmp	CheckObjDespawnTime

; -------------------------------------------------------------------------

.Proceed:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjBigRing_Index(pc,d0.w),d0
	jsr	ObjBigRing_Index(pc,d0.w)
	cmpi.b	#4,oRoutine(a0)
	beq.s	.End
	jmp	DrawObject

; -------------------------------------------------------------------------

.End:
	rts
; End of function ObjBigRing

; -------------------------------------------------------------------------
ObjBigRing_Index:dc.w	ObjBigRing_Init-ObjBigRing_Index
	dc.w	ObjBigRing_Main-ObjBigRing_Index
	dc.w	ObjBigRing_Animate-ObjBigRing_Index
; -------------------------------------------------------------------------

ObjBigRing_Init:
	cmpi.b	#$7F,timeStones
	bne.s	.TimeStonesLeft
	jmp	DeleteObject

; -------------------------------------------------------------------------

.TimeStonesLeft:
	tst.b	timeAttackMode
	beq.s	.Init
	jmp	DeleteObject

; -------------------------------------------------------------------------

.Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oRender(a0)
	move.w	#$2488,oTile(a0)
	move.l	#MapSpr_BigRing,oMap(a0)
	move.b	#$20,oXRadius(a0)
	move.b	#$20,oWidth(a0)
	move.b	#$20,oYRadius(a0)
; End of function ObjBigRing_Init

; -------------------------------------------------------------------------

ObjBigRing_Main:
	lea	objPlayerSlot.w,a1
	bsr.w	ObjBigRing_CheckCollision
	beq.s	ObjBigRing_Animate
	move.b	#1,enteredBigRing
	addq.b	#2,oRoutine(a0)
	move.w	cameraX.w,d0
	addi.w	#$150,d0
	move.w	d0,oX(a1)
	bset	#0,ctrlLocked.w
	move.w	#$808,playerCtrlHold.w
	move.w	#0,oXVel(a1)
	move.w	#0,oPlayerGVel(a1)
	move.b	#1,scrollLock.w
	move.w	#$AF,d0
	jsr	PlayFMSound
	jsr	FindObjSlot
	bne.s	ObjBigRing_Main
	move.b	#$14,oID(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	move.b	#1,oSubtype(a1)
; End of function ObjBigRing_Main

; -------------------------------------------------------------------------

ObjBigRing_Animate:
	lea	Ani_BigRing,a1
	jmp	AnimateObject
; End of function ObjBigRing_Animate

; -------------------------------------------------------------------------

ObjBigRing_CheckCollision:
	move.b	oXRadius(a1),d1
	ext.w	d1
	addi.w	#$10,d1
	move.w	oX(a1),d0
	sub.w	oX(a0),d0
	add.w	d1,d0
	bmi.s	.NoCollide
	add.w	d1,d1
	cmp.w	d1,d0
	bcc.s	.NoCollide
	move.b	oYRadius(a1),d1
	ext.w	d1
	addi.w	#$20,d1
	move.w	oY(a1),d0
	sub.w	oY(a0),d0
	add.w	d1,d0
	bmi.s	.NoCollide
	add.w	d1,d1
	cmp.w	d1,d0
	bcc.s	.NoCollide
	moveq	#1,d0
	rts

; -------------------------------------------------------------------------

.NoCollide:
	moveq	#0,d0
	rts
; End of function ObjBigRing_CheckCollision

; -------------------------------------------------------------------------

ObjGoalPost:
	lea	objPlayerSlot.w,a6
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjGoalPost_Index(pc,d0.w),d0
	jsr	ObjGoalPost_Index(pc,d0.w)
	cmpi.b	#2,levelAct
	beq.s	.MarkGone
	jsr	DrawObject

.MarkGone:
	jmp	CheckObjDespawnTime
; End of function ObjGoalPost

; -------------------------------------------------------------------------
ObjGoalPost_Index:dc.w	ObjGoalPost_Init-ObjGoalPost_Index
	dc.w	ObjGoalPost_Main-ObjGoalPost_Index
	dc.w	ObjGoalPost_Null-ObjGoalPost_Index
; -------------------------------------------------------------------------

ObjGoalPost_Init:
	cmpi.w	#$201,levelZone
	bne.s	.Init
	cmpi.b	#1,timeZone
	bne.s	.Init
	tst.b	oSubtype(a0)
	bne.s	.WaitPLC
	move.b	#1,oSubtype(a0)
	moveq	#$13,d0
	jmp	LoadPLC

; -------------------------------------------------------------------------

.WaitPLC:
	tst.l	plcBuffer.w
	beq.s	.Init
	rts

; -------------------------------------------------------------------------

.Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oRender(a0)
	move.b	#4,oPriority(a0)
	move.l	#MapSpr_GoalPost_Signpost,oMap(a0)
	move.b	#$10,oXRadius(a0)
	move.b	#$10,oWidth(a0)
	move.b	#$20,oYRadius(a0)
	move.b	#5,oMapFrame(a0)
	bsr.w	ObjGoalPost_SetBaseTile
; End of function ObjGoalPost_Init

; -------------------------------------------------------------------------

ObjGoalPost_Main:
	move.w	oY(a6),d0
	sub.w	oY(a0),d0
	addi.w	#$80,d0
	bmi.s	.End
	cmpi.w	#$100,d0
	bcc.s	.End
	move.w	oX(a6),d0
	cmp.w	oX(a0),d0
	bcs.s	.End
	addq.b	#2,oRoutine(a0)
	move.w	cameraX.w,leftBound.w
	move.w	cameraX.w,destLeftBound.w
	clr.w	timeWarpTimer.w
	clr.b	timeWarpDir.w
	clr.b	timeWarpFlag
	moveq	#$12,d0
	jmp	LoadPLC

; -------------------------------------------------------------------------

.End:
	rts
; End of function ObjGoalPost_Main

; -------------------------------------------------------------------------

ObjGoalPost_Null:
	rts
; End of function ObjGoalPost_Null

; -------------------------------------------------------------------------

ObjGoalPost_SetBaseTile:
	moveq	#0,d0
	move.w	level,d0
	lsl.b	#7,d0
	lsr.w	#4,d0
	move.b	timeZone,d1
	cmpi.b	#2,d1
	bne.s	.NotFuture
	add.b	goodFuture,d1

.NotFuture:
	add.b	d1,d1
	add.b	d1,d0
	move.w	ObjGoalPost_BaseTileList(pc,d0.w),oTile(a0)
	cmpi.b	#3,levelZone
	beq.s	.End
	ori.w	#$8000,oTile(a0)

.End:
	rts
; End of function ObjGoalPost_SetBaseTile

; -------------------------------------------------------------------------
ObjGoalPost_BaseTileList:dc.w	$35A, $4F7, $4F7,	$4F7, $381, $4F7, $4F7,	$4F7
	dc.w	$300, $300, $300, $300, $300, $300, $300, $300
	dc.w	$4F2, $4F2, $4F2, $4F2, $4F2, $4F2, $4F2, $4F2
	dc.w	$2BA, $2CC, $2B3, $2B1, $2BA, $2CC, $2B3, $2B1
	dc.w	$254, $22C, $294, $238, $278, $28A, $2BC, $298
	dc.w	$3AE, $3AE, $3AE, $3AE, $3AE, $3AE, $3AE, $3AE
	dc.w	$220, $221, $24C, $236, $23E, $24A, $25D, $246
; -------------------------------------------------------------------------

ObjSignpost:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjSignpost_Index(pc,d0.w),d0
	jsr	ObjSignpost_Index(pc,d0.w)
	jmp	DrawObject
; End of function ObjSignpost

; -------------------------------------------------------------------------
ObjSignpost_Index:dc.w	ObjSignpost_Init-ObjSignpost_Index
	dc.w	ObjSignpost_Main-ObjSignpost_Index
	dc.w	ObjSignpost_Spin-ObjSignpost_Index
	dc.w	LoadEndOfAct-ObjSignpost_Index
	dc.w	ObjCapsule_Signpost_Null-ObjSignpost_Index
; -------------------------------------------------------------------------

ObjSignpost_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oRender(a0)
	move.b	#$18,oXRadius(a0)
	move.b	#$18,oWidth(a0)
	move.b	#$20,oYRadius(a0)
	move.b	#4,oPriority(a0)
	move.w	#$43C,oTile(a0)
	cmpi.b	#3,levelZone
	beq.s	.NotHighPriority
	ori.b	#$80,oTile(a0)

.NotHighPriority:
	move.l	#MapSpr_GoalPost_Signpost,oMap(a0)
; End of function ObjSignpost_Init

; -------------------------------------------------------------------------

ObjSignpost_Main:
	lea	objPlayerSlot.w,a6
	move.w	oY(a6),d0
	sub.w	oY(a0),d0
	addi.w	#$80,d0
	bmi.s	.End
	cmpi.w	#$100,d0
	bcc.s	.End
	move.w	oX(a0),d0
	cmp.w	oX(a6),d0
	bcc.s	.End
	move.w	cameraX.w,leftBound.w
	move.w	cameraX.w,destLeftBound.w
	clr.b	updateTime
	move.b	#$78,oVar2A(a0)
	move.b	#0,oMapFrame(a0)
	addq.b	#2,oRoutine(a0)
	clr.b	speedShoesFlag
	clr.b	invincibleFlag
	move.w	#$9D,d0
	jmp	PlayFMSound

; -------------------------------------------------------------------------

.End:
	rts
; End of function ObjSignpost_Main

; -------------------------------------------------------------------------

ObjSignpost_Spin:
	lea	unk_23F21A,a1
	jsr	AnimateObject
	subq.b	#1,oVar2A(a0)
	bne.s	.End
	addq.b	#2,oRoutine(a0)
	move.b	#3,oMapFrame(a0)
	move.b	#60,oVar2A(a0)

.End:
	rts
; End of function ObjSignpost_Spin

; -------------------------------------------------------------------------

LoadEndOfAct:
	subq.b	#1,oVar2A(a0)
	bne.w	.End
	tst.b	timeZone
	bne.s	.NotPast
	move.w	#$82,d0
	jsr	SubCPUCmd

.NotPast:
	move.w	#$6B,d0
	jsr	SubCPUCmd
	bset	#0,ctrlLocked.w
	move.w	#$808,playerCtrlHold.w
	cmpi.w	#$502,levelZone
	bne.s	.NotSSZ3
	move.w	#0,playerCtrlHold.w

.NotSSZ3:
	move.b	#$B4,oVar2A(a0)
	addq.b	#2,oRoutine(a0)
	jsr	FindObjSlot
	move.b	#$3A,oID(a1)
	move.b	#$10,oVar32(a1)
	move.b	#1,updateResultsBonus.w
	moveq	#0,d0
	move.b	levelTime+1,d0
	mulu.w	#60,d0
	moveq	#0,d1
	move.b	levelTime+2,d1
	add.w	d1,d0
	divu.w	#$F,d0
	moveq	#$14,d1
	cmp.w	d1,d0
	bcs.s	.GetBonus
	move.w	d1,d0

.GetBonus:
	add.w	d0,d0
	move.w	TimeBonuses(pc,d0.w),bonusCount1.w
	move.w	levelRings,d0
	mulu.w	#$64,d0
	move.w	d0,bonusCount2.w

.End:
	rts
; End of function LoadEndOfAct

; -------------------------------------------------------------------------
TimeBonuses:	dc.w	50000
	dc.w	50000
	dc.w	10000
	dc.w	5000
	dc.w	4000
	dc.w	4000
	dc.w	3000
	dc.w	3000
	dc.w	2000
	dc.w	2000
	dc.w	2000
	dc.w	2000
	dc.w	1000
	dc.w	1000
	dc.w	1000
	dc.w	1000
	dc.w	500
	dc.w	500
	dc.w	500
	dc.w	500
	dc.w	0
; -------------------------------------------------------------------------

ObjCapsule_Signpost_Null:
	rts
; End of function ObjCapsule_Signpost_Null

; -------------------------------------------------------------------------

LoadFlowerCapsulePal:
	move.w	#7,d6
	lea	Pal_FlowerCapsule,a1
	lea	palette+$20.w,a2

.Load:
	move.l	(a1)+,(a2)+
	dbf	d6,.Load
	rts
; End of function LoadFlowerCapsulePal

; -------------------------------------------------------------------------
Pal_FlowerCapsule:
	incbin	"level/r1/objects/flowercapsule/palette.bin"
	even
Ani_BigRingFlash:
	include	"level/r1/objects/bigring/animflash.asm"
	even
MapSpr_BigRingFlash:
	include	"level/r1/objects/bigring/mapflash.asm"
	even
ArtNem_BigRingFlash:
	incbin	"level/r1/objects/bigring/artflash.bin"
	even
; -------------------------------------------------------------------------

Obj3DPlant:
	lea	objPlayerSlot.w,a6
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	Obj3DPlant_Index(pc,d0.w),d0
	jsr	Obj3DPlant_Index(pc,d0.w)
	jsr	DrawObject
	move.w	oVar2A(a0),d0
	bra.w	CheckObjDespawn2Time
; End of function Obj3DPlant

; -------------------------------------------------------------------------
Obj3DPlant_Index:dc.w	Obj3DPlant_Init-Obj3DPlant_Index
	dc.w	Obj3DPlant_Main-Obj3DPlant_Index
; -------------------------------------------------------------------------

Obj3DPlant_Init:
	ori.b	#4,oRender(a0)
	move.l	#MapSpr_3DPlant,oMap(a0)
	move.w	#$4424,oTile(a0)
	move.b	#$18,oWidth(a0)
	move.b	#$14,oYRadius(a0)
	move.w	oX(a0),d3
	movea.l	a0,a1
	moveq	#3,d6
	bclr	#0,oSubtype(a0)
	beq.s	.GotCount
	moveq	#1,d6

.GotCount:
	moveq	#0,d2
	bra.s	.Init

; -------------------------------------------------------------------------

.Loop:
	jsr	FindObjSlot

.Init:
	addq.b	#2,oRoutine(a1)
	move.b	#$2C,oID(a1)
	move.w	d3,oX(a1)
	move.w	oY(a0),oY(a1)
	move.w	d3,oVar2A(a1)
	move.l	oMap(a0),oMap(a1)
	move.w	oTile(a0),oTile(a1)
	move.b	oWidth(a0),oWidth(a1)
	move.b	oYRadius(a0),oYRadius(a1)
	ori.b	#4,oRender(a1)
	move.w	Obj3DPlant_Offsets1(pc,d2.w),d1
	add.w	d1,oX(a1)
	move.w	oX(a1),oVar2C(a1)
	addq.b	#2,d2
	dbf	d6,.Loop

	moveq	#2,d6
	moveq	#0,d2

.Loop2:
	jsr	FindObjSlot
	addq.b	#2,oRoutine(a1)
	move.b	#$2C,oID(a1)
	move.b	#1,oSubtype(a1)
	move.b	#1,oMapFrame(a1)
	move.b	#4,oPriority(a1)
	move.w	d3,oX(a1)
	move.w	d3,oVar2A(a1)
	move.w	oY(a0),oY(a1)
	move.l	oMap(a0),oMap(a1)
	move.w	oTile(a0),oTile(a1)
	move.b	#$C,oWidth(a1)
	move.b	#$C,oYRadius(a1)
	ori.b	#4,oRender(a1)
	move.w	Obj3DPlant_Offsets2(pc,d2.w),d1
	add.w	d1,oX(a1)
	addq.b	#2,d2
	dbf	d6,.Loop2
	rts
; End of function Obj3DPlant_Init

; -------------------------------------------------------------------------
Obj3DPlant_Offsets1:dc.w	$40, $80, $FFC0, $FF80
Obj3DPlant_Offsets2:dc.w	0, $60, $FFA0
; -------------------------------------------------------------------------

Obj3DPlant_Main:
	tst.b	oSubtype(a0)
	bne.s	.End
	moveq	#0,d0
	btst	#1,oVar2C(a6)
	beq.s	.MovePlant
	moveq	#0,d3
	move.w	oX(a6),d0
	move.w	d0,d2
	andi.w	#$FF,d0
	cmp.w	oVar2A(a0),d2
	bcc.s	.GetChunkPos
	move.w	d0,d1
	move.w	#$FF,d0
	sub.w	d1,d0

.GetChunkPos:
	cmpi.w	#$C0,d0
	bcs.s	.GotChunkPos
	cmpi.w	#$F0,d0
	bcc.s	.CapChunkPos
	move.w	#$BF,d0
	bra.s	.GotChunkPos

; -------------------------------------------------------------------------

.CapChunkPos:
	moveq	#0,d0

.GotChunkPos:
	lsr.w	#1,d0
	cmp.w	oVar2A(a0),d2
	bcc.s	.MovePlant
	neg.w	d0

.MovePlant:
	add.w	oVar2C(a0),d0
	move.w	d0,oX(a0)

.End:
	rts
; End of function Obj3DPlant_Main

; -------------------------------------------------------------------------

Obj3DFall:
	move.w	Obj3DFall_Index(pc,d0.w),d0
	jsr	Obj3DFall_Index(pc,d0.w)
	bra.w	CheckObjDespawnTime
; End of function Obj3DFall

; -------------------------------------------------------------------------
Obj3DFall_Index:dc.w	Obj3DFall_Init-Obj3DFall_Index
	dc.w	Obj3DFall_Main-Obj3DFall_Index
; -------------------------------------------------------------------------

Obj3DFall_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oRender(a0)
; End of function Obj3DFall_Init

; -------------------------------------------------------------------------

Obj3DFall_Main:
	cmpi.b	#$2B,oAnim(a6)
	beq.w	.End
	move.w	oY(a0),d0
	sub.w	oY(a6),d0
	addi.w	#$40,d0
	cmpi.w	#$80,d0
	bcc.s	.End
	move.w	oX(a0),d0
	sub.w	oX(a6),d0
	addi.w	#$20,d0
	cmpi.w	#$40,d0
	bcc.s	.End
	move.w	oX(a0),d0
	move.w	oXVel(a6),d1
	tst.w	d1
	bpl.s	.End
	cmp.w	oX(a6),d0
	bcs.s	.End
	move.w	d0,oX(a6)
	move.w	#0,oXVel(a6)
	move.w	#0,oPlayerGVel(a6)
	move.b	#$37,oAnim(a6)
	move.b	#1,oPlayerJump(a6)
	clr.b	oPlayerStick(a6)
	move.b	#$E,oYRadius(a0)
	move.b	#7,oXRadius(a0)
	addq.w	#5,oY(a0)
	bset	#2,oStatus(a6)

.End:
	rts
; End of function Obj3DFall_Main

; -------------------------------------------------------------------------

Obj3DRamp:
	lea	objPlayerSlot.w,a6
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	tst.b	oSubtype2(a0)
	bne.w	Obj3DFall
	move.w	Obj3DRamp_Index(pc,d0.w),d0
	jsr	Obj3DRamp_Index(pc,d0.w)
	jsr	DrawObject
	move.w	oVar2A(a0),d0
	bra.w	CheckObjDespawn2Time
; End of function Obj3DRamp

; -------------------------------------------------------------------------
Obj3DRamp_Index:dc.w	Obj3DRamp_Init-Obj3DRamp_Index
	dc.w	Obj3DRamp_Main-Obj3DRamp_Index
; -------------------------------------------------------------------------

Obj3DRamp_Init:
	addq.b	#2,oRoutine(a0)
	move.b	#4,oRender(a0)
	move.b	#1,oPriority(a0)
	move.l	#MapSpr_3DRamp,oMap(a0)
	move.w	#$441,oTile(a0)
	move.b	#$20,oWidth(a0)
	move.b	#$20,oYRadius(a0)
	move.w	oX(a0),oVar2A(a0)
	tst.b	oSubtype(a0)
	beq.s	Obj3DRamp_Main
	bset	#0,oRender(a0)
	bset	#0,oStatus(a0)
; End of function Obj3DRamp_Init

; -------------------------------------------------------------------------

Obj3DRamp_Main:
	tst.b	oVar2E(a0)
	beq.s	.TimeRunSet
	move.b	#1,oAnim(a0)
	btst	#1,oPlayerCtrl(a6)
	bne.s	.Animate
	addq.b	#1,oAnim(a0)

.Animate:
	lea	Ani_3DRamp,a1
	jsr	AnimateObject
	bra.s	.GetChunkPos

; -------------------------------------------------------------------------

.TimeRunSet:
	move.b	#0,oMapFrame(a0)
	moveq	#0,d1
	btst	#1,oPlayerCtrl(a6)
	beq.s	.Move3D

.GetChunkPos:
	move.w	oX(a6),d0
	andi.w	#$FF,d0
	tst.b	oSubtype(a0)
	beq.s	.NoFlip
	move.w	d0,d1
	move.w	#$FF,d0
	sub.w	d1,d0

.NoFlip:
	cmpi.w	#$C0,d0
	bcs.s	.GotChunkPos
	cmpi.w	#$F0,d0
	bcc.s	.CapChunkPos
	move.w	#$BF,d0
	bra.s	.GotChunkPos

; -------------------------------------------------------------------------

.CapChunkPos:
	moveq	#0,d0

.GotChunkPos:
	ext.l	d0
	move.w	d0,d1
	tst.b	oVar2E(a0)
	bne.s	.KeepFrame
	divu.w	#$30,d0
	move.b	d0,oMapFrame(a0)

.KeepFrame:
	lsr.w	#2,d1
	move.w	d1,d2
	lsr.w	#1,d2
	add.w	d2,d1
	tst.b	oSubtype(a0)
	beq.s	.Move3D
	neg.w	d1

.Move3D:
	add.w	oVar2A(a0),d1
	move.w	d1,oX(a0)
	tst.b	oVar2E(a0)
	beq.s	.SkipTimer
	subq.b	#1,oVar2E(a0)
	bra.s	.ChkTouch

; -------------------------------------------------------------------------

.SkipTimer:
	btst	#1,oStatus(a6)
	bne.s	.End

.ChkTouch:
	move.b	oWidth(a0),d1
	ext.w	d1
	move.w	oX(a6),d0
	sub.w	oX(a0),d0
	add.w	d1,d0
	bmi.s	.End
	add.w	d1,d1
	cmp.w	d1,d0
	bcc.s	.End
	move.b	oYRadius(a0),d1
	ext.w	d1
	move.w	oY(a6),d0
	sub.w	oY(a0),d0
	add.w	d1,d0
	bmi.s	.End
	add.w	d1,d1
	cmp.w	d1,d0
	bcc.s	.End
	cmpi.b	#$2B,oAnim(a6)
	beq.s	.End
	tst.b	oVar2E(a0)
	bne.s	.TimerSet
	move.b	#60,oVar2E(a0)

.TimerSet:
	tst.w	oYVel(a6)
	bpl.s	.LaunchDown
	move.w	#-$C00,oYVel(a6)
	rts

; -------------------------------------------------------------------------

.LaunchDown:
	move.w	#$C00,oYVel(a6)

.End:
	rts
; End of function Obj3DRamp_Main

; -------------------------------------------------------------------------
MapSpr_3DPlant:
	include	"level/r1/objects/3dplant/map.asm"
	even
Ani_3DRamp:
	include	"level/r1/objects/3dramp/anim.asm"
	even
; -------------------------------------------------------------------------

ObjRobotGenerator:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjRobotGenerator_Index(pc,d0.w),d0
	jsr	ObjRobotGenerator_Index(pc,d0.w)
	jsr	DrawObject
	cmpi.b	#2,oRoutine(a0)
	bgt.s	.End
	jmp	CheckObjDespawnTime

; -------------------------------------------------------------------------

.End:
	rts
; End of function ObjRobotGenerator

; -------------------------------------------------------------------------
ObjRobotGenerator_Index:dc.w	ObjRobotGenerator_Init-ObjRobotGenerator_Index
	dc.w	ObjRobotGenerator_Main-ObjRobotGenerator_Index
	dc.w	ObjRobotGenerator_Exploding-ObjRobotGenerator_Index
	dc.w	ObjRobotGenerator_BreakDown-ObjRobotGenerator_Index
; -------------------------------------------------------------------------

ObjRobotGenerator_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oRender(a0)
	move.b	#4,oPriority(a0)
	move.b	#$22,oXRadius(a0)
	move.b	#$22,oWidth(a0)
	move.b	#$20,oYRadius(a0)
	lea	ObjRobotGenerator_BaseTileList(pc),a1
	moveq	#0,d0
	move.b	levelAct,d0
	asl.w	#2,d0
	add.b	timeZone,d0
	add.w	d0,d0
	move.w	(a1,d0.w),oTile(a0)
	move.l	#MapSpr_RobotGenerator,oMap(a0)
	move.l	#ObjRobotGenerator_ExplosionLocs,oVar2C(a0)
	move.w	oY(a0),oVar30(a0)
	move.w	#4,oVar2A(a0)
	move.w	#1,oVar32(a0)
	moveq	#0,d0
	tst.b	goodFuture
	bne.s	.GoodFuture
	addq.b	#2,d0

.GoodFuture:
	tst.b	timeZone
	bne.s	.NotPast
	addq.b	#1,d0

.NotPast:
	move.b	d0,oMapFrame(a0)
	tst.b	goodFuture
	bne.s	ObjRobotGenerator_Main
	tst.b	timeZone
	bne.s	ObjRobotGenerator_Main
	move.b	#$FA,oColType(a0)
	subi.w	#$10,oY(a0)
; End of function ObjRobotGenerator_Init

; -------------------------------------------------------------------------

ObjRobotGenerator_Main:
	tst.b	goodFuture
	bne.s	.End2
	tst.b	timeZone
	bne.s	.End2
	bsr.w	ObjRobotGenerator_Float
	tst.b	oColStatus(a0)
	beq.s	.Solid
	clr.w	oColType(a0)
	clr.w	oVar2A(a0)
	move.b	#7,oMapFrame(a0)
	addq.b	#2,oRoutine(a0)
	move.b	#1,goodFuture
	move.l	#$96,d0
	jsr	AddPoints
	lea	objPlayerSlot.w,a1
	jsr	SolidObject
	beq.s	.End
	jsr	ClearObjRide

.End:
	rts

; -------------------------------------------------------------------------

.Solid:
	lea	objPlayerSlot.w,a1
	jsr	SolidObject
	lea	Ani_RobotGenerator(pc),a1
	jmp	AnimateObject

; -------------------------------------------------------------------------

.End2:
	rts
; End of function ObjRobotGenerator_Main

; -------------------------------------------------------------------------

ObjRobotGenerator_Exploding:
	movea.l	oVar2C(a0),a6
	move.b	(a6)+,d0
	bmi.s	.Finished
	addq.b	#1,oVar2A(a0)
	cmp.b	oVar2A(a0),d0
	bne.s	.End
	move.b	(a6)+,d5
	move.b	(a6)+,d6
	move.l	a6,oVar2C(a0)
	ext.w	d5
	ext.w	d6
	jsr	FindObjSlot
	bne.s	.End
	move.b	#$18,oID(a1)
	move.b	#1,oRoutine2(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	add.w	d5,oX(a1)
	add.w	d6,oY(a1)
	move.w	#$9E,d0
	jsr	PlayFMSound

.End:
	rts

; -------------------------------------------------------------------------

.Finished:
	addq.b	#2,oRoutine(a0)
	move.b	#8,oVar2A(a0)
	rts
; End of function ObjRobotGenerator_Exploding

; -------------------------------------------------------------------------

ObjRobotGenerator_BreakDown:
	subq.b	#1,oVar2A(a0)
	bne.s	.End
	subq.b	#6,oRoutine(a0)
	move.w	oVar30(a0),oY(a0)
	move.w	#$D9,d0
	jmp	PlayFMSound

; -------------------------------------------------------------------------

.End:
	rts
; End of function ObjRobotGenerator_BreakDown

; -------------------------------------------------------------------------

ObjRobotGenerator_Float:
	addq.w	#1,oVar2A(a0)
	move.w	oVar2A(a0),d0
	andi.w	#7,d0
	bne.s	.Stay
	move.w	oVar32(a0),d0
	add.w	d0,oY(a0)

.Stay:
	move.w	oVar2A(a0),d0
	andi.w	#$1F,d0
	bne.s	.End
	neg.w	oVar32(a0)

.End:
	rts
; End of function ObjRobotGenerator_Float

; -------------------------------------------------------------------------
Ani_RobotGenerator:
	include	"level/r1/objects/robotgenerator/anim.asm"
	even
MapSpr_RobotGenerator:
	include	"level/r1/objects/robotgenerator/map.asm"
	even
ObjRobotGenerator_ExplosionLocs:dc.b	1,	0, 0
	dc.b	2,	$D8, $EC
	dc.b	3,	$1C, $A
	dc.b	4,	$12, $EE
	dc.b	5,	$EE, $F6
	dc.b	6,	8, $F8
	dc.b	8,	$EE, $E
	dc.b	$A, $F6, $A
	dc.b	$C, $1E, $F6
	dc.b	$F, 0, $EE
	dc.b	$12, $14, $F6
	dc.b	$14, $F6, $12
	dc.b	$16, 8, $17
	dc.b	$19, $D, $F6
	dc.b	$1A, $17, $EA
	dc.b	$1C, $FD, $E7
	dc.b	$1E, $A, $14
	dc.b	$20, $F6, 2
	dc.b	$22, $1E, $F8
	dc.b	$23, $D, $F6
	dc.b	$28, $F6, $A
	dc.b	$FF
ObjRobotGenerator_BaseTileList:dc.w	$43F, $409,	0, 0
	dc.w	$454, $400, 0, 0
	dc.w	0,	0, 0
; -------------------------------------------------------------------------

ObjProjector:

; FUNCTION CHUNK AT 0020E510 SIZE 00000006 BYTES
; FUNCTION CHUNK AT 0020E6E8 SIZE 0000007A BYTES

	tst.b	oSubtype(a0)
	bne.w	ObjMetalSonicHologram
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjProjector_Index(pc,d0.w),d0
	jsr	ObjProjector_Index(pc,d0.w)
	jsr	DrawObject
	cmpi.b	#2,oRoutine(a0)
	bgt.s	.End
	jsr	CheckObjDespawnTime
	tst.b	(a0)
	bne.s	.End
	move.w	#4,d0
	jmp	LoadPLC

; -------------------------------------------------------------------------

.End:
	rts
; End of function ObjProjector

; -------------------------------------------------------------------------
ObjProjector_Index:dc.w	ObjProjector_Init-ObjProjector_Index
	dc.w	ObjProjector_Main-ObjProjector_Index
	dc.w	ObjProjector_StartExploding-ObjProjector_Index
	dc.w	ObjProjector_Exploding-ObjProjector_Index
	dc.w	ObjProjector_Destroyed-ObjProjector_Index

; -------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR ObjProjector

ObjProjector_Destroy:
	jmp	DeleteObject
; END OF FUNCTION CHUNK	FOR ObjProjector
; -------------------------------------------------------------------------

ObjProjector_Init:
	tst.b	projDestroyed
	bne.s	ObjProjector_Destroy
	move.w	#5,d0
	jsr	LoadPLC
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oRender(a0)
	move.b	#4,oPriority(a0)
	move.b	#$C,oXRadius(a0)
	move.b	#$C,oWidth(a0)
	move.b	#$C,oYRadius(a0)
	move.b	#$FB,oColType(a0)
	move.w	#$403,d0
	tst.b	levelAct
	beq.s	.SetBaseTile
	move.w	#$3AF,d0

.SetBaseTile:
	move.w	d0,oTile(a0)
	move.l	#MapSpr_Projector,oMap(a0)
	move.l	#ObjProjector_ExplosionLocs,oVar2C(a0)
	jsr	FindObjSlot
	bne.w	ObjProjector_Destroy
	move.b	oID(a0),oID(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	subi.w	#$15,oX(a1)
	subq.w	#7,oY(a1)
	move.b	#$FF,oSubtype(a1)
	move.w	a0,oVar3E(a1)
	jsr	FindObjSlot
	bne.w	ObjProjector_Destroy
	move.b	oID(a0),oID(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	subi.w	#$58,oX(a1)
	subq.w	#4,oY(a1)
	move.b	#1,oSubtype(a1)
	move.w	a0,oVar3E(a1)
	jsr	FindObjSlot
	bne.w	ObjProjector_Destroy
	move.b	#$24,oID(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	subi.w	#$58,oX(a1)
	addi.w	#-$18,oY(a1)
	move.b	#$80,oSubtype(a1)
	move.w	a0,oVar3E(a1)
	jsr	FindObjSlot
	bne.w	ObjProjector_Destroy
	move.b	#$24,oID(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	subi.w	#$64,oX(a1)
	addq.w	#4,oY(a1)
	move.b	#$81,oSubtype(a1)
	move.w	a0,oVar3E(a1)

ObjProjector_Main:
	tst.b	oColStatus(a0)
	beq.s	.Solid
	clr.w	oColType(a0)
	addq.b	#2,oRoutine(a0)

.Solid:
	lea	objPlayerSlot.w,a1
	jmp	SolidObject
; End of function ObjProjector_Init

; -------------------------------------------------------------------------

ObjProjector_StartExploding:
	addq.b	#2,oRoutine(a0)
	move.b	#1,oMapFrame(a0)
	st	oVar3F(a0)
	move.w	#4,d0
	jsr	LoadPLC
	lea	objPlayerSlot.w,a1
	jsr	SolidObject
	beq.s	ObjProjector_Exploding
	jsr	ClearObjRide

ObjProjector_Exploding:
	movea.l	oVar2C(a0),a6
	move.b	(a6)+,d0
	bmi.s	.Finished
	addq.b	#1,oVar2A(a0)
	cmp.b	oVar2A(a0),d0
	bne.s	.End
	move.b	(a6)+,d5
	move.b	(a6)+,d6
	move.l	a6,oVar2C(a0)
	ext.w	d5
	ext.w	d6
	jsr	FindObjSlot
	bne.s	.End
	move.b	#$18,oID(a1)
	move.b	#1,oRoutine2(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	add.w	d5,oX(a1)
	add.w	d6,oY(a1)
	move.w	#$9E,d0
	jsr	PlayFMSound

.End:
	rts

; -------------------------------------------------------------------------

.Finished:
	addq.b	#2,oRoutine(a0)
	move.w	#60,oVar2A(a0)
	rts
; End of function ObjProjector_StartExploding

; -------------------------------------------------------------------------

ObjProjector_Destroyed:
	subq.w	#1,$2A(a0)
	bne.s	locret_20E6E6
	st	projDestroyed
	bra.w	ObjProjector_Destroy

; -------------------------------------------------------------------------

locret_20E6E6:
	rts
; End of function ObjProjector_Destroyed

; -------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR ObjProjector

ObjMetalSonicHologram:
	movea.w	oVar3E(a0),a1
	cmpi.b	#$2E,oID(a1)
	bne.w	ObjProjector_Destroy
	tst.b	oVar3F(a1)
	bne.w	ObjProjector_Destroy
	tst.b	oRoutine(a0)
	bne.s	.Animate
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oRender(a0)
	move.b	#4,oPriority(a0)
	move.w	#$403,d0
	tst.b	levelAct
	beq.s	.SetBaseTile
	move.w	#$3AF,d0

.SetBaseTile:
	move.w	d0,oTile(a0)
	move.l	#MapSpr_Projector,oMap(a0)
	moveq	#8,d0
	moveq	#4,d1
	moveq	#0,d2
	tst.b	oSubtype(a0)
	bmi.s	.GotSize
	moveq	#$14,d0
	moveq	#$18,d1
	moveq	#1,d2

.GotSize:
	move.b	d0,oXRadius(a0)
	move.b	d0,oWidth(a0)
	move.b	d1,oYRadius(a0)
	move.b	d2,oAnim(a0)

.Animate:
	lea	Ani_MetalSonicHologram(pc),a1
	jsr	AnimateObject
	jmp	DrawObject
; END OF FUNCTION CHUNK	FOR ObjProjector

; -------------------------------------------------------------------------
Ani_MetalSonicHologram:
	include	"level/r1/objects/projector/anim.asm"
	even
MapSpr_Projector:
	include	"level/r1/objects/projector/map.asm"
	even
ObjProjector_ExplosionLocs:dc.b	1, 0, 0
	dc.b	5,	$EE, $F6
	dc.b	$A, $F6, $A
	dc.b	$F, 0, $EE
	dc.b	$14, $F6, $12
	dc.b	$16, 8, $17
	dc.b	$19, $D, $F6
	dc.b	$1C, $FD, $E7
	dc.b	$1E, $A, $14
	dc.b	$20, $F6, 2
	dc.b	$23, $D, $F6
	dc.b	$28, $F6, $A
	dc.b	$FF
	dc.b	0
; -------------------------------------------------------------------------

DestroyOnGoodFuture:
	tst.b	goodFuture
	beq.s	.End
	cmpi.b	#1,timeZone
	bne.s	.Destroy
	tst.b	oSubtype(a0)
	beq.s	.End

.Destroy:
	move.w	oX(a0),d5
	move.w	oY(a0),d6
	jsr	DeleteObject
	move.w	d5,oX(a0)
	move.w	d6,oY(a0)
	move.b	#$18,oID(a0)
	tst.b	oRender(a0)
	bpl.s	.NoReturn
	move.w	#$9E,d0
	jsr	PlayFMSound

.NoReturn:
	addq.l	#4,sp

.End:
	rts
; End of function DestroyOnGoodFuture

; -------------------------------------------------------------------------

CheckAnimalPrescence:
	tst.b	oSubtype(a0)
	bmi.s	.End
	cmpi.b	#2,timeZone
	bge.s	.ChkGoodFuture
	tst.b	projDestroyed
	bne.s	.End
	addq.l	#4,sp
	jmp	CheckObjDespawnTime

; -------------------------------------------------------------------------

.ChkGoodFuture:
	tst.b	goodFuture
	bne.s	.End
	addq.l	#4,sp
	jmp	DeleteObject

; -------------------------------------------------------------------------

.End:
	rts
; End of function CheckAnimalPrescence

; -------------------------------------------------------------------------

ObjAmyRose:
	tst.b	timeAttackMode
	bne.s	.ResetPal
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjAmyRose_Index(pc,d0.w),d0
	jsr	ObjAmyRose_Index(pc,d0.w)
	bsr.w	ObjAmyRose_MakeHearts
	jsr	DrawObject
	jsr	CheckObjDespawnTime
	cmpi.b	#$2F,0(a0)
	beq.s	.End

.ResetPal:
	lea	Pal_PPZPresentEnd,a3
	bsr.w	ObjAmyRose_ResetPal

.End:
	rts
; End of function ObjAmyRose

; -------------------------------------------------------------------------
ObjAmyRose_Index:dc.w	ObjAmyRose_Init-ObjAmyRose_Index
	dc.w	ObjAmyRose_Main-ObjAmyRose_Index
	dc.w	ObjAmyRose_HoldSonic-ObjAmyRose_Index
	dc.w	ObjAmyRose_FollowSonic-ObjAmyRose_Index
	dc.w	ObjAmyRose_WaitLand-ObjAmyRose_Index
; -------------------------------------------------------------------------

ObjAmyRose_Init:

; FUNCTION CHUNK AT 0020EDA0 SIZE 00000062 BYTES

	ori.b	#4,oRender(a0)
	move.w	#$2370,oTile(a0)
	move.b	#1,oPriority(a0)
	move.l	#MapSpr_AmyRose,oMap(a0)
	move.b	#$C,oWidth(a0)
	move.b	#$10,oYRadius(a0)
	move.w	oX(a0),oVar36(a0)
	bsr.w	ObjAmyRose_LoadPal

.PlaceLoop:
	jsr	CheckFloorEdge
	tst.w	d1
	beq.s	.FoundFloor
	add.w	d1,$C(a0)
	bra.w	.PlaceLoop

; -------------------------------------------------------------------------

.FoundFloor:
	lea	objPlayerSlot.w,a1
	bsr.w	ObjAmyRose_SetFacing
	move.w	oX(a1),d0
	sub.w	oX(a0),d0
	bcc.s	.ChkRange
	neg.w	d0

.ChkRange:
	cmpi.w	#$70,d0
	bcc.s	.Animate
	addq.b	#2,oRoutine(a0)

.Animate:
	move.b	#5,oAnim(a0)
	lea	Ani_AmyRose,a1
	bra.w	AnimateObjSimple
; End of function ObjAmyRose_Init

; -------------------------------------------------------------------------

ObjAmyRose_Main:
	lea	objPlayerSlot.w,a1
	bsr.w	ObjAmyRose_SetFacing
	btst	#6,oVar3E(a0)
	bne.w	.WallBump
	btst	#2,oVar3E(a0)
	bne.w	.GetDX2
	tst.w	oXVel(a1)
	bne.s	.GetAccel
	move.w	oX(a1),d0
	sub.w	oX(a0),d0
	bcc.s	.GetDX
	neg.w	d0

.GetDX:
	cmpi.w	#$A,d0
	bcc.s	.GetAccel

.InRange:
	bset	#2,oVar3E(a0)
	clr.w	oXVel(a0)
	bra.w	.ChkFloor2

; -------------------------------------------------------------------------

.GetDX2:
	move.w	oX(a1),d0
	sub.w	oX(a0),d0
	bcc.s	.AbsDX
	neg.w	d0

.AbsDX:
	cmpi.w	#$20,d0
	bcs.s	.InRange
	bclr	#2,oVar3E(a0)

.GetAccel:
	move.w	#-$10,d0
	btst	#0,oStatus(a0)
	bne.s	.NoFlip
	neg.w	d0

.NoFlip:
	add.w	oXVel(a0),d0
	move.w	d0,d1
	move.w	#$200,d2
	tst.w	d1
	bpl.s	.ChkCap
	neg.w	d1
	neg.w	d2

.ChkCap:
	cmpi.w	#$200,d1
	bcs.s	.SetVX
	move.w	d2,d0

.SetVX:
	move.w	d0,oXVel(a0)
	tst.w	oXVel(a0)
	bpl.s	.NoFlip2
	move.w	oVar36(a0),d0
	subi.w	#$130,d0
	cmp.w	oX(a0),d0
	bcs.s	.ChkFloor
	bra.w	.WallBump

; -------------------------------------------------------------------------

.NoFlip2:
	move.w	oVar36(a0),d0
	addi.w	#$90,d0
	cmp.w	oX(a0),d0
	bcc.s	.ChkFloor
	bra.w	.WallBump

; -------------------------------------------------------------------------

.ChkFloor:
	jsr	CheckFloorEdge
	cmpi.w	#7,d1
	bpl.s	.WallBump
	cmpi.w	#-7,d1
	bmi.s	.WallBump
	add.w	d1,oY(a0)
	bsr.w	ObjectMoveX
	bsr.w	ObjAmyRose_CheckGrabSonic
	move.b	#2,oAnim(a0)
	lea	Ani_AmyRose,a1
	bra.w	AnimateObjSimple

; -------------------------------------------------------------------------

.WallBump:
	clr.w	oXVel(a0)
	btst	#7,oVar3E(a0)
	bne.s	.ChkIfJump

.ChkFloor2:
	jsr	CheckFloorEdge
	add.w	d1,oY(a0)
	move.b	#1,oAnim(a0)
	lea	Ani_AmyRose,a1
	bra.w	AnimateObjSimple

; -------------------------------------------------------------------------

.ChkIfJump:
	btst	#6,oVar3E(a0)
	bne.s	.MoveFall
	cmpi.b	#3,oVar3F(a0)
	bcs.s	.Jump
	addq.b	#4,oVar3A(a0)
	bcc.s	.Animate
	clr.b	oVar3F(a0)

.Animate:
	move.b	#4,oAnim(a0)
	lea	Ani_AmyRose,a1
	bra.w	AnimateObjSimple

; -------------------------------------------------------------------------

.Jump:
	move.w	#-$300,oYVel(a0)
	bset	#6,oVar3E(a0)

.MoveFall:
	bsr.w	ObjectMoveY
	addi.w	#$40,oYVel(a0)
	move.b	#6,oMapFrame(a0)
	tst.w	oYVel(a0)
	bmi.s	.GoingUp
	move.b	#4,oMapFrame(a0)

.GoingUp:
	jsr	CheckFloorEdge
	tst.w	d1
	bpl.s	.End
	clr.w	oYVel(a0)
	bclr	#6,oVar3E(a0)
	addq.b	#1,oVar3F(a0)

.End:
	rts
; End of function ObjAmyRose_Main

; -------------------------------------------------------------------------

ObjAmyRose_HoldSonic:
	lea	objPlayerSlot.w,a1
	bset	#0,oPlayerCtrl(a1)
	move.b	#5,oAnim(a1)
	bsr.w	ObjAmyRose_SlowSonic
	bsr.w	ObjAmyRose_SetFacing
	moveq	#$C,d0
	btst	#0,oStatus(a1)
	bne.s	.NoFlip
	neg.w	d0

.NoFlip:
	add.w	oX(a1),d0
	move.w	d0,oX(a0)
	move.w	oY(a1),oY(a0)
	move.w	p1CtrlData.w,playerCtrl.w
	bsr.w	Player_Jump
	btst	#0,oPlayerCtrl(a1)
	beq.s	.PlayerJumped
	cmpi.l	#$93200,levelTime
	bcc.s	.ForceJump
	move.b	#3,oAnim(a0)
	lea	Ani_AmyRose,a1
	bra.w	AnimateObjSimple

; -------------------------------------------------------------------------

.PlayerJumped:
	bclr	#0,oVar3E(a0)
	move.b	#6,oRoutine(a0)
	rts

; -------------------------------------------------------------------------

.ForceJump:
	bsr.w	Player_Jump2
	bclr	#0,oVar3E(a0)
	move.b	#2,oRoutine(a0)
	rts
; End of function ObjAmyRose_HoldSonic

; -------------------------------------------------------------------------

ObjAmyRose_FollowSonic:
	move.b	#6,oMapFrame(a0)
	move.w	#$80,d0
	btst	#0,oStatus(a0)
	bne.s	.NoFlip
	neg.w	d0

.NoFlip:
	move.w	d0,oXVel(a0)
	move.w	oX(a0),d0
	sub.w	oVar36(a0),d0
	bcc.s	.ChkRange
	neg.w	d0

.ChkRange:
	cmpi.w	#$80,d0
	bcs.s	.Jump
	clr.w	oXVel(a0)

.Jump:
	move.w	#-$300,oYVel(a0)
	addq.b	#2,oRoutine(a0)
; End of function ObjAmyRose_FollowSonic

; -------------------------------------------------------------------------

ObjAmyRose_WaitLand:
	bsr.w	ObjectMove
	addi.w	#$40,oYVel(a0)
	tst.w	oYVel(a0)
	bmi.s	.ChkFloor
	move.b	#7,oMapFrame(a0)

.ChkFloor:
	jsr	CheckFloorEdge
	tst.w	d1
	bpl.s	.End
	clr.w	oXVel(a0)
	clr.w	oYVel(a0)
	addi.b	#$10,oVar3A(a0)
	bcc.s	.End
	move.b	#2,oRoutine(a0)

.End:
	rts
; End of function ObjAmyRose_WaitLand

; -------------------------------------------------------------------------

ObjAmyRose_SlowSonic:
	tst.w	oXVel(a0)
	beq.s	.End
	movem.l	a0-a1,-(sp)
	exg	a0,a1
	bsr.w	ObjectMoveX
	jsr	CheckFloorEdge
	add.w	d1,oY(a0)
	movem.l	(sp)+,a0-a1
	tst.w	oXVel(a1)
	bmi.s	.Decel
	subi.w	#$40,oXVel(a1)
	bpl.s	.End
	bra.s	.StopSonic

; -------------------------------------------------------------------------

.Decel:
	addi.w	#$40,oXVel(a1)
	bmi.s	.End

.StopSonic:
	clr.w	oXVel(a1)

.End:
	rts
; End of function ObjAmyRose_SlowSonic

; -------------------------------------------------------------------------

Player_Jump:
	move.b	playerCtrlTap.w,d0
	andi.b	#$70,d0
	beq.w	Player_Jump_Done
; End of function Player_Jump

; -------------------------------------------------------------------------

Player_Jump2:
	clr.b	oPlayerCtrl(a1)
	move.w	#$680,d2
	moveq	#0,d0
	move.b	oAngle(a1),d0
	subi.b	#$40,d0
	jsr	CalcSine
	muls.w	d2,d1
	asr.l	#8,d1
	add.w	d1,oXVel(a1)
	muls.w	d2,d0
	asr.l	#8,d0
	add.w	d0,oYVel(a1)
	bset	#1,oStatus(a1)
	bclr	#5,oStatus(a1)
	move.b	#1,oPlayerJump(a1)
	clr.b	oPlayerStick(a1)
	move.b	#$13,oYRadius(a1)
	move.b	#9,oXRadius(a1)
	btst	#2,oStatus(a1)
	bne.s	Player_Jump_RollJmp
	move.b	#$E,oYRadius(a1)
	move.b	#7,oXRadius(a1)
	addq.w	#5,oY(a1)
	bset	#2,oStatus(a1)
	move.b	#2,oAnim(a1)

Player_Jump_Done:
	rts

; -------------------------------------------------------------------------

Player_Jump_RollJmp:
	bset	#4,oStatus(a1)
	rts
; End of function Player_Jump2

; -------------------------------------------------------------------------

ObjAmyRose_CheckGrabSonic:
	tst.w	oXVel(a0)
	bpl.s	.GoingRight
	move.w	oVar36(a0),d0
	subi.w	#$130,d0
	cmp.w	oX(a0),d0
	bcs.s	.ChkRange
	bra.w	.End

; -------------------------------------------------------------------------

.GoingRight:
	move.w	oVar36(a0),d0
	addi.w	#$90,d0
	cmp.w	oX(a0),d0
	bcc.s	.ChkRange
	bra.w	.End

; -------------------------------------------------------------------------

.ChkRange:
	cmpi.l	#$93200,levelTime
	bcc.w	.End
	lea	objPlayerSlot.w,a1
	tst.b	lvlDebugMode
	bne.w	.End
	btst	#0,oStatus(a1)
	bne.s	.GetDX
	move.w	oX(a1),d0
	sub.w	oX(a0),d0
	bra.s	.GotDX

; -------------------------------------------------------------------------

.GetDX:
	move.w	oX(a0),d0
	sub.w	oX(a1),d0

.GotDX:
	bcs.w	.End
	cmpi.w	#$C,d0
	bcs.w	.End
	cmpi.w	#$18,d0
	bcc.s	.End
	moveq	#8,d1
	move.w	oY(a1),d0
	sub.w	oY(a0),d0
	add.w	d1,d0
	bmi.s	.End
	move.w	d1,d2
	add.w	d2,d2
	cmp.w	d2,d0
	bcc.s	.End
	move.w	oXVel(a1),d0
	bpl.s	.AbsVX
	neg.w	d0

.AbsVX:
	btst	#1,oStatus(a1)
	bne.s	.NoGrab
	btst	#2,oStatus(a1)
	bne.s	.NoGrab
	tst.b	oPlayerHurt(a1)
	bne.s	.NoGrab
	cmpi.w	#$680,d0
	bcc.s	.NoGrab
	tst.b	shieldFlag
	bne.s	.NoGrab
	tst.b	timeWarpFlag
	bne.s	.NoGrab
	tst.b	invincibleFlag
	bne.s	.NoGrab
	bclr	#2,oStatus(a1)
	ori.b	#$81,oVar3E(a0)
	clr.w	oYVel(a0)
	clr.w	oXVel(a0)
	move.b	#7,oMapFrame(a0)
	move.b	#4,oRoutine(a0)
	move.w	#$7C,d0
	jsr	SubCPUCmd

.End:
	rts

; -------------------------------------------------------------------------

.NoGrab:
	move.b	#6,oRoutine(a0)
	rts
; End of function ObjAmyRose_CheckGrabSonic

; -------------------------------------------------------------------------

CheckPlayerRange1:
	lea	objPlayerSlot.w,a1
	move.w	oX(a0),d0
	sub.w	oX(a1),d0
	bcc.s	.AbsDX
	neg.w	d0

.AbsDX:
	cmpi.w	#52,d0
	rts
; End of function CheckPlayerRange1

; -------------------------------------------------------------------------

CheckPlayerRange2:
	lea	objPlayerSlot.w,a1
	move.w	oX(a0),d0
	sub.w	oX(a1),d0
	bcc.s	.AbsDX
	neg.w	d0

.AbsDX:
	cmpi.w	#124,d0
	rts
; End of function CheckPlayerRange2

; -------------------------------------------------------------------------

ObjectMove:
	bsr.s	ObjectMoveX
; End of function ObjectMove

; -------------------------------------------------------------------------

ObjectMoveY:
	move.w	oYVel(a0),d0
	ext.l	d0
	asl.l	#8,d0
	add.l	d0,oY(a0)
	rts
; End of function ObjectMoveY

; -------------------------------------------------------------------------

ObjectMoveX:
	move.w	oXVel(a0),d0
	ext.l	d0
	asl.l	#8,d0
	add.l	d0,oX(a0)
	rts
; End of function ObjectMoveX

; -------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR ObjAmyRose_Init

AnimateObjSimple:
	moveq	#0,d0
	move.b	oAnim(a0),d0
	cmp.b	oPrevAnim(a0),d0
	beq.s	.run
	move.b	d0,oPrevAnim(a0)
	clr.b	oAnimFrame(a0)
	clr.b	oAnimTime(a0)

.run:
	subq.b	#1,oAnimTime(a0)
	bpl.s	.End
	add.w	d0,d0
	adda.w	(a1,d0.w),a1

.Next:
	move.b	oAnimFrame(a0),d0
	lea	(a1,d0.w),a2
	move.b	(a2),d0
	bpl.s	.SetFrame
	clr.b	oAnimFrame(a0)
	bra.s	.Next

; -------------------------------------------------------------------------

.SetFrame:
	move.b	d0,d1
	andi.b	#$1F,d0
	move.b	d0,oMapFrame(a0)
	move.b	oStatus(a0),d0
	rol.b	#3,d1
	eor.b	d0,d1
	andi.b	#3,d1
	andi.b	#$FC,oRender(a0)
	or.b	d1,oRender(a0)
	move.b	oRender(a2),oAnimTime(a0)
	addq.b	#2,oAnimFrame(a0)

.End:
	rts
; END OF FUNCTION CHUNK	FOR ObjAmyRose_Init
; -------------------------------------------------------------------------

ObjAmyRose_MakeHearts:
	moveq	#6,d0
	btst	#0,oVar3E(a0)
	beq.s	.ChkTimer
	moveq	#$10,d0

.ChkTimer:
	add.b	d0,oVar3B(a0)
	bcc.s	.End
	jsr	FindObjSlot
	bne.s	.End
	move.b	#$30,oID(a1)
	moveq	#8,d1
	btst	#0,oStatus(a0)
	beq.s	.NoFlip
	move.w	#-$A,d1

.NoFlip:
	btst	#0,oVar3E(a0)
	beq.s	.SetPos
	neg.w	d1

.SetPos:
	move.w	oX(a0),d0
	add.w	d1,d0
	move.w	d0,oX(a1)
	move.w	oY(a0),d0
	subi.w	#$C,d0
	move.w	d0,oY(a1)

.End:
	rts
; End of function ObjAmyRose_MakeHearts

; -------------------------------------------------------------------------

ObjAmyRose_SetFacing:
	bsr.s	ObjAmyRose_XUnflip
	move.w	oX(a0),d0
	sub.w	oX(a1),d0
	bcs.s	.End
	bsr.s	ObjAmyRose_XFlip

.End:
	rts
; End of function ObjAmyRose_SetFacing

; -------------------------------------------------------------------------

ObjAmyRose_XUnflip:
	bclr	#0,oStatus(a0)
	bclr	#0,oRender(a0)
	rts
; End of function ObjAmyRose_XUnflip

; -------------------------------------------------------------------------

ObjAmyRose_XFlip:
	bset	#0,oStatus(a0)
	bset	#0,oRender(a0)
	rts
; End of function ObjAmyRose_XFlip

; -------------------------------------------------------------------------

ObjAmyRose_LoadPal:
	lea	Pal_AmyRose(pc),a3
; End of function ObjAmyRose_LoadPal

; -------------------------------------------------------------------------

ObjAmyRose_ResetPal:
	lea	palette+$20.w,a4
	movem.l	(a3)+,d0-d3
	movem.l	d0-d3,(a4)
	movem.l	(a3)+,d0-d3
	movem.l	d0-d3,$10(a4)
	rts
; End of function ObjAmyRose_ResetPal

; -------------------------------------------------------------------------
Pal_AmyRose:	dc.w	0,	0, $628, $84A, $E6E, $EAE, $EEE, $AAA
	dc.w	$888, $444, $8AE, $6C, $C2, $80, $806, $E
; -------------------------------------------------------------------------

ObjAmyHeart:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjAmyHeart_Index(pc,d0.w),d0
	jsr	ObjAmyHeart_Index(pc,d0.w)
	jsr	DrawObject
	jmp	CheckObjDespawnTime
; End of function ObjAmyHeart

; -------------------------------------------------------------------------
ObjAmyHeart_Index:dc.w	ObjAmyHeart_Init-ObjAmyHeart_Index
	dc.w	ObjAmyHeart_Main-ObjAmyHeart_Index
; -------------------------------------------------------------------------

ObjAmyHeart_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oRender(a0)
	move.w	#$370,oTile(a0)
	move.l	#MapSpr_AmyRose,oMap(a0)
	move.b	#8,oMapFrame(a0)
	move.w	#-$60,oYVel(a0)
	move.b	#3,oPriority(a0)
; End of function ObjAmyHeart_Init

; -------------------------------------------------------------------------

ObjAmyHeart_Main:
	tst.b	oVar3C(a0)
	bne.s	.StopRipple
	moveq	#0,d0
	move.b	oVar3A(a0),d0
	add.b	d0,d0
	add.b	oVar3A(a0),d0
	jsr	CalcSine
	asr.w	#2,d0
	move.w	d0,oXVel(a0)

.StopRipple:
	bsr.w	ObjectMove
	addq.b	#1,oVar3A(a0)
	move.b	oVar3A(a0),d0
	cmpi.b	#$14,d0
	bne.s	.ChkTimer
	addq.b	#1,oMapFrame(a0)

.ChkTimer:
	cmpi.b	#$6E,d0
	bne.s	.ChkDel
	addq.b	#1,oMapFrame(a0)
	clr.w	oYVel(a0)
	clr.w	oXVel(a0)
	st	oVar3C(a0)

.ChkDel:
	cmpi.b	#$78,d0
	bne.s	.End
	jmp	DeleteObject

; -------------------------------------------------------------------------

.End:
	rts
; End of function ObjAmyHeart_Main

; -------------------------------------------------------------------------

ObjGameOver:
	moveq	#0,d0
	move.b	$24(a0),d0
	move.w	ObjGameOver_Index(pc,d0.w),d0
	jmp	ObjGameOver_Index(pc,d0.w)
; End of function ObjGameOver

; -------------------------------------------------------------------------
ObjGameOver_Index:dc.w	ObjGameOver_Init-ObjGameOver_Index
	dc.w	ObjGameOver_Main-ObjGameOver_Index
; -------------------------------------------------------------------------

ObjGameOver_Init:
	move.w	#$82,d0
	jsr	SubCPUCmd
	addq.b	#2,oRoutine(a0)
	move.w	#$E0,oYScr(a0)
	move.w	#$80,oX(a0)
	move.w	#$120,oVar2A(a0)
	move.w	#$8544,oTile(a0)
	move.l	#MapSpr_GameOver1,oMap(a0)
	move.b	#8,lvlLoadShieldArt
	bclr	#0,lvlTimeOver
	beq.s	.NotTimeOver
	tst.b	lifeCount
	beq.s	.GameOver
	move.l	#MapSpr_GameOver2,4(a0)
	addq.b	#2,lvlLoadShieldArt
	bra.s	.GameOver

; -------------------------------------------------------------------------

.NotTimeOver:
	tst.b	lifeCount
	bne.s	.Destroy

.GameOver:
	bset	#7,lvlLoadShieldArt
	jsr	FindObjSlot
	beq.s	.LoadAuxObj

.Destroy:
	jmp	DeleteObject

; -------------------------------------------------------------------------

.LoadAuxObj:
	move.b	#$3B,oID(a1)
	move.b	oRoutine(a0),oRoutine(a1)
	move.w	oTile(a0),oTile(a1)
	move.l	oMap(a0),oMap(a1)
	move.b	#1,oMapFrame(a1)
	move.w	#$E0,oYScr(a1)
	move.w	#$1C0,oX(a1)
	move.w	#$120,oVar2A(a1)
	tst.b	lifeCount
	bne.s	ObjGameOver_Main
	move.w	#$6E,d0
	jmp	SubCPUCmd
; End of function ObjGameOver_Init

; -------------------------------------------------------------------------

ObjGameOver_Main:
	moveq	#8,d0
	move.w	oVar2A(a0),d1
	cmp.w	oX(a0),d1
	beq.s	.Display
	bge.s	.MoveToDest
	neg.w	d0

.MoveToDest:
	add.w	d0,oX(a0)

.Display:
	jmp	DrawObject
; End of function ObjGameOver_Main

; -------------------------------------------------------------------------
	include	"level/r1/objects/gameover/map.asm"
	even
; -------------------------------------------------------------------------

ObjTitleCard:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjTitleCard_Index(pc,d0.w),d0
	jmp	ObjTitleCard_Index(pc,d0.w)
; End of function ObjTitleCard

; -------------------------------------------------------------------------
ObjTitleCard_Index:dc.w	ObjTitleCard_Init-ObjTitleCard_Index
	dc.w	ObjTitleCard_SlideInVert-ObjTitleCard_Index
	dc.w	ObjTitleCard_SlideInHoriz-ObjTitleCard_Index
	dc.w	ObjTitleCard_SlideOutVert-ObjTitleCard_Index
	dc.w	ObjTitleCard_SlideOutHoriz-ObjTitleCard_Index
	dc.w	ObjTitleCard_WaitPLC-ObjTitleCard_Index
; -------------------------------------------------------------------------

ObjTitleCard_Init:
	move.b	#2,oRoutine(a0)
	move.w	#$118,oX(a0)
	move.w	#$30,oYScr(a0)
	move.w	#$30,oVar30(a0)
	move.w	#$F0,oVar2E(a0)
	move.b	#$5A,oAnimTime(a0)
	move.w	#$8360,oTile(a0)
	move.l	#MapSpr_TitleCard,oMap(a0)
	move.b	#4,oPriority(a0)
	moveq	#0,d1
	moveq	#7,d6
	lea	ObjTitleCard_Data,a2

.Loop:
	jsr	FindObjSlot
	move.b	#$3C,oID(a1)
	move.b	#4,oRoutine(a1)
	move.w	#$8360,oTile(a1)
	move.l	#MapSpr_TitleCard,4(a1)
	move.w	d1,d2
	lsl.w	#3,d2
	move.w	(a2,d2.w),oYScr(a1)
	move.w	2(a2,d2.w),oX(a1)
	move.w	2(a2,d2.w),oVar2C(a1)
	move.w	4(a2,d2.w),oVar2A(a1)
	move.b	6(a2,d2.w),oMapFrame(a1)
	cmpi.b	#5,d1
	bne.s	.NotActNum
	move.b	levelAct,d3
	add.b	d3,oMapFrame(a1)

.NotActNum:
	move.b	7(a2,d2.w),oAnimTime(a1)
	addq.b	#1,d1
	dbf	d6,.Loop
	rts
; End of function ObjTitleCard_Init

; -------------------------------------------------------------------------

ObjTitleCard_SlideInVert:
	moveq	#8,d0
	move.w	oVar2E(a0),d1
	cmp.w	oYScr(a0),d1
	beq.s	.DidSlide
	bge.s	.DoYSlide
	neg.w	d0

.DoYSlide:
	add.w	d0,oYScr(a0)
	jmp	DrawObject

; -------------------------------------------------------------------------

.DidSlide:
	addq.b	#4,oRoutine(a0)
	jmp	DrawObject
; End of function ObjTitleCard_SlideInVert

; -------------------------------------------------------------------------

ObjTitleCard_SlideInHoriz:
	moveq	#8,d0
	move.w	oVar2A(a0),d1
	cmp.w	oX(a0),d1
	beq.s	.DidSlide
	bge.s	.DoXSlide
	neg.w	d0

.DoXSlide:
	add.w	d0,oX(a0)
	jmp	DrawObject

; -------------------------------------------------------------------------

.DidSlide:
	addq.b	#4,oRoutine(a0)
	jmp	DrawObject
; End of function ObjTitleCard_SlideInHoriz

; -------------------------------------------------------------------------

ObjTitleCard_SlideOutVert:
	tst.b	oAnimTime(a0)
	beq.s	.SlideOut
	subq.b	#1,oAnimTime(a0)
	jmp	DrawObject

; -------------------------------------------------------------------------

.SlideOut:
	moveq	#$10,d0
	move.w	oVar30(a0),d1
	cmp.w	oYScr(a0),d1
	beq.s	.DidSlide
	bge.s	.DoYSlide
	neg.w	d0

.DoYSlide:
	add.w	d0,oYScr(a0)
	jmp	DrawObject

; -------------------------------------------------------------------------

.DidSlide:
	addq.b	#4,oRoutine(a0)
	move.b	#1,scrollLock.w
	moveq	#2,d0
	jmp	LoadPLC
; End of function ObjTitleCard_SlideOutVert

; -------------------------------------------------------------------------

ObjTitleCard_SlideOutHoriz:
	tst.b	oAnimTime(a0)
	beq.s	.SlideOut
	subq.b	#1,oAnimTime(a0)
	jmp	DrawObject

; -------------------------------------------------------------------------

.SlideOut:
	moveq	#$10,d0
	move.w	oVar2C(a0),d1
	cmp.w	oX(a0),d1
	beq.s	.DidSlide
	bge.s	.DoXSlide
	neg.w	d0

.DoXSlide:
	add.w	d0,oX(a0)
	jmp	DrawObject

; -------------------------------------------------------------------------

.DidSlide:
	jmp	DeleteObject
; End of function ObjTitleCard_SlideOutHoriz

; -------------------------------------------------------------------------

ObjTitleCard_WaitPLC:
	tst.l	plcBuffer.w
	bne.s	.End
	clr.b	scrollLock.w
	clr.b	ctrlLocked.w
	jmp	DeleteObject

; -------------------------------------------------------------------------

.End:
	rts
; End of function ObjTitleCard_WaitPLC

; -------------------------------------------------------------------------

ObjResults:
	moveq	#0,d0
	move.b	$24(a0),d0
	move.w	ObjResults_Index(pc,d0.w),d0
	jmp	ObjResults_Index(pc,d0.w)
; End of function ObjResults

; -------------------------------------------------------------------------
ObjResults_Index:dc.w	ObjResults_Init-ObjResults_Index
	dc.w	ObjResults_WaitPLC-ObjResults_Index
	dc.w	ObjResults_MoveToDest-ObjResults_Index
	dc.w	ObjResults_BonusCountdown-ObjResults_Index
	dc.w	ObjResults_NextLevel-ObjResults_Index
; -------------------------------------------------------------------------

ObjResults_Init:
	subq.b	#1,oVar32(a0)
	beq.s	.LoadPLC
	rts

; -------------------------------------------------------------------------

.LoadPLC:
	moveq	#$10,d0
	jsr	LoadPLC
	addq.b	#2,oRoutine(a0)
; End of function ObjResults_Init

; -------------------------------------------------------------------------

ObjResults_WaitPLC:
	tst.l	plcBuffer.w
	bne.s	.End
	cmpi.w	#$502,levelZone
	beq.s	.LoadResults
	lea	objPlayerSlot.w,a6
	move.w	cameraX.w,d0
	addi.w	#$150,d0
	cmp.w	oX(a6),d0
	bcs.s	.LoadResults

.End:
	rts

; -------------------------------------------------------------------------

.LoadResults:
	lea	ObjResults_Data,a2
	moveq	#2,d6
	moveq	#0,d1
	movea.l	a0,a1
	if REGION=USA
		move.w	#$1E0,oVar32(a0)
	else
		move.w	#$168,oVar32(a0)
	endif
	bra.s	.InitLoop

; -------------------------------------------------------------------------

.Loop:
	jsr	FindObjSlot

.InitLoop:
	if REGION=USA
		move.w	#$1E0,oVar32(a1)
	else
		move.w	#$168,oVar32(a1)
	endif
	move.b	#$3A,oID(a1)
	move.b	#4,oRoutine(a1)
	move.w	#$83C4,oTile(a1)
	cmpi.w	#$502,levelZone
	bne.s	.NotSSZ3
	move.w	#$82F2,oTile(a1)
	move.l	#MapSpr_Results2,oMap(a1)
	tst.b	goodFuture
	beq.s	.GotMaps
	move.l	#MapSpr_Results4,oMap(a1)
	bra.s	.GotMaps

; -------------------------------------------------------------------------

.NotSSZ3:
	move.l	#MapSpr_Results1,4(a1)
	tst.b	goodFuture
	beq.s	.GotMaps
	move.l	#MapSpr_Results3,4(a1)

.GotMaps:
	move.w	d1,d2
	lsl.w	#3,d2
	move.w	(a2,d2.w),oYScr(a1)
	move.w	2(a2,d2.w),oX(a1)
	move.w	4(a2,d2.w),oVar2A(a1)
	move.b	7(a2,d2.w),oMapFrame(a1)
	cmpi.b	#2,d1
	bne.s	.GotFrame
	move.b	levelAct,d2
	add.b	d2,oMapFrame(a1)

.GotFrame:
	addq.b	#1,d1
	dbf	d6,.Loop
	rts
; End of function ObjResults_WaitPLC

; -------------------------------------------------------------------------

ObjResults_MoveToDest:
	tst.w	oVar32(a0)
	beq.s	.TimerDone
	subq.w	#1,oVar32(a0)

.TimerDone:
	moveq	#8,d0
	move.w	oVar2A(a0),d1
	cmp.w	oX(a0),d1
	beq.s	.InPlace
	bge.s	.GotSpeed
	neg.w	d0

.GotSpeed:
	add.w	d0,oX(a0)

.TestDisplay:
	if REGION=USA
		cmpi.w	#$1D8,oVar32(a0)
	else
		cmpi.w	#$160,oVar32(a0)
	endif
	bcc.s	.End
	jmp	DrawObject

; -------------------------------------------------------------------------

.End:
	rts

; -------------------------------------------------------------------------

.InPlace:
	tst.b	oMapFrame(a0)
	bne.s	.TestDisplay
	addq.b	#2,oRoutine(a0)
	bra.s	.TestDisplay
; End of function ObjResults_MoveToDest

; -------------------------------------------------------------------------

ObjResults_BonusCountdown:
	move.b	#1,updateResultsBonus.w
	moveq	#0,d0
	tst.w	bonusCount1.w
	bne.s	.GiveBonus1
	tst.w	bonusCount2.w
	bne.s	.GiveBonus2
	subq.w	#1,oVar32(a0)
	bpl.s	.KeepRout
	addq.b	#2,oRoutine(a0)

.KeepRout:
	cmpi.w	#$1E,oVar32(a0)
	bne.s	.Display
	tst.b	enteredBigRing
	beq.s	.Display
	move.w	#$C8,d0
	jsr	PlayFMSound

.Display:
	jmp	DrawObject

; -------------------------------------------------------------------------

.GiveBonus1:
	addi.w	#10,d0
	subi.w	#100,bonusCount1.w
	tst.w	bonusCount2.w
	beq.s	.ChkDone

.GiveBonus2:
	addi.w	#10,d0
	subi.w	#100,bonusCount2.w

.ChkDone:
	move.l	d0,d1
	tst.w	bonusCount1.w
	bne.s	.HaveBonus
	tst.w	bonusCount2.w
	bne.s	.HaveBonus
	jsr	StopZ80
	move.b	#$9A,FMDrvQueue1
	jsr	StartZ80
	cmpi.w	#$2D,oVar32(a0)
	bcc.s	.NoSFX
	move.w	#$2D,oVar32(a0)
	bra.s	.NoSFX

; -------------------------------------------------------------------------

.HaveBonus:
	tst.w	oVar32(a0)
	beq.s	.TestSFX
	subq.w	#1,oVar32(a0)

.TestSFX:
	btst	#0,oVar32(a0)
	bne.s	.NoSFX
	move.w	#$BD,d0
	jsr	PlayFMSound

.NoSFX:
	move.l	d1,d0
	jsr	AddPoints
	jmp	DrawObject
; End of function ObjResults_BonusCountdown

; -------------------------------------------------------------------------

ObjResults_NextLevel:
	move.w	#2,levelRestart
	move.b	#0,resetLevelFlags
	clr.w	lastCamPLC
	clr.l	flowerCount
	clr.b	unkLevelFlag
	clr.b	projDestroyed
	clr.b	lastCheckpoint
	tst.b	timeAttackMode
	beq.s	.NotTimeAttack
	bclr	#0,plcLoadFlags

.NotTimeAttack:
	bclr	#1,plcLoadFlags
	move.b	#1,timeZone
	move.w	level,d0
	addq.b	#1,d0
	cmpi.b	#2,d0
	bne.s	.NotAct3
	move.b	#2,timeZone

.NotAct3:
	cmpi.b	#3,d0
	bne.s	.SameZone
	move.b	#0,d0
	addi.w	#$100,d0
	move.b	#0,d0

.SameZone:
	move.w	d0,levelZone
	jsr	ResetRespawnTable
	jsr	FadeOutMusic
	jsr	DrawObject
	move.b	levelAct,d0
	subq.b	#1,d0
	bpl.s	.NotAct1
	clr.b	goodFutureFlags
	rts

; -------------------------------------------------------------------------

.NotAct1:
	tst.b	timeAttackMode
	bne.s	.End
	cmpi.b	#$7F,timeStones
	beq.s	.SetGoodFuture
	tst.b	goodFuture
	beq.s	.End
	clr.b	goodFuture
	bset	d0,goodFutureFlags
	cmpi.b	#3,goodFutureFlags
	bne.s	.End

.SetGoodFuture:
	move.b	#1,goodFuture

.End:
	rts
; End of function ObjResults_NextLevel

; -------------------------------------------------------------------------
ObjResults_Data:dc.w	$CC, 0, $120, 0
	dc.w	$110, $200, $F0, 1
	dc.w	$CC, 0, $120, 2

	include	"level/r1/objects/endresults/map.asm"
	even

ObjTitleCard_Data:dc.w	$130, $228, $168, $15A
	dc.w	$100, $238, $178, $25A
	dc.w	$100, $240, $180, $25A
	dc.w	$100, $248, $188, $25A
	dc.w	$120, $230, $170, $35A
	dc.w	$140, $248, $188, $45A
	dc.w	$100, $1D0, $110, $75A
	dc.w	$100, $1D0, $110, $85A
MapSpr_TitleCard:
	include	"level/r1/objects/titlecard/map.asm"
	even
; -------------------------------------------------------------------------

ObjBreakableWall:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjBreakableWall_Index(pc,d0.w),d0
	jmp	ObjBreakableWall_Index(pc,d0.w)
; End of function ObjBreakableWall

; -------------------------------------------------------------------------
ObjBreakableWall_Index:dc.w	ObjBreakableWall_Init-ObjBreakableWall_Index
	dc.w	ObjBreakableWall_Main-ObjBreakableWall_Index
	dc.w	ObjBreakableWall_Fall-ObjBreakableWall_Index
; -------------------------------------------------------------------------

ObjBreakableWall_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oRender(a0)
	move.b	#1,oPriority(a0)
	move.b	#$10,oXRadius(a0)
	move.b	#$10,oWidth(a0)
	move.b	#$18,oYRadius(a0)
	move.b	#$EF,oColType(a0)
	move.w	#$44BE,oTile(a0)
	move.l	#MapSpr_BreakableWall,oMap(a0)
	move.b	oSubtype(a0),oMapFrame(a0)
; End of function ObjBreakableWall_Init

; -------------------------------------------------------------------------

ObjBreakableWall_Main:
	tst.b	oColStatus(a0)
	beq.s	.Solid
	clr.w	oColType(a0)
	addq.b	#2,oRoutine(a0)
	lea	objPlayerSlot.w,a1
	move.w	oXVel(a1),oVar2A(a0)
	move.w	oYVel(a1),oVar2E(a0)
	bra.s	.BreakUp

; -------------------------------------------------------------------------

.Solid:
	lea	objPlayerSlot.w,a1
	jsr	SolidObject
	jsr	DrawObject
	jmp	CheckObjDespawnTime

; -------------------------------------------------------------------------

.BreakUp:
	move.w	#$B0,d0
	jsr	PlayFMSound
	lea	objPlayerSlot.w,a6
	asr	oXVel(a6)
	lea	ObjBreakableWall_PieceFrames(pc),a5
	moveq	#0,d0
	move.b	oSubtype(a0),d0
	lsl.w	#3,d0
	adda.w	d0,a5
	lea	ObjBreakableWall_PieceDeltas(pc),a4
	lea	ObjBreakableWall_PieceSpeeds(pc),a3
	moveq	#5,d6
	movea.w	a0,a1
	bra.s	.InitLoop

; -------------------------------------------------------------------------

.Loop:
	jsr	FindObjSlot
	bne.s	ObjBreakableWall_Fall
	move.b	oID(a0),oID(a1)
	move.b	oRoutine(a0),oRoutine(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	move.b	oRender(a0),oRender(a1)
	move.b	oPriority(a0),oPriority(a1)
	move.l	oMap(a0),oMap(a1)
	move.w	oTile(a0),oTile(a1)

.InitLoop:
	move.b	#8,oXRadius(a1)
	move.b	#8,oWidth(a1)
	move.b	#8,oYRadius(a1)
	move.b	(a5)+,oMapFrame(a1)
	move.w	(a4)+,d0
	move.w	(a4)+,d1
	add.w	d0,oX(a1)
	add.w	d1,oY(a1)
	move.l	(a3)+,d0
	move.l	(a3)+,oVar2E(a1)
	tst.w	oXVel(a6)
	bpl.s	.NoFlip
	neg.l	d0

.NoFlip:
	move.l	d0,oVar2A(a1)
	dbf	d6,.Loop
; End of function ObjBreakableWall_Main

; -------------------------------------------------------------------------

ObjBreakableWall_Fall:
	addi.l	#$4000,oVar2E(a0)
	move.l	oVar2A(a0),d0
	move.l	oVar2E(a0),d1
	add.l	d0,oX(a0)
	add.l	d1,oY(a0)
	lea	objPlayerSlot.w,a1
	move.w	oY(a1),d0
	sub.w	oY(a0),d0
	cmpi.w	#-$E0,d0
	ble.s	.Destroy
	jmp	DrawObject

; -------------------------------------------------------------------------

.Destroy:
	jmp	DeleteObject
; End of function ObjBreakableWall_Fall

; -------------------------------------------------------------------------
MapSpr_BreakableWall:
	include	"level/r1/objects/breakablewall/map.asm"
	even
ObjBreakableWall_PieceFrames:dc.b	8, 9,	8, $C, $D, $C, 0, 0
	dc.b	8,	9, 8, $A, $B, $A, 0, 0
	dc.b	$A, $B, $A, $A, $B, $A, 0,	0
	dc.b	$A, $B, $A, $C, $D, $C, 0,	0
	dc.b	9,	8, 9, $D, $C, $D, 0, 0
	dc.b	9,	8, 9, $B, $A, $B, 0, 0
	dc.b	$B, $A, $B, $B, $A, $B, 0,	0
	dc.b	$B, $A, $B, $D, $C, $D, 0,	0
ObjBreakableWall_PieceDeltas:dc.w	$FFF8, $FFF0
	dc.w	0,	$10
	dc.w	0,	$20
	dc.w	$10, 0
	dc.w	$10, $10
	dc.w	$10, $20
ObjBreakableWall_PieceSpeeds:dc.w	$FFFD, $97C
	dc.w	$FFFE, $B750
	dc.w	$FFFC, $25EE
	dc.w	0,	0
	dc.w	$FFFD, $97C
	dc.w	1,	$48B0
	dc.w	$FFFD, $97C
	dc.w	$FFFE, $4445
	dc.w	$FFFC, $97B5
	dc.w	0,	0
	dc.w	$FFFD, $97C
	dc.w	1,	$BBBB
; -------------------------------------------------------------------------
; Attributes: thunk

JmpTo_LoadShieldArt:
	jmp	LoadShieldArt
; End of function JmpTo_LoadShieldArt

; -------------------------------------------------------------------------

LevelDataIndex:
	dc.l	$3000000|ArtNem_LevelArt
	dc.l	$2000000|MapNem_LevelBlocks
	dc.l	LevelChunks
	dc.b	0
	dc.b	$81

LevelPaletteID:
	dc.b	5
	dc.b	5

PLCIndex:
	dc.w	PLC_Level-PLCIndex
	dc.w	PLC_Std-PLCIndex
	dc.w	PLC_Cam1_Full-PLCIndex
	dc.w	PLC_Level-PLCIndex
	dc.w	PLC_Cam2_Full-PLCIndex
	dc.w	PLC_Cam3_Full-PLCIndex
	dc.w	PLC_Cam4_Full-PLCIndex
	dc.w	PLC_Cam5_Full-PLCIndex
	dc.w	PLC_Cam1_Incr-PLCIndex
	dc.w	PLC_Cam2_Incr-PLCIndex
	dc.w	PLC_Cam3_Incr-PLCIndex
	dc.w	PLC_Cam4_Incr-PLCIndex
	dc.w	PLC_Cam5_Incr-PLCIndex
	dc.w	PLC_Cam1_Full-PLCIndex
	dc.w	PLC_Cam1_Full-PLCIndex
	dc.w	PLC_Cam1_Full-PLCIndex
	dc.w	PLC_Results-PLCIndex
	dc.w	PLC_Cam1_Full-PLCIndex
	dc.w	PLC_Signpost-PLCIndex
PLC_Level:	dc.w	1
	dc.l	ArtNem_LevelArt
	dc.w	0
	dc.l	ArtNem_ContinuePost
	dc.w	$D960
PLC_Std:	dc.w	$D
	dc.l	ArtNem_Spikes
	dc.w	$6400
	dc.l	ArtNem_SpinTubeDoors
	dc.w	$6500
	dc.l	ArtNem_HiddenPlatforms
	dc.w	$6680
	dc.l	ArtNem_TitleCard
	dc.w	$6C00
	dc.l	ArtNem_TitleCardText
	dc.w	$7A00
	dc.l	ArtNem_DiagonalSpring
	dc.w	$9200
	dc.l	ArtNem_CollapsePlatform
	dc.w	$97C0
	dc.l	ArtNem_Springs
	dc.w	$A400
	dc.l	ArtNem_HUD
	dc.w	$AD00
	dc.l	ArtNem_MonitorTimePosts
	dc.w	$B500
	dc.l	ArtNem_Explosions
	dc.w	$D000
	dc.l	ArtNem_Points
	dc.w	$D8C0
	dc.l	ArtNem_Flower
	dc.w	$DAE0
	dc.l	ArtNem_Rings
	dc.w	$F5C0
PLC_Cam1_Full:	dc.w	6
	dc.l	ArtNem_GreyRock
	dc.w	$6E80
	dc.l	ArtNem_PPZAnimals
	dc.w	$7100
	dc.l	ArtNem_Mosqui
	dc.w	$7400
	dc.l	ArtNem_Anton
	dc.w	$8120
	dc.l	ArtNem_StarBush
	dc.w	$8480
	dc.l	ArtNem_LargeFan
	dc.w	$8820
	dc.l	ArtNem_GoalPost
	dc.w	$9EE0
PLC_Cam2_Full:	dc.w	5
	dc.l	ArtNem_GreyRock
	dc.w	$6E80
	dc.l	ArtNem_PPZAnimals
	dc.w	$7100
	dc.l	ArtNem_PataBata
	dc.w	$7600
	dc.l	ArtNem_Anton
	dc.w	$8120
	dc.l	ArtNem_MotorizedBeetle
	dc.w	$8500
	dc.l	ArtNem_GoalPost
	dc.w	$9EE0
PLC_Cam3_Full:	dc.w	8
	dc.l	ArtNem_GreyRock
	dc.w	$6E80
	dc.l	ArtNem_PPZAnimals
	dc.w	$7100
	dc.l	ArtNem_SonicHole
	dc.w	$7400
	dc.l	ArtNem_PataBata
	dc.w	$7600
	dc.l	ArtNem_WaterSplash
	dc.w	$7C80
	dc.l	ArtNem_RotPlatform
	dc.w	$8120
	dc.l	ArtNem_HollowLogBG
	dc.w	$8300
	dc.l	ArtNem_MotorizedBeetle
	dc.w	$8500
	dc.l	ArtNem_GoalPost
	dc.w	$9EE0
PLC_Cam4_Full:	dc.w	6
	dc.l	ArtNem_Anton
	dc.w	$6E00
	dc.l	ArtNem_PPZAnimals
	dc.w	$7100
	dc.l	ArtNem_Mosqui
	dc.w	$7400
	dc.l	ArtNem_RotPlatform
	dc.w	$8120
	dc.l	ArtNem_StarBush
	dc.w	$8480
	dc.l	ArtNem_LargeFan
	dc.w	$8820
	dc.l	ArtNem_GoalPost
	dc.w	$9EE0
PLC_Cam5_Full:	dc.w	4
	dc.l	ArtNem_AmyRose
	dc.w	$6E00
	dc.l	ArtNem_AgedTeleporter
	dc.w	$8120
	dc.l	ArtNem_StarBush
	dc.w	$8480
	dc.l	ArtNem_LargeFan
	dc.w	$8820
	dc.l	ArtNem_GoalPost
	dc.w	$9EE0
PLC_Cam1_Incr:	dc.w	5
	dc.l	ArtNem_GreyRock
	dc.w	$6E80
	dc.l	ArtNem_PPZAnimals
	dc.w	$7100
	dc.l	ArtNem_Mosqui
	dc.w	$7400
	dc.l	ArtNem_Anton
	dc.w	$8120
	dc.l	ArtNem_StarBush
	dc.w	$8480
	dc.l	ArtNem_LargeFan
	dc.w	$8820
PLC_Cam2_Incr:	dc.w	2
	dc.l	ArtNem_PataBata
	dc.w	$7600
	dc.l	ArtNem_Anton
	dc.w	$8120
	dc.l	ArtNem_MotorizedBeetle
	dc.w	$8500
PLC_Cam3_Incr:	dc.w	6
	dc.l	ArtNem_GreyRock
	dc.w	$6E80
	dc.l	ArtNem_SonicHole
	dc.w	$7400
	dc.l	ArtNem_PataBata
	dc.w	$7600
	dc.l	ArtNem_WaterSplash
	dc.w	$7C80
	dc.l	ArtNem_RotPlatform
	dc.w	$8120
	dc.l	ArtNem_HollowLogBG
	dc.w	$8300
	dc.l	ArtNem_MotorizedBeetle
	dc.w	$8500
PLC_Cam4_Incr:	dc.w	5
	dc.l	ArtNem_Anton
	dc.w	$6E00
	dc.l	ArtNem_PPZAnimals
	dc.w	$7100
	dc.l	ArtNem_Mosqui
	dc.w	$7400
	dc.l	ArtNem_RotPlatform
	dc.w	$8120
	dc.l	ArtNem_StarBush
	dc.w	$8480
	dc.l	ArtNem_LargeFan
	dc.w	$8820
PLC_Cam5_Incr:	dc.w	1
	dc.l	ArtNem_AmyRose
	dc.w	$6E00
	dc.l	ArtNem_AgedTeleporter
	dc.w	$8120
PLC_Results:	dc.w	0
	dc.l	ArtNem_Results
	dc.w	$7880
PLC_Signpost:	dc.w	2
	dc.l	ArtNem_Signpost
	dc.w	$8780
	dc.l	ArtNem_BigRing
	dc.w	$9100
	dc.l	ArtNem_BigRingFlash
	dc.w	$7DE0

; -------------------------------------------------------------------------
; Leftover data from other level files used as padding, can be replaced
; with a "align $10000"
; -------------------------------------------------------------------------

	if REGION=USA
		incbin	"level/r1/unused/leftover1.usa.bin"
	else
		incbin	"level/r1/unused/leftover1.jpeu.bin"
	endif

; -------------------------------------------------------------------------

LevelChunks:
	incbin	"level/r1/data/chunks.bin"
	even
MapSpr_Sonic:
	include	"level/r1/objects/sonic/map.asm"
	even
MapSpr_3DRamp:
	include	"level/r1/objects/3dramp/map.asm"
	even
ArtUnc_Sonic:
	incbin	"level/r1/objects/sonic/art.bin"
	even
DPLC_Sonic:
	include	"level/r1/objects/sonic/dplc.asm"
	even
ArtNem_Points:
	incbin	"level/r1/objects/points/art.bin"
	even
ArtNem_SeedPods:
	incbin	"level/r1/objects/flowercapsule/art.bin"
	even
ArtNem_BigRing:
	incbin	"level/r1/objects/bigring/art.bin"
	even
ArtNem_GoalPost:
	incbin	"level/r1/objects/endpost/artgoal.bin"
	even
ArtNem_Signpost:
	incbin	"level/r1/objects/endpost/artsign.bin"
	even
ArtNem_Results:
	incbin	"level/r1/objects/endresults/art.bin"
	even
ArtUnc_TimeOver:
	incbin	"level/r1/objects/gameover/arttimeover.bin"
	even
ArtUnc_GameOver:
	incbin	"level/r1/objects/gameover/artgameover.bin"
	even
ArtNem_TitleCard:
	incbin	"level/r1/objects/titlecard/artbase.bin"
	even
ArtUnc_Shield:
	incbin	"level/r1/objects/powerup/artshield.bin"
	even
ArtUnc_InvStars:
	incbin	"level/r1/objects/powerup/artinvinc.bin"
	even
ArtUnc_TimeStars:
	incbin	"level/r1/objects/powerup/artwarp.bin"
	even
ArtNem_DiagonalSpring:
	incbin	"level/r1/objects/spring/artdiag.bin"
	even
ArtNem_Springs:
	incbin	"level/r1/objects/spring/artnormal.bin"
	even
ArtNem_MonitorTimePosts:
	incbin	"level/r1/objects/monitor/art.bin"
	even
ArtNem_Explosions:
	incbin	"level/r1/objects/explosion/art.bin"
	even
ArtNem_Rings:
	incbin	"level/r1/objects/ring/art.bin"
	even
ArtUnc_LifeIcon:
	incbin	"level/r1/objects/hud/artlifeicon.bin"
	even
ArtUnc_HUD:
	incbin	"level/r1/objects/hud/artnumbers.bin"
	even
ArtNem_HUD:
	incbin	"level/r1/objects/hud/artbase.bin"
	even
ArtNem_ContinuePost:
	incbin	"level/r1/objects/checkpoint/art.bin"
	even
ArtNem_Unused1:
	incbin	"level/r1/objects/logbg/artunused.bin"
	even
ArtNem_HollowLogBG:
	incbin	"level/r1/objects/logbg/art.bin"
	even
Ani_Flower:
	include	"level/r1/objects/flower/anim.asm"
	even
MapSpr_Flower:
	include	"level/r1/objects/flower/map.asm"
	even
ArtNem_Flower:
	incbin	"level/r1/objects/flower/art.bin"
	even
ArtNem_TitleCardText:
	incbin	"level/r1/objects/titlecard/arttext.bin"
	even
ArtNem_CollapsePlatform:
	incbin	"level/r1/objects/platform/art.bin"
	even
ArtNem_GreyRock:
	incbin	"level/r1/objects/grayrock/art.bin"
	even
ArtNem_HiddenPlatforms:
	incbin	"level/r1/objects/smallptfm/art.bin"
	even
ArtNem_Wheel:
	incbin	"level/r1/objects/spring/artwheel.bin"
	even
ArtNem_RotPlatform:
	incbin	"level/r1/objects/rotatingptfm/art.bin"
	even
ArtNem_WaterSplash:
	incbin	"level/r1/objects/splash/artwaterfall.bin"
	even
ArtNem_ExtraWaterSplashes1:
	incbin	"level/r1/objects/waterfall/art.bin"
	even
ArtNem_SpinTubeDoors:
	incbin	"level/r1/objects/flapdoor/art.bin"
	even
ArtNem_ExtraWaterSplashes2:
	incbin	"level/r1/objects/splash/artnormal.bin"
	even
ArtNem_Anton:
	incbin	"level/r1/objects/anton/art.bin"
	even
ArtNem_Mosqui:
	incbin	"level/r1/objects/mosqui/art.bin"
	even
ArtNem_PataBata:
	incbin	"level/r1/objects/patabata/art.bin"
	even
ArtNem_TagaTaga:
	incbin	"level/r1/objects/tagataga/art.bin"
	even
ArtNem_MotorizedBeetle:
	incbin	"level/r1/objects/tamabboh/art.bin"
	even
ArtNem_SprintPole:
	incbin	"level/r1/objects/springboard/art.bin"
	even
ArtNem_Button:
	incbin	"level/r1/unused/art/button.bin"
	even
ArtNem_Spikes:
	incbin	"level/r1/objects/spikes/art.bin"
	even
ArtNem_SwingingPlatform:
	incbin	"level/r1/unused/art/swingptfm.bin"
	even
ArtNem_PPZAnimals:
	incbin	"level/r1/objects/animal/art.bin"
	even
ArtNem_RotPlatformDrill:
	incbin	"level/r1/unused/art/rotptfmdrill.bin"
	even
ArtNem_AgedTeleporter:
	incbin	"level/r1/objects/robotgenerator/art.bin"
	even
ColAngleMap:
	incbin	"level/r1/data/colangles.bin"
	even
ColHeightMap:
	incbin	"level/r1/data/colheights.bin"
	even
ColWidthMap:
	incbin	"level/r1/data/colwidths.bin"
	even
LevelCollision:
	incbin	"level/r1/data/colblocks.bin"
	even
LevelLayoutIndex:
	dc.w LevelLayout_FG-LevelLayoutIndex
	dc.w LevelLayout_BG-LevelLayoutIndex
	dc.w LevelLayout_Null-LevelLayoutIndex
	dc.w LevelLayout_Null-LevelLayoutIndex
	dc.w LevelLayout_Null-LevelLayoutIndex
	dc.w LevelLayout_Null-LevelLayoutIndex
	dc.w LevelLayout_Null-LevelLayoutIndex
	dc.w LevelLayout_Null-LevelLayoutIndex
	dc.w LevelLayout_Null-LevelLayoutIndex
	dc.w LevelLayout_Null-LevelLayoutIndex
	dc.w LevelLayout_Null-LevelLayoutIndex
	dc.w LevelLayout_Null-LevelLayoutIndex
	dc.w LevelLayout_FG-LevelLayoutIndex
	dc.w LevelLayout_BG-LevelLayoutIndex
	dc.w LevelLayout_Null-LevelLayoutIndex
	dc.w LevelLayout_Null-LevelLayoutIndex
	dc.w LevelLayout_Null-LevelLayoutIndex
	dc.w LevelLayout_Null-LevelLayoutIndex
	dc.w LevelLayout_Null-LevelLayoutIndex
	dc.w LevelLayout_Null-LevelLayoutIndex
	dc.w LevelLayout_Null-LevelLayoutIndex
	dc.w LevelLayout_Null-LevelLayoutIndex
	dc.w LevelLayout_Null-LevelLayoutIndex
	dc.w LevelLayout_Null-LevelLayoutIndex
	dc.w LevelLayout_FG-LevelLayoutIndex
	dc.w LevelLayout_BG-LevelLayoutIndex
	dc.w LevelLayout_Null-LevelLayoutIndex
	dc.w LevelLayout_Null-LevelLayoutIndex
	dc.w LevelLayout_Null-LevelLayoutIndex
	dc.w LevelLayout_Null-LevelLayoutIndex
	dc.w LevelLayout_Null-LevelLayoutIndex
	dc.w LevelLayout_Null-LevelLayoutIndex
	dc.w LevelLayout_Null-LevelLayoutIndex
	dc.w LevelLayout_Null-LevelLayoutIndex
	dc.w LevelLayout_Null-LevelLayoutIndex
	dc.w LevelLayout_Null-LevelLayoutIndex
LevelLayout_FG:
	incbin	"level/r1/data/levelfg.bin"
	even
LevelLayout_BG:
	incbin	"level/r1/data/levelbg.bin"
	even
LevelLayout_Null:

ArtNem_SonicHole:
	incbin	"level/r1/objects/sonichole/art.bin"
	even
ArtNem_StarBush:
	incbin	"level/r1/objects/3dplant/art.bin"
	even
ArtNem_LargeFan:
	incbin	"level/r1/objects/3dramp/art.bin"
	even
MapNem_LevelBlocks:
	incbin	"level/r1/data/blocks.bin"
	even
ArtNem_LevelArt:
	incbin	"level/r1/data/art.bin"
	even
Ani_Powerup:
	include	"level/r1/objects/powerup/anim.asm"
	even
MapSpr_Powerup:
	include	"level/r1/objects/powerup/map.asm"
	even
Ani_WaterSplash:
	include	"level/r1/objects/splash/animnormal.asm"
	even
MapSpr_WaterSplash:
	include	"level/r1/objects/splash/mapnormal.asm"
	even
Ani_FlapDoorH:
	include	"level/r1/objects/flapdoor/animhoriz.asm"
	even
MapSpr_FlapDoorH:
	include	"level/r1/objects/flapdoor/maphoriz.asm"
	even
Ani_WaterfallSplash:
	include	"level/r1/objects/splash/animwaterfall.asm"
	even
MapSpr_WaterfallSplash:
	include	"level/r1/objects/splash/mapwaterfall.asm"
	even
Ani_Explosion:
	include	"level/r1/objects/explosion/anim.asm"
	even
MapSpr_Explosion:
	include	"level/r1/objects/explosion/map.asm"
	even
Ani_Checkpoint:
	include	"level/r1/objects/checkpoint/anim.asm"
	even
MapSpr_Checkpoint:
	include	"level/r1/objects/checkpoint/map.asm"
	even
Ani_BigRing:
	include	"level/r1/objects/bigring/anim.asm"
	even
MapSpr_BigRing:
	include	"level/r1/objects/bigring/map.asm"
	even
MapSpr_GoalPost_Signpost:
	include	"level/r1/objects/endpost/map.asm"
	even
MapSpr_FlowerCapsule:
;	include	"level/r1/objects/flowercapsule/map.asm"
;	even
Ani_FlowerCapsule:
;	include	"level/r1/objects/flowercapsule/anim.asm"
;	even
ArtNem_Projector:
;	incbin	"level/r1/objects/projector/art.bin"
;	even
ArtNem_AmyRose:
	incbin	"level/r1/objects/amyrose/art.bin"
	even
MapSpr_AmyRose:	
	include	"level/r1/objects/amyrose/map.asm"
	even
Ani_AmyRose:
	include	"level/r1/objects/amyrose/anim.asm"
	even

; -------------------------------------------------------------------------
; Leftover data from other level files used as padding, can be replaced
; with a "align $40000"
; -------------------------------------------------------------------------

	incbin	"level/r1/unused/leftover2.bin"

; -------------------------------------------------------------------------
