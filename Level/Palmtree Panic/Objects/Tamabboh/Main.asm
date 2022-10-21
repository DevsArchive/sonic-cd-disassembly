; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Tamabboh object
; -------------------------------------------------------------------------

ObjTamabboh:
	cmpi.b	#1,oSubtype(a0)
	beq.w	ObjTamabbohMissile
	jsr	DestroyOnGoodFuture
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjTamabboh_Index(pc,d0.w),d0
	jsr	ObjTamabboh_Index(pc,d0.w)
	jsr	DrawObject
	move.w	oVar2A(a0),d0
	jmp	CheckObjDespawn2
; End of function ObjTamabboh

; -------------------------------------------------------------------------
ObjTamabboh_Index:dc.w	ObjTamabboh_Init-ObjTamabboh_Index
	dc.w	ObjTamabboh_Position-ObjTamabboh_Index
	dc.w	ObjTamabboh_Main-ObjTamabboh_Index
	dc.w	ObjTamabboh_Wait1-ObjTamabboh_Index
	dc.w	ObjTamabboh_Wait2-ObjTamabboh_Index
	dc.w	ObjTamabboh_Fire-ObjTamabboh_Index
; -------------------------------------------------------------------------

ObjTamabboh_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oSprFlags(a0)
	move.b	#4,oPriority(a0)
	move.b	#$2C,oColType(a0)
	move.b	#$10,oXRadius(a0)
	move.b	#$10,oWidth(a0)
	move.b	#$F,oYRadius(a0)
	move.w	oX(a0),oVar2A(a0)
	moveq	#4,d0
	jsr	SetObjectTileID
	tst.b	oSubtype(a0)
	bne.s	.AltMaps
	lea	MapSpr_Tamabboh1(pc),a1
	lea	Ani_Tamabboh1(pc),a2
	move.l	#-$A000,d0
	bra.s	.SetMaps

; -------------------------------------------------------------------------

.AltMaps:
	lea	MapSpr_Tamabboh2(pc),a1
	lea	Ani_Tamabboh2(pc),a2
	move.l	#-$5000,d0

.SetMaps:
	move.l	a1,oMap(a0)
	move.l	a2,oVar30(a0)
	move.l	d0,oVar2C(a0)
; End of function ObjTamabboh_Init

; -------------------------------------------------------------------------

ObjTamabboh_Position:
	move.l	#$10000,d0
	add.l	d0,oY(a0)
	jsr	ObjGetFloorDist
	tst.w	d1
	bpl.s	.End
	addq.b	#2,oRoutine(a0)

.End:
	rts
; End of function ObjTamabboh_Position

; -------------------------------------------------------------------------

ObjTamabboh_Main:
	tst.w	debugMode
	bne.s	.SkipRange
	tst.b	oSubtype(a0)
	bne.s	.SkipRange
	tst.w	oVar34(a0)
	beq.s	.DoRange
	subq.w	#1,oVar34(a0)
	bra.s	.SkipRange

; -------------------------------------------------------------------------

.DoRange:
	lea	objPlayerSlot.w,a1
	bsr.s	ObjTamabboh_CheckInRange
	bcs.s	.NextState

.SkipRange:
	move.l	oVar2C(a0),d0
	add.l	d0,oX(a0)
	move.w	oX(a0),d0
	sub.w	oVar2A(a0),d0
	bpl.s	.ChlTirm
	neg.w	d0

.ChlTirm:
	cmpi.w	#$80,d0
	bge.s	.TurnAround
	jsr	ObjGetFloorDist
	cmpi.w	#-7,d1
	blt.s	.TurnAround
	cmpi.w	#7,d1
	bgt.s	.TurnAround
	add.w	d1,oY(a0)
	movea.l	oVar30(a0),a1
	jmp	AnimateObject

; -------------------------------------------------------------------------

.TurnAround:
	neg.l	oVar2C(a0)
	bchg	#0,oSprFlags(a0)
	bchg	#0,oFlags(a0)
	bra.s	ObjTamabboh_Main

; -------------------------------------------------------------------------

.NextState:
	addq.b	#2,oRoutine(a0)
	rts
; End of function ObjTamabboh_Main

; -------------------------------------------------------------------------

ObjTamabboh_CheckInRange:
	move.w	oY(a1),d0
	sub.w	oY(a0),d0
	subi.w	#-$50,d0
	subi.w	#$A0,d0
	bcc.s	.End
	move.w	oX(a1),d0
	sub.w	oX(a0),d0
	move.w	d0,d1
	subi.w	#-$50,d1
	subi.w	#$A0,d1

.End:
	rts
; End of function ObjTamabboh_CheckInRange

; -------------------------------------------------------------------------

ObjTamabboh_Wait1:
	addq.b	#2,oRoutine(a0)
	move.b	#1,oAnim(a0)
; End of function ObjTamabboh_Wait1

; -------------------------------------------------------------------------

ObjTamabboh_Wait2:
	movea.l	oVar30(a0),a1
	jmp	AnimateObject
; End of function ObjTamabboh_Wait2

; -------------------------------------------------------------------------

ObjTamabboh_Fire:
	move.b	#4,oRoutine(a0)
	move.b	#0,oAnim(a0)
	move.w	#$78,oVar34(a0)
	tst.b	oSubtype(a0)
	bne.s	.End
	jsr	FindObjSlot
	bne.s	.End
	tst.b	oSprFlags(a0)
	bpl.s	.SkipSound
	move.w	#FM_A0,d0
	jsr	PlayFMSound

.SkipSound:
	bsr.s	ObjTamabboh_InitMissile
	sf	oVar3F(a1)
	jsr	FindObjSlot
	bne.s	.End
	bsr.s	ObjTamabboh_InitMissile
	st	oVar3F(a1)

.End:
	rts
; End of function ObjTamabboh_Fire

; -------------------------------------------------------------------------

ObjTamabboh_InitMissile:
	move.b	oID(a0),oID(a1)
	move.b	#1,oSubtype(a1)
	move.w	oTile(a0),oTile(a1)
	move.b	oPriority(a0),oPriority(a1)
	addq.b	#1,oPriority(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	subi.w	#10,oY(a1)
	rts
; End of function ObjTamabboh_InitMissile

; -------------------------------------------------------------------------
Ani_Tamabboh1:
	include	"Level/Palmtree Panic/Objects/Tamabboh/Data/Animations (Normal).asm"
	even
Ani_Tamabboh2:
	include	"Level/Palmtree Panic/Objects/Tamabboh/Data/Animations (Damaged).asm"
	even
	include	"Level/Palmtree Panic/Objects/Tamabboh/Data/Mappings.asm"
	even

; -------------------------------------------------------------------------

ObjTamabbohMissile:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjTamabbohMissile_Index(pc,d0.w),d0
	jsr	ObjTamabbohMissile_Index(pc,d0.w)
	jmp	DrawObject
; End of function ObjTamabbohMissile

; -------------------------------------------------------------------------
ObjTamabbohMissile_Index:dc.w	ObjTamabbohMissile_Init-ObjTamabbohMissile_Index
	dc.w	ObjTamabbohMissile_Main-ObjTamabbohMissile_Index
; -------------------------------------------------------------------------

ObjTamabbohMissile_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oSprFlags(a0)
	move.b	#$AD,oColType(a0)
	move.b	#8,oXRadius(a0)
	move.b	#8,oWidth(a0)
	move.b	#8,oYRadius(a0)
	move.l	#MapSpr_TamabbohMissile,oMap(a0)
	move.l	#0,oVar32(a0)
	move.l	#$2000,oVar36(a0)
	tst.b	oVar3F(a0)
	bne.s	.FlipX
	move.l	#$20000,d0
	move.l	#-$40000,d1
	bra.s	.SetSpeeds

; -------------------------------------------------------------------------

.FlipX:
	move.l	#-$20000,d0
	move.l	#-$40000,d1

.SetSpeeds:
	move.l	d0,oVar2A(a0)
	move.l	d1,oVar2E(a0)
	rts
; End of function ObjTamabbohMissile_Init

; -------------------------------------------------------------------------

ObjTamabbohMissile_Main:
	tst.b	oSprFlags(a0)
	bmi.s	.Action
	jmp	DeleteObject

; -------------------------------------------------------------------------

.Action:
	jsr	ObjGetFloorDist
	tst.w	d1
	bpl.s	.MoveAnim
	jmp	DeleteObject

; -------------------------------------------------------------------------

.MoveAnim:
	move.l	oVar2A(a0),d0
	add.l	d0,oX(a0)
	move.l	oVar2E(a0),d0
	add.l	d0,oY(a0)
	move.l	oVar32(a0),d0
	add.l	d0,oVar2A(a0)
	move.l	oVar36(a0),d0
	add.l	d0,oVar2E(a0)
	lea	Ani_TamabbohMissile(pc),a1
	jmp	AnimateObject
; End of function ObjTamabbohMissile_Main

; -------------------------------------------------------------------------
Ani_TamabbohMissile:
	include	"Level/Palmtree Panic/Objects/Tamabboh/Data/Animations (Missile).asm"
	even
MapSpr_TamabbohMissile:
	include	"Level/Palmtree Panic/Objects/Tamabboh/Data/Mappings (Missile).asm"
	even

; -------------------------------------------------------------------------
