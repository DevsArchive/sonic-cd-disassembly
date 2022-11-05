; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Palmtree Panic object collision
; -------------------------------------------------------------------------

Player_ObjCollide:
	nop
	move.w	oX(a0),d2
	move.w	oY(a0),d3
	subq.w	#8,d2
	moveq	#0,d5
	move.b	oYRadius(a0),d5
	subq.b	#3,d5
	sub.w	d5,d3
	cmpi.b	#$39,oMapFrame(a0)
	bne.s	.NoDuck
	addi.w	#$C,d3
	moveq	#$A,d5

.NoDuck:
	move.w	#$10,d4
	add.w	d5,d5
	lea	dynObjects.w,a1
	move.w	#$5F,d6

.Loop:
	tst.b	oSprFlags(a1)
	bpl.s	.Next
	move.b	oColType(a1),d0
	bne.s	.CheckWidth

.Next:
	lea	oSize(a1),a1
	dbf	d6,.Loop
	moveq	#0,d0
	rts

; -------------------------------------------------------------------------

.CheckWidth:
	andi.w	#$3F,d0
	add.w	d0,d0
	lea	ObjColSizes,a2
	lea	-2(a2,d0.w),a2
	moveq	#0,d1
	move.b	(a2)+,d1
	move.w	oX(a1),d0
	sub.w	d1,d0
	sub.w	d2,d0
	bcc.s	.TouchRight
	add.w	d1,d1
	add.w	d1,d0
	bcs.s	.CheckHeight
	bra.w	.Next

; -------------------------------------------------------------------------

.TouchRight:
	cmp.w	d4,d0
	bhi.w	.Next

.CheckHeight:
	moveq	#0,d1
	move.b	(a2)+,d1
	move.w	oY(a1),d0
	sub.w	d1,d0
	sub.w	d3,d0
	bcc.s	.TouchBottom
	add.w	d1,d1
	add.w	d0,d1
	bcs.s	.CheckColType
	bra.w	.Next

; -------------------------------------------------------------------------

.TouchBottom:
	cmp.w	d5,d0
	bhi.w	.Next

.CheckColType:
	move.b	oColType(a1),d1
	andi.b	#$C0,d1
	beq.w	Player_TouchEnemy
	cmpi.b	#$C0,d1
	beq.w	Player_TouchSpecial
	tst.b	d1
	bmi.w	Player_TouchHazard
	move.b	oColType(a1),d0
	andi.b	#$3F,d0
	cmpi.b	#6,d0
	beq.s	Player_TouchMonitor
	cmpi.w	#$5A,oPlayerHurt(a0)
	bcc.w	.End
	addq.b	#2,oRoutine(a1)

.End:
	rts

; -------------------------------------------------------------------------

Player_TouchMonitor:
	tst.w	oYVel(a0)
	bpl.s	.GoingDown
	move.w	oY(a0),d0
	subi.w	#$10,d0
	cmp.w	oY(a1),d0
	bcs.s	.End2
	neg.w	oYVel(a0)
	move.w	#-$180,oYVel(a1)
	tst.b	oMonitorFall(a1)
	bne.s	.End2
	addq.b	#4,oMonitorFall(a1)
	rts

; -------------------------------------------------------------------------

.GoingDown:
	cmpi.b	#2,oAnim(a0)
	bne.s	.End2
	neg.w	oYVel(a0)
	addq.b	#2,oRoutine(a1)

.End2:
	rts
; End of function ObjSonic_ObjCollide

; -------------------------------------------------------------------------

Player_TouchEnemy:
	tst.b	timeWarp
	bne.s	.DamageEnemy
	tst.b	invincible
	bne.s	.DamageEnemy
	cmpi.b	#2,oAnim(a0)
	bne.w	Player_TouchHazard

.DamageEnemy:
	tst.b	oColStatus(a1)
	beq.s	.KillEnemy
	neg.w	oXVel(a0)
	neg.w	oYVel(a0)
	asr	oXVel(a0)
	asr	oYVel(a0)
	move.b	#0,oColType(a1)
	subq.b	#1,oColStatus(a1)
	bne.s	.End
	bset	#7,oFlags(a1)

.End:
	rts

; -------------------------------------------------------------------------

.KillEnemy:
	bset	#7,oFlags(a1)
	moveq	#0,d0
	move.w	scoreChain.w,d0
	addq.w	#2,scoreChain.w
	cmpi.w	#6,d0
	bcs.s	.CappedChain
	moveq	#6,d0

.CappedChain:
	move.w	d0,oVar3E(a1)
	move.w	EnemyPoints(pc,d0.w),d0
	cmpi.w	#$20,scoreChain.w
	bcs.s	.GivePoints
	move.w	#$3E8,d0
	move.w	#$A,oVar3E(a1)

.GivePoints:
	bsr.w	AddPoints
	move.w	#FM_DESTROY,d0
	jsr	PlayFMSound
	move.b	#$18,oID(a1)
	move.b	#0,oRoutine(a1)
	move.b	#1,oSubtype(a1)
	tst.w	oYVel(a0)
	bmi.s	.BounceDown
	move.w	oY(a0),d0
	cmp.w	oY(a1),d0
	bcc.s	.BounceUp
	neg.w	oYVel(a0)
	rts

; -------------------------------------------------------------------------

.BounceDown:
	addi.w	#$100,oYVel(a0)
	rts

; -------------------------------------------------------------------------

.BounceUp:
	subi.w	#$100,oYVel(a0)
	rts

; -------------------------------------------------------------------------
EnemyPoints:
	dc.w	10
	dc.w	20
	dc.w	50
	dc.w	100

; -------------------------------------------------------------------------

Player_TouchHazard2:
	bset	#7,oFlags(a1)

Player_TouchHazard:
	tst.b	timeWarp
	bne.s	.NoHurt
	tst.b	invincible
	beq.s	.ChkHurt

.NoHurt:
	moveq	#-1,d0
	rts

; -------------------------------------------------------------------------

.ChkHurt:
	nop
	tst.w	oPlayerHurt(a0)
	bne.s	.NoHurt
	movea.l	a1,a2

HurtPlayer:
	tst.b	shield
	bne.s	.ClearCharge
	tst.w	rings
	beq.w	.CheckKill
	jsr	FindObjSlot
	bne.s	.ClearCharge
	move.b	#$11,oID(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)

.ClearCharge:
	clr.b	oPlayerCharge(a0)
	bclr	#0,shield
	bne.s	.SetHurt
	move.b	#0,combineRing

.SetHurt:
	move.b	#4,oRoutine(a0)
	bsr.w	Player_ResetOnFloor
	bset	#1,oFlags(a0)
	move.w	#-$400,oYVel(a0)
	move.w	#-$200,oXVel(a0)
	btst	#6,oFlags(a0)
	beq.s	.NoWater
	move.w	#-$200,oYVel(a0)
	move.w	#-$100,oXVel(a0)

.NoWater:
	move.w	oX(a0),d0
	cmp.w	oX(a2),d0
	bcs.s	.GotXVel
	neg.w	oXVel(a0)

.GotXVel:
	move.w	#0,oPlayerGVel(a0)
	move.b	#$1A,oAnim(a0)
	move.w	#$78,oPlayerHurt(a0)
	moveq	#-1,d0
	rts

; -------------------------------------------------------------------------

.CheckKill:
	tst.w	debugCheat
	bne.w	.ClearCharge
; End of function Player_TouchEnemy

; -------------------------------------------------------------------------

KillPlayer:
	tst.w	debugMode
	bne.s	.End
	move.b	#0,invincible
	move.b	#6,oRoutine(a0)
	bsr.w	Player_ResetOnFloor
	bset	#1,oFlags(a0)
	move.w	#-$700,oYVel(a0)
	move.w	#0,oXVel(a0)
	move.w	#0,oPlayerGVel(a0)
	move.w	oY(a0),oPlayerStick(a0)
	move.b	#$18,oAnim(a0)
	bset	#7,oTile(a0)
	move.b	#0,oPriority(a0)
	move.w	#FM_HURT,d0
	jsr	PlayFMSound

.End:
	moveq	#-1,d0
	rts
; End of function KillPlayer
; -------------------------------------------------------------------------

Player_TouchSpecial:
	move.b	oColType(a1),d1
	andi.b	#$3F,d1
	cmpi.b	#$1F,d1
	beq.w	.FlagCollision
	cmpi.b	#$B,d1
	beq.w	.TouchHazard
	cmpi.b	#$C,d1
	beq.w	.TouchMechaBlu
	cmpi.b	#$17,d1
	beq.w	.FlagCollision
	cmpi.b	#$21,d1
	beq.w	.FlagCollision
	cmpi.b	#$23,d1
	beq.w	.FlagCollision
	cmpi.b	#$2F,d1
	beq.w	.CheckIfRoll
	cmpi.b	#$3A,d1
	beq.w	.CheckIfRoll
	cmpi.b	#$3B,d1
	beq.w	.CheckIfRoll
	cmpi.b	#1,bossFight.w
	bne.s	.End3
	cmpi.b	#$3C,d1
	blt.s	.End3
	cmpi.b	#$3F,d1
	bgt.s	.End3
	bsr.w	Player_TouchEnemy
	tst.b	oColType(a1)
	bne.s	.NoResetHits
	addq.b	#3,oColStatus(a1)

.NoResetHits:
	clr.b	oColType(a1)
	bra.w	.FlagCollision

; -------------------------------------------------------------------------

.End3:
	rts

; -------------------------------------------------------------------------

.TouchHazard:
	bra.w	Player_TouchHazard2

; -------------------------------------------------------------------------

.TouchMechaBlu:
	sub.w	d0,d5
	cmpi.w	#8,d5
	bcc.s	.TouchEnemy
	move.w	oX(a1),d0
	subq.w	#4,d0
	btst	#0,oFlags(a1)
	beq.s	.NotFlipped
	subi.w	#$10,d0

.NotFlipped:
	sub.w	d2,d0
	bcc.s	.CheckIfRight
	addi.w	#$18,d0
	bcs.s	.TouchHazard2
	bra.s	.TouchEnemy

; -------------------------------------------------------------------------

.CheckIfRight:
	cmp.w	d4,d0
	bhi.s	.TouchEnemy

.TouchHazard2:
	bra.w	Player_TouchHazard

; -------------------------------------------------------------------------

.TouchEnemy:
	bra.w	Player_TouchEnemy

; -------------------------------------------------------------------------

.FlagCollision:
	addq.b	#1,oColStatus(a1)
	rts

; -------------------------------------------------------------------------

.CheckIfRoll:
	cmpi.b	#2,oAnim(a0)
	bne.s	.End4
	addq.b	#1,oColStatus(a1)

.End4:
	rts

; -------------------------------------------------------------------------
ObjColSizes:
	dc.b	$14, $14
	dc.b	$12, $C
	dc.b	$C, $10
	dc.b	4, $10
	dc.b	$C, $12
	dc.b	$10, $10
	dc.b	6, 6
	dc.b	$18, $C
	dc.b	$C, $10
	dc.b	$10, $C
	dc.b	8, 8
	dc.b	$14, $10
	dc.b	$14, 8
	dc.b	$E, $E
	dc.b	$18, $18
	dc.b	$28, $10
	dc.b	$10, $18
	dc.b	8, $10
	dc.b	$20, $70
	dc.b	$40, $20
	dc.b	$80, $20
	dc.b	$20, $20
	dc.b	8, 8
	dc.b	4, 4
	dc.b	$20, 8
	dc.b	$C, $C
	dc.b	8, 4
	dc.b	$18, 4
	dc.b	$28, 4
	dc.b	4, 8
	dc.b	4, $18
	dc.b	4, $28
	dc.b	4, $20
	dc.b	$18, $18
	dc.b	$C, $18
	dc.b	$48, 8
	dc.b	8, $C
	dc.b	$10, 8
	dc.b	$20, $10
	dc.b	$20, $10
	dc.b	8, $10
	dc.b	$10, $10
	dc.b	$C, $C
	dc.b	$10, $10
	dc.b	4, 4
	dc.b	$10, $10
	dc.b	$16, $1A
	dc.b	0, 0
	dc.b	0, 0
	dc.b	0, 0
	dc.b	0, 0
	dc.b	0, 0
	dc.b	0, 0
	dc.b	0, 0
	dc.b	0, 0
	dc.b	0, 0
	dc.b	0, 0
	dc.b	$28, $24
	dc.b	$12, $11
	dc.b	$20, $18
	dc.b	$C, $14
	dc.b	$20, $C
	dc.b	$C, $10

; -------------------------------------------------------------------------
