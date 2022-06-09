; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Palmtree Panic Past palette cycle
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Handle palette cycling
; -------------------------------------------------------------------------

PaletteCycle:
	bra.w	PalCycle_Do			; Skip over prototype code

	; Dead code: this is the palette cycling routine from the v0.02 prototype

	lea	PalCycProtoData1,a0		; Prepare first palette data set
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
						; Prepare second palette data set
	adda.w	#PalCycProtoData2-PalCycProtoData1,a0
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
; Prototype palette cycle data
; -------------------------------------------------------------------------

PalCycProtoData1:
	dc.w	$EEA, $CE6, $EEE, $8C4
	dc.w	$8C4, $EEA, $EEA, $CE6
	dc.w	$CE6, $8C4, $CE6, $EEA

PalCycProtoData2:
	dc.w	$EEC, $CE6, $AA0, $8C4
	dc.w	$CE6, $8C4, $AA0, $EEC
	dc.w	$8C4, $EEC, $AA0, $CE6

; -------------------------------------------------------------------------
; The actual final palette cycling function
; -------------------------------------------------------------------------

PalCycle_Do:
	lea	palCycleTimers.w,a5		; Prepare palette cycle variables
	lea	palCycleSteps.w,a4

	lea	PalCycleScript1,a1		; Cycle color 1
	lea	PalCycleColors1,a2
	bsr.s	CycleColor

	lea	PalCycleScript2,a1		; Cycle color 2
	lea	PalCycleColors2,a2
	bsr.s	CycleColor

	lea	PalCycleScript3,a1		; Cycle color 3
	lea	PalCycleColors3,a2
	bsr.s	CycleColor

	lea	PalCycleScript4,a1		; Cycle color 4
	lea	PalCycleColors4,a2
	bsr.s	CycleColor

	lea	PalCycleScript5,a1		; Cycle color 5
	lea	PalCycleColors5,a2
	bsr.s	CycleColor

	lea	PalCycleScript6,a1		; Cycle color 6
	lea	PalCycleColors6,a2

; -------------------------------------------------------------------------

	include	"Level/Palette Cycle Script.asm"

; -------------------------------------------------------------------------

; Color 1
PalCycleScript1:
	dc.b	$31, 3				; Palette index, number of frames
	dc.b	8, 0				; Frame length, color index
	dc.b	8, 1
	dc.b	8, 2
PalCycleColors1:
	dc.w	$EEA, $CE6, $8C4

; Color 2
PalCycleScript2:
	dc.b	$32, 3
	dc.b	8, 0
	dc.b	8, 1
	dc.b	8, 2
PalCycleColors2:
	dc.w	$8C4, $EEA, $CE6

; Color 3
PalCycleScript3:
	dc.b	$33, 3
	dc.b	8, 0
	dc.b	8, 1
	dc.b	8, 2
PalCycleColors3:
	dc.w	$CE6, $8C4, $EEA

; Color 4
PalCycleScript4:
	dc.b	$2C, 3
	dc.b	6, 0
	dc.b	6, 1
	dc.b	6, 2
PalCycleColors4:
	dc.w	$EEC, $CE6, $8C4

; Color 5
PalCycleScript5:
	dc.b	$2D, 3
	dc.b	6, 0
	dc.b	6, 1
	dc.b	6, 2
PalCycleColors5:
	dc.w	$CE6, $8C4, $EEC

; Color 6
PalCycleScript6:
	dc.b	$2F, 3
	dc.b	6, 0
	dc.b	6, 1
	dc.b	6, 2
PalCycleColors6:
	dc.w	$8C4, $EEC, $CE6

; -------------------------------------------------------------------------
