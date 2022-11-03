; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Semi object
; -------------------------------------------------------------------------

oSemiXVel	EQU	oVar2A
oSemiYVel	EQU	oVar2E
oSemiTime	EQU	oVar32
oSemiPlayerX	EQU	oVar34

; -------------------------------------------------------------------------

ObjSemi:
	tst.b	oSubtype2(a0)
	bmi.w	ObjSemiBomb
	
	jsr	DestroyOnGoodFuture

	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	jsr	DrawObject
	jmp	CheckObjDespawn

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjSemi_Init-.Index
	dc.w	ObjSemi_Wait-.Index
	dc.w	ObjSemi_WaitPlayer-.Index
	dc.w	ObjSemi_StartMove-.Index
	dc.w	ObjSemi_Move-.Index
	dc.w	ObjSemi_StartAttack-.Index
	dc.w	ObjSemi_Attack-.Index

; -------------------------------------------------------------------------

ObjSemi_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oSprFlags(a0)
	move.b	#1,oPriority(a0)
	move.b	#16,oYRadius(a0)
	move.b	#19,oXRadius(a0)
	move.b	#19,oWidth(a0)
	move.w	#$A4A8,oTile(a0)
	move.b	#$36,oColType(a0)
	move.b	oSubtype2(a0),oSemiTime+1(a0)
	
	lea	MapSpr_Semi(pc),a1
	tst.b	oSubtype(a0)
	beq.s	.NotDamaged
	lea	MapSpr_SemiDamaged(pc),a1
	
.NotDamaged:
	move.l	a1,oMap(a0)

; -------------------------------------------------------------------------

ObjSemi_Wait:
	subq.w	#1,oSemiTime(a0)
	bpl.s	.End
	addq.b	#2,oRoutine(a0)
	
.End:
	rts

; -------------------------------------------------------------------------

ObjSemi_WaitPlayer:
	lea	objPlayerSlot.w,a1
	bsr.s	ObjSemi_CheckPlayer
	bcc.s	.End
	addq.b	#2,oRoutine(a0)
	
.End:
	rts

; -------------------------------------------------------------------------

ObjSemi_CheckPlayer:
	move.w	oY(a1),d0
	sub.w	oY(a0),d0
	subi.w	#-96,d0
	subi.w	#192,d0
	bcc.s	.End
	
	move.w	oX(a1),d0
	sub.w	oX(a0),d0
	move.w	d0,oSemiPlayerX(a0)
	subi.w	#-120,d0
	subi.w	#240,d0

.End:
	rts

; -------------------------------------------------------------------------

ObjSemi_StartMove:
	addq.b	#2,oRoutine(a0)
	move.l	#$10000,d0
	move.l	#-$8000,d1
	move.w	#96,d2
	tst.b	oSubtype(a0)
	beq.s	.NotDamaged
	move.l	#$C000,d0
	move.l	#$6000,d1
	move.w	#42,d2
	
.NotDamaged:
	tst.w	oSemiPlayerX(a0)
	bmi.s	.StartMove
	neg.l	d0
	
.StartMove:
	move.l	d0,oSemiXVel(a0)
	move.l	d1,oSemiYVel(a0)
	move.w	d2,oSemiTime(a0)

; -------------------------------------------------------------------------

ObjSemi_Move:
	subq.w	#1,oSemiTime(a0)
	bpl.s	.Move
	addq.b	#2,oRoutine(a0)
	
.Move:
	move.l	oSemiXVel(a0),d0
	add.l	d0,oX(a0)
	move.l	oSemiYVel(a0),d0
	add.l	d0,oY(a0)
	
	lea	Ani_Semi(pc),a1
	jmp	AnimateObject

; -------------------------------------------------------------------------

ObjSemi_StartAttack:
	addq.b	#2,oRoutine(a0)
	move.w	#0,oSemiTime(a0)
	move.l	#$10000,d0
	tst.b	oSubtype(a0)
	beq.s	.NotDamaged
	move.l	#$C000,d0
	
.NotDamaged:
	tst.w	oSemiPlayerX(a0)
	bmi.s	.Move
	neg.l	d0
	
.Move:
	move.l	d0,oSemiXVel(a0)

; -------------------------------------------------------------------------

ObjSemi_Attack:
	tst.b	oSubtype(a0)
	bne.s	.Move

	andi.w	#$3F,oSemiTime(a0)
	bne.s	.NoBomb
	lea	objPlayerSlot.w,a1
	bsr.w	ObjSemi_CheckPlayer
	bcc.s	.NoBomb
	
	jsr	FindObjSlot
	bne.s	.NoBomb
	move.b	oID(a0),oID(a1)
	move.l	oX(a0),oX(a1)
	move.l	oY(a0),oY(a1)
	addi.w	#10,oY(a1)
	move.b	#-1,oSubtype2(a1)
	move.b	oSprFlags(a0),oSprFlags(a1)
	move.b	oPriority(a0),oPriority(a1)
	addq.b	#1,oPriority(a1)
	
.NoBomb:
	addq.w	#1,oSemiTime(a0)

.Move:
	move.l	oSemiXVel(a0),d0
	add.l	d0,oX(a0)
	
	lea	Ani_Semi(pc),a1
	jmp	AnimateObject

; -------------------------------------------------------------------------

Ani_Semi:
	include	"Level/Wacky Workbench/Objects/Semi/Data/Animations (Normal).asm"
	even

MapSpr_Semi:
	include	"Level/Wacky Workbench/Objects/Semi/Data/Mappings (Normal).asm"
	even

MapSpr_SemiDamaged:
	include	"Level/Wacky Workbench/Objects/Semi/Data/Mappings (Damaged).asm"
	even

; -------------------------------------------------------------------------
; Semi bomb
; -------------------------------------------------------------------------

oSemiBombYVel	EQU	oVar2E
oSemiBombTime	EQU	oVar32

; -------------------------------------------------------------------------

ObjSemiBomb:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	jsr	DrawObject
	jmp	CheckObjDespawn
	
; -------------------------------------------------------------------------

.Index:
	dc.w	ObjSemiBomb_Init-.Index
	dc.w	ObjSemiBomb_Fall-.Index
	dc.w	ObjSemiBomb_Wait-.Index
	dc.w	ObjSemiBomb_Detonate-.Index
	dc.w	ObjSemiBomb_Explode-.Index

; -------------------------------------------------------------------------

ObjSemiBomb_Init:
	addq.b	#2,oRoutine(a0)
	move.b	#$B7,oColType(a0)
	move.b	#6,oYRadius(a0)
	move.b	#6,oXRadius(a0)
	move.b	#6,oWidth(a0)
	move.w	#$84C8,oTile(a0)
	move.l	#MapSpr_SemiBomb,oMap(a0)
	move.l	#$8000,oSemiBombYVel(a0)

; -------------------------------------------------------------------------

ObjSemiBomb_Fall:
	move.l	oSemiBombYVel(a0),d0
	add.l	d0,oY(a0)
	addi.l	#$4000,oSemiBombYVel(a0)
	
	jsr	ObjGetFloorDist
	tst.w	d1
	bpl.s	.End
	addq.b	#2,oRoutine(a0)
	add.w	d1,oY(a0)
	move.w	#120,oSemiBombTime(a0)
	
.End:
	rts

; -------------------------------------------------------------------------

ObjSemiBomb_Wait:
	subq.w	#1,oSemiBombTime(a0)
	bpl.s	.End
	addq.b	#2,oRoutine(a0)
	move.w	#120,oSemiBombTime(a0)
	
.End:
	rts

; -------------------------------------------------------------------------

ObjSemiBomb_Detonate:
	subq.w	#1,oSemiBombTime(a0)
	bpl.s	.Animate
	addq.b	#2,oRoutine(a0)
	
.Animate:
	lea	Ani_SemiBomb(pc),a1
	jmp	AnimateObject

; -------------------------------------------------------------------------

ObjSemiBomb_Explode:
	move.b	#$18,oID(a0)
	move.b	#0,oRoutine(a0)
	move.b	#1,oExplodeBadnik(a0)
	tst.b	oSprFlags(a0)
	bpl.s	.End
	move.w	#FM_EXPLODE,d0
	jsr	PlayFMSound
	
.End:
	rts

; -------------------------------------------------------------------------

Ani_SemiBomb:
	include	"Level/Wacky Workbench/Objects/Semi/Data/Animations (Bomb).asm"
	even

MapSpr_SemiBomb:
	include	"Level/Wacky Workbench/Objects/Semi/Data/Mappings (Bomb).asm"
	even

; -------------------------------------------------------------------------
