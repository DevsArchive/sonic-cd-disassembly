; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Special stage Sub CPU program
; -------------------------------------------------------------------------

	include	"_Include/Common.i"
	include	"_Include/Sound.i"
	include	"_Include/Sub CPU.i"
	include	"Special Stage/_Common.i"
	include	"Special Stage/_Global Variables.i"
	
; -------------------------------------------------------------------------
; Object variables structure
; -------------------------------------------------------------------------

oSize		EQU	$80
c = 0
	rept	oSize
oVar\$c		EQU	c
		c: = c+1
	endr

	rsreset
oID		rs.b	1			; ID
oSpriteFlag	rs.b	1			; Sprite flag
oFlags		rs.b	1			; Flags
oRoutine	rs.b	1			; Routine
oTile		rs.w	1			; Base tile ID
oSprites	rs.l	1			; Sprite data
oSprite		rs.b	1			; Sprite ID
oSpriteFrame	rs.b	1			; Sprite frame
oAnimTime	rs.b	1			; Sprite time
oAnimTime2	rs.b	1			; Sprite time (copy)
		rs.b	$E
oX		rs.l	1			; X position
oY		rs.l	1			; Y position
oZ		rs.l	1			; Z position
oSprX		rs.l	1			; Sprite X position
oSprY		rs.l	1			; Sprite Y position
oXVel		rs.l	1			; X velocity
oYVel		rs.l	1			; Y velocity
		rs.b	$18
oTimer		rs.b	1			; Timer

oDustXVel	EQU	oVar3C

; -------------------------------------------------------------------------
; Graphics operation variable structure
; -------------------------------------------------------------------------

	rsreset
gfxCamX		rs.w	1			; Camera X
gfxCamY		rs.w	1			; Camera Y
gfxCamZ		rs.w	1			; Camera Z
gfxPitch	rs.w	1			; Pitch
gfxPitchSin	rs.w	1			; Sine of pitch
gfxPitchCos	rs.w	1			; Cosine of pitch
gfxYaw		rs.w	1			; Yaw
gfxYawSin	rs.w	1			; Sine of yaw
gfxYawCos	rs.w	1			; Cosine of yaw
gfxYawSinN	rs.w	1			; Negative sine of yaw
gfxYawCosN	rs.w	1			; Negative cosine of yaw
gfxFOV		rs.w	1			; FOV
gfxCenter	rs.w	1			; Center point
		rs.b	$16
gfxPsYsFOV	rs.l	1			; sin(pitch) * sin(yaw) * FOV
gfxPsYcFOV	rs.l	1			; sin(pitch) * cos(yaw) * FOV
		rs.b	8
gfxPcFOV	rs.l	1			; cos(pitch) * FOV
		rs.b	4
gfxYsFOV	rs.w	1			; sin(yaw) * FOV
		rs.b	2
gfxYcFOV	rs.w	1			; cos(yaw) * FOV
		rs.b	6
gfxCenterX	rs.w	1			; Center point X offset
		rs.b	2
gfxCenterY	rs.w	1			; Center point Y offset
		rs.b	2
gfxPcYs		rs.w	1			; cos(pitch) * sin(yaw)
		rs.b	2
gfxPcYc		rs.w	1			; cos(pitch) * cos(yaw)
gfxSize		rs.b	0			; Size of structure

; -------------------------------------------------------------------------
; Variables
; -------------------------------------------------------------------------

	rsset	PRGRAM+$3C000
VARSSTART	rs.b	0			; Start of variables

sonicObject	rs.b	oSize			; Sonic object
sonicShadowObj	rs.b	oSize			; Sonic's shadow object

objPrioLevel1	rs.b	0			; Priority level 1 objects
splashObject	rs.b	oSize			; Splash object
ttlCardBarObj	rs.b	oSize			; Title card bar object
ttlCardTextObj	rs.b	oSize			; Title card text object
timeStoneObject	rs.b	oSize			; Time stone object
sparkleObject1	rs.b	oSize			; Sparkle object 1
sparkleObject2	rs.b	oSize			; Sparkle object 2
dustObjects	rs.b	0
dustObject1	rs.b	oSize			; Dust object 1
dustObject2	rs.b	oSize			; Dust object 2
dustObject3	rs.b	oSize			; Dust object 3
dustObject4	rs.b	oSize			; Dust object 4
dustObject5	rs.b	oSize			; Dust object 5
dustObject6	rs.b	oSize			; Dust object 6
dustObject7	rs.b	oSize			; Dust object 7
dustObject8	rs.b	oSize			; Dust object 8
DUSTOBJCOUNT	EQU	(__rs-dustObjects)/oSize
OBJ1COUNT	EQU	(__rs-objPrioLevel1)/oSize

objPrioLevel2	rs.b	0			; Priority level 2 objects
itemObject	rs.b	oSize			; Item object
ringObject1	rs.b	oSize			; Lost ring object 1
ringObject2	rs.b	oSize			; Lost ring object 2
ringObject3	rs.b	oSize			; Lost ring object 3
ringObject4	rs.b	oSize			; Lost ring object 4
ringObject5	rs.b	oSize			; Lost ring object 5
ringObject6	rs.b	oSize			; Lost ring object 6
ringObject7	rs.b	oSize			; Lost ring object 7

explosionObjs	rs.b	0
explosionObj1	rs.b	oSize			; Explosion object 1
explosionObj2	rs.b	oSize			; Explosion object 2
explosionObj3	rs.b	oSize			; Explosion object 3
explosionObj4	rs.b	oSize			; Explosion object 4
explosionObj5	rs.b	oSize			; Explosion object 5
explosionObj6	rs.b	oSize			; Explosion object 6
explosionObj7	rs.b	oSize			; Explosion object 7
explosionObj8	rs.b	oSize			; Explosion object 8
EXPLODEOBJCNT	EQU	(__rs-explosionObjs)/oSize

ufoObjects	rs.b	0
ufoObject1	rs.b	oSize			; UFO object 1
ufoObject2	rs.b	oSize			; UFO object 2
ufoObject3	rs.b	oSize			; UFO object 3
ufoObject4	rs.b	oSize			; UFO object 4
ufoObject5	rs.b	oSize			; UFO object 5
ufoObject6	rs.b	oSize			; UFO object 6
UFOOBJCOUNT	EQU	(__rs-ufoObjects)/oSize

		rs.b	oSize
timeUFOObject	rs.b	oSize			; Time UFO object
OBJ2COUNT	EQU	(__rs-objPrioLevel2)/oSize

objPrioLevel3	rs.b	0			; Priority level 3 objects
ufoShadowObj1	rs.b	oSize			; UFO's shadow object 1
ufoShadowObj2	rs.b	oSize			; UFO's shadow object 2
ufoShadowObj3	rs.b	oSize			; UFO's shadow object 3
ufoShadowObj4	rs.b	oSize			; UFO's shadow object 4
ufoShadowObj5	rs.b	oSize			; UFO's shadow object 5
ufoShadowObj6	rs.b	oSize			; UFO's shadow object 6
		rs.b	oSize
timeUFOShadObj	rs.b	oSize			; Time UFO's shadow object
OBJ3COUNT	EQU	(__rs-objPrioLevel3)/oSize

ZBUFLEVELS	EQU	64			; Z buffer levels
ZBUFSLOTS	EQU	8			; Z buffer slots per level

zBuffer		rs.w	ZBUFLEVELS*ZBUFSLOTS	; Z buffer
		rs.b	$700
gfxOpFlag	rs.b	1			; Graphics operation flag
		rs.b	1
curSpriteSlot	rs.l	1			; Current sprite slot pointer
spriteCount	rs.b	1			; Sprite count
		rs.b	5
stampTypes	rs.l	1			; Stamp types list pointer
rngSeed		rs.l	1			; RNG seed
stageOver	rs.b	1			; Stage over flag
gotTimeStone	rs.b	1			; Time stone retrieved flag
timerSpeedUp	rs.b	1			; Timer speed up counter
timerFrames	rs.b	1			; Timer frame counter
stageInactive	rs.b	1			; Stage inactive flag
timeStopped	rs.b	1			; Time stopped flag
ufoRingBonus	rs.w	1			; UFO ring bonus counter
jumpTimer	rs.w	1			; Jump timer
playerCtrlData	rs.b	0			; Player controller data
playerCtrlHold	rs.b	1			; Player controller held buttons data
playerCtrlTap	rs.b	1			; Player controller tapped buttons data
lostRingXDir	rs.b	1			; Lost ring X direction
		rs.b	1
stampAnim1Data	rs.l	1			; Stamp animation 1 data pointer
stampAnim1Count	rs.w	1			; Stamp animation 1 data count
stampAnim2Data	rs.l	1			; Stamp animation 2 data pointer
stampAnim2Count	rs.w	1			; Stamp animation 2 data count
stampAnim1Delay	rs.w	1			; Stamp animation 1 delay counter
stampAnim1Frame	rs.w	1			; Stamp animation 1 frame	
stampAnim2Frame	rs.w	1			; Stamp animation 2 frame
		rs.b	$CC
gfxVars		rs.b	gfxSize			; Graphics operations variables
		rs.b	$1B9E
VARSSZ		EQU	__rs-VARSSTART		; Size of variables area

; -------------------------------------------------------------------------
; Program start
; -------------------------------------------------------------------------

	org	$10000

	move.l	#IRQ1,_LEVEL1+2.w		; Set graphics interrupt handler
	move.b	#0,GAMEMMODE.w			; Set to 2M mode

	moveq	#0,d0
	move.l	d0,specStageTimer.w		; Reset timer
	move.w	d0,specStageRings.w		; Reset rings
	move.b	#6,ufoCount.w			; Reset UFO count
	
	bset	#7,GASUBFLAG.w			; Mark as started
	bclr	#1,GAIRQMASK.w			; Disable graphics interrupt
	move.b	#3,GACDCDEVICE.w		; Set CDC device to "Sub CPU"
	
	bsr.w	WaitWordRAMAccess		; Wait for Word RAM access

	lea	VARSSTART,a0			; Clear variables
	move.w	#VARSSZ/4-1,d7

.ClearVariables:
	move.l	#0,(a0)+
	dbf	d7,.ClearVariables
	
	bsr.w	InitGfxOperation		; Initialize graphics operation
	
	lea	WORDRAM2M,a0			; Clear Word RAM
	move.w	#WORDRAM2MS/8-1,d7

.ClearWordRAM:
	move.l	#0,(a0)+
	move.l	#0,(a0)+
	dbf	d7,.ClearWordRAM
	
	bsr.w	LoadStageMap			; Load stage map
	bsr.w	GetStampTypes			; Get stamp types

	move.b	#1,sonicObject+oID		; Spawn Sonic
	move.b	#6,sonicShadowObj+oID		; Spawn Sonic's shadow
	move.b	#$A,ttlCardBarObj+oID		; Spawn title card bar
	move.b	#$B,ttlCardTextObj+oID		; Spawn title card text
	bsr.w	SpawnUFOs			; Spawn UFOs

	bsr.w	InitStampAnim			; Initialize stamp animation
	move.b	#60/3,timerFrames		; Set timer frame counter
	move.w	#20,ufoRingBonus		; Set initial UFO ring bonus
	move.b	#1,stageInactive		; Mark stage as inactive

	btst	#1,specStageFlags.w		; Are we in time attack mode?
	bne.s	.NoCountdown			; If so, branch
	move.l	#100,specStageTimer.w		; If not, set timer to 100 seconds

.NoCountdown:
	bset	#1,GAIRQMASK.w			; Enable graphics interrupt
	bclr	#7,GASUBFLAG.w			; Mark as initialized

; -------------------------------------------------------------------------

MainLoop:
	btst	#5,GAMAINFLAG.w			; Is the Main CPU side paused?
	beq.s	.NotPaused			; If not, branch
	move.w	#MSCPAUSEON,d0			; Pause music
	jsr	_CDBIOS.w

.PauseLoop:
	btst	#1,specStageFlags.w		; Are we in time attack mode?
	beq.s	.CheckUnpause			; If not, branch
	move.b	ctrlData.w,d0			; Have A, B, or C been presed?
	andi.b	#$70,d0
	beq.s	.CheckUnpause			; If not, branch
	bset	#5,GASUBFLAG.w			; If so, exit the stage
	bra.w	.Exit

.CheckUnpause:
	btst	#5,GAMAINFLAG.w			; Is the Main CPU side paused?
	bne.s	.PauseLoop			; If so, loop
	move.w	#MSCPAUSEOFF,d0			; Unpause music
	jsr	_CDBIOS.w

.NotPaused:
	btst	#0,GACOMCMD2.w			; Should we start updating?
	beq.s	MainLoop			; If not, wait

	bsr.w	WaitWordRAMAccess		; Wait for Word RAM access
	move.l	#0,subSndQueue1			; Clear sound queues

	bset	#0,GACOMSTAT2.w			; Respond to the Main CPU

.WaitMainCPU:
	btst	#0,GACOMCMD2.w			; Has the Main CPU responded?
	bne.s	.WaitMainCPU			; If not, wait
	bclr	#0,GACOMSTAT2.w			; Communication is done

	bsr.w	AnimateStamps			; Animate stamps
	bsr.w	GetGfxSines			; Get sines for graphics operation
	bsr.w	RunGfxOperation			; Run graphics operation
	
	move.b	#0,spriteCount			; Reset sprites
	move.l	#subSprites,curSpriteSlot
	bsr.w	Init3DSpritePos

	bsr.w	RunObjects			; Run objects

	movea.l	curSpriteSlot,a0		; Set terminating sprite slot
	move.l	#0,(a0)

	bsr.w	UpdateTimer			; Update timer

.WaitGfx:
	tst.b	GAIMGVDOT+1.w			; Has the graphics operation finished?
	bne.s	.WaitGfx			; If not, wait

	bsr.w	GiveWordRAMAccess		; Give Word RAM access to the Main CPU
	
	bsr.w	CheckUFOPresence		; Are there any UFOs left?
	bne.s	.NotOver			; If so, branch

	move.b	specStageFlags.w,d0		; Are we in temporary or time attack mode?
	andi.b	#3,d0
	beq.s	.NotOver			; If not, branch
	move.b	#1,stageOver			; Stage is now over

.NotOver:
	btst	#0,specStageFlags.w		; Are we in time attack mode?
	beq.s	.CheckExit			; If not, branch
	btst	#7,ctrlData.w			; Has the start button been pressed?
	bne.s	.Exit				; If so, branch

.CheckExit:
	tst.b	stageOver			; Is the stage over?
	bne.s	.Exit				; If so, branch
	tst.b	gotTimeStone			; Did we get the time stone?
	bne.s	.StageBeaten			; If so, branch
	bra.w	MainLoop			; Loop

.StageBeaten:
	bset	#0,GASUBFLAG.w			; Mark stage as over
	moveq	#0,d0				; Mark time stone as retrieved
	move.b	specStageID.w,d0
	bset	d0,timeStonesSub.w

.Exit:
	bset	#0,GASUBFLAG.w			; Mark stage as over

	move.b	specStageID.w,d0		; Search for next stage ID

.GetNextStage:
	addq.b	#1,d0
	cmpi.b	#7,d0
	bcs.s	.CheckTimeStone
	moveq	#0,d0

.CheckTimeStone:
	cmpi.b	#%1111111,timeStonesSub.w	; Did we get all the time stones?
	beq.s	.SetNextStage			; If so, branch
	btst	d0,timeStonesSub.w		; Is the next stage selected already beaten?
	bne.s	.GetNextStage			; If so, search again

.SetNextStage:
	move.b	d0,specStageID.w		; Set next stage ID

.WaitMainCPUDone:
	btst	#0,GAMAINFLAG.w			; Wait for the Main CPU to respond
	beq.s	.WaitMainCPUDone

	moveq	#0,d0				; Clear communication statuses
	move.b	d0,GASUBFLAG.w
	move.l	d0,GACOMSTAT0.w
	move.l	d0,GACOMSTAT4.w
	move.l	d0,GACOMSTAT8.w
	move.l	d0,GACOMSTATC.w
	rts

; -------------------------------------------------------------------------
; Check for UFO presence
; -------------------------------------------------------------------------
; RETURNS:
;	eq/ne - No UFOs found/UFOs found
; -------------------------------------------------------------------------

CheckUFOPresence:
	lea	ufoObject1,a0			; Check UFO 1
	tst.b	(a0)
	bne.s	.End
	tst.b	ufoObject2-ufoObject1(a0)	; Check UFO 2
	bne.s	.End
	tst.b	ufoObject3-ufoObject1(a0)	; Check UFO 3
	bne.s	.End
	tst.b	ufoObject4-ufoObject1(a0)	; Check UFO 4
	bne.s	.End
	tst.b	ufoObject5-ufoObject1(a0)	; Check UFO 5
	bne.s	.End
	tst.b	ufoObject6-ufoObject1(a0)	; Check UFO 6

.End:
	rts

; -------------------------------------------------------------------------
; Graphics operation interrupt
; -------------------------------------------------------------------------

IRQ1:
	move.b	#0,gfxOpFlag			; Clear graphics operation flag
	rte

; -------------------------------------------------------------------------
; Load stage map
; -------------------------------------------------------------------------

LoadStageMap:
	moveq	#0,d0				; Run routine
	move.b	specStageID.w,d0
	add.w	d0,d0
	move.w	StageMaps(pc,d0.w),d0
	jmp	StageMaps(pc,d0.w)

; -------------------------------------------------------------------------

StageMaps:
	dc.w	LoadMap_SS1-StageMaps		; Stage 1
	dc.w	LoadMap_SS2-StageMaps		; Stage 2
	dc.w	LoadMap_SS3-StageMaps		; Stage 3
	dc.w	LoadMap_SS4-StageMaps		; Stage 4
	dc.w	LoadMap_SS5-StageMaps		; Stage 5
	dc.w	LoadMap_SS6-StageMaps		; Stage 6
	dc.w	LoadMap_SS7-StageMaps		; Stage 7
	dc.w	LoadMap_SS8-StageMaps		; Stage 8

; -------------------------------------------------------------------------

LoadMap_SS1:
	lea	Stamps_SS1,a0			; Load stamps and stamp map
	lea	StampMap_SS1,a1
	bra.s	LoadStamps

; -------------------------------------------------------------------------

LoadMap_SS2:
	lea	Stamps_SS2,a0			; Load stamps and stamp map
	lea	StampMap_SS2,a1
	bra.s	LoadStamps

; -------------------------------------------------------------------------

LoadMap_SS3:
	lea	Stamps_SS3_1,a0			; Load stamps and stamp map
	lea	StampMap_SS3,a1
	bsr.s	LoadStamps

	lea	Stamps_SS3_2,a0			; Load secondary stamps
	lea	WORDRAM2M+$10000,a1
	bra.w	KosDec

; -------------------------------------------------------------------------

LoadMap_SS4:
	lea	Stamps_SS4,a0			; Load stamps and stamp map
	lea	StampMap_SS4,a1
	bra.s	LoadStamps

; -------------------------------------------------------------------------

LoadMap_SS5:
	lea	Stamps_SS5,a0			; Load stamps and stamp map
	lea	StampMap_SS5,a1
	bra.s	LoadStamps

; -------------------------------------------------------------------------

LoadMap_SS6:
	lea	Stamps_SS6,a0			; Load stamps and stamp map
	lea	StampMap_SS6,a1
	bra.s	LoadStamps

; -------------------------------------------------------------------------

LoadMap_SS7:
	lea	Stamps_SS7,a0			; Load stamps and stamp map
	lea	StampMap_SS7,a1
	bra.s	LoadStamps

; -------------------------------------------------------------------------

LoadMap_SS8:
	lea	Stamps_SS8,a0			; Load stamps and stamp map
	lea	StampMap_SS8,a1

; -------------------------------------------------------------------------

LoadStamps:
	move.l	a1,-(sp)			; Load stamps
	lea	WORDRAM2M+$200,a1
	bsr.w	KosDec
	
	movea.l	(sp)+,a0			; Load stamp map
	lea	WORDRAM2M+STAMPMAP,a1
	bra.w	KosDec

; -------------------------------------------------------------------------
; Decompress Kosinski data into RAM
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Kosinski data pointer
;	a1.l - Destination buffer pointer
; -------------------------------------------------------------------------

KosDec:
	subq.l	#2,sp				; Allocate 2 bytes on the stack
	move.b	(a0)+,1(sp)
	move.b	(a0)+,(sp)
	move.w	(sp),d5				; Get first description field
	moveq	#$F,d4				; Set to loop for 16 bits

KosDec_Loop:
	lsr.w	#1,d5				; Shift bit into the C flag
	move	sr,d6
	dbf	d4,.ChkBit
	move.b	(a0)+,1(sp)
	move.b	(a0)+,(sp)
	move.w	(sp),d5
	moveq	#$F,d4

.ChkBit:
	move	d6,ccr				; Was the bit set?
	bcc.s	KosDec_RLE			; If not, branch

	move.b	(a0)+,(a1)+			; Copy byte as is
	bra.s	KosDec_Loop

; -------------------------------------------------------------------------

KosDec_RLE:
	moveq	#0,d3
	lsr.w	#1,d5				; Get next bit
	move	sr,d6
	dbf	d4,.ChkBit
	move.b	(a0)+,1(sp)
	move.b	(a0)+,(sp)
	move.w	(sp),d5
	moveq	#$F,d4

.ChkBit:
	move	d6,ccr				; Was the bit set?
	bcs.s	KosDec_SeparateRLE		; If yes, branch

	lsr.w	#1,d5				; Shift bit into the X flag
	dbf	d4,.Loop
	move.b	(a0)+,1(sp)
	move.b	(a0)+,(sp)
	move.w	(sp),d5
	moveq	#$F,d4

.Loop:
	roxl.w	#1,d3				; Get high repeat count bit
	lsr.w	#1,d5
	dbf	d4,.Loop2
	move.b	(a0)+,1(sp)
	move.b	(a0)+,(sp)
	move.w	(sp),d5
	moveq	#$F,d4

.Loop2:
	roxl.w	#1,d3				; Get low repeat count bit
	addq.w	#1,d3				; Increment repeat count
	moveq	#$FFFFFFFF,d2
	move.b	(a0)+,d2			; Calculate offset
	bra.s	KosDec_RLELoop

; -------------------------------------------------------------------------

KosDec_SeparateRLE:
	move.b	(a0)+,d0			; Get first byte
	move.b	(a0)+,d1			; Get second byte
	moveq	#$FFFFFFFF,d2
	move.b	d1,d2
	lsl.w	#5,d2
	move.b	d0,d2				; Calculate offset
	andi.w	#7,d1				; Does a third byte need to be read?
	beq.s	KosDec_SeparateRLE2		; If yes, branch
	move.b	d1,d3				; Copy repeat count
	addq.w	#1,d3				; Increment

KosDec_RLELoop:
	move.b	(a1,d2.w),d0			; Copy appropriate byte
	move.b	d0,(a1)+			; Repeat
	dbf	d3,KosDec_RLELoop
	bra.s	KosDec_Loop

; -------------------------------------------------------------------------

KosDec_SeparateRLE2:
	move.b	(a0)+,d1
	beq.s	KosDec_Done			; 0 indicates end of compressed data
	cmpi.b	#1,d1
	beq.w	KosDec_Loop			; 1 indicates new description to be read
	move.b	d1,d3				; Otherwise, copy repeat count
	bra.s	KosDec_RLELoop

; -------------------------------------------------------------------------

KosDec_Done:
	addq.l	#2,sp				; Deallocate the 2 bytes
	rts

; -------------------------------------------------------------------------
; Unknown
; -------------------------------------------------------------------------

	jmp	$500000
	jmp	$510000
	jmp	$520000
	jmp	$530000
	jmp	$540000
	jmp	$550000
	jmp	$560000
	jmp	$570000
	jmp	$580000
	jmp	$590000
	jmp	$5A0000
	jmp	$5B0000
	jmp	$5C0000
	jmp	$5D0000
	jmp	$5E0000
	jmp	$5F0000

; -------------------------------------------------------------------------
; Run objects
; -------------------------------------------------------------------------

RunObjects:
	bsr.w	InitZBuffer			; Initialize Z buffer
	
	lea	objPrioLevel1,a0		; Run priority level 1 objects
	moveq	#OBJ1COUNT-1,d7

.Priority1:
	bsr.s	RunObject
	adda.w	#oSize,a0
	dbf	d7,.Priority1
	
	lea	sonicObject,a0			; Run Sonic object
	bsr.s	RunObject
	lea	sonicShadowObj,a0		; Run Sonic's shadow object
	bsr.s	RunObject
	
	lea	objPrioLevel2,a0		; Run priority level 2 objects
	moveq	#OBJ2COUNT-1,d7

.Priority2:
	bsr.s	RunObject
	adda.w	#oSize,a0
	dbf	d7,.Priority2
	
	bsr.w	Draw3DObjects			; Draw 3D objects
	
	lea	objPrioLevel3,a0		; Run priority level 3 objects
	moveq	#OBJ3COUNT-1,d7

.Priority3:
	bsr.s	RunObject
	adda.w	#oSize,a0
	dbf	d7,.Priority3
	
	rts

; -------------------------------------------------------------------------
; Run object
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to object slot
; -------------------------------------------------------------------------

RunObject:
	moveq	#0,d0				; Get object address
	move.b	(a0),d0
	beq.s	.End
	lea	ObjectIndex-4(pc),a1
	add.w	d0,d0
	add.w	d0,d0
	movea.l	(a1,d0.w),a1

	move.w	d7,-(sp)			; Run object
	jsr	(a1)
	move.w	(sp)+,d7

	btst	#0,oFlags(a0)			; Should this object be deleted?
	beq.s	.End				; If not, branch
	movea.l	a0,a1				; If so, delete it
	moveq	#0,d1
	bra.w	Fill128
	
.End:
	rts

; -------------------------------------------------------------------------
; Initialize Z buffer
; -------------------------------------------------------------------------

InitZBuffer:
	lea	zBuffer,a6			; Get Z buffer
	moveq	#0,d5				; Fill with 0
	moveq	#ZBUFSLOTS*2,d6			; Number of slots per level
	moveq	#ZBUFLEVELS-1,d7		; Number of levels

.Clear:
	move.w	d5,(a6)				; Reset level
	adda.w	d6,a6				; Next level
	dbf	d7,.Clear			; Loop until Z buffer is initialized
	rts

; -------------------------------------------------------------------------
; Set an object for drawing in a 3D space
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - Z buffer level
;	a0.l - Pointer to object slot
; -------------------------------------------------------------------------

Set3DObjectDraw:
	move.l	d0,-(sp)			; Save d0

	cmpi.l	#ZBUFLEVELS*$40,d0		; Is the Z buffer level too high?
	bcs.s	.GotLevel			; If not, branch
	move.l	#(ZBUFLEVELS*$40)-1,d0		; If so, cap it

.GotLevel:
	lsr.w	#2,d0				; Get proper Z buffer level
	andi.w	#$3F0,d0

	lea	zBuffer,a6			; Get Z buffer level
	lea	(a6,d0.w),a6

	moveq	#ZBUFSLOTS-1-1,d7		; Start searching for free slot

.FindSlot:
	tst.w	(a6)+				; Is this slot free?
	beq.s	.Set				; If so, branch
	dbf	d7,.FindSlot			; If not, loop

.Set:
	move.w	a0,-2(a6)			; Set object in slot
	move.w	#0,(a6)				; Set termination

	move.l	(sp)+,d0			; Restore d0
	rts

; -------------------------------------------------------------------------
; Draw 3D objects
; -------------------------------------------------------------------------

Draw3DObjects:
	move.l	#zBuffer,d4			; Get Z buffer
	move.l	#DataSection,d5			; Use data section
	moveq	#ZBUFSLOTS*2,d6			; Number of slots per level
	moveq	#ZBUFLEVELS-1,d7		; Number of levels

.Draw:
	movea.l	d4,a6				; Draw objects in Z buffer level
	bsr.s	DrawZBufObjLevel
	add.l	d6,d4				; Next level
	dbf	d7,.Draw			; Loop until objects are drawn
	rts

; -------------------------------------------------------------------------
; Draw objects in Z buffer level
; -------------------------------------------------------------------------
; PARAMETERS:
;	a6.l - Pointer to Z buffer level
; -------------------------------------------------------------------------

DrawZBufObjLevel:
	rept	ZBUFSLOTS
		bsr.s	Draw3DObject
	endr
	rts

; -------------------------------------------------------------------------
; Draw 3D object queued in Z buffer
; -------------------------------------------------------------------------
; PARAMETERS:
;	a6.l - Pointer to Z buffer slot
; -------------------------------------------------------------------------

Draw3DObject:
	move.w	(a6)+,d5			; Is this slot occupied?
	beq.s	.NoObject			; If not, branch

	movea.l	d5,a0				; Draw object
	movem.l	d4-d7,-(sp)
	bsr.w	DrawObject
	movem.l	(sp)+,d4-d7
	rts

.NoObject:
	move.l	(sp)+,d0			; Force out of Z buffer level
	rts

; -------------------------------------------------------------------------
; Set object sprite (resets animation)
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.b - Sprite ID
;	a0.l - Pointer to object slot
; -------------------------------------------------------------------------

SetObjSprite:
	move.b	d0,oSprite(a0)			; Set sprite ID
	
	moveq	#0,d0				; Reset sprite frame
	move.b	d0,oSpriteFrame(a0)

	movea.l	oSprites(a0),a6		; Get sprite data
	move.b	oSprite(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	movea.l	(a6,d0.w),a6

	move.b	(a6)+,d0			; Skip over number of frames
	move.b	(a6),oAnimTime(a0)		; Get animation speed
	move.b	(a6)+,oAnimTime2(a0)
	rts

; -------------------------------------------------------------------------
; Change object sprite (doesn't reset animation)
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.b - Sprite ID
;	a0.l - Pointer to object slot
; -------------------------------------------------------------------------

ChgObjSprite:
	move.b	d0,oSprite(a0)			; Set sprite ID

	movea.l	oSprites(a0),a6		; Get sprite data
	moveq	#0,d0
	move.b	oSprite(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	movea.l	(a6,d0.w),a6

	move.b	(a6)+,d0			; Skip over number of frames
	move.b	(a6),oAnimTime(a0)		; Get animation speed
	move.b	(a6)+,oAnimTime2(a0)
	rts

; -------------------------------------------------------------------------
; Draw object
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to object slot
; -------------------------------------------------------------------------

DrawObject:
	movea.l	oSprites(a0),a2		; Get sprite data
	moveq	#0,d0
	move.b	oSprite(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	movea.l	(a2,d0.w),a2

	move.b	(a2)+,d1			; Get number of frames
	move.b	(a2)+,d2			; Get animation speed

	btst	#1,oFlags(a0)			; Should this sprite be animated?
	bne.s	.GetSprite			; If not, branch

	subq.b	#1,oAnimTime(a0)		; Decrement animation time
	bpl.s	.GetSprite			; If it hasn't run out, branch
	move.b	d2,oAnimTime(a0)		; Reset animation time

	addq.b	#1,oSpriteFrame(a0)		; Increment sprite frame
	cmp.b	oSpriteFrame(a0),d1		; Has it gone past the last frame?
	bhi.s	.GetSprite			; If not, branch
	move.b	#0,oSpriteFrame(a0)		; Restart animation

.GetSprite:
	btst	#2,oFlags(a0)			; Should this sprite be drawn?
	bne.w	.End				; If not, branch

	move.w	oSprX(a0),d4			; Get sprite position
	move.w	oSprY(a0),d3

	moveq	#0,d0				; Get sprite frame data
	move.b	oSpriteFrame(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	movea.l	(a2,d0.w),a3

	moveq	#0,d7				; Get number of sprite pieces
	move.b	(a3)+,d7
	bmi.w	.End				; If there are none, branch

	move.b	(a3)+,oSpriteFlag(a0)		; Set sprite flag
	tst.b	(a3)+				; Skip over padding
	tst.b	(a3)+
	tst.b	(a3)+

	movea.l	curSpriteSlot,a4		; Get current sprite slot
	move.w	oTile(a0),d5			; Get base tile ID

	tst.b	(a2,d0.w)			; Check flip flags
	cmpi.b	#1,(a2,d0.w)			; Is the sprite horizontally flipped?
	beq.w	.XFlip				; If so, branch
	cmpi.b	#2,(a2,d0.w)			; Is the sprite vertically flipped?
	beq.w	.YFlip				; If so, branch
	cmpi.b	#3,(a2,d0.w)			; Is the sprite flipped both ways?
	beq.w	.XYFlip				; If so, branch

; -------------------------------------------------------------------------

.NoFlip:
	cmpi.b	#$50,spriteCount		; Is the sprite table full?
	bcc.s	.NoFlip_Done			; If so, branch

	move.b	(a3)+,d0			; Get Y position
	ext.w	d0
	add.w	d3,d0
	cmpi.w	#-32+128,d0			; Is it offscreen?
	ble.s	.NoFlip_SkipSprite		; If so, branch
	cmpi.w	#256+128,d0
	bge.s	.NoFlip_SkipSprite		; If so, branch
	move.w	d0,(a4)+			; Set Y position

	move.b	(a3)+,(a4)+			; Set size
	addq.b	#1,spriteCount			; Increment sprite count
	move.b	spriteCount,(a4)+		; Set link

	move.b	(a3)+,d0			; Set tile ID
	lsl.w	#8,d0
	move.b	(a3)+,d0
	add.w	d5,d0
	move.w	d0,(a4)+

	move.b	(a3)+,d0			; Get X position
	ext.w	d0
	add.w	d4,d0
	cmpi.w	#-32+128,d0			; Is it offscreen?
	ble.s	.NoFlip_Undo			; If so, branch
	cmpi.w	#320+128,d0
	bge.s	.NoFlip_Undo			; If so, branch
	andi.w	#$1FF,d0			; Is it 0?
	bne.s	.NoFlip_SetX			; If not, branch
	addq.w	#1,d0				; If so, force it to not be 0

.NoFlip_SetX:
	move.w	d0,(a4)+			; Set X position

.NoFlip_Next:
	dbf	d7,.NoFlip			; Loop until pieces are drawn

.NoFlip_Done:
	move.l	a4,curSpriteSlot		; Update current sprite slot
	rts

.NoFlip_SkipSprite:
	addq.w	#4,a3				; Skip over sprite
	bra.s	.NoFlip_Next
	
.NoFlip_Undo:
	subq.w	#6,a4				; Undo sprite data written
	subq.b	#1,spriteCount
	bra.s	.NoFlip_Next

; -------------------------------------------------------------------------

.XFlip:
	cmpi.b	#$50,spriteCount		; Is the sprite table full?
	bcc.s	.XFlip_Done			; If so, branch

	move.b	(a3)+,d0			; Get Y position
	ext.w	d0
	add.w	d3,d0
	cmpi.w	#-32+128,d0			; Is it offscreen?
	ble.s	.XFlip_SkipSprite		; If so, branch
	cmpi.w	#256+128,d0
	bge.s	.XFlip_SkipSprite		; If so, branch
	move.w	d0,(a4)+			; Set Y position

	move.b	(a3),d2				; Get size
	move.b	(a3)+,(a4)+			; Set size
	addq.b	#1,spriteCount			; Increment sprite count
	move.b	spriteCount,(a4)+		; Set link

	move.b	(a3)+,d0			; Set tile ID
	eori.b	#8,d0
	lsl.w	#8,d0
	move.b	(a3)+,d0
	add.w	d5,d0
	move.w	d0,(a4)+

	move.b	(a3)+,d0			; Get X position
	add.b	d2,d2
	addq.b	#8,d2
	andi.b	#$F8,d2
	add.b	d2,d0
	neg.b	d0
	ext.w	d0
	add.w	d4,d0
	cmpi.w	#-32+128,d0			; Is it offscreen?
	ble.s	.XFlip_Undo			; If so, branch
	cmpi.w	#320+128,d0
	bge.s	.XFlip_Undo			; If so, branch
	andi.w	#$1FF,d0			; Is it 0?
	bne.s	.XFlip_SetX			; If not, branch
	addq.w	#1,d0				; If so, force it to not be 0

.XFlip_SetX:
	move.w	d0,(a4)+			; Set X position

.XFlip_Next:
	dbf	d7,.XFlip			; Loop until pieces are drawn

.XFlip_Done:
	move.l	a4,curSpriteSlot		; Update current sprite slot
	rts

.XFlip_SkipSprite:
	addq.w	#4,a3				; Skip over sprite
	bra.s	.XFlip_Next

.XFlip_Undo:
	subq.w	#6,a4				; Undo sprite data written
	subq.b	#1,spriteCount
	bra.s	.XFlip_Next

; -------------------------------------------------------------------------

.YFlip:
	cmpi.b	#$50,spriteCount		; Is the sprite table full?
	bcc.s	.YFlip_Done			; If so, branch

	move.b	(a3)+,d0			; Get Y position
	move.b	(a3),d6
	ext.w	d0
	neg.w	d0
	lsl.b	#3,d6
	andi.w	#$18,d6
	addq.w	#8,d6
	sub.w	d6,d0
	add.w	d3,d0
	cmpi.w	#-32+128,d0			; Is it offscreen?
	ble.s	.YFlip_SkipSprite		; If so, branch
	cmpi.w	#256+128,d0
	bge.s	.YFlip_SkipSprite		; If so, branch
	move.w	d0,(a4)+			; Set Y position

	move.b	(a3)+,(a4)+			; Set size
	addq.b	#1,spriteCount			; Increment sprite count
	move.b	spriteCount,(a4)+		; Set link

	move.b	(a3)+,d0			; Set tile ID
	lsl.w	#8,d0
	move.b	(a3)+,d0
	add.w	d5,d0
	eori.w	#$1000,d0
	move.w	d0,(a4)+

	move.b	(a3)+,d0			; Get X position
	ext.w	d0
	add.w	d4,d0
	cmpi.w	#-32+128,d0			; Is it offscreen?
	ble.s	.YFlip_Undo			; If so, branch
	cmpi.w	#320+128,d0
	bge.s	.YFlip_Undo			; If so, branch
	andi.w	#$1FF,d0			; Is it 0?
	bne.s	.YFlip_SetX			; If not, branch
	addq.w	#1,d0				; If so, force it to not be 0

.YFlip_SetX:
	move.w	d0,(a4)+			; Set X position

.YFlip_Next:
	dbf	d7,.YFlip			; Loop until pieces are drawn

.YFlip_Done:
	move.l	a4,curSpriteSlot		; Update current sprite slot
	rts

.YFlip_SkipSprite:
	addq.w	#4,a3				; Skip over sprite
	bra.s	.YFlip_Next

.YFlip_Undo:
	subq.w	#6,a4				; Undo sprite data written
	subq.b	#1,spriteCount
	bra.s	.YFlip_Next
	
; -------------------------------------------------------------------------

.XYFlip:
	cmpi.b	#$50,spriteCount		; Is the sprite table full?
	bcc.s	.XYFlip_Done			; If so, branch

	move.b	(a3)+,d0			; Get Y position
	move.b	(a3),d6
	ext.w	d0
	neg.w	d0
	lsl.b	#3,d6
	andi.w	#$18,d6
	addq.w	#8,d6
	sub.w	d6,d0
	add.w	d3,d0
	cmpi.w	#-32+128,d0			; Is it offscreen?
	ble.s	.XYFlip_SkipSprite		; If so, branch
	cmpi.w	#256+128,d0
	bge.s	.XYFlip_SkipSprite		; If so, branch
	move.w	d0,(a4)+			; Set Y position
		
	move.b	(a3)+,d6			; Get size
	move.b	d6,(a4)+			; Set size
	addq.b	#1,spriteCount			; Increment sprite count
	move.b	spriteCount,(a4)+		; Set link
	
	move.b	(a3)+,d0			; Set tile ID
	lsl.w	#8,d0
	move.b	(a3)+,d0
	add.w	d5,d0
	eori.w	#$1800,d0
	move.w	d0,(a4)+

	move.b	(a3)+,d0			; Get X position
	ext.w	d0
	neg.w	d0
	add.b	d6,d6
	andi.w	#$18,d6
	addq.w	#8,d6
	sub.w	d6,d0
	add.w	d4,d0
	cmpi.w	#-32+128,d0			; Is it offscreen?
	ble.s	.XYFlip_Undo			; If so, branch
	cmpi.w	#320+128,d0
	bge.s	.XYFlip_Undo			; If so, branch
	andi.w	#$1FF,d0			; Is it 0?
	bne.s	.XYFlip_SetX			; If not, branch
	addq.w	#1,d0				; If so, force it to not be 0

.XYFlip_SetX:
	move.w	d0,(a4)+			; Set X position

.XYFlip_Next:
	dbf	d7,.XYFlip			; Loop until pieces are drawn

.XYFlip_Done:
	move.l	a4,curSpriteSlot		; Update current sprite slot
	rts

.XYFlip_SkipSprite:
	addq.w	#4,a3				; Skip over sprite
	bra.s	.XYFlip_Next

.XYFlip_Undo:
	subq.w	#6,a4				; Undo sprite data written
	subq.b	#1,spriteCount
	bra.s	.XYFlip_Next
	
; -------------------------------------------------------------------------

.End:
	rts

; -------------------------------------------------------------------------
; Object index
; -------------------------------------------------------------------------

ObjectIndex:
	dc.l	ObjSonic			; Sonic
	dc.l	ObjUFO				; UFO
	dc.l	ObjTimeUFO			; Time UFO
	dc.l	ObjItem				; Item
	dc.l	ObjUFOShadow			; UFO shadow
	dc.l	ObjSonicShadow			; Sonic's shadow
	dc.l	ObjDust				; Dust
	dc.l	ObjSplash			; Splash
	dc.l	ObjPressStart			; "Press Start"
	dc.l	ObjTitleCardText		; Title card text
	dc.l	ObjTitleCardBar			; Title card bar
	dc.l	ObjExplosion			; Explosion
	dc.l	ObjLostRing			; Lost ring
	dc.l	ObjTimeStone			; Time stone
	dc.l	ObjSparkle1			; Sparkle 1
	dc.l	ObjSparkle2			; Sparkle 2

; -------------------------------------------------------------------------
; Initialize stamp animation
; -------------------------------------------------------------------------

InitStampAnim:
	moveq	#0,d0				; Get stamp animation data
	move.b	specStageID.w,d0
	mulu.w	#$C,d0
	move.l	.Animations(pc,d0.w),stampAnim1Data
	move.w	.Animations+4(pc,d0.w),stampAnim1Count
	move.l	.Animations+6(pc,d0.w),stampAnim2Data
	move.w	.Animations+$A(pc,d0.w),stampAnim2Count
	rts

; -------------------------------------------------------------------------

.Animations:
	dc.l	StampAnim1_SS1			; Stage 1
	dc.w	$C-1
	dc.l	StampAnim2_SS1
	dc.w	8-1

	dc.l	StampAnim1_SS2			; Stage 2
	dc.w	$A-1
	dc.l	StampAnim2_SS2
	dc.w	8-1

	dc.l	StampAnim1_SS3			; Stage 3
	dc.w	8-1
	dc.l	StampAnim2_SS3
	dc.w	$C-1

	dc.l	StampAnim1_SS4			; Stage 4
	dc.w	$24-1
	dc.l	StampAnim2_SS4
	dc.w	$10-1

	dc.l	StampAnim1_SS5			; Stage 5
	dc.w	$B-1
	dc.l	StampAnim2_SS5
	dc.w	$C-1

	dc.l	StampAnim1_SS6			; Stage 6
	dc.w	$B-1
	dc.l	StampAnim2_SS6
	dc.w	$10-1

	dc.l	StampAnim1_SS7			; Stage 7
	dc.w	4-1
	dc.l	StampAnim2_SS7
	dc.w	4-1
	
	dc.l	StampAnim1_SS8			; Stage 8
	dc.w	$A-1
	dc.l	StampAnim2_SS8
	dc.w	$C-1

; -------------------------------------------------------------------------
; Animate stamps
; -------------------------------------------------------------------------

AnimateStamps:
	addq.w	#2,stampAnim2Frame		; Update second animation
	cmpi.w	#6,stampAnim2Frame
	bcs.s	.CheckAnim1
	move.w	#0,stampAnim2Frame

.CheckAnim1:
	addq.w	#1,stampAnim1Delay		; Increment first animation delay counter
	move.w	stampAnim1Delay,d0		; Is it time to update the animation?
	andi.w	#1,d0
	bne.w	.Anim2				; If not, branch

	addq.w	#2,stampAnim1Frame		; Update first animation
	andi.w	#7,stampAnim1Frame
	
	movea.l	stampAnim1Data,a0		; Get animation data
	lea	WORDRAM2M+STAMPMAP,a1		; Get stamp map
	move.w	stampAnim1Frame,d1		; Get frame ID
	move.w	stampAnim1Count,d7		; Get number of stamps to animate

.Anim1Loop:
	move.w	(a0),d0				; Set stamp ID
	move.w	2(a0,d1.w),d2
	move.w	d2,(a1,d0.w)
	adda.w	#$A,a0				; Next stamp to animate
	dbf	d7,.Anim1Loop			; Loop until stamps are animated

.Anim2:
	movea.l	stampAnim2Data,a0		; Get animation data
	lea	WORDRAM2M+STAMPMAP,a1		; Get stamp map
	move.w	stampAnim2Frame,d1		; Get frame ID
	move.w	stampAnim2Count,d7		; Get number of stamps to animate

.Anim2Loop:
	move.w	(a0),d0				; Set stamp ID
	move.w	2(a0,d1.w),d2
	move.w	d2,(a1,d0.w)
	adda.w	#8,a0				; Next stamp to animate
	dbf	d7,.Anim2Loop			; Loop until stamps are animated
	rts

; -------------------------------------------------------------------------

StampAnim1_SS1:
	dc.w	$277E, $016C, $0170, $0174, $0178
	dc.w	$287E, $016C, $0170, $0174, $0178
	dc.w	$297E, $016C, $0170, $0174, $0178
	dc.w	$2A7E, $016C, $0170, $0174, $0178
	dc.w	$3282, $016C, $0170, $0174, $0178
	dc.w	$3382, $016C, $0170, $0174, $0178
	dc.w	$3482, $016C, $0170, $0174, $0178
	dc.w	$3582, $016C, $0170, $0174, $0178
	dc.w	$3298, $016C, $0170, $0174, $0178
	dc.w	$3398, $016C, $0170, $0174, $0178
	dc.w	$3498, $016C, $0170, $0174, $0178
	dc.w	$3598, $016C, $0170, $0174, $0178

StampAnim2_SS1:
	dc.w	$4484, $6160, $6164, $6168
	dc.w	$4486, $4160, $4164, $4168
	dc.w	$4584, $0160, $0164, $0168
	dc.w	$4586, $2160, $2164, $2168
	dc.w	$4488, $6160, $6164, $6168
	dc.w	$448A, $4160, $4164, $4168
	dc.w	$4588, $0160, $0164, $0168
	dc.w	$458A, $2160, $2164, $2168

StampAnim1_SS2:
	dc.w	$4C68, $01AC, $01B0, $01B4, $01B8
	dc.w	$4D66, $01AC, $01B0, $01B4, $01B8
	dc.w	$4E64, $01AC, $01B0, $01B4, $01B8
	dc.w	$4A6C, $01AC, $01B0, $01B4, $01B8
	dc.w	$4B6E, $01AC, $01B0, $01B4, $01B8
	dc.w	$4C70, $01AC, $01B0, $01B4, $01B8
	dc.w	$3F7E, $01AC, $01B0, $01B4, $01B8
	dc.w	$3F80, $01AC, $01B0, $01B4, $01B8
	dc.w	$407E, $01AC, $01B0, $01B4, $01B8
	dc.w	$4080, $01AC, $01B0, $01B4, $01B8

StampAnim2_SS2:
	dc.w	$47B0, $61A0, $61A4, $61A8
	dc.w	$47B2, $41A0, $41A4, $41A8
	dc.w	$48B0, $01A0, $01A4, $01A8
	dc.w	$48B2, $21A0, $21A4, $21A8
	dc.w	$3098, $61A0, $61A4, $61A8
	dc.w	$309A, $41A0, $41A4, $41A8
	dc.w	$3198, $01A0, $01A4, $01A8
	dc.w	$319A, $21A0, $21A4, $21A8

StampAnim1_SS3:
	dc.w	$2F70, $01EC, $01F0, $01F4, $01F8
	dc.w	$2F72, $01EC, $01F0, $01F4, $01F8
	dc.w	$2F74, $01EC, $01F0, $01F4, $01F8
	dc.w	$2F76, $01EC, $01F0, $01F4, $01F8
	dc.w	$4F5E, $01EC, $01F0, $01F4, $01F8
	dc.w	$4F60, $01EC, $01F0, $01F4, $01F8
	dc.w	$4F62, $01EC, $01F0, $01F4, $01F8
	dc.w	$4F64, $01EC, $01F0, $01F4, $01F8

StampAnim2_SS3:
	dc.w	$4088, $61E0, $61E4, $61E8
	dc.w	$408A, $41E0, $41E4, $41E8
	dc.w	$4188, $01E0, $01E4, $01E8
	dc.w	$418A, $21E0, $21E4, $21E8
	dc.w	$408C, $61E0, $61E4, $61E8
	dc.w	$408E, $41E0, $41E4, $41E8
	dc.w	$418C, $01E0, $01E4, $01E8
	dc.w	$418E, $21E0, $21E4, $21E8
	dc.w	$50B0, $61E0, $61E4, $61E8
	dc.w	$50B2, $41E0, $41E4, $41E8
	dc.w	$51B0, $01E0, $01E4, $01E8
	dc.w	$51B2, $21E0, $21E4, $21E8

StampAnim1_SS4:
	dc.w	$3576, $01CC, $01D0, $01D4, $01D8
	dc.w	$3676, $01CC, $01D0, $01D4, $01D8
	dc.w	$3776, $01CC, $01D0, $01D4, $01D8
	dc.w	$3876, $01CC, $01D0, $01D4, $01D8
	dc.w	$4788, $01CC, $01D0, $01D4, $01D8
	dc.w	$4888, $01CC, $01D0, $01D4, $01D8
	dc.w	$4988, $01CC, $01D0, $01D4, $01D8
	dc.w	$4A88, $01CC, $01D0, $01D4, $01D8
	dc.w	$269C, $01CC, $01D0, $01D4, $01D8
	dc.w	$279A, $01CC, $01D0, $01D4, $01D8
	dc.w	$2898, $01CC, $01D0, $01D4, $01D8
	dc.w	$2996, $01CC, $01D0, $01D4, $01D8
	dc.w	$26AC, $01CC, $01D0, $01D4, $01D8
	dc.w	$27AA, $01CC, $01D0, $01D4, $01D8
	dc.w	$28A8, $01CC, $01D0, $01D4, $01D8
	dc.w	$29A6, $01CC, $01D0, $01D4, $01D8
	dc.w	$2AA4, $01CC, $01D0, $01D4, $01D8
	dc.w	$2BA2, $01CC, $01D0, $01D4, $01D8
	dc.w	$2CA0, $01CC, $01D0, $01D4, $01D8
	dc.w	$2D9E, $01CC, $01D0, $01D4, $01D8
	dc.w	$27AE, $01CC, $01D0, $01D4, $01D8
	dc.w	$28AC, $01CC, $01D0, $01D4, $01D8
	dc.w	$29AA, $01CC, $01D0, $01D4, $01D8
	dc.w	$2AA8, $01CC, $01D0, $01D4, $01D8
	dc.w	$2BA6, $01CC, $01D0, $01D4, $01D8
	dc.w	$2CA4, $01CC, $01D0, $01D4, $01D8
	dc.w	$2DA2, $01CC, $01D0, $01D4, $01D8
	dc.w	$2EA0, $01CC, $01D0, $01D4, $01D8
	dc.w	$29B8, $01CC, $01D0, $01D4, $01D8
	dc.w	$2AB6, $01CC, $01D0, $01D4, $01D8
	dc.w	$2BB4, $01CC, $01D0, $01D4, $01D8
	dc.w	$2CB2, $01CC, $01D0, $01D4, $01D8
	dc.w	$2ABA, $01CC, $01D0, $01D4, $01D8
	dc.w	$2BB8, $01CC, $01D0, $01D4, $01D8
	dc.w	$2CB6, $01CC, $01D0, $01D4, $01D8
	dc.w	$2DB4, $01CC, $01D0, $01D4, $01D8

StampAnim2_SS4:
	dc.w	$565C, $61C0, $61C4, $61C8
	dc.w	$565E, $41C0, $41C4, $41C8
	dc.w	$575C, $01C0, $01C4, $01C8
	dc.w	$575E, $21C0, $21C4, $21C8
	dc.w	$5660, $61C0, $61C4, $61C8
	dc.w	$5662, $41C0, $41C4, $41C8
	dc.w	$5760, $01C0, $01C4, $01C8
	dc.w	$5762, $21C0, $21C4, $21C8
	dc.w	$524C, $61C0, $61C4, $61C8
	dc.w	$524E, $41C0, $41C4, $41C8
	dc.w	$534C, $01C0, $01C4, $01C8
	dc.w	$534E, $21C0, $21C4, $21C8
	dc.w	$5250, $61C0, $61C4, $61C8
	dc.w	$5252, $41C0, $41C4, $41C8
	dc.w	$5350, $01C0, $01C4, $01C8
	dc.w	$5352, $21C0, $21C4, $21C8

StampAnim1_SS5:
	dc.w	$2274, $01B0, $01B4, $01B8, $01BC
	dc.w	$2374, $01B0, $01B4, $01B8, $01BC
	dc.w	$2474, $01B0, $01B4, $01B8, $01BC
	dc.w	$4178, $01B0, $01B4, $01B8, $01BC
	dc.w	$427A, $01B0, $01B4, $01B8, $01BC
	dc.w	$437C, $01B0, $01B4, $01B8, $01BC
	dc.w	$447E, $01B0, $01B4, $01B8, $01BC
	dc.w	$517C, $01B0, $01B4, $01B8, $01BC
	dc.w	$527A, $01B0, $01B4, $01B8, $01BC
	dc.w	$5378, $01B0, $01B4, $01B8, $01BC
	dc.w	$5476, $01B0, $01B4, $01B8, $01BC

StampAnim2_SS5:
	dc.w	$2970, $61A4, $61A8, $61AC
	dc.w	$2972, $41A4, $41A8, $41AC
	dc.w	$2A70, $01A4, $01A8, $01AC
	dc.w	$2A72, $21A4, $21A8, $21AC
	dc.w	$405C, $61A4, $61A8, $61AC
	dc.w	$405E, $41A4, $41A8, $41AC
	dc.w	$415C, $01A4, $01A8, $01AC
	dc.w	$415E, $21A4, $21A8, $21AC
	dc.w	$4A90, $61A4, $61A8, $61AC
	dc.w	$4A92, $41A4, $41A8, $41AC
	dc.w	$4B90, $01A4, $01A8, $01AC
	dc.w	$4B92, $21A4, $21A8, $21AC

StampAnim1_SS6:
	dc.w	$393A, $016C, $0170, $0174, $0178
	dc.w	$3A3A, $016C, $0170, $0174, $0178
	dc.w	$493A, $016C, $0170, $0174, $0178
	dc.w	$4A3A, $016C, $0170, $0174, $0178
	dc.w	$5BC0, $016C, $0170, $0174, $0178
	dc.w	$5CBE, $016C, $0170, $0174, $0178
	dc.w	$5CC0, $016C, $0170, $0174, $0178
	dc.w	$2994, $016C, $0170, $0174, $0178
	dc.w	$2996, $016C, $0170, $0174, $0178
	dc.w	$2A92, $016C, $0170, $0174, $0178
	dc.w	$2A94, $016C, $0170, $0174, $0178

StampAnim2_SS6:
	dc.w	$2298, $6160, $6164, $6168
	dc.w	$229A, $4160, $4164, $4168
	dc.w	$2398, $0160, $0164, $0168
	dc.w	$239A, $2160, $2164, $2168
	dc.w	$325C, $6160, $6164, $6168
	dc.w	$325E, $4160, $4164, $4168
	dc.w	$335C, $0160, $0164, $0168
	dc.w	$335E, $2160, $2164, $2168
	dc.w	$4A94, $6160, $6164, $6168
	dc.w	$4A96, $4160, $4164, $4168
	dc.w	$4B94, $0160, $0164, $0168
	dc.w	$4B96, $2160, $2164, $2168
	dc.w	$4C5C, $6160, $6164, $6168
	dc.w	$4C5E, $4160, $4164, $4168
	dc.w	$4D5C, $0160, $0164, $0168
	dc.w	$4D5E, $2160, $2164, $2168

StampAnim1_SS7:
	dc.w	$2144, $01A4, $01A8, $01AC, $01B0
	dc.w	$2242, $01A4, $01A8, $01AC, $01B0
	dc.w	$2148, $01A4, $01A8, $01AC, $01B0
	dc.w	$2246, $01A4, $01A8, $01AC, $01B0

StampAnim2_SS7:
	dc.w	$3464, $6198, $619C, $61A0
	dc.w	$3466, $4198, $419C, $41A0
	dc.w	$3564, $0198, $019C, $01A0
	dc.w	$3566, $2198, $219C, $21A0

StampAnim1_SS8:
	dc.w	$353C, $016C, $0170, $0174, $0178
	dc.w	$3542, $016C, $0170, $0174, $0178
	dc.w	$599C, $016C, $0170, $0174, $0178
	dc.w	$5A9E, $016C, $0170, $0174, $0178
	dc.w	$5B9C, $016C, $0170, $0174, $0178
	dc.w	$5C9E, $016C, $0170, $0174, $0178
	dc.w	$5D9C, $016C, $0170, $0174, $0178
	dc.w	$2486, $016C, $0170, $0174, $0178
	dc.w	$2586, $016C, $0170, $0174, $0178
	dc.w	$2686, $016C, $0170, $0174, $0178

StampAnim2_SS8:
	dc.w	$3D3E, $6160, $6164, $6168
	dc.w	$3D40, $4160, $4164, $4168
	dc.w	$3E3E, $0160, $0164, $0168
	dc.w	$3E40, $2160, $2164, $2168
	dc.w	$3D82, $6160, $6164, $6168
	dc.w	$3D84, $4160, $4164, $4168
	dc.w	$3E82, $0160, $0164, $0168
	dc.w	$3E84, $2160, $2164, $2168
	dc.w	$5A82, $6160, $6164, $6168
	dc.w	$5A84, $4160, $4164, $4168
	dc.w	$5B82, $0160, $0164, $0168
	dc.w	$5B84, $2160, $2164, $2168

; -------------------------------------------------------------------------
; Check player collision with a UFO
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to UFO object slot
; -------------------------------------------------------------------------

ObjUFO_CheckPlayerCol:
	lea	sonicObject,a1			; Get Sonic object
	tst.b	oID(a1)				; Is Sonic spawned in?
	beq.w	.End				; If not, branch
	tst.b	oPlayerUFOCol(a1)		; Is collision already taking place?
	bne.w	.End				; If so, branch

	move.w	oX(a0),d0			; Get UFO's left boundary
	subi.w	#16,d0
	move.w	d0,d1				; Get UFO's right boundary
	addi.w	#16*2,d1
	move.w	oX(a1),d2			; Get Sonic's left boundary
	subi.w	#16,d2
	move.w	d2,d3
	cmp.w	d1,d2				; Is Sonic right of the UFO's right boundary?
	bgt.s	.End				; If so, branch
	addi.w	#16*2,d3			; Get Sonic's right boundary
	cmp.w	d0,d3				; Is Sonic left of the UFO's left boundary?
	blt.s	.End				; If so, branch

	move.w	oY(a0),d0			; Get UFO's top boundary
	subi.w	#12,d0
	move.w	d0,d1				; Get UFO's bottom boundary
	addi.w	#12*2,d1
	move.w	oY(a1),d2			; Get Sonic's top boundary
	subi.w	#16,d2
	move.w	d2,d3
	cmp.w	d1,d2				; Is Sonic below the UFO's bottom boundary?
	bgt.s	.End				; If so, branch
	addi.w	#16*2,d3			; Get Sonic's bottom boundary
	cmp.w	d0,d3				; Is Sonic above the UFO's top boundary?
	blt.s	.End				; If so, branch

	cmpi.w	#$210,oZ(a1)			; Is Sonic above the UFO?
	bcs.s	.End				; If so, branch
	cmpi.w	#$270,oZ(a1)			; Is Sonic below the UFO?
	bcc.s	.End				; If so, branch

	move.b	oID(a0),oPlayerUFOCol(a1)	; Mark collision
	move.b	oID(a1),oUFOPlayerCol(a0)

.End:
	rts

; -------------------------------------------------------------------------
; Get stamps that Sonic is currently colliding with
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to Sonic's object slot
; -------------------------------------------------------------------------

ObjSonic_GetStamps:
	lea	gfxVars,a4			; Graphics operations variables
	movea.l	stampTypes,a5			; Stamp types

	move.w	oX(a0),d0			; Get stamp at center
	move.w	oY(a0),d1
	bsr.w	GetStampAtPos
	move.b	(a5,d2.w),oPlayerStampC(a0)
	rol.w	#4,d1				; Get stamp's orientation
	andi.b	#$F,d1
	move.b	d1,oPlayerStampOri(a0)

	move.w	oX(a0),d0			; Get stamp at top left
	subq.w	#8,d0
	move.w	oY(a0),d1
	subq.w	#8,d1
	bsr.w	GetStampAtPos
	move.b	(a5,d2.w),oPlayerStampTL(a0)

	move.w	oX(a0),d0			; Get stamp at top right
	addq.w	#8,d0
	move.w	oY(a0),d1
	subq.w	#8,d1
	bsr.w	GetStampAtPos
	move.b	(a5,d2.w),oPlayerStampTR(a0)

	move.w	oX(a0),d0			; Get stamp at bottom right
	addq.w	#8,d0
	move.w	oY(a0),d1
	addq.w	#8,d1
	bsr.w	GetStampAtPos
	move.b	(a5,d2.w),oPlayerStampBR(a0)

	move.w	oX(a0),d0			; Get stamp at bottom left
	subq.w	#8,d0
	move.w	oY(a0),d1
	addq.w	#8,d1
	bsr.w	GetStampAtPos
	move.b	(a5,d2.w),oPlayerStampBL(a0)
	rts

; -------------------------------------------------------------------------
; Get type of stamp currently being stood on by Sonic
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to Sonic's object slot
; RETURNS:
;	d0.b - Stamp type
; -------------------------------------------------------------------------

ObjSonic_GetStampType:
	movea.l	stampTypes,a5			; Stamp types

	move.w	oX(a0),d0			; Get stamp
	move.w	oY(a0),d1
	bsr.w	GetStampAtPos
	move.b	(a5,d2.w),d0			; Get stamp type
	beq.s	.End				; If it's a path stamp, branch
	rts

.End:
	rts

; -------------------------------------------------------------------------
; Get stamp at position in stamp map
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - X position
;	d1.w - Y position
; RETURNS:
;	d1.w - Stamp ID (raw, with flags)
;	d2.w - Stamp ID (divided by 4, without flags)
; -------------------------------------------------------------------------

GetStampAtPos:
	move.w	d0,d2				; ((X >> 4) & $FFE) + ((Y << 3) & $FF00)
	move.w	d1,d3
	lsr.w	#5,d2
	add.w	d2,d2
	lsr.w	#5,d3
	lsl.w	#8,d3
	add.w	d3,d2

	lea	WORDRAM2M+STAMPMAP,a6		; Get raw stamp ID
	move.w	(a6,d2.w),d2
	move.w	d2,d1				; Copy raw stamp ID
	andi.w	#$7FF,d2			; Mask out flags
	lsr.w	#2,d2				; Divide by 4
	rts

; -------------------------------------------------------------------------
; Stamp types
; -------------------------------------------------------------------------

StampTypes_SS1:
	incbin	"Special Stage/Data/Stage 1/Stamp Types.bin"
	even

StampTypes_SS2:
	incbin	"Special Stage/Data/Stage 2/Stamp Types.bin"
	even

StampTypes_SS3:
	incbin	"Special Stage/Data/Stage 3/Stamp Types.bin"
	even

StampTypes_SS4:
	incbin	"Special Stage/Data/Stage 4/Stamp Types.bin"
	even

StampTypes_SS5:
	incbin	"Special Stage/Data/Stage 5/Stamp Types.bin"
	even

StampTypes_SS6:
	incbin	"Special Stage/Data/Stage 6/Stamp Types.bin"
	even

StampTypes_SS7:
	incbin	"Special Stage/Data/Stage 7/Stamp Types.bin"
	even

StampTypes_SS8:
	incbin	"Special Stage/Data/Stage 8/Stamp Types.bin"
	even

; -------------------------------------------------------------------------
; Get stamp types
; -------------------------------------------------------------------------

GetStampTypes:
	moveq	#0,d0				; Get stamp types
	move.b	specStageID.w,d0
	lsl.w	#2,d0
	move.l	.Index(pc,d0.w),stampTypes
	rts

; -------------------------------------------------------------------------

.Index:
	dc.l	StampTypes_SS1			; Stage 1
	dc.l	StampTypes_SS2			; Stage 2
	dc.l	StampTypes_SS3			; Stage 3
	dc.l	StampTypes_SS4			; Stage 4
	dc.l	StampTypes_SS5			; Stage 5
	dc.l	StampTypes_SS6			; Stage 6
	dc.l	StampTypes_SS7			; Stage 7
	dc.l	StampTypes_SS8			; Stage 8

; -------------------------------------------------------------------------

	include	"Special Stage/Objects/Item/Main.asm"
	include	"Special Stage/Objects/UFO/Main.asm"
	include	"Special Stage/Objects/Shadow/Main.asm"
	include	"Special Stage/Objects/Press Start/Main.asm"
	include	"Special Stage/Objects/Title Card/Main.asm"
	include	"Special Stage/Objects/Explosion/Main.asm"

; -------------------------------------------------------------------------
; Decrement UFO count
; -------------------------------------------------------------------------

DecUFOCount:
	subq.b	#1,ufoCount.w			; Decrement UFO count
	bne.s	.End				; If there's still some UFOs left, branch
	nop					; Nothing

.End:
	rts

; -------------------------------------------------------------------------
; Add rings
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Number of rings to add
; -------------------------------------------------------------------------

AddRings:
	add.w	d0,specStageRings.w		; Add to ring count
	cmpi.w	#999,specStageRings.w		; Are there too many rings?
	bls.s	.End				; If not, branch
	move.w	#999,specStageRings.w		; If so, cap the count

.End:
	rts

; -------------------------------------------------------------------------
; Update timer
; -------------------------------------------------------------------------

UpdateTimer:
	btst	#1,specStageFlags.w		; Are we in time attack mode?
	bne.w	.TimeAttack			; If so, branch

	subq.b	#1,timerFrames			; Decrement frame counter
	bne.s	.CheckSpeedUp			; If it hasn't run out, branch
	move.b	#60/3,timerFrames		; Reset frame counter
	bsr.w	.Tick				; Tick countdown

.CheckSpeedUp:
	tst.b	timerSpeedUp			; Is the timer speed-up counter active?
	beq.s	.End				; If not, branch
	subq.b	#1,timerSpeedUp			; Decrement timer speed-up counter
	bsr.w	.Tick				; Tick countdown

.End:
	rts

; -------------------------------------------------------------------------

.Tick:
	tst.b	timeStopped			; Is time stopped?
	bne.s	.TickEnd			; If so, branch
	tst.b	stageInactive			; Is the stage active?
	bne.s	.TickEnd			; If not, branch

	subq.l	#1,specStageTimer.w		; Decrement timer
	bpl.s	.LowOnTime			; If it hasn't run out, branch
	move.l	#0,specStageTimer.w		; Cap at 0
	move.b	#0,timerSpeedUp			; Stop speeding up timer
	move.b	#1,stageOver			; Mark stage as over

.LowOnTime:
	bsr.w	SpawnTimeUFO			; Check if time UFO needs to be spawned
	cmpi.l	#$F,specStageTimer.w		; Are we really short on time?
	bcc.s	.TickEnd			; If not, branch
	move.b	#FM_DF,subSndQueue1		; Play warning sound

.TickEnd:
	rts

; -------------------------------------------------------------------------

.TimeAttack:
	tst.b	timeStopped			; Is time stopped?
	bne.s	.TimeAttackEnd			; If so, branch
	tst.b	stageInactive			; Is the stage active?
	bne.s	.TimeAttackEnd			; If not, branch

	lea	specStageTimer.w,a1		; Get timer

	addq.b	#3,3(a1)			; Increment frame counter
	cmpi.b	#60,3(a1)			; Is it time to tick a second?
	bcs.s	.TimeAttackEnd			; If not, branch

	subi.b	#60,3(a1)			; Reset frame counter
	addq.b	#1,2(a1)			; Increment second counter
	cmpi.b	#60,2(a1)			; Is it time to tick a minute?
	bcs.s	.TimeAttackEnd			; If not, branch

	subi.b	#60,2(a1)			; Reset second counter
	addq.b	#1,1(a1)			; Increment minut counter
	cmpi.b	#10,1(a1)			; Are we at the max time?
	bcs.s	.TimeAttackEnd			; If not, branch

	move.l	#(9<<16)|(59<<8)|59,(a1)	; Cap time at 9'59"59
	move.b	#1,stageOver			; Mark stage as over

.TimeAttackEnd:
	rts

; -------------------------------------------------------------------------
; Get angle between 2 points
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Point 1 X
;	d1.w - Point 1 Y
;	d4.w - Point 2 X
;	d5.w - Point 2 Y
; RETURNS:
;	d1.w - Angle
;	d2.w - Angle quadrant flags
;	       0 = Left quadrant
;	       1 = Top quadrant
;	       2 = Inner corner quadrant
; -------------------------------------------------------------------------

GetAngle:
	moveq	#0,d2				; Reset flags

	move.w	d0,d3				; Get sign difference between X points
	eor.w	d4,d3
	sub.w	d4,d0				; Get X distance
	bcc.s	.X2Less				; If x2 < x1, unsigned wise, branch

.X2Greater:
	andi.w	#$8000,d3			; Are the signs different?
	bne.s	.CheckY				; If so, branch

.FlipX:
	bset	#0,d2				; Use left quadrant
	neg.w	d0				; Get absolute value of X distance
	bra.s	.CheckY

.X2Less:
	andi.w	#$8000,d3			; Are the signs different?
	bne.s	.FlipX				; If so, branch

.CheckY:
	sub.w	d5,d1				; Get Y distance
	bpl.s	.Y2Above			; If it's positive, branch
	tst.w	d5				; Was y2 negative?
	bmi.s	.Y2Above			; If so, branch
	; BUG: If both y1 and y2 and negative, and y1 < y2, then it'll fail
	; to properly get the absolute value, and thus return a massive
	; distance after being interpreted as unsigned
	bset	#1,d2				; Use top quadrant
	neg.w	d1				; Get absolute value of Y distance

.Y2Above:
	cmp.w	d0,d1				; Is the X distance larger than the Y distance?
	bcs.s	.PrepareDivide			; If not, branch
	bset	#2,d2				; If so, use inner corner quadrant
	exg	d0,d1				; Do x/y instead of y/x

.PrepareDivide:
	ext.l	d1				; Perform the division
	lsl.l	#6,d1
	tst.w	d0
	bne.s	.Divide
	moveq	#0,d1
	bra.s	.Cap

.Divide:
	divu.w	d0,d1

.Cap:
	andi.w	#$FF,d1				; Cap within quadrant
	cmpi.b	#$40,d1
	bcs.s	.End
	move.b	#$3F,d1

.End:
	rts

; -------------------------------------------------------------------------
; Get the trajectory between 2 points
; -------------------------------------------------------------------------
; PARAMETERS:
;	d1.w - Angle
;	d2.w - Angle quadrant flags
;	d3.w - Trajectory multiplier
; RETURNS:
;	d0.w - X trajectory
;	d1.w - Y trajectory
; -------------------------------------------------------------------------

GetTrajectory:
	lea	TrajectoryTable(pc),a1		; Trajectory table

	andi.w	#$FF,d1				; Get table offset
	add.w	d1,d1
	add.w	d1,d1
	bne.s	.Angled				; If we are on an angle, branch
	move.w	#0,d0				; If not, skip unnecessary math
	move.w	d3,d1
	bra.s	.CheckCornerQuad

.Angled:
	adda.w	d1,a1				; Get X anad Y trajectories based on angle
	move.w	(a1)+,d0
	move.w	(a1),d1
	mulu.w	d3,d0
	swap	d0
	mulu.w	d3,d1
	swap	d1

.CheckCornerQuad:
	btst	#2,d2				; Are we in an inner corner quadrant?
	beq.s	.CheckYQuad			; If not, branch
	exg	d0,d1				; If so, swap X and Y trajectories

.CheckYQuad:
	btst	#1,d2				; Are we in a top quadrant?
	beq.s	.SetYTrajectory			; If not, branch
	neg.w	d0				; If so, make the Y trajectory face the other way

.SetYTrajectory:
	swap	d0				; Shift Y trajectory down
	move.w	#0,d0
	asr.l	#8,d0

	btst	#0,d2				; Are we in a left quadrant?
	beq.s	.SetXTrajectory			; If not, branch
	neg.w	d1				; If so, make the X trajectory face the other way

.SetXTrajectory:
	swap	d1				; Shift X trajectory down
	move.w	#0,d1
	asr.l	#8,d1

	exg	d0,d1				; Have d0 store the X trajectory, and d1 store the Y trajectory
	rts

; -------------------------------------------------------------------------
; Get the distance between 2 points
; -------------------------------------------------------------------------
; PARAMETERS:
;	d2.w - Angle quadrant flags
;	d3.w - Point 1 X
;	d4.w - Point 1 Y
;	d5.w - Point 2 X
;	d6.w - Point 2 Y
; RETURNS:
;	d0.l - Distance
; -------------------------------------------------------------------------

GetDistance:
	lea	DistanceTable(pc),a1		; Get distance table entry
	andi.w	#$FF,d1
	add.w	d1,d1
	adda.w	d1,a1
	move.w	#0,d0
	move.w	#0,d1
	move.w	(a1),d0

	btst	#2,d2				; Are we in an inner corner qudrant?
	beq.s	.OuterCorner			; If not, branch

.InnerCorner:
	move.w	d6,d1				; Use Y points	 
	move.w	d4,d2
	bra.s	.GetDistance

.OuterCorner:
	move.w	d5,d1				; Use X points
	move.w	d3,d2

.GetDistance:
	sub.w	d2,d1				; Get distance
	bpl.s	.NotNeg
	neg.w	d1

.NotNeg:
	mulu.w	d1,d0
	lsr.l	#8,d0
	rts

; -------------------------------------------------------------------------

TrajectoryTable:
	dc.w	$00FF, $FFFF
	dc.w	$0400, $FFF8
	dc.w	$07FF, $FFE0
	dc.w	$0BFD, $FFB8
	dc.w	$0FF8, $FF80
	dc.w	$13F0, $FF39
	dc.w	$17E5, $FEE2
	dc.w	$1BD6, $FE7B
	dc.w	$1FC1, $FE06
	dc.w	$23A6, $FD81
	dc.w	$2785, $FCEE
	dc.w	$2B5D, $FC4D
	dc.w	$2F2E, $FB9E
	dc.w	$32F6, $FAE0
	dc.w	$36B5, $FA16
	dc.w	$3A6B, $F93F
	dc.w	$3E17, $F85B
	dc.w	$41B9, $F76C
	dc.w	$4550, $F670
	dc.w	$48DB, $F56A
	dc.w	$4C5C, $F459
	dc.w	$4FD0, $F33E
	dc.w	$5338, $F219
	dc.w	$5694, $F0EA
	dc.w	$59E3, $EFB3
	dc.w	$5D25, $EE74
	dc.w	$605A, $ED2D
	dc.w	$6382, $EBDF
	dc.w	$669C, $EA89
	dc.w	$69A9, $E92E
	dc.w	$6CA8, $E7CC
	dc.w	$6F99, $E665
	dc.w	$727D, $E4F9
	dc.w	$7552, $E389
	dc.w	$781B, $E214
	dc.w	$7AD5, $E09B
	dc.w	$7D82, $DF20
	dc.w	$8021, $DDA1
	dc.w	$82B3, $DC1F
	dc.w	$8537, $DA9C
	dc.w	$87AE, $D916
	dc.w	$8A18, $D78F
	dc.w	$8C75, $D607
	dc.w	$8EC5, $D47E
	dc.w	$9108, $D2F4
	dc.w	$933F, $D16A
	dc.w	$9569, $CFE0
	dc.w	$9787, $CE56
	dc.w	$999A, $CCCD
	dc.w	$9BA0, $CB44
	dc.w	$9D9B, $C9BC
	dc.w	$9F8A, $C835
	dc.w	$A16F, $C6AF
	dc.w	$A348, $C52B
	dc.w	$A516, $C3A9
	dc.w	$A6DA, $C228
	dc.w	$A894, $C0A9
	dc.w	$AA43, $BF2C
	dc.w	$ABE9, $BDB1
	dc.w	$AD84, $BC39
	dc.w	$AF17, $BAC3
	dc.w	$B0A0, $B94F
	dc.w	$B220, $B7DF
	dc.w	$B397, $B670
	dc.w	$B505, $B505
	
DistanceTable:
	dc.w	$00FF, $0100, $0100, $0100, $0100
	dc.w	$0100, $0101, $0101, $0101, $0102
	dc.w	$0103, $0103, $0104, $0105, $0106
	dc.w	$0106, $0107, $0108, $0109, $010B
	dc.w	$010C, $010D, $010E, $0110, $0111
	dc.w	$0112, $0114, $0115, $0117, $0119
	dc.w	$011A, $011C, $011E, $0120, $0121
	dc.w	$0123, $0125, $0127, $0129, $012B
	dc.w	$012D, $0130, $0132, $0134, $0136
	dc.w	$0138, $013B, $013D, $0140, $0142
	dc.w	$0144, $0147, $0149, $014C, $014E
	dc.w	$0151, $0154, $0156, $0159, $015C
	dc.w	$015E, $0161, $0164, $0167, $016A

; -------------------------------------------------------------------------
; Mass copy 128 bytes
; -------------------------------------------------------------------------
; PARAMETERS:
;	a1.l - Pointer to source data
;	a2.l - Pointer to destination buffer
; -------------------------------------------------------------------------

Copy128:
	rept	32
		move.l	(a1)+,(a2)+
	endr
	rts

; -------------------------------------------------------------------------
; Mass fill 128 bytes
; -------------------------------------------------------------------------
; PARAMETERS:
;	d1.l - Value to fill with
;	a1.l - Pointer to destination buffer
; -------------------------------------------------------------------------

Fill128:
	rept	32
		move.l	d1,(a1)+
	endr
	rts
	
; -------------------------------------------------------------------------
; Wait for a graphics operation to be over
; -------------------------------------------------------------------------

WaitGfxOperation:
	move.b	#1,gfxOpFlag			; Set flag
	move	#$2000,sr			; Enable interrupts

.Wait:
	tst.b	gfxOpFlag			; Is the operation over?
	bne.s	.Wait				; If not, wait
	rts

; -------------------------------------------------------------------------
; Wait for the Main CPU to start an update
; -------------------------------------------------------------------------

WaitUpdateStart:
	tst.w	GACOMCMD2.w			; Should we start the update?
	bne.s	WaitUpdateStart			; If not, wait
	rts

; -------------------------------------------------------------------------
; Give Main CPU Word RAM access
; -------------------------------------------------------------------------

GiveWordRAMAccess:
	btst	#0,GAMEMMODE.w			; Do we have Word RAM access?
	bne.s	.End				; If not, branch
	bset	#0,GAMEMMODE.w			; Give Main CPU Word RAM access
	btst	#0,GAMEMMODE.w			; Has it been given?
	beq.s	GiveWordRAMAccess		; If not, wait

.End:
	rts

; -------------------------------------------------------------------------
; Wait for Word RAM access
; -------------------------------------------------------------------------

WaitWordRAMAccess:
	btst	#1,GAMEMMODE.w			; Do we have Word RAM access?
	beq.s	WaitWordRAMAccess		; If not, wait
	rts

; -------------------------------------------------------------------------
; Load stamp map
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - Destination address
;	d1.w - Width (minus 1)
;	d2.w - Height (minus 1)
; -------------------------------------------------------------------------

LoadStampMap:
	move.l	#$100,d4			; Row delta

.Row:
	movea.l	d0,a2				; Set row address
	move.w	d1,d3				; Get width

.Stamp:
	move.w	(a1)+,d5			; Write stamp ID
	lsl.w	#2,d5
	move.w	d5,(a2)+
	dbf	d3,.Stamp			; Loop until row is written

	add.l	d4,d0				; Next row
	dbf	d2,.Row				; Loop until stamp map is written
	rts

; -------------------------------------------------------------------------
; Play FM sound
; -------------------------------------------------------------------------

PlayFMSound:
	tst.b	subSndQueue1			; Is queue 1 full?
	bne.s	.CheckQueue2			; If so, branch
	move.b	d0,subSndQueue1			; Set ID in queue 1
	bra.s	.End

.CheckQueue2:
	tst.b	subSndQueue2			; Is queue 2 full?
	bne.s	.CheckQueue3			; If so, branch
	move.b	d0,subSndQueue2			; Set ID in queue 2
	bra.s	.End

.CheckQueue3:
	tst.b	subSndQueue3			; Is queue 3 full?
	bne.s	.End				; If so, branch
	move.b	d0,subSndQueue3			; Set ID in queue 3

.End:
	rts

; -------------------------------------------------------------------------
; Get a random number
; -------------------------------------------------------------------------
; RETURNS:
;	d0.l - Random number
; -------------------------------------------------------------------------

Random:
	move.l	d1,-(sp)
	move.l	rngSeed,d1			; Get RNG seed
	bne.s	.GotSeed			; If it's set, branch
	move.l	#$2A6D365A,d1			; Reset RNG seed otherwise

.GotSeed:
	move.l	d1,d0				; Get random number
	asl.l	#2,d1
	add.l	d0,d1
	asl.l	#3,d1
	add.l	d0,d1
	move.w	d1,d0
	swap	d1
	add.w	d1,d0
	move.w	d0,d1
	swap	d1
	move.l	d1,rngSeed			; Update RNG seed
	move.l	(sp)+,d1
	rts

; -------------------------------------------------------------------------
; Initialize 3D sprite positioning
; -------------------------------------------------------------------------

Init3DSpritePos:
	lea	gfxVars,a6			; Graphics operations variables
	
	move.w	gfxFOV(a6),d0			; FOV * cos(yaw)
	muls.w	gfxYawCos(a6),d0
	asr.l	#8,d0
	move.w	d0,gfxYcFOV(a6)
	
	move.w	gfxFOV(a6),d0			; FOV * sin(yaw)
	muls.w	gfxYawSin(a6),d0
	asr.l	#8,d0
	move.w	d0,gfxYsFOV(a6)
	rts

; -------------------------------------------------------------------------
; Map 3D position to sprite position
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to object slot
; -------------------------------------------------------------------------

Set3DSpritePos:
	lea	sonicObject,a5			; Sonic object
	lea	gfxVars,a6			; Graphics operations variables
	
	move.w	oX(a5),d0			; Get distance from Sonic
	sub.w	oX(a0),d0
	move.w	oY(a5),d1
	sub.w	oY(a0),d1
	
	moveq	#8,d5				; 8 bit shifts
	
	moveq	#0,d2				; Z point
	move.w	gfxFOV(a6),d2
	add.w	gfxCenter(a6),d2
	move.w	gfxYawSin(a6),d3
	muls.w	d0,d3
	asr.l	d5,d3
	sub.l	d3,d2
	move.w	gfxYawCos(a6),d3
	muls.w	d1,d3
	asr.l	d5,d3
	add.l	d3,d2
	bne.s	.NotZero
	moveq	#1,d2

.NotZero:
	; Z point    = (FOV + center) - (X distance * sin(yaw)) + (Y distance * cos(yaw))
	; X position = ((FOV * cos(yaw) * X distance) + (FOV * sin(yaw) * Y distance)) / Z point
	; Y position = (FOV * Z position) / Z point

	move.w	gfxYcFOV(a6),d3			; Set sprite X position
	muls.w	d0,d3
	move.w	gfxYsFOV(a6),d4
	muls.w	d1,d4
	add.l	d4,d3
	divs.w	d2,d3
	addi.w	#128+128,d3
	move.w	d3,oSprX(a0)
	
	move.w	gfxFOV(a6),d3			; Set sprite Y position
	muls.w	oZ(a0),d3
	asr.l	#3,d3
	divs.w	d2,d3
	addi.w	#128+128,d3
	move.w	d3,oSprY(a0)
	rts

; -------------------------------------------------------------------------
; Generate trace table
; -------------------------------------------------------------------------

GenGfxTraceTbl:
	lea	WORDRAM2M+TRACETBL,a5		; Trace table buffer
	lea	gfxVars,a6			; Graphics operations variables
	
	move.w	gfxCamX(a6),d0			; Camera X
	lsl.w	#3,d0
	move.w	gfxCamY(a6),d1			; Camera Y
	lsl.w	#3,d1

	move.w	#-3,d2				; Initial line ID
	moveq	#8,d6				; 8 bit shifts
	
	move.w	gfxPitchCos(a6),d3		; cos(pitch) * sin(yaw)
	muls.w	gfxYawSin(a6),d3
	asr.l	#5,d3
	move.w	d3,gfxPcYs(a6)

	move.w	gfxPitchCos(a6),d3		; cos(pitch) * cos(yaw)
	muls.w	gfxYawCos(a6),d3
	asr.l	#5,d3
	move.w	d3,gfxPcYc(a6)

	move.w	gfxFOV(a6),d4			; FOV * sin(pitch) * sin(yaw)
	move.w	d4,d3
	muls.w	gfxPitchSin(a6),d3
	muls.w	gfxYawSin(a6),d3
	asr.l	#5,d3
	move.l	d3,gfxPsYsFOV(a6)
	
	move.w	d4,d3				; FOV * sin(pitch) * cos(yaw)
	muls.w	gfxPitchSin(a6),d3
	muls.w	gfxYawCos(a6),d3
	asr.l	#5,d3
	move.l	d3,gfxPsYcFOV(a6)

	move.w	d4,d3				; FOV * cos(pitch)
	muls.w	gfxPitchCos(a6),d3
	move.l	d3,gfxPcFOV(a6)

	move.w	#-128,d3			; -128 * cos(yaw)
	muls.w	gfxYawCos(a6),d3
	lsl.l	#3,d3
	movea.l	d3,a1

	move.w	#-128,d3			; -128 * sin(yaw)
	muls.w	gfxYawSin(a6),d3
	lsl.l	#3,d3
	movea.l	d3,a2

	move.w	#127,d3				; 127 * cos(yaw)
	muls.w	gfxYawCos(a6),d3
	lsl.l	#3,d3
	movea.l	d3,a3

	move.w	#127,d3				; 127 * sin(yaw)
	muls.w	gfxYawSin(a6),d3
	lsl.l	#3,d3
	movea.l	d3,a4
	
	move.w	gfxPitchSin(a6),d4		; (sin(pitch) * sin(yaw)) * (FOV + gfxCenter)
	muls.w	gfxYawSin(a6),d4
	asr.l	#5,d4
	move.w	gfxFOV(a6),d3
	add.w	gfxCenter(a6),d3
	muls.w	d4,d3
	asr.l	d6,d3
	move.w	d3,gfxCenterX(a6)

	move.w	gfxPitchSin(a6),d4		; (sin(pitch) * cos(yaw)) * (FOV + gfxCenter)
	muls.w	gfxYawCos(a6),d4
	asr.l	#5,d4
	move.w	gfxFOV(a6),d3
	add.w	gfxCenter(a6),d3
	muls.w	d4,d3
	asr.l	d6,d3
	move.w	d3,gfxCenterY(a6)
	
	move.l	#$FFF8,(a5)+			; Blank out first 3 lines
	move.l	#0,(a5)+
	move.l	#$FFF8,(a5)+
	move.l	#0,(a5)+
	move.l	#$FFF8,(a5)+
	move.l	#0,(a5)+
	
	move.w	#IMGHEIGHT-3-1,d7		; Number of lines

; -------------------------------------------------------------------------

.GenLoop:
	; X point = -(line * cos(pitch) * sin(yaw)) + (FOV * sin(pitch) * sin(yaw))
	; Y point =  (line * cos(pitch) * cos(yaw)) - (FOV * sin(pitch) * cos(yaw))
	; Z point =  (line * sin(pitch)) + (FOV * cos(pitch))
	
	; Shear left X  = Camera X + (((-128 * cos(yaw)) + X point) * (Camera Z / Z point)) - Center X
	; Shear left Y  = Camera Y + (((-128 * sin(yaw)) + Y point) * (Camera Z / Z point)) + Center Y
	; Shear right X = Camera X + (((127 * cos(yaw)) + X point) * (Camera Z / Z point)) - Center X
	; Shear right Y = Camera Y + (((127 * sin(yaw)) + Y point) * (Camera Z / Z point)) + Center Y

	move.w	d2,d3				; Z point
	muls.w	gfxPitchSin(a6),d3
	add.l	gfxPcFOV(a6),d3
	asr.l	#5,d3
	bne.s	.NotZero
	moveq	#1,d3

.NotZero:
	move.l	a1,d4				; X start = Shear left X
	move.w	gfxPcYs(a6),d5
	muls.w	d2,d5
	sub.l	d5,d4
	add.l	gfxPsYsFOV(a6),d4
	asr.l	d6,d4
	muls.w	gfxCamZ(a6),d4
	divs.w	d3,d4
	add.w	d0,d4
	sub.w	gfxCenterX(a6),d4
	move.w	d4,(a5)+
	
	move.l	a2,d4				; Y start = Shear left Y
	move.w	gfxPcYc(a6),d5
	muls.w	d2,d5
	add.l	d5,d4
	sub.l	gfxPsYcFOV(a6),d4
	asr.l	d6,d4
	muls.w	gfxCamZ(a6),d4
	divs.w	d3,d4
	add.w	d1,d4
	add.w	gfxCenterY(a6),d4
	move.w	d4,(a5)+

	move.l	a3,d4				; X delta = Shear right X - Shear left X
	move.w	gfxPcYs(a6),d5
	muls.w	d2,d5
	sub.l	d5,d4
	add.l	gfxPsYsFOV(a6),d4
	asr.l	d6,d4
	muls.w	gfxCamZ(a6),d4
	divs.w	d3,d4
	add.w	d0,d4
	sub.w	gfxCenterX(a6),d4
	sub.w	-4(a5),d4
	move.w	d4,(a5)+
	
	move.l	a4,d4				; Y delta = Shear right Y - Shear left Y
	move.w	gfxPcYc(a6),d5
	muls.w	d2,d5
	add.l	d5,d4
	sub.l	gfxPsYcFOV(a6),d4
	asr.l	d6,d4
	muls.w	gfxCamZ(a6),d4
	divs.w	d3,d4
	add.w	d1,d4
	add.w	gfxCenterY(a6),d4
	sub.w	-4(a5),d4
	move.w	d4,(a5)+
	
	subq.w	#1,d2				; Next line
	dbf	d7,.GenLoop			; Loop until entire table is generated
	rts

; -------------------------------------------------------------------------
; Initialize graphics operation
; -------------------------------------------------------------------------

InitGfxOperation:
	lea	gfxVars,a1			; Graphics operations variables
	
	move.w	#%110,GASTAMPSIZE.w		; 32x32 stamps, 4096x4096 map, not repeated
	move.w	#IMGHTILE-1,GAIMGVCELL.w	; Height in tiles
	move.w	#IMGBUFFER/4,GAIMGSTART.w	; Image buffer address
	move.w	#0,GAIMGOFFSET.w		; Image buffer offset
	move.w	#IMGWIDTH,GAIMGHDOT.w		; Image buffer width
	
	move.w	#$80,gfxFOV(a1)			; Set FOV
	move.w	#-$40,gfxCenter(a1)		; Set center point
	rts

; -------------------------------------------------------------------------
; Get graphics operation sines
; -------------------------------------------------------------------------

GetGfxSines:
	lea	gfxVars,a6			; Graphics operations variables

	move.w	gfxPitch(a6),d3			; sin(pitch)
	bsr.w	GetSine
	move.w	d3,gfxPitchSin(a6)

	move.w	gfxPitch(a6),d3			; cos(pitch)
	bsr.w	GetCosine
	move.w	d3,gfxPitchCos(a6)

	move.w	gfxYaw(a6),d3			; sin(yaw)
	bsr.w	GetSine
	move.w	d3,gfxYawSin(a6)
	
	move.w	gfxYaw(a6),d3			; cos(yaw)
	bsr.w	GetCosine
	move.w	d3,gfxYawCos(a6)

	move.w	gfxYaw(a6),d3			; -sin(yaw)
	addi.w	#$100,d3
	bsr.w	GetSine
	move.w	d3,gfxYawSinN(a6)
	
	move.w	gfxYaw(a6),d3			; -cos(yaw)
	addi.w	#$100,d3
	bsr.w	GetCosine
	move.w	d3,gfxYawCosN(a6)

	rts

; -------------------------------------------------------------------------
; Run graphics operation
; -------------------------------------------------------------------------

RunGfxOperation:
	bsr.w	GenGfxTraceTbl			; Generate trace table
	andi.b	#%11100111,GAMEMMODE.w		; Disable priority mode
	move.w	#STAMPMAP/4,GASTAMPMAP.w	; Stamp map
	move.w	#IMGHEIGHT,GAIMGVDOT.w		; Image buffer height
	move.w	#TRACETBL/4,GAIMGTRACE.w	; Set trace table and start operation
	rts

; -------------------------------------------------------------------------
; Get sine or cosine of a value
; -------------------------------------------------------------------------
; PARAMETERS:
;	d3.w - Value
; RETURNS:
;	d3.w - Sine/cosine of value
; -------------------------------------------------------------------------

GetCosine:
	addi.w	#$80,d3				; Offset value for cosine

GetSine:
	andi.w	#$1FF,d3			; Keep within range
	move.w	d3,d4
	btst	#7,d3				; Is the value the 2nd or 4th quarters of the sinewave?
	beq.s	.NoInvert			; If not, branch
	not.w	d4				; Invert value to fit sinewave pattern

.NoInvert:
	andi.w	#$7F,d4				; Get sine/cosine value
	add.w	d4,d4
	move.w	SineTable(pc,d4.w),d4

	btst	#8,d3				; Was the input value in the 2nd half of the sinewave?
	beq.s	.SetValue			; If not, branch
	neg.w	d4				; Negate value

.SetValue:
	move.w	d4,d3				; Set final value
	rts

; -------------------------------------------------------------------------

SineTable:
	dc.w	$0000, $0003, $0006, $0009, $000C, $000F, $0012, $0016
	dc.w	$0019, $001C, $001F, $0022, $0025, $0028, $002B, $002F
	dc.w	$0032, $0035, $0038, $003B, $003E, $0041, $0044, $0047
	dc.w	$004A, $004D, $0050, $0053, $0056, $0059, $005C, $005F
	dc.w	$0062, $0065, $0068, $006A, $006D, $0070, $0073, $0076
	dc.w	$0079, $007B, $007E, $0081, $0084, $0086, $0089, $008C
	dc.w	$008E, $0091, $0093, $0096, $0099, $009B, $009E, $00A0
	dc.w	$00A2, $00A5, $00A7, $00AA, $00AC, $00AE, $00B1, $00B3
	dc.w	$00B5, $00B7, $00B9, $00BC, $00BE, $00C0, $00C2, $00C4
	dc.w	$00C6, $00C8, $00CA, $00CC, $00CE, $00D0, $00D1, $00D3
	dc.w	$00D5, $00D7, $00D8, $00DA, $00DC, $00DD, $00DF, $00E0
	dc.w	$00E2, $00E3, $00E5, $00E6, $00E7, $00E9, $00EA, $00EB
	dc.w	$00EC, $00EE, $00EF, $00F0, $00F1, $00F2, $00F3, $00F4
	dc.w	$00F5, $00F6, $00F7, $00F7, $00F8, $00F9, $00FA, $00FA
	dc.w	$00FB, $00FB, $00FC, $00FC, $00FD, $00FD, $00FE, $00FE
	dc.w	$00FE, $00FF, $00FF, $00FF, $00FF, $00FF, $00FF, $0100

; -------------------------------------------------------------------------

	include	"Special Stage/Objects/Sonic/Main.asm"

; -------------------------------------------------------------------------

ObjSplash:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	add.w	d0,d0
	move.w	ObjSplash_Index(pc,d0.w),d0
	jsr	ObjSplash_Index(pc,d0.w)
	bsr.w	DrawObject
	tst.b	timeStopped
	beq.s	.End
	bset	#0,oFlags(a0)

.End:
	rts

; -------------------------------------------------------------------------

ObjSplash_Index:
	dc.w	ObjSplash_Init-ObjSplash_Index
	dc.w	ObjSplash_Large-ObjSplash_Index
	dc.w	ObjSplash_Small-ObjSplash_Index

; -------------------------------------------------------------------------

ObjSplash_Init:
	move.w	#$8582,oTile(a0)
	move.l	#Spr_Splash,oSprites(a0)
	move.w	#$100,oSprX(a0)
	move.w	#$158,oSprY(a0)
	moveq	#0,d0
	bsr.w	SetObjSprite
	move.w	#14,oTimer(a0)
	addq.b	#1,oRoutine(a0)
	move.b	#$A2,d0
	bsr.w	PlayFMSound
	btst	#1,specStageFlags.w
	bne.s	ObjSplash_Large
	move.b	#10,timerSpeedUp

; -------------------------------------------------------------------------

ObjSplash_Large:

	subq.w	#1,oTimer(a0)
	bne.s	.End
	cmpi.b	#3,(sonicObject+oPlayerStampC).l
	bne.s	ObjSplash_Delete
	moveq	#1,d0
	bsr.w	SetObjSprite
	move.b	#2,oRoutine(a0)

.End:
	rts

; -------------------------------------------------------------------------

ObjSplash_Small:
	cmpi.b	#3,(sonicObject+oPlayerStampC).l
	bne.s	ObjSplash_Delete
	tst.b	oSpriteFrame(a0)
	bne.s	.End
	move.b	#2,timerSpeedUp

.End:
	rts

; -------------------------------------------------------------------------

ObjSplash_Delete:
	bset	#0,oFlags(a0)
	rts

; -------------------------------------------------------------------------

DeleteSplash:
	tst.b	(splashObject+oID).l
	beq.s	.End
	bset	#0,(splashObject+oFlags).l

.End:
	rts

; -------------------------------------------------------------------------

ObjDust:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	add.w	d0,d0
	move.w	off_13C3E(pc,d0.w),d0
	jsr	off_13C3E(pc,d0.w)
	bsr.w	DrawObject
	rts

; -------------------------------------------------------------------------
off_13C3E:
	dc.w	ObjDust_Init-off_13C3E
	dc.w	ObjDust_Main-off_13C3E

; -------------------------------------------------------------------------

ObjDust_Init:
	move.w	#$87AE,oTile(a0)
	move.l	#Spr_Dust,oSprites(a0)
	move.w	#$F0,oSprX(a0)
	move.w	#$154,oSprY(a0)
	moveq	#0,d0
	bsr.w	SetObjSprite
	move.w	#6,oTimer(a0)
	addq.b	#1,oRoutine(a0)
	bsr.w	Random
	move.w	d0,d1
	andi.w	#$1F,d0
	add.w	d0,oSprX(a0)
	andi.w	#7,d0
	add.w	d0,oSprY(a0)
	move.w	#3,oDustXVel(a0)
	btst	#2,(playerCtrlData).l
	bne.s	ObjDust_Main
	move.w	#-3,oDustXVel(a0)
	btst	#3,(playerCtrlData).l
	bne.s	ObjDust_Main
	move.w	#0,oDustXVel(a0)

; -------------------------------------------------------------------------

ObjDust_Main:
	subq.w	#1,oTimer(a0)
	bne.s	.Move
	bset	#0,oFlags(a0)

.Move:
	move.l	oDustXVel(a0),d0
	add.l	d0,oSprX(a0)
	subq.w	#1,oSprY(a0)
	rts

; -------------------------------------------------------------------------
Spr_Dust:
	dc.l	unk_13CC6
unk_13CC6:
	dc.b	  3
	dc.b	  1
	dc.l	byte_13CE8
	dc.l	byte_13CDE
	dc.l	byte_13CD4
byte_13CD4:
	dc.b	0, 0, 0, 0, 0
	dc.b	$FC, 0, 0, $2C, $FC
byte_13CDE:
	dc.b	0, 0, 0, 0, 0
	dc.b	$FC, 0, 0, $2D, $FC
byte_13CE8:
	dc.b	0, 0, 0, 0, 0
	dc.b	$FC, 0, 0, $2E, $FC

; -------------------------------------------------------------------------

ObjTimeStone:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	add.w	d0,d0
	move.w	off_13D08(pc,d0.w),d0
	jsr	off_13D08(pc,d0.w)
	bsr.w	DrawObject
	rts

; -------------------------------------------------------------------------
off_13D08:
	dc.w	ObjTimeStone_Init-off_13D08
	dc.w	ObjTimeStone_Wait-off_13D08
	dc.w	ObjTimeStone_Fall-off_13D08
	dc.w	ObjTimeStone_Wait2-off_13D08

; -------------------------------------------------------------------------

ObjTimeStone_Init:
	move.w	#$E424,oTile(a0)
	move.l	#Spr_Sparkle,oSprites(a0)
	move.w	#$101,oSprX(a0)
	move.w	#$70,oSprY(a0)
	moveq	#0,d0
	bsr.w	SetObjSprite
	move.w	#$1E,oTimer(a0)
	addq.b	#1,oRoutine(a0)

; -------------------------------------------------------------------------

ObjTimeStone_Wait:
	subq.w	#1,oTimer(a0)
	bne.s	.End
	addq.b	#1,oRoutine(a0)

.End:
	rts

; -------------------------------------------------------------------------

ObjTimeStone_Fall:
	addq.w	#4,oSprY(a0)
	cmpi.w	#$150,oSprY(a0)
	bcs.s	.End
	addq.b	#1,oRoutine(a0)
	bset	#0,(sparkleObject1+oFlags).l
	bset	#0,(sparkleObject2+oFlags).l
	move.w	#$3C,oTimer(a0)
	move.b	#$12,(sonicObject+oRoutine).l
	move.b	#$D9,d0
	bsr.w	PlayFMSound

.End:
	rts

; -------------------------------------------------------------------------

ObjTimeStone_Wait2:
	subq.w	#1,oTimer(a0)
	bne.s	.End
	move.b	#1,gotTimeStone

.End:
	rts

; -------------------------------------------------------------------------

ObjSparkle1:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	add.w	d0,d0
	move.w	off_13DA4(pc,d0.w),d0
	jsr	off_13DA4(pc,d0.w)
	bsr.w	DrawObject
	rts

; -------------------------------------------------------------------------
off_13DA4:
	dc.w	ObjSparkle1_Init-off_13DA4
	dc.w	ObjSparkle1_Main-off_13DA4

; -------------------------------------------------------------------------

ObjSparkle1_Init:
	move.w	#$E424,oTile(a0)
	move.l	#Spr_Sparkle,oSprites(a0)
	moveq	#1,d0
	bsr.w	SetObjSprite
	addq.b	#1,oRoutine(a0)

; -------------------------------------------------------------------------

ObjSparkle1_Main:
	move.w	(timeStoneObject+oSprX).l,oSprX(a0)
	move.w	(timeStoneObject+oSprY).l,oSprY(a0)
	subi.w	#$10,oSprY(a0)
	rts

; -------------------------------------------------------------------------

ObjSparkle2:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	add.w	d0,d0
	move.w	off_13DEE(pc,d0.w),d0
	jsr	off_13DEE(pc,d0.w)
	bsr.w	DrawObject
	rts

; -------------------------------------------------------------------------
off_13DEE:
	dc.w	ObjSparkle2_Init-off_13DEE
	dc.w	ObjSparkle2_Main-off_13DEE

; -------------------------------------------------------------------------

ObjSparkle2_Init:
	move.w	#$E424,oTile(a0)
	move.l	#Spr_Sparkle,oSprites(a0)
	moveq	#2,d0
	bsr.w	SetObjSprite
	addq.b	#1,oRoutine(a0)

; -------------------------------------------------------------------------

ObjSparkle2_Main:
	move.w	(timeStoneObject+oSprX).l,oSprX(a0)
	move.w	(timeStoneObject+oSprY).l,oSprY(a0)
	subi.w	#$20,oSprY(a0)
	rts

; -------------------------------------------------------------------------
Spr_Sparkle:
	dc.l	byte_13E2E
	dc.l	byte_13E40
	dc.l	byte_13E52
byte_13E2E:
	dc.b	4, 3
	dc.l	byte_13E64
	dc.l	byte_13E6E
	dc.l	byte_13E82
	dc.l	byte_13E78
byte_13E40:
	dc.b	4, 1
	dc.l	byte_13E8C
	dc.l	byte_13E9C
	dc.l	byte_13EAC
	dc.l	byte_13EBC
byte_13E52:
	dc.b	4, 1
	dc.l	byte_13EFC
	dc.l	byte_13EEC
	dc.l	byte_13EDC
	dc.l	byte_13ECC
byte_13E64:
	dc.b	0, 0, 0, 0, 0
	dc.b	$E8, 6, 0, 0, $F8
byte_13E6E:
	dc.b	0, 0, 0, 0, 0
	dc.b	$E8, 6, 0, 6, $F8
byte_13E78:
	dc.b	0, 0, 0, 0, 0
	dc.b	$E8, 6, 8, 6, $F8
byte_13E82:
	dc.b	0, 0, 0, 0, 0
	dc.b	$E8, 6, 0, $C, $F8
byte_13E8C:
	dc.b	1, 0, 0, 0, 0
	dc.b	$E8, 9, 0, $12, $F4
	dc.b	$F8, 0, 0, $18, $FC
	dc.b	0
byte_13E9C:
	dc.b	1, 0, 0, 0, 0
	dc.b	$E8, 0, $10, $18, $FC
	dc.b	$F0, 9, $10, $12, $F4
	dc.b	0
byte_13EAC:
	dc.b	1, 0, 0, 0, 0
	dc.b	$E8, 0, $18, $18, $FC
	dc.b	$F0, 9, $18, $12, $F4
	dc.b	0
byte_13EBC:
	dc.b	1, 0, 0, 0, 0
	dc.b	$E8, 9, 8, $12, $F4
	dc.b	$F8, 0, 8, $18, $FC
	dc.b	0
byte_13ECC:
	dc.b	1, 0, 0, 0, 0
	dc.b	$F0, 0, 0, $19, 0
	dc.b	$F8, 4, 0, $1A, $F8
	dc.b	0
byte_13EDC:
	dc.b	1, 0, 0, 0, 0
	dc.b	$F8, 0, $10, $19, 0
	dc.b	$F0, 4, $10, $1A, $F8
	dc.b	0
byte_13EEC:
	dc.b	1, 0, 0, 0, 0
	dc.b	$F0, 4, $18, $1A, $F8
	dc.b	$F8, 0, $18, $19, $F8
	dc.b	0
byte_13EFC:
	dc.b	1, 0, 0, 0, 0
	dc.b	$F0, 0, 8, $19, $F8
	dc.b	$F8, 4, 8, $1A, $F8
	dc.b	0
	
	align	SpecStageData, $FF
	incbin	"Special Stage/Stage Data.bin"
	align	PRGRAM+$30000, $FF

; -------------------------------------------------------------------------
; Data section
; -------------------------------------------------------------------------

DataSection:
SonicArt:
	dc.l	byte_30118
	dc.l	byte_30358
	dc.l	byte_305D8
	dc.l	byte_30858
	dc.l	byte_30AD8
	dc.l	byte_30D98
	dc.l	byte_31038
	dc.l	byte_312B8
	dc.l	byte_31578
	dc.l	byte_31818
	dc.l	byte_31A98
	dc.l	byte_31D18
	dc.l	byte_31F98
	dc.l	byte_32218
	dc.l	byte_32498
	dc.l	byte_32638
	dc.l	byte_32758
	dc.l	byte_329B8
	dc.l	byte_32AF8
	dc.l	byte_32D58
	dc.l	byte_32FB8
	dc.l	byte_33118
	dc.l	byte_33358
	dc.l	byte_335D8
	dc.l	byte_337F8
	dc.l	byte_33A78
	dc.l	byte_33CF8
	dc.l	byte_33F78
	dc.l	byte_34218
	dc.l	byte_34358
	dc.l	byte_344D8
	dc.l	byte_34658
	dc.l	byte_348D8
	dc.l	byte_34B58
	dc.l	byte_34DF8
	dc.l	byte_35078
	dc.l	byte_35358
	dc.l	byte_355B8
	dc.l	byte_35818
	dc.l	byte_35A78
	dc.l	byte_35D58
	dc.l	byte_35FF8
	dc.l	byte_36298
	dc.l	byte_364F8
	dc.l	byte_367B8
	dc.l	byte_36A78
	dc.l	byte_36D38
	dc.l	byte_36FF8
	dc.l	byte_372B8
	dc.l	byte_37538
	dc.l	byte_37738
	dc.l	byte_379B8
	dc.l	byte_37C58
	dc.l	byte_37F18
	dc.l	byte_38198
	dc.l	byte_38418
	dc.l	byte_386F8
	dc.l	byte_38998
	dc.l	byte_38BF8
	dc.l	byte_38E38
	dc.l	byte_39098
	dc.l	byte_39298
	dc.l	byte_394D8
	dc.l	byte_39718
	dc.l	Spr_Sonic
	dc.l	Spr_Sonic
	dc.l	Spr_Sonic
	dc.l	Spr_Sonic
	dc.l	Spr_Sonic
	dc.l	Spr_Sonic
byte_30118:
	dc.b	0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, $34, $45, 0, $33, $45, $34, $55, $34, $43, $34, $43, $33, $32, $23, $34, $42, $22, $22, $44, $41, $22
	dc.b	$34, $55, $44, $12, $45, $55, $44, $32, $45, $55, $43, $32, $55, $55, $33, $23, $55, $53, $22, $33, $55, $32, $23, $33, $22, $21, $23, $34, 2, $22, $23, $35
	dc.b	0, 0, 0, 0, $33, 0, 0, 0, $54, $30, 0, 0, $55, $43, $30, 5, $53, $44, $35, $54, $52, $33, $33, $44, $22, $22, $44, $33, $22, $21, $44, $42
	dc.b	$22, $14, $45, $54, $22, $34, $45, $55, $12, $33, $45, $55, $33, $23, $35, $55, $33, $32, $23, $55, $43, $33, $22, $35, $54, $33, $21, $22, $55, $33, $22, $22
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $40, 0, 0, 0, $30, 0, 0, 0, $30, 0, 0, 0, $20, 0, 0, 0, $20, 0, 0, 0
	dc.b	$30, 0, 0, 0, $40, 0, 0, 0, $40, 0, 0, 0, $50, 0, 0, 0, $50, 0, 0, 0, $50, 0, 0, 0, $20, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, $73, 0, 0, 8, $73, 0, 0, 8, $82, 0, 0, 8, $97
	dc.b	0, 0, 8, $79, 0, 0, 8, $9D, 0, 0, 0, $99, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	2, $33, $23, $35, $33, $44, $22, $34, $34, $54, $22, $34, $45, $54, $22, $23, $55, $43, $22, $22, $54, $32, $22, $22, $53, $22, $12, $32, $22, 1, $33, $42
	dc.b	$DB, $BD, $44, $42, $DD, $D3, $43, $22, $90, $34, $52, $23, 0, $35, $21, $33, 0, $33, $12, $33, 0, $23, $12, $23, 0, 2, 1, $22, 0, 0, 1, $22
	dc.b	$55, $33, $23, $32, $54, $32, $24, $43, $54, $32, $24, $54, $53, $22, $24, $55, $22, $22, $23, $45, $12, $22, $22, $34, $23, $32, $12, $23, $33, $43, $BB, 2
	dc.b	$33, $44, $DA, $A0, $22, $34, $DB, $AA, $42, $23, $4D, $DD, $43, $12, $44, $EE, $33, $12, $24, $EE, $32, $21, $22, $EE, $22, $21, $99, $9E, $42, $21, $19, $99
	dc.b	0, 0, 0, 0, $30, 0, 0, 0, $30, 0, 0, 0, $43, 0, 0, 0, $53, 0, 0, 0, $53, 0, 0, 0, $52, 0, 0, 0, $20, 0, 0, 0
	dc.b	6, $60, 0, 0, $66, $97, $70, 0, $67, $77, $67, 0, $87, $76, $66, $80, $98, $76, $78, $80, $19, $98, $88, $90, $19, $88, $89, 0, $10, 9, $90, 0
	dc.b	0, $C, $CC, $11, 0, $CC, $FC, $C0, 0, $DE, $EE, $CD, $D, $E1, $11, $ED, $E, $11, $11, $1E, $E, $11, $11, $11, 1, $11, $11, $11, $E1, $11, $11, $10
	dc.b	$41, $11, $19, $D9, $40, $E9, $89, $DE, $50, $D9, $99, $D1, $10, $DD, $DD, $E1, 0, $ED, $DD, $10, 0, $1E, $EE, $10, 0, 1, $11, 0, 0, 0, 0, 0
	dc.b	$10, 0, 0, 0, $10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$E1, $11, $11, $10, $11, $11, $11, $10, $11, $11, $11, 0, $11, $11, $11, 0, $11, $11, $11, 0, $11, $11, $10, 0, $11, $11, $10, 0, 1, $11, 0, 0
byte_30358:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 4, 0, 0, 0, 3, 0, 0, 0, 3, 0, 0, 0, 2
	dc.b	0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 5, 0, 0, 0, 5, 0, 0, 0, 5, 0, 0, 0, 5, 0, 0, 0, 2, 0, 0, 0, 0
	dc.b	0, 0, 0, $33, 0, 0, 3, $45, 0, 0, $34, $55, $50, 3, $34, $55, $45, $53, $43, $25, $44, $33, $32, $22, $33, $44, $22, $22, $34, $55, $12, $22
	dc.b	$25, $54, $41, $22, $55, $54, $43, $22, $55, $44, $32, $21, $54, $32, $22, $33, $43, $22, $23, $34, $32, $22, $33, $45, $20, $12, $33, $45, 0, $22, $23, $45
	dc.b	$30, 0, 0, 0, $43, 0, 0, 0, $54, $30, 0, 4, $54, $33, 5, $54, $23, $43, $54, $43, $22, $33, $34, $43, $22, $24, $43, $32, $22, $15, $54, $20
	dc.b	$21, $44, $55, $53, $23, $44, $55, $55, $22, $34, $45, $55, $32, $22, $34, $45, $33, $22, $22, $35, $43, $32, $22, $22, $54, $32, $10, 0, $55, $33, $22, $20
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, $78, 0, 0, $77, $78, 0, 8, $87, $78
	dc.b	0, 9, $79, $BB, 0, 9, $89, $DD, 0, 9, $99, $99, 0, 0, $99, $90, 0, 0, 0, 0, 0, 0, 0, $E, 0, 0, 0, $E1, 0, 0, 0, $E1
	dc.b	2, $44, $23, $34, $24, $54, $22, $34, $45, $54, $22, $23, $45, $43, $22, $22, $45, $32, $22, $22, $44, $22, $22, $22, $22, 1, $13, $33, $9A, $A1, $34, $44
	dc.b	$AD, $D4, $44, $42, $D0, 4, $54, $22, 0, 5, $42, $24, $E, $EE, $22, $33, $E1, $11, $E2, $23, $11, $11, $1E, $22, $11, $11, $1E, $22, $11, $11, $1E, $12
	dc.b	$54, $33, $24, $42, $54, $32, $24, $54, $53, $22, $24, $55, $22, $22, $23, $45, $22, $22, $22, $34, $12, $22, $22, $23, $23, $33, $11, 2, $23, $4B, $B0, 0
	dc.b	$22, $4B, $A0, 7, $42, $2D, $BA, $D7, $44, $22, $DD, $D8, $43, $32, $20, 9, $33, $21, $20, 0, $32, $22, $10, 0, $22, $21, 0, 0, $42, $21, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $79, $87, $77, 0
	dc.b	$98, $76, $66, $70, $97, $78, $66, $70, $98, $89, $77, $80, $89, $98, $88, $90, $99, 9, $99, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, $E, $11, 0, 0, $E, $11, 0, 0, $E1, $11, 0, 0, $E1, $11, 0, 0, $E1, $11, 0, 0, $E1, $11, 0, 0, $E1, $11, 0, 0, $E1, $11
	dc.b	0, 0, $E, $EE, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$11, $11, $EE, 1, $11, $11, $E0, 0, $11, $1E, 0, 0, $11, $1E, 0, 0, $11, $E0, 0, 0, $11, $E0, 0, $E, $1E, 0, 0, $E, $E0, 0, 0, $E
	dc.b	0, 0, 0, $E, 0, 0, 0, 9, 0, 0, 0, 9, 0, 0, 0, $E, 0, 0, 0, $E, 0, 0, 0, $E, 0, 0, 0, 1, 0, 0, 0, 0
	dc.b	$41, $12, 0, 0, $40, $12, 0, 0, $15, $20, 0, 0, 1, $20, 0, 0, $E1, $2E, 0, 0, $E1, $2E, $E0, 0, $71, $27, $E0, 0, $81, $27, $EE, 0
	dc.b	$87, $78, $9E, 0, $99, $99, $E9, 0, $87, $78, $E9, 0, $EC, $CD, $EE, 0, $DC, $CD, $DE, 0, $DD, $DD, $DE, 0, $DD, $DD, $D1, 0, $11, $11, $10, 0
byte_305D8:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 4, 0, 0, 0, 2, 0, 0, 0, 0
	dc.b	0, 0, 0, $33, 0, 0, 3, $45, 0, 0, 3, $55, 0, 0, $34, $56, $55, 3, $34, $42, $44, $53, $34, $22, $33, $43, $33, $22, $23, $34, $42, $22
	dc.b	$30, 0, 0, 0, $43, 0, 0, $54, $54, $30, 5, $44, $54, $43, 4, $43, $22, $44, $33, $43, $22, $23, $34, $32, $22, $22, $45, $42, $22, $21, $55, $55
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $30, 0, 0, 0
	dc.b	2, $45, $51, $22, 2, $55, $44, $12, $35, $55, $54, $43, $55, $54, $43, $32, $55, $43, $22, $23, $54, $22, $22, $33, $22, 2, $22, $33, 0, 0, $12, $34
	dc.b	$22, $14, $45, $55, $22, $34, $44, $45, $21, $22, $23, $34, $33, $32, $22, $22, $34, $33, $22, $22, $45, $43, $32, $10, $45, $54, $32, $22, $45, $55, $32, $24
	dc.b	$50, 0, 0, 0, $55, 0, 0, 0, $45, 0, 0, 0, $22, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $54, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $60, 0, $77, $76, $8A
	dc.b	7, $76, $76, $6D, 7, $66, $69, $77, 8, $89, $79, $90, 9, $88, $98, $90, 0, $99, $99, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, $22, $23, 0, 4, $54, $22, 0, $35, $54, $22, 3, $45, $44, $22, 4, $54, $43, $22, 3, $33, $22, $13, $A, $AB, $B1, $34, $AD, $DD, $14, $54
	dc.b	$D0, 1, $45, $44, 0, 1, $43, $22, 0, 1, $32, $12, 0, 0, $21, $22, 0, $DD, $D1, $22, 0, $DC, $C1, $22, $D, $CF, $CC, $12, $D, $EE, $EE, $D1
	dc.b	$44, $55, $32, $24, $24, $45, $22, $24, $22, $22, $22, $23, $22, $22, $22, $22, $22, $22, $22, $20, $32, $22, $21, 0, $43, $22, $43, $10, $43, $24, $44, $3B
	dc.b	$22, $23, $45, $3D, $23, $22, $35, $53, $34, $42, $23, $53, $34, $43, $12, $43, $33, $33, $21, $32, $23, $32, $21, $20, $22, $22, $10, 0, $42, $22, $10, 0
	dc.b	$55, $40, 0, 0, $45, $54, 0, 0, $34, $45, 0, 0, $23, $33, 0, 0, $88, $88, 0, 0, $89, $77, $80, 0, $97, $A9, $80, 0, $B9, $DA, $90, 0
	dc.b	$DB, $AA, $90, 0, $D, $DD, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	1, $11, $11, $1D, 1, $11, $11, $11, 0, $E1, $11, $E0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$14, $11, $10, 0, 1, $45, $10, 0, 0, $11, $10, 0, 0, 2, $10, 0, 0, 2, $10, 0, 0, 2, $10, 0, 7, $66, $78, 0, 9, $99, $99, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, $1C, 0, 0, 0, $1C, 0, 0, 0, $1C, 0, 0, 0, $E1, 0, 0, 0, $E
	dc.b	$97, $78, $88, 0, $86, $67, $89, 0, $DD, $DD, $DE, $11, $CF, $DD, $DE, $DE, $CC, $CD, $DD, $DD, $CC, $CD, $DD, $DE, $11, $11, $EE, $E1, $E1, $11, $11, $10
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $10, 0, 0, 0, $10, 0, 0, 0, $10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
byte_30858:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, $45, 0, 0, 0, $22, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 3, 0, 0, 0, $33, 0, 0, 0, $32, 0, 0, 3, $32, 0, 0, 3, $22, 0, 0, 2, $20, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 3, 0, 0, 0, 4, 0, 0, 0, $34, 0, 0, 0, $34, 0, 0, 3, $22, 0, 0, $32, $21, 0, 0, $22, 0, 0, 0, 0, $97
	dc.b	0, 0, 8, $79, 0, 0, 8, $9D, 0, 0, 0, $99, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 4, $44, $43, $44, $45, $55, $55, $55, $54, $44, $44, $43, $33, $33, $33, $22, $22, $22, $33, 0, $22, $22, $22, $33, $31, $22, $23
	dc.b	$32, $21, $22, $34, $22, $22, $13, $34, $22, $23, $43, $44, $22, $44, $43, $45, $23, $44, $33, $53, 4, $43, $23, $53, $34, $32, $22, $12, $43, $22, $22, $22
	dc.b	$43, $22, $22, $23, $32, $22, $22, $23, $32, $22, $22, $34, $22, $22, $11, $34, $21, $11, $22, $43, $10, 2, $22, $43, 0, 0, $12, $51, 0, 1, $34, $32
	dc.b	$DB, $BD, $44, $42, $DD, $D3, $43, $22, $90, $34, $52, $23, 0, $35, $21, $33, 0, $33, $12, $33, 0, $23, $12, $23, 0, 2, 1, $22, 0, 0, 1, $22
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, $44, $43, $30, 0, $55, $44, $43, $44, $34, $44, $44, $44, $33, $44, $44, $43, $34, $55, $54, $33, $45, $55, $54, $43
	dc.b	$45, $54, $45, $44, $54, $44, $45, $44, $53, $33, $34, $44, $33, $33, $33, $34, $32, $22, $33, $33, $23, $33, $33, $33, $23, $44, $33, $33, $34, $44, $33, $33
	dc.b	$45, $33, $23, $33, $43, $32, $33, $DA, $33, $22, $3D, $BB, $33, $22, $3D, $BB, $32, $22, $DB, $BB, $12, $22, $DB, $D0, $23, $31, $DD, 0, $33, $33, $D0, 0
	dc.b	$33, $44, $DB, $B0, $22, $34, $4D, $BA, $42, $23, $44, $DD, $43, $12, $44, $EE, $33, $12, $24, $EE, $32, $21, $22, $EE, $22, $21, $99, $9E, $42, $21, $19, $99
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $34, $40, 0, 0, $43, $30, 0, 0, $33, 0, 0, 0, $30, 0, 0, 0, $30, 0, 0, 0
	dc.b	$40, 0, 0, 0, $44, 0, 0, 0, $34, 0, 0, 0, $34, 0, 0, 0, $45, 0, 0, 0, $55, 0, 0, 0, $55, 0, 0, 0, $54, 0, 0, 0
	dc.b	$50, 0, 0, 0, $A0, 0, 0, 0, $B0, 0, 0, 0, $B0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, $A0, $78, 0, 0, $B6, $98, $77, 0, $68, $87, $66, $80, $99, $88, $78, $88, $11, $99, $88, $88, $10, 0, $98, $80, $10, 0, 9, $90
	dc.b	0, $C, $CC, $11, 0, $CC, $FC, $C0, 0, $DE, $EE, $CD, $D, $E1, $11, $ED, $E, $11, $11, $1E, $E, $11, $11, $11, 1, $11, $11, $11, $E1, $11, $11, $10
	dc.b	$41, $11, $19, $D9, $40, $E9, $89, $DE, $50, $D9, $99, $D1, $10, $DD, $DD, $E1, 0, $ED, $DD, $10, 0, $1E, $EE, $10, 0, 1, $11, 0, 0, 0, 0, 0
	dc.b	$10, 0, 0, 0, $10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$E1, $11, $11, $10, $11, $11, $11, $10, $11, $11, $11, 0, $11, $11, $11, 0, $11, $11, $11, 0, $11, $11, $10, 0, $11, $11, $10, 0, 1, $11, 0, 0
byte_30AD8:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 4, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 3, 0, 0, 0, $33, 0, 0, 3, $32, 0, 0, 3, $22, 0, 0, $32, $22, 0, 0, $22, $20, 0, 0, 0, 0, 0, 0, 0, 3
	dc.b	0, 0, 0, 3, 0, 0, 0, $33, 0, 0, 0, $32, 0, 0, 0, $22, 0, 0, $33, $22, 0, 0, $22, $11, 0, 0, 0, $78, 0, 8, $87, $78
	dc.b	0, 9, $79, $BB, 0, 9, $89, $DD, 0, 9, $99, $99, 0, 0, $99, $90, 0, 0, 0, 0, 0, 0, 0, $E, 0, 0, 0, $E1, 0, 0, 0, $E1
	dc.b	0, 0, 0, 0, 3, $34, $44, $44, $45, $55, $55, $54, $54, $44, $44, $45, $22, $23, $33, $33, 0, $22, $22, $33, 0, $32, $22, $22, $33, $31, $22, $22
	dc.b	$33, $21, $22, $24, $22, $22, $12, $35, $22, $23, $43, $54, $22, $44, $43, $54, $24, $44, $33, $53, $34, $43, $22, $21, $44, $32, $22, $12, $43, $22, $22, $23
	dc.b	$32, $22, $22, $23, $22, $22, $22, $34, $22, $22, $22, $34, $22, $21, $11, $44, $11, $12, $22, $44, 0, 2, $22, $51, 0, 1, $13, $31, $9A, $A1, $34, $43
	dc.b	$AD, $D4, $44, $42, $D0, 4, $54, $22, 0, 5, $42, $24, $E, $EE, $22, $33, $E1, $11, $E2, $23, $11, $11, $1E, $22, $11, $11, $1E, $22, $11, $11, $1E, $12
	dc.b	0, 0, 0, 0, $33, 0, 0, 0, $44, $43, $30, 0, $55, $44, $43, $44, $34, $44, $44, $44, $33, $44, $44, $43, $34, $55, $54, $33, $44, $55, $54, $43
	dc.b	$45, $54, $45, $44, $54, $44, $45, $44, $43, $33, $34, $44, $22, $23, $33, $34, $22, $22, $33, $33, $23, $33, $33, $33, $34, $44, $33, $33, $35, $44, $33, $33
	dc.b	$44, $33, $23, $33, $43, $32, $33, $DA, $33, $22, $3D, $BB, $32, $22, $3D, $BB, $22, $22, $DB, $BB, $22, $22, $DB, $D0, $23, $31, $DD, 0, $24, $44, $30, 0
	dc.b	$22, $4B, $A0, 7, $42, $2D, $BA, $D7, $44, $22, $DD, $D8, $43, $32, $20, 9, $33, $21, $20, 0, $32, $22, $10, 0, $22, $21, 0, 0, $42, $21, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $44, 0, 0, 0, $43, 0, 0, 0, $33, 0, 0, 0, $30, 0, 0, 0, $30, 0, 0, 0
	dc.b	$40, 0, 0, 0, $44, 0, 0, 0, $34, 0, 0, 0, $34, 0, 0, 0, $45, 0, 0, 0, $55, 0, 0, 0, $55, 0, 0, 0, $54, 0, 0, 0
	dc.b	$50, 0, 0, 0, $A0, 0, 0, 0, $B0, 0, 0, 0, $B0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $79, $87, $77, 0
	dc.b	$98, $76, $66, $70, $97, $78, $66, $70, $98, $89, $77, $80, $89, $98, $88, $90, $99, 9, $99, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, $E, $11, 0, 0, $E, $11, 0, 0, $E1, $11, 0, 0, $E1, $11, 0, 0, $E1, $11, 0, 0, $E1, $11, 0, 0, $E1, $11, 0, 0, $E1, $11
	dc.b	0, 0, $E, $EE, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$11, $11, $EE, 1, $11, $11, $E0, 0, $11, $1E, 0, 0, $11, $1E, 0, 0, $11, $E0, 0, 0, $11, $E0, 0, $E, $1E, 0, 0, $E, $E0, 0, 0, $E
	dc.b	0, 0, 0, $E, 0, 0, 0, 9, 0, 0, 0, 9, 0, 0, 0, $E, 0, 0, 0, $E, 0, 0, 0, $E, 0, 0, 0, 1, 0, 0, 0, 0
	dc.b	$41, $12, 0, 0, $40, $12, 0, 0, $15, $20, 0, 0, 1, $20, 0, 0, $E1, $2E, 0, 0, $E1, $2E, $E0, 0, $71, $27, $E0, 0, $81, $27, $EE, 0
	dc.b	$87, $78, $9E, 0, $99, $99, $E9, 0, $87, $78, $E9, 0, $EC, $CD, $EE, 0, $DC, $CD, $DE, 0, $DD, $DD, $DE, 0, $DD, $DD, $D1, 0, $11, $11, $10, 0
byte_30D98:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 3, 0, 0, 0, $33, 0, 0, 3, $32, 0, 0, $32, $22, 0, 0, $22, $22, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3
	dc.b	0, 0, 0, 3, 0, 0, 0, $33, 0, 0, 0, $32, 0, 0, 3, $22, 0, 0, $32, $11, 0, 0, $22, 0, 0, 0, 0, 0, 0, 0, 0, $A
	dc.b	0, 0, 7, $6D, 0, 0, $69, $77, 0, 6, $68, $90, 0, $66, $88, $70, 0, $68, $87, $80, 6, $88, $97, 0, 6, $88, 7, 0, 0, $80, 0, 0
	dc.b	0, 4, $44, $43, $34, $45, $55, $44, $45, $54, $44, $55, $22, $22, $33, $34, 2, $22, $22, $33, 0, $22, $22, $23, 0, $32, $22, $22, $33, $31, $22, $23
	dc.b	$33, $21, $22, $34, $22, $22, $13, $35, $22, $23, $43, $54, $22, $44, $43, $53, $24, $44, $32, $22, $34, $43, $22, $21, $44, $32, $22, $12, $43, $22, $22, $23
	dc.b	$32, $22, $22, $34, $22, $22, $22, $34, $22, $22, $22, $34, $22, $11, $11, $54, $11, $22, $22, $54, 0, 2, $22, $11, $A, $AB, $B1, $34, $AD, $DD, $14, $54
	dc.b	$D0, 1, $45, $44, 0, 1, $43, $22, 0, 1, $32, $12, 0, 0, $21, $22, 0, $DD, $D1, $22, 0, $DC, $C1, $22, $D, $CF, $CC, $12, $D, $EE, $EE, $D1
	dc.b	0, 0, 0, 0, $33, $30, 0, 0, $44, $43, $30, 0, $55, $44, $43, $44, $34, $44, $44, $44, $33, $44, $44, $43, $34, $55, $54, $33, $45, $55, $54, $43
	dc.b	$54, $44, $45, $44, $44, $44, $45, $44, $43, $33, $34, $44, $22, $23, $33, $34, $22, $22, $33, $33, $23, $33, $33, $33, $34, $44, $33, $33, $45, $44, $33, $33
	dc.b	$44, $33, $23, $33, $43, $32, $33, $DA, $33, $22, $3D, $BB, $32, $22, $3D, $BB, $22, $22, $DB, $BB, $32, $22, $11, $D0, $43, $22, $43, $10, $43, $24, $44, $3B
	dc.b	$22, $23, $45, $3D, $23, $22, $35, $53, $34, $42, $23, $53, $34, $43, $12, $43, $33, $33, $21, $32, $23, $32, $21, $20, $22, $22, $10, 0, $42, $22, $10, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, $40, 0, 0, 0, $43, 0, 0, 0, $33, 0, 0, 0, $30, 0, 0, 0, $30, 0, 0, 0, $30, 0, 0, 0
	dc.b	$40, 0, 0, 0, $44, 0, 0, 0, $34, 0, 0, 0, $34, 0, 0, 0, $45, 0, 0, 0, $55, 0, 0, 0, $55, 0, 0, 0, $54, 0, 0, 0
	dc.b	$50, 0, 0, 0, $A0, 0, 0, 0, $B0, 0, 0, 0, $B0, 0, 0, 0, $88, $88, 0, 0, $89, $77, $80, 0, $97, $A9, $80, 0, $B9, $DA, $90, 0
	dc.b	$DB, $AA, $90, 0, $D, $DD, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	1, $11, $11, $1D, 1, $11, $11, $11, 0, $E1, $11, $E0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$14, $11, $10, 0, 1, $45, $10, 0, 0, $11, $10, 0, 0, 2, $10, 0, 0, 2, $10, 0, 0, 2, $10, 0, 7, $66, $78, 0, 9, $99, $99, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, $1C, 0, 0, 0, $1C, 0, 0, 0, $1C, 0, 0, 0, $E1, 0, 0, 0, $E
	dc.b	$97, $78, $88, 0, $86, $67, $89, 0, $DD, $DD, $DE, $11, $CF, $DD, $DE, $DE, $CC, $CD, $DD, $DD, $CC, $CD, $DD, $DE, $11, $11, $EE, $E1, $E1, $11, $11, $10
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $10, 0, 0, 0, $10, 0, 0, 0, $10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
byte_31038:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, $35, 0, 0, 4, $54, 0, 0, 2, $22, 0, 0, 0, 0, 0, 0, 0, 3
	dc.b	0, 0, 0, $33, 0, 0, 3, $32, 0, 0, 3, $22, 0, 0, $33, $22, 0, 0, $32, $22, 0, 0, $22, 0, 0, 0, 0, 3, 0, 0, 0, 4
	dc.b	0, 0, 0, $34, 0, 0, 0, $43, 0, 0, 3, $43, 0, 0, 3, $42, 0, 0, $32, $22, 0, 3, $22, $11, 0, 2, $20, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, $87, $A, 0, $77, $89, $6B, 8, $66, $78, $86, $88, $87, $88, $99, $88, $88, $99, $11, 8, $89, 0, 1, 9, $90, 0, 1
	dc.b	0, 0, 0, 0, 0, $44, $44, $30, $44, $55, $55, $54, $55, $44, $44, $45, $33, $33, $33, $33, $22, $22, $23, $33, 2, $22, $22, $23, $33, $12, $22, $34
	dc.b	$22, $12, $23, $44, $22, $21, $33, $45, $22, $34, $34, $45, $24, $44, $34, $53, $34, $43, $35, $33, $44, $32, $35, $32, $43, $22, $21, $22, $32, $22, $22, $23
	dc.b	$32, $22, $22, $34, $22, $22, $22, $34, $22, $22, $23, $43, $22, $21, $13, $43, $11, $12, $24, $33, 1, $22, $24, $31, 0, 1, $25, $14, 0, $B, $34, $33
	dc.b	$B, $BD, $44, $33, $AB, $D4, $43, $22, $DD, $44, $32, $24, $EE, $44, $21, $34, $EE, $42, $21, $33, $EE, $22, $12, $23, $E9, $99, $12, $22, $99, $91, $12, $24
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, $44, $33, 0, 0, $54, $44, $34, $44, $44, $44, $44, $44, $34, $44, $44, $33, $45, $55, $43, $33, $55, $55, $44, $44
	dc.b	$55, $44, $54, $44, $44, $44, $54, $44, $33, $33, $44, $43, $33, $33, $33, $43, $22, $23, $33, $34, $23, $33, $33, $35, $34, $43, $33, $35, $44, $43, $33, $35
	dc.b	$53, $32, $33, $35, $33, $23, $3D, $AA, $32, $23, $DB, $BB, $32, $23, $DB, $BB, $22, $2D, $BB, $B8, $22, $2D, $BD, $89, $23, $32, $D0, $97, $24, $33, $10, $97
	dc.b	$24, $44, $DB, $BD, $22, $34, $3D, $DD, $32, $25, $43, 9, $33, $12, $53, 0, $33, $21, $33, 0, $32, $21, $32, 0, $22, $10, $20, 0, $22, $10, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $43, 0, 0, 0, $33, 0, 0, 0, $30, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$40, 0, 0, 0, $40, 0, 0, 0, $40, 0, 0, 0, $50, 0, 0, 0, $50, 0, 0, 0, $50, 0, 0, 0, $40, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $77, 0, 0, 0, $77, $80, 0, 0, $98, $80, 0, 0, $79, $80, 0, 0, $79, $80, 0, 0
	dc.b	$97, $80, 0, 0, $D9, $80, 0, 0, $99, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$9D, $91, $11, $14, $ED, $98, $9E, 4, $1D, $99, $9D, 5, $1E, $DD, $DD, 1, 1, $DD, $DE, 0, 1, $EE, $E1, 0, 0, $11, $10, 0, 0, 0, 0, 0
	dc.b	$11, $CC, $C0, 0, $C, $CF, $CC, 0, $DC, $EE, $ED, 0, $DE, $11, $1E, $D0, $E1, $11, $11, $E0, $11, $11, $11, $E0, $11, $11, $11, $10, 1, $11, $11, $1E
	dc.b	1, $11, $11, $1E, 1, $11, $11, $11, 0, $11, $11, $11, 0, $11, $11, $11, 0, $11, $11, $11, 0, 1, $11, $11, 0, 1, $11, $11, 0, 0, $11, $10
byte_312B8:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $34, 0, 0, 0, $45, 0, 0, 0, $22, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3
	dc.b	0, 0, 0, $33, 0, 0, 3, $32, 0, 0, $33, $22, 0, 0, $32, $22, 0, 3, $22, $22, 0, 2, $22, 3, 0, 0, 0, 4, 0, 0, 0, $34
	dc.b	0, 0, 0, $33, 0, 0, 3, $32, 0, 0, 3, $22, 0, 0, 2, $22, 0, 3, $32, $21, 0, 2, $21, $10, 0, 0, 0, 0, 0, $77, $78, $97
	dc.b	7, $66, $67, $89, 7, $66, $87, $79, 8, $77, $98, $89, 9, $88, $89, $98, 0, $99, $90, $99, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, $33, $44, $44, $43, $55, $55, $55, $44, $44, $44, $44, $55, $22, $33, $33, $33, 2, $22, $23, $33, 3, $22, $22, $23, $33, $12, $22, $24
	dc.b	$32, $12, $22, $44, $22, $21, $23, $55, $22, $34, $35, $44, $24, $44, $35, $42, $44, $43, $35, $32, $44, $32, $22, $12, $43, $22, $21, $23, $32, $22, $22, $33
	dc.b	$22, $22, $22, $34, $22, $22, $23, $44, $22, $22, $23, $43, $22, $11, $14, $43, $11, $22, $24, $42, 0, $22, $25, $12, 0, 1, $33, $32, 0, $B, $B4, $32
	dc.b	$70, $A, $B4, $22, $7D, $AB, $D2, $24, $8D, $DD, $22, $44, $90, 2, $23, $34, 0, 2, $12, $33, 0, 1, $22, $23, 0, 0, $12, $22, 0, 0, $12, $24
	dc.b	0, 0, 0, 0, $30, 0, 0, 0, $44, $33, 0, 0, $54, $44, $34, $44, $44, $44, $44, $43, $34, $44, $44, $33, $45, $55, $43, $33, $45, $55, $44, $33
	dc.b	$55, $44, $54, $44, $44, $44, $54, $44, $33, $33, $44, $43, $22, $33, $33, $43, $22, $23, $33, $34, $33, $33, $33, $34, $44, $43, $33, $35, $54, $43, $33, $35
	dc.b	$43, $32, $33, $35, $33, $23, $3D, $AA, $32, $23, $DB, $BB, $22, $23, $DB, $BB, $22, $2D, $BB, $B0, $22, $2D, $BD, 0, $33, $11, $D0, 0, $44, $43, $1A, $A9
	dc.b	$24, $44, $4D, $DA, $22, $45, $40, $D, $42, $24, $50, 0, $33, $22, $EE, $E0, $32, $2E, $11, $1E, $22, $E1, $11, $11, $22, $E1, $11, $11, $21, $E1, $11, $11
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $40, 0, 0, 0, $30, 0, 0, 0, $30, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, $40, 0, 0, 0, $40, 0, 0, 0, $40, 0, 0, 0, $50, 0, 0, 0, $50, 0, 0, 0, $50, 0, 0, 0, $40, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $87, $70, 0, 0, $87, $77, 0, 0, $87, $78, $80, 0
	dc.b	$BB, $97, $90, 0, $DD, $98, $90, 0, $99, $99, $90, 0, 9, $99, 0, 0, 0, 0, 0, 0, $E0, 0, 0, 0, $1E, 0, 0, 0, $1E, 0, 0, 0
	dc.b	0, 0, $21, $14, 0, 0, $21, 4, 0, 0, 2, $51, 0, 0, 2, $10, 0, 0, $E2, $1E, 0, $E, $E2, $1E, 0, $E, $72, $17, 0, $EE, $72, $18
	dc.b	0, $E9, $87, $78, 0, $9E, $99, $99, 0, $9E, $87, $78, 0, $EE, $DC, $CE, 0, $ED, $DC, $CD, 0, $ED, $DD, $DD, 0, $1D, $DD, $DD, 0, 1, $11, $11
	dc.b	$10, $EE, $11, $11, 0, $E, $11, $11, 0, 0, $E1, $11, 0, 0, $E1, $11, 0, 0, $E, $11, $E0, 0, $E, $11, $E0, 0, 0, $E1, $E0, 0, 0, $E
	dc.b	$E0, 0, 0, 0, $90, 0, 0, 0, $90, 0, 0, 0, $E0, 0, 0, 0, $E0, 0, 0, 0, $E0, 0, 0, 0, $10, 0, 0, 0, 0, 0, 0, 0
	dc.b	$11, $E0, 0, 0, $11, $E0, 0, 0, $11, $1E, 0, 0, $11, $1E, 0, 0, $11, $1E, 0, 0, $11, $1E, 0, 0, $11, $1E, 0, 0, $11, $1E, 0, 0
	dc.b	$EE, $E0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
byte_31578:
	dc.b	0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, $34, 0, 0, 0, $22, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3
	dc.b	0, 0, 0, $33, 0, 0, 3, $32, 0, 0, $33, $22, 0, 3, $22, $22, 0, 2, $22, $22, 0, 0, 0, 3, 0, 0, 0, 4, 0, 0, 0, $34
	dc.b	0, 0, 0, $33, 0, 0, 3, $32, 0, 0, 3, $22, 0, 0, $32, $22, 0, 3, $21, $11, 0, 2, $27, $98, 0, 8, $9A, $79, 0, 9, $AD, $9B
	dc.b	0, 9, $AA, $BD, 0, 0, $DD, $D0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, $44, $44, $30, $44, $55, $54, $43, $55, $44, $45, $54, $22, $23, $33, $45, $22, $22, $23, $33, 2, $22, $22, $33, 3, $22, $22, $23, $33, $12, $22, $34
	dc.b	$32, $12, $23, $45, $22, $21, $33, $54, $22, $34, $35, $44, $24, $44, $35, $32, $44, $43, $22, $22, $44, $32, $22, $12, $43, $22, $21, $23, $32, $22, $22, $34
	dc.b	$22, $22, $23, $44, $22, $22, $23, $44, $22, $22, $23, $43, $21, $11, $15, $43, $12, $22, $25, $42, 0, $12, $21, $12, 1, $34, $22, $34, $B3, $44, $42, $34
	dc.b	$D3, $54, $32, $22, $35, $53, $22, $32, $35, $32, $24, $43, $34, $21, $34, $43, $23, $12, $33, $33, 2, $12, $23, $32, 0, 1, $22, $22, 0, 1, $22, $24
	dc.b	0, 0, 0, 0, $33, 0, 0, 0, $44, $33, 0, 4, $54, $44, $34, $44, $44, $44, $44, $43, $34, $44, $44, $33, $45, $55, $43, $33, $55, $55, $44, $33
	dc.b	$44, $44, $54, $44, $44, $44, $54, $44, $33, $33, $44, $43, $22, $33, $33, $43, $22, $23, $33, $34, $33, $33, $33, $35, $44, $43, $33, $35, $54, $43, $33, $35
	dc.b	$43, $32, $33, $35, $33, $23, $3D, $AA, $32, $23, $DB, $BB, $22, $23, $DB, $BB, $22, $2D, $BB, $B0, $31, $2D, $BD, 0, $43, $1B, $BA, $A0, $45, $41, $DD, $DA
	dc.b	$44, $54, $10, $D, $22, $34, $10, 0, $21, $23, $10, 0, $22, $12, 0, 0, $22, $1D, $DD, 0, $22, $1C, $CD, 0, $21, $CC, $FC, $D0, $1D, $EE, $EE, $D0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $30, 0, 0, 0, $30, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, $40, 0, 0, 0, $40, 0, 0, 0, $40, 0, 0, 0, $50, 0, 0, 0, $50, 0, 0, 0, $50, 0, 0, 0, $40, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $A0, 0, 0, 0
	dc.b	$D6, $70, 0, 0, $77, $96, 0, 0, 9, $86, $60, 0, 7, $88, $66, 0, 8, $78, $86, 0, 0, $79, $88, $60, 0, $70, $88, $60, 0, 0, 8, 0
	dc.b	0, 1, $11, $41, 0, 1, $54, $10, 0, 1, $11, 0, 0, 1, $20, 0, 0, 1, $20, 0, 0, 1, $20, 0, 0, $87, $66, $70, 0, $99, $99, $90
	dc.b	$D1, $11, $11, $10, $11, $11, $11, $10, $E, $11, $1E, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, $88, $87, $79, 0, $98, $76, $68, $11, $ED, $DD, $DD, $ED, $ED, $DD, $FC, $DD, $DD, $DC, $CC, $ED, $DD, $DC, $CC, $1E, $EE, $11, $11, 1, $11, $11, $1E
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, $10, 0, 0, 0, $C1, 0, 0, 0, $C1, 0, 0, 0, $C1, 0, 0, 0, $1E, 0, 0, 0, $E0, 0, 0, 0
byte_31818:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, $33
	dc.b	0, 0, 3, $32, 0, 0, 3, $22, 0, 0, $33, $23, 0, 0, $32, $32, 0, 3, $32, $23, 0, 3, $22, $33, 0, 3, $23, $23, 0, 3, $22, $33
	dc.b	0, $33, $23, $23, 0, $32, $22, $33, 0, $32, $23, $23, 0, $32, $22, $33, 0, $32, $23, $23, 0, $32, $22, $32, 0, $32, $23, $23, 0, $33, $22, $32
	dc.b	0, 3, $22, $23, 0, 3, $22, $32, 0, 3, $22, $23, 0, 3, $32, $22, 0, 0, $32, $23, 0, 0, $33, $22, 0, 0, 3, $22, 0, 0, 3, $32
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, $33, 0, 3, $33, $33, 3, $33, $33, $33, $33, $33, $33, $33, $32, $33, $33, $33, $23, $33, $33, $33
	dc.b	$33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33
	dc.b	$33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33
	dc.b	$23, $33, $33, $33, $33, $33, $33, $33, $23, $33, $33, $33, $32, $33, $33, $33, $23, $33, $33, $33, $32, $33, $33, $33, $23, $23, $33, $33, $22, $32, $33, $33
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, $33, $30, 0, 0, $33, $33, $30, 0, $33, $33, $33, $30, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33
	dc.b	$33, $34, $44, $43, $33, $44, $44, $44, $34, $44, $55, $54, $34, $45, $66, $55, $34, $45, $66, $65, $34, $45, $56, $65, $33, $44, $55, $55, $33, $44, $45, $54
	dc.b	$33, $34, $44, $44, $33, $33, $34, $44, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33
	dc.b	$33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $30, 0, 0, 0, $33, 0, 0, 0
	dc.b	$33, $30, 0, 0, $43, $30, 0, 0, $43, $33, 0, 0, $44, $33, 0, 0, $44, $33, $30, 0, $44, $33, $30, 0, $44, $33, $30, 0, $44, $33, $30, 0
	dc.b	$43, $33, $33, 0, $33, $33, $33, 0, $33, $33, $33, 0, $33, $33, $33, 0, $33, $33, $33, 0, $33, $33, $33, 0, $33, $33, $33, 0, $33, $33, $33, 0
	dc.b	$33, $33, $30, 0, $33, $33, $30, 0, $33, $33, $30, 0, $33, $33, $30, 0, $33, $33, 0, 0, $33, $33, 0, 0, $33, $30, 0, 0, $33, $30, 0, 0
	dc.b	0, 0, 0, $33, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$22, $23, $23, $33, $32, $22, $33, $33, $33, $22, $23, $23, 3, $33, $22, $32, 0, 3, $33, $23, 0, 0, 3, $33, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$33, $33, $33, $33, $33, $33, $33, $33, $33, $23, $23, $33, $32, $32, $33, $30, $23, $33, $30, 0, $33, $30, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$33, 0, 0, 0, $30, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
byte_31A98:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, $32
	dc.b	0, 0, 3, $22, 0, 0, 3, $22, 0, 0, $32, $22, 0, 0, $32, $22, 0, 3, $22, $22, 0, 3, $22, $22, 0, 3, $22, $22, 0, 3, $22, $22
	dc.b	0, $32, $22, $2D, 0, $32, $22, $BD, 0, $32, $22, $BD, 0, $32, $2B, $BD, 0, $32, $2B, $DD, 0, $32, $BB, $DD, 0, $32, $BB, $DD, 0, $32, $BB, $DD
	dc.b	0, 3, $BB, $DD, 0, 3, $99, $DD, 0, 3, $88, $DD, 0, 9, $88, $DD, 0, 0, $88, $8D, 0, 0, $88, $8D, 0, 0, 8, $8D, 0, 0, 8, $8D
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $33, 0, 3, 3, $23, 3, $33, $32, $33, $32, $23, $32, $33, $22, $23, $22, $33, $22, $23, $23, $33
	dc.b	$22, $22, $23, $33, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $2C, $CC, $22, $22, $CC, $CC, $C2, $22, $DD, $CC, $C2, $22
	dc.b	$DD, $DD, $CC, $22, $DD, $DD, $DC, $22, $DD, $DD, $DC, $22, $DD, $DD, $DC, $22, $DD, $DD, $DC, $C2, $DD, $DD, $DC, $C2, $DD, $DD, $DC, $C2, $DD, $DD, $DC, $C2
	dc.b	$DD, $DD, $DC, $C2, $DD, $DD, $DC, $C2, $DD, $DD, $DC, $CB, $DD, $DD, $DC, $CA, $DD, $DD, $DC, $BA, $DD, $DD, $DC, $33, $DD, $DD, $DC, $33, $DD, $DD, $DC, $BB
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, $34, 0, 0, 0, $34, $40, $30, 0, $34, $43, $23, $40, $33, $43, $22, $34, $33, $33, $22, $34, $33, $33, $22, $34
	dc.b	$33, $33, $23, $33, $33, $33, $35, $53, $22, $33, $56, $65, $22, $23, $56, $66, $22, $22, $56, $66, $22, $22, $CC, $66, $22, $CC, $CC, $C5, $22, $CD, $DC, $C2
	dc.b	$2D, $CD, $DD, $CC, $2D, $DD, $DD, $CC, $2D, $DD, $DD, $CC, $2D, $DD, $DD, $DC, $2D, $DD, $DD, $DC, $2D, $DD, $DD, $DC, $2D, $DD, $DD, $DC, $2D, $DD, $DD, $DD
	dc.b	$2D, $DD, $DD, $DD, $2D, $DD, $DD, $DD, $BD, $DD, $DD, $DD, $AD, $DD, $DD, $DC, $AD, $DD, $DD, $DC, $3D, $DD, $DD, $DC, $3D, $DD, $DD, $DC, $BD, $DD, $DD, $DC
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $40, 0, 0, 0, $44, 0, 0, 0
	dc.b	$44, $40, 0, 0, $34, $40, 0, 0, $54, $44, 0, 0, $65, $44, 0, 0, $65, $44, $40, 0, $65, $44, $40, 0, $53, $44, $40, 0, $24, $44, $40, 0
	dc.b	$C4, $44, $44, 0, $C2, $44, $44, 0, $C2, $44, $44, 0, $CB, $44, $34, 0, $CB, $44, $33, 0, $CB, $B5, $33, 0, $CB, $B5, $33, 0, $CB, $B3, $33, 0
	dc.b	$CB, $B3, $30, 0, $C9, $93, $30, 0, $C8, $88, $30, 0, $C8, $88, $30, 0, $C7, $88, 0, 0, $C7, $78, 0, 0, $C7, $70, 0, 0, $C7, $70, 0, 0
	dc.b	0, 0, 0, $88, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$DD, $DD, $DC, $BB, $DD, $DD, $DA, $AB, $D, $DD, $C5, $51, $D, $DD, $C0, 0, 0, $D, $C0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$BD, $DD, $DD, $CC, $BD, $DD, $DD, $C8, $95, $CD, $DC, $C8, 0, $CD, $DC, 0, 0, $C, $D0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$87, 0, 0, 0, $80, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
byte_31D18:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $C, 0, 0, 0, $3C
	dc.b	0, 0, 3, $BC, 0, 0, $B, $B9, 0, 0, $3B, $77, 0, 0, $3B, $77, 0, 3, $2B, $77, 0, 3, $20, $77, 0, 3, $22, $87, 0, 3, $22, $88
	dc.b	0, $32, $22, $20, 0, $32, $22, $22, 0, $32, $22, $22, 0, $32, $22, $22, 0, $32, $22, $22, 0, $32, $22, $22, 0, $32, $22, $22, 0, $32, $22, $22
	dc.b	0, 3, $22, $22, 0, 3, $22, $22, 0, 3, $22, $22, 0, 3, $22, $22, 0, 0, $32, $22, 0, 0, $32, $22, 0, 0, 3, $22, 0, 0, 3, $22
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $C, $C0, 0, $C, $CC, $C2, $C, $CC, $CC, $C2, $CC, $CC, $CC, $C2, $CC, $CC, $CC, $C2, $CC, $CC, $CC, $D2
	dc.b	$DC, $CC, $CD, $D2, $CD, $CC, $CD, $DB, $CD, $DD, $DD, $DB, $CD, $DD, $DD, $D2, $CD, $DD, $DD, $D2, $CD, $DD, $DD, $DB, $CD, $DD, $DD, $DA, $CD, $DD, $DD, $DA
	dc.b	$8C, $DD, $DD, $B1, $2C, $DD, $DD, $B1, $2C, $DD, $DD, $B1, $2C, $DD, $DD, $18, $3C, $DD, $DD, $13, $34, $CD, $D1, $34, $34, $CD, $D3, $42, $33, $4C, $C2, $22
	dc.b	$23, $3C, $C2, $22, $23, $33, $32, $23, $22, $33, $33, $32, $22, $23, $22, $23, $22, $22, $23, $33, $BB, $22, $23, $33, $BB, $B2, $22, $33, $2B, $B2, $22, $23
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, $C, $C0, 0, 0, $2C, $CC, $C0, 0, $2C, $CC, $CC, $C0, $2C, $CC, $CC, $CC, $2C, $CC, $CC, $CC, $2D, $CD, $DC, $CC
	dc.b	$2D, $DD, $DC, $CC, $BD, $CD, $DD, $CC, $BD, $DD, $DD, $CB, $2D, $DD, $DD, $CB, $2D, $DD, $DD, $BB, $BD, $DD, $DD, $BB, $AD, $DD, $DD, $BB, $AD, $DD, $DD, $CC
	dc.b	$1B, $DD, $DD, $CC, $1B, $CD, $DD, $DC, $1B, $CD, $DD, $DC, $81, $1C, $DD, $D2, $31, $1C, $DD, $D2, $43, $1C, $DD, $C2, $24, $33, $DD, $C3, $22, $23, $CC, $33
	dc.b	$22, $23, $CC, $34, $32, $23, $3C, $44, $33, $33, $33, $44, $33, $33, $33, $45, $33, $33, $33, $43, $33, $33, $32, $BB, $33, $33, $2B, $BB, $33, $33, $2B, $B2
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $C0, 0, 0, 0, $C4, 0, 0, 0
	dc.b	$CB, $40, 0, 0, $9B, $B0, 0, 0, $67, $B4, 0, 0, $77, $B4, 0, 0, $66, $B4, $40, 0, $66, $44, $40, 0, $67, $44, $40, 0, $73, $44, $40, 0
	dc.b	$33, $44, $44, 0, $33, $44, $44, 0, $33, $44, $44, 0, $23, $45, $44, 0, $24, $45, $44, 0, $24, $45, $44, 0, $34, $55, $44, 0, $45, $54, $44, 0
	dc.b	$45, $54, $40, 0, $45, $44, $40, 0, $44, $44, $40, 0, $54, $43, $40, 0, $24, $33, 0, 0, $23, $33, 0, 0, $23, $30, 0, 0, $33, $30, 0, 0
	dc.b	0, 0, 0, $32, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$22, $22, $22, $22, $22, $22, $22, $22, $32, $22, $22, $22, 3, $32, $22, $22, 0, 3, $32, $22, 0, 0, 3, $33, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$22, $22, $22, $23, $22, $22, $23, $33, $22, $33, $33, $33, $22, $33, $33, $30, $22, $23, $30, 0, $33, $30, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$33, 0, 0, 0, $30, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
byte_31F98:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, $43
	dc.b	0, 0, 4, $32, 0, 0, 3, $32, 0, 0, $33, $32, 0, 0, $32, $33, 0, 3, $23, $33, 0, 3, $23, $33, 0, 3, $23, $33, 0, 3, $23, $33
	dc.b	0, $32, $33, $33, 0, $32, $33, $33, 0, $32, $23, $33, 0, $32, $23, $33, 0, $32, $23, $33, 0, $32, $23, $33, 0, $32, $22, $33, 0, $32, $22, $33
	dc.b	0, 3, $22, $33, 0, 3, $22, $23, 0, 3, $22, $23, 0, 3, $22, $22, 0, 0, $32, $22, 0, 0, $32, $22, 0, 0, 3, $22, 0, 0, 3, $22
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $D, $D9, 0, 4, $43, $33, 3, $44, $33, $33, $43, $33, $33, $34, $33, $33, $33, $44, $33, $33, $33, $44
	dc.b	$22, $23, $33, $44, $33, $33, $33, $34, $23, $33, $33, $34, $22, $33, $33, $34, $32, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33
	dc.b	$33, $33, $33, $33, $33, $23, $33, $33, $33, $23, $33, $33, $33, $22, $33, $33, $33, $22, $33, $33, $33, $32, $33, $33, $33, $32, $23, $33, $33, $32, $23, $33
	dc.b	$33, $32, $23, $33, $33, $32, $22, $33, $33, $33, $22, $33, $33, $33, $22, $23, $33, $33, $32, $22, $23, $33, $32, $22, $23, $33, $22, $32, $22, $33, $22, $32
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, $1D, $D0, 0, 0, $34, $44, $D0, 0, $33, $33, $44, $40, $44, $43, $34, $44, $44, $44, $34, $44, $44, $44, $35, $55
	dc.b	$44, $44, $32, $22, $45, $54, $43, $35, $44, $55, $44, $44, $44, $45, $55, $44, $44, $45, $55, $55, $44, $45, $66, $65, $34, $45, $66, $66, $34, $45, $76, $66
	dc.b	$33, $45, $56, $65, $33, $45, $55, $55, $33, $44, $55, $45, $33, $44, $54, $45, $33, $44, $44, $45, $33, $44, $43, $44, $34, $44, $33, $44, $34, $44, $23, $44
	dc.b	$34, $43, $23, $44, $34, $43, $23, $44, $44, $22, $33, $44, $33, $22, $33, $43, $32, $23, $34, $33, $22, $23, $33, $33, $22, $22, $33, $33, $23, $22, $33, $33
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $40, 0, 0, 0, $54, 0, 0, 0
	dc.b	$24, $40, 0, 0, $24, $40, 0, 0, $24, $44, 0, 0, $33, $24, 0, 0, $44, $32, $40, 0, $54, $32, $40, 0, $55, $32, $40, 0, $65, $32, $40, 0
	dc.b	$54, $32, $44, 0, $54, $32, $44, 0, $54, $32, $44, 0, $44, $32, $44, 0, $42, $53, $23, 0, $42, $53, $23, 0, $42, $53, $23, 0, $42, $43, $23, 0
	dc.b	$32, $43, $20, 0, $32, $43, $20, 0, $32, $32, $30, 0, $33, $32, $30, 0, $33, $23, 0, 0, $33, $23, 0, 0, $33, $20, 0, 0, $32, $30, 0, 0
	dc.b	0, 0, 0, $32, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$22, $33, $23, $33, $22, $32, $23, $33, $32, $22, $23, $33, 3, $32, $32, $33, 0, 3, $32, $23, 0, 0, 3, $32, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$33, $22, $23, $32, $33, $33, $23, $32, $33, $32, $22, $22, $33, $23, $32, $20, $32, $23, $30, 0, $22, $30, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$23, 0, 0, 0, $20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
byte_32218:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, $33
	dc.b	0, 0, 3, $33, 0, 0, 3, $23, 0, 0, $32, $33, 0, 0, $32, $33, 0, 3, $23, $33, 0, 3, $23, $33, 0, 3, $23, $34, 0, 3, $23, $34
	dc.b	0, $32, $23, $34, 0, $32, $23, $33, 0, $32, $23, $33, 0, $32, $22, $33, 0, $32, $22, $33, 0, $32, $22, $23, 0, $32, $22, $22, 0, $32, $22, $32
	dc.b	0, 3, $22, $33, 0, 3, $22, $33, 0, 3, $22, $23, 0, 3, $22, $22, 0, 0, $32, $22, 0, 0, $32, $22, 0, 0, 3, $2C, 0, 0, 3, $3C
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, $33, 0, 3, $34, $44, 3, $33, $34, $44, $32, $33, $33, $44, $32, $33, $33, $44, $33, $32, $33, $34
	dc.b	$33, $33, $33, $34, $33, $33, $33, $34, $33, $33, $33, $33, $34, $33, $32, $33, $44, $33, $32, $33, $44, $43, $33, $23, $44, $33, $33, $22, $44, $33, $33, $22
	dc.b	$43, $33, $32, $34, $33, $33, $23, $34, $33, $32, $33, $34, $33, $33, $23, $34, $33, $33, $23, $34, $23, $33, $32, $34, $33, $33, $33, $23, $33, $33, $32, $22
	dc.b	$33, $33, $32, $32, $33, $33, $23, $33, $33, $32, $33, $33, $33, $22, $33, $33, $22, $22, $23, $33, $C2, $22, $23, $33, $CC, $C2, $32, $33, $CC, $CC, $23, $23
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, $44, $40, 0, 0, $44, $44, $40, 0, $44, $44, $44, $40, $44, $44, $43, $44, $45, $44, $43, $34, $45, $54, $43, $44
	dc.b	$55, $44, $43, $44, $55, $44, $34, $44, $54, $43, $34, $44, $34, $43, $45, $55, $33, $34, $66, $65, $33, $45, $66, $66, $33, $44, $56, $66, $44, $34, $56, $65
	dc.b	$44, $43, $35, $55, $44, $44, $35, $54, $44, $34, $33, $44, $44, $33, $32, $34, $43, $32, $33, $23, $33, $33, $33, $32, $33, $33, $33, $32, $32, $33, $33, $33
	dc.b	$33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $22, $33, $33, $32, $C2, $33, $33, $2C, $C2, $23, $33, $CC, $CC
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $40, 0, 0, 0, $44, 0, 0, 0
	dc.b	$44, $40, 0, 0, $44, $40, 0, 0, $44, $44, 0, 0, $44, $44, 0, 0, $54, $44, $40, 0, $54, $34, $40, 0, $54, $33, $40, 0, $54, $33, $40, 0
	dc.b	$54, $33, $44, 0, $43, $33, $44, 0, $43, $33, $44, 0, $33, $34, $44, 0, $33, $34, $34, 0, $33, $44, $34, 0, $33, $43, $34, 0, $23, $43, $34, 0
	dc.b	$44, $43, $30, 0, $44, $43, $30, 0, $44, $42, $30, 0, $44, $32, $30, 0, $34, $23, 0, 0, $33, $23, 0, 0, $23, $20, 0, 0, $22, $30, 0, 0
	dc.b	0, 0, 0, $DD, 0, 0, 0, $D, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$DD, $DC, $22, $32, $DD, $DC, $22, $23, $DD, $DD, $22, $22, $D, $DD, $D3, $22, 0, $D, $DD, 0, 0, 0, $D, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$32, $2C, $CC, $CC, $22, $2C, $CD, $DD, $22, $CD, $DD, $DD, $22, $CD, $DD, $D0, $D, $DD, $D0, 0, $D, $D0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$23, 0, 0, 0, $20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
byte_32498:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5
	dc.b	0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 2, $77, 0, 0, 2, $97, $70, 0, 0, $79, $78, 7, $70, $77, $77, $87, $90, $77, $77, $77, 3
	dc.b	$87, $77, $79, 3, $88, $77, $89, $34, $98, $88, $98, $35, 9, $98, $79, $25, 0, $98, $9D, $12, 0, 0, 0, $DD, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, $C, 0, 0, 0, $CC, 0, 0, $D, $11, 0, 0, 1, $DD, 0, 0, $1D, $EE, 0, 0, $1E, $EE, 0, 0, $EE, $EE
	dc.b	0, 0, 0, 4, 0, 0, 0, $45, 0, 0, 0, $45, 0, 0, 4, $32, 0, 0, 3, $22, 0, 0, $33, $22, $44, 0, $32, $22, $54, $44, $12, $22
	dc.b	$35, $44, $21, $21, $23, $43, $32, $33, $22, $32, $23, $34, $22, $22, $13, $45, $22, $21, $23, $55, $21, $12, $23, $55, $13, $33, $12, $35, $34, $43, $31, $22
	dc.b	$45, $43, $31, $22, $55, $43, $32, $11, $53, $32, $13, $32, $22, $21, $34, $32, $20, 3, $54, $32, $BB, $B5, $43, $22, $DD, $45, $32, $24, 0, $52, $12, $45
	dc.b	0, $21, $34, $55, $CC, 1, $23, $44, $CF, $C1, $22, $35, $1C, $C1, $22, $21, $D1, $C0, $12, $22, $D1, $D0, $11, $22, $D1, $D0, 0, $11, $D1, $D0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $77, 0, 0, 0, $98, 0, 0, 8, $89, 0, 0, 9, $88
	dc.b	0, 0, 8, $89, 0, 0, 0, $98, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, $E, $EE, $EE, 0, $E, $EE, $EE, 0, $E, $EE, $EE, 0, $E, $EE, $EE, 0, $E, $EE, $EE, 0, $E, $EE, $EE, 0, $E, $EE, $EE, 0, $E, $EE, $E1
	dc.b	$D1, 0, 0, 0, $E1, 0, 0, 0, $E1, 0, 0, 0, $10, 0, 0, 0, $10, 0, 0, 0, $10, 0, 0, 0, $10, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, $E, $EE, $E1, 0, 1, $EE, $E1, 0, 1, $EE, $10, 0, 0, $11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
byte_32638:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, $35, $45, 0, 3, $45, $34, $55, $33, $52, $33, $45, $34, $22, $33, $45, $34, $22
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, $77, 0, 9, $88, $77, 0, 8, $88, $87, 0, 9, $88, $88, 0, 0, $99, $88
	dc.b	0, 0, 0, $99, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 3, $77, 0, 0, $31, $77, $87, $70, $1C, $77, $78, $90, $1C, $77, $87, $71, $CD, $88, $79, $91, $CD
	dc.b	$98, $7D, $D1, $DD, $98, $9D, $1D, $DD, 0, 0, $1D, $DD, 0, 0, $1D, $DD, 0, 0, $1D, $DD, 0, 0, $1D, $DD, 0, 0, $1D, $DD, 0, 0, $1D, $DD
	dc.b	$33, $22, $32, $22, $31, $12, $22, $22, $1C, $D1, $22, $23, $CC, $CC, $12, $34, $DD, $CC, $12, $34, $DD, $DC, $14, $25, $DD, $DC, $13, $32, $DD, $DD, $13, $32
	dc.b	$DD, $DD, $13, $23, $DD, $D1, $22, $34, $DD, $D1, $23, $22, $DD, $D1, $22, $22, $DD, $12, $22, $22, $DD, $12, $22, $22, $DD, $1D, $22, $22, $DD, $1D, $DB, $BB
	dc.b	0, 0, $1D, $DD, 0, 0, $1D, $DD, 0, 0, 1, $DD, 0, 0, 1, $DD, 0, 0, 0, $11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$D1, 0, $DB, $BB, $D1, 0, $D, $BB, $D1, 0, 0, $DD, $10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
byte_32758:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 1
	dc.b	0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, $34, 0, 0, 0, $33, 0, 0, 0, $33, $51, $11, $13, $32, $1C, $CC, $C1, $32, $CC, $CC, $C1, $24
	dc.b	0, 0, 0, 0, $50, 0, 0, 0, $53, 0, 0, 0, $34, 0, 0, 0, $24, 0, 0, 0, $24, $30, 0, $35, $23, $40, 3, $44, $52, $40, $34, $43
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $50, 0, 0, 0, $40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, $77, 0, 9, $88, $77, 0, 8, $88, $87
	dc.b	0, 9, $88, $88, 0, 0, $99, $88, 0, 0, 0, $99, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, $1C, 0, 0, 1, $CC, 0, 0, 1, $CC, 0, 0, $1C, $CC, 0, 1, $CC, $CC, $77, 1, $CC, $CC, $77, $1C, $CC, $CC, $77, $1C, $CC, $CC
	dc.b	$77, $1C, $CC, $C1, $88, $1C, $CC, $1E, $98, $71, $11, $E0, $98, $9D, $DB, 0, 0, 0, $D, $DD, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$CC, $CC, $C1, $24, $CC, $CC, $1E, $44, $CC, $CC, $1E, $41, $CC, $C1, $E9, $31, $CC, $1E, $E8, $31, $CC, $1E, $87, $31, $C1, $E8, $72, $21, $1E, $98, $21, $12
	dc.b	$E2, $22, $34, $31, 2, $54, $43, $32, 2, $13, $33, $23, 0, $21, $32, $33, $D1, $24, $34, $45, 0, $12, $43, $45, 0, $21, $22, $44, 0, $22, $22, $22
	dc.b	$52, $32, $44, $32, $45, $23, $33, $22, $35, $22, $32, $21, $23, $32, $22, $1C, $23, $32, $23, $1C, $23, $22, $34, $1C, $22, $23, $33, $1C, $21, $12, $11, $1C
	dc.b	$13, $43, $22, $1C, $23, $34, $45, $21, $52, $33, $31, $21, $53, $23, $12, 1, $54, $43, $22, $DD, $54, $32, $32, 0, $44, $22, $22, 0, $22, $22, $22, 0
	dc.b	0, 0, 0, 0, $11, 0, 0, 0, $DC, $10, 0, 0, $CC, $C1, 0, 0, $CC, $CC, $10, 0, $CC, $CC, $10, $77, $CC, $CC, $C1, $77, $CC, $CC, $C1, $77
	dc.b	$CC, $CC, $C1, $77, $CC, $CC, $CD, $18, $CC, $CC, $CC, $19, $CC, $CC, $CC, $19, $1C, $CC, $CC, $10, $1C, $CC, $CC, $10, $1C, $CC, $CC, $10, $1D, $CC, $CC, $10
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $77, $90, 0, 0, $77, $88, $90, 0, $78, $88, $80, 0
	dc.b	$88, $88, $90, 0, $88, $99, 0, 0, $99, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, $D, $22, $22, 0, $D, $DB, $BB, 0, 0, $DB, $BB, 0, 0, $D, $BB, 0, 0, 0, $DD, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$22, $22, $D0, 0, $BB, $BD, $D0, 0, $BB, $BD, 0, 0, $BB, $D0, 0, 0, $DD, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	1, $CC, $CC, $10, 1, $CC, $CC, $10, 1, $DC, $C1, 0, 0, $1D, $D1, 0, 0, 1, $10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
byte_329B8:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $55, 0, 0, 0, $24, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 5, 0, 0, 0, $35, 0, 0, 0, $43, 0, 0, 0, $42, $53, 0, 3, $42, $44, $30, 4, $32, $34, $43, 4, $25, $23, $44, $23, $25
	dc.b	$22, $33, $32, $54, 2, $23, $22, $53, $42, $22, $23, $32, $44, $32, $23, $32, $33, $43, $22, $32, $11, $33, $32, $22, $22, $11, $21, $12, $22, $22, $34, $31
	dc.b	0, 0, $88, $80, 0, $98, $87, $77, 9, $88, $77, $77, 9, $88, $87, $79, 0, $98, $88, $98, 0, 9, $98, $98, 0, 0, 9, $90, 0, 0, 0, 1
	dc.b	0, 0, 1, $1C, 0, 1, $1C, $CD, 0, $1C, $CD, $DD, 1, $CD, $DD, $DD, $1C, $DD, $DD, $DD, $1C, $DD, $DD, $DD, 1, $DD, $DD, $D1, 0, $11, $11, $10
	dc.b	0, 0, 0, 0, $88, 0, 0, 0, $87, $70, 0, 0, $79, $90, 0, 5, $7D, $BB, $BB, $42, $91, $DD, $DD, $77, 0, $11, $11, $18, $11, $CC, $CC, $C1
	dc.b	$CC, $DD, $DD, $DC, $DD, $DD, $DD, $DD, $DD, $DD, $DD, $DD, $DD, $DD, $DD, $D1, $DD, $DD, $D1, $10, $DD, $11, $10, 0, $11, 0, 0, 0, 0, 0, 0, 0
	dc.b	2, $54, $43, $32, 2, $13, $33, $25, 0, $21, $32, $35, $44, $42, $23, $42, $22, $22, $23, $31, 0, 2, $22, $33, $72, $21, $12, $22, $88, $11, $22, $11
	dc.b	$19, 0, $12, $22, $19, 0, $DB, $BB, $10, 0, $D, $BB, 0, 0, 0, $DD, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
byte_32AF8:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $50, 0, 0, 0, $45, $30, 0, 0, $24, $40, 0, 0, $23, $43, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 4, $40, 0, 0, $45, $40, 0, 0, $43, $40, 0, 4, $33, $40, 0, $33, $32, $40, 0, $33, $22, $40, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, $B, 0, 0, 0, $BD, 0, 0, 0, $BD, 0, 0, 0, $BD, 0, 0, 0, $76, 0, 0, 0, $99, 0, 0, 0, $78, 0, 0, 7, $78
	dc.b	0, 0, $78, $99, 0, 0, $79, $99, 0, 0, 9, $90, 0, 0, 0, 8, 0, 0, 0, $89, 0, 0, 0, $88, 0, 0, 0, $98, 0, 0, 8, $DD
	dc.b	0, 8, $7D, $DD, 0, $D8, $7D, $DD, 0, $D8, $8D, $DD, 0, $E8, $8D, $DD, 0, $E, $ED, $DD, 0, 0, $E, $EE, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, $23, $44, 3, 0, 2, $34, $23, 0, 2, $33, $32, $55, $42, $23, $22, $24, $44, $22, $23, $22, $44, $32, $23, $22, $13, $32, $23, 2, $21, $33, $22
	dc.b	$B2, $22, $12, $11, $DB, $B2, $23, $43, $D, $DB, $34, $33, 0, 3, $54, $32, $80, 5, $43, $24, $68, 4, $21, $44, $88, 2, $13, $45, $44, $80, $12, $34
	dc.b	$22, $44, $12, $23, $22, $22, $12, $22, $22, 2, $21, $22, $76, $77, 1, $12, $99, $99, 0, 1, $87, $79, 0, 0, $77, $78, 0, 0, $DE, $E1, 0, $E
	dc.b	$DF, $CC, $10, 1, $CC, $CC, $10, 1, $CC, $CC, $10, 1, $CC, $CC, $10, 0, $CC, $CC, $10, 0, $11, $11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$32, $22, $30, 0, $24, $52, $40, $34, $44, $52, $32, $44, $42, $45, $23, $33, $31, $35, $22, $32, $21, $23, $32, $22, $21, $23, $32, $23, $12, $23, $23, $44
	dc.b	$22, $22, $33, $33, $12, $11, $21, $11, $11, $34, $32, $22, $23, $45, $42, $22, $42, $33, $54, $20, $54, $21, $25, 0, $55, $43, $12, 0, $44, $32, $1D, $B0
	dc.b	$53, $22, $10, $DB, $12, $22, $10, $DB, $22, $21, $22, $D, $22, $10, $11, $22, $11, 9, $68, $44, $E, $DC, $C9, $88, $E1, $11, $11, $C9, $1C, $CC, $CC, $11
	dc.b	$CD, $DD, $DD, $CC, $DD, $DD, $DD, $DD, $ED, $DD, $DD, $DD, $1E, $ED, $DD, $DD, 1, $1E, $EE, $DD, 0, 1, $11, $EE, 0, 0, 0, $11, 0, 0, 0, 0
	dc.b	$33, $54, 0, 0, $44, $40, 0, 0, $43, $20, 0, 0, $32, 0, 0, 0, $22, 0, 0, 0, $20, 0, 0, 0, $34, $55, 0, 0, $44, $20, 0, 0
	dc.b	$32, 0, 0, 0, $22, 0, 0, 0, $20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, $B0, 0, 0, 0, $B7, $70, 0, 0, $2B, $69, 0, 0, $28, $98, $77, $78, $99, $98, $88, $88, $19, $99, $88, $99
	dc.b	$C1, $19, $99, 0, $DC, $C1, $10, 0, $DD, $DC, $C1, 0, $DD, $DD, $DC, $10, $DD, $DD, $DD, $C1, $ED, $DD, $DD, $E1, $1E, $EE, $EE, $10, 1, $11, $11, 0
byte_32D58:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, $40, 0, 0, $45, $44, 0, 4, $35, $34, 0
	dc.b	0, 0, 0, 0, 0, 4, $40, 0, 0, $55, $44, 3, 0, $23, $54, $41, 0, $22, $34, $42, 0, $22, $24, $33, 0, $22, $23, $22, 0, $22, $22, $13
	dc.b	$33, $22, $34, 0, $32, $22, $23, 0, $22, $22, $23, $30, $22, $22, $22, $30, $12, $12, $21, $44, $23, $32, $12, $44, $33, $43, $23, $34, $45, $53, $32, $33
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $44, 0, 0, 0, $45, $50, 0, 0, $44, $20, 0, 0, $22, $20, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 2, 0, 0, 0, 1
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $A, 0, 0, 0, $AD, 0, 0, 0, $BD, 0, 0, 0, $D
	dc.b	0, $21, $11, $23, 0, $13, $32, $23, 0, $34, $43, $12, 3, $45, $44, $31, $45, $55, $43, $31, $54, $43, $33, $21, $42, $22, $21, $33, $20, 0, $13, $43
	dc.b	0, 0, $35, $43, 0, 3, $54, $32, 0, 5, $43, $24, $A, $B4, $21, $44, $AD, $D2, $13, $45, $D0, 0, $12, $34, 8, $80, $12, $23, $DD, $88, $12, $22
	dc.b	$55, $43, $12, $22, $55, $53, $21, $22, $35, $53, $22, $11, $22, $32, $13, $33, $22, $21, $33, $44, $11, $13, $34, $45, $21, $23, $34, $55, $22, $31, $23, $35
	dc.b	$23, $43, $12, $23, $23, $45, $40, 2, $42, $33, $54, 0, $54, $21, $25, 0, $55, $43, $12, 0, $44, $32, $1D, $B0, $53, $22, $10, $DB, $12, $22, $10, $D
	dc.b	$22, 0, 0, 0, $22, 0, 0, 0, $20, 0, 0, 0, $10, 0, 0, 0, $30, 0, 0, 0, $30, 0, 0, 0, $33, 0, 0, 0, $43, 0, 0, 0
	dc.b	$53, 0, 0, 0, $44, 0, 0, 0, $22, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $B0, 0, 0, 0
	dc.b	$88, $89, $91, $22, $89, $92, $21, $12, $92, $22, $10, 1, $91, $11, $21, 0, 9, $87, $78, 0, 9, $99, $99, 0, 8, $88, $77, $90, 9, $87, $77, $80
	dc.b	$22, $21, $20, $D, $22, $11, $12, $28, $11, 0, 1, $29, 0, 0, $22, $18, 0, 6, $67, $88, 0, 9, $99, $99, 0, $97, $78, $88, 0, $86, $67, $89
	dc.b	$B8, 0, 0, 0, $1B, $80, 0, 0, $77, $80, 0, 0, $89, $88, 0, 0, $99, $98, $80, 0, $99, $99, $80, 0, 9, $99, $80, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, $87, 0, 0, $D, $87, 0, 0, $D, $88, 0, 0, $E, $88, 0, 0, 0, $EE, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$8D, $DD, $EE, $10, $DD, $DD, $FC, $C1, $DD, $DC, $CC, $C1, $DD, $DC, $CC, $C1, $DD, $D1, $11, $11, $DD, $EE, $EE, 0, $EE, $EE, 0, 0, 0, 0, 0, 0
	dc.b	0, $1E, $ED, $DD, 1, $CC, $FD, $DD, 1, $CC, $CC, $DD, 1, $CC, $CC, $DD, 1, $CC, $CC, $DD, 1, $CC, $CC, $DD, 0, $11, $11, $EE, 0, 0, 0, 0
	dc.b	$80, 0, 0, 0, $D7, $80, 0, 0, $D7, $8D, 0, 0, $D8, $8D, 0, 0, $D8, $8E, 0, 0, $DE, $E0, 0, 0, $E0, 0, 0, 0, 0, 0, 0, 0
byte_32FB8:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, $45, 0, 0, 0, $45, 0, 0, 4, $32, 3, $30, $33, $22, 2, $43, $33, $22
	dc.b	0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 3, 0, 0, 0, $34, 0, 0, 0, $35, 0, 0, 0, $25, 0, 0, 0, $12, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, $A, 0, 0, 0, $AB, 0, 0, 0, $BD, 0, 0, 0, $BD, 0, 0, 0, $BD, 0, 0, 0, $BD, 0, 0, 6, $DD
	dc.b	0, 0, 7, $DD, 0, 0, 8, $91, 0, 0, 8, $89, 0, 0, 9, $99, 0, 0, 0, $99, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$44, $33, $32, $22, $54, $44, $12, $22, $35, $44, $21, $21, $23, $43, $32, $33, $22, $32, $23, $34, $22, $22, $13, $45, $22, $21, $23, $55, $21, $12, $23, $55
	dc.b	$13, $33, $12, $35, $34, $43, $31, $22, $45, $43, $31, $22, $55, $43, $32, $11, $53, $32, $12, $22, $22, $21, $12, $22, $20, 1, $34, $42, 0, 4, $44, $32
	dc.b	$AA, $35, $42, $23, $BD, $44, $21, $34, $D0, $52, $13, $44, 0, $21, $23, $34, 0, 1, $22, $33, 0, 0, $12, $22, $67, 0, $12, $24, $76, $90, $21, $14
	dc.b	$97, $90, $21, 5, $97, $90, $21, 1, $79, $92, $10, 0, $99, 2, $10, 0, $90, 2, $10, 0, 8, $76, $67, 0, 9, $99, $99, 0, $88, $87, $79, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 8, $7D, 0, 0, $D8, $7D, 0, 0, $D8, $8D, 0, 0, $E8, $8D, 0, 0, $E, $ED, 0, 0, 0, $E
	dc.b	$98, $76, $68, 0, $DD, $DE, $E1, 0, $DD, $DF, $CC, $10, $DD, $CC, $CC, $10, $DD, $CC, $CC, $10, $DD, $CC, $CC, $10, $DD, $CC, $CC, $10, $EE, $11, $11, 0
byte_33118:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, $33, 0, 2, $22, $23, 0, 0, $22, $22, 0, 0, 0, $22, 0, 0, 0, 0, 0, 0, $23, $33
	dc.b	0, 0, 2, $26, 0, 0, 2, $66, 0, 0, 2, $89, 0, 0, 3, $88, 0, 0, $32, $28, $12, $44, $22, $AB, $DD, $22, $34, $AB, $3D, $D2, $22, $AB
	dc.b	0, 0, 0, 0, 3, $33, $33, 0, $33, $32, $44, $33, $33, $2A, $24, $44, $22, $BA, $A2, $44, $22, $BA, $AB, $44, $22, $6B, $AA, $44, $36, $66, $B3, $45
	dc.b	$66, $97, $64, $45, $99, $87, $24, $54, $88, $84, $44, $55, $88, $24, $44, $55, $88, $43, $44, $55, $D2, $33, $44, $45, $22, $33, $33, $44, $22, $23, $33, $34
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, $33, 0, 2, 0, $44, $32, $22, 0, $54, $43, $32, 0, $55, $44, $32, 0, $55, $54, $43, 0, $55, $55, $44, 0
	dc.b	$44, $55, $54, 0, $66, $45, $54, $30, $66, $54, $54, $50, $66, $54, $44, $50, $66, $13, $44, $17, $66, $11, $33, $18, $66, $11, $55, $19, $56, $11, $66, $10
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 0
	dc.b	0, 7, $79, $88, 0, $77, $98, $99, $77, $79, $89, $77, $76, $89, $97, $99, $67, $99, $99, $77, $76, $70, 0, 0, $99, $67, 0, 0, 0, $99, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, $10, 0, 0, $1C, $C1, 0, 1, $CC, $CC, $10, 1, $CC, $66, $61, $1C, $C6, $86, $33
	dc.b	0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, $1C, 0, 0, 0, $1C, 0, 0, 0, $1C, 0, 0, 1, $CC, 0, 0, 1, $CC
	dc.b	0, 0, 1, $DD, 0, 0, 1, $DD, 0, 0, 0, $11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$1C, $C6, $68, $23, $7C, $C6, $68, $22, $66, $C8, $86, $71, $C6, $6D, $88, $81, $CC, $7D, $11, 1, $FC, $D1, 0, 1, $CD, $D1, 0, 1, $DD, $10, 0, 1
	dc.b	$DD, 0, 0, 1, $D1, 0, 0, 0, $10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$33, $32, $22, $AB, $23, $32, $22, $2A, $22, $22, $23, $2B, $D1, $12, $33, $32, $DD, $12, $33, $3B, $DD, $12, $BB, $BA, $D1, $D, $BB, $BB, $D1, 0, $DB, $BB
	dc.b	$10, 0, $D, $DD, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$22, $22, $3B, $66, $B2, $22, $BA, $66, $B2, $22, $BA, $AA, $22, $22, $BA, $AA, $BB, $22, $BB, $AA, $AA, $D1, $2D, $BB, $AB, $D0, $11, $DD, $BD, 0, 0, 0
	dc.b	$D0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$35, $66, $6B, $18, $65, $66, $6A, $11, $66, $6A, $AA, 0, $AA, $AA, $BD, 0, $AA, $BB, $D0, 0, $BB, $DD, 0, 0, $DD, 0, 0, 0, 0, 0, 0, 0
byte_33358:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $66, 0, 0, $66, $97
	dc.b	0, 0, $98, $69, 0, 6, $69, $86, 0, 9, $86, $66, 0, 6, $69, $68, 0, 0, $96, $66, 0, 0, 0, $98, 0, 0, 0, 9, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $60, 0, 0, 0
	dc.b	$68, 6, $60, 2, $67, $86, $90, 2, $79, $66, 0, $22, $98, $69, 0, $22, $96, $89, 0, $22, $68, $97, $80, $2D, $97, $69, $90, $1D, $98, $9D, $A0, $1D
	dc.b	0, 0, 0, 3, 0, 0, 0, $35, $45, 0, 3, $45, $4A, $55, $33, $55, $4A, $A5, $34, $55, $4A, $A5, $34, $55, $4A, $AA, $44, $45, $4A, $A3, $44, $45
	dc.b	$13, $33, $44, $45, $13, $33, $64, $44, $13, $36, $66, $44, $13, $36, $66, $34, $23, $36, $69, $24, $83, $36, $69, $13, $83, $36, $69, $15, $83, $33, $69, $16
	dc.b	$30, 0, 0, 0, $53, 0, 0, 0, $54, $30, 0, $54, $55, $33, $55, $A4, $55, $43, $5A, $A4, $55, $43, $5A, $A4, $54, $44, $AA, $A4, $54, $44, $3A, $A4
	dc.b	$54, $44, $33, $31, $44, $46, $33, $31, $44, $66, $63, $31, $43, $66, $63, $31, $42, $96, $63, $32, $31, $96, $63, $38, $51, $96, $63, $38, $61, $96, $33, $38
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6
	dc.b	$20, 6, $60, $86, $20, 9, $68, $76, $22, 0, $66, $97, $22, 0, $96, $89, $22, 0, $98, $69, $D2, 8, $79, $86, $D1, 9, $96, $79, $D1, $A, $D9, $89
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $66, 0, 0, 0, $79, $66, 0, 0
	dc.b	$96, $89, 0, 0, $68, $96, $60, 0, $66, $68, $90, 0, $86, $96, $60, 0, $66, $69, 0, 0, $89, 0, 0, 0, $90, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, $BA, $AD, 0, 0, $BA, $AD, 0, 0, $B, $BA, 0, 0, 1, $EB, 0, 0, 1, $DE, 0, 0, 1, $DD, 0, 0, 1, $DD, 0, 0, 1, $DD
	dc.b	0, 0, 0, $11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$D8, $3A, $66, $A1, $D8, $3A, $AA, $A1, $AD, $3A, $AA, $AA, $BD, $DB, $AA, $AA, $E1, $D, $BB, $AA, $10, 0, $EE, $BB, $10, 0, $DB, $E1, $10, 0, $D, $BB
	dc.b	0, 0, 0, $D, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$1A, $66, $A3, $8D, $1A, $AA, $A3, $8D, $AA, $AA, $A3, $DA, $AA, $AA, $BD, $DB, $AA, $BB, $D0, $1E, $BB, $EE, 0, 1, $1E, $BD, 0, 1, $BB, $D0, 0, 1
	dc.b	$D0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$DA, $AB, 0, 0, $DA, $AB, 0, 0, $AB, $B0, 0, 0, $BE, $10, 0, 0, $ED, $10, 0, 0, $DD, $10, 0, 0, $DD, $10, 0, 0, $DD, $10, 0, 0
	dc.b	$11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
byte_335D8:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 0, 0, 9, $69, $69, $96
	dc.b	9, $96, $96, $96, $97, $79, $66, $66, 9, $97, $76, $67, $97, $77, $76, $66, 9, $98, $77, $87, 0, 0, $98, $86, 0, 0, 0, $98, 0, 0, 0, 9
	dc.b	0, 0, 0, 8, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $44, $A, $54, $33, $45, 0, $A5, $34, $55, 0, $A5, $45, $55, 0, $AB, $55, $45, 0, $BB, $44, $44
	dc.b	0, $44, $44, $55, 4, $54, $44, $44, 5, $65, $44, $44, $65, $65, $44, $44, $66, $55, $44, $44, $B4, $45, $44, $44, $DA, $A4, $44, $33, $B, $BA, $33, $33
	dc.b	$1D, $DB, $AA, $AA, $1D, $DB, $AA, $AA, $D, $BD, $BB, $BB, 0, $DB, $22, $22, 0, $D, $BB, $22, 0, 0, $DD, $D2, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 4, $44, $44, $44, $45, $55, $55, $55, $54, $44, $44, $54, $44, $22, $22, $44, $22, $22, $22, $42, $22, $22, $22, $22, $22, $22, $22, $55, $52, $23, $32
	dc.b	$55, $55, $22, $33, $45, $55, $51, $CC, $44, $44, $1C, $CC, $44, $44, $1C, $CC, $44, $33, $1C, $DD, $33, $32, $1D, $DD, $32, $22, $1D, $DD, $22, $22, $1D, $DD
	dc.b	$22, $24, $1D, $DD, $22, $24, $1D, $DD, $AB, $B4, $41, $DD, $BB, $B2, $41, $DD, $22, $24, $B1, $DD, $22, $22, $AB, $1D, 0, $D, $BB, $1D, 0, 0, $DB, $1D
	dc.b	0, 0, 0, 0, $44, $40, 0, 0, $44, $44, $40, 0, $22, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $20, 0, 0, 0
	dc.b	$34, $40, 0, 0, $42, $33, 0, 0, $C4, $22, $30, 0, $C3, $22, $23, 0, $C2, $20, 0, 0, $CC, $20, 0, 7, $DC, $12, 0, $77, $DC, $10, 2, $77
	dc.b	$DC, $12, $22, $27, $DC, $12, $22, $27, $DD, $C1, $20, 0, $DD, $C1, 0, 0, $DD, $C1, 0, 0, $DD, $C1, 0, 0, $DD, $C1, 0, 0, $DD, $C1, 0, 0
	dc.b	0, 0, 0, 0, 1, $10, 0, 0, $1D, $D1, 0, 0, $1D, $D1, 0, 0, $1D, $DD, $10, 0, $1D, $DD, $10, 0, $1D, $DD, $10, 0, $D1, $DD, $10, 0
	dc.b	$D1, $DD, $10, 0, $D1, $DD, $D1, 0, $D1, $DD, $D1, 0, $DD, $1D, $D1, 0, $D, $1D, $D1, 0, $D, $1D, $D1, 0, $D, $1D, $D1, 0, 0, $1D, $D1, 0
	dc.b	0, 0, 0, $D1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$DD, $C1, 0, 0, $1D, $C1, 0, 0, 1, $10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 1, $10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
byte_337F8:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $77, 0, 0, $77, $97
	dc.b	0, 0, $98, $79, 0, 8, $89, $77, 0, 9, $88, $77, 0, 8, $89, $87, 0, 0, $98, $88, 0, 0, 0, $98, 0, 0, 0, 9, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $70, 0, 0, 3
	dc.b	$78, 7, $70, 3, $77, $87, $90, $31, $77, $77, 0, $1C, $77, $79, 0, $1C, $77, $89, 1, $CD, $88, $98, $81, $CD, $98, $79, $91, $DD, $98, $9D, $1D, $DD
	dc.b	0, 0, 0, 3, 0, 0, 0, $35, $45, 0, 3, $45, $34, $55, $33, $52, $33, $45, $34, $22, $33, $45, $34, $22, $33, $22, $32, $22, $31, $12, $22, $22
	dc.b	$1C, $D1, $22, $23, $CC, $CC, $12, $34, $DD, $CC, $12, $34, $DD, $DC, $14, $25, $DD, $DC, $13, $32, $DD, $DD, $13, $32, $DD, $DD, $13, $23, $DD, $D1, $22, $34
	dc.b	$30, 0, 0, 0, $53, 0, 0, 0, $54, $30, 0, $54, $25, $33, $55, $43, $22, $43, $54, $33, $22, $43, $54, $33, $22, $23, $22, $33, $22, $22, $21, $13
	dc.b	$32, $22, $1D, $C1, $43, $21, $CC, $CC, $43, $21, $CC, $DD, $52, $41, $CD, $DD, $23, $31, $CD, $DD, $23, $31, $DD, $DD, $32, $31, $DD, $DD, $43, $22, $1D, $DD
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $30, 0, 0, 7
	dc.b	$30, 7, $70, $87, $13, 9, $78, $77, $C1, 0, $77, $77, $C1, 0, $97, $77, $DC, $10, $98, $77, $DC, $18, $89, $88, $DD, $19, $97, $89, $DD, $D1, $D9, $89
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $77, 0, 0, 0, $79, $77, 0, 0
	dc.b	$97, $89, 0, 0, $77, $98, $80, 0, $77, $88, $90, 0, $78, $98, $80, 0, $88, $89, 0, 0, $89, 0, 0, 0, $90, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, $1D, $DD, 0, 0, $1D, $DD, 0, 0, $1D, $DD, 0, 0, $1D, $DD, 0, 0, $1D, $DD, 0, 0, $1D, $DD, 0, 0, $1D, $DD, 0, 0, $1D, $DD
	dc.b	0, 0, 1, $DD, 0, 0, 1, $DD, 0, 0, 0, $11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$DD, $D1, $23, $22, $DD, $D1, $22, $22, $DD, $12, $22, $22, $DD, $12, $22, $22, $DD, $1D, $22, $22, $DD, $1D, $DB, $BB, $D1, 0, $DB, $BB, $D1, 0, $D, $BB
	dc.b	$D1, 0, 0, $DD, $10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$22, $32, $1D, $DD, $22, $22, $1D, $DD, $22, $22, $21, $DD, $22, $22, $21, $DD, $22, $22, $D1, $DD, $BB, $BD, $D1, $DD, $BB, $BD, 0, $1D, $BB, $D0, 0, $1D
	dc.b	$DD, 0, 0, $1D, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$DD, $D1, 0, 0, $DD, $D1, 0, 0, $DD, $D1, 0, 0, $DD, $D1, 0, 0, $DD, $D1, 0, 0, $DD, $D1, 0, 0, $DD, $D1, 0, 0, $DD, $D1, 0, 0
	dc.b	$DD, $10, 0, 0, $DD, $10, 0, 0, $11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
byte_33A78:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $40, 0, 0, 4, $54, 0, 0, 4, $54, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $87
	dc.b	0, 0, 8, $77, 0, 0, 8, $77, 0, 0, $88, $77, 0, 0, $88, $87, 0, 0, 8, $88, 0, 0, 0, $88, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, $33, 0, 0, 0, $24, 0, 0, 4, $43, 0, 0, $55, $44, 0, 0, $23, $54, 0, 0, $22, $34, 0, $70, $22, $23
	dc.b	$70, $70, $22, $22, $77, $70, 2, $22, $77, $80, 2, $11, $76, $67, 1, $33, $67, $97, $33, $44, $79, $D9, $34, $54, $79, $B3, $45, $54, 0, 3, $55, $33
	dc.b	0, $43, $23, $40, 3, $32, $22, $33, $33, $32, $22, $33, $33, $22, $22, $23, $41, $22, $22, $21, $42, $12, $12, $12, $33, $23, $33, $23, $22, $33, $43, $32
	dc.b	$21, $34, $54, $31, $12, $35, $55, $32, $22, $35, $55, $32, $31, $23, $53, $21, $33, $12, $22, $13, $33, $12, $22, $13, $33, $21, $11, $23, $21, $22, $22, $21
	dc.b	0, 0, 0, 0, 3, $30, 0, 0, $34, $20, 0, 0, $33, $44, 0, 0, $44, $45, $50, 0, $44, $53, $20, 0, $34, $32, $20, 0, $23, $22, $20, 0
	dc.b	$22, $22, $20, 0, $12, $22, 0, 0, $21, $12, 0, 0, $33, $31, 0, 0, $34, $43, $30, 0, $34, $54, $30, 0, $34, $55, $43, 0, $23, $35, $53, 0
	dc.b	0, 2, $43, $22, 0, 0, $22, $BD, 0, 0, 0, $B, 0, 0, 0, 3, 0, 0, 0, $34, 0, 0, 0, $34, 0, 0, 0, $22, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $E, 0, 0, 0, $E, 0, 0, 0, $EE
	dc.b	$11, $22, $22, $21, $13, $32, $23, $32, $33, $32, $23, $33, $43, $23, $32, $33, $42, $13, $33, $23, $21, $23, $33, $21, $12, $22, $32, $21, $12, $22, $22, $22
	dc.b	$21, $22, $22, $22, $21, $22, $42, $21, 2, $11, $42, $11, 2, $15, $10, $E, $E2, $11, 0, $D, $E2, $1E, $E0, $D, $92, $19, $E0, $E, $72, $18, $E0, 1
	dc.b	$12, $23, $42, 0, $1B, 2, $20, 0, $2D, $B0, 0, 0, $4E, $BA, 0, 7, $44, $ED, $AA, $69, $44, $11, $D6, $87, $24, $EE, $17, $98, $19, $9E, $E1, $88
	dc.b	$19, $99, $E1, 9, $11, $99, $91, 0, $11, $9D, $91, 0, $98, $9D, $E1, 0, $99, $9D, $10, 0, $DD, $DE, $10, 0, $DD, $D1, 0, 0, $EE, $E1, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $80, $76, $77, 0, $77, $67, $99, 0, $76, $67, $77, $80, $77, $77, $79, $90, $87, $79, $77, 0
	dc.b	$87, $97, $99, 0, $98, $79, $70, 0, 9, $79, 0, 0, 0, $90, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, $E9, 0, 0, 0, $9E, 0, 0, 0, $9E, 0, 0, 0, $EE, 0, 0, 0, $ED, 0, 0, 0, $ED, 0, 0, 0, $1D, 0, 0, 0, 1
	dc.b	$87, $78, $E0, 0, $99, $99, $90, 0, $87, $78, $90, 0, $DC, $CE, $E0, 0, $DC, $CD, $E0, 0, $DD, $DD, $E0, 0, $DD, $DD, $10, 0, $11, $11, 0, 0
	dc.b	$11, $10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
byte_33CF8:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $40, 0, 0, 4, $54, 0, 0, $44, $54, $40, 0, $44, $24, $40
	dc.b	0, 0, 0, 0, 0, 0, 0, $33, 0, 0, 0, $24, 0, 5, $54, $43, 0, 2, $44, $44, 0, 2, $22, $44, 0, 0, $22, $24, 0, 0, $22, $23
	dc.b	4, $42, $22, $44, 3, $32, $22, $33, $33, $22, $22, $23, $33, $22, $22, $23, $41, $22, $22, $21, $42, $12, $12, $12, $33, $23, $43, $23, $22, $34, $54, $32
	dc.b	0, 0, 0, 0, 3, $30, 0, 0, $34, $20, 0, 0, $33, $44, $55, 0, $44, $44, $42, 0, $44, $42, $22, 0, $34, $22, $20, 0, $23, $22, $20, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $77, $77, $80, 7, $77, $77, $77
	dc.b	7, $77, $77, $77, 8, $77, $77, $77, 9, $99, $97, $79, 0, 0, 9, $99, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 2, $22, 0, 0, 2, $22, 0, 0, 2, $11, 0, 0, 1, $33, 0, 0, $34, $44, 0, 3, $45, $54, 0, 4, $54, $43, 0, $35, $43, $32
	dc.b	$77, $22, $22, $22, $79, $A0, 0, $B, $79, $BA, $AA, $B4, $90, $B, $BB, $44, 0, 0, 0, $52, 0, 0, 0, $2E, 0, 0, 0, $ED, 0, 0, $E, $DD
	dc.b	$21, $35, $55, $31, $12, $35, $55, $32, $22, $23, $53, $22, $31, $22, $22, $21, $33, $12, $22, $13, $33, $11, $21, $13, $33, $21, $11, $23, $21, $22, $22, $21
	dc.b	$11, $22, $22, $21, $33, $33, $23, $33, $33, $33, $23, $33, $32, $22, $32, $22, $22, $13, $33, $12, $21, $23, $33, $21, $12, $22, $32, $22, $12, $22, $22, $22
	dc.b	$22, $22, 0, 0, $12, $22, 0, 0, $21, $12, 0, 0, $33, $31, 0, 0, $34, $44, $30, 0, $34, $55, $43, 0, $33, $44, $54, 0, $22, $33, $45, $30
	dc.b	$12, $22, $22, $27, $3B, 0, 0, $A9, $34, $BA, $AA, $B9, $34, $4B, $BB, 0, $22, $50, 0, 0, $2E, $20, 0, 0, $1D, $E0, 0, 0, $1D, $DE, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $87, $77, $70, 7, $77, $77, $77
	dc.b	$77, $77, $77, $77, $77, $77, $77, $78, $79, $77, $99, $99, $99, $99, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, $E, $DD, 0, 0, 1, $DD, 0, 0, 1, $DD, 0, 0, 1, $79, 0, 0, 1, $79, 0, 0, 1, $87, 0, 0, 1, $D9, 0, 0, 1, $ED
	dc.b	0, 0, 0, $1E, 0, 0, 0, $E, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$21, $22, $32, $21, $21, $22, $32, $21, $21, $11, $41, $11, $21, $71, $51, $71, $21, $71, $11, $71, $77, $81, 1, $87, $88, $91, 1, $98, $99, $D1, 1, $D9
	dc.b	$DD, $E1, 1, $ED, $EE, $10, 0, $1E, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$2D, $D1, 0, 0, $2D, $D1, 0, 0, $2D, $D1, 0, 0, $29, $71, 0, 0, $29, $71, 0, 0, $77, $81, 0, 0, $89, $D1, 0, 0, $9D, $E1, 0, 0
	dc.b	$DE, $10, 0, 0, $EE, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
byte_33F78:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, $34
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $40, 0, 0, 0, $54, 0, 0, 0, $54, $30, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, $88, 0, 0, 8, $77, 0, 0, 7, $77, 0, 0, 7, $77, 0, 0, 8, $77, 0, 0, 8, $87, 0, 0, 0, $97
	dc.b	0, 0, 0, $9D, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 3
	dc.b	0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, $33, 3, $33, $80, $24, $33, $32, $77, $43, $33, $22, $74, $44, $41, $22, $35, $44, $42, $12, $54, $34, $33, $23, $22, $33, $22, $33, $22, $23, $21, $34
	dc.b	2, $22, $12, $34, 2, $11, $22, $35, 1, $33, $31, $23, 3, $44, $33, $13, $34, $54, $33, $12, $45, $54, $33, $21, $55, $33, $21, $22, $53, $32, $11, $22
	dc.b	$53, $2D, $13, $32, $22, $B, $33, $22, 0, 3, $33, $23, 0, 4, $32, $33, 0, $34, $22, $23, 0, $42, $22, $22, 0, $22, $22, $22, 0, 0, $21, $22
	dc.b	$43, $33, 3, $30, $22, $33, $34, $20, $22, $23, $33, $40, $22, $21, $44, $44, $12, $12, $44, $45, $33, $23, $34, $34, $43, $32, $23, $32, $44, $31, $23, $22
	dc.b	$54, $32, $12, $22, $55, $32, $21, $12, $53, $21, $33, $31, $53, $13, $34, $43, $22, $13, $34, $54, $11, $23, $34, $55, $22, $21, $23, $35, $22, $21, $12, $33
	dc.b	$33, $32, $1B, $23, $33, $33, $1D, $D2, $32, $34, $2B, $DD, $33, $35, $4B, $AD, $32, $14, $5B, $AD, $22, $24, $2D, $BA, $22, $22, $2D, $BA, $22, $21, $2D, $DB
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $30, 0, 0, 0, $50, 0, 0, 0, $20, 0, 0, 0, $20, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $30, 0, 0, 0, $40, 0, 0, 0, $53, 0, 0, 0, $53, 0, 0, 0
	dc.b	$52, 0, 0, 0, $22, 0, 0, 0, $E0, 0, 0, 0, $E0, 0, 0, 0, $E0, 0, 0, 0, $E0, 0, 0, 0, $E0, 0, 0, 0, $A0, 0, 0, 0
	dc.b	0, 0, $21, $24, 0, 2, $10, $41, 0, 2, $15, $10, 0, 2, $11, 0, 0, 0, $21, 0, 0, 8, $76, $67, 0, 9, $99, $99, 0, $88, $87, $79
	dc.b	$12, $21, $DD, $EB, $11, $10, $EE, 7, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$66, $70, 0, 0, $88, $66, $60, 0, $87, $66, $67, $70, $77, $66, $88, $87, $87, $76, $78, 0, $87, $76, $67, 0, 8, $77, $67, 0, 8, $77, $77, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $D, 0, 0, 0, $DD, 0, 0, 0, $ED, 0, 0, 0, $EE, 0, 0, 0, $E, 0, 0, 0, 0
	dc.b	0, $98, $76, $68, 8, $DD, $DE, $E1, $7D, $DD, $DF, $CC, $7D, $DD, $CC, $CC, $8D, $DD, $CC, $CC, $8D, $DD, $CC, $CC, $ED, $DE, $E1, $11, $E, $EE, $EE, $E0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, $10, 0, 0, 0, $10, 0, 0, 0, $10, 0, 0, 0, $10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	8, $77, $70, 0, 0, $80, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
byte_34218:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $33, 0, 0, $33, $44
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 0, 0, 7, $97, 0, 7, $97, $97, 0, 0, $78, $77
	dc.b	0, $70, $78, $76, 0, 7, $87, $77, 0, 8, $77, $77, 0, 0, $88, $77, 0, 0, 8, $88, 0, 0, 0, $88, 0, 0, 0, 9, 0, 0, 0, 9
	dc.b	0, 0, 0, 5, 0, 0, 0, 4, 0, 0, 0, 3, 0, 0, 0, 3, 0, 0, 0, $D2, 0, 0, $D, $D3, 0, $60, $D, $D3, $80, $60, $DD, $D3
	dc.b	$66, $80, $DD, $D4, $76, $80, $DD, $D4, $78, 0, $DD, $D4, $77, 0, $DD, $D5, $88, $90, $98, $D5, $87, $90, $98, $D2, $69, $A0, $9D, $DB, $90, $BA, $AA, $B0
	dc.b	$44, $33, $34, $55, $54, $43, $44, $55, $45, $43, $34, $55, $34, $43, $23, $45, $33, $34, $23, $45, $24, $55, $13, $45, $25, $54, $32, $45, $45, $54, $21, $35
	dc.b	$45, $43, $22, $25, $54, $32, $22, $32, $54, $22, $23, $31, $43, $22, $23, $45, $32, $12, $23, $55, $21, $34, $23, $45, $34, $54, $22, $45, $45, $43, $22, $44
	dc.b	0, $B, $BB, $D4, 0, 0, $E, $D4, 0, 0, $E, $D4, 0, 0, 0, $E4, 0, 0, 0, $E4, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$55, $43, $22, $44, $54, $33, $22, $24, $43, $32, $22, $24, $43, $21, $23, $21, $32, 2, $33, $22, $20, 2, $33, $22, 0, 2, $32, $23, 0, 2, $42, $23
	dc.b	0, 0, $20, $22, 0, 0, 0, 2, 0, 0, 0, 3, 0, 0, 0, 4, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
byte_34358:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $DD, 0, 0, $D, $CC, 0, 0, $D, $CC, 0, 0, $D, $CC, 0, 0, $D, $CC, 0, 0, $D, $CC
	dc.b	0, 0, $D, $CC, 0, 0, $D, $CC, 0, 0, $D, $CC, 0, 0, $D, $87, 0, 0, $D, $77, 0, 0, $D, $DC, 0, 0, 0, $DC, 0, 0, 0, $DD
	dc.b	0, 0, 0, $D5, 0, 0, 0, $D4, 0, 0, 0, $D3, 0, 0, 0, 3, 0, 0, 0, 2, 0, 0, 0, 3, 0, 0, 0, 3, 0, 0, 0, 3
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $D0, 0, 0, 0, $DD, 0, 0, 0, $CD, 0, 0, 0, $CD, 0, 0, 0, $CD, $D0, 0, 0
	dc.b	$CC, $D0, 0, 0, $CC, $D0, 0, 0, $67, $7D, 0, 0, $66, $87, 0, 0, $CC, $CD, 0, 0, $CC, $CD, 0, 0, $CC, $CD, 0, $33, $88, $9D, $33, $44
	dc.b	$44, $33, $34, $55, $54, $43, $44, $55, $45, $43, $34, $55, $34, $43, $23, $45, $33, $34, $23, $45, $24, $55, $13, $45, $25, $54, $32, $45, $45, $54, $21, $35
	dc.b	0, 0, 0, 0, 0, 0, $70, 0, 0, $78, $60, 0, 0, $78, $67, 6, 7, $87, $86, $76, 8, $77, $77, $66, $88, $87, $77, $77, 8, $87, $77, $76
	dc.b	0, $88, $88, $69, 0, 0, $88, $89, 0, 0, 0, $99, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 4, 0, 0, 0, 4, 0, 0, 0, 4, 0, 0, 0, 5, 0, 0, 0, 5, 0, 0, 0, 2, 0, 0, 0, $B, $60, 0, 0, $AD
	dc.b	$A0, 0, $AA, $D4, $BA, $AA, $BD, 4, $B, $BB, 0, 4, 0, 0, 0, 4, 0, 0, 0, 4, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$45, $43, $22, $25, $54, $32, $22, $32, $54, $22, $23, $31, $43, $22, $23, $45, $32, $12, $23, $55, $21, $34, $23, $45, $34, $54, $22, $45, $45, $43, $22, $44
	dc.b	$55, $43, $22, $44, $54, $33, $22, $24, $43, $32, $22, $24, $43, $21, $23, $21, $32, 2, $32, $22, $20, 2, $32, $22, 0, 0, $20, $23, 0, 0, 0, 2
byte_344D8:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $D, $D0, 0, 0, $DC, $CD, 0, 0, $DC, $CD, 0, 0, $DC, $CC, 0, 0, $DC, $CC
	dc.b	0, 0, $DC, $CC, 0, 0, $DC, $CC, 0, 0, $DC, $CC, 0, 0, $DC, $C6, 0, 0, $D8, $76, 0, 0, $D7, $7C, 0, 0, $DC, $CC, 0, 0, $D, $C5
	dc.b	0, 0, $D, $C4, 0, 0, $D, $C4, 0, 0, 0, $D3, 0, 0, 0, $D3, 0, 0, 0, 2, 0, 0, 0, 3, 0, 0, 0, 3, 0, 0, 0, 3
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $D0, 0, 0, 0, $D0, 0, 0, 0, $D0, 0, 0, 0
	dc.b	$DD, 0, 0, 0, $CD, 0, 0, 0, $CD, 0, 0, 0, $77, $D0, 0, 0, $68, $70, 0, 0, $CC, $D0, 0, 0, $CC, $D0, 0, $33, $48, $90, $33, $44
	dc.b	$54, $33, $34, $55, $54, $43, $44, $55, $45, $42, $34, $55, $34, $43, $23, $45, $33, $34, $23, $45, $24, $55, $12, $45, $25, $54, $32, $35, $45, $54, $21, $25
	dc.b	0, 0, 0, 0, 0, 0, $70, 0, 0, $78, $67, 7, 0, $87, $76, $76, 7, $77, $77, $66, 7, $87, $77, $77, 8, $77, $77, $76, 0, $88, $77, $69
	dc.b	0, 0, $88, $69, 0, 0, 0, $99, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 4, 0, 0, 0, 4, 0, 0, 0, 4, 0, 0, 0, 5, 0, 0, 0, 2, 0, 0, 0, 0, $60, 0, 0, $B, $9A, 0, $A, $AD
	dc.b	$BA, $AA, $AB, $D4, $B, $BB, $B0, 4, 0, 0, 0, 5, 0, 0, 0, 4, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$45, $43, $22, $22, $54, $32, $22, $31, $54, $22, $23, $34, $42, $22, $23, $45, $21, $32, $23, $55, $13, $54, $23, $45, $35, $44, $22, $44, $45, $43, $22, $44
	dc.b	$54, $43, $22, $24, $54, $33, $22, $24, $43, $32, $22, $21, $42, $21, $23, $22, $20, 2, $32, $22, 0, 2, $32, $22, 0, 0, $20, $23, 0, 0, 0, 2
byte_34658:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, $44, 0, 0, $45, $55, 0, 2, $22, $43, 0, 0, 2, $22, 0, 0, 0, $32, 0, 0, $33, $33
	dc.b	0, 3, $44, $32, 0, $44, $32, $23, 4, $32, $23, $34, $32, $22, $34, $44, $22, 3, $44, $43, 0, 4, $44, $33, 0, $34, $43, $32, 3, $44, $33, $22
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, $55, $54, $43, 0, $44, $45, $54, $33, $34, $44, $45, $44, $23, $33, $34, $54, $22, $23, $33, $44, $12, $22, $23, $34
	dc.b	$12, $22, $33, $45, $42, $24, $45, $55, $32, $44, $55, $44, $23, $45, $44, $44, $34, $54, $43, $33, $45, $43, $22, $23, $44, $22, $23, $33, $21, $22, $33, $33
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $30, 0, 0, 0, $43, 0, 0, 0, $43, $30, 0, 0, $44, $33, 0, 0, $44, $44, $44, $40
	dc.b	$54, $44, $44, $55, $55, $44, $45, $44, $55, $44, $43, $33, $45, $44, $44, $30, $44, $44, $44, 0, $33, $44, $44, 0, $33, $34, $45, 0, $33, $33, $35, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 3, 0, 0, 0, 3, 0, 0, 0, $82, 0, 0, 0, $87, 0, 0, 0, $99
	dc.b	0, 0, 0, $99, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, $D, 0, 0, 0, $D, 0, 0, 0, $DE, 0, 0, 0, $E1, 0, 0, $E, $11, 0, 0, $E, $11, 0, 0, $E1, $11, 0, 0, $E1, $11
	dc.b	$34, $53, $22, $22, $43, $22, $22, $22, $33, $22, $22, $22, $32, $21, $11, $12, $22, $22, $22, $23, $27, $80, $22, $24, $9D, $80, $11, $24, $DB, $BB, $D4, $43
	dc.b	$9D, $D3, $43, $42, $90, $34, $52, $22, 0, $35, $21, $23, 2, $33, $11, $33, 2, $31, $23, $33, 0, $20, $12, $33, 0, 0, $12, $22, $CC, $CC, $C2, $24
	dc.b	$DC, $FC, $CD, $14, $EE, $EE, $ED, $41, $11, $11, $ED, $5E, $11, $11, $1D, $1E, $11, $11, $10, $E, $11, $11, $10, 1, $11, $11, 0, 0, $11, $1E, 0, 0
	dc.b	$22, $23, $34, $43, $23, $44, $44, $33, $23, $45, $43, $33, $34, $54, $32, $23, $44, $33, $22, $2D, $43, $22, $22, $DB, $31, $22, $22, $DB, $23, $33, $22, $DB
	dc.b	$33, $33, $32, $20, $22, $44, $DD, 0, $42, $34, $DB, 0, $42, $23, $4B, $A0, $31, $12, $41, $DA, $21, $22, $4E, $16, $22, $12, $2E, $E7, $22, $19, $9E, $E1
	dc.b	$11, $11, $99, $E1, $11, $19, $99, $E1, $E9, $89, $D9, $10, $D9, $99, $DE, $10, $DD, $DD, $E1, 0, $DD, $DE, $10, 0, $EE, $E1, 0, 0, $11, $10, 0, 0
	dc.b	$33, $34, $70, 0, $33, $37, $50, 0, $33, $35, 0, 0, $33, $50, 0, 0, $BA, $A0, 0, 0, $AB, $B0, 0, 0, $BB, 0, 0, 0, $B0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $A0, $78, 0, 0, $89, $98, $78, 0, $98, $76, $67, $80, $98, $77, $67, $80
	dc.b	$89, $88, $88, $80, $99, $88, $88, $90, 9, $99, $90, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, $E, $11, $11, 0, $E, $11, $11, 0, 1, $11, $11, 0, 1, $11, $11, 0, 1, $11, $11, 0, 0, $11, $10, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$11, $10, 0, 0, $11, $E0, 0, 0, $11, 0, 0, 0, $10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
byte_348D8:
	dc.b	0, 0, 0, 0, 0, 0, $44, $55, 0, 0, $22, $34, 0, 0, 0, $22, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 3, $43, 0, 3, $44, $33
	dc.b	0, $44, $33, $32, 4, $33, $22, $23, $33, $22, $24, $44, $22, $22, $44, $44, 0, 4, $44, $33, 0, $34, $43, $32, 0, $44, $32, $22, 3, $53, $22, $22
	dc.b	0, 0, 0, 0, $55, $44, $43, 0, $44, $55, $44, $33, $33, $44, $55, $44, $22, $33, $34, $54, $22, $23, $33, $44, $12, $22, $33, $34, $12, $22, $23, $44
	dc.b	$22, $22, $44, $45, $42, $34, $55, $55, $43, $45, $54, $44, $43, $54, $43, $33, $35, $43, $33, $33, $33, $32, $22, $23, $21, $22, $33, $33, $22, $23, $44, $43
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, $30, 0, 0, 0, $43, 0, 0, 0, $43, $30, 0, 0, $44, $43, 0, 0, $44, $44, $43, 0, $44, $44, $44, $45
	dc.b	$54, $44, $45, $54, $55, $44, $44, $43, $55, $44, $43, $33, $45, $44, $44, $30, $34, $44, $44, 0, $33, $44, $34, 0, $33, $34, $45, 0, $33, $33, $35, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, $77, $72, 0, 7, $77, $78, 0, 8, $87, $77, 0, 8, $98, $9B, 0, 9, $99, $DD
	dc.b	0, 0, $99, $99, 0, 0, 9, $90, 0, 0, 0, $E, 0, 0, 0, $E1, 0, 0, $E, $11, 0, 0, $E1, $11, 0, $E, $11, $11, 0, $E1, $11, $11
	dc.b	0, $E1, $11, $11, $E, $11, $11, $11, $E, $11, $11, $11, $E, $11, $11, $1E, $E, $11, $1E, $E0, 0, $EE, $E0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$33, $22, $22, $22, $33, $11, $12, $22, $32, $22, $21, $12, $22, $22, $22, $23, 0, 0, $22, $24, 0, 0, 2, $25, $BB, $AA, $13, $33, $DD, $DD, $44, $44
	dc.b	0, 4, $54, $42, $E, $EE, $42, $22, $E1, $11, $E2, $24, $11, $11, $E2, $33, $11, $11, $E2, $33, $11, $11, $E2, $23, $11, $11, $E2, $22, $11, $1E, $11, $24
	dc.b	$11, $E0, 1, $41, $1E, 0, 0, $40, $E0, 0, 0, $15, 0, 0, 0, 1, 0, 0, $E, $E1, 0, 0, $EE, $12, 0, 0, $E7, $12, 0, $E, $81, $12
	dc.b	$23, $34, $54, $43, $34, $45, $43, $33, $34, $44, $33, $33, $44, $33, $22, $23, $44, $22, $22, $2D, $12, $22, $22, $DB, $12, $22, $22, $DB, $32, $33, $12, $DD
	dc.b	$22, $44, $42, $20, $42, $4B, $A0, 0, $42, $2D, $B0, 7, $44, $22, $DA, $B7, $33, $32, $2D, $D8, $22, $12, 0, $98, $22, $21, 0, 9, $22, $10, 0, 0
	dc.b	$11, 0, 0, 0, $12, 0, 0, 0, $12, 0, 0, 0, $20, 0, 0, 0, $20, 0, 0, 0, $E0, 0, 0, 0, $EE, 0, 0, 0, $7E, 0, 0, 0
	dc.b	$33, $34, $70, 0, $33, $37, $50, 0, $33, $35, 0, 0, $33, $50, 0, 0, $BA, $A0, 0, 0, $AB, $B0, 0, 0, $B0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, $70, 0, 0, 0, $99, $87, $70, 0, $98, $76, $67, 0, $97, $77, $66, $70, $98, $88, $76, $70, $99, $88, $78, $90, $90, $99, $99, 0
	dc.b	0, 0, $90, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, $E, $87, $78, 0, $E, $99, $98, 0, $E9, $87, $79, 0, $EE, $CC, $D8, 0, $ED, $CC, $DE, 0, $1D, $DD, $DD, 0, $D, $DD, $DE, 0, 1, $11, $11
	dc.b	$9E, 0, 0, 0, $9E, 0, 0, 0, $EE, 0, 0, 0, $EE, 0, 0, 0, $EE, 0, 0, 0, $E0, 0, 0, 0, $E0, 0, 0, 0, 0, 0, 0, 0
byte_34B58:
	dc.b	0, 0, 0, 3, 0, 0, 2, $45, 0, 0, 0, $22, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $33, $43, 0, $34, $44, $33
	dc.b	$44, $44, $30, 0, $54, $55, $44, $30, $23, $44, $55, $33, $22, $33, $44, $54, $22, $23, $34, $45, $22, $22, $33, $45, $12, $22, $23, $34, $12, $22, $24, $44
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, $30, 0, 0, 0, $43, 0, 0, 0, $43, $30, 0, 0, $44, $43, 0, 0, $44, $44, $43, 0, $44, $44, $44, $55
	dc.b	0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 3, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 7, $77, $70, 0, $77, $67, $79, $8B, $76, $66, $67, $6D, $87, $77, $89, $70
	dc.b	$98, $98, $89, $8E, 9, $89, $9E, $DD, 0, $99, $E1, $1C, 0, $E, $11, $1E, 0, 1, $11, $11, 0, 1, $11, $11, 0, 1, $11, $11, 0, 1, $11, $11
	dc.b	$34, $33, $33, $22, $33, $32, $22, $23, $22, $22, $24, $44, 0, $22, $44, $44, 0, 4, $44, $32, 0, $54, $43, $32, 5, $43, $32, $22, $32, $22, $22, $22
	dc.b	$31, $11, $22, $22, $22, $22, $11, $22, 0, $22, $22, $13, 0, 0, $22, $35, 0, 0, $22, $22, $AA, $BB, 0, $12, $DD, $DD, $D1, $34, $87, $9D, $14, $45
	dc.b	$EE, $61, $43, $44, $CC, $71, $32, $22, $CF, $D8, $21, $12, $CC, $DD, 1, $22, $EC, $D0, 2, $23, $ED, $D0, 1, $22, $1D, $E0, 1, $22, $EE, 0, 0, $13
	dc.b	$22, $44, $44, $45, $44, $45, $55, $55, $45, $55, $44, $44, $44, $44, $33, $33, $43, $33, $33, $33, $22, $12, $22, $23, $21, $22, $33, $33, $22, $23, $45, $43
	dc.b	$23, $34, $54, $43, $34, $44, $33, $33, $44, $33, $22, $33, $43, $22, $22, $23, $22, $22, $22, $2D, $22, $22, $22, $DB, $44, $22, $2D, $BB, $34, $32, $2D, $DD
	dc.b	$22, $32, $44, $31, $23, $23, $44, $3B, $33, $22, $35, $3D, $34, $42, $25, $53, $34, $43, $13, $53, $33, $32, $14, $30, $23, $22, $13, $20, $22, $21, 2, 0
	dc.b	$54, $44, $45, $43, $55, $44, $44, $33, $55, $44, $43, $30, $45, $44, $44, $30, $34, $44, $44, 0, $33, $44, $34, 0, $33, $34, $45, 0, $33, $33, $35, 0
	dc.b	$33, $34, $70, 0, $33, $37, $50, 0, $33, $35, 0, 0, $33, $50, 0, 0, $BA, $A0, 0, 0, $AB, $B0, 0, 0, $B8, $77, 0, 0, $77, $77, $80, 0
	dc.b	$78, $77, $78, 0, $B9, $B7, $98, 0, $DB, $D8, $90, 0, $D, $99, $90, 0, 9, $99, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, $11, $11, 0, 0, 1, $1E, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, $E, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$E0, 0, 0, $13, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, $21, 0, 0, $76, $67, 0, $98, $99, $98
	dc.b	0, $86, $78, $89, 1, $DD, $67, $88, $1C, $CC, $DD, $D9, $CC, $CC, $FD, $EE, $DC, $CC, $CD, $DD, $1E, $DC, $DD, $DD, $E1, $1E, $EE, $ED, 0, $E1, $11, $11
	dc.b	$12, $11, 0, 0, $35, $10, 0, 0, $11, $10, 0, 0, $21, 0, 0, 0, $10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $80, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $10, 0, 0, 0, $E1, 0, 0, 0, $D1, 0, 0, 0, $E1, 0, 0, 0, $10, 0, 0, 0
byte_34DF8:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $34, $45, 0, 4, $55, $54, 0, $22, $24, $33, 0, 0, $22, $22, 0, 0, 3, $22, 0, 3, $33, $31
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, $55, $44, $30, 0, $44, $55, $43, $33, $44, $44, $54, $44, $33, $33, $45, $44, $22, $33, $34, $44, $22, $22, $33, $44
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $30, 0, 0, 0, $33, 0, 0, 0, $43, $30, 0, 0, $44, $44, $44, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 3, 0, 0, 0, 4, 0, 0, 0, $33, 0, 0, 0, $33, 0, 0, 0, $32, 0, 0, 0, $22, 7, $77, 0, 0, $87, $67, $89, $70
	dc.b	$88, $66, $78, $7B, $98, $87, $78, $6D, $98, $88, $89, $9E, 9, $89, $90, $1E, 0, $99, 0, $1E, 0, 0, 0, $19, 0, 0, 0, $19, 0, 0, 0, $1D
	dc.b	0, $34, $43, $21, 4, $43, $22, $34, $43, $22, $33, $43, $22, $23, $44, $42, $20, $34, $44, $33, 0, $44, $43, $34, 3, $44, $33, $24, $34, $43, $32, $22
	dc.b	$45, $32, $22, $22, $32, $22, $22, $22, $32, $22, $22, $22, $22, $11, $11, $23, $22, $22, $22, $34, 0, 2, $22, $44, 0, 0, $12, $43, $A, $BB, $D4, $51
	dc.b	$AD, $DD, $43, $33, $DD, $44, $32, $22, $E2, $44, $21, $24, $E2, $22, $21, $34, $92, $21, $23, $33, $99, $91, $22, $33, $D9, $11, $22, $22, $91, $11, $12, $42
	dc.b	$22, $23, $34, $55, $22, $44, $55, $55, $24, $45, $54, $45, $34, $54, $44, $44, $45, $44, $33, $34, $54, $32, $22, $33, $42, $22, $33, $33, $12, $23, $33, $33
	dc.b	$22, $33, $44, $33, $34, $44, $43, $33, $34, $54, $33, $33, $45, $43, $22, $33, $43, $32, $22, $DB, $32, $22, $2D, $BA, $12, $22, $2D, $BB, $42, $22, $2D, $BB
	dc.b	$22, $33, $22, $D9, $22, $44, $B0, $97, $32, $34, $DB, $BD, $32, $25, $4D, $DD, $31, $12, $53, 9, $22, $13, $30, 0, $22, $13, $20, 0, $21, 2, 0, 0
	dc.b	$44, $44, $45, $55, $54, $44, $54, $43, $54, $44, $33, $30, $54, $44, $43, 0, $44, $44, $40, 0, $34, $44, $40, 0, $33, $44, $50, 0, $33, $33, $50, 0
	dc.b	$33, $37, 0, 0, $33, $75, 0, 0, $33, $50, 0, 0, $35, 0, 0, 0, $AA, 0, 0, 0, $BB, 0, 0, 0, $B7, 0, 0, 0, $87, $70, 0, 0
	dc.b	$87, $78, 0, 0, $78, $88, 0, 0, $97, $88, 0, 0, $D8, $80, 0, 0, $99, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, $1D, 0, 0, 0, $1E, 0, 0, 0, $1E, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$98, $9E, $11, $4C, $D9, $9D, $14, $1C, $DD, $DD, $15, $DC, $ED, $EE, 1, $DE, $EE, $E1, $E, $11, $11, $10, 1, $11, 0, 0, 1, $11, 0, 0, 1, $11
	dc.b	$CC, 0, 0, 0, $CC, $C0, 0, 0, $CF, $CC, 0, 0, $EE, $DC, 0, 0, $11, $ED, 0, 0, $11, $1E, 0, 0, $11, $1E, 0, 0, $11, $1E, 0, 0
	dc.b	0, 0, 1, $11, 0, 0, 1, $11, 0, 0, 1, $11, 0, 0, 1, $11, 0, 0, 1, $11, 0, 0, $E, $11, 0, 0, 0, $11, 0, 0, 0, $E1
	dc.b	$11, $1E, 0, 0, $11, $1E, 0, 0, $11, $1E, 0, 0, $11, $1E, 0, 0, $11, $1E, 0, 0, $11, $E0, 0, 0, $11, $E0, 0, 0, $1E, 0, 0, 0
byte_35078:
	dc.b	0, 0, 0, 0, 0, 4, $45, $55, 0, 2, $23, $44, 0, 0, 2, $23, 0, 0, 0, $22, 0, 0, 0, 2, 0, 0, $34, $31, 0, $34, $43, $31
	dc.b	0, 0, 0, 0, $54, $44, $30, 0, $45, $54, $43, $33, $34, $45, $54, $44, $23, $33, $45, $44, $22, $33, $34, $44, $22, $23, $33, $44, $22, $22, $34, $44
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $30, 0, 0, 0, $33, 0, 0, 0, $44, $30, 0, 0, $44, $44, $30, 0, $44, $44, $44, $55
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 3, 0, 0, 0, 3, 0, 0, 0, $33, 0, 0, 0, $22, 0, $77, $77, $80, 8, $76, $66, $89, 8, $76, $68, $78, 8, $77, $98, $79
	dc.b	9, $88, $89, $89, 0, $99, $90, $98, 0, 0, 0, $99, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $E, 0, 0, 0, $E, 0, 0, 0, $EE
	dc.b	4, $43, $33, $22, $43, $32, $22, $34, $32, $22, $44, $44, $22, $24, $44, $44, 0, $44, $43, $33, 3, $44, $33, $23, 4, $43, $22, $22, $35, $32, $22, $22
	dc.b	$32, $22, $22, $22, $31, $11, $22, $23, $22, $22, $11, $23, $22, $22, $22, $34, 0, 2, $22, $44, $70, 0, $13, $51, $7B, $AB, $AB, $33, $7D, $DD, $DB, $43
	dc.b	$80, 3, $33, $22, $90, 2, $22, $24, 0, 2, $23, $44, 0, $22, $13, $34, 0, $12, $23, $33, 0, 1, $22, $32, 0, 1, $22, $22, 0, 2, $12, $31
	dc.b	0, 2, $14, $10, 0, 2, $51, 0, 0, 2, $10, 0, $E, $21, 0, 0, $EE, $21, $E0, 0, $97, $21, $EE, 0, $97, $21, $7E, 0, $97, $78, $9E, 0
	dc.b	$22, $24, $44, $55, $23, $45, $55, $55, $34, $55, $44, $45, $35, $44, $33, $34, $54, $33, $33, $33, $33, $22, $22, $33, $12, $23, $33, $33, $22, $34, $44, $33
	dc.b	$33, $45, $44, $33, $44, $54, $33, $33, $44, $43, $33, $33, $43, $32, $22, $33, $42, $22, $22, $DB, $22, $22, $2D, $BA, $23, $22, $2D, $BB, $24, $31, $2D, $DB
	dc.b	$23, $44, $3D, 0, $22, $44, $4A, $A9, $42, $45, $4D, $DA, $32, $24, $50, $D, $22, $EE, $E0, 0, $2E, $E1, $1E, 0, $2E, $11, $11, $E0, $1E, $11, $11, $10
	dc.b	$E1, $11, $11, $1E, $E1, $11, $11, $1E, 1, $11, $11, $1E, $E, $11, $11, $11, $E, $11, $11, $11, 0, $E1, $11, $11, 0, $E1, $11, $11, 0, $E, $11, $11
	dc.b	$44, $44, $55, $43, $54, $44, $44, $30, $54, $44, $33, $30, $54, $44, $43, 0, $44, $44, $40, 0, $34, $43, $40, 0, $33, $44, $50, 0, $33, $33, $50, 0
	dc.b	$33, $47, 0, 0, $33, $75, 0, 0, $33, $50, 0, 0, $35, 0, 0, 0, $AA, 0, 0, 0, $BB, 0, 0, 0, $B0, 0, 0, 0, 0, 0, 0, 0
	dc.b	8, $77, 0, 0, $88, $77, $70, 0, $B9, $78, $80, 0, $DB, $97, $80, 0, $9D, $98, $80, 0, $99, $89, $90, 0, 9, $90, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $E0, 0, 0, 0, $E0, 0, 0, 0, $E0, 0, 0, 0, $E0, 0, 0, 0
	dc.b	0, 0, 0, $ED, 0, 0, $E, $DD, 0, 0, $E, $DD, 0, 0, $E, $DD, 0, 0, 1, $DD, 0, 0, 0, $1D, 0, 0, 0, 1, 0, 0, 0, 0
	dc.b	$99, $99, $EE, 0, $87, $78, $E0, 0, $DC, $CD, $E0, 0, $CC, $DD, $E0, 0, $DD, $DE, $E0, 0, $DD, $DE, 0, 0, $11, $11, 0, 0, 0, 0, 0, 0
	dc.b	0, $E, $11, $11, 0, 0, $E1, $11, 0, 0, $E, $EE, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$E0, 0, 0, 0, $E0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
byte_35358:
	dc.b	0, 0, 0, $34, 0, 0, $24, $55, 0, 0, 2, $22, 0, 0, 0, $22, 0, 0, 0, 2, 0, 0, 0, 2, 0, 3, $34, $31, 3, $44, $43, $31
	dc.b	$44, $43, 0, 0, $45, $54, $43, 0, $34, $45, $53, $33, $23, $34, $45, $44, $22, $33, $44, $54, $22, $23, $34, $54, $22, $22, $33, $44, $22, $22, $44, $44
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $30, 0, 0, 0, $33, 0, 0, 0, $44, $30, 0, 0, $44, $44, $30, 0, $44, $44, $45, $55
	dc.b	0, 0, 0, 3, 0, 0, 0, $33, 0, 0, 0, $22, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3
	dc.b	0, 0, 0, $33, 0, 0, 0, $22, 0, 0, 8, $88, 0, 0, $87, $89, 0, 0, $87, $1B, 0, 0, $99, $DB, 0, 0, 9, $9D, 0, 0, 0, $90
	dc.b	$43, $33, $32, $22, $33, $22, $22, $34, $22, $22, $44, $44, 2, $24, $44, $44, 0, $44, $43, $24, 5, $44, $33, $22, $54, $33, $22, $22, $22, $22, $22, $22
	dc.b	$11, $12, $22, $22, $22, $21, $12, $23, $82, $22, $21, $34, $88, 2, $23, $54, $98, 2, $22, $22, $BB, $13, $32, $22, $DD, $34, $44, $22, $35, $35, $43, $23
	dc.b	$24, $44, $44, $55, $44, $55, $55, $55, $55, $54, $44, $45, $44, $43, $33, $34, $33, $33, $33, $33, $21, $22, $22, $33, $12, $23, $33, $33, $22, $34, $54, $33
	dc.b	$33, $45, $44, $33, $44, $43, $33, $33, $43, $32, $23, $33, $32, $22, $22, $33, $22, $22, $22, $DB, $22, $22, $2D, $BA, $44, $22, $2D, $BB, $44, $32, $2D, $D0
	dc.b	$44, $44, $54, $33, $54, $44, $43, $30, $54, $44, $33, 0, $54, $44, $43, 0, $44, $44, $40, 0, $34, $43, $40, 0, $33, $44, $50, 0, $33, $33, $50, 0
	dc.b	$33, $47, 0, 0, $33, $75, 0, 0, $33, $50, 0, 0, $35, 0, 0, 0, $AA, 0, 0, 0, $BB, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$35, $53, $22, $22, $34, $32, $24, $32, $23, $21, $34, $43, $21, $22, $34, $43, 1, $22, $33, $32, 0, $12, $23, $22, 0, $12, $22, $22, 0, $11, $13, $11
	dc.b	1, $53, $31, 0, 0, $11, $10, 0, 0, $12, 0, 0, 0, $12, 0, 0, 0, $12, 0, 0, 8, $76, 0, 0, 9, $98, $67, 0, $88, $78, $90, 0
	dc.b	$44, $54, $1D, 0, $22, $54, $1B, $B0, $22, $34, $1D, $DB, $21, $23, $16, $7D, $21, $12, $87, $DE, $11, $D, $CC, $CD, $10, $D, $CF, $CC, 0, $D, $DC, $C1
	dc.b	0, $E, $DC, $11, 0, $E, $E1, $11, 0, $E, $11, $11, 0, 0, $11, $11, 0, 0, $11, $11, 0, 0, 1, $11, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, $A0, $87, 0, 0, $DB, $69, $78, $80, $E7, $97, $67, $78, $D9, $98, $76, $67, $19, $88, $76, $78, $11, $99, $97, $89
	dc.b	$11, $E9, $88, $90, $11, 0, $99, 0, $11, 0, 0, 0, $11, 0, 0, 0, $10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, $11, 0, 0, 1, $ED, 0, 0, $1D, $DD, 0, 0, $1E, $DD, 0, 0, 1, $ED, 0, 0, 0, $1E, 0, 0, 0, 1, 0, 0, 0, 0
	dc.b	$98, $76, $79, 0, $ED, $DD, $68, 0, $ED, $DD, $DD, $10, $DD, $CF, $CC, $10, $DD, $CC, $CC, $10, $EE, $EC, $CC, $10, $11, $11, $11, $E0, 0, 0, 0, 0
byte_355B8:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, $45, 0, 0, 0, $45, 0, 0, 4, $32, 0, 0, 3, $22, 0, 0, $33, $22
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $40, 0, 0, 0, $40, 0, 0, 0, $34, 0, 0, 0, $23, 0, 0, 0, $23, $30, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 3, 0, 0, 0, $34, 0, 0, 0, $35, 0, 7, $78, $25, 0, $76, $67, $82, 0, $77, $89, $80
	dc.b	0, $88, $9D, $90, 0, $88, $9D, $AA, 0, $98, $9E, $DD, 0, 9, $99, 0, 0, 0, 0, $E0, 0, 0, $E, $E, 0, 0, $E0, $E0, 0, 0, $E, $E
	dc.b	$44, 0, $32, $22, $54, $44, $12, $22, $35, $44, $21, $21, $23, $43, $32, $33, $22, $32, $23, $34, $22, $22, $13, $45, $22, $21, $23, $55, $21, $12, $23, $55
	dc.b	$13, $33, $12, $35, $34, $43, $31, $22, $45, $43, $31, $22, $55, $43, $32, $11, $54, $32, $13, $32, $43, $21, $34, $32, $20, 3, $54, $32, 0, $B5, $43, $22
	dc.b	$AB, $45, $32, $24, $DD, $52, $12, $45, 0, $21, $34, $55, 0, $C, $23, $44, 0, $CC, $C2, $35, 0, $CC, $C1, $21, $C, $CC, $CC, $12, $C, $CC, $CC, $12
	dc.b	$22, $30, 4, $40, $22, $14, $44, $55, $21, $24, $45, $32, $32, $33, $43, $22, $33, $22, $32, $22, $43, $12, $22, $22, $53, $21, $22, $20, $53, $22, $11, $20
	dc.b	$32, $13, $33, $10, $21, $33, $44, $33, $21, $33, $45, $43, $12, $33, $45, $5C, $33, $12, $34, $54, $34, $31, $23, $45, $34, $53, 0, $22, $23, $45, $B0, $E
	dc.b	$22, $35, $4B, $A0, $42, $12, $5D, $DA, $54, $21, $2E, $DD, $43, $21, $EE, $EE, $32, $21, $EE, $EE, $22, $21, $EE, $EE, $22, $12, $EE, $EE, $21, $2E, $EE, $EE
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $C, 0, 0
	dc.b	0, $C0, $C0, 0, $C, $C, 0, 0, $C0, $C0, $C0, 0, $C, $C, 0, 0, $C0, $C0, 0, 0, $2C, 7, 0, 0, $80, $66, $70, 0, $89, $87, $70, 0
	dc.b	$9D, $98, $80, 0, $AD, $98, $80, 0, $DE, $98, $90, 0, $E9, $99, 0, 0, 0, 0, 0, 0, $E0, 0, 0, 0, $E0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, $E0, $E0, 0, 0, $E, $E, 0, 0, $E0, $E0, 0, 0, $E, $E, 0, 0, 0, $E0, 0, 0, $E, $E, 0, 0, 0, $E0, 0, 0, $E, $E
	dc.b	$1C, $CC, $CC, $11, $1C, $CD, $DD, $D1, $DC, $DD, $DD, $D1, $CC, $DD, $DD, $D1, $CD, $DD, $DD, $D1, $CD, $DD, $DD, $D1, $DD, $DD, $ED, $D1, $DE, $DE, $ED, $10
	dc.b	$12, $EE, $EE, $EE, $E, $EE, $EE, $EE, $E, $EE, $EE, $E0, $E, $EE, $EE, $E0, $E, $EE, $EE, 0, $E, $EE, $EE, 0, 0, $EE, $E0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, $E0, 0, 0, $E, $D, 0, 0, 0, $ED, 0, 0, $E, $ED, 0, 0, $E, $DE, 0, 0, 0, $1E, 0, 0, 0, $11, 0, 0, 0, 1
	dc.b	$DE, $EE, $EE, $10, $EE, $EE, $EE, $10, $EE, $EE, $EE, $10, $EE, $EE, $E1, 0, $EE, $EE, $E1, 0, $EE, $EE, $10, 0, $EE, $E1, 0, 0, $11, $10, 0, 0
byte_35818:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, $44, 0, 0, 0, $43, 0, 0, 3, $32
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $40, 0, 0, 0, $54, 0, 0, 0, $54, $40, 0, 0, $23, $40, 0, 0, $22, $33, 0, 0
	dc.b	0, 0, 3, $22, 4, $44, $41, $22, $55, $54, $32, $12, $42, $33, $33, $23, $22, $22, $22, $34, $22, $22, $21, $35, 2, $22, $12, $35, 2, $11, $22, $33
	dc.b	$22, $23, 0, 0, $22, $21, $44, $44, $12, $12, $34, $55, $33, $23, $33, $32, $54, $32, $22, $22, $55, $31, $22, $22, $55, $32, $12, $22, $53, $32, $21, $12
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, $50, 0, 0, 0, $40, 0, 0, 0, $20, 0, 0, 0, $20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 1, $11, 0, 0, $1C, $CC, 0, 1, $CC, $CC, 0, 1, $CC, $CC, 0, 1, $CC, $CC
	dc.b	0, 1, $CC, $CC, 0, 1, $CD, $DD, 0, 9, $1C, $DD, 0, 0, $1D, $DD, 0, 0, $1D, $DD, 0, 0, 1, $DD, 0, 0, 1, $DD, 0, 0, 1, $DD
	dc.b	0, 0, 0, $1D, 0, 0, 0, $1D, 0, 0, 0, $1E, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	1, $33, $31, $22, $33, $44, $33, $12, $45, $54, $33, $12, $55, $44, $33, $21, $14, $32, $21, $33, $C1, $22, $14, $43, $CC, $10, $45, $43, $CC, $C1, $53, $32
	dc.b	$CC, $C1, $32, $22, $CD, $CD, $11, $24, $DD, $CD, $12, $45, $DD, $DD, $12, $34, $DD, $DD, $D1, $23, $DD, $DD, $D1, $22, $DD, $DD, $DD, $22, $ED, $DD, $DD, $12
	dc.b	$ED, $ED, $DD, $11, $DE, $EE, $DD, $10, $DE, $EE, $ED, $E0, $DE, $EE, $ED, 0, $EE, $EE, $E0, $E0, $E, $EE, $E, 0, $E0, $E0, $E0, $E0, $E, $E, $E, 0
	dc.b	$32, $21, $33, $31, $22, $13, $34, $43, $22, $13, $34, $55, $11, $23, $34, $45, $23, $31, $22, $34, $23, $44, $12, $22, $23, $45, $40, 0, $22, $33, $53, 0
	dc.b	$42, $22, $35, $BA, $54, $21, $22, $DD, $55, $42, $10, $D, $44, $32, $10, $E, $44, $52, $10, $E0, $11, $12, $10, $E, $22, $21, $20, $E0, $22, $12, 0, $E
	dc.b	$11, $20, 0, $E0, 0, 0, $E, $E, 0, 0, $EE, $EE, 0, 0, $EE, $EE, 0, $E, $EE, $EE, 0, $E, $EE, $EE, 0, $EE, $EE, $EE, 0, $EE, $EE, $EE
	dc.b	0, 0, 0, 0, $30, 0, 0, 0, $43, 0, 0, 0, $54, 0, 0, 0, $54, 0, 0, 0, $22, $87, $70, 0, 8, $76, $67, 0, 8, $98, $77, 0
	dc.b	9, $D9, $88, 0, $AA, $D9, $88, 0, $DD, $E9, $89, 0, $E, $99, $90, 0, $E0, $E0, 0, 0, $E, 0, 0, 0, $E0, $E0, 0, 0, $E, 0, 0, 0
	dc.b	$E0, 0, 0, 0, $E, 0, 0, 0, $E0, 0, 0, 0, $E, 0, 0, 0, $E0, 0, 0, 0, 0, 0, 0, 0, $E0, 0, 0, 0, $E0, 0, 0, 0
	dc.b	0, $E0, $E0, $E0, 0, $E, $E, 0, 0, 0, $E0, $ED, 0, 0, 0, $D, 0, 0, 0, $D, 0, 0, 0, $D, 0, 0, 0, $E, 0, 0, 0, 0
	dc.b	$E, $EE, $EE, $EE, $DD, $DE, $EE, $EE, $DD, $DD, $EE, $EE, $DD, $DD, $EE, $EE, $DD, $DD, $DD, $E0, $DD, $DD, $DE, $10, $ED, $DD, $D1, 0, $11, $11, $10, 0
byte_35A78:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3
	dc.b	0, 0, 0, 3, 0, 0, 0, $34, 0, 0, 0, $34, 0, 0, 3, $44, 0, $25, $44, $44, 0, $23, $54, $44, 0, 2, $34, $44, 0, 0, $34, $44
	dc.b	0, 0, $34, $44, 0, 0, $34, $44, 0, 0, $33, $44, 0, 0, $23, $34, 0, 0, $25, $24, 0, 0, 4, $93, 0, 0, 0, $51, 0, 0, 0, $59
	dc.b	0, 0, 0, 5, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8
	dc.b	0, 0, 0, 0, 0, 0, 0, $33, 0, 0, $33, $44, 0, 3, $44, $44, 0, $34, $44, $44, 3, $44, $44, $43, $34, $44, $44, $43, $44, $44, $44, $43
	dc.b	$44, $44, $44, $43, $44, $44, $44, $43, $44, $44, $55, $45, $44, $45, $54, $52, $44, $45, $54, $2B, $44, $55, $42, $BB, $44, $55, $44, $42, $44, $54, $44, $43
	dc.b	$44, $44, $44, $43, $44, $44, $55, $33, $44, $45, $33, $32, $44, $43, $35, $52, $44, $33, $66, $65, $44, $35, $11, $66, $33, $35, $91, $96, $13, $56, $61, $16
	dc.b	$95, $AA, $66, $6A, $11, $BB, $AA, $AB, $DD, $BB, $BB, $BD, 0, $DD, $DD, $D0, 0, 0, $7B, $D0, 0, $77, $97, $D9, $88, $77, $79, $89, $87, $77, $78, $90
	dc.b	$33, $20, 0, 0, $43, $20, 0, 0, $32, 0, 0, 0, $32, 0, 0, 0, $32, 0, 0, 0, $32, 0, 3, $33, $32, 0, $34, $44, $33, $23, $34, $43
	dc.b	$33, $33, $44, $32, $55, $23, $44, $32, $22, $23, $43, $22, $BA, $22, $33, $20, $AA, $22, $32, $20, $AA, $22, $22, $23, $2B, $22, $22, $34, $22, $22, $22, $33
	dc.b	$32, $22, $22, $22, $32, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $21, $22, $22, $22, $22, $22, $22, $2A, $22, $22, $22, $2B, $A2, $22, $12, $BD, $BA
	dc.b	$B2, $1B, $BB, $DA, $B1, $BB, $B2, $2B, $D0, 2, $10, $22, 0, 2, $10, $22, 0, 2, $10, $22, 0, $21, 0, $22, 0, $21, 3, $29, 0, $21, 3, $27
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $33, 0, 0, 0, $32, 0, 0, 0, $20, 0, 0, 0, $20, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $33, $33, 0, 0, $43, $32, $20, 0, $32, $22, 0, 0
	dc.b	$22, 0, 0, 0, $20, 0, 0, 0, 0, 0, 0, 0, $20, 0, 0, 0, $20, 0, 0, 0, $22, 0, 0, 0, $22, $20, 0, 0, $20, 2, 0, 0
	dc.b	0, 0, 0, 0, $A0, 0, 0, 0, $A0, 0, 0, 0, $B7, $70, 0, 0, $79, $90, 0, 0, $97, $67, 0, 0, $76, $66, $67, $70, $66, $66, $67, $90
	dc.b	0, 0, 0, 7, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $D, 0, 0, 0, $ED, 0, 0, 0, $1E, 0, 0, 0, 1
	dc.b	$77, $78, $78, $90, $88, $99, $88, $90, $99, 8, $89, 0, 0, 9, $90, 9, $DD, $DD, $80, 9, $DD, $DD, $98, $D9, $DD, $DD, $98, $DD, $1E, $DD, $D8, $DE
	dc.b	0, $21, 3, $26, 0, $21, 3, $67, 2, $10, 3, $89, $82, $10, 3, $90, $88, $91, $87, $66, $99, $91, $99, $99, $E9, $18, $88, $77, $EE, $19, $87, $66
	dc.b	$86, $66, $66, $70, $98, $69, $67, $90, 9, $86, $99, 0, 0, $98, $90, 0, $70, 9, 0, 0, $90, 0, 0, 0, $90, 0, 0, 0, $80, 0, 0, 0
	dc.b	1, $1E, $D9, $9E, 0, 1, $11, $9E, 0, 0, 0, $11, 0, 0, 0, 0, 0, 0, 0, $D, 0, 0, 0, $D, 0, 0, 0, 1, 0, 0, 0, 0
	dc.b	$EE, $1D, $DD, $DD, $E1, $66, $66, $CD, $18, $CC, $C8, $6C, $DC, $CC, $CC, $87, $CC, $CC, $CD, $87, $CC, $CC, $DD, $D8, $DC, $CD, $DE, $11, $11, $11, $11, 0
	dc.b	$E0, 0, 0, 0, $DE, 0, 0, 0, $DE, 0, 0, 0, $DE, 0, 0, 0, $D1, 0, 0, 0, $10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
byte_35D58:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, $34
	dc.b	0, 0, 0, 0, 0, 0, 0, $33, 0, 0, $33, $43, 0, $33, $44, $32, 3, $44, $44, $32, $34, $44, $44, $32, $44, $44, $43, $32, $44, $44, $43, $32
	dc.b	0, 0, 0, 0, $20, 0, 0, 0, $20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $33, 0, 3, $33, $32, 0, $34, $44, $20
	dc.b	0, 0, 3, $44, 0, 0, 3, $44, 0, 0, $34, $44, 0, 0, $34, $44, 0, 3, $44, $44, $25, $44, $44, $44, $23, $54, $44, $44, 2, $34, $44, $44
	dc.b	0, $34, $44, $44, 0, $34, $44, $44, 0, $34, $44, $44, 0, $33, $44, $44, 0, $23, $34, $44, 0, $25, $24, $44, 0, 4, $93, $44, 0, 0, $51, $33
	dc.b	0, 0, $59, $13, 0, 0, 5, $95, 0, 0, 1, $11, 0, 0, 0, $DD, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$44, $44, $43, $33, $44, $44, $43, $33, $44, $44, $43, $55, $44, $55, $45, $22, $45, $54, $52, $BA, $45, $54, $2B, $AA, $55, $42, $BB, $AA, $55, $44, $42, $2B
	dc.b	$54, $44, $43, $22, $44, $44, $43, $32, $44, $55, $33, $32, $45, $33, $32, $22, $43, $35, $52, $22, $33, $66, $65, $22, $35, $11, $66, $22, $35, $91, $96, $22
	dc.b	$56, $61, $16, $22, $AA, $66, $6A, $B2, $BB, $AA, $AB, $B1, $BB, $BB, $BD, $D9, $DD, $DD, $D8, $90, 0, $77, $77, $90, 8, $77, $97, $90, 8, $78, $97, $90
	dc.b	$23, $34, $43, $20, $33, $44, $32, 0, $23, $44, $32, 0, $23, $43, $22, 0, $22, $33, $22, $20, $22, $32, $22, $20, $22, $22, $23, $33, $22, $22, $34, $43
	dc.b	$22, $22, $33, $32, $22, $22, $22, $22, $22, $22, $22, $20, $22, $22, $22, $BA, $22, $22, $22, $2B, $22, $22, $22, $27, $22, $21, 2, $29, $22, $21, 3, $29
	dc.b	$12, $21, 3, $29, $10, $21, 3, $27, 0, $21, 3, $26, 0, $21, 3, $20, 0, $21, 0, $32, 0, $21, 0, $32, 8, $21, 8, $76, $98, $89, $19, $99
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $33, 0, 0, 0, $32, $20, 0, 0
	dc.b	$22, 0, 0, 0, $20, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, $77, 0, 0, 0, $99, $70, 0, 0, $76, $76, $70, 0, $66, $66, $67, 0
	dc.b	$66, $66, $66, $70, $88, $66, $67, $70, $99, $68, $96, $90, 0, $96, $99, 0, 0, 9, $90, 0, $67, 0, 0, 0, $79, 0, 0, 0, $99, $90, 0, 0
	dc.b	8, $79, 8, $90, 8, $79, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, $DD, 0, 0, 0, $DD, 0, 0, 0, $DD, 0, 0, $D, $DD
	dc.b	0, 0, $D, $DE, 0, 0, $D, $DE, 0, 0, $D, $DE, 0, 0, 1, $11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$99, $99, $98, $88, $D8, $89, $19, $87, $DD, $EE, $E1, $DD, $89, $EE, $EC, $66, $D8, $8E, $18, $CC, $EE, $89, $DC, $CC, $EE, $E1, $DC, $CC, $EE, $ED, $CC, $CC
	dc.b	$EE, $1D, $CC, $CD, $E1, $D, $CC, $CD, $10, $D, $CC, $DE, 0, 1, $DD, $E1, 0, 0, $11, $10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$76, $80, 0, 0, $6D, $E0, 0, 0, $DD, $DE, 0, 0, $6C, $DD, $E0, 0, $88, $CD, $E0, 0, $C8, $7D, $10, 0, $D8, $81, 0, 0, $DD, $11, 0, 0
	dc.b	$DE, $10, 0, 0, $E1, 0, 0, 0, $10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
byte_35FF8:
	dc.b	0, 0, 0, 3, 0, 0, 0, $34, $45, 0, $33, $45, $34, $55, $34, $43, $34, $43, $33, $32, $23, $34, $42, $22, $22, $44, $41, $22, $34, $55, $44, $12
	dc.b	$45, $55, $44, $32, $45, $55, $43, $32, $55, $54, $33, $23, $55, $43, $22, $33, $54, $32, $23, $34, $22, $21, $23, $44, 2, $22, $23, $45, 2, $33, $23, $35
	dc.b	$33, $44, $22, $34, $34, $54, $22, $34, $45, $54, $22, $23, $55, $43, $22, $22, $54, $32, $22, $22, $53, $22, $12, $33, $22, 1, $33, $43, 0, $AD, $44, $43
	dc.b	$33, 0, 0, 0, $54, $30, 0, 0, $55, $43, $30, 5, $53, $44, $35, $54, $52, $33, $33, $44, $22, $22, $44, $33, $22, $21, $44, $42, $22, $14, $45, $54
	dc.b	$22, $34, $45, $55, $12, $33, $45, $55, $33, $23, $34, $55, $43, $32, $23, $45, $44, $33, $22, $34, $54, $43, $21, $22, $55, $43, $22, $22, $55, $33, $23, $32
	dc.b	$54, $32, $24, $43, $54, $32, $24, $54, $53, $22, $24, $55, $22, $22, $23, $45, $12, $22, $22, $34, $23, $32, $12, $23, $23, $43, $31, 2, $23, $44, $4D, $A0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, $40, 0, 0, 0, $30, 0, 0, 0, $30, 0, 0, 0, $20, 0, 0, 0, $20, 0, 0, 0, $30, 0, 0, 0
	dc.b	$40, 0, 0, 0, $40, 0, 0, 0, $50, 0, 0, 0, $50, 0, 0, 0, $50, 0, 0, 0, $20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$30, 0, 0, 0, $30, 0, 0, 0, $40, 0, 0, 0, $50, 0, 0, 0, $50, 0, 0, 0, $50, 0, 0, 0, $20, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $B, 0, 0, 0, $B, 0, 0, 0, $B, 0, 0, 0, $6D, 0, 0, 0, $7D
	dc.b	0, 0, 0, $89, 0, 0, 0, $88, 0, 0, 0, $99, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $87, 0, 0, $D, $87, 0, 0, $D, $88, 0, 0, $E, $88, 0, 0, 0, $EE, 0, 0, 0, 0
	dc.b	$A, $B3, $44, $32, $AB, $D4, $53, $13, $BD, 5, $41, $23, $D0, 4, $21, $23, $D0, 3, $12, $22, $D6, $72, 1, $22, $D7, $69, 1, $21, $D9, $79, 2, $11
	dc.b	$19, $79, 2, $10, $97, $99, 2, $10, $99, $90, 2, $10, $99, 0, 2, $10, 0, 0, 2, $10, 0, $87, $66, $70, 0, $99, $99, $90, 8, $88, $77, $90
	dc.b	9, $87, $66, $80, $8D, $DD, $EE, $10, $DD, $DD, $FC, $C1, $DD, $DC, $CC, $C1, $DD, $DC, $CC, $C1, $DD, $DC, $CC, $C1, $DD, $DC, $CC, $C1, $EE, $E1, $11, $10
	dc.b	$32, $34, $43, $BA, $43, $13, $54, $DB, $43, $21, $45, $D, $33, $21, $24, 0, $32, $22, $13, 0, $22, $21, 2, $76, $41, $21, 9, $67, $41, $12, 9, $79
	dc.b	$40, $12, 9, $79, $50, $12, 9, $97, $10, $12, 0, $99, 0, $12, 0, 9, 0, $12, 0, 0, 0, $76, $67, $80, 0, $99, $99, $90, 0, $97, $78, $88
	dc.b	0, $86, $67, $89, 0, $1E, $ED, $DD, 1, $CC, $FD, $DD, 1, $CC, $CC, $DD, 1, $CC, $CC, $DD, 1, $CC, $CC, $DD, 1, $CC, $CC, $DD, 0, $11, $11, $EE
	dc.b	0, 0, 0, 0, $A0, 0, 0, 0, $B0, 0, 0, 0, $DB, 0, 0, 0, $DB, 0, 0, 0, $DB, 0, 0, 0, $DD, $60, 0, 0, $DD, $70, 0, 0
	dc.b	$19, $80, 0, 0, $98, $80, 0, 0, $99, $90, 0, 0, $99, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, $80, 0, 0, 0, $D7, $80, 0, 0, $D7, $8D, 0, 0, $D8, $8D, 0, 0, $D8, $8E, 0, 0, $DE, $E0, 0, 0, $E0, 0, 0, 0
byte_36298:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 4, 0, 0, 0, 4, 0, 0, 0, 5, 0, 0, 0, 5, 0, 0, 0, 5
	dc.b	0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $33, $40, 0, $33, $44, $44, $43, $44, $45, $34, $44, $44, $44, $33, $44, $44, $43, $33, $34, $55, $54
	dc.b	$33, $44, $55, $55, $44, $45, $44, $44, $44, $45, $44, $44, $34, $44, $33, $33, $34, $33, $33, $22, $43, $33, $32, $22, $53, $33, $33, $33, $53, $33, $34, $44
	dc.b	$53, $33, $34, $45, $43, $33, $23, $34, $AA, $D3, $32, $33, $BB, $BD, $32, $23, $BB, $BD, $32, $22, $B, $BB, $D2, $22, 0, $DB, $D2, $22, 0, $D, $D2, $22
	dc.b	0, 0, 0, 0, 3, $44, $44, 0, $34, $45, $55, $44, $45, $54, $44, $55, $54, $33, $32, $22, $33, $32, $22, $22, $33, $22, $22, $20, $32, $22, $22, $30
	dc.b	$43, $22, $21, $33, $54, $32, $21, $23, $45, $33, $12, $22, $44, $53, $43, $22, $23, $53, $44, $42, $22, $22, $34, $44, $21, $22, $23, $44, $32, $12, $22, $34
	dc.b	$43, $22, $22, $23, $44, $32, $22, $22, $44, $32, $22, $22, $34, $32, $22, $22, $34, $41, $11, $12, $24, $42, $22, $21, $21, $52, $22, 0, $42, $32, $10, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, $30, 0, 0, 0, $43, 0, 0, 0, $22, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$30, 0, 0, 0, $33, 0, 0, 0, $23, $30, 0, 0, $22, $33, 0, 0, $22, $22, $30, 0, $22, $22, $20, 0, $30, 0, 0, 0, $40, 0, 0, 0
	dc.b	$43, 0, 0, 0, $33, 0, 0, 0, $23, $30, 0, 0, $22, $30, 0, 0, $22, $20, 0, 0, $11, $13, 0, 0, $22, $22, $30, 0, 0, 2, $20, 0
	dc.b	0, 0, $AD, $23, 0, $A, $BD, $23, 0, $A, $D2, $23, 0, $AB, $D2, $22, 0, $AD, $22, $22, 0, $BD, $82, $22, 0, $BD, $98, $22, 8, $DD, $78, $22
	dc.b	8, $7D, $D8, $91, 8, $98, $89, $10, 9, $89, $91, 0, 0, $99, $91, 0, 0, 2, $10, 0, 0, 2, $10, 0, 0, $92, $10, 0, 8, $86, $68, $90
	dc.b	$44, $33, $31, 0, $34, $33, $3D, 0, $33, $43, $33, $B0, $33, $32, $33, $DB, $23, $32, $33, $DB, $22, $32, $23, $DD, $22, $22, $12, $D9, $22, $31, $9D, $99
	dc.b	$11, $24, $99, $99, 0, $12, $49, $90, 0, $21, $20, 0, 0, $21, 0, 0, 0, 2, $10, 0, 0, $92, $19, 0, 9, $88, $88, 0, 9, $99, $99, $90
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $D8, 0, 0, $DD, $87, 0, $D, $DD, $87, 0, $E, $DC, $88, 0, 0, $EE, $D8, 0, 0, 0, $E
	dc.b	9, $88, $89, $90, 8, $66, $68, $90, $8D, $99, $99, $10, $CC, $CF, $CC, $D1, $CC, $CC, $CC, $D1, $CC, $CC, $CC, $D1, $8C, $CC, $CC, $D1, $EE, $E1, $11, $10
	dc.b	9, $97, $78, $90, 1, $DD, $DD, $D0, $1D, $CC, $CC, $DD, $1D, $CC, $CC, $CD, $1D, $CC, $CC, $CD, $1D, $CC, $CC, $D1, 1, $11, $11, $10, 0, 0, 0, 0
byte_364F8:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 5, 0, 0, 0, 3, 0, 0, 0, 2, 0, 0, 0, 2
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 3, $34, 0, 0, $33, $34, $22, 3, $34, $45, $22, $34, $45, $54, $23, $44, $55, $53
	dc.b	$34, $45, $55, $55, $34, $45, $54, $45, $34, $45, $44, $44, $44, $54, $45, $54, $44, $44, $56, $65, $44, $43, $69, $15, $34, $43, $69, $15, $33, $26, $69, $14
	dc.b	$22, $36, $69, $14, $11, $66, $61, $43, $9B, $B6, $65, $6B, $1A, $A6, $66, $AA, $B, $AA, $AA, $AA, $D, $BB, $BB, $BB, 0, $DD, $BB, $BB, 0, 0, $DD, $32
	dc.b	0, 0, 0, 0, 0, $33, $33, $33, $33, $44, $33, $33, $44, $43, $33, $33, $44, $22, $33, $33, $42, $BB, $23, $22, $2A, $BB, $22, $20, $AA, $BB, $23, $33
	dc.b	$44, $BB, $23, $33, $54, $33, $33, $33, $54, $33, $33, $33, $44, $44, $32, $23, $44, $44, $32, $22, $44, $33, $32, $22, $44, $33, $32, $22, $43, $33, $32, $22
	dc.b	$43, $33, $22, $23, $33, $33, $22, $33, $B3, $32, $22, $33, $AB, $22, $22, $23, $BB, $22, $22, $22, $BB, $22, $12, $22, $B2, $11, $22, $22, $21, $22, $20, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, $33, 0, 0, 0, $33, $30, 0, 0, $32, $20, 0, 0, $20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$33, 0, 0, 0, $33, $30, 0, 0, $33, $33, 0, 0, $33, $33, $30, 0, $22, $33, $30, 0, $22, $22, $33, 0, $22, $22, $22, 0, $22, 0, 0, 0
	dc.b	0, 0, 0, 0, $30, 0, 0, 0, $33, 0, 0, 0, $33, $30, 0, 0, $23, $30, 0, 0, $22, $33, 0, 0, $22, $23, 0, 0, 2, $22, 0, 0
	dc.b	0, 0, 0, $DD, 0, 0, $D, $B2, 0, 0, $B, $B2, 0, 0, $B, $B7, 0, 0, $B, $B9, 0, 0, $D, $77, 0, 0, 8, $77, 0, 0, 9, $87
	dc.b	0, 0, 0, $98, 0, 0, 0, $99, 0, 0, 0, $21, 0, 0, 2, $10, 0, 0, 2, $10, 0, 0, $21, 0, 0, $99, $21, $90, 8, $86, $68, $90
	dc.b	$2B, $A2, $22, $BB, $2D, $BA, $22, $2D, $22, $DA, $22, $2D, $72, $DB, $21, $22, $86, $DB, $21, $22, $6D, $BD, $21, $22, $6D, $D7, $19, $92, $96, $79, $13, $90
	dc.b	$89, $99, $12, $30, $88, $92, $10, $23, $99, 2, $10, 2, 0, 2, $10, 0, 0, 2, $10, 0, 0, $92, $19, 0, 0, $98, $77, $80, 0, $99, $99, $99
	dc.b	0, 0, 0, 0, $B0, 0, 0, 0, $D0, 0, 0, 0, $D0, 0, 0, 0, $D0, 0, 0, 0, $D0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, $40, 0, 0, 0, $20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $88, 0, 0, $DD, $76, 0, $DD, $CC, $C6, $D, $DC, $CC, $C6, $E, $DC, $CC, $CC, 0, $11, $11, $11
	dc.b	9, $88, $89, $90, 8, $86, $78, $90, $DC, $99, $99, $10, $CC, $FC, $CC, $D1, $6C, $CC, $CC, $D1, $6C, $CC, $CC, $D1, $67, $CC, $CC, $D1, $11, $11, $11, $10
	dc.b	0, $99, $77, $89, 0, $1D, $DD, $DD, 1, $DC, $CC, $CD, 1, $DC, $CC, $CC, 1, $DC, $CC, $CC, 1, $DC, $CC, $CC, 0, $11, $11, $11, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, $D0, 0, 0, 0, $D0, 0, 0, 0, $D0, 0, 0, 0, $10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
byte_367B8:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 5, 0, 0, 0, 3, 0, 0, 0, 2, 0, 0, 0, 2
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 3, $34, 0, 0, $33, $34, $22, 3, $34, $45, $22, $34, $45, $54, $23, $44, $55, $53
	dc.b	$34, $45, $55, $55, $34, $45, $54, $45, $34, $45, $44, $44, $44, $54, $45, $54, $44, $44, $56, $65, $44, $43, $69, $15, $34, $43, $69, $15, $33, $26, $69, $14
	dc.b	$22, $36, $69, $14, $11, $66, $61, $43, $9B, $B6, $65, $6B, $1A, $A6, $66, $AA, $B, $AA, $AA, $AA, $D, $BB, $BB, $BB, 0, $DD, $BB, $BB, 0, 0, $DD, $32
	dc.b	0, 0, 0, 0, 0, $33, $33, $33, $33, $44, $33, $33, $44, $43, $33, $33, $44, $22, $33, $33, $42, $BB, $23, $22, $2A, $BB, $22, $20, $AA, $BB, $23, $33
	dc.b	$44, $BB, $23, $33, $54, $33, $33, $33, $54, $33, $33, $33, $44, $44, $32, $23, $44, $44, $32, $22, $44, $33, $32, $22, $44, $33, $32, $22, $43, $33, $32, $22
	dc.b	$43, $33, $22, $23, $33, $33, $22, $33, $B3, $32, $22, $33, $AB, $22, $22, $23, $BB, $22, $22, $22, $BB, $22, $12, $22, $B2, $11, $22, $22, $21, $22, $20, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, $33, 0, 0, 0, $33, $30, 0, 0, $32, $20, 0, 0, $20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$33, 0, 0, 0, $33, $30, 0, 0, $33, $33, 0, 0, $33, $33, $30, 0, $22, $33, $30, 0, $22, $22, $33, 0, $22, $22, $22, 0, $22, 0, 0, 0
	dc.b	0, 0, 0, 0, $30, 0, 0, 0, $33, 0, 0, 0, $33, $30, 0, 0, $23, $30, 0, 0, $22, $33, 0, 0, $22, $23, 0, 0, 2, $22, 0, 0
	dc.b	0, 0, 0, $DD, 0, 0, $D, $B2, 0, 0, $B, $B2, 0, 0, $B, $B7, 0, 0, $B, $B9, 0, 0, $D, $77, 0, 0, 8, $77, 0, 0, 9, $87
	dc.b	0, 0, 0, $98, 0, 0, 0, $99, 0, 0, 0, $21, 0, 0, 2, $10, 0, 0, 2, $10, 0, 0, $21, 0, 8, $99, $21, $90, 8, $88, $88, $90
	dc.b	$2B, $A2, $22, $BB, $2D, $BA, $22, $2D, $22, $DA, $22, $2D, $72, $DB, $21, $22, $86, $DB, $21, $22, $6D, $BD, $21, $22, $6D, $D7, $19, $92, $96, $79, $13, $90
	dc.b	$89, $99, $12, $30, $88, $92, $10, $23, $99, 2, $10, 2, 0, 2, $10, 0, 0, 2, $10, 0, 0, $92, $19, 0, 0, $98, $77, $80, 0, $99, $99, $99
	dc.b	0, 0, 0, 0, $B0, 0, 0, 0, $D0, 0, 0, 0, $D0, 0, 0, 0, $D0, 0, 0, 0, $D0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, $40, 0, 0, 0, $20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, $DD, $D9, $E, $DD, $CC, $C8, $ED, $CC, $CC, $CC, $ED, $CC, $CC, $CC, $E, $EE, $DC, $CC, 0, 0, $EE, $EE, 0, 0, 0, 0
	dc.b	9, $66, $79, $90, $97, $86, $77, $90, $8D, $99, $99, $10, $67, $FC, $CC, $D1, $67, $CC, $CC, $D1, $76, $CC, $CC, $D1, $E7, $DC, $CC, $D1, $E, $E1, $11, $11
	dc.b	0, $99, $77, $89, 0, $1D, $DD, $DD, 1, $DC, $CC, $CD, 1, $DC, $CC, $CC, 1, $DC, $CC, $CC, 1, $DC, $CC, $CC, 0, $11, $11, $11, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, $D0, 0, 0, 0, $D0, 0, 0, 0, $D0, 0, 0, 0, $10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
byte_36A78:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 5, 0, 0, 0, 3, 0, 0, 0, 2, 0, 0, 0, 2
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 3, $34, 0, 0, $33, $34, $22, 3, $34, $45, $22, $34, $45, $54, $23, $44, $55, $53
	dc.b	$34, $45, $55, $55, $34, $45, $54, $45, $34, $45, $44, $44, $44, $54, $45, $54, $44, $44, $56, $65, $44, $43, $69, $15, $34, $43, $69, $15, $33, $26, $69, $14
	dc.b	$22, $36, $69, $14, $11, $66, $61, $43, $9B, $B6, $65, $6B, $1A, $A6, $66, $AA, $B, $AA, $AA, $AA, $D, $BB, $BB, $BB, 0, $DD, $BB, $BB, 0, 0, $DD, $32
	dc.b	0, 0, 0, 0, 0, $33, $33, $33, $33, $44, $33, $33, $44, $43, $33, $33, $44, $22, $33, $33, $42, $BB, $23, $22, $2A, $BB, $22, $20, $AA, $BB, $23, $33
	dc.b	$44, $BB, $23, $33, $54, $33, $33, $33, $54, $33, $33, $33, $44, $44, $32, $23, $44, $44, $32, $22, $44, $33, $33, $86, $44, $33, $39, $67, $43, $33, $38, $79
	dc.b	$43, $33, $37, $93, $33, $88, $96, $63, $B3, $98, $66, $66, $AB, $99, $98, $68, $BB, $88, $99, $89, $BB, $98, $77, $99, $B2, $89, $99, $92, $21, $28, $88, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, $33, 0, 0, 0, $33, $30, 0, 0, $32, $20, 0, 0, $20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$33, 0, 0, 0, $33, $30, 0, 0, $33, $33, 0, 0, $33, $33, $30, 0, $22, $33, $30, 0, $22, $22, $33, 0, $22, $22, $22, 0, $22, 0, 0, 0
	dc.b	0, 0, 0, 0, $30, 0, 0, 0, $33, 0, 0, 0, $33, $30, 0, 0, $23, $30, 0, 0, $22, $33, 0, 0, $22, $23, 0, 0, 2, $22, 0, 0
	dc.b	0, 0, 0, $DD, 0, 0, $D, $B2, 0, 0, $B, $B2, 0, 0, $B, $B2, 0, 0, $B, $B2, 0, 0, $D, $B2, 0, 0, $D, $D2, 0, 0, 0, $D2
	dc.b	0, 0, 0, 2, 0, 0, 0, $21, 0, 0, 0, $21, 0, 0, 2, $10, 0, 0, 2, $10, 0, 0, $21, 0, 0, $99, $21, $90, 8, $86, $68, $90
	dc.b	$2B, $DB, $D2, $BB, $2B, $DA, $D2, $2D, $2D, $AB, $D2, $2D, $22, $DD, $21, $22, $22, $22, $21, $22, $22, $22, $21, $22, $22, $22, $29, $92, $12, $21, $23, $90
	dc.b	$11, $12, $12, $30, 0, 2, $10, $23, 0, 2, $10, 2, 0, 2, $10, 0, 0, 2, $10, 0, 0, $92, $19, 0, 0, $98, $77, $80, 0, $99, $99, $99
	dc.b	0, 0, 0, 0, $B0, 0, 0, 0, $D0, 0, 0, 0, $D0, 0, 0, 0, $D0, 0, 0, 0, $D0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, $40, 0, 0, 0, $20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $88, 0, 0, $DD, $76, 0, $DD, $CC, $C6, $D, $DC, $CC, $C6, $E, $DC, $CC, $CC, 0, $11, $11, $11
	dc.b	9, $88, $89, $90, 8, $86, $78, $90, $DC, $99, $99, $10, $CC, $FC, $CC, $D1, $6C, $CC, $CC, $D1, $6C, $CC, $CC, $D1, $67, $CC, $CC, $D1, $11, $11, $11, $10
	dc.b	0, $99, $77, $89, 0, $1D, $DD, $DD, 1, $DC, $CC, $CD, 1, $DC, $CC, $CC, 1, $DC, $CC, $CC, 1, $DC, $CC, $CC, 0, $11, $11, $11, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, $D0, 0, 0, 0, $D0, 0, 0, 0, $D0, 0, 0, 0, $10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
byte_36D38:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 5, 0, 0, 0, 3, 0, 0, 0, 2, 0, 0, 0, 2
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 3, $34, 0, 0, $33, $34, $22, 3, $34, $45, $22, $34, $45, $54, $23, $44, $55, $53
	dc.b	$34, $45, $55, $55, $34, $45, $54, $45, $34, $45, $44, $44, $44, $54, $45, $54, $44, $44, $56, $65, $44, $43, $69, $15, $34, $43, $69, $15, $33, $26, $69, $14
	dc.b	$22, $36, $69, $14, $11, $66, $61, $43, $9B, $B6, $65, $6B, $1A, $A6, $66, $AA, $B, $AA, $AA, $AA, $D, $BB, $BB, $BB, 0, $DD, $BB, $BB, 0, 0, $DD, $32
	dc.b	0, 0, 0, 0, 0, $33, $33, $33, $33, $44, $33, $33, $44, $43, $33, $33, $44, $22, $33, $33, $42, $BB, $23, $22, $2A, $BB, $22, $20, $AA, $BB, $23, $33
	dc.b	$44, $BB, $23, $33, $54, $33, $33, $33, $54, $33, $33, $33, $44, $44, $32, $23, $44, $86, $32, $22, $44, $66, $32, $22, $44, $77, $32, $22, $43, $77, $32, $22
	dc.b	$49, $87, $22, $23, $68, $66, $72, $33, $98, $76, $62, $33, $99, $89, $82, $23, $88, $98, $82, $22, $98, $88, $92, $22, $89, $99, $22, $22, $87, $67, $80, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, $33, 0, 0, 0, $33, $30, 0, 0, $32, $20, 0, 0, $20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$33, 0, 0, 0, $33, $30, 0, 0, $33, $33, 0, 0, $33, $33, $30, 0, $22, $33, $30, 0, $22, $22, $33, 0, $22, $22, $22, 0, $22, 0, 0, 0
	dc.b	0, 0, 0, 0, $30, 0, 0, 0, $33, 0, 0, 0, $33, $30, 0, 0, $23, $30, 0, 0, $22, $33, 0, 0, $22, $23, 0, 0, 2, $22, 0, 0
	dc.b	0, 0, 0, $DD, 0, 0, $D, $B2, 0, 0, $B, $B2, 0, 0, $B, $B2, 0, 0, $B, $B2, 0, 0, $D, $B2, 0, 0, $D, $D2, 0, 0, 0, $D2
	dc.b	0, 0, 0, 2, 0, 0, 0, $21, 0, 0, 0, $21, 0, 0, 2, $10, 0, 0, 2, $10, 0, 0, $21, 0, 0, $99, $21, $90, 8, $86, $68, $90
	dc.b	$2B, $DD, $22, $BB, $2B, $AD, $22, $2D, $2D, $AD, $22, $2D, $22, $DD, $21, $22, $22, $22, $21, $22, $22, $22, $21, $22, $22, $22, $29, $92, $12, $21, $23, $90
	dc.b	$11, $12, $12, $30, 0, 2, $10, $23, 0, 2, $10, 2, 0, 2, $10, 0, 0, 2, $10, 0, 0, $92, $19, 0, 0, $98, $77, $80, 0, $99, $99, $99
	dc.b	0, 0, 0, 0, $B0, 0, 0, 0, $D0, 0, 0, 0, $D0, 0, 0, 0, $D0, 0, 0, 0, $D0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, $40, 0, 0, 0, $20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $88, 0, 0, $DD, $76, 0, $DD, $CC, $C6, $D, $DC, $CC, $C6, $E, $DC, $CC, $CC, 0, $11, $11, $11
	dc.b	9, $88, $89, $90, 8, $86, $78, $90, $DC, $99, $99, $10, $CC, $FC, $CC, $D1, $6C, $CC, $CC, $D1, $6C, $CC, $CC, $D1, $67, $CC, $CC, $D1, $11, $11, $11, $10
	dc.b	0, $99, $77, $89, 0, $1D, $DD, $DD, 1, $DC, $CC, $CD, 1, $DC, $CC, $CC, 1, $DC, $CC, $CC, 1, $DC, $CC, $CC, 0, $11, $11, $11, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, $D0, 0, 0, 0, $D0, 0, 0, 0, $D0, 0, 0, 0, $10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
byte_36FF8:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 5, 0, 0, 0, 3, 0, 0, 0, 2, 0, 0, 0, 2
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 3, $34, 0, 0, $33, $34, $22, 3, $34, $45, $22, $34, $45, $54, $23, $44, $55, $53
	dc.b	$34, $45, $55, $55, $34, $45, $54, $45, $34, $45, $44, $44, $44, $54, $45, $54, $44, $44, $56, $65, $44, $43, $69, $15, $34, $43, $69, $15, $33, $26, $96, $14
	dc.b	$22, $36, $97, $64, $11, $66, $69, $77, $9B, $B6, $65, $99, $1A, $A6, $69, $97, $B, $AA, $A9, $98, $D, $BB, $B9, $99, 0, $DD, $BB, $99, 0, 0, $DD, $39
	dc.b	0, 0, 0, 0, 0, $33, $33, $33, $33, $44, $33, $33, $44, $43, $33, $33, $44, $22, $33, $33, $42, $BB, $23, $22, $2A, $BB, $22, $20, $AA, $BB, $23, $33
	dc.b	$44, $BB, $23, $33, $54, $33, $33, $33, $54, $33, $33, $33, $44, $44, $32, $23, $44, $44, $32, $22, $33, $33, $32, $22, $33, $33, $32, $22, $33, $33, $32, $22
	dc.b	$33, $33, $22, $23, $33, $33, $22, $33, $68, $32, $22, $33, $66, $72, $22, $23, $76, $82, $22, $22, $88, $82, $12, $22, $99, $82, $22, $22, $98, $82, $20, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, $33, 0, 0, 0, $33, $30, 0, 0, $32, $20, 0, 0, $20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$33, 0, 0, 0, $33, $30, 0, 0, $33, $33, 0, 0, $33, $33, $30, 0, $22, $33, $30, 0, $22, $22, $33, 0, $22, $22, $22, 0, $22, 0, 0, 0
	dc.b	0, 0, 0, 0, $30, 0, 0, 0, $33, 0, 0, 0, $33, $30, 0, 0, $23, $30, 0, 0, $22, $33, 0, 0, $22, $23, 0, 0, 2, $22, 0, 0
	dc.b	0, 0, 0, $D8, 0, 0, $D, $B2, 0, 0, $B, $B2, 0, 0, $B, $B2, 0, 0, $B, $B2, 0, 0, $D, $B2, 0, 0, $D, $D2, 0, 0, 0, $D2
	dc.b	0, 0, 0, 2, 0, 0, 0, $21, 0, 0, 0, $21, 0, 0, 2, $10, 0, 0, 2, $10, 0, 0, $21, 0, 0, $99, $21, $90, 8, $86, $68, $90
	dc.b	$8D, $D2, $22, $BB, $DB, $D2, $22, $2D, $DB, $D2, $22, $2D, $2D, $D2, $21, $22, $22, $22, $21, $22, $22, $22, $21, $22, $22, $22, $29, $92, $12, $21, $23, $90
	dc.b	$11, $12, $12, $30, 0, 2, $10, $23, 0, 2, $10, 2, 0, 2, $10, 0, 0, 2, $10, 0, 0, $92, $19, 0, 0, $98, $77, $80, 0, $99, $99, $99
	dc.b	0, 0, 0, 0, $B0, 0, 0, 0, $D0, 0, 0, 0, $D0, 0, 0, 0, $D0, 0, 0, 0, $D0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, $40, 0, 0, 0, $20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $88, 0, 0, $DD, $76, 0, $DD, $CC, $C6, $D, $DC, $CC, $C6, $E, $DC, $CC, $CC, 0, $11, $11, $11
	dc.b	9, $88, $89, $90, 8, $86, $78, $90, $DC, $99, $99, $10, $CC, $FC, $CC, $D1, $6C, $CC, $CC, $D1, $6C, $CC, $CC, $D1, $67, $CC, $CC, $D1, $11, $11, $11, $10
	dc.b	0, $99, $77, $89, 0, $1D, $DD, $DD, 1, $DC, $CC, $CD, 1, $DC, $CC, $CC, 1, $DC, $CC, $CC, 1, $DC, $CC, $CC, 0, $11, $11, $11, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, $D0, 0, 0, 0, $D0, 0, 0, 0, $D0, 0, 0, 0, $10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
byte_372B8:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $33, 0, 0, $33, $44
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $33, 0, 0, 0, $44, $33, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8
	dc.b	0, 0, 0, $88, 0, 0, 8, $87, 0, 0, 8, $77, 0, 0, 8, $87, 0, 0, 0, $88, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 5, 0, 0, 0, 4, 0, 0, 0, 3, 0, 0, 0, 3, 0, 0, 0, 2, 0, 0, 0, 3, 0, 0, 0, 3, $70, $70, 0, 3
	dc.b	$76, $86, 0, 4, $77, $68, $60, 4, $77, $66, $60, 4, $77, $76, $70, 5, $77, $77, 0, 5, $88, $86, $70, 2, $87, $79, $90, 0, 0, $9B, $A0, 0
	dc.b	$44, $33, $34, $55, $54, $43, $44, $55, $45, $43, $34, $55, $34, $43, $23, $45, $33, $34, $23, $45, $24, $55, $13, $45, $25, $54, $32, $45, $45, $54, $21, $35
	dc.b	$45, $43, $22, $25, $54, $32, $22, $32, $54, $22, $23, $31, $43, $22, $23, $45, $32, $12, $23, $55, $21, $34, $23, $45, $34, $54, $22, $45, $45, $43, $22, $44
	dc.b	0, 0, $BA, 4, 0, 0, $B, $A4, 0, 0, 0, $B4, 0, 0, 0, 4, 0, 0, 0, 4, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$55, $43, $22, $44, $54, $33, $22, $24, $43, $32, $22, $24, $43, $22, $54, $21, $32, $B5, $43, $22, $2B, $45, $32, $45, 0, $52, $14, $45, 0, $21, $24, $45
	dc.b	$44, $22, $34, $55, $42, $22, $33, $45, $42, $22, $23, $34, $12, $45, $22, $34, $22, $34, $5B, $23, $54, $23, $54, $B2, $54, $41, $25, 0, $54, $42, $12, 0
	dc.b	$40, $AB, 0, 0, $4A, $B0, 0, 0, $4B, 0, 0, 0, $40, 0, 0, 0, $40, 0, 0, 0, $20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 1, $23, $44, 0, 1, $22, $33, 0, 1, $22, $22, 0, 0, $32, $25, 0, 0, $41, $21, 0, 0, $42, $11, 0, 0, $32, 0, 0, 3, $33, 0
	dc.b	0, 4, $30, 0, 0, 4, $30, 0, 0, 4, $30, 0, 0, 4, $30, 0, 8, $76, $67, 0, 9, $99, $99, 0, $88, $87, $79, 0, $98, $76, $68, 0
	dc.b	$44, $32, $10, 0, $33, $22, $10, 0, $22, $22, $10, 0, $52, $23, 0, 0, $12, $14, 0, 0, $11, $24, 0, 0, 0, $23, 0, 0, 0, $33, $30, 0
	dc.b	0, 3, $40, 0, 0, 3, $40, 0, 0, 3, $40, 0, 0, 3, $40, 0, 0, $76, $67, $80, 0, $99, $99, $90, 0, $97, $78, $88, 0, $86, $67, $89
	dc.b	0, 0, 0, 8, 0, 0, 0, $D, 0, 0, 0, $7D, 0, 0, 7, $7D, 0, 0, 8, $8D, 0, 0, $D8, $88, 0, 0, $DD, $8E, 0, 0, $EE, $EE
	dc.b	$DD, $DE, $E1, 0, $DD, $DF, $CC, $10, $DD, $CC, $CC, $10, $DD, $CC, $CC, $10, $DD, $CC, $CC, $10, $DD, $CC, $DE, $10, $EE, $11, $11, 0, $EE, $EE, 0, 0
	dc.b	0, $1E, $ED, $DD, 1, $CC, $FD, $DD, 1, $CC, $CC, $DD, 1, $CC, $CC, $DD, 1, $CC, $CC, $DD, 1, $ED, $CC, $DD, 0, $11, $11, $EE, 0, 0, $EE, $EE
	dc.b	$80, 0, 0, 0, $D0, 0, 0, 0, $D7, 0, 0, 0, $D7, $70, 0, 0, $D8, $80, 0, 0, $88, $8D, 0, 0, $E8, $DD, 0, 0, $EE, $EE, 0, 0
byte_37538:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $79, 0, 0, 0, 7, 0, 0, 7, 7, 0, 0, 0, $78
	dc.b	0, 0, 0, $87, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, $70, 0, 0, $79, $70, 0, 0, $79, $70, 6, 0, $87, $78, 6, 0, $87, $66, $68, 0, $77, $77, $68, 0
	dc.b	$77, $77, $80, 0, $87, $77, $70, 0, $88, $88, $89, 0, 8, $88, $79, $55, 0, $96, $90, $24, 0, $99, 0, $22, 0, $B, $A0, 2, 0, 0, $BA, 2
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $45, 0, 0, 4, $45, 0, 0, 4, $42
	dc.b	0, 0, $44, $22, 3, $30, $33, $22, 2, $43, $32, $22, $44, $33, $32, $22, $44, $44, $12, $22, $24, $44, $21, $21, $22, $43, $32, $34, $22, $32, $23, $45
	dc.b	0, 0, $BA, 0, 0, 0, $BA, $A0, 0, 0, $B, $A0, 0, 0, 0, $BA, 0, 0, 0, $B3, 0, 0, 0, $34, 0, 0, 0, $45, 0, 0, 3, $54
	dc.b	0, 0, 2, $22, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $C, 0, 0, 0, $CC, 0, 0, $D, $11
	dc.b	0, 0, 1, $DD, 0, 0, $1D, $EE, 0, 0, $1E, $EE, 0, 0, $EE, $EE, 0, $E, $EE, $EE, 0, $E, $EE, $EE, 0, $E, $EE, $EE, 0, $E, $EE, $EE
	dc.b	$22, $22, $13, $55, $22, $21, $23, $55, $21, $12, $22, $35, $13, $33, $12, $22, $44, $43, $31, $22, $55, $43, $31, $12, $44, $33, $32, $11, $33, $22, $12, $22
	dc.b	$22, $21, $12, $22, $D, $B3, $33, $32, $D, $44, $33, $32, 4, $43, $32, $23, 5, $32, $22, $34, 3, $22, $24, $44, 0, $11, $24, $45, 0, 1, $34, $41
	dc.b	0, 1, $33, $41, 0, 1, $22, $31, 0, 1, $22, $21, 0, 0, $32, $21, 0, 0, $41, $22, $CC, $64, $10, $11, $CF, $C6, $10, 0, $1C, $C7, 0, 0
	dc.b	$D1, $C8, 0, 0, $D1, $D8, 0, 0, $D1, $D0, 0, 0, $D1, $D0, 0, 0, $D1, 0, 0, 0, $E1, 0, 0, 0, $E1, 0, 0, 0, $10, 0, 0, 0
	dc.b	0, $E, $EE, $EE, 0, $E, $EE, $EE, 0, $E, $EE, $EE, 0, $E, $EE, $E1, 0, $E, $EE, $E1, 0, 1, $EE, $E1, 0, 1, $EE, $10, 0, 0, $11, 0
	dc.b	$10, 0, 0, 0, $10, 0, 0, 0, $10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
byte_37738:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 5, 0, 0, 0, 3, 0, 0, 0, 2, 0, 0, 0, 2
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 3, $34, 0, 0, $33, $34, $22, 3, $34, $45, $22, $34, $45, $54, $23, $44, $55, $53
	dc.b	$34, $45, $55, $55, $34, $45, $54, $45, $34, $45, $44, $44, $44, $54, $45, $54, $44, $44, $56, $65, $44, $43, $69, $15, $34, $43, $69, $15, $33, $26, $69, $14
	dc.b	$22, $36, $69, $14, $11, $66, $61, $43, $9B, $B6, $65, $6B, $1A, $A6, $66, $AA, $B, $AA, $AA, $AA, $D, $BB, $BB, $BB, 0, $DD, $BB, $BB, 0, 0, $DD, $32
	dc.b	0, 0, 0, 0, 0, $33, $33, $33, $33, $44, $33, $33, $44, $43, $33, $33, $44, $22, $33, $33, $42, $BB, $23, $22, $2A, $BB, $22, $20, $AA, $BB, $23, $33
	dc.b	$44, $BB, $23, $33, $54, $33, $33, $33, $54, $33, $33, $33, $44, $44, $32, $23, $44, $44, $32, $22, $44, $33, $32, $22, $44, $33, $32, $22, $43, $33, $32, $22
	dc.b	$43, $33, $22, $23, $33, $33, $22, $33, $B3, $32, $22, $33, $AB, $22, $22, $23, $BB, $22, $22, $22, $BB, $22, $12, $22, $B2, $11, $22, $22, $21, $22, $20, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, $33, 0, 0, 0, $33, $30, 0, 0, $32, $20, 0, 0, $20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$33, 0, 0, 0, $33, $30, 0, 0, $33, $33, 0, 0, $33, $33, $30, 0, $22, $33, $30, 0, $22, $22, $33, 0, $22, $22, $22, 0, $22, 0, 0, 0
	dc.b	0, 0, 0, 0, $30, 0, 0, 0, $33, 0, 0, 0, $33, $30, 0, 0, $23, $30, 0, 0, $22, $33, 0, 0, $22, $23, 0, 0, 2, $22, 0, 0
	dc.b	0, 0, 0, $DD, 0, 0, $D, $BD, 0, 0, $B, $BB, 0, 0, $8B, $AB, 0, 0, $9B, $BB, 0, 0, $9B, $BB, 0, 0, $9D, $BD, 0, 0, $99, $D8
	dc.b	$22, $BA, $A2, 0, $D2, $DD, $BA, $20, $D2, $22, $DB, $B0, $D7, $72, $2B, $D2, $D2, $87, $7B, $D2, $D7, $67, $87, $D2, $76, $67, $98, $72, $77, $77, $79, $90
	dc.b	0, 0, 9, $92, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, $8D, 0, $D, $D7, $6C, $D, $DC, $CC, $66, $DD, $CC, $CC, $66, $ED, $CC, $CC, $C6, $11, $11, $11, $11
	dc.b	$88, $77, $89, $30, $98, $78, $90, $23, $19, $99, $10, 2, $10, 2, $10, 0, $10, 2, $10, 0, $21, $78, $19, 0, $27, $68, $97, $80, $76, $89, $79, $90
	dc.b	$98, $66, $7D, $D0, $77, $DD, $DD, $DD, $CC, $CC, $DD, $DD, $CC, $CC, $CD, $DD, $CC, $CC, $DD, $11, $CC, $DD, $11, $EE, $7D, $11, $11, $11, $11, $10, 0, 0
	dc.b	0, 0, 0, 0, $40, 0, 0, 0, $20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, $D0, 0, 0, 0, $10, 0, 0, 0, $E0, 0, 0, 0, $E0, 0, 0, 0, $10, 0, 0, 0, 0, 0, 0, 0
byte_379B8:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 5, 0, 0, 0, 3, 0, 0, 0, 2, 0, 0, 0, 2
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 3, $34, 0, 0, $33, $34, $22, 3, $34, $45, $22, $34, $45, $54, $23, $44, $55, $53
	dc.b	$34, $45, $55, $55, $34, $45, $54, $45, $34, $45, $44, $44, $44, $54, $45, $54, $44, $44, $5A, $A5, $44, $43, $AA, $A5, $34, $43, $69, $15, $33, $26, $69, $14
	dc.b	$22, $36, $69, $14, $11, $66, $61, $43, $9B, $B6, $65, $6B, $1A, $A6, $66, $AA, $B, $AA, $AA, $AA, $D, $BB, $BB, $BB, 0, $DD, $BB, $BB, 0, 0, $DD, $32
	dc.b	0, 0, 0, 0, 0, $33, $33, $33, $33, $44, $33, $33, $44, $43, $33, $33, $44, $22, $33, $33, $42, $BB, $23, $22, $2A, $BB, $22, $20, $AA, $BB, $23, $33
	dc.b	$44, $BB, $23, $33, $54, $33, $33, $33, $54, $33, $33, $33, $44, $44, $32, $23, $44, $44, $32, $22, $44, $33, $32, $22, $44, $33, $32, $22, $43, $33, $32, $22
	dc.b	$43, $33, $22, $23, $33, $33, $22, $33, $B3, $32, $22, $33, $AB, $22, $22, $23, $BB, $22, $22, $22, $BB, $22, $12, $22, $B2, $11, $22, $22, $21, $22, $20, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, $33, 0, 0, 0, $33, $30, 0, 0, $32, $20, 0, 0, $20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$33, 0, 0, 0, $33, $30, 0, 0, $33, $33, 0, 0, $33, $33, $30, 0, $22, $33, $30, 0, $22, $22, $33, 0, $22, $22, $22, 0, $22, 0, 0, 0
	dc.b	0, 0, 0, 0, $30, 0, 0, 0, $33, 0, 0, 0, $33, $30, 0, 0, $23, $30, 0, 0, $22, $33, 0, 0, $22, $23, 0, 0, 2, $22, 0, 0
	dc.b	0, 0, 0, $DD, 7, $77, $D, $BD, $78, $88, $7B, $BB, $78, $88, $8B, $AB, $78, $88, $9B, $BB, 9, $88, $9B, $BB, 0, $99, $D, $BD, 0, 0, 0, $DD
	dc.b	0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, $8D, 0, $D, $D7, $6C, $D, $DC, $CC, $66, $DD, $CC, $CC, $66, $ED, $CC, $CC, $C6, $11, $11, $11, $11
	dc.b	$22, $BB, $22, $86, $D2, $DB, $B2, $87, $D2, $22, $76, $77, $D2, $22, $66, $66, $D2, $27, $67, $77, $D2, $27, $77, $77, $D2, $29, $77, $77, $22, $22, $99, $79
	dc.b	$22, $22, $12, $99, $21, 2, $10, $23, $10, 2, $10, 2, $10, 2, $10, 0, $10, 2, $10, 0, $21, $78, $19, 0, $27, $68, $97, $80, $76, $89, $79, $90
	dc.b	$98, $66, $7D, $D0, $77, $DD, $DD, $DD, $CC, $CC, $DD, $DD, $CC, $CC, $CD, $DD, $CC, $CC, $DD, $11, $CC, $DD, $11, $EE, $7D, $11, $11, $11, $11, $10, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $70, 0, 0, 0, $79, 0, 0, 0, $79, 0, 0, 0, $97, 0, 0, 0, $97, 0, 0, 0
	dc.b	$70, 0, 0, 0, $40, 0, 0, 0, $20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, $D0, 0, 0, 0, $10, 0, 0, 0, $E0, 0, 0, 0, $E0, 0, 0, 0, $10, 0, 0, 0, 0, 0, 0, 0
byte_37C58:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 2
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 5, 0, 0, 0, 3, 0, 0, 0, 2
	dc.b	0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, $77, 0, 0, 7, $77
	dc.b	0, 0, 8, $77, 0, 0, 0, $88, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 3, $34, 0, 0, $33, $34, $22, 3, $34, $45, $22, $34, $45, $54
	dc.b	$23, $44, $55, $53, $34, $45, $55, $55, $34, $45, $54, $45, $34, $45, $44, $44, $44, $54, $45, $54, $44, $44, $5A, $A5, $44, $43, $AA, $A5, $34, $43, $69, $B5
	dc.b	$33, $26, $69, $14, $22, $36, $69, $14, $11, $66, $61, $43, $9B, $B6, $65, $6B, $1A, $A6, $66, $AA, $B, $AA, $AA, $AA, $7D, $BB, $BB, $BB, $77, $DD, $BB, $BB
	dc.b	$77, $78, $DD, $32, $78, $79, $D, $BD, $87, $9B, $DB, $BB, 0, $9D, $DB, $AB, 0, 0, $B, $BB, 0, 0, $B, $BB, 0, 0, $D, $BD, 0, 0, 0, $DD
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, $33, $33, $33, $33, $44, $33, $33, $44, $43, $33, $33, $44, $22, $33, $33, $42, $BB, $23, $22, $2A, $BB, $22, $20
	dc.b	$AA, $BB, $23, $33, $44, $BB, $23, $33, $54, $33, $33, $33, $54, $33, $33, $33, $44, $44, $32, $23, $44, $44, $32, $22, $44, $33, $32, $22, $44, $33, $32, $22
	dc.b	$43, $33, $32, $22, $43, $33, $22, $23, $33, $33, $22, $33, $B3, $32, $22, $33, $AB, $22, $22, $23, $BB, $22, $22, $22, $BB, $22, $12, $22, $B2, $11, $22, $22
	dc.b	$21, $22, $BA, 0, $D2, $22, $DB, $AA, $D2, $22, $22, $BB, $D2, $22, $22, $22, $D2, $22, $22, $22, $D2, $22, $22, $22, $D2, $22, $22, $22, $22, $22, $23, 2
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $33, 0, 0, 0, $33, $30, 0, 0, $32, $20, 0, 0, $20, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, $33, 0, 0, 0, $33, $30, 0, 0, $33, $33, 0, 0, $33, $33, $30, 0, $22, $33, $30, $30, $22, $22, $33, $20, $22, $22, $22, 0
	dc.b	$22, 0, 0, 0, 0, 0, 0, 0, $30, 0, 0, 0, $33, 7, 0, 0, $33, $37, 0, $77, $23, $76, $76, $77, $22, $66, $66, $78, $27, $86, $67, $89
	dc.b	7, $88, $89, $90, $97, $99, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, $8D, 0, $D, $D7, $6C, $D, $DC, $CC, $66, $DD, $CC, $CC, $66, $ED, $CC, $CC, $C6, $11, $11, $11, $11
	dc.b	$22, $22, $12, $30, $21, 2, $10, $23, $10, 2, $10, 2, $10, 2, $10, 0, $10, 2, $10, 0, $21, $78, $19, 0, $27, $68, $97, $80, $76, $89, $79, $90
	dc.b	$98, $66, $7D, $D0, $77, $DD, $DD, $DD, $CC, $CC, $DD, $DD, $CC, $CC, $CD, $DD, $CC, $CC, $DD, $11, $CC, $DD, $11, $EE, $7D, $11, $11, $11, $11, $10, 0, 0
	dc.b	0, 0, 0, 0, $40, 0, 0, 0, $20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, $D0, 0, 0, 0, $10, 0, 0, 0, $E0, 0, 0, 0, $E0, 0, 0, 0, $10, 0, 0, 0, 0, 0, 0, 0
byte_37F18:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $20, 0, 0, $33, $20, 0, 3, $34, $22, 0, $33, $34, $22, 3, $34, $45, $22, $34, $45, $54
	dc.b	0, 0, 3, $33, 0, $33, $33, $33, $33, $33, $33, $33, $33, $42, $33, $32, $44, $2B, $33, $32, $42, $AB, $23, $20, $42, $AB, $23, $20, $2A, $BB, $22, $33
	dc.b	$33, 0, 0, 0, $32, 0, 0, 0, $20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $33, $30, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 5, 0, 0, 0, 3, 0, 0, 0, 2
	dc.b	0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, $77, 0, 0, 7, $77
	dc.b	0, 0, 8, $77, 0, 0, 0, $88, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$23, $44, $55, $53, $34, $45, $55, $55, $34, $45, $54, $45, $34, $45, $44, $44, $44, $54, $45, $54, $44, $44, $5A, $A5, $44, $43, $AA, $A5, $34, $43, $69, $B5
	dc.b	$33, $26, $69, $14, $22, $36, $69, $14, $11, $66, $61, $43, $9B, $B6, $65, $6B, $1A, $A6, $66, $AA, $B, $AA, $AA, $AA, $7D, $BB, $BB, $BB, $77, $DD, $BB, $BB
	dc.b	$77, $78, $DD, $32, $78, $79, $D, $BD, $87, $9B, $DB, $BB, 0, $9D, $DB, $AB, 0, 0, $B, $BB, 0, 0, $B, $BB, 0, 0, $D, $BD, 0, 0, 0, $DD
	dc.b	$AA, $BB, $23, $33, $44, $BB, $23, $33, $54, $33, $33, $33, $54, $33, $33, $33, $44, $44, $32, $22, $44, $44, $32, $22, $44, $33, $32, $22, $44, $33, $32, $22
	dc.b	$43, $33, $32, $22, $43, $33, $22, $23, $33, $33, $22, $33, $B3, $32, $22, $32, $AB, $22, $22, $22, $BB, $22, $22, $22, $BB, $22, $12, $22, $B2, $11, $22, $20
	dc.b	$21, $22, $BA, 0, $D2, $22, $DB, $AA, $D2, $22, $22, $BB, $D2, $22, $22, $22, $D2, $22, $22, $22, $D2, $22, $22, $22, $D2, $22, $22, $23, $22, $22, $23, $32
	dc.b	$33, $33, $30, 0, $33, $33, $33, $30, $33, $33, $22, $20, $22, $22, $20, 0, $22, $20, 0, 0, $22, 0, 0, 0, $20, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, $33, 0, 0, 0, $33, $33, 0, 0, $22, $37, $33, 0, $22, $27, $22, $77, $22, $76, $76, $77, $20, $66, $66, $78, 7, $86, $67, $89
	dc.b	7, $88, $89, $90, $97, $99, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, $42, 0, 0, 0, $42, 0, 0, 0, $20, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$22, $22, $12, $22, $21, 2, $10, 0, $10, 2, $10, 0, $10, 2, $10, 0, $10, 2, $10, 0, $21, $78, $19, 0, $27, $68, $97, $80, $76, $89, $79, $90
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, $8D, 0, $D, $D7, $6C, $D, $DC, $CC, $66, $DD, $CC, $CC, $66, $ED, $CC, $CC, $C6, $11, $11, $11, $11
	dc.b	$98, $66, $7D, $D0, $77, $DD, $DD, $DD, $CC, $CC, $DD, $DD, $CC, $CC, $CD, $DD, $CC, $CC, $DD, $11, $CC, $DD, $11, $EE, $7D, $11, $11, $11, $11, $10, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, $D0, 0, 0, 0, $10, 0, 0, 0, $E0, 0, 0, 0, $E0, 0, 0, 0, $10, 0, 0, 0, 0, 0, 0, 0
byte_38198:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $20, 0, 0, 0, 0, 0, 0, 0, $20, 0, 0, 3, $20, 0, 0, $33
	dc.b	$22, 0, 3, $34, $22, 0, $33, $34, $22, 3, $34, $45, $22, $34, $45, $54, $23, $44, $55, $53, $34, $45, $55, $55, $34, $45, $54, $45, $34, $45, $44, $44
	dc.b	0, 0, 0, 3, 0, 0, 0, $33, 0, 0, 3, $32, 0, 0, $33, $32, 0, $33, $33, $32, 3, $32, $33, $32, $33, $2B, $33, $20, $33, $2B, $33, $20
	dc.b	$42, $BB, $32, $20, $42, $AB, $22, $20, $2A, $BB, $22, 0, $2A, $BB, $22, $33, $AB, $BB, $23, $33, $44, $BB, $23, $33, $54, $33, $33, $33, $54, $33, $33, $33
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0
	dc.b	0, 0, $32, 0, 0, 3, $32, 0, 3, $33, $20, 0, $33, $33, $20, 0, $33, $32, 0, 0, $33, $22, 0, 0, $32, $20, 0, 0, $22, 0, $20, 0
	dc.b	0, 0, 0, 3, 0, 0, 0, 5, 0, 0, 0, 3, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8
	dc.b	0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, $77, 0, 0, 7, $77, 0, 0, 8, $77, 0, 0, 0, $88, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$44, $54, $45, $54, $44, $44, $5A, $A5, $44, $43, $AA, $A5, $34, $43, $69, $B5, $33, $26, $69, $14, $22, $36, $69, $14, $11, $66, $61, $43, $9B, $B6, $65, $6B
	dc.b	$1A, $A6, $66, $AA, $B, $AA, $AA, $AA, $7D, $BB, $BB, $BB, $77, $DD, $BB, $BB, $77, $78, $DD, $32, $78, $79, $D, $BD, $87, $9B, $DB, $BB, 0, $9D, $DB, $AB
	dc.b	$44, $44, $32, $22, $44, $44, $32, $22, $44, $33, $32, $22, $44, $33, $32, $22, $43, $33, $32, $23, $43, $33, $22, $23, $33, $33, $22, $32, $B3, $32, $22, $32
	dc.b	$AB, $22, $22, $22, $BB, $22, $22, $22, $BB, $22, $12, $22, $B2, $11, $22, $20, $21, $22, $BA, 0, $D2, $22, $DB, $AA, $D2, $22, $22, $BB, $D2, $22, $22, $24
	dc.b	$22, 3, $20, 0, $20, $32, 0, 0, $23, $22, 0, 0, $33, $20, 0, 0, $32, $20, 0, 0, $22, 0, 0, 0, $20, 0, 0, 0, $20, 7, 0, 0
	dc.b	0, 7, 0, $77, 0, $76, $76, $77, 0, $66, $66, $78, 7, $86, $67, $89, 7, $88, $89, $90, $97, $99, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, $B, $BB, 0, 0, $B, $BB, 0, 0, $D, $BD, 0, 0, 0, $DD, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2
	dc.b	0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, $8D, 0, $D, $D7, $6C
	dc.b	$D2, $22, $22, $23, $D2, $22, $22, $23, $D2, $22, $22, $33, $22, $22, $23, $22, $22, $22, $12, 2, $21, 2, $10, 0, $10, 2, $10, 0, $10, 2, $10, 0
	dc.b	$10, 2, $10, 0, $21, $78, $19, 0, $27, $68, $97, $80, $76, $89, $79, $90, $98, $66, $7D, $D0, $77, $DD, $DD, $DD, $CC, $CC, $DD, $DD, $CC, $CC, $CD, $DD
	dc.b	$20, 0, 0, 0, $20, 0, 0, 0, $20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $D0, 0, 0, 0, $10, 0, 0, 0
byte_38418:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, $70, 0
	dc.b	0, 0, 0, 0, 0, 4, 0, 0, 0, 5, 0, 0, 0, $43, $40, 0, 0, $42, $40, 0, 4, $32, $34, 0, 4, $32, $34, 0, $43, $22, $23, $40
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $77, 0, 0
	dc.b	7, $79, $67, 0, 9, $86, $96, $80, $87, $97, $66, $68, $98, $77, $66, $77, $88, $97, $77, $77, 9, $88, $77, $78, 0, 9, $87, $88, 0, 0, $99, $86
	dc.b	0, 0, 9, $6D, 0, 0, 0, $9D, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, $55, $33, $30, $77, $34, $44, $33, $79, $23, $34, $43, $70, 2, $33, $44, $80, 2, $22, $34, $80, 2, $22, $23, $90, 0, $22, $22, $80, 0, $22, $22
	dc.b	$D0, 0, $22, $21, $BA, 0, $21, $12, $B, $A0, $55, $33, 0, $B5, $55, $43, 0, $33, $34, $44, 0, $22, $22, $33, 0, 0, $22, $21, 0, 0, 2, $21
	dc.b	$43, $22, $23, $40, $32, $22, $22, $33, $32, $22, $22, $33, $12, $22, $22, $14, $21, $25, $21, $24, $32, $54, $52, $33, $23, $42, $43, $22, $13, $32, $33, $12
	dc.b	$23, $22, $23, $21, $23, $22, $23, $22, $12, $22, $22, $13, $31, $21, $21, $33, $31, $11, $11, $34, $32, $11, $12, $33, $23, $42, $43, $21, $45, $33, $35, $41
	dc.b	$33, $35, $50, 0, $34, $44, $37, $70, $44, $33, $29, $78, $43, $32, 0, $77, $32, $22, 0, $87, $22, $22, 0, $88, $22, $20, 0, $98, $22, $20, 0, $86
	dc.b	$22, $20, 0, $DD, $11, $20, $A, $BD, $35, $50, $AB, 0, $45, $55, $B0, 0, $44, $33, $30, 0, $32, $22, $20, 0, $22, $20, 0, 0, $22, 0, 0, 0
	dc.b	7, $69, $77, 0, $86, $96, $89, 0, $66, $67, $97, $80, $76, $67, $78, $90, $77, $77, $98, $80, $77, $78, $89, 0, $87, $89, 0, 0, $89, $90, 0, 0
	dc.b	$69, 0, 0, 0, $90, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, $24, 0, 0, 0, $25, 0, 0, 0, 5, 0, 0, 0, 1, 0, 0, 0, 2, 0, 0, 4, $43, 0, 0, 2, $13, 0, 0, 2, $11
	dc.b	$54, $24, $24, $54, $42, $44, $42, $45, $21, $34, $31, $25, $12, $23, $22, $11, $22, $22, $22, $25, $22, $22, $33, $41, $32, $23, $11, $12, $12, $21, $22, $22
	dc.b	$20, 0, 0, 0, $20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, $21, 0, 0, 0, $21, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, $87, 0, 0, 0, $99, 0, 0, 8, $88, 0, 0, 9, $87
	dc.b	1, $11, $11, $20, 0, 0, 1, $20, $10, 0, 1, $20, $10, 0, 1, $20, $66, $70, 1, $20, $99, $90, 1, $20, $77, $90, 1, $20, $66, $80, 1, $20
	dc.b	0, 0, $8D, $DD, 0, $D7, $DD, $DD, $D, $D7, $DD, $DC, $E, $D8, $DD, $DC, $E, $E8, $DD, $DC, 0, $EE, $DD, $EE, 0, 0, $EE, $EE, 0, 0, 0, 0
	dc.b	$EE, $10, $87, $78, $FC, $C1, $99, $99, $CC, $C1, $9C, $C9, $CC, $C1, $DC, $CD, $CC, $C1, $DC, $CC, $11, $10, $DC, $CC, $EE, 0, $D1, $1E, 0, 0, $1E, $E1
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $D0, 0, 0, 0, $D0, 0, 0, 0, $D0, 0, 0, 0, $D0, 0, 0, 0, $D0, 0, 0, 0
	dc.b	0, 0, $EE, $EE, 0, 0, $EE, $EE, 0, 0, $EE, $EE, 0, 0, $EE, $EE, 0, 0, $E, $EE, 0, 0, $E, $EE, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$D0, 0, 0, 0, $E0, 0, 0, 0, $E0, 0, 0, 0, $E0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
byte_386F8:
	dc.b	0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 3, $44, $45, $40, $34, $44, $34, $55, $43, $43, $33, $44, $34, $33, $33, $33, $44, $22, 3, $34, $44, $12
	dc.b	0, 0, 0, 0, $44, $43, 0, 0, $45, $55, $43, 0, $44, $44, $55, $40, $33, $44, $32, $20, $22, $22, $22, $30, $22, $22, $22, $40, $22, $22, $23, $44
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 4, 0, 0, 0, 4, 0, 0, 0, 4
	dc.b	0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 0, 0, 0, 7
	dc.b	0, 0, 0, 8, 0, 0, 0, 8, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	3, $45, $54, $41, $34, $55, $54, $43, $34, $55, $54, $33, $33, $44, $55, $43, $33, $33, $34, $53, $33, $32, $23, $53, $33, $22, $22, $23, $34, $34, $32, $23
	dc.b	$33, $44, $43, $22, $33, $45, $54, $32, $34, $44, $54, $32, $33, $44, $55, $43, $B, $24, $45, $43, $D, $B2, $44, $43, 0, $DB, $23, $43, 0, $D, $12, $24
	dc.b	0, $A, $B2, $34, 0, $AB, $D2, $34, $A, $BD, $22, $34, $A, $D2, $22, $35, $B, $D2, $22, $35, $6B, $D7, $22, $23, $7D, $D6, $92, $22, $7D, $D7, $92, $22
	dc.b	$91, $97, $90, $21, $89, $79, $90, $21, $99, $99, $90, $21, $99, $99, 0, $21, 0, 0, 0, $21, 0, 0, 0, $21, 0, 9, $87, $77, 0, 9, $99, $99
	dc.b	$22, $22, $24, $44, $22, $22, $34, $44, $21, $23, $33, $44, $23, $32, $33, $34, $34, $33, $22, $33, $44, $43, $32, $22, $45, $54, $32, $12, $44, $55, $43, $22
	dc.b	$34, $45, $44, $33, $23, $34, $54, $44, $22, $33, $44, $44, $22, $22, $34, $44, $22, $22, $22, $23, $21, $21, $11, $23, $22, $22, $22, $22, $42, $32, $20, 0
	dc.b	$42, $33, $32, 0, $32, $43, $33, $B0, $32, $23, $33, $DB, $32, $22, $33, $D, $32, $22, $33, $D, $22, $22, $23, $7D, $23, $22, $12, $8B, $13, $12, $88, $9D
	dc.b	1, $32, $98, $91, 1, $42, $99, $89, 0, $11, 9, $99, 0, $21, 0, 0, 0, $21, 0, 0, 0, $21, 0, 0, $98, $77, $88, 0, $99, $99, $99, 0
	dc.b	$40, 0, 0, 0, $40, 0, 0, 0, $44, 0, 0, 0, $44, 0, 0, 0, $44, $40, 0, 0, $23, $40, 0, 0, $22, $20, 0, 0, 0, 0, 0, 0
	dc.b	$30, 0, 0, 0, $30, 0, 0, 0, $43, 0, 0, 0, $44, 0, 0, 0, $44, $30, 0, 0, $34, $40, 0, 0, $33, $40, 0, 0, $22, $20, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $B0, 0, 0, 0, $B0, 0, 0, 0, $B0, 0, 0, 0, $D8, 0, 0, 0, $98, 0, 0, 0
	dc.b	$89, 0, 0, 0, $90, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $D, 0, 0, $D, $D8, 0, 0, $ED, $D8, 0, 0, $ED, $D8, 0, 0, $EE, $EE, 0, 0, 0, $EE
	dc.b	0, $99, $87, $66, 0, $7D, $DD, $EE, $87, $DD, $DD, $FC, $7D, $DD, $DC, $CC, $7D, $DD, $DC, $CC, $8D, $DD, $DC, $CC, $9D, $DD, $DD, $CC, $EE, $EE, $E1, $11
	dc.b	$89, $97, $78, $90, $1D, $DD, $DD, $D0, $C1, $DD, $FC, $DD, $C1, $DC, $CC, $CD, $C1, $DC, $CC, $CD, $C1, $DC, $CC, $CD, $C1, $DD, $CC, $D1, $11, $11, $11, $10
byte_38998:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 4, 0, 0, 0, 4, 0, 0, 0, 5, 0, 0, 0, 5, 0, 0, 0, 5
	dc.b	0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $33, $40, 0, $33, $44, $44, $43, $44, $45, $34, $44, $44, $44, $33, $44, $44, $43, $33, $34, $55, $54
	dc.b	$33, $44, $55, $55, $44, $45, $44, $44, $44, $45, $44, $44, $34, $44, $33, $33, $34, $33, $33, $22, $43, $33, $32, $22, $53, $33, $33, $33, $53, $33, $34, $44
	dc.b	$53, $33, $34, $45, $43, $33, $23, $34, $AA, $D3, $32, $33, $BB, $BD, $32, $23, $BB, $BD, $32, $22, $B, $BB, $D2, $22, 0, $DB, $D2, $22, 0, $D, $D2, $22
	dc.b	0, 0, 0, 0, 3, $44, $44, 0, $34, $45, $55, $44, $45, $54, $44, $55, $54, $33, $32, $22, $33, $32, $22, $22, $33, $22, $22, $20, $32, $22, $22, $30
	dc.b	$43, $22, $21, $33, $54, $32, $21, $23, $45, $33, $12, $22, $44, $53, $43, $22, $23, $53, $44, $42, $22, $22, $34, $44, $21, $22, $23, $44, $32, $12, $22, $34
	dc.b	$43, $22, $22, $23, $44, $32, $22, $22, $44, $32, $22, $22, $34, $32, $22, $22, $34, $41, $11, $12, $24, $42, $22, $21, $21, $52, $22, 0, $42, $32, $10, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, $30, 0, 0, 0, $43, 0, 0, 0, $22, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$30, 0, 0, 0, $33, 0, 0, 0, $23, $30, 0, 0, $22, $33, 0, 0, $22, $22, $30, 0, $22, $22, $20, 0, $30, 0, 0, 0, $40, 0, 0, 0
	dc.b	$43, 0, 0, 0, $33, 0, 0, 0, $23, $30, 0, 0, $22, $30, 0, 0, $22, $20, 0, 0, $11, $13, 0, 0, $22, $22, $30, 0, 0, 2, $20, 0
	dc.b	0, 0, $AD, $23, 0, $A, $BD, $23, 0, $A, $D2, $23, 0, $AB, $D2, $22, 0, $AD, $22, $22, 0, $BD, $82, $22, 0, $BD, $98, $22, 8, $DD, $78, $22
	dc.b	8, $7D, $D8, $91, 8, $98, $89, $21, 9, $89, $90, $21, 0, $99, $90, 2, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 9, $87, 0, 0, 9, $99
	dc.b	$44, $33, $31, 0, $35, $43, $3D, 0, $33, $53, $33, $B0, $33, $52, $33, $DB, $23, $32, $33, $DB, $22, $32, $23, $DD, $22, $22, $12, $D9, $12, $31, $9D, $99
	dc.b	1, $24, $99, $99, 2, $12, $49, $90, 2, $10, $20, 0, $10, $21, 0, 0, $10, $21, 0, 0, $10, $21, 0, 0, $77, $98, $80, 0, $99, $99, $90, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $D, 0, 0, 0, $ED, 0, 0, 0, $ED, 0, 0, 0, $ED, 0, 0, 0, $E
	dc.b	0, 0, $99, $87, 0, 0, $8D, $DD, $D, $D8, $7D, $DD, $DD, $D8, $79, $DC, $DD, $D8, $79, $DC, $DD, $D8, $89, $DC, $DD, $D9, $99, $DD, $EE, $EE, $EE, $E1
	dc.b	$66, $89, $70, 0, $EE, $1D, $DD, 0, $FC, $C1, $DD, $D0, $CC, $CD, $1D, $D0, $CC, $CD, $1D, $D0, $CC, $CD, $1D, $D0, $CC, $CD, $1D, $10, $11, $11, $11, 0
byte_38BF8:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 4, $44, 0, 4, $44, $44, 0, $3A, $34, $43, 0, $3B, $24, $33, 4, $3B, $23, $43
	dc.b	0, 0, 0, 0, 3, $44, $44, $30, $44, $44, $44, $44, $44, $44, $33, $33, $33, $33, $32, $22, $33, $22, $22, $22, $32, $22, $22, $22, $44, $43, $32, $20
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, $43, 0, 0, 0, $34, $30, 0, 0, $22, $20, 0, 0, $20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 3, 0, 0, 0, 4, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, $89, 0, 0, 0, $11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$34, $55, $32, $43, $44, $45, $54, $33, $44, $44, $44, $44, $33, $54, $44, $44, $96, $65, $44, $44, $16, $65, $44, $33, $16, $65, $44, $33, $96, $65, $43, $33
	dc.b	$96, $54, $43, $33, $65, $43, $33, $33, $AA, $A3, $33, $32, $BB, $AA, $33, $32, $DB, $BB, $B3, $22, $D, $BB, $B2, $22, 0, $DD, $B2, $21, 0, 0, $DD, $22
	dc.b	$55, $44, $43, $33, $44, $44, $44, $33, $43, $33, $33, $43, $33, $33, $33, $33, $33, $33, $22, $22, $33, $22, $22, $22, $33, $32, $22, $22, $34, $43, $33, $23
	dc.b	$23, $44, $43, $32, $23, $34, $44, $43, $22, $33, $34, $44, $22, $22, $33, $44, $22, $22, $22, $34, $22, $22, $22, $23, $12, $22, $22, $22, $23, $33, $20, 0
	dc.b	0, 0, 0, 0, $30, 0, 0, 0, $33, 0, 0, 0, $33, $30, 0, 0, $33, $33, 0, 0, $22, $23, $30, 0, $22, $22, $20, 0, $30, 0, 0, 0
	dc.b	$33, 0, 0, 0, $23, 0, 0, 0, $32, $30, 0, 0, $32, $23, 0, 0, $42, $22, 0, 0, $43, $11, 0, 0, $34, 0, 0, 0, $23, 0, 0, 0
	dc.b	0, 0, 0, $2B, 0, 0, 2, $2A, 0, 0, $B2, $2A, 0, 0, $A2, $2B, 0, 0, $B7, $6B, 0, 0, $77, $6B, 0, 0, $76, $97, 0, 0, $87, $79
	dc.b	0, 0, $98, $87, 0, 0, 9, $88, 0, 0, 0, $99, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $97, 0, 0, 0, $99
	dc.b	$B3, $44, $34, 0, $B2, $34, $22, $40, $B2, $23, $22, $40, $D2, $23, $22, $24, $D6, $22, $22, $24, $D7, $22, $22, $22, $79, $22, $20, 2, $99, $22, $10, 0
	dc.b	$99, $12, $40, 0, $92, $10, $24, $40, $22, $10, 2, $20, $22, $10, 0, 0, $22, $10, 0, 0, $22, $10, 0, 0, $77, $78, $90, 0, $99, $99, $90, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $D, 0, 0, 0, $ED, 0, 0, 0, $ED, 0, 0, 0, $E
	dc.b	0, 0, 0, $97, 0, 0, $D7, $DD, 0, $DD, $77, $CC, $DD, $CC, $86, $CC, $CC, $CC, $86, $8C, $CC, $CC, $C7, $6C, $CC, $CC, $C7, $6C, $EE, $EE, $EE, $E1
	dc.b	$66, $87, $90, 0, $EE, $E9, $90, 0, $FC, $CC, $1D, 0, $CC, $CC, $CD, $D0, $CC, $CC, $CD, $D0, $CC, $CC, $CD, $D0, $CC, $CC, $CD, $10, $11, $11, $11, 0
byte_38E38:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 3, $34, $20, 0, $33, $42, $22, $23, $34, $5A, $22, $34, $45, $3A, 2, $44, $55, $3A
	dc.b	0, 0, 0, 0, 0, $33, $33, $33, $34, $44, $44, $43, $44, $44, $33, $33, $24, $33, $33, $33, $A2, $33, $33, $22, $BB, $23, $32, $20, $BB, $23, $44, $43
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, $33, 0, 0, 0, $33, $30, 0, 0, $32, $20, 0, 0, $20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 9, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	3, $45, $55, $55, $34, $45, $54, $45, $34, $45, $44, $44, $44, $54, $45, $54, $44, $44, $16, $65, $24, $41, $16, $65, $24, $31, $16, $65, $23, $41, $96, $65
	dc.b	$24, $59, $66, $64, $84, $56, $66, $43, $19, $AA, $6A, $66, 1, $AA, $AA, $AA, $B, $BA, $AA, $AA, $D, $BB, $AA, $AA, 0, $DD, $BB, $BB, 0, 0, $DD, $DD
	dc.b	$4B, $22, $55, $44, $54, $33, $44, $44, $54, $44, $43, $33, $44, $44, $33, $23, $44, $44, $32, $22, $44, $33, $32, $22, $44, $33, $32, $22, $43, $33, $33, $32
	dc.b	$43, $33, $23, $44, $33, $33, $23, $34, $33, $32, $22, $33, $A3, $22, $22, $22, $B2, $22, $22, $22, $B2, $22, $22, $22, $D2, $11, $11, $12, $21, $22, $23, 0
	dc.b	$43, 0, 0, 0, $44, $30, 0, 0, $33, $43, 0, 0, $33, $33, $30, 0, $22, $33, $30, 0, $22, $22, $33, 0, $22, $22, $22, 0, $22, 0, 0, 0
	dc.b	0, 0, 0, 0, $40, 0, 0, 0, $43, 0, 0, 0, $34, 0, 0, 0, $23, $30, 0, 0, $22, $30, 0, 0, $22, $23, 0, 0, 2, $22, 0, 0
	dc.b	0, 0, 0, $DD, 0, 0, $D, $AA, 0, 0, $BB, $BA, 0, 0, $BB, $B7, 0, $B, $DB, $B9, 0, 8, $DD, $77, 0, 7, $98, $77, 0, 8, $89, $87
	dc.b	$2B, $A2, $22, $30, $BD, $BA, $22, $23, $A2, $DA, $22, $23, $72, $DB, $21, $22, $86, $DB, $21, $22, $6D, $BD, $21, $22, $6D, $D7, $19, $92, $96, $79, $13, $90
	dc.b	0, 9, $81, $98, 0, 0, $99, $19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $79, 0, 0, 0, $99
	dc.b	$89, $99, $12, $30, $88, $91, 0, $23, $99, $31, 0, 2, $21, $31, 0, 0, $21, $31, 0, 0, $21, $31, 0, 0, $97, $66, $80, 0, $99, $99, $99, 0
	dc.b	0, 0, 0, 0, $40, 0, 0, 0, $20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $DD, 0, 0, $D, $DD, 0, 0, $D, $DD, 0, 0, $E, $DD, 0, 0, 0, $11
	dc.b	0, 0, 0, $88, 0, 8, $88, $8D, $DD, $ED, $D7, $6C, $DE, $DC, $CC, $66, $ED, $CC, $CC, $66, $ED, $CC, $CC, $C6, $ED, $CC, $CC, $C6, $11, $11, $11, $11
	dc.b	$98, $67, $89, 0, $C9, $99, $99, 0, $CF, $CC, $C1, 0, $CC, $CC, $CD, $10, $CC, $CC, $CD, $10, $7C, $CC, $CD, $10, $7C, $CC, $CD, $10, $11, $11, $11, 0
byte_39098:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $33, 0, 0, 3, $33, $22, 0, $33, $44, $AB, 3, $34, $44, $BB, $33, $44, $44, $B3, $34, $44, $43
	dc.b	3, $44, $44, $55, $33, $44, $44, $55, $34, $44, $44, $54, $33, $34, $44, $35, $32, $33, $43, $16, $31, $23, $31, $16, $31, $24, $31, $16, $31, $25, $41, $16
	dc.b	$34, $25, $59, $96, $34, $88, $66, $65, $D, $11, $B6, $6A, $D, $AA, $AA, $AA, 0, $BA, $AA, $AA, 0, $DB, $BA, $AA, 0, $D, $BB, $BB, 0, 0, $DD, $DD
	dc.b	0, 0, 0, 0, 3, $33, $33, 0, $34, $44, $44, $44, $44, $44, $44, $33, $43, $22, $33, $33, $32, $AA, $23, $32, $2B, $BA, $23, $32, $3B, $BB, $23, $43
	dc.b	$53, $3B, $24, $44, $54, $33, $44, $33, $45, $44, $43, $33, $54, $44, $33, $33, $65, $44, $33, $33, $65, $43, $33, $32, $65, $43, $33, $32, $65, $33, $33, $32
	dc.b	$54, $33, $33, $44, $33, $33, $33, $34, $66, $33, $32, $23, $AA, $B3, $32, $22, $AA, $B2, $22, $22, $AA, $D2, $22, $22, $BD, $11, $11, $12, $D1, $22, $23, 0
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, $30, 0, 0, 0, $33, 0, 0, 0, $22, 0, 0, 0, $20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.b	$33, 0, 0, 0, $33, $30, 0, 0, $33, $30, 0, 0, $22, $33, 0, 0, $22, $23, 0, 0, $22, $22, $30, 0, $22, $22, $20, 0, $22, $22, $20, 0
	dc.b	$30, 0, $20, 0, $43, 0, 0, 0, $44, 0, 0, 0, $24, $30, 0, 0, $22, $30, 0, 0, $22, $30, 0, 0, $22, $20, 0, 0, 0, $20, 0, 0
	dc.b	0, 0, $B, $DD, 0, 0, $BD, $BB, 0, 0, $BD, $BA, 0, $A, $BD, $BA, 0, $A, $DD, $BB, 0, $77, $8D, $BB, 0, $77, $78, $DB, 0, $88, $78, $8D
	dc.b	0, $98, $88, $92, 0, 9, $99, 2, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, $87, $78, 0, 0, $99, $99
	dc.b	$B2, $2B, $BA, $30, $BB, $2D, $DB, $A3, $AB, $B2, $2D, $BA, $AB, $B2, $22, $BB, $BB, $B2, $77, $BD, $BB, $77, $96, $BD, $B7, $66, $96, $D9, $D7, $67, $79, $67
	dc.b	$29, $78, $88, $90, $10, $98, $88, $94, $10, 9, $99, 2, $10, 3, $10, 0, $10, 3, $10, 0, $10, 3, $10, 0, $99, $87, $66, $70, $99, $99, $99, $90
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $DD, 0, 0, $D, $CC, 0, 0, $DC, $CC, 0, 0, $DC, $CC, 0, 0, $ED, $DD, 0, 0, 1, $11
	dc.b	0, 0, $88, $88, $D, $77, $DD, $DE, $DC, $CD, $7D, $E8, $CC, $DD, $9E, $DC, $CD, $EE, $ED, $CC, $DE, $EE, $ED, $CC, $DE, $EE, $ED, $CC, $11, $11, $11, $11
	dc.b	$99, $87, $66, $80, $ED, $DD, $EE, $10, $76, $68, $DD, $DE, $CC, $D6, $7D, $DE, $FC, $CD, $67, $DE, $CC, $CD, $77, $DE, $CC, $CD, $79, $DE, $11, $11, $EE, $E0
byte_39298:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, $50, 0, 0, 2, $45, 0, 0, $B, $A4, 0, 0, $B, $BA, 0, 0, $B, $B3
	dc.b	0, 0, 3, $33, 0, 0, 3, $33, 0, 0, $33, $55, 0, 0, $25, $51, 0, 0, $25, $51, 0, 0, $25, $51, 0, 0, $25, $51, 0, 0, $25, $51
	dc.b	0, 0, $22, $39, 0, 0, $2B, $A1, 0, 0, $B, $AA, 0, 0, $D, $BA, 0, 0, $D, $BB, 0, 0, 0, $DB, 0, 0, 0, $D, 0, 0, 0, 0
	dc.b	0, 0, 0, $B, 0, 0, 0, $BD, 0, 0, $B, $D0, 0, 7, $77, $90, 0, 7, $61, $79, 0, $76, $78, $79, 0, $77, $78, $79, 0, $88, $88, $99
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, $33, $33, $33, $33, $45, $54, $33, $34, $55, $54, $43, $34, $55, $44, $43, $45, $55, $44, $44, $45, $54, $44, $44
	dc.b	$45, $54, $44, $44, $44, $44, $44, $44, $44, $44, $45, $53, $44, $44, $16, $65, $33, $44, $16, $65, $24, $42, $16, $65, $13, $31, $16, $65, $95, $51, $96, $63
	dc.b	$89, $A6, $65, $33, $11, $AA, $AA, $A3, $AA, $AA, $AA, $AB, $AA, $AA, $AA, $BB, $BA, $AA, $AB, $BD, $BB, $BB, $BB, $BD, $DB, $BB, $BD, $E2, $E, $E1, $EE, $3B
	dc.b	$BD, $BB, $BD, $33, $DB, $BA, $AB, $D3, $DB, $BA, $AA, $B3, $DB, $BA, $AB, $B3, $DB, $BB, $BB, $D8, $DB, $BB, $BB, $91, $2D, $BB, $BD, $98, $90, $DD, $D2, $98
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, $30, 0, 0, 0, $55, $30, 0, 0, $44, $43, 0, 0, $AB, $23, $30, 0, $AB, $22, $20, 0, $3B, $23, 0, 0
	dc.b	$33, $33, $30, 0, $33, $33, $30, 0, $33, $33, $33, 0, $33, $32, $33, 0, $33, $32, $23, 0, $33, $32, $22, $30, $33, $32, $22, $20, $33, $32, $22, $20
	dc.b	$33, $23, 2, $20, $33, $23, 0, 0, $33, $23, $30, 0, $32, $22, $30, 0, $22, $22, $30, 0, $22, $22, $30, 0, $22, $22, $20, 0, $AA, 0, $20, 0
	dc.b	$DD, $A0, 0, 0, $32, $DB, 0, 0, $32, $DB, 0, 0, $77, $97, $70, 0, $16, $79, $80, 0, $86, $67, $90, 0, $87, $77, $90, 0, $88, $88, $90, 0
	dc.b	0, $98, $88, $99, 0, 9, $89, $99, 0, 0, $99, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 0, 0, 0, 9
	dc.b	0, 0, 0, 7, 0, 0, $D, $DD, 0, $D, $76, $67, $D, $CC, $CC, $D6, $DC, $CC, $CD, $D6, $DC, $CC, $DD, $D6, $DC, $CD, $DD, $D7, 1, $11, $11, $11
	dc.b	0, $21, 1, $19, 0, $21, 1, $12, 0, $21, 0, $12, 0, $21, 0, $12, 0, $21, 0, $12, 0, $21, 0, $12, $66, $77, $80, $76, $99, $99, $90, $99
	dc.b	$66, $88, $80, $86, $EE, $EE, $10, $1E, $DD, $DE, $EE, $D8, $8D, $DD, $EE, $8C, $8D, $DD, $E8, $CC, $8D, $DD, $E8, $CC, $8D, $DD, $ED, $CC, $EE, $EE, $E, $11
	dc.b	$88, $88, $90, 0, $98, $89, 0, 0, 9, $90, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $67, $80, 0, 0, $99, $90, 0, 0
	dc.b	$67, $89, 0, 0, $ED, $DD, 0, 0, $66, $67, $D0, 0, $CC, $CC, $8D, 0, $CF, $CC, $C8, 0, $CC, $CC, $CD, 0, $CC, $CC, $CD, 0, $11, $11, $1E, 0
byte_394D8:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, $55, 0, 0, 2, $24, 0, 0, 2, $BA, 0, 0, 2, $BB, 0, 0, 2, $BB
	dc.b	0, 0, 2, $33, 0, 0, 2, $33, 0, 0, 2, $33, 0, 0, $22, $35, 0, 0, $22, $35, 0, 0, $22, $35, 0, 0, $22, $35, 0, 0, $22, $33
	dc.b	0, 0, $22, $23, 0, 0, $22, $23, 0, 0, $22, $23, 0, 0, $20, $22, 0, 0, $20, $22, 0, 0, 0, $22, 0, 0, 0, $22, 0, 0, 0, $2B
	dc.b	0, 0, $B, $BB, 0, 0, $BB, $DD, 0, $B, $AD, 2, 0, $79, $77, $82, 0, $97, $61, $82, 0, $76, $68, $19, 0, $77, $78, $89, 0, $88, $88, $89
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 3, $33, $30, 3, $34, $55, $43, $53, $45, $55, $54, $43, $45, $55, $54, $A4, $44, $55, $44, $34, $44, $55, $44
	dc.b	$34, $44, $55, $44, $34, $44, $55, $44, $55, $44, $44, $44, $56, $14, $44, $41, $66, $13, $44, $31, $66, $12, $44, $21, $66, $11, $33, $11, $66, $91, $55, $19
	dc.b	$36, $66, $11, $66, $A6, $6A, $11, $A6, $AA, $AA, $AA, $AA, $BA, $AA, $AA, $AA, $DB, $BA, $AA, $AB, $DD, $BB, $BB, $BB, $D, $DB, $BB, $DE, $B3, $EE, $1E, $E3
	dc.b	$33, $DB, $BB, $D3, $3D, $BA, $AA, $BD, $3B, $AA, $AA, $AB, $3B, $AA, $AA, $AB, $3B, $BA, $AA, $BB, $2D, $BB, $BB, $BD, $22, $DB, $BB, $D2, 2, $2D, $DD, $22
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $30, $55, 0, 0, $35, $42, $40, 0, $34, $AB, $20, 0, $4A, $BB, $20, 0, $43, $BB, $20, 0
	dc.b	$43, $33, $20, 0, $43, $33, $20, 0, $55, $33, $20, 0, $65, $53, $22, 0, $66, $53, $22, 0, $66, $53, $22, 0, $66, $53, $22, 0, $66, $33, $22, 0
	dc.b	$63, $32, $22, 0, $6A, $32, $22, 0, $AA, $32, $22, 0, $AB, $22, 2, 0, $BD, $22, 2, 0, $DD, $22, 0, 0, $D0, $22, 0, 0, $BB, $20, 0, 0
	dc.b	$3B, $BB, 0, 0, $3D, $DB, $B0, 0, $32, $D, $AB, 0, $32, $87, $79, $70, $32, $81, $67, $90, $29, $18, $66, $70, $29, $88, $77, $70, 9, $88, $88, $80
	dc.b	0, $88, $88, $90, 0, $98, $89, 0, 0, 9, $90, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $87, 0, 0, 0, $99
	dc.b	0, 0, 9, $87, 0, 0, $DD, $DD, 0, 8, $76, $66, 0, $8C, $CC, $D6, $D, $CC, $FC, $CD, $D, $CC, $CC, $CD, $D, $CC, $CC, $CD, 1, $11, $11, $11
	dc.b	2, $10, $10, $12, 2, $10, $10, $12, 2, $10, 0, $12, 2, $10, 0, $12, 2, $10, 0, $12, 2, $10, 0, $12, $66, $70, 0, $76, $99, $90, 0, $99
	dc.b	$66, $80, 0, $86, $EE, $10, 0, $1E, $DD, $DE, $E, $DD, $6D, $DE, $E, $DD, $67, $DE, $E, $D7, $77, $DE, $E, $D7, $79, $EE, $E, $E9, $EE, 0, 0, $E
	dc.b	0, $98, $88, $80, 0, 9, $88, $90, 0, 0, $99, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $67, $80, 0, 0, $99, $90, 0, 0
	dc.b	$67, $89, 0, 0, $ED, $DD, $D0, 0, $D6, $66, $78, 0, $66, $DC, $CC, $80, $6D, $CC, $FC, $CD, $7D, $CC, $CC, $CD, $7D, $CC, $CC, $CD, $E1, $11, $11, $11
byte_39718:
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, $55, 0, 0, 2, $24, 0, 0, 2, $BA, 0, 0, 2, $BB
	dc.b	0, 0, 2, $BB, 0, 0, 2, $33, 0, 0, 2, $33, 0, 0, $22, $33, 0, 0, $22, $35, 0, 0, $22, $35, 0, 0, $22, $35, 0, 0, $22, $35
	dc.b	0, 0, $22, $33, 0, 0, $22, $23, 0, 0, $22, $23, 0, 0, $20, $23, 0, 0, 0, $22, 0, 0, 0, $22, 0, 0, 0, $20, 0, 0, 0, $B
	dc.b	0, $60, 0, $BB, 0, $76, $B, $DD, 0, $97, $69, $D2, 0, $76, $68, $92, 6, $68, $66, $82, 7, $88, $66, $82, 9, $76, $86, $80, 0, $88, $68, 0
	dc.b	0, 0, 0, 0, 0, 0, $33, 0, 0, 3, $55, $30, 0, $34, $55, $43, 3, $35, $55, $53, $53, $45, $55, $54, $43, $45, $55, $54, $A4, $44, $55, $44
	dc.b	$34, $44, $55, $44, $34, $44, $55, $44, $34, $44, $55, $44, $55, $44, $44, $44, $56, $54, $44, $45, $66, $13, $44, $31, $66, $12, $44, $21, $66, $11, $33, $11
	dc.b	$66, $11, $55, $11, $36, $11, $66, $11, $A6, $6A, $11, $A6, $AA, $AA, $11, $AA, $BA, $AA, $AA, $AA, $DB, $BA, $AA, $AB, $D, $BB, $BB, $BE, $B3, $EE, $11, $EE
	dc.b	$33, $DB, $BB, $D3, $3D, $BA, $AA, $BD, $3B, $AA, $AA, $AB, $3B, $AA, $AA, $AB, $3B, $BA, $AA, $BB, $2D, $BB, $BB, $BD, $22, $DB, $BB, $D2, 2, $2D, $DD, $22
	dc.b	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $30, $55, $40, 0, $35, $42, $20, 0, $34, $AB, $20, 0, $4A, $BB, $20, 0
	dc.b	$43, $BB, $20, 0, $43, $33, $20, 0, $43, $33, $20, 0, $55, $33, $22, 0, $65, $53, $22, 0, $66, $53, $22, 0, $66, $53, $22, 0, $66, $53, $22, 0
	dc.b	$66, $33, $22, 0, $63, $32, $22, 0, $6A, $32, $22, 0, $AA, $32, 2, 0, $AB, $22, 0, 0, $BD, $22, 0, 0, $D0, 2, 0, 0, $BB, 0, 0, 0
	dc.b	$3B, $B0, 0, $60, $3D, $DB, 6, $70, $32, $D9, $67, $90, $32, $98, $66, $70, $32, $86, $68, $66, $22, $86, $68, $87, $20, $86, $86, $79, 0, 8, $68, $80
	dc.b	0, $98, $89, 0, 0, 9, $90, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $87, 0, 0, 0, $99
	dc.b	0, 0, 9, $87, 0, 0, $DD, $DD, 0, 8, $76, $66, 0, $8C, $CC, $D6, $D, $CC, $FC, $CD, $D, $CC, $CC, $CD, $D, $CC, $CC, $CD, 1, $11, $11, $11
	dc.b	2, $10, $10, $12, 2, $10, $10, $12, 2, $10, 0, $12, 2, $10, 0, $12, 2, $10, 0, $12, 2, $10, 0, $12, $66, $70, 0, $76, $99, $90, 0, $99
	dc.b	$66, $80, 0, $86, $EE, $10, 0, $1E, $DD, $DE, $E, $DD, $6D, $DE, $E, $DD, $67, $DE, $E, $D7, $77, $DE, $E, $D7, $79, $EE, $E, $E9, $EE, 0, 0, $E
	dc.b	0, 9, $88, $90, 0, 0, $99, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $67, $80, 0, 0, $99, $90, 0, 0
	dc.b	$67, $89, 0, 0, $ED, $DD, $D0, 0, $D6, $66, $78, 0, $66, $DC, $CC, $80, $6D, $CC, $FC, $CD, $7D, $CC, $CC, $CD, $7D, $CC, $CC, $CD, $E1, $11, $11, $11
Spr_Sonic:
	dc.l	byte_39A0C
	dc.l	byte_39A26
	dc.l	byte_39A38
	dc.l	byte_39A52
	dc.l	byte_39A6C
	dc.l	byte_39A86
	dc.l	byte_39AA0
	dc.l	byte_39AB2
	dc.l	byte_39AB8
	dc.l	byte_39AC2
	dc.l	byte_39AD4
	dc.l	byte_39ADA
	dc.l	byte_39AF4
	dc.l	byte_39AFE
	dc.l	byte_39BB8
	dc.l	byte_39BDA
	dc.l	byte_39CDC
	dc.l	byte_39CF6
	dc.l	byte_39D10
	dc.l	byte_39D2A
	dc.l	byte_39D44
	dc.l	byte_39D5E
	dc.l	byte_39D78
	dc.l	byte_39D92
	dc.l	byte_39DAC
	dc.l	byte_39DC6
	dc.l	byte_39DE0
	dc.l	byte_39DFA
	dc.l	byte_39E14
	dc.l	byte_39E2E
	dc.l	byte_39E48
	dc.l	byte_39E62
	dc.l	byte_39E68
	dc.l	byte_39E6E
	dc.l	byte_39EC8
	dc.l	byte_39ECE
	dc.l	byte_39EE8
	dc.l	byte_39EEE
	dc.l	byte_39EF4
	dc.l	byte_39EFA
	dc.l	byte_39F00
	dc.l	byte_39F06
	dc.l	byte_39F0C
	dc.l	byte_39F12
	dc.l	byte_39F18
byte_39A0C:
	dc.b	6, 0
	dc.l	byte_39F26
	dc.l	byte_39F40
	dc.l	byte_39F54
	dc.l	$1039F26
	dc.l	$1039F40
	dc.l	$1039F54
byte_39A26:
	dc.b	4, 0
	dc.l	byte_3A288
	dc.l	byte_3A2A2
	dc.l	$103A288
	dc.l	$103A2A2
byte_39A38:
	dc.b	6, 0
	dc.l	$1039F72
	dc.l	$1039F86
	dc.l	$1039F96
	dc.l	$1039FAA
	dc.l	$1039FBE
	dc.l	$1039FCE
byte_39A52:
	dc.b	6, 0
	dc.l	byte_39F72
	dc.l	byte_39F86
	dc.l	byte_39F96
	dc.l	byte_39FAA
	dc.l	byte_39FBE
	dc.l	byte_39FCE
byte_39A6C:
	dc.b	6, 0
	dc.l	$103A204
	dc.l	$103A218
	dc.l	$103A22C
	dc.l	$103A240
	dc.l	$103A25A
	dc.l	$103A26E
byte_39A86:
	dc.b	6, 0
	dc.l	byte_3A204
	dc.l	byte_3A218
	dc.l	byte_3A22C
	dc.l	byte_3A240
	dc.l	byte_3A25A
	dc.l	byte_3A26E
byte_39AA0:
	dc.b	4, 0
	dc.l	byte_39FE2
	dc.l	byte_39FF2
	dc.l	byte_3A002
	dc.l	byte_3A012
byte_39AB2:
	dc.b	1, 0
	dc.l	byte_3A2F4
byte_39AB8:
	dc.b	2, 9
	dc.l	byte_3A308
	dc.l	byte_3A31C
byte_39AC2:
	dc.b	4, 1
	dc.l	byte_3A330
	dc.l	byte_3A344
	dc.l	byte_3A358
	dc.l	byte_3A344
byte_39AD4:
	dc.b	1, 0
	dc.l	byte_3A2E4
byte_39ADA:
	dc.b	6, 2
	dc.l	byte_3A0FA
	dc.l	byte_3A114
	dc.l	$103A0FA
	dc.l	byte_3A128
	dc.l	byte_3A13C
	dc.l	$103A128
byte_39AF4:
	dc.b	2, 3
	dc.l	byte_3A2BC
	dc.l	byte_3A2D0
byte_39AFE:
	dc.b	$2E, 0
	dc.l	byte_3A022
	dc.l	byte_3A022
	dc.l	byte_3A050
	dc.l	byte_3A050
	dc.l	byte_3A074
	dc.l	byte_3A074
	dc.l	byte_3A08E
	dc.l	byte_3A08E
	dc.l	byte_3A08E
	dc.l	byte_3A08E
	dc.l	byte_3A08E
	dc.l	byte_3A08E
	dc.l	byte_3A08E
	dc.l	byte_3A08E
	dc.l	byte_3A08E
	dc.l	byte_3A08E
	dc.l	byte_3A08E
	dc.l	byte_3A08E
	dc.l	byte_3A08E
	dc.l	byte_3A08E
	dc.l	byte_3A08E
	dc.l	byte_3A08E
	dc.l	byte_3A08E
	dc.l	byte_3A08E
	dc.l	byte_3A08E
	dc.l	byte_3A08E
	dc.l	byte_3A08E
	dc.l	byte_3A08E
	dc.l	byte_3A08E
	dc.l	byte_3A08E
	dc.l	byte_3A08E
	dc.l	byte_3A08E
	dc.l	byte_3A08E
	dc.l	byte_3A08E
	dc.l	byte_3A08E
	dc.l	byte_3A08E
	dc.l	byte_3A08E
	dc.l	byte_3A08E
	dc.l	byte_3A08E
	dc.l	byte_3A08E
	dc.l	byte_3A0A8
	dc.l	byte_3A0A8
	dc.l	byte_3A0B8
	dc.l	byte_3A0B8
	dc.l	byte_3A0D6
	dc.l	byte_3A0D6
byte_39BB8:
	dc.b	8, 2
	dc.l	byte_3A188
	dc.l	byte_3A150
	dc.l	$103A16A
	dc.l	$103A150
	dc.l	$103A188
	dc.l	$103A150
	dc.l	byte_3A16A
	dc.l	byte_3A150
byte_39BDA:
	dc.b	$40, 0
	dc.l	byte_3A188
	dc.l	byte_3A150
	dc.l	$103A16A
	dc.l	byte_3A1A2
	dc.l	byte_3A1D0
	dc.l	byte_3A1EA
	dc.l	byte_3A1D0
	dc.l	byte_3A1EA
	dc.l	byte_3A1D0
	dc.l	byte_3A1EA
	dc.l	byte_3A1D0
	dc.l	byte_3A1EA
	dc.l	byte_3A1D0
	dc.l	byte_3A1EA
	dc.l	byte_3A1D0
	dc.l	byte_3A1EA
	dc.l	byte_3A1D0
	dc.l	byte_3A1EA
	dc.l	byte_3A1D0
	dc.l	byte_3A1EA
	dc.l	byte_3A1D0
	dc.l	byte_3A1EA
	dc.l	byte_3A1D0
	dc.l	byte_3A1EA
	dc.l	byte_3A1D0
	dc.l	byte_3A1EA
	dc.l	byte_3A1D0
	dc.l	byte_3A1EA
	dc.l	byte_3A1D0
	dc.l	byte_3A1EA
	dc.l	byte_3A1D0
	dc.l	byte_3A1EA
	dc.l	byte_3A1D0
	dc.l	byte_3A1EA
	dc.l	byte_3A1D0
	dc.l	byte_3A1EA
	dc.l	byte_3A1D0
	dc.l	byte_3A1EA
	dc.l	byte_3A1D0
	dc.l	byte_3A1EA
	dc.l	byte_3A1D0
	dc.l	byte_3A1EA
	dc.l	byte_3A1D0
	dc.l	byte_3A1EA
	dc.l	byte_3A1D0
	dc.l	byte_3A1EA
	dc.l	byte_3A1D0
	dc.l	byte_3A1EA
	dc.l	byte_3A1D0
	dc.l	byte_3A1EA
	dc.l	byte_3A1D0
	dc.l	byte_3A1EA
	dc.l	byte_3A1D0
	dc.l	byte_3A1EA
	dc.l	byte_3A1D0
	dc.l	byte_3A1EA
	dc.l	byte_3A1D0
	dc.l	byte_3A1EA
	dc.l	byte_3A1D0
	dc.l	byte_3A1EA
	dc.l	byte_3A1D0
	dc.l	byte_3A1EA
	dc.l	byte_3A1D0
	dc.l	byte_3A1EA
byte_39CDC:
	dc.b	6, 1
	dc.l	byte_39F26
	dc.l	byte_39F40
	dc.l	byte_39F54
	dc.l	$1039F26
	dc.l	$1039F40
	dc.l	$1039F54
byte_39CF6:
	dc.b	6, 2
	dc.l	byte_39F26
	dc.l	byte_39F40
	dc.l	byte_39F54
	dc.l	$1039F26
	dc.l	$1039F40
	dc.l	$1039F54
byte_39D10:
	dc.b	6, 3
	dc.l	byte_39F26
	dc.l	byte_39F40
	dc.l	byte_39F54
	dc.l	$1039F26
	dc.l	$1039F40
	dc.l	$1039F54
byte_39D2A:
	dc.b	6, 1
	dc.l	byte_39F72
	dc.l	byte_39F86
	dc.l	byte_39F96
	dc.l	byte_39FAA
	dc.l	byte_39FBE
	dc.l	byte_39FCE
byte_39D44:
	dc.b	6, 2
	dc.l	byte_39F72
	dc.l	byte_39F86
	dc.l	byte_39F96
	dc.l	byte_39FAA
	dc.l	byte_39FBE
	dc.l	byte_39FCE
byte_39D5E:
	dc.b	6, 3
	dc.l	byte_39F72
	dc.l	byte_39F86
	dc.l	byte_39F96
	dc.l	byte_39FAA
	dc.l	byte_39FBE
	dc.l	byte_39FCE
byte_39D78:
	dc.b	6, 1
	dc.l	$1039F72
	dc.l	$1039F86
	dc.l	$1039F96
	dc.l	$1039FAA
	dc.l	$1039FBE
	dc.l	$1039FCE
byte_39D92:
	dc.b	6, 2
	dc.l	$1039F72
	dc.l	$1039F86
	dc.l	$1039F96
	dc.l	$1039FAA
	dc.l	$1039FBE
	dc.l	$1039FCE
byte_39DAC:
	dc.b	6, 3
	dc.l	$1039F72
	dc.l	$1039F86
	dc.l	$1039F96
	dc.l	$1039FAA
	dc.l	$1039FBE
	dc.l	$1039FCE
byte_39DC6:
	dc.b	6, 1
	dc.l	$103A204
	dc.l	$103A218
	dc.l	$103A22C
	dc.l	$103A240
	dc.l	$103A25A
	dc.l	$103A26E
byte_39DE0:
	dc.b	6, 2
	dc.l	$103A204
	dc.l	$103A218
	dc.l	$103A22C
	dc.l	$103A240
	dc.l	$103A25A
	dc.l	$103A26E
byte_39DFA:
	dc.b	6, 3
	dc.l	$103A204
	dc.l	$103A218
	dc.l	$103A22C
	dc.l	$103A240
	dc.l	$103A25A
	dc.l	$103A26E
byte_39E14:
	dc.b	6, 1
	dc.l	byte_3A204
	dc.l	byte_3A218
	dc.l	byte_3A22C
	dc.l	byte_3A240
	dc.l	byte_3A25A
	dc.l	byte_3A26E
byte_39E2E:
	dc.b	6, 2
	dc.l	byte_3A204
	dc.l	byte_3A218
	dc.l	byte_3A22C
	dc.l	byte_3A240
	dc.l	byte_3A25A
	dc.l	byte_3A26E
byte_39E48:
	dc.b	6, 3
	dc.l	byte_3A204
	dc.l	byte_3A218
	dc.l	byte_3A22C
	dc.l	byte_3A240
	dc.l	byte_3A25A
	dc.l	byte_3A26E
byte_39E62:
	dc.b	1, $FF
	dc.l	byte_3A36C
byte_39E68:
	dc.b	1, $FF
	dc.l	byte_3A390
byte_39E6E:
	dc.b	$16, 4
	dc.l	byte_3A0D6
	dc.l	byte_3A0D6
	dc.l	byte_3A0D6
	dc.l	byte_3A2E4
	dc.l	byte_3A2E4
	dc.l	byte_3A2E4
	dc.l	byte_3A2E4
	dc.l	byte_3A2E4
	dc.l	byte_3A0D6
	dc.l	byte_3A0D6
	dc.l	byte_3A2F4
	dc.l	byte_3A308
	dc.l	byte_3A3B4
	dc.l	byte_3A3B4
	dc.l	byte_3A3B4
	dc.l	byte_3A3B4
	dc.l	byte_3A3B4
	dc.l	byte_3A3C8
	dc.l	byte_3A3D8
	dc.l	byte_3A3D8
	dc.l	byte_3A3D8
	dc.l	byte_3A3E8
byte_39EC8:
	dc.b	1, $FF
	dc.l	byte_3A402
byte_39ECE:
	dc.b	6, 2
	dc.l	byte_3A416
	dc.l	byte_3A416
	dc.l	byte_3A416
	dc.l	byte_3A416
	dc.l	byte_3A0B8
	dc.l	byte_3A0D6
byte_39EE8:
	dc.b	1, $FF
	dc.l	byte_3A448
byte_39EEE:
	dc.b	1, $FF
	dc.l	byte_3A45C
byte_39EF4:
	dc.b	1, $FF
	dc.l	byte_3A470
byte_39EFA:
	dc.b	1, $FF
	dc.l	byte_3A48A
byte_39F00:
	dc.b	1, $FF
	dc.l	byte_3A4A8
byte_39F06:
	dc.b	1, $FF
	dc.l	byte_3A4BC
byte_39F0C:
	dc.b	1, $FF
	dc.l	byte_3A4CC
byte_39F12:
	dc.b	1, $FF
	dc.l	byte_3A4DC
byte_39F18:
	dc.b	3, 1
	dc.l	byte_3A308
	dc.l	byte_3A2F4
	dc.l	byte_3A2E4
byte_39F26:
	dc.b	3, 0, 0, 0, 0
	dc.b	$D0, 9, 0, 0, $F8
	dc.b	$E0, $D, 0, 6, $F0
	dc.b	$F0, 8, 0, $E, $F8
	dc.b	$F8, 0, 0, $11, $F8
	dc.b	0
byte_39F40:
	dc.b	2, 1, 0, 0, 0
	dc.b	$D0, 9, 0, 0, $F0
	dc.b	$E0, $D, 0, 6, $F0
	dc.b	$F0, 9, 0, $E, $F0
byte_39F54:
	dc.b	4, 2, 0, 0, 0
	dc.b	$D0, $C, 0, 0, $F0
	dc.b	$D8, 8, 0, 4, $F8
	dc.b	$E0, $D, 0, 7, $F0
	dc.b	$F0, 4, 0, $F, $F8
	dc.b	$F8, 8, 0, $11, $F8
byte_39F72:
	dc.b	2, 3, 0, 0, 0
	dc.b	$D0, $F, 0, 0, $F0
	dc.b	$F0, 8, 0, $10, $F8
	dc.b	$F8, 0, 0, $13, $F8
byte_39F86:
	dc.b	1, 4, 0, 0, 0
	dc.b	$D0, $F, 0, 0, $F0
	dc.b	$F0, 9, 0, $10, $F0
	dc.b	0
byte_39F96:
	dc.b	2, 5, 0, 0, 0
	dc.b	$D0, $F, 0, 0, $F0
	dc.b	$F0, 4, 0, $10, $F8
	dc.b	$F8, 8, 0, $12, $F8
byte_39FAA:
	dc.b	2, 6, 0, 0, 0
	dc.b	$D0, $F, 0, 0, $F0
	dc.b	$F0, 8, 0, $10, $F0
	dc.b	$F8, 0, 0, $13, 0
byte_39FBE:
	dc.b	1, 7, 0, 0, 0
	dc.b	$D0, $F, 0, 0, $F0
	dc.b	$F0, 9, 0, $10, $F8
	dc.b	0
byte_39FCE:
	dc.b	2, 8, 0, 0, 0
	dc.b	$D0, $F, 0, 0, $F0
	dc.b	$F0, 4, 0, $10, $F8
	dc.b	$F8, 8, 0, $12, $F0
byte_39FE2:
	dc.b	1, 9, 0, 0, 0
	dc.b	$D8, $F, 0, 0, $F0
	dc.b	$F8, $C, 0, $10, $F0
	dc.b	0
byte_39FF2:
	dc.b	1, $A, 0, 0, 0
	dc.b	$D8, $F, 0, 0, $F0
	dc.b	$F8, $C, 0, $10, $F0
	dc.b	0
byte_3A002:
	dc.b	1, $B, 0, 0, 0
	dc.b	$D8, $F, 0, 0, $F0
	dc.b	$F8, $C, 0, $10, $F0
	dc.b	0
byte_3A012:
	dc.b	1, $C, 0, 0, 0
	dc.b	$D8, $F, 0, 0, $F0
	dc.b	$F8, $C, 0, $10, $F0
	dc.b	0
byte_3A022:
	dc.b	7, $E, 0, 0, 0
	dc.b	$D0, 7, 0, 0, $F0
	dc.b	$D0, 7, 8, 0, 0
	dc.b	$D8, 1, 0, 8, $E8
	dc.b	$D8, 1, 8, 8, $10
	dc.b	$F0, 4, 0, $A, $F0
	dc.b	$F0, 4, 8, $A, 0
	dc.b	$F8, 0, 0, $C, $F0
	dc.b	$F8, 0, 8, $C, 8
	dc.b	0
byte_3A050:
	dc.b	5, $F, 0, 0, 0
	dc.b	$E0, 0, 0, 0, $F8
	dc.b	$E0, 0, 8, 0, 0
	dc.b	$E8, 9, 0, 1, $E8
	dc.b	$E8, 9, 8, 1, 0
	dc.b	$F8, 4, 0, 7, $F0
	dc.b	$F8, 4, 8, 7, 0
	dc.b	0
byte_3A074:
	dc.b	3, $10, 0, 0, 0
	dc.b	$E0, $C, 0, 0, $F0
	dc.b	$E8, 9, 0, 4, $E8
	dc.b	$E8, 9, 0, $A, 0
	dc.b	$F8, 8, 0, $10, $F8
	dc.b	0
byte_3A08E:
	dc.b	3, $11, 0, 0, 0
	dc.b	$E0, 5, 0, 0, $F0
	dc.b	$E0, 5, 8, 0, 0
	dc.b	$F0, 9, 0, 4, $E8
	dc.b	$F0, 9, 8, 4, 0
	dc.b	0
byte_3A0A8:
	dc.b	1, $12, 0, 0, 0
	dc.b	$D8, 8, 0, 0, $F8
	dc.b	$E0, $F, 0, 3, $F0
	dc.b	0
byte_3A0B8:
	dc.b	4, $13, 0, 0, 0
	dc.b	$D0, 0, 0, 0, 0
	dc.b	$D8, 8, 0, 1, $F8
	dc.b	$E0, $D, 0, 4, $F0
	dc.b	$F0, 8, 0, $C, $F8
	dc.b	$F8, $C, 0, $F, $F0
byte_3A0D6:
	dc.b	5, $14, 0, 0, 0
	dc.b	$D0, 0, 0, 0, $F8
	dc.b	$D0, 0, 8, 0, 0
	dc.b	$D8, 7, 0, 1, $F0
	dc.b	$D8, 7, 8, 1, 0
	dc.b	$F8, 4, 0, 9, $F0
	dc.b	$F8, 4, 8, 9, 0
	dc.b	0
byte_3A0FA:
	dc.b	3, $15, 0, 0, 0
	dc.b	$E0, $D, 0, 0, $FC
	dc.b	$E8, 0, 0, 8, $F4
	dc.b	$F0, $D, 0, 9, $EC
	dc.b	$F0, 0, 0, $11, $C
	dc.b	0
byte_3A114:
	dc.b	2, $16, 0, 0, 0
	dc.b	$E0, 9, 0, 0, $E8
	dc.b	$E0, 9, 0, 6, 0
	dc.b	$F0, $D, 0, $C, $F0
byte_3A128:
	dc.b	2, $17, 0, 0, 0
	dc.b	$E0, $E, 0, 0, $E4
	dc.b	$E8, 1, 0, $C, 4
	dc.b	$F8, 8, 0, $E, $F4
byte_3A13C:
	dc.b	2, $18, 0, 0, 0
	dc.b	$E0, 9, 0, 0, $E8
	dc.b	$E0, 9, 0, 6, 0
	dc.b	$F0, $D, 0, $C, $F0
byte_3A150:
	dc.b	3, $19, 0, 0, 0
	dc.b	$D0, 0, 0, 0, $FC
	dc.b	$D8, $D, 0, 1, $EC
	dc.b	$E8, $D, 0, 9, $F4
	dc.b	$F8, 8, 0, $11, $F4
	dc.b	0
byte_3A16A:
	dc.b	4, $1A, 0, 0, 0
	dc.b	$D0, 0, 0, 0, $FC
	dc.b	$D8, 8, 0, 1, $F4
	dc.b	$E0, $D, 0, 4, $EC
	dc.b	$E0, 1, 0, $C, $C
	dc.b	$F0, 9, 0, $E, $F4
byte_3A188:
	dc.b	3, $1B, 0, 0, 0
	dc.b	$D0, 4, 0, 0, $F8
	dc.b	$D8, $E, 0, 2, $F0
	dc.b	$F0, 8, 0, $E, $F8
	dc.b	$F8, $C, 0, $11, $F0
	dc.b	0
byte_3A1A2:
	dc.b	7, $1C, 0, 0, 0
	dc.b	$D8, 0, 0, 0, $F8
	dc.b	$D8, 0, 8, 1, 0
	dc.b	$E0, 9, 0, 2, $E8
	dc.b	$E0, 9, 8, 8, 0
	dc.b	$F0, 4, 0, $E, $F0
	dc.b	$F0, 4, 8, $10, 0
	dc.b	$F8, 0, 0, $12, $F8
	dc.b	$F8, 0, 8, $13, 0
	dc.b	0
byte_3A1D0:
	dc.b	3, $1D, 0, 0, 0
	dc.b	$D8, 6, 0, 0, $F0
	dc.b	$D8, 6, 8, 6, 0
	dc.b	$F0, 9, 0, $C, $E8
	dc.b	$F0, 9, 8, $12, 0
	dc.b	0
byte_3A1EA:
	dc.b	3, $1E, 0, 0, 0
	dc.b	$D8, 6, 0, 0, $F0
	dc.b	$D8, 6, 8, 6, 0
	dc.b	$F0, 9, 0, $C, $E8
	dc.b	$F0, 9, 8, $12, 0
	dc.b	0
byte_3A204:
	dc.b	2, $1F, 0, 0, 0
	dc.b	$D0, 9, 0, 0, $F8
	dc.b	$E0, $E, 0, 6, $F0
	dc.b	$F8, 4, 0, $12, $F0
byte_3A218:
	dc.b	2, $20, 0, 0, 0
	dc.b	$D0, 9, 0, 0, $F8
	dc.b	$E0, $E, 0, 6, $F0
	dc.b	$F8, 4, 0, $12, $F8
byte_3A22C:
	dc.b	2, $21, 0, 0, 0
	dc.b	$D0, 8, 0, 0, $F8
	dc.b	$D8, $E, 0, 3, $F0
	dc.b	$F0, 9, 0, $F, $F0
byte_3A240:
	dc.b	3, $22, 0, 0, 0
	dc.b	$D0, 8, 0, 0, $F8
	dc.b	$D8, $E, 0, 3, $F0
	dc.b	$F0, 8, 0, $F, $F0
	dc.b	$F8, 4, 0, $12, $F8
	dc.b	0
byte_3A25A:
	dc.b	2, $23, 0, 0, 0
	dc.b	$D0, 8, 0, 0, $F8
	dc.b	$D8, $F, 0, 3, $F0
	dc.b	$F8, $C, 0, $13, $F0
byte_3A26E:
	dc.b	3, $24, 0, 0, 0
	dc.b	$D0, 8, 0, 0, $F8
	dc.b	$D8, $D, 0, 3, $F0
	dc.b	$E8, 9, 0, $B, $F8
	dc.b	$F8, 4, 0, $11, $F0
	dc.b	0
byte_3A288:
	dc.b	3, $25, 0, 0, 0
	dc.b	$D0, 4, 0, 0, $F8
	dc.b	$D8, $E, 0, 2, $F0
	dc.b	$F0, 8, 0, $E, $F0
	dc.b	$F8, 4, 0, $11, $F0
	dc.b	0
byte_3A2A2:
	dc.b	3, $26, 0, 0, 0
	dc.b	$D0, 4, 0, 0, $F8
	dc.b	$D8, 8, 0, 2, $F8
	dc.b	$E0, $E, 0, 5, $F0
	dc.b	$F8, 4, 0, $11, $F8
	dc.b	0
byte_3A2BC:
	dc.b	2, $27, 0, 0, 0
	dc.b	$D0, $F, 0, 0, $F0
	dc.b	$F0, $C, 0, $10, $F0
	dc.b	$F8, 8, 0, $14, $F8
byte_3A2D0:
	dc.b	2, $28, 0, 0, 0
	dc.b	$D0, 8, 0, 0, $F0
	dc.b	$D8, $E, 0, 3, $F0
	dc.b	$F0, 9, 0, $F, $F8
byte_3A2E4:
	dc.b	1, $29, 0, 0, 0
	dc.b	$D0, $A, 0, 0, $F8
	dc.b	$E8, $E, 0, 9, $F0
	dc.b	0
byte_3A2F4:
	dc.b	2, $2A, 0, 0, 0
	dc.b	$D0, $E, 0, 0, $F0
	dc.b	$E8, 5, 0, $C, $F8
	dc.b	$F8, 8, 0, $10, $F0
byte_3A308:
	dc.b	2, $2B, 0, 0, 0
	dc.b	$D0, $E, 0, 0, $F0
	dc.b	$E8, 9, 0, $C, $F8
	dc.b	$F8, $C, 0, $12, $F0
byte_3A31C:
	dc.b	2, $2C, 0, 0, 0
	dc.b	$D0, $E, 0, 0, $F0
	dc.b	$E8, 9, 0, $C, $F8
	dc.b	$F8, $C, 0, $12, $F0
byte_3A330:
	dc.b	2, $2D, 0, 0, 0
	dc.b	$D0, $E, 0, 0, $F0
	dc.b	$E8, 9, 0, $C, $F8
	dc.b	$F8, $C, 0, $12, $F0
byte_3A344:
	dc.b	2, $2E, 0, 0, 0
	dc.b	$D0, $E, 0, 0, $F0
	dc.b	$E8, 9, 0, $C, $F8
	dc.b	$F8, $C, 0, $12, $F0
byte_3A358:
	dc.b	2, $2F, 0, 0, 0
	dc.b	$D0, $E, 0, 0, $F0
	dc.b	$E8, 9, 0, $C, $F8
	dc.b	$F8, $C, 0, $12, $F0
byte_3A36C:
	dc.b	5, $30, 0, 0, 0
	dc.b	$C8, 4, 0, 0, $F8
	dc.b	$D0, 9, 0, 2, $E8
	dc.b	$D0, 9, 8, 2, 0
	dc.b	$E0, $C, 0, 8, $F0
	dc.b	$E8, 5, 0, $C, $F8
	dc.b	$F8, $C, 0, $10, $F0
	dc.b	0
byte_3A390:
	dc.b	5, $31, 0, 0, 0
	dc.b	$C8, 9, 0, 0, $E8
	dc.b	$C8, 9, 8, 0, 0
	dc.b	$D8, 7, 0, 6, $F0
	dc.b	$D8, 7, 8, 6, 0
	dc.b	$F8, 4, 0, $E, $F0
	dc.b	$F8, 4, 8, $E, 0
	dc.b	0
byte_3A3B4:
	dc.b	2, $32, 0, 0, 0
	dc.b	$D0, $E, 0, 0, $F0
	dc.b	$E8, 4, 0, $C, $F8
	dc.b	$F0, 9, 0, $E, $F8
byte_3A3C8:
	dc.b	1, $33, 0, 0, 0
	dc.b	$D0, $E, 0, 0, $F0
	dc.b	$E8, $A, 0, $C, $F8
	dc.b	0
byte_3A3D8:
	dc.b	1, $34, 0, 0, 0
	dc.b	$D0, $F, 0, 0, $F0
	dc.b	$F0, 9, 0, $10, $F8
	dc.b	0
byte_3A3E8:
	dc.b	3, $35, 0, 0, 0
	dc.b	$D0, 8, 0, 0, $F8
	dc.b	$D8, $E, 0, 3, $F0
	dc.b	$F0, 4, 0, $F, $F8
	dc.b	$F8, 8, 0, $11, $F8
	dc.b	0
byte_3A402:
	dc.b	2, $36, 0, 0, 0
	dc.b	$D0, 9, 0, 0, $F8
	dc.b	$E0, $D, 0, 6, $F0
	dc.b	$F0, 9, 0, $E, $F8
byte_3A416:
	dc.b	8, $37, 0, 0, 0
	dc.b	$C8, 0, 0, 0, $EC
	dc.b	$C8, 0, 0, 1, $FC
	dc.b	$C8, 0, 0, 2, $C
	dc.b	$D0, 9, 0, 3, $EC
	dc.b	$D0, 5, 0, 9, 4
	dc.b	$E0, 8, 0, $D, $F4
	dc.b	$E8, 4, 0, $10, $F4
	dc.b	$F0, 8, 0, $12, $F4
	dc.b	$F8, 4, 0, $15, $FC
byte_3A448:
	dc.b	2, $38, 0, 0, 0
	dc.b	$D0, 4, 0, 0, $F8
	dc.b	$D8, $F, 0, 2, $F0
	dc.b	$F8, 8, 0, $12, $F0
byte_3A45C:
	dc.b	2, $39, 0, 0, 0
	dc.b	$D0, $E, 0, 0, $F0
	dc.b	$E8, 5, 0, $C, $F8
	dc.b	$F8, 8, 0, $10, $F0
byte_3A470:
	dc.b	3, $3A, 0, 0, 0
	dc.b	$D0, 8, 0, 0, $F8
	dc.b	$D8, $D, 0, 3, $F0
	dc.b	$E8, 5, 0, $B, $F8
	dc.b	$F8, 8, 0, $F, $F0
	dc.b	0
byte_3A48A:
	dc.b	4, $3B, 0, 0, 0
	dc.b	$D0, 8, 0, 0, $F8
	dc.b	$D8, $D, 0, 3, $F0
	dc.b	$E8, 4, 0, $B, $F8
	dc.b	$F0, 8, 0, $D, $F8
	dc.b	$F8, 8, 0, $10, $F0
byte_3A4A8:
	dc.b	2, $3C, 0, 0, 0
	dc.b	$D0, $A, 0, 0, $F8
	dc.b	$E8, 5, 0, 9, $F8
	dc.b	$F8, 8, 0, $D, $F0
byte_3A4BC:
	dc.b	1, $3D, 0, 0, 0
	dc.b	$D0, $B, 0, 0, $F4
	dc.b	$F0, 9, 0, $C, $F4
	dc.b	0
byte_3A4CC:
	dc.b	1, $3E, 0, 0, 0
	dc.b	$D0, $B, 0, 0, $F4
	dc.b	$F0, 9, 0, $C, $F4
	dc.b	0
byte_3A4DC:
	dc.b	1, $3F, 0, 0, 0
	dc.b	$D0, $B, 0, 0, $F4
	dc.b	$F0, 9, 0, $C, $F4
	dc.b	0
Spr_Splash:
	dc.l	byte_3A4F4
	dc.l	byte_3A512
byte_3A4F4:
	dc.b	7, 1
	dc.l	byte_3A520
	dc.l	byte_3A530
	dc.l	byte_3A540
	dc.l	byte_3A54A
	dc.l	byte_3A55E
	dc.l	byte_3A578
	dc.l	byte_3A582
byte_3A512:
	dc.b	3, 0
	dc.l	byte_3A520
	dc.l	byte_3A530
	dc.l	byte_3A540
byte_3A520:
	dc.b	1, 0, 0, 0, 0
	dc.b	$F0, 4, 0, 0, $F8
	dc.b	$F8, $C, 0, 2, $F0
	dc.b	0
byte_3A530:
	dc.b	1, 0, 0, 0, 0
	dc.b	$E0, 0, 0, 6, $F8
	dc.b	$E8, $E, 0, 7, $F0
	dc.b	0
byte_3A540:
	dc.b	0, 0, 0, 0, 0
	dc.b	$E0, $F, 0, $13, $F0
byte_3A54A:
	dc.b	2, 0, 0, 0, 0
	dc.b	$D0, 4, 0, $23, $F8
	dc.b	$D8, 8, 0, $25, $F0
	dc.b	$E0, $F, 0, $28, $F0
byte_3A55E:
	dc.b	3, 0, 0, 0, 0
	dc.b	$C0, 8, 0, $38, $F8
	dc.b	$C8, 8, 0, $3B, $F0
	dc.b	$D0, $F, 0, $3E, $F0
	dc.b	$F0, $D, 0, $4E, $F0
	dc.b	0
byte_3A578:
	dc.b	0, 0, 0, 0, 0
	dc.b	$F8, 4, 0, $56, $F8
byte_3A582:
	dc.b	1, 0, 0, 0, 0
	dc.b	$F8, 4, 0, $58, $F0
	dc.b	$F8, 4, 8, $58, 0
	dc.b	0
Spr_Shadow:
	dc.l	byte_3A5BA
	dc.l	byte_3A5C0
	dc.l	byte_3A5C6
	dc.l	byte_3A5CC
	dc.l	byte_3A5D2
	dc.l	byte_3A5D8
	dc.l	byte_3A5DE
	dc.l	byte_3A5E4
	dc.l	byte_3A5EA
	dc.l	byte_3A5F0
byte_3A5BA:
	dc.b	1, $FF
	dc.l	byte_3A5F6
byte_3A5C0:
	dc.b	1, $FF
	dc.l	byte_3A606
byte_3A5C6:
	dc.b	1, $FF
	dc.l	byte_3A61A
byte_3A5CC:
	dc.b	1, $FF
	dc.l	byte_3A62A
byte_3A5D2:
	dc.b	1, $FF
	dc.l	byte_3A63A
byte_3A5D8:
	dc.b	1, $FF
	dc.l	byte_3A64E
byte_3A5DE:
	dc.b	1, $FF
	dc.l	byte_3A65E
byte_3A5E4:
	dc.b	1, $FF
	dc.l	byte_3A668
byte_3A5EA:
	dc.b	1, $FF
	dc.l	byte_3A672
byte_3A5F0:
	dc.b	1, $FF
	dc.l	byte_3A67C
byte_3A5F6:
	dc.b	1, 0, 0, 0, 0
	dc.b	$F8, $D, 0, 0, $E0
	dc.b	$F8, $D, 8, 0, 0
	dc.b	0
byte_3A606:
	dc.b	2, 0, 0, 0, 0
	dc.b	$F8, 9, 0, 8, $E4
	dc.b	$F8, 1, 0, $E, $FC
	dc.b	$F8, 9, 8, 8, 4
byte_3A61A:
	dc.b	1, 0, 0, 0, 0
	dc.b	$FC, 8, 0, $10, $E8
	dc.b	$FC, 8, 8, $10, 0
	dc.b	0
byte_3A62A:
	dc.b	1, 0, 0, 0, 0
	dc.b	$FC, 8, 0, $13, $E8
	dc.b	$FC, 8, 8, $13, 0
	dc.b	0
byte_3A63A:
	dc.b	2, 0, 0, 0, 0
	dc.b	$FC, 4, 0, $16, $EC
	dc.b	$FC, 4, 8, $16, 4
	dc.b	$FC, 0, 0, $18, $FC
byte_3A64E:
	dc.b	1, 0, 0, 0, 0
	dc.b	$FC, 4, 0, $19, $F0
	dc.b	$FC, 4, 8, $19, 0
	dc.b	0
byte_3A65E:
	dc.b	0, 0, 0, 0, 0
	dc.b	$FC, 8, 0, $1B, $F4
byte_3A668:
	dc.b	0, 0, 0, 0, 0
	dc.b	$FC, 8, 0, $1E, $F4
byte_3A672:
	dc.b	0, 0, 0, 0, 0
	dc.b	$FC, 4, 0, $21, $F8
byte_3A67C:
	dc.b	0, 0, 0, 0, 0
	dc.b	$FC, 0, 0, $23, $FC
Spr_UFO1:
	dc.l	byte_3A6AE
	dc.l	byte_3A6B4
	dc.l	byte_3A6BA
	dc.l	byte_3A6C0
	dc.l	byte_3A6C6
	dc.l	byte_3A6CC
	dc.l	byte_3A6D2
	dc.l	byte_3A6D8
	dc.l	byte_3A6DE
	dc.l	byte_3A6E4
byte_3A6AE:
	dc.b	1, $FF
	dc.l	byte_3A6EA
byte_3A6B4:
	dc.b	1, $FF
	dc.l	byte_3A718
byte_3A6BA:
	dc.b	1, $FF
	dc.l	byte_3A73C
byte_3A6C0:
	dc.b	1, $FF
	dc.l	byte_3A756
byte_3A6C6:
	dc.b	1, $FF
	dc.l	byte_3A77A
byte_3A6CC:
	dc.b	1, $FF
	dc.l	byte_3A794
byte_3A6D2:
	dc.b	1, $FF
	dc.l	byte_3A7A4
byte_3A6D8:
	dc.b	1, $FF
	dc.l	byte_3A7B8
byte_3A6DE:
	dc.b	1, $FF
	dc.l	byte_3A7CC
byte_3A6E4:
	dc.b	1, $FF
	dc.l	byte_3A7D6
byte_3A6EA:
	dc.b	7, 0, 0, 0, 0
	dc.b	$C8, 8, 0, 0, $E8
	dc.b	$C8, 8, 8, 0, 0
	dc.b	$D0, $F, 0, 3, $E0
	dc.b	$D0, $F, 8, 3, 0
	dc.b	$F0, $C, 0, $13, $E0
	dc.b	$F0, $C, 8, $13, 0
	dc.b	$F8, 8, 0, $17, $E8
	dc.b	$F8, 8, 8, $17, 0
	dc.b	0
byte_3A718:
	dc.b	5, 0, 0, 0, 0
	dc.b	$D0, 8, 0, $1A, $E8
	dc.b	$D0, 8, 8, $1A, 0
	dc.b	$D8, $E, 0, $1D, $E0
	dc.b	$D8, $E, 8, $1D, 0
	dc.b	$F0, 9, 0, $29, $E8
	dc.b	$F0, 9, 8, $29, 0
	dc.b	0
byte_3A73C:
	dc.b	3, 0, 0, 0, 0
	dc.b	$D8, $B, 0, $2F, $E8
	dc.b	$D8, $B, 8, $2F, 0
	dc.b	$F8, 4, 0, $3B, $F0
	dc.b	$F8, 4, 8, $3B, 0
	dc.b	0
byte_3A756:
	dc.b	5, 0, 0, 0, 0
	dc.b	$D8, 4, 0, $3D, $F0
	dc.b	$D8, 4, 8, $3D, 0
	dc.b	$E0, $A, 0, $3F, $E8
	dc.b	$E0, $A, 8, $3F, 0
	dc.b	$F8, 4, 0, $48, $F0
	dc.b	$F8, 4, 8, $48, 0
	dc.b	0
byte_3A77A:
	dc.b	3, 0, 0, 0, 0
	dc.b	$E0, $A, 0, $4A, $E8
	dc.b	$E0, $A, 8, $4A, 0
	dc.b	$F8, 4, 0, $53, $F0
	dc.b	$F8, 4, 8, $53, 0
	dc.b	0
byte_3A794:
	dc.b	1, 0, 0, 0, 0
	dc.b	$E0, 7, 0, $55, $F0
	dc.b	$E0, 7, 8, $55, 0
	dc.b	0
byte_3A7A4:
	dc.b	2, 0, 0, 0, 0
	dc.b	$E8, 2, 0, $5D, $F4
	dc.b	$E8, 2, 0, $60, $FC
	dc.b	$E8, 2, 8, $5D, 4
byte_3A7B8:
	dc.b	2, 0, 0, 0, 0
	dc.b	$F0, 1, 0, $63, $F4
	dc.b	$F0, 1, 0, $65, $FC
	dc.b	$F0, 1, 8, $63, 4
byte_3A7CC:
	dc.b	0, 0, 0, 0, 0
	dc.b	$F0, 5, 0, $67, $F8
byte_3A7D6:
	dc.b	0, 0, 0, 0, 0
	dc.b	$F8, 0, 0, $6B, $FC
Spr_UFO2:
	dc.l	byte_3A808
	dc.l	byte_3A80E
	dc.l	byte_3A814
	dc.l	byte_3A81A
	dc.l	byte_3A820
	dc.l	byte_3A826
	dc.l	byte_3A82C
	dc.l	byte_3A832
	dc.l	byte_3A838
	dc.l	byte_3A83E
byte_3A808:
	dc.b	1, $FF
	dc.l	byte_3A844
byte_3A80E:
	dc.b	1, $FF
	dc.l	byte_3A872
byte_3A814:
	dc.b	1, $FF
	dc.l	byte_3A896
byte_3A81A:
	dc.b	1, $FF
	dc.l	byte_3A8B0
byte_3A820:
	dc.b	1, $FF
	dc.l	byte_3A8D4
byte_3A826:
	dc.b	1, $FF
	dc.l	byte_3A8EE
byte_3A82C:
	dc.b	1, $FF
	dc.l	byte_3A8FE
byte_3A832:
	dc.b	1, $FF
	dc.l	byte_3A912
byte_3A838:
	dc.b	1, $FF
	dc.l	byte_3A926
byte_3A83E:
	dc.b	1, $FF
	dc.l	byte_3A930
byte_3A844:
	dc.b	7, 0, 0, 0, 0
	dc.b	$C8, 8, 0, $6C, $E8
	dc.b	$C8, 8, 8, $6C, 0
	dc.b	$D0, $F, 0, $6F, $E0
	dc.b	$D0, $F, 8, $6F, 0
	dc.b	$F0, $C, 0, $7F, $E0
	dc.b	$F0, $C, 8, $7F, 0
	dc.b	$F8, 8, 0, $83, $E8
	dc.b	$F8, 8, 8, $83, 0
	dc.b	0
byte_3A872:
	dc.b	5, 0, 0, 0, 0
	dc.b	$D0, 8, 0, $86, $E8
	dc.b	$D0, 8, 8, $86, 0
	dc.b	$D8, $E, 0, $89, $E0
	dc.b	$D8, $E, 8, $89, 0
	dc.b	$F0, 9, 0, $95, $E8
	dc.b	$F0, 9, 8, $95, 0
	dc.b	0
byte_3A896:
	dc.b	3, 0, 0, 0, 0
	dc.b	$D8, $B, 0, $9B, $E8
	dc.b	$D8, $B, 8, $9B, 0
	dc.b	$F8, 4, 0, $A7, $F0
	dc.b	$F8, 4, 8, $A7, 0
	dc.b	0
byte_3A8B0:
	dc.b	5, 0, 0, 0, 0
	dc.b	$D8, 4, 0, $3D, $F0
	dc.b	$D8, 4, 8, $3D, 0
	dc.b	$E0, $A, 0, $A9, $E8
	dc.b	$E0, $A, 8, $A9, 0
	dc.b	$F8, 4, 0, $B2, $F0
	dc.b	$F8, 4, 8, $B2, 0
	dc.b	0
byte_3A8D4:
	dc.b	3, 0, 0, 0, 0
	dc.b	$E0, $A, 0, $B4, $E8
	dc.b	$E0, $A, 8, $B4, 0
	dc.b	$F8, 4, 0, $BD, $F0
	dc.b	$F8, 4, 8, $BD, 0
	dc.b	0
byte_3A8EE:
	dc.b	1, 0, 0, 0, 0
	dc.b	$E0, 7, 0, $BF, $F0
	dc.b	$E0, 7, 8, $BF, 0
	dc.b	0
byte_3A8FE:
	dc.b	2, 0, 0, 0, 0
	dc.b	$E8, 2, 0, $C7, $F4
	dc.b	$E8, 2, 0, $CA, $FC
	dc.b	$E8, 2, 8, $C7, 4
byte_3A912:
	dc.b	2, 0, 0, 0, 0
	dc.b	$F0, 1, 0, $CD, $F4
	dc.b	$F0, 1, 0, $CF, $FC
	dc.b	$F0, 1, 8, $CD, 4
byte_3A926:
	dc.b	0, 0, 0, 0, 0
	dc.b	$F0, 5, 0, $D1, $F8
byte_3A930:
	dc.b	0, 0, 0, 0, 0
	dc.b	$F8, 0, 0, $D5, $FC
	
	align	VARSSTART, $FF
	dcb.b	VARSSZ, $FF
	
Stamps_SS1:
	incbin	"Special Stage/Data/Stage 1/Stamps.kos"
	align	$10

Stamps_SS2:
	incbin	"Special Stage/Data/Stage 2/Stamps.kos"
	align	$10
	
Stamps_SS3_1:
	incbin	"Special Stage/Data/Stage 3/Stamps 1.kos"
	align	$10
	
Stamps_SS3_2:
	incbin	"Special Stage/Data/Stage 3/Stamps 2.kos"
	align	$10
	
Stamps_SS4:
	incbin	"Special Stage/Data/Stage 4/Stamps.kos"
	align	$10
	
Stamps_SS5:
	incbin	"Special Stage/Data/Stage 5/Stamps.kos"
	align	$10

Stamps_SS6:
	incbin	"Special Stage/Data/Stage 6/Stamps.kos"
	align	$10
	
Stamps_SS7:
	incbin	"Special Stage/Data/Stage 7/Stamps.kos"
	align	$10

Stamps_SS8:
	incbin	"Special Stage/Data/Stage 8/Stamps.kos"
	align	$10

StampMap_SS1:
	incbin	"Special Stage/Data/Stage 1/Stamp Map.kos"
	align	$10

StampMap_SS2:
	incbin	"Special Stage/Data/Stage 2/Stamp Map.kos"
	align	$10
	
StampMap_SS3:
	incbin	"Special Stage/Data/Stage 3/Stamp Map.kos"
	align	$10
	
StampMap_SS4:
	incbin	"Special Stage/Data/Stage 4/Stamp Map.kos"
	align	$10
	
StampMap_SS5:
	incbin	"Special Stage/Data/Stage 5/Stamp Map.kos"
	align	$10
	
StampMap_SS6:
	incbin	"Special Stage/Data/Stage 6/Stamp Map.kos"
	align	$10
	
StampMap_SS7:
	incbin	"Special Stage/Data/Stage 7/Stamp Map.kos"
	align	$10
	
StampMap_SS8:
	incbin	"Special Stage/Data/Stage 8/Stamp Map.kos"
	align	$10

; -------------------------------------------------------------------------

	align	$10000, $FF

; -------------------------------------------------------------------------
