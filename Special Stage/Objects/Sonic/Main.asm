; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Sonic object
; -------------------------------------------------------------------------

ObjSonic_Index:
	dc.w	ObjSonic_Init-ObjSonic_Index
	dc.w	ObjSonic_Normal-ObjSonic_Index
	dc.w	ObjSonic_Jump-ObjSonic_Index
	dc.w	ObjSonic_Float-ObjSonic_Index
	dc.w	ObjSonic_Bumped-ObjSonic_Index
	dc.w	ObjSonic_Unk-ObjSonic_Index
	dc.w	ObjSonic_Unk2-ObjSonic_Index
	dc.w	ObjSonic_Hurt-ObjSonic_Index
	dc.w	ObjSonic_GotTimeStone1-ObjSonic_Index
	dc.w	ObjSonic_GotTimeStone2-ObjSonic_Index
	dc.w	ObjSonic_GotTimeStone3-ObjSonic_Index
	dc.w	ObjSonic_GotTimeStone4-ObjSonic_Index
	dc.w	ObjSonic_GotTimeStone5-ObjSonic_Index
	dc.w	ObjSonic_GotTimeStone6-ObjSonic_Index
	dc.w	ObjSonic_GotTimeStone7-ObjSonic_Index
	dc.w	ObjSonic_GotTimeStone8-ObjSonic_Index
	dc.w	ObjSonic_GotTimeStone9-ObjSonic_Index
	dc.w	ObjSonic_GotTimeStone10-ObjSonic_Index
	dc.w	ObjSonic_GotTimeStone11-ObjSonic_Index
	dc.w	ObjSonic_Boosted-ObjSonic_Index
	dc.w	ObjSonic_Start1-ObjSonic_Index
	dc.w	ObjSonic_Start2-ObjSonic_Index
	dc.w	ObjSonic_Start3-ObjSonic_Index
	dc.w	ObjSonic_Start4-ObjSonic_Index

; -------------------------------------------------------------------------

ObjSonic:
	move.w	ctrlData.w,d0
	cmp.w	ctrlData.w,d0
	bne.s	ObjSonic
	move.w	d0,playerCtrlData
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	add.w	d0,d0
	move.w	ObjSonic_Index(pc,d0.w),d0
	bsr.w	ObjSonic_HandleSpeed
	bclr	#5,oFlags(a0)
	bclr	#2,oFlags(a0)
	move.w	#$A00,oPlayerTopSpeed(a0)
	jsr	ObjSonic_Index(pc,d0.w)
	btst	#3,oFlags(a0)
	bne.s	.CheckRightBound
	btst	#7,oFlags(a0)
	bne.s	.NoStampCol
	btst	#6,oFlags(a0)
	bne.s	.NoStampCol
	tst.b	stageInactive
	bne.s	.NoStampCol
	bsr.w	ObjSonic_GetStamps
	bsr.w	ObjSonic_StampCollide

.NoStampCol:
	btst	#5,oFlags(a0)
	bne.s	.CheckLeftBound
	bsr.w	ObjSonic_MoveDown

.CheckLeftBound:
	cmpi.w	#$340,oX(a0)
	bcc.s	.CheckRightBound
	move.w	#$340,oX(a0)

.CheckRightBound:
	cmpi.w	#$CC0,oX(a0)
	bcs.s	.CheckTopBound
	move.w	#$CC0,oX(a0)

.CheckTopBound:
	cmpi.w	#$340,oY(a0)
	bcc.s	.CheckBottomBound
	move.w	#$340,oY(a0)

.CheckBottomBound:
	cmpi.w	#$CC0,oY(a0)
	bcs.s	.SetPosition
	move.w	#$CC0,oY(a0)

.SetPosition:
	lea	gfxVars,a1
	move.w	oX(a0),gfxCamX(a1)
	move.w	oY(a0),gfxCamY(a1)
	move.w	oZ(a0),gfxCamZ(a1)
	move.w	oPlayerPitch(a0),gfxPitch(a1)
	move.w	oPlayerYaw(a0),gfxYaw(a1)
	cmpi.b	#7,oRoutine(a0)
	beq.s	.Draw
	cmpi.b	#$13,oRoutine(a0)
	beq.s	.Draw
	bsr.w	ObjSonic_Tilt
	bsr.w	ObjSonic_Animate

.Draw:
	bsr.w	DrawObject
	bsr.w	ObjSonic_LoadArt
	move.b	#0,oPlayerUFOCol(a0)
	rts

; -------------------------------------------------------------------------

ObjSonic_Init:
	move.w	#$85E0,oTile(a0)
	move.l	#Spr_Sonic,oSprites(a0)
	move.w	#$100,oSprX(a0)
	move.w	#$158,oSprY(a0)
	moveq	#9,d0
	bsr.w	SetObjSprite
	move.b	#$14,oRoutine(a0)
	move.w	#0,oPlayerSpeed(a0)
	bsr.w	ObjSonic_GetStartPos
	move.w	#$160,oZ(a0)
	move.w	#$80,oTimer(a0)

; -------------------------------------------------------------------------

ObjSonic_Start1:
	rts

; -------------------------------------------------------------------------

ObjSonic_Start2:
	moveq	#$2C,d0
	bsr.w	SetObjSprite
	move.b	#$16,oRoutine(a0)
	move.b	#5,oPlayerTimer(a0)
	rts

; -------------------------------------------------------------------------

ObjSonic_Start3:
	subq.b	#1,oPlayerTimer(a0)
	bne.s	.End
	moveq	#$A,d0
	bsr.w	SetObjSprite
	move.b	#$17,oRoutine(a0)

.End:
	rts

; -------------------------------------------------------------------------

ObjSonic_Start4:
	rts

; -------------------------------------------------------------------------

ObjSonic_Normal:
	bsr.w	ObjSonic_Rotate
	bsr.w	ObjSonic_CheckJump
	bsr.w	ObjSonic_CheckWin
	rts

; -------------------------------------------------------------------------

ObjSonic_Jump:
	move.l	oSprY(a0),d0
	add.l	oPlayerSprYVel(a0),d0
	move.l	d0,oSprY(a0)
	if REGION<>EUROPE
		addi.l	#$A000,oPlayerSprYVel(a0)
	else
		addi.l	#$C000,oPlayerSprYVel(a0)
	endif
	tst.w	(jumpTimer).l
	beq.s	.CheckLand
	if REGION<>EUROPE
		addi.l	#$A000,oPlayerSprYVel(a0)
	else
		addi.l	#$C000,oPlayerSprYVel(a0)
	endif
	subq.w	#1,(jumpTimer).l
	move.b	(playerCtrlData).l,d0
	andi.b	#$70,d0
	beq.s	.CheckLand
	if REGION<>EUROPE
		subi.l	#$A000,oPlayerSprYVel(a0)
	else
		subi.l	#$C000,oPlayerSprYVel(a0)
	endif

.CheckLand:
	cmpi.w	#$158,oSprY(a0)
	bcs.s	.NotLanded
	move.b	#1,oRoutine(a0)
	move.l	#$1580000,oSprY(a0)
	move.l	#0,oPlayerSprYVel(a0)
	bclr	#7,oFlags(a0)
	move.w	#$160,oZ(a0)

.NotLanded:
	bsr.w	ObjSonic_Rotate
	move.w	#$158,d0
	sub.w	oSprY(a0),d0
	lsl.w	#2,d0
	addi.w	#$160,d0
	move.w	d0,oZ(a0)
	rts

; -------------------------------------------------------------------------

ObjSonic_Float:
	move.l	oSprY(a0),d0
	add.l	oPlayerSprYVel(a0),d0
	move.l	d0,oSprY(a0)
	if REGION<>EUROPE
		addi.l	#$2000,oPlayerSprYVel(a0)
	else
		addi.l	#$2666,oPlayerSprYVel(a0)
	endif
	cmpi.w	#$158,oSprY(a0)
	bcs.s	.NotLanded
	move.b	#1,oRoutine(a0)
	move.l	#$1580000,oSprY(a0)
	move.l	#0,oPlayerSprYVel(a0)
	bclr	#6,oFlags(a0)
	move.w	#$160,oZ(a0)

.NotLanded:
	bsr.w	ObjSonic_Rotate
	move.w	#$158,d0
	sub.w	oSprY(a0),d0
	lsl.w	#2,d0
	addi.w	#$160,d0
	move.w	d0,oZ(a0)
	rts

; -------------------------------------------------------------------------

ObjSonic_Bumped:
	subq.w	#1,oVar16(a0)
	bne.s	loc_132DC
	move.b	#1,oRoutine(a0)
	move.l	#0,oXVel(a0)
	move.l	#0,oYVel(a0)
	bra.s	loc_132EC
; -------------------------------------------------------------------------

loc_132DC:
	move.l	oXVel(a0),d0
	add.l	d0,oX(a0)
	move.l	oYVel(a0),d0
	add.l	d0,oY(a0)

loc_132EC:
	bsr.w	ObjSonic_Rotate
	bsr.w	ObjSonic_CheckJump
	bsr.w	ObjSonic_CheckWin
	rts

; -------------------------------------------------------------------------

ObjSonic_Unk:
	addq.w	#4,oSprY(a0)
	cmpi.w	#$1C0,oSprY(a0)
	bcs.s	.End
	move.b	#6,oRoutine(a0)

.End:
	rts

; -------------------------------------------------------------------------

ObjSonic_Unk2:
	rts

; -------------------------------------------------------------------------

ObjSonic_Hurt:
	subq.b	#1,oPlayerTimer(a0)
	bne.s	.End
	move.b	#1,oRoutine(a0)
	moveq	#0,d0
	bsr.w	SetObjSprite

.End:
	rts

; -------------------------------------------------------------------------

ObjSonic_GotTimeStone1:
	cmpi.w	#$158,oSprY(a0)
	bcs.s	loc_1334E
	move.b	#60,oPlayerTimer(a0)
	moveq	#$A,d0
	bsr.w	SetObjSprite
	move.b	#9,oRoutine(a0)
	move.b	#1,stageInactive
	move.w	#0,oPlayerSpeed(a0)
	rts
	
; -------------------------------------------------------------------------

loc_1334E:
	bsr.w	ObjSonic_Rotate
	bsr.w	ObjSonic_CheckJump
	rts

; -------------------------------------------------------------------------

ObjSonic_GotTimeStone2:
	subq.b	#1,oPlayerTimer(a0)
	bne.s	.End
	move.b	#$E,(timeStoneObject+oID).l
	move.b	#$F,(sparkleObject1+oID).l
	move.b	#$10,(sparkleObject2+oID).l
	move.b	#$A,oRoutine(a0)
	move.b	#6,oPlayerTimer(a0)

.End:
	rts

; -------------------------------------------------------------------------

ObjSonic_GotTimeStone3:
	bset	#2,(subScrollFlags).l
	subq.w	#8,oPlayerYaw(a0)
	andi.w	#$1FF,oPlayerYaw(a0)
	subq.b	#1,oPlayerTimer(a0)
	bne.s	.End
	move.b	#$B,oRoutine(a0)
	move.b	#4,oPlayerTimer(a0)
	moveq	#$24,d0
	bsr.w	SetObjSprite

.End:
	rts

; -------------------------------------------------------------------------

ObjSonic_GotTimeStone4:
	bset	#2,(subScrollFlags).l
	subq.w	#8,oPlayerYaw(a0)
	andi.w	#$1FF,oPlayerYaw(a0)
	subq.b	#1,oPlayerTimer(a0)
	bne.s	.End
	move.b	#$C,oRoutine(a0)
	move.b	#5,oPlayerTimer(a0)
	moveq	#$25,d0
	bsr.w	SetObjSprite

.End:
	rts

; -------------------------------------------------------------------------

ObjSonic_GotTimeStone5:
	bset	#2,(subScrollFlags).l
	subq.w	#8,oPlayerYaw(a0)
	andi.w	#$1FF,oPlayerYaw(a0)
	subq.b	#1,oPlayerTimer(a0)
	bne.s	.End
	move.b	#$D,oRoutine(a0)
	move.b	#4,oPlayerTimer(a0)
	moveq	#$26,d0
	bsr.w	SetObjSprite

.End:
	rts

; -------------------------------------------------------------------------

ObjSonic_GotTimeStone6:
	bset	#2,(subScrollFlags).l
	subq.w	#8,oPlayerYaw(a0)
	andi.w	#$1FF,oPlayerYaw(a0)
	subq.b	#1,oPlayerTimer(a0)
	bne.s	.End
	move.b	#$E,oRoutine(a0)
	move.b	#5,oPlayerTimer(a0)
	moveq	#$27,d0
	bsr.w	SetObjSprite

.End:
	rts

; -------------------------------------------------------------------------

ObjSonic_GotTimeStone7:
	bset	#2,(subScrollFlags).l
	subq.w	#8,oPlayerYaw(a0)
	andi.w	#$1FF,oPlayerYaw(a0)
	subq.b	#1,oPlayerTimer(a0)
	bne.s	.End
	move.b	#$F,oRoutine(a0)
	move.b	#4,oPlayerTimer(a0)
	moveq	#$28,d0
	bsr.w	SetObjSprite

.End:
	rts

; -------------------------------------------------------------------------

ObjSonic_GotTimeStone8:
	bset	#2,(subScrollFlags).l
	subq.w	#8,oPlayerYaw(a0)
	andi.w	#$1FF,oPlayerYaw(a0)
	subq.b	#1,oPlayerTimer(a0)
	bne.s	.End
	move.b	#$10,oRoutine(a0)
	move.b	#5,oPlayerTimer(a0)
	moveq	#$29,d0
	bsr.w	SetObjSprite

.End:
	rts

; -------------------------------------------------------------------------

ObjSonic_GotTimeStone9:
	bset	#2,(subScrollFlags).l
	subq.w	#8,oPlayerYaw(a0)
	andi.w	#$1FF,oPlayerYaw(a0)
	subq.b	#1,oPlayerTimer(a0)
	bne.s	ObjSonic_GotTimeStone10
	move.b	#$11,oRoutine(a0)
	moveq	#$2A,d0
	bsr.w	SetObjSprite

; -------------------------------------------------------------------------

ObjSonic_GotTimeStone10:

	rts

; -------------------------------------------------------------------------

ObjSonic_GotTimeStone11:
	moveq	#$2B,d0
	bsr.w	SetObjSprite
	rts

; -------------------------------------------------------------------------

ObjSonic_Boosted:
	subq.w	#1,oVar16(a0)
	bne.s	.Move
	move.b	#1,oRoutine(a0)
	move.l	#0,oXVel(a0)
	move.l	#0,oYVel(a0)
	moveq	#0,d0
	bsr.w	SetObjSprite
	bra.s	.Done
; -------------------------------------------------------------------------

.Move:
	move.l	oXVel(a0),d0
	add.l	d0,oX(a0)
	move.l	oYVel(a0),d0
	add.l	d0,oY(a0)

.Done:
	bsr.w	ObjSonic_Rotate
	bsr.w	ObjSonic_CheckJump
	rts

; -------------------------------------------------------------------------

ObjSonic_GetStartPos:
	moveq	#0,d0
	move.b	specStageID.w,d0
	mulu.w	#6,d0
	move.w	ObjSonic_StartPos(pc,d0.w),oX(a0)
	move.w	ObjSonic_StartPos+2(pc,d0.w),oY(a0)
	move.w	ObjSonic_StartPos+4(pc,d0.w),oPlayerYaw(a0)
	rts

; -------------------------------------------------------------------------
ObjSonic_StartPos:
	dc.w	$540, $520, $80
	dc.w	$500, $500, $80
	dc.w	$500, $500, $80
	dc.w	$500, $500, $80
	dc.w	$500, $500, $80
	dc.w	$4C0, $4C0, $80
	dc.w	$500, $500, $80
	dc.w	$400, $480, $80

; -------------------------------------------------------------------------

ObjSonic_CheckWin:
	tst.b	ufoCount.w
	bne.s	.End
	move.b	#8,(sonicObject+oRoutine).l
	lea	(timeUFOObject).l,a6
	bsr.s	.DeleteUFO
	lea	(timeUFOShadObj).l,a6

; -------------------------------------------------------------------------

.DeleteUFO:
	tst.b	(a6)
	beq.s	.End
	bset	#0,oFlags(a6)

.End:
	rts

; -------------------------------------------------------------------------

ObjSonic_StampCollide:
	bsr.w	ObjSonic_CheckBumper
	tst.b	ufoCount.w
	beq.s	ObjSonic_TouchPath
	move.b	oPlayerStampC(a0),d0
	cmpi.b	#$A,d0
	bcs.s	.Handle
	moveq	#0,d0

.Handle:
	ext.w	d0
	add.w	d0,d0
	move.w	off_13590(pc,d0.w),d0
	jmp	off_13590(pc,d0.w)
; -------------------------------------------------------------------------
off_13590:
	dc.w	ObjSonic_TouchPath-off_13590
	dc.w	ObjSonic_TouchPath-off_13590
	dc.w	ObjSonic_TouchFan-off_13590
	dc.w	ObjSonic_TouchWater-off_13590
	dc.w	ObjSonic_TouchRough-off_13590
	dc.w	ObjSonic_TouchSpring-off_13590
	dc.w	ObjSonic_TouchHazard-off_13590
	dc.w	ObjSonic_TouchBigBooster-off_13590
	dc.w	ObjSonic_TouchSmallBooster-off_13590
	dc.w	ObjSonic_TouchPath-off_13590
; -------------------------------------------------------------------------

ObjSonic_TouchPath:

	rts

; -------------------------------------------------------------------------

ObjSonic_TouchFan:
	move.b	#3,oRoutine(a0)
	if REGION<>EUROPE
		move.l	#-$40000,oPlayerSprYVel(a0)
	else
		move.l	#-$48000,oPlayerSprYVel(a0)
	endif
	bset	#6,oFlags(a0)
	move.b	#$B8,d0
	bsr.w	PlayFMSound
	bsr.w	DeleteSplash
	rts

; -------------------------------------------------------------------------

ObjSonic_TouchWater:
	tst.b	timeStopped
	bne.s	.End
	move.b	#8,(splashObject+oID).l
	btst	#1,specStageFlags.w
	beq.s	.End
	move.w	#$500,oPlayerTopSpeed(a0)

.End:
	rts

; -------------------------------------------------------------------------

ObjSonic_TouchRough:
	if REGION<>EUROPE
		move.w	#$500,oPlayerTopSpeed(a0)
	else
		move.w	#$600,oPlayerTopSpeed(a0)
	endif
	cmpi.w	#$100,oPlayerSpeed(a0)
	bcs.s	.End
	bsr.w	FindDustObjSlot
	bne.s	.PlaySound
	move.b	#7,(a1)

.PlaySound:
	move.b	#$D6,d0
	bsr.w	PlayFMSound

.End:
	rts

; -------------------------------------------------------------------------

ObjSonic_TouchSpring:
	move.b	#2,oRoutine(a0)
	if REGION<>EUROPE
		move.l	#-$100000,oPlayerSprYVel(a0)
	else
		move.l	#-$120000,oPlayerSprYVel(a0)
	endif
	bset	#7,oFlags(a0)
	move.b	#$98,d0
	bsr.w	PlayFMSound
	bsr.w	DeleteSplash
	rts

; -------------------------------------------------------------------------

ObjSonic_TouchHazard:
	cmpi.b	#4,oRoutine(a0)
	beq.w	.End
	cmpi.b	#7,oRoutine(a0)
	beq.w	.End
	move.b	#$2E,oPlayerTimer(a0)
	move.b	#7,oRoutine(a0)
	moveq	#$D,d0
	bsr.w	SetObjSprite
	move.w	specStageRings.w,d0
	move.w	d0,d1
	lsr.w	#1,d0
	move.w	d0,specStageRings.w
	sub.w	d0,d1
	tst.w	d1
	beq.s	.End
	cmpi.w	#1,d1
	beq.s	.Lose1Ring
	cmpi.w	#2,d1
	beq.s	.Lose2Rings
	cmpi.w	#3,d1
	beq.s	.Lose3Rings
	cmpi.w	#4,d1
	beq.s	.Lose4Rings
	cmpi.w	#5,d1
	beq.s	.Lose5Rings
	cmpi.w	#6,d1
	beq.s	.Lose6Rings
	
.Lose7Rings:
	move.b	#$D,(ringObject1+oID).l

.Lose6Rings:
	move.b	#$D,(ringObject2+oID).l

.Lose5Rings:
	move.b	#$D,(ringObject3+oID).l

.Lose4Rings:
	move.b	#$D,(ringObject4+oID).l

.Lose3Rings:
	move.b	#$D,(ringObject5+oID).l

.Lose2Rings:
	move.b	#$D,(ringObject6+oID).l

.Lose1Ring:
	move.b	#$D,(ringObject7+oID).l

.End:
	rts

; -------------------------------------------------------------------------

ObjSonic_TouchBigBooster:
	move.b	#$CE,d0
	bsr.w	PlayFMSound
	moveq	#$E,d0
	bsr.w	SetObjSprite
	moveq	#0,d0
	move.b	oPlayerStampOri(a0),d0
	andi.w	#$E,d0
	move.w	off_136E2(pc,d0.w),d0
	jmp	off_136E2(pc,d0.w)

; -------------------------------------------------------------------------
off_136E2:
	dc.w	ObjSonic_BigBoostUp-off_136E2
	dc.w	ObjSonic_BigBoostLeft-off_136E2
	dc.w	ObjSonic_BigBoostDown-off_136E2
	dc.w	ObjSonic_BigBoostRight-off_136E2
	dc.w	ObjSonic_BigBoostUp-off_136E2
	dc.w	ObjSonic_BigBoostRight-off_136E2
	dc.w	ObjSonic_BigBoostDown-off_136E2
	dc.w	ObjSonic_BigBoostLeft-off_136E2

; -------------------------------------------------------------------------

ObjSonic_BigBoostUp:
	moveq	#0,d0
	move.w	#-$18,d1
	bra.s	ObjSonic_BigBoost

; -------------------------------------------------------------------------

ObjSonic_BigBoostLeft:
	move.w	#-$18,d0
	moveq	#0,d1
	bra.s	ObjSonic_BigBoost

; -------------------------------------------------------------------------

ObjSonic_BigBoostDown:
	moveq	#0,d0
	moveq	#$18,d1
	bra.s	ObjSonic_BigBoost

; -------------------------------------------------------------------------

ObjSonic_BigBoostRight:
	moveq	#$18,d0
	moveq	#0,d1

; -------------------------------------------------------------------------

ObjSonic_BigBoost:
	move.w	d0,oXVel(a0)
	move.w	d1,oYVel(a0)
	move.w	#$14,oVar16(a0)
	move.b	#$13,oRoutine(a0)
	rts

; -------------------------------------------------------------------------

ObjSonic_TouchSmallBooster:
	move.b	#$C3,d0
	bsr.w	PlayFMSound
	moveq	#0,d0
	move.b	oPlayerStampOri(a0),d0
	andi.w	#$E,d0
	move.w	off_1373C(pc,d0.w),d0
	jmp	off_1373C(pc,d0.w)

; -------------------------------------------------------------------------
off_1373C:
	dc.w	ObjSonic_SmallBoostUp-off_1373C
	dc.w	ObjSonic_SmallBoostLeft-off_1373C
	dc.w	ObjSonic_SmallBoostDown-off_1373C
	dc.w	ObjSonic_SmallBoostRight-off_1373C
	dc.w	ObjSonic_SmallBoostUp-off_1373C
	dc.w	ObjSonic_SmallBoostRight-off_1373C
	dc.w	ObjSonic_SmallBoostDown-off_1373C
	dc.w	ObjSonic_SmallBoostLeft-off_1373C

; -------------------------------------------------------------------------

ObjSonic_SmallBoostUp:
	moveq	#0,d0
	move.w	#-$10,d1
	bra.s	ObjSonic_SmallBoost

; -------------------------------------------------------------------------

ObjSonic_SmallBoostLeft:
	move.w	#-$10,d0
	moveq	#0,d1
	bra.s	ObjSonic_SmallBoost

; -------------------------------------------------------------------------

ObjSonic_SmallBoostDown:
	moveq	#0,d0
	moveq	#$10,d1
	bra.s	ObjSonic_SmallBoost

; -------------------------------------------------------------------------

ObjSonic_SmallBoostRight:
	moveq	#$10,d0
	moveq	#0,d1

; -------------------------------------------------------------------------

ObjSonic_SmallBoost:
	move.w	d0,oXVel(a0)
	move.w	d1,oYVel(a0)
	move.w	#8,oVar16(a0)
	move.b	#4,oRoutine(a0)
	rts

; -------------------------------------------------------------------------

ObjSonic_CheckBumper:
	moveq	#0,d1
	move.w	oPlayerSpeed(a0),d1
	lsl.l	#8,d1
	addi.l	#$20000,d1
	move.l	d1,d2
	neg.l	d2
	moveq	#0,d3
	moveq	#0,d0
	cmpi.b	#1,oPlayerStampTL(a0)
	bne.s	.CheckTopRight
	bset	#0,d0

.CheckTopRight:
	cmpi.b	#1,oPlayerStampTR(a0)
	bne.s	.CheckBottomRight
	bset	#1,d0

.CheckBottomRight:
	cmpi.b	#1,oPlayerStampBR(a0)
	bne.s	.CheckBottomLeft
	bset	#2,d0

.CheckBottomLeft:
	cmpi.b	#1,oPlayerStampBL(a0)
	bne.s	.Handle
	bset	#3,d0

.Handle:
	add.w	d0,d0
	move.w	off_137CC(pc,d0.w),d0
	jmp	off_137CC(pc,d0.w)

; -------------------------------------------------------------------------
off_137CC:
	dc.w	ObjSonic_BumpEnd-off_137CC
	dc.w	ObjSonic_BumpDownRight-off_137CC
	dc.w	ObjSonic_BumpDownLeft-off_137CC
	dc.w	ObjSonic_BumpDown-off_137CC
	dc.w	ObjSonic_BumpUpLeft-off_137CC
	dc.w	ObjSonic_BumpUpRight-off_137CC
	dc.w	ObjSonic_BumpLeft-off_137CC
	dc.w	ObjSonic_BumpDownLeft-off_137CC
	dc.w	ObjSonic_BumpUpRight-off_137CC
	dc.w	ObjSonic_BumpRight-off_137CC
	dc.w	ObjSonic_BumpUpLeft-off_137CC
	dc.w	ObjSonic_BumpDownRight-off_137CC
	dc.w	ObjSonic_BumpUp-off_137CC
	dc.w	ObjSonic_BumpUpRight-off_137CC
	dc.w	ObjSonic_BumpUpLeft-off_137CC
	dc.w	ObjSonic_BumpUpLeft-off_137CC

; -------------------------------------------------------------------------

ObjSonic_BumpDownRight:
	move.l	d1,oXVel(a0)
	move.l	d1,oYVel(a0)
	bra.s	ObjSonic_Bump

; -------------------------------------------------------------------------

ObjSonic_BumpDownLeft:
	move.l	d2,oXVel(a0)
	move.l	d1,oYVel(a0)
	bra.s	ObjSonic_Bump

; -------------------------------------------------------------------------

ObjSonic_BumpDown:
	move.l	d3,oXVel(a0)
	move.l	d1,oYVel(a0)
	bra.s	ObjSonic_Bump

; -------------------------------------------------------------------------

ObjSonic_BumpUpLeft:
	move.l	d2,oXVel(a0)
	move.l	d2,oYVel(a0)
	bra.s	ObjSonic_Bump

; -------------------------------------------------------------------------

ObjSonic_BumpUpRight:
	move.l	d1,oXVel(a0)
	move.l	d2,oYVel(a0)
	bra.s	ObjSonic_Bump

; -------------------------------------------------------------------------

ObjSonic_BumpLeft:
	move.l	d2,oXVel(a0)
	move.l	d3,oYVel(a0)
	bra.s	ObjSonic_Bump

; -------------------------------------------------------------------------

ObjSonic_BumpRight:
	move.l	d1,oXVel(a0)
	move.l	d3,oYVel(a0)
	bra.s	ObjSonic_Bump

; -------------------------------------------------------------------------

ObjSonic_BumpUp:
	move.l	d3,oXVel(a0)
	move.l	d2,oYVel(a0)

; -------------------------------------------------------------------------

ObjSonic_Bump:
	move.w	#$10,oVar16(a0)
	move.b	#4,oRoutine(a0)
	bset	#5,oFlags(a0)
	move.b	#$B5,d0
	bsr.w	PlayFMSound
	moveq	#0,d0
	bsr.w	SetObjSprite

ObjSonic_BumpEnd:
	rts

; -------------------------------------------------------------------------

FindDustObjSlot:
	lea	dustObject1,a1
	moveq	#7,d7

.Find:
	tst.w	(a1)
	beq.s	.End
	adda.w	#$80,a1
	dbf	d7,.Find

.End:
	rts

; -------------------------------------------------------------------------

ObjSonic_CheckJump:
	tst.b	stageInactive
	bne.s	.End
	move.b	(playerCtrlData+1).l,d0
	andi.b	#$70,d0
	beq.s	.End
	move.b	#2,oRoutine(a0)
	if REGION<>EUROPE
		move.l	#-$80000,oPlayerSprYVel(a0)
	else
		move.l	#-$90000,oPlayerSprYVel(a0)
	endif
	move.w	#$14,(jumpTimer).l
	bset	#7,oFlags(a0)
	move.w	#0,oVar16(a0)
	move.b	#$92,d0
	bsr.w	PlayFMSound
	bsr.w	DeleteSplash

.End:
	rts

; -------------------------------------------------------------------------

ObjSonic_Rotate:
	tst.b	stageInactive
	bne.s	.End
	if REGION<>EUROPE
		move.l	#$60000,d0
	else
		move.l	#$73333,d0
	endif
	btst	#3,(playerCtrlData).l
	beq.s	.CheckLeft
	sub.l	d0,oPlayerYaw(a0)
	andi.l	#$1FFFFFF,oPlayerYaw(a0)
	bset	#3,(subScrollFlags).l

.CheckLeft:
	btst	#2,(playerCtrlData).l
	beq.s	.End
	add.l	d0,oPlayerYaw(a0)
	andi.l	#$1FFFFFF,oPlayerYaw(a0)
	bset	#2,(subScrollFlags).l

.End:
	rts

; -------------------------------------------------------------------------

ObjSonic_RotateSlow:
	if REGION<>EUROPE
		move.l	#$40000,d0
	else
		move.l	#$4CCCC,d0
	endif
	btst	#3,(playerCtrlData).l
	beq.s	.CheckLeft
	sub.l	d0,oPlayerYaw(a0)
	andi.l	#$1FFFFFF,oPlayerYaw(a0)
	bset	#3,(subScrollFlags).l

.CheckLeft:
	btst	#2,(playerCtrlData).l
	beq.s	.End
	add.l	d0,oPlayerYaw(a0)
	andi.l	#$1FFFFFF,oPlayerYaw(a0)
	bset	#2,(subScrollFlags).l

.End:
	rts

; -------------------------------------------------------------------------

ObjSonic_HandleSpeed:
	tst.b	stageInactive
	bne.s	.End
	move.b	(playerCtrlData).l,d1
	andi.b	#$F,d1
	cmpi.b	#2,d1
	beq.s	.Decelerate
	tst.w	oPlayerShoes(a0)
	beq.s	.NoSpeedShoes
	subq.w	#1,oPlayerShoes(a0)
	if REGION<>EUROPE
		move.w	#$E00,d7
	else
		move.w	#$10CC,d7
	endif
	bra.s	.Accelerate
; -------------------------------------------------------------------------

.NoSpeedShoes:
	cmpi.b	#7,oRoutine(a0)
	bne.s	.NotHurt
	if REGION<>EUROPE
		move.w	#$200,d7
	else
		move.w	#$266,d7
	endif
	bra.s	.Accelerate
; -------------------------------------------------------------------------

.NotHurt:
	move.w	oPlayerTopSpeed(a0),d7

.Accelerate:
	if REGION<>EUROPE
		addi.w	#$20,oPlayerSpeed(a0)
	else
		addi.w	#$26,oPlayerSpeed(a0)
	endif
	cmp.w	oPlayerSpeed(a0),d7
	bcc.s	.End
	move.w	d7,oPlayerSpeed(a0)
	rts
	
; -------------------------------------------------------------------------

.Decelerate:
	if REGION<>EUROPE
		subi.w	#$40,oPlayerSpeed(a0)
	else
		subi.w	#$4C,oPlayerSpeed(a0)
	endif
	cmpi.w	#$200,oPlayerSpeed(a0)
	bge.s	.End
	move.w	#$200,oPlayerSpeed(a0)

.End:
	rts

; -------------------------------------------------------------------------

ObjSonic_MoveDown:
	move.w	oPlayerYaw(a0),d0
	addi.w	#$180,d0
	andi.w	#$1FF,d0
	move.w	d0,d3
	bsr.w	GetCosine
	if REGION<>EUROPE
		muls.w	oPlayerSpeed(a0),d3
	else
		move.w	oPlayerSpeed(a0),d5
		muls.w	#60,d5
		divs.w	#50,d5
		muls.w	d5,d3
	endif
	add.l	d3,oX(a0)
	andi.l	#$FFFFFFF,oX(a0)
	move.w	d0,d3
	bsr.w	GetSine
	if REGION<>EUROPE
		muls.w	oPlayerSpeed(a0),d3
	else
		muls.w	d5,d3
	endif
	add.l	d3,oY(a0)
	andi.l	#$FFFFFFF,oY(a0)
	rts

; -------------------------------------------------------------------------

ObjSonic_MoveUp:
	move.w	oPlayerYaw(a0),d0
	addi.w	#$80,d0
	andi.w	#$1FF,d0
	bra.s	ObjSonic_Move

; -------------------------------------------------------------------------

ObjSonic_MoveRight:
	move.w	oPlayerYaw(a0),d0
	addi.w	#0,d0
	andi.w	#$1FF,d0
	bra.s	ObjSonic_Move

; -------------------------------------------------------------------------

ObjSonic_MoveLeft:
	move.w	oPlayerYaw(a0),d0
	addi.w	#$100,d0
	andi.w	#$1FF,d0

; -------------------------------------------------------------------------

ObjSonic_Move:
	move.w	d0,d3
	bsr.w	GetCosine
	if REGION<>EUROPE
		muls.w	oVar16(a0),d3
	else
		move.w	oVar16(a0),d5
		muls.w	#60,d5
		divs.w	#50,d5
		muls.w	d5,d3
	endif
	add.l	d3,oX(a0)
	andi.l	#$FFFFFFF,oX(a0)
	move.w	d0,d3
	bsr.w	GetSine
	if REGION<>EUROPE
		muls.w	oVar16(a0),d3
	else
		muls.w	d5,d3
	endif
	add.l	d3,oY(a0)
	andi.l	#$FFFFFFF,oY(a0)
	rts

; -------------------------------------------------------------------------

ObjSonic_Tilt:
	btst	#2,(playerCtrlData).l
	beq.s	.CheckRight
	subq.b	#1,oPlayerTilt(a0)
	bpl.s	.EndLeft
	move.b	#0,oPlayerTilt(a0)

.EndLeft:
	rts
	
; -------------------------------------------------------------------------

.CheckRight:
	btst	#3,(playerCtrlData).l
	beq.s	.Untilt
	addq.b	#1,oPlayerTilt(a0)
	cmpi.b	#$A,oPlayerTilt(a0)
	bcs.s	.EndRight
	move.b	#9,oPlayerTilt(a0)

.EndRight:
	rts
	
; -------------------------------------------------------------------------

.Untilt:
	cmpi.b	#5,oPlayerTilt(a0)
	bcs.s	.UntiltLeft

.UntiltRight:
	subq.b	#1,oPlayerTilt(a0)
	cmpi.b	#5,oPlayerTilt(a0)
	bcc.s	.UntiltLeft
	move.b	#5,oPlayerTilt(a0)
	rts
	
; -------------------------------------------------------------------------

.UntiltLeft:
	addq.b	#1,oPlayerTilt(a0)
	cmpi.b	#5,oPlayerTilt(a0)
	bls.s	.UntiltLeft
	move.b	#5,oPlayerTilt(a0)
	rts

; -------------------------------------------------------------------------

ObjSonic_Animate:
	tst.b	stageInactive
	bne.w	.End
	moveq	#6,d0
	btst	#7,oFlags(a0)
	bne.s	.OtherAnim
	moveq	#$B,d0
	btst	#6,oFlags(a0)
	bne.s	.OtherAnim
	moveq	#$A,d0
	move.w	oPlayerSpeed(a0),d1
	beq.s	.OtherAnim
	move.b	oPlayerTilt(a0),d2
	add.w	d2,d2
	andi.w	#$1C,d2
	move.b	ObjSonic_Animations+3(pc,d2.w),d0
	cmpi.w	#$300,d1
	bcs.s	.GroundMoveAnim
	move.b	ObjSonic_Animations+2(pc,d2.w),d0
	cmpi.w	#$540,d1
	bcs.s	.GroundMoveAnim
	move.b	ObjSonic_Animations+1(pc,d2.w),d0
	cmpi.w	#$780,d1
	bcs.s	.GroundMoveAnim
	move.b	ObjSonic_Animations(pc,d2.w),d0
	cmpi.w	#$B00,d1
	bcs.s	.GroundMoveAnim
	move.b	#1,d0
	bra.s	.CheckAnimReset

.OtherAnim:
	bclr	#4,oFlags(a0)

.CheckAnimReset:
	cmp.b	oSprite(a0),d0
	beq.s	.End
	bsr.w	SetObjSprite
	rts
	
.GroundMoveAnim:
	bset	#4,oFlags(a0)
	beq.s	.CheckAnimReset
	cmp.b	oSprite(a0),d0
	beq.s	.End
	bsr.w	ChgObjSprite

.End:
	rts

; -------------------------------------------------------------------------

ObjSonic_Animations:
	dc.b	4, $19, $1A, $1B
	dc.b	3, $16, $17, $18
	dc.b	0, $10, $11, $12
	dc.b	2, $13, $14, $15
	dc.b	5, $1C, $1D, $1E

; -------------------------------------------------------------------------

ObjSonic_LoadArt:
	moveq	#0,d0
	move.b	oSpriteFlag(a0),d0
	lea	(SonicArt).l,a1
	add.w	d0,d0
	add.w	d0,d0
	movea.l	(a1,d0.w),a1
	lea	subSonicArtBuf,a2
	move.w	#$17,d7

.Copy:
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	dbf	d7,.Copy
	rts

; -------------------------------------------------------------------------
