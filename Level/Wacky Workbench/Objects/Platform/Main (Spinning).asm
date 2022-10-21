; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Spinning platform object
; -------------------------------------------------------------------------

oSPtfmY		EQU	oVar32
oSPtfmX		EQU	oVar36
oSPtfm3A	EQU	oVar3A

; -------------------------------------------------------------------------

ObjSpinPlatform:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	jsr	DrawObject
	move.w	oSPtfmX(a0),d0
	jmp	CheckObjDespawn2

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjSpinPlatform_Init-.Index
	dc.w	ObjSpinPlatform_Main-.Index

; -------------------------------------------------------------------------

ObjSpinPlatform_Solid:
	move.w	oX(a0),d3
	move.w	oY(a0),d4
	jmp	TopSolidObject

; -------------------------------------------------------------------------

ObjSpinPlatform_Init:
	ori.b	#4,oSprFlags(a0)
	move.b	#1,oPriority(a0)
	move.w	#$436A,oTile(a0)
	move.l	#MapSpr_SpinPlatform,oMap(a0)
	move.w	oX(a0),oSPtfmX(a0)
	move.w	oY(a0),oSPtfmY(a0)
	move.b	#12,oYRadius(a0)
	move.b	#16,oWidth(a0)
	addq.b	#2,oRoutine(a0)

; -------------------------------------------------------------------------

ObjSpinPlatform_Main:
	bsr.w	ObjSpinPlatform_Move

	lea	Ani_SpinPlatform(pc),a1
	jsr	AnimateObject

	lea	objPlayerSlot.w,a1
	bsr.w	ObjSpinPlatform_Solid
	beq.s	.End

	bset	#0,oFlags(a1)
	andi.b	#$FC,oSprFlags(a1)
	ori.b	#1,oSprFlags(a1)
	bset	#0,oPlayerCtrl(a1)
	bne.s	.AlreadySpinning
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

.AlreadySpinning:
	cmpi.b	#6,oRoutine(a1)
	bcc.s	.End
	bra.s	ObjSpinPlatform_MoveSonic

.End:
	rts

; -------------------------------------------------------------------------

ObjSpinPlatform_CheckYDist:
	moveq	#0,d0
	move.b	oYRadius(a1),d0
	add.w	oY(a1),d0
	sub.w	oY(a0),d0
	bmi.s	.Away
	cmpi.w	#16,d0
	bcs.s	.Away

.Near:
	moveq	#-1,d0
	rts

.Away:
	moveq	#0,d0
	rts

; -------------------------------------------------------------------------

ObjSpinPlatform_MoveSonic:
	addq.b	#4,oPlayerRotAngle(a1)
	move.b	oPlayerRotAngle(a1),d0
	jsr	CalcSine

	moveq	#0,d0
	move.b	oPlayerRotDist(a1),d0
	muls.w	d1,d0
	asr.l	#8,d0
	move.w	oX(a0),oX(a1)
	add.w	d0,oX(a1)

	moveq	#0,d0
	move.b	oPlayerRotAngle(a1),d0
	move.b	d0,d1
	andi.b	#$F0,d0
	lsr.b	#4,d0
	move.b	.PlayerFrames(pc,d0.w),oAnimFrame(a1)
	andi.b	#$3F,d1
	bne.s	.ChkInput
	addq.b	#1,oPlayerRotDist(a1)

.ChkInput:
	move.w	p1CtrlData.w,playerCtrl.w
	cmpi.b	#1,oID(a1)
	beq.s	.NotPlayer2
	move.w	p2CtrlData.w,playerCtrl.w

.NotPlayer2:
	bsr.w	ObjSpinPlatform_CheckDirs
	bra.w	ObjSpinPlatform_CheckJump

	rts

; -------------------------------------------------------------------------

.PlayerFrames:
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	1
	dc.b	1
	dc.b	2
	dc.b	2
	dc.b	2
	dc.b	3
	dc.b	3
	dc.b	3
	dc.b	4
	dc.b	4
	dc.b	5
	dc.b	5
	dc.b	5

; -------------------------------------------------------------------------

ObjSpinPlatform_CheckDirs:
	move.w	oX(a1),d0
	sub.w	oX(a0),d0
	bcc.s	.ChkRight2
	btst	#2,playerCtrlHold.w
	beq.s	.ChkRight
	addq.b	#1,oPlayerRotDist(a1)
	bra.s	.End

.ChkRight:
	btst	#3,playerCtrlHold.w
	beq.s	.End
	subq.b	#1,oPlayerRotDist(a1)
	bcc.s	.End
	clr.b	oPlayerRotDist(a1)
	bra.s	.End

.ChkRight2:
	btst	#3,playerCtrlHold.w
	beq.s	.ChkLeft
	addq.b	#1,oPlayerRotDist(a1)
	bra.s	.End

.ChkLeft:
	btst	#2,playerCtrlHold.w
	beq.s	.End
	subq.b	#1,oPlayerRotDist(a1)
	bcc.s	.End
	clr.b	oPlayerRotDist(a1)

.End:
	rts

; -------------------------------------------------------------------------

ObjSpinPlatform_CheckJump:
	move.b	playerCtrlTap.w,d0
	andi.b	#$70,d0
	beq.w	.End

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

	bset	#1,oFlags(a1)
	bclr	#5,oFlags(a1)
	move.b	#1,oPlayerJump(a1)
	clr.b	oPlayerStick(a1)
	tst.b	miniSonic
	beq.s	.NotMini
	move.b	#$A,oYRadius(a1)
	move.b	#5,oXRadius(a1)
	bra.s	.GotSize

.NotMini:
	move.b	#$13,oYRadius(a1)
	move.b	#9,oXRadius(a1)

.GotSize:
	btst	#2,oFlags(a1)
	bne.s	.RollJump
	tst.b	miniSonic
	beq.s	.NotMini2
	move.b	#$A,oYRadius(a1)
	move.b	#5,oXRadius(a1)
	bra.s	.SetRoll

.NotMini2:
	move.b	#$E,oYRadius(a1)
	move.b	#7,oXRadius(a1)
	addq.w	#5,oY(a1)

.SetRoll:
	bset	#2,oFlags(a1)
	move.b	#2,oAnim(a1)

.End:
	rts

.RollJump:
	bset	#4,oFlags(a1)
	rts

; -------------------------------------------------------------------------

ObjSpinPlatform_Move:
	moveq	#0,d0
	move.b	oSubtype(a0),d0
	add.w	d0,d0
	move.w	.MoveTypes(pc,d0.w),d0
	jmp	.MoveTypes(pc,d0.w)

; -------------------------------------------------------------------------

.MoveTypes:
	dc.w	ObjSpinPlatform_MoveX-.MoveTypes
	dc.w	ObjSpinPlatform_MoveX2-.MoveTypes
	dc.w	ObjSpinPlatform_MoveY-.MoveTypes
	dc.w	ObjSpinPlatform_MoveY2-.MoveTypes

; -------------------------------------------------------------------------

ObjSpinPlatform_MoveY:
	bsr.w	ObjSpinPlatform_GetOffset
	neg.w	d0
	add.w	oSPtfmY(a0),d0
	move.w	d0,oY(a0)
	rts

; -------------------------------------------------------------------------

ObjSpinPlatform_MoveY2:
	bsr.w	ObjSpinPlatform_GetOffset
	add.w	oSPtfmY(a0),d0
	move.w	d0,oY(a0)
	rts

; -------------------------------------------------------------------------

ObjSpinPlatform_MoveX:
	move.l	oX(a0),-(sp)
	bsr.w	ObjSpinPlatform_GetOffset
	add.w	oSPtfmX(a0),d0
	move.w	d0,oX(a0)

	move.l	oX(a0),d0
	sub.l	(sp)+,d0
	lsr.l	#8,d0
	move.w	d0,oXVel(a0)
	rts

; -------------------------------------------------------------------------

ObjSpinPlatform_MoveX2:
	move.l	oX(a0),-(sp)
	bsr.w	ObjSpinPlatform_GetOffset
	neg.w	d0
	add.w	oSPtfmX(a0),d0
	move.w	d0,oX(a0)

	move.l	oX(a0),d0
	sub.l	(sp)+,d0
	lsr.l	#8,d0
	move.w	d0,oXVel(a0)
	rts

; -------------------------------------------------------------------------

ObjSpinPlatform_GetOffset:
	move.w	levelFrames,d0
	andi.w	#$FF,d0
	jsr	CalcSine
	add.w	d0,d0
	add.w	d0,d0
	asr.w	#4,d0

	addq.b	#1,oSPtfm3A(a0)
	rts

; -------------------------------------------------------------------------

Ani_SpinPlatform:
	include	"Level/Wacky Workbench/Objects/Platform/Data/Animations (Spinning).asm"
	even

MapSpr_SpinPlatform:
	include	"Level/Wacky Workbench/Objects/Platform/Data/Mappings (Spinning).asm"
	even

; -------------------------------------------------------------------------
