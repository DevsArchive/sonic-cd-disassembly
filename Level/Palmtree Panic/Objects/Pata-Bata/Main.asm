; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Pata-Bata object
; -------------------------------------------------------------------------

ObjPataBata:
	jsr	DestroyOnGoodFuture
	tst.b	oRoutine(a0)
	bne.w	ObjPataBata_Main
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oSprFlags(a0)
	move.b	#3,oPriority(a0)
	move.b	#$2A,oColType(a0)
	move.b	#$10,oXRadius(a0)
	move.b	#$10,oWidth(a0)
	move.b	#$10,oYRadius(a0)
	move.w	oX(a0),oVar2A(a0)
	move.w	oY(a0),oVar2C(a0)
	move.w	#$8000,oVar2E(a0)
	moveq	#1,d0
	jsr	SetObjectTileID
	tst.b	oSubtype(a0)
	bne.s	.Damaged
	move.l	#-$8000,d0
	move.w	#-$200,d1
	moveq	#3,d2
	moveq	#0,d3
	lea	MapSpr_PataBata1(pc),a1
	bra.s	.SetInfo

; -------------------------------------------------------------------------

.Damaged:
	move.l	#-$4000,d0
	move.w	#-$100,d1
	moveq	#4,d2
	moveq	#1,d3
	lea	MapSpr_PataBata2(pc),a1

.SetInfo:
	move.l	d0,oVar30(a0)
	move.w	d1,oVar36(a0)
	move.w	d2,oVar38(a0)
	move.b	d3,oAnim(a0)
	move.l	a1,oMap(a0)

ObjPataBata_Main:
	move.l	oVar30(a0),d0
	add.l	d0,oX(a0)
	move.w	oX(a0),d0
	sub.w	oVar2A(a0),d0
	bpl.s	.AbsDX
	neg.w	d0

.AbsDX:
	cmpi.w	#$80,d0
	blt.s	.NoFlip
	neg.l	oVar30(a0)
	move.l	oVar30(a0),d0
	add.l	d0,oX(a0)
	bchg	#0,oSprFlags(a0)
	bchg	#0,oFlags(a0)
	clr.w	oVar34(a0)

.NoFlip:
	move.w	oVar36(a0),d0
	add.w	d0,oVar34(a0)
	move.b	oVar34(a0),d0
	jsr	CalcSine
	swap	d0
	move.w	oVar38(a0),d1
	asr.l	d1,d0
	add.l	oVar2C(a0),d0
	move.l	d0,oY(a0)
	lea	Ani_PataBata(pc),a1
	jsr	AnimateObject
	jsr	DrawObject
	move.w	oVar2A(a0),d0
	jmp	CheckObjDespawn2
; End of function ObjPataBata

; -------------------------------------------------------------------------
Ani_PataBata:
	include	"Level/Palmtree Panic/Objects/Pata-Bata/Data/Animations.asm"
	even
MapSpr_PataBata1:
	include	"Level/Palmtree Panic/Objects/Pata-Bata/Data/Mappings (Normal).asm"
	even
MapSpr_PataBata2:
	include	"Level/Palmtree Panic/Objects/Pata-Bata/Data/Mappings (Damaged).asm"
	even

; -------------------------------------------------------------------------
