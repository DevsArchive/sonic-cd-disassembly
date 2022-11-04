; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Misc. level functions
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Check if an object should despawn offscreen (leftover from Sonic 1)
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Object slot
; -------------------------------------------------------------------------

CheckObjDespawnS1:
	move.w	oX(a0),d0			; Get the object's chunk position
	andi.w	#$FF80,d0
	move.w	cameraX.w,d1			; Get the camera's chunk position
	subi.w	#$80,d1
	andi.w	#$FF80,d1

	sub.w	d1,d0				; Has the object gone offscreen?
	cmpi.w	#$80+(320+$40)+$80,d0
	bhi.w	.NoDraw				; If so, branch
	bra.w	DrawObject			; If not, draw the object's sprite

.NoDraw:
	lea	savedObjFlags,a2		; Saved object flags table
	moveq	#0,d0				; Get table entry ID
	move.b	oSavedFlagsID(a0),d0
	beq.s	.NoClear			; If the object doesn't have one, branch
	bclr	#7,2(a2,d0.w)			; Mark as unloaded

.NoClear:
	bra.w	DeleteObject			; Delete the object

; -------------------------------------------------------------------------
; Perform VSync
; -------------------------------------------------------------------------

VSync:
	move	#$2300,sr			; Enable interrupts

.Wait:
	tst.b	vintRoutine.w			; Has the V-INT routine run?
	bne.s	.Wait				; If not, wait for it to
	
	rts

; -------------------------------------------------------------------------
; Get the sine and cosine of an angle
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.b - Angle
; RETURNS:
;	d0.w - Sine
;	d1.w - Cosine
; -------------------------------------------------------------------------

CalcSine:
	andi.w	#$FF,d0				; Convert angle into table index
	add.w	d0,d0
	addi.w	#$80,d0				; Get cosine
	move.w	SineTable(pc,d0.w),d1
	subi.w	#$80,d0				; Get sine
	move.w	SineTable(pc,d0.w),d0
	rts

; -------------------------------------------------------------------------

SineTable:
	dc.w	$0000, $0006, $000C, $0012, $0019, $001F, $0025, $002B, $0031, $0038, $003E, $0044, $004A, $0050, $0056, $005C
	dc.w	$0061, $0067, $006D, $0073, $0078, $007E, $0083, $0088, $008E, $0093, $0098, $009D, $00A2, $00A7, $00AB, $00B0
	dc.w	$00B5, $00B9, $00BD, $00C1, $00C5, $00C9, $00CD, $00D1, $00D4, $00D8, $00DB, $00DE, $00E1, $00E4, $00E7, $00EA
	dc.w	$00EC, $00EE, $00F1, $00F3, $00F4, $00F6, $00F8, $00F9, $00FB, $00FC, $00FD, $00FE, $00FE, $00FF, $00FF, $00FF
	dc.w	$0100, $00FF, $00FF, $00FF, $00FE, $00FE, $00FD, $00FC, $00FB, $00F9, $00F8, $00F6, $00F4, $00F3, $00F1, $00EE
	dc.w	$00EC, $00EA, $00E7, $00E4, $00E1, $00DE, $00DB, $00D8, $00D4, $00D1, $00CD, $00C9, $00C5, $00C1, $00BD, $00B9
	dc.w	$00B5, $00B0, $00AB, $00A7, $00A2, $009D, $0098, $0093, $008E, $0088, $0083, $007E, $0078, $0073, $006D, $0067
	dc.w	$0061, $005C, $0056, $0050, $004A, $0044, $003E, $0038, $0031, $002B, $0025, $001F, $0019, $0012, $000C, $0006
	dc.w	$0000, $FFFA, $FFF4, $FFEE, $FFE7, $FFE1, $FFDB, $FFD5, $FFCF, $FFC8, $FFC2, $FFBC, $FFB6, $FFB0, $FFAA, $FFA4
	dc.w	$FF9F, $FF99, $FF93, $FF8B, $FF88, $FF82, $FF7D, $FF78, $FF72, $FF6D, $FF68, $FF63, $FF5E, $FF59, $FF55, $FF50
	dc.w	$FF4B, $FF47, $FF43, $FF3F, $FF3B, $FF37, $FF33, $FF2F, $FF2C, $FF28, $FF25, $FF22, $FF1F, $FF1C, $FF19, $FF16
	dc.w	$FF14, $FF12, $FF0F, $FF0D, $FF0C, $FF0A, $FF08, $FF07, $FF05, $FF04, $FF03, $FF02, $FF02, $FF01, $FF01, $FF01
	dc.w	$FF00, $FF01, $FF01, $FF01, $FF02, $FF02, $FF03, $FF04, $FF05, $FF07, $FF08, $FF0A, $FF0C, $FF0D, $FF0F, $FF12
	dc.w	$FF14, $FF16, $FF19, $FF1C, $FF1F, $FF22, $FF25, $FF28, $FF2C, $FF2F, $FF33, $FF37, $FF3B, $FF3F, $FF43, $FF47
	dc.w	$FF4B, $FF50, $FF55, $FF59, $FF5E, $FF63, $FF68, $FF6D, $FF72, $FF78, $FF7D, $FF82, $FF88, $FF8B, $FF93, $FF99
	dc.w	$FF9F, $FFA4, $FFAA, $FFB0, $FFB6, $FFBC, $FFC2, $FFC8, $FFCF, $FFD5, $FFDB, $FFE1, $FFE7, $FFEE, $FFF4, $FFFA
	; Extra data for cosine
	dc.w	$0000, $0006, $000C, $0012, $0019, $001F, $0025, $002B, $0031, $0038, $003E, $0044, $004A, $0050, $0056, $005C
	dc.w	$0061, $0067, $006D, $0073, $0078, $007E, $0083, $0088, $008E, $0093, $0098, $009D, $00A2, $00A7, $00AB, $00B0
	dc.w	$00B5, $00B9, $00BD, $00C1, $00C5, $00C9, $00CD, $00D1, $00D4, $00D8, $00DB, $00DE, $00E1, $00E4, $00E7, $00EA
	dc.w	$00EC, $00EE, $00F1, $00F3, $00F4, $00F6, $00F8, $00F9, $00FB, $00FC, $00FD, $00FE, $00FE, $00FF, $00FF, $00FF

; -------------------------------------------------------------------------
; Calculate an angle from (0,0) to (x,y)
; -------------------------------------------------------------------------
; PARAMETERS:
;	d1.w - X position
;	d2.w - Y position
; -------------------------------------------------------------------------
; RETURNS:
;	d0.w - Angle
; -------------------------------------------------------------------------

CalcAngle:
	movem.l	d3-d4,-(sp)
	moveq	#0,d3
	moveq	#0,d4
	move.w	d1,d3
	move.w	d2,d4
	or.w	d3,d4
	beq.s	.AngleZero			; Special case when both x and y are zero
	move.w	d2,d4

	tst.w	d3				; Get absolute value of X
	bpl.w	.NotNeg1
	neg.w	d3

.NotNeg1:
	tst.w	d4				; Get absolute value of Y
	bpl.w	.NotNeg2
	neg.w	d4

.NotNeg2:
	cmp.w	d3,d4
	bcc.w	.YGreater			; If |y| >= |x|
	lsl.l	#8,d4
	divu.w	d3,d4
	moveq	#0,d0
	move.b	ArcTanTable(pc,d4.w),d0
	bra.s	.CheckQuadrant

.YGreater:
	lsl.l	#8,d3
	divu.w	d4,d3
	moveq	#$40,d0
	sub.b	ArcTanTable(pc,d3.w),d0		; arctan(y/x) = 90 - arctan(x/y)

.CheckQuadrant:
	tst.w	d1
	bpl.w	.GotHalf
	neg.w	d0
	addi.w	#$80,d0				; Place angle in appropriate quadrant

.GotHalf:
	tst.w	d2
	bpl.w	.GotQuadrant
	neg.w	d0
	addi.w	#$100,d0			; Place angle in appropriate quadrant

.GotQuadrant:
	movem.l	(sp)+,d3-d4
	rts

.AngleZero:
	move.w	#$40,d0				; Angle = 90 degrees
	movem.l	(sp)+,d3-d4
	rts

; -------------------------------------------------------------------------

ArcTanTable:
	dc.b	$00, $00, $00, $00, $01, $01
	dc.b	$01, $01, $01, $01, $02, $02
	dc.b	$02, $02, $02, $02, $03, $03
	dc.b	$03, $03, $03, $03, $03, $04
	dc.b	$04, $04, $04, $04, $04, $05
	dc.b	$05, $05, $05, $05, $05, $06
	dc.b	$06, $06, $06, $06, $06, $06
	dc.b	$07, $07, $07, $07, $07, $07
	dc.b	$08, $08, $08, $08, $08, $08
	dc.b	$08, $09, $09, $09, $09, $09
	dc.b	$09, $0A, $0A, $0A, $0A, $0A
	dc.b	$0A, $0A, $0B, $0B, $0B, $0B
	dc.b	$0B, $0B, $0B, $0C, $0C, $0C
	dc.b	$0C, $0C, $0C, $0C, $0D, $0D
	dc.b	$0D, $0D, $0D, $0D, $0D, $0E
	dc.b	$0E, $0E, $0E, $0E, $0E, $0E
	dc.b	$0F, $0F, $0F, $0F, $0F, $0F
	dc.b	$0F, $10, $10, $10, $10, $10
	dc.b	$10, $10, $11, $11, $11, $11
	dc.b	$11, $11, $11, $11, $12, $12
	dc.b	$12, $12, $12, $12, $12, $13
	dc.b	$13, $13, $13, $13, $13, $13
	dc.b	$13, $14, $14, $14, $14, $14
	dc.b	$14, $14, $14, $15, $15, $15
	dc.b	$15, $15, $15, $15, $15, $15
	dc.b	$16, $16, $16, $16, $16, $16
	dc.b	$16, $16, $17, $17, $17, $17
	dc.b	$17, $17, $17, $17, $17, $18
	dc.b	$18, $18, $18, $18, $18, $18
	dc.b	$18, $18, $19, $19, $19, $19
	dc.b	$19, $19, $19, $19, $19, $19
	dc.b	$1A, $1A, $1A, $1A, $1A, $1A
	dc.b	$1A, $1A, $1A, $1B, $1B, $1B
	dc.b	$1B, $1B, $1B, $1B, $1B, $1B
	dc.b	$1B, $1C, $1C, $1C, $1C, $1C
	dc.b	$1C, $1C, $1C, $1C, $1C, $1C
	dc.b	$1D, $1D, $1D, $1D, $1D, $1D
	dc.b	$1D, $1D, $1D, $1D, $1D, $1E
	dc.b	$1E, $1E, $1E, $1E, $1E, $1E
	dc.b	$1E, $1E, $1E, $1E, $1F, $1F
	dc.b	$1F, $1F, $1F, $1F, $1F, $1F
	dc.b	$1F, $1F, $1F, $1F, $20, $20
	dc.b	$20, $20, $20, $20, $20, $00

; -------------------------------------------------------------------------
