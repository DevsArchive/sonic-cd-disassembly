; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Wacky Workbench animal object
; -------------------------------------------------------------------------

ObjAnimal:
	jsr	CheckAnimalPrescence
	move.b	oSubtype(a0),d0
	andi.b	#$7F,d0
	bne.w	ObjGroundAnimal

ObjFlyingAnimal:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjFlyingAnimal_Index(pc,d0.w),d0
	jmp	ObjFlyingAnimal_Index(pc,d0.w)

; -------------------------------------------------------------------------
ObjFlyingAnimal_Index:
	dc.w	ObjFlyingAnimal_Init-ObjFlyingAnimal_Index
	dc.w	ObjFlyingAnimal_Flying-ObjFlyingAnimal_Index
	dc.w	ObjFlyingAnimal_Hologram-ObjFlyingAnimal_Index
; -------------------------------------------------------------------------

ObjFlyingAnimal_Init:
	addq.b	#2,oRoutine(a0)
	move.b	#4,oSprFlags(a0)
	move.l	#$8080108,oYRadius(a0)
	move.l	#MapSpr_FlyingAnimal,oMap(a0)
	move.w	oX(a0),oVar2A(a0)
	move.w	oY(a0),oVar2C(a0)
	bsr.w	ObjAnimal_XFlip
	bsr.w	ObjAnimal_SetBaseTile
	tst.b	oSubtype(a0)
	bmi.s	.Holographic
	move.b	#1,oPriority(a0)
	ori.w	#$8000,oTile(a0)
	move.w	#$101,oVar2E(a0)
	rts

; -------------------------------------------------------------------------

.Holographic:
	addq.b	#2,oRoutine(a0)
	move.b	#1,oAnim(a0)
	move.b	#3,oPriority(a0)
	rts
; End of function ObjFlyingAnimal_Init

; -------------------------------------------------------------------------

ObjFlyingAnimal_Flying:
	moveq	#1,d2
	moveq	#1,d3
	bsr.w	ObjFlyingAnimal_Move
	move.b	oVar2E(a0),d0
	add.b	oVar2F(a0),d0
	move.b	d0,d1
	subq.b	#1,d1
	subi.b	#$7F,d1
	bcs.s	.NoFlip
	move.b	oVar2E(a0),d0
	neg.b	oVar2F(a0)
	bsr.w	ObjAnimal_XFlip

.NoFlip:
	move.b	d0,oVar2E(a0)
	lea	Ani_FlyingAnimal(pc),a1
	jsr	AnimateObject
	jsr	DrawObject
	move.w	oVar2A(a0),d0
	jmp	CheckObjDespawn2
; End of function ObjFlyingAnimal_Flying

; -------------------------------------------------------------------------

ObjFlyingAnimal_Hologram:

; FUNCTION CHUNK AT 0020D17C SIZE 00000006 BYTES

	movea.w	oVar3E(a0),a1
	cmpi.b	#$2F,oID(a1)
	bne.w	ObjAnimal_Destroy
	tst.b	oVar3F(a1)
	bne.w	ObjAnimal_Destroy
	moveq	#3,d2
	moveq	#4,d3
	bsr.w	ObjFlyingAnimal_Move
	addq.b	#4,oVar2E(a0)
	move.b	oVar2E(a0),d0
	andi.b	#$7F,d0
	beq.w	ObjAnimal_XFlip
	lea	Ani_FlyingAnimal(pc),a1
	jsr	AnimateObject
	jmp	DrawObject
; End of function ObjFlyingAnimal_Hologram

; -------------------------------------------------------------------------

ObjFlyingAnimal_Move:
	move.b	oVar2E(a0),d0
	jsr	CalcSine
	asr.w	d2,d1
	asr.w	d3,d0
	add.w	oVar2A(a0),d1
	add.w	oVar2C(a0),d0
	move.w	d1,oX(a0)
	move.w	d0,oY(a0)
	rts
; End of function ObjFlyingAnimal_Move

; -------------------------------------------------------------------------

ObjGroundAnimal:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjGroundAnimal_Index(pc,d0.w),d0
	jmp	ObjGroundAnimal_Index(pc,d0.w)
; End of function ObjGroundAnimal

; -------------------------------------------------------------------------
ObjGroundAnimal_Index:
	dc.w	ObjGroundAnimal_Init-ObjGroundAnimal_Index
	dc.w	ObjGroundAnimal_Main-ObjGroundAnimal_Index
	dc.w	ObjGroundAnimal_Main-ObjGroundAnimal_Index
	dc.w	ObjGroundAnimal_Flip-ObjGroundAnimal_Index
	dc.w	ObjGroundAnimal_Hologram-ObjGroundAnimal_Index
; -------------------------------------------------------------------------

ObjGroundAnimal_Init:
	addq.b	#2,oRoutine(a0)
	move.b	#4,oSprFlags(a0)
	move.l	#$8080408,oYRadius(a0)
	move.l	#MapSpr_GroundAnimal,oMap(a0)
	bsr.w	ObjAnimal_SetBaseTile
	tst.b	oSubtype(a0)
	bmi.s	.Holographic
	move.l	#$10000,oVar2C(a0)
	move.l	#-$40000,oVar30(a0)
	rts

; -------------------------------------------------------------------------

.Holographic:
	move.b	#8,oRoutine(a0)
	rts
; End of function ObjGroundAnimal_Init

; -------------------------------------------------------------------------

ObjGroundAnimal_Main:
	move.l	oVar2C(a0),d0
	add.l	d0,oX(a0)
	move.l	oVar30(a0),d0
	add.l	d0,oY(a0)
	addi.l	#$2000,oVar30(a0)
	smi	d0
	addq.b	#1,d0
	move.b	d0,oMapFrame(a0)
	jsr	ObjGetFloorDist
	tst.w	d1
	bpl.s	ObjGroundAnimal_Draw
	addq.b	#2,oRoutine(a0)
	add.w	d1,oY(a0)
	move.l	#-$40000,oVar30(a0)

ObjGroundAnimal_Draw:
	jsr	DrawObject
	jmp	CheckObjDespawn
; End of function ObjGroundAnimal_Main

; -------------------------------------------------------------------------

ObjGroundAnimal_Flip:
	move.b	#2,oRoutine(a0)
	neg.l	oVar2C(a0)
	bsr.s	ObjAnimal_XFlip
	bra.s	ObjGroundAnimal_Draw
; End of function ObjGroundAnimal_Flip

; -------------------------------------------------------------------------

ObjGroundAnimal_Hologram:
	movea.w	oVar3E(a0),a1
	cmpi.b	#$2F,oID(a1)
	bne.w	ObjAnimal_Destroy
	tst.b	oVar3F(a1)
	bne.w	ObjAnimal_Destroy
	lea	Ani_GroundAnimal(pc),a1
	jsr	AnimateObject
	jmp	DrawObject
; End of function ObjGroundAnimal_Hologram

; -------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR ObjFlyingAnimal_Hologram

ObjAnimal_Destroy:
	jmp	DeleteObject
; END OF FUNCTION CHUNK	FOR ObjFlyingAnimal_Hologram
; -------------------------------------------------------------------------

ObjAnimal_XFlip:
	bchg	#0,oSprFlags(a0)
	bchg	#0,oFlags(a0)
	rts
; End of function ObjAnimal_XFlip

; -------------------------------------------------------------------------

ObjAnimal_SetBaseTile:
	lea	ObjAnimal_BaseTileList(pc),a1
	moveq	#0,d0
	move.b	act,d0
	asl.w	#2,d0
	add.b	timeZone,d0
	add.w	d0,d0
	move.w	(a1,d0.w),oTile(a0)
	rts
; End of function ObjAnimal_SetBaseTile

; -------------------------------------------------------------------------
Ani_FlyingAnimal:
	include	"Level/Wacky Workbench/Objects/Animal/Data/Animations (Flying).asm"
	even
Ani_GroundAnimal:
	include	"Level/Wacky Workbench/Objects/Animal/Data/Animations (Ground).asm"
	even
MapSpr_FlyingAnimal:
	include	"Level/Wacky Workbench/Objects/Animal/Data/Mappings (Flying).asm"
	even
MapSpr_GroundAnimal:
	include	"Level/Wacky Workbench/Objects/Animal/Data/Mappings (Ground).asm"
	even
ObjAnimal_BaseTileList:
	dc.w	$4D0
	dc.w	$4D0
	dc.w	$4D0
	dc.w	0
	dc.w	$4D0
	dc.w	$4D0
	dc.w	$4D0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	$4D0
	
; -------------------------------------------------------------------------
