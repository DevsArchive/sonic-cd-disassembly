; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Amy Rose object
; -------------------------------------------------------------------------

ObjAmyRose:
	tst.b	timeAttackMode
	bne.s	.ResetPal
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjAmyRose_Index(pc,d0.w),d0
	jsr	ObjAmyRose_Index(pc,d0.w)
	bsr.w	ObjAmyRose_MakeHearts
	jsr	DrawObject
	jsr	CheckObjDespawn
	cmpi.b	#$2F,oID(a0)
	beq.s	.End

.ResetPal:
	lea	Pal_LevelEnd,a3
	bsr.w	ObjAmyRose_ResetPal

.End:
	rts
; End of function ObjAmyRose

; -------------------------------------------------------------------------
ObjAmyRose_Index:dc.w	ObjAmyRose_Init-ObjAmyRose_Index
	dc.w	ObjAmyRose_Main-ObjAmyRose_Index
	dc.w	ObjAmyRose_HoldSonic-ObjAmyRose_Index
	dc.w	ObjAmyRose_FollowSonic-ObjAmyRose_Index
	dc.w	ObjAmyRose_WaitLand-ObjAmyRose_Index
; -------------------------------------------------------------------------

ObjAmyRose_Init:
	ori.b	#4,oSprFlags(a0)
	move.w	#$2370,oTile(a0)
	move.b	#1,oPriority(a0)
	move.l	#MapSpr_AmyRose,oMap(a0)
	move.b	#$C,oWidth(a0)
	move.b	#$10,oYRadius(a0)
	move.w	oX(a0),oVar36(a0)
	bsr.w	ObjAmyRose_LoadPal

.PlaceLoop:
	jsr	ObjGetFloorDist
	tst.w	d1
	beq.s	.FoundFloor
	add.w	d1,oY(a0)
	bra.w	.PlaceLoop

; -------------------------------------------------------------------------

.FoundFloor:
	lea	objPlayerSlot.w,a1
	bsr.w	ObjAmyRose_SetFacing
	move.w	oX(a1),d0
	sub.w	oX(a0),d0
	bcc.s	.ChkRange
	neg.w	d0

.ChkRange:
	cmpi.w	#$70,d0
	bcc.s	.Animate
	addq.b	#2,oRoutine(a0)

.Animate:
	move.b	#5,oAnim(a0)
	lea	Ani_AmyRose,a1
	bra.w	AnimateObjSimple
; End of function ObjAmyRose_Init

; -------------------------------------------------------------------------

ObjAmyRose_Main:
	lea	objPlayerSlot.w,a1
	bsr.w	ObjAmyRose_SetFacing
	btst	#6,oVar3E(a0)
	bne.w	.WallBump
	btst	#2,oVar3E(a0)
	bne.w	.GetDX2
	tst.w	oXVel(a1)
	bne.s	.GetAccel
	move.w	oX(a1),d0
	sub.w	oX(a0),d0
	bcc.s	.GetDX
	neg.w	d0

.GetDX:
	cmpi.w	#$A,d0
	bcc.s	.GetAccel

.InRange:
	bset	#2,oVar3E(a0)
	clr.w	oXVel(a0)
	bra.w	.ChkFloor2

; -------------------------------------------------------------------------

.GetDX2:
	move.w	oX(a1),d0
	sub.w	oX(a0),d0
	bcc.s	.AbsDX
	neg.w	d0

.AbsDX:
	cmpi.w	#$20,d0
	bcs.s	.InRange
	bclr	#2,oVar3E(a0)

.GetAccel:
	move.w	#-$10,d0
	btst	#0,oFlags(a0)
	bne.s	.NoFlip
	neg.w	d0

.NoFlip:
	add.w	oXVel(a0),d0
	move.w	d0,d1
	move.w	#$200,d2
	tst.w	d1
	bpl.s	.ChkCap
	neg.w	d1
	neg.w	d2

.ChkCap:
	cmpi.w	#$200,d1
	bcs.s	.SetVX
	move.w	d2,d0

.SetVX:
	move.w	d0,oXVel(a0)
	tst.w	oXVel(a0)
	bpl.s	.NoFlip2
	move.w	oVar36(a0),d0
	subi.w	#$130,d0
	cmp.w	oX(a0),d0
	bcs.s	.ChkFloor
	bra.w	.WallBump

; -------------------------------------------------------------------------

.NoFlip2:
	move.w	oVar36(a0),d0
	addi.w	#$90,d0
	cmp.w	oX(a0),d0
	bcc.s	.ChkFloor
	bra.w	.WallBump

; -------------------------------------------------------------------------

.ChkFloor:
	jsr	ObjGetFloorDist
	cmpi.w	#7,d1
	bpl.s	.WallBump
	cmpi.w	#-7,d1
	bmi.s	.WallBump
	add.w	d1,oY(a0)
	bsr.w	ObjectMoveX
	bsr.w	ObjAmyRose_CheckGrabSonic
	move.b	#2,oAnim(a0)
	lea	Ani_AmyRose,a1
	bra.w	AnimateObjSimple

; -------------------------------------------------------------------------

.WallBump:
	clr.w	oXVel(a0)
	btst	#7,oVar3E(a0)
	bne.s	.ChkIfJump

.ChkFloor2:
	jsr	ObjGetFloorDist
	add.w	d1,oY(a0)
	move.b	#1,oAnim(a0)
	lea	Ani_AmyRose,a1
	bra.w	AnimateObjSimple

; -------------------------------------------------------------------------

.ChkIfJump:
	btst	#6,oVar3E(a0)
	bne.s	.MoveFall
	cmpi.b	#3,oVar3F(a0)
	bcs.s	.Jump
	addq.b	#4,oVar3A(a0)
	bcc.s	.Animate
	clr.b	oVar3F(a0)

.Animate:
	move.b	#4,oAnim(a0)
	lea	Ani_AmyRose,a1
	bra.w	AnimateObjSimple

; -------------------------------------------------------------------------

.Jump:
	move.w	#-$300,oYVel(a0)
	bset	#6,oVar3E(a0)

.MoveFall:
	bsr.w	ObjectMoveY
	addi.w	#$40,oYVel(a0)
	move.b	#6,oMapFrame(a0)
	tst.w	oYVel(a0)
	bmi.s	.GoingUp
	move.b	#4,oMapFrame(a0)

.GoingUp:
	jsr	ObjGetFloorDist
	tst.w	d1
	bpl.s	.End
	clr.w	oYVel(a0)
	bclr	#6,oVar3E(a0)
	addq.b	#1,oVar3F(a0)

.End:
	rts
; End of function ObjAmyRose_Main

; -------------------------------------------------------------------------

ObjAmyRose_HoldSonic:
	lea	objPlayerSlot.w,a1
	bset	#0,oPlayerCtrl(a1)
	move.b	#5,oAnim(a1)
	bsr.w	ObjAmyRose_SlowSonic
	bsr.w	ObjAmyRose_SetFacing
	moveq	#$C,d0
	btst	#0,oFlags(a1)
	bne.s	.NoFlip
	neg.w	d0

.NoFlip:
	add.w	oX(a1),d0
	move.w	d0,oX(a0)
	move.w	oY(a1),oY(a0)
	move.w	p1CtrlData.w,playerCtrl.w
	bsr.w	Player_Jump
	btst	#0,oPlayerCtrl(a1)
	beq.s	.PlayerJumped
	cmpi.l	#(9<<16)|(50<<8)|0,time
	bcc.s	.ForceJump
	move.b	#3,oAnim(a0)
	lea	Ani_AmyRose,a1
	bra.w	AnimateObjSimple

; -------------------------------------------------------------------------

.PlayerJumped:
	bclr	#0,oVar3E(a0)
	move.b	#6,oRoutine(a0)
	rts

; -------------------------------------------------------------------------

.ForceJump:
	bsr.w	Player_Jump2
	bclr	#0,oVar3E(a0)
	move.b	#2,oRoutine(a0)
	rts
; End of function ObjAmyRose_HoldSonic

; -------------------------------------------------------------------------

ObjAmyRose_FollowSonic:
	move.b	#6,oMapFrame(a0)
	move.w	#$80,d0
	btst	#0,oFlags(a0)
	bne.s	.NoFlip
	neg.w	d0

.NoFlip:
	move.w	d0,oXVel(a0)
	move.w	oX(a0),d0
	sub.w	oVar36(a0),d0
	bcc.s	.ChkRange
	neg.w	d0

.ChkRange:
	cmpi.w	#$80,d0
	bcs.s	.Jump
	clr.w	oXVel(a0)

.Jump:
	move.w	#-$300,oYVel(a0)
	addq.b	#2,oRoutine(a0)
; End of function ObjAmyRose_FollowSonic

; -------------------------------------------------------------------------

ObjAmyRose_WaitLand:
	bsr.w	ObjectMove
	addi.w	#$40,oYVel(a0)
	tst.w	oYVel(a0)
	bmi.s	.ChkFloor
	move.b	#7,oMapFrame(a0)

.ChkFloor:
	jsr	ObjGetFloorDist
	tst.w	d1
	bpl.s	.End
	clr.w	oXVel(a0)
	clr.w	oYVel(a0)
	addi.b	#$10,oVar3A(a0)
	bcc.s	.End
	move.b	#2,oRoutine(a0)

.End:
	rts
; End of function ObjAmyRose_WaitLand

; -------------------------------------------------------------------------

ObjAmyRose_SlowSonic:
	tst.w	oXVel(a0)
	beq.s	.End
	movem.l	a0-a1,-(sp)
	exg	a0,a1
	bsr.w	ObjectMoveX
	jsr	ObjGetFloorDist
	add.w	d1,oY(a0)
	movem.l	(sp)+,a0-a1
	tst.w	oXVel(a1)
	bmi.s	.Decel
	subi.w	#$40,oXVel(a1)
	bpl.s	.End
	bra.s	.StopSonic

; -------------------------------------------------------------------------

.Decel:
	addi.w	#$40,oXVel(a1)
	bmi.s	.End

.StopSonic:
	clr.w	oXVel(a1)

.End:
	rts
; End of function ObjAmyRose_SlowSonic

; -------------------------------------------------------------------------

Player_Jump:
	move.b	playerCtrlTap.w,d0
	andi.b	#$70,d0
	beq.w	Player_Jump_Done
; End of function Player_Jump

; -------------------------------------------------------------------------

Player_Jump2:
	clr.b	oPlayerCtrl(a1)
	move.w	#$680,d2
	moveq	#0,d0
	move.b	oAngle(a1),d0
	subi.b	#$40,d0
	jsr	CalcSine
	muls.w	d2,d1
	asr.l	#8,d1
	add.w	d1,oXVel(a1)
	muls.w	d2,d0
	asr.l	#8,d0
	add.w	d0,oYVel(a1)
	bset	#1,oFlags(a1)
	bclr	#5,oFlags(a1)
	move.b	#1,oPlayerJump(a1)
	clr.b	oPlayerStick(a1)
	move.b	#$13,oYRadius(a1)
	move.b	#9,oXRadius(a1)
	btst	#2,oFlags(a1)
	bne.s	Player_Jump_RollJmp
	move.b	#$E,oYRadius(a1)
	move.b	#7,oXRadius(a1)
	addq.w	#5,oY(a1)
	bset	#2,oFlags(a1)
	move.b	#2,oAnim(a1)

Player_Jump_Done:
	rts

; -------------------------------------------------------------------------

Player_Jump_RollJmp:
	bset	#4,oFlags(a1)
	rts
; End of function Player_Jump2

; -------------------------------------------------------------------------

ObjAmyRose_CheckGrabSonic:
	tst.w	oXVel(a0)
	bpl.s	.GoingRight
	move.w	oVar36(a0),d0
	subi.w	#$130,d0
	cmp.w	oX(a0),d0
	bcs.s	.ChkRange
	bra.w	.End

; -------------------------------------------------------------------------

.GoingRight:
	move.w	oVar36(a0),d0
	addi.w	#$90,d0
	cmp.w	oX(a0),d0
	bcc.s	.ChkRange
	bra.w	.End

; -------------------------------------------------------------------------

.ChkRange:
	cmpi.l	#(9<<16)|(50<<8)|0,time
	bcc.w	.End
	lea	objPlayerSlot.w,a1
	tst.b	debugMode
	bne.w	.End
	btst	#0,oFlags(a1)
	bne.s	.GetDX
	move.w	oX(a1),d0
	sub.w	oX(a0),d0
	bra.s	.GotDX

; -------------------------------------------------------------------------

.GetDX:
	move.w	oX(a0),d0
	sub.w	oX(a1),d0

.GotDX:
	bcs.w	.End
	cmpi.w	#$C,d0
	bcs.w	.End
	cmpi.w	#$18,d0
	bcc.s	.End
	moveq	#8,d1
	move.w	oY(a1),d0
	sub.w	oY(a0),d0
	add.w	d1,d0
	bmi.s	.End
	move.w	d1,d2
	add.w	d2,d2
	cmp.w	d2,d0
	bcc.s	.End
	move.w	oXVel(a1),d0
	bpl.s	.AbsVX
	neg.w	d0

.AbsVX:
	btst	#1,oFlags(a1)
	bne.s	.NoGrab
	btst	#2,oFlags(a1)
	bne.s	.NoGrab
	tst.b	oPlayerHurt(a1)
	bne.s	.NoGrab
	cmpi.w	#$680,d0
	bcc.s	.NoGrab
	tst.b	shield
	bne.s	.NoGrab
	tst.b	timeWarp
	bne.s	.NoGrab
	tst.b	invincible
	bne.s	.NoGrab
	bclr	#2,oFlags(a1)
	ori.b	#$81,oVar3E(a0)
	clr.w	oYVel(a0)
	clr.w	oXVel(a0)
	move.b	#7,oMapFrame(a0)
	move.b	#4,oRoutine(a0)
	move.w	#SCMD_GIGGLESFX,d0
	jsr	SubCPUCmd

.End:
	rts

; -------------------------------------------------------------------------

.NoGrab:
	move.b	#6,oRoutine(a0)
	rts
; End of function ObjAmyRose_CheckGrabSonic

; -------------------------------------------------------------------------

CheckPlayerRange1:
	lea	objPlayerSlot.w,a1
	move.w	oX(a0),d0
	sub.w	oX(a1),d0
	bcc.s	.AbsDX
	neg.w	d0

.AbsDX:
	cmpi.w	#52,d0
	rts
; End of function CheckPlayerRange1

; -------------------------------------------------------------------------

CheckPlayerRange2:
	lea	objPlayerSlot.w,a1
	move.w	oX(a0),d0
	sub.w	oX(a1),d0
	bcc.s	.AbsDX
	neg.w	d0

.AbsDX:
	cmpi.w	#124,d0
	rts
; End of function CheckPlayerRange2

; -------------------------------------------------------------------------

ObjectMove:
	bsr.s	ObjectMoveX
; End of function ObjectMove

; -------------------------------------------------------------------------

ObjectMoveY:
	move.w	oYVel(a0),d0
	ext.l	d0
	asl.l	#8,d0
	add.l	d0,oY(a0)
	rts
; End of function ObjectMoveY

; -------------------------------------------------------------------------

ObjectMoveX:
	move.w	oXVel(a0),d0
	ext.l	d0
	asl.l	#8,d0
	add.l	d0,oX(a0)
	rts
; End of function ObjectMoveX

; -------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR ObjAmyRose_Init

AnimateObjSimple:
	moveq	#0,d0
	move.b	oAnim(a0),d0
	cmp.b	oPrevAnim(a0),d0
	beq.s	.run
	move.b	d0,oPrevAnim(a0)
	clr.b	oAnimFrame(a0)
	clr.b	oAnimTime(a0)

.run:
	subq.b	#1,oAnimTime(a0)
	bpl.s	.End
	add.w	d0,d0
	adda.w	(a1,d0.w),a1

.Next:
	move.b	oAnimFrame(a0),d0
	lea	(a1,d0.w),a2
	move.b	(a2),d0
	bpl.s	.SetFrame
	clr.b	oAnimFrame(a0)
	bra.s	.Next

; -------------------------------------------------------------------------

.SetFrame:
	move.b	d0,d1
	andi.b	#$1F,d0
	move.b	d0,oMapFrame(a0)
	move.b	oFlags(a0),d0
	rol.b	#3,d1
	eor.b	d0,d1
	andi.b	#3,d1
	andi.b	#$FC,oSprFlags(a0)
	or.b	d1,oSprFlags(a0)
	move.b	oSprFlags(a2),oAnimTime(a0)
	addq.b	#2,oAnimFrame(a0)

.End:
	rts
; END OF FUNCTION CHUNK	FOR ObjAmyRose_Init
; -------------------------------------------------------------------------

ObjAmyRose_MakeHearts:
	moveq	#6,d0
	btst	#0,oVar3E(a0)
	beq.s	.ChkTimer
	moveq	#$10,d0

.ChkTimer:
	add.b	d0,oVar3B(a0)
	bcc.s	.End
	jsr	FindObjSlot
	bne.s	.End
	move.b	#$30,oID(a1)
	moveq	#8,d1
	btst	#0,oFlags(a0)
	beq.s	.NoFlip
	move.w	#-$A,d1

.NoFlip:
	btst	#0,oVar3E(a0)
	beq.s	.SetPos
	neg.w	d1

.SetPos:
	move.w	oX(a0),d0
	add.w	d1,d0
	move.w	d0,oX(a1)
	move.w	oY(a0),d0
	subi.w	#$C,d0
	move.w	d0,oY(a1)

.End:
	rts
; End of function ObjAmyRose_MakeHearts

; -------------------------------------------------------------------------

ObjAmyRose_SetFacing:
	bsr.s	ObjAmyRose_XUnflip
	move.w	oX(a0),d0
	sub.w	oX(a1),d0
	bcs.s	.End
	bsr.s	ObjAmyRose_XFlip

.End:
	rts
; End of function ObjAmyRose_SetFacing

; -------------------------------------------------------------------------

ObjAmyRose_XUnflip:
	bclr	#0,oFlags(a0)
	bclr	#0,oSprFlags(a0)
	rts
; End of function ObjAmyRose_XUnflip

; -------------------------------------------------------------------------

ObjAmyRose_XFlip:
	bset	#0,oFlags(a0)
	bset	#0,oSprFlags(a0)
	rts
; End of function ObjAmyRose_XFlip

; -------------------------------------------------------------------------

ObjAmyRose_LoadPal:
	lea	Pal_AmyRose(pc),a3
; End of function ObjAmyRose_LoadPal

; -------------------------------------------------------------------------

ObjAmyRose_ResetPal:
	lea	palette+$20.w,a4
	movem.l	(a3)+,d0-d3
	movem.l	d0-d3,(a4)
	movem.l	(a3)+,d0-d3
	movem.l	d0-d3,$10(a4)
	rts
; End of function ObjAmyRose_ResetPal

; -------------------------------------------------------------------------
Pal_AmyRose:
	incbin	"Level/Palmtree Panic/Objects/Amy Rose/Data/Palette.bin"
	even
; -------------------------------------------------------------------------

ObjAmyHeart:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjAmyHeart_Index(pc,d0.w),d0
	jsr	ObjAmyHeart_Index(pc,d0.w)
	jsr	DrawObject
	jmp	CheckObjDespawn
; End of function ObjAmyHeart

; -------------------------------------------------------------------------
ObjAmyHeart_Index:dc.w	ObjAmyHeart_Init-ObjAmyHeart_Index
	dc.w	ObjAmyHeart_Main-ObjAmyHeart_Index
; -------------------------------------------------------------------------

ObjAmyHeart_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oSprFlags(a0)
	move.w	#$370,oTile(a0)
	move.l	#MapSpr_AmyRose,oMap(a0)
	move.b	#8,oMapFrame(a0)
	move.w	#-$60,oYVel(a0)
	move.b	#3,oPriority(a0)
; End of function ObjAmyHeart_Init

; -------------------------------------------------------------------------

ObjAmyHeart_Main:
	tst.b	oVar3C(a0)
	bne.s	.StopRipple
	moveq	#0,d0
	move.b	oVar3A(a0),d0
	add.b	d0,d0
	add.b	oVar3A(a0),d0
	jsr	CalcSine
	asr.w	#2,d0
	move.w	d0,oXVel(a0)

.StopRipple:
	bsr.w	ObjectMove
	addq.b	#1,oVar3A(a0)
	move.b	oVar3A(a0),d0
	cmpi.b	#$14,d0
	bne.s	.ChkTimer
	addq.b	#1,oMapFrame(a0)

.ChkTimer:
	cmpi.b	#$6E,d0
	bne.s	.ChkDel
	addq.b	#1,oMapFrame(a0)
	clr.w	oYVel(a0)
	clr.w	oXVel(a0)
	st	oVar3C(a0)

.ChkDel:
	cmpi.b	#$78,d0
	bne.s	.End
	jmp	DeleteObject

; -------------------------------------------------------------------------

.End:
	rts
; End of function ObjAmyHeart_Main

; -------------------------------------------------------------------------
