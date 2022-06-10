; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Level end objects
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Flower capsule object
; -------------------------------------------------------------------------

ObjCapsule:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjCapsule_Index(pc,d0.w),d0
	jsr	ObjCapsule_Index(pc,d0.w)
	tst.b	oRoutine(a0)
	beq.s	.End
	cmpi.b	#$A,oRoutine(a0)
	beq.s	.Display
	cmpi.b	#6,oRoutine(a0)
	bcc.s	.End

.Display:
	jmp	DrawObject

; -------------------------------------------------------------------------

.End:
	rts
; End of function ObjCapsule

; -------------------------------------------------------------------------
ObjCapsule_Index:dc.w	ObjCapsule_Init-ObjCapsule_Index
	dc.w	ObjCapsule_Main-ObjCapsule_Index
	dc.w	ObjCapsule_Explode-ObjCapsule_Index
	dc.w	LoadEndOfAct-ObjCapsule_Index
	dc.w	ObjCapsule_Signpost_Null-ObjCapsule_Index
	dc.w	ObjCapsule_FlowerSeeds-ObjCapsule_Index
; -------------------------------------------------------------------------

ObjCapsule_Init:
	ori.b	#4,oRender(a0)
	addq.b	#2,oRoutine(a0)
	move.b	#4,oPriority(a0)
	move.l	#MapSpr_FlowerCapsule,4(a0)
	move.w	#$2481,oTile(a0)
	move.b	#$20,oXRadius(a0)
	move.b	#$20,oWidth(a0)
	move.b	#$18,oYRadius(a0)
; End of function ObjCapsule_Init

; -------------------------------------------------------------------------

ObjCapsule_Main:
	lea	Ani_FlowerCapsule,a1
	jsr	AnimateObject
	lea	objPlayerSlot.w,a6
	bsr.w	ObjCapsule_CheckCollision
	beq.s	.End
	clr.b	updateTime
	move.b	#2,oMapFrame(a0)
	move.b	#$78,oVar2A(a0)
	addq.b	#2,oRoutine(a0)
	move.w	objPlayerSlot+oX.w,d0
	move.b	objPlayerSlot+oXRadius.w,d1
	ext.w	d1
	addi.w	#$20,d1
	sub.w	8(a0),d0
	add.w	d1,d0
	bmi.s	.BounceX
	add.w	d1,d1
	cmp.w	d1,d0
	bcc.s	.BounceX
	move.w	objPlayerSlot+oYVel.w,d0
	neg.w	d0
	asr.w	#2,d0
	move.w	d0,objPlayerSlot+oYVel.w
	rts

; -------------------------------------------------------------------------

.BounceX:
	move.w	objPlayerSlot+oXVel.w,d0
	neg.w	d0
	asr.w	#2,d0
	move.w	d0,objPlayerSlot+oXVel.w

.End:
	rts
; End of function ObjCapsule_Main

; -------------------------------------------------------------------------

ObjCapsule_Explode:
	subq.b	#1,oVar2A(a0)
	bmi.s	.FinishUp
	move.b	oVar2A(a0),d0
	move.b	d0,d1
	andi.b	#3,d1
	bne.s	.End
	lsr.w	#2,d0
	andi.w	#7,d0
	add.w	d0,d0
	lea	ObjCapsule_ExplosionLocs(pc,d0.w),a2
	jsr	FindObjSlot
	bne.s	.End
	move.w	#$9E,d0
	jsr	PlayFMSound
	move.b	#$18,oID(a1)
	move.b	#1,oRoutine2(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	move.b	(a2),d0
	ext.w	d0
	add.w	d0,oX(a1)
	move.b	1(a2),d0
	ext.w	d0
	add.w	d0,oY(a1)
	rts

; -------------------------------------------------------------------------

.FinishUp:
	bsr.w	ObjCapsule_SpawnSeeds
	addq.b	#2,$24(a0)
	move.b	#$3C,$2A(a0)

.End:
	rts
; End of function ObjCapsule_Explode

; -------------------------------------------------------------------------
ObjCapsule_ExplosionLocs:dc.b	0, 0
	dc.b	$20, $F8
	dc.b	$E0, 0
	dc.b	$E8, $F8
	dc.b	$18, 8
	dc.b	$F0, 8
	dc.b	$10, 8
	dc.b	$F8, $F8
; -------------------------------------------------------------------------

ObjCapsule_SpawnSeeds:
	moveq	#0,d0
	move.b	LevelPaletteID,d0
	move.l	d7,d6
	jsr	LoadPalette
	move.l	d6,d7
	moveq	#6,d6
	moveq	#0,d1

.Loop:
	jsr	FindObjSlot
	bne.s	.End
	move.b	#$15,oID(a1)
	ori.b	#4,oRender(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	move.b	#$A,oRoutine(a1)
	move.l	#MapSpr_FlowerCapsule,oMap(a1)
	move.w	#$2481,oTile(a1)
	move.b	#1,oAnim(a1)
	move.w	#-$600,oYVel(a1)
	move.w	ObjCapsule_FlowerLocs(pc,d1.w),oXVel(a1)
	addq.w	#2,d1
	dbf	d6,.Loop

.End:
	rts
; End of function ObjCapsule_SpawnSeeds

; -------------------------------------------------------------------------
ObjCapsule_FlowerLocs:dc.w	0
	dc.w	$FF80
	dc.w	$80
	dc.w	$FF00
	dc.w	$100
	dc.w	$FE80
	dc.w	$180
	dc.w	$FE00
	dc.w	$200
	dc.w	$FD80
	dc.w	$280
; -------------------------------------------------------------------------

ObjCapsule_FlowerSeeds:
	lea	Ani_FlowerCapsule,a1
	jsr	AnimateObject
	jsr	ObjMoveGrv
	jsr	CheckFloorEdge
	tst.w	d1
	bpl.s	.End
	move.b	#$1F,oID(a0)
	move.b	#1,oSubtype(a0)
	move.b	#0,oRoutine(a0)

.End:
	rts
; End of function ObjCapsule_FlowerSeeds

; -------------------------------------------------------------------------

ObjCapsule_CheckCollision:
	btst	#2,oStatus(a6)
	beq.s	.NoCollide
	move.b	oXRadius(a6),d1
	ext.w	d1
	addi.w	#$20,d1
	move.w	oX(a6),d0
	sub.w	oX(a0),d0
	add.w	d1,d0
	bmi.s	.NoCollide
	add.w	d1,d1
	cmp.w	d1,d0
	bcc.s	.NoCollide
	move.b	oYRadius(a6),d1
	ext.w	d1
	addi.w	#$1C,d1
	move.w	oY(a6),d0
	sub.w	oY(a0),d0
	add.w	d1,d0
	bmi.s	.NoCollide
	add.w	d1,d1
	cmp.w	d1,d0
	bcc.s	.NoCollide
	moveq	#1,d0
	rts

; -------------------------------------------------------------------------

.NoCollide:
	moveq	#0,d0
	rts

; -------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR ObjBigRing

ObjBigRingFlash:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjBigRingFlash_Index(pc,d0.w),d0
	jsr	ObjBigRingFlash_Index(pc,d0.w)
	jmp	DrawObject
; END OF FUNCTION CHUNK	FOR ObjBigRing

; -------------------------------------------------------------------------
ObjBigRingFlash_Index:dc.w	ObjBigRingFlash_Init-ObjBigRingFlash_Index
	dc.w	ObjBigRingFlash_Animate-ObjBigRingFlash_Index
	dc.w	ObjBigRingFlash_Destroy-ObjBigRingFlash_Index
; -------------------------------------------------------------------------

ObjBigRingFlash_Init:
	ori.b	#4,oRender(a0)
	addq.b	#2,oRoutine(a0)
	move.w	#$3EF,oTile(a0)
	move.l	#MapSpr_BigRingFlash,oMap(a0)
; End of function ObjBigRingFlash_Init

; -------------------------------------------------------------------------

ObjBigRingFlash_Animate:
	lea	Ani_BigRingFlash,a1
	jmp	AnimateObject
; End of function ObjBigRingFlash_Animate

; -------------------------------------------------------------------------

ObjBigRingFlash_Destroy:
	jmp	DeleteObject
; End of function ObjBigRingFlash_Destroy

; -------------------------------------------------------------------------

ObjBigRing:

; FUNCTION CHUNK AT 0020D4B4 SIZE 00000014 BYTES

	tst.b	oSubtype(a0)
	bne.s	ObjBigRingFlash
	cmpi.w	#50,levelRings
	bcc.s	.Proceed
	if (REGION=USA)|((REGION<>USA)&(DEMO=0))
		jmp	CheckObjDespawnTime
	else
		jmp	DeleteObject
	endif

; -------------------------------------------------------------------------

.Proceed:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjBigRing_Index(pc,d0.w),d0
	jsr	ObjBigRing_Index(pc,d0.w)
	cmpi.b	#4,oRoutine(a0)
	beq.s	.End
	jmp	DrawObject

; -------------------------------------------------------------------------

.End:
	rts
; End of function ObjBigRing

; -------------------------------------------------------------------------
ObjBigRing_Index:dc.w	ObjBigRing_Init-ObjBigRing_Index
	dc.w	ObjBigRing_Main-ObjBigRing_Index
	dc.w	ObjBigRing_Animate-ObjBigRing_Index
; -------------------------------------------------------------------------

ObjBigRing_Init:
	cmpi.b	#$7F,timeStones
	bne.s	.TimeStonesLeft
	jmp	DeleteObject

; -------------------------------------------------------------------------

.TimeStonesLeft:
	tst.b	timeAttackMode
	beq.s	.Init
	jmp	DeleteObject

; -------------------------------------------------------------------------

.Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oRender(a0)
	move.w	#$2488,oTile(a0)
	move.l	#MapSpr_BigRing,oMap(a0)
	move.b	#$20,oXRadius(a0)
	move.b	#$20,oWidth(a0)
	move.b	#$20,oYRadius(a0)
; End of function ObjBigRing_Init

; -------------------------------------------------------------------------

ObjBigRing_Main:
	lea	objPlayerSlot.w,a1
	bsr.w	ObjBigRing_CheckCollision
	beq.s	ObjBigRing_Animate
	move.b	#1,enteredBigRing
	addq.b	#2,oRoutine(a0)
	move.w	cameraX.w,d0
	addi.w	#$150,d0
	move.w	d0,oX(a1)
	bset	#0,ctrlLocked.w
	move.w	#$808,playerCtrlHold.w
	move.w	#0,oXVel(a1)
	move.w	#0,oPlayerGVel(a1)
	move.b	#1,scrollLock.w
	move.w	#$AF,d0
	jsr	PlayFMSound
	jsr	FindObjSlot
	bne.s	ObjBigRing_Main
	move.b	#$14,oID(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	move.b	#1,oSubtype(a1)
; End of function ObjBigRing_Main

; -------------------------------------------------------------------------

ObjBigRing_Animate:
	lea	Ani_BigRing,a1
	jmp	AnimateObject
; End of function ObjBigRing_Animate

; -------------------------------------------------------------------------

ObjBigRing_CheckCollision:
	move.b	oXRadius(a1),d1
	ext.w	d1
	addi.w	#$10,d1
	move.w	oX(a1),d0
	sub.w	oX(a0),d0
	add.w	d1,d0
	bmi.s	.NoCollide
	add.w	d1,d1
	cmp.w	d1,d0
	bcc.s	.NoCollide
	move.b	oYRadius(a1),d1
	ext.w	d1
	addi.w	#$20,d1
	move.w	oY(a1),d0
	sub.w	oY(a0),d0
	add.w	d1,d0
	bmi.s	.NoCollide
	add.w	d1,d1
	cmp.w	d1,d0
	bcc.s	.NoCollide
	moveq	#1,d0
	rts

; -------------------------------------------------------------------------

.NoCollide:
	moveq	#0,d0
	rts
; End of function ObjBigRing_CheckCollision

; -------------------------------------------------------------------------

ObjGoalPost:
	lea	objPlayerSlot.w,a6
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjGoalPost_Index(pc,d0.w),d0
	jsr	ObjGoalPost_Index(pc,d0.w)
	cmpi.b	#2,levelAct
	beq.s	.MarkGone
	jsr	DrawObject

.MarkGone:
	jmp	CheckObjDespawnTime
; End of function ObjGoalPost

; -------------------------------------------------------------------------
ObjGoalPost_Index:dc.w	ObjGoalPost_Init-ObjGoalPost_Index
	dc.w	ObjGoalPost_Main-ObjGoalPost_Index
	dc.w	ObjGoalPost_Null-ObjGoalPost_Index
; -------------------------------------------------------------------------

ObjGoalPost_Init:
	cmpi.w	#$201,levelZone
	bne.s	.Init
	cmpi.b	#1,timeZone
	bne.s	.Init
	tst.b	oSubtype(a0)
	bne.s	.WaitPLC
	move.b	#1,oSubtype(a0)
	moveq	#$13,d0
	jmp	LoadPLC

; -------------------------------------------------------------------------

.WaitPLC:
	tst.l	plcBuffer.w
	beq.s	.Init
	rts

; -------------------------------------------------------------------------

.Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oRender(a0)
	move.b	#4,oPriority(a0)
	move.l	#MapSpr_GoalSignpost,oMap(a0)
	move.b	#$10,oXRadius(a0)
	move.b	#$10,oWidth(a0)
	move.b	#$20,oYRadius(a0)
	move.b	#5,oMapFrame(a0)
	bsr.w	ObjGoalPost_SetBaseTile
; End of function ObjGoalPost_Init

; -------------------------------------------------------------------------

ObjGoalPost_Main:
	move.w	oY(a6),d0
	sub.w	oY(a0),d0
	addi.w	#$80,d0
	bmi.s	.End
	cmpi.w	#$100,d0
	bcc.s	.End
	move.w	oX(a6),d0
	cmp.w	oX(a0),d0
	bcs.s	.End
	addq.b	#2,oRoutine(a0)
	move.w	cameraX.w,leftBound.w
	move.w	cameraX.w,destLeftBound.w
	clr.w	timeWarpTimer.w
	clr.b	timeWarpDir.w
	clr.b	timeWarpFlag
	moveq	#$12,d0
	jmp	LoadPLC

; -------------------------------------------------------------------------

.End:
	rts
; End of function ObjGoalPost_Main

; -------------------------------------------------------------------------

ObjGoalPost_Null:
	rts
; End of function ObjGoalPost_Null

; -------------------------------------------------------------------------

ObjGoalPost_SetBaseTile:
	moveq	#0,d0
	move.w	level,d0
	lsl.b	#7,d0
	lsr.w	#4,d0
	move.b	timeZone,d1
	cmpi.b	#2,d1
	bne.s	.NotFuture
	add.b	goodFuture,d1

.NotFuture:
	add.b	d1,d1
	add.b	d1,d0
	move.w	ObjGoalPost_BaseTileList(pc,d0.w),oTile(a0)
	cmpi.b	#3,levelZone
	beq.s	.End
	ori.w	#$8000,oTile(a0)

.End:
	rts
; End of function ObjGoalPost_SetBaseTile

; -------------------------------------------------------------------------
ObjGoalPost_BaseTileList:
	dc.w	$35A, $4F7, $4F7, $4F7, $381, $4F7, $4F7,	$4F7
	dc.w	$300, $300, $300, $300, $300, $300, $300, $300
	dc.w	$4F2, $4F2, $4F2, $4F2, $4F2, $4F2, $4F2, $4F2
	dc.w	$2BA, $2CC, $2B3, $2B1, $2BA, $2CC, $2B3, $2B1
	dc.w	$254, $22C, $294, $238, $278, $28A, $2BC, $298
	dc.w	$3AE, $3AE, $3AE, $3AE, $3AE, $3AE, $3AE, $3AE
	dc.w	$220, $221, $24C, $236, $23E, $24A, $25D, $246
; -------------------------------------------------------------------------

ObjSignpost:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjSignpost_Index(pc,d0.w),d0
	jsr	ObjSignpost_Index(pc,d0.w)
	jmp	DrawObject
; End of function ObjSignpost

; -------------------------------------------------------------------------
ObjSignpost_Index:dc.w	ObjSignpost_Init-ObjSignpost_Index
	dc.w	ObjSignpost_Main-ObjSignpost_Index
	dc.w	ObjSignpost_Spin-ObjSignpost_Index
	dc.w	LoadEndOfAct-ObjSignpost_Index
	dc.w	ObjCapsule_Signpost_Null-ObjSignpost_Index
; -------------------------------------------------------------------------

ObjSignpost_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oRender(a0)
	move.b	#$18,oXRadius(a0)
	move.b	#$18,oWidth(a0)
	move.b	#$20,oYRadius(a0)
	move.b	#4,oPriority(a0)
	move.w	#$43C,oTile(a0)
	cmpi.b	#3,levelZone
	beq.s	.NotHighPriority
	ori.b	#$80,oTile(a0)

.NotHighPriority:
	move.l	#MapSpr_GoalSignpost,oMap(a0)
; End of function ObjSignpost_Init

; -------------------------------------------------------------------------

ObjSignpost_Main:
	lea	objPlayerSlot.w,a6
	move.w	oY(a6),d0
	sub.w	oY(a0),d0
	addi.w	#$80,d0
	bmi.s	.End
	cmpi.w	#$100,d0
	bcc.s	.End
	move.w	oX(a0),d0
	cmp.w	oX(a6),d0
	bcc.s	.End
	move.w	cameraX.w,leftBound.w
	move.w	cameraX.w,destLeftBound.w
	clr.b	updateTime
	move.b	#$78,oVar2A(a0)
	move.b	#0,oMapFrame(a0)
	addq.b	#2,oRoutine(a0)
	clr.b	speedShoesFlag
	clr.b	invincibleFlag
	move.w	#$9D,d0
	jmp	PlayFMSound

; -------------------------------------------------------------------------

.End:
	rts
; End of function ObjSignpost_Main

; -------------------------------------------------------------------------

ObjSignpost_Spin:
	lea	Ani_Signpost,a1
	jsr	AnimateObject
	subq.b	#1,oVar2A(a0)
	bne.s	.End
	addq.b	#2,oRoutine(a0)
	move.b	#3,oMapFrame(a0)
	move.b	#60,oVar2A(a0)

.End:
	rts
; End of function ObjSignpost_Spin

; -------------------------------------------------------------------------

LoadEndOfAct:
	subq.b	#1,oVar2A(a0)
	bne.w	.End
	tst.b	timeZone
	bne.s	.NotPast
	move.w	#$82,d0
	jsr	SubCPUCmd

.NotPast:
	move.w	#$6B,d0
	jsr	SubCPUCmd
	bset	#0,ctrlLocked.w
	move.w	#$808,playerCtrlHold.w
	cmpi.w	#$502,levelZone
	bne.s	.NotSSZ3
	move.w	#0,playerCtrlHold.w

.NotSSZ3:
	move.b	#$B4,oVar2A(a0)
	addq.b	#2,oRoutine(a0)
	jsr	FindObjSlot
	move.b	#$3A,oID(a1)
	move.b	#$10,oVar32(a1)
	move.b	#1,updateResultsBonus.w
	moveq	#0,d0
	move.b	levelTime+1,d0
	mulu.w	#60,d0
	moveq	#0,d1
	move.b	levelTime+2,d1
	add.w	d1,d0
	divu.w	#$F,d0
	moveq	#$14,d1
	cmp.w	d1,d0
	bcs.s	.GetBonus
	move.w	d1,d0

.GetBonus:
	add.w	d0,d0
	move.w	TimeBonuses(pc,d0.w),bonusCount1.w
	move.w	levelRings,d0
	mulu.w	#$64,d0
	move.w	d0,bonusCount2.w

.End:
	rts
; End of function LoadEndOfAct

; -------------------------------------------------------------------------
TimeBonuses:
	dc.w	50000
	dc.w	50000
	dc.w	10000
	dc.w	5000
	dc.w	4000
	dc.w	4000
	dc.w	3000
	dc.w	3000
	dc.w	2000
	dc.w	2000
	dc.w	2000
	dc.w	2000
	dc.w	1000
	dc.w	1000
	dc.w	1000
	dc.w	1000
	dc.w	500
	dc.w	500
	dc.w	500
	dc.w	500
	dc.w	0
; -------------------------------------------------------------------------

ObjCapsule_Signpost_Null:
	rts
; End of function ObjCapsule_Signpost_Null

; -------------------------------------------------------------------------

LoadFlowerCapsulePal:
	move.w	#7,d6
	lea	Pal_FlowerCapsule,a1
	lea	palette+$20.w,a2

.Load:
	move.l	(a1)+,(a2)+
	dbf	d6,.Load
	rts
; End of function LoadFlowerCapsulePal

; -------------------------------------------------------------------------

Pal_FlowerCapsule:
	incbin	"Level/_Objects/Level End/Data/Palette (Flower Capsule).bin"
	even
Ani_BigRingFlash:
	include	"Level/_Objects/Level End/Data/Animations (Big Ring Flash).asm"
	even
MapSpr_BigRingFlash:
	include	"Level/_Objects/Level End/Data/Mappings (Big Ring Flash).asm"
	even
Art_BigRingFlash:
	incbin	"Level/_Objects/Level End/Data/Art (Big Ring Flash).nem"
	even

; -------------------------------------------------------------------------
