; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; UFO objects (special stage)
; -------------------------------------------------------------------------

oUFOPlayerCol	EQU	oVar4F			; Player collision object ID
oUFOAnim	EQU	oVar52			; Current animation ID
oUFOExplodeDir	EQU	oVar53			; Explode direction
oUFOShadow	EQU	oVar54			; Shadow
oUFOPathStart	EQU	oVar58			; Path data start pointer
oUFOPath	EQU	oVar5C			; Path data pointer
oUFOPathTime	EQU	oVar60			; Path timer
oUFOItem	EQU	oVar62			; Item ID
oUFOUnk		EQU	oVar63			; Unknown
oUFODrawDelay	EQU	oVar64			; Draw delay

; -------------------------------------------------------------------------
; Time UFO
; -------------------------------------------------------------------------

ObjTimeUFO:
	moveq	#0,d0				; Run routine
	move.b	oRoutine(a0),d0
	add.w	d0,d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	move.w	sonicObject+oZ,oZ(a0)		; Shift Z position according to Sonic's Z position
	subi.w	#$140,oZ(a0)

	tst.b	oUFODrawDelay(a0)		; Is the draw delay counter active?
	beq.s	.End				; If not, branch
	subq.b	#1,oUFODrawDelay(a0)		; Decrement counter
	bset	#2,oFlags(a0)			; Don't draw sprite

.End:
	rts

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjTimeUFO_Init-.Index
	dc.w	ObjTimeUFO_Main-.Index
	dc.w	ObjTimeUFO_Explode-.Index

; -------------------------------------------------------------------------

ObjTimeUFO_Init:
	move.w	#$8440,oTile(a0)		; Base tile ID
	bsr.w	ObjUFO_FollowPath		; Start following path
	move.l	#MapSpr_UFORings,oMap(a0)	; Mappings

	move.w	sonicObject+oZ,oZ(a0)		; Shift Z position according to Sonic's Z position
	subi.w	#$140,oZ(a0)

	addq.b	#1,oRoutine(a0)			; Set routine to main
	move.b	#2,oUFODrawDelay(a0)		; Set draw delay
	
	move.b	#FM_BC,d0			; Play spawn sound
	bsr.w	PlayFMSound

; -------------------------------------------------------------------------

ObjTimeUFO_Main:
	move.l	oXVel(a0),d0			; Move
	add.l	d0,oX(a0)
	move.l	oYVel(a0),d0
	add.l	d0,oY(a0)

	subq.w	#1,oUFOPathTime(a0)		; Decrement path time
	bne.s	.Draw				; If it hasn't run out yet, branch
	bsr.w	ObjUFO_FollowPath		; Follow path

.Draw:
	bsr.w	ObjUFO_Draw			; Draw sprite
	bsr.w	Set3DSpritePos			; Set sprite position

	bsr.w	ObjUFO_CheckPlayerCol		; Check player collision
	tst.b	oUFOPlayerCol(a0)		; Was there a collision?
	beq.s	.End				; If not, branch
	tst.b	timeStopped			; Is time stopped?
	bne.s	.End				; If so, branch

	move.b	#2,oRoutine(a0)			; Start exploding
	
	movea.l	oUFOShadow(a0),a1		; Delete shadow
	bset	#0,oFlags(a1)

	move.w	#60,oTimer(a0)			; Set explosion time
	bsr.w	Random				; Set explosion direction
	andi.b	#1,d0
	move.b	d0,oUFOExplodeDir(a0)

	move.b	#0,d0				; Set animation
	bsr.w	SetObjAnim
	addi.l	#30,specStageTimer.w		; Add 30 seconds to the timer

	lea	itemObject,a1			; Spawn item icon
	move.b	#4,(a1)
	move.b	#3,oItemSpawnType(a1)
	move.w	oSprX(a0),oSprX(a1)
	move.w	oSprY(a0),oSprY(a1)

.End:
	rts

; -------------------------------------------------------------------------

ObjTimeUFO_Explode:
	subq.w	#4,oSprX(a0)			; Move left
	tst.b	oUFOExplodeDir(a0)		; Are we supposed to be moving right?
	bne.s	.Fall				; If not, branch
	addq.w	#8,oSprX(a0)			; If so, move right

.Fall:
	addq.w	#1,oSprY(a0)			; Move down
	bclr	#2,oFlags(a0)			; Enable sprite drawing

	subq.w	#1,oTimer(a0)			; Decrement timer
	bne.s	.Explode			; If it hasn't run out, branch
	bset	#0,oFlags(a0)			; Delete object

.Explode:
	btst	#0,oTimer+1(a0)			; Only spawn explosion every other frame
	bne.s	.End

	bsr.w	FindExplosionObjSlot		; Spawn explosion
	bne.s	.End
	move.b	#$C,oID(a1)
	move.w	oSprX(a0),oSprX(a1)
	subi.w	#16,oSprX(a1)
	move.w	oSprY(a0),oSprY(a1)
	bsr.w	Random
	move.w	d0,d1
	andi.w	#$1F,d0
	add.w	d0,oSprX(a1)
	andi.w	#$1F,d1
	sub.w	d0,oSprY(a1)

.End:
	rts

; -------------------------------------------------------------------------
; UFO object
; -------------------------------------------------------------------------

ObjUFO:
	moveq	#0,d0				; Run routine
	move.b	oRoutine(a0),d0
	add.w	d0,d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	move.w	sonicObject+oZ,oZ(a0)		; Shift Z position according to Sonic's Z position
	subi.w	#$140,oZ(a0)

	tst.b	oUFODrawDelay(a0)		; Is the draw delay counter active?
	beq.s	.End				; If not, branch
	subq.b	#1,oUFODrawDelay(a0)		; Decrement counter
	bset	#2,oFlags(a0)			; Don't draw sprite

.End:
	rts

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjUFO_Init-.Index
	dc.w	ObjUFO_Main-.Index
	dc.w	ObjUFO_Explode-.Index

; -------------------------------------------------------------------------

ObjUFO_Init:
	move.w	#$E440,oTile(a0)		; Base tile ID
	bsr.w	ObjUFO_FollowPath		; Start following path
	move.l	#MapSpr_UFORings,oMap(a0)	; Mappings (ring)
	cmpi.b	#0,oUFOItem(a0)			; Does this UFO have rings?
	beq.s	.GotAnim			; If so, branch
	move.l	#MapSpr_UFOShoes,oMap(a0)	; Mappings (speed shoes)

.GotAnim:
	move.w	sonicObject+oZ,oZ(a0)		; Shift Z position according to Sonic's Z position
	subi.w	#$140,oZ(a0)

	moveq	#0,d0				; Set animation
	move.b	d0,oUFOAnim(a0)
	bsr.w	SetObjAnim
	
	move.b	#2,oUFODrawDelay(a0)		; Set draw delay
	addq.b	#1,oRoutine(a0)			; Set routine to main

; -------------------------------------------------------------------------

ObjUFO_Main:
	move.l	oXVel(a0),d0			; Move
	add.l	d0,oX(a0)
	move.l	oYVel(a0),d0
	add.l	d0,oY(a0)

	subq.w	#1,oUFOPathTime(a0)		; Decrement path time
	bne.s	.Draw				; If it hasn't run out yet, branch
	bsr.w	ObjUFO_FollowPath		; Follow path

.Draw:
	bsr.w	ObjUFO_Draw			; Draw sprite
	bsr.w	Set3DSpritePos			; Set sprite position

	bsr.w	ObjUFO_CheckPlayerCol		; Check player collision
	tst.b	oUFOPlayerCol(a0)		; Was there a collision?
	beq.w	ObjUFO_End			; If not, branch

	cmpi.b	#2,ufoCount.w			; Is this the last UFO?
	bcc.s	.Explode			; If not, branch
	move.b	#1,timeStopped			; If so, stop the timer

.Explode:
	bsr.w	DecUFOCount			; Decrement UFO count

	move.b	#2,oRoutine(a0)			; Start exploding
	
	movea.l	oUFOShadow(a0),a1		; Delete shadow
	bset	#0,oFlags(a1)

	move.w	#60,oTimer(a0)			; Set explosion time
	bsr.w	Random				; Set explosion direction
	andi.b	#1,d0
	move.b	d0,oUFOExplodeDir(a0)

	move.b	#0,d0				; Set animation
	bsr.w	SetObjAnim
	
	lea	itemObject,a1			; Spawn item icon
	move.b	#4,(a1)
	move.w	oSprX(a0),oSprX(a1)
	move.w	oSprY(a0),oSprY(a1)
	move.b	oUFOItem(a0),oItemSpawnType(a1)

	moveq	#0,d0				; Give item bonus
	move.b	oUFOItem(a0),d0
	add.w	d0,d0
	move.w	.Items(pc,d0.w),d0
	jmp	.Items(pc,d0.w)

; -------------------------------------------------------------------------

.Items:
	dc.w	.Rings-.Items			; Rings
	dc.w	.SpeedShoes-.Items		; Speed shoes
	dc.w	.Rings-.Items			; Dummy
	dc.w	.Rings-.Items			; Hand

; -------------------------------------------------------------------------

.Rings:
	move.w	ufoRingBonus,d1			; Get ring bonus and double it
	move.w	d1,d0
	add.w	d1,d1
	move.w	d1,ufoRingBonus
	bra.w	AddRings

; -------------------------------------------------------------------------

.SpeedShoes:
	move.w	#200,sonicObject+oPlayerShoes	; Set speed shoes timer
	move.w	#20,ufoRingBonus		; Reset ring bonus
	rts

; -------------------------------------------------------------------------

ObjUFO_End:
	rts

; -------------------------------------------------------------------------

ObjUFO_Explode:
	subq.w	#4,oSprX(a0)			; Move left
	tst.b	oUFOExplodeDir(a0)		; Are we supposed to be moving right?
	bne.s	.Fall				; If not, branch
	addq.w	#8,oSprX(a0)			; If so, move right

.Fall:
	addq.w	#1,oSprY(a0)			; Move down
	bclr	#2,oFlags(a0)			; Enable sprite drawing

	subq.w	#1,oTimer(a0)			; Decrement timer
	bne.s	.Explode			; If it hasn't run out, branch
	bset	#0,oFlags(a0)			; Delete object

.Explode:
	btst	#0,oTimer+1(a0)			; Only spawn explosion every other frame
	bne.s	.End

	bsr.w	FindExplosionObjSlot		; Spawn explosion
	bne.s	.End
	move.b	#$C,oID(a1)
	move.w	oSprX(a0),oSprX(a1)
	subi.w	#16,oSprX(a1)
	move.w	oSprY(a0),oSprY(a1)
	bsr.w	Random
	move.w	d0,d1
	andi.w	#$1F,d0
	add.w	d0,oSprX(a1)
	andi.w	#$1F,d1
	sub.w	d0,oSprY(a1)

.End:
	rts

; -------------------------------------------------------------------------
; Follow path
; -------------------------------------------------------------------------

ObjUFO_FollowPath:
	movea.l	oUFOPath(a0),a1			; Get current path node
	move.w	(a1)+,oUFOPathTime(a0)		; Set path time
	bpl.s	.SetDest			; If this is a node, branch
	move.l	oUFOPathStart(a0),oUFOPath(a0)	; Restart path
	bra.s	ObjUFO_FollowPath		; Loop

.SetDest:
	move.w	(a1)+,d0			; Set start position
	move.w	(a1)+,d1
	move.w	d0,oX(a0)
	move.w	d1,oY(a0)

	move.w	(a1)+,d2			; Get target position
	move.w	(a1)+,d3
	
	sub.w	d0,d2				; Get distance from target position
	sub.w	d1,d3
	ext.l	d2
	ext.l	d3
	asl.l	#4,d2
	asl.l	#4,d3
	
	divs.w	oUFOPathTime(a0),d2		; Set trajectory
	divs.w	oUFOPathTime(a0),d3
	ext.l	d2
	ext.l	d3
	asl.l	#4,d2
	asl.l	#4,d3
	asl.l	#8,d2
	asl.l	#8,d3
	move.l	d2,oXVel(a0)
	move.l	d3,oYVel(a0)

	move.l	a1,oUFOPath(a0)			; Update path data pointer
	rts

; -------------------------------------------------------------------------
; Check if a UFO is on screen
; -------------------------------------------------------------------------

ObjUFO_ChkOnScreen:
	bclr	#2,oFlags(a0)			; Enable drawing

	move.w	oSprX(a0),d0			; Is the UFO onscreen horizontally?
	cmpi.w	#384+128,d0
	bcc.s	.OffScreen			; If not, branch

	move.w	oSprY(a0),d0			; Is the UFO onscreen vertically?
	cmpi.w	#128+128,d0
	blt.s	.OffScreen			; If not, branch
	cmpi.w	#320+128,d0
	blt.s	.End				; If not, branch

.OffScreen:
	bset	#2,oFlags(a0)			; Disable drawing

.End:
	rts

; -------------------------------------------------------------------------
; Draw UFO
; -------------------------------------------------------------------------

ObjUFO_Draw:
	lea	sonicObject,a6			; Get angle from player
	move.w	oX(a6),d4
	move.w	oY(a6),d5
	move.w	oX(a0),d0
	move.w	oY(a0),d1
	bsr.w	GetAngle

	move.w	oX(a6),d5			; Get distance from player
	move.w	oY(a6),d6
	move.w	oX(a0),d3
	move.w	oY(a0),d4
	bsr.w	GetDistance

	bsr.w	Set3DObjectDraw			; Draw in 3D space

	cmpi.l	#$500,d0			; Is the distance too far?
	bcs.s	.SetFrame			; If not, branch
	move.l	#$500,d0			; Cap the distance

.SetFrame:
	lsr.w	#4,d0				; Get animation based on distance
	move.b	.Frames(pc,d0.w),d0
	cmp.b	oUFOAnim(a0),d0			; Is the animation different?
	beq.s	.End				; If not, branch
	move.b	d0,oUFOAnim(a0)			; If so, set it
	bsr.w	ChgObjAnim

.End:
	rts

; -------------------------------------------------------------------------

.Frames:
	dc.b	0, 1, 2, 2, 3, 3, 3, 3
	dc.b	4, 4, 4, 4, 4, 4, 4, 4
	dc.b	5, 5, 5, 5, 5, 5, 5, 5
	dc.b	5, 5, 5, 5, 5, 5, 5, 5
	dc.b	6, 6, 6, 6, 6, 6, 6, 6
	dc.b	6, 6, 6, 6, 6, 6, 6, 6
	dc.b	7, 7, 7, 7, 7, 7, 7, 7
	dc.b	7, 7, 7, 7, 7, 7, 7, 7
	dc.b	8, 8, 8, 8, 8, 8, 8, 8
	dc.b	8, 8, 8, 8, 8, 8, 8, 8
	dc.b	9, 0

; -------------------------------------------------------------------------
; Spawn UFOs
; -------------------------------------------------------------------------

SpawnUFOs:
	moveq	#0,d0				; Get UFO path data for stage
	move.b	specStageID.w,d0
	lsl.w	#2,d0
	movea.l	.Index(pc,d0.w),a1

	lea	ufoObjects,a2			; UFO object slots
	move.w	(a1)+,d7			; Get number of UFOs
	move.b	d7,ufoCount.w
	subq.w	#1,d7

.SpawnLoop:
	bsr.s	.Spawn				; Spawn UFO
	lea	oSize(a2),a2			; Next slot
	dbf	d7,.SpawnLoop			; Loop until UFOs are spawned
	rts

; -------------------------------------------------------------------------

.Index:
	dc.l	UFOPaths_SS1			; Stage 1
	dc.l	UFOPaths_SS2			; Stage 2
	dc.l	UFOPaths_SS3			; Stage 3
	dc.l	UFOPaths_SS4			; Stage 4
	dc.l	UFOPaths_SS5			; Stage 5
	dc.l	UFOPaths_SS6			; Stage 6
	dc.l	UFOPaths_SS7			; Stage 7
	dc.l	UFOPaths_SS8			; Stage 8

; -------------------------------------------------------------------------

.Spawn:
	movea.l	(a1)+,a3			; Get path data
	lea	ufoShadowObj1-ufoObject1(a2),a4	; Get shadow slot

	move.b	#2,(a2)				; Spawn UFO
	move.b	(a3)+,oUFOItem(a2)
	move.b	(a3)+,oUFOUnk(a2)
	move.l	a3,oUFOPathStart(a2)
	move.l	a3,oUFOPath(a2)
	move.l	a4,oUFOShadow(a2)

	move.b	#5,(a4)				; Spawn shadow
	move.l	a2,oShadowParent(a4)
	rts

; -------------------------------------------------------------------------
; Spawn time UFO
; -------------------------------------------------------------------------

SpawnTimeUFO:
	cmpi.l	#20,specStageTimer.w		; Are we running out of time?
	bcc.s	.End				; If not, branch

	lea	timeUFOObject,a2		; Time UFO object slot
	lea	TimeUFOPath(pc),a3		; Path data
	tst.b	(a2)				; If the time UFO already spawned?
	bne.s	.End				; If so, branch
	lea	ufoShadowObj1-ufoObject1(a2),a4	; Get shadow slot

	move.b	#3,(a2)				; Spawn UFO
	move.b	(a3)+,oUFOItem(a2)
	move.b	(a3)+,oUFOUnk(a2)
	move.l	a3,oUFOPathStart(a2)
	move.l	a3,oUFOPath(a2)
	move.l	a4,oUFOShadow(a2)

	move.b	#5,(a4)				; Spawn shadow
	move.l	a2,oShadowParent(a4)

.End:
	rts

; -------------------------------------------------------------------------
; UFO path data
; -------------------------------------------------------------------------

TimeUFOPath:
	incbin	"Special Stage/Data/Time UFO Path.bin"
	even

; -------------------------------------------------------------------------

UFOPaths_SS1:
	dc.w	6
	dc.l	UFOPath_SS1_1
	dc.l	UFOPath_SS1_2
	dc.l	UFOPath_SS1_3
	dc.l	UFOPath_SS1_4
	dc.l	UFOPath_SS1_5
	dc.l	UFOPath_SS1_6

UFOPaths_SS2:
	dc.w	6
	dc.l	UFOPath_SS2_1
	dc.l	UFOPath_SS2_2
	dc.l	UFOPath_SS2_3
	dc.l	UFOPath_SS2_4
	dc.l	UFOPath_SS2_5
	dc.l	UFOPath_SS2_6

UFOPaths_SS3:
	dc.w	6
	dc.l	UFOPath_SS3_1
	dc.l	UFOPath_SS3_2
	dc.l	UFOPath_SS3_3
	dc.l	UFOPath_SS3_4
	dc.l	UFOPath_SS3_5
	dc.l	UFOPath_SS3_6

UFOPaths_SS4:
	dc.w	6
	dc.l	UFOPath_SS4_1
	dc.l	UFOPath_SS4_2
	dc.l	UFOPath_SS4_3
	dc.l	UFOPath_SS4_4
	dc.l	UFOPath_SS4_5
	dc.l	UFOPath_SS4_6

UFOPaths_SS5:
	dc.w	6
	dc.l	UFOPath_SS5_1
	dc.l	UFOPath_SS5_2
	dc.l	UFOPath_SS5_3
	dc.l	UFOPath_SS5_4
	dc.l	UFOPath_SS5_5
	dc.l	UFOPath_SS5_6

UFOPaths_SS6:
	dc.w	6
	dc.l	UFOPath_SS6_1
	dc.l	UFOPath_SS6_2
	dc.l	UFOPath_SS6_3
	dc.l	UFOPath_SS6_4
	dc.l	UFOPath_SS6_5
	dc.l	UFOPath_SS6_6

UFOPaths_SS7:
	dc.w	6
	dc.l	UFOPath_SS7_1
	dc.l	UFOPath_SS7_2
	dc.l	UFOPath_SS7_3
	dc.l	UFOPath_SS7_4
	dc.l	UFOPath_SS7_5
	dc.l	UFOPath_SS7_6

UFOPaths_SS8:
	dc.w	6
	dc.l	UFOPath_SS8_1
	dc.l	UFOPath_SS8_2
	dc.l	UFOPath_SS8_3
	dc.l	UFOPath_SS8_4
	dc.l	UFOPath_SS8_5
	dc.l	UFOPath_SS8_6

; -------------------------------------------------------------------------

UFOPath_SS1_1:
	incbin	"Special Stage/Data/Stage 1/UFO 1.bin"
	even

UFOPath_SS1_2:
	incbin	"Special Stage/Data/Stage 1/UFO 2.bin"
	even

UFOPath_SS1_3:
	incbin	"Special Stage/Data/Stage 1/UFO 3.bin"
	even

UFOPath_SS1_4:
	incbin	"Special Stage/Data/Stage 1/UFO 4.bin"
	even

UFOPath_SS1_5:
	incbin	"Special Stage/Data/Stage 1/UFO 5.bin"
	even

UFOPath_SS1_6:
	incbin	"Special Stage/Data/Stage 1/UFO 6.bin"
	even

UFOPath_SS2_1:
	incbin	"Special Stage/Data/Stage 2/UFO 1.bin"
	even

UFOPath_SS2_2:
	incbin	"Special Stage/Data/Stage 2/UFO 2.bin"
	even

UFOPath_SS2_3:
	incbin	"Special Stage/Data/Stage 2/UFO 3.bin"
	even

UFOPath_SS2_4:
	incbin	"Special Stage/Data/Stage 2/UFO 4.bin"
	even

UFOPath_SS2_5:
	incbin	"Special Stage/Data/Stage 2/UFO 5.bin"
	even

UFOPath_SS2_6:
	incbin	"Special Stage/Data/Stage 2/UFO 6.bin"
	even

UFOPath_SS3_1:
	incbin	"Special Stage/Data/Stage 3/UFO 1.bin"
	even

UFOPath_SS3_2:
	incbin	"Special Stage/Data/Stage 3/UFO 2.bin"
	even

UFOPath_SS3_3:
	incbin	"Special Stage/Data/Stage 3/UFO 3.bin"
	even

UFOPath_SS3_4:
	incbin	"Special Stage/Data/Stage 3/UFO 4.bin"
	even

UFOPath_SS3_5:
	incbin	"Special Stage/Data/Stage 3/UFO 5.bin"
	even

UFOPath_SS3_6:
	incbin	"Special Stage/Data/Stage 3/UFO 6.bin"
	even

UFOPath_SS4_1:
	incbin	"Special Stage/Data/Stage 4/UFO 1.bin"
	even

UFOPath_SS4_2:
	incbin	"Special Stage/Data/Stage 4/UFO 2.bin"
	even

UFOPath_SS4_3:
	incbin	"Special Stage/Data/Stage 4/UFO 3.bin"
	even

UFOPath_SS4_4:
	incbin	"Special Stage/Data/Stage 4/UFO 4.bin"
	even

UFOPath_SS4_5:
	incbin	"Special Stage/Data/Stage 4/UFO 5.bin"
	even

UFOPath_SS4_6:
	incbin	"Special Stage/Data/Stage 4/UFO 6.bin"
	even

UFOPath_SS5_1:
	incbin	"Special Stage/Data/Stage 5/UFO 1.bin"
	even

UFOPath_SS5_2:
	incbin	"Special Stage/Data/Stage 5/UFO 2.bin"
	even

UFOPath_SS5_3:
	incbin	"Special Stage/Data/Stage 5/UFO 3.bin"
	even

UFOPath_SS5_4:
	incbin	"Special Stage/Data/Stage 5/UFO 4.bin"
	even

UFOPath_SS5_5:
	incbin	"Special Stage/Data/Stage 5/UFO 5.bin"
	even

UFOPath_SS5_6:
	incbin	"Special Stage/Data/Stage 5/UFO 6.bin"
	even

UFOPath_SS6_1:
	incbin	"Special Stage/Data/Stage 6/UFO 1.bin"
	even

UFOPath_SS6_2:
	incbin	"Special Stage/Data/Stage 6/UFO 2.bin"
	even

UFOPath_SS6_3:
	incbin	"Special Stage/Data/Stage 6/UFO 3.bin"
	even

UFOPath_SS6_4:
	incbin	"Special Stage/Data/Stage 6/UFO 4.bin"
	even

UFOPath_SS6_5:
	incbin	"Special Stage/Data/Stage 6/UFO 5.bin"
	even

UFOPath_SS6_6:
	incbin	"Special Stage/Data/Stage 6/UFO 6.bin"
	even

UFOPath_SS7_1:
	incbin	"Special Stage/Data/Stage 7/UFO 1.bin"
	even

UFOPath_SS7_2:
	incbin	"Special Stage/Data/Stage 7/UFO 2.bin"
	even

UFOPath_SS7_3:
	incbin	"Special Stage/Data/Stage 7/UFO 3.bin"
	even

UFOPath_SS7_4:
	incbin	"Special Stage/Data/Stage 7/UFO 4.bin"
	even

UFOPath_SS7_5:
	incbin	"Special Stage/Data/Stage 7/UFO 5.bin"
	even

UFOPath_SS7_6:
	incbin	"Special Stage/Data/Stage 7/UFO 6.bin"
	even

UFOPath_SS8_1:
	incbin	"Special Stage/Data/Stage 8/UFO 1.bin"
	even

UFOPath_SS8_2:
	incbin	"Special Stage/Data/Stage 8/UFO 2.bin"
	even

UFOPath_SS8_3:
	incbin	"Special Stage/Data/Stage 8/UFO 3.bin"
	even

UFOPath_SS8_4:
	incbin	"Special Stage/Data/Stage 8/UFO 4.bin"
	even

UFOPath_SS8_5:
	incbin	"Special Stage/Data/Stage 8/UFO 5.bin"
	even

UFOPath_SS8_6:
	incbin	"Special Stage/Data/Stage 8/UFO 6.bin"
	even

; -------------------------------------------------------------------------
