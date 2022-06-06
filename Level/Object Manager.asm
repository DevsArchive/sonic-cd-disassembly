; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Object manager
; -------------------------------------------------------------------------

ResetRespawnTable:
	lea	lvlObjRespawns,a2
	move.w	#$101,(a2)+
	move.w	#$BE,d0

.Clear:
	clr.l	(a2)+
	dbf	d0,.Clear
	rts
; End of function ResetRespawnTable

; -------------------------------------------------------------------------

ObjectManager:
	moveq	#0,d0
	move.b	objManagerRout.w,d0
	move.w	ObjMan_Index(pc,d0.w),d0
	jmp	ObjMan_Index(pc,d0.w)
; End of function ObjectManager

; -------------------------------------------------------------------------
ObjMan_Index:
	dc.w	ObjMan_Init-ObjMan_Index
	dc.w	ObjMan_Main-ObjMan_Index
; -------------------------------------------------------------------------

ObjMan_Init:
	addq.b	#2,objManagerRout.w
	lea	ObjectLayouts,a0
	movea.l	a0,a1
	adda.w	(a0),a0
	move.l	a0,objLoadAddrR.w
	move.l	a0,objLoadAddrL.w
	adda.w	2(a1),a1
	move.l	a1,objLoadAddr2R.w
	move.l	a1,objLoadAddr2L.w
	lea	lvlObjRespawns,a2
	move.w	#$101,(a2)
	moveq	#0,d2
	move.w	cameraX.w,d6
	subi.w	#$80,d6
	bcc.s	.SkipLCap
	moveq	#0,d6

.SkipLCap:
	andi.w	#$FF80,d6
	movea.l	objLoadAddrR.w,a0

.ScanRight:
	cmp.w	(a0),d6
	bls.s	.FoundRightmost
	tst.b	4(a0)
	bpl.s	.NextObj
	move.b	(a2),d2
	addq.b	#1,(a2)

.NextObj:
	addq.w	#8,a0
	bra.s	.ScanRight

; -------------------------------------------------------------------------

.FoundRightmost:
	move.l	a0,objLoadAddrR.w
	movea.l	objLoadAddrL.w,a0
	subi.w	#$80,d6
	bcs.s	.FoundRightmost2

.ScanRight2:
	cmp.w	(a0),d6
	bls.s	.FoundRightmost2
	tst.b	4(a0)
	bpl.s	.NextObj2
	addq.b	#1,1(a2)

.NextObj2:
	addq.w	#8,a0
	bra.s	.ScanRight2

; -------------------------------------------------------------------------

.FoundRightmost2:
	move.l	a0,objLoadAddrL.w
	move.w	#-1,objPrevCamX.w
; End of function ObjMan_Init

; -------------------------------------------------------------------------

ObjMan_Main:
	lea	lvlObjRespawns,a2
	moveq	#0,d2
	move.w	cameraX.w,d6
	andi.w	#$FF80,d6
	cmp.w	objPrevCamX.w,d6
	beq.w	ObjMan_SameXRange
	bge.s	ObjMan_Forward
	nop
	nop
	nop
	nop
	move.w	d6,objPrevCamX.w
	movea.l	objLoadAddrL.w,a0
	subi.w	#$80,d6
	bcs.s	.ScanLeft

.Loop:
	cmp.w -8(a0),d6
	bge.s	.ScanLeft
	subq.w	#8,a0
	tst.b	4(a0)
	bpl.s	.NoRespawn
	subq.b	#1,1(a2)
	move.b	1(a2),d2

.NoRespawn:
	bsr.w	LevelLoadObj
	bne.s	.ScanDone
	subq.w	#8,a0
	bra.s	.Loop

; -------------------------------------------------------------------------

.ScanDone:
	tst.b	4(a0)
	bpl.s	.NoRespawn2
	addq.b	#1,1(a2)
	bclr	#7,2(a2,d3.w)

.NoRespawn2:
	addq.w	#8,a0

.ScanLeft:
	move.l	a0,objLoadAddrL.w
	movea.l	objLoadAddrR.w,a0
	addi.w	#$300,d6

.Loop2:
	cmp.w	-8(a0),d6
	bgt.s	.End
	tst.b	-4(a0)
	bpl.s	.NextObj
	subq.b	#1,(a2)

.NextObj:
	subq.w	#8,a0
	bra.s	.Loop2

; -------------------------------------------------------------------------

.End:
	move.l	a0,objLoadAddrR.w
	rts

; -------------------------------------------------------------------------

ObjMan_Forward:
	nop
	nop
	nop
	nop
	move.w	d6,objPrevCamX.w
	movea.l	objLoadAddrR.w,a0
	addi.w	#$280,d6

.Loop3:
	cmp.w	(a0),d6
	bls.s	.ScanDone2
	tst.b	4(a0)
	bpl.s	.NoRespawn3
	move.b	(a2),d2
	addq.b	#1,(a2)

.NoRespawn3:
	bsr.w	LevelLoadObj
	beq.s	.Loop3
	tst.b	4(a0)
	bpl.s	.ScanDone2
	subq.b	#1,(a2)
	bclr	#7,2(a2,d3.w)

.ScanDone2:
	move.l	a0,objLoadAddrR.w
	movea.l	objLoadAddrL.w,a0
	subi.w	#$300,d6
	bcs.s	.End2

.ScanRight:
	cmp.w	(a0),d6
	bls.s	.End2
	tst.b	4(a0)
	bpl.s	.NextObj2
	addq.b	#1,1(a2)

.NextObj2:
	addq.w	#8,a0
	bra.s	.ScanRight

; -------------------------------------------------------------------------

.End2:
	move.l	a0,objLoadAddrL.w

ObjMan_SameXRange:
	rts
; End of function ObjMan_Main

; -------------------------------------------------------------------------

CheckObjOccurs:
	moveq	#0,d0
	move.b	timeZone,d0
	bclr	#7,d0
	move.w	d2,d3
	add.w	d3,d3
	add.w	d2,d3
	add.w	d0,d3
	move.b	6(a0),d1
	rol.b	#3,d1
	andi.b	#7,d1
	btst	d0,d1
	rts
; End of function CheckObjOccurs

; -------------------------------------------------------------------------

LevelLoadObj:
	bsr.s	CheckObjOccurs
	beq.s	.SkipObj
	tst.b	4(a0)
	bpl.s	.Load
	bset	#7,2(a2,d3.w)
	beq.s	.Load

.SkipObj:
	addq.w	#8,a0
	moveq	#0,d0
	rts

; -------------------------------------------------------------------------

.Load:
	bsr.w	FindObjSlot
	bne.s	.End
	move.w	(a0)+,oX(a1)
	move.w	(a0)+,d0
	move.w	d0,d1
	andi.w	#$FFF,d0
	move.w	d0,oY(a1)
	rol.w	#2,d1
	andi.b	#3,d1
	move.b	d1,oRender(a1)
	move.b	d1,oStatus(a1)
	move.b	(a0)+,d0
	bpl.s	.NoRespawn
	andi.b	#$7F,d0
	move.b	d2,oRespawn(a1)

.NoRespawn:
	move.b	d0,oID(a1)
	cmpi.b	#$31,d0
	bne.s	.SetFields
	nop
	nop
	nop
	nop

.SetFields:
	move.b	(a0)+,oSubtype(a1)
	move.b	(a0)+,d0
	move.b	(a0)+,oSubtype2(a1)
	moveq	#0,d0

.End:
	rts
; End of function LevelLoadObj

; -------------------------------------------------------------------------

FindObjSlot:
	lea	dynObjects.w,a1
	move.w	#$5F,d0

.Find:
	tst.b	(a1)
	beq.s	.End
	lea	oSize(a1),a1
	dbf	d0,.Find

.End:
	rts
; End of function FindObjSlot

; -------------------------------------------------------------------------

FindNextObjSlot:
	movea.l	a0,a1
	lea	oSize(a1),a1
	move.w	#objectsEnd,d0
	sub.w	a0,d0
	lsr.w	#6,d0
	subq.w	#2,d0
	bcs.s	.End

.Find:
	tst.b	(a1)
	beq.s	.End
	lea	oSize(a1),a1
	dbf	d0,.Find

.End:
	rts
; End of function FindNextObjSlot

; -------------------------------------------------------------------------

CheckObjDespawnTime:
	move.w	8(a0),d0

CheckObjDespawn2Time:
	tst.b	oRender(a0)
	bmi.s	CheckObjDespawn_OnScreen
	andi.w	#$FF80,d0
	move.w	cameraX.w,d1
	subi.w	#$80,d1
	andi.w	#$FF80,d1
	sub.w	d1,d0
	cmpi.w	#$280,d0
	bls.s	CheckObjDespawn_OnScreen

CheckObjDespawnTime_Despawn:
	moveq	#0,d0
	move.b	oRespawn(a0),d0
	beq.s	.DelObj
	lea	lvlObjRespawns,a1
	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,d0
	moveq	#0,d1
	move.b	timeZone,d1
	bclr	#7,d1
	beq.s	.SetRespawn
	move.b	timeWarpDir.w,d2
	ext.w	d2
	neg.w	d2
	add.w	d2,d1
	bpl.s	.NoCap
	moveq	#0,d1
	bra.s	.SetRespawn

; -------------------------------------------------------------------------

.NoCap:
	cmpi.w	#3,d1
	bcs.s	.SetRespawn
	moveq	#2,d1

.SetRespawn:
	add.w	d1,d0
	bclr	#7,2(a1,d0.w)

.DelObj:
	jsr	DeleteObject
	moveq	#1,d0
	rts

; -------------------------------------------------------------------------

CheckObjDespawn_OnScreen:
	btst	#7,timeZone
	bne.s	CheckObjDespawnTime_Despawn
	moveq	#0,d0
	rts

; -------------------------------------------------------------------------
