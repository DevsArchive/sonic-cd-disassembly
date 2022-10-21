; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Object animation function
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Animate an object's sprite
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Object RAM
; -------------------------------------------------------------------------

AnimateObject:
	moveq	#0,d0				; Get current animation
	move.b	oAnim(a0),d0
	cmp.b	oPrevAnim(a0),d0		; Are we changing animations?
	beq.s	.Do				; If not, branch

	move.b	d0,oPrevAnim(a0)		; Reset animation flags
	move.b	#0,oAnimFrame(a0)
	move.b	#0,oAnimTime(a0)

.Do:
	subq.b	#1,oAnimTime(a0)
	bpl.s	.End
	add.w	d0,d0				; Get pointer to animation data
	adda.w	(a1,d0.w),a1
	move.b	(a1),oAnimTime(a0)		; Get animation speed

	moveq	#0,d1				; Get animation frame
	move.b	oAnimFrame(a0),d1
	move.b	1(a1,d1.w),d0
	bmi.s	.AniFF				; If it's a flag, branch

.AniNext:
	move.b	d0,d1				; Copy flip flags
	andi.b	#$1F,d0				; Set sprite frame
	move.b	d0,oMapFrame(a0)

	move.b	oFlags(a0),d0			; Apply flip flags
	rol.b	#3,d1
	eor.b	d0,d1
	andi.b	#%00000011,d1
	andi.b	#%11111100,oSprFlags(a0)
	or.b	d1,oSprFlags(a0)

	addq.b	#1,oAnimFrame(a0)		; Update animation frame

.End:
	rts

; -------------------------------------------------------------------------

.AniFF:
	addq.b	#1,d0				; Is the flag $FF (loop)?
	bne.s	.AniFE				; If not, branch

	move.b	#0,oAnimFrame(a0)		; Set animation script frame back to 0
	move.b	1(a1),d0			; Get animation frame at that point
	bra.s	.AniNext

.AniFE:
	addq.b	#1,d0				; Is the flag $FE (loop back to frame)?
	bne.s	.AniFD

	move.b	2(a1,d1.w),d0			; Get animation script frame to go back to
	sub.b	d0,oAnimFrame(a0)
	sub.b	d0,d1				; Get animation frame at that point
	move.b	1(a1,d1.w),d0
	bra.s	.AniNext

.AniFD:
	addq.b	#1,d0				; Is the flag $FD (new animation)?
	bne.s	.AniFC
	move.b	2(a1,d1.w),oAnim(a0)		; Set new animation ID

.AniFC:
	addq.b	#1,d0				; Is the flag $FC (increment routine ID)?
	bne.s	.AniFB				; If not, branch
	addq.b	#2,oRoutine(a0)			; Increment routine ID

.AniFB:
	addq.b	#1,d0				; Is the flag $FB (loop and reset secondary routine ID)?
	bne.s	.AniFA				; If not, branch
	move.b	#0,oAnimFrame(a0)		; Set animation script frame back to 0
	clr.b	oRoutine2(a0)			; Reset secondary routine ID

.AniFA:
	addq.b	#1,d0				; Is the flag $FA (increment secondary routine ID)?
	bne.s	.End2				; If not, branch
	addq.b	#2,oRoutine2(a0)		; Increment secondary routine ID

.End2:
	rts

; -------------------------------------------------------------------------
