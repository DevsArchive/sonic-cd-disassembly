; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Splash object (special stage)
; -------------------------------------------------------------------------

ObjSplash:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	add.w	d0,d0
	move.w	ObjSplash_Index(pc,d0.w),d0
	jsr	ObjSplash_Index(pc,d0.w)
	bsr.w	DrawObject
	tst.b	timeStopped
	beq.s	.End
	bset	#0,oFlags(a0)

.End:
	rts

; -------------------------------------------------------------------------

ObjSplash_Index:
	dc.w	ObjSplash_Init-ObjSplash_Index
	dc.w	ObjSplash_Large-ObjSplash_Index
	dc.w	ObjSplash_Small-ObjSplash_Index

; -------------------------------------------------------------------------

ObjSplash_Init:
	move.w	#$8582,oTile(a0)
	move.l	#MapSpr_Splash,oMap(a0)
	move.w	#$100,oSprX(a0)
	move.w	#$158,oSprY(a0)
	moveq	#0,d0
	bsr.w	SetObjAnim
	move.w	#14,oTimer(a0)
	addq.b	#1,oRoutine(a0)
	move.b	#$A2,d0
	bsr.w	PlayFMSound
	btst	#1,specStageFlags.w
	bne.s	ObjSplash_Large
	move.b	#10,timerSpeedUp

; -------------------------------------------------------------------------

ObjSplash_Large:

	subq.w	#1,oTimer(a0)
	bne.s	.End
	cmpi.b	#3,(sonicObject+oPlayerStampC).l
	bne.s	ObjSplash_Delete
	moveq	#1,d0
	bsr.w	SetObjAnim
	move.b	#2,oRoutine(a0)

.End:
	rts

; -------------------------------------------------------------------------

ObjSplash_Small:
	cmpi.b	#3,(sonicObject+oPlayerStampC).l
	bne.s	ObjSplash_Delete
	tst.b	oAnimFrame(a0)
	bne.s	.End
	move.b	#2,timerSpeedUp

.End:
	rts

; -------------------------------------------------------------------------

ObjSplash_Delete:
	bset	#0,oFlags(a0)
	rts

; -------------------------------------------------------------------------

DeleteSplash:
	tst.b	(splashObject+oID).l
	beq.s	.End
	bset	#0,(splashObject+oFlags).l

.End:
	rts

; -------------------------------------------------------------------------
