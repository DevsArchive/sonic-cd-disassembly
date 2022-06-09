; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Palette cycle script function
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Cycle a color in the palette
; -------------------------------------------------------------------------
; PARAMETERS:
;	a4.l - Pointer to cycle frame
;	a5.l - Pointer to timer
; -------------------------------------------------------------------------

CycleColor:
	subq.b	#1,(a5)				; Decrement timer
	bpl.s	.End				; If it hasn't run out, branch

	moveq	#0,d0
	move.b	(a1)+,d0			; Get palette index
	move.b	(a1)+,d1			; Get total number of cycle frames

	add.w	d0,d0				; Get pointer to palette entry
	lea	palette.w,a3
	lea	(a3,d0.w),a3

	moveq	#0,d0				; Get current cycle frame
	move.b	(a4),d0
	addq.b	#1,d0				; Increment it
	cmp.b	d1,d0				; Should we wrap it back to 0?
	bcs.s	.NoReset			; If not, don't worry about it
	moveq	#0,d0				; If so, then do it

.NoReset:
	move.b	d0,(a4)

	add.w	d0,d0
	move.b	(a1,d0.w),(a5)			; Get cycle frame length
	move.b	1(a1,d0.w),d0			; Get cycle color index
	ext.w	d0
	add.w	d0,d0
	move.w	(a2,d0.w),(a3)			; Store the color in palette RAM

.End:
	adda.w	#1,a4				; Go to next cycle frame and timer
	adda.w	#1,a5
	rts

; -------------------------------------------------------------------------
