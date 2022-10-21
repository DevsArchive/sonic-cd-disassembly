; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Anton object
; -------------------------------------------------------------------------

ObjAnton:
	jsr	DestroyOnGoodFuture
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjAnton_Index(pc,d0.w),d0
	jsr	ObjAnton_Index(pc,d0.w)
	jsr	DrawObject
	move.w	oVar2E(a0),d0
	jmp	CheckObjDespawn2
; End of function ObjAnton

; -------------------------------------------------------------------------
ObjAnton_Index:	dc.w	ObjAnton_Init-ObjAnton_Index
	dc.w	ObjAnton_Place-ObjAnton_Index
	dc.w	ObjAnton_Main-ObjAnton_Index
; -------------------------------------------------------------------------

ObjAnton_Init:
	ori.b	#4,oSprFlags(a0)
	move.b	#4,oPriority(a0)
	move.l	#MapSpr_Anton,oMap(a0)
	move.b	#$18,oXRadius(a0)
	move.b	#$18,oWidth(a0)
	move.b	#$13,oYRadius(a0)
	move.b	#$29,oColType(a0)
	move.w	oX(a0),oVar2E(a0)
	moveq	#2,d0
	jsr	SetObjectTileID
	tst.b	oSubtype(a0)
	bne.s	.Damaged
	move.l	#-$10000,d0
	moveq	#0,d1
	bra.s	.SetInfo

; -------------------------------------------------------------------------

.Damaged:
	move.l	#-$8000,d0
	moveq	#1,d1

.SetInfo:
	move.l	d0,oVar2A(a0)
	move.b	d1,oAnim(a0)
; End of function ObjAnton_Init

; -------------------------------------------------------------------------

ObjAnton_Place:
	move.l	#$10000,d0
	add.l	d0,oY(a0)
	jsr	ObjGetFloorDist
	tst.w	d1
	bpl.s	.End
	addq.b	#2,oRoutine(a0)

.End:
	rts
; End of function ObjAnton_Place

; -------------------------------------------------------------------------

ObjAnton_Main:
	move.l	oVar2A(a0),d0
	add.l	d0,oX(a0)
	move.w	oX(a0),d0
	sub.w	oVar2E(a0),d0
	bpl.s	.AbsDX
	neg.w	d0

.AbsDX:
	cmpi.w	#$80,d0
	bge.s	.TurnAround
	jsr	ObjGetFloorDist
	cmpi.w	#-7,d1
	blt.s	.TurnAround
	cmpi.w	#7,d1
	bgt.s	.TurnAround
	add.w	d1,oY(a0)
	lea	Ani_Anton(pc),a1
	jmp	AnimateObject

; -------------------------------------------------------------------------

.TurnAround:
	neg.l	oVar2A(a0)
	bchg	#0,oSprFlags(a0)
	bchg	#0,oFlags(a0)
	bra.s	ObjAnton_Main
; End of function ObjAnton_Main

; -------------------------------------------------------------------------
Ani_Anton:
	include	"Level/Palmtree Panic/Objects/Anton/Data/Animations.asm"
	even
MapSpr_Anton:
	include	"Level/Palmtree Panic/Objects/Anton/Data/Mappings.asm"
	even

; -------------------------------------------------------------------------
