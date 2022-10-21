; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Level HUD/points object
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
	ori.b	#4,oSprFlags(a0)
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
	include	"Level/_Objects/HUD and Points/Data/Mappings (Points).asm"
	even
; -------------------------------------------------------------------------

ObjHUDPoints:
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
	tst.w	rings
	beq.s	.ChkFlashRings
	bclr	#5,oTile(a0)
	bra.s	.Display

; -------------------------------------------------------------------------

.ChkFlashRings:
	move.b	levelVIntCounter+3,d0
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
	include	"Level/_Objects/HUD and Points/Data/Mappings (HUD).asm"
	even
; -------------------------------------------------------------------------

AddPoints:
	move.b	#1,updateHUDScore
	lea	score,a3
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
	addq.b	#1,lives
	addq.b	#1,updateHUDLives
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
	move.b	savedObjFlags,d1
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
	move.w	debugBlock,d1
	andi.w	#$7FF,d1
	lea	Hud_100,a2
	moveq	#2,d6
	bsr.w	Hud_Digits
	bra.w	.ChkTime

; -------------------------------------------------------------------------

.NormalHUD:
	tst.b	updateHUDScore
	beq.s	.ChkRings
	bpl.s	.UpdateScore
	bsr.w	Hud_Base

.UpdateScore:
	clr.b	updateHUDScore
	move.l	#$70600002,d0
	move.l	score,d1
	bsr.w	Hud_Score

.ChkRings:
	tst.b	updateHUDRings
	beq.s	.ChkTime
	bpl.s	.UpdateRings
	bsr.w	Hud_InitRings

.UpdateRings:
	clr.b	updateHUDRings
	move.l	#$73600002,d0
	moveq	#0,d1
	move.w	rings,d1
	cmpi.w	#1000,d1
	bcs.s	.CappedRings
	move.w	#999,d1
	move.w	d1,rings

.CappedRings:
	bsr.w	Hud_Rings

.ChkTime:
	tst.w	debugCheat
	bne.w	.ChkLives
	tst.b	updateHUDTime
	beq.w	.ChkLives
	tst.w	paused.w
	bne.w	.ChkLives
	lea	time,a1
	cmpi.l	#(9<<16)|(59<<8)|59,(a1)+
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
	move.b	timeMinutes,d1
	bsr.w	Hud_Mins
	move.l	#$72600002,d0
	moveq	#0,d1
	move.b	timeSeconds,d1
	bsr.w	Hud_SecsCentisecs
	move.l	#$72E00002,d0
	moveq	#0,d1
	move.b	timeFrames,d1
	mulu.w	#100,d1
	divu.w	#60,d1
	swap	d1
	move.w	#0,d1
	swap	d1
	cmpi.l	#(9<<16)|(59<<8)|59,time
	bne.s	.UpdateCentisecs
	move.w	#99,d1

.UpdateCentisecs:
	bsr.w	Hud_SecsCentisecs

.ChkLives:
	tst.b	updateHUDLives
	beq.s	.ChkBonus
	clr.b	updateHUDLives
	bsr.w	Hud_Lives

.ChkBonus:
	tst.b	updateHUDBonus.w
	beq.s	.End
	clr.b	updateHUDBonus.w
	move.l	#$47800002,d0
	cmpi.w	#$502,zoneAct
	bne.s	.GotVRAMLoc
	move.l	#$6D400001,d0

.GotVRAMLoc:
	moveq	#0,d1
	move.w	bonusCount1.w,d1
	bsr.w	Hud_Bonus
	move.l	#$48C00002,d0
	cmpi.w	#$502,zoneAct
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
	clr.b	updateHUDTime
	move.l	#0,time
	lea	objPlayerSlot.w,a0
	movea.l	a0,a2
	bsr.w	KillPlayer
	move.b	#1,timeOver

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
	lea	Art_HUDNumbers,a1

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
	lea	Art_HUDNumbers,a1

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
	lea	Art_HUDNumbers,a1

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
	lea	Art_HUDNumbers,a1

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
	move.b	lives,d1
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
	lea	Art_HUDNumbers,a1

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
