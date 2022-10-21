; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Door object
; -------------------------------------------------------------------------

oDoorSwitch	EQU	oVar30
oDoorY		EQU	oVar32
oDoorPlayerX	EQU	oVar38
oDoorOff	EQU	oVar3A
oDoorDir	EQU	oVar3C
oDoorPlayerY	EQU	oVar3E

; -------------------------------------------------------------------------

ObjDoor:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	jsr	DrawObject
	jmp	CheckObjDespawn

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjDoor_Init-.Index
	dc.w	ObjDoor_Main-.Index
	dc.w	ObjDoor_Opened-.Index
	dc.w	ObjDoor_Close-.Index

; -------------------------------------------------------------------------

ObjDoor_Solid:
	lea	objPlayerSlot.w,a1
	move.w	oX(a0),d3
	move.w	oY(a0),d4
	jmp	SolidObject

; -------------------------------------------------------------------------

ObjDoor_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oSprFlags(a0)
	move.b	#3,oPriority(a0)
	move.l	#MapSpr_Door,oMap(a0)
	move.w	oY(a0),oDoorY(a0)
	move.w	#$3A0,oTile(a0)
	move.b	#32,oYRadius(a0)
	move.b	#8,oWidth(a0)
	
	cmpi.b	#2,act
	bne.s	.NotAct3
	move.w	#$330,oTile(a0)
	move.b	#32,oYRadius(a0)
	move.b	#32,oWidth(a0)
	move.b	#1,oMapFrame(a0)

.NotAct3:
	move.b	oSubtype(a0),d0
	andi.b	#$F,d0
	move.b	d0,oDoorSwitch(a0)
	move.b	#-1,oDoorDir(a0)

; -------------------------------------------------------------------------

ObjDoor_Main:
	moveq	#0,d0
	move.b	oDoorSwitch(a0),d0
	lea	switchFlags.w,a1
	btst	#7,(a1,d0.w)
	beq.s	.NoSwitch
	clr.b	oDoorDir(a0)

.NoSwitch:
	lea	objPlayerSlot.w,a1
	move.w	oX(a1),oDoorPlayerX(a0)
	move.w	oY(a1),oDoorPlayerY(a0)
	bsr.w	ObjDoor_Move
	bsr.w	ObjDoor_Solid

	cmpi.b	#64,oDoorOff(a0)
	bne.s	.End
	addq.b	#2,oRoutine(a0)

.End:
	rts

; -------------------------------------------------------------------------

ObjDoor_Opened:
	lea	objPlayerSlot.w,a1
	move.w	oX(a0),d0
	sub.w	oDoorPlayerX(a0),d0
	bcc.s	.LeftSide

	move.b	oXRadius(a1),d0
	ext.w	d0
	add.w	oX(a1),d0
	sub.w	oX(a0),d0
	bcc.s	.End
	neg.w	d0
	cmp.b	oWidth(a0),d0
	bcs.s	.End
	bra.s	.Close

.LeftSide:
	move.b	oXRadius(a1),d0
	neg.b	d0
	ext.w	d0
	add.w	oX(a1),d0
	sub.w	oX(a0),d0
	bcs.s	.End
	cmp.b	oWidth(a0),d0
	bcs.s	.End

.Close:
	addq.b	#2,oRoutine(a0)

.End:
	rts

; -------------------------------------------------------------------------

ObjDoor_Close:
	st	oDoorDir(a0)
	bsr.w	ObjDoor_Move
	tst.b	oDoorOff(a0)
	bne.s	.NotClosed
	move.b	#2,oRoutine(a0)

.NotClosed:
	bra.w	ObjDoor_Solid

; -------------------------------------------------------------------------

ObjDoor_Move:
	bsr.w	.MoveY
	moveq	#0,d0
	move.b	oDoorOff(a0),d0
	neg.w	d0
	add.w	oDoorY(a0),d0
	move.w	d0,oY(a0)
	rts

.MoveY:
	tst.b	oDoorDir(a0)
	beq.s	.Open

.Close:
	subq.b	#4,oDoorOff(a0)
	bcc.s	.End
	clr.b	oDoorOff(a0)
	bra.s	.End

.Open:
	addq.b	#4,oDoorOff(a0)
	move.b	oDoorOff(a0),d0
	cmpi.b	#64,d0
	bcs.s	.End
	move.b	#64,oDoorOff(a0)

.End:
	rts

; -------------------------------------------------------------------------

MapSpr_Door:
	include	"Level/Wacky Workbench/Objects/Door/Data/Mappings.asm"
	even

; -------------------------------------------------------------------------
