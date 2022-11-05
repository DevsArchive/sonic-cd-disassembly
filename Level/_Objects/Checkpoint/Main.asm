; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Checkpoint object
; -------------------------------------------------------------------------

oChkBallX	EQU	oVar2A			; Ball X origin
oChkBallY	EQU	oVar2C			; Ball Y origin
oChkActive	EQU	oVar2E			; Activated flag
oChkParent	EQU	oVar30			; Parent object
oChkBallAngle	EQU	oVar34			; Ball angle

; -------------------------------------------------------------------------
; Save data at a checkpoint
; -------------------------------------------------------------------------

ObjCheckpoint_SaveData:
	move.b	spawnMode,savedSpawnMode	; Save some values
	move.w	objPlayerSlot+oX.w,savedX
	move.w	objPlayerSlot+oY.w,savedY
	move.b	waterRoutine.w,savedWaterRoutine
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
	move.b	waterRoutine.w,savedWaterRoutine
	move.b	waterFullscreen.w,savedWaterFull

	move.l	time,d0				; Move the time to 5:00 if we are past that
	cmpi.l	#(5<<16)|(0<<8)|0,d0
	bcs.s	.StoreTime
	move.l	#(5<<16)|(0<<8)|0,d0

.StoreTime:
	move.l	d0,savedTime

	move.b	miniSonic,savedMiniSonic
	rts

; -------------------------------------------------------------------------
; Checkpoint object
; -------------------------------------------------------------------------

ObjCheckpoint:
	moveq	#0,d0				; Run routine
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	jsr	DrawObject			; Draw sprite
	jmp	CheckObjDespawn			; Check if we should despawn

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjCheckpoint_Init-.Index
	dc.w	ObjCheckpoint_Main-.Index
	dc.w	ObjCheckpoint_Ball-.Index
	dc.w	ObjCheckpoint_Animate-.Index

; -------------------------------------------------------------------------
; Initialization
; -------------------------------------------------------------------------

ObjCheckpoint_Init:
	addq.b	#2,oRoutine(a0)			; Advance routine

	move.l	#MapSpr_Checkpoint,oMap(a0)	; Set mappings
	move.w	#$6CB,oTile(a0)			; Set base tile
	move.b	#%00000100,oSprFlags(a0)	; Set sprite flags
	move.b	#8,oWidth(a0)			; Set width
	move.b	#$18,oYRadius(a0)		; Set Y radius
	move.b	#4,oPriority(a0)		; Set priority

	move.b	checkpoint,d0			; Has a later checkpoint been activated?
	cmp.b	oSubtype(a0),d0
	bcs.s	.Unactivated			; If not, branch

	move.b	#1,oChkActive(a0)		; Mark as activated
	bra.s	.GenBall			; Continue initialization

.Unactivated:
	move.b	#$C0|$23,oColType(a0)		; Enable collision

.GenBall:
	jsr	FindObjSlot			; Spawn checkpoint ball object
	bne.s	.Delete
	move.b	#$13,oID(a1)
	addq.b	#4,oRoutine(a1)			; Set ball routine to the main ball routine
	tst.b	oChkActive(a0)			; Were we already activated?
	beq.s	.Unactivated2			; If not, branch
	addq.b	#2,oRoutine(a1)			; Set ball routine to just animate

.Unactivated2:
	move.l	#MapSpr_Checkpoint,oMap(a1)	; Set mappings
	move.w	#$6CB,oTile(a1)			; Set base tile
	move.b	#%00000100,oSprFlags(a1)	; Set sprite flags
	move.b	#8,oWidth(a1)			; Set width
	move.b	#8,oYRadius(a1)			; Set Y radius
	move.b	#3,oPriority(a1)		; Set priority
	move.b	#1,oMapFrame(a1)		; Set sprite frame
	move.l	a0,oChkParent(a1)		; Set parent object

	move.w	oX(a0),oX(a1)			; Set position
	move.w	oY(a0),oY(a1)
	subi.w	#32,oY(a1)

	move.w	oX(a0),oChkBallX(a1)		; Set center position
	move.w	oY(a0),oChkBallY(a1)
	subi.w	#32-8,oChkBallY(a1)
	rts

.Delete:
	jmp	DeleteObject			; Delete ourselves

; -------------------------------------------------------------------------
; Main routine
; -------------------------------------------------------------------------

ObjCheckpoint_Main:
	tst.b	oChkActive(a0)			; Have we been activated?
	bne.s	.End				; If so, branch
	tst.b	oColStatus(a0)			; Has the player touched us yet?
	beq.s	.End				; If not, branch

	clr.b	oColType(a0)			; Disable collision
	move.b	#1,oChkActive(a0)		; Mark as activated
	move.b	oSubtype(a0),checkpoint		; Set checkpoint ID

	move.b	#1,spawnMode			; Spawn at checkpoint
	bsr.w	ObjCheckpoint_SaveData		; Save level data at this point

	move.w	#FM_CHECKPOINT,d0		; Play checkpoint sound
	jmp	PlayFMSound

.End:
	rts

; -------------------------------------------------------------------------
; Ball
; -------------------------------------------------------------------------

ObjCheckpoint_Ball:
	tst.b	oChkActive(a0)			; Have we been activated?
	bne.s	.Spin				; If not, branch

	movea.l	oChkParent(a0),a1		; Has the main checkpoint object been touched by the player?
	tst.b	oChkActive(a1)
	beq.s	.End				; If not, branch

	move.b	#1,oChkActive(a0)		; Mark as activated

.Spin:
	addq.b	#8,oChkBallAngle(a0)		; Increment angle

	moveq	#0,d0				; Get sine and cosine of our angle
	move.b	oChkBallAngle(a0),d0
	jsr	CalcSine

	muls.w	#8,d0				; Get X offset (center X + (sin(angle) * 8))
	lsr.l	#8,d0
	move.w	oChkBallX(a0),oX(a0)
	add.w	d0,oX(a0)

	muls.w	#-8,d1				; Get Y offset (center Y + (cos(angle) * -8))
	lsr.l	#8,d1
	move.w	oChkBallY(a0),oY(a0)
	add.w	d1,oY(a0)

	tst.b	oChkBallAngle(a0)		; Have we fully spun around?
	bne.s	.End				; If not, branch
	addq.b	#2,oRoutine(a0)			; Set routine to just animate now

.End:
	rts

; -------------------------------------------------------------------------
; Animation
; -------------------------------------------------------------------------

ObjCheckpoint_Animate:
	lea	Ani_Checkpoint,a1		; Animate sprite
	bra.w	AnimateObject
	
; -------------------------------------------------------------------------
