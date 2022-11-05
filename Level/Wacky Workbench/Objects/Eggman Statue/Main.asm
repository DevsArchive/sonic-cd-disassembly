; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Eggman statue object
; -------------------------------------------------------------------------

oEggStatExplode	EQU	oVar2C
oEggStatTime	EQU	oVar3F

; -------------------------------------------------------------------------

ObjEggmanStatue:
	tst.b	oSubtype(a0)
	bne.w	ObjSpikeBomb

	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)
	
	jsr	DrawObject
	cmpi.b	#2,oRoutine(a0)
	bgt.s	.End
	jmp	CheckObjDespawn
	
.End:
	rts

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjEggmanStatue_Init-.Index
	dc.w	ObjEggmanStatue_Main-.Index
	dc.w	ObjEggmanStatue_Explode-.Index
	dc.w	ObjEggmanStatue_Wait-.Index
	dc.w	ObjEggmanStatue_DropBombs-.Index

; -------------------------------------------------------------------------

ObjEggmanStatue_Init:
	tst.b	goodFuture
	beq.s	.BadFuture
	addq.l	#4,sp
	jmp	DeleteObject

.BadFuture:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oSprFlags(a0)
	move.b	#3,oPriority(a0)
	move.b	#20,oXRadius(a0)
	move.b	#20,oWidth(a0)
	move.b	#28,oYRadius(a0)
	move.w	#$44E8,oTile(a0)
	move.l	#MapSpr_EggmanStatue,oMap(a0)
	move.b	#$F8,oColType(a0)
	move.l	#ObjEggmanStatue_ExplodeLocs,oEggStatExplode(a0)

; -------------------------------------------------------------------------

ObjEggmanStatue_Main:
	tst.b	oColStatus(a0)
	beq.s	.NoExplode
	clr.w	oColType(a0)
	addq.b	#2,oRoutine(a0)
	
	lea	objPlayerSlot.w,a1
	jsr	SolidObject
	beq.s	.End
	jsr	GetOffObject
	
.End:
	rts
	
.NoExplode:
	lea	objPlayerSlot.w,a1
	jmp	SolidObject

; -------------------------------------------------------------------------

ObjEggmanStatue_Explode:
	movea.l	oEggStatExplode(a0),a6
	move.b	(a6)+,d0
	bmi.s	.Done
	addq.b	#1,oEggStatTime(a0)
	cmp.b	oEggStatTime(a0),d0
	bne.s	.End
	
	move.b	(a6)+,d5
	move.b	(a6)+,d6
	move.l	a6,oEggStatExplode(a0)
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
	
.Done:
	addq.b	#2,oRoutine(a0)
	move.b	#1,oMapFrame(a0)
	move.b	#60,oEggStatTime(a0)
	rts

; -------------------------------------------------------------------------

ObjEggmanStatue_Wait:
	subq.b	#1,oEggStatTime(a0)
	bne.s	.End
	addq.b	#2,oRoutine(a0)
	
.End:
	rts

; -------------------------------------------------------------------------

ObjEggmanStatue_DropBombs:
	lea	ObjEggmanStatue_BombLocs(pc),a6
	move.b	oID(a0),d1
	moveq	#-1,d2
	move.w	oX(a0),d3
	move.w	oY(a0),d4
	
.SpawnBombs:
	move.b	(a6)+,d5
	cmpi.b	#-1,d5
	beq.s	.Done
	move.b	(a6)+,d6
	ext.w	d5
	ext.w	d6
	
	jsr	FindObjSlot
	bne.s	.Done
	move.b	d1,oID(a1)
	move.b	d2,oSubtype(a1)
	move.w	d3,oX(a1)
	move.w	d4,oY(a1)
	subi.w	#160,oY(a1)
	add.w	d5,oX(a1)
	add.w	d6,oY(a1)
	move.w	d4,oSpikeFloorY(a1)
	addi.w	#38,oSpikeFloorY(a1)
	bra.s	.SpawnBombs
	
.Done:
	jmp	DeleteObject

; -------------------------------------------------------------------------

MapSpr_EggmanStatue:
	include	"Level/Wacky Workbench/Objects/Eggman Statue/Data/Mappings (Statue).asm"
	even

ObjEggmanStatue_ExplodeLocs:
	dc.b	1, 0, 0
	dc.b	5, $EE, $F6
	dc.b	$A, $F6, $A
	dc.b	$F, 0, $F6
	dc.b	$14, $F6, $F6
	dc.b	$19, $D, $F6
	dc.b	$1E, $F6, $14
	dc.b	$23, $D, $F6
	dc.b	$28, $F6, $A
	dc.b	-1
	even

ObjEggmanStatue_BombLocs:
	dc.b	$E8, $C0
	dc.b	$F8, $40
	dc.b	8, 0
	dc.b	$18, $80
	dc.b	$28, $80
	dc.b	$38, $40
	dc.b	$48, $40
	dc.b	$58, $80
	dc.b	$68, $40
	dc.b	$78, $C0
	dc.b	-1
	even

; -------------------------------------------------------------------------
; Spike bomb
; -------------------------------------------------------------------------

oSpikeYVel	EQU	oVar2A
oSpikeFloorY	EQU	oVar2E

; -------------------------------------------------------------------------

ObjSpikeBomb:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)
	jmp	DrawObject

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjSpikeBomb_Init-.Index
	dc.w	ObjSpikeBomb_Main-.Index
	dc.w	ObjSpikeBomb_Explode-.Index

; -------------------------------------------------------------------------

ObjSpikeBomb_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oSprFlags(a0)
	move.b	#3,oPriority(a0)
	move.b	#6,oYRadius(a0)
	move.b	#6,oXRadius(a0)
	move.b	#6,oWidth(a0)
	move.w	#$4C8,oTile(a0)
	move.l	#MapSpr_SpikeBomb,oMap(a0)
	move.b	#$B7,oColType(a0)
	move.l	#0,oSpikeYVel(a0)

; -------------------------------------------------------------------------

ObjSpikeBomb_Main:
	move.l	oSpikeYVel(a0),d0
	add.l	d0,oY(a0)
	addi.l	#$400,oSpikeYVel(a0)
	
	move.w	oY(a0),d0
	cmp.w	oSpikeFloorY(a0),d0
	blt.s	.Animate
	addq.b	#2,oRoutine(a0)
	
.Animate:
	lea	Ani_SpikeBomb(pc),a1
	jmp	AnimateObject

; -------------------------------------------------------------------------

ObjSpikeBomb_Explode:
	move.b	#$18,oID(a0)
	move.b	#0,oRoutine(a0)
	move.b	#1,oExplodeBadnik(a0)
	move.w	#FM_EXPLODE,d0
	jmp	PlayFMSound

; -------------------------------------------------------------------------

Ani_SpikeBomb:
	include	"Level/Wacky Workbench/Objects/Eggman Statue/Data/Animations (Bomb).asm"
	even

MapSpr_SpikeBomb:
	include	"Level/Wacky Workbench/Objects/Eggman Statue/Data/Mappings (Bomb).asm"
	even

; -------------------------------------------------------------------------
