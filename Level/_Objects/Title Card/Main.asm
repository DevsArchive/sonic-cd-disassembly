; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Title card object
; -------------------------------------------------------------------------

ObjTitleCard:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjTitleCard_Index(pc,d0.w),d0
	jmp	ObjTitleCard_Index(pc,d0.w)
; End of function ObjTitleCard

; -------------------------------------------------------------------------
ObjTitleCard_Index:dc.w	ObjTitleCard_Init-ObjTitleCard_Index
	dc.w	ObjTitleCard_SlideInVert-ObjTitleCard_Index
	dc.w	ObjTitleCard_SlideInHoriz-ObjTitleCard_Index
	dc.w	ObjTitleCard_SlideOutVert-ObjTitleCard_Index
	dc.w	ObjTitleCard_SlideOutHoriz-ObjTitleCard_Index
	dc.w	ObjTitleCard_WaitPLC-ObjTitleCard_Index
; -------------------------------------------------------------------------

ObjTitleCard_Init:
	move.b	#2,oRoutine(a0)
	move.w	#$118,oX(a0)
	move.w	#$30,oYScr(a0)
	move.w	#$30,oVar30(a0)
	move.w	#$F0,oVar2E(a0)
	move.b	#$5A,oAnimTime(a0)
	move.w	#$8360,oTile(a0)
	move.l	#MapSpr_TitleCard,oMap(a0)
	move.b	#4,oPriority(a0)
	moveq	#0,d1
	moveq	#7,d6
	lea	ObjTitleCard_Data,a2

.Loop:
	jsr	FindObjSlot
	move.b	#$3C,oID(a1)
	move.b	#4,oRoutine(a1)
	move.w	#$8360,oTile(a1)
	move.l	#MapSpr_TitleCard,oMap(a1)
	move.w	d1,d2
	lsl.w	#3,d2
	move.w	(a2,d2.w),oYScr(a1)
	move.w	2(a2,d2.w),oX(a1)
	move.w	2(a2,d2.w),oVar2C(a1)
	move.w	4(a2,d2.w),oVar2A(a1)
	move.b	6(a2,d2.w),oMapFrame(a1)
	cmpi.b	#5,d1
	bne.s	.NotActNum
	move.b	act,d3
	add.b	d3,oMapFrame(a1)

.NotActNum:
	move.b	7(a2,d2.w),oAnimTime(a1)
	addq.b	#1,d1
	dbf	d6,.Loop
	rts
; End of function ObjTitleCard_Init

; -------------------------------------------------------------------------

ObjTitleCard_SlideInVert:
	moveq	#8,d0
	move.w	oVar2E(a0),d1
	cmp.w	oYScr(a0),d1
	beq.s	.DidSlide
	bge.s	.DoYSlide
	neg.w	d0

.DoYSlide:
	add.w	d0,oYScr(a0)
	jmp	DrawObject

; -------------------------------------------------------------------------

.DidSlide:
	addq.b	#4,oRoutine(a0)
	jmp	DrawObject
; End of function ObjTitleCard_SlideInVert

; -------------------------------------------------------------------------

ObjTitleCard_SlideInHoriz:
	moveq	#8,d0
	move.w	oVar2A(a0),d1
	cmp.w	oX(a0),d1
	beq.s	.DidSlide
	bge.s	.DoXSlide
	neg.w	d0

.DoXSlide:
	add.w	d0,oX(a0)
	jmp	DrawObject

; -------------------------------------------------------------------------

.DidSlide:
	addq.b	#4,oRoutine(a0)
	jmp	DrawObject
; End of function ObjTitleCard_SlideInHoriz

; -------------------------------------------------------------------------

ObjTitleCard_SlideOutVert:
	tst.b	oAnimTime(a0)
	beq.s	.SlideOut
	subq.b	#1,oAnimTime(a0)
	jmp	DrawObject

; -------------------------------------------------------------------------

.SlideOut:
	moveq	#$10,d0
	move.w	oVar30(a0),d1
	cmp.w	oYScr(a0),d1
	beq.s	.DidSlide
	bge.s	.DoYSlide
	neg.w	d0

.DoYSlide:
	add.w	d0,oYScr(a0)
	jmp	DrawObject

; -------------------------------------------------------------------------

.DidSlide:
	addq.b	#4,oRoutine(a0)
	move.b	#1,scrollLock.w
	moveq	#2,d0
	jmp	LoadPLC
; End of function ObjTitleCard_SlideOutVert

; -------------------------------------------------------------------------

ObjTitleCard_SlideOutHoriz:
	tst.b	oAnimTime(a0)
	beq.s	.SlideOut
	subq.b	#1,oAnimTime(a0)
	jmp	DrawObject

; -------------------------------------------------------------------------

.SlideOut:
	moveq	#$10,d0
	move.w	oVar2C(a0),d1
	cmp.w	oX(a0),d1
	beq.s	.DidSlide
	bge.s	.DoXSlide
	neg.w	d0

.DoXSlide:
	add.w	d0,oX(a0)
	jmp	DrawObject

; -------------------------------------------------------------------------

.DidSlide:
	jmp	DeleteObject
; End of function ObjTitleCard_SlideOutHoriz

; -------------------------------------------------------------------------

ObjTitleCard_WaitPLC:
	tst.l	plcBuffer.w
	bne.s	.End
	clr.b	scrollLock.w
	clr.b	ctrlLocked.w
	jmp	DeleteObject

; -------------------------------------------------------------------------

.End:
	rts
	
; -------------------------------------------------------------------------
