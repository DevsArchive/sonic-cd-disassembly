; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Mosqui object
; -------------------------------------------------------------------------

ObjMosqui:
	jsr	DestroyOnGoodFuture
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjMosqui_Index(pc,d0.w),d0
	jsr	ObjMosqui_Index(pc,d0.w)
	jsr	DrawObject
	move.w	oVar2A(a0),d0
	jmp	CheckObjDespawn2
; End of function ObjMosqui

; -------------------------------------------------------------------------
ObjMosqui_Index:dc.w	ObjMosqui_Init-ObjMosqui_Index
	dc.w	ObjMosqui_Main-ObjMosqui_Index
	dc.w	ObjMosqui_Animate-ObjMosqui_Index
	dc.w	ObjMosqui_Dive-ObjMosqui_Index
	dc.w	ObjMosqui_Wait-ObjMosqui_Index
; -------------------------------------------------------------------------

ObjMosqui_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oSprFlags(a0)
	move.b	#3,oPriority(a0)
	move.b	#$10,oXRadius(a0)
	move.b	#$10,oWidth(a0)
	move.b	#$10,oYRadius(a0)
	move.b	#$2B,oColType(a0)
	move.w	oX(a0),oVar2A(a0)
	moveq	#0,d0
	jsr	SetObjectTileID
	tst.b	oSubtype(a0)
	bne.s	.Damaged
	lea	MapSpr_Mosqui1(pc),a1
	lea	Ani_Mosqui1(pc),a2
	move.l	#-$10000,d0
	bra.s	.SetInfo

; -------------------------------------------------------------------------

.Damaged:
	lea	MapSpr_Mosqui2(pc),a1
	lea	Ani_Mosqui2(pc),a2
	move.l	#-$8000,d0

.SetInfo:
	move.l	a1,oMap(a0)
	move.l	a2,oVar30(a0)
	move.l	d0,oVar2C(a0)
; End of function ObjMosqui_Init

; -------------------------------------------------------------------------

ObjMosqui_Main:
	tst.w	debugMode
	bne.s	.SkipRange
	lea	objPlayerSlot.w,a1
	bsr.s	ObjMosqui_CheckInRange
	bcs.s	.StartDive

.SkipRange:
	move.l	oVar2C(a0),d0
	add.l	d0,oX(a0)
	move.w	oX(a0),d0
	sub.w	oVar2A(a0),d0
	bpl.s	.ChkTurn
	neg.w	d0

.ChkTurn:
	cmpi.w	#$80,d0
	blt.s	.Animate
	neg.l	oVar2C(a0)
	bchg	#0,oSprFlags(a0)
	bchg	#0,oFlags(a0)
	bra.s	.SkipRange

; -------------------------------------------------------------------------

.Animate:
	movea.l	oVar30(a0),a1
	jmp	AnimateObject

; -------------------------------------------------------------------------

.StartDive:
	addq.b	#2,oRoutine(a0)
	move.b	#1,oAnim(a0)
	rts
; End of function ObjMosqui_Main

; -------------------------------------------------------------------------

ObjMosqui_CheckInRange:
	move.w	oY(a1),d0
	sub.w	oY(a0),d0
	subi.w	#-$30,d0
	subi.w	#$70,d0
	bcc.s	.End
	move.w	oX(a1),d0
	sub.w	oX(a0),d0
	move.w	d0,d1
	subi.w	#-$30,d1
	subi.w	#$60,d1

.End:
	rts
; End of function ObjMosqui_CheckInRange

; -------------------------------------------------------------------------

ObjMosqui_Animate:
	movea.l	oVar30(a0),a1
	jmp	AnimateObject
; End of function ObjMosqui_Animate

; -------------------------------------------------------------------------

ObjMosqui_Dive:
	addq.w	#6,oY(a0)
	jsr	ObjGetFloorDist
	cmpi.w	#-8,d1
	bgt.s	.End
	subi.w	#-8,d1
	add.w	d1,oY(a0)
	addq.b	#2,oRoutine(a0)
	tst.b	oSprFlags(a0)
	bpl.s	.End
	move.w	#FM_A7,d0
	jsr	PlayFMSound

.End:
	rts
; End of function ObjMosqui_Dive

; -------------------------------------------------------------------------

ObjMosqui_Wait:
	tst.b	oSprFlags(a0)
	bmi.s	.End
	jmp	DespawnObject

; -------------------------------------------------------------------------

.End:
	rts
; End of function ObjMosqui_Wait

; -------------------------------------------------------------------------
Ani_Mosqui1:
	include	"Level/Palmtree Panic/Objects/Mosqui/Data/Animations (Normal).asm"
	even
Ani_Mosqui2:
	include	"Level/Palmtree Panic/Objects/Mosqui/Data/Animations (Damaged).asm"
	even
MapSpr_Mosqui1:
	include	"Level/Palmtree Panic/Objects/Mosqui/Data/Mappings (Normal).asm"
	even
MapSpr_Mosqui2:
	include	"Level/Palmtree Panic/Objects/Mosqui/Data/Mappings (Damaged).asm"
	even

; -------------------------------------------------------------------------
