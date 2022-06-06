; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Springboard object
; -------------------------------------------------------------------------

ObjSpringBoard_Platform:
	tst.b	lvlDebugMode
	bne.s	.NoTouch
	cmpi.b	#6,oRoutine(a1)
	bcc.s	.NoTouch
	tst.w	oYVel(a1)
	bmi.s	.NoTouch
	bra.s	.ChkTouch

; -------------------------------------------------------------------------

.NoTouch:
	bclr	#3,oStatus(a0)
	moveq	#0,d1
	rts

; -------------------------------------------------------------------------

.ChkTouch:
	lea	ObjSpringBoard_Size,a2
	andi.w	#7,d0
	asl.w	#2,d0
	lea	(a2,d0.w),a2
	move.w	oX(a0),d0
	move.w	oX(a1),d1
	move.b	oXRadius(a1),d3
	ext.w	d3
	move.b	0(a2),d2
	ext.w	d2
	move.w	d0,d4
	move.w	d1,d5
	add.w	d2,d4
	sub.w	d3,d5
	cmp.w	d4,d5
	bpl.s	.ClearRide
	move.b	1(a2),d2
	ext.w	d2
	neg.w	d2
	move.w	d0,d4
	move.w	d1,d5
	sub.w	d2,d4
	add.w	d3,d5
	cmp.w	d5,d4
	bpl.s	.ClearRide
	move.w	oY(a0),d0
	move.w	oY(a1),d1
	move.b	oYRadius(a1),d3
	ext.w	d3
	move.b	2(a2),d2
	ext.w	d2
	move.w	d0,d4
	move.w	d1,d5
	add.w	d2,d4
	sub.w	d3,d5
	cmp.w	d4,d5
	bpl.s	.ClearRide
	move.b	3(a2),d2
	ext.w	d2
	neg.w	d2
	move.w	d0,d4
	move.w	d1,d5
	sub.w	d2,d4
	add.w	d3,d5
	cmp.w	d5,d4
	bpl.s	.ClearRide
	bset	#3,oStatus(a0)
	moveq	#$FFFFFFFF,d1
	rts

; -------------------------------------------------------------------------

.ClearRide:
	bclr	#3,oStatus(a0)
	moveq	#0,d1
	rts
; End of function ObjSpringBoard_Platform

; -------------------------------------------------------------------------
ObjSpringBoard_Size:
	dc.b	$10, $F0, $10,	$F0
	dc.b	$10, $F0, 4, $FC
	dc.b	9,	$F7, $38, $10
	dc.b	0,	$E8, 4,	$FC
	dc.b	0,	$E8, $C, 0
	dc.b	$18, 0, 4,	$FC
	dc.b	$18, 0, $C, 0
	dc.b	$20, $E0, $20, $E0
; -------------------------------------------------------------------------

ObjSpringBoard:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjSpringBoard_Index(pc,d0.w),d0
	jsr	ObjSpringBoard_Index(pc,d0.w)
	jmp	CheckObjDespawnTime
; End of function ObjSpringBoard

; -------------------------------------------------------------------------
ObjSpringBoard_Index:dc.w	ObjSpringBoard_Init-ObjSpringBoard_Index
	dc.w	ObjSpringBoard_MainNormal-ObjSpringBoard_Index
	dc.w	ObjSpringBoard_MainFlip-ObjSpringBoard_Index
	dc.w	ObjSpringBoard_UnkNormal-ObjSpringBoard_Index
	dc.w	ObjSpringBoard_UnkFlip-ObjSpringBoard_Index
	dc.w	ObjSpringBoard_BounceNormal-ObjSpringBoard_Index
	dc.w	ObjSpringBoard_BounceFlip-ObjSpringBoard_Index
; -------------------------------------------------------------------------

ObjSpringBoard_Init:
	move.l	#MapSpr_SpringBoard,oMap(a0)
	ori.b	#4,oRender(a0)
	move.b	#3,oPriority(a0)
	move.b	#$10,oWidth(a0)
	move.b	#$18,oXRadius(a0)
	move.b	#4,oYRadius(a0)
	moveq	#7,d0
	jsr	LevelObj_SetBaseTile(pc)
	move.b	#3,d0
	move.b	#2,d1
	tst.b	oSubtype(a0)
	bne.s	.Flip
	btst	#0,oRender(a0)
	beq.s	.NoFlip

.Flip:
	move.b	#4,d0
	move.b	#4,d1
	bclr	#0,oRender(a0)
	bclr	#0,oStatus(a0)

.NoFlip:
	move.b	d0,oAnim(a0)
	move.b	d1,oRoutine(a0)
	rts
; End of function ObjSpringBoard_Init

; -------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR ObjSpringBoard_MainFlip

ObjSpringBoard_Animate:
	lea	Ani_SpringBoard(pc),a1
	jsr	AnimateObject
	jmp	DrawObject
; END OF FUNCTION CHUNK	FOR ObjSpringBoard_MainFlip
; -------------------------------------------------------------------------

ObjSpringBoard_MainFlip:

; FUNCTION CHUNK AT 0020BE64 SIZE 00000010 BYTES

	lea	objPlayerSlot.w,a1
	moveq	#3,d0
	bsr.w	ObjSpringBoard_Platform
	tst.b	d1
	beq.s	.NoTouch
	move.l	oY(a0),d0
	moveq	#0,d1
	move.b	oYRadius(a1),d1
	swap	d1
	sub.l	d1,d0
	move.l	d0,oY(a1)
	move.b	#$C,oRoutine(a0)
	move.b	#4,oAnim(a0)

.NoTouch:
	bra.w	ObjSpringBoard_Animate
; End of function ObjSpringBoard_MainFlip

; -------------------------------------------------------------------------

ObjSpringBoard_UnkFlip:
	lea	objPlayerSlot.w,a1
	moveq	#3,d0
	bsr.w	ObjSpringBoard_Platform
	tst.b	d1
	bne.w	.Touching
	move.b	#4,oRoutine(a0)
	btst	#1,oStatus(a1)
	beq.s	.ChkBounce
	move.b	#$C,oRoutine(a0)

.ChkBounce:
	cmpi.b	#$C,oRoutine(a0)
	beq.s	.IsBounce
	bra.s	.Touching

; -------------------------------------------------------------------------

.IsBounce:
	move.b	#$40,oVar2A(a0)

.Touching:
	bra.w	ObjSpringBoard_Animate
; End of function ObjSpringBoard_UnkFlip

; -------------------------------------------------------------------------

ObjSpringBoard_BounceFlip:
	move.b	#2,oAnim(a0)
	nop
	nop
	nop
	nop
	lea	objPlayerSlot.w,a1
	moveq	#4,d0
	bsr.w	ObjSpringBoard_Platform
	tst.b	d1
	beq.s	.NoTouch
	move.w	oYVel(a1),d0
	addi.w	#$100,d0
	cmpi.w	#$A00,d0
	bmi.s	.CapYVel
	move.w	#$A00,d0

.CapYVel:
	neg.w	d0
	move.w	d0,oYVel(a1)
	move.b	#$40,oVar2A(a0)
	bset	#1,oStatus(a1)
	beq.s	.ClearJump
	clr.b	oPlayerJump(a1)

.ClearJump:
	bclr	#5,oStatus(a1)
	clr.b	oPlayerStick(a1)
	move.b	#$13,oYRadius(a1)
	move.b	#9,oXRadius(a1)
	btst	#2,oStatus(a1)
	bne.s	.RollJump
	move.b	#$E,oYRadius(a1)
	move.b	#7,oXRadius(a1)
	addq.w	#5,oY(a1)
	bset	#2,oStatus(a1)
	move.b	#2,oAnim(a1)
	bra.s	.NoTouch

; -------------------------------------------------------------------------

.RollJump:
	bset	#4,oStatus(a1)

.NoTouch:
	move.b	oVar2A(a0),d0
	subq.b	#1,d0
	move.b	d0,oVar2A(a0)
	bne.s	.DoAnim
	move.b	#$40,oVar2A(a0)
	move.b	#4,oRoutine(a0)
	move.b	#4,oAnim(a0)

.DoAnim:
	bra.w	ObjSpringBoard_Animate
; End of function ObjSpringBoard_BounceFlip

; -------------------------------------------------------------------------

ObjSpringBoard_MainNormal:
	lea	objPlayerSlot.w,a1
	moveq	#5,d0
	bsr.w	ObjSpringBoard_Platform
	tst.b	d1
	beq.s	.NoTouch
	move.l	oY(a0),d0
	moveq	#0,d1
	move.b	oYRadius(a1),d1
	swap	d1
	sub.l	d1,d0
	move.l	d0,oY(a1)
	move.b	#$A,oRoutine(a0)
	move.b	#3,oAnim(a0)

.NoTouch:
	bra.w	ObjSpringBoard_Animate
; End of function ObjSpringBoard_MainNormal

; -------------------------------------------------------------------------

ObjSpringBoard_UnkNormal:
	lea	objPlayerSlot.w,a1
	moveq	#5,d0
	bsr.w	ObjSpringBoard_Platform
	tst.b	d1
	bne.w	.NoTouch
	move.b	#2,oRoutine(a0)
	btst	#1,oStatus(a1)
	beq.s	.ChkBounce
	move.b	#$A,oRoutine(a0)

.ChkBounce:
	cmpi.b	#$A,oRoutine(a0)
	beq.s	.IsBounce
	bra.s	.NoTouch

; -------------------------------------------------------------------------

.IsBounce:
	move.b	#$40,oVar2A(a0)

.NoTouch:
	bra.w	ObjSpringBoard_Animate
; End of function ObjSpringBoard_UnkNormal

; -------------------------------------------------------------------------

ObjSpringBoard_BounceNormal:
	move.b	#1,oAnim(a0)
	lea	objPlayerSlot.w,a1
	moveq	#6,d0
	bsr.w	ObjSpringBoard_Platform
	tst.b	d1
	beq.s	.Touching
	move.w	oYVel(a1),d0
	addi.w	#$100,d0
	cmpi.w	#$A00,d0
	bmi.s	.CapYVel
	move.w	#$A00,d0

.CapYVel:
	neg.w	d0
	move.w	d0,oYVel(a1)
	move.b	#$40,oVar2A(a0)
	bset	#1,oStatus(a1)
	beq.s	.ClearJump
	clr.b	oPlayerJump(a1)

.ClearJump:
	bclr	#5,oStatus(a1)
	clr.b	oPlayerStick(a1)
	move.b	#$13,oYRadius(a1)
	move.b	#9,oXRadius(a1)
	btst	#2,oStatus(a1)
	bne.s	.RollJump
	move.b	#$E,oYRadius(a1)
	move.b	#7,oXRadius(a1)
	addq.w	#5,oY(a1)
	bset	#2,oStatus(a1)
	move.b	#2,oAnim(a1)
	bra.s	.Touching

; -------------------------------------------------------------------------

.RollJump:
	bset	#4,oStatus(a1)

.Touching:
	move.b	oVar2A(a0),d0
	subq.b	#1,d0
	move.b	d0,oVar2A(a0)
	bne.s	.Animate
	move.b	#2,oRoutine(a0)
	move.b	#3,oAnim(a0)
	move.b	#$40,oVar2A(a0)

.Animate:
	bra.w	ObjSpringBoard_Animate
; End of function ObjSpringBoard_BounceNormal

; -------------------------------------------------------------------------
Ani_SpringBoard:
	include	"Level/Palmtree Panic/Objects/Springboard/Data/Animations.asm"
	even
MapSpr_SpringBoard:
	include	"Level/Palmtree Panic/Objects/Springboard/Data/Mappings.asm"
	even

; -------------------------------------------------------------------------
