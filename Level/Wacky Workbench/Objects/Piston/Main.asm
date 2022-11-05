; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Piston object
; -------------------------------------------------------------------------

oPistonY	EQU	oVar32
oPistonParent	EQU	oVar34
oPistonX	EQU	oVar36
oPistonTime	EQU	oVar3A
oPistonOff	EQU	oVar3B
oPistonDir	EQU	oVar3C

; -------------------------------------------------------------------------

ObjPiston:
	tst.b	oSubtype(a0)
	bmi.w	ObjPiston_SolidSide

	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	jsr	DrawObject
	jmp	CheckObjDespawn

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjPiston_Init-.Index
	dc.w	ObjPiston_Main-.Index

; -------------------------------------------------------------------------

ObjPiston_Solid:
	lea	objPlayerSlot.w,a1
	jmp	TopSolidObject

; -------------------------------------------------------------------------

ObjPiston_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oSprFlags(a0)
	move.w	#$340,oTile(a0)
	move.l	#MapSpr_Piston,oMap(a0)
	move.b	#40,oYRadius(a0)
	move.b	#32,oWidth(a0)
	move.w	oX(a0),oPistonX(a0)
	move.w	oY(a0),oPistonY(a0)

	jsr	FindObjSlot
	bne.s	.RightSolid
	move.w	#-32,d0
	bsr.w	ObjPiston_SetupSolidSide

.RightSolid:
	jsr	FindObjSlot
	bne.s	ObjPiston_Main
	move.w	#32,d0
	bsr.w	ObjPiston_SetupSolidSide

; -------------------------------------------------------------------------

ObjPiston_Main:
	jsr	ObjPiston_Move(pc)

	moveq	#0,d0
	move.b	oPistonOff(a0),d0
	neg.w	d0
	add.w	oPistonY(a0),d0
	move.w	d0,oY(a0)

	tst.b	oPistonDir(a0)
	beq.s	.CheckSolid
	tst.b	oPistonTime(a0)
	beq.s	.Solid

.CheckSolid:
	cmpi.b	#$21,oPistonOff(a0)
	bcs.s	.Solid
	lea	objPlayerSlot.w,a1
	jmp	GetOffObject

.Solid:
	jmp	ObjPiston_Solid(pc)

; -------------------------------------------------------------------------

ObjPiston_Move:
	tst.b	oPistonTime(a0)
	beq.s	.Moving
	subq.b	#1,oPistonTime(a0)
	bne.s	.End

.Moving:
	tst.b	oPistonDir(a0)
	beq.s	.MovingUp

.MovingDown:
	subq.b	#1,oPistonOff(a0)
	bcc.s	.End
	clr.b	oPistonOff(a0)
	clr.b	oPistonDir(a0)
	move.b	#60,oPistonTime(a0)
	rts

; -------------------------------------------------------------------------

.MovingUp:
	addq.b	#8,oPistonOff(a0)
	cmpi.b	#80,oPistonOff(a0)
	bcs.s	.End
	move.b	#80,oPistonOff(a0)
	move.b	#1,oPistonDir(a0)
	move.b	#60,oPistonTime(a0)

.End:
	rts

; -------------------------------------------------------------------------

ObjPiston_SetupSolidSide:
	move.b	#$20,oID(a1)
	move.w	a0,oPistonParent(a1)
	move.b	#-1,oSubtype(a1)
	add.w	oX(a0),d0
	move.w	d0,oX(a1)
	move.w	oY(a0),oY(a1)
	ori.b	#4,oSprFlags(a1)
	move.l	#MapSpr_Piston,oMap(a1)
	move.b	#40,oYRadius(a1)
	move.b	#1,oMapFrame(a1)
	rts

; -------------------------------------------------------------------------

ObjPiston_SolidSide:
	movea.w	oPistonParent(a0),a1
	cmpi.b	#$20,oID(a1)
	bne.s	.Delete
	
	move.w	oY(a1),oY(a0)
	lea	objPlayerSlot.w,a1
	jsr	SolidObject
	jmp	DrawObject

.Delete:
	jmp	DeleteObject

; -------------------------------------------------------------------------

MapSpr_Piston:
	include	"Level/Wacky Workbench/Objects/Piston/Data/Mappings.asm"
	even

; -------------------------------------------------------------------------
