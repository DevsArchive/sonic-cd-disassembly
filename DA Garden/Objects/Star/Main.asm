; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; DA Garden star object
; -------------------------------------------------------------------------

ObjStar:
	lea	.Index,a1			; Run routine
	jmp	RunObjRoutine

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjStar_Init-.Index
	dc.w	ObjStar_Main-.Index

; -------------------------------------------------------------------------

ObjStar_Init:
	addi.w	#$4000,oTile(a0)		; Set to sprite palette limit
	move.w	#0,oAnimFrame(a0)		; Reset animation
	lea	MapSpr_Star(pc),a1		; Set mappings
	move.l	a1,oMap(a0)
	move.w	2(a1),oAnimTime(a0)
	clr.w	oXOffset(a0)			; Reset position offset
	clr.w	oYOffset(a0)
	move.w	#1,oRoutine(a0)			; Set to main routine
	rts

; -------------------------------------------------------------------------

ObjStar_Main:
	bsr.w	ChkObjOffscreen			; Are we offscreen?
	bne.w	DelObjFromGroup			; If so, delete object
	bra.s	.SkipFloat			; Stars don't float

	move.w	oYOffset(a0),d0			; Apply Y offset		
	sub.w	d0,oY(a0)
	
	move.w	oFloatAngle(a0),d3		; Update Y offset
	jsr	GetSine(pc)
	muls.w	#10,d3
	asr.l	#8,d3
	move.w	d3,oYOffset(a0)
	add.w	d3,oY(a0)

.SkipFloat:
	jsr	Random(pc)			; Increment float angle
	andi.l	#$7FFF,d0
	divs.w	#$28,d0
	swap	d0
	add.w	d0,oFloatAngle(a0)
	cmpi.w	#$1FF,oFloatAngle(a0)
	blt.s	.Move
	subi.w	#$1FF,oFloatAngle(a0)

.Move:
	move.l	oXVel(a0),d0			; Move
	add.l	d0,oX(a0)
	move.l	oYVel(a0),d0
	add.l	d0,oY(a0)
	rts

; -------------------------------------------------------------------------
