; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; 3D ramp objects
; -------------------------------------------------------------------------

Obj3DPlant:
	lea	objPlayerSlot.w,a6
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	Obj3DPlant_Index(pc,d0.w),d0
	jsr	Obj3DPlant_Index(pc,d0.w)
	jsr	DrawObject
	move.w	oVar2A(a0),d0
	bra.w	CheckObjDespawn2
; End of function Obj3DPlant

; -------------------------------------------------------------------------
Obj3DPlant_Index:
	dc.w	Obj3DPlant_Init-Obj3DPlant_Index
	dc.w	Obj3DPlant_Main-Obj3DPlant_Index
; -------------------------------------------------------------------------

Obj3DPlant_Init:
	ori.b	#4,oSprFlags(a0)
	move.l	#MapSpr_3DPlant,oMap(a0)
	move.w	#$4424,oTile(a0)
	move.b	#$18,oWidth(a0)
	move.b	#$14,oYRadius(a0)
	move.w	oX(a0),d3
	movea.l	a0,a1
	moveq	#3,d6
	bclr	#0,oSubtype(a0)
	beq.s	.GotCount
	moveq	#1,d6

.GotCount:
	moveq	#0,d2
	bra.s	.Init

; -------------------------------------------------------------------------

.Loop:
	jsr	FindObjSlot

.Init:
	addq.b	#2,oRoutine(a1)
	move.b	#$2C,oID(a1)
	move.w	d3,oX(a1)
	move.w	oY(a0),oY(a1)
	move.w	d3,oVar2A(a1)
	move.l	oMap(a0),oMap(a1)
	move.w	oTile(a0),oTile(a1)
	move.b	oWidth(a0),oWidth(a1)
	move.b	oYRadius(a0),oYRadius(a1)
	ori.b	#4,oSprFlags(a1)
	move.w	Obj3DPlant_Offsets1(pc,d2.w),d1
	add.w	d1,oX(a1)
	move.w	oX(a1),oVar2C(a1)
	addq.b	#2,d2
	dbf	d6,.Loop

	moveq	#2,d6
	moveq	#0,d2

.Loop2:
	jsr	FindObjSlot
	addq.b	#2,oRoutine(a1)
	move.b	#$2C,oID(a1)
	move.b	#1,oSubtype(a1)
	move.b	#1,oMapFrame(a1)
	move.b	#4,oPriority(a1)
	move.w	d3,oX(a1)
	move.w	d3,oVar2A(a1)
	move.w	oY(a0),oY(a1)
	move.l	oMap(a0),oMap(a1)
	move.w	oTile(a0),oTile(a1)
	move.b	#$C,oWidth(a1)
	move.b	#$C,oYRadius(a1)
	ori.b	#4,oSprFlags(a1)
	move.w	Obj3DPlant_Offsets2(pc,d2.w),d1
	add.w	d1,oX(a1)
	addq.b	#2,d2
	dbf	d6,.Loop2
	rts
; End of function Obj3DPlant_Init

; -------------------------------------------------------------------------
Obj3DPlant_Offsets1:dc.w	$40, $80, $FFC0, $FF80
Obj3DPlant_Offsets2:dc.w	0, $60, $FFA0
; -------------------------------------------------------------------------

Obj3DPlant_Main:
	tst.b	oSubtype(a0)
	bne.s	.End
	moveq	#0,d0
	btst	#1,oVar2C(a6)
	beq.s	.MovePlant
	moveq	#0,d3
	move.w	oX(a6),d0
	move.w	d0,d2
	andi.w	#$FF,d0
	cmp.w	oVar2A(a0),d2
	bcc.s	.GetChunkPos
	move.w	d0,d1
	move.w	#$FF,d0
	sub.w	d1,d0

.GetChunkPos:
	cmpi.w	#$C0,d0
	bcs.s	.GotChunkPos
	cmpi.w	#$F0,d0
	bcc.s	.CapChunkPos
	move.w	#$BF,d0
	bra.s	.GotChunkPos

; -------------------------------------------------------------------------

.CapChunkPos:
	moveq	#0,d0

.GotChunkPos:
	lsr.w	#1,d0
	cmp.w	oVar2A(a0),d2
	bcc.s	.MovePlant
	neg.w	d0

.MovePlant:
	add.w	oVar2C(a0),d0
	move.w	d0,oX(a0)

.End:
	rts
; End of function Obj3DPlant_Main

; -------------------------------------------------------------------------

Obj3DFall:
	move.w	Obj3DFall_Index(pc,d0.w),d0
	jsr	Obj3DFall_Index(pc,d0.w)
	bra.w	CheckObjDespawn
; End of function Obj3DFall

; -------------------------------------------------------------------------
Obj3DFall_Index:dc.w	Obj3DFall_Init-Obj3DFall_Index
	dc.w	Obj3DFall_Main-Obj3DFall_Index
; -------------------------------------------------------------------------

Obj3DFall_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oSprFlags(a0)
; End of function Obj3DFall_Init

; -------------------------------------------------------------------------

Obj3DFall_Main:
	if (REGION=USA)|((REGION<>USA)&(DEMO=0))
		cmpi.b	#$2B,oAnim(a6)
		beq.w	.End
	endif
	move.w	oY(a0),d0
	sub.w	oY(a6),d0
	addi.w	#$40,d0
	cmpi.w	#$80,d0
	bcc.s	.End
	move.w	oX(a0),d0
	sub.w	oX(a6),d0
	addi.w	#$20,d0
	cmpi.w	#$40,d0
	bcc.s	.End
	move.w	oX(a0),d0
	move.w	oXVel(a6),d1
	tst.w	d1
	bpl.s	.End
	cmp.w	oX(a6),d0
	bcs.s	.End
	move.w	d0,oX(a6)
	move.w	#0,oXVel(a6)
	move.w	#0,oPlayerGVel(a6)
	move.b	#$37,oAnim(a6)
	move.b	#1,oPlayerJump(a6)
	clr.b	oPlayerStick(a6)
	move.b	#$E,oYRadius(a0)
	move.b	#7,oXRadius(a0)
	addq.w	#5,oY(a0)
	bset	#2,oFlags(a6)

.End:
	rts
; End of function Obj3DFall_Main

; -------------------------------------------------------------------------

Obj3DRamp:
	lea	objPlayerSlot.w,a6
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	tst.b	oSubtype2(a0)
	bne.w	Obj3DFall
	move.w	Obj3DRamp_Index(pc,d0.w),d0
	jsr	Obj3DRamp_Index(pc,d0.w)
	jsr	DrawObject
	move.w	oVar2A(a0),d0
	bra.w	CheckObjDespawn2
; End of function Obj3DRamp

; -------------------------------------------------------------------------
Obj3DRamp_Index:dc.w	Obj3DRamp_Init-Obj3DRamp_Index
	dc.w	Obj3DRamp_Main-Obj3DRamp_Index
; -------------------------------------------------------------------------

Obj3DRamp_Init:
	addq.b	#2,oRoutine(a0)
	move.b	#4,oSprFlags(a0)
	move.b	#1,oPriority(a0)
	move.l	#MapSpr_3DRamp,oMap(a0)
	move.w	#$441,oTile(a0)
	move.b	#$20,oWidth(a0)
	move.b	#$20,oYRadius(a0)
	move.w	oX(a0),oVar2A(a0)
	tst.b	oSubtype(a0)
	beq.s	Obj3DRamp_Main
	bset	#0,oSprFlags(a0)
	bset	#0,oFlags(a0)
; End of function Obj3DRamp_Init

; -------------------------------------------------------------------------

Obj3DRamp_Main:
	tst.b	oVar2E(a0)
	beq.s	.TimeRunSet
	move.b	#1,oAnim(a0)
	btst	#1,oPlayerCtrl(a6)
	bne.s	.Animate
	addq.b	#1,oAnim(a0)

.Animate:
	lea	Ani_3DRamp,a1
	jsr	AnimateObject
	bra.s	.GetChunkPos

; -------------------------------------------------------------------------

.TimeRunSet:
	move.b	#0,oMapFrame(a0)
	moveq	#0,d1
	btst	#1,oPlayerCtrl(a6)
	beq.s	.Move3D

.GetChunkPos:
	move.w	oX(a6),d0
	andi.w	#$FF,d0
	tst.b	oSubtype(a0)
	beq.s	.NoFlip
	move.w	d0,d1
	move.w	#$FF,d0
	sub.w	d1,d0

.NoFlip:
	cmpi.w	#$C0,d0
	bcs.s	.GotChunkPos
	cmpi.w	#$F0,d0
	bcc.s	.CapChunkPos
	move.w	#$BF,d0
	bra.s	.GotChunkPos

; -------------------------------------------------------------------------

.CapChunkPos:
	moveq	#0,d0

.GotChunkPos:
	ext.l	d0
	move.w	d0,d1
	tst.b	oVar2E(a0)
	bne.s	.KeepFrame
	divu.w	#$30,d0
	move.b	d0,oMapFrame(a0)

.KeepFrame:
	lsr.w	#2,d1
	move.w	d1,d2
	lsr.w	#1,d2
	add.w	d2,d1
	tst.b	oSubtype(a0)
	beq.s	.Move3D
	neg.w	d1

.Move3D:
	add.w	oVar2A(a0),d1
	move.w	d1,oX(a0)
	tst.b	oVar2E(a0)
	beq.s	.SkipTimer
	subq.b	#1,oVar2E(a0)
	bra.s	.ChkTouch

; -------------------------------------------------------------------------

.SkipTimer:
	btst	#1,oFlags(a6)
	bne.s	.End

.ChkTouch:
	move.b	oWidth(a0),d1
	ext.w	d1
	move.w	oX(a6),d0
	sub.w	oX(a0),d0
	add.w	d1,d0
	bmi.s	.End
	add.w	d1,d1
	cmp.w	d1,d0
	bcc.s	.End
	move.b	oYRadius(a0),d1
	ext.w	d1
	move.w	oY(a6),d0
	sub.w	oY(a0),d0
	add.w	d1,d0
	bmi.s	.End
	add.w	d1,d1
	cmp.w	d1,d0
	bcc.s	.End
	cmpi.b	#$2B,oAnim(a6)
	beq.s	.End
	tst.b	oVar2E(a0)
	bne.s	.TimerSet
	move.b	#60,oVar2E(a0)

.TimerSet:
	tst.w	oYVel(a6)
	bpl.s	.LaunchDown
	move.w	#-$C00,oYVel(a6)
	rts

; -------------------------------------------------------------------------

.LaunchDown:
	move.w	#$C00,oYVel(a6)

.End:
	rts
; End of function Obj3DRamp_Main

; -------------------------------------------------------------------------
MapSpr_3DPlant:
	include	"Level/Palmtree Panic/Objects/3D Ramp/Data/Mappings (Plant).asm"
	even
Ani_3DRamp:
	include	"Level/Palmtree Panic/Objects/3D Ramp/Data/Animations (Booster).asm"
	even

; -------------------------------------------------------------------------
