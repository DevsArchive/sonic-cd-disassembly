; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Debug mode
; -------------------------------------------------------------------------

UpdateDebugMode:
	move.b	p1CtrlHold.w,d0
	andi.b	#$F,d0
	bne.s	.Accel
	move.l	#$4000,debugSpeed
	bra.s	.GotSpeed

; -------------------------------------------------------------------------

.Accel:
	addi.l	#$2000,debugSpeed
	cmpi.l	#$80000,debugSpeed
	bls.s	.GotSpeed
	move.l	#$80000,debugSpeed

.GotSpeed:
	move.l	debugSpeed,d0
	btst	#0,p1CtrlHold.w
	beq.s	.ChkDown
	sub.l	d0,oY(a0)

.ChkDown:
	btst	#1,p1CtrlHold.w
	beq.s	.ChkLeft
	add.l	d0,oY(a0)

.ChkLeft:
	btst	#2,p1CtrlHold.w
	beq.s	.ChkRight
	sub.l	d0,oX(a0)

.ChkRight:
	btst	#3,p1CtrlHold.w
	beq.s	.SetPos
	add.l	d0,oX(a0)

.SetPos:
	move.w	oY(a0),d2
	move.b	oYRadius(a0),d0
	ext.w	d0
	add.w	d0,d2
	move.w	oX(a0),d3
	jsr	GetLevelBlock
	move.w	(a1),debugBlock
	lea	DebugItemIndex,a2
	btst	#6,p1CtrlTap.w
	beq.s	.NoInc
	moveq	#0,d1
	move.b	debugObject,d1
	addq.b	#1,d1
	cmp.b	(a2),d1
	bcs.s	.NoWrap
	move.b	#0,d1

.NoWrap:
	move.b	d1,debugObject

.NoInc:
	btst	#7,p1CtrlTap.w
	beq.s	.NoDec
	moveq	#0,d1
	move.b	debugObject,d1
	subq.b	#1,d1
	cmpi.b	#$FF,d1
	bne.s	.NoWrap2
	add.b	(a2),d1

.NoWrap2:
	move.b	d1,debugObject

.NoDec:
	moveq	#0,d1
	move.b	debugObject,d1
	mulu.w	#$C,d1
	move.l	4(a2,d1.w),oMap(a0)
	move.w	8(a2,d1.w),oTile(a0)
	move.b	3(a2,d1.w),oPriority(a0)
	move.b	$D(a2,d1.w),oMapFrame(a0)
	move.b	$C(a2,d1.w),debugSubtype2
	move.b	$B(a2,d1.w),d0
	ori.b	#4,d0
	move.b	d0,oSprFlags(a0)
	move.b	#0,oAnim(a0)
	btst	#5,p1CtrlTap.w
	beq.s	.NoPlace
	bsr.w	FindObjSlot
	bne.s	.NoPlace
	moveq	#0,d1
	move.b	debugObject,d1
	mulu.w	#$C,d1
	move.b	2(a2,d1.w),oID(a1)
	move.b	$A(a2,d1.w),oSubtype(a1)
	move.b	$C(a2,d1.w),oSubtype2(a1)
	move.b	$D(a2,d1.w),oMapFrame(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	move.b	oSprFlags(a0),d0
	andi.b	#3,d0
	move.b	d0,oSprFlags(a1)
	move.b	d0,oFlags(a1)

.NoPlace:
	btst	#4,p1CtrlTap.w
	beq.s	.NoRevert
	move.b	#0,debugMode
	move.l	#MapSpr_Sonic,oMap(a0)
	move.w	#$780,oTile(a0)
	move.b	#2,oPriority(a0)
	move.b	#0,oMapFrame(a0)
	move.b	#4,oSprFlags(a0)

.NoRevert:
	jmp	DrawObject

; -------------------------------------------------------------------------

debugSpeed:
	dc.l	$4000

; -------------------------------------------------------------------------
