; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Sonic object (Wacky Workbench)
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Check to see if Sonic should give up from boredom
; -------------------------------------------------------------------------

ObjSonic_ChkBoredom:
	lea	boredTimer.w,a1			; Get boredom timer

	cmpi.b	#5,oAnim(a0)			; Is the player idle?
	beq.s	.WaitAnim			; If so, branch

	move.w	#0,(a1)				; Reset the boredom timer
	rts

.WaitAnim:
	tst.w	(a1)				; Is the timer active?
	bne.s	.TimerGoing			; If so, branch
	move.b	#1,1(a1)			; Make the timer active

.TimerGoing:
	cmpi.w	#3*60*60,(a1)			; Have 3 minutes passed?
	bcs.s	.End				; If not, branch

	move.w	#0,(a1)				; Stop the timer

	move.b	#$2B,oAnim(a0)			; Set the player's animation accordingly
	ori.b	#$80,oTile(a0)
	move.b	#0,oPriority(a0)

	move.b	#1,lives			; Make it so a game over happens

	move.w	#-$500,oYVel(a0)		; Make the player jump
	move.w	#$100,oXVel(a0)
	btst	#0,oFlags(a0)
	beq.s	.GotXVel
	neg.w	oXVel(a0)

.GotXVel:
	move.w	#0,oPlayerGVel(a0)

	move.w	#SCMD_GIVEUPSFX,d0		; Play "I'm outta here" sound
	bra.w	SubCPUCmd

.End:
	rts

; -------------------------------------------------------------------------
; Main Sonic object code
; -------------------------------------------------------------------------

ObjSonic:
	if (REGION<>USA)|((REGION=USA)&(DEMO=0))
		tst.b	timeAttackMode		; Are we in time attack mode?
		bne.s	.NormalMode		; If so, branch
		cmpa.w	#objPlayerSlot2,a0	; Are we the second player?
		beq.s	.NormalMode		; If so, branch
		if DEMO<>0
			btst	#7,p2CtrlTap.w	; Did player 2 press the start button?
			beq.s	.CheckDebug	; If not, branch
			eori.b	#1,debugCheat	; Swap debug cheat flag
			
.CheckDebug:
		endif
		tst.b	debugMode		; Are we in debug mode?
		beq.s	.NormalMode		; If not, branch
		jmp	UpdateDebugMode		; Handle debug mode

.NormalMode:
	endif
	move.b	oPlayerCharge(a0),d0		; Get charge time
	beq.s	.RunRoutines			; If it's 0, branch
	addq.b	#1,d0				; Increment the charge time
	btst	#2,oFlags(a0)			; Are we spindashing?
	beq.s	.Peelout			; If not, branch
	cmpi.b	#45,d0				; Is the spindash fully charged?
	bcs.s	.SetChargeTimer			; If not, branch
	move.b	#45,d0				; Cap the charge time
	bra.s	.SetChargeTimer

.Peelout:
	cmpi.b	#30,d0				; Is the peelout fully charged?
	bcs.s	.SetChargeTimer			; If not, branch
	move.b	#30,d0				; Cap the charge time

.SetChargeTimer:
	move.b	d0,oPlayerCharge(a0)		; Update the charge time

.RunRoutines:
	moveq	#0,d0				; Run object routine
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d1
	jmp	.Index(pc,d1.w)

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjSonic_Init-.Index		; Initialization
	dc.w	ObjSonic_Main-.Index		; Main
	dc.w	ObjSonic_Hurt-.Index		; Hurt
	dc.w	ObjSonic_Dead-.Index		; Death
	dc.w	ObjSonic_Restart-.Index		; Death delay and level restart

; -------------------------------------------------------------------------
; Create time warp stars
; -------------------------------------------------------------------------

ObjSonic_MakeTimeWarpStars:
	tst.b	objTimeStar1Slot.w		; Are they already loaded?
	bne.s	.End				; If so, branch

	move.b	#1,timeWarp			; Set time warp flag

	move.b	#3,objTimeStar1Slot.w		; Load time warp stars
	move.b	#5,objTimeStar1Slot+oAnim.w
	move.b	#3,objTimeStar2Slot.w
	move.b	#6,objTimeStar2Slot+oAnim.w
	move.b	#3,objTimeStar3Slot.w
	move.b	#7,objTimeStar3Slot+oAnim.w
	move.b	#3,objTimeStar4Slot.w
	move.b	#8,objTimeStar4Slot+oAnim.w

.End:
	rts
	rts

; -------------------------------------------------------------------------
; Sonic's initialization routine
; -------------------------------------------------------------------------

ObjSonic_Init:
	addq.b	#2,oRoutine(a0)			; Advance routine

	move.b	#$13,oYRadius(a0)		; Default hitbox size
	move.b	#9,oXRadius(a0)
	tst.b	miniSonic			; Are we miniature?
	beq.s	.NotMini			; If not, branch
	move.b	#$A,oYRadius(a0)		; Mini hitbox size
	move.b	#5,oXRadius(a0)

.NotMini:
	move.l	#MapSpr_Sonic,oMap(a0)		; Set mappings
	move.w	#$780,oTile(a0)			; Set base tile
	move.b	#2,oPriority(a0)		; Set priority
	move.b	#$18,oWidth(a0)			; Set width
	move.b	#%00000100,oSprFlags(a0)	; Set sprite flags

	move.w	#$600,sonicTopSpeed.w		; Set physics values
	move.w	#$C,sonicAcceleration.w
	move.w	#$80,sonicDeceleration.w
	rts

; -------------------------------------------------------------------------
; Create waterfall splashes
; -------------------------------------------------------------------------

ObjSonic_MakeWaterfallSplash:
	tst.b	zone				; Are we in Palmtree Panic zone?
	bne.s	ObjSonic_SplashEnd		; If not, branch

	move.b	levelFrames+1,d0		; Only spawn a splash every 4 frames
	andi.b	#3,d0
	bne.s	ObjSonic_SplashEnd

	move.b	oYRadius(a0),d2			; Are we behind a waterfall?
	ext.w	d2
	add.w	oY(a0),d2
	move.w	oX(a0),d3
	bsr.w	ObjSonic_GetChunkAtPos
	cmpi.b	#$2F,d1
	bne.s	ObjSonic_SplashEnd2		; If not, branch

	cmpi.w	#$15C0,oX(a0)			; Are we too far into the level?
	bcc.s	ObjSonic_SplashEnd		; If so, branch
	tst.b	oPlayerCtrl(a0)			; Are we in a spin tunnel?
	beq.s	ObjSonic_SplashEnd		; If not, branch

	jsr	FindObjSlot			; Create a waterfall splash at our position
	bne.s	ObjSonic_SplashEnd
	move.b	#$E,oID(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)

	moveq	#1,d0				; Set splash direction
	tst.w	oXVel(a0)
	bmi.s	.SetFlip
	moveq	#0,d0

.SetFlip:
	move.b	d0,oSprFlags(a1)
	move.b	d0,oFlags(a1)

ObjSonic_SplashEnd:
	rts

ObjSonic_SplashEnd2:
	rts

; -------------------------------------------------------------------------

ObjSonic_MakeSplash:
	move.b	oYRadius(a0),d2			; Get bottom sensor
	ext.w	d2
	add.w	oY(a0),d2

	cmpi.b	#$10,d1				; Are we in horizontal range $1000-$10FF?
	bne.s	.CheckOther			; If not, branch
	cmpi.w	#$210,d2			; Are we in vertical range $208-$210?
	bcc.s	ObjSonic_SplashEnd		; If not, branch
	cmpi.w	#$208,d2
	bcs.s	ObjSonic_SplashEnd		; If not, branch
	bra.s	.MakeSplash			; If so, make a splash

.CheckOther:
	cmpi.b	#$21,d1				; Are we in horizontal range $2100-$21FF?
	bne.s	ObjSonic_SplashEnd		; If not, branch
	cmpi.w	#$2A0,d2			; Are we in vertical range $298-$2A0?
	bcc.s	ObjSonic_SplashEnd		; If not, branch
	cmpi.w	#$298,d2
	bcs.s	ObjSonic_SplashEnd		; If not, branch

.MakeSplash:
	tst.w	oPlayerGVel(a0)			; Are we moving?
	beq.s	ObjSonic_SplashEnd		; If not, branch
	
	jsr	FindObjSlot			; Make a splash
	bne.s	ObjSonic_SplashEnd
	move.b	#$B,oID(a1)
	move.w	oX(a0),oX(a1)
	andi.w	#$FFF8,d2
	move.w	d2,oY(a1)
	move.b	#1,oSubtype(a1)

	move.w	oPlayerGVel(a0),d0		; Get speed
	bpl.s	.CheckSpeed
	neg.w	d0

.CheckSpeed:
	cmpi.w	#$600,d0			; Were we going fast?
	bcc.s	.Sound				; If so, branch
	move.b	#2,oSubtype(a1)			; If not, use smaller splash

.Sound:
	move.w	#FM_A1,d0			; Play sound
	jmp	PlayFMSound

; -------------------------------------------------------------------------
; Get the chunk at a specific position
; -------------------------------------------------------------------------
; PARAMETERS:
;	d2.w - Y position
;	d3.w - X position
; RETURNS:
;	d1.b - Chunk ID
; -------------------------------------------------------------------------

ObjSonic_GetChunkAtPos:
	move.w	d2,d0				; Get the chunk at the given position
	lsr.w	#1,d0
	andi.w	#$380,d0
	move.w	d3,d1
	lsr.w	#8,d1
	andi.w	#$7F,d1
	add.w	d1,d0
	move.l	#LevelChunks,d1
	lea	levelLayout.w,a1
	move.b	(a1,d0.w),d1
	andi.b	#$7F,d1
	rts

; -------------------------------------------------------------------------
; Check rotating pole collision
; -------------------------------------------------------------------------

ObjSonic_CheckRotPole:
	cmpi.b	#$2B,oAnim(a0)			; Are we giving up from boredom?
	beq.s	.End				; If so, branch
	cmpi.b	#4,oRoutine(a0)			; Are we hurt or dead?
	bcc.s	.End				; If so, branch
	btst	#3,oPlayerCtrl(a0)		; Are we already on a pole?
	bne.s	.End				; If so, branch

	move.w	oX(a0),d3			; Get block we are in
	move.w	oY(a0),d2
	jsr	GetLevelBlock
	move.w	(a1),d0
	andi.w	#$7FF,d0
	cmpi.w	#$103,d0			; Are we on a pole?
	bne.s	.End				; If not, branch

	bset	#3,oPlayerCtrl(a0)		; Mark as on pole
	move.w	#0,oXVel(a0)			; Stop horizontal movement
	move.w	#-$200,d0			; Set vertical speed
	tst.w	oYVel(a0)
	bmi.s	.SetYVel
	neg.w	d0

.SetYVel:
	move.w	d0,oYVel(a0)
	move.b	#$40,oPlayerRotAngle(a0)	; Set rotation angle

	move.w	oX(a0),d0			; Clip to pole
	andi.w	#$FFF0,d0
	addq.w	#8,d0
	move.w	d0,oX(a0)
	move.w	d0,oPlayerRotCenter(a0)

	move.b	#2,oAnim(a0)			; Start rolling
	bset	#2,oFlags(a0)
	move.b	#$E,oYRadius(a0)
	move.b	#7,oXRadius(a0)

.End:
	rts
	
; -------------------------------------------------------------------------
; Check hanging bar collision
; -------------------------------------------------------------------------

ObjSonic_CheckHangBar:
	cmpi.b	#$2B,oAnim(a0)			; Are we giving up from boredom?
	beq.w	.End				; If so, branch
	cmpi.b	#2,spawnMode			; Are we time warping?
	beq.w	.End				; If so, branch
	
	btst	#0,oPlayerCtrl(a0)		; Are we being controlled by another object?
	bne.s	.End				; If so, branch
	btst	#2,oPlayerCtrl(a0)		; Are we already hanging onto a bar?
	bne.s	.End				; If so, branch

	move.w	oX(a0),d3			; Get block we are in
	move.w	oY(a0),d2
	subi.w	#24,d2
	jsr	GetLevelBlock
	move.w	(a1),d0
	andi.w	#$7FF,d0
	cmpi.w	#$159,d0			; Are we on a bar?
	bne.s	.End				; If not, branch

	move.w	timeWarpTimer.w,d0		; Get time warp timer
	beq.s	.NoTimeWarp			; If we weren't time warping, branch
	clr.w	timeWarpTimer.w			; Stop time warp
	clr.b	timeWarp
	cmpi.w	#90,d0				; Were we just about to warp?
	bcs.s	.NoTimeWarp			; If not, branch
	clr.b	timeWarpDir.w			; If so, disable time warping until the next time post is touched

.NoTimeWarp:
	bclr	#2,oFlags(a0)			; Force out of ball
	move.w	#0,oXVel(a0)			; Stop movement
	move.w	#0,oYVel(a0)
	move.w	#0,oPlayerGVel(a0)
	move.b	#$2C,oAnim(a0)			; Set hanging animation
	bset	#2,oPlayerCtrl(a0)		; Mark as hanging on a bar
	move.b	#7,oPlayerHangAni(a0)		; Set animation timer

	move.w	oY(a0),d0			; Clip onto bar
	subi.w	#24,d0
	andi.w	#$FFF0,d0
	addi.w	#24,d0
	move.w	d0,oY(a0)

.End:
	rts

; -------------------------------------------------------------------------
; Check electric beam collision
; -------------------------------------------------------------------------

ObjSonic_CheckElecBeam:
	cmpi.b	#$2B,oAnim(a0)			; Are we giving up from boredom?
	beq.w	.End				; If so, branch
	cmpi.b	#4,oRoutine(a0)			; Are we hurt or dead?
	bcc.s	.End				; If so, branch
	tst.b	timeWarp			; Are we time warping?
	bne.s	.End				; If so, branch
	tst.b	invincible			; Are we invincible?
	bne.s	.End				; If so, branch
	tst.w	oPlayerHurt(a0)			; Are we invulnerable after getting hurt?
	bne.s	.End				; If so, branch

	moveq	#0,d0				; Get beam blocks to check
	move.b	wwzBeamMode,d0
	beq.s	.End
	subq.b	#1,d0
	add.w	d0,d0
	move.w	.BeamModes(pc,d0.w),d0
	lea	.BeamModes(pc,d0.w),a3

	move.w	oX(a0),d3			; Get block we are in
	move.w	oY(a0),d2
	jsr	GetLevelBlock
	move.w	(a1),d0
	andi.w	#$7FF,d0

.Check:
	move.w	(a3)+,d1			; Get block ID to check
	bmi.s	.End				; If we are at the end of the list, branch
	cmp.w	d1,d0				; Are we colliding with a beam block?
	bne.s	.Check				; If not, check next block
	bra.w	HurtPlayer			; If so, get hurt

.End:
	rts

; -------------------------------------------------------------------------

.BeamModes:
	dc.w	.Blue-.BeamModes
	dc.w	.Pink-.BeamModes
	dc.w	.Yellow-.BeamModes

.Blue:
	dc.w	$1AA
	dc.w	-1

.Pink:
	dc.w	$1C1
	dc.w	-1

.Yellow:
	dc.w	$1BC
	dc.w	$1DB
	dc.w	$1D4
	dc.w	$1D1
	dc.w	$1A3
	dc.w	$199
	dc.w	$198
	dc.w	$1A2
	dc.w	-1

; -------------------------------------------------------------------------
; Check electric spark collision
; -------------------------------------------------------------------------

ObjSonic_CheckSparks:
	cmpi.b	#$2B,oAnim(a0)			; Are we giving up from boredom?
	beq.w	.End				; If so, branch
	tst.b	timeWarp			; Are we time warping?
	bne.w	.End				; If so, branch
	tst.b	invincible			; Are we invincible?
	bne.w	.End				; If so, branch
	
	cmpi.w	#$980,oX(a0)			; Are in the boss arena entrance?
	bcs.s	.CheckBoss			; If not, branch
	cmpi.w	#$A20,oX(a0)
	bcs.w	.End				; If so, branch

.CheckBoss:
	btst	#7,bossFlags.w			; Is the boss defeated?
	bne.w	.End				; If so, branch
	tst.w	oPlayerHurt(a0)			; Are we invulnerable after getting hurt?
	bne.s	.End				; If so, branch
	
	cmpi.b	#2,act				; Are we in act 3?
	bne.s	.NotAct3
	cmpi.w	#$A10,oX(a0)			; Are we in the boss arena?
	bcs.s	.CheckCol			; If not, branch
	tst.b	bossMusic			; Is the boss active?
	beq.s	.End				; If not, branch
	tst.b	goodFuture			; Are we in the good future?
	bne.s	.CheckAnim			; If so, branch
	bra.s	.CheckCol			; If not, disregard animation

.NotAct3:
	cmpi.b	#2,timeZone			; Are we in the future?
	bne.s	.CheckCol			; If not, branch
	tst.b	goodFuture			; Are we in the bad future?
	beq.s	.CheckCol			; If so, branch

.CheckAnim:
	tst.b	aniArtFrames+2.w		; Are the sparks active?
	beq.s	.End				; If not, branch

.CheckCol:
	move.w	oX(a0),d3			; Get block we are in
	move.w	oY(a0),d2
	jsr	GetLevelBlock
	move.w	(a1),d0
	andi.w	#$7FF,d0

	moveq	#3-1,d6				; Get which blocks to check
	lea	.SparkBlocksNormal,a1
	cmpi.b	#2,timeZone			; Are we in the future?
	bne.s	.Check				; If not, branch
	tst.b	goodFuture			; Are we in the good future?
	bne.s	.Check				; If so, branch
	lea	.SparkBlocksBadFuture,a1	; Bad future uses different block IDs

.Check:
	cmp.w	(a1)+,d0			; Check block ID
	beq.w	HurtPlayer			; If we are touching a spark, get hurt
	dbf	d6,.Check			; Loop until all blocks are checked

.End:
	rts

; -------------------------------------------------------------------------

.SparkBlocksNormal:
	dc.w	$243
	dc.w	$244
	dc.w	$245

.SparkBlocksBadFuture:
	dc.w	$287
	dc.w	$288
	dc.w	$289

; -------------------------------------------------------------------------
; Check bouncy floor collision
; -------------------------------------------------------------------------

ObjSonic_CheckBouncyFloor:
	cmpi.b	#$2B,oAnim(a0)			; Are we giving up from boredom?
	beq.w	.End				; If so, branch
	
	tst.b	bossFlags.w			; Is the boss active?
	bne.w	.End				; If so, branch
	cmpi.b	#2,timeZone			; Are we in the future?
	bcc.s	.CheckCol			; If so, branch

	move.b	#$3C,d0				; Get palette cycle frame where the bouncy floors are inactive
	tst.b	timeZone
	beq.s	.CheckActive
	addi.b	#$1E,d0

.CheckActive:
	cmp.b	palCycleSteps+3.w,d0		; Are the bouncy floors active?
	beq.w	.End				; If not, branch

.CheckCol:
	move.w	oX(a0),d3			; Get block we are on (left sensor)
	move.w	oY(a0),d2
	move.b	oYRadius(a0),d0
	ext.w	d0
	add.w	d0,d2
	addq.w	#2,d2
	move.b	oXRadius(a0),d0
	ext.w	d0
	sub.w	d0,d3
	jsr	GetLevelBlock
	move.w	(a1),d0
	andi.w	#$7FF,d0
	cmpi.w	#$21F,d0			; Are we on a bouncy floor?
	beq.s	.Bounce				; If so, branch
	
	move.w	oX(a0),d3			; Get block we are on (right sensor)
	move.w	oY(a0),d2
	move.b	oYRadius(a0),d0
	ext.w	d0
	add.w	d0,d2
	addq.w	#2,d2
	move.b	oXRadius(a0),d0
	ext.w	d0
	add.w	d0,d3
	jsr	GetLevelBlock
	move.w	(a1),d0
	andi.w	#$7FF,d0
	cmpi.w	#$21F,d0			; Are we on a bouncy floor?
	bne.s	.End				; If not, branch

.Bounce:
	move.w	#-$1600,oYVel(a0)		; Bounce up
	bset	#1,oFlags(a0)			; Mark as in the air
	bclr	#4,oFlags(a0)			; Clear roll-jump flag
	bclr	#5,oFlags(a0)			; Clear push flag
	clr.b	oPlayerJump(a0)			; Clear jump flag
	
	bset	#2,oFlags(a0)			; Mark as rolling
	bne.s	.End				; If it was already marked, branch
	move.b	#$E,oYRadius(a0)		; Set rolling hitbox size
	move.b	#7,oXRadius(a0)
	addq.w	#5,oY(a0)
	move.b	#2,oAnim(a0)			; Set animation to rolling animation

	move.w	#FM_DA,d0			; Play bounce sound
	jsr	PlayFMSound
	
.End:
	rts

; -------------------------------------------------------------------------
; Handle the extended camera
; -------------------------------------------------------------------------

ObjSonic_ExtCamera:
	rts					; Extended camera is disabled in Wacky Workbench

	move.w	camXCenter.w,d1			; Get camera X center position

	move.w	oPlayerGVel(a0),d0		; Get how fast we are moving
	bpl.s	.PosInertia
	neg.w	d0

.PosInertia:
	btst	#1,oPlayerCtrl(a0)		; Are we on a 3D ramp?
	bne.s	.ResetPan			; If so, branch
	cmpi.w	#$600,d0			; Are we going at max regular speed?
	bcs.s	.ResetPan			; If not, branch

	tst.w	oPlayerGVel(a0)			; Are we moving right?
	bpl.s	.MovingRight			; If so, branch

.MovingLeft:
	addq.w	#2,d1				; Pan the camera to the right
	cmpi.w	#(320/2)+64,d1			; Has it panned far enough?
	bcs.s	.SetPanVal			; If not, branch
	move.w	#(320/2)+64,d1			; Cap the camera's position
	bra.s	.SetPanVal

.MovingRight:
	subq.w	#2,d1				; Pan the camera to the left
	cmpi.w	#(320/2)-64,d1			; Has it panned far enough
	bcc.s	.SetPanVal			; If not, branch
	move.w	#(320/2)-64,d1			; Cap the camera's position
	bra.s	.SetPanVal

.ResetPan:
	cmpi.w	#320/2,d1			; Has the camera panned back to the middle?
	beq.s	.SetPanVal			; If so, branch
	bcc.s	.ResetLeft			; If it's panning back left

.ResetRight:
	addq.w	#2,d1				; Pan back to the right
	bra.s	.SetPanVal

.ResetLeft:
	subq.w	#2,d1				; Pan back to the left

.SetPanVal:
	move.w	d1,camXCenter.w			; Update camera X center position
	rts

; -------------------------------------------------------------------------
; Sonic's main routine
; -------------------------------------------------------------------------

ObjSonic_Main:
	bsr.s	ObjSonic_ExtCamera		; Handle extended camera
	bsr.w	ObjSonic_MakeWaterfallSplash	; Handle waterfall splash creation

	tst.w	debugCheat			; Is debug mode enabled?
	beq.s	.NoDebug			; If not, branch
	btst	#4,p1CtrlTap.w			; Was the B button pressed?
	beq.s	.NoDebug			; If not, branch
	move.b	#1,debugMode			; Enter debug mode
	rts

.NoDebug:
	tst.b	ctrlLocked.w			; Are controls locked?
	bne.s	.CtrlLock			; If so, branch
	move.w	p1CtrlData.w,playerCtrl.w	; Copy controller data

.CtrlLock:
	btst	#0,oPlayerCtrl(a0)		; Are we being controlled by another object?
	beq.s	.NormalCtrl			; If not, branch
	
	bsr.w	ObjSonic_TimeWarp		; Handle time warping
	bra.s	.SkipControl

.NormalCtrl:
	moveq	#0,d0				; Run player mode routine
	move.b	oFlags(a0),d0
	andi.w	#6,d0
	move.w	ObjSonic_ModeIndex(pc,d0.w),d1
	jsr	ObjSonic_ModeIndex(pc,d1.w)

	bsr.w	ObjSonic_CheckBouncyFloor	; Check bouncy floor collision
	bsr.w	ObjSonic_CheckSparks		; Check electric spark collision
	bsr.w	ObjSonic_CheckElecBeam		; Check electric beam collision
	bsr.w	ObjSonic_CheckHangBar		; Check hanging bar collision
	bsr.w	ObjSonic_CheckRotPole		; Check rotating pole collision

.SkipControl:
	bsr.s	ObjSonic_Display		; Draw sprite and handle timers
	bsr.w	ObjSonic_RecordPos		; Save current position into the position buffer

						; Update our angle buffers
	move.b	primaryAngle.w,oPlayerPriAngle(a0)
	move.b	secondaryAngle.w,oPlayerSecAngle(a0)

	bsr.w	ObjSonic_Animate		; Animate sprite

	tst.b	oPlayerCtrl(a0)			; Has object collision been disabled?
	bmi.s	.NoObjCol			; If so, branch
	cmpi.b	#$2B,oAnim(a0)			; Are we giving up from boredom?
	beq.s	.NoObjCol			; If so, branch

	jsr	Player_ObjCollide		; Handle object collision

.NoObjCol:
	bsr.w	ObjSonic_SpecialChunks		; Handle special chunks
	rts

; -------------------------------------------------------------------------

ObjSonic_ModeIndex:
	dc.w	ObjSonic_MdGround-ObjSonic_ModeIndex
	dc.w	ObjSonic_MdAir-ObjSonic_ModeIndex
	dc.w	ObjSonic_MdRoll-ObjSonic_ModeIndex
	dc.w	ObjSonic_MdJump-ObjSonic_ModeIndex

; -------------------------------------------------------------------------
; Leftover music ID list from Sonic 1
; -------------------------------------------------------------------------

LevelMusicIDs2_S1:
	dc.b	$81, $82, $83, $84, $85, $86
	even

; -------------------------------------------------------------------------
; Display Sonic's sprite and update timers
; -------------------------------------------------------------------------

ObjSonic_Display:
	cmpi.w	#210,timeWarpTimer.w		; Are we about to time warp?
	bcc.s	.SkipDisplay			; If so, branch

	move.w	oPlayerHurt(a0),d0		; Get current hurt time
	beq.s	.NotFlashing			; If we are not hurting, branch
	subq.w	#1,oPlayerHurt(a0)		; Decrement hurt time
	lsr.w	#3,d0				; Should we flash our sprite?
	bcc.s	.SkipDisplay			; If so, branch

.NotFlashing:
	btst	#6,oPlayerCtrl(a0)		; Are we invisible?
	bne.s	.SkipDisplay			; If so, branch
	jsr	DrawObject			; Draw sprite

.SkipDisplay:
	tst.b	invincible			; Are we invincible?
	beq.s	.NotInvincible			; If not, branch
	tst.w	oPlayerInvinc(a0)		; Is the invincibility timer active?
	beq.s	.NotInvincible			; If not, branch

	subq.w	#1,oPlayerInvinc(a0)		; Decrement invincibility time
	bne.s	.NotInvincible			; If it hasn't run out, branch

	tst.b	speedShoes			; Is the speed shoes music playing?
	bne.s	.StopInvinc			; If so, branch
	tst.b	bossMusic			; Is the boss music playing?
	bne.s	.StopInvinc			; If so, branch
	tst.b	timeZone			; Are we in the past?
	bne.s	.NotPast			; If not, branch
	move.w	#SCMD_FADECDA,d0		; Fade out music
	jsr	SubCPUCmd

.NotPast:
	jsr	PlayLevelMusic			; Play level music

.StopInvinc:
	move.b	#0,invincible			; Stop invincibility

.NotInvincible:
	tst.b	speedShoes			; Do we have speed shoes?
	beq.s	.End				; If not, branch
	tst.w	oPlayerShoes(a0)		; Is the speed shoes timer active?
	beq.s	.End				; If not, branch

	subq.w	#1,oPlayerShoes(a0)		; Decrement speed shoes time
	bne.s	.End				; If it hasn't run out, branch

	move.w	#$600,sonicTopSpeed.w		; Return physics back to normal
	move.w	#$C,sonicAcceleration.w
	move.w	#$80,sonicDeceleration.w

	tst.b	invincible			; Is the invincibility music playing?
	bne.s	.StopSpeedShoes			; If so, branch
	tst.b	bossMusic			; Is the boss music playing?
	bne.s	.StopSpeedShoes			; If so, branch
	tst.b	timeZone			; Are we in the past?
	bne.s	.NotPast2			; If not, branch
	move.w	#SCMD_FADECDA,d0		; Fade out music
	jsr	SubCPUCmd

.NotPast2:
	jsr	PlayLevelMusic			; Play level music

.StopSpeedShoes:
	move.b	#0,speedShoes			; Stop speed shoes

.End:
	rts

; -------------------------------------------------------------------------
; Save Sonic's current position into the position buffer
; -------------------------------------------------------------------------

ObjSonic_RecordPos:
	move.w	sonicRecordIndex.w,d0		; Get pointer to current position buffer index
	lea	sonicRecordBuf.w,a1
	lea	(a1,d0.w),a1

	move.w	oX(a0),(a1)+			; Save our position
	move.w	oY(a0),(a1)+

	addq.b	#4,sonicRecordIndex+1.w		; Advance position buffer index
	rts

; -------------------------------------------------------------------------
; Handle Sonic underwater
; -------------------------------------------------------------------------

ObjSonic_Water:
	rts

; -------------------------------------------------------------------------
; Save time warp data
; -------------------------------------------------------------------------

SaveTimeWarpData:
	move.b	spawnMode,warpSpawnMode		; Save some values
	move.w	oX(a0),warpX
	move.w	oY(a0),warpY
	move.w	oPlayerGVel(a0),warpGVel
	move.w	oXVel(a0),warpXVel
	move.w	oYVel(a0),warpYVel
	move.b	oFlags(a0),warpPlayerFlags
	bclr	#3,warpPlayerFlags		; Not standing on an object
	move.b	waterRoutine.w,warpWaterRoutine
	move.w	bottomBound.w,warpBtmBound
	move.w	cameraX.w,warpCamX
	move.w	cameraY.w,warpCamY
	move.w	cameraBgX.w,warpCamBgX
	move.w	cameraBgY.w,warpCamBgY
	move.w	cameraBg2X.w,warpCamBg2X
	move.w	cameraBg2Y.w,warpCamBg2Y
	move.w	cameraBg3X.w,warpCamBg3X
	move.w	cameraBg3Y.w,warpCamBg3Y
	move.w	waterHeight2.w,warpWaterHeight
	move.b	waterRoutine.w,warpWaterRoutine
	move.b	waterFullscreen.w,warpWaterFull
	move.w	rings,warpRings
	move.b	livesFlags,warpLivesFlags

	move.l	time,d0				; Move the time to 5:00 if we are past that
	cmpi.l	#(5<<16)|(0<<8)|0,d0
	bcs.s	.CapTime
	move.l	#(5<<16)|(0<<8)|0,d0

.CapTime:
	move.l	d0,warpTime
	rts

; -------------------------------------------------------------------------
; Handle time warping for Sonic
; -------------------------------------------------------------------------

ObjSonic_TimeWarp:
	tst.b	oPlayerCharge(a0)		; Are we charging a peelout or spindash?
	bne.w	.End2				; If so, branch
	tst.b	timeWarpDir.w			; Have we touched a time post?
	beq.w	.End2				; If not, branch

	move.w	#$600,d2			; Minimum speed in which to keep the time warp going

	moveq	#0,d0				; Get current ground velocity
	move.w	oPlayerGVel(a0),d0
	bpl.s	.PosInertia
	neg.w	d0

.PosInertia:
	tst.w	timeWarpTimer.w			; Is the time warp timer active?
	bne.s	.TimerGoing			; If so, branch
	move.w	#1,timeWarpTimer.w		; Make the time warp timer active

.TimerGoing:
	move.w	timeWarpTimer.w,d1		; Get current time warp time
	cmpi.w	#230,d1				; Should we time warp now?
	bcs.s	.KeepGoing			; If not, branch

	move.b	#1,levelRestart			; Set to go to the time warp cutscene
	bra.w	FadeOutMusic

.KeepGoing:
	cmpi.w	#210,d1				; Are we about to time warp soon?
	bcs.s	.CheckStars			; If not, branch

	cmpi.b	#2,spawnMode			; Are we time warping?
	beq.s	.End				; If so, branch

	move.b	#1,scrollLock.w			; Lock the screen in place

	move.b	timeZone,d0			; Get current time zone
	bne.s	.GetNewTime			; If we are not in the past, branch

	move.w	#SCMD_FADEPCM,d0		; Fade out PCM music
	jsr	SubCPUCmd

	moveq	#0,d0				; We are currently in the past

.GetNewTime:
	add.b	timeWarpDir.w,d0		; Set the new time period
	bpl.s	.NoUnderflow			; If we aren't trying to go past the past, branch
	moveq	#0,d0				; Stay in this game's "past" time period
	bra.s	.GotNewTime

.NoUnderflow:
	cmpi.b	#3,d0				; Are we trying to go forward past the future?
	bcs.s	.GotNewTime			; If not, branch
	moveq	#2,d0				; Stay in this game's "future" time period

.GotNewTime:
	bset	#7,d0				; Mark time warp as active
	move.b	d0,timeZone

	bsr.w	SaveTimeWarpData		; Save time warp data
	move.b	#2,spawnMode			; Spawn from time warp position

.End:
	rts

.CheckStars:
	cmpi.w	#90,d1				; Have we tried time warping for a bit already?
	bcc.s	.CheckStop			; If so, branch

	cmp.w	d2,d0				; Are we going fast enough?
	bcc.w	ObjSonic_MakeTimeWarpStars	; If so, branch
	clr.w	timeWarpTimer.w			; If not, reset time warping until we go fast again
	clr.b	timeWarp
	rts

.CheckStop:
	cmp.w	d2,d0				; Are we going fast enough?
	bcc.s	.End2				; If so, branch

.StopTimeWarp:
	clr.w	timeWarpTimer.w			; Disable time warping until the next time post is touched
	clr.b	timeWarpDir.w
	clr.b	timeWarp

.End2:
	rts

; -------------------------------------------------------------------------
; Sonic's ground mode routine
; -------------------------------------------------------------------------

ObjSonic_MdGround:
	tst.b	sneezeFlag.w			; Is Sonic sneezing?
	beq.s	.NoSneeze			; If not, branch
	cmpi.b	#5,oAnim(a0)			; Has Sonic stopped sneezing?
	bne.s	.End				; If not, branch
	clr.b	sneezeFlag.w			; Clear sneeze flag

.NoSneeze:
	bsr.w	ObjSonic_ChkBoredom		; Check boredom timer

	cmpi.b	#$2B,oAnim(a0)			; Are we giving up from boredom?
	bne.s	.NotGivingUp			; If not, branch
	tst.b	miniSonic			; Are we miniature?
	beq.s	.NotMini			; If not, branch
	cmpi.b	#$79,oMapFrame(a0)		; Are we jumping?
	bne.s	.End				; If not, branch
	bra.s	.GivingUp

.NotMini:
	cmpi.b	#$17,oMapFrame(a0)		; Are we jumping?
	bcs.s	.End				; If not, branch

.GivingUp:
	bsr.w	ObjSonic_LevelBound		; Handle level boundary collision
	jmp	ObjMoveGrv			; Apply velocity

.NotGivingUp:
	bsr.w	ObjSonic_Handle3DRamp		; Check for a 3D ramp
	bsr.w	ObjSonic_TimeWarp		; Handle time warp
	bsr.w	ObjSonic_CheckJump		; Check for jumping
	bsr.w	ObjSonic_SlopeResist		; Handle slope resistance
	bsr.w	ObjSonic_MoveGround		; Handle movement
	bsr.w	ObjSonic_CheckRoll		; Check for rolling
	bsr.w	ObjSonic_LevelBound		; Handle level boundary collision
	jsr	ObjMove				; Apply velocity
	bsr.w	Player_GroundCol		; Handle level collision
	bsr.w	ObjSonic_CheckFallOff		; Check for falling off a steep slope or ceiling

.End:
	rts

; -------------------------------------------------------------------------
; Sonic's air mode routine
; -------------------------------------------------------------------------

ObjSonic_MdAir:
	tst.w	oYVel(a0)			; Are we moving upwards?
	bmi.s	.CheckHangBar			; If so, branch
	cmpi.b	#$2C,oAnim(a0)			; Are we in the hanging animation?
	beq.s	.CheckHangBar			; If so, branch
	move.b	#0,oAnim(a0)			; Reset animation to walking animation

.CheckHangBar:
	btst	#2,oPlayerCtrl(a0)		; Are we hanging on a bar?
	beq.s	.NoHangBar			; If not, branch
	bsr.w	ObjSonic_HangBar		; Handle hanging bar movement
	bra.s	.Collision

.NoHangBar:
	bsr.w	ObjSonic_Handle3DRamp		; Check for a 3D ramp
	bsr.w	ObjSonic_TimeWarp		; Handle time warp
	bsr.w	ObjSonic_JumpHeight		; Handle jump height
	bsr.w	ObjSonic_MoveAir		; Handle movement
	bsr.w	ObjSonic_LevelBound		; Handle level boundary collision
	jsr	ObjMoveGrv			; Apply velocity
	btst	#6,oFlags(a0)			; Are we underwater?
	beq.s	.NoWater			; If not, branch
	subi.w	#$28,oYVel(a0)			; Apply water gravity resistance

.NoWater:
	bsr.w	ObjSonic_JumpAngle		; Reset angle

.Collision:
	bsr.w	Player_LevelColInAir		; Handle level collision
	rts

; -------------------------------------------------------------------------
; Sonic's roll mode routine
; -------------------------------------------------------------------------

ObjSonic_MdRoll:
	bsr.w	ObjSonic_Handle3DRamp		; Check for  3D ramp
	bsr.w	ObjSonic_TimeWarp		; Handle time warp
	bsr.w	ObjSonic_CheckJump		; Check for jumping
	bsr.w	ObjSonic_SlopeResistRoll	; Handle slope resistance
	bsr.w	ObjSonic_MoveRoll		; Handle movement
	bsr.w	ObjSonic_LevelBound		; Handle level boundary collision
	tst.b	oPlayerCharge(a0)		; Are we spindashing?
	bne.s	.IsCharging			; If so, branch
	jsr	ObjMove				; Apply velocity

.IsCharging:
	bsr.w	Player_GroundCol		; Handle level collision
	bsr.w	ObjSonic_CheckFallOff		; Check for falling off a steep slope or ceiling
	rts

; -------------------------------------------------------------------------
; Sonic's jump mode routine
; -------------------------------------------------------------------------

ObjSonic_MdJump:
	btst	#3,oPlayerCtrl(a0)		; Are we on a rotating pole?
	beq.s	.CheckHangBar			; If not, branch
	bsr.w	ObjSonic_RotPole		; Handle rotating pole movement
	bsr.w	ObjSonic_TimeWarp		; Handle time warp
	bra.s	.Collision

.CheckHangBar:
	btst	#2,oPlayerCtrl(a0)		; Are we hanging on a bar?
	beq.s	.NoHangBar			; If not, branch
	bsr.w	ObjSonic_HangBar		; Handle hanging bar movement
	bsr.w	ObjSonic_TimeWarp		; Handle time warp
	bra.s	.Collision

.NoHangBar:
	bsr.w	ObjSonic_Handle3DRamp		; Check for a 3D ramp
	bsr.w	ObjSonic_TimeWarp		; Handle time warp
	bsr.w	ObjSonic_JumpHeight		; Handle jump height
	bsr.w	ObjSonic_MoveAir		; Handle movement
	bsr.w	ObjSonic_LevelBound		; Handle level boundary collision
	jsr	ObjMoveGrv			; Apply velocity
	btst	#6,oFlags(a0)			; Are we underwater?
	beq.s	.NoWater			; If not, branch
	subi.w	#$28,oYVel(a0)			; Apply water gravity resistance

.NoWater:
	bsr.w	ObjSonic_JumpAngle		; Reset angle

.Collision:
	bsr.w	Player_LevelColInAir		; Handle level collision
	rts

; -------------------------------------------------------------------------
; Handle rotating pole movement
; -------------------------------------------------------------------------

ObjSonic_RotPole:
	btst	#4,oPlayerCtrl(a0)		; Are we jumping off the pole?
	beq.s	.CheckJump			; If not, branch

	move.b	oPlayerRotAngle(a0),d0		; Get angle
	andi.b	#$7F,d0
	bne.s	.Rotate				; If we aren't on a far end, branch
	
	move.w	#-$C00,oXVel(a0)		; Jump off
	tst.b	oPlayerRotAngle(a0)		; Were we facing left?
	bmi.s	.JumpOff			; If so, branch
	neg.w	oXVel(a0)			; If not, jump the other way

.JumpOff:
	andi.b	#$7F,oTile(a0)			; Set to low plane
	andi.b	#%11100111,oPlayerCtrl(a0)	; Clear pole flags
	clr.w	oPlayerRotCenter(a0)		; Clear center position
	rts

.CheckJump:
	move.b	playerCtrlTap.w,d0		; Are we jumping off?
	andi.b	#$70,d0
	beq.s	.Rotate				; If not, branch
	bset	#4,oPlayerCtrl(a0)		; Mark as jumping off pole

.Rotate:
	addq.b	#8,oPlayerRotAngle(a0)		; Rotate around pole
	ori.w	#$8000,oTile(a0)		; Set perspective around pole
	move.b	oPlayerRotAngle(a0),d0
	bpl.s	.SetPos
	andi.w	#$7FFF,oTile(a0)

.SetPos:
	jsr	CalcSine			; Set horizontal position on pole
	muls.w	#23,d1
	asr.l	#8,d1
	move.w	oPlayerRotCenter(a0),oX(a0)
	add.w	d1,oX(a0)

	move.w	oYVel(a0),d0			; Move vertically on pole
	ext.l	d0
	lsl.l	#8,d0
	add.l	d0,oY(a0)

	move.w	oPlayerRotCenter(a0),d3		; Get block we are in
	move.w	oY(a0),d2
	jsr	GetLevelBlock
	move.w	(a1),d0
	andi.w	#$7FF,d0
	cmpi.w	#$103,d0			; Did we touch a pole end?
	beq.s	.End				; If not, branch
	neg.w	oYVel(a0)			; If so, move in the other direction

.End:
	rts

; -------------------------------------------------------------------------
; Handle hanging bar movement
; -------------------------------------------------------------------------

ObjSonic_HangBar:
	move.w	oX(a0),d3			; Get block we are in
	move.w	oY(a0),d2
	subi.w	#24,d2
	jsr	GetLevelBlock
	move.w	(a1),d0
	andi.w	#$7FF,d0
	cmpi.w	#$159,d0			; Are we on the bar?
	bne.s	.FallOff			; If not, branch
	
	move.b	playerCtrlTap.w,d0		; Are we jumping off?
	andi.b	#$70,d0
	beq.s	.MoveX				; If not, branch

.FallOff:
	bclr	#2,oPlayerCtrl(a0)		; Stop hanging
	addi.w	#$10,oY(a0)			; Fall off
	move.b	#$13,oYRadius(a0)		; Reset collision hitbox
	move.b	#9,oXRadius(a0)
	rts

.MoveX
	moveq	#2,d0				; X speed
	btst	#2,playerCtrlHold.w		; Are we going left?
	beq.s	.ChkRight			; If not, branch
	neg.w	d0				; Go the other way
	bset	#0,oFlags(a0)			; Face to the left
	bset	#0,oSprFlags(a0)
	bra.s	.DoMove

.ChkRight:
	btst	#3,playerCtrlHold.w		; Are we going left?
	beq.s	.End				; If not, branch
	bclr	#0,oFlags(a0)			; Face to the right
	bclr	#0,oSprFlags(a0)

.DoMove:
	add.w	d0,oX(a0)			; Update X position
	subq.b	#1,oPlayerHangAni(a0)		; Decrement animation timer
	bpl.s	.End				; If it hasn't run out, branch
	move.b	#7,oPlayerHangAni(a0)		; Reset timer
	addq.b	#1,oAnimFrame(a0)		; Increment animation frame
	cmpi.b	#4,oAnimFrame(a0)		; Have we reached the last one?
	bcs.s	.End				; If not, branch
	move.b	#0,oAnimFrame(a0)		; Reset animation frame

.End:
	rts

; -------------------------------------------------------------------------
; Check for a 3D ramp for Sonic
; -------------------------------------------------------------------------

ObjSonic_Handle3DRamp:
	cmpi.b	#1,timeZone			; Are we in the present?
	bne.s	.End				; If not, branch
	tst.w	zoneAct				; Are we in Palmtree Panic act 1?
	bne.s	.End				; If not, branch

	move.w	oY(a0),d0			; Get current chunk that we are in
	lsr.w	#1,d0
	andi.w	#$380,d0
	move.b	oX(a0),d1
	andi.w	#$7F,d1
	add.w	d1,d0
	lea	levelLayout.w,a1
	move.b	(a1,d0.w),d1

	lea	.ChunkList,a2			; Get list of 3D ramp chunks

.CheckChunk:
	move.b	(a2)+,d0			; Are we in a 3D ramp chunk at all?
	bmi.s	.NotFound			; If not, branch
	cmp.b	d0,d1				; Have we found the 3D ramp chunk that we are in?
	bne.s	.CheckChunk			; If not, keep searching
	bset	#1,oPlayerCtrl(a0)		; Mark as on a 3D ramp
	rts

.NotFound:
	bclr	#1,oPlayerCtrl(a0)		; Mark as not on a 3D ramp
	beq.s	.End				; If we weren't on one to begin with, branch
	tst.w	oYVel(a0)			; Are we moving upwards?
	bpl.s	.End				; If not, branch
	cmpi.w	#-$800,oYVel(a0)		; Are we launching off the 3D ramp?
	bcc.s	.End				; If not, branch

	move.w	#$600,oXVel(a0)			; Gain a horizontal boost off the 3D ramp
	btst	#0,oFlags(a0)
	beq.s	.End
	neg.w	oXVel(a0)

.End:
	rts

; -------------------------------------------------------------------------

.ChunkList:
	dc.b	6
	dc.b	7
	dc.b	8
	dc.b	$44
	dc.b	$45
	dc.b	$46
	dc.b	$49
	dc.b	-1

; -------------------------------------------------------------------------
; Handle Sonic's movement on the ground
; -------------------------------------------------------------------------

ObjSonic_MoveGround:
	move.w	sonicTopSpeed.w,d6		; Get top speed
	move.w	sonicAcceleration.w,d5		; Get acceleration
	move.w	sonicDeceleration.w,d4		; Get deceleration

	tst.b	waterSlideFlag.w		; Are we on a water slide?
	bne.w	.CalcXYVels			; If so, branch
	tst.w	oPlayerMoveLock(a0)		; Is our movement locked temporarily?
	bne.w	.ResetScreen			; If so, branch

	btst	#2,playerCtrlHold.w		; Are we holding left?
	beq.s	.NotLeft			; If not, branch
	bsr.w	ObjSonic_MoveGndLeft		; Move left

.NotLeft:
	btst	#3,playerCtrlHold.w		; Are we holding right
	beq.s	.NotRight			; If not, branch
	bsr.w	ObjSonic_MoveGndRight		; Move right

.NotRight:
	move.b	oAngle(a0),d0			; Are we on firm on the ground?
	addi.b	#$20,d0
	andi.b	#$C0,d0
	bne.w	.ResetScreen			; If not, branch
	tst.w	oPlayerGVel(a0)			; Are we moving at all?
	beq.s	.Stand				; If not, branch
	tst.b	oPlayerCharge(a0)		; Are we charging a peelout or spindash?
	beq.w	.ResetScreen			; If not, branch
	bra.s	.CheckBalance			; Check for balancing

.Stand:
	bclr	#5,oFlags(a0)			; Stop pushing
	move.b	#5,oAnim(a0)			; Set animation to idle animation

; -------------------------------------------------------------------------

.CheckBalance:
	btst	#3,oFlags(a0)			; Are we standing on an object?
	beq.s	.BalanceGround			; If not, branch

	moveq	#0,d0				; Get the object we are standing on
	move.b	oPlayerStandObj(a0),d0
	lsl.w	#6,d0
	lea	objects.w,a1
	lea	(a1,d0.w),a1
	tst.b	oFlags(a1)			; Is it a special hazardous object?
	bmi.s	.CheckCharge			; If so, branch
	cmpi.b	#$1E,oID(a1)			; Is it a pinball flipper from CCZ?
	bne.s	.CheckObjBalance		; If not, branch
	move.b	#0,oAnim(a0)			; Set animation to walking animation
	bra.w	.ResetScreen			; Reset screen position

.CheckObjBalance:
	moveq	#0,d1				; Get distance from an edge of the object
	move.b	oWidth(a1),d1
	move.w	d1,d2
	add.w	d2,d2
	subq.w	#4,d2
	add.w	oX(a0),d1
	sub.w	oX(a1),d1
	cmpi.w	#4,d1				; Are we at least 4 pixels away from the left edge?
	blt.s	.BalanceLeft			; If so, branch
	cmp.w	d2,d1				; Are we at least 4 pixels away from the right edge?
	bge.s	.BalanceRight			; If so, branch
	bra.s	.CheckCharge			; Check for peelout/spindash charge

.BalanceGround:
	jsr	ObjGetFloorDist			; Are we leaning near a ledge on either side?
	cmpi.w	#$C,d1
	blt.s	.CheckCharge			; If not, branch
	cmpi.b	#3,oPlayerPriAngle(a0)		; Are we leaning near a ledge on the right?
	bne.s	.CheckLeft			; If not, branch

.BalanceRight:
	btst	#0,oFlags(a0)			; Are we facing left?
	bne.s	.BalanceAniBackwards		; If so, use the backwards animation
	bra.s	.BalanceAniForwards		; Use the forwards animation

.CheckLeft:
	cmpi.b	#3,oPlayerSecAngle(a0)		; Are we leaning near a ledge on the left?
	bne.s	.CheckCharge			; If not, branch

.BalanceLeft:
	btst	#0,oFlags(a0)			; Are we facing left?
	bne.s	.BalanceAniForwards		; If so, use the forwards animation

.BalanceAniBackwards:
	move.b	#$32,oAnim(a0)			; Set animation to balancing backwards animation
	bra.w	.ResetScreen			; Reset screen position

.BalanceAniForwards:
	move.b	#6,oAnim(a0)			; Set animation to balancing forwards animation
	bra.w	.ResetScreen			; Reset screen position

; -------------------------------------------------------------------------

.CheckCharge:
	move.b	lookMode.w,d0			; Get double tap timer
	andi.b	#$F,d0
	beq.s	.DblTapNotInit			; If it's not active, branch
	addq.b	#1,lookMode.w			; Increment timer
	andi.b	#$CF,lookMode.w			; Cap the timer properly

.DblTapNotInit:
	btst	#7,lookMode.w			; Is the look up flag set?
	bne.w	.LookUp				; If so, branch
	btst	#6,lookMode.w			; Is the look down flag set?
	bne.w	.CheckForSpindash		; If so, branch

	btst	#1,playerCtrlHold.w		; Is down being held?
	bne.w	.CheckForSpindash		; If so, branch
	andi.b	#$F,lookMode.w			; Clear out look flags
	beq.s	.CheckUpPress			; If the double tap timer wasn't set, branch

	btst	#0,playerCtrlTap.w		; Have we double tapped up?
	beq.s	.CheckUpHeld			; If not, branch
	bset	#7,lookMode.w			; Set the look up flag
	bra.w	.Settle				; Settle movement

.CheckUpPress:
	btst	#0,playerCtrlTap.w		; Have we just pressed up?
	beq.w	.CheckUpHeld			; If not, branch
	move.b	#1,lookMode.w			; Set the double tap timer to be active
	bra.w	.Settle				; Settle movement

.CheckUpHeld:
	btst	#0,playerCtrlHold.w		; Are we holding up?
	beq.s	.CheckUnleashPeelout		; If not, branch

	move.b	#7,oAnim(a0)			; Set animation to looking up animation
	tst.b	oPlayerCharge(a0)		; Are we charging a peelout?
	beq.s	.CheckStartCharge		; If not, branch

; -------------------------------------------------------------------------

.Peelout:
	move.b	#0,oAnim(a0)			; Set animation to charging peelout animation

	moveq	#100,d0				; Get charge speed increment value
	move.w	sonicTopSpeed.w,d1		; Get max charge speed (top speed * 2)
	move.w	d1,d2
	asl.w	#1,d1
	tst.b	speedShoes			; Do we have speed shoes?
	beq.s	.NoSpeedShoes			; If not, branch
	asr.w	#1,d2				; Get max charge speed for speed shoes ((top speed * 2) - (top speed / 2))
	sub.w	d2,d1

.NoSpeedShoes:
	btst	#0,oFlags(a0)			; Are we facing left?
	beq.s	.IncPeeloutCharge		; If not, branch
	neg.w	d0				; Negate the charge speed increment value
	neg.w	d1				; Negate the max charge speed

.IncPeeloutCharge:
	add.w	d0,oPlayerGVel(a0)		; Increment charge speed

	move.w	oPlayerGVel(a0),d0		; Get current charge speed
	btst	#0,oFlags(a0)			; Are we facing left?
	beq.s	.CheckMaxRight			; If not, branch
	cmp.w	d0,d1				; Have we reached the max charge speed?
	ble.s	.SetChargeSpeed			; If not, branch
	bra.s	.CapCharge			; If so, cap it

.CheckMaxRight:
	cmp.w	d1,d0				; Have we reached the max charge speed?
	ble.s	.SetChargeSpeed			; If not, branch

.CapCharge:
	move.w	d1,d0				; Cap the charge speed

.SetChargeSpeed:
	move.w	d0,oPlayerGVel(a0)		; Update the charge speed
	rts

.CheckStartCharge:
	move.b	playerCtrlTap.w,d0		; Did we press A, B, or C while we were holding up?
	andi.b	#$70,d0
	beq.s	.DontCharge			; If not, branch

	move.b	#1,oPlayerCharge(a0)		; Set the look double tap timer to be active
	move.w	#FM_9C,d0			; Play charge sound
	jsr	PlayFMSound

.DontCharge:
	bra.w	.Settle				; Settle movement

.CheckUnleashPeelout:
	cmpi.b	#30,oPlayerCharge(a0)		; Have we fully charged the peelout?
	beq.s	.UnleashPeelout			; If so, branch

	move.w	#FM_CHARGESTOP,d0		; Play charge stop sound
	jsr	PlayFMSound
	move.b	#0,oPlayerCharge(a0)		; Stop charging
	move.w	#0,oPlayerGVel(a0)
	bra.s	.CheckForSpindash		; Check for spindash

.UnleashPeelout:
	move.b	#0,oPlayerCharge(a0)		; Stop charging
	move.w	#FM_91,d0			; Play charge release sound
	jsr	PlayFMSound
	bra.w	.ResetScreen			; Reset screen position

; -------------------------------------------------------------------------

	bsr.w	ObjSonic_MoveGndLeft		; Move left
	bra.w	.ResetScreen			; Reset screen position

; -------------------------------------------------------------------------

.LookUp:
	btst	#0,playerCtrlHold.w		; Are we holding up?
	beq.s	.CheckForSpindash		; If not, branch

	move.b	#7,oAnim(a0)			; Set animation to looking up animation
	cmpi.w	#$C8,camYCenter.w		; Has the screen scrolled up all the way?
	beq.w	.Settle				; If so, branch
	addq.w	#2,camYCenter.w			; Move the screen up
	bra.w	.Settle				; Settle movement

; -------------------------------------------------------------------------

.CheckForSpindash:
	btst	#6,lookMode.w			; Is the look down flag set?
	bne.w	.Duck				; If so, branch
	andi.b	#$F,lookMode.w			; Clear out the look flags
	beq.s	.CheckDownPress			; If the double tap timer wasn't set, branch

	btst	#1,playerCtrlTap.w		; Have we double tapped down?
	beq.s	.CheckSpindash			; If not, branch
	bset	#6,lookMode.w			; Set the look down flag
	bra.w	.Settle				; Settle movement

.CheckDownPress:
	btst	#1,playerCtrlTap.w		; Have we just pressed down?
	beq.s	.CheckSpindash			; If not, branch
	move.b	#1,lookMode.w			; Set the double tap timer to be active
	bra.w	.Settle				; Settle movement

.CheckSpindash:
	btst	#1,playerCtrlHold.w		; Are we holding down?
	beq.s	.ResetScreen			; If not, branch

	move.b	#8,oAnim(a0)			; Set animation to ducking animation
	tst.b	oPlayerCharge(a0)		; Are we charging a spindash?
	bne.s	.DoSettle			; If so, branch

	move.b	playerCtrlTap.w,d0		; Did we press A, B, or C while we were holding down?
	andi.b	#$70,d0
	beq.s	.DoSettle			; If not, branch

	move.b	#1,oPlayerCharge(a0)		; Set the look double tap timer to be active
	move.w	#$16,oPlayerGVel(a0)		; Set initial spindash charge speed
	btst	#0,oFlags(a0)
	beq.s	.PlaySpindashSound
	neg.w	oPlayerGVel(a0)

.PlaySpindashSound:
	move.w	#FM_9C,d0			; Play charge sound
	jsr	PlayFMSound
	bsr.w	ObjSonic_StartRoll		; Start rolling for the spindash

.DoSettle:
	bra.s	.Settle				; Settle movement

; -------------------------------------------------------------------------

.Duck:
	btst	#1,playerCtrlHold.w		; Are we holding down?
	beq.s	.ResetScreen			; If not, branch

	move.b	#8,oAnim(a0)			; Set animation to ducking animation
	cmpi.w	#8,camYCenter.w			; Has the screen scrolled dowm all the way?
	beq.s	.Settle				; If so, branch
	subq.w	#2,camYCenter.w			; Move the screen down
	bra.s	.Settle				; Settle movement

; -------------------------------------------------------------------------

.ResetScreen:
	cmpi.w	#$60,camYCenter.w		; Is the screen centered?
	bne.s	.CheckIncShift			; If not, branch

	move.b	lookMode.w,d0			; Get look double tap timer
	andi.b	#$F,d0
	bne.s	.Settle				; If it's active, branch
	move.b	#0,lookMode.w			; Reset double tap timer and charge lock flags
	bra.s	.Settle				; Settle movement

.CheckIncShift:
	bcc.s	.DecShift			; If the screen needs to move back down, branch
	addq.w	#4,camYCenter.w			; Move the screen back up

.DecShift:
	subq.w	#2,camYCenter.w			; Move the screen back down

; -------------------------------------------------------------------------

.Settle:
	move.b	playerCtrlHold.w,d0		; Are we holding left or right?
	andi.b	#$C,d0
	bne.s	.CalcXYVels			; If so, branch

	move.w	oPlayerGVel(a0),d0		; Get current ground velocity
	beq.s	.CalcXYVels			; If we aren't moving at all, branch
	bmi.s	.SettleLeft			; If we are moving left, branch

	sub.w	d5,d0				; Settle right
	bcc.s	.SetGVel			; If we are still moving, branch
	move.w	#0,d0				; Stop moving

.SetGVel:
	move.w	d0,oPlayerGVel(a0)		; Update ground velocity
	bra.s	.CalcXYVels			; Calculate X and Y velocities

.SettleLeft:
	add.w	d5,d0				; Settle left
	bcc.s	.SetGVel2			; If we are still moving, branch
	move.w	#0,d0				; Stop moving

.SetGVel2:
	move.w	d0,oPlayerGVel(a0)		; Update ground velocity

.CalcXYVels:
	move.b	oAngle(a0),d0			; Get sine and cosine of our current angle
	jsr	CalcSine
	muls.w	oPlayerGVel(a0),d1		; Get X velocity (ground velocity * cos(angle))
	asr.l	#8,d1
	move.w	d1,oXVel(a0)
	muls.w	oPlayerGVel(a0),d0		; Get Y velocity (ground velocity * sin(angle))
	asr.l	#8,d0
	move.w	d0,oYVel(a0)

; -------------------------------------------------------------------------
; Handle wall collision for Sonic
; -------------------------------------------------------------------------

ObjSonic_CheckWallCol:
	move.b	oAngle(a0),d0			; Are we moving on a ceiling?
	addi.b	#$40,d0
	bmi.s	.End				; If so, branch

	move.b	#$40,d1				; Get angle to point the sensor towards (angle +/- 90 degrees)
	tst.w	oPlayerGVel(a0)
	beq.s	.End
	bmi.s	.RotAngle
	neg.w	d1

.RotAngle:
	move.b	oAngle(a0),d0
	add.b	d1,d0

	move.w	d0,-(sp)			; Get distance from wall
	bsr.w	Player_CalcRoomInFront
	move.w	(sp)+,d0
	tst.w	d1
	bpl.s	.End				; If we aren't colliding with a wall, branch
	asl.w	#8,d1				; Get zip distance

	addi.b	#$20,d0				; Get the angle of the wall
	andi.b	#$C0,d0
	beq.s	.ZipUp				; If we are facing a wall downwards, branch
	cmpi.b	#$40,d0				; Are we facing a wall on the left?
	beq.s	.ZipRight			; If so, branch
	cmpi.b	#$80,d0				; Are we facing a wall upwards?
	beq.s	.ZipDown			; If so, branch

.ZipLeft:
	add.w	d1,oXVel(a0)			; Zip to the left
	bset	#5,oFlags(a0)			; Mark as pushing
	move.w	#0,oPlayerGVel(a0)		; Stop moving
	rts

.ZipDown:
	sub.w	d1,oYVel(a0)			; Zip downwards
	rts

.ZipRight:
	sub.w	d1,oXVel(a0)			; Zip to the right
	bset	#5,oFlags(a0)			; Mark as pushing
	move.w	#0,oPlayerGVel(a0)		; Stop moving
	rts

.ZipUp:
	add.w	d1,oYVel(a0)			; Zip upwards

.End:
	rts

; -------------------------------------------------------------------------
; Move Sonic left on the ground
; -------------------------------------------------------------------------

ObjSonic_MoveGndLeft:
	tst.b	oPlayerCharge(a0)		; Are we charging a peelout or spindash?
	bne.s	.End				; If so, branch

	move.w	oPlayerGVel(a0),d0		; Get current ground velocity
	beq.s	.Normal				; If we aren't moving at all, branch
	bpl.s	.Skid				; If we are moving right, branch

.Normal:
	bset	#0,oFlags(a0)			; Face left
	bne.s	.Accelerate			; If we were already facing left, branch
	bclr	#5,oFlags(a0)			; Stop pushing
	move.b	#1,oPrevAnim(a0)		; Reset animation

.Accelerate:
	move.w	d6,d1				; Get top speed
	neg.w	d1
	cmp.w	d1,d0				; Have we already reached it?
	ble.s	.SetGVel			; If so, branch
	sub.w	d5,d0				; Apply acceleration
	cmp.w	d1,d0				; Have we reached top speed?
	bgt.s	.SetGVel			; If not, branch
	move.w	d1,d0				; Cap our velocity

.SetGVel:
	move.w	d0,oPlayerGVel(a0)		; Update ground velocity
	move.b	#0,oAnim(a0)			; Set animation to walking animation
	rts

.Skid:
	sub.w	d4,d0				; Apply deceleration
	bcc.s	.SetGVel2			; If we are still moving right, branch
	move.w	#-$80,d0			; If we are now moving left, set velocity to -0.5

.SetGVel2:
	move.w	d0,oPlayerGVel(a0)		; Update ground velocity

	move.b	oAngle(a0),d0			; Are we on a floor?
	addi.b	#$20,d0
	andi.b	#$C0,d0
	bne.s	.End				; If not, branch
	cmpi.w	#$400,d0			; Is our ground velocity at least 4?
	blt.s	.End				; If not, branch

	move.b	#$D,oAnim(a0)			; Set animation to skidding animation
	bclr	#0,oFlags(a0)			; Face right
	move.w	#FM_SKID,d0			; Play skidding sound
	jsr	PlayFMSound

.End:
	rts

; -------------------------------------------------------------------------
; Move Sonic right on the ground
; -------------------------------------------------------------------------

ObjSonic_MoveGndRight:
	tst.b	oPlayerCharge(a0)		; Are we charging a peelout or spindash?
	bne.s	.End				; If so, branch

	move.w	oPlayerGVel(a0),d0		; Get current ground velocity
	bmi.s	.Skid

.Normal:
	bclr	#0,oFlags(a0)			; Face right
	beq.s	.Accelerate			; If we were already facing right, branch
	bclr	#5,oFlags(a0)			; Stop pushing
	move.b	#1,oPrevAnim(a0)		; Reset animation

.Accelerate:
	cmp.w	d6,d0				; Have we already reached top speed?
	bge.s	.SetGVel			; If so, branch
	add.w	d5,d0				; Apply acceleration
	cmp.w	d6,d0				; Have we reached top speed?
	blt.s	.SetGVel			; If not, branch
	move.w	d6,d0				; Cap our velocity

.SetGVel:
	move.w	d0,oPlayerGVel(a0)		; Update ground velocity
	move.b	#0,oAnim(a0)			; Set animation to walking animation
	rts

.Skid:
	add.w	d4,d0				; Apply deceleration
	bcc.s	.SetGVel2			; If we are still moving left, branch
	move.w	#$80,d0				; If we are now moving right, set velocity to 0.5

.SetGVel2:
	move.w	d0,oPlayerGVel(a0)		; Update ground velocity

	move.b	oAngle(a0),d0			; Are we on a floor?
	addi.b	#$20,d0
	andi.b	#$C0,d0
	bne.s	.End				; If not, branch
	cmpi.w	#-$400,d0			; Is our ground velocity at least -4?
	bgt.s	.End				; If not, branch

	move.b	#$D,oAnim(a0)			; Set animation to skidding animation
	bset	#0,oFlags(a0)			; Face left
	move.w	#FM_SKID,d0			; Play skidding sound
	jsr	PlayFMSound

.End:
	rts

; -------------------------------------------------------------------------
; Handle Sonic's movement while rolling on the ground
; -------------------------------------------------------------------------

ObjSonic_MoveRoll:
	move.w	sonicTopSpeed.w,d6		; Get top speed (multiplied by 2)
	asl.w	#1,d6
	move.w	sonicAcceleration.w,d5		; Get acceleration (divided by 2)
	asr.w	#1,d5
	move.w	sonicDeceleration.w,d4		; Get deceleration (divided by 4)
	asr.w	#2,d4

	tst.b	waterSlideFlag.w		; Are we on a water slide?
	bne.w	.CalcXYVels			; If so, branch
	tst.w	oPlayerMoveLock(a0)		; Is our movement locked temporarily?
	bne.s	.NotRight			; If so, branch

	btst	#2,playerCtrlHold.w		; Are we holding left?
	beq.s	.NotLeft			; If not, branch
	bsr.w	ObjSonic_MoveRollLeft		; Move left

.NotLeft:
	btst	#3,playerCtrlHold.w		; Are we holding right
	beq.s	.NotRight			; If not, branch
	bsr.w	ObjSonic_MoveRollRight		; Move right

.NotRight:
	tst.b	oPlayerCharge(a0)		; Are we charging a spindash?
	beq.w	.Settle				; If not, branch

; -------------------------------------------------------------------------

.Spindash:
	move.w	#50,d0				; Get charge speed increment value
	move.w	sonicTopSpeed.w,d1		; Get max charge speed (top speed * 2)
	move.w	d1,d2
	asl.w	#1,d1
	tst.b	speedShoes			; Do we have speed shoes?
	beq.s	.NoSpeedShoes			; If not, branch
	asr.w	#1,d2				; Get max charge speed for speed shoes ((top speed * 2) - (top speed / 2))
	sub.w	d2,d1

.NoSpeedShoes:
	btst	#0,oFlags(a0)			; Are we facing left?
	beq.s	.IncSpindashCharge		; If not, branch
	neg.w	d0				; Negate the charge speed increment value
	neg.w	d1				; Negate the max charge speed

.IncSpindashCharge:
	add.w	d0,oPlayerGVel(a0)		; Increment charge speed

	move.w	oPlayerGVel(a0),d0		; Get current charge speed
	btst	#0,oFlags(a0)			; Are we facing left?
	beq.s	.CheckMaxRight			; If not, branch
	cmp.w	d0,d1				; Have we reached the max charge speed?
	ble.s	.SetChargeSpeed			; If not, branch
	bra.s	.CapCharge			; If so, cap it

.CheckMaxRight:
	cmp.w	d1,d0				; Have we reached the max charge speed?
	ble.s	.SetChargeSpeed			; If not, branch

.CapCharge:
	move.w	d1,d0				; Cap the charge speed

.SetChargeSpeed:
	move.w	d0,oPlayerGVel(a0)		; Update the charge speed

	btst	#1,playerCtrlHold.w		; Are we holding down?
	beq.s	.NotDown			; If not, branch
	rts

.ChargeNotFull:
	move.w	#FM_CHARGESTOP,d0		; Play charge stop sound
	jsr	PlayFMSound

	move.b	#0,oPlayerCharge(a0)		; Stop charging
	move.w	#0,oPlayerGVel(a0)
	move.w	#0,oXVel(a0)
	move.w	#0,oYVel(a0)

	bra.w	.StopRolling			; Stop rolling

.NotDown:
	cmpi.b	#45,oPlayerCharge(a0)		; Have we fully charged the spindash?
	bne.s	.ChargeNotFull			; If not, branch

	move.b	#0,oPlayerCharge(a0)		; Stop charging
	move.w	#FM_91,d0			; Play charge release sound
	jsr	PlayFMSound

	btst	#0,oFlags(a0)			; Are we facing left?
	bne.s	.ChargeLeft			; If so, branch
	bsr.w	ObjSonic_MoveRollRight		; Charge towards the right
	bra.s	.Settle				; Settle movement

.ChargeLeft:
	bsr.w	ObjSonic_MoveRollLeft		; Charge towards the left
	bra.s	.Settle				; Settle movement
	rts

; -------------------------------------------------------------------------

.Settle:
	move.w	oPlayerGVel(a0),d0		; Get current ground velocity
	beq.s	.CheckStopRoll			; If we aren't moving at all, branch
	bmi.s	.SettleLeft			; If we are moving left, branch

	sub.w	d5,d0				; Settle right
	bcc.s	.SetGVel			; If we are still moving, branch
	move.w	#0,d0				; Stop moving

.SetGVel:
	move.w	d0,oPlayerGVel(a0)		; Update ground velocity
	bra.s	.CheckStopRoll			; Calculate X and Y velocities

.SettleLeft:
	add.w	d5,d0				; Settle left
	bcc.s	.SetGVel2			; If we are still moving, branch
	move.w	#0,d0				; Stop moving

.SetGVel2:
	move.w	d0,oPlayerGVel(a0)		; Update ground velocity

.CheckStopRoll:
	tst.w	oPlayerGVel(a0)			; Are we still moving?
	bne.s	.CalcXYVels			; If so, branch

.StopRolling:
	bclr	#2,oFlags(a0)			; Stop rolling

	tst.b	miniSonic			; Are we miniature?
	beq.s	.NotMini			; If not, branch
	move.b	#$A,oYRadius(a0)		; Restore miniature hitbox size
	move.b	#5,oXRadius(a0)
	bra.s	.ResetAnim

.NotMini:
	move.b	#$13,oYRadius(a0)		; Restore hitbox size
	move.b	#9,oXRadius(a0)
	subq.w	#5,oY(a0)

.ResetAnim:
	move.b	#5,oAnim(a0)			; Set animation to idle animation

.CalcXYVels:
	move.b	oAngle(a0),d0			; Get sine and cosine of our current angle
	jsr	CalcSine
	muls.w	oPlayerGVel(a0),d0		; Get Y velocity (ground velocity * sin(angle))
	asr.l	#8,d0
	move.w	d0,oYVel(a0)
	muls.w	oPlayerGVel(a0),d1		; Get X velocity (ground velocity * cos(angle))
	asr.l	#8,d1
	cmpi.w	#$1000,d1			; Is the X velocity greater than 16?
	ble.s	.CheckCapLeft			; If not, branch
	move.w	#$1000,d1			; Cap the X velocity at 16

.CheckCapLeft:
	cmpi.w	#-$1000,d1			; Is the X velocity less than -16?
	bge.s	.SetXVel			; If not, branch
	move.w	#-$1000,d1			; Cap the X velocity at -16

.SetXVel:
	move.w	d1,oXVel(a0)			; Set X velocity

	bra.w	ObjSonic_CheckWallCol		; Handle wall collision

; -------------------------------------------------------------------------
; Move Sonic left on the ground while rolling
; -------------------------------------------------------------------------

ObjSonic_MoveRollLeft:
	move.w	oPlayerGVel(a0),d0		; Get current ground velocity
	beq.s	.StartRoll			; If we aren't moving at all, branch
	bpl.s	.DecelRoll			; If we are moving right, branch

.StartRoll:
	bset	#0,oFlags(a0)			; Face left
	move.b	#2,oAnim(a0)			; Set animation to rolling animation
	rts

.DecelRoll:
	sub.w	d4,d0				; Apply deceleration
	bcc.s	.SetGVel			; If we are still moving right, branch
	move.w	#-$80,d0			; If we are now moving left, set velocity to -0.5

.SetGVel:
	move.w	d0,oPlayerGVel(a0)		; Update ground velocity
	rts

; -------------------------------------------------------------------------
; Move Sonic right on the ground while rolling
; -------------------------------------------------------------------------

ObjSonic_MoveRollRight:
	move.w	oPlayerGVel(a0),d0		; Get current ground velocity
	bmi.s	.DecelRoll			; If we are moving left, branch

.StartRoll:
	bclr	#0,oFlags(a0)			; Face right
	move.b	#2,oAnim(a0)			; Set animation to rolling animation
	rts

.DecelRoll:
	add.w	d4,d0				; Apply deceleration
	bcc.s	.SetGVel			; If we are still moving left, branch
	move.w	#$80,d0				; If we are now moving left, set velocity to 0.5

.SetGVel:
	move.w	d0,oPlayerGVel(a0)		; Update ground velocity
	rts

; -------------------------------------------------------------------------
; Handle Sonic's movement in the air
; -------------------------------------------------------------------------

ObjSonic_MoveAir:
	move.w	sonicTopSpeed.w,d6		; Get top speed
	move.w	sonicAcceleration.w,d5		; Get acceleration (multiplied by 2)
	asl.w	#1,d5

	move.w	oXVel(a0),d0			; Get current X velocity

	tst.w	zoneAct				; Are we in Palmtree Panic?
	bne.s	.CheckLeft			; If not, branch

	cmpi.w	#$6C8,oX(a0)			; Are we left of the first 3D ramp launch area?
	bcs.s	.Check3DRamp			; If so, branch
	cmpi.w	#$840,oX(a0)			; Are we right of the first 3D ramp launch area?
	bcs.s	.SetXVel			; If not, branch

.Check3DRamp:
	btst	#1,oPlayerCtrl(a0)		; Are we on a 3D ramp?
	bne.s	.SetXVel			; If so, branch

.CheckLeft:
	btst	#2,playerCtrlHold.w		; Are we holding left?
	beq.s	.CheckRight			; If not, branch
	bset	#0,oFlags(a0)			; Face left
	sub.w	d5,d0				; Apply acceleration
	move.w	d6,d1				; Get top speed
	neg.w	d1
	cmp.w	d1,d0				; Have we reached top speed?
	bgt.s	.CheckRight			; If not, branch
	move.w	d1,d0				; Cap at top speed

.CheckRight:
	btst	#3,playerCtrlHold.w		; Are we holding right?
	beq.s	.SetXVel			; If not, branch
	bclr	#0,oFlags(a0)			; Face right
	add.w	d5,d0				; Apply acceleration
	cmp.w	d6,d0				; Have we reached top speed?
	blt.s	.SetXVel			; If not, branch
	move.w	d6,d0				; Cap at top speed

.SetXVel:
	move.w	d0,oXVel(a0)			; Update X velocity

; -------------------------------------------------------------------------

.ResetScreen:
	cmpi.w	#$60,camYCenter.w		; Is the screen centered?
	beq.s	.CheckDrag			; If not, branch
	bcc.s	.DecShift			; If the screen needs to move back down, branch
	addq.w	#4,camYCenter.w			; Move the screen back up

.DecShift:
	subq.w	#2,camYCenter.w			; Move the screen back down

; -------------------------------------------------------------------------

.CheckDrag:
	cmpi.w	#-$400,oYVel(a0)		; Are we moving upwards at a velocity greater than -4?
	bcs.s	.End				; If not, branch

	move.w	oXVel(a0),d0			; Get air drag value (X velocity / $20)
	move.w	d0,d1
	asr.w	#5,d1
	beq.s	.End				; If there is no air drag to apply, branch
	bmi.s	.DecLXVel			; If we are moving left, branch

.DecRXVel:
	sub.w	d1,d0				; Apply air drag
	bcc.s	.SetRAirDrag			; If we haven't stopped horizontally, branch
	move.w	#0,d0				; Stop our horizontal movement

.SetRAirDrag:
	move.w	d0,oXVel(a0)			; Update X velocity
	rts

.DecLXVel:
	sub.w	d1,d0				; Apply air drag
	bcs.s	.SetLAirDrag			; If we haven't stopped horizontally, branch
	move.w	#0,d0				; Stop our horizontal movement

.SetLAirDrag:
	move.w	d0,oXVel(a0)			; Update X velocity

.End:
	rts

; -------------------------------------------------------------------------
; Leftover unused function from Sonic 1 that handles squashing Sonic
; -------------------------------------------------------------------------

ObjSonic_CheckSquash:
	move.b	oAngle(a0),d0			; Are we on the floor?
	addi.b	#$20,d0
	andi.b	#$C0,d0
	bne.s	.End				; If not, branch

	bsr.w	Player_CheckCeiling		; Are we also colliding with the ceiling?
	tst.w	d1
	bpl.s	.End				; If not, branch

	move.w	#0,oPlayerGVel(a0)		; Stop movement
	move.w	#0,oXVel(a0)
	move.w	#0,oYVel(a0)
	move.b	#$B,oAnim(a0)			; Set animation to squished/warping animation (leftover from Sonic 1)

.End:
	rts

; -------------------------------------------------------------------------
; Handle level boundaries for Sonic
; -------------------------------------------------------------------------

ObjSonic_LevelBound:
	move.l	oX(a0),d1			; Get X position for horizontal boundary checking (X position + X velocity)
	move.w	oXVel(a0),d0
	ext.l	d0
	asl.l	#8,d0
	add.l	d0,d1
	swap	d1

	move.w	leftBound.w,d0			; Have we crossed the left boundary?
	addi.w	#16,d0
	cmp.w	d1,d0
	bhi.s	.Sides				; If so, branch

	move.w	rightBound.w,d0			; Get right boundary
	addi.w	#320-16,d0
	tst.b	bossFight.w			; Are we in a boss fight?
	bne.s	.ScreenLocked			; If so, branch
	addi.w	#56,d0				; If not, extend the boundary beyond the screen

.ScreenLocked:
	cmp.w	d1,d0				; Have we crossed the right boundary?
	bls.s	.Sides				; If so, branch

.CheckBottom:
	move.w	bottomBound.w,d0		; Have we crossed the bottom boundary?
	addi.w	#224,d0
	cmp.w	oY(a0),d0
	blt.s	.Bottom				; If so, branch
	rts

.Bottom:
	cmpi.b	#$2B,oAnim(a0)			; Is the player giving up from boredom?
	bne.w	KillPlayer			; If not, kill Sonic as normal
	move.b	#6,oRoutine(a0)			; If so, just set the routine to death
	rts

.Sides:
	move.w	d0,oX(a0)			; Stop at the boundary
	move.w	#0,oXSub(a0)
	move.w	#0,oXVel(a0)
	move.w	#0,oPlayerGVel(a0)
	bra.s	.CheckBottom			; Continue checking for bottom boundary collision

; -------------------------------------------------------------------------
; Check for rolling for Sonic
; -------------------------------------------------------------------------

ObjSonic_CheckRoll:
	tst.b	waterSlideFlag.w		; Are we on a water slide?
	bne.s	.End				; If so, branch

	move.w	oPlayerGVel(a0),d0		; Get absolute value of our ground velocity
	bpl.s	.PosInertia
	neg.w	d0

.PosInertia:
	cmpi.w	#$80,d0				; Is it at least 0.5?
	bcs.s	.End				; If not, branch
	move.b	playerCtrlHold.w,d0		; Are we holding left or right?
	andi.b	#$C,d0
	bne.s	.End				; If not, branch
	btst	#1,playerCtrlHold.w		; Are we holding down?
	bne.s	ObjSonic_StartRoll		; If so, branch

.End:
	rts

; -------------------------------------------------------------------------
; Make Sonic start rolling
; -------------------------------------------------------------------------

ObjSonic_StartRoll:
	btst	#2,oFlags(a0)			; Are we already rolling?
	beq.s	.DoRoll				; If not, branch
	rts

.DoRoll:
	bset	#2,oFlags(a0)			; Mark as rolling
	tst.b	miniSonic			; Are we miniature?
	beq.s	.NotMini			; If not, branch
	move.b	#$A,oYRadius(a0)		; Set miniature rolling hitbox size
	move.b	#5,oXRadius(a0)
	bra.s	.SetRollAnim			; Set animatiion

.NotMini:
	move.b	#$E,oYRadius(a0)		; Set rolling hitbox size
	move.b	#7,oXRadius(a0)
	addq.w	#5,oY(a0)

.SetRollAnim:
	move.b	#2,oAnim(a0)			; Set animation to rolling animation

	tst.w	oPlayerGVel(a0)			; Are we moving?
	bne.s	.End				; If so, branch
	move.w	#$200,oPlayerGVel(a0)		; If not, get a slight boost

.End:
	rts

; -------------------------------------------------------------------------
; Check for jumping for Sonic
; -------------------------------------------------------------------------

ObjSonic_CheckJump:
	tst.b	oPlayerCharge(a0)		; Are we charging a peelout or spindash?
	beq.s	.CanJump			; If not, branch
	rts

.CanJump:
	move.b	playerCtrlHold.w,d0		; Are we holding up or down?
	andi.b	#3,d0
	beq.s	.NotUpDown			; If not, branch
	tst.w	oPlayerGVel(a0)			; Are we moving at all?
	beq.w	.End				; If not, branch

.NotUpDown:
	move.b	playerCtrlTap.w,d0		; Have we pressed A, B, or C?
	andi.b	#$70,d0
	beq.w	.End				; If not, branch

	btst	#3,oFlags(a0)			; Are we standing on an object?
	beq.s	.NotOnObj			; If not, branch
	jsr	ObjSonic_ChkFlipper		; Check if we are on a pinball flipper, and if so, get the angle and speed to launch at
	beq.s	.GotAngle			; If we were on a pinball flipper, branch

.NotOnObj:
	moveq	#0,d0				; Get the amount of space over our head
	move.b	oAngle(a0),d0
	addi.b	#$80,d0
	bsr.w	Player_CalcRoomOverHead
	cmpi.w	#6,d1				; Is there at least 6 pixels of space?
	blt.w	.End				; If not, branch

	move.w	#$680,d2			; Get jump speed (6.5)
	btst	#6,oFlags(a0)			; Are we underwater?
	beq.s	.NoWater			; If not, branch
	move.w	#$380,d2			; Get underwater jump speed (3.5)

.NoWater:
	moveq	#0,d0				; Get our angle on the ground
	move.b	oAngle(a0),d0
	subi.b	#$40,d0

.GotAngle:
	jsr	CalcSine			; Get the sine and cosine of our angle
	muls.w	d2,d1				; Get X velocity to jump at (jump speed * cos(angle))
	asr.l	#8,d1
	add.w	d1,oXVel(a0)
	muls.w	d2,d0				; Get Y velocity to jump at (jump speed * sin(angle))
	asr.l	#8,d0
	add.w	d0,oYVel(a0)

	bset	#1,oFlags(a0)			; Mark as in air
	bclr	#5,oFlags(a0)			; Stop pushing
	addq.l	#4,sp				; Stop handling ground specific routines after this
	move.b	#1,oPlayerJump(a0)		; Mark as jumping
	clr.b	oPlayerStick(a0)		; Mark as not sticking to terrain
	clr.b	lookMode.w			; Reset look double tap timer and flags

	move.w	#FM_JUMP,d0			; Play jump sound
	jsr	PlayFMSound

	btst	#2,oFlags(a0)			; Were we rolling?
	bne.s	.RollJump			; If so, branch
	tst.b	miniSonic			; Are we miniature?
	beq.s	.SetJumpSize			; If not, branch
	move.b	#$A,oYRadius(a0)		; Set miniature jumping hitbox size
	move.b	#5,oXRadius(a0)
	bra.s	.StartJump			; Mark as jumping

.SetJumpSize:
	move.b	#$E,oYRadius(a0)		; Set jumping hitbox size
	move.b	#7,oXRadius(a0)
	addq.w	#5,oY(a0)

.StartJump:
	bset	#2,oFlags(a0)			; Mark as rolling
	move.b	#2,oAnim(a0)			; Set animation to rolling animation

.End:
	rts

.RollJump:
	bset	#4,oFlags(a0)			; Mark as roll-jumping
	rts

; -------------------------------------------------------------------------
; Handle Sonic's jump height
; -------------------------------------------------------------------------

ObjSonic_JumpHeight:
	tst.b	oPlayerJump(a0)			; Are we jumping?
	beq.s	.NotJump			; If not, branch

	move.w	#-$400,d1			; Get minimum jump velocity
	btst	#6,oFlags(a0)			; Are we underwater?
	beq.s	.GotCapVel			; If not, branch
	move.w	#-$200,d1			; Get minimum underwater jump velocity

.GotCapVel:
	cmp.w	oYVel(a0),d1			; Are we going up faster than the minimum jump velocity?
	ble.s	.End				; If so, branch
	move.b	playerCtrlHold.w,d0		; Are we holding A, B, or C?
	andi.b	#$70,d0
	bne.s	.End				; If so, branch

	move.b	#0,oPlayerCharge(a0)		; Stop charging
	move.w	d1,oYVel(a0)			; Cap our Y velocity at the minimum jump velocity

.End:
	rts

.NotJump:
	rts

; -------------------------------------------------------------------------
; Handle slope resistance for Sonic
; -------------------------------------------------------------------------

ObjSonic_SlopeResist:
	tst.b	oPlayerCharge(a0)		; Are we charging a peelout or spindash?
	bne.s	.End2				; If so, branch

	move.b	oAngle(a0),d0			; Are we on a ceiling?
	addi.b	#$60,d0
	cmpi.b	#$C0,d0
	bcc.s	.End2				; If so, branch

	move.b	oAngle(a0),d0			; Get slope resistance value (sin(angle) / 8)
	jsr	CalcSine
	muls.w	#$20,d0
	asr.l	#8,d0

	tst.w	oPlayerGVel(a0)			; Are we moving at all?
	beq.s	.End2				; If not, branch
	bmi.s	.MovingLeft			; If we are moving left, branch
	tst.w	d0				; Is the slope resistance value 0?
	beq.s	.End				; If so, branch
	add.w	d0,oPlayerGVel(a0)		; Apply slope resistance

.End:
	rts

.MovingLeft:
	add.w	d0,oPlayerGVel(a0)		; Apply slope resistance

.End2:
	rts

; -------------------------------------------------------------------------
; Handle slope resistance for Sonic while rolling
; -------------------------------------------------------------------------

ObjSonic_SlopeResistRoll:
	tst.b	oPlayerCharge(a0)		; Are we charging a peelout or spindash?
	bne.s	.End				; If so, branch

	move.b	oAngle(a0),d0			; Are we on a ceiling?
	addi.b	#$60,d0
	cmpi.b	#$C0,d0
	bcc.s	.End				; If so, branch

	move.b	oAngle(a0),d0			; Get slope resistance value (sin(angle) / 3.2)
	jsr	CalcSine
	muls.w	#$50,d0
	asr.l	#8,d0

	tst.w	oPlayerGVel(a0)			; Are we moving at all?
	bmi.s	.MovingLeft			; If we are moving left, branch
	tst.w	d0				; Is the slope resistance value positive?
	bpl.s	.ApplyResist			; If so, branch
	asr.l	#2,d0				; If it's negative, divide it by 4

.ApplyResist:
	add.w	d0,oPlayerGVel(a0)		; Apply slope resistance
	rts

.MovingLeft:
	tst.w	d0				; Is the slope resistance value negatie?
	bmi.s	.ApplyResist2			; If so, branch
	asr.l	#2,d0				; If it's positive, divide it by 4

.ApplyResist2:
	add.w	d0,oPlayerGVel(a0)		; Apply slope resistance

.End:
	rts

; -------------------------------------------------------------------------
; Check if Sonic should fall off a steep slope or ceiling
; -------------------------------------------------------------------------

ObjSonic_CheckFallOff:
	nop
	tst.b	oPlayerStick(a0)		; Are we stuck to the terrain?
	bne.s	.End				; If so, branch
	tst.w	oPlayerMoveLock(a0)		; Is our movement currently temporarily locked?
	bne.s	.RunMoveLock			; If so, branch

	move.b	oAngle(a0),d0			; Are we on a steep enough slope or ceiling?
	addi.b	#$20,d0
	andi.b	#$C0,d0
	beq.s	.End				; If not, branch

	move.w	oPlayerGVel(a0),d0		; Get current ground speed
	bpl.s	.CheckSpeed
	neg.w	d0

.CheckSpeed:
	cmpi.w	#$280,d0			; Is our ground speed less than 2.5?
	bcc.s	.End				; If not, branch

	clr.w	oPlayerGVel(a0)			; Set ground velocity to 0
	bset	#1,oFlags(a0)			; Mark as in air
	move.w	#30,oPlayerMoveLock(a0)		; Set movement lock timer

.End:
	rts

.RunMoveLock:
	subq.w	#1,oPlayerMoveLock(a0)		; Decrement movement lock timer
	rts

; -------------------------------------------------------------------------
; Reset Sonic's angle in the air
; -------------------------------------------------------------------------

ObjSonic_JumpAngle:
	btst	#1,oPlayerCtrl(a0)		; Are we on a 3D ramp?
	bne.s	.End				; If so, branch

	move.b	oAngle(a0),d0			; Get current angle
	beq.s	.End				; If it's 0, branch
	bpl.s	.DecPosAngle			; If it's positive, branch

	addq.b	#2,d0				; Slowly set angle back to 0
	bcc.s	.DontCap
	moveq	#0,d0

.DontCap:
	bra.s	.SetNewAngle			; Update the angle value

.DecPosAngle:
	subq.b	#2,d0				; Slowly set angle back to 0
	bcc.s	.SetNewAngle
	moveq	#0,d0

.SetNewAngle:
	move.b	d0,oAngle(a0)			; Update angle

.End:
	rts

; -------------------------------------------------------------------------
; Handle level collision while in the air
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

Player_LevelColInAir:
	move.w	oXVel(a0),d1			; Get the angle that we are moving at
	move.w	oYVel(a0),d2
	jsr	CalcAngle

	move.b	d0,debugAngle			; Update debug angle buffers
	subi.b	#$20,d0
	move.b	d0,debugAngleShift
	andi.b	#$C0,d0
	move.b	d0,debugQuadrant

	cmpi.b	#$40,d0				; Are we moving left?
	beq.w	Player_LvlColAir_Left		; If so, branch
	cmpi.b	#$80,d0				; Are we moving up?
	beq.w	Player_LvlColAir_Up		; If so, branch
	cmpi.b	#$C0,d0				; Are we moving right?
	beq.w	Player_LvlColAir_Right		; If so, branch

; -------------------------------------------------------------------------
; Handle level collision while moving downwards in the air
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

Player_LvlColAir_Down:
	bsr.w	Player_GetLWallDist		; Are we colliding with a wall on the left?
	tst.w	d1
	bpl.s	.NotLeftWall			; If not, branch

	sub.w	d1,oX(a0)			; Move outside of the wall
	move.w	#0,oXVel(a0)			; Stop moving horizontally

.NotLeftWall:
	bsr.w	Player_GetRWallDist		; Are we colliding with a wall on the right?
	tst.w	d1
	bpl.s	.NotRightWall			; If not, branch

	add.w	d1,oX(a0)			; Move outside of the wall
	move.w	#0,oXVel(a0)			; Stop moving horizontally

.NotRightWall:
	bsr.w	Player_CheckFloor		; Are we colliding with the floor?
	move.b	d1,debugFloorDist
	tst.w	d1
	bpl.s	.End				; If not, branch

	move.b	oYVel(a0),d2			; Are we moving too fast downwards?
	addq.b	#8,d2
	neg.b	d2
	cmp.b	d2,d1
	bge.s	.NotFallThrough			; If not, branch
	cmp.b	d2,d0
	blt.s	.End				; If so, branch

.NotFallThrough:
	add.w	d1,oY(a0)			; Move outside of the floor
	move.b	d3,oAngle(a0)			; Set angle
	bsr.w	Player_ResetOnFloor		; Reset flags
	move.b	#0,oAnim(a0)			; Set animation to walking animation

	move.b	d3,d0				; Did we land on a steep slope?
	addi.b	#$20,d0
	andi.b	#$40,d0
	bne.s	.LandSteepSlope			; If so, branch

	move.b	d3,d0				; Did we land on a more flat surface?
	addi.b	#$10,d0
	andi.b	#$20,d0
	beq.s	.LandFloor			; If so, branch

.LandSlope:
	asr	oYVel(a0)			; Halve the landing speed
	bra.s	.KeepYVel

.LandFloor:
	move.w	#0,oYVel(a0)			; Stop moving vertically
	move.w	oXVel(a0),oPlayerGVel(a0)	; Set landing speed
	rts

.LandSteepSlope:
	move.w	#0,oXVel(a0)			; Stop moving horizontally
	cmpi.w	#$FC0,oYVel(a0)			; Is our landing speed greater than 15.75?
	ble.s	.KeepYVel			; If not, branch
	move.w	#$FC0,oYVel(a0)			; Cap it at 15.75

.KeepYVel:
	move.w	oYVel(a0),oPlayerGVel(a0)	; Set landing speed
	tst.b	d3				; Is our angle 0-$7F?
	bpl.s	.End				; If so, branch
	neg.w	oPlayerGVel(a0)			; If not, negate our landing speed

.End:
	rts

; -------------------------------------------------------------------------
; Handle level collision while moving left in the air
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

Player_LvlColAir_Left:
	bsr.w	Player_GetLWallDist		; Are we colliding with a wall on the left?
	tst.w	d1
	bpl.s	.NotLeftWall			; If not, branch

	sub.w	d1,oX(a0)			; Move outside of the wall
	move.w	#0,oXVel(a0)			; Stop moving horizontally
	move.w	oYVel(a0),oPlayerGVel(a0)	; Set landing speed
	rts

.NotLeftWall:
	bsr.w	Player_CheckCeiling		; Are we colliding with a ceiling?
	tst.w	d1
	bpl.s	.NotCeiling			; If not, branch

	sub.w	d1,oY(a0)			; Move outside of the ceiling
	tst.w	oYVel(a0)			; Were we moving upwards?
	bpl.s	.End				; If not, branch
	move.w	#0,oYVel(a0)			; If so, stop moving vertically

.End:
	rts

.NotCeiling:
	tst.w	oYVel(a0)			; Are we moving upwards?
	bmi.s	.End2				; If so, branch

	bsr.w	Player_CheckFloor		; Are we colliding with the floor?
	tst.w	d1
	bpl.s	.End2				; If not, branch

	add.w	d1,oY(a0)			; Move outside of the floor
	move.b	d3,oAngle(a0)			; Set angle
	bsr.w	Player_ResetOnFloor		; Reset flags
	move.b	#0,oAnim(a0)			; Set animation to walking animation
	move.w	#0,oYVel(a0)			; Stop moving vertically
	move.w	oXVel(a0),oPlayerGVel(a0)	; Set landing speed

.End2:
	rts

; -------------------------------------------------------------------------
; Handle level collision while moving upwards in the air
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

Player_LvlColAir_Up:
	bsr.w	Player_GetLWallDist		; Are we colliding with a wall on the left?
	tst.w	d1
	bpl.s	.NotLeftWall			; If not, branch

	sub.w	d1,oX(a0)			; Move outside of the wall
	move.w	#0,oXVel(a0)			; Stop moving horizontally

.NotLeftWall:
	bsr.w	Player_GetRWallDist		; Are we colliding with a wall on the right?
	tst.w	d1
	bpl.s	.NotRightWall			; If not, branch

	add.w	d1,oX(a0)			; Move outside of the wall
	move.w	#0,oXVel(a0)			; Stop moving horizontally

.NotRightWall:
	bsr.w	Player_CheckCeiling		; Are we colliding with a ceiling?
	tst.w	d1
	bpl.s	.End				; If not, branch

	sub.w	d1,oY(a0)			; Move outside of the ceiling

	move.b	d3,d0				; Did we land on a steep slope?
	addi.b	#$20,d0
	andi.b	#$40,d0
	bne.s	.LandSteepSlope			; If so, branch

.LandCeiling:
	move.w	#0,oYVel(a0)			; Stop moving vertically
	rts

.LandSteepSlope:
	move.b	d3,oAngle(a0)			; Set angle
	bsr.w	Player_ResetOnSteepSlope	; Reset flags
	move.w	oYVel(a0),oPlayerGVel(a0)	; Set landing speed

	tst.b	d3				; Is our angle 0-$7F?
	bpl.s	.End				; If so, branch
	neg.w	oPlayerGVel(a0)			; If not, negate our landing speed

.End:
	rts

; -------------------------------------------------------------------------
; Handle level collision while moving right in the air
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

Player_LvlColAir_Right:
	bsr.w	Player_GetRWallDist		; Are we colliding with a wall on the right?
	tst.w	d1
	bpl.s	.NotRightWall			; If not, branch

	add.w	d1,oX(a0)			; Move outside of the wall
	move.w	#0,oXVel(a0)			; Stop moving horizontally
	move.w	oYVel(a0),oPlayerGVel(a0)	; Set landing speed
	rts

.NotRightWall:
	bsr.w	Player_CheckCeiling		; Are we colliding with a ceiling?
	tst.w	d1
	bpl.s	.NotCeiling			; If not, branch

	sub.w	d1,oY(a0)			; Move outside of the ceiling
	tst.w	oYVel(a0)			; Were we moving upwards?
	bpl.s	.End				; If not, branch
	move.w	#0,oYVel(a0)			; If so, stop moving vertically

.End:
	rts

.NotCeiling:
	tst.w	oYVel(a0)			; Are we moving upwards?
	bmi.s	.End2				; If so, branch

	bsr.w	Player_CheckFloor		; Are we colliding with the floor?
	tst.w	d1
	bpl.s	.End2				; If not, branch

	add.w	d1,oY(a0)			; Move outside of the floor
	move.b	d3,oAngle(a0)			; Set angle
	bsr.w	Player_ResetOnFloor		; Reset flags
	move.b	#0,oAnim(a0)			; Set animation to walking animation
	move.w	#0,oYVel(a0)			; Stop moving vertically
	move.w	oXVel(a0),oPlayerGVel(a0)	; Set landing speed

.End2:
	rts

; -------------------------------------------------------------------------
; Reset flags for when the player lands on the floor
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

Player_ResetOnFloor:
	btst	#4,oFlags(a0)			; Did we jump after rolling?
	beq.s	.NoRollJump			; If not, branch
	nop

.NoRollJump:
	bclr	#5,oFlags(a0)			; Stop puishing
 	bclr	#1,oFlags(a0)			; Mark as on the ground
	bclr	#4,oFlags(a0)			; Clear roll jump flag

	btst	#2,oFlags(a0)			; Did we land from a jump?
	beq.s	.NotJumping			; If not, branch
	bclr	#2,oFlags(a0)			; Mark as not jumping

	tst.b	miniSonic			; Are we miniature?
	beq.s	.NormalSize			; If not, branch

	move.b	#$A,oYRadius(a0)		; Restore miniature hitbox size
	move.b	#5,oXRadius(a0)
	bra.s	.LandSound			; Continue resetting more flags

.NormalSize:
	move.b	#$13,oYRadius(a0)		; Restore hitbox size
	move.b	#9,oXRadius(a0)
	subq.w	#5,oY(a0)

.LandSound:
	move.b	#0,oAnim(a0)			; Set animation to walking animation

.NotJumping:
	move.b	#0,oPlayerJump(a0)		; Clear jumping flag
	move.w	#0,scoreChain.w			; Clear chain bonus counter
	rts

; -------------------------------------------------------------------------
; Reset flags for when the player lands on a steep slope
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

Player_ResetOnSteepSlope:
	bclr	#5,oFlags(a0)			; Stop puishing
 	bclr	#1,oFlags(a0)			; Mark as on the ground
	bclr	#4,oFlags(a0)			; Clear roll jump flag
	move.b	#0,oPlayerJump(a0)		; Clear jumping flag
	move.w	#0,scoreChain.w			; Clear chain bonus counter
	rts

; -------------------------------------------------------------------------
; Sonic's hurt routine
; -------------------------------------------------------------------------

ObjSonic_Hurt:
	jsr	ObjMove				; Apply velocity

	addi.w	#$30,oYVel(a0)			; Make gravity stronger
	btst	#6,oFlags(a0)			; Is Sonic underwater?
	beq.s	.NoWater			; If not, branch
	subi.w	#$20,oYVel(a0)			; Make the gravity less strong underwater

.NoWater:
	bsr.w	ObjSonic_HurtChkLand		; Check for landing on the ground
	bsr.w	ObjSonic_LevelBound		; Handle level boundary collision
	bsr.w	ObjSonic_RecordPos		; Save current position into the position buffer
	bsr.w	ObjSonic_Animate		; Animate sprite

	jmp	DrawObject			; Draw sprite

; -------------------------------------------------------------------------
; Check for Sonic landing on the ground while hurting
; -------------------------------------------------------------------------

ObjSonic_HurtChkLand:
	move.w	bottomBound.w,d0		; Have we gone past the bottom level boundary?
	addi.w	#224,d0
	cmp.w	oY(a0),d0
	bcs.w	KillPlayer			; If so, branch

	bsr.w	Player_LevelColInAir		; Handle level collision
	btst	#1,oFlags(a0)			; Are we still in the air?
	bne.s	.End				; If so, branch

	moveq	#0,d0				; Stop movement
	move.w	d0,oYVel(a0)
	move.w	d0,oXVel(a0)
	move.w	d0,oPlayerGVel(a0)
	move.b	#0,oAnim(a0)			; Set animation to walking animation
	subq.b	#2,oRoutine(a0)			; Go back to the main routine
	move.w	#120,oPlayerHurt(a0)		; Set hurt time

.End:
	rts

; -------------------------------------------------------------------------
; Sonic's death routine
; -------------------------------------------------------------------------

ObjSonic_Dead:
	bsr.w	ObjSonic_DeadChkGone		; Check if we have gone offscreen

	jsr	ObjMoveGrv			; Apply velocity
	bsr.w	ObjSonic_RecordPos		; Save current position into the position buffer
	bsr.w	ObjSonic_Animate		; Animate sprite

	jmp	DrawObject			; Draw sprite

; -------------------------------------------------------------------------
; Check for Sonic going offscreen when he's dead
; -------------------------------------------------------------------------

ObjSonic_DeadChkGone:
	move.w	bottomBound.w,d0		; Have we gone past the bottom level boundary?
	addi.w	#256,d0
	cmp.w	oY(a0),d0
	bcc.w	.End				; If not, branch

	move.w	#-$38,oYVel(a0)			; Make us go upwards a little
	addq.b	#2,oRoutine(a0)			; Set routine to gone

	clr.b	updateHUDTime			; Stop the level timer
	addq.b	#1,updateHUDLives		; Decrement life counter
	subq.b	#1,lives
	bpl.s	.CapLives			; If we still have lives left, branch
	clr.b	lives				; Cap lives at 0

.CapLives:
	cmpi.b	#$2B,oAnim(a0)			; Were we giving up from boredom?
	beq.s	.LoadGameOver			; If so, branch

	tst.b	timeAttackMode			; Are we in time attack mode?
	beq.s	.LoadGameOver			; If not, branch

	move.b	#0,lives			; Set lives to 0
	bra.s	.ResetDelay			; Continue setting the delay timer

.LoadGameOver:
	jsr	FindObjSlot			; Load the game over text object
	move.b	#$3B,oID(a1)

	move.w	#8*60,oPlayerReset(a0)		; Set game over delay timer to 8 seconds
	tst.b	lives				; Do we still have lives left?
	beq.s	.End				; If not, branch

.ResetDelay:
	move.w	#60,oPlayerReset(a0)		; Set delay timer to 1 second

.End:
	rts

; -------------------------------------------------------------------------
; Handle Sonic's death delay timer and handle level reseting
; -------------------------------------------------------------------------

ObjSonic_Restart:
	tst.w	oPlayerReset(a0)		; Is the delay timer active?
	beq.w	.End				; If not, branch
	subq.w	#1,oPlayerReset(a0)		; Decrement the delay timer
	bne.w	.End				; If it hasn't run out, branch

	move.w	#1,levelRestart			; Set to restart the level

	bsr.w	ResetSavedObjFlags		; Reset saved object flags
	clr.l	flowerCount			; Reset flower count

	tst.b	checkpoint			; Have we hit a checkpoint?
	bne.s	.Skip				; If so, branch
	cmpi.b	#1,timeZone			; Are we in the present?
	bne.s	.Skip				; If not, branch
	bclr	#1,plcLoadFlags			; Set to reload the title card upon restarting

.Skip:
	move.w	#SCMD_FADECDA,d0		; Set to fade out music

	tst.b	lives				; Are we out of lives?
	beq.s	.SendCmd			; If so, branch
	cmpi.b	#1,timeZone			; Are we in the present?
	bne.s	.SpawnAtStart			; If not, branch
	tst.b	checkpoint			; Have we hit a checkpoint?
	beq.s	.SendCmd			; If not, branch

	move.b	#1,spawnMode			; Spawn at checkpoint
	bra.s	.SendCmd			; Continue setting the fade out command

.SpawnAtStart:
	clr.b	spawnMode			; Spawn at beginning

.SendCmd:
	bra.w	SubCPUCmd			; Set the fade out command

.End:
	rts

; -------------------------------------------------------------------------
; Handle special chunks for Sonic
; -------------------------------------------------------------------------

ObjSonic_SpecialChunks:
	rts					; This is dummied out in Wacky Workbench

	cmpi.b	#5,zone				; Are we in Stardust Speedway?
	beq.s	.HasSpecChunks			; If so, branch
	cmpi.b	#2,zone				; Are we in Tidal Tempest?
	beq.s	.HasSpecChunks			; If so, branch
	tst.b	zone				; Are we in Palmtree Panic?
	bne.w	.End				; If not, branch

.HasSpecChunks:
	move.w	oY(a0),d0			; Get current chunk that we are in
	lsr.w	#1,d0
	andi.w	#$380,d0
	move.b	oX(a0),d1
	andi.w	#$7F,d1
	add.w	d1,d0
	lea	levelLayout.w,a1
	move.b	(a1,d0.w),d1

; -------------------------------------------------------------------------

	cmp.b	specialChunks+2.w,d1		; Are we in a special roll tunnel?
	bne.s	.NotRoll			; If not, branch
	tst.b	zone				; Are we in Palmtree Panic?
	bne.w	.RollTunnel			; If not, branch

	move.w	oY(a0),d0			; Is our Y position greater than or equal to $90?
	andi.w	#$FF,d0
	cmpi.w	#$90,d0
	bcc.w	.RollTunnel			; If so, branch

	bra.s	.CheckIfLoop			; Continue checking other chunks

.NotRoll:
	cmp.b	specialChunks+3.w,d1		; Are we in a regular roll tunnel?
	beq.w	.RollTunnel			; If so, branch

; -------------------------------------------------------------------------

.CheckIfLoop:
	cmp.b	specialChunks.w,d1		; Are we on a loop?
	beq.s	.CheckIfLeft			; If so, branch
	cmp.b	specialChunks+1.w,d1		; Are we on a special loop?
	beq.s	.CheckIfInAir			; If so, branch

	bclr	#6,oSprFlags(a0)		; Set to lower path layer
	rts

.CheckIfInAir:
	cmpi.b	#5,zone				; Are we in Stardust Speedway?
	beq.w	.SSZ				; If so, branch

	btst	#1,oFlags(a0)			; Are we in the air?
	beq.s	.CheckIfLeft			; If not, branch
	bclr	#6,oSprFlags(a0)		; Set to lower path layer
	rts

.CheckIfLeft:
	rts					; This code is dummied out

	move.w	oX(a0),d2			; Are we left of the loop check section?
	cmpi.b	#$2C,d2
	bcc.s	.CheckIfRight			; If not, branch
	bclr	#6,oSprFlags(a0)		; Set to lower path layer
	rts

.CheckIfRight:
	cmpi.b	#$E0,d2				; Are we right of the loop check section?
	bcs.s	.CheckAngle			; If not, branch
	bset	#6,oSprFlags(a0)		; Set to higher path layer
	rts

.CheckAngle:
	btst	#6,oSprFlags(a0)		; Are we on the higher path layer?
	bne.s	.HighPath			; If so, branch

	move.b	oAngle(a0),d1			; Get angle
	beq.s	.End				; If we are flat on the floor, branch

	cmpi.b	#$80,d1				; Are right of the path swap position?
	bhi.s	.End				; If so, branch
	bset	#6,oSprFlags(a0)		; Set to higher path layer
	rts

.HighPath:
	move.b	oAngle(a0),d1			; Are left of the path swap position?
	cmpi.b	#$80,d1
	bls.s	.End				; If so, branch
	bclr	#6,oSprFlags(a0)		; Set to lower path layer

.End:
	rts

; -------------------------------------------------------------------------

.RollTunnel:
	if REGION<>USA
		move.w	#FM_9C,d0		; Play roll sound
		jsr	PlayFMSound
	endif
	jmp	ObjSonic_StartRoll		; Start rolling

; -------------------------------------------------------------------------

.SSZ:
	tst.w	oYVel(a0)			; Are we moving upwards?
	bmi.s	.End2				; If so, branch

	move.w	oY(a0),d1			; Get position within chunk
	andi.w	#$FF,d1
	move.w	oX(a0),d0
	andi.w	#$FF,d0

	cmpi.w	#$80,d0				; Are we on the right side of the chunk?
	bcc.s	.CheckIfAbove			; If so, branch
	cmpi.w	#$38,d1				; Are we at the top of the chunk?
	bcs.s	.SetLowPlane			; If so, branch
	cmpi.w	#$80,d1				; Are we on the top side of the chunk?
	bcs.s	.End2				; If so, branch

.SetHighPlane:
	bclr	#6,oSprFlags(a0)		; Set to lower path layer
	rts

.SetLowPlane:
	bset	#6,oSprFlags(a0)		; Set to higher path layer
	rts

.CheckIfAbove:
	cmpi.w	#$38,d1				; Are we at the top of the chunk?
	bcs.s	.SetHighPlane			; If so, branch
	cmpi.w	#$80,d1				; Are we on the bottom side of the chunk?
	bcc.s	.SetLowPlane			; If so, branch

.End2:
	rts

; -------------------------------------------------------------------------
; Animate Sonic's sprite
; -------------------------------------------------------------------------

ObjSonic_Animate:
	lea	Ani_Sonic,a1			; Get animation script

	moveq	#0,d0				; Get current animation
	move.b	oAnim(a0),d0
	cmp.b	oPrevAnim(a0),d0		; Are we changing animations?
	beq.s	.Do				; If not, branch

	move.b	d0,oPrevAnim(a0)		; Reset animation flags
	move.b	#0,oAnimFrame(a0)
	move.b	#0,oAnimTime(a0)

.Do:
	bsr.w	ObjSonic_GetMiniAnim		; If we are miniature, get the mini version of the current animation

	add.w	d0,d0				; Get pointer to animation data
	adda.w	(a1,d0.w),a1
	move.b	(a1),d0				; Get animation speed/special flag
	bmi.s	.SpecialAnim			; If it's a special flag, branch

	move.b	oFlags(a0),d1			; Apply horizontal flip flag
	andi.b	#%00000001,d1
	andi.b	#%11111100,oSprFlags(a0)
	or.b	d1,oSprFlags(a0)

	subq.b	#1,oAnimTime(a0)		; Decrement frame duration time
	bpl.s	.AniDelay			; If it hasn't run out, branch
	move.b	d0,oAnimTime(a0)		; Reset frame duration time

; -------------------------------------------------------------------------

.RunAnimScript:
	moveq	#0,d1				; Get animation frame
	move.b	oAnimFrame(a0),d1
	move.b	1(a1,d1.w),d0
	beq.s	.AniNext			; If it's a frame ID, branch
	bpl.s	.AniNext
	cmpi.b	#$FD,d0				; Is it a flag?
	bge.s	.AniFF				; If so, branch

.AniNext:
	move.b	d0,oMapFrame(a0)		; Update animation frame
	addq.b	#1,oAnimFrame(a0)

.AniDelay:
	rts

.AniFF:
	addq.b	#1,d0				; Is the flag $FF (loop)?
	bne.s	.AniFE				; If not, branch

	move.b	#0,oAnimFrame(a0)		; Set animation script frame back to 0
	move.b	1(a1),d0			; Get animation frame at that point
	bra.s	.AniNext

.AniFE:
	addq.b	#1,d0				; Is the flag $FE (loop back to frame)?
	bne.s	.AniFD

	move.b	2(a1,d1.w),d0			; Get animation script frame to go back to
	sub.b	d0,oAnimFrame(a0)
	sub.b	d0,d1				; Get animation frame at that point
	move.b	1(a1,d1.w),d0
	bra.s	.AniNext

.AniFD:
	addq.b	#1,d0				; Is the flag $FD (new animation)?
	bne.s	.End
	move.b	2(a1,d1.w),oAnim(a0)		; Set new animation ID

.End:
	rts

; -------------------------------------------------------------------------

.SpecialAnim:
	subq.b	#1,oAnimTime(a0)		; Decrement frame duration time
	bpl.s	.AniDelay			; If it hasn't run out, branch

	addq.b	#1,d0				; Is this special animation $FF (walking/running)?
	bne.w	.RollAnim			; If not, branch

	tst.b	miniSonic			; Are we minature?
	bne.w	.MiniSonicRun			; If so, branch

	moveq	#0,d1				; Initialize flip flags
	move.b	oAngle(a0),d0			; Get angle
	move.b	oFlags(a0),d2			; Are we flipped horizontally?
	andi.b	#%00000001,d2
	bne.s	.Flipped			; If so, branch
	not.b	d0				; If not, flip the angle

.Flipped:
	btst	#1,oPlayerCtrl(a0)		; Are we on a 3D ramp?
	bne.s	.3DRamp				; If so, branch
	addi.b	#$10,d0				; Center the angle
	bra.s	.CheckInvert			; Continue setting up the animation

.3DRamp:
	addq.b	#8,d0				; Center the angle for the 3D ramp

.CheckInvert:
	bpl.s	.NoInvert			; If we aren't on an angle where we should flip the sprite, branch
	moveq	#%00000011,d1			; If we are, set the flip flags accordingly

.NoInvert:
	andi.b	#%11111100,oSprFlags(a0)	; Apply flip flags
	eor.b	d1,d2
	or.b	d2,oSprFlags(a0)

	btst	#5,oFlags(a0)			; Are we pushing on something?
	bne.w	.PushAnim			; If so, branch

	move.w	oPlayerGVel(a0),d2		; Get ground speed
	bpl.s	.CheckSpeed
	neg.w	d2

.CheckSpeed:
	btst	#1,oPlayerCtrl(a0)		; Are we on a 3D ramp?
	beq.s	.No3DRamp			; If not, branch

	lsr.b	#4,d0				; Get offset of the angled sprites we need for 3D running
	lsl.b	#1,d0				; ((((angle + 8) / 8) & 0xE) * 2)
	andi.b	#$E,d0				; (angle is NOT'd if we are facing right)

	lea	SonAni_Run3D,a1			; Get 3D running sprites
	bra.s	.GotRunAnim			; Continue setting up animation

.No3DRamp:
	lsr.b	#4,d0				; Get offset of the angled sprites we need for running and peelout
	andi.b	#6,d0				; ((((angle + 16) / 16) & 6) * 2)
						; (angle is NOT'd if we are facing right)

	lea	SonAni_Peelout,a1		; Get peelout sprites
	cmpi.w	#$A00,d2			; Are we running at peelout speed?
	bcc.s	.GotRunAnim			; If so, branch
	lea	SonAni_Run,a1			; Get running sprites
	cmpi.w	#$600,d2			; Are we running at running speed?
	bcc.s	.GotRunAnim			; If so, branch
	lea	SonAni_Walk,a1			; Get walking sprites

	move.b	d0,d1				; Get offset of the angled sprites we need for walking
	lsr.b	#1,d1				; ((((angle + 16) / 16) & 6) * 3)
	add.b	d1,d0				; (angle is NOT'd if we are facing right)

.GotRunAnim:
	add.b	d0,d0

	move.b	d0,d3				; Get animation duration
	neg.w	d2				; max(-ground speed + 8, 0)
	addi.w	#$800,d2
	bpl.s	.BelowMax
	moveq	#0,d2

.BelowMax:
	lsr.w	#8,d2
	move.b	d2,oAnimTime(a0)

	bsr.w	.RunAnimScript			; Run animation script
	add.b	d3,oMapFrame(a0)		; Add angle offset
	rts

; -------------------------------------------------------------------------

.RollAnim:
	addq.b	#1,d0				; Is this special animation $FE (rolling)?
	bne.s	.CheckPush			; If not, branch

	move.w	oPlayerGVel(a0),d2		; Get ground speed
	bpl.s	.CheckSpeed2
	neg.w	d2

.CheckSpeed2:
	lea	SonAni_RollMini,a1		; Get mini rolling sprites
	tst.b	miniSonic			; Are we miniature?
	bne.s	.GotRollAnim			; If so, branch

	lea	SonAni_RollFast,a1		; Get fast rolling sprites
	btst	#1,oPlayerCtrl(a0)		; Are we on a 3D ramp?
	beq.s	.No3DRoll			; If not, branch
	move.b	oAngle(a0),d0			; Are we going upwards on the ramp?
	addi.b	#$10,d0
	andi.b	#$C0,d0
	beq.s	.GotRollAnim			; If not, branch
	lea	SonAni_Roll3D,a1		; Get 3D rolling sprites
	bra.s	.GotRollAnim			; Continue setting up animation

.No3DRoll:
	cmpi.w	#$600,d2			; Are we rolling fast?
	bcc.s	.GotRollAnim			; If so, branch
	lea	SonAni_Roll,a1			; If not, use the regular rolling sprites

.GotRollAnim:
	neg.w	d2				; Get animation duration
	addi.w	#$400,d2			; max(-ground speed + 4, 0)
	bpl.s	.BelowMax2
	moveq	#0,d2

.BelowMax2:
	lsr.w	#8,d2
	move.b	d2,oAnimTime(a0)

	move.b	oFlags(a0),d1			; Apply horizontal flip flag
	andi.b	#%00000001,d1
	andi.b	#%11111100,oSprFlags(a0)
	or.b	d1,oSprFlags(a0)

	bra.w	.RunAnimScript			; Run animation script

; -------------------------------------------------------------------------

.CheckPush:
	addq.b	#1,d0				; Is this special animation $FD (pushing)?
	bne.s	.FrozenAnim			; If not, branch

.PushAnim:
	move.w	oPlayerGVel(a0),d2		; Get ground speed (negated)
	bmi.s	.CheckSpeed3
	neg.w	d2

.CheckSpeed3:
	addi.w	#$800,d2			; Get animation duration
	bpl.s	.BelowMax3			; max(-ground speed + 8, 0) * 4
	moveq	#0,d2

.BelowMax3:
	lsr.w	#6,d2
	move.b	d2,oAnimTime(a0)

	lea	SonAni_PushMini,a1		; Get mini pushing sprites
	tst.b	miniSonic			; Are we miniature?
	bne.s	.GotPushAnim			; If so, branch
	lea	SonAni_Push,a1			; Get normal pushing sprites

.GotPushAnim:
	move.b	oFlags(a0),d1			; Apply horizontal flip flag
	andi.b	#%00000001,d1
	andi.b	#%11111100,oSprFlags(a0)
	or.b	d1,oSprFlags(a0)

	bra.w	.RunAnimScript			; Run animation script

; -------------------------------------------------------------------------

.FrozenAnim:
	moveq	#0,d1				; This is special animation $FC (frozen animation)
	move.b	oAnimFrame(a0),d1		; Get animation frame
	move.b	1(a1,d1.w),oMapFrame(a0)
	move.b	#0,oAnimTime(a0)		; Keep duration at 0 and don't advance the animation frame
	rts

; -------------------------------------------------------------------------

.MiniSonicRun:
	moveq	#0,d1				; Initialize flip flags
	move.b	oAngle(a0),d0			; Get angle
	move.b	oFlags(a0),d2			; Are we flipped horizontally?
	andi.b	#$00000001,d2
	bne.s	.Flipped2			; If so, branch
	not.b	d0				; If not, flip the angle

.Flipped2:
	addi.b	#$10,d0				; Center the angle
	bpl.s	.NoFlip2			; If we aren't on an angle where we should flip the sprite, branch
	moveq	#0,d1				; If we are, then don't set the flags anyways

.NoFlip2:
	andi.b	#%11111100,oSprFlags(a0)	; Apply horizontal flip flag
	or.b	d2,oSprFlags(a0)

	addi.b	#$30,d0				; Are we running on the floor?
	cmpi.b	#$60,d0
	bcs.s	.MiniOnFloor			; If so, branch

	bset	#2,oFlags(a0)			; Mark as rolling
	move.b	#$A,oYRadius(a0)		; Set miniature rolling hitbox size
	move.b	#5,oXRadius(a0)
	move.b	#$FF,d0				; Go run the rolling animation instead
	bra.w	.RollAnim

.MiniOnFloor:
	move.w	oPlayerGVel(a0),d2		; Get ground speed
	bpl.s	.CheckSpeed4
	neg.w	d2

.CheckSpeed4:
	lea	SonAni_RunMini,a1		; Get mini running sprites
	cmpi.w	#$600,d2			; Are we running at running speed?
	bcc.s	.GotRunAnim2			; If so, branch
	lea	SonAni_WalkMini,a1		; Get mini walking sprites

.GotRunAnim2:
	neg.w	d2				; Get animation duration
	addi.w	#$800,d2			; max(-ground speed + 8, 0)
	bpl.s	.BelowMax4
	moveq	#0,d2

.BelowMax4:
	lsr.w	#8,d2
	move.b	d2,oAnimTime(a0)

	bra.w	.RunAnimScript			; Run animation script

; -------------------------------------------------------------------------
; Get the mini version of Sonic's animation if Sonic is miniature
; -------------------------------------------------------------------------

ObjSonic_GetMiniAnim:
	tst.b	miniSonic			; Are we miniature?
	beq.s	.End				; If not, branch
	move.b	.MiniAnims(pc,d0.w),d0		; Get mini animation ID

.End:
	rts

; -------------------------------------------------------------------------

.MiniAnims:
	dc.b	$21				; $00
	dc.b	$18				; $01
	dc.b	$23				; $02
	dc.b	$23				; $03
	dc.b	$27				; $04
	dc.b	$1F				; $05
	dc.b	$26				; $06
	dc.b	$28				; $07
	dc.b	$20				; $08
	dc.b	$09				; $09
	dc.b	$0A				; $0A
	dc.b	$0B				; $0B
	dc.b	$0C				; $0C
	dc.b	$24				; $0D
	dc.b	$0E				; $0E
	dc.b	$0F				; $0F
	dc.b	$28				; $10
	dc.b	$11				; $11
	dc.b	$12				; $12
	dc.b	$13				; $13
	dc.b	$14				; $14
	dc.b	$15				; $15
	dc.b	$16				; $16
	dc.b	$17				; $17
	dc.b	$18				; $18
	dc.b	$19				; $19
	dc.b	$25				; $1A
	dc.b	$25				; $1B
	dc.b	$1C				; $1C
	dc.b	$1D				; $1D
	dc.b	$1E				; $1E
	dc.b	$1F				; $1F
	dc.b	$20				; $20
	dc.b	$21				; $21
	dc.b	$22				; $22
	dc.b	$23				; $23
	dc.b	$24				; $24
	dc.b	$25				; $25
	dc.b	$26				; $26
	dc.b	$27				; $27
	dc.b	$28				; $28
	dc.b	$29				; $29
	dc.b	$2A				; $2A
	dc.b	$30				; $2B
	dc.b	$2C				; $2C
	dc.b	$2D				; $2D
	dc.b	$2E				; $2E
	dc.b	$2F				; $2F
	dc.b	$00				; $30
	dc.b	$00				; $31
	dc.b	$00				; $32
	dc.b	$00				; $33
	dc.b	$00				; $34
	dc.b	$00				; $35
	dc.b	$00				; $36
	dc.b	$00				; $37
	dc.b	$39				; $38
	dc.b	$00				; $39
	dc.b	$00				; $3A
	dc.b	$00				; $3B
	dc.b	$00				; $3C
	dc.b	$00				; $3D
	dc.b	$00				; $3E
	dc.b	$00				; $3F
	dc.b	$00				; $40
	dc.b	$00				; $41
	dc.b	$00				; $42
	dc.b	$00				; $43
	dc.b	$00				; $44
	dc.b	$00				; $45
	dc.b	$00				; $46
	dc.b	$00				; $47
	dc.b	$00				; $48
	dc.b	$00				; $49
	dc.b	$00				; $4A
	dc.b	$00				; $4B
	dc.b	$00				; $4C
	dc.b	$00				; $4D
	dc.b	$00				; $4E
	dc.b	$00				; $4F

; -------------------------------------------------------------------------
; Sonic's animation script
; -------------------------------------------------------------------------

Ani_Sonic:
	include	"Level/Wacky Workbench/Objects/Sonic/Data/Animations.asm"
	even

; -------------------------------------------------------------------------
; Load the tiles for Sonic's current sprite frame
; -------------------------------------------------------------------------

LoadSonicDynPLC:
	tst.b	(a0)				; Are we even loaded at all?
	beq.w	.End				; If not, branch

	lea	sonicLastFrame.w,a2		; Get the ID of the last sprite frame that was loaded
	moveq	#0,d0
	move.b	oMapFrame(a0),d0		; Get current sprite frame ID
	cmp.b	(a2),d0				; Has our sprite frame changed?
	beq.s	.End				; If not, branch
	move.b	d0,(a2)				; Update last sprite frame ID

	lea	DPLC_Sonic,a2			; Get DPLC data for our current sprite frame
	add.w	d0,d0
	adda.w	(a2,d0.w),a2

	moveq	#0,d1				; Get number of DPLC entries
	move.w	(a2)+,d1
	subq.b	#1,d1
	bmi.s	.End				; If there are none, branch

	lea	sonicArtBuf.w,a3		; Get sprite frame tile buffer
	move.b	#1,updateSonicArt.w		; Mark buffer as updated

.PieceLoop:
	moveq	#0,d2				; Get number of tiles to load
	move.b	(a2)+,d2
	move.w	d2,d0
	lsr.b	#4,d0

	lsl.w	#8,d2				; Get starting tile to load
	move.b	(a2)+,d2
	andi.w	#$FFF,d2
	lsl.l	#5,d2
	lea	Art_Sonic,a1
	adda.l	d2,a1

.CopyPieceLoop:
	movem.l	(a1)+,d2-d6/a4-a6		; Load tile data for this entry
	movem.l	d2-d6/a4-a6,(a3)
	lea	$20(a3),a3
	dbf	d0,.CopyPieceLoop		; Loop until all tiles in this entry are loaded

	dbf	d1,.PieceLoop			; Loop until all entries are processed

.End:
	rts

; -------------------------------------------------------------------------
; Check if Sonic is on a pinball flipper, and if so, get the angle to launch
; Sonic at when jumping off of it
; -------------------------------------------------------------------------
; RETURNS:
;	d0.b - Angle to launch at
;	d2.w - Speed to launch at
;	eq/ne - Was on flipper/Was not on flipper
; -------------------------------------------------------------------------

ObjSonic_ChkFlipper:
	moveq	#0,d0				; Get object we are standing on
	move.b	oPlayerStandObj(a0),d0
	lsl.w	#6,d0
	addi.l	#objPlayerSlot&$FFFFFF,d0
	movea.l	d0,a1

	cmpi.b	#$1E,oID(a1)			; Is it a pinball flipper from CCZ?
	bne.s	.End				; If not, branch

	move.b	#1,oAnim(a1)			; Set flipper animation to move

	move.w	oX(a1),d1			; Get angle in which to launch at
	move.w	oY(a1),d2			; arctan((object Y + 24 - player Y) / (object X - player X))
	addi.w	#24,d2
	sub.w	oX(a0),d1
	sub.w	oY(a0),d2
	jsr	CalcAngle

	moveq	#0,d2				; Get the amount of force used to get the speed to launch us at, depending on
	move.b	oWidth(a1),d2			; the distance we are from the flipper's rotation pivot
	move.w	oX(a0),d3			; (object width + (player X - object X))
	sub.w	oX(a1),d3
	add.w	d2,d3

	btst	#0,oFlags(a1)			; Is the flipper object flipped horizontally?
	bne.s	.XFlip				; If so, branch

	move.w	#64,d1				; Invert the force to account for the horizontal flip
	sub.w	d3,d1				; (64 - (object width + (player X - object X)))
	move.w	d1,d3

.XFlip:
	move.w	#-$A00,d2			; Get the speed to launch us at
	move.w	d2,d1				; (-10 + ((-10 * force) / 64))
	ext.l	d1
	muls.w	d3,d1
	divs.w	#64,d1
	add.w	d1,d2

	moveq	#0,d1				; Mark as having been on the flipper

.End:
	rts

; -------------------------------------------------------------------------
