; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Floor collision functions
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Handle the player's collision on the ground
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

Player_GroundCol:
	btst	#3,oFlags(a0)			; Are we standing on an object?
	beq.s	.OnGround			; If not, then we are on the ground

	moveq	#0,d0				; Reset angle buffers
	move.b	d0,primaryAngle.w
	move.b	d0,secondaryAngle.w
	rts

.OnGround:
	moveq	#3,d0				; Reset angle buffers
	move.b	d0,primaryAngle.w
	move.b	d0,secondaryAngle.w

	move.b	oAngle(a0),d0			; Get the quadrant that we are in
	addi.b	#$20,d0
	bpl.s	.HighAngle
	move.b	oAngle(a0),d0
	bpl.s	.SkipSub
	subq.b	#1,d0

.SkipSub:
	addi.b	#$20,d0
	bra.s	.GotAngle

.HighAngle:
	move.b	oAngle(a0),d0
	bpl.s	.SkipAdd
	addq.b	#1,d0

.SkipAdd:
	addi.b	#$1F,d0

.GotAngle:
	andi.b	#$C0,d0

	cmpi.b	#$40,d0				; Are we on a left wall?
	beq.w	Player_WalkVertL		; If so, branch
	cmpi.b	#$80,d0				; Are we on a ceiling?
	beq.w	Player_WalkCeiling		; If so, branch
	cmpi.b	#$C0,d0				; Are we on a right wall?
	beq.w	Player_WalkVertR		; If so, branch

; -------------------------------------------------------------------------
; Move the player along a floor
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

Player_WalkFloor:
	move.w	oY(a0),d2			; Get primary sensor position
	move.w	oX(a0),d3
	moveq	#0,d0
	move.b	oYRadius(a0),d0
	ext.w	d0
	add.w	d0,d2
	move.b	oXRadius(a0),d0
	ext.w	d0
	add.w	d0,d3
	lea	primaryAngle.w,a4		; Get floor information from this sensor
	movea.w	#$10,a3
	move.w	#0,d6
	moveq	#$D,d5
	bsr.w	FindLevelFloor
	move.w	d1,-(sp)

	move.w	oY(a0),d2			; Get secondary sensor position
	move.w	oX(a0),d3
	moveq	#0,d0
	move.b	oYRadius(a0),d0
	ext.w	d0
	add.w	d0,d2
	move.b	oXRadius(a0),d0
	ext.w	d0
	neg.w	d0
	add.w	d0,d3

	lea	secondaryAngle.w,a4		; Get floor information from this sensor
	movea.w	#$10,a3
	move.w	#0,d6
	moveq	#$D,d5
	bsr.w	FindLevelFloor
	move.w	(sp)+,d0

	bsr.w	Player_PickSensor		; Choose which height and angle to go with
	tst.w	d1				; Are we perfectly aligned to the ground?
	beq.s	.End				; If so, branch
	bpl.s	.CheckLedge			; If we are outside the floor, branch
	cmpi.w	#-$E,d1				; Have we hit a wall?
	blt.s	Player_AnglePos_Done		; If so, branch
	add.w	d1,oY(a0)			; Align outselves onto the floor

.End:
	rts

.CheckLedge:
	cmpi.w	#$E,d1				; Are we about to fall off?
	bgt.s	.CheckStick			; If so, branch

.SetY:
	add.w	d1,oY(a0)			; Align ourselves onto the floor
	rts

.CheckStick:
	tst.b	oPlayerStick(a0)		; Are we sticking to a surface?
	bne.s	.SetY				; If so, align to the floor anyways

	bset	#1,oFlags(a0)			; Fall off the ground
	bclr	#5,oFlags(a0)
	move.b	#1,oPrevAnim(a0)
	rts

; -------------------------------------------------------------------------

Player_AnglePos_Done:
	rts

; -------------------------------------------------------------------------
; Some kind of unsued object movement with gravity routine
; -------------------------------------------------------------------------
; PARAMETERS:
;	d3.l - Y position
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

ObjMoveGrvUnused:
	move.l	oX(a0),d2			; Apply X velocity
	move.w	oXVel(a0),d0
	ext.l	d0
	asl.l	#8,d0
	sub.l	d0,d2
	move.l	d2,oX(a0)

	move.w	#$38,d0				; Apply gravity without first applying Y velocity
	ext.l	d0				; ...and getting the Y position first
	asl.l	#8,d0
	sub.l	d0,d3
	move.l	d3,oY(a0)
	rts

; -------------------------------------------------------------------------

Player_WalkVert_Done:
	rts

; -------------------------------------------------------------------------
; Unused routine to apply Y velocity and reverse gravity onto an object
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

ObjMoveYRevGrv:
	move.l	oY(a0),d3			; Apply Y velocity
	move.w	oYVel(a0),d0
	subi.w	#$38,d0				; ...and reversed gravity
	move.w	d0,oYVel(a0)
	ext.l	d0
	asl.l	#8,d0
	sub.l	d0,d3
	move.l	d3,oY(a0)
	rts

; -------------------------------------------------------------------------
; Apply X and Y velocity onto an object (unused)
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

ObjMoveUnused:
	rts
	move.l	oX(a0),d2			; Get position
	move.l	oY(a0),d3

	move.w	oXVel(a0),d0			; Apply X velocity
	ext.l	d0
	asl.l	#8,d0
	sub.l	d0,d2

	move.w	oYVel(a0),d0			; Apply Y velocity
	ext.l	d0
	asl.l	#8,d0
	sub.l	d0,d3

	move.l	d2,oX(a0)			; Update position
	move.l	d3,oY(a0)
	rts

; -------------------------------------------------------------------------
; Pick a sensor to use to align the player to the ground
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

Player_PickSensor:
	move.b	secondaryAngle.w,d2		; Use secondary angle
	cmp.w	d0,d1				; Is the primary sensor on the higher ground?
	ble.s	.GotAngle			; If not, branch
	move.b	primaryAngle.w,d2		; Use primary angle
	move.w	d0,d1				; Use primary floor height

.GotAngle:
	btst	#0,d2				; Was the level block found a flat surface?
	bne.s	.FlatSurface			; If so, branch
	move.b	d2,oAngle(a0)			; Update angle
	rts

.FlatSurface:
	move.b	oAngle(a0),d2			; Shift ourselves to the next quadrant
	addi.b	#$20,d2
	andi.b	#$C0,d2
	move.b	d2,oAngle(a0)
	rts

; -------------------------------------------------------------------------
; Move the player along a right wall
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

Player_WalkVertR:
	move.w	oY(a0),d2			; Get primary sensor position
	move.w	oX(a0),d3
	moveq	#0,d0
	move.b	oXRadius(a0),d0
	ext.w	d0
	neg.w	d0
	add.w	d0,d2
	move.b	oYRadius(a0),d0
	ext.w	d0
	add.w	d0,d3
	lea	primaryAngle.w,a4		; Get floor information from this sensor
	movea.w	#$10,a3
	move.w	#0,d6
	moveq	#$D,d5
	bsr.w	FindLevelWall
	move.w	d1,-(sp)

	move.w	oY(a0),d2			; Get secondary sensor position
	move.w	oX(a0),d3
	moveq	#0,d0
	move.b	oXRadius(a0),d0
	ext.w	d0
	add.w	d0,d2
	move.b	oYRadius(a0),d0
	ext.w	d0
	add.w	d0,d3
	lea	secondaryAngle.w,a4		; Get floor information from this sensor
	movea.w	#$10,a3
	move.w	#0,d6
	moveq	#$D,d5
	bsr.w	FindLevelWall
	move.w	(sp)+,d0

	bsr.w	Player_PickSensor		; Choose which height and angle to go with
	tst.w	d1				; Are we perfectly aligned to the ground?
	beq.s	.End				; If so, branch
	bpl.s	.CheckLedge			; If we are outside the wall, branch
	cmpi.w	#-$E,d1				; Have we hit a wall?
	blt.w	Player_WalkVert_Done		; If so, branch
	add.w	d1,oX(a0)			; Align outselves onto the wall

.End:
	rts

.CheckLedge:
	cmpi.w	#$E,d1				; Are we about to fall off?
	bgt.s	.CheckStick			; If so, branch

.SetX:
	add.w	d1,oX(a0)			; Align ourselves onto the wall
	rts

.CheckStick:
	tst.b	oPlayerStick(a0)		; Are we sticking to a surface?
	bne.s	.SetX				; If so, align to the wall anyways

	bset	#1,oFlags(a0)			; Fall off the ground
	bclr	#5,oFlags(a0)
	move.b	#1,oPrevAnim(a0)
	rts

; -------------------------------------------------------------------------
; Move the player along a ceiling
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

Player_WalkCeiling:
	move.w	oY(a0),d2			; Get primary sensor position
	move.w	oX(a0),d3
	moveq	#0,d0
	move.b	oYRadius(a0),d0
	ext.w	d0
	sub.w	d0,d2
	eori.w	#$F,d2
	move.b	oXRadius(a0),d0
	ext.w	d0
	add.w	d0,d3
	lea	primaryAngle.w,a4		; Get floor information from this sensor
	movea.w	#-$10,a3
	move.w	#$1000,d6
	moveq	#$D,d5
	bsr.w	FindLevelFloor
	move.w	d1,-(sp)

	move.w	oY(a0),d2			; Get secondary sensor position
	move.w	oX(a0),d3
	moveq	#0,d0
	move.b	oYRadius(a0),d0
	ext.w	d0
	sub.w	d0,d2
	eori.w	#$F,d2
	move.b	oXRadius(a0),d0
	ext.w	d0
	sub.w	d0,d3
	lea	secondaryAngle.w,a4		; Get floor information from this sensor
	movea.w	#-$10,a3
	move.w	#$1000,d6
	moveq	#$D,d5
	bsr.w	FindLevelFloor
	move.w	(sp)+,d0

	bsr.w	Player_PickSensor		; Choose which height and angle to go with
	tst.w	d1				; Are we perfectly aligned to the ground?
	beq.s	.End				; If so, branch
	bpl.s	.CheckLedge			; If we are outside the ceiling, branch
	cmpi.w	#-$E,d1				; Have we hit a ceiling?
	blt.w	Player_AnglePos_Done		; If so, branch
	sub.w	d1,oY(a0)			; Align outselves onto the ceiling

.End:
	rts

.CheckLedge:
	cmpi.w	#$E,d1				; Are we about to fall off?
	bgt.s	.CheckStick			; If so, branch

.SetY:
	sub.w	d1,oY(a0)			; Align ourselves onto the ceiling
	rts

.CheckStick:
	tst.b	oPlayerStick(a0)		; Are we sticking to a surface?
	bne.s	.SetY				; If so, align to the ceiling anyways

	bset	#1,oFlags(a0)			; Fall off the ground
	bclr	#5,oFlags(a0)
	move.b	#1,oPrevAnim(a0)
	rts

; -------------------------------------------------------------------------
; Move the player along a left wall
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

Player_WalkVertL:
	move.w	oY(a0),d2			; Get primary sensor position
	move.w	oX(a0),d3
	moveq	#0,d0
	move.b	oXRadius(a0),d0
	ext.w	d0
	sub.w	d0,d2
	move.b	oYRadius(a0),d0
	ext.w	d0
	sub.w	d0,d3
	eori.w	#$F,d3
	lea	primaryAngle.w,a4		; Get floor information from this sensor
	movea.w	#-$10,a3
	move.w	#$800,d6
	moveq	#$D,d5
	bsr.w	FindLevelWall
	move.w	d1,-(sp)

	move.w	oY(a0),d2			; Get secondary sensor position
	move.w	oX(a0),d3
	moveq	#0,d0
	move.b	oXRadius(a0),d0
	ext.w	d0
	add.w	d0,d2
	move.b	oYRadius(a0),d0
	ext.w	d0
	sub.w	d0,d3
	eori.w	#$F,d3
	lea	secondaryAngle.w,a4		; Get floor information from this sensor
	movea.w	#-$10,a3
	move.w	#$800,d6
	moveq	#$D,d5
	bsr.w	FindLevelWall
	move.w	(sp)+,d0

	bsr.w	Player_PickSensor		; Choose which height and angle to go with
	tst.w	d1				; Are we perfectly aligned to the ground?
	beq.s	.End				; If so, branch
	bpl.s	.CheckLedge			; If we are outside the wall, branch
	cmpi.w	#-$E,d1				; Have we hit a wall?
	blt.w	Player_WalkVert_Done		; If so, branch
	sub.w	d1,oX(a0)			; Align outselves onto the wall

.End:
	rts

.CheckLedge:
	cmpi.w	#$E,d1				; Are we about to fall off?
	bgt.s	.CheckStick			; If so, branch

.SetX:
	sub.w	d1,oX(a0)			; Align ourselves onto the wall
	rts

.CheckStick:
	tst.b	oPlayerStick(a0)		; Are we sticking to a surface?
	bne.s	.SetX				; If so, align to the wall anyways

	bset	#1,oFlags(a0)			; Fall off the ground
	bclr	#5,oFlags(a0)
	move.b	#1,oPrevAnim(a0)
	rts

; -------------------------------------------------------------------------
; Get level Block metadata at a position
; -------------------------------------------------------------------------
; PARAMETERS:
;	d2.w - Y position
;	d3.w - X position
;	a0.l - Object RAM
; RETURNS:
;	a1.l - Block metadata pointer
; -------------------------------------------------------------------------

GetLevelBlock:
	move.w	d2,d0				; Get Y position
	lsr.w	#1,d0
	andi.w	#$780,d0			; Limit from 0 to $EFF in most levels
	cmpi.b	#2,zone				; Are we in Tidal Tempest?
	bne.s	.NotTTZ				; If not, branch
	andi.w	#$380,d0			; Limit from 0 to $6FF in Tidal Tempest

.NotTTZ:
	move.w	d3,d1				; Get X position
	lsr.w	#8,d1
	andi.w	#$7F,d1
	add.w	d1,d0				; Combine the X and Y into a level layout data index value

	move.l	#LevelChunks,d1			; Get base chunk data pointer
	lea	levelLayout.w,a1		; Get chunk that the block we want is in
	move.b	(a1,d0.w),d1
	beq.s	.Blank				; If it's a blank chunk, branch
	bmi.s	.LoopChunk			; If it's a loop chunk, branch

	cmpi.b	#5,zone				; Are we in Stardust Speedway?
	beq.s	.SSZ				; If so, branch
	cmpi.b	#6,zone				; Are we in Metallic Madness?
	bne.s	.NotMMZ				; If not, branch

.SSZ:
	andi.w	#$7FFF,oTile(a0)		; Set the object's sprite to be low priority

.NotMMZ:
	cmpi.b	#4,zone				; Are we in Wacky Workbench?
	bne.s	.NotWWZ				; If not, branch
	bclr	#6,oSprFlags(a0)		; Move the object onto the lower path layer

.NotWWZ:
	subq.b	#1,d1				; Prepare chunk data index value from X and Y position
	ext.w	d1
	ror.w	#7,d1
	move.w	d2,d0
	add.w	d0,d0
	andi.w	#$1E0,d0
	add.w	d0,d1
	move.w	d3,d0
	lsr.w	#3,d0
	andi.w	#$1E,d0
	add.w	d0,d1

.Blank:
	movea.l	d1,a1				; Get pointer to block
	rts

; -------------------------------------------------------------------------

.LoopChunk:
	andi.w	#$7F,d1				; Get chunk ID

	cmpi.b	#4,zone				; Are we in Wacky Workbench?
	bne.s	.NotWWZ2			; If not, branch

	btst	#6,oSprFlags(a0)		; Is the object on the higher path layer?
	bne.s	.LowPlane			; If so, branch
	cmpi.b	#$14,d1				; Is this chunk $14?
	bne.w	.GetBlock			; If not, branch
	bset	#6,oSprFlags(a0)		; Move the object onto the higher path layer
	andi.b	#$7F,oTile(a0)			; Set the object's sprite to be low priority
	bra.w	.GetBlock

.LowPlane:
	cmpi.b	#$15,d1				; Is this chunk $15?
	bne.s	.Not15				; If not, branch
	move.w	#$60,d1				; Change it to chunk $60
	bra.w	.GetBlock

.Not15:
	cmpi.b	#$1E,d1				; Is this chunk $1E?
	bne.s	.Not1E				; If not, branch
	move.w	#$61,d1				; Change it to chunk $61
	bra.w	.GetBlock

.Not1E:
	cmpi.b	#$1F,d1				; Is this chunk $1F?
	bne.s	.Not1F				; If not, branch
	move.w	#$62,d1				; Change it to chunk $62
	bra.w	.GetBlock

.Not1F:
	cmpi.b	#$32,d1				; Is this chunk $32?
	bne.w	.GetBlock			; If not, branch
	move.w	#$63,d1				; Change it to chunk $63
	bra.w	.GetBlock

; -------------------------------------------------------------------------

.NotWWZ2:
	cmpi.b	#5,zone				; Are we in Stardust Speedway?
	bne.w	.NotSSZ				; If not, branch

	ori.w	#$8000,oTile(a0)		; Set the object's sprite to be high priority
	cmpi.b	#4,d1				; Is this chunk 4?
	beq.s	.SwapChunkIfLow			; If so, branch
	cmpi.b	#6,d1				; Is this chunk 6?
	beq.s	.SwapChunkIfLow			; If so, branch

	tst.b	layer				; Are we on the first layer?
	beq.w	.GetBlock			; If so, branch
	andi.w	#$7FFF,oTile(a0)		; Set the object's sprite to be low priority
	cmpi.b	#$28,d1				; Is this chunk $28?
	beq.s	.SwapChunk			; If so, branch
	cmpi.b	#$3C,d1				; Is this chunk $3C?
	beq.s	.SwapChunk			; If so, branch
	cmpi.b	#$37,d1				; Is this chunk $37?
	beq.s	.SwapChunk			; If so, branch
	cmpi.b	#$2F,d1				; Is this chunk $2F?
	beq.s	.SwapChunk			; If so, branch
	cmpi.b	#$16,d1				; Is this chunk $16?
	beq.s	.SwapChunk			; If so, branch
	bra.w	.GetBlock

.SwapChunkIfLow:
	andi.w	#$7FFF,oTile(a0)		; Set the object's sprite to be low priority
	btst	#6,oSprFlags(a0)		; Is the object on the lower path layer?
	beq.w	.GetBlock			; If so, branch

.SwapChunk:
	addq.b	#1,d1				; Swap chunks
	bra.w	.GetBlock

; -------------------------------------------------------------------------

.NotSSZ:
	cmpi.b	#6,zone				; Are we in Metallic Madness?
	bne.s	.NotMMZ2			; If not, branch
	cmpi.b	#3,oID(a0)			; Is this a player object?
	bcc.w	.GetBlock			; If not, branch

	ori.w	#$8000,oTile(a0)		; Set the object's sprite to be high priority
	tst.b	layer				; Are we on layer 1?
	beq.s	.GetBlock			; If so, branch
	andi.w	#$7FFF,oTile(a0)		; Set the object's sprite to be low priority

	cmpi.b	#$46,d1				; Is this chunk $46?
	bne.s	.Not46
	move.w	#$6A,d1
	bra.s	.GetBlock

.Not46:
	cmpi.b	#$48,d1				; Is this chunk $48?
	bne.s	.Not48				; If not, branch
	move.w	#$6B,d1				; Change it to chunk $6B
	bra.s	.GetBlock

.Not48:
	cmpi.b	#$4A,d1				; Is this chunk $4A?
	bne.s	.Not4A				; If not, branch
	move.w	#$6C,d1				; Change it to chunk $6C
	bra.s	.GetBlock

.Not4A:
	cmpi.b	#$10,d1				; Is this chunk $10?
	bne.s	.Not10				; If not, branch
	move.w	#$6D,d1				; Change it to chunk $6D
	bra.s	.GetBlock

.Not10:
	cmpi.b	#$63,d1				; Is this chunk $63?
	bne.s	.Not63				; If not, branch
	move.w	#$6E,d1				; Change it to chunk $6E
	bra.s	.GetBlock

.Not63:
	cmpi.b	#$43,d1				; Is this chunk $43?
	bne.s	.GetBlock			; If not, branch
	move.w	#$6F,d1				; Change it to chunk $6F
	bra.s	.GetBlock

; -------------------------------------------------------------------------

.NotMMZ2:
	btst	#6,oSprFlags(a0)		; Is the object on the lower path layer?
	beq.s	.GetBlock			; If so, branch

	addq.w	#1,d1				; Swap chunks
	cmpi.w	#$29,d1				; Are we now on chunk $29?
	bne.s	.GetBlock			; If not, branch
	move.w	#$51,d1				; If so, change it to chunk $51

; -------------------------------------------------------------------------

.GetBlock:
	subq.b	#1,d1				; Prepare chunk data index value from X and Y position
	ror.w	#7,d1
	move.w	d2,d0
	add.w	d0,d0
	andi.w	#$1E0,d0
	add.w	d0,d1
	move.w	d3,d0
	lsr.w	#3,d0
	andi.w	#$1E,d0
	add.w	d0,d1

	movea.l	d1,a1				; Get pointer to block
	rts

; -------------------------------------------------------------------------
; Get the distance to the nearest block vertically
; -------------------------------------------------------------------------
; PARAMETERS:
;	d2.w - Y position
;	d3.w - X position
;	d5.w - Bit to check for solidity
;	d6.w - Flip bits
;	a3.w - Distance in pixels to check for a nearby block
;	a4.w - Pointer to where the angle will be stored
; RETURNS:
;	d1.w - Distance from the block
;	a1.l - Block metadata pointer
;	(a4).b - Angle
; -------------------------------------------------------------------------

FindLevelFloor:
	bsr.w	GetLevelBlock			; Get block at position
	cmpi.l	#LevelChunks,d1			; Is it a blank block?
	beq.s	.IsBlank			; If so, branch

	move.w	(a1),d0				; Get block ID
	move.w	d0,d4
	andi.w	#$7FF,d0
	beq.s	.IsBlank			; If it's blank, branch
	btst	d5,d4				; Is the block solid?
	bne.s	.IsSolid			; If so, branch

.IsBlank:
	add.w	a3,d2				; Check the nearby block
	bsr.w	FindLevelFloor2
	sub.w	a3,d2				; Restore Y position
	addi.w	#$10,d1				; Increment height
	rts

.IsSolid:
	movea.l	collisionPtr.w,a2		; Get collision block ID
	move.b	(a2,d0.w),d0
	andi.w	#$FF,d0
	beq.s	.IsBlank			; If it's blank, branch

	lea	ColAngleMap,a2			; Get collision angle
	move.b	(a2,d0.w),(a4)

	lsl.w	#4,d0				; Get base collision block height map index
	move.w	d3,d1				; Get X position
	btst	#$B,d4				; Is this block horizontally flipped?
	beq.s	.NoXFlip			; If not, branch
	not.w	d1				; Flip the X position
	neg.b	(a4)				; Flip the angle

.NoXFlip:
	btst	#$C,d4				; Is this block vertically flipped?
	beq.s	.NoYFlip			; If not, branch
	addi.b	#$40,(a4)			; Flip the angle
	neg.b	(a4)
	subi.b	#$40,(a4)

.NoYFlip:
	andi.w	#$F,d1				; Get block column height
	add.w	d0,d1
	lea	ColHeightMap,a2
	move.b	(a2,d1.w),d0
	ext.w	d0

	eor.w	d6,d4				; Is this block vertically flipped?
	btst	#$C,d4
	beq.s	.NoYFlip2			; If not, branch
	neg.w	d0				; Flip the height

.NoYFlip2:
	tst.w	d0				; Check the height
	beq.s	.IsBlank			; If it's 0, branch
	bmi.s	.CheckNegFloor			; If it's negative, branch
	cmpi.b	#$10,d0				; Is this a full height?
	beq.s	.MaxFloor			; If so, branch

.FoundFloor:
	move.w	d2,d1				; Get how deep the object is into the block
	andi.w	#$F,d1
	add.w	d1,d0
	move.w	#$F,d1
	sub.w	d0,d1
	rts

.CheckNegFloor:
	cmpa.w	#$10,a3				; Is the next block above?
	bne.s	.NegFloor			; If so, branch
	move.w	#$10,d0				; Force height to be full
	move.b	#0,(a4)				; Set angle to 0
	bra.s	.FoundFloor

.NegFloor:
	move.w	d2,d1				; Get how deep the object is into the block
	andi.w	#$F,d1
	add.w	d1,d0
	bpl.w	.IsBlank			; If the object is outside of the block, branch

.MaxFloor:
	sub.w	a3,d2				; Check the nearby block
	bsr.w	FindLevelFloor2
	add.w	a3,d2				; Restore Y position
	subi.w	#$10,d1				; Decrement height
	rts

; -------------------------------------------------------------------------

FindLevelFloor2:
	bsr.w	GetLevelBlock			; Get block at position
	cmpi.l	#LevelChunks,d1			; Is it a blank block?
	beq.s	.IsBlank			; If so, branch

	move.w	(a1),d0				; Get block ID
	move.w	d0,d4
	andi.w	#$7FF,d0
	beq.s	.IsBlank			; If it's blank, branch
	btst	d5,d4				; Is the block solid?
	bne.s	.IsSolid			; If so, branch

.IsBlank:
	move.w	#$F,d1				; Get how deep the object is into the block
	move.w	d2,d0
	andi.w	#$F,d0
	sub.w	d0,d1
	rts

.IsSolid:
	movea.l	collisionPtr.w,a2		; Get collision block ID
	move.b	(a2,d0.w),d0
	andi.w	#$FF,d0
	beq.s	.IsBlank			; If it's blank, branch

	lea	ColAngleMap,a2			; Get collision angle
	move.b	(a2,d0.w),(a4)

	lsl.w	#4,d0				; Get base collision block height map index
	move.w	d3,d1				; Get X position
	btst	#$B,d4				; Is this block horizontally flipped?
	beq.s	.NoXFlip			; If not, branch
	not.w	d1				; Flip the X position
	neg.b	(a4)				; Flip the angle

.NoXFlip:
	btst	#$C,d4				; Is this block vertically flipped?
	beq.s	.NoYFlip			; If not, branch
	addi.b	#$40,(a4)			; Flip the angle
	neg.b	(a4)
	subi.b	#$40,(a4)

.NoYFlip:
	andi.w	#$F,d1				; Get block column height
	add.w	d0,d1
	lea	ColHeightMap,a2
	move.b	(a2,d1.w),d0
	ext.w	d0

	eor.w	d6,d4				; Is this block vertically flipped?
	btst	#$C,d4
	beq.s	.NoYFlip2			; If not, branch
	neg.w	d0				; Flip the height

.NoYFlip2:
	tst.w	d0				; Check the height
	beq.s	.IsBlank			; If it's 0, branch
	bmi.s	.CheckNegFloor			; If it's negative, branch

.FoundFloor:
	move.w	d2,d1				; Get how deep the object is into the block
	andi.w	#$F,d1
	add.w	d1,d0
	move.w	#$F,d1
	sub.w	d0,d1
	rts

.CheckNegFloor:
	cmpa.w	#$10,a3				; Were we checking above the last block?
	bne.s	.NegFloor			; If so, branch
	move.w	#$10,d0				; Force height to be full
	move.b	#0,(a4)				; Set angle to 0
	bra.s	.FoundFloor

.NegFloor:
	move.w	d2,d1				; Get how deep the object is into the block
	andi.w	#$F,d1
	add.w	d1,d0
	bpl.w	.IsBlank			; If the object is outside of the block, branch
	not.w	d1				; Flip the height
	rts

; -------------------------------------------------------------------------
; Get the distance to the nearest block horizontally
; -------------------------------------------------------------------------
; PARAMETERS:
;	d2.w - Y position
;	d3.w - X position
;	d5.w - Bit to check for solidity
;	d6.w - Flip bits
;	a3.w - Distance in pixels to check for a nearby block
;	a4.w - Pointer to where the angle will be stored
; RETURNS:
;	d1.w - Distance from the block
;	a1.l - Block metadata pointer
;	(a4).b - Angle
; -------------------------------------------------------------------------

FindLevelWall:
	bsr.w	GetLevelBlock			; Get block at position
	cmpi.l	#LevelChunks,d1			; Is it a blank block?
	beq.s	.IsBlank			; If so, branch

	move.w	(a1),d0				; Get block ID
	move.w	d0,d4
	andi.w	#$7FF,d0
	beq.s	.IsBlank			; If it's blank, branch
	btst	d5,d4				; Is the block solid?
	bne.s	.IsSolid			; If so, branch

.IsBlank:
	add.w	a3,d3				; Check the nearby block
	bsr.w	FindLevelWall2
	sub.w	a3,d3				; Restore Y position
	addi.w	#$10,d1				; Increment width
	rts

.IsSolid:
	movea.l	collisionPtr.w,a2		; Get collision block ID
	move.b	(a2,d0.w),d0
	andi.w	#$FF,d0
	beq.s	.IsBlank			; If it's blank, branch

	lea	ColAngleMap,a2			; Get collision angle
	move.b	(a2,d0.w),(a4)

	lsl.w	#4,d0				; Get base collision block width map index
	move.w	d2,d1				; Get Y position
	btst	#$C,d4				; Is this block vertically flipped?
	beq.s	.NoYFlip			; If not, branch
	not.w	d1				; Flip the Y position
	addi.b	#$40,(a4)			; Flip the angle
	neg.b	(a4)
	subi.b	#$40,(a4)

.NoYFlip:
	btst	#$B,d4				; Is this block horizontally flipped?
	beq.s	.NoXFlip			; If not, branch
	neg.b	(a4)				; Flip the angle

.NoXFlip:
	andi.w	#$F,d1				; Get block row width
	add.w	d0,d1
	lea	ColWidthMap,a2
	move.b	(a2,d1.w),d0
	ext.w	d0

	eor.w	d6,d4				; Is this block horizontally flipped?
	btst	#$B,d4
	beq.s	.NoYFlip2			; If not, branch
	neg.w	d0				; Flip the width

.NoYFlip2:
	tst.w	d0				; Check the width
	beq.s	.IsBlank			; If it's 0, branch
	bmi.s	.NegWall			; If it's negative, branch
	cmpi.b	#$10,d0				; Is this a full width?
	beq.s	.MaxWall			; If so, branch
	move.w	d3,d1				; Get how deep the object is into the block
	andi.w	#$F,d1
	add.w	d1,d0
	move.w	#$F,d1
	sub.w	d0,d1
	rts

.NegWall:
	move.w	d3,d1				; Get how deep the object is into the block
	andi.w	#$F,d1
	add.w	d1,d0
	bpl.w	.IsBlank			; If the object is outside of the block, branch

.MaxWall:
	sub.w	a3,d3				; Check the nearby block
	bsr.w	FindLevelWall2
	add.w	a3,d3				; Restore Y position
	subi.w	#$10,d1				; Decrement width
	rts

; -------------------------------------------------------------------------

FindLevelWall2:
	bsr.w	GetLevelBlock			; Get block at position
	cmpi.l	#LevelChunks,d1			; Is it a blank block?
	beq.s	.IsBlank			; If so, branch

	move.w	(a1),d0				; Get block ID
	move.w	d0,d4
	andi.w	#$7FF,d0
	beq.s	.IsBlank			; If it's blank, branch
	btst	d5,d4				; Is the block solid?
	bne.s	.IsSolid			; If so, branch

.IsBlank:
	move.w	#$F,d1				; Get how deep the object is into the block
	move.w	d3,d0
	andi.w	#$F,d0
	sub.w	d0,d1
	rts

.IsSolid:
	movea.l	collisionPtr.w,a2		; Get collision block ID
	move.b	(a2,d0.w),d0
	andi.w	#$FF,d0
	beq.s	.IsBlank			; If it's blank, branch

	lea	ColAngleMap,a2			; Get collision angle
	move.b	(a2,d0.w),(a4)

	lsl.w	#4,d0				; Get base collision block width map index
	move.w	d2,d1				; Get Y position
	btst	#$C,d4				; Is this block vertically flipped?
	beq.s	.NoYFlip			; If not, branch
	not.w	d1				; Flip the Y position
	addi.b	#$40,(a4)			; Flip the angle
	neg.b	(a4)
	subi.b	#$40,(a4)

.NoYFlip:
	btst	#$B,d4				; Is this block horizontally flipped?
	beq.s	.NoXFlip			; If not, branch
	neg.b	(a4)				; Flip the angle

.NoXFlip:
	andi.w	#$F,d1				; Get block row width
	add.w	d0,d1
	lea	ColWidthMap,a2
	move.b	(a2,d1.w),d0
	ext.w	d0

	eor.w	d6,d4				; Is this block horizontally flipped?
	btst	#$B,d4
	beq.s	.NoYFlip2			; If not, branch
	neg.w	d0				; Flip the width

.NoYFlip2:
	tst.w	d0				; Check the width
	beq.s	.IsBlank			; If it's 0, branch
	bmi.s	.NegWall			; If it's negative, branch
	move.w	d3,d1				; Get how deep the object is into the block
	andi.w	#$F,d1
	add.w	d1,d0
	move.w	#$F,d1
	sub.w	d0,d1
	rts

.NegWall:
	move.w	d3,d1				; Get how deep the object is into the block
	andi.w	#$F,d1
	add.w	d1,d0
	bpl.w	.IsBlank			; If the object is outside of the block, branch
	not.w	d1				; Flip the width
	rts

; -------------------------------------------------------------------------
; This subroutine takes 'raw' bitmap-like collision block data as input and
; converts it into the proper collision arrays. Pointers to said raw data
; are dummied out.
; -------------------------------------------------------------------------

RawColBlocks		EQU	ColHeightMap
ConvRowColBlocks	EQU	ColHeightMap

ConvColArray:
	rts

	lea	RawColBlocks,a1			; Source of "raw" collision array
	lea	ConvRowColBlocks,a2		; Destination of converted collision array

	move.w	#$100-1,d3			; Number of blocks in collision array

.BlockLoop:
	moveq	#16,d5				; Start on the leftmost pixel
	move.w	#16-1,d2			; Width of a block in pixels

.ColumnLoop:
	moveq	#0,d4
	move.w	#16-1,d1			; Height of a block of pixels

.RowLoop:
	move.w	(a1)+,d0			; Get row of collision bits
	lsr.l	d5,d0				; Push the selected bit of this row into the extended flag
	addx.w	d4,d4				; Shift d4 to the left, and append the selected bit
	dbf	d1,.RowLoop

	move.w	d4,(a2)+			; Store the column of collision bits
	suba.w	#2*16,a1			; Back to the start of the block
	subq.w	#1,d5				; Get next bit in the row
	dbf	d2,.ColumnLoop			; Loop for each column of pixels in a block

	adda.w	#2*16,a1			; Next block
	dbf	d3,.BlockLoop			; Loop for each block in the collision array

	lea	ConvRowColBlocks,a1		; Convert widths
	lea	ColWidthMap,a2
	bsr.s	.ConvToColBlocks
	lea	RawColBlocks,a1			; Convert heights
	lea	ColHeightMap,a2

; -------------------------------------------------------------------------

.ConvToColBlocks:
	move.w	#$1000-1,d3			; Size of a standard collision arary

.ProcCollision:
	moveq	#0,d2				; Base height
	move.w	#16-1,d1			; Column height
	move.w	(a1)+,d0			; Get current column of collision pixels
	beq.s	.NoCollision			; If there's no collision in this column, branch
	bmi.s	.InvertedCol			; If the collision is inverted, branch

.ProcColumnLoop:
	lsr.w	#1,d0				; Is there a solid pixel?
	bcc.s	.NotSolid			; If not, branch
	addq.b	#1,d2				; Increment height

.NotSolid:
	dbf	d1,.ProcColumnLoop		; Loop until finished
	bra.s	.ColumnProcessed

.InvertedCol:
	cmpi.w	#$FFFF,d0			; Is the entire column solid?
	beq.s	.FullColumn			; If so, branch

.ProcColumnLoop2:
	lsl.w	#1,d0				; Is there a solid pixel?
	bcc.s	.NotSolid2			; If not, branch
	subq.b	#1,d2				; Decrement height

.NotSolid2:
	dbf	d1,.ProcColumnLoop2		; Loop until finished
	bra.s	.ColumnProcessed

.FullColumn:
	move.w	#16,d0				; Set height to 16 pixels

.NoCollision:
	move.w	d0,d2				; Set fill height

.ColumnProcessed:
	move.b	d2,(a2)+			; Store column height
	dbf	d3,.ProcCollision		; Loop until finished
	rts

; -------------------------------------------------------------------------
