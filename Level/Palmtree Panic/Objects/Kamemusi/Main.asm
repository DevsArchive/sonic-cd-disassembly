; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Kamemusi object
; -------------------------------------------------------------------------

ObjKamemusi:
	cmpi.b	#1,oSubtype(a0)
	beq.w	ObjKamemusiMissile
	jsr	DestroyOnGoodFuture
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjKamemusi_Index(pc,d0.w),d0
	jsr	ObjKamemusi_Index(pc,d0.w)
	jsr	DrawObject
	move.w	oVar2A(a0),d0
	jmp	CheckObjDespawn2Time
; End of function ObjKamemusi

; -------------------------------------------------------------------------
ObjKamemusi_Index:dc.w	ObjKamemusi_Init-ObjKamemusi_Index
	dc.w	ObjKamemusi_Position-ObjKamemusi_Index
	dc.w	ObjKamemusi_Main-ObjKamemusi_Index
	dc.w	ObjKamemusi_Wait1-ObjKamemusi_Index
	dc.w	ObjKamemusi_Wait2-ObjKamemusi_Index
	dc.w	ObjKamemusi_Fire-ObjKamemusi_Index
; -------------------------------------------------------------------------

ObjKamemusi_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oRender(a0)
	move.b	#4,oPriority(a0)
	move.b	#$2C,oColType(a0)
	move.b	#$10,oXRadius(a0)
	move.b	#$10,oWidth(a0)
	move.b	#$F,oYRadius(a0)
	move.w	oX(a0),oVar2A(a0)
	moveq	#4,d0
	jsr	LevelObj_SetBaseTile
	tst.b	oSubtype(a0)
	bne.s	.AltMaps
	lea	MapSpr_Kamemusi1(pc),a1
	lea	Ani_Kamemusi1(pc),a2
	move.l	#-$A000,d0
	bra.s	.SetMaps

; -------------------------------------------------------------------------

.AltMaps:
	lea	MapSpr_Kamemusi2(pc),a1
	lea	Ani_Kamemusi2(pc),a2
	move.l	#-$5000,d0

.SetMaps:
	move.l	a1,4(a0)
	move.l	a2,oVar30(a0)
	move.l	d0,oVar2C(a0)
; End of function ObjKamemusi_Init

; -------------------------------------------------------------------------

ObjKamemusi_Position:
	move.l	#$10000,d0
	add.l	d0,oY(a0)
	jsr	CheckFloorEdge
	tst.w	d1
	bpl.s	.End
	addq.b	#2,oRoutine(a0)

.End:
	rts
; End of function ObjKamemusi_Position

; -------------------------------------------------------------------------

ObjKamemusi_Main:
	tst.w	lvlDebugMode
	bne.s	.SkipRange
	tst.b	$28(a0)
	bne.s	.SkipRange
	tst.w	$34(a0)
	beq.s	.DoRange
	subq.w	#1,$34(a0)
	bra.s	.SkipRange

; -------------------------------------------------------------------------

.DoRange:
	lea	objPlayerSlot.w,a1
	bsr.s	ObjKamemusi_CheckInRange
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
	jsr	CheckFloorEdge
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
	bchg	#0,oRender(a0)
	bchg	#0,oStatus(a0)
	bra.s	ObjKamemusi_Main

; -------------------------------------------------------------------------

.NextState:
	addq.b	#2,oRoutine(a0)
	rts
; End of function ObjKamemusi_Main

; -------------------------------------------------------------------------

ObjKamemusi_CheckInRange:
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
; End of function ObjKamemusi_CheckInRange

; -------------------------------------------------------------------------

ObjKamemusi_Wait1:
	addq.b	#2,oRoutine(a0)
	move.b	#1,oAnim(a0)
; End of function ObjKamemusi_Wait1

; -------------------------------------------------------------------------

ObjKamemusi_Wait2:
	movea.l	oVar30(a0),a1
	jmp	AnimateObject
; End of function ObjKamemusi_Wait2

; -------------------------------------------------------------------------

ObjKamemusi_Fire:
	move.b	#4,oRoutine(a0)
	move.b	#0,oAnim(a0)
	move.w	#$78,oVar34(a0)
	tst.b	oSubtype(a0)
	bne.s	.End
	jsr	FindObjSlot
	bne.s	.End
	tst.b	oRender(a0)
	bpl.s	.SkipSound
	move.w	#$A0,d0
	jsr	PlayFMSound

.SkipSound:
	bsr.s	ObjKamemusi_InitMissile
	sf	oVar3F(a1)
	jsr	FindObjSlot
	bne.s	.End
	bsr.s	ObjKamemusi_InitMissile
	st	oVar3F(a1)

.End:
	rts
; End of function ObjKamemusi_Fire

; -------------------------------------------------------------------------

ObjKamemusi_InitMissile:
	move.b	oID(a0),oID(a1)
	move.b	#1,oSubtype(a1)
	move.w	oTile(a0),oTile(a1)
	move.b	oPriority(a0),oPriority(a1)
	addq.b	#1,oPriority(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	subi.w	#10,oY(a1)
	rts
; End of function ObjKamemusi_InitMissile

; -------------------------------------------------------------------------
Ani_Kamemusi1:
	include	"Level/Palmtree Panic/Objects/Kamemusi/Data/Animations (Normal).asm"
	even
Ani_Kamemusi2:
	include	"Level/Palmtree Panic/Objects/Kamemusi/Data/Animations (Damaged).asm"
	even
	include	"Level/Palmtree Panic/Objects/Kamemusi/Data/Mappings.asm"
	even

; -------------------------------------------------------------------------

ObjKamemusiMissile:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjKamemusiMissile_Index(pc,d0.w),d0
	jsr	ObjKamemusiMissile_Index(pc,d0.w)
	jmp	DrawObject
; End of function ObjKamemusiMissile

; -------------------------------------------------------------------------
ObjKamemusiMissile_Index:dc.w	ObjKamemusiMissile_Init-ObjKamemusiMissile_Index
	dc.w	ObjKamemusiMissile_Main-ObjKamemusiMissile_Index
; -------------------------------------------------------------------------

ObjKamemusiMissile_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oRender(a0)
	move.b	#$AD,oColType(a0)
	move.b	#8,oXRadius(a0)
	move.b	#8,oWidth(a0)
	move.b	#8,oYRadius(a0)
	move.l	#MapSpr_KamemusiMissile,oMap(a0)
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
; End of function ObjKamemusiMissile_Init

; -------------------------------------------------------------------------

ObjKamemusiMissile_Main:
	tst.b	oRender(a0)
	bmi.s	.Action
	jmp	DeleteObject

; -------------------------------------------------------------------------

.Action:
	jsr	CheckFloorEdge
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
	lea	Ani_KamemusiMissile(pc),a1
	jmp	AnimateObject
; End of function ObjKamemusiMissile_Main

; -------------------------------------------------------------------------
Ani_KamemusiMissile:
	include	"Level/Palmtree Panic/Objects/Kamemusi/Data/Animations (Missile).asm"
	even
MapSpr_KamemusiMissile:
	include	"Level/Palmtree Panic/Objects/Kamemusi/Data/Mappings (Missile).asm"
	even

; -------------------------------------------------------------------------
