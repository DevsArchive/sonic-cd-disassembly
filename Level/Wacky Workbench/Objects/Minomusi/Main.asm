; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Minomusi object
; -------------------------------------------------------------------------

oMinoTime	EQU	oVar2A
oMinoYVel	EQU	oVar30
oMinoStartY	EQU	oVar34
oMinoDropY	EQU	oVar36
oMinoParent	EQU	oVar38

; -------------------------------------------------------------------------

ObjMinomusi:
	tst.b	oSubtype2(a0)
	beq.s	.Main
	bmi.w	ObjMinomusiSilk
	bra.w	ObjMinomusiSpikes
	
.Main:
	jsr	DestroyOnGoodFuture
	
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)
	
	jsr	DrawObject
	jmp	CheckObjDespawn

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjMinomusi_Init-.Index
	dc.w	ObjMinomusi_SetWait-.Index
	dc.w	ObjMinomusi_WaitPlayer-.Index
	dc.w	ObjMinomusi_StartDrop-.Index
	dc.w	ObjMinomusi_Drop-.Index
	dc.w	ObjMinomusi_StartRetract-.Index
	dc.w	ObjMinomusi_Retract-.Index
	dc.w	ObjMinomusi_StartAttack-.Index
	dc.w	ObjMinomusi_Attack-.Index

; -------------------------------------------------------------------------

ObjMinomusi_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oSprFlags(a0)
	move.b	#3,oPriority(a0)
	move.b	#16,oYRadius(a0)
	move.b	#16,oXRadius(a0)
	move.b	#16,oWidth(a0)
	move.w	#$2488,oTile(a0)
	move.b	#$34,oColType(a0)
	addq.w	#8,oY(a0)
	move.w	oY(a0),oMinoStartY(a0)
	move.w	oY(a0),oMinoDropY(a0)
	addi.w	#95,oMinoDropY(a0)
	
	lea	MapSpr_Minomusi(pc),a1
	tst.b	oSubtype(a0)
	beq.s	.NotDamaged
	lea	MapSpr_MinomusiDamaged(pc),a1
	
.NotDamaged:
	move.l	a1,oMap(a0)
	
	jsr	FindNextObjSlot
	beq.s	.SpawnSilk
	jmp	DeleteObject

.SpawnSilk:
	move.b	oID(a0),oID(a1)
	move.b	#-1,oSubtype2(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	move.b	oSprFlags(a0),oSprFlags(a1)
	move.b	oPriority(a0),oPriority(a1)
	addq.b	#1,oPriority(a1)
	move.w	oTile(a0),oTile(a1)
	move.l	oMap(a0),oMap(a1)
	move.b	#32,oYRadius(a1)
	move.b	#1,oXRadius(a1)
	move.b	#1,oWidth(a1)
	move.w	a0,oMinoParent(a1)

; -------------------------------------------------------------------------

ObjMinomusi_SetWait:
	addq.b	#2,oRoutine(a0)
	move.b	#9,oMapFrame(a0)
	move.w	#121,oMinoTime(a0)

; -------------------------------------------------------------------------

ObjMinomusi_WaitPlayer:
	subq.w	#1,oMinoTime(a0)
	bne.s	.End
	move.w	#121,oMinoTime(a0)
	
	move.b	#2,d6
	lea	objPlayerSlot.w,a1
	bsr.w	ObjMinomusi_CheckPlayer
	bcs.s	.NextRoutine
	neg.b	d6
	
.NextRoutine:
	add.b	d6,oRoutine(a0)
	
.End:
	rts

; -------------------------------------------------------------------------

ObjMinomusi_CheckPlayer:
	move.w	oY(a1),d0
	sub.w	oY(a0),d0
	subi.w	#40,d0
	subi.w	#120,d0
	bcc.s	.End
	
	move.w	oX(a1),d0
	sub.w	oX(a0),d0
	subi.w	#-168,d0
	subi.w	#336,d0
	
.End:
	rts

; -------------------------------------------------------------------------

ObjMinomusi_StartDrop:
	addq.b	#2,oRoutine(a0)
	move.l	#$80000,oMinoYVel(a0)

; -------------------------------------------------------------------------

ObjMinomusi_Drop:
	move.l	oMinoYVel(a0),d0
	add.l	d0,oY(a0)
	move.w	oMinoDropY(a0),d0
	sub.w	oY(a0),d0
	bgt.s	.End
	add.w	d0,oY(a0)
	move.b	#$E,oRoutine(a0)
	
.End:
	rts

; -------------------------------------------------------------------------

ObjMinomusi_StartRetract:
	addq.b	#2,oRoutine(a0)
	move.l	#$70000,d0
	tst.b	oSubtype(a0)
	beq.s	.NotDamaged
	move.l	#$20000,d0
	
.NotDamaged:
	move.l	d0,oMinoYVel(a0)

; -------------------------------------------------------------------------

ObjMinomusi_Retract:
	move.l	oMinoYVel(a0),d0
	sub.l	d0,oY(a0)
	move.w	oMinoStartY(a0),d0
	sub.w	oY(a0),d0
	blt.s	.End
	add.w	d0,oY(a0)
	move.b	#2,oRoutine(a0)
	
.End:
	rts

; -------------------------------------------------------------------------

ObjMinomusi_StartAttack:
	addq.b	#2,oRoutine(a0)
	
	move.w	#230,d0
	move.w	#$00FF,d1
	tst.b	oSubtype(a0)
	beq.s	.NotDamaged
	move.w	#61,d0
	move.w	#$01FF,d1
	
.NotDamaged:
	move.w	d0,oMinoTime(a0)
	move.w	d1,oAnim(a0)

; -------------------------------------------------------------------------

ObjMinomusi_Attack:
	subq.w	#1,oMinoTime(a0)
	bne.s	.Attack
	move.b	#$A,oRoutine(a0)
	
.Attack:
	lea	Ani_Minomusi(pc),a1
	jsr	AnimateObject
	
	tst.b	oSubtype(a0)
	bne.w	.End
	cmpi.b	#$1E,oAnimFrame(a0)
	bne.w	.End
	
	jsr	FindNextObjSlot
	bne.w	.End
	move.b	oID(a0),oID(a1)
	move.b	#1,oSubtype2(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	addq.w	#4,oY(a1)
	move.b	oSprFlags(a0),oSprFlags(a1)
	move.b	oPriority(a0),oPriority(a1)
	move.w	oTile(a0),oTile(a1)
	move.l	oMap(a0),oMap(a1)
	move.b	oYRadius(a0),oYRadius(a1)
	move.b	oXRadius(a0),oXRadius(a1)
	move.b	oWidth(a0),oWidth(a1)
	move.w	a0,oMinoParent(a1)
	move.b	#$B5,oColType(a1)
	
	tst.b	oSprFlags(a0)
	bpl.s	.End
	move.w	#FM_B7,d0
	jsr	PlayFMSound
	
.End:
	rts

; -------------------------------------------------------------------------

ObjMinomusiSpikes:
	movea.w	oMinoParent(a0),a1
	cmpi.b	#$33,oID(a1)
	bne.s	.Delete
	cmpi.b	#1,oAnimFrame(a1)
	beq.s	.Delete
	jmp	DrawObject
	
.Delete:
	jmp	DeleteObject

; -------------------------------------------------------------------------

ObjMinomusiSilk:
	movea.w	oMinoParent(a0),a1
	cmpi.b	#$33,oID(a1)
	beq.s	.Draw
	jmp	DeleteObject
	
.Draw:
	move.w	oY(a1),d0
	sub.w	oMinoStartY(a1),d0
	subi.w	#24,d0
	asr.w	#3,d0
	bpl.s	.SetFrame
	moveq	#0,d0

.SetFrame:
	move.b	d0,oMapFrame(a0)

	asl.w	#2,d0
	add.w	oMinoStartY(a1),d0
	addi.w	#16,d0
	move.w	d0,oY(a0)
	
	jmp	DrawObject

; -------------------------------------------------------------------------

Ani_Minomusi:
	include	"Level/Wacky Workbench/Objects/Minomusi/Data/Animations.asm"
	even

	include	"Level/Wacky Workbench/Objects/Minomusi/Data/Mappings.asm"
	even

; -------------------------------------------------------------------------
