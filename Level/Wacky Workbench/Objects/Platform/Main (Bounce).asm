; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Bouncing platform object
; -------------------------------------------------------------------------

oBPtfmYRad	EQU	oVar2E
oBPftmYVel	EQU	oVar30
oBPtfmGrav	EQU	oVar3E

; -------------------------------------------------------------------------

ObjBouncePlatform:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	jsr	DrawObject
	jmp	CheckObjDespawn

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjBouncePlatform_Init-.Index
	dc.w	ObjBouncePlatform_Main-.Index
	dc.w	ObjBouncePlatform_Bounced-.Index
	dc.w	ObjBouncePlatform_Landed-.Index

; -------------------------------------------------------------------------

ObjBouncePlatform_JmpToSolid:
	jmp	ObjBouncePlatform_Solid

; -------------------------------------------------------------------------

ObjBouncePlatform_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oSprFlags(a0)
	move.b	#3,oPriority(a0)
	move.w	#$43E8,oTile(a0)
	move.l	#MapSpr_BouncePlatform,oMap(a0)
	move.b	#16,oYRadius(a0)
	move.b	#32,oWidth(a0)

; -------------------------------------------------------------------------

ObjBouncePlatform_Main:
	jsr	ObjBouncePlatform_CheckFloor(pc)
	bne.s	.NoBounce
	move.w	#-$600,oYVel(a0)
	move.w	#$10,oBPtfmGrav(a0)
	addq.b	#2,oRoutine(a0)

.NoBounce:
	bra.w	ObjBouncePlatform_JmpToSolid

; -------------------------------------------------------------------------

ObjBouncePlatform_Bounced:
	jsr	ObjBouncePlatform_Move(pc)
	jsr	ObjGetCeilDist
	tst.w	d1
	bpl.s	.CheckFloor
	clr.w	oYVel(a0)

.CheckFloor:
	jsr	ObjGetFloorDist
	tst.w	d1
	bpl.s	.Solid
	jsr	ObjBouncePlatform_CheckFloor(pc)
	bne.s	.Landed
	move.w	#-$600,oYVel(a0)
	move.w	#$10,oBPtfmGrav(a0)
	btst	#7,oSprFlags(a0)
	beq.s	.Solid
	move.w	#FM_B4,d0
	jsr	PlayFMSound
	bra.s	.Solid

.Landed:
	move.w	#-$180,oYVel(a0)
	move.w	#$10,oBPtfmGrav(a0)
	addq.b	#2,oRoutine(a0)

.Solid:
	bra.w	ObjBouncePlatform_JmpToSolid

; -------------------------------------------------------------------------

ObjBouncePlatform_Landed:
	jsr	ObjBouncePlatform_Move(pc)
	tst.w	oYVel(a0)
	bmi.s	.Solid
	jsr	ObjGetFloorDist
	tst.w	d1
	bpl.s	.Solid
	clr.w	oYVel(a0)
	clr.w	oBPtfmGrav(a0)
	subq.b	#4,oRoutine(a0)

.Solid:
	bra.w	ObjBouncePlatform_JmpToSolid

; -------------------------------------------------------------------------

ObjBouncePlatform_Move:
	move.w	oYVel(a0),d0
	add.w	oBPtfmGrav(a0),d0
	bmi.s	.MoveY
	cmpi.w	#$600,d0
	bcs.s	.MoveY
	move.w	#$600,d0

.MoveY:
	move.w	d0,oYVel(a0)
	ext.l	d0
	asl.l	#8,d0
	add.l	d0,oY(a0)
	rts

; -------------------------------------------------------------------------

ObjBouncePlatform_CheckFloor:
	cmpi.b	#2,timeZone
	bcc.s	.Bounce
	move.b	#$3C,d0
	tst.b	timeZone
	beq.s	.Check
	addi.b	#$1E,d0

.Check:
	cmp.b	palCycleSteps+3.w,d0
	beq.s	.NoBounce

.Bounce:
	moveq	#0,d0
	rts

.NoBounce:
	moveq	#-1,d0
	rts

; -------------------------------------------------------------------------

MapSpr_BouncePlatform:
	include	"Level/Wacky Workbench/Objects/Platform/Data/Mappings (Bounce).asm"
	even

; -------------------------------------------------------------------------

ObjBouncePlatform_Solid:
	lea	objPlayerSlot.w,a1
	move.w	oYVel(a1),d0
	bpl.s	.NotNeg
	neg.w	d0
	cmpi.w	#$600,d0
	bgt.w	.End

.NotNeg:
	tst.w	oYVel(a0)
	beq.s	.NotMoving
	move.b	#4,oBPtfmYRad(a0)
	bra.s	.DoSolid

.NotMoving:
	move.b	#0,oBPtfmYRad(a0)

.DoSolid:
	move.b	oBPtfmYRad(a0),d0
	add.b	d0,oYRadius(a0)

	lea	objPlayerSlot.w,a1
	bsr.s	.Solid

	move.b	oBPtfmYRad(a0),d0
	sub.b	d0,oYRadius(a0)
	rts

; -------------------------------------------------------------------------

.Solid:
	move.w	oYVel(a1),oBPftmYVel(a0)
	btst	#3,oFlags(a1)
	beq.s	.CheckSolid
	btst	#1,oFlags(a1)
	bne.s	.CheckSolid
	clr.w	oYVel(a1)

.CheckSolid:
	jsr	SolidObject
	bne.s	.StoodOn
	move.w	oBPftmYVel(a0),oYVel(a1)

.End:
	rts

.StoodOn:
	cmpi.b	#6,oRoutine(a1)
	bcc.s	.StopYVel

	move.l	oY(a0),oY(a1)
	move.b	oYRadius(a1),d0
	ext.w	d0
	addi.w	#$10,d0
	sub.w	d0,oY(a1)
	tst.w	oYVel(a0)
	bge.s	.StopYVel
	move.w	oYVel(a0),oYVel(a1)
	rts

.StopYVel:
	clr.w	oYVel(a1)
	rts

; -------------------------------------------------------------------------
