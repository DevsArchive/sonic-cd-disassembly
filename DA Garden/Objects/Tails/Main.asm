; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; DA Garden Tails object
; -------------------------------------------------------------------------

ObjTails:
	lea	.Index,a1			; Run routine
	jmp	RunObjRoutine

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjTails_Init-.Index
	dc.w	ObjTails_NextMode-.Index
	dc.w	ObjTails_Float-.Index
	dc.w	ObjMoveToDest-.Index

; -------------------------------------------------------------------------

ObjTails_Init:
	addi.w	#$4000,oTile(a0)		; Set to sprite palette
	move.w	#0,oAnimFrame(a0)		; Reset animation
	lea	MapSpr_Tails(pc),a1
	move.l	a1,oMap(a0)
	move.w	2(a1),oAnimTime(a0)
	
	jsr	Random(pc)			; Set mode counter
	andi.l	#$7FFF,d0
	move.w	d0,d1
	divs.w	#5,d0
	swap	d0
	addq.b	#1,d0
	move.b	d0,oModeCnt(a0)
	
	divs.w	#48,d1				; Set timer
	swap	d1
	move.b	d1,oTimer2(a0)
	
	move.w	#2,oRoutine(a0)			; Set to float routine
	rts

; -------------------------------------------------------------------------

ObjTails_NextMode:
	bsr.w	GetObjDestX			; Get destination X position
	cmpi.b	#3,oModeCnt(a0)			; Should we move vertically?
	bne.s	.MoveVerti			; If so, branch
	bsr.w	ObjTails_MoveStraight		; Move straighr
	bra.s	.ChkTimer

.MoveVerti:
	bsr.w	ObjTails_MoveVerti		; Move vertically

.ChkTimer:
	tst.b	oModeCnt(a0)			; Has the mode counter run out?
	blt.s	.End				; If so, branch
	subq.b	#1,oModeCnt(a0)			; Decrement it

.End:
	rts

; -------------------------------------------------------------------------

ObjTails_MoveStraight:
	move.l	#$20000,oXVel(a0)		; Move straight ahead
	move.l	#0,oYVel(a0)
	move.w	#0,oAnimFrame(a0)		; Set straight animation
	lea	MapSpr_Tails(pc),a3
	move.l	a3,oMap(a0)
	
	btst	#7,oFlags(a0)			; Are we facing right?
	beq.s	.End				; If so, branch
	neg.l	oXVel(a0)			; Move left
	neg.l	oYVel(a0)

.End:
	move.b	#24,oTimer2(a0)			; Set timer
	move.w	#2,oRoutine(a0)			; Set to float routine
	rts

; -------------------------------------------------------------------------

ObjTails_MoveVerti:
	move.w	#3,oRoutine(a0)			; Set to move routine
	
	jsr	Random(pc)			; Set X velocity
	andi.l	#$7FFF,d0
	move.w	d0,d1
	divs.w	#16,d0
	clr.w	d0
	asr.l	#4,d0
	addi.l	#$20000,d0
	move.l	d0,oXVel(a0)
	btst	#7,oFlags(a0)
	beq.s	.GetYVel
	neg.l	oXVel(a0)

.GetYVel:
	move.l	oYVel(a0),d7			; Set Y velocity
	divs.w	#$28,d1
	clr.w	d1
	asr.l	#4,d1
	move.l	d1,oYVel(a0)
	addq.w	#1,oYVel(a0)
	
	jsr	Random(pc)			; Get random destination Y position
	andi.l	#$7FFF,d0
	divs.w	#56,d0
	swap	d0
	tst.l	d7				; Are we moving?
	bne.s	.CheckCurYDir			; If so, branch
	cmpi.w	#100,oY(a0)			; Are we below the center?
	bgt.s	.MoveUp				; If so, branch
	bra.s	.MoveDown			; Move down

.CheckCurYDir:
	ble.s	.MoveDown			; If we are moving up, then move down instead

.MoveUp:
	neg.l	oYVel(a0)			; Move up
	addi.w	#32,d0				; Set destination Y position
	move.w	d0,oDestY(a0)
	
	lea	MapSpr_TailsUp(pc),a1		; Set upwards animation
	move.l	a1,oMap(a0)
	move.w	#0,oAnimFrame(a0)
	bra.s	.End

.MoveDown:
	addi.w	#160,d0				; Set destination Y position
	move.w	d0,oDestY(a0)
	
	lea	MapSpr_TailsDown(pc),a1		; Set downwards animation
	move.l	a1,oMap(a0)
	move.w	#0,oAnimFrame(a0)

.End:
	rts

; -------------------------------------------------------------------------

ObjTails_Float:
	bsr.w	ObjMoveFloat			; Move
	subq.b	#1,oTimer2(a0)			; Decrement float time
	bgt.s	.End				; If it hasn't run out, branch
	move.w	#1,oRoutine(a0)			; Set to next mode

.End:
	rts

; -------------------------------------------------------------------------
