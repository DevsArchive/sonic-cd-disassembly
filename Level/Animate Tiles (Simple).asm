; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Tile animation function
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Animate tiles (simple)
; -------------------------------------------------------------------------
; PARAMETERS:
;	d6.w - Size of frame in longwords (minus 1)
;	a1.l - Pointer to animated tile data
;	a2.l - Pointer to timer
;	a4.l - Pointer to frame ID
; -------------------------------------------------------------------------
; RETURNS:
;	a2.l - Pointer to next timer
;	a4.l - Pointer to frame ID
; -------------------------------------------------------------------------

AnimateTilesSimple:
	subq.b	#1,(a2)				; Decrement timer
	bpl.w	.NoUpdate			; If it hasn't run out, branch
	move.b	(a1),(a2)			; Reset timer

	moveq	#0,d0				; Get frame ID
	move.b	(a4),d0
	addq.b	#1,d0				; Increment it
	cmp.b	1(a1),d0			; Did it increment past the end?
	bcs.s	.GetFrameArt			; If not, branch
	moveq	#0,d0				; If so, wrap back to the start

.GetFrameArt:
	move.b	d0,(a4)				; Update frame ID

	add.w	d0,d0				; Get frame art
	add.w	d0,d0
	movea.l	2(a1,d0.w),a1

	lea	aniArtBuffer,a3			; Copy it into work RAM

.Copy:
	move.l	(a1)+,(a3)+
	dbf	d6,.Copy

	adda.w	#1,a2				; Next animated art slot
	adda.w	#1,a4

	moveq	#0,d0				; Updated
	rts

.NoUpdate:
	adda.w	#1,a2				; Next animated art slot
	adda.w	#1,a4

	moveq	#1,d0				; No updates
	rts

; -------------------------------------------------------------------------
