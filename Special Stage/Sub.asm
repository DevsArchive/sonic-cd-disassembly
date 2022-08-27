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
oMap		rs.l	1			; Mappings
oAnim		rs.b	1			; Animation ID
oAnimFrame	rs.b	1			; Animation frame
oAnimTime	rs.b	1			; Animation time
oAnimTime2	rs.b	1			; Animation time (copy)
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
; Set object animation
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.b - Animation ID
;	a0.l - Pointer to object slot
; -------------------------------------------------------------------------

SetObjAnim:
	move.b	d0,oAnim(a0)			; Set animation ID
	
	moveq	#0,d0				; Reset animation frame
	move.b	d0,oAnimFrame(a0)

	movea.l	oMap(a0),a6			; Get animation
	move.b	oAnim(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	movea.l	(a6,d0.w),a6

	move.b	(a6)+,d0			; Skip over number of frames
	move.b	(a6),oAnimTime(a0)		; Get animation speed
	move.b	(a6)+,oAnimTime2(a0)
	rts

; -------------------------------------------------------------------------
; Change object animation midway
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.b - Animation ID
;	a0.l - Pointer to object slot
; -------------------------------------------------------------------------

ChgObjAnim:
	move.b	d0,oAnim(a0)			; Set animation ID

	movea.l	oMap(a0),a6			; Get animation
	moveq	#0,d0
	move.b	oAnim(a0),d0
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
	movea.l	oMap(a0),a2			; Get animation
	moveq	#0,d0
	move.b	oAnim(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	movea.l	(a2,d0.w),a2

	move.b	(a2)+,d1			; Get number of frames
	move.b	(a2)+,d2			; Get animation speed

	btst	#1,oFlags(a0)			; Should we animate?
	bne.s	.GetSprite			; If not, branch

	subq.b	#1,oAnimTime(a0)		; Decrement animation time
	bpl.s	.GetSprite			; If it hasn't run out, branch
	move.b	d2,oAnimTime(a0)		; Reset animation time

	addq.b	#1,oAnimFrame(a0)		; Increment animation frame
	cmp.b	oAnimFrame(a0),d1		; Has it gone past the last frame?
	bhi.s	.GetSprite			; If not, branch
	move.b	#0,oAnimFrame(a0)		; Restart animation

.GetSprite:
	btst	#2,oFlags(a0)			; Should this sprite be drawn?
	bne.w	.End				; If not, branch

	move.w	oSprX(a0),d4			; Get sprite position
	move.w	oSprY(a0),d3

	moveq	#0,d0				; Get sprite data
	move.b	oAnimFrame(a0),d0
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
	include	"Special Stage/Objects/Splash/Main.asm"
	include	"Special Stage/Objects/Dust/Main.asm"
	include	"Special Stage/Objects/Time Stone/Main.asm"
	
; -------------------------------------------------------------------------
	
	align	SpecStageData, $FF
	incbin	"Special Stage/Stage Data.bin"
	align	PRGRAM+$30000, $FF

; -------------------------------------------------------------------------
; Data section
; -------------------------------------------------------------------------

DataSection:

SonicArt:
	include	"Special Stage/Objects/Sonic/Data/Art.asm"
	even

MapSpr_Sonic:
	include	"Special Stage/Objects/Sonic/Data/Mappings.asm"

MapSpr_Splash:
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
MapSpr_Shadow:
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
MapSpr_UFO1:
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
MapSpr_UFO2:
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
