; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; DA Garden flicky object
; -------------------------------------------------------------------------

ObjFlicky:
	lea	.Index,a1			; Run routine
	jmp	RunObjRoutine

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjFlicky_Init-.Index
	dc.w	ObjFlicky_Normal-.Index
	dc.w	ObjFlicky_Slow-.Index
	dc.w	ObjFlicky_Glide-.Index

; -------------------------------------------------------------------------

ObjFlicky_Init:
	addi.w	#$4000,oTile(a0)		; Set to sprite palette line
	move.w	#0,oAnimFrame(a0)		; Reset animation
	clr.w	oXOffset(a0)			; Reset position offset
	clr.w	oYOffset(a0)
	btst	#1,oFlags(a0)			; Are we gliding?
	beq.s	.CheckSlow			; If not, branch
	move.w	#3,oRoutine(a0)			; Set to gliding routine
	rts

.CheckSlow:
	btst	#0,oFlags(a0)			; Are we going slow?
	beq.s	.Normal				; If not, branch
	move.w	#2,oRoutine(a0)			; Set to slow routine
	rts

.Normal:
	move.w	#1,oRoutine(a0)			; Set to normal routine
	rts

; -------------------------------------------------------------------------

ObjFlicky_Normal:
	bsr.w	ChkObjOffscreen			; Are we offscreen?
	bne.w	DelObjFromGroup			; If so, delete object
	
	bsr.w	ObjFlicky_Move			; Move
	rts

; -------------------------------------------------------------------------

ObjFlicky_Slow:
	bsr.w	ChkObjOffscreen			; Are we offscreen?
	bne.w	DelObjFromGroup			; If so, delete object

	bsr.w	ObjFlicky_Move			; Move
	bsr.w	ObjFlicky_SlowMove		; Update slow movement
	rts

; -------------------------------------------------------------------------

ObjFlicky_Glide:
	bsr.w	ChkObjOffscreen			; Are we offscreen?
	bne.w	DelObjFromGroup			; If so, delete object

	bsr.w	ObjFlicky_Move			; Move
	bsr.w	ObjFlicky_GlideMove		; Update glide movement
	rts

; -------------------------------------------------------------------------

ObjFlicky_Move:
	btst	#1,oFlags(a0)			; Are we gliding?
	beq.s	.NotGliding			; If not, branch
	tst.l	oYVel(a0)			; Are we moving down?
	bgt.s	.GetXVel			; If so, branch

.NotGliding:
	move.w	oYOffset(a0),d0			; Apply Y offset
	sub.w	d0,oY(a0)

	move.w	oFloatAngle(a0),d3		; Update Y offset
	jsr	GetSine(pc)
	muls.w	#4,d3
	asr.l	#8,d3
	move.w	d3,oYOffset(a0)
	add.w	d3,oY(a0)

	jsr	Random(pc)			; Increment float angle
	andi.l	#$7FFF,d0
	divs.w	#$30,d0
	swap	d0
	add.w	d0,oFloatAngle(a0)
	cmpi.w	#$1FF,oFloatAngle(a0)
	blt.s	.GetXVel
	subi.w	#$1FF,oFloatAngle(a0)

.GetXVel:
	move.l	oXVel(a0),d0			; Get X velocity
	tst.b	trackSelFlags.w			; Is track selection active?
	beq.s	.Move				; If not, branch
	asl.l	#3,d0				; If, so, go 8 times as fast

.Move:
	add.l	d0,oX(a0)			; Move X position
	move.l	oYVel(a0),d0			; Move Y position
	add.l	d0,oY(a0)
	rts

; -------------------------------------------------------------------------

ObjFlicky_SlowMove:
	move.w	oID(a0),d0			; Find flicky group
	bsr.w	FindOtherObjByID
	beq.s	.CatchUp			; If we are the only flicky, branch

	move.w	oX(a0),d0			; Get distance from group
	sub.w	oX(a1),d0
	bge.s	.CheckDist
	neg.w	d0

.CheckDist:
	cmpi.w	#72,d0				; Are we too far from the group?
	blt.s	.Slow				; If not, branch

.CatchUp:
	lea	MapSpr_FlickyCatchUp(pc),a3	; Catch up animation
	move.l	a3,oMap(a0)
	move.w	#0,oAnimFrame(a0)

	tst.l	oXVel(a0)			; Are we moving right?
	bge.s	.CatchUpRight			; If so, branch
	move.l	#-$30000,oXVel(a0)		; Catch up left
	bra.s	.End

.CatchUpRight:
	move.l	#$30000,oXVel(a0)		; Catch up right
	bra.s	.End

.Slow:
	cmpi.w	#32,d0				; Are we too close to the group?
	bgt.s	.End				; If not, branch

	lea	MapSpr_FlickySlow(pc),a3	; Slow animation
	move.l	a3,oMap(a0)
	move.w	#0,oAnimFrame(a0)

	tst.l	oXVel(a0)			; Are we moving right?
	bge.s	.SlowRight			; If so, branch
	move.l	#-$A000,oXVel(a0)		; Slow down left
	bra.s	.End

.SlowRight:
	move.l	#$A000,oXVel(a0)		; Slow down right

.End:
	rts

; -------------------------------------------------------------------------

ObjFlicky_GlideMove:
	move.w	oID(a0),d0			; Find flicky group
	bsr.w	FindOtherObjByID
	beq.s	.CatchUp			; If we are the only flicky, branch

	move.w	oY(a0),d0			; Get distance from group
	sub.w	oY(a1),d0
	bgt.s	.CheckDist
	moveq	#0,d0

.CheckDist:
	cmpi.w	#58,d0				; Are we too far up?
	blt.s	.Glide				; If so, branch

.CatchUp:
	lea	MapSpr_FlickyCatchUp(pc),a3	; Catch up animation
	move.l	a3,oMap(a0)
	move.w	#0,oAnimFrame(a0)
	
	move.l	#-$B000,oYVel(a0)		; Move up
	bra.s	.End

.Glide:
	cmpi.w	#8,d0				; Are we close enough to the group?
	bgt.s	.End				; If so, branch
	
	lea	MapSpr_FlickyGlide(pc),a3	; Glide animation
	move.l	a3,oMap(a0)
	move.w	#0,oAnimFrame(a0)

	move.l	#$E000,oYVel(a0)		; Glide down

.End:
	rts

; -------------------------------------------------------------------------
