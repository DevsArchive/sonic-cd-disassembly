; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Object functions
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Run objects
; -------------------------------------------------------------------------

RunObjects:
	lea	objects.w,a0			; Prepare objects
	moveq	#OBJCOUNT-1,d7

	moveq	#0,d0				; Prepare to get object ID

.Loop:
	move.b	(a0),d0				; Get object ID
	beq.s	.NextObj			; If it's 0, branch

	add.w	d0,d0				; Run object
	add.w	d0,d0
	lea	ObjectIndex,a1
	movea.l -4(a1,d0.w),a1
	jsr	(a1)

	moveq	#0,d0				; Prepare to get object ID

.NextObj:
	lea	oSize(a0),a0			; Get next object
	dbf	d7,.Loop			; Loop until finished

	rts

; -------------------------------------------------------------------------
; Handle player movement with gravity
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

ObjMoveGrv:
	move.l	oX(a0),d2			; Get position
	move.l	oY(a0),d3

	move.w	oXVel(a0),d0			; Apply X velocity
	ext.l	d0
	asl.l	#8,d0
	add.l	d0,d2

	move.w	oYVel(a0),d0			; Get Y velocity

	btst	#3,oPlayerCtrl(a0)		; Are we on a rotating pole?
	bne.s	.NoGravity			; If so, branch

	bpl.s	.CheckGravity			; If we are moving downwards, branch

	btst	#1,oPlayerCtrl(a0)		; Are we on a 3D ramp?
	beq.s	.CheckGravity			; If not, branch
	cmpi.w	#-$800,oYVel(a0)		; Are we going fast enough?
	bcs.s	.NoGravity			; If so, branch

.CheckGravity:
	btst	#2,oPlayerCtrl(a0)		; Are we hanging from a bar?
	bne.s	.NoGravity			; If so, branch
	addi.w	#$38,oYVel(a0)			; Apply gravity

.NoGravity:
	tst.w	oYVel(a0)			; Are we moving up?
	bmi.s	.NoDownVelCap			; If so, branch
	cmpi.w	#$1000,oYVel(a0)		; Are we falling down too fast?
	bcs.s	.NoDownVelCap			; If not, branch
	move.w	#$1000,oYVel(a0)		; Cap the fall speed

.NoDownVelCap:
	ext.l	d0				; Apply Y velocity
	asl.l	#8,d0
	add.l	d0,d3

	move.l	d2,oX(a0)			; Update position
	move.l	d3,oY(a0)
	rts

; -------------------------------------------------------------------------
; Handle player movement
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Player object RAM
; -------------------------------------------------------------------------

ObjMove:
	move.l	oX(a0),d2			; Get position
	move.l	oY(a0),d3

	move.w	oXVel(a0),d0			; Get X velocity

	btst	#3,oFlags(a0)			; Are we standing on an object?
	beq.s	.NotOnObj			; If not, branch

	moveq	#0,d1				; Get the object we are standing on
	move.b	oPlayerStandObj(a0),d1
	lsl.w	#6,d1
	addi.l	#objects&$FFFFFF,d1
	movea.l	d1,a1
	cmpi.b	#$1E,oID(a1)			; Is it a pinball flipper from CCZ?
	bne.s	.NotOnObj			; If not, branch

	move.w	#-$100,d1			; Get resistance value
	btst	#0,oFlags(a1)			; Is the object flipped?
	beq.s	.NotNeg				; If not, branch
	neg.w	d1				; Flip the resistance value

.NotNeg:
	add.w	d1,d0				; Apply resistance on the X velocity

.NotOnObj:
	ext.l	d0				; Apply X velocity
	asl.l	#8,d0
	add.l	d0,d2

	move.w	oYVel(a0),d0			; Apply Y velocity
	ext.l	d0
	asl.l	#8,d0
	add.l	d0,d3

	move.l	d2,oX(a0)			; Update position
	move.l	d3,oY(a0)
	rts

; -------------------------------------------------------------------------
; Draw an object's sprite
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Object RAM
; -------------------------------------------------------------------------

DrawObject:
	bclr	#7,oSprFlags(a0)		; Mark this object as offscreen

	move.b	oSprFlags(a0),d0		; Is this object to be drawn relative to a camera?
	andi.w	#$C,d0
	beq.w	.DrawObj			; If not, branch

	move.b	oWidth(a0),d0			; Is this object onscreen horizontally?
	move.w	oX(a0),d3
	sub.w	cameraX.w,d3
	move.w	d3,d1
	add.w	d0,d1
	bmi.s	.End				; If not, branch
	move.w	d3,d1
	sub.w	d0,d1
	cmpi.w	#320,d1
	bge.s	.End				; If not, branch

	move.b	oYRadius(a0),d0			; Get object Y position and radius
	move.w	oY(a0),d3

	cmpi.w	#$100,cameraY.w			; Are we near the top of the screen?
	bcc.s	.ChkBottomWrap			; If not, branch
	cmpi.w	#$800,d3			; Is this object at the bottom of the level?
	bcs.s	.CheckY				; If not, branch
	subi.w	#$800,d3			; Wrap to the top of the screen
	bra.s	.CheckY

.ChkBottomWrap:
	cmpi.w	#$700,cameraY.w			; Are we near the bottom of the screen?
	bcs.s	.CheckY				; If not, branch
	cmpi.w	#$100,d3			; Is this object at the top of the level?
	bcc.s	.CheckY				; If not, branch
	addi.w	#$800,d3			; Wrap to the bottom of the screen

.CheckY:
	sub.w	cameraY.w,d3			; Is this object onscreen vertically?
	move.w	d3,d1
	add.w	d0,d1
	bmi.s	.End				; If not, branch
	move.w	d3,d1
	sub.w	d0,d1
	cmpi.w	#$E0,d1
	bge.s	.End				; If not, branch

.DrawObj:
	lea	objDrawQueue.w,a1		; Get the object draw queue for this object's priority level
	move.w	oPriority(a0),d0
	lsr.w	#1,d0
	andi.w	#$380,d0
	adda.w	d0,a1

	cmpi.w	#$7E,(a1)			; Is the queue full?
	bcc.s	.End				; If so, branch
	addq.w	#2,(a1)				; Add this object to the queue
	adda.w	(a1),a1
	move.w	a0,(a1)

.End:
	rts

; -------------------------------------------------------------------------
; Draw another object's sprite
; -------------------------------------------------------------------------
; PARAMETERS:
;	a1.l - Object RAM
; -------------------------------------------------------------------------

DrawOtherObject:
	lea	objDrawQueue.w,a2		; Get the object draw queue for this object's priority level
	move.w	oPriority(a1),d0
	lsr.w	#1,d0
	andi.w	#$380,d0
	adda.w	d0,a2

	cmpi.w	#$7E,(a2)			; Is the queue full?
	bcc.s	.End				; If so, branch
	addq.w	#2,(a2)				; Add this object to the queue
	adda.w	(a2),a2
	move.w	a1,(a2)

.End:
	rts

; -------------------------------------------------------------------------
; Make an object delete itself
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Object RAM
; -------------------------------------------------------------------------

DeleteObject:
	movea.l	a0,a1				; Clear object slot RAM
	moveq	#0,d1
	moveq	#oSize/4-1,d0

.Clear:
	move.l	d1,(a1)+
	dbf	d0,.Clear

	rts

; -------------------------------------------------------------------------
; Draw all of the queued object sprites
; -------------------------------------------------------------------------

ObjDrawCameras:
	dc.l	0				; Absolute position
	dc.l	cameraX&$FFFFFF			; Relative to FG camera
	dc.l	cameraBgX&$FFFFFF		; Relative to BG camera
	dc.l	cameraBg3X&$FFFFFF		; Relative to BG3 camera

; -------------------------------------------------------------------------

DrawObjects:
	lea	sprites.w,a2			; Prepare sprite table buffer
	moveq	#0,d5				; Prepare sprite counter
	lea	objDrawQueue.w,a4		; Prepare object draw queue

	moveq	#8-1,d7				; Number of priority levels

.LevelLoop:
	tst.w	(a4)				; Does this priority level's queue have any entries?
	beq.w	.NextLevel			; If not, branch
	moveq	#2,d6				; Prepare to go through the queue

.ObjLoop:
	movea.w	(a4,d6.w),a0			; Get entry object RAM

	tst.b	(a0)				; Is this object loaded?
	beq.w	.NextObj			; If not, branch

	move.b	oSprFlags(a0),d0		; Is this object to be drawn relative to a camera?
	move.b	d0,d4
	andi.w	#%00001100,d0
	beq.w	.ScreenPos			; If not, branch

	movea.l	ObjDrawCameras(pc,d0.w),a1	; Get camera that the object is relative to

	moveq	#0,d0				; Get object's X position onscreen
	move.b	oWidth(a0),d0
	move.w	oX(a0),d3
	sub.w	(a1),d3
	addi.w	#128,d3

	moveq	#0,d0				; Get object's Y position
	move.b	oYRadius(a0),d0
	move.w	oY(a0),d2
	cmpi.w	#$100,4(a1)			; Is the camera near the top of the level?
	bcc.s	.ChkBottomWrap			; If not, branch
	cmpi.w	#$800,d2			; Is this object near the bottom of the level?
	bcs.s	.EndWrap			; If not, branch
	subi.w	#$800,d2			; Wrap the object to the top of the screen
	bra.s	.EndWrap

.ChkBottomWrap:
	cmpi.w	#$700,4(a1)			; Is the camera near the bottom of the level?
	bcs.s	.EndWrap			; If not, branch
	cmpi.w	#$100,d2			; Is this object near the top of the level?
	bcc.s	.EndWrap			; If not, branch
	addi.w	#$800,d2			; Wrap the object to the bottom of the screen

.EndWrap:
	sub.w	4(a1),d2			; Get object's Y position onscreen
	addi.w	#128,d2
	bra.s	.DrawSprite

.ScreenPos:
	move.w	oYScr(a0),d2			; The object's position is an absolute screen position
	move.w	oX(a0),d3
	bra.s	.DrawSprite

; -------------------------------------------------------------------------
; Dead code. It's a leftover from Sonic 1, in which if bit 4 of the object's
; render flags is clear, it ignores the object's Y radius for its Y position
; onscreen check. However, since DrawObject handles the onscreen check now, this
; is left unused.
; -------------------------------------------------------------------------

.NoYRadChk:
	move.w	oY(a0),d2			; Get object's Y position onscreen
	sub.w	4(a1),d2
	addi.w	#128,d2
	cmpi.w	#0-32+128,d2			; Is it onscreen?
	bcs.s	.NextObj			; If not, branch
	cmpi.w	#224+32+128,d2
	bcc.s	.NextObj			; If not, branch

; -------------------------------------------------------------------------

.DrawSprite:
	movea.l	oMap(a0),a1			; Get object mappings
	moveq	#0,d1
	btst	#5,d4				; Is the pointer to the mappings a pointer to static mappings data?
	bne.s	.StaticMap			; If so, branch

	move.b	oMapFrame(a0),d1		; Get pointer to the object's frame mappings
	add.w	d1,d1
	adda.w	(a1,d1.w),a1

	moveq	#0,d1				; Get number of pieces to draw
	move.b	(a1)+,d1
	subq.b	#1,d1
	bmi.s	.DrawDone			; If there are no pieces to draw, branch

.StaticMap:
	bsr.w	DrawSprite			; Draw the sprite

.DrawDone:
	bset	#7,oSprFlags(a0)		; Mark the object as onscreen

.NextObj:
	addq.w	#2,d6				; Next entry in the draw queue
	subq.w	#2,(a4)				; Decrement queue entry count
	bne.w	.ObjLoop			; If we haven't run out, branch

.NextLevel:
	lea	$80(a4),a4			; Next priority level draw queue
	dbf	d7,.LevelLoop			; Loop until all the priority levels have been gone through

	move.b	d5,spriteCount.w		; Save sprite count
	cmpi.b	#80,d5				; Is the sprite table full?
	beq.s	.TableFull			; If so, branch

	move.l	#0,(a2)				; Mark the current sprite table entry as the last
	rts

.TableFull:
	move.b	#0,-5(a2)			; Mark the last sprite table entry as the last
	rts

; -------------------------------------------------------------------------
; Draw a sprite from mappings data
; -------------------------------------------------------------------------
; PARAMETERS:
;	d1.w - Sprite piece count
;	d2.w - Y position
;	d3.w - X position
;	d4.b - Render flags
;	d5.b - Previous sprite link value
;	a0.l - Object RAM
;	a1.l - Sprite mappings data pointer
;	a2.l - Sprite table buffer pointer
; -------------------------------------------------------------------------

DrawSprite:
	movea.w	oTile(a0),a3			; Get base tile

	btst	#0,d4				; Is the sprite flipped horizontally?
	bne.s	DrawSprite_FlipX		; If so, branch
	btst	#1,d4				; Is the sprite flipped vertically?
	bne.w	DrawSprite_FlipY		; If so, branch

.Loop:
	cmpi.b	#80,d5				; Is the sprite table full?
	beq.s	.End				; If so, branch

	move.b	(a1)+,d0			; Set Y position
	ext.w	d0
	add.w	d2,d0
	move.w	d0,(a2)+

	move.b	(a1)+,(a2)+			; Set sprite size

	addq.b	#1,d5				; Set sprite link
	move.b	d5,(a2)+

	move.b	(a1)+,d0			; Set sprite tile
	lsl.w	#8,d0
	move.b	(a1)+,d0
	add.w	a3,d0
	move.w	d0,(a2)+

	move.b	(a1)+,d0			; Set X position
	ext.w	d0
	add.w	d3,d0
	andi.w	#$1FF,d0
	bne.s	.SetX
	addq.w	#1,d0

.SetX:
	move.w	d0,(a2)+

	dbf	d1,.Loop			; Loop until all pieces are drawn

.End:
	rts

; -------------------------------------------------------------------------

DrawSprite_FlipX:
	btst	#1,d4				; Is the sprite flipped vertically?
	bne.w	DrawSprite_FlipXY

.Loop:
	cmpi.b	#80,d5				; Is the sprite table full?
	beq.s	.End				; If so, branch

	move.b	(a1)+,d0			; Set Y position
	ext.w	d0
	add.w	d2,d0
	move.w	d0,(a2)+

	move.b	(a1)+,d4			; Set sprite size
	move.b	d4,(a2)+

	addq.b	#1,d5				; Set sprite link
	move.b	d5,(a2)+

	move.b	(a1)+,d0			; Set sprite tile
	lsl.w	#8,d0
	move.b	(a1)+,d0
	add.w	a3,d0
	eori.w	#$800,d0
	move.w	d0,(a2)+

	move.b	(a1)+,d0			; Set X position
	ext.w	d0
	neg.w	d0
	add.b	d4,d4
	andi.w	#$18,d4
	addq.w	#8,d4
	sub.w	d4,d0
	add.w	d3,d0
	andi.w	#$1FF,d0
	bne.s	.SetX
	addq.w	#1,d0

.SetX:
	move.w	d0,(a2)+

	dbf	d1,.Loop			; Loop until all pieces are drawn

.End:
	rts

; -------------------------------------------------------------------------

DrawSprite_FlipY:
.Loop:
	cmpi.b	#80,d5				; Is the sprite table full?
	beq.s	.End				; If so, branch

	move.b	(a1)+,d0			; Set Y position
	move.b	(a1),d4
	ext.w	d0
	neg.w	d0
	lsl.b	#3,d4
	andi.w	#$18,d4
	addq.w	#8,d4
	sub.w	d4,d0
	add.w	d2,d0
	move.w	d0,(a2)+

	move.b	(a1)+,(a2)+			; Set sprite size

	addq.b	#1,d5				; Set sprite link
	move.b	d5,(a2)+

	move.b	(a1)+,d0			; Set sprite tile
	lsl.w	#8,d0
	move.b	(a1)+,d0
	add.w	a3,d0
	eori.w	#$1000,d0
	move.w	d0,(a2)+

	move.b	(a1)+,d0			; Set X position
	ext.w	d0
	add.w	d3,d0
	andi.w	#$1FF,d0
	bne.s	.SetX
	addq.w	#1,d0

.SetX:
	move.w	d0,(a2)+

	dbf	d1,.Loop			; Loop until all pieces are drawn

.End:
	rts

; -------------------------------------------------------------------------

DrawSprite_FlipXY:
.Loop:
	cmpi.b	#80,d5				; Is the sprite table full?
	beq.s	.End				; If so, branch

	move.b	(a1)+,d0			; Set Y position
	move.b	(a1),d4
	ext.w	d0
	neg.w	d0
	lsl.b	#3,d4
	andi.w	#$18,d4
	addq.w	#8,d4
	sub.w	d4,d0
	add.w	d2,d0
	move.w	d0,(a2)+

	move.b	(a1)+,d4			; Set sprite size
	move.b	d4,(a2)+

	addq.b	#1,d5				; Set sprite link
	move.b	d5,(a2)+

	move.b	(a1)+,d0			; Set sprite tile
	lsl.w	#8,d0
	move.b	(a1)+,d0
	add.w	a3,d0
	eori.w	#$1800,d0
	move.w	d0,(a2)+

	move.b	(a1)+,d0			; Set X position
	ext.w	d0
	neg.w	d0
	add.b	d4,d4
	andi.w	#$18,d4
	addq.w	#8,d4
	sub.w	d4,d0
	add.w	d3,d0
	andi.w	#$1FF,d0
	bne.s	.SetX
	addq.w	#1,d0

.SetX:
	move.w	d0,(a2)+

	dbf	d1,.Loop			; Loop until all pieces are drawn

.End:
	rts

; -------------------------------------------------------------------------
; Check if an object is onscreen
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Object RAM
; -------------------------------------------------------------------------

ChkObjOnScreen:
	move.w	oX(a0),d0			; Is the object onscreen horizontally?
	sub.w	cameraX.w,d0
	bmi.s	.OffScreen			; If not, branch
	cmpi.w	#320,d0
	bge.s	.OffScreen			; If not, branch

	move.w	oY(a0),d1			; Is the object onscreen vertically?
	sub.w	cameraY.w,d1
	bmi.s	.OffScreen			; If not, branch
	cmpi.w	#224,d1
	bge.s	.OffScreen			; If not, branch

	moveq	#0,d0				; Mark as onscreen
	rts

.OffScreen:
	moveq	#1,d0				; Mark as offscreen
	rts

; -------------------------------------------------------------------------

ChkObjOnScrWidth:
	moveq	#0,d1				; Is the object onscreen horizontally?
	move.b	oWidth(a0),d1
	move.w	oX(a0),d0
	sub.w	cameraX.w,d0
	add.w	d1,d0
	bmi.s	.OffScreen			; If not, branch
	add.w	d1,d1
	sub.w	d1,d0
	cmpi.w	#320,d0
	bge.s	.OffScreen			; If not, branch

	move.w	oY(a0),d1			; Is the object onscreen vertically?
	sub.w	cameraY.w,d1
	bmi.s	.OffScreen			; If not, branch
	cmpi.w	#224,d1
	bge.s	.OffScreen			; If not, branch

	moveq	#0,d0				; Mark as onscreen
	rts

.OffScreen:
	moveq	#1,d0				; Mark as offscreen
	rts

; -------------------------------------------------------------------------
