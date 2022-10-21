; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Platform object
; -------------------------------------------------------------------------

oPtfmY		EQU	oVar32
oPtfmX		EQU	oVar36
oPtfm3A		EQU	oVar3A

; -------------------------------------------------------------------------

ObjPlatform:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	jsr	DrawObject
	move.w	oPtfmX(a0),d0
	jmp	CheckObjDespawn2

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjPlatform_Init-.Index
	dc.w	ObjPlatform_Main-.Index

; -------------------------------------------------------------------------

ObjPlatform_Solid:
	lea	objPlayerSlot.w,a1
	move.w	oX(a0),d3
	move.w	oY(a0),d4
	jmp	TopSolidObject

; -------------------------------------------------------------------------

ObjPlatform_Init:
	ori.b	#4,oSprFlags(a0)
	move.b	#1,oPriority(a0)
	move.w	#$436A,oTile(a0)
	move.l	#MapSpr_Platform,oMap(a0)
	move.w	oX(a0),oPtfmX(a0)
	move.w	oY(a0),oPtfmY(a0)
	move.b	#12,oYRadius(a0)
	move.b	#24,oWidth(a0)
	addq.b	#2,oRoutine(a0)

; -------------------------------------------------------------------------

ObjPlatform_Main:
	moveq	#0,d0
	move.b	oSubtype(a0),d0
	add.w	d0,d0
	move.w	.MoveTypes(pc,d0.w),d0
	jmp	.MoveTypes(pc,d0.w)

; -------------------------------------------------------------------------

.MoveTypes:
	dc.w	ObjPlatform_MoveX-.MoveTypes
	dc.w	ObjPlatform_MoveX2-.MoveTypes
	dc.w	ObjPlatform_MoveY-.MoveTypes
	dc.w	ObjPlatform_MoveY2-.MoveTypes

; -------------------------------------------------------------------------

ObjPlatform_MoveY:
	bsr.w	ObjPlatform_GetOffset
	neg.w	d0
	add.w	oPtfmY(a0),d0
	move.w	d0,oY(a0)
	bra.w	ObjPlatform_Solid

; -------------------------------------------------------------------------

ObjPlatform_MoveY2:
	bsr.w	ObjPlatform_GetOffset
	add.w	oPtfmY(a0),d0
	move.w	d0,oY(a0)
	bra.w	ObjPlatform_Solid

; -------------------------------------------------------------------------

ObjPlatform_MoveX:
	move.l	oX(a0),-(sp)
	bsr.w	ObjPlatform_GetOffset
	add.w	oPtfmX(a0),d0
	move.w	d0,oX(a0)

	move.l	oX(a0),d0
	sub.l	(sp)+,d0
	lsr.l	#8,d0
	move.w	d0,oXVel(a0)
	bra.w	ObjPlatform_Solid

; -------------------------------------------------------------------------

ObjPlatform_MoveX2:
	move.l	oX(a0),-(sp)
	bsr.w	ObjPlatform_GetOffset
	neg.w	d0
	add.w	oPtfmX(a0),d0
	move.w	d0,oX(a0)

	move.l	oX(a0),d0
	sub.l	(sp)+,d0
	lsr.l	#8,d0
	move.w	d0,oXVel(a0)
	bra.w	ObjPlatform_Solid

; -------------------------------------------------------------------------

ObjPlatform_GetOffset:
	move.w	levelFrames,d0
	andi.w	#$FF,d0
	jsr	CalcSine
	add.w	d0,d0
	add.w	d0,d0
	asr.w	#4,d0

	addq.b	#1,oPtfm3A(a0)
	rts

; -------------------------------------------------------------------------

MapSpr_Platform:
	include	"Level/Wacky Workbench/Objects/Platform/Data/Mappings (Normal).asm"
	even

; -------------------------------------------------------------------------
