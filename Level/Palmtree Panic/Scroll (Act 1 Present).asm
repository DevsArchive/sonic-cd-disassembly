; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Palmtree Panic Act 1 Present level scrolling/drawing
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Get level size and start position
; -------------------------------------------------------------------------

LevelSizeLoad:
	moveq	#0,d0				; Clear unused variables
	move.b	d0,unusedF740.w
	move.b	d0,unusedF741.w
	move.b	d0,unusedF746.w
	move.b	d0,unusedF748.w
	move.b	d0,eventRoutine.w		; Clear level event routine

	lea	CamBounds,a0			; Prepare camera boundary information
	move.w	(a0)+,d0			; Get unused word
	move.w	d0,unusedF730.w
	move.l	(a0)+,d0			; Get left and right boundaries
	move.l	d0,leftBound.w
	move.l	d0,destLeftBound.w
	move.l	(a0)+,d0			; Get top and bottom boundaries
	move.l	d0,topBound.w
	move.l	d0,destTopBound.w
	move.w	leftBound.w,d0			; Get left boundary + $240
	addi.w	#$240,d0
	move.w	d0,leftBound3.w
	move.w	#$1010,horizBlkCrossed.w	; Initialize horizontal block crossed flags
	move.w	(a0)+,d0			; Get camera Y center
	move.w	d0,camYCenter.w
	move.w	#320/2,camXCenter.w		; Get camera X center

	bra.w	LevelSizeLoad_StartPos

; -------------------------------------------------------------------------
; Camera boundaries
; -------------------------------------------------------------------------

CamBounds:
	dc.w	4, 0, $2897, 0, $710, $60

; -------------------------------------------------------------------------
; Leftover ending demo start positions from Sonic 1
; -------------------------------------------------------------------------

EndingStLocsS1:
	dc.w	$50, $3B0
	dc.w	$EA0, $46C
	dc.w	$1750, $BD
	dc.w	$A00, $62C
	dc.w	$BB0, $4C
	dc.w	$1570, $16C
	dc.w	$1B0, $72C
	dc.w	$1400, $2AC

; -------------------------------------------------------------------------

LevelSizeLoad_StartPos:
	tst.b	resetLevelFlags			; Was the level reset midway?
	beq.s	.DefaultStart			; If not, branch

	jsr	ObjCheckpoint_LoadData		; Load checkpoint data
	moveq	#0,d0				; Get player position
	moveq	#0,d1
	move.w	objPlayerSlot+oX.w,d1
	move.w	objPlayerSlot+oY.w,d0
	bpl.s	.SkipCap			; If the Y position is positive, branch
	moveq	#0,d0				; Cap the Y position at 0 if negative

.SkipCap:
	bra.s	.SetupCamera

.DefaultStart:
	lea	LevelStartLoc,a1		; Prepare level start position
	moveq	#0,d1				; Get starting X position
	move.w	(a1)+,d1
	move.w	d1,objPlayerSlot+oX.w
	moveq	#0,d0				; Get starting Y position
	move.w	(a1),d0
	move.w	d0,objPlayerSlot+oY.w

.SetupCamera:
	subi.w	#320/2,d1			; Get camera X position
	bcc.s	.SkipXLeftBnd			; If it doesn't need to be capped, branch
	moveq	#0,d1				; If it does, cap at 0

.SkipXLeftBnd:
	move.w	rightBound.w,d2			; Is the camera past the right boundary?
	cmp.w	d2,d1
	bcs.s	.SkipXRightBnd			; If not, branch
	move.w	d2,d1				; If so, cap it

.SkipXRightBnd:
	move.w	d1,cameraX.w			; Set camera X position

	subi.w	#$60,d0				; Get camera Y position
	bcc.s	.SkipYTopBnd			; If it doesn't need to be capped, branch
	moveq	#0,d0				; If it does, cap at 0

.SkipYTopBnd:
	cmp.w	bottomBound.w,d0		; Is the camera past the bottom boundary?
	blt.s	.SkipYBtmBnd			; If not, branch
	move.w	bottomBound.w,d0		; If so, cap it

.SkipYBtmBnd:
	move.w	d0,cameraY.w			; Set camera Y position

	bsr.w	InitLevelScroll			; Initialize level scrolling

	lea	SpecChunks,a1			; Get loop chunks
	move.l	(a1),specialChunks.w
	rts

; -------------------------------------------------------------------------
; Start location
; -------------------------------------------------------------------------

LevelStartLoc:
	incbin	"Level/Palmtree Panic/Data/Start Position (Act 1 Present).bin"

; -------------------------------------------------------------------------
; Special chunk IDs
; -------------------------------------------------------------------------

SpecChunks:
	dc.b	$7F, $7F, $7F, $7F

; -------------------------------------------------------------------------
; Initialize level scrolling
; -------------------------------------------------------------------------

InitLevelScroll:
	cmpi.w	#$800,objPlayerSlot+oX.w	; Has the player gone past the first 3D ramp?
	bcs.s	.No3DRamp			; If not, branch
	subi.w	#$1E0,d0			; Get background Y position after first 3D ramp
	bcs.s	.ChgDir
	lsr.w	#1,d0

.ChgDir:
	addi.w	#$1E0,d0			; Get background Y position

.No3DRamp:
	swap	d0				; Set background Y positions
	move.l	d0,cameraBgY.w
	swap	d0
	move.w	d0,cameraBg2Y.w
	move.w	d0,cameraBg3Y.w

	lsr.w	#1,d1				; Get background X positions
	move.w	d1,cameraBgX.w
	lsr.w	#2,d1
	move.w	d1,d2
	add.w	d2,d2
	add.w	d1,d2
	move.w	d2,cameraBg3X.w
	lsr.w	#1,d1
	move.w	d1,d2
	add.w	d2,d2
	add.w	d1,d2
	move.w	d2,cameraBg2X.w

	lea	lvlLayerSpeeds,a2		; Clear cloud speeds
	moveq	#$12,d6

.ClearSpeeds:
	clr.l	(a2)+
	dbf	d6,.ClearSpeeds
	rts

; -------------------------------------------------------------------------
; Handle level scrolling
; -------------------------------------------------------------------------

LevelScroll:
	tst.b	scrollLock.w			; Is scrolling locked?
	beq.s	.DoScroll			; If not, branch
	rts

.DoScroll:
	clr.w	scrollFlags.w			; Clear scroll flags
	clr.w	scrollFlagsBg.w
	clr.w	scrollFlagsBg2.w
	clr.w	scrollFlagsBg3.w

	if REGION=USA
		bsr.w	RunLevelEvents		; Run level events
		bsr.w	ScrollCamX		; Scroll camera horizontally
		bsr.w	ScrollCamY		; Scroll camera vertically
	else
		bsr.w	ScrollCamX		; Scroll camera horizontally
		bsr.w	ScrollCamY		; Scroll camera vertically
		bsr.w	RunLevelEvents		; Run level events
	endif

	move.w	cameraY.w,vscrollScreen.w	; Update VScroll values
	move.w	cameraBgY.w,vscrollScreen+2.w

; -------------------------------------------------------------------------

	moveq	#0,d5				; Reset scroll speed offset
	btst	#1,objPlayerSlot+oPlayerCtrl.w	; Is the player on a 3D ramp?
	beq.s	.GotSpeed			; If not, branch
	tst.w	scrollXDiff.w			; Is the camera scrolling horizontally?
	beq.s	.GotSpeed			; If not, branch
	move.w	objPlayerSlot+oXVel.w,d5	; Set scroll speed offset to the player's X velocity
	ext.l	d5
	asl.l	#8,d5

.GotSpeed:
	move.w	scrollXDiff.w,d4		; Set scroll offset and flags for the clouds
	ext.l	d4
	asl.l	#5,d4
	add.l	d5,d4
	moveq	#6,d6
	bsr.w	SetHorizScrollFlagsBG3

	move.w	scrollXDiff.w,d4		; Set scroll offset and flags for the mountains
	ext.l	d4
	asl.l	#4,d4
	move.l	d4,d3
	add.l	d3,d3
	add.l	d3,d4
	add.l	d5,d4
	add.l	d5,d4
	moveq	#4,d6
	bsr.w	SetHorizScrollFlagsBG2

	lea	deformBuffer.w,a1		; Prepare deformation buffer

	move.w	scrollXDiff.w,d4		; Set scroll offset and flags for the bushes and water
	ext.l	d4
	asl.l	#7,d4
	add.l	d5,d4
	moveq	#2,d6
	bsr.w	SetHorizScrollFlagsBG

	move.w	cameraY.w,d0			; Get background Y position
	cmpi.w	#$800,objPlayerSlot+oX.w	; Has the player gone past the first 3D ramp?
	bcs.s	.No3DRamp			; If not, branch
	subi.w	#$1E0,d0			; Get background Y position past the first 3D ramp
	bcs.s	.ChgDir
	lsr.w	#1,d0

.ChgDir:
	addi.w	#$1E0,d0			; Get background Y position before the first 3D ramp

.No3DRamp:
	bsr.w	SetVertiScrollFlagsBG2		; Set BG2 vertical scroll flags

	move.w	cameraBgY.w,vscrollScreen+2.w	; Update background Y positions
	move.w	cameraBgY.w,cameraBg2Y.w
	move.w	cameraBgY.w,cameraBg3Y.w

	move.b	scrollFlagsBg3.w,d0		; Combine background scroll flags for the level drawing routine
	or.b	scrollFlagsBg2.w,d0
	or.b	d0,scrollFlagsBg.w
	clr.b	scrollFlagsBg3.w
	clr.b	scrollFlagsBg2.w

	lea	lvlLayerSpeeds,a2		; Set speeds for the clouds
	addi.l	#$10000,(a2)+
	addi.l	#$E000,(a2)+
	addi.l	#$C000,(a2)+
	addi.l	#$A000,(a2)+
	addi.l	#$8000,(a2)+
	addi.l	#$6000,(a2)+
	addi.l	#$4800,(a2)+
	addi.l	#$4000,(a2)+
	addi.l	#$2800,(a2)+
	addi.l	#$2000,(a2)+
	addi.l	#$2000,(a2)+
	addi.l	#$4000,(a2)+
	addi.l	#$8000,(a2)+
	addi.l	#$C000,(a2)+
	addi.l	#$10000,(a2)+
	addi.l	#$C000,(a2)+
	addi.l	#$8000,(a2)+
	addi.l	#$4000,(a2)+
	addi.l	#$2000,(a2)+

	move.w	cameraX.w,d0			; Prepare scroll buffer entry
	neg.w	d0
	swap	d0

	lea	lvlLayerSpeeds,a2		; Prepare cloud speeds
	moveq	#10-1,d6			; Number of cloud sections

.CloudsScroll:
	move.l	(a2)+,d1			; Get cloud section scroll offset
	swap	d1
	add.w	cameraBg3X.w,d1
	neg.w	d1

	moveq	#0,d5				; Get number of lines in this section
	lea	CloudSectSizes,a3
	move.b	(a3,d6.w),d5

.CloudsScrollSect:
	move.w	d1,(a1)+			; Store scroll offset
	dbf	d5,.CloudsScrollSect		; Loop until this section is stored
	dbf	d6,.CloudsScroll		; Loop until the clouds are finished being processed

	move.w	cameraBg2X.w,d0			; Scroll top mountains
	neg.w	d0
	moveq	#20-1,d6

.ScrollMountains:
	move.w	d0,(a1)+
	dbf	d6,.ScrollMountains

	move.w	cameraBgX.w,d0			; Scroll top bushes
	neg.w	d0
	moveq	#4-1,d6

.ScrollBushes:
	move.w	d0,(a1)+
	dbf	d6,.ScrollBushes

	move.w	cameraBgX.w,d0			; Scroll water (top and upside down)
	neg.w	d0
	move.w	#(28*2)-1,d6

.ScrollWater:
	move.w	d0,(a1)+
	dbf	d6,.ScrollWater

	move.w	cameraBgX.w,d0			; Scroll upside down bushes
	neg.w	d0
	moveq	#4-1,d6

.ScrollUpsideDownBushes:
	move.w	d0,(a1)+
	dbf	d6,.ScrollUpsideDownBushes

	move.w	cameraBg2X.w,d0			; Scroll upside down mountains
	neg.w	d0
	moveq	#20-1,d6

.ScrollUpsideDownMountains:
	move.w	d0,(a1)+
	dbf	d6,.ScrollUpsideDownMountains

	moveq	#9-1,d6				; Number of cloud sections

.UpsideDownCloudsScroll:
	move.l	(a2)+,d1			; Get cloud section scroll offset
	swap	d1
	add.w	cameraBg3X.w,d1
	neg.w	d1

	moveq	#0,d5				; Get number of lines in this section
	lea	CloudUpsideDownSectSizes,a3
	move.b	(a3,d6.w),d5

.UpsideDownCloudsScrollSect:
	move.w	d1,(a1)+			; Store scroll offset
	dbf	d5,.UpsideDownCloudsScrollSect	; Loop until this section is stored
	dbf	d6,.UpsideDownCloudsScroll	; Loop until the clouds are finished being processed

	move.w	cameraBg2X.w,d0			; Scroll bottom mountains
	neg.w	d0
	moveq	#20-1,d6

.ScrollBtmMountains:
	move.w	d0,(a1)+
	dbf	d6,.ScrollBtmMountains

	move.w	cameraBgX.w,d0			; Scroll bottom bushes
	neg.w	d0
	moveq	#4-1,d6

.ScrollBtmBushes:
	move.w	d0,(a1)+
	dbf	d6,.ScrollBtmBushes

	move.w	cameraBgX.w,d0			; Scroll bottom water
	neg.w	d0
	move.w	#16-1,d6

.ScrollBtmWater:
	move.w	d0,(a1)+
	dbf	d6,.ScrollBtmWater

	lea	hscroll.w,a1			; Prepare horizontal scroll buffer
	lea	deformBuffer.w,a2		; Prepare deformation buffer

	move.w	cameraBgY.w,d0			; Get background Y position
	move.w	d0,d2
	move.w	d0,d4
	andi.w	#$7F8,d0
	lsr.w	#2,d0
	moveq	#(240/8)-1,d1			; Max number of blocks to scroll
	lea	(a2,d0.w),a2			; Get starting scroll block
	lea	WaterDeformSects,a3		; Prepare water deformation section information
	bra.w	ApplyBGHScroll			; Apply HScroll

; -------------------------------------------------------------------------

CloudSectSizes:					; Top cloud section sizes
	dc.b	2-1
	dc.b	4-1
	dc.b	6-1
	dc.b	8-1
	dc.b	8-1
	dc.b	8-1
	dc.b	4-1
	dc.b	6-1
	dc.b	6-1
	dc.b	4-1

CloudUpsideDownSectSizes:			; Upside down and bottom cloud section sizes
	dc.b	2-1
	dc.b	4-1
	dc.b	6-1
	dc.b	8-1
	dc.b	16-1
	dc.b	4-1
	dc.b	10-1
	dc.b	4-1
	dc.b	2-1
	even

WaterDeformSects:				; Water deform section positions and sizes
	dc.w	$280, $E0
	dc.w	$780, $80
	dc.w	$7FFF, $360

; -------------------------------------------------------------------------

ApplyBGHScroll:
	cmp.w	(a3),d4				; Is the background scrolled past the current water section?
	bcc.s	.FoundWaterSection		; If so, branch

.ScrollUnmodified:
	andi.w	#7,d2				; Get the number of lines to scroll for the first block of lines
	sub.w	d2,d4
	addq.w	#8,d4
	add.w	d2,d2

	move.w	(a2)+,d0			; Start scrolling
	jmp	.ScrollBlock(pc,d2.w)

.ScrollLoop:
	tst.w	d1				; Are we done scrolling?
	bmi.s	.End				; If so, branch
	cmp.w	(a3),d4				; Is the background scrolled past the current water section?
	bcc.s	.FoundWaterSection		; If so, branch

	addq.w	#8,d4				; Scroll another block of lines
	move.w	(a2)+,d0

.ScrollBlock:
	rept	8				; Scroll a block of 8 lines
		move.l	d0,(a1)+
	endr
	dbf	d1,.ScrollLoop			; Loop until finished

.End:
	rts

.FoundWaterSection:
	move.w	d4,d5				; Determine how deep we are into the section
	sub.w	(a3),d5
	move.w	2(a3),d6			; Get number of scanlines to scroll
	sub.w	d5,d6
	bcs.s	.SectOffscreen			; If the section is offscreen now, branch
	beq.s	.NextSection

	move.w	#224,d3				; Get base water deformation speed
	move.w	cameraBgX.w,d0
	move.w	cameraX.w,d2
	sub.w	d0,d2
	ext.l	d2
	asl.l	#8,d2
	divs.w	d3,d2
	ext.l	d2
	asl.l	#8,d2
	moveq	#0,d3
	move.w	d0,d3

	subq.w	#1,d5				; Get number of scanlines in which the section is offscreen
	bmi.s	.GotStartWaterSpeed		; to help get the starting water deformation speed

.GetStartWaterSpeed:
	move.w	d3,d0				; Increment starting water deformation speed
	swap	d3
	add.l	d2,d3
	swap	d3
	dbf	d5,.GetStartWaterSpeed		; Loop until we got it

.GotStartWaterSpeed:
	move.w	d6,d5				; Decrement section size from scroll block count
	lsr.w	#3,d5
	sub.w	d5,d1
	bcc.s	.StartWaterDeform		; If we still have some scroll blocks left over, branch

	move.w	d1,d5				; Shrink the size of the section down to fit only up to the bottom of the screen
	neg.w	d5
	lsl.w	#3,d5
	sub.w	d5,d6
	beq.s	.NextSection			; If the size of the section shrinks down to 0 pixels, branch

.StartWaterDeform:
	subq.w	#1,d6				; Prepare section size

.DoWaterDeform:
	move.w	d3,d0				; Scroll line
	neg.w	d0
	move.l	d0,(a1)+

	swap	d3				; Increment water deformation speed
	add.l	d2,d3
	swap	d3

	addq.w	#1,d4				; Next line
	move.w	d4,d0
	andi.w	#7,d0				; Have we crossed a block?
	bne.s	.NextLine			; If not, branch
	addq.w	#2,a2				; Skip block in the deformation buffer

.NextLine:
	dbf	d6,.DoWaterDeform		; Loop until section is scrolled

.NextSection:
	addq.w	#4,a3				; Next section
	bra.w	.ScrollLoop			; Start scrolling regular blocks of lines again

.SectOffscreen:
	addq.w	#4,a3				; Next section
	move.w	d4,d2				; Start scrolling regular blocks of lines again
	bra.w	.ScrollUnmodified

; -------------------------------------------------------------------------
; Scroll the camera horizontally
; -------------------------------------------------------------------------

ScrollCamX:
	move.w	cameraX.w,d4			; Handle camera movement
	bsr.s	MoveScreenHoriz

	move.w	cameraX.w,d0			; Check if a block has been crossed and set flags accordingly
	andi.w	#$10,d0
	move.b	horizBlkCrossed.w,d1
	eor.b	d1,d0
	bne.s	.End
	eori.b	#$10,horizBlkCrossed.w
	move.w	cameraX.w,d0
	sub.w	d4,d0
	bpl.s	.Forward
	bset	#2,scrollFlags.w
	rts

.Forward:
	bset	#3,scrollFlags.w

.End:
	rts

; -------------------------------------------------------------------------

MoveScreenHoriz:
	move.w	objPlayerSlot+oX.w,d0		; Get the distance scrolled
	sub.w	cameraX.w,d0
	sub.w	camXCenter.w,d0
	beq.s	.AtDest				; If not scrolled at all, branch
	bcs.s	MoveScreenHoriz_CamBehind	; If scrolled to the left, branch
	bra.s	MoveScreenHoriz_CamAhead	; If scrolled to the right, branch

.AtDest:
	clr.w	scrollXDiff.w			; Didn't scroll at all
	rts

MoveScreenHoriz_CamAhead:
	cmpi.w	#16,d0				; Have we scrolled past 16 pixels?
	blt.s	.CapSpeed			; If not, branch
	move.w	#16,d0				; Cap at 16 pixels

.CapSpeed:
	add.w	cameraX.w,d0			; Have we gone past the right boundary?
	cmp.w	rightBound.w,d0
	blt.s	MoveScreenHoriz_MoveCam		; If not, branch
	move.w	rightBound.w,d0			; Cap at the right boundary

MoveScreenHoriz_MoveCam:
	move.w	d0,d1				; Update camera position
	sub.w	cameraX.w,d1
	asl.w	#8,d1
	move.w	d0,cameraX.w
	move.w	d1,scrollXDiff.w		; Get scroll delta
	rts

MoveScreenHoriz_CamBehind:
	cmpi.w	#-16,d0				; Have we scrolled past 16 pixels?
	bge.s	.CapSpeed			; If not, branch
	move.w	#-16,d0				; Cap at 16 pixels

.CapSpeed:
	add.w	cameraX.w,d0			; Have we gone past the left boundary?
	cmp.w	leftBound.w,d0
	bgt.s	MoveScreenHoriz_MoveCam		; If not, branch
	move.w	leftBound.w,d0			; Cap at the left boundary
	bra.s	MoveScreenHoriz_MoveCam

; -------------------------------------------------------------------------
; Shift the camera horizontally
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Scroll direction
; -------------------------------------------------------------------------

ShiftCameraHoriz:
	tst.w	d0				; Are we shifting to the right?
	bpl.s	.MoveRight			; If so, branch
	move.w	#-2,d0				; Shift to the left
	bra.s	MoveScreenHoriz_CamBehind

.MoveRight:
	move.w	#2,d0				; Shift to the right
	bra.s	MoveScreenHoriz_CamAhead

; -------------------------------------------------------------------------
; Scroll the camera vertically
; -------------------------------------------------------------------------

ScrollCamY:
	moveq	#0,d1				; Get how far we have scrolled vertically
	move.w	objPlayerSlot+oY.w,d0
	sub.w	cameraY.w,d0
	btst	#2,objPlayerSlot+oStatus.w	; Is the player rolling?
	beq.s	.NoRoll				; If not, branch
	subq.w	#5,d0				; Account for the different height

.NoRoll:
	btst	#1,objPlayerSlot+oStatus.w	; Is the player in the air?
	beq.s	.OnGround			; If not, branch

	addi.w	#$20,d0
	sub.w	camYCenter.w,d0
	bcs.s	.DoScrollFast			; If the player is above the boundary, scroll to catch up
	subi.w	#$20*2,d0
	bcc.s	.DoScrollFast			; If the player is below the boundary, scroll to catch up

	tst.b	btmBoundShift.w			; Is the bottom boundary shifting?
	bne.s	.StopCam			; If it is, branch
	bra.s	.DoNotScroll

.OnGround:
	sub.w	camYCenter.w,d0			; Subtract center position
	bne.s	.CamMoving			; If the player has moved, scroll to catch up
	tst.b	btmBoundShift.w			; Is the bottom boundary shifting?
	bne.s	.StopCam			; If it is, branch

.DoNotScroll:
	clr.w	scrollYDiff.w			; Didn't scroll at all
	rts

; -------------------------------------------------------------------------

.CamMoving:
	cmpi.w	#$60,camYCenter.w		; Is the camera center normal?
	bne.s	.DoScrollSlow			; If not, branch
	move.w	objPlayerSlot+oPlayerGVel.w,d1	; Get the player's ground velocity
	bpl.s	.DoScrollMedium
	neg.w	d1

.DoScrollMedium:
	cmpi.w	#8<<8,d1			; Is the player moving very fast?
	bcc.s	.DoScrollFast			; If they are, branch
	move.w	#6<<8,d1			; If the player is going too fast, cap the movement to 6 pixels/frame
	cmpi.w	#6,d0				; Is the player going down too fast?
	bgt.s	.MovingDown			; If so, move the camera at the capped speed
	cmpi.w	#-6,d0				; Is the player going up too fast?
	blt.s	.MovingUp			; If so, move the camera at the capped speed
	bra.s	.GotCamSpeed			; Otherwise, move the camera at the player's speed

.DoScrollSlow:
	move.w	#2<<8,d1			; If the player is going too fast, cap the movement to 2 pixels/frame
	cmpi.w	#2,d0				; Is the player going down too fast?
	bgt.s	.MovingDown			; If so, move the camera at the capped speed
	cmpi.w	#-2,d0				; Is the player going up too fast?
	blt.s	.MovingUp			; If so, move the camera at the capped speed
	bra.s	.GotCamSpeed			; Otherwise, move the camera at the player's speed

.DoScrollFast:
	move.w	#16<<8,d1			; If the player is going too fast, cap the movement to 16 pixels/frame
	cmpi.w	#16,d0				; Is the player going down too fast?
	bgt.s	.MovingDown			; If so, move the camera at the capped speed
	cmpi.w	#-16,d0				; Is the player going up too fast?
	blt.s	.MovingUp			; If so, move the camera at the capped speed
	bra.s	.GotCamSpeed			; Otherwise, move the camera at the player's speed

; -------------------------------------------------------------------------

.StopCam:
	moveq	#0,d0				; Stop the camera
	move.b	d0,btmBoundShift.w		; Clear bottom boundary shifting flag

.GotCamSpeed:
	moveq	#0,d1
	move.w	d0,d1				; Get position difference
	add.w	cameraY.w,d1			; Add old camera Y position
	tst.w	d0				; Is the camera scrolling down?
	bpl.w	.ChkBottom			; If so, branch
	bra.w	.ChkTop

.MovingUp:
	neg.w	d1				; Make the value negative
	ext.l	d1
	asl.l	#8,d1				; Move this into the upper word to align with the camera's Y position variable
	add.l	cameraY.w,d1			; Shift the camera over
	swap	d1				; Get the proper Y position

.ChkTop:
	cmp.w	topBound.w,d1			; Is the new position past the top boundary?
	bgt.s	.MoveCam			; If not, branch
	cmpi.w	#-$100,d1			; Is Y wrapping enabled?
	bgt.s	.CapTop				; If not, branch
	andi.w	#$7FF,d1			; Apply wrapping
	andi.w	#$7FF,objPlayerSlot+oY.w
	andi.w	#$7FF,cameraY.w
	andi.w	#$3FF,cameraBgY.w
	bra.s	.MoveCam

; -------------------------------------------------------------------------

.CapTop:
	move.w	topBound.w,d1			; Cap at the top boundary
	bra.s	.MoveCam

.MovingDown:
	ext.l	d1
	asl.l	#8,d1				; Move this into the upper word to align with the camera's Y position variable
	add.l	cameraY.w,d1			; Shift the camera over
	swap	d1				; Get the proper Y position

.ChkBottom:
	cmp.w	bottomBound.w,d1		; Is the new position past the bottom boundary?
	blt.s	.MoveCam			; If not, branch
	subi.w	#$800,d1			; Should we wrap?
	bcs.s	.CapBottom			; If not, branch
	andi.w	#$7FF,objPlayerSlot+oY.w	; Apply wrapping
	subi.w	#$800,cameraY.w
	andi.w	#$3FF,cameraBgY.w
	bra.s	.MoveCam

; -------------------------------------------------------------------------

.CapBottom:
	move.w	bottomBound.w,d1		; Cap at the bottom boundary

.MoveCam:
	move.w	cameraY.w,d4			; Update the camera position and get the scroll delta
	swap	d1
	move.l	d1,d3
	sub.l	cameraY.w,d3
	ror.l	#8,d3
	move.w	d3,scrollYDiff.w
	move.l	d1,cameraY.w

	move.w	cameraY.w,d0			; Check if a block has been crossed and set flags accordingly
	andi.w	#$10,d0
	move.b	vertiBlkCrossed.w,d1
	eor.b	d1,d0
	bne.s	.End
	eori.b	#$10,vertiBlkCrossed.w
	move.w	cameraY.w,d0
	sub.w	d4,d0
	bpl.s	.Downward
	bset	#0,scrollFlags.w
	rts

.Downward:
	bset	#1,scrollFlags.w

.End:
	rts

; -------------------------------------------------------------------------

	include	"Level/Scroll Flag Set.asm"

; -------------------------------------------------------------------------
; Update level background drawing
; -------------------------------------------------------------------------

DrawLevelBG:
	lea	VDPCTRL,a5			; Prepare VDP ports
	lea	VDPDATA,a6

	lea	scrollFlagsBg.w,a2		; Update background section 1
	lea	cameraBgX.w,a3
	lea	levelLayout+$40.w,a4
	move.w	#$6000,d2
	bsr.w	DrawLevelBG1

	lea	scrollFlagsBg2.w,a2		; Update background section 2
	lea	cameraBg2X.w,a3
	bra.w	DrawLevelBG2

; -------------------------------------------------------------------------
; Update level drawing
; -------------------------------------------------------------------------

DrawLevel:
	lea	VDPCTRL,a5			; Prepare VDP ports
	lea	VDPDATA,a6

	lea	lvlScrollFlagsCopy+2,a2		; Update background
	lea	lvlCamXBgCopy,a3
	lea	levelLayout+$40.w,a4
	move.w	#$6000,d2
	bsr.w	DrawLevelBG1

	lea	lvlScrollFlagsCopy,a2		; Update foreground
	lea	lvlCamXCopy,a3
	lea	levelLayout.w,a4
	move.w	#$4000,d2

; -------------------------------------------------------------------------
; Draw foreground
; -------------------------------------------------------------------------
; PARAMETERS:
;	d2.w - Base high VDP write command
;	a2.l - Scroll flags pointer
;	a3.l - Camera position pointer
;	a4.l - Layout data pointer
;	a5.l - VDP control port
;	a6.l - VDP data port
; -------------------------------------------------------------------------

DrawLevelFG:
	tst.b	(a2)				; Are any scroll flags set?
	beq.s	.End				; If not, branch

	bclr	#0,(a2)				; Should we draw a row at the top?
	beq.s	.ChkBottomRow			; If not, branch
	moveq	#-16,d4				; Draw a row at (-16, -16)
	moveq	#-16,d5
	bsr.w	GetBlockVDPCmd
	moveq	#-16,d4
	moveq	#-16,d5
	bsr.w	DrawBlockRow

.ChkBottomRow:
	bclr	#1,(a2)				; Should we draw a row at the bottom?
	beq.s	.ChkLeftCol			; If not, branch
	move.w	#224,d4				; Draw a row at (-16, 224)
	moveq	#-16,d5
	bsr.w	GetBlockVDPCmd
	move.w	#224,d4
	moveq	#-16,d5
	bsr.w	DrawBlockRow

.ChkLeftCol:
	bclr	#2,(a2)				; Should we draw a column on the left?
	beq.s	.ChkRightCol			; If not, branch
	moveq	#-16,d4				; Draw a column at (-16, -16)
	moveq	#-16,d5
	bsr.w	GetBlockVDPCmd
	moveq	#-16,d4
	moveq	#-16,d5
	bsr.w	DrawBlockCol

.ChkRightCol:
	bclr	#3,(a2)				; Should we draw a column on the right?
	beq.s	.End				; If not, branch
	moveq	#-16,d4				; Draw a column at (320, -16)
	move.w	#320,d5
	bsr.w	GetBlockVDPCmd
	moveq	#-16,d4
	move.w	#320,d5
	bsr.w	DrawBlockCol

.End:
	rts
	
; -------------------------------------------------------------------------
; Draw background section #1
; -------------------------------------------------------------------------
; PARAMETERS:
;	d2.w - Base high VDP write command
;	a2.l - Scroll flags pointer
;	a3.l - Camera position pointer
;	a4.l - Layout data pointer
;	a5.l - VDP control port
;	a6.l - VDP data port
; -------------------------------------------------------------------------

DrawLevelBG1:
	lea	BGCameraSectIDs,a0		; Prepare background section camera IDs
	adda.w	#1,a0

	moveq	#-$10,d4			; Prepare to draw a row at the top

	bclr	#0,(a2)				; Should we draw a row at the top?
	bne.s	.GotRowPos			; If so, branch
	bclr	#1,(a2)				; Should we draw a row at the bottom?
	beq.s	.ChkHorizScroll			; If not, branch

	move.w	#224,d4				; Prepare to draw a row at the bottom

.GotRowPos:
	move.w	cameraBgY.w,d0			; Get which camera the current block section is using
	add.w	d4,d0
	andi.w	#$FFF0,d0
	asr.w	#4,d0
	move.b	(a0,d0.w),d0
	ext.w	d0
	add.w	d0,d0
	movea.l	.CameraSects(pc,d0.w),a3
	beq.s	.StaticRow			; If it's a statically drawn row of blocks, branch

	moveq	#-$10,d5			; Draw a row of blocks
	move.l	a0,-(sp)
	movem.l	d4-d5,-(sp)
	bsr.w	GetBlockVDPCmd
	movem.l	(sp)+,d4-d5
	bsr.w	DrawBlockRow
	movea.l	(sp)+,a0

	bra.s	.ChkHorizScroll

.StaticRow:
	moveq	#0,d5				; Draw a full statically drawn row of blocks
	move.l	a0,-(sp)
	movem.l	d4-d5,-(sp)
	bsr.w	GetBlockVDPCmdAbsX
	movem.l	(sp)+,d4-d5
	moveq	#(512/16)-1,d6
	bsr.w	DrawBlockRowAbsX
	movea.l	(sp)+,a0

.ChkHorizScroll:
	tst.b	(a2)				; Did the screen background horizontally at all?
	bne.s	.DidScrollHoriz			; If so, branch
	rts

.DidScrollHoriz:
	moveq	#-$10,d4			; Prepare to draw a column on the left
	moveq	#-$10,d5
	move.b	(a2),d0				; Should we draw a column on the right?
	andi.b	#%10101000,d0
	beq.s	.GotScrollDir			; If not, branch
	lsr.b	#1,d0				; Shift scroll flags to fit camera ID array later on
	move.b	d0,(a2)
	move.w	#320,d5				; Prepare to draw a column on the right

.GotScrollDir:
	move.w	cameraBgY.w,d0			; Prepare background section camera ID array
	andi.w	#$FFF0,d0
	asr.w	#4,d0
	suba.w	#1,a0
	lea	(a0,d0.w),a0

	bra.w	.DrawColumn

; -------------------------------------------------------------------------

.CameraSects:
	dc.l	lvlCamXBgCopy			; BG1 (static)
	dc.l	lvlCamXBgCopy			; BG1 (dynamic)
	dc.l	lvlCamXBg2Copy			; BG2 (dynamic)
	dc.l	lvlCamXBg3Copy			; BG3 (dynamic)

; -------------------------------------------------------------------------

.DrawColumn:
	moveq	#((224+(16*2))/16)-1,d6		; 16 blocks in a column
	move.l	#$800000,d7			; VDP command row delta

.Loop:
	moveq	#0,d0				; Get camera ID for this block section
	move.b	(a0)+,d0
	beq.s	.NextBlock			; If this is a static row of blocks, branch
	btst	d0,(a2)				; Has this block section scrolled enough to warrant a new block to be drawn?
	beq.s	.NextBlock			; If not, branch

	add.w	d0,d0				; Draw a block
	movea.l	.CameraSects(pc,d0.w),a3
	movem.l	d4-d5/a0,-(sp)
	movem.l	d4-d5,-(sp)
	bsr.w	GetBlockData
	movem.l	(sp)+,d4-d5
	bsr.w	GetBlockVDPCmd
	bsr.w	DrawBlock
	movem.l	(sp)+,d4-d5/a0

.NextBlock:
	addi.w	#16,d4				; Shift down
	dbf	d6,.Loop			; Loop until finished

	clr.b	(a2)				; Clear scroll flags
	rts

; -------------------------------------------------------------------------
; Draw background section #2 (unused)
; -------------------------------------------------------------------------
; PARAMETERS:
;	d2.w - Base high VDP write command
;	a2.l - Scroll flags pointer
;	a3.l - Camera position pointer
;	a4.l - Layout data pointer
;	a5.l - VDP control port
;	a6.l - VDP data port
; -------------------------------------------------------------------------

DrawLevelBG2:
	rts

; -------------------------------------------------------------------------
; Draw background section #3 (unused)
; -------------------------------------------------------------------------
; PARAMETERS:
;	d2.w - Base high VDP write command
;	a2.l - Scroll flags pointer
;	a3.l - Camera position pointer
;	a4.l - Layout data pointer
;	a5.l - VDP control port
;	a6.l - VDP data port
; -------------------------------------------------------------------------

DrawLevelBG3:
	rts

; -------------------------------------------------------------------------
; Draw a row of blocks
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - Swapped VDP write command
;	d4.w - Y position
;	d5.w - X position
;	a3.l - Camera position pointer
;	a4.l - Layout data pointer
;	a5.l - VDP control port
;	a6.l - VDP data port
; -------------------------------------------------------------------------

DrawBlockRow:
	moveq	#((320+(16*2))/16)-1,d6		; 22 blocks in a row

DrawBlockRow2:
	move.l	#$800000,d7			; VDP command row delta
	move.l	d0,d1				; Copy VDP command

.Loop:
	movem.l	d4-d5,-(sp)			; Draw a block
	bsr.w	GetBlockData
	move.l	d1,d0
	bsr.w	DrawBlock
	addq.b	#4,d1				; Set up VDP command for next block
	andi.b	#$7F,d1
	movem.l	(sp)+,d4-d5

	addi.w	#16,d5				; Move right
	dbf	d6,.Loop			; Loop until finished

	rts

; -------------------------------------------------------------------------
; Draw a static row of blocks
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - Swapped VDP write command
;	d4.w - Y position
;	d5.w - X position
;	a3.l - Camera position pointer
;	a4.l - Layout data pointer
;	a5.l - VDP control port
;	a6.l - VDP data port
; -------------------------------------------------------------------------

DrawBlockRowAbsX:
	move.l	#$800000,d7			; VDP command row delta
	move.l	d0,d1				; Copy VDP command

.Draw:
	movem.l	d4-d5,-(sp)			; Draw a block
	bsr.w	GetBlockDataAbsX
	move.l	d1,d0
	bsr.w	DrawBlock
	addq.b	#4,d1				; Set up VDP command for next block
	andi.b	#$7F,d1
	movem.l	(sp)+,d4-d5

	addi.w	#16,d5				; Move right
	dbf	d6,.Draw			; Loop until finished

	rts

; -------------------------------------------------------------------------
; Draw a column of blocks
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - Swapped VDP write command
;	d4.w - Y position
;	d5.w - X position
;	a3.l - Camera position pointer
;	a4.l - Layout data pointer
;	a5.l - VDP control port
;	a6.l - VDP data port
; -------------------------------------------------------------------------

DrawBlockCol:
	moveq	#((224+(16*2))/16)-1,d6		; 16 blocks in a column
	move.l	#$800000,d7			; VDP command row delta
	move.l	d0,d1				; Copy VDP command

.Draw:
	movem.l	d4-d5,-(sp)			; Draw a block
	bsr.w	GetBlockData
	move.l	d1,d0
	bsr.w	DrawBlock
	addi.w	#$100,d1			; Set up VDP command for next block
	andi.w	#$FFF,d1
	movem.l	(sp)+,d4-d5

	addi.w	#16,d4				; Move down
	dbf	d6,.Draw			; Loop until finished

	rts

; -------------------------------------------------------------------------
; Draw a block
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - Swapped VDP write command
;	d4.w - Y position
;	d5.w - X position
;	a0.l - Block metadata pointer
;	a1.l - Block data pointer
;	a5.l - VDP control port
;	a6.l - VDP data port
; -------------------------------------------------------------------------

DrawBlock:
	or.w	d2,d0				; Add base high VDP word
	swap	d0

	btst	#4,(a0)				; Is this block flipped vertically?
	bne.s	.FlipY				; If so, branch
	btst	#3,(a0)				; Is this block flipped horizontally?
	bne.s	.FlipX				; If so, branch

	move.l	d0,(a5)				; Draw a block
	move.l	(a1)+,(a6)
	add.l	d7,d0
	move.l	d0,(a5)
	move.l	(a1)+,(a6)
	rts

; -------------------------------------------------------------------------

.FlipX:
	move.l	d0,(a5)				; Draw a block (flipped horizontally)
	move.l	(a1)+,d4
	eori.l	#$8000800,d4
	swap	d4
	move.l	d4,(a6)
	add.l	d7,d0
	move.l	d0,(a5)
	move.l	(a1)+,d4
	eori.l	#$8000800,d4
	swap	d4
	move.l	d4,(a6)
	rts

; -------------------------------------------------------------------------

.FlipY:
	btst	#3,(a0)				; Is this block flipped horizontally?
	bne.s	.FlipXY				; If so, branch

	move.l	d0,(a5)				; Draw a block (flipped vertically)
	move.l	(a1)+,d5
	move.l	(a1)+,d4
	eori.l	#$10001000,d4
	move.l	d4,(a6)
	add.l	d7,d0
	move.l	d0,(a5)
	eori.l	#$10001000,d5
	move.l	d5,(a6)
	rts

; -------------------------------------------------------------------------

.FlipXY:
	move.l	d0,(a5)				; Draw a block (flipped both ways)
	move.l	(a1)+,d5
	move.l	(a1)+,d4
	eori.l	#$18001800,d4
	swap	d4
	move.l	d4,(a6)
	add.l	d7,d0
	move.l	d0,(a5)
	eori.l	#$18001800,d5
	swap	d5
	move.l	d5,(a6)
	rts

; -------------------------------------------------------------------------
; Get the addresses of a block's metadata and data at a position relative
; to a camera
; -------------------------------------------------------------------------
; PARAMETERS:
;	d4.w - Y position
;	d5.w - X position
;	a3.l - Camera position pointer
;	a4.l - Layout data pointer
; RETURNS:
;	a0.l - Block metadata pointer
;	a1.l - Block data pointer
; -------------------------------------------------------------------------

GetBlockData:
	add.w	(a3),d5				; Add camera X position

GetBlockDataAbsX:
	add.w	4(a3),d4			; Add camera Y position

GetBlockDataAbsXY:
	lea	blockBuffer,a1			; Prepare block data pointer

	move.w	d4,d3				; Get the chunk that the block we want is in
	lsr.w	#1,d3
	andi.w	#$380,d3
	lsr.w	#3,d5
	move.w	d5,d0
	lsr.w	#5,d0
	andi.w	#$7F,d0
	add.w	d3,d0
	move.l	#LevelChunks,d3
	move.b	(a4,d0.w),d3
	beq.s	.End				; If it's a blank chunk, branch out of here

	subq.b	#1,d3				; Get pointer to block metadata in the chunk
	andi.w	#$7F,d3
	ror.w	#7,d3
	add.w	d4,d4
	andi.w	#$1E0,d4
	andi.w	#$1E,d5
	add.w	d4,d3
	add.w	d5,d3
	movea.l	d3,a0

	move.w	(a0),d3				; Get pointer to block data
	andi.w	#$3FF,d3
	lsl.w	#3,d3
	adda.w	d3,a1

	moveq	#1,d0				; Mark block as retrieved

.End:
	rts

; -------------------------------------------------------------------------
; Get the address of a block's metadata at a position
; -------------------------------------------------------------------------
; PARAMETERS:
;	d4.w - Y position
;	d5.w - X position
;	a4.l - Layout data pointer
; RETURNS:
;	a0.l - Block metadata pointer
;	a1.l - Block data pointer
; -------------------------------------------------------------------------

GetBlockMetadata:
	move.w	d4,d3				; Get the chunk that the block we want is in
	lsr.w	#1,d3
	andi.w	#$380,d3
	lsr.w	#3,d5
	move.w	d5,d0
	lsr.w	#5,d0
	andi.w	#$7F,d0
	add.w	d3,d0
	move.l	#LevelChunks,d3
	move.b	(a4,d0.w),d3

	subq.b	#1,d3				; Get pointer to block metadata in the chunk
	andi.w	#$7F,d3
	ror.w	#7,d3
	add.w	d4,d4
	andi.w	#$1E0,d4
	andi.w	#$1E,d5
	add.w	d4,d3
	add.w	d5,d3
	movea.l	d3,a0

	rts

; -------------------------------------------------------------------------
; Place a block at a position in the level
; -------------------------------------------------------------------------
; NOTE: Be wary of using this function. It also overwrites chunk data in
; order for Sonic to interact with the block placed. It will affect
; every instance of the chunk affected.
; -------------------------------------------------------------------------
; PARAMETERS:
;	d3.w - Block metadata
;	d4.w - Y position
;	d5.w - X position
; -------------------------------------------------------------------------

PlaceBlockAtPos:
	move.l	a0,-(sp)

	lea	levelLayout.w,a4		; Prepare level layout
	lea	VDPCTRL,a5			; Prepare VDP ports
	lea	VDPDATA,a6
	move.w	#$4000,d2			; Set to draw on plane A
	move.l	#$800000,d7			; VDP command row delta

	movem.l	d3-d5,-(sp)
	bsr.w	GetBlockDataAbsXY		; Get the pointer to the block at our position
	bne.s	.GotBlock			; If we ended up getting a block, branch
	movem.l	(sp)+,d3-d5
	bra.s	.End

.GotBlock:
	movem.l	(sp)+,d3-d5

	move.w	d3,(a0)				; Overwrite the block in the chunk found
	bsr.w	ChkBlockPosOnscreen		; Check if this block is onscreen
	bne.s	.End				; If it's not, branch

	movem.l	d3-d5,-(sp)			; Draw the block
	lea	blockBuffer,a1
	andi.w	#$3FF,d3
	lsl.w	#3,d3
	adda.w	d3,a1
	bsr.w	GetBlockVDPCmdAbsXY
	bsr.w	DrawBlock
	movem.l	(sp)+,d3-d5

.End:
	movea.l	(sp)+,a0
	rts

; -------------------------------------------------------------------------
; Check if a block position is onscreen
; -------------------------------------------------------------------------
; PARAMETERS:
;	d4.w - Y position
;	d5.w - X position
; RETURNS:
;	d0.w - Return status
;	z/nz - Onscreen/offscreen
; -------------------------------------------------------------------------

ChkBlockPosOnscreen:
	move.w	cameraY.w,d0			; Is the block above the top of the screen?
	move.w	d0,d1
	andi.w	#$FFF0,d0
	subi.w	#16,d0
	cmp.w	d0,d4
	bcs.s	.Offscreen			; If so, branch

	addi.w	#224+16,d1			; Is the block below the bottom of the screen?
	andi.w	#$FFF0,d1
	cmp.w	d1,d4
	bgt.s	.Offscreen			; If so, branch

	move.w	cameraX.w,d0			; Is the block left of the left side of the screen?
	move.w	d0,d1
	andi.w	#$FFF0,d0
	subi.w	#16,d0
	cmp.w	d0,d5
	bcs.s	.Offscreen			; If so, branch

	addi.w	#320+16,d1			; Is the block right of the right side of the screen?
	andi.w	#$FFF0,d1
	cmp.w	d1,d5
	bgt.s	.Offscreen			; If so, branch

	moveq	#0,d0				; Mark as onscreen
	rts

.Offscreen:
	moveq	#1,d0				; Mark as offscreen
	rts

; -------------------------------------------------------------------------
; Calculate the base VDP command for drawing blocks with
; (For VRAM addresses $C000-$FFFF)
; -------------------------------------------------------------------------
; PARAMETERS:
;	d4.w - Y position
;	d5.w - X position
;	a3.l - Camera position pointer
; RETURNS:
;	d0.l - Base VDP command 
; -------------------------------------------------------------------------

GetBlockVDPCmd:
	add.w	(a3),d5				; Add camera X position

GetBlockVDPCmdAbsX:
	add.w	4(a3),d4			; Add camera Y position

GetBlockVDPCmdAbsXY:
	andi.w	#$F0,d4				; Calculate VDP command
	andi.w	#$1F0,d5
	lsl.w	#4,d4
	lsr.w	#2,d5
	add.w	d5,d4
	moveq	#3,d0
	swap	d0
	move.w	d4,d0

	rts

; -------------------------------------------------------------------------
; Calculate the base VDP command for drawing blocks with
; (For VRAM addresses $8000-$BFFF)
; -------------------------------------------------------------------------
; PARAMETERS:
;	d4.w - Y position
;	d5.w - X position
;	a3.l - Camera position pointer
; RETURNS:
;	d0.l - Base VDP command 
; -------------------------------------------------------------------------

GetBlockVDPCmd2:
	add.w	4(a3),d4			; Add camera Y position
	add.w	(a3),d5				; Add camera X position

	andi.w	#$F0,d4				; Calculate VDP command
	andi.w	#$1F0,d5
	lsl.w	#4,d4
	lsr.w	#2,d5
	add.w	d5,d4
	moveq	#2,d0
	swap	d0
	move.w	d4,d0

	rts

; -------------------------------------------------------------------------
; Start level drawing
; -------------------------------------------------------------------------

InitLevelDraw:
	lea	VDPCTRL,a5			; Prepare VDP ports
	lea	VDPDATA,a6

	lea	cameraX.w,a3			; Initialize foreground
	lea	levelLayout.w,a4
	move.w	#$4000,d2
	bsr.s	InitLevelDrawFG

	lea	cameraBgX.w,a3			; Initialize background
	lea	levelLayout+$40.w,a4
	move.w	#$6000,d2
	bra.w	InitLevelDrawBG

; -------------------------------------------------------------------------
; Draw foreground
; -------------------------------------------------------------------------
; PARAMETERS:
;	d2.w - Base high VDP write command
;	a3.l - Camera position pointer
;	a4.l - Layout data pointer
;	a5.l - VDP control port
;	a6.l - VDP data port
; -------------------------------------------------------------------------

InitLevelDrawFG:
	moveq	#-16,d4				; Start drawing at the top of the screen
	moveq	#((224+(16*2))/16)-1,d6		; 16 blocks in a column

.Draw:
	movem.l	d4-d6,-(sp)			; Draw a full row of blocks
	moveq	#0,d5
	move.w	d4,d1
	bsr.w	GetBlockVDPCmd
	move.w	d1,d4
	moveq	#0,d5
	moveq	#(512/16)-1,d6
	bsr.w	DrawBlockRow2
	movem.l	(sp)+,d4-d6

	addi.w	#16,d4				; Move down
	dbf	d6,.Draw			; Loop until finished

	rts

; -------------------------------------------------------------------------
; Draw background
; -------------------------------------------------------------------------
; PARAMETERS:
;	d2.w - Base high VDP write command
;	a3.l - Camera position pointer
;	a4.l - Layout data pointer
;	a5.l - VDP control port
;	a6.l - VDP data port
; -------------------------------------------------------------------------

InitLevelDrawBG:
	moveq	#-16,d4				; Start drawing at the top of the screen
	moveq	#((224+(16*2))/16)-1,d6		; 16 blocks in a column

.Draw:
	movem.l	d4-d6/a0,-(sp)			; Draw a row of blocks
	lea	BGCameraSectIDs,a0
	adda.w	#1,a0
	move.w	cameraBgY.w,d0
	add.w	d4,d0
	andi.w	#$7F0,d0
	bsr.w	DrawBGBlockRow
	movem.l	(sp)+,d4-d6/a0

	addi.w	#16,d4				; Move down
	dbf	d6,.Draw			; Loop until finished

	rts

; -------------------------------------------------------------------------
; Background camera sections
; -------------------------------------------------------------------------
; Each row of blocks is assigned a background camera section to help
; determine how to draw it
; -------------------------------------------------------------------------
; 0 = Background 1 (Static)
; 2 = Background 1 (Dynamic)
; 4 = Background 2 (Dynamic)
; 6 = Background 3 (Dynamic)
; -------------------------------------------------------------------------

BGCameraSectIDs:
	BGSECT	16,  BGSTATIC			; Offscreen top row, required to be here

	BGSECT	16,  BGSTATIC			; Top clouds
	BGSECT	32,  BGSTATIC
	BGSECT	48,  BGSTATIC
	BGSECT	64,  BGSTATIC
	BGSECT	64,  BGSTATIC
	BGSECT	64,  BGSTATIC
	BGSECT	32,  BGSTATIC
	BGSECT	48,  BGSTATIC
	BGSECT	48,  BGSTATIC
	BGSECT	32,  BGSTATIC
	BGSECT	160, BGSTATIC			; Top mountains
	BGSECT	32,  BGSTATIC			; Top bushes
	BGSECT	224, BGSTATIC			; Top water

	BGSECT	224, BGSTATIC			; Upside down water
	BGSECT	32,  BGSTATIC			; Upside down bushes
	BGSECT	160, BGDYNAMIC2			; Upside down mountains
	BGSECT	16,  BGSTATIC			; Upside down clouds
	BGSECT	32,  BGSTATIC
	BGSECT	48,  BGSTATIC
	BGSECT	64,  BGSTATIC
	BGSECT	64,  BGSTATIC

	BGSECT	64,  BGSTATIC			; Bottom clouds
	BGSECT	32,  BGSTATIC
	BGSECT	80,  BGSTATIC
	BGSECT	32,  BGSTATIC
	BGSECT	16,  BGSTATIC
	BGSECT	160, BGDYNAMIC2			; Bottom mountains
	BGSECT	32,  BGSTATIC			; Bottom bushes
	BGSECT	144, BGSTATIC			; Bottom water

; -------------------------------------------------------------------------

BGCameraSects:
	dc.l	cameraBgX&$FFFFFF		; BG1 (static)
	dc.l	cameraBgX&$FFFFFF		; BG1 (dynamic)
	dc.l	cameraBg2X&$FFFFFF		; BG2 (dynamic)
	dc.l	cameraBg3X&$FFFFFF		; BG3 (dynamic)

; -------------------------------------------------------------------------
; Draw row of blocks for the background
; -------------------------------------------------------------------------
; PARAMETERS:
;	d2.w - Base high VDP write command
;	a0.l - Background camera sections
;	a3.l - Camera position pointer
;	a4.l - Layout data pointer
;	a5.l - VDP control port
;	a6.l - VDP data port
; -------------------------------------------------------------------------

DrawBGBlockRow:
	lsr.w	#4,d0				; Get camera section ID
	move.b	(a0,d0.w),d0
	add.w	d0,d0
	movea.l	BGCameraSects(pc,d0.w),a3
	beq.s	.StaticRow			; If it's a statically drawn row of blocks, branch

	moveq	#-16,d5				; Draw a row of blocks
	movem.l	d4-d5,-(sp)
	bsr.w	GetBlockVDPCmd
	movem.l	(sp)+,d4-d5
	bsr.w	DrawBlockRow
	bra.s	.End

.StaticRow:
	moveq	#0,d5				; Draw a full statically drawn row of blocks
	movem.l	d4-d5,-(sp)
	bsr.w	GetBlockVDPCmdAbsX
	movem.l	(sp)+,d4-d5
	moveq	#(512/16)-1,d6
	bsr.w	DrawBlockRowAbsX

.End:
	rts

; -------------------------------------------------------------------------
