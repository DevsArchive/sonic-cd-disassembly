; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Palmtree Panic Good Future palette cycle
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Handle palette cycling
; -------------------------------------------------------------------------

PaletteCycle:
	lea	PalCycleData1,a0		; Prepare first palette data set
	subq.b	#1,palCycleTimers.w		; Decrement timer
	bpl.s	.SkipCycle1			; If this cycle's timer isn't done, branch
	move.b	#7,palCycleTimers.w		; Reset the timer

	moveq	#0,d0				; Get the current palette cycle frame
	move.b	palCycleSteps.w,d0
	cmpi.b	#2,d0				; Should we wrap it back to 0?
	bne.s	.IncCycle1			; If not, don't worry about it
	moveq	#0,d0				; If so, then do it
	bra.s	.ApplyCycle1

.IncCycle1:
	addq.b	#1,d0				; Increment the palette cycle frame

.ApplyCycle1:
	move.b	d0,palCycleSteps.w

	lsl.w	#3,d0				; Store the currnent palette cycle data in palette RAM
	lea	palette+$6A.w,a1
	move.l	(a0,d0.w),(a1)+
	move.l	4(a0,d0.w),(a1)

.SkipCycle1:
	adda.w	#PalCycleData2-PalCycleData1,a0	; Prepare second palette data set
	subq.b	#1,palCycleTimers+1.w		; Decrement timer
	bpl.s	.End				; If this cycle's timer isn't done, branch
	move.b	#5,palCycleTimers+1.w		; Reset the timer

	moveq	#0,d0				; Get the current palette cycle frame
	move.b	palCycleSteps+1.w,d0
	cmpi.b	#2,d0				; Should we wrap it back to 0?
	bne.s	.IncCycle2			; If not, don't worry about it
	moveq	#0,d0				; If so, then do it
	bra.s	.ApplyCycle2

.IncCycle2:
	addq.b	#1,d0				; Increment the palette cycle frame

.ApplyCycle2:
	move.b	d0,palCycleSteps+1.w

	andi.w	#3,d0				; Store the currnent palette cycle data in palette RAM
	lsl.w	#3,d0
	lea	palette+$58.w,a1
	move.l	(a0,d0.w),(a1)+
	move.l	4(a0,d0.w),(a1)

.End:
	rts

; -------------------------------------------------------------------------
; Palette cycle data
; -------------------------------------------------------------------------

PalCycleData1:
	dc.w	$ECC, $ECA, $EEE, $EA8
	dc.w	$EA8, $ECC, $ECC, $ECA
	dc.w	$ECA, $EA8, $ECA, $ECC

PalCycleData2:
	dc.w	$ECA, $EA8, $C60, $E86
	dc.w	$EA8, $E86, $C60, $ECA
	dc.w	$E86, $ECA, $C60, $EA8

; -------------------------------------------------------------------------
