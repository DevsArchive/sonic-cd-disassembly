; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; DA Garden planet object (Sub CPU)
; -------------------------------------------------------------------------

ObjPlanet:
	lea	planetObj,a0			; Object slot

	moveq	#0,d0				; Run routine
	move.b	oRoutine(a0),d0
	add.w	d0,d0
	move.w	.Index(pc,d0.w),d0
	jmp	.Index(pc,d0.w)

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjPlanet_Init-.Index
	dc.w	ObjPlanet_Move-.Index
	dc.w	ObjPlanet_Stopped-.Index

; -------------------------------------------------------------------------

ObjPlanet_Init:
	move.w	#0,oX(a0)			; Set position
	move.w	#$18,oY(a0)
	move.w	#$40,oZ(a0)
	move.w	#0,planetObj+oAngle		; Reset angle
	
	lea	gfxParams,a6			; Set unknown graphics operations parameters
	move.w	#$800,gfx10(a6)
	move.w	#$400,gfx12(a6)
	clr.w	oUnk(a0)			; Clear unknown variable
			
	move.w	#1,angleDirection		; Rotate right
	move.w	#1,scaleDirection		; Zoom out
	move.w	#2,angleSpeed			; Set angle speed
	
	addq.b	#1,oRoutine(a0)			; Start moving

; -------------------------------------------------------------------------

ObjPlanet_Move:
	btst	#7,ctrlTap.w			; Has start been pressed?
	beq.s	.NoExit				; If not, branch
	bset	#6,GASUBFLAG.w			; Set exit flag
	move.b	#0,planetObj+oRoutine		; Reset planet object
	rts

.NoExit:
	btst	#4,GAMAINFLAG.w			; Is track selection active?
	beq.s	.AllowMove			; If not, branch
	move.b	#2,oRoutine(a0)			; Stop moving

.AllowMove:
	btst	#4,ctrlHold.w			; Is B being held?
	beq.w	.NoAngleAccel			; If not, branch
	
	tst.l	angleSpeed			; Are we rotating?
	beq.s	.StartRotate			; If not, start rotating
	
	btst	#4,planetFlags			; Have we already started rotating?
	bne.s	.AccelAngleLeft			; If so, branch
	move.l	#0,angleSpeed			; Stop rotating
	neg.w	angleDirection			; Rotate in other direction
	bra.s	.MarkAngleAccel

.StartRotate:
	btst	#4,planetFlags			; Have we already started rotating?
	bne.s	.MarkAngleAccel			; If so, branch

.AccelAngleLeft:
	tst.w	angleDirection			; Are we rotating right?
	blt.s	.AccelAngleRight		; If so, branch
	addi.l	#$8000,angleSpeed		; Accelerate rotation left
	bra.s	.MarkAngleAccel

.AccelAngleRight:
	addi.l	#-$8000,angleSpeed		; Accelerate rotation right

.MarkAngleAccel:
	bset	#4,planetFlags			; Mark as rotating
	bra.s	.CheckScale

.NoAngleAccel:
	bclr	#4,planetFlags			; Not rotating

.CheckScale:
	btst	#5,ctrlHold.w			; Is C being held?
	beq.s	.NoZoom				; If so, branch
	
	nop
	tst.w	scaleDirection			; Are we zooming out?
	bgt.s	.ChkZoomInStart			; If so, branch
	btst	#5,planetFlags			; Are we already zooming?
	beq.s	.ZoomOut			; If not, branch
	bra.s	.ZoomIn				; If so, zoom in

.ChkZoomInStart:
	btst	#5,planetFlags			; Are we already zooming?
	beq.s	.ZoomIn				; If so, branch

.ZoomOut:
	move.w	#1,scaleDirection		; Mark as zooming out
	move.w	planetObj+oZ,d2			; Are we zoomed out all the way?
	cmpi.w	#$700,d2
	bgt.s	.MarkZooming			; If so, branch
	addq.w	#8,planetObj+oZ			; Zoom out
	bra.s	.MarkZooming

.ZoomIn:
	move.w	#-1,scaleDirection		; Mark as zooming in
	move.w	planetObj+oZ,d2			; Are we zoomed in all the way?
	cmpi.w	#$FF90,d2
	blt.s	.MarkZooming			; If so, branch
	addi.w	#-8,planetObj+oZ		; Zoom in

.MarkZooming:
	bset	#5,planetFlags			; Mark as zooming
	bra.s	.CheckLeft

.NoZoom:
	bclr	#5,planetFlags			; Not zooming

.CheckLeft:
	move.w	planetObj+oZ,d5			; Get move speed modifier based on scale
	asr.w	#6,d5
	move.w	d5,d6
	neg.w	d6
	
	btst	#2,ctrlHold.w			; Is left being held?
	beq.s	.CheckRight			; If not, branch
	addq.w	#8,planetObj+oX			; Move left
	add.w	d5,planetObj+oX

.CheckRight:
	btst	#3,ctrlHold.w			; Is right being held?
	beq.s	.CheckUp			; If not, branch
	addi.w	#-8,planetObj+oX		; Move right
	add.w	d6,planetObj+oX

.CheckUp:
	btst	#0,ctrlHold.w			; Is up being held?
	beq.s	.CheckDown			; If not, branch
	addq.w	#8,planetObj+oY			; Move up
	add.w	d5,planetObj+oY

.CheckDown:
	btst	#1,ctrlHold.w			; Is down being held?
	beq.s	.CheckLeftBound			; If not, branch
	addi.w	#-8,planetObj+oY		; Move down
	add.w	d6,planetObj+oY

.CheckLeftBound:
	move.w	planetObj+oZ,d0			; Are we past the left boundary?
	addi.w	#$150,d0
	cmp.w	planetObj+oX,d0
	bgt.s	.CheckRightBound		; If not, branch
	move.w	d0,planetObj+oX			; Cap at boundary

.CheckRightBound:
	move.w	planetObj+oZ,d0			; Are we past the right boundary?
	neg.w	d0
	addi.w	#-$150,d0
	cmp.w	planetObj+oX,d0
	blt.s	.CheckTopBound			; If not, branch
	move.w	d0,planetObj+oX			; Cap at boundary

.CheckTopBound:
	move.w	planetObj+oZ,d0			; Are we past the top boundary?
	addi.w	#$150,d0
	cmp.w	planetObj+oY,d0
	bgt.s	.CheckBtmBound			; If not, branch
	move.w	d0,planetObj+oY			; Cap at boundary

.CheckBtmBound:
	move.w	planetObj+oZ,d0			; Are we past the bottom boundary?
	neg.w	d0
	addi.w	#-$150,d0
	cmp.w	planetObj+oY,d0
	blt.s	.Rotate				; If not, branch
	move.w	d0,planetObj+oY			; Cap at boundary

.Rotate:
	move.w	angleSpeed,d2			; Rotate
	add.w	d2,planetObj+oAngle
	andi.w	#$1FF,planetObj+oAngle
	rts

; -------------------------------------------------------------------------

ObjPlanet_Stopped:
	btst	#7,ctrlTap.w			; Has start been pressed?
	beq.s	.NoExit				; If not, branch
	bset	#6,GASUBFLAG.w			; Set exit flag
	move.b	#0,planetObj+oRoutine		; Reset planet object
	rts

.NoExit:
	btst	#4,GAMAINFLAG.w			; Is track selection active?
	bne.s	.Rotate				; If so, branch
	move.b	#1,oRoutine(a0)			; Start moving again

.Rotate:
	move.w	angleSpeed,d2			; Rotate
	add.w	d2,planetObj+oAngle
	andi.w	#$1FF,planetObj+oAngle
	rts

; -------------------------------------------------------------------------
