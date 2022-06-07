; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Scroll flag set functions
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Set scroll flags for the background while scrolling the position
; -------------------------------------------------------------------------
; PARAMETERS:
;	d4.w - X scroll offset
;	d5.w - Y scroll offset
; -------------------------------------------------------------------------

SetScrollFlagsBG:
	move.l	cameraBgX.w,d2			; Scroll horizontally
	move.l	d2,d0
	add.l	d4,d0
	move.l	d0,cameraBgX.w

	move.l	d0,d1				; Check if a block has been crossed and set flags accordingly
	swap	d1
	andi.w	#$10,d1
	move.b	horizBlkCrossedBg.w,d3
	eor.b	d3,d1
	bne.s	.ChkY
	eori.b	#$10,horizBlkCrossedBg.w
	sub.l	d2,d0
	bpl.s	.MoveRight
	bset	#2,scrollFlagsBg.w
	bra.s	.ChkY

.MoveRight:
	bset	#3,scrollFlagsBg.w

; -------------------------------------------------------------------------

.ChkY:
	move.l	cameraBgY.w,d3			; Scroll vertically
	move.l	d3,d0
	add.l	d5,d0
	move.l	d0,cameraBgY.w

	move.l	d0,d1				; Check if a block has been crossed and set flags accordingly
	swap	d1
	andi.w	#$10,d1
	move.b	vertiBlkCrossedBg.w,d2
	eor.b	d2,d1
	bne.s	.End
	eori.b	#$10,vertiBlkCrossedBg.w
	sub.l	d3,d0
	bpl.s	.MoveDown
	bset	#0,scrollFlagsBg.w
	rts

.MoveDown:
	bset	#1,scrollFlagsBg.w

.End:
	rts

; -------------------------------------------------------------------------
; Set vertical scroll flags for the background camera while scrolling the
; position
; -------------------------------------------------------------------------
; PARAMETERS:
;	d5.w - Y scroll offset
; -------------------------------------------------------------------------

SetVertiScrollFlagsBG:
	move.l	cameraBgY.w,d3			; Scroll vertically
	move.l	d3,d0
	add.l	d5,d0
	move.l	d0,cameraBgY.w

	move.l	d0,d1				; Check if a block has been crossed and set flags accordingly
	swap	d1
	andi.w	#$10,d1
	move.b	vertiBlkCrossedBg.w,d2
	eor.b	d2,d1
	bne.s	.End
	eori.b	#$10,vertiBlkCrossedBg.w
	sub.l	d3,d0
	bpl.s	.MoveDown
	bset	#4,scrollFlagsBg.w
	rts

.MoveDown:
	bset	#5,scrollFlagsBg.w

.End:
	rts

; -------------------------------------------------------------------------
; Set vertical scroll flags for the background camera while setting the
; position directly
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - New Y position
; -------------------------------------------------------------------------

SetVertiScrollFlagsBG2:
	move.w	cameraBgY.w,d3			; Set new position
	move.w	d0,cameraBgY.w

	move.w	d0,d1				; Check if a block has been crossed and set flags accordingly
	andi.w	#$10,d1
	move.b	vertiBlkCrossedBg.w,d2
	eor.b	d2,d1
	bne.s	.End
	eori.b	#$10,vertiBlkCrossedBg.w
	sub.w	d3,d0
	bpl.s	.MoveDown
	bset	#0,scrollFlagsBg.w
	rts

.MoveDown:
	bset	#1,scrollFlagsBg.w

.End:
	rts

; -------------------------------------------------------------------------
; Set horizontal scroll flags for the background camera while
; scrolling the position
; -------------------------------------------------------------------------
; PARAMETERS:
;	d4.w - X scroll offset
;	d6.b - Base scroll flag bit
; -------------------------------------------------------------------------

SetHorizScrollFlagsBG:
	move.l	cameraBgX.w,d2			; Scroll horizontally
	move.l	d2,d0
	add.l	d4,d0
	move.l	d0,cameraBgX.w

	move.l	d0,d1				; Check if a block has been crossed and set flags accordingly
	swap	d1
	andi.w	#$10,d1
	move.b	horizBlkCrossedBg.w,d3
	eor.b	d3,d1
	bne.s	.End
	eori.b	#$10,horizBlkCrossedBg.w
	sub.l	d2,d0
	bpl.s	.MoveRight
	bset	d6,scrollFlagsBg.w
	bra.s	.End

.MoveRight:
	addq.b	#1,d6
	bset	d6,scrollFlagsBg.w

.End:
	rts

; -------------------------------------------------------------------------
; Set horizontal scroll flags for the background camera #2 while
; scrolling the position
; -------------------------------------------------------------------------
; PARAMETERS:
;	d4.w - X scroll offset
;	d6.b - Base scroll flag bit
; -------------------------------------------------------------------------

SetHorizScrollFlagsBG2:
	move.l	cameraBg2X.w,d2			; Scroll horizontally
	move.l	d2,d0
	add.l	d4,d0
	move.l	d0,cameraBg2X.w

	move.l	d0,d1				; Check if a block has been crossed and set flags accordingly
	swap	d1
	andi.w	#$10,d1
	move.b	horizBlkCrossedBg2.w,d3
	eor.b	d3,d1
	bne.s	.End
	eori.b	#$10,horizBlkCrossedBg2.w
	sub.l	d2,d0
	bpl.s	.MoveRight
	bset	d6,scrollFlagsBg2.w
	bra.s	.End


.MoveRight:
	addq.b	#1,d6
	bset	d6,scrollFlagsBg2.w

.End:
	rts

; -------------------------------------------------------------------------
; Set horizontal scroll flags for the background camera #3 while
; scrolling the position
; -------------------------------------------------------------------------
; PARAMETERS:
;	d4.w - X scroll offset
;	d6.b - Base scroll flag bit
; -------------------------------------------------------------------------

SetHorizScrollFlagsBG3:
	move.l	cameraBg3X.w,d2			; Scroll horizontally
	move.l	d2,d0
	add.l	d4,d0
	move.l	d0,cameraBg3X.w

	move.l	d0,d1				; Check if a block has been crossed and set flags accordingly
	swap	d1
	andi.w	#$10,d1
	move.b	horizBlkCrossedBg3.w,d3
	eor.b	d3,d1
	bne.s	.End
	eori.b	#$10,horizBlkCrossedBg3.w
	sub.l	d2,d0
	bpl.s	.MoveRight
	bset	d6,scrollFlagsBg3.w
	bra.s	.End

.MoveRight:
	addq.b	#1,d6
	bset	d6,scrollFlagsBg3.w

.End:
	rts

; -------------------------------------------------------------------------
