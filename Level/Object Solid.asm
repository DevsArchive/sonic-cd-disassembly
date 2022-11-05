; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Solid object functions
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Get off object
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Object slot
;	a1.l - Player object slot
; -------------------------------------------------------------------------

GetOffObject:
	btst	#3,oFlags(a0)			; Were we being stood on?
	beq.s	.End				; If not, branch
	btst	#3,oFlags(a1)			; Was the player standing on an object?
	beq.s	.End				; If not, branch
	
	moveq	#0,d0				; Get object the player is standing on
	move.b	oPlayerStandObj(a1),d0
	if oSize=$40
		lsl.w	#6,d0
	else
		mulu.w	#oSize,d0
	endif
	addi.l	#objects&$FFFFFF,d0
	cmpa.w	d0,a0				; Is it us?
	bne.s	.End				; If not, branch

	tst.b	oPlayerCharge(a1)		; Is the player charging a peelout or spindash?
	beq.s	.NoSound			; If not, branch
	move.w	#FM_CHARGESTOP,d0		; Play charge stop sound
	jsr	PlayFMSound

.NoSound:
	clr.b	oPlayerStick(a1)		; Clear collision stick flag
	bset	#1,oFlags(a1)			; Mark player in the air
	bclr	#3,oFlags(a1)			; Player is no longer standing on an object
	bclr	#3,oFlags(a0)
	btst	#6,oPlayerCtrl(a1)		; Is the player invisible?
	bne.s	.ReleasePlayer			; If so, branch
	cmpi.b	#$17,oAnim(a1)			; Is the player drowning?
	beq.s	.ReleasePlayer			; If so, branch
	bclr	#0,oPlayerCtrl(a1)		; Stop controlling the player

.ReleasePlayer:
	clr.b	oPlayerStandObj(a1)		; Reset object that player is standing on
	cmpi.b	#$2B,oAnim(a1)			; Is the player giving up from boredom?
	bne.s	.End				; If not, branch
	bclr	#1,oFlags(a1)			; Mark player on the ground

.End:
	rts
	
; -------------------------------------------------------------------------
; Stand on object
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Object slot
;	a1.l - Player object slot
; -------------------------------------------------------------------------

StandOnObject:
	cmpi.b	#4,oRoutine(a1)			; Is the player hurt?
	bne.s	.NotHurt			; If not, branch
	subq.b	#2,oRoutine(a1)			; Go back to the main routine
	move.w	#120,oPlayerHurt(a1)		; Set hurt time

.NotHurt:
	clr.b	oSolidType(a0)			; Clear solidity type
	clr.b	oPlayerJump(a1)			; Clear player jump flag
	
	bset	#3,oFlags(a0)			; Mark as being stood on
	bne.s	.StandOn			; If it was already set, branch
	
	cmpi.b	#$2B,oAnim(a1)			; Is the player giving up from boredom?
	bne.s	.NotGivingUp			; If not, branch
	bclr	#3,oFlags(a0)			; Stop being stood on
	bra.w	GetOffObject

.NotGivingUp:
	bclr	#4,oFlags(a1)			; Clear player roll jump flag
	bclr	#2,oFlags(a1)			; Clear player roll flag
	beq.s	.StandOn			; If it wasn't set, branch
	
	tst.b	miniSonic			; Is the player miniature?
	beq.s	.NotMini			; If not, branch
	move.b	#$A,oYRadius(a1)		; Restore miniature hitbox size
	move.b	#5,oXRadius(a1)
	subq.w	#2,oY(a1)
	bra.s	.SetWalk

.NotMini:
	move.b	#$13,oYRadius(a1)		; Restore hitbox size
	move.b	#9,oXRadius(a1)
	subq.w	#5,oY(a1)

.SetWalk:
	move.b	#0,oAnim(a1)			; Set to walking animation

.StandOn:
	bset	#3,oFlags(a1)			; Mark player as standing on object
	beq.s	.SetInteract			; If it wasn't set, branch

	moveq	#0,d0				; Get object the player is standing on
	move.b	oPlayerStandObj(a1),d0
	if oSize=$40
		lsl.w	#6,d0
	else
		mulu.w	#oSize,d0
	endif
	addi.l	#objects&$FFFFFF,d0
	cmpa.w	d0,a0				; Is it us?
	beq.s	.End				; If so, branch
	movea.l	d0,a2				; If not, make the player stop standing on that
	bclr	#3,oFlags(a2)

.SetInteract:
	move.w	a0,d0				; Set object player is standing on to us
	subi.w	#objects,d0
	if oSize=$40
		lsr.w	#6,d0
	else
		divu.w	#oSize,d0
	endif
	andi.w	#$7F,d0
	move.b	d0,oPlayerStandObj(a1)
	
	move.b	#0,oAngle(a1)			; Reset player angle
	move.w	#0,oYVel(a1)			; Stop player's vertical movement
	
	cmpi.b	#$A,oID(a0)			; Is this a spring?
	bne.s	.SetInertia			; If not, branch
	cmpi.b	#2,oRoutine(a0)			; Is this spring facing upwards?
	beq.s	.ClearAirBit			; If so, branch

.SetInertia:
	move.w	oXVel(a1),oPlayerGVel(a1)	; Set ground velocity to horizontal velocity

.ClearAirBit:
	bclr	#1,oFlags(a1)			; Mark player on the ground

.End:
	rts

; -------------------------------------------------------------------------
; Handle solidity (bottom solid)
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Object slot
;	a1.l - Player object slot
; RETURNS:
;	d0.b - 0 - Left/right collision
;              1 - Top/bottom collision
; -------------------------------------------------------------------------

BtmSolidObject:
	move.b	#2,oSolidType(a0)		; Set as bottom solid
	bra.s	SolidObject
	
; -------------------------------------------------------------------------
; Handle solidity (top solid)
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Object slot
;	a1.l - Player object slot
; RETURNS:
;	d0.b - 0 - No top/bottom collision
;              1 - Top/bottom collision
; -------------------------------------------------------------------------

TopSolidObject:
	move.b	#1,oSolidType(a0)		; Set as top solid

; -------------------------------------------------------------------------
; Handle solidity
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Object slot
;	a1.l - Player object slot
; RETURNS:
;	d0.b - 0 - No top/bottom collision
;              1 - Top/bottom collision
; -------------------------------------------------------------------------

SolidObject:
	cmpi.b	#$17,oAnim(a1)			; Is the player drowning?
	beq.w	.GetOff				; If so, branch
	btst	#6,oPlayerCtrl(a1)		; Is the player invisible?
	bne.w	.GetOff				; If so, branch
	cmpi.b	#6,oRoutine(a1)			; Is the player dead?
	bcc.w	.GetOff				; If so, branch
	tst.b	oID(a1)				; Does the player even exist?
	beq.w	.GetOff				; If not, branch
	tst.b	oSprFlags(a0)			; Are we offscreen?
	bpl.w	.GetOff				; If so, branch
	tst.b	debugMode			; Is debug mode enabled?
	bne.w	.GetOff				; If so, branch
	
	move.b	oWidth(a0),d1			; Get collision check width
	ext.w	d1				; (Object X radius + 1 + Player X radius)
	addi.w	#9+1,d1
	
	move.w	oX(a1),d0			; Is the player left of us?
	sub.w	oX(a0),d0
	add.w	d1,d0
	bmi.w	.GetOff				; If so, branch
	move.w	d1,d2				; Is the player right of us?
	add.w	d2,d2
	cmp.w	d2,d0
	bcc.w	.GetOff				; If so, branch
	
	cmpi.b	#$2B,oAnim(a1)			; Is the player giving up from boredom?
	bne.s	.NotGivingUp			; If not, branch
	btst	#3,oFlags(a0)			; Are we being stood on?
	bne.s	.CheckYRange			; If so, branch
	bra.w	.GetOff

.NotGivingUp:
	cmpi.b	#1,oSolidType(a0)		; Are we top solid?
	bne.s	.CheckYRange			; If not, branch
	tst.w	oYVel(a1)			; How is the player moving vertically?
	beq.s	.CheckYRange			; If not at all, branch
	bmi.w	.GetOff				; If they're moving up, branch

.CheckYRange:
	move.b	oYRadius(a0),d2			; Get collision check height
	ext.w	d2				; (Object Y radius + 2 + Player Y radius)
	move.b	oYRadius(a1),d3
	ext.w	d3
	add.w	d2,d3
	addq.w	#2,d3
	
	move.w	oY(a1),d2			; Is the player above us?
	sub.w	oY(a0),d2
	add.w	d3,d2
	bmi.w	.GetOff				; If so, branch
	move.w	d3,d4				; Is the player below us?
	add.w	d4,d4
	cmp.w	d4,d2
	bcc.w	.GetOff				; If so, branch
	
	move.w	d0,d4				; Get horizontal distance inside object
	cmp.w	d0,d1
	bcc.s	.GotDistToHEdge
	add.w	d1,d1
	sub.w	d1,d0
	move.w	d0,d4
	neg.w	d4

.GotDistToHEdge:
	move.w	d2,d5				; Get vertical distance inside object
	cmp.w	d2,d3
	bcc.s	.GotDistToVEdge
	add.w	d3,d3
	sub.w	d3,d2
	move.w	d2,d5
	neg.w	d5

.GotDistToVEdge:
	cmp.w	d4,d5				; Is the player horizontally inside the object more?
	bcs.w	.CollideVert			; If so, branch
	
	cmpi.b	#1,oSolidType(a0)		; Are we top solid?
	beq.w	.GetOff				; If so, branch
	
	cmpi.b	#$A,oID(a0)			; Is this a spring?
	bne.s	.NotSpring			; If not, branch
	btst	#1,oFlags(a1)			; Is the player in the air?
	bne.w	.GetOff				; If so, branch

.NotSpring:
	cmpi.b	#4,d5				; Is the player in deep enough vertically?
	bls.w	.GetOff				; If not, branch

; -------------------------------------------------------------------------

.CollideHoriz:
	bsr.w	PushObject			; Have the player push against us
	
	move.l	d0,-(sp)			; Make it so the player isn't standing on us
	bsr.w	GetOffObject
	clr.b	oSolidType(a0)
	move.l	(sp)+,d0
	
	sub.w	d0,oX(a1)			; Move the player outside of us
	tst.w	d0				; Was the player right of us?
	bmi.s	.PlayerRight			; If so, branch
	
.PlayerLeft:
	tst.w	oXVel(a1)			; How was the player moving horizontally?
	beq.s	.StopPush			; If not at all, branch
	bpl.s	.HaltOnX			; If they were moving right, branch
	bra.s	.StopPush

.PlayerRight:
	tst.w	oXVel(a1)			; How was the player moving horizontally?
	beq.s	.StopPush			; If not at all, branch
	bpl.s	.StopPush			; If they were moving right, branch

.HaltOnX:
	bsr.w	CheckWallCrush			; Check crushing between us and a wall
	btst	#1,oFlags(a1)			; Is the player in the air?
	bne.s	.ClearXSpd			; If so, branch
	bset	#5,oFlags(a1)			; Set push flags
	bset	#5,oFlags(a0)
	move.w	#0,oPlayerGVel(a1)		; Stop the player on the ground

.ClearXSpd:
	move.w	#0,oXVel(a1)			; Stop the player horizontally
	
	moveq	#0,d0				; Collided
	rts

.StopPush:
	bsr.w	StopObjPush			; Stop pushing
	bsr.w	CheckWallCrush			; Check crushing between us and a wall
	bclr	#5,oFlags(a1)			; Clear push flags
	bclr	#5,oFlags(a0)
	
	moveq	#0,d0				; Collided
	rts

; -------------------------------------------------------------------------

.CollideVert:
	cmpi.b	#$19,oID(a0)			; Is this a monitor?
	bne.s	.NotMonitor			; If not, branch
	btst	#2,oFlags(a1)			; Is the player rolling?
	bne.w	.GetOff				; If so, branch

.NotMonitor:
	move.b	oYRadius(a0),d0			; Get collision height
	ext.w	d0
	move.b	oYRadius(a1),d1
	ext.w	d1
	add.w	d0,d1
	tst.w	d2				; Check if the player is above or below us
	beq.s	.PlayerAbove			; If they are at our level, consider them above us
	bmi.w	.PlayerBelow			; If they are below us, branch

.PlayerAbove:
	cmpi.b	#$2B,oAnim(a1)			; Is the player giving up from boredom?
	beq.s	.MoveOnObject			; If so, branch
	tst.w	oYVel(a1)			; How is the player moving vertically?
	beq.s	.MoveOnObject			; If not at all, branch
	bmi.w	.GetOff				; If they are moving up, branch

.MoveOnObject:
	move.w	oY(a0),oY(a1)			; Move the player on top of us
	sub.w	d1,oY(a1)
	
	moveq	#0,d1				; Move the player with us horizontally
	move.w	oXVel(a0),d1
	ext.l	d1
	asl.l	#8,d1
	move.l	oX(a1),d0
	add.l	d1,d0
	move.l	d0,oX(a1)
	
	move.b	#$C0,d0				; Check wall to the right
	tst.w	oXVel(a0)
	beq.s	.MoveY				; If the player is not moving, don't check walls
	bpl.s	.CheckWall			; If they are moving right, branch
	neg.b	d0				; If they are moving left, check wall to the left instead

.CheckWall:
	movem.l	a0-a1,-(sp)			; Check wall collision
	movea.l	a1,a0
	jsr	Player_CalcRoomInFront
	movem.l	(sp)+,a0-a1
	tst.w	d1
	bpl.s	.MoveY				; If the player did not touch a wall, branch
	
	tst.w	oXVel(a0)			; Was the player moving right?
	bpl.s	.MoveOutOfWall			; If so, branch
	neg.w	d1				; If not, flip distance inside wall to properly move them out

.MoveOutOfWall:
	add.w	d1,oX(a1)			; Move player out of wall

.MoveY:
	moveq	#0,d1				; Move the player with us vertically
	move.w	oYVel(a0),d1
	ext.l	d1
	asl.l	#8,d1
	move.l	oY(a1),d0
	add.l	d1,d0
	move.l	d0,oY(a1)
	
	cmpi.b	#$A,oID(a0)			; Is this a spring?
	beq.s	.StandOn			; If so, branch
	
.CheckFloor:
	tst.w	oYVel(a0)			; Are we moving up?
	bmi.s	.CheckCeiling			; If so, branch
	
	movem.l	a0-a1,-(sp)			; Check floor collision
	movea.l	a1,a0
	jsr	Player_CheckFloor
	movem.l	(sp)+,a0-a1
	tst.w	d1
	bpl.s	.CheckCeiling			; If the player did not touch the floor, branch
	add.w	d1,oY(a1)			; Move the player to the floor instead
	bra.w	.GetOff

.CheckCeiling:
	tst.w	oYVel(a0)			; Are we moving down?
	bpl.s	.StandOn			; If so, branch
	
	movem.l	a0-a1,-(sp)			; Check ceiling collision
	movea.l	a1,a0
	jsr	Player_GetCeilDist
	movem.l	(sp)+,a0-a1
	tst.w	d1
	bpl.s	.StandOn			; If the player did not touch the ceiling, branch
	
	movem.l	a0-a1,-(sp)			; Crush the player between us and the ceiling
	movea.l	a1,a0
	jsr	KillPlayer
	movem.l	(sp)+,a0-a1
	bra.s	.GetOff

.StandOn:
	bsr.w	StandOnObject			; Make the player stand on us
	
	moveq	#1,d0				; Collided
	rts

; -------------------------------------------------------------------------

.PlayerBelow:
	cmpi.b	#1,oSolidType(a0)		; Are we top solid?
	beq.s	.GetOff				; If so, branch
	cmpi.b	#9,oID(a0)			; Is this a spinning disc?
	beq.s	.GetOff				; If so, branch
	
	cmpi.b	#$A,oID(a0)			; Is this a spring?
	bne.s	.CheckCrushFloor		; If not, branch
	
	cmpi.b	#2,oSolidType(a0)		; Are we bottom solid?
	beq.s	.HitBottom			; If so, branch
	btst	#1,oSprFlags(a0)		; Are we vertically flipped?
	bne.s	.HitBottom			; If so, branch
	bra.s	.GetOff

.CheckCrushFloor:
	btst	#1,oFlags(a1)			; Is the player in the air?
	bne.s	.HitBottom			; If so, branch
	
	tst.w	oYVel(a0)			; How is the player moving vertically?
	beq.s	.HitBottom			; If not at all, branch
	bmi.s	.HitBottom			; If they are moving up, branch
	
	movem.l	a0-a1,-(sp)			; Crush the player between us and the floor
	movea.l	a1,a0
	jsr	KillPlayer
	movem.l	(sp)+,a0-a1

.HitBottom:
	sub.w	d2,oY(a1)			; Move the player below us
	move.w	#0,oYVel(a1)			; Stop the player vertically
	
	bsr.w	StopObjPush			; Make it so the player isn't on us
	bsr.w	GetOffObject
	clr.b	oSolidType(a0)
	
	moveq	#1,d0				; Collided
	rts

.GetOff:
	bsr.w	StopObjPush			; Make it so the player isn't on us
	bsr.w	GetOffObject
	clr.b	oSolidType(a0)
	
	moveq	#0,d0				; No collision
	rts

; -------------------------------------------------------------------------
; Check for crushing the player between an object and a wall
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Object slot
;	a1.l - Player object slot
; -------------------------------------------------------------------------

CheckWallCrush:
	tst.w	oXVel(a0)			; Is the player moving horizontally?
	beq.s	.End				; If not, branch
	cmpi.b	#$A,oID(a0)			; Is this a spring?
	beq.s	.End				; If not, branch
	
	move.b	#$C0,d0				; Check wall to the right
	tst.w	oXVel(a0)			; Is the player moving right?
	bpl.s	.CheckWall			; If so, branch
	neg.b	d0				; If they are moving left, check wall to the left instead

.CheckWall:
	movem.l	a0-a1,-(sp)			; Check wall collision
	movea.l	a1,a0
	jsr	Player_CalcRoomInFront
	movem.l	(sp)+,a0-a1
	tst.w	d1
	bpl.s	.End				; If the player did not touch a wall, branch
	
	movem.l	a0-a1,-(sp)			; Crush the player
	movea.l	a1,a0
	jsr	KillPlayer
	movem.l	(sp)+,a0-a1

.End:
	rts

; -------------------------------------------------------------------------
; Make the player push on an object
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Object slot
;	a1.l - Player object slot
; -------------------------------------------------------------------------

PushObject:
	cmpi.b	#$A,oID(a0)			; Is this a spring?
	bne.s	.NotSpring			; If not, branch
	move.b	#0,oPlayerPushObj(a1)		; Don't push on springs
	rts

.NotSpring:
	moveq	#0,d1				; Get object the player is pushing
	move.b	oPlayerPushObj(a1),d1
	beq.s	.SetPushObj
	if oSize=$40
		lsl.w	#6,d1
	else
		mulu.w	#oSize,d1
	endif
	addi.l	#objects&$FFFFFF,d1
	cmpa.w	d1,a0				; Is it us?
	beq.s	.End				; If so, branch
	movea.l	d1,a2
	
	tst.w	oXVel(a0)			; Are we moving horizontally?
	bne.s	.MayCrush			; If so, branch
	tst.w	oXVel(a2)			; Is the other object moving horizontally?
	beq.s	.End				; If so, branch

.MayCrush:
	move.w	oX(a1),d1			; Is the player right of us?
	cmp.w	oX(a0),d1
	bcc.s	.CheckRight			; If so, branch
	
.CheckLeft:
	cmp.w	oX(a2),d1			; Is the player left of the other object?
	bcs.s	.End				; If so, branch
	bra.s	.Crush				; If not, crush the player

.CheckRight:
	cmp.w	oX(a2),d1			; Is the player right of the other object?
	bcc.s	.End				; If so, branch

.Crush:
	cmpi.b	#$15,oID(a0)			; Is this a flower capsule?
	beq.s	.End				; If so, branch
	
	movem.l	d0/a0-a1,-(sp)			; Crush the player
	movea.l	a1,a0
	jsr	KillPlayer
	movem.l	(sp)+,d0/a0-a1
	rts

.SetPushObj:
	move.w	a0,d1				; Make the player push on us
	subi.w	#objects,d1
	lsr.w	#6,d1
	andi.w	#$7F,d1
	move.b	d1,oPlayerPushObj(a1)

.End:
	rts

; -------------------------------------------------------------------------
; Stop making the player push on an object
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Object slot
;	a1.l - Player object slot
; -------------------------------------------------------------------------

StopObjPush:
	moveq	#0,d1				; Get object the player is pushing
	move.b	oPlayerPushObj(a1),d1
	beq.s	.End
	if oSize=$40
		lsl.w	#6,d1
	else
		mulu.w	#oSize,d1
	endif
	addi.l	#objects&$FFFFFF,d1
	cmpa.w	d1,a0				; Is it us?
	bne.s	.End				; If not, branch
	
	move.b	#0,oPlayerPushObj(a1)		; Make the player stop pushing on us

.End:
	rts

; -------------------------------------------------------------------------
