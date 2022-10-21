; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Tube door object
; -------------------------------------------------------------------------

oTDoorTime	EQU	oVar3A
oTDoorClose	EQU	oVar3C

; -------------------------------------------------------------------------

ObjTubeDoor:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	jsr	DrawObject
	jmp	CheckObjDespawn

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjTubeDoor_Init-.Index
	dc.w	ObjTubeDoor_Main-.Index
	dc.w	ObjTubeDoor_Open-.Index
	dc.w	ObjTubeDoor_CheckClose-.Index
	dc.w	ObjTubeDoor_Close-.Index

; -------------------------------------------------------------------------

ObjTubeDoor_Solid:
	tst.b	oMapFrame(a0)
	beq.s	.Solid
	rts

.Solid:
	lea	objPlayerSlot.w,a1
	move.w	oX(a0),d3
	move.w	oY(a0),d4
	jmp	SolidObject

; -------------------------------------------------------------------------

ObjTubeDoor_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oSprFlags(a0)
	move.b	#3,oPriority(a0)
	move.w	#$4410,oTile(a0)
	move.l	#MapSpr_TubeDoor,oMap(a0)
	move.b	#4,oWidth(a0)
	move.b	#32,oYRadius(a0)
	
	tst.b	oSubtype(a0)
	beq.s	ObjTubeDoor_Main
	bset	#0,oSprFlags(a0)
	bset	#0,oFlags(a0)

; -------------------------------------------------------------------------

ObjTubeDoor_Main:
	lea	objPlayerSlot.w,a1
	move.w	oY(a0),d0
	sub.w	oY(a1),d0
	bcc.s	.CheckYDist
	neg.w	d0

.CheckYDist:
	cmpi.w	#64,d0
	bcc.s	.Solid
	
	move.w	oX(a0),d1
	move.w	oX(a1),d0
	tst.b	oSubtype(a0)
	bne.s	.CheckXDist
	move.w	oX(a0),d0
	move.w	oX(a1),d1

.CheckXDist:
	sub.w	d1,d0
	bcs.s	.Solid
	cmpi.w	#64,d0
	bcc.s	.Solid

.Open:
	clr.w	oTDoorTime(a0)
	addq.b	#2,oRoutine(a0)
	btst	#7,oSprFlags(a0)
	beq.s	.Solid
	move.w	#FM_A4,d0
	jsr	PlayFMSound

.Solid:
	bra.w	ObjTubeDoor_Solid

; -------------------------------------------------------------------------

ObjTubeDoor_Open:
	clr.b	oTDoorClose(a0)
	jsr	ObjTubeDoor_Move(pc)
	cmpi.b	#3,oMapFrame(a0)
	bne.s	.Solid
	addq.b	#2,oRoutine(a0)

.Solid:
	bra.w	ObjTubeDoor_Solid

; -------------------------------------------------------------------------

ObjTubeDoor_CheckClose:
	lea	objPlayerSlot.w,a1
	move.w	oY(a0),d0
	sub.w	oY(a1),d0
	bcc.s	.CheckYDist
	neg.w	d0

.CheckYDist:
	cmpi.w	#64,d0
	bcc.s	.Solid
	
	move.w	oX(a1),d1
	move.w	oX(a0),d0
	tst.b	oSubtype(a0)
	bne.s	.CheckXDist
	move.w	oX(a1),d0
	move.w	oX(a0),d1

.CheckXDist:
	sub.w	d1,d0
	bcs.s	.Solid
	cmpi.w	#64,d0
	bcs.s	.Solid

.Close:
	clr.w	oTDoorTime(a0)
	addq.b	#2,oRoutine(a0)
	move.w	#FM_A4,d0
	jsr	PlayFMSound

.Solid:
	bra.w	ObjTubeDoor_Solid

; -------------------------------------------------------------------------

ObjTubeDoor_Close:
	move.b	#1,oTDoorClose(a0)
	jsr	ObjTubeDoor_Move(pc)
	tst.b	oMapFrame(a0)
	bne.s	.Solid
	move.b	#2,oRoutine(a0)

.Solid:
	bra.w	ObjTubeDoor_Solid

; -------------------------------------------------------------------------

ObjTubeDoor_Move:
	addi.b	#$40,oTDoorTime(a0)
	bcs.s	.Move
	rts

.Move:
	tst.b	oTDoorClose(a0)
	bne.s	.Close
	addq.b	#1,oMapFrame(a0)
	rts

.Close:
	subq.b	#1,oMapFrame(a0)
	bcc.s	.End
	clr.b	oMapFrame(a0)

.End:
	rts

; -------------------------------------------------------------------------

MapSpr_TubeDoor:
	include	"Level/Wacky Workbench/Objects/Tube Door/Data/Mappings.asm"
	even

; -------------------------------------------------------------------------
