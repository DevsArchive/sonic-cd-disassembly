; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Platform object
; -------------------------------------------------------------------------

ObjCollapsePlatform:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjCollapsePlatform_Index(pc,d0.w),d0
	jsr	ObjCollapsePlatform_Index(pc,d0.w)
	jsr	DrawObject
	cmpi.b	#4,oRoutine(a0)
	bge.s	.End
	jmp	CheckObjDespawnTime

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
	ori.b	#4,oRender(a0)
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
	bset	#0,oRender(a0)
	bset	#0,oStatus(a0)

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

; FUNCTION CHUNK AT 0020C32C SIZE 000001F4 BYTES

	lea	objPlayerSlot.w,a1
	jsr	SolidObject1
	bne.s	.StandOn
	rts

; -------------------------------------------------------------------------

.StandOn:
	jsr	ClearObjRide
	move.w	#$A3,d0
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
	jsr	SolidObject1
	beq.s	.End
	tst.w	oVar2A(a0)
	bne.s	.End
	jsr	ClearObjRide

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
	add.w	$C(a0),d4
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
	ori.b	#4,oRender(a1)
	move.b	#3,oPriority(a1)
	move.w	#$44BE,oTile(a1)
	move.l	#MapSpr_CollapsePlatform3,oMap(a1)
	move.l	#$20000,oVar2C(a1)
	move.b	oVar3F(a0),oID(a1)
	move.b	oRoutine(a0),oRoutine(a1)
	cmpa.w	#0,a4
	beq.s	.SkipThis3
	bset	#0,oRender(a1)
	bset	#0,oStatus(a1)

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
	jsr	SolidObject1
	beq.s	.Delete
	jsr	ClearObjRide

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
	ori.b	#4,oRender(a1)
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
	jsr	SolidObject1
	beq.s	.Delete2
	jsr	ClearObjRide

.Delete2:
	jmp	DeleteObject
; END OF FUNCTION CHUNK	FOR ObjCollapsePlatform_Main

; -------------------------------------------------------------------------
MapSpr_CollapsePlatform1:
	include	"Level/Palmtree Panic/Objects/Platform/Data/Mappings (Collapse Ledge).asm"
	even
ObjCollapsePlatform_Sizes1:dc.w	byte_20C598-ObjCollapsePlatform_Sizes1
byte_20C598:	dc.b	4,	3
	dc.b	$FF, $FF
	dc.b	0,	0
	dc.b	0,	1
	dc.b	2,	3
	dc.b	3,	4
	dc.b	0,	5
	dc.b	5,	5
	dc.b	5,	6
	dc.b	6,	6
	dc.b	6,	6
MapSpr_CollapsePlatform3:
	include	"Level/Palmtree Panic/Objects/Platform/Data/Mappings (Collapse Pieces 1).asm"
	even
MapSpr_CollapsePlatform2:
	include	"Level/Palmtree Panic/Objects/Platform/Data/Mappings (Collapse).asm"
	even


ObjCollapsePlatform_Sizes2:dc.w	byte_20C790-ObjCollapsePlatform_Sizes2
	dc.w	byte_20C790-ObjCollapsePlatform_Sizes2
	dc.w	byte_20C798-ObjCollapsePlatform_Sizes2
	dc.w	byte_20C79E-ObjCollapsePlatform_Sizes2
	dc.w	byte_20C7A4-ObjCollapsePlatform_Sizes2
	dc.w	byte_20C7A8-ObjCollapsePlatform_Sizes2
byte_20C790:	dc.b	5,	1
	dc.b	0,	0
	dc.b	0,	0
	dc.b	0,	0
byte_20C798:	dc.b	3,	3
	dc.b	1,	2
	dc.b	2,	2
byte_20C79E:	dc.b	3,	3
	dc.b	2,	2
	dc.b	2,	2
byte_20C7A4:	dc.b	1,	3
	dc.b	3,	5
byte_20C7A8:	dc.b	1,	3
	dc.b	5,	4
MapSpr_CollapsePlatform4:
	include	"Level/Palmtree Panic/Objects/Platform/Data/Mappings (Collapse Pieces 2).asm"
	even

; -------------------------------------------------------------------------
; Regular platform
; -------------------------------------------------------------------------

ObjPlatform:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjPlatform_Index(pc,d0.w),d0
	jsr	ObjPlatform_Index(pc,d0.w)
	jsr	DrawObject
	rts
; End of function ObjPlatform

; -------------------------------------------------------------------------
ObjPlatform_Index:dc.w	ObjPlatform_Init-ObjPlatform_Index
	dc.w	ObjPlatform_Main-ObjPlatform_Index
; -------------------------------------------------------------------------

ObjPlatform_SolidObj:
	lea	objPlayerSlot.w,a1
	move.w	oX(a0),d3
	move.w	oY(a0),d4
	jmp	SolidObject1
; End of function ObjPlatform_SolidObj

; -------------------------------------------------------------------------

ObjPlatform_Init:
	ori.b	#4,oRender(a0)
	move.w	#$44BE,oTile(a0)
	move.b	#2,oPriority(a0)
	move.w	oX(a0),oVar38(a0)
	move.w	oY(a0),oVar3A(a0)
	move.w	oY(a0),oVar36(a0)
	move.l	#MapSpr_Platform,d0
	cmpi.w	#0,levelZone
	beq.s	.SetMaps
	move.l	#MapSpr_Platform,d0
	cmpi.w	#1,levelZone
	beq.s	.SetMaps
	move.l	#MapSpr_Platform,d0

.SetMaps:
	move.l	d0,oMap(a0)
	move.b	oSubtype(a0),d0
	move.b	d0,d1
	andi.w	#3,d0
	move.b	d0,oMapFrame(a0)
	move.b	ObjPlatform_Widths(pc,d0.w),oWidth(a0)
	move.b	#8,oYRadius(a0)
	lsr.b	#2,d1
	andi.w	#3,d1
	move.b	ObjPlatform_Ranges(pc,d1.w),oVar2D(a0)
	move.b	oSubtype2(a0),d0
	beq.s	.NoChild
	jsr	FindObjSlot
	beq.s	.MakeSpring
	jmp	ObjPlatform_Destroy

; -------------------------------------------------------------------------

.MakeSpring:
	move.b	#$A,oID(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	subi.w	#$10,oY(a1)
	move.b	#$F0,oVar39(a1)
	move.w	a0,oVar34(a1)
	move.b	oSubtype2(a0),d0
	move.b	d0,d1
	andi.b	#2,d1
	move.b	d1,oSubtype(a1)
	andi.b	#$F8,d0
	move.b	d0,oVar38(a1)
	add.w	d0,oX(a1)

.NoChild:
	addq.b	#2,oRoutine(a0)
	rts
; End of function ObjPlatform_Init

; -------------------------------------------------------------------------
ObjPlatform_Widths:dc.b	$10, $20, $30, 0
ObjPlatform_Ranges:dc.b	2, 3, 4, 6
; -------------------------------------------------------------------------

ObjPlatform_Main:
	tst.w	timeStopTimer
	beq.s	.TimeOK
	bra.w	ObjPlatform_SolidObj

; -------------------------------------------------------------------------

.TimeOK:
	move.b	oSubtype(a0),d0
	lsr.b	#4,d0
	andi.w	#$F,d0
	add.w	d0,d0
	move.w	ObjPlatform_Subtypes(pc,d0.w),d0
	jsr	ObjPlatform_Subtypes(pc,d0.w)
	move.w	$38(a0),d0
	andi.w	#$FF80,d0
	move.w	cameraX.w,d1
	subi.w	#$80,d1
	andi.w	#$FF80,d1
	sub.w	d1,d0
	cmpi.w	#$280,d0
	bhi.s	.Destroy
	rts

; -------------------------------------------------------------------------

.Destroy:
	lea	objPlayerSlot.w,a1
	jsr	ClearObjRide
	bra.w	ObjPlatform_Destroy
; End of function ObjPlatform_Main

; -------------------------------------------------------------------------
ObjPlatform_Subtypes:
	dc.w	ObjPlatform_Subtype0X-ObjPlatform_Subtypes
	dc.w	ObjPlatform_Subtype1X-ObjPlatform_Subtypes
	dc.w	ObjPlatform_Subtype2X-ObjPlatform_Subtypes
	dc.w	ObjPlatform_Subtype3X-ObjPlatform_Subtypes
	dc.w	ObjPlatform_Subtype4X-ObjPlatform_Subtypes
	dc.w	ObjPlatform_Subtype5X-ObjPlatform_Subtypes
	dc.w	ObjPlatform_Subtype6X-ObjPlatform_Subtypes
	dc.w	ObjPlatform_Subtype7X-ObjPlatform_Subtypes
	dc.w	ObjPlatform_Subtype8X-ObjPlatform_Subtypes
	dc.w	ObjPlatform_Subtype9X-ObjPlatform_Subtypes
; -------------------------------------------------------------------------

ObjPlatform_Subtype0X:
	addq.b	#1,oVar2A(a0)
	jsr	ObjPlatform_DoOsc(pc)
	add.w	oVar3A(a0),d0
	move.w	d0,oY(a0)
	jmp	ObjPlatform_SolidObj
; End of function ObjPlatform_Subtype0X

; -------------------------------------------------------------------------

ObjPlatform_Subtype1X:
	move.l	oX(a0),-(sp)
	jsr	ObjPlatform_DoOsc(pc)
	add.w	oVar38(a0),d0
	move.w	d0,oX(a0)
	addq.b	#1,oVar2A(a0)
	moveq	#0,d0
	move.b	oVar2C(a0),d0
	asr.b	#1,d0
	add.w	oVar3A(a0),d0
	move.w	d0,oY(a0)

ObjPlatform_SetXSpdAndDrop:
	move.l	(sp)+,d0
	move.l	oX(a0),d1
	sub.l	d0,d1
	asr.l	#8,d1
	move.w	d1,oXVel(a0)

ObjPlatform_DropWhenStoodOn:
	jsr	ObjPlatform_SolidObj(pc)
	beq.s	.Backup
	move.b	oVar2C(a0),d0
	cmpi.b	#8,d0
	bcc.s	.EndDropping
	addq.b	#1,oVar2C(a0)

.EndDropping:
	moveq	#1,d0
	rts

; -------------------------------------------------------------------------

.Backup:
	moveq	#0,d0
	move.b	oVar2C(a0),d0
	beq.s	.EndRising
	subq.b	#1,oVar2C(a0)

.EndRising:
	moveq	#0,d0
	rts
; End of function ObjPlatform_Subtype1X

; -------------------------------------------------------------------------

ObjPlatform_Subtype2X:
	move.l	oX(a0),-(sp)
	addq.b	#1,oVar2A(a0)
	jsr	ObjPlatform_DoOsc(pc)
	add.w	oVar3A(a0),d0
	move.w	d0,oY(a0)
	jsr	ObjPlatform_DoOsc(pc)
	add.w	oVar38(a0),d0
	move.w	d0,oX(a0)
	bra.w	ObjPlatform_SetXSpdAndDrop
; End of function ObjPlatform_Subtype2X

; -------------------------------------------------------------------------

ObjPlatform_Subtype3X:
	move.l	oX(a0),-(sp)
	addq.b	#1,oVar2A(a0)
	jsr	ObjPlatform_DoOsc(pc)
	add.w	oVar3A(a0),d0
	move.w	d0,oY(a0)
	jsr	ObjPlatform_DoOsc(pc)
	neg.w	d0
	add.w	oVar38(a0),d0
	move.w	d0,oX(a0)
	bra.w	ObjPlatform_SetXSpdAndDrop
; End of function ObjPlatform_Subtype3X

; -------------------------------------------------------------------------

ObjPlatform_Subtype4X:
	moveq	#0,d0
	move.b	oVar2C(a0),d0
	asr.b	#1,d0
	add.w	oVar3A(a0),d0
	move.w	d0,oY(a0)
	bra.w	ObjPlatform_DropWhenStoodOn
; End of function ObjPlatform_Subtype4X

; -------------------------------------------------------------------------

ObjPlatform_Subtype5X:
	move.b	oVar2B(a0),d0
	bne.s	.RunTimer
	jsr	ObjPlatform_Subtype4X(pc)
	bne.s	.InitTimer
	rts

; -------------------------------------------------------------------------

.InitTimer:
	move.b	#30,oVar2E(a0)
	addq.b	#2,oVar2B(a0)

.RunTimer:
	move.b	oVar2E(a0),d0
	beq.s	.Drop
	subq.b	#1,oVar2E(a0)
	bra.w	ObjPlatform_Subtype4X

; -------------------------------------------------------------------------

.Drop:
	jsr	ObjPlatform_SolidObj(pc)
	move.l	oY(a0),d1
	move.w	oYVel(a0),d0
	ext.l	d0
	asl.l	#8,d0
	add.l	d0,d1
	move.l	d1,oY(a0)
	move.w	oYVel(a0),d0
	cmpi.w	#$400,d0
	bcc.s	.ChkDel
	addi.w	#$40,oYVel(a0)

.ChkDel:
	move.w	cameraY.w,d0
	addi.w	#$100,d0
	cmp.w	oY(a0),d0
	bcc.s	.End
	lea	objPlayerSlot.w,a1
	jsr	ClearObjRide
	jmp	DeleteObject

; -------------------------------------------------------------------------

.End:
	rts
; End of function ObjPlatform_Subtype5X

; -------------------------------------------------------------------------

ObjPlatform_Subtype6X:
	move.b	oVar2B(a0),d0
	andi.w	#$FF,d0
	move.w	ObjPlatform_Subtype6X_Index(pc,d0.w),d0
	jmp	ObjPlatform_Subtype6X_Index(pc,d0.w)
; End of function ObjPlatform_Subtype6X

; -------------------------------------------------------------------------
ObjPlatform_Subtype6X_Index:
	dc.w	ObjPlatform_Subtype6X_Stationary1-ObjPlatform_Subtype6X_Index
	dc.w	ObjPlatform_Subtype6X_MoveDown-ObjPlatform_Subtype6X_Index
	dc.w	ObjPlatform_Subtype6X_Stationary2-ObjPlatform_Subtype6X_Index
; -------------------------------------------------------------------------

ObjPlatform_Subtype6X_Stationary1:
	jsr	ObjPlatform_Subtype4X(pc)
	bne.s	.StartMoving
	rts

; -------------------------------------------------------------------------

.StartMoving:
	addq.b	#2,oVar2B(a0)
; End of function ObjPlatform_Subtype6X_Stationary1

; -------------------------------------------------------------------------

ObjPlatform_Subtype6X_MoveDown:
	move.b	oVar2A(a0),d0
	cmpi.b	#$40,d0
	bcc.w	.StopMoving
	jsr	ObjPlatform_DoOsc(pc)
	neg.w	d0
	add.w	oVar3A(a0),d0
	move.w	d0,oY(a0)
	addq.b	#2,oVar2A(a0)
	jmp	ObjPlatform_SolidObj

; -------------------------------------------------------------------------

.StopMoving:
	move.w	oY(a0),oVar3A(a0)
	addq.b	#2,oVar2B(a0)
; End of function ObjPlatform_Subtype6X_MoveDown

; -------------------------------------------------------------------------

ObjPlatform_Subtype6X_Stationary2:
	bra.w	ObjPlatform_Subtype4X
; End of function ObjPlatform_Subtype6X_Stationary2

; -------------------------------------------------------------------------

ObjPlatform_Subtype7X:
	move.b	oVar2B(a0),d0
	andi.w	#$FF,d0
	move.w	ObjPlatform_Subtype7X_Index(pc,d0.w),d0
	jmp	ObjPlatform_Subtype7X_Index(pc,d0.w)
; End of function ObjPlatform_Subtype7X

; -------------------------------------------------------------------------
ObjPlatform_Subtype7X_Index:dc.w	ObjPlatform_Subtype7X_Stationary1-ObjPlatform_Subtype7X_Index
	dc.w	ObjPlatform_Subtype7X_Rising-ObjPlatform_Subtype7X_Index
	dc.w	ObjPlatform_Subtype7X_Stationary2-ObjPlatform_Subtype7X_Index
; -------------------------------------------------------------------------

ObjPlatform_Subtype7X_Stationary1:
	jsr	ObjPlatform_Subtype4X(pc)
	bne.s	.StartMoving
	rts

; -------------------------------------------------------------------------

.StartMoving:
	addq.b	#2,oVar2B(a0)
	move.b	#$3C,oVar2E(a0)
; End of function ObjPlatform_Subtype7X_Stationary1

; -------------------------------------------------------------------------

ObjPlatform_Subtype7X_Rising:
	move.b	oVar2E(a0),d0
	beq.s	.RiseToCeiling
	subq.b	#1,oVar2E(a0)
	bra.w	ObjPlatform_Subtype4X

; -------------------------------------------------------------------------

.RiseToCeiling:
	jsr	ObjMove
	subq.w	#8,oYVel(a0)
	jsr	ObjGetCeilDist
	tst.w	d1
	bmi.s	.StopMoving
	bra.w	ObjPlatform_DropWhenStoodOn

; -------------------------------------------------------------------------

.StopMoving:
	sub.w	d1,oY(a0)
	move.w	oY(a0),oVar3A(a0)
	addq.b	#2,oVar2B(a0)
; End of function ObjPlatform_Subtype7X_Rising

; -------------------------------------------------------------------------

ObjPlatform_Subtype7X_Stationary2:
	bra.w	ObjPlatform_Subtype4X
; End of function ObjPlatform_Subtype7X_Stationary2

; -------------------------------------------------------------------------

ObjPlatform_Subtype8X:
	move.b	oVar2B(a0),d0
	andi.w	#$FF,d0
	move.w	ObjPlatform_Subtype8X_Index(pc,d0.w),d0
	jmp	ObjPlatform_Subtype8X_Index(pc,d0.w)
; End of function ObjPlatform_Subtype8X

; -------------------------------------------------------------------------
ObjPlatform_Subtype8X_Index:dc.w	ObjPlatform_Subtype8X_Stationary1-ObjPlatform_Subtype8X_Index
	dc.w	ObjPlatform_Subtype8X_MoveX-ObjPlatform_Subtype8X_Index
	dc.w	ObjPlatform_Subtype8X_Stationary2-ObjPlatform_Subtype8X_Index
; -------------------------------------------------------------------------

ObjPlatform_Subtype8X_Stationary1:
	jsr	ObjPlatform_Subtype4X(pc)
	bne.s	.StartMoving
	rts

; -------------------------------------------------------------------------

.StartMoving:
	addq.b	#2,oVar2B(a0)
	move.b	#$3C,oVar2E(a0)
; End of function ObjPlatform_Subtype8X_Stationary1

; -------------------------------------------------------------------------

ObjPlatform_Subtype8X_MoveX:
	move.b	oVar2E(a0),d0
	beq.s	.DoMove
	subq.b	#1,oVar2E(a0)
	bra.w	ObjPlatform_Subtype4X

; -------------------------------------------------------------------------

.DoMove:
	move.b	oVar2A(a0),d0
	cmpi.b	#$40,d0
	bcc.w	.StopMoving
	move.l	oX(a0),-(sp)
	jsr	ObjPlatform_DoOsc(pc)
	add.w	oVar38(a0),d0
	move.w	d0,oX(a0)
	addq.b	#1,oVar2A(a0)
	moveq	#0,d0
	move.b	oVar2C(a0),d0
	asr.b	#1,d0
	add.w	oVar3A(a0),d0
	move.w	d0,oY(a0)
	bra.w	ObjPlatform_SetXSpdAndDrop

; -------------------------------------------------------------------------

.StopMoving:
	move.w	oX(a0),oVar38(a0)
	addq.b	#2,oVar2B(a0)
; End of function ObjPlatform_Subtype8X_MoveX

; -------------------------------------------------------------------------

ObjPlatform_Subtype8X_Stationary2:
	bra.w	ObjPlatform_Subtype4X
; End of function ObjPlatform_Subtype8X_Stationary2

; -------------------------------------------------------------------------

ObjPlatform_Subtype9X:
	move.b	oVar2B(a0),d0
	andi.w	#$FF,d0
	move.w	ObjPlatform_Subtype9X_Index(pc,d0.w),d0
	jmp	ObjPlatform_Subtype9X_Index(pc,d0.w)
; End of function ObjPlatform_Subtype9X

; -------------------------------------------------------------------------
ObjPlatform_Subtype9X_Index:dc.w	ObjPlatform_Subtype9X_Stationary1-ObjPlatform_Subtype9X_Index
	dc.w	ObjPlatform_Subtype9X_MoveX-ObjPlatform_Subtype9X_Index
	dc.w	ObjPlatform_Subtype9X_Stationary2-ObjPlatform_Subtype9X_Index
; -------------------------------------------------------------------------

ObjPlatform_Subtype9X_Stationary1:
	jsr	ObjPlatform_Subtype4X(pc)
	bne.s	.StartMoving
	rts

; -------------------------------------------------------------------------

.StartMoving:
	addq.b	#2,oVar2B(a0)
	move.b	#$3C,oVar2E(a0)
; End of function ObjPlatform_Subtype9X_Stationary1

; -------------------------------------------------------------------------

ObjPlatform_Subtype9X_MoveX:
	move.b	oVar2E(a0),d0
	beq.s	.DoMove
	subq.b	#1,oVar2E(a0)
	bra.w	ObjPlatform_Subtype4X

; -------------------------------------------------------------------------

.DoMove:
	move.b	oVar2A(a0),d0
	cmpi.b	#$40,d0
	bcc.s	.StopMoving
	move.l	oX(a0),-(sp)
	jsr	ObjPlatform_DoOsc(pc)
	neg.w	d0
	add.w	oVar38(a0),d0
	move.w	d0,oX(a0)
	addq.b	#1,oVar2A(a0)
	moveq	#0,d0
	move.b	oVar2C(a0),d0
	asr.b	#1,d0
	add.w	oVar3A(a0),d0
	move.w	d0,oY(a0)
	bra.w	ObjPlatform_SetXSpdAndDrop

; -------------------------------------------------------------------------

.StopMoving:
	move.w	oX(a0),oVar38(a0)
	addq.b	#2,oVar2B(a0)
; End of function ObjPlatform_Subtype9X_MoveX

; -------------------------------------------------------------------------

ObjPlatform_Subtype9X_Stationary2:
	bra.w	ObjPlatform_Subtype4X
; End of function ObjPlatform_Subtype9X_Stationary2

; -------------------------------------------------------------------------

ObjPlatform_DoOsc:
	moveq	#0,d0
	move.b	oVar2A(a0),d0
	jsr	CalcSine
	moveq	#0,d2
	move.b	oVar2D(a0),d2
	muls.w	d2,d0
	asr.w	#4,d0
	rts
; End of function ObjPlatform_DoOsc

; -------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR ObjPlatform_Init

ObjPlatform_Destroy:
	moveq	#0,d0
	move.b	oRespawn(a0),d0
	beq.s	.Delete
	lea	lvlObjRespawns,a1
	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,d0
	moveq	#0,d1
	move.b	timeZone,d1
	add.w	d1,d0
	bclr	#7,2(a1,d0.w)

.Delete:
	jmp	DeleteObject
; END OF FUNCTION CHUNK	FOR ObjPlatform_Init

; -------------------------------------------------------------------------
MapSpr_Platform:
	include	"Level/Palmtree Panic/Objects/Platform/Data/Mappings (Platform 1).asm"
	even
MapSpr_Platform2:
	include	"Level/Palmtree Panic/Objects/Platform/Data/Mappings (Platform 2).asm"
	even
	
; -------------------------------------------------------------------------
