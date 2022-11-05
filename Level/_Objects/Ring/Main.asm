; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Ring object
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
	lea	savedObjFlags,a2
	moveq	#0,d0
	move.b	oSavedFlagsID(a0),d0
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
	cmpi.b	#6,zone
	bne.s	.NotMMZ
	move.b	#0,oPriority(a1)
	move.b	oSubtype2(a0),oSubtype2(a1)
	tst.b	oSubtype2(a1)
	beq.s	.NotMMZ
	andi.b	#$7F,oTile(a1)
	move.b	#2,oPriority(a1)

.NotMMZ:
	move.b	#%00000100,oSprFlags(a1)
	move.b	#$47,oColType(a1)
	move.b	#8,oWidth(a1)
	move.b	#8,oYRadius(a1)
	move.b	oSavedFlagsID(a0),oSavedFlagsID(a1)
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
	tst.b	oSprFlags(a0)
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
	lea	savedObjFlags,a2
	moveq	#0,d0
	move.b	oSavedFlagsID(a0),d0
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
	addq.w	#1,rings
	ori.b	#1,updateHUDRings
	move.w	#FM_RING,d0
	cmpi.w	#100,rings
	bcs.s	.PlaySound
	bset	#1,livesFlags
	beq.s	.GainLife
	cmpi.w	#200,rings
	bcs.s	.PlaySound
	bset	#2,livesFlags
	bne.s	.PlaySound

.GainLife:
	addq.b	#1,lives
	addq.b	#1,updateHUDLives
	move.w	#SCMD_YESSFX,d0
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
	move.w	rings,d5
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
	cmpi.b	#6,zone
	bne.s	.NotMMZ
	move.b	#0,oPriority(a1)
	tst.b	oSubtype2(a0)
	beq.s	.NotMMZ
	move.b	#3,oPriority(a1)
	andi.b	#$7F,oTile(a1)

.NotMMZ:
	move.b	#%00000100,oSprFlags(a1)
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
	move.w	#0,rings
	move.b	#$80,updateHUDRings
	move.b	#0,livesFlags
	move.w	#FM_RINGLOSS,d0
	jsr	PlayFMSound
; End of function ObjLostRing_Init

; -------------------------------------------------------------------------

ObjLostRing_Main:
	move.b	ringLossAnimFrame,oMapFrame(a0)
	bsr.w	ObjMove
	addi.w	#$18,oYVel(a0)
	bmi.s	.ChkDel
	move.b	levelVIntCounter+3,d0
	add.b	d7,d0
	andi.b	#3,d0
	bne.s	.ChkDel
	jsr	ObjGetFloorDist
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
	include	"Level/_Objects/Ring/Data/Animations.asm"
	even
MapSpr_Ring:
	include	"Level/_Objects/Ring/Data/Mappings.asm"
	even
MapSpr_S1BigRing:
	include	"Level/_Objects/Ring/Data/Mappings (Sonic 1 Big Ring).asm"
	even
MapSpr_S1BigRingFlash:
	include	"Level/_Objects/Ring/Data/Mappings (Sonic 1 Big Ring Flash).asm"
	even

; -------------------------------------------------------------------------
