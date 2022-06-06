; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Checkpoint object
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Save data at a checkpoint
; -------------------------------------------------------------------------

ObjCheckpoint_SaveData:				; Save some values
	move.b	resetLevelFlags,savedResetLvlFlags
	move.w	objPlayerSlot+oX.w,savedX
	move.w	objPlayerSlot+oY.w,savedY
	move.b	waterRoutine.w,savedWaterRout
	move.w	bottomBound.w,savedBtmBound
	move.w	cameraX.w,savedCamX
	move.w	cameraY.w,savedCamY
	move.w	cameraBgX.w,savedCamBgX
	move.w	cameraBgY.w,savedCamBgY
	move.w	cameraBg2X.w,savedCamBg2X
	move.w	cameraBg2Y.w,savedCamBg2Y
	move.w	cameraBg3X.w,savedCamBg3X
	move.w	cameraBg3Y.w,savedCamBg3Y
	move.w	waterHeight2.w,savedWaterHeight
	move.b	waterRoutine.w,savedWaterRout
	move.b	waterFullscreen.w,savedWaterFull

	move.l	levelTime,d0			; Move the level timer to 5:00 if we are past that
	cmpi.l	#$50000,d0
	bcs.s	.StoreTime
	move.l	#$50000,d0

.StoreTime:
	move.l	d0,savedTime

	move.b	miniSonic,savedMiniSonic
	rts

; -------------------------------------------------------------------------
; Checkpoint object
; -------------------------------------------------------------------------

oChkPntBallX		EQU	oVar2A		; Ball X origin
oChkPntBallY		EQU	oVar2C		; Ball Y origin
oChkPntActive		EQU	oVar2E		; Activated flag
oChkPntParent		EQU	oVar30		; Parent object
oChkPntBallAngle	EQU	oVar34		; Ball angle

; -------------------------------------------------------------------------

ObjCheckpoint:
	moveq	#0,d0				; Run object routine
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	jsr	DrawObject			; Draw sprite
	jmp	CheckObjDespawnTime		; Check if we should despawn

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjCheckpoint_Init-.Index	; Initialization
	dc.w	ObjCheckpoint_Main-.Index	; Main
	dc.w	ObjCheckpoint_Ball-.Index	; Ball main
	dc.w	ObjCheckpoint_Animate-.Index	; Animation

; -------------------------------------------------------------------------
; Checkpoint initialization routine
; -------------------------------------------------------------------------

ObjCheckpoint_Init:
	addq.b	#2,oRoutine(a0)			; Advance routine

	move.l	#MapSpr_Checkpoint,oMap(a0)	; Set mappings
	move.w	#$6CB,oTile(a0)			; Set base tile
	move.b	#4,oRender(a0)			; Set render flags
	move.b	#8,oWidth(a0)			; Set width
	move.b	#$18,oYRadius(a0)		; Set Y radius
	move.b	#4,oPriority(a0)		; Set priority

	move.b	lastCheckpoint,d0		; Has a later checkpoint already been activated?
	cmp.b	oSubtype(a0),d0
	bcs.s	.Unactivated			; If not, branch

	move.b	#1,oChkPntActive(a0)		; Mark as activated
	bra.s	.GenBall			; Continue initialization

.Unactivated:
	move.b	#$E3,oColType(a0)		; Enable collision

.GenBall:
	jsr	FindObjSlot			; Find a free object slot
	bne.s	.Delete				; If one was not found, don't bother having the checkpoint loaded at all

	move.b	#$13,oID(a1)			; Load the checkpoint ball object
	addq.b	#4,oRoutine(a1)			; Set ball routine to the main ball routine
	tst.b	oChkPntActive(a0)		; Were we already activated?
	beq.s	.Unactivated2			; If not, branch
	addq.b	#2,oRoutine(a1)			; Set ball routine to just animate

.Unactivated2:
	move.l	#MapSpr_Checkpoint,oMap(a1)	; Set ball mappings
	move.w	#$6CB,oTile(a1)			; Set ball base tile
	move.b	#4,oRender(a1)			; Set ball render flags
	move.b	#8,oWidth(a1)			; Set ball width
	move.b	#8,oYRadius(a1)			; Set ball Y radius
	move.b	#3,oPriority(a1)		; Set ball priority
	move.b	#1,oMapFrame(a1)		; Set ball sprite frame
	move.l	a0,oChkPntParent(a1)		; Set ball parent object to us

	move.w	oX(a0),oX(a1)			; Set ball position to our position
	move.w	oY(a0),oY(a1)
	subi.w	#32,oY(a1)			; Offset ball Y position up by 32 pixels

	move.w	oX(a0),oChkPntBallX(a1)		; Set ball center position
	move.w	oY(a0),oChkPntBallY(a1)
	subi.w	#32-8,oChkPntBallY(a1)
	rts

.Delete:
	jmp	DeleteObject			; Delete ourselves

; -------------------------------------------------------------------------
; Main checkpoint routine
; -------------------------------------------------------------------------

ObjCheckpoint_Main:
	tst.b	oChkPntActive(a0)		; Have we been activated?
	bne.s	.End				; If so, branch
	tst.b	oColStatus(a0)			; Has the player touched us yet?
	beq.s	.End				; If not, branch

	clr.b	oColType(a0)			; Disable collision
	move.b	#1,oChkPntActive(a0)		; Mark as activated
	move.b	oSubtype(a0),lastCheckpoint	; Set current checkpoint ID to ours

	move.b	#1,resetLevelFlags		; Mark checkpoint as active in the level
	bsr.w	ObjCheckpoint_SaveData		; Save level data at this point

	move.w	#$AE,d0				; Play checkpoint sound
	jmp	PlayFMSound

.End:
	rts

; -------------------------------------------------------------------------
; Main checkpoint ball routine
; -------------------------------------------------------------------------

ObjCheckpoint_Ball:
	tst.b	oChkPntActive(a0)		; Have we been activated?
	bne.s	.Spin				; If not, branch

	movea.l	oChkPntParent(a0),a1		; Has the main checkpoint object been touched by the player?
	tst.b	oChkPntActive(a1)
	beq.s	.End				; If not, branch

	move.b	#1,oChkPntActive(a0)		; Mark as activated

.Spin:
	addq.b	#8,oChkPntBallAngle(a0)		; Increment angle

	moveq	#0,d0				; Get sine and cosine of our angle
	move.b	oChkPntBallAngle(a0),d0
	jsr	CalcSine

	muls.w	#8,d0				; Get X offset (center X + (sin(angle) * 8))
	lsr.l	#8,d0
	move.w	oChkPntBallX(a0),oX(a0)
	add.w	d0,oX(a0)

	muls.w	#-8,d1				; Get Y offset (center Y + (cos(angle) * -8))
	lsr.l	#8,d1
	move.w	oChkPntBallY(a0),oY(a0)
	add.w	d1,oY(a0)

	tst.b	oChkPntBallAngle(a0)		; Have we fully spun around?
	bne.s	.End				; If not, branch
	addq.b	#2,oRoutine(a0)			; Set routine to just animate now

.End:
	rts

; -------------------------------------------------------------------------
; Checkpoint animation routine
; -------------------------------------------------------------------------

ObjCheckpoint_Animate:
	lea	Ani_Checkpoint,a1		; Animate sprite
	bra.w	AnimateObject
	
; -------------------------------------------------------------------------
