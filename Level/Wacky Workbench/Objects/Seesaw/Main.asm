; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Seesaw object
; -------------------------------------------------------------------------

oSeesawParent	EQU	oVar2A
oSeesawPtfm1	EQU	oVar2A
oSeesawPtfm2	EQU	oVar2C
oSeesawTime	EQU	oVar2E
oSeesawStood	EQU	oVar3F

; -------------------------------------------------------------------------

ObjSeesaw:
	tst.b	oSubtype(a0)
	bne.w	ObjSeesawPtfm

	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)
	
	jsr	DrawObject
	jmp	CheckObjDespawn
	
; -------------------------------------------------------------------------

.Index:
	dc.w	ObjSeesaw_Init-.Index
	dc.w	ObjSeesaw_Main-.Index
	dc.w	ObjSeesaw_PushUp-.Index
	
; -------------------------------------------------------------------------

ObjSeesaw_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oSprFlags(a0)
	move.b	#3,oPriority(a0)
	move.b	#24,oXRadius(a0)
	move.b	#24,oWidth(a0)
	move.b	#24,oYRadius(a0)
	move.w	#$3B8,oTile(a0)
	move.l	#MapSpr_Seesaw,oMap(a0)

	jsr	FindObjSlot
	bne.w	ObjSeesaw_Delete
	bsr.w	ObjSeesaw_InitSub
	move.w	a1,oSeesawPtfm1(a0)
	subi.w	#40,oX(a1)
	subi.w	#24,oY(a1)

	jsr	FindObjSlot
	bne.w	ObjSeesaw_Delete
	bsr.w	ObjSeesaw_InitSub
	move.w	a1,oSeesawPtfm2(a0)
	addi.w	#40,oX(a1)
	addi.w	#24,oY(a1)
	bset	#0,oSprFlags(a1)
	bset	#0,oFlags(a1)
	rts

; -------------------------------------------------------------------------

ObjSeesaw_InitSub:
	move.b	oID(a0),oID(a1)
	move.b	oSprFlags(a0),oSprFlags(a1)
	move.b	oPriority(a0),oPriority(a1)
	move.w	oTile(a0),oTile(a1)
	move.l	oMap(a0),oMap(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	move.b	#-1,oSubtype(a1)
	move.b	#16,oXRadius(a1)
	move.b	#16,oWidth(a1)
	move.b	#8,oYRadius(a1)
	move.b	#9,oMapFrame(a1)
	move.w	a0,oSeesawParent(a1)
	move.w	#120,oSeesawTime(a0)
	rts

; -------------------------------------------------------------------------

ObjSeesaw_Main:
	lea	ObjSeesaw_CheckSlideDown(pc),a1
	tst.w	oYVel(a0)
	beq.s	.RunRoutine
	lea	ObjSeesaw_SlideDown(pc),a1

.RunRoutine:
	jsr	(a1)

	move.w	a0,-(sp)
	movea.w	oSeesawPtfm2(a0),a0
	lea	objPlayerSlot.w,a1
	jsr	TopSolidObject
	jsr	DrawObject
	movea.w	(sp)+,a0

	move.w	a0,-(sp)
	movea.w	oSeesawPtfm1(a0),a0
	lea	objPlayerSlot.w,a1
	jsr	TopSolidObject
	sne	oSeesawStood(a0)
	jsr	DrawObject
	movea.w	(sp)+,a0

	movea.w	oSeesawPtfm1(a0),a1
	tst.b	oSeesawStood(a1)
	bne.s	.StoodOn

	lea	Ani_Seesaw(pc),a1
	jmp	AnimateObject

.StoodOn:
	move.b	#4,oRoutine(a0)
	move.w	#3,oSeesawTime(a0)
	move.b	#8,oMapFrame(a0)
	rts

; -------------------------------------------------------------------------

ObjSeesaw_CheckSlideDown:
	tst.w	oSeesawTime(a0)
	bmi.s	.End
	subq.w	#1,oSeesawTime(a0)
	bmi.s	.SlideDown
	cmpi.w	#60,oSeesawTime(a0)
	beq.s	.Animate
	bra.s	.End

.SlideDown:
	move.w	#$100,oYVel(a0)

.Animate:
	addq.b	#1,oAnim(a0)

.End:
	rts

; -------------------------------------------------------------------------

ObjSeesaw_SlideDown:
	movea.w	oSeesawPtfm1(a0),a1
	movea.w	oSeesawPtfm2(a0),a2

	moveq	#0,d0
	move.b	oYVel(a0),d0
	add.w	d0,oY(a0)
	add.w	d0,oY(a1)
	add.w	d0,oY(a2)

	moveq	#0,d0
	move.b	oWidth(a2),d0
	move.w	oX(a2),d3
	cmp.w	oX(a0),d3
	blt.s	.CheckFloor
	neg.w	d0

.CheckFloor:
	add.w	d0,d3
	
	move.w	a0,-(sp)
	movea.w	a2,a0
	jsr	ObjGetFloorDist2
	movea.w	(sp)+,a0
	tst.w	d1
	bmi.s	.Landed
	rts

.Landed:
	movea.w	oSeesawPtfm1(a0),a1
	movea.w	oSeesawPtfm2(a0),a2
	add.w	d1,oY(a0)
	add.w	d1,oY(a1)
	add.w	d1,oY(a2)
	move.w	#0,oYVel(a0)
	rts

; -------------------------------------------------------------------------

ObjSeesaw_PushUp:
	movea.w	oSeesawPtfm2(a0),a1
	subi.w	#24,oY(a1)
	subi.w	#12,oY(a0)

	subq.w	#1,oSeesawTime(a0)
	bpl.s	.Draw
	bsr.s	ObjSeesaw_Swap

.Draw:
	move.w	a0,-(sp)
	movea.w	oSeesawPtfm2(a0),a0
	jsr	DrawObject
	movea.w	(sp),a0

	movea.w	oSeesawPtfm1(a0),a0
	jsr	DrawObject
	movea.w	(sp)+,a0

	rts

; -------------------------------------------------------------------------

ObjSeesaw_Swap:
	move.b	#2,oRoutine(a0)
	move.w	#0,oYVel(a0)
	move.w	#120,oSeesawTime(a0)
	move.w	oSeesawPtfm1(a0),oSeesawPtfm2(a0)
	move.w	a1,oSeesawPtfm1(a0)

	moveq	#0,d0
	cmpi.b	#2,oAnim(a0)
	bgt.s	.SetAnim
	moveq	#3,d0

.SetAnim:
	move.b	d0,oAnim(a0)
	move.b	#-1,oPrevAnim(a0)
	rts

; -------------------------------------------------------------------------

ObjSeesawPtfm:
	movea.w	oSeesawParent(a0),a1
	cmpi.b	#$2C,oID(a1)
	bne.s	ObjSeesaw_Delete
	rts

; -------------------------------------------------------------------------

ObjSeesaw_Delete:
	jmp	DeleteObject

; -------------------------------------------------------------------------

Ani_Seesaw:
	include	"Level/Wacky Workbench/Objects/Seesaw/Data/Animations.asm"
	even
	
MapSpr_Seesaw:
	include	"Level/Wacky Workbench/Objects/Seesaw/Data/Mappings.asm"
	even
	
; -------------------------------------------------------------------------
