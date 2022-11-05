; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Level end objects
; -------------------------------------------------------------------------

oLvlEndTimer	EQU	oVar2A			; Timer

; -------------------------------------------------------------------------
; Flower capsule object
; -------------------------------------------------------------------------

ObjCapsule:
	moveq	#0,d0				; Run routine
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	tst.b	oRoutine(a0)			; Have we been initialized?
	beq.s	.End				; If not, branch
	cmpi.b	#$A,oRoutine(a0)		; Is this a seed?
	beq.s	.Draw				; If so, branch
	cmpi.b	#6,oRoutine(a0)			; Have we been destroyed?
	bcc.s	.End				; If so, branch

.Draw:
	jmp	DrawObject			; Draw sprite

.End:
	rts

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjCapsule_Init-.Index
	dc.w	ObjCapsule_Main-.Index
	dc.w	ObjCapsule_Explode-.Index
	dc.w	StartResults-.Index
	dc.w	ResultsActive-.Index
	dc.w	ObjCapsule_Seed-.Index

; -------------------------------------------------------------------------
; Initialization
; -------------------------------------------------------------------------

ObjCapsule_Init:
	ori.b	#%00000100,oSprFlags(a0)	; Set sprite flags
	addq.b	#2,oRoutine(a0)			; Next routine
	move.b	#4,oPriority(a0)		; Set priority
	move.l	#MapSpr_FlowerCapsule,oMap(a0)	; Set mappings
	move.w	#$2481,oTile(a0)		; Set base tile ID
	move.b	#$20,oXRadius(a0)		; Set width
	move.b	#$20,oWidth(a0)
	move.b	#$18,oYRadius(a0)		; Set height

; -------------------------------------------------------------------------
; Main routine
; -------------------------------------------------------------------------

ObjCapsule_Main:
	lea	Ani_FlowerCapsule,a1		; Animate sprite
	jsr	AnimateObject

	lea	objPlayerSlot.w,a6		; Check if we have been hit
	bsr.w	ObjCapsule_CheckHit
	beq.s	.End				; If there was no collision, branch

	clr.b	updateHUDTime			; Stop time
	move.b	#2,oMapFrame(a0)		; Set to destroyed sprite frame
	move.b	#120,oLvlEndTimer(a0)		; Set explosion timer
	addq.b	#2,oRoutine(a0)			; Start exploding

	move.w	objPlayerSlot+oX.w,d0		; Is the player horizontally outside of us?
	move.b	objPlayerSlot+oXRadius.w,d1
	ext.w	d1
	addi.w	#32,d1
	sub.w	oX(a0),d0
	add.w	d1,d0
	bmi.s	.BounceX			; If so, branch
	add.w	d1,d1
	cmp.w	d1,d0
	bcc.s	.BounceX			; If so, branch

.BounceY:
	move.w	objPlayerSlot+oYVel.w,d0	; Make the player bounce off us vertically
	neg.w	d0
	asr.w	#2,d0
	move.w	d0,objPlayerSlot+oYVel.w
	rts

.BounceX:
	move.w	objPlayerSlot+oXVel.w,d0	; Make the player bounce off us horizontally
	neg.w	d0
	asr.w	#2,d0
	move.w	d0,objPlayerSlot+oXVel.w

.End:
	rts

; -------------------------------------------------------------------------
; Explode
; -------------------------------------------------------------------------

ObjCapsule_Explode:
	subq.b	#1,oLvlEndTimer(a0)		; Decrement timer
	bmi.s	.FinishUp			; If it has run out, branch

	move.b	oLvlEndTimer(a0),d0		; Only spawn an explosion every 4 frames
	move.b	d0,d1
	andi.b	#3,d1
	bne.s	.End

	lsr.w	#2,d0				; Get explosion position offset based on frame
	andi.w	#7,d0
	add.w	d0,d0
	lea	.ExplosionPos(pc,d0.w),a2

	jsr	FindObjSlot			; Spawn explosion
	bne.s	.End
	move.w	#FM_EXPLODE,d0
	jsr	PlayFMSound
	move.b	#$18,oID(a1)
	move.b	#1,oRoutine2(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	
	move.b	(a2),d0				; Add position offset
	ext.w	d0
	add.w	d0,oX(a1)
	move.b	1(a2),d0
	ext.w	d0
	add.w	d0,oY(a1)
	rts

.FinishUp:
	bsr.w	ObjCapsule_SpawnSeeds		; Spawn seeds
	addq.b	#2,oRoutine(a0)			; Destroyed
	move.b	#60,oLvlEndTimer(a0)		; Set results delay timer

.End:
	rts

; -------------------------------------------------------------------------

.ExplosionPos:
	dc.b	  0,  0
	dc.b	 32, -8
	dc.b	-32,  0
	dc.b	-24, -8
	dc.b	 24,  8
	dc.b	-16,  8
	dc.b	 16,  8
	dc.b	 -8, -8

; -------------------------------------------------------------------------
; Spawn speeds
; -------------------------------------------------------------------------

ObjCapsule_SpawnSeeds:
	moveq	#0,d0				; Restore level palette
	move.b	LevelPaletteID,d0
	move.l	d7,d6
	jsr	LoadPalette
	move.l	d6,d7

	moveq	#7-1,d6				; Number of seeds
	moveq	#0,d1				; Seed velocity table offset

.Spawn:
	jsr	FindObjSlot			; Spawn seed
	bne.s	.End
	move.b	#$15,oID(a1)
	ori.b	#%00000100,oSprFlags(a1)	; Set sprite flags
	move.w	oX(a0),oX(a1)			; Set position
	move.w	oY(a0),oY(a1)
	move.b	#$A,oRoutine(a1)		; Set seed routine
	move.l	#MapSpr_FlowerCapsule,oMap(a1)	; Set mappings
	move.w	#$2481,oTile(a1)		; Set base tile ID
	move.b	#1,oAnim(a1)			; Set animation

	move.w	#-$600,oYVel(a1)		; Set speed velocity
	move.w	.SeedVel(pc,d1.w),oXVel(a1)

	addq.w	#2,d1				; Next seed
	dbf	d6,.Spawn			; Loop until seeds are spawned

.End:
	rts

; -------------------------------------------------------------------------

.SeedVel:
	dc.w	 0
	dc.w	-$80
	dc.w	 $80
	dc.w	-$100
	dc.w	 $100
	dc.w	-$180
	dc.w	 $180
	dc.w	-$200
	dc.w	 $200
	dc.w	-$280
	dc.w	 $280

; -------------------------------------------------------------------------
; Seed
; -------------------------------------------------------------------------

ObjCapsule_Seed:
	lea	Ani_FlowerCapsule,a1		; Animate sprite
	jsr	AnimateObject

	jsr	ObjMoveGrv			; Move
	jsr	ObjGetFloorDist			; Check floor collision
	tst.w	d1
	bpl.s	.End				; If the seed hasn't landed, branch

	move.b	#$1F,oID(a0)			; Change into flower
	move.b	#1,oSubtype(a0)
	move.b	#0,oRoutine(a0)

.End:
	rts

; -------------------------------------------------------------------------
; Check if the capsule has been hit
; -------------------------------------------------------------------------
; PARAMETERS:
;	a6.l  - Player object slot
; RETURNS:
;	eq/ne - No collision/Collision
; -------------------------------------------------------------------------

ObjCapsule_CheckHit:
	btst	#2,oFlags(a6)			; Is the player in a ball?
	beq.s	.NoCollision			; If not, branch

	move.b	oXRadius(a6),d1			; Check horizontal collision
	ext.w	d1
	addi.w	#32,d1
	move.w	oX(a6),d0
	sub.w	oX(a0),d0
	add.w	d1,d0
	bmi.s	.NoCollision			; If there is no collision, branch
	add.w	d1,d1
	cmp.w	d1,d0
	bcc.s	.NoCollision			; If there is no collision, branch

	move.b	oYRadius(a6),d1			; Check vertical collision
	ext.w	d1
	addi.w	#28,d1
	move.w	oY(a6),d0
	sub.w	oY(a0),d0
	add.w	d1,d0
	bmi.s	.NoCollision			; If there is no collision, branch
	add.w	d1,d1
	cmp.w	d1,d0
	bcc.s	.NoCollision			; If there is no collision, branch

.Collided:
	moveq	#1,d0				; Collision
	rts

.NoCollision:
	moveq	#0,d0				; No collision
	rts

; -------------------------------------------------------------------------
; Big ring flash object
; -------------------------------------------------------------------------

ObjBigRingFlash:
	moveq	#0,d0				; Run routine
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	jmp	DrawObject			; Draw sprite

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjBigRingFlash_Init-.Index
	dc.w	ObjBigRingFlash_Animate-.Index
	dc.w	ObjBigRingFlash_Delete-.Index

; -------------------------------------------------------------------------
; Initialization
; -------------------------------------------------------------------------

ObjBigRingFlash_Init:
	ori.b	#%00000100,oSprFlags(a0)	; Set sprite flags
	addq.b	#2,oRoutine(a0)			; Next routine
	move.w	#$3EF,oTile(a0)			; Set base tile ID
	move.l	#MapSpr_BigRingFlash,oMap(a0)	; Set mappings

; -------------------------------------------------------------------------
; Animate
; -------------------------------------------------------------------------

ObjBigRingFlash_Animate:
	lea	Ani_BigRingFlash,a1		; Animate sprite
	jmp	AnimateObject

; -------------------------------------------------------------------------
; Delete
; -------------------------------------------------------------------------

ObjBigRingFlash_Delete:
	jmp	DeleteObject			; Delete ourselves

; -------------------------------------------------------------------------
; Big ring object
; -------------------------------------------------------------------------

ObjBigRing:
	tst.b	oSubtype(a0)			; Is this a flash?
	bne.s	ObjBigRingFlash			; If so, branch
	cmpi.w	#50,rings			; Have 50 rings been collected?
	bcc.s	.Proceed			; If so, branch

	if (REGION=USA)|((REGION<>USA)&(DEMO=0))
		jmp	CheckObjDespawn		; Check despawn
	else
		jmp	DeleteObject		; Delete ourselves
	endif

.Proceed:
	moveq	#0,d0				; Run routine
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	cmpi.b	#4,oRoutine(a0)			; Has the big ring been touched?
	beq.s	.End				; If so, branch
	jmp	DrawObject			; If not, draw sprite

.End:
	rts

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjBigRing_Init-.Index
	dc.w	ObjBigRing_Main-.Index
	dc.w	ObjBigRing_Animate-.Index

; -------------------------------------------------------------------------
; Initialization
; -------------------------------------------------------------------------

ObjBigRing_Init:
	cmpi.b	#%1111111,timeStones		; Have all the time stones been collected?
	bne.s	.TimeStonesLeft			; If not, branch
	jmp	DeleteObject			; If so, delete object

.TimeStonesLeft:
	tst.b	timeAttackMode			; Are we in time attack mode?
	beq.s	.Init				; If not, branch
	jmp	DeleteObject			; If so, delete object

.Init:
	addq.b	#2,oRoutine(a0)			; Next routine
	ori.b	#%00000100,oSprFlags(a0)	; Set sprite flags
	move.w	#$2488,oTile(a0)		; Set base tile ID
	move.l	#MapSpr_BigRing,oMap(a0)	; Set mappings
	move.b	#$20,oXRadius(a0)		; Set width
	move.b	#$20,oWidth(a0)
	move.b	#$20,oYRadius(a0)		; Set height

; -------------------------------------------------------------------------
; Main routine
; -------------------------------------------------------------------------

ObjBigRing_Main:
	lea	objPlayerSlot.w,a1		; Check if the player has touched us?
	bsr.w	ObjBigRing_CheckTouch
	beq.s	ObjBigRing_Animate		; If not, branch

	move.b	#1,specialStage			; Set special stage flag
	addq.b	#2,oRoutine(a0)			; Touched

	move.w	cameraX.w,d0			; Force player off screen
	addi.w	#336,d0
	move.w	d0,oX(a1)
	
	bset	#0,ctrlLocked.w			; Force right to be held
	move.w	#$808,playerCtrlHold.w
	move.w	#0,oXVel(a1)			; Stop player's movement
	move.w	#0,oPlayerGVel(a1)
	move.b	#1,scrollLock.w			; Lock camera

	move.w	#FM_BIGRING,d0			; Play sound
	jsr	PlayFMSound

	jsr	FindObjSlot			; Spawn flash
	bne.s	ObjBigRing_Main
	move.b	#$14,oID(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	move.b	#1,oSubtype(a1)

; -------------------------------------------------------------------------
; Animate
; -------------------------------------------------------------------------

ObjBigRing_Animate:
	lea	Ani_BigRing,a1			; Animate sprite
	jmp	AnimateObject

; -------------------------------------------------------------------------
; Check if the player has touched the big ring
; -------------------------------------------------------------------------
; PARAMETERS:
;	a1.l  - Player object slot
; RETURNS:
;	eq/ne - No collision/Collision
; -------------------------------------------------------------------------

ObjBigRing_CheckTouch:
	move.b	oXRadius(a1),d1			; Check horizontal collision
	ext.w	d1
	addi.w	#16,d1
	move.w	oX(a1),d0
	sub.w	oX(a0),d0
	add.w	d1,d0
	bmi.s	.NoCollision			; If there was no collision, branch
	add.w	d1,d1
	cmp.w	d1,d0
	bcc.s	.NoCollision			; If there was no collision, branch

	move.b	oYRadius(a1),d1			; Check vertical collision
	ext.w	d1
	addi.w	#32,d1
	move.w	oY(a1),d0
	sub.w	oY(a0),d0
	add.w	d1,d0
	bmi.s	.NoCollision			; If there was no collision, branch
	add.w	d1,d1
	cmp.w	d1,d0
	bcc.s	.NoCollision			; If there was no collision, branch

.Collided:
	moveq	#1,d0				; Collided
	rts

.NoCollision:
	moveq	#0,d0				; No collision
	rts

; -------------------------------------------------------------------------
; Goal post object
; -------------------------------------------------------------------------

ObjGoalPost:
	lea	objPlayerSlot.w,a6		; Get player

	moveq	#0,d0				; Run routine
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	cmpi.b	#2,act				; Are we in act 3?
	beq.s	.CheckDespawn			; If so, branch
	jsr	DrawObject			; Draw sprite

.CheckDespawn:
	jmp	CheckObjDespawn			; Check despawn

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjGoalPost_Init-.Index
	dc.w	ObjGoalPost_Main-.Index
	dc.w	ObjGoalPost_Done-.Index

; -------------------------------------------------------------------------
; Initialization
; -------------------------------------------------------------------------

ObjGoalPost_Init:
	cmpi.w	#$201,zoneAct			; Are we in Tidal Tempest Act 2?
	bne.s	.Init				; If not, branch
	cmpi.b	#TIME_PRESENT,timeZone		; Are we in the present?
	bne.s	.Init				; If not, branch

	tst.b	oSubtype(a0)			; Are the PLCs already loading?
	bne.s	.WaitPLC			; Is so, branch
	move.b	#1,oSubtype(a0)			; Mark PLCs as loading
	moveq	#$13,d0				; Load PLCs
	jmp	LoadPLC

.WaitPLC:
	tst.l	plcBuffer.w			; Are the PLCs still loading?
	beq.s	.Init				; If not, branch
	rts

.Init:
	addq.b	#2,oRoutine(a0)			; Next routine
	ori.b	#%00000100,oSprFlags(a0)	; Set sprite flags
	move.b	#4,oPriority(a0)		; Set priority
	move.l	#MapSpr_GoalSignpost,oMap(a0)	; Set mappings
	move.b	#$10,oXRadius(a0)		; Set width
	move.b	#$10,oWidth(a0)
	move.b	#$20,oYRadius(a0)		; Set height
	move.b	#5,oMapFrame(a0)		; Set sprite frame
	bsr.w	ObjGoalPost_SetBaseTile		; Set base tile ID

; -------------------------------------------------------------------------
; Main routine
; -------------------------------------------------------------------------

ObjGoalPost_Main:
	move.w	oY(a6),d0			; Check if the player is in range vertically
	sub.w	oY(a0),d0
	addi.w	#128,d0
	bmi.s	.End				; If not, branch
	cmpi.w	#256,d0
	bcc.s	.End				; If not, branch

	move.w	oX(a6),d0			; Has the player gone past us?
	cmp.w	oX(a0),d0
	bcs.s	.End				; If not, branch

	addq.b	#2,oRoutine(a0)			; Next routine

	move.w	cameraX.w,leftBound.w		; Set left boundary at our position
	move.w	cameraX.w,destLeftBound.w

	clr.w	timeWarpTimer.w			; Stop time warp
	clr.b	timeWarpDir.w
	clr.b	timeWarp

	moveq	#$12,d0				; Load signpost and big ring art
	jmp	LoadPLC

.End:
	rts

; -------------------------------------------------------------------------
; Done
; -------------------------------------------------------------------------

ObjGoalPost_Done:
	rts

; -------------------------------------------------------------------------
; Set goal post's base tile ID
; -------------------------------------------------------------------------

ObjGoalPost_SetBaseTile:
	moveq	#0,d0				; Get base table offset from level ID
	move.w	zoneAct,d0
	lsl.b	#7,d0
	lsr.w	#4,d0
	move.b	timeZone,d1			; Add time zone to the offset
	cmpi.b	#TIME_FUTURE,d1
	bne.s	.NotFuture
	add.b	goodFuture,d1

.NotFuture:
	add.b	d1,d1				; Get base tile ID
	add.b	d1,d0
	move.w	.TileIDs(pc,d0.w),oTile(a0)

	cmpi.b	#3,zone				; Are we in Quartz Quadrant?
	beq.s	.End				; If so, branch
	ori.w	#$8000,oTile(a0)		; If not, set high priority on the goal post sprite

.End:
	rts

; -------------------------------------------------------------------------

.TileIDs:
	dc.w	$35A, $4F7, $4F7, $4F7		; Palmtree Panic
	dc.w	$381, $4F7, $4F7, $4F7
	dc.w	$300, $300, $300, $300		; Collision Chaos
	dc.w	$300, $300, $300, $300
	dc.w	$4F2, $4F2, $4F2, $4F2		; Tidal Tempest
	dc.w	$4F2, $4F2, $4F2, $4F2
	dc.w	$2BA, $2CC, $2B3, $2B1		; Quartz Quadrant
	dc.w	$2BA, $2CC, $2B3, $2B1
	dc.w	$254, $22C, $294, $238		; Wacky Workbench
	dc.w	$278, $28A, $2BC, $298
	dc.w	$3AE, $3AE, $3AE, $3AE		; Stardust Speedway
	dc.w	$3AE, $3AE, $3AE, $3AE
	dc.w	$220, $221, $24C, $236		; Metallic Madness
	dc.w	$23E, $24A, $25D, $246

; -------------------------------------------------------------------------
; Signpost object
; -------------------------------------------------------------------------

ObjSignpost:
	moveq	#0,d0				; Run routine
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	jmp	DrawObject			; Draw sprite

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjSignpost_Init-.Index
	dc.w	ObjSignpost_Main-.Index
	dc.w	ObjSignpost_Spin-.Index
	dc.w	StartResults-.Index
	dc.w	ResultsActive-.Index

; -------------------------------------------------------------------------
; Initialization
; -------------------------------------------------------------------------

ObjSignpost_Init:
	addq.b	#2,oRoutine(a0)			; Next routine
	ori.b	#%00000100,oSprFlags(a0)	; Set sprite flags
	move.b	#$18,oXRadius(a0)		; Set width
	move.b	#$18,oWidth(a0)
	move.b	#$20,oYRadius(a0)		; Set height
	move.b	#4,oPriority(a0)		; Set priority
	move.w	#$43C,oTile(a0)			; Set base tile ID
	cmpi.b	#3,zone				; Are we in Quartz Quadrant?
	beq.s	.NotHighPriority		; If so, branch
	ori.b	#$80,oTile(a0)			; If not, set high priority on sprite

.NotHighPriority:
	move.l	#MapSpr_GoalSignpost,oMap(a0)	; Set mappings

; -------------------------------------------------------------------------
; Main routine
; -------------------------------------------------------------------------

ObjSignpost_Main:
	lea	objPlayerSlot.w,a6
	move.w	oY(a6),d0			; Check if the player is in range vertically
	sub.w	oY(a0),d0
	addi.w	#128,d0
	bmi.s	.End				; If not, branch
	cmpi.w	#256,d0
	bcc.s	.End				; If not, branch

	move.w	oX(a0),d0			; Has the player gone past us?
	cmp.w	oX(a6),d0
	bcc.s	.End				; If not, branch

	move.w	cameraX.w,leftBound.w		; Lock camera
	move.w	cameraX.w,destLeftBound.w

	clr.b	updateHUDTime			; Stop timer
	move.b	#120,oLvlEndTimer(a0)		; Set spin timer
	move.b	#0,oMapFrame(a0)		; Set to the Robotnik side
	addq.b	#2,oRoutine(a0)			; Next routine

	clr.b	speedShoes			; Disable speed shoes
	clr.b	invincible			; Disable invincibility

	move.w	#FM_SIGNPOST,d0			; Play signpost sound
	jmp	PlayFMSound

.End:
	rts

; -------------------------------------------------------------------------
; Spin
; -------------------------------------------------------------------------

ObjSignpost_Spin:
	lea	Ani_Signpost,a1			; Animate sprite
	jsr	AnimateObject

	subq.b	#1,oLvlEndTimer(a0)		; Decrement timer
	bne.s	.End				; If it hasn't run out, branch
	addq.b	#2,oRoutine(a0)			; Spun
	move.b	#3,oMapFrame(a0)		; Set to the player side
	move.b	#60,oLvlEndTimer(a0)		; Set results delay timer

.End:
	rts

; -------------------------------------------------------------------------
; Start results
; -------------------------------------------------------------------------

StartResults:
	subq.b	#1,oLvlEndTimer(a0)		; Decrement timer
	bne.w	.End				; If it hasn't run out, branch

	tst.b	timeZone			; Are we in the past?
	bne.s	.NotPast			; If not, branch
	move.w	#SCMD_FADEPCM,d0		; If so, fade out PCM
	jsr	SubCPUCmd

.NotPast:
	move.w	#SCMD_RESULTMUS,d0		; Play results music
	jsr	SubCPUCmd

	bset	#0,ctrlLocked.w			; Force the player to move right
	move.w	#$808,playerCtrlHold.w
	cmpi.w	#$502,zoneAct			; Are we in Stardust Speedway act 3?
	bne.s	.NotSSZ3			; If not, branch
	move.w	#0,playerCtrlHold.w		; If so, force the player to stay still

.NotSSZ3:
	move.b	#180,oLvlEndTimer(a0)		; Set (unused) timer
	addq.b	#2,oRoutine(a0)			; Next routine

	jsr	FindObjSlot			; Spawn results
	move.b	#$3A,oID(a1)
	move.b	#16,oResultsTimer(a1)		; Set results spawn delay
	move.b	#1,updateHUDBonus.w		; Update bonus count

	moveq	#0,d0				; Get time bonus index
	move.b	timeMinutes,d0
	mulu.w	#60,d0
	moveq	#0,d1
	move.b	timeSeconds,d1
	add.w	d1,d0
	divu.w	#15,d0
	moveq	#(.TimeBonusesEnd-.TimeBonuses)/2-1,d1
	cmp.w	d1,d0
	bcs.s	.GetBonus
	move.w	d1,d0

.GetBonus:
	add.w	d0,d0				; Set time bonus
	move.w	.TimeBonuses(pc,d0.w),timeBonus.w

	move.w	rings,d0			; Set ring bonus
	mulu.w	#100,d0
	move.w	d0,ringBonus.w

.End:
	rts

; -------------------------------------------------------------------------

.TimeBonuses:
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
.TimeBonusesEnd:

; -------------------------------------------------------------------------
; Results active
; -------------------------------------------------------------------------

ResultsActive:
	rts

; -------------------------------------------------------------------------
; Load flower capsule palette
; -------------------------------------------------------------------------

LoadCapsulePal:
	move.w	#$20/4-1,d6			; Load palette
	lea	Pal_FlowerCapsule,a1
	lea	palette+($10*2).w,a2

.Load:
	move.l	(a1)+,(a2)+
	dbf	d6,.Load
	rts

; -------------------------------------------------------------------------
; Data
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
