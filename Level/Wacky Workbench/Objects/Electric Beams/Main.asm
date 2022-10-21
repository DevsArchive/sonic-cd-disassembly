; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Electric beams object
; -------------------------------------------------------------------------

oBeamCharge	EQU	oVar2E
oBeamChargeTime	EQU	oVar30
oBeamTime	EQU	oVar3A
oBeamMode	EQU	oVar3C
oBeamFlash	EQU	oVar3E
oBeamBGFlash	EQU	oVar3F

; -------------------------------------------------------------------------

ObjElectricBeams:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	jsr	DrawObject
	jmp	CheckObjDespawn

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjElectricBeams_Init-.Index
	dc.w	ObjElectricBeams_Main-.Index
	dc.w	ObjElectricBeams_Flash-.Index

; -------------------------------------------------------------------------

ObjElectricBeams_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oSprFlags(a0)
	move.b	#4,oPriority(a0)
	move.w	#$6358,oTile(a0)
	move.l	#MapSpr_ElectricBeams,oMap(a0)
	move.b	#16,oYRadius(a0)
	move.b	#16,oWidth(a0)
	move.b	oSubtype(a0),oMapFrame(a0)
	bsr.w	ObjElectricBeams_SpawnHandler

; -------------------------------------------------------------------------

ObjElectricBeams_Main:
	tst.b	oSubtype(a0)
	beq.s	.End

.Handler:
	bsr.w	ObjElectricBeams_StickToPlayer

	tst.w	oBeamTime(a0)
	bne.s	.CheckFlash

	bsr.w	ObjElectricBeams_RestorePal
	cmpi.b	#2,timeZone
	bne.s	.NotFuture
	tst.b	goodFuture
	bne.s	.End

.NotFuture:
	tst.b	act
	bne.s	.NotAct1
	move.w	cameraY.w,d0
	cmpi.w	#$400,d0
	bcc.s	.End

.NotAct1:
	move.w	#360,d0
	move.b	timeZone,d1
	beq.s	.SetTimer
	move.w	#480,d0
	subq.b	#1,d1
	beq.s	.SetTimer
	move.w	#240,d0

.SetTimer:
	move.w	d0,oBeamTime(a0)

.End:
	rts

.CheckFlash:
	subq.w	#1,oBeamTime(a0)
	bne.s	.End

	addq.b	#2,oRoutine(a0)
	move.w	#120,oBeamTime(a0)
	move.w	#90,oBeamChargeTime(a0)
	clr.b	oBeamCharge(a0)

	btst	#7,oSprFlags(a0)
	beq.s	ObjElectricBeams_Flash
	move.w	#FM_B2,d0
	jsr	PlayFMSound

; -------------------------------------------------------------------------

ObjElectricBeams_Flash:
	bsr.w	ObjElectricBeams_StickToPlayer

	tst.w	oBeamChargeTime(a0)
	beq.s	.Flash
	move.b	oBeamMode(a0),d0
	bsr.w	ObjElectricBeams_ChargePal
	subq.w	#1,oBeamChargeTime(a0)
	beq.s	.ChargedUp
	rts

.ChargedUp:
	bsr.w	ObjElectricBeams_RestorePal

.Flash:
	move.b	oBeamMode(a0),d0
	addq.b	#1,d0
	move.b	d0,wwzBeamMode

	moveq	#0,d0
	move.b	oBeamMode(a0),d0
	bsr.w	ObjElectricBeams_FlashPal

	subq.w	#1,oBeamTime(a0)
	bne.s	.End

	subq.b	#2,oRoutine(a0)
	clr.b	wwzBeamMode
	addq.b	#1,oBeamMode(a0)
	cmpi.b	#3,oBeamMode(a0)
	bcs.s	.End
	clr.b	oBeamMode(a0)
	clr.w	oBeamFlash(a0)

.End:
	rts

; -------------------------------------------------------------------------

ObjElectricBeams_StickToPlayer:
	lea	objPlayerSlot.w,a1
	move.w	oX(a1),oX(a0)
	move.w	oY(a1),oY(a0)
	rts

; -------------------------------------------------------------------------

ObjElectricBeams_SpawnHandler:
	lea	dynObjects.w,a1
	move.w	#$60-1,d0

.FindHandler:
	cmpi.b	#$21,oID(a1)
	bne.s	.NextObj
	tst.b	oSubtype(a1)
	bne.s	.End

.NextObj:
	lea	oSize(a1),a1
	dbf	d0,.FindHandler

.NotFound:
	jsr	FindObjSlot
	bne.s	.End
	move.b	#$21,oID(a1)
	move.b	#1,oSubtype(a1)
	lea	objPlayerSlot.w,a2
	move.w	oX(a2),oX(a1)
	move.w	oY(a2),oY(a1)

.End:
	rts

; -------------------------------------------------------------------------

ObjElectricBeams_RestorePal:
	lea	palette+$40.w,a3
	move.w	#$626,d0
	move.w	#$646,d2
	move.b	timeZone,d1
	beq.s	.RestorePal
	
	lea	palette+$7A.w,a3
	move.w	#$222,d0
	move.w	#$680,d2
	subq.b	#1,d1
	beq.s	.RestorePal
	
	move.w	#$402,d0
	move.w	#$246,d2
	tst.b	goodFuture
	beq.s	.RestorePal

	rts

.RestorePal:
	lea	palette+$64.w,a2
	move.w	d0,(a2)+
	move.w	d0,(a2)+
	move.w	d0,(a2)+
	move.w	d2,(a3)+
	rts

; -------------------------------------------------------------------------

ObjElectricBeams_ModeColors:
	dc.b	0
	dc.b	2
	dc.b	4
	even

; -------------------------------------------------------------------------

ObjElectricBeams_FlashPal:
	move.b	ObjElectricBeams_ModeColors(pc,d0.w),d0
	lea	palette+$64.w,a2
	lea	(a2,d0.w),a2

	lea	.PastBeamColors,a1
	move.b	timeZone,d1
	beq.s	.FlashBeams
	lea	.PresentBeamColors,a1
	subq.b	#1,d1
	beq.s	.FlashBeams
	lea	.FutureBeamColors,a1

.FlashBeams:
	moveq	#0,d1
	move.b	oBeamFlash(a0),d1
	add.b	d1,d1
	lea	(a1,d1.w),a1
	move.w	(a1)+,(a2)+

	addq.b	#1,oBeamFlash(a0)
	move.w	(a1),d1
	cmpi.w	#-1,d1
	bne.s	.GetBGFlash
	clr.b	oBeamFlash(a0)

.GetBGFlash:
	lea	palette+$40.w,a2
	lea	.PastBGColors,a1
	move.b	timeZone,d1
	beq.s	.FlashBG
	lea	palette+$7A.w,a2
	lea	.PresentBGColors,a1
	subq.b	#1,d1
	beq.s	.FlashBG
	lea	.FutureBGColors,a1

.FlashBG:
	moveq	#0,d1
	move.b	oBeamBGFlash(a0),d1
	add.b	d1,d1
	lea	(a1,d1.w),a1
	move.w	(a1)+,(a2)+

	addq.b	#1,oBeamBGFlash(a0)
	move.w	(a1),d1
	cmpi.w	#-1,d1
	bne.s	.End
	clr.b	oBeamBGFlash(a0)

.End:
	rts

; -------------------------------------------------------------------------

.PresentBeamColors:
	dc.w	0, $EE0
	dc.w	0, $EE
	dc.w	0, $E0E
	dc.w	0
	dc.w	-1

.PresentBGColors:
	dc.w	$A60, $AA0
	dc.w	$A60, $AA0
	dc.w	-1

.PastBeamColors:
	dc.w	0, $EE0
	dc.w	0, $EE
	dc.w	0, $E0E
	dc.w	0
	dc.w	-1

.PastBGColors:
	dc.w	$846, $84A
	dc.w	$846, $84A
	dc.w	-1

.FutureBeamColors:
	dc.w	0, $EE0
	dc.w	0, $EE
	dc.w	0, $E0E
	dc.w	0
	dc.w	-1

.FutureBGColors:
	dc.w	$244, $248
	dc.w	$244, $248
	dc.w	-1

; -------------------------------------------------------------------------

ObjElectricBeams_ChargePal:
	move.b	.ModeColors(pc,d0.w),d0
	lea	palette+$64.w,a2
	lea	(a2,d0.w),a2

	move.w	#$80,d0
	tst.b	oBeamCharge(a0)
	beq.s	.ChargeBeam
	moveq	#0,d0

.ChargeBeam:
	move.w	d0,(a2)
	eori.b	#1,oBeamCharge(a0)
	rts

; -------------------------------------------------------------------------

.ModeColors:
	dc.b	0
	dc.b	2
	dc.b	4
	even

; -------------------------------------------------------------------------

MapSpr_ElectricBeams:
	include	"Level/Wacky Workbench/Objects/Electric Beams/Data/Mappings.asm"
	even

; -------------------------------------------------------------------------
