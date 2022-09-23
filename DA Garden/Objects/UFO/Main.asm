; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; DA Garden UFO object
; -------------------------------------------------------------------------

ObjUFO:
	lea	.Index,a1			; Run routine
	jmp	RunObjRoutine

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjUFO_Init-.Index
	dc.w	ObjUFO_NextMode-.Index
	dc.w	ObjUFO_Float-.Index
	dc.w	ObjMoveToDest-.Index

; -------------------------------------------------------------------------

ObjUFO_Init:
	addi.w	#$4000,oTile(a0)		; Set to sprite palette
	move.w	#0,oAnimFrame(a0)		; Reset animation
	lea	MapSpr_UFO(pc),a1
	move.l	a1,oMap(a0)
	move.w	2(a1),oAnimTime(a0)
	clr.w	oXOffset(a0)			; Reset position offset
	clr.w	oYOffset(a0)
	
	jsr	Random(pc)			; Set mode counter
	andi.l	#$7FFF,d0
	move.w	d0,d1
	divs.w	#5,d0
	swap	d0
	addq.b	#1,d0
	move.b	d0,oModeCnt(a0)
	
	divs.w	#64,d1				; Set float time
	swap	d1
	move.b	d1,oTimer2(a0)
	
	move.w	#2,oRoutine(a0)			; Set to float routine
	rts

; -------------------------------------------------------------------------

ObjUFO_NextMode:
	cmpi.b	#3,oModeCnt(a0)			; Should we stop?
	bne.s	.NoStop				; If not, branch
	bsr.w	ObjUFO_Stop			; Stop
	bra.s	.ChkTimer

.NoStop:
	bsr.w	GetObjDestX			; Get destination X position
	bsr.w	ObjUFO_StartMoving		; Start moving

.ChkTimer:
	tst.b	oModeCnt(a0)			; Has the mode counter run out?
	blt.s	.End				; If so, branch
	subq.b	#1,oModeCnt(a0)			; Decrement it

.End:
	rts

; -------------------------------------------------------------------------

GetObjDestX:
	jsr	Random(pc)			; Get random horizontal distance
	andi.l	#$7FFF,d0
	divs.w	#32,d0
	swap	d0
	addi.w	#64,d0
	
	btst	#7,oFlags(a0)			; Are we facing right?
	beq.s	.RightDest			; If so, branch
	move.w	oX(a0),d1			; Get distance from the left
	sub.w	d0,d1
	bra.s	.SetDestX

.RightDest:
	move.w	oX(a0),d1			; Get distance from the right
	add.w	d0,d1

.SetDestX:
	move.w	d1,oDestX(a0)			; Set destination X position
	rts

; -------------------------------------------------------------------------

ObjUFO_Stop:
	move.w	#2,oRoutine(a0)			; Set to float routine
	move.l	#0,oXVel(a0)			; Stop movement
	move.l	#0,oYVel(a0)
	
	lea	MapSpr_UFO(pc),a1		; Set normal animation
	move.l	a1,oMap(a0)
	move.w	#0,oAnimFrame(a0)
	
	move.b	#24,oTimer2(a0)			; Set time
	rts

; -------------------------------------------------------------------------

ObjUFO_StartMoving:
	move.w	#3,oRoutine(a0)			; Set to move routine
	
	jsr	Random(pc)			; Set X velocity
	andi.l	#$7FFF,d0
	move.w	d0,d1
	divs.w	#64,d0
	clr.w	d0
	asr.l	#4,d0
	addi.l	#$20000,d0
	move.l	d0,oXVel(a0)
	btst	#3,oFlags(a0)
	bne.s	.GetYVel
	neg.l	oXVel(a0)

.GetYVel:
	move.l	oYVel(a0),d7			; Set Y velocity
	divs.w	#96,d1
	clr.w	d1
	asr.l	#4,d1
	move.l	d1,oYVel(a0)
	addq.w	#5,oYVel(a0)
	
	jsr	Random(pc)			; Get random destination Y position
	andi.l	#$7FFF,d0
	divs.w	#56,d0
	swap	d0
	tst.l	d7				; Are we moving down?
	ble.s	.MoveDown			; If so, branch
	
.MoveUp:
	neg.l	oYVel(a0)			; Move up
	addi.w	#32,d0				; Set destination Y position
	move.w	d0,oDestY(a0)
	
	lea	MapSpr_UFOUp(pc),a1		; Set upwards animation
	move.l	a1,oMap(a0)
	move.w	#0,oAnimFrame(a0)
	bra.s	.End

.MoveDown:
	addi.w	#160,d0				; Set destination Y position
	move.w	d0,oDestY(a0)
	
	lea	MapSpr_UFODown(pc),a1		; Set downwards animation
	move.l	a1,oMap(a0)
	move.w	#0,oAnimFrame(a0)

.End:
	rts

; -------------------------------------------------------------------------

ObjMoveToDest:
	bsr.w	ChkObjOffscreen			; Are we offscreen?
	bne.w	DelObjFromGroup			; If so, delete object
	
	move.l	oXVel(a0),d0			; Get X velocity
	tst.b	trackSelFlags.w			; Is track selection active?
	beq.s	.MoveX				; If not, branch
	asl.l	#3,d0				; If, so, go 8 times as fast

.MoveX:
	add.l	d0,oX(a0)			; Move X
	
	move.w	oX(a0),d0			; Get current X position
	tst.l	oXVel(a0)			; Are we moving right?
	bge.s	.ChkRightDestX			; If so, branch
	
.ChkLeftDestX:
	cmp.w	oDestX(a0),d0			; Are we at the destination?
	ble.s	.NextMode			; If so, branch
	bra.s	.MoveY

.ChkRightDestX:
	cmp.w	oDestX(a0),d0			; Are we at the destination?
	blt.s	.MoveY				; If not, branch

.NextMode:
	tst.b	oModeCnt(a0)			; Are there any more modes left to set?
	blt.s	.MoveY				; If not, branch
	move.w	#1,oRoutine(a0)			; Set to next mode

.MoveY:
	move.l	oYVel(a0),d1			; Move Y
	add.l	d1,oY(a0)
	
	move.w	oY(a0),d1			; Get current Y position
	tst.l	oYVel(a0)			; Are we moving down?
	bge.s	.ChkBtmDestY			; If so, branch
	
.ChkTopDestY:
	cmp.w	oDestY(a0),d1			; Are we at the destination?
	ble.s	.NextMode2			; If so, branch
	bra.s	.End

.ChkBtmDestY:
	cmp.w	oDestY(a0),d1			; Are we at the destination?
	blt.s	.End				; If not, branch

.NextMode2:
	tst.b	oModeCnt(a0)			; Are there any more modes left to set?
	blt.s	.End				; If not, branch
	move.w	#1,oRoutine(a0)			; Set to next mode

.End:
	rts

; -------------------------------------------------------------------------

ObjUFO_Float:
	tst.l	oXVel(a0)			; Are we moving?
	bne.s	.SlowFloat			; If so, branch
	move.w	#$48,oFloatSpeed(a0)		; Float up and down quickly
	bra.s	.Move

.SlowFloat:
	move.w	#$28,oFloatSpeed(a0)		; Float up and down slowly

.Move:
	bsr.w	ObjMoveFloat			; Move
	subq.b	#1,oTimer2(a0)			; Decrement time
	bgt.s	.End				; If it hasn't run out, branch
	move.w	#1,oRoutine(a0)			; Set to next mode

.End:
	rts

; -------------------------------------------------------------------------
