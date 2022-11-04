; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Results object
; -------------------------------------------------------------------------

oResultsDestX	EQU	oVar2A			; Destination X position
oResultsTimer	EQU	oVar32			; Timer

; -------------------------------------------------------------------------

ObjResults:
	moveq	#0,d0				; Run routine
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jmp	.Index(pc,d0.w)

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjResults_Init-.Index
	dc.w	ObjResults_WaitPLC-.Index
	dc.w	ObjResults_Move-.Index
	dc.w	ObjResults_Bonus-.Index
	dc.w	ObjResults_NextLevel-.Index

; -------------------------------------------------------------------------
; Initialization
; -------------------------------------------------------------------------

ObjResults_Init:
	subq.b	#1,oResultsTimer(a0)		; Decrement delay timer
	beq.s	.LoadPLC			; If it hasn't run out, branch
	rts

.LoadPLC:
	moveq	#$10,d0				; Load PLCs
	jsr	LoadPLC
	addq.b	#2,oRoutine(a0)			; Next routine

; -------------------------------------------------------------------------
; Wait for PLCs and spawn objects
; -------------------------------------------------------------------------

ObjResults_WaitPLC:
	tst.l	plcBuffer.w			; Have the PLCs loaded?
	bne.s	.End				; If not, branch
	cmpi.w	#$502,zoneAct			; Are we in Stardust Speedway Act 3?
	beq.s	.LoadResults			; If so, branch

	lea	objPlayerSlot.w,a6		; Is the player offscreen?
	move.w	cameraX.w,d0
	addi.w	#336,d0
	cmp.w	oX(a6),d0
	bcs.s	.LoadResults			; If so, branch

.End:
	rts

.LoadResults:
	lea	ObjResults_InitData,a2		; Get results initialization data
	moveq	#(ObjResults_InitDataEnd-ObjResults_InitData)/8-1,d6
	moveq	#0,d1
	movea.l	a0,a1

	if REGION=USA				; Set timer
		move.w	#480,oResultsTimer(a0)
	else
		move.w	#360,oResultsTimer(a0)
	endif
	bra.s	.InitLoop			; Start initializing

.Loop:
	jsr	FindObjSlot			; Spawn results object

.InitLoop:
	if REGION=USA				; Set timer
		move.w	#480,oResultsTimer(a1)
	else
		move.w	#360,oResultsTimer(a1)
	endif
	move.b	#$3A,oID(a1)			; Set results object ID
	move.b	#4,oRoutine(a1)			; Set routine
	move.w	#$83C4,oTile(a1)		; Set base tile ID

	cmpi.w	#$502,zoneAct			; Are we in Stardust Speedway Act 3?
	bne.s	.NotSSZ3			; If not, branch

	move.w	#$82F2,oTile(a1)		; Set base tile ID
	move.l	#MapSpr_ResultsBadSSZ3,oMap(a1)	; Set mappings
	tst.b	goodFuture
	beq.s	.GotMaps
	move.l	#MapSpr_ResultsGoodSSZ3,oMap(a1)
	bra.s	.GotMaps

.NotSSZ3:
	move.l	#MapSpr_ResultsBad,oMap(a1)	; Set mappings
	tst.b	goodFuture
	beq.s	.GotMaps
	move.l	#MapSpr_ResultsGood,oMap(a1)

.GotMaps:
	move.w	d1,d2				; Get initialization data offset
	lsl.w	#3,d2
	
	move.w	(a2,d2.w),oYScr(a1)		; Y position
	move.w	2(a2,d2.w),oX(a1)		; X position
	move.w	4(a2,d2.w),oResultsDestX(a1)	; Destination X position 
	move.b	7(a2,d2.w),oMapFrame(a1)	; Sprite frame ID

	cmpi.b	#2,d1				; Does this line have the act number in it?
	bne.s	.GotFrame			; If not, branch
	move.b	act,d2				; If so, display correct act number
	add.b	d2,oMapFrame(a1)

.GotFrame:
	addq.b	#1,d1				; Next object
	dbf	d6,.Loop			; Loop until results are fully spawned
	rts

; -------------------------------------------------------------------------
; Move
; -------------------------------------------------------------------------

ObjResults_Move:
	tst.w	oResultsTimer(a0)		; Has the timer run out?
	beq.s	.MoveX				; If so, branch
	subq.w	#1,oResultsTimer(a0)		; Decrement timer

.MoveX:
	moveq	#8,d0				; Movement speed
	move.w	oResultsDestX(a0),d1		; Are we at our destination?
	cmp.w	oX(a0),d1
	beq.s	.AtDestX			; If so, branch
	bge.s	.AddX				; If we're left of it, branch
	neg.w	d0				; If we're right of it, move left

.AddX:
	add.w	d0,oX(a0)			; Move

.CheckDraw:
	if REGION=USA				; Is it time to draw the sprite?
		cmpi.w	#472,oResultsTimer(a0)
	else
		cmpi.w	#352,oResultsTimer(a0)
	endif
	bcc.s	.End				; If not, branch
	jmp	DrawObject			; Draw sprite

.End:
	rts

.AtDestX:
	tst.b	oMapFrame(a0)			; Is this the main object?
	bne.s	.CheckDraw			; If not, branch
	addq.b	#2,oRoutine(a0)			; If so, set next routine
	bra.s	.CheckDraw

; -------------------------------------------------------------------------
; Bonus calculation
; -------------------------------------------------------------------------

ObjResults_Bonus:
	move.b	#1,updateHUDBonus.w		; Update bonus counter

	moveq	#0,d0				; Reset number of points to add

	tst.w	timeBonus.w			; Are there still points in the time bonus?
	bne.s	.TimeBonus			; If so, branch
	tst.w	ringBonus.w			; Are there still points in the ring bonus?
	bne.s	.RingBonus			; If so, branch

	subq.w	#1,oResultsTimer(a0)		; Decrement timer
	if (REGION=USA)|((REGION<>USA)&(DEMO=0))
		bpl.s	.ChkWarpSound		; If it hasn't run out, branch
	else
		bpl.s	.Draw			; If it hasn't run out, branch
	endif
	addq.b	#2,oRoutine(a0)

.ChkWarpSound:
	if (REGION=USA)|((REGION<>USA)&(DEMO=0))
		cmpi.w	#30,oResultsTimer(a0)	; Should we play the special stage warp sound?
		bne.s	.Draw			; If not, branch
	endif
	tst.b	specialStage			; Is the special stage flag set?
	beq.s	.Draw				; If not, branch
	move.w	#FM_SSWARP,d0			; Play special stage warp sound
	jsr	PlayFMSound

.Draw:
	jmp	DrawObject			; Draw sprite

.TimeBonus:
	addi.w	#10,d0				; Add time bonus points
	subi.w	#100,timeBonus.w
	tst.w	ringBonus.w			; Are there still points in the ring bonus?
	beq.s	.ChkDone			; If not, branch

.RingBonus:
	addi.w	#10,d0				; Add ring bonus points
	subi.w	#100,ringBonus.w

.ChkDone:
	move.l	d0,d1				; Save points to add

	tst.w	timeBonus.w			; Are there still points in the time bonus?
	bne.s	.HaveBonus			; If so, branch
	tst.w	ringBonus.w			; Are there still points in the ring bonus?
	bne.s	.HaveBonus			; If so, branch

	if (REGION=USA)|((REGION<>USA)&(DEMO=0))
		jsr	StopZ80			; Play "ka-ching" sound
		move.b	#FM_KACHING,FMDrvQueue1
		jsr	StartZ80

		cmpi.w	#45,oResultsTimer(a0)
		bcc.s	.AddPoints
		move.w	#45,oResultsTimer(a0)
		bra.s	.AddPoints

	else
		move.w	#FM_KACHING,d0		; Play "ka-ching" sound
		jsr	PlayFMSound
		bra.s	.AddPoints
	endif

.HaveBonus:
	tst.w	oResultsTimer(a0)		; Has the timer run out?
	beq.s	.PlayTallySound			; If it has, branch
	subq.w	#1,oResultsTimer(a0)		; Decrement timer

.PlayTallySound:
	btst	#0,oResultsTimer(a0)		; Is this an even frame?
	bne.s	.AddPoints			; If not, branch
	move.w	#FM_TALLY,d0			; Play tally sound
	jsr	PlayFMSound

.AddPoints:
	move.l	d1,d0				; Add points
	jsr	AddPoints
	jmp	DrawObject			; Draw sprite

; -------------------------------------------------------------------------
; Set next level
; -------------------------------------------------------------------------

ObjResults_NextLevel:
	move.w	#2,levelRestart			; Go to next level
	move.b	#0,spawnMode			; Spawn from beginning

	clr.w	sectionID			; Reset section ID
	clr.l	flowerCount			; Reset flower count
	clr.b	unkLevelFlag			; Clear unknown flag
	clr.b	projDestroyed			; Reset projector destroyed flag
	clr.b	checkpoint			; Reset checkpoint ID

	tst.b	timeAttackMode			; Are we in time attack mode?
	beq.s	.NotTimeAttack			; If not, branch
	bclr	#0,plcLoadFlags			; Mark PLCs as not loaded

.NotTimeAttack:
	bclr	#1,plcLoadFlags			; Mark title card as not loaded

	move.b	#TIME_PRESENT,timeZone		; Go to the present
	move.w	zoneAct,d0			; Next act
	addq.b	#1,d0
	cmpi.b	#2,d0				; Are we in act 3?
	bne.s	.NotAct3			; If not, branch
	move.b	#TIME_FUTURE,timeZone		; If so, go to the future

.NotAct3:
	cmpi.b	#3,d0				; Is the zone done?
	bne.s	.SetLevel			; If not, branch

	move.b	#0,d0				; Set to act 1
	addi.w	#$100,d0			; Next zone
	move.b	#0,d0				; Set to act 1

.SetLevel:
	move.w	d0,zoneAct			; Set level ID

	jsr	ResetSavedObjFlags		; Reset saved object flags
	jsr	FadeOutMusic			; Fade music out

	jsr	DrawObject			; Draw sprite
	move.b	act,d0				; Were we in act 3?
	subq.b	#1,d0
	bpl.s	.CheckGoodFuture		; If not, branch
	clr.b	goodFutureFlags			; Reset good future flags
	rts

.CheckGoodFuture:
	if (REGION=USA)|((REGION<>USA)&(DEMO=0))
		tst.b	timeAttackMode		; Are we in time attack mode?
		bne.s	.End			; If so, branch
		cmpi.b	#%1111111,timeStones	; Do we have all the time stones?
		beq.s	.SetGoodFuture		; If so, branch
	endif

	tst.b	goodFuture			; Is the good future flag set?
	beq.s	.End				; If not, branch

	clr.b	goodFuture			; Clear good future flag
	bset	d0,goodFutureFlags		; Mark act as having a good future
	cmpi.b	#%11,goodFutureFlags		; Were good futures achieved for acts 1 and 2?
	bne.s	.End				; If not, branch

.SetGoodFuture:
	move.b	#1,goodFuture			; Set good future flag for act 3

.End:
	rts

; -------------------------------------------------------------------------
; Results initialization data
; -------------------------------------------------------------------------

RESOBJ macro x, destx, y, frame
	dc.w	\y, \x, \destx, \frame
	endm

; -------------------------------------------------------------------------

ObjResults_InitData:
	RESOBJ	0,   288, 204, 0		; "SONIC GOT"/"SONIC MADE A GOOD"
	RESOBJ	512, 240, 272, 1		; Score counters
	RESOBJ	0,   288, 204, 2		; "THROUGH Zone X"/"FUTURE IN Zone X"
ObjResults_InitDataEnd:

; -------------------------------------------------------------------------
; Data
; -------------------------------------------------------------------------

	include	"Level/_Objects/Results/Data/Mappings.asm"
	even
	
; -------------------------------------------------------------------------
