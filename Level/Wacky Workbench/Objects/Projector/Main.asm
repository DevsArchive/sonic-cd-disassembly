; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Projector object
; -------------------------------------------------------------------------

ObjProjector:
	tst.b	oSubtype(a0)
	bne.w	ObjMetalSonicHologram
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjProjector_Index(pc,d0.w),d0
	jsr	ObjProjector_Index(pc,d0.w)
	jsr	DrawObject
	cmpi.b	#2,oRoutine(a0)
	bgt.s	.End
	jsr	CheckObjDespawn
	tst.b	(a0)
	bne.s	.End
	move.w	#4,d0
	jmp	LoadPLC

; -------------------------------------------------------------------------

.End:
	rts
; End of function ObjProjector

; -------------------------------------------------------------------------
ObjProjector_Index:dc.w	ObjProjector_Init-ObjProjector_Index
	dc.w	ObjProjector_Main-ObjProjector_Index
	dc.w	ObjProjector_StartExploding-ObjProjector_Index
	dc.w	ObjProjector_Exploding-ObjProjector_Index
	dc.w	ObjProjector_Destroyed-ObjProjector_Index

; -------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR ObjProjector

ObjProjector_Destroy:
	jmp	DeleteObject
; END OF FUNCTION CHUNK	FOR ObjProjector
; -------------------------------------------------------------------------

ObjProjector_Init:
	tst.b	projDestroyed
	bne.s	ObjProjector_Destroy
	move.w	#5,d0
	jsr	LoadPLC
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oSprFlags(a0)
	move.b	#4,oPriority(a0)
	move.b	#$C,oXRadius(a0)
	move.b	#$C,oWidth(a0)
	move.b	#$C,oYRadius(a0)
	move.b	#$FB,oColType(a0)
	move.l	#MapSpr_Projector,oMap(a0)
	move.l	#ObjProjector_ExplosionLocs,oVar2C(a0)
	move.w	#$4E8,oTile(a0)
	tst.b	act
	beq.s	.SpawnSubObjs
	move.w	#$300,oTile(a0)

.SpawnSubObjs:
	jsr	FindObjSlot
	bne.w	ObjProjector_Destroy
	move.b	oID(a0),oID(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	subi.w	#$15,oX(a1)
	subq.w	#7,oY(a1)
	move.b	#$FF,oSubtype(a1)
	move.w	a0,oVar3E(a1)
	jsr	FindObjSlot
	bne.w	ObjProjector_Destroy
	move.b	oID(a0),oID(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	subi.w	#$48,oX(a1)
	subq.w	#4,oY(a1)
	move.b	#1,oSubtype(a1)
	move.w	a0,oVar3E(a1)
	jsr	FindObjSlot
	bne.w	ObjProjector_Destroy
	move.b	#$29,oID(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	subi.w	#$48,oX(a1)
	addi.w	#-$18,oY(a1)
	move.b	#$80,oSubtype(a1)
	move.w	a0,oVar3E(a1)
	jsr	FindObjSlot
	bne.w	ObjProjector_Destroy
	move.b	#$29,oID(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	subi.w	#$54,oX(a1)
	addq.w	#7,oY(a1)
	move.b	#$81,oSubtype(a1)
	move.w	a0,oVar3E(a1)

ObjProjector_Main:
	tst.b	oColStatus(a0)
	beq.s	.Solid
	clr.w	oColType(a0)
	addq.b	#2,oRoutine(a0)

.Solid:
	lea	objPlayerSlot.w,a1
	jmp	SolidObject
; End of function ObjProjector_Init

; -------------------------------------------------------------------------

ObjProjector_StartExploding:
	addq.b	#2,oRoutine(a0)
	move.b	#1,oMapFrame(a0)
	st	oVar3F(a0)
	move.w	#4,d0
	jsr	LoadPLC
	lea	objPlayerSlot.w,a1
	jsr	SolidObject
	beq.s	ObjProjector_Exploding
	jsr	GetOffObject

ObjProjector_Exploding:
	movea.l	oVar2C(a0),a6
	move.b	(a6)+,d0
	bmi.s	.Finished
	addq.b	#1,oVar2A(a0)
	cmp.b	oVar2A(a0),d0
	bne.s	.End
	move.b	(a6)+,d5
	move.b	(a6)+,d6
	move.l	a6,oVar2C(a0)
	ext.w	d5
	ext.w	d6
	jsr	FindObjSlot
	bne.s	.End
	move.b	#$18,oID(a1)
	move.b	#1,oExplodeBadnik(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	add.w	d5,oX(a1)
	add.w	d6,oY(a1)
	move.w	#FM_EXPLODE,d0
	jsr	PlayFMSound

.End:
	rts

; -------------------------------------------------------------------------

.Finished:
	addq.b	#2,oRoutine(a0)
	move.w	#60,oVar2A(a0)
	rts
; End of function ObjProjector_StartExploding

; -------------------------------------------------------------------------

ObjProjector_Destroyed:
	subq.w	#1,oVar2A(a0)
	bne.s	locret_20E6E6
	st	projDestroyed
	bra.w	ObjProjector_Destroy

; -------------------------------------------------------------------------

locret_20E6E6:
	rts
; End of function ObjProjector_Destroyed

; -------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR ObjProjector

ObjMetalSonicHologram:
	movea.w	oVar3E(a0),a1
	cmpi.b	#$2F,oID(a1)
	bne.w	ObjProjector_Destroy
	tst.b	oVar3F(a1)
	bne.w	ObjProjector_Destroy
	tst.b	oRoutine(a0)
	bne.s	.Animate
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oSprFlags(a0)
	move.b	#4,oPriority(a0)
	move.l	#MapSpr_Projector,oMap(a0)
	move.w	#$4E8,oTile(a0)
	tst.b	act
	beq.s	.SetProperties
	move.w	#$300,oTile(a0)

.SetProperties:
	moveq	#8,d0
	moveq	#4,d1
	moveq	#0,d2
	tst.b	oSubtype(a0)
	bmi.s	.GotSize
	moveq	#$14,d0
	moveq	#$18,d1
	moveq	#1,d2

.GotSize:
	move.b	d0,oXRadius(a0)
	move.b	d0,oWidth(a0)
	move.b	d1,oYRadius(a0)
	move.b	d2,oAnim(a0)

.Animate:
	lea	Ani_MetalSonicHologram(pc),a1
	jsr	AnimateObject
	jmp	DrawObject
; END OF FUNCTION CHUNK	FOR ObjProjector

; -------------------------------------------------------------------------

Ani_MetalSonicHologram:
	include	"Level/Wacky Workbench/Objects/Projector/Data/Animations.asm"
	even
MapSpr_Projector:
	include	"Level/Wacky Workbench/Objects/Projector/Data/Mappings.asm"
	even
ObjProjector_ExplosionLocs:dc.b	1, 0, 0
	dc.b	5,	$EE, $F6
	dc.b	$A, $F6, $A
	dc.b	$F, 0, $EE
	dc.b	$14, $F6, $12
	dc.b	$16, 8, $17
	dc.b	$19, $D, $F6
	dc.b	$1C, $FD, $E7
	dc.b	$1E, $A, $14
	dc.b	$20, $F6, 2
	dc.b	$23, $D, $F6
	dc.b	$28, $F6, $A
	dc.b	$FF
	dc.b	0

; -------------------------------------------------------------------------
