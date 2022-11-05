; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Main function
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Leftover music ID list from Sonic 1
; -------------------------------------------------------------------------

LevelMusicIDs_S1:
	dc.b	$81, $82, $83, $84, $85, $86, $8D
	even

; -------------------------------------------------------------------------
; Level game mode
; -------------------------------------------------------------------------

LevelStart:
	clr.w	demoMode			; Clear demo mode flag

	cmpi.b	#$7F,timeStones			; Did we get all of the time stones?
	bne.s	.NotGoodFuture			; If not, branch
	tst.b	timeAttackMode			; Are we in time attack mode?
	bne.s	.NotGoodFuture			; If not, branch
	move.b	#1,goodFuture			; Force a good future

.NotGoodFuture:
	move.b	#0,levelStarted			; Mark the level as not started yet
	clr.b	vintRoutine.w			; Reset V-INT routine ID
	clr.b	usePlayer2			; Clear unused "use player 2" flag
	if DEMO<>0
		move.b	#0,checkpoint		; Reset checkpoint if in a demo
	endif
	move.b	#0,paused.w			; Clear pause flag

	bset	#0,plcLoadFlags			; Mark PLCs as loaded
	bne.s	.NoReset			; If they were loaded before, branch

	clr.b	palFadeFlags			; Mark palette fading as inactive
	clr.b	checkpoint			; Reset checkpoint
	move.l	#5000,nextLifeScore		; Reset next score for 1-UP

	bsr.w	ResetSavedObjFlags		; Reset saved object flags

	clr.b	spawnMode			; Spawn at beginning
	clr.b	goodFutureFlags			; Clear good future flags
	clr.l	score				; Clear score

	move.b	#3,lives			; Reset life count to 3
	tst.b	timeAttackMode			; Are we in time attack mode?
	beq.s	.NoReset			; If not, branch
	move.b	#1,lives			; Reset life count to 1

.NoReset:
	bset	#7,gameMode.w			; Mark level as initializing
	bsr.w	ClearPLCs			; Clear PLCs

	tst.b	specialStage			; Are we exiting from a special stage?
	bne.s	.FromSpecialStage		; If so, branch
	btst	#7,timeZone			; Were we time warping before?
	beq.s	.FadeToBlack			; If not, branch

	bset	#0,palFadeFlags			; Mark palette fading as active
	beq.s	.SkipFade			; If it was active before, branch

.FromSpecialStage:
	bsr.w	FadeToWhite			; Fade to white
	bclr	#0,palFadeFlags			; Mark palette fading as inactive

.SkipFade:
	clr.b	timeWarpDir.w			; Reset time warp direction
	tst.w	levelRestart			; Was the level restart flag set?
	beq.w	.CheckNormalLoad		; If not, branch
	move.w	#0,levelRestart			; Clear level restart flag
	cmpi.b	#2,act				; Are we in act 3?
	bne.s	.End				; If not, branch
	bclr	#7,timeZone			; Clear time warp flag

.End:
	rts

; -------------------------------------------------------------------------

.FadeToBlack:
	bset	#0,palFadeFlags			; Mark palette fading as active
	beq.s	.SkipFade2			; If it was active before, branch
	bsr.w	FadeToBlack			; Fade to black

.SkipFade2:
	cmpi.w	#2,levelRestart			; Were we going to the next level?
	bne.s	.CheckNoLives			; If not, branch
	move.w	#0,levelRestart			; Clear level restart flag
	move.b	#0,palFadeFlags			; Mark palette fading as inactive
	bra.s	.ClearPal			; Get out of here

.CheckNoLives:
	tst.b	lives				; Do we have any lives?
	bne.s	.CheckNormalLoad		; If so, branch
	move.b	#0,plcLoadFlags			; Mark PLCs as not loaded
	move.b	#0,checkpoint			; Reset checkpoint
	move.b	#0,spawnMode			; Spawn at beginning
	move.b	#0,palFadeFlags			; Mark palette fading as inactive

.ClearPal:
	lea	palette.w,a1			; Fill the palette with black
	move.w	#$80/4-1,d6

.ClearPalLoop:
	move.l	#0,(a1)+
	dbf	d6,.ClearPalLoop

	move.b	#$C,vintRoutine.w		; Process the palette clear in V-INT
	bsr.w	VSync
	rts

; -------------------------------------------------------------------------

.CheckNormalLoad:
	cmpi.w	#$800,demoDataIndex.w		; Was a demo running?
	bne.s	.NormalLoad			; If not, branch
	move.w	#0,demoDataIndex.w		; Reset demo timer
	clr.w	demoMode			; Clear demo mode flag
	move.b	#0,palFadeFlags			; Mark palette fading as inactive
	rts

; -------------------------------------------------------------------------

.NormalLoad:
	moveq	#0,d0				; Fill palette with black
	btst	#0,palClearFlags		; Should we fill the palette with white?
	bne.s	.UseWhite			; If so, branch
	btst	#7,timeZone			; Were we time warping before?
	beq.s	.ClearPal2			; If not, branch

.UseWhite:
	move.l	#$0EEE0EEE,d0			; Fill palette with white

.ClearPal2:
	lea	palette.w,a1			; Fill the palette with black or white
	move.w	#$80/4-1,d6

.ClearPalLoop2:
	move.l	d0,(a1)+
	dbf	d6,.ClearPalLoop2		; Loop until finished

.WaitPLC:
	move.b	#$C,vintRoutine.w		; VSync
	bsr.w	VSync
	bsr.w	ProcessPLCs			; Process PLCs
	bne.s	.WaitPLC			; If the queue isn't empty, wait
	tst.l	plcBuffer.w

	bsr.w	PlayLevelMusic			; Play level music

	moveq	#0,d0				; Get level PLCs
	lea	LevelDataIndex,a2
	moveq	#0,d0
	move.b	(a2),d0
	beq.s	.LoadStdPLCs
	bsr.w	LoadPLCImm			; Load it immediately

.LoadStdPLCs:
	moveq	#1,d0				; Load standard PLCs immediately
	bsr.w	LoadPLCImm

	clr.b	powerup				; Reset powerup ID
	clr.l	flowerCount			; Clear flower count

	lea	objDrawQueue.w,a1		; Clear object sprite draw queue
	moveq	#0,d0
	move.w	#$400/4-1,d1

.ClearObjSprites:
	move.l	d0,(a1)+
	dbf	d1,.ClearObjSprites

	lea	flowerPosBuf,a1			; Clear flower position buffer and other misc. variables
	moveq	#0,d0
	move.w	#$A00/4-1,d1

.ClearFlowers:
	move.l	d0,(a1)+
	dbf	d1,.ClearFlowers

	lea	objects.w,a1			; Clear object RAM
	moveq	#0,d0
	move.w	#$2000/4-1,d1

.ClearObjects:
	move.l	d0,(a1)+
	dbf	d1,.ClearObjects

	lea	unkBuffer2,a1			; Clear an unknown buffer
	moveq	#0,d0
	move.w	#$1000/4-1,d1

.ClearUnkBuffer:
	move.l	d0,(a1)+
	dbf	d1,.ClearUnkBuffer

	lea	miscVariables.w,a1		; Clear misc. variables
	moveq	#0,d0
	move.w	#$58/4-1,d1

.ClearMiscVars:
	move.l	d0,(a1)+
	dbf	d1,.ClearMiscVars

	lea	cameraX.w,a1			; Clear camera RAM
	moveq	#0,d0
	move.w	#$100/4-1,d1

.ClearCamera:
	move.l	d0,(a1)+
	dbf	d1,.ClearCamera

	move	#$2700,sr			; Disable interrupts
	move.l	#DemoData,demoDataPtr.w		; Set demo data pointer
	if DEMO<>0
		move.w	#1,demoMode		; Set demo mode flag
	endif
	move.w	#0,demoDataIndex.w		; Reset demo data index

	bsr.w	ClearScreen			; Clear the screen
	lea	VDPCTRL,a6
	move.w	#$8B03,(a6)			; HScroll by line, VScroll by screen
	move.w	#$8230,(a6)			; Plane A at $C000
	move.w	#$8407,(a6)			; Plane B at $E000
	move.w	#$857C,(a6)			; Sprite table at $F800
	move.w	#$9001,(a6)			; Plane size 64x32
	move.w	#$8004,(a6)			; Disable H-INT
	move.w	#$8720,(a6)			; Background color at line 2, color 0
	move.w	#$8ADF,vdpReg0A.w		; Set H-INT counter to 233
	move.w	vdpReg0A.w,(a6)

	move.w	#30,drownTimer			; Set drown timer

	move	#$2300,sr			; Enable interrupts
	moveq	#3,d0				; Load Sonic's palette into both palette buffers
	bsr.w	LoadPalette
	moveq	#3,d0
	bsr.w	LoadFadePal

	bsr.w	LevelSizeLoad			; Get level size and start position
	bsr.w	LevelScroll			; Initialize level scrolling
	bset	#2,scrollFlags.w		; Force draw a block column on the left side of the screen
	bsr.w	LoadLevelData			; Load level data
	bsr.w	InitLevelDraw			; Begin level drawing
	jsr	ConvColArray			; Convert collision data (dummied out)
	bsr.w	LoadLevelCollision		; Load collision block IDs

.WaitPLC2:
	move.b	#$C,vintRoutine.w		; VSync
	bsr.w	VSync
	bsr.w	ProcessPLCs			; Process PLCs
	bne.s	.WaitPLC2			; If the queue isn't empty, wait
	tst.l	plcBuffer.w			; Is the queue empty?
	bne.s	.WaitPLC2			; If not, wait

	bsr.w	LoadPlayer			; Load the player
	move.b	#$1C,objHUDScoreSlot.w		; Load HUD score object
	move.b	#$1C,objHUDLivesSlot.w		; Load HUD lives object
	move.b	#1,objHUDLivesSlot+oSubtype.w
	move.b	#$1C,objHUDRingsSlot.w		; Load HUD rings object
	move.b	#1,objHUDRingsSlot+oSubtype2.w
	bsr.w	LoadLifeIcon
	move.b	#$19,objHUDIconSlot.w		; Load HUD time icon object
	move.b	#$A,objHUDIconSlot+oSubtype.w

	bset	#1,plcLoadFlags			; Mark title card as loaded
	bne.s	.SkipTitleCard			; If it was already loaded, branch
	move.b	#$3C,objTtlCardSlot.w		; Load the title card
	move.b	#1,ctrlLocked.w			; Lock controls
	clr.b	sectionID			; Reset section

.SkipTitleCard:
	move.w	#0,playerCtrl.w			; Clear controller data
	move.w	#0,p1CtrlData.w
	move.w	#0,p2CtrlData.w
	move.w	#0,boredTimer.w			; Reset boredom timers
	move.w	#0,boredTimerP2.w
	move.b	#0,unkLevelFlag			; Clear unknown flag

	moveq	#0,d0
	tst.b	spawnMode			; Is the player being spawned at the beginning?
	bne.s	.SkipClear			; If not, branch
	move.w	d0,rings			; Reset ring count
	move.l	d0,time				; Reset time
	move.b	d0,livesFlags			; Reset 1UP flags

.SkipClear:
	move.b	d0,timeOver			; Clear time over flag
	move.b	d0,shield			; Clear shield flag
	move.b	d0,invincible			; Clear invincible  flag
	move.b	d0,speedShoes			; Clear speed shoes flag
	move.b	d0,timeWarp			; Clear time warp flag
	move.w	d0,debugMode			; Clear debug mode flag
	move.w	d0,levelRestart			; Clear level restart flag
	move.w	d0,levelFrames			; Reset frame counter
	move.b	d0,spawnMode			; Spawn at the beginning
	move.b	#1,updateHUDScore		; Update the score in the HUD
	move.b	#1,updateHUDRings		; Update the ring count in the HUD
	move.b	#1,updateHUDTime		; Update the time in the HUD
	move.b	#1,updateHUDLives		; Update the life counter in the HUD
	move.b	#$80,updateHUDRings		; Initialize the score in the HUD
	move.b	#$80,updateHUDScore		; Initialize the score in the HUD

	move.w	#0,demoS1Index.w		; Clear demo data index (Sonic 1 leftover)
	move.w	#$202F,palFadeInfo.w		; Set to fade palette lines 1-3

	jsr	UpdateAnimTiles			; Update animated tiles

	move.b	#1,fadeEnableDisplay		; Set to enable display on palette fade
	bclr	#7,timeZone			; Stop time warp
	beq.s	.ChkPalFade			; If we weren't to begin with, branch

.FromWhite:
	bsr.w	FadeFromWhite			; Fade from white
	bra.s	.BeginLevel

.ChkPalFade:
	bclr	#0,palClearFlags		; Did we fill the palette with white?
	bne.s	.FromWhite			; If so, branch
	bsr.w	FadeFromBlack			; Fade from black

.BeginLevel:
	bclr	#7,gameMode.w			; Mark level as initialized
	move.b	#1,levelStarted			; Mark level as started

; -------------------------------------------------------------------------

Level_MainLoop:
	move.b	#8,vintRoutine.w		; VSync
	bsr.w	VSync

	if REGION=USA				; Did the player die?
		cmpi.b	#6,objPlayerSlot+oRoutine.w	
		bcc.s	.CheckPaused		; If so, branch
	endif
	tst.b	ctrlLocked.w			; Are controls locked?
	bne.s	.CheckPaused			; If so, branch
	btst	#7,p1CtrlTap.w			; Was the start button pressed?
	beq.s	.CheckPaused			; If not, branch
	eori.b	#1,paused.w			; Do pause/unpause

.CheckPaused:
	btst	#0,paused.w			; Is the game paused?
	beq.w	.NotPaused			; If not, branch

	bsr.w	PauseMusic			; Pause music
	
	if DEMO<>0
		tst.w	demoMode		; Are we in a demo?
		bne.s	.IsDemo			; If so, branch
	endif
	move.b	p1CtrlTap.w,d0			; Get pressed buttons
	tst.b	timeAttackMode			; Are we in time attack mode?
	bne.s	.CheckReset			; If so, branch

	andi.b	#$70,d0				; Get A, B, or C
	if REGION=USA
		beq.s	Level_MainLoop		; If none of them were pressed, branch
	else
		cmpi.b	#$70,d0			; Were A, B, and C pressed?
		bne.s	Level_MainLoop		; If not, branch
	endif
	subq.b	#1,lives			; Take away a life
	bpl.s	.GotLives			; If we haven't run out, branch
	clr.b	lives				; Cap lives at 0

.GotLives:
	move.w	#SCMD_FADECDA,d0		; Fade out music
	jsr	SubCPUCmd

	bsr.w	ResetSavedObjFlags		; Reset saved object flags
	clr.b	spawnMode			; Spawn at the beginning
	move.w	#1,levelRestart			; Restart the level
	bra.s	.DoReset

.CheckReset:
	andi.b	#$70,d0				; Was A, B, or C pressed?
	beq.w	Level_MainLoop			; If not, branch
	
.IsDemo:
	clr.b	lives				; Set lives to 0

.DoReset:
	clr.b	paused.w			; Clear pause flag
	clr.w	demoMode			; Clear demo mode flag
	clr.b	checkpoint			; Reset checkpoint
	if DEMO<>0
		move.w	#$800,demoDataIndex.w	; Stop the demo
	endif
	bra.w	LevelStart			; Restart the level

.NotPaused:
	bsr.w	UnpauseMusic			; Unpause music

	addq.w	#1,levelFrames			; Increment frame counter

	jsr	SpawnObjects			; Spawn objects
	jsr	RunObjects			; Run objects

	cmpi.w	#$800,demoDataIndex.w		; Is the demo over?
	beq.w	LevelStart			; If so, restart the level
	tst.w	levelRestart			; Is the level restarting?
	bne.w	LevelStart			; If so, restart the level
	tst.w	debugMode			; Are we in debug mode?
	bne.s	.DoScroll			; If so, branch
	cmpi.b	#6,objPlayerSlot+oRoutine.w	; Is the player dead?
	bcs.s	.DoScroll			; If not, branch
	move.w	cameraY.w,bottomBound.w		; Set the bottom boundary of the level to wherever the camera is
	move.w	cameraY.w,destBottomBound.w
	bra.s	.DrawObjects			; Don't handle level scrolling

.DoScroll:
	bsr.w	LevelScroll			; Handle level scrolling

.DrawObjects:
	jsr	DrawObjects			; Draw objects

	tst.w	timeStopTimer			; Is the time stop timer active?
	bne.s	.SkipPalCycle			; If so, branch
	bsr.w	PaletteCycle			; Handle palette cycling

.SkipPalCycle:
	jsr	UpdateSectionArt		; Update section art
	bsr.w	ProcessPLCs			; Process PLCs
	bsr.w	UpdateGlobalAnims		; Update global animations

	bra.w	Level_MainLoop			; Loop

; -------------------------------------------------------------------------
; Load the player object
; -------------------------------------------------------------------------

LoadPlayer:
	lea	objPlayerSlot.w,a1		; Player object
	moveq	#1,d0				; Set player object ID
	move.b	d0,oID(a1)
	tst.b	spawnMode			; Is the player being spawned at the beginning?
	beq.s	.End				; If so, branch
	move.w	#$78,oPlayerHurt(a1)		; If not, make the player invulnerable for a bit

.End:
	rts

; -------------------------------------------------------------------------
; Restore zone flowers
; -------------------------------------------------------------------------

RestoreZoneFlowers:
	lea	flowerCount,a1			; Get flower count bsaed on time zone
	moveq	#0,d0
	move.b	timeZone,d0
	bclr	#7,d0
	move.b	(a1,d0.w),d0
	beq.s	.End				; There are no flowers, exit

	subq.b	#1,d0				; Fix flower count for DBF
	lea	dynObjects.w,a2			; Dynamic object RAM
	moveq	#0,d1				; Flower ID

.Loop:
	move.b	#$1F,oID(a2)			; Load a flower
	move.w	d1,d2				; Get flower position buffer index based on time zone
	add.w	d2,d2
	add.w	d2,d2
	moveq	#0,d3
	move.b	timeZone,d3
	bclr	#7,d3
	lsl.w	#8,d3
	add.w	d3,d2
	lea	flowerPosBuf,a3			; Get flower position
	move.w	(a3,d2.w),oX(a2)
	move.w	2(a3,d2.w),oY(a2)

	adda.w	#oSize,a2			; Next object
	addq.b	#1,d1				; Next flower
	dbf	d0,.Loop			; Loop until finished

.End:
	rts

; -------------------------------------------------------------------------
; Load level collision
; -------------------------------------------------------------------------

LoadLevelCollision:
	moveq	#0,d0				; Get level collision pointer
	move.b	zone,d0
	lsl.w	#2,d0
	move.l	LevelColIndex(pc,d0.w),collisionPtr.w
	rts

; -------------------------------------------------------------------------

LevelColIndex:
	dc.l	LevelCollision			; They are all the same. For some reason,
	dc.l	LevelCollision			; the Sonic CD team decided to keep this table
	dc.l	LevelCollision			; instead of just directly setting the pointer
	dc.l	LevelCollision
	dc.l	LevelCollision
	dc.l	LevelCollision
	dc.l	LevelCollision
	dc.l	LevelCollision

; -------------------------------------------------------------------------
; Handle global animations
; -------------------------------------------------------------------------

UpdateGlobalAnims:
	subq.b	#1,logSpikeAnimTimer		; Decrement Sonic 1 spiked log animation timer
	bpl.s	.Rings				; If it hasn't run out, branch
	move.b	#$B,logSpikeAnimTimer		; Reset animation timer
	subq.b	#1,logSpikeAnimFrame		; Decrement frame
	andi.b	#7,logSpikeAnimFrame		; Keep the frame in range

.Rings:
	subq.b	#1,ringAnimTimer		; Decrement ring animation timer
	bpl.s	.Unknown			; If it hasn't run out, branch
	move.b	#7,ringAnimTimer		; Reset animation timer
	addq.b	#1,ringAnimFrame		; Increment frame
	andi.b	#3,ringAnimFrame		; Keep the frame in range

.Unknown:
	subq.b	#1,unkAnimTimer			; Decrement Sonic 1 unused animation timer
	bpl.s	.RingSpill			; If it hasn't run out, branch
	move.b	#7,unkAnimTimer			; Reset animation timer
	addq.b	#1,unkAnimFrame			; Increment frame
	cmpi.b	#6,unkAnimFrame			; Keep the frame in range
	bcs.s	.RingSpill
	move.b	#0,unkAnimFrame

.RingSpill:
	tst.b	ringLossAnimTimer		; Has the ring spill timer run out?
	beq.s	.End				; If so, branch
	moveq	#0,d0				; Increment frame accumulator
	move.b	ringLossAnimTimer,d0
	add.w	ringLossAnimAccum,d0
	move.w	d0,ringLossAnimAccum
	rol.w	#7,d0				; Set ring spill frame
	andi.w	#3,d0
	move.b	d0,ringLossAnimFrame
	subq.b	#1,ringLossAnimTimer		; Decrement ring spill timer

.End:
	rts

; -------------------------------------------------------------------------
; Play level music
; -------------------------------------------------------------------------

PlayLevelMusic:
	moveq	#0,d0				; Get time zone
	moveq	#0,d1
	move.b	timeZone,d0
	bclr	#7,d0
	tst.b	timeAttackMode			; Are we in time attack mode?
	bne.s	.Notfuture			; If so, branch
	cmpi.b	#2,d0				; Are we in the future?
	bne.s	.NotFuture			; If not, branch
	add.b	goodFuture,d0			; Apply good future flag

.NotFuture:
	move.b	zone,d1				; Send music play Sub CPU command
	add.w	d1,d1
	add.w	d1,d1
	add.w	d0,d1
	moveq	#0,d0
	move.b	MusicPlayCmds(pc,d1.w),d0
	jmp	SubCPUCmd

; -------------------------------------------------------------------------

MusicPlayCmds:
	dc.b	SCMD_PASTMUS, SCMD_R1AMUS, SCMD_R1DMUS, SCMD_R1CMUS
	dc.b	SCMD_PASTMUS, SCMD_R3AMUS, SCMD_R3DMUS, SCMD_R3CMUS
	dc.b	SCMD_PASTMUS, SCMD_R4AMUS, SCMD_R4DMUS, SCMD_R4CMUS
	dc.b	SCMD_PASTMUS, SCMD_R5AMUS, SCMD_R5DMUS, SCMD_R5CMUS
	dc.b	SCMD_PASTMUS, SCMD_R6AMUS, SCMD_R6DMUS, SCMD_R6CMUS
	dc.b	SCMD_PASTMUS, SCMD_R7AMUS, SCMD_R7DMUS, SCMD_R7CMUS
	dc.b	SCMD_PASTMUS, SCMD_R8AMUS, SCMD_R8DMUS, SCMD_R8CMUS

; -------------------------------------------------------------------------
; Play Palmtree Panic present music
; -------------------------------------------------------------------------

PlayLevelMusic2:
	move.w	#SCMD_R1AMUS,d0			; Play PPZ present music
	jsr	SubCPUCmd
	; Continue to load the life icon

; -------------------------------------------------------------------------
; Load life icon
; -------------------------------------------------------------------------

LoadLifeIcon:
	move.l	#$74200002,d0			; Set VDP write command

	moveq	#0,d2				; Get pointer to life icon
	move.b	timeZone,d2
	bclr	#7,d2
	lsl.w	#7,d2
	move.l	d0,4(a6)
	lea	Art_LifeIcon,a1
	lea	(a1,d2.w),a3

	rept	32
		move.l	(a3)+,(a6)		; Load life icon
	endr

	rts

; -------------------------------------------------------------------------
; Pause the music
; -------------------------------------------------------------------------

PauseMusic:
	move.w	#FM_CHARGESTOP,d0		; Play charge stop sound
	jsr	PlayFMSound

	bset	#7,paused.w			; Set the music as paused
	bne.s	.End				; If it was already paused, branch

	move.b	timeZone,d0			; Get time zone
	bclr	#7,d0
	tst.b	d0				; Are we in the past?
	beq.s	.Past				; If so, branch

.PauseMusic:
	move.w	#SCMD_PAUSECDA,d0		; Pause CD music
	jmp	SubCPUCmd

.Past:
	tst.b	invincible			; Are we invincible?
	bne.s	.PauseMusic			; If so, pause the invincibility music
	tst.b	speedShoes			; Do we have speed shoes?
	bne.s	.PauseMusic			; If so, pause the speed shoes music

	move.w	#SCMD_PAUSEPCM,d0		; Pause PCM music
	jmp	SubCPUCmd

.End:
	rts

; -------------------------------------------------------------------------
; Unpause music
; -------------------------------------------------------------------------

UnpauseMusic:
	bclr	#7,paused.w			; Set the music as unpaused
	beq.s	.End				; If it was already unpaused, branch

	move.b	timeZone,d0			; Get time zone
	bclr	#7,d0
	tst.b	d0				; Are we in the past?
	beq.s	.Past				; If so, branch

.UnpauseMusic:
	move.w	#SCMD_UNPAUSECDA,d0		; Unpause CD music
	jmp	SubCPUCmd

.Past:
	tst.b	invincible			; Are we invincible?
	bne.s	.UnpauseMusic			; If so, unpause the invincibility music
	tst.b	speedShoes			; Do we have speed shoes?
	bne.s	.UnpauseMusic			; If so, unpause the speed shoes music

	move.w	#SCMD_UNPAUSEPCM,d0		; Unpause PCM music
	jmp	SubCPUCmd

.End:
	rts

; -------------------------------------------------------------------------
; Vertical interrupt routine
; -------------------------------------------------------------------------

VInterrupt:
	bset	#0,GAIRQ2			; Send Sub CPU IRQ2 request
	movem.l	d0-a6,-(sp)			; Save registers

	tst.b	vintRoutine.w			; Are we lagging?
	beq.s	VInt_Lag			; If so, branch

	move.w	VDPCTRL,d0	
	move.l	#$40000010,VDPCTRL		; Update VScroll
	move.l	vscrollScreen.w,VDPDATA

	btst	#6,versionCache			; Is this a PAL console?
	beq.s	.NotPAL				; If not, branch
	move.w	#$700,d0			; Delay for a bit
	dbf	d0,*

.NotPAL:
	move.b	vintRoutine.w,d0		; Get V-INT routine ID
	move.b	#0,vintRoutine.w		; Mark V-INT as run
	andi.w	#$3E,d0
	move.w	VInt_Index(pc,d0.w),d0		; Run the current V-INT routine
	jsr	VInt_Index(pc,d0.w)

VInt_Finish:
	jsr	UpdateFMQueues			; Update FM driver queues
	tst.b	paused.w			; Is the game paused?
	bne.s	VInt_Done			; If so, branch
	bsr.w	RunBoredTimer			; Run boredom timer
	bsr.w	RunTimeWarp			; Run time warp timer

VInt_Done:
	addq.l	#1,levelVIntCounter		; Increment frame counter

	movem.l	(sp)+,d0-a6			; Restore registers
	rte

; -------------------------------------------------------------------------

VInt_Index:
	dc.w	VInt_Lag-VInt_Index		; Lag
	dc.w	VInt_General-VInt_Index		; General
	dc.w	VInt_S1Title-VInt_Index		; Sonic 1 title screen (leftover)
	dc.w	VInt_Unk6-VInt_Index		; Unknown (leftover)
	dc.w	VInt_Level-VInt_Index		; Level
	dc.w	VInt_S1SpecStg-VInt_Index	; Sonic 1 special stage (leftover)
	dc.w	VInt_LevelLoad-VInt_Index	; Level load
	dc.w	VInt_UnkE-VInt_Index		; Unknown (leftover)
	dc.w	VInt_Pause-VInt_Index		; Sonic 1 pause (leftover)
	dc.w	VInt_PalFade-VInt_Index		; Palette fade
	dc.w	VInt_S1SegaScr-VInt_Index	; Sonic 1 SEGA screen (leftover)
	dc.w	VInt_S1ContScr-VInt_Index	; Sonic 1 continue screen (leftover)
	dc.w	VInt_LevelLoad-VInt_Index	; Level load

; -------------------------------------------------------------------------
; V-INT lag routine
; -------------------------------------------------------------------------

VInt_Lag:
	tst.b	levelStarted			; Has the level started?
	beq.w	VInt_Finish			; If not, branch
	cmpi.b	#2,zone				; Are we in Tidal Tempest?
	bne.w	VInt_Finish			; If not, branch

	move.w	VDPCTRL,d0
	btst	#6,versionCache			; Is this a PAL console?
	beq.s	.NotPAL				; If not, branch
	move.w	#$700,d0			; Delay for a bit
	dbf	d0,*

.NotPAL:
	move.w	#1,hintFlag.w			; Set H-INT flag
	jsr	StopZ80				; Stop the Z80

	tst.b	waterFullscreen.w		; Is water filling the screen?
	bne.s	.WaterPal			; If so, branch
	LVLDMA	palette,$0000,$80,CRAM		; DMA palette
	bra.s	.Done

.WaterPal:
	LVLDMA	waterPalette,$0000,$80,CRAM	; DMA water palette

.Done:
	move.w	vdpReg0A.w,(a5)			; Update H-INT counter
	jsr	StartZ80			; Start the Z80

	bra.w	VInt_Finish			; Finish V-INT

; -------------------------------------------------------------------------
; V-INT general routine
; -------------------------------------------------------------------------

VInt_General:
	bsr.w	DoVIntUpdates			; Do V-INT updates

VInt_S1SegaScr:					; Pointer to here is leftover from Sonic 1's
						; SEGA screen V-INT routine

	tst.w	vintTimer.w			; Is the V-INT timer running?
	beq.w	.End				; If not, branch
	subq.w	#1,vintTimer.w			; Decrement V-INT timer

.End:
	rts

; -------------------------------------------------------------------------
; Leftover dead code from Sonic 1's title screen V-INT routine
; -------------------------------------------------------------------------

VInt_S1Title:
	bsr.w	DoVIntUpdates			; Do V-INT updates
	bsr.w	DrawLevelBG			; Draw level BG
	bsr.w	DecompPLCFast			; Process PLC art decompression

	tst.w	vintTimer.w			; Is the V-INT timer running?
	beq.w	.End				; If not, branch
	subq.w	#1,vintTimer.w			; Decrement V-INT timer

.End:
	rts

; -------------------------------------------------------------------------
; Leftover dead code from Sonic 1's V-INT
; -------------------------------------------------------------------------

VInt_Unk6:
	bsr.w	DoVIntUpdates			; Do V-INT updates
	rts

; -------------------------------------------------------------------------
; Leftover dead code from Sonic 1's pause V-INT routine
; -------------------------------------------------------------------------

VInt_Pause:
	cmpi.b	#$10,gameMode.w			; Are we in the Sonic 1 special stage?
	beq.w	VInt_S1SpecStg			; If so, branch

; -------------------------------------------------------------------------
; V-INT level routine
; -------------------------------------------------------------------------

VInt_Level:
	jsr	StopZ80				; Stop the Z80
	bsr.w	ReadControllers			; Read controllers

	LVLDMA	palette,$0000,$80,CRAM		; DMA palette
	LVLDMA	hscroll,$FC00,$380,VRAM		; DMA horizontal scroll data
	LVLDMA	sprites,$F800,$280,VRAM		; DMA sprites

	lea	objPlayerSlot.w,a0		; Load player sprite art
	bsr.w	LoadSonicDynPLC
	tst.b	updateSonicArt.w
	beq.s	.NoArtLoad
	LVLDMA	sonicArtBuf,$F000,$2E0,VRAM
	move.b	#0,updateSonicArt.w

.NoArtLoad:
	jsr	UpdateAnimTiles			; Update animated tiles
	jsr	StartZ80			; Start the Z80

	movem.l	cameraX.w,d0-d7			; Draw level
	movem.l	d0-d7,camXCopy
	movem.l	scrollFlags.w,d0-d1
	movem.l	d0-d1,scrollFlagsCopy
	bsr.w	DrawLevel

	bsr.w	DecompPLCSlow			; Process PLC art decompression
	jmp	UpdateHUD			; Update the HUD

; -------------------------------------------------------------------------
; Emptied out code from Sonic 1's special stage V-INT routine
; -------------------------------------------------------------------------

VInt_S1SpecStg:
	rts

; -------------------------------------------------------------------------
; V-INT level load routine
; -------------------------------------------------------------------------

VInt_LevelLoad:
	jsr	StopZ80				; Stop the Z80
	bsr.w	ReadControllers			; Read controllers

	LVLDMA	palette,$0000,$80,CRAM		; DMA palette
	LVLDMA	hscroll,$FC00,$380,VRAM		; DMA horizontal scroll data
	LVLDMA	sprites,$F800,$280,VRAM		; DMA sprites

	jsr	StartZ80			; Start the Z80

	movem.l	cameraX.w,d0-d7			; Draw level
	movem.l	d0-d7,camXCopy
	movem.l	scrollFlags.w,d0-d1
	movem.l	d0-d1,scrollFlagsCopy
	bsr.w	DrawLevel

	bra.w	DecompPLCFast			; Process PLC art decompression

; -------------------------------------------------------------------------
; Leftover dead code from Sonic 1's V-INT
; -------------------------------------------------------------------------

VInt_UnkE:
	bsr.w	DoVIntUpdates			; Do V-INT updates

	addq.b	#1,vintECount.w			; Increment counter
	move.b	#$E,vintRoutine.w		; Set to run this routine again next VBlank

	rts

; -------------------------------------------------------------------------
; V-INT palette fade routine
; -------------------------------------------------------------------------

VInt_PalFade:
	bsr.w	DoVIntUpdates			; Do V-INT updates

	cmpi.b	#1,fadeEnableDisplay		; Should we enable display?
	bne.s	.SetHIntCounter			; If not, branch
	addq.b	#1,fadeEnableDisplay		; Mark display as enabled

	move.w	vdpReg01.w,d0			; Enable display
	ori.b	#$40,d0
	move.w	d0,VDPCTRL

.SetHIntCounter:
	move.w	vdpReg0A.w,(a5)			; Set H-INT counter
	bra.w	DecompPLCFast			; Process PLC art decompression

; -------------------------------------------------------------------------
; Leftover dead code from Sonic 1's continue screen V-INT routine
; -------------------------------------------------------------------------

VInt_S1ContScr:
	jsr	StopZ80				; Stop the Z80
	bsr.w	ReadControllers			; Read controllers

	LVLDMA	palette,$0000,$80,CRAM		; DMA palette
	LVLDMA	sprites,$F800,$280,VRAM		; DMA sprites
	LVLDMA	hscroll,$FC00,$380,VRAM		; DMA horizontal scroll data

	jsr	StartZ80			; Start the Z80

	lea	objPlayerSlot.w,a0		; Load player sprite art
	bsr.w	LoadSonicDynPLC
	tst.b	updateSonicArt.w
	beq.s	.NoArtLoad
	LVLDMA	sonicArtBuf,$F000,$2E0,VRAM
	move.b	#0,updateSonicArt.w

.NoArtLoad:
	tst.w	vintTimer.w			; Is the V-INT timer running?
	beq.w	.End				; If not, branch
	subq.w	#1,vintTimer.w			; Decrement V-INT timer

.End:
	rts

; -------------------------------------------------------------------------
; Do common V-INT updates
; -------------------------------------------------------------------------

DoVIntUpdates:
	jsr	StopZ80				; Stop the Z80
	bsr.w	ReadControllers			; Read controllers

	tst.b	waterFullscreen.w		; Is water filling the screen?
	bne.s	.WaterPal			; If so, branch
	LVLDMA	palette,$0000,$80,CRAM		; DMA palette
	bra.s	.LoadedPal

.WaterPal:
	LVLDMA	waterPalette,$0000,$80,CRAM	; DMA water palette

.LoadedPal:
	LVLDMA	sprites,$F800,$280,VRAM		; DMA sprites
	LVLDMA	hscroll,$FC00,$380,VRAM		; DMA horizontal scroll data

	jmp	StartZ80			; Start the Z80

; -------------------------------------------------------------------------
; Horizontal interrupt
; -------------------------------------------------------------------------

HInterrupt:
	rte

; -------------------------------------------------------------------------
; Run time warp timer
; -------------------------------------------------------------------------

RunTimeWarp:
	tst.b	objPlayerSlot+oPlayerCharge.w	; Is the player charging?
	bne.s	.End				; If so, branch
	tst.w	timeWarpTimer.w			; Is the time warp timer active?
	beq.s	.End				; If not, branch	
	addq.w	#1,timeWarpTimer.w		; Increment time warp timer

.End:
	rts

; -------------------------------------------------------------------------
; Run boredom timer
; -------------------------------------------------------------------------

RunBoredTimer:
	tst.w	boredTimer.w			; Is the bored timer active?
	beq.s	.CheckP2Timer			; If not, branch
	addq.w	#1,boredTimer.w			; Increment bored timer

.CheckP2Timer:
	tst.w	boredTimerP2.w			; Is the player 2 bored timer active?
	beq.s	.End				; If not, branch
	addq.w	#1,boredTimerP2.w		; Increment player 2 bored timer

.End:
	rts

; -------------------------------------------------------------------------
