; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Results object
; -------------------------------------------------------------------------

ObjResults:
	moveq	#0,d0
	move.b	$24(a0),d0
	move.w	ObjResults_Index(pc,d0.w),d0
	jmp	ObjResults_Index(pc,d0.w)
; End of function ObjResults

; -------------------------------------------------------------------------
ObjResults_Index:dc.w	ObjResults_Init-ObjResults_Index
	dc.w	ObjResults_WaitPLC-ObjResults_Index
	dc.w	ObjResults_MoveToDest-ObjResults_Index
	dc.w	ObjResults_BonusCountdown-ObjResults_Index
	dc.w	ObjResults_NextLevel-ObjResults_Index
; -------------------------------------------------------------------------

ObjResults_Init:
	subq.b	#1,oVar32(a0)
	beq.s	.LoadPLC
	rts

; -------------------------------------------------------------------------

.LoadPLC:
	moveq	#$10,d0
	jsr	LoadPLC
	addq.b	#2,oRoutine(a0)
; End of function ObjResults_Init

; -------------------------------------------------------------------------

ObjResults_WaitPLC:
	tst.l	plcBuffer.w
	bne.s	.End
	cmpi.w	#$502,levelZone
	beq.s	.LoadResults
	lea	objPlayerSlot.w,a6
	move.w	cameraX.w,d0
	addi.w	#$150,d0
	cmp.w	oX(a6),d0
	bcs.s	.LoadResults

.End:
	rts

; -------------------------------------------------------------------------

.LoadResults:
	lea	ObjResults_Data,a2
	moveq	#2,d6
	moveq	#0,d1
	movea.l	a0,a1
	if REGION=USA
		move.w	#$1E0,oVar32(a0)
	else
		move.w	#$168,oVar32(a0)
	endif
	bra.s	.InitLoop

; -------------------------------------------------------------------------

.Loop:
	jsr	FindObjSlot

.InitLoop:
	if REGION=USA
		move.w	#$1E0,oVar32(a1)
	else
		move.w	#$168,oVar32(a1)
	endif
	move.b	#$3A,oID(a1)
	move.b	#4,oRoutine(a1)
	move.w	#$83C4,oTile(a1)
	cmpi.w	#$502,levelZone
	bne.s	.NotSSZ3
	move.w	#$82F2,oTile(a1)
	move.l	#MapSpr_Results2,oMap(a1)
	tst.b	goodFuture
	beq.s	.GotMaps
	move.l	#MapSpr_Results4,oMap(a1)
	bra.s	.GotMaps

; -------------------------------------------------------------------------

.NotSSZ3:
	move.l	#MapSpr_Results1,4(a1)
	tst.b	goodFuture
	beq.s	.GotMaps
	move.l	#MapSpr_Results3,4(a1)

.GotMaps:
	move.w	d1,d2
	lsl.w	#3,d2
	move.w	(a2,d2.w),oYScr(a1)
	move.w	2(a2,d2.w),oX(a1)
	move.w	4(a2,d2.w),oVar2A(a1)
	move.b	7(a2,d2.w),oMapFrame(a1)
	cmpi.b	#2,d1
	bne.s	.GotFrame
	move.b	levelAct,d2
	add.b	d2,oMapFrame(a1)

.GotFrame:
	addq.b	#1,d1
	dbf	d6,.Loop
	rts
; End of function ObjResults_WaitPLC

; -------------------------------------------------------------------------

ObjResults_MoveToDest:
	tst.w	oVar32(a0)
	beq.s	.TimerDone
	subq.w	#1,oVar32(a0)

.TimerDone:
	moveq	#8,d0
	move.w	oVar2A(a0),d1
	cmp.w	oX(a0),d1
	beq.s	.InPlace
	bge.s	.GotSpeed
	neg.w	d0

.GotSpeed:
	add.w	d0,oX(a0)

.TestDisplay:
	if REGION=USA
		cmpi.w	#$1D8,oVar32(a0)
	else
		cmpi.w	#$160,oVar32(a0)
	endif
	bcc.s	.End
	jmp	DrawObject

; -------------------------------------------------------------------------

.End:
	rts

; -------------------------------------------------------------------------

.InPlace:
	tst.b	oMapFrame(a0)
	bne.s	.TestDisplay
	addq.b	#2,oRoutine(a0)
	bra.s	.TestDisplay
; End of function ObjResults_MoveToDest

; -------------------------------------------------------------------------

ObjResults_BonusCountdown:
	move.b	#1,updateResultsBonus.w
	moveq	#0,d0
	tst.w	bonusCount1.w
	bne.s	.GiveBonus1
	tst.w	bonusCount2.w
	bne.s	.GiveBonus2
	subq.w	#1,oVar32(a0)
	if (REGION=USA)|((REGION<>USA)&(DEMO=0))
		bpl.s	.KeepRout
	else
		bpl.s	.Display
	endif
	addq.b	#2,oRoutine(a0)

.KeepRout:
	if (REGION=USA)|((REGION<>USA)&(DEMO=0))
		cmpi.w	#$1E,oVar32(a0)
		bne.s	.Display
	endif
	tst.b	enteredBigRing
	beq.s	.Display
	move.w	#$C8,d0
	jsr	PlayFMSound

.Display:
	jmp	DrawObject

; -------------------------------------------------------------------------

.GiveBonus1:
	addi.w	#10,d0
	subi.w	#100,bonusCount1.w
	tst.w	bonusCount2.w
	beq.s	.ChkDone

.GiveBonus2:
	addi.w	#10,d0
	subi.w	#100,bonusCount2.w

.ChkDone:
	move.l	d0,d1
	tst.w	bonusCount1.w
	bne.s	.HaveBonus
	tst.w	bonusCount2.w
	bne.s	.HaveBonus
	if (REGION=USA)|((REGION<>USA)&(DEMO=0))
		jsr	StopZ80
		move.b	#$9A,FMDrvQueue1
		jsr	StartZ80
		cmpi.w	#$2D,oVar32(a0)
		bcc.s	.NoSFX
		move.w	#$2D,oVar32(a0)
		bra.s	.NoSFX
	else
		move.w	#$9A,d0
		jsr	PlayFMSound
		bra.s	.NoSFX
	endif

; -------------------------------------------------------------------------

.HaveBonus:
	tst.w	oVar32(a0)
	beq.s	.TestSFX
	subq.w	#1,oVar32(a0)

.TestSFX:
	btst	#0,oVar32(a0)
	bne.s	.NoSFX
	move.w	#$BD,d0
	jsr	PlayFMSound

.NoSFX:
	move.l	d1,d0
	jsr	AddPoints
	jmp	DrawObject
; End of function ObjResults_BonusCountdown

; -------------------------------------------------------------------------

ObjResults_NextLevel:
	move.w	#2,levelRestart
	move.b	#0,resetLevelFlags
	clr.w	lastCamPLC
	clr.l	flowerCount
	clr.b	unkLevelFlag
	clr.b	projDestroyed
	clr.b	lastCheckpoint
	tst.b	timeAttackMode
	beq.s	.NotTimeAttack
	bclr	#0,plcLoadFlags

.NotTimeAttack:
	bclr	#1,plcLoadFlags
	move.b	#1,timeZone
	move.w	level,d0
	addq.b	#1,d0
	cmpi.b	#2,d0
	bne.s	.NotAct3
	move.b	#2,timeZone

.NotAct3:
	cmpi.b	#3,d0
	bne.s	.SameZone
	move.b	#0,d0
	addi.w	#$100,d0
	move.b	#0,d0

.SameZone:
	move.w	d0,levelZone
	jsr	ResetRespawnTable
	jsr	FadeOutMusic
	jsr	DrawObject
	move.b	levelAct,d0
	subq.b	#1,d0
	bpl.s	.NotAct1
	clr.b	goodFutureFlags
	rts

; -------------------------------------------------------------------------

.NotAct1:
	if (REGION=USA)|((REGION<>USA)&(DEMO=0))
		tst.b	timeAttackMode
		bne.s	.End
		cmpi.b	#$7F,timeStones
		beq.s	.SetGoodFuture
	endif
	tst.b	goodFuture
	beq.s	.End
	clr.b	goodFuture
	bset	d0,goodFutureFlags
	cmpi.b	#3,goodFutureFlags
	bne.s	.End

.SetGoodFuture:
	move.b	#1,goodFuture

.End:
	rts
; End of function ObjResults_NextLevel

; -------------------------------------------------------------------------

ObjResults_Data:
	dc.w	$CC, 0, $120, 0
	dc.w	$110, $200, $F0, 1
	dc.w	$CC, 0, $120, 2

; -------------------------------------------------------------------------

	include	"Level/_Objects/Results/Data/Mappings.asm"
	even
	
; -------------------------------------------------------------------------
