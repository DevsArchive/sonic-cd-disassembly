; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Wacky Workbench Act 1 Present level scrolling/drawing
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Get level size and start position
; -------------------------------------------------------------------------

LevelSizeLoad:
	lea	objPlayerSlot.w,a6		; Get player slot

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
	dc.w	4, 0, $2297, 0, $710, $60

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
	tst.b	spawnMode			; Is the player being spawned at the beginning?
	beq.s	.DefaultStart			; If so, branch

	jsr	LoadCheckpointData		; Load checkpoint data
	moveq	#0,d0				; Get player position
	moveq	#0,d1
	move.w	oX(a6),d1
	move.w	oY(a6),d0
	bpl.s	.SkipCap			; If the Y position is positive, branch
	moveq	#0,d0				; Cap the Y position at 0 if negative

.SkipCap:
	bra.s	.SetupCamera

.DefaultStart:
	lea	LevelStartLoc,a1		; Prepare level start position
	
	tst.w	demoMode			; Are we in the credits (Sonic 1 leftover)?
	bpl.s	.NotS1Credits			; If not, branch
	move.w	s1CreditsIndex,d0		; Get Sonic 1 credits starting position
	subq.w	#1,d0
	lsl.w	#2,d0
	lea	EndingStLocsS1,a1
	adda.w	d0,a1
	bra.s	.SetStartPos
	
.NotS1Credits:
	move.w	demoMode,d0			; Get start position
	lsl.w	#2,d0
	adda.w	d0,a1
	
.SetStartPos:
	moveq	#0,d1				; Get starting X position
	move.w	(a1)+,d1
	move.w	d1,oX(a6)
	moveq	#0,d0				; Get starting Y position
	move.w	(a1),d0
	move.w	d0,oY(a6)

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
	incbin	"Level/Wacky Workbench/Data/Start Position (Act 1 Present).bin"

; -------------------------------------------------------------------------
; Special chunk IDs
; -------------------------------------------------------------------------

SpecChunks:
	dc.b	$7F, $7F, $7F, $7F

; -------------------------------------------------------------------------
; Initialize level scrolling
; -------------------------------------------------------------------------

InitLevelScroll:
	swap	d0				; Set background Y positions
	lsr.l	#2,d0
	move.l	d0,cameraBgY.w
	swap	d0
	move.w	d0,cameraBg2Y.w
	move.w	d0,cameraBg3Y.w

	lsr.l	#1,d1				; Get background X positions
	move.w	d1,cameraBg2X.w
	lsr.l	#1,d1
	move.w	d1,cameraBg3X.w
	lsr.l	#2,d1
	move.l	d1,d2
	add.l	d2,d2
	add.l	d2,d1
	move.w	d1,cameraBgX.w

	rts

; -------------------------------------------------------------------------
; Handle level scrolling
; -------------------------------------------------------------------------

LevelScroll:
	lea	objPlayerSlot.w,a6		; Get player slot

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

	move.w	scrollXDiff.w,d4		; Set scroll offset and flags for middle section
	ext.l	d4
	asl.l	#6,d4
	moveq	#6,d6
	bsr.w	SetHorizScrollFlagsBG3

	move.w	scrollXDiff.w,d4		; Set scroll offset and flags for bottom section
	ext.l	d4
	asl.l	#7,d4
	moveq	#4,d6
	bsr.w	SetHorizScrollFlagsBG2

	lea	deformBuffer.w,a1		; Prepare deformation buffer

	move.w	scrollXDiff.w,d4		; Set scroll offset and flags for lights
	ext.l	d4
	asl.l	#4,d4
	move.l	d4,d3
	add.l	d3,d3
	add.l	d3,d4
	moveq	#2,d6
	bsr.w	SetHorizScrollFlagsBG

	move.w	cameraY.w,d0			; Get background Y position
	lsr.w	#2,d0
	bsr.w	SetVertiScrollFlagsBG2		; Set BG2 vertical scroll flags

	move.w	cameraBgY.w,vscrollScreen+2.w	; Update background Y positions
	move.w	cameraBgY.w,cameraBg2Y.w
	move.w	cameraBgY.w,cameraBg3Y.w

	move.b	scrollFlagsBg3.w,d0		; Combine background scroll flags for the level drawing routine
	or.b	scrollFlagsBg2.w,d0
	or.b	d0,scrollFlagsBg.w
	clr.b	scrollFlagsBg3.w
	clr.b	scrollFlagsBg2.w

	lea	deformBuffer.w,a1		; Prepare deformation buffer

	move.w	cameraX.w,d0			; Prepare scroll buffer entry
	neg.w	d0
	swap	d0

	bsr.w	ScrollBGLights			; Scroll lights

	move.w	cameraBg3X.w,d0			; Scroll middle section
	neg.w	d0
	moveq	#$14-1,d6

.ScrollMiddle:
	move.w	d0,(a1)+
	dbf	d6,.ScrollMiddle

	move.w	cameraBg2X.w,d0			; Scroll bottom section
	neg.w	d0
	moveq	#$2E-1,d6

.ScrollBottom:
	move.w	d0,(a1)+
	dbf	d6,.ScrollBottom

	lea	hscroll.w,a1			; Prepare horizontal scroll buffer
	lea	deformBuffer.w,a2		; Prepare deformation buffer

	move.w	cameraBgY.w,d0			; Get background Y position
	move.w	d0,d2
	andi.w	#$3F8,d0
	lsr.w	#2,d0

	moveq	#(240/8)-1,d1			; Scroll blocks
	lea	(a2,d0.w),a2
	bra.w	ScrollBlocks

; -------------------------------------------------------------------------

BGLightSects:
	dc.b	6-1
	dc.b	4-1
	dc.b	4-1
	dc.b	3-1
	dc.b	3-1
	dc.b	2-1
	dc.b	2-1
	dc.b	2-1
	dc.b	2-1
	dc.b	2-1
BGLightSectsEnd:

; -------------------------------------------------------------------------

ScrollBGLights:
	move.w	cameraBgX.w,d0			; Get scroll offset
	move.w	cameraX.w,d2
	sub.w	d0,d2
	ext.l	d2

	moveq	#0,d3				; Prepare to scroll
	move.w	cameraBgX.w,d4
	moveq	#BGLightSectsEnd-BGLightSects-1,d6
	adda.w	#$1E*2,a1

.SectLoop:
	move.b	d3,d0				; Get scroll offset for section
	jsr	CalcSine			; (($100 - (cos(d3))) * scroll offset) + background position
	move.w	#$100,d5
	sub.w	d1,d5
	muls.w	d2,d5
	lsr.l	#8,d5
	add.w	d4,d5
	neg.w	d5

	moveq	#0,d1				; Scroll section blocks
	move.b	BGLightSects(pc,d6.w),d1

.SectScroll:
	move.w	d5,-(a1)
	dbf	d1,.SectScroll

	addq.b	#6,d3				; Cosine is used to handle perspective
	dbf	d6,.SectLoop			; Loop until all sections are scrolled

	adda.w	#$1E*2,a1			; Go past the light sections
	rts

; -------------------------------------------------------------------------

ScrollBlocks:
	andi.w	#7,d2				; Get the number of lines to scroll for the first block of lines
	add.w	d2,d2
	move.w	(a2)+,d0			; Start scrolling
	jmp	ScrollBlockStart(pc,d2.w)

ScrollBlockLoop:
	move.w	(a2)+,d0			; Scroll another block of lines

ScrollBlockStart:
	rept	8				; Scroll a block of 8 lines
		move.l	d0,(a1)+
	endr
	dbf	d1,ScrollBlockLoop		; Loop until finished

.End:
	rts

; -------------------------------------------------------------------------

ScrollBlocksAlt:
	neg.w	d0				; Start scrolling
	jmp	.ScrollBlock(pc,d2.w)

.ScrollLoop:
	neg.w	d0				; Alternate offset
	
.ScrollBlock:
	rept	8				; Scroll a block of 8 lines
		move.l	d0,(a1)+
	endr
	dbf	d1,ScrollBlockLoop		; Loop until finished

.End:
	rts

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
	move.w	oX(a6),d0			; Get the distance scrolled
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
	move.w	oY(a6),d0
	sub.w	cameraY.w,d0
	btst	#2,oFlags(a6)			; Is the player rolling?
	beq.s	.NoRoll				; If not, branch
	subq.w	#5,d0				; Account for the different height

.NoRoll:
	btst	#1,oFlags(a6)			; Is the player in the air?
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
	move.w	oPlayerGVel(a6),d1		; Get the player's ground velocity
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
	andi.w	#$7FF,oY(a6)
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
	andi.w	#$7FF,oY(a6)			; Apply wrapping
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

	lea	scrollFlagsBgCopy,a2		; Update background section 1
	lea	camXBgCopy,a3
	lea	levelLayout+$40.w,a4
	move.w	#$6000,d2
	bsr.w	DrawLevelBG1

	lea	scrollFlagsBg2Copy,a2		; Update background section 2
	lea	camXBg2Copy,a3
	bsr.w	DrawLevelBG2

	lea	scrollFlagsBg3Copy,a2		; Update background section 3
	lea	camXBg3Copy,a3
	bsr.w	DrawLevelBG3

	lea	scrollFlagsCopy,a2		; Update foreground
	lea	camXCopy,a3
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
	dc.l	camXBgCopy			; BG1 (static)
	dc.l	camXBgCopy			; BG1 (dynamic)
	dc.l	camXBg2Copy			; BG2 (dynamic)
	dc.l	camXBg3Copy			; BG3 (dynamic)

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

	include	"Level/Block Draw.asm"

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
	andi.w	#$1F0,d0
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

	BGSECT	240, BGSTATIC			; Lights
	BGSECT	160, BGDYNAMIC3			; Middle section
	BGSECT	368, BGDYNAMIC2			; Bottom section
	even

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
