; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Collapsing platform object
; -------------------------------------------------------------------------

ObjCollapsePlatform:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjCollapsePlatform_Index(pc,d0.w),d0
	jsr	ObjCollapsePlatform_Index(pc,d0.w)
	jsr	DrawObject
	cmpi.b	#4,oRoutine(a0)
	bge.s	.End
	jmp	CheckObjDespawn

; -------------------------------------------------------------------------

.End:
	rts
; End of function ObjCollapsePlatform

; -------------------------------------------------------------------------
ObjCollapsePlatform_Index:
	dc.w	ObjCollapsePlatform_Init-ObjCollapsePlatform_Index
	dc.w	ObjCollapsePlatform_Main-ObjCollapsePlatform_Index
	dc.w	ObjCollapsePlatform_Delay-ObjCollapsePlatform_Index
	dc.w	ObjCollapsePlatform_Fall-ObjCollapsePlatform_Index
; -------------------------------------------------------------------------

ObjCollapsePlatform_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oSprFlags(a0)
	move.b	#3,oPriority(a0)
	move.w	#$44BE,oTile(a0)
	lea	MapSpr_CollapsePlatform1(pc),a1
	lea	ObjCollapsePlatform_Sizes1(pc),a2
	move.b	oSubtype(a0),d0
	bpl.s	.SetMaps
	lea	MapSpr_CollapsePlatform2(pc),a1
	lea	ObjCollapsePlatform_Sizes2(pc),a2

.SetMaps:
	move.l	a1,oMap(a0)
	btst	#4,d0
	beq.s	.NoFlip
	bset	#0,oSprFlags(a0)
	bset	#0,oFlags(a0)

.NoFlip:
	andi.w	#$F,d0
	move.b	d0,oMapFrame(a0)
	add.w	d0,d0
	move.w	(a2,d0.w),d0
	move.b	(a2,d0.w),d1
	addq.b	#1,d1
	asl.b	#3,d1
	move.b	d1,oXRadius(a0)
	move.b	d1,oWidth(a0)
	move.b	1(a2,d0.w),d1
	bpl.s	.AbsDY
	neg.b	d1

.AbsDY:
	addq.b	#1,d1
	asl.b	#3,d1
	addq.b	#2,d1
	move.b	d1,oYRadius(a0)
; End of function ObjCollapsePlatform_Init

; -------------------------------------------------------------------------

ObjCollapsePlatform_Main:
	lea	objPlayerSlot.w,a1
	jsr	TopSolidObject
	bne.s	.StandOn
	rts

; -------------------------------------------------------------------------

.StandOn:
	jsr	GetOffObject
	move.w	#FM_A3,d0
	jsr	PlayFMSound
	addq.b	#2,oRoutine(a0)
	move.b	oSubtype(a0),d0
	bpl.w	ObjCollapsePlatform_BreakUp_MultiRow
	bra.w	ObjCollapsePlatform_BreakUp_SingleRow
; End of function ObjCollapsePlatform_Main

; -------------------------------------------------------------------------

ObjCollapsePlatform_Delay:
	addi.w	#-1,oVar2A(a0)
	bne.s	.KeepOn
	addq.b	#2,oRoutine(a0)

.KeepOn:
	move.b	oVar3E(a0),d0
	beq.s	.End
	lea	objPlayerSlot.w,a1
	jsr	TopSolidObject
	beq.s	.End
	tst.w	oVar2A(a0)
	bne.s	.End
	jsr	GetOffObject

.End:
	rts
; End of function ObjCollapsePlatform_Delay

; -------------------------------------------------------------------------

ObjCollapsePlatform_Fall:
	move.l	oVar2C(a0),d0
	add.l	d0,oY(a0)
	addi.l	#$4000,oVar2C(a0)
	move.w	oY(a0),d0
	lea	objPlayerSlot.w,a1
	sub.w	oY(a1),d0
	cmpi.w	#$200,d0
	bgt.w	.Delete
	rts

; -------------------------------------------------------------------------

.Delete:
	jmp	DeleteObject
; End of function ObjCollapsePlatform_Fall

; -------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR ObjCollapsePlatform_Main

ObjCollapsePlatform_BreakUp_MultiRow:
	move.b	oSubtype(a0),d0
	suba.l	a4,a4
	btst	#4,d0
	beq.s	.SkipThis
	lea	ObjCollapsePlatform_BreakUp_MultiRow(pc),a4

.SkipThis:
	lea	ObjCollapsePlatform_Sizes1(pc),a6
	andi.w	#$F,d0
	add.w	d0,d0
	move.w	(a6,d0.w),d0
	lea	(a6,d0.w),a6
	moveq	#0,d0
	move.b	(a6)+,d0
	movea.w	d0,a5
	asl.w	#3,d0
	move.w	#$FFF0,d1
	cmpa.w	#0,a4
	bne.s	.SkipThis2
	neg.w	d0
	neg.w	d1

.SkipThis2:
	add.w	oX(a0),d0
	movea.w	d0,a2
	movea.w	d1,a3
	moveq	#0,d6
	move.b	(a6)+,d6
	move.w	d6,d4
	asl.w	#3,d4
	add.w	oY(a0),d4
	move.w	#9,d2
	move.b	oID(a0),oVar3F(a0)

.Loop:
	move.w	a5,d5
	move.w	a2,d3
	move.w	d2,d1

.Loop2:
	jsr	FindObjSlot
	bne.w	.Solid
	move.b	(a6)+,d0
	bmi.w	.Endxt
	move.b	d0,oMapFrame(a1)
	ori.b	#4,oSprFlags(a1)
	move.b	#3,oPriority(a1)
	move.w	#$44BE,oTile(a1)
	move.l	#MapSpr_CollapsePlatform3,oMap(a1)
	move.l	#$20000,oVar2C(a1)
	move.b	oVar3F(a0),oID(a1)
	move.b	oRoutine(a0),oRoutine(a1)
	cmpa.w	#0,a4
	beq.s	.SkipThis3
	bset	#0,oSprFlags(a1)
	bset	#0,oFlags(a1)

.SkipThis3:
	tst.w	d6
	bne.s	.NotLast
	st	oVar3E(a1)
	move.b	#8,oXRadius(a1)
	move.b	#8,oWidth(a1)
	move.b	#9,oYRadius(a1)

.NotLast:
	move.w	d4,oY(a1)
	move.w	d3,oX(a1)
	move.w	d1,oVar2A(a1)

.Endxt:
	add.w	a3,d3
	addi.w	#$C,d1
	dbf	d5,.Loop2
	addi.w	#-$10,d4
	addq.w	#5,d2
	dbf	d6,.Loop
	bra.s	.Delete

; -------------------------------------------------------------------------

.Solid:
	lea	objPlayerSlot.w,a1
	jsr	TopSolidObject
	beq.s	.Delete
	jsr	GetOffObject

.Delete:
	jmp	DeleteObject

; -------------------------------------------------------------------------

ObjCollapsePlatform_BreakUp_SingleRow:
	move.b	oSubtype(a0),d2
	lea	ObjCollapsePlatform_Sizes2(pc),a6
	move.b	d2,d0
	andi.w	#$1F,d0
	add.w	d0,d0
	move.w	(a6,d0.w),d0
	lea	(a6,d0.w),a6
	move.b	(a6)+,d5
	move.b	(a6)+,d1
	addq.b	#1,d1
	asl.b	#3,d1
	addq.b	#2,d1
	andi.w	#$FF,d5
	move.w	d5,d4
	lsl.w	#3,d4
	neg.w	d4
	move.w	#$10,d3
	moveq	#1,d6
	btst	#6,d2
	bne.w	.GetSpeed
	lsl.b	#2,d2
	bra.s	.SkipSpeed

; -------------------------------------------------------------------------

.GetSpeed:
	lea	objPlayerSlot.w,a1
	move.w	oXVel(a1),d0
	btst	#5,d2
	beq.s	.GotSpeed
	neg.w	d0

.GotSpeed:
	tst.w	d0

.SkipSpeed:
	bpl.s	.InitX
	lea	(a6,d5.w),a6
	neg.w	d4
	neg.w	d3
	neg.w	d6

.InitX:
	add.w	oX(a0),d4
	move.w	#9,d2
	move.b	oID(a0),oVar3F(a0)

.Loop3:
	jsr	FindObjSlot
	bne.w	.Solid2
	move.b	#3,oPriority(a1)
	move.w	#$44BE,oTile(a1)
	ori.b	#4,oSprFlags(a1)
	move.l	#MapSpr_CollapsePlatform4,oMap(a1)
	move.l	#$20000,oVar2C(a1)
	move.b	oVar3F(a0),oID(a1)
	move.b	oRoutine(a0),oRoutine(a1)
	move.w	oY(a0),oY(a1)
	st	oVar3E(a1)
	move.b	#8,oXRadius(a1)
	move.b	#8,oWidth(a1)
	move.b	d1,oYRadius(a1)
	move.b	(a6),oMapFrame(a1)
	lea	(a6,d6.w),a6
	move.w	d4,oX(a1)
	add.w	d3,d4
	move.w	d2,oVar2A(a1)
	addi.w	#$C,d2
	dbf	d5,.Loop3
	bra.s	.Delete2

; -------------------------------------------------------------------------

.Solid2:
	lea	objPlayerSlot.w,a1
	jsr	TopSolidObject
	beq.s	.Delete2
	jsr	GetOffObject

.Delete2:
	jmp	DeleteObject
	
; -------------------------------------------------------------------------
