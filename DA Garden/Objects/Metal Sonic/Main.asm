; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; DA Garden Metal Sonic object
; -------------------------------------------------------------------------

ObjMetalSonic:
	lea	.Index,a1			; Run routine
	jmp	RunObjRoutine

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjMetalSonic_Init-.Index
	dc.w	ObjMetalSonic_Enter-.Index
	dc.w	ObjMetalSonic_Float-.Index
	dc.w	ObjMetalSonic_BackUp-.Index
	dc.w	ObjMetalSonic_Exit-.Index

; -------------------------------------------------------------------------

ObjMetalSonic_Init:
	addi.w	#$4000,oTile(a0)		; Set to sprite palette
	move.w	#0,oAnimFrame(a0)		; Reset animation
	lea	MapSpr_MetalSonic(pc),a1
	move.l	a1,oMap(a0)
	move.w	2(a1),oAnimTime(a0)
	move.w	#1,oRoutine(a0)			; Set to main routine
	rts

; -------------------------------------------------------------------------

ObjMetalSonic_Enter:
	bsr.w	ChkObjOffscreen			; Are we offscreen?
	bne.w	DeleteObject			; If so, delete object
	
	move.l	oXVel(a0),d0			; Get velocity
	move.l	oYVel(a0),d1
	
	tst.b	trackSelFlags.w			; Is track selection active?
	beq.s	.Move				; If not, branch
	
	move.l	#$180000,oXVel(a0)		; Set exit velocity
	move.l	#0,oYVel(a0)
	btst	#7,oFlags(a0)
	beq.s	.Exit
	neg.l	oXVel(a0)

.Exit:
	move.w	#4,oRoutine(a0)			; Set to exit routine
	bra.s	.End

.Move:
	add.l	d0,oX(a0)			; Move
	add.l	d1,oY(a0)
	btst	#7,oFlags(a0)			; Are we moving from the left side of the screen?
	beq.s	.ChkCenterXFromLeft		; If so, branch
	
.ChkCenterXFromRight:
	cmpi.w	#128,oX(a0)			; Are we at the horizontal center of the screen?
	bgt.s	.CheckY				; If not, branch
	bra.s	.StopAtCenterX

.ChkCenterXFromLeft:
	cmpi.w	#128,oX(a0)			; Are we at the horizontal center of the screen?
	blt.s	.CheckY				; If not, branch

.StopAtCenterX:
	move.w	#128,oX(a0)			; Stop at horizontal center of the screen
	move.l	#0,oXVel(a0)

.CheckY:
	btst	#3,oFlags(a0)			; Are we moving from the top side of the screen?
	bne.s	.ChkCenterYFromTop		; If so, branch
	
.ChkCenterYFromBtm:
	cmpi.w	#100,oY(a0)			; Are we at the vertical center of the screen?
	bgt.s	.CheckStop			; If not, branch
	bra.s	.StopAtCenterY

.ChkCenterYFromTop:
	cmpi.w	#100,oY(a0)			; Are we at the vertical center of the screen?
	blt.s	.CheckStop			; If not, branch

.StopAtCenterY:
	move.w	#100,oY(a0)			; Stop at vertical center of the screen
	move.l	#0,oYVel(a0)

.CheckStop:
	cmpi.w	#128,oX(a0)			; Are we at the center of the screen?
	bne.s	.End				; If not, branch
	cmpi.w	#100,oY(a0)
	bne.s	.End				; If not, branch
	
	move.b	#64,oTimer(a0)			; Set float timer
	move.b	#8,oTimer2(a0)			; Set direction timer
	move.w	#2,oRoutine(a0)			; Set to float routine

.End:
	rts

; -------------------------------------------------------------------------

ObjMetalSonic_Float:
	tst.b	trackSelFlags.w			; Is track selection active?
	bne.s	.BackUp				; If so, branch
	
	tst.b	oTimer(a0)			; Has the float run out?
	blt.s	.Float				; If so, branch
	tst.b	oTimer2(a0)			; Has the direction timer run out?
	bne.s	.DecTimer			; If not, branch
	
	move.b	#24,oTimer2(a0)			; Reset direction timer
	jsr	Random(pc)			; Face random direction
	btst	#0,d0
	bne.s	.FaceOtherDir
	bclr	#7,oFlags(a0)
	bra.s	.DecTimer

.FaceOtherDir:
	bset	#7,oFlags(a0)

.DecTimer:
	subq.b	#1,oTimer2(a0)			; Decrement direction timer
	subq.b	#1,oTimer(a0)			; Decrement float timer
	bge.s	.Float				; If it hasn't run out, branch

.BackUp:
	move.b	#48,oTimer(a0)			; Set back up timer
	move.w	#$100,oFloatSpeed(a0)		; Set float speed
	move.w	#2,oFloatAmp(a0)		; Set float amplitude
	lea	MapSpr_MetalSonicBackUp(pc),a3	; Set back up animation
	move.l	a3,oMap(a0)
	move.w	#0,oAnimFrame(a0)
	
	move.l	#-$10000,oXVel(a0)		; Set back up speed
	btst	#7,oFlags(a0)
	beq.s	.SetBackUpRoutine
	neg.l	oXVel(a0)

.SetBackUpRoutine:
	move.w	#3,oRoutine(a0)			; Set to back up routine
	bra.s	.End

.Float:
	bsr.w	ObjMoveFloat			; Move

.End:
	rts

; -------------------------------------------------------------------------

ObjMetalSonic_BackUp:
	tst.b	trackSelFlags.w			; Is track selection active?
	bne.s	.Exit				; If so, branch
	subq.b	#1,oTimer(a0)			; Decrement back up timer
	bgt.s	.Float				; If it hasn't run out, branch

.Exit:
	move.w	#0,oFloatSpeed(a0)		; Stop floating
	move.w	#0,oFloatAmp(a0)
	move.l	#$180000,oXVel(a0)		; Set exit velocity
	btst	#7,oFlags(a0)
	beq.s	.SetExitRoutine
	neg.l	oXVel(a0)

.SetExitRoutine:
	move.w	#4,oRoutine(a0)			; Set to exit routine
	bra.s	.End

.Float:
	bsr.w	ObjMoveFloat			; Move

.End:
	rts

; -------------------------------------------------------------------------

ObjMetalSonic_Exit:
	bsr.w	ChkObjOffscreen			; Are we offscreen?
	bne.w	DeleteObject			; If so, delete object
	
	move.l	oXVel(a0),d0			; Get velocity
	move.l	oYVel(a0),d1
	
	tst.b	trackSelFlags.w			; Is track selection active?
	beq.s	.Move				; If not, branch
	
	asl.l	#1,d0				; Move twice as fast
	asl.l	#1,d1
	add.l	d0,oX(a0)
	add.l	d1,oY(a0)
	bra.s	.End

.Move:
	add.l	d0,oX(a0)			; Move
	add.l	d1,oY(a0)

.End:
	rts

; -------------------------------------------------------------------------
