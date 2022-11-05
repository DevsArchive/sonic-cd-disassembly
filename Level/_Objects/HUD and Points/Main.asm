; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Level HUD/points object
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Points object
; -------------------------------------------------------------------------

oPntsTimer	EQU	oVar2A			; Timer

; -------------------------------------------------------------------------

ObjPoints:
	moveq	#0,d0				; Run routine
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	jmp	DrawObject			; Draw sprite

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjPoints_Init-.Index
	dc.w	ObjPoints_Main-.Index

; -------------------------------------------------------------------------
; Initialization
; -------------------------------------------------------------------------

ObjPoints_Init:
	addq.b	#2,oRoutine(a0)			; Next routine
	ori.b	#%00000100,oSprFlags(a0)	; Set sprite flags
	move.w	#$6C6,oTile(a0)			; Set base tile ID
	move.l	#MapSpr_Points,oMap(a0)		; Set mappings
	move.b	oSubtype(a0),oMapFrame(a0)	; Set sprite frame
	andi.b	#$7F,oMapFrame(a0)
	move.b	#24,oPntsTimer(a0)		; Set timer

; -------------------------------------------------------------------------
; Main routine
; -------------------------------------------------------------------------

ObjPoints_Main:
	subq.b	#1,oPntsTimer(a0)		; Decrement timer
	bne.s	.Rise				; If it hasn't run out, branch
	jmp	DeleteObject			; Delete ourselves

.Rise:
	subq.w	#2,oY(a0)			; Move up
	rts

; -------------------------------------------------------------------------
; Data
; -------------------------------------------------------------------------

MapSpr_Points:
	include	"Level/_Objects/HUD and Points/Data/Mappings (Points).asm"
	even

; -------------------------------------------------------------------------
; HUD object
; -------------------------------------------------------------------------

ObjHUDPoints:
	tst.b	oSubtype(a0)			; Is this a points object?
	bmi.w	ObjPoints			; If so, branch

ObjHUD:
	moveq	#0,d0				; Run routine
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jmp	.Index(pc,d0.w)

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjHUD_Init-.Index
	dc.w	ObjHUD_Main-.Index

; -------------------------------------------------------------------------
; Initialization
; -------------------------------------------------------------------------

ObjHUD_Init:
	addq.b	#2,oRoutine(a0)			; Next routine
	move.l	#MapSpr_HUD,oMap(a0)		; Set mappings
	move.w	#$8568,oTile(a0)		; Set base tile ID
	move.w	#16+128,oX(a0)			; Set position
	move.w	#8+128,oYScr(a0)

	tst.b	oSubtype2(a0)			; Is this the rings counter?
	beq.s	.NotRings			; If not, branch
	move.b	#3,oMapFrame(a0)		; Set rings counter sprite frame
	bra.s	ObjHUD_Main

.NotRings:
	tst.w	debugCheat			; Is debug mode enabled?
	beq.s	.NoDebug			; If not, branch
	move.b	#2,oMapFrame(a0)		; Set position tracker sprite frame

.NoDebug:
	tst.b	oSubtype(a0)			; Is this the lives counter?
	beq.s	ObjHUD_Main			; If not, branch
	move.w	#200+128,oYScr(a0)		; Set lives counter position
	move.b	#1,oMapFrame(a0)		; Set lives counter sprite frame

; -------------------------------------------------------------------------
; Main routine
; -------------------------------------------------------------------------

ObjHUD_Main:
	tst.b	oSubtype(a0)			; Is this the lives counter?
	bne.s	.Draw				; If so, branch
	tst.b	oSubtype2(a0)			; Is this the rings counter?
	beq.s	.Score				; If not, branch

.Rings:
	tst.w	rings				; Do we have any rings?
	beq.s	.FlashRings			; If not, branch
	bclr	#5,oTile(a0)			; Stay yellow
	bra.s	.Draw

.FlashRings:
	move.b	levelVIntCounter+3,d0		; Flash between red and yellow
	andi.b	#$F,d0
	bne.s	.Draw
	eori.b	#$20,oTile(a0)
	bra.s	.Draw

.Score:
	move.b	#0,oMapFrame(a0)		; Set score counter sprite frame
	tst.w	debugCheat			; Is debug mode enabled?
	beq.s	.Draw				; If not, branch
	move.b	#2,oMapFrame(a0)		; Set position tracker sprite frame

.Draw:
	jmp	DrawObject			; Draw sprite

; -------------------------------------------------------------------------
; Data
; -------------------------------------------------------------------------

MapSpr_HUD:
	include	"Level/_Objects/HUD and Points/Data/Mappings (HUD).asm"
	even

; -------------------------------------------------------------------------
; Add points
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - Number of points to add
; -------------------------------------------------------------------------

AddPoints:
	move.b	#1,updateHUDScore		; Update score counter
	lea	score,a3			; Add to score
	add.l	d0,(a3)
	
	move.l	#999999,d1			; Has it reached the maximum score?
	cmp.l	(a3),d1
	bhi.s	.CappedScore			; If not, branch
	move.l	d1,(a3)				; If so, cap it

.CappedScore:
	move.l	(a3),d0				; Has it reached the next extra life score?
	cmp.l	nextLifeScore,d0
	bcs.s	.End				; If not, branch
	
	addi.l	#5000,nextLifeScore		; Set next extra life score
	addq.b	#1,lives			; Add extra life
	addq.b	#1,updateHUDLives		; Update lives counter
	
	move.w	#SCMD_YESSFX,d0			; Play 1UP sound
	jmp	SubCPUCmd

.End:
	rts

; -------------------------------------------------------------------------
; Update HUD
; -------------------------------------------------------------------------

UpdateHUD:
	tst.w	debugCheat			; Is debug mode enabled?
	beq.s	.NormalHUD			; If not, branch

.DebugHUD:
	bsr.w	HUD_DrawPos			; Update position tracker

	VDPCMD	move.l,$B360,VRAM,WRITE,d0	; Get VDP command

	moveq	#0,d1				; Get right object chunk's current saved flags entry ID (not displayed)
	move.b	savedObjFlags,d1

	move.w	objPlayerSlot+oY.w,d2		; Get chunk ID the player is on (not displayed)
	lsr.w	#1,d2
	andi.w	#$380,d2
	move.b	objPlayerSlot+oX.w,d1
	andi.w	#$7F,d1
	add.w	d1,d2
	lea	levelLayout.w,a1
	moveq	#0,d1
	move.b	(a1,d2.w),d1
	andi.w	#$7F,d1

	move.w	debugBlock,d1			; Display block ID the player is on
	andi.w	#$7FF,d1
	lea	Hud_100,a2
	moveq	#2,d6
	bsr.w	HUD_DrawNum

	bra.w	.ChkTime			; Check timer

; -------------------------------------------------------------------------

.NormalHUD:
	tst.b	updateHUDScore			; Should we update the score counter?
	beq.s	.ChkRings			; If not, branch
	bpl.s	.UpdateScore			; If the score counter is not being reset, branch
	bsr.w	HUD_ResetScore			; Reset the score counter

.UpdateScore:
	clr.b	updateHUDScore			; Clear flag
	VDPCMD	move.l,$B060,VRAM,WRITE,d0	; Draw score counter
	move.l	score,d1
	bsr.w	HUD_DrawScore

.ChkRings:
	tst.b	updateHUDRings			; Should we update the rings counter?
	beq.s	.ChkTime			; If not, branch
	bpl.s	.UpdateRings			; If the rings counter is not being reset, branch
	bsr.w	HUD_ResetRings			; Reset the rings counter

.UpdateRings:
	clr.b	updateHUDRings			; Clear flag
	VDPCMD	move.l,$B360,VRAM,WRITE,d0	; Draw rings counter
	moveq	#0,d1
	move.w	rings,d1
	cmpi.w	#1000,d1			; Are there too many rings collected?
	bcs.s	.CappedRings			; If not, branch
	move.w	#999,d1				; If so, cap it
	move.w	d1,rings

.CappedRings:
	bsr.w	HUD_DrawRings			; Draw rings counter

; -------------------------------------------------------------------------

.ChkTime:
	tst.w	debugCheat			; Is debug mode enabled?
	bne.w	.ChkLives			; If so, branch
	tst.b	updateHUDTime			; Is the timer enabled?
	beq.w	.ChkLives			; If not, branch
	tst.w	paused.w			; Is the game paused?
	bne.w	.ChkLives			; If so, branch

	lea	time,a1				; Get time
	cmpi.l	#(9<<16)|(59<<8)|59,(a1)+	; Are we at the max time?
	beq.w	.SetTimeOver			; If so, set a time over
	tst.b	ctrlLocked.w			; Are the player's controls locked?
	bne.s	.UpdateTimer			; If so, branch

	addq.b	#1,-(a1)			; Tick a frame
	cmpi.b	#60,(a1)			; Should we tick a second?
	bcs.s	.UpdateTimer			; If not, branch
	
	move.b	#0,(a1)				; Reset frame counter
	addq.b	#1,-(a1)			; Tick a second
	cmpi.b	#60,(a1)			; Should we tick a minute?
	bcs.s	.UpdateTimer			; If not, branch
	
	move.b	#0,(a1)				; Reset seconds counter
	addq.b	#1,-(a1)			; Tick a minute
	cmpi.b	#9,(a1)				; Are we at the max number of minutes?
	bcs.s	.UpdateTimer			; If not, branch
	move.b	#9,(a1)				; If so, cap it

.UpdateTimer:
	VDPCMD	move.l,$B220,VRAM,WRITE,d0	; Draw minutes
	moveq	#0,d1
	move.b	timeMinutes,d1
	bsr.w	HUD_DrawMins

	VDPCMD	move.l,$B260,VRAM,WRITE,d0	; Draw seconds
	moveq	#0,d1
	move.b	timeSeconds,d1
	bsr.w	HUD_DrawSecs

	VDPCMD	move.l,$B2E0,VRAM,WRITE,d0	; Draw frames as centiseconds
	moveq	#0,d1
	move.b	timeFrames,d1
	mulu.w	#100,d1
	divu.w	#60,d1
	swap	d1
	move.w	#0,d1
	swap	d1
	cmpi.l	#(9<<16)|(59<<8)|59,time	; Are we at the max time?
	bne.s	.UpdateCentisecs		; If not, branch
	move.w	#99,d1				; If so, set centiseconds to 99

.UpdateCentisecs:
	bsr.w	HUD_DrawSecs			; Draw centiseconds

.ChkLives:
	tst.b	updateHUDLives			; Should we update the lives counter?
	beq.s	.ChkBonus			; If not, branch
	clr.b	updateHUDLives			; Clear flag
	bsr.w	HUD_DrawLives			; Draw lives counter

.ChkBonus:
	tst.b	updateHUDBonus.w		; Should we update the bonus counters?
	beq.s	.End				; If not, branch
	clr.b	updateHUDBonus.w		; Clear flag

	VDPCMD	move.l,$8780,VRAM,WRITE,d0	; Draw time bonus counter
	cmpi.w	#$502,zoneAct
	bne.s	.DrawTimeBonus
	VDPCMD	move.l,$6D40,VRAM,WRITE,d0

.DrawTimeBonus:
	moveq	#0,d1
	move.w	timeBonus.w,d1
	bsr.w	HUD_DrawBonus
	
	VDPCMD	move.l,$88C0,VRAM,WRITE,d0	; Draw ring bonus counter
	cmpi.w	#$502,zoneAct
	bne.s	.DrawRingBonus
	VDPCMD	move.l,$6E80,VRAM,WRITE,d0

.DrawRingBonus:
	moveq	#0,d1
	move.w	ringBonus.w,d1
	bsr.w	HUD_DrawBonus

.End:
	rts

.SetTimeOver:
	btst	#7,timeZone			; Is there a time warp happening?
	bne.s	.End2				; If so, branch

	clr.b	updateHUDTime			; Stop updating the timer
	move.l	#0,time				; Clear timer
	lea	objPlayerSlot.w,a0		; Kill the player
	movea.l	a0,a2
	bsr.w	KillPlayer
	move.b	#1,timeOver			; Set time over flag

.End2:
	rts

; -------------------------------------------------------------------------
; Reset rings in HUD
; -------------------------------------------------------------------------

HUD_ResetRings:
	VDPCMD	move.l,$B360,VRAM,WRITE,VDPCTRL	; Reset rings counter
	lea	HUD_DrawRingsTiles(pc),a2
	move.w	#(HUD_DrawRingsTilesEnd-HUD_DrawRingsTiles)-1,d2
	bra.s	HUD_ResetNumber

; -------------------------------------------------------------------------
; Reset score in HUD
; -------------------------------------------------------------------------

HUD_ResetScore:
	lea	VDPDATA,a6			; VDP data port
	bsr.w	HUD_DrawLives			; Draw lives counter

	VDPCMD	move.l,$B060,VRAM,WRITE,VDPCTRL	; Reset score counter
	lea	HUD_DrawScoreTiles(pc),a2
	move.w	#(HUD_DrawScoreTilesEnd-HUD_DrawScoreTiles)-1,d2

; -------------------------------------------------------------------------
; Reset number in HUD
; -------------------------------------------------------------------------
; PARAMETERS:
;	d2.w - Number of digits (minus 1)
;	a2.l - Pointer to digit data
; -------------------------------------------------------------------------

HUD_ResetNumber:
	lea	Art_HUDNumbers,a1		; HUD numbers art

.Loop:
	move.w	#$40/4-1,d1			; Size of digit art in bytes
	move.b	(a2)+,d0			; Get digit to write
	bmi.s	.BlankSpace			; If it's a blank space, branch

	ext.w	d0				; Draw digit
	lsl.w	#5,d0
	lea	(a1,d0.w),a3

.DrawNumber:
	move.l	(a3)+,(a6)
	dbf	d1,.DrawNumber

.Next:
	dbf	d2,.Loop			; Loop until digits are drawn
	rts

.BlankSpace:
	move.l	#0,(a6)				; Draw blank digit
	dbf	d1,.BlankSpace
	bra.s	.Next				; Loop

; -------------------------------------------------------------------------

HUD_DrawScoreTiles:
	dc.b	$FF, $FF, $FF, $FF, $FF, $FF, 0
HUD_DrawScoreTilesEnd:
	even

HUD_DrawRingsTiles:
	dc.b	$FF, $FF, 0
HUD_DrawRingsTilesEnd:
	even

; -------------------------------------------------------------------------
; Draw position tracker
; -------------------------------------------------------------------------

HUD_DrawPos:
	VDPCMD	move.l,$B0E0,VRAM,WRITE,d0	; Draw X position
	moveq	#0,d1
	move.w	objPlayerSlot+oX.w,d1
	bsr.w	HUD_DrawHexNum

	VDPCMD	move.l,$B260,VRAM,WRITE,d0	; Draw Y position
	move.w	objPlayerSlot+oY.w,d1
	bra.w	HUD_DrawHexNum

; -------------------------------------------------------------------------
; Draw bonus counter
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - VDP command
;	d1.l - Number to draw
; -------------------------------------------------------------------------

HUD_DrawBonus:
	lea	Hud_10000,a2			; 5 digits
	moveq	#5-1,d6

	moveq	#0,d4				; Clear leading digit found flag
	lea	Art_HUDNumbers,a1		; HUD numbers art

.Loop:
	moveq	#0,d2				; Get current digit
	move.l	(a2)+,d3

.FindDigit:
	sub.l	d3,d1
	bcs.s	.GotDigit
	addq.w	#1,d2
	bra.s	.FindDigit

.GotDigit:
	add.l	d3,d1

	tst.w	d2				; Is this digit 0?
	beq.s	.NonZeroDigit			; If so, branch
	move.w	#1,d4				; Set leading digit found flag

.NonZeroDigit:
	move.l	d0,4(a6)			; Set VDP command
	tst.w	d4				; Has the leading digit been found?
	bne.s	.DrawDigit			; If so, branch
	tst.w	d6				; Is this the last digit?
	bne.s	.BlankTile			; If not, branch

.DrawDigit:
	lsl.w	#6,d2				; Draw digit
	lea	(a1,d2.w),a3
	rept	$40/4
		move.l	(a3)+,(a6)
	endr

.Next:
	addi.l	#$400000,d0			; Next digit slot
	dbf	d6,.Loop			; Loop until digits are drawn
	rts

.BlankTile:
	moveq	#$40/4-1,d5			; Draw blank digit

.BlankTileLoop:
	move.l	#0,(a6)
	dbf	d5,.BlankTileLoop
	bra.s	.Next				; Next slot

; -------------------------------------------------------------------------
; Draw rings counter
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - VDP command
;	d1.l - Number to draw
; -------------------------------------------------------------------------

HUD_DrawRings:
	lea	Hud_100,a2			; 3 digits
	moveq	#3-1,d6
	bra.s	HUD_DrawCounter

; -------------------------------------------------------------------------
; Draw score counter
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - VDP command
;	d1.l - Number to draw
; -------------------------------------------------------------------------

HUD_DrawScore:
	lea	Hud_100000,a2			; 6 digits
	moveq	#6-1,d6

; -------------------------------------------------------------------------
; Draw score or rings counter
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - VDP command
;	d1.l - Number to draw
;	d6.w - Number of digits (minus 1)
;	a2.l - Pointer to digit data
; -------------------------------------------------------------------------

HUD_DrawCounter:
	moveq	#0,d4				; Clear leading digit found flag
	lea	Art_HUDNumbers,a1		; HUD numbers art

.Loop:
	moveq	#0,d2				; Get current digit
	move.l	(a2)+,d3

.FindDigit:
	sub.l	d3,d1
	bcs.s	.GotDigit
	addq.w	#1,d2
	bra.s	.FindDigit

.GotDigit:
	add.l	d3,d1

	tst.w	d2				; Is this digit 0?
	beq.s	.NonZeroDigit			; If so, branch
	move.w	#1,d4				; Set leading digit found flag

.NonZeroDigit:
	tst.w	d4				; Has the leading digit been found?
	beq.s	.Next				; If not, branch

	lsl.w	#6,d2				; Draw digit
	move.l	d0,4(a6)
	lea	(a1,d2.w),a3
	rept	$40/4
		move.l	(a3)+,(a6)
	endr

.Next:
	addi.l	#$400000,d0			; Next digit slot
	dbf	d6,.Loop			; Loop until digits are drawn
	rts

; -------------------------------------------------------------------------
; Draw continue screen counter (leftover from Sonic 1)
; -------------------------------------------------------------------------

ContScrCounter:
	VDPCMD	move.l,$DF80,VRAM,WRITE,VDPCTRL	; Set VDP command
	lea	VDPDATA,a6			; VDP data port

	lea	Hud_10,a2			; 2 digits
	moveq	#1,d6

	moveq	#0,d4				; Clear leading digit found flag
	lea	Art_HUDNumbers,a1		; HUD numbers art

.Loop:
	moveq	#0,d2				; Get current digit
	move.l	(a2)+,d3

.FindDigit:
	sub.l	d3,d1
	bcs.s	.GotDigit
	addq.w	#1,d2
	bra.s	.FindDigit

.GotDigit:
	add.l	d3,d1

	lsl.w	#6,d2				; Draw digit
	lea	(a1,d2.w),a3
	rept	$40/4
		move.l	(a3)+,(a6)
	endr

	dbf	d6,.Loop			; Loop until digits are drawn
	rts

; -------------------------------------------------------------------------
; Digits
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
; Draw hexadecimal number
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - VDP command
;	d1.l - Number to draw
; -------------------------------------------------------------------------

HUD_DrawHexNum:
	moveq	#4-1,d6				; 4 digits
	lea	Hud_1000h,a2
	bra.s	HUD_DrawNum			; Draw number

; -------------------------------------------------------------------------
; Draw lives counter
; -------------------------------------------------------------------------
; PARAMETERS:
;	d1.l - Number to draw
; -------------------------------------------------------------------------

HUD_DrawLives:
	VDPCMD	move.l,$B4A0,VRAM,WRITE,d0	; Get VDP command

	moveq	#0,d1				; Get number of lives
	move.b	lives,d1
	cmpi.b	#9,d1				; Are there too many?
	bcs.s	.Draw				; If not, branch
	moveq	#9,d1				; Is so, cap it

.Draw:
	lea	Hud_1,a2			; 1 digit
	moveq	#1-1,d6
	bra.s	HUD_DrawNum			; Draw number

; -------------------------------------------------------------------------
; Draw minutes
; -------------------------------------------------------------------------
; PARAMETERS:
;	d1.l - Number to draw
; -------------------------------------------------------------------------

HUD_DrawMins:
	lea	Hud_1,a2			; 1 digit
	moveq	#1-1,d6
	bra.s	HUD_DrawNum			; Draw number

; -------------------------------------------------------------------------
; Draw seconds or centiseconds
; -------------------------------------------------------------------------
; PARAMETERS:
;	d1.l - Number to draw
; -------------------------------------------------------------------------

HUD_DrawSecs:
	lea	Hud_10,a2			; 2 digits
	moveq	#2-1,d6

; -------------------------------------------------------------------------
; Draw number
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - VDP command
;	d1.l - Number to draw
;	d6.w - Number of digits (minus 1)
;	a2.l - Pointer to digit data
; -------------------------------------------------------------------------

HUD_DrawNum:
	moveq	#0,d4				; Clear leading digit found flag
	lea	Art_HUDNumbers,a1		; HUD numbers art

.Loop:
	moveq	#0,d2				; Get current digit
	move.l	(a2)+,d3

.FindDigit:
	sub.l	d3,d1
	bcs.s	.GotDigit
	addq.w	#1,d2
	bra.s	.FindDigit

.GotDigit:
	add.l	d3,d1

	tst.w	d2				; Is this digit 0?
	beq.s	.NonZeroDigit			; If so, branch
	move.w	#1,d4				; Set leading digit found flag

.NonZeroDigit:
	lsl.w	#6,d2				; Draw digit
	move.l	d0,4(a6)
	lea	(a1,d2.w),a3
	rept	$40/4
		move.l	(a3)+,(a6)
	endr
	
	addi.l	#$400000,d0			; Next digit slot
	dbf	d6,.Loop			; Loop until digits are drawn
	rts

; -------------------------------------------------------------------------
