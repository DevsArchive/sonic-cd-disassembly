; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Flower object
; -------------------------------------------------------------------------

oFlowerLoPrio	EQU	oSubtype2		; Low priority sprite flag

; -------------------------------------------------------------------------

ObjFlower:
	moveq	#0,d0				; Run routine
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	jmp	DrawObject			; Draw sprite

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjFlower_Init-.Index
	dc.w	ObjFlower_Seed-.Index
	dc.w	ObjFlower_Animate-.Index
	dc.w	ObjFlower_Growing-.Index
	dc.w	ObjFlower_Done-.Index

; -------------------------------------------------------------------------
; Initialization
; -------------------------------------------------------------------------

ObjFlower_Init:
	ori.b	#%00000100,oSprFlags(a0)	; Set sprite flags
	move.b	#1,oPriority(a0)		; Set priority
	move.b	#0,oYRadius(a0)			; Set Y radius
	move.w	#$A6D7,oTile(a0)		; Set base tile
	tst.b	oFlowerLoPrio(a0)		; Should our sprite be low priority?
	beq.s	.GotPriority			; If not, branch
	andi.b	#$7F,oTile(a0)			; Clear tile priority bit

.GotPriority:
	move.l	#MapSpr_Flower,oMap(a0)		; Set mappings

	tst.b	oSubtype(a0)			; Should we be able to respawn?
	bne.s	.NoFlags			; If not, branch

	bsr.w	ObjFlower_GetSavedFlags		; Get saved flags
	move.b	(a1),d0
	move.b	#4,oRoutine(a0)			; Set routine to animate
	move.b	#3,oAnim(a0)			; Set animation to flower animation
	btst	#6,d0				; Have we already spawned?
	bne.s	ObjFlower_Animate		; If so, branch

.NoFlags:
	move.w	#2,oAnim(a0)			; Set animation to seed animation (and have it reset)
	move.b	#2,oRoutine(a0)			; Set routine to seed
	move.w	#$6D7,oTile(a0)			; Set base tile to use palette line 0

; -------------------------------------------------------------------------
; Seed
; -------------------------------------------------------------------------

ObjFlower_Seed:
	jsr	ObjGetFloorDist			; Have we touched the floor yet?
	tst.w	d1
	bpl.s	.Fall				; If not, branch
	add.w	d1,oY(a0)			; Align to the floor

	tst.b	oSubtype(a0)			; Should we be able to respawn?
	bne.s	.TouchDown			; If not, branch

	bsr.w	ObjFlower_GetSavedFlags		; Get saved flags
	
	lea	flowerCount,a2			; Increment flower count in this time zone
	move.b	(a2,d1.w),d0
	addq.b	#1,(a2,d1.w)

	bsr.w	ObjFlower_GetPosBuffer		; Mark our position
	move.w	oX(a0),(a1,d0.w)
	move.w	oY(a0),2(a1,d0.w)

.TouchDown:
	move.b	#4,oRoutine(a0)			; Set routine to animate
	move.b	#1,oAnim(a0)			; Set animation to seed planted animation
	move.b	#$30,oYRadius(a0)		; Set Y radius
	bra.w	ObjFlower_Animate		; Continue to animate sprite

.Fall:
	addq.w	#2,oY(a0)			; Fall down slowly

; -------------------------------------------------------------------------
; Animation
; -------------------------------------------------------------------------

ObjFlower_Animate:
	lea	Ani_Flower,a1			; Animate sprite
	bra.w	AnimateObject

; -------------------------------------------------------------------------
; Get a flower object's saved flags
; -------------------------------------------------------------------------
; RETURNS:
;	d1.w - Offset in table
;	a1.l - Pointer to entry
; -------------------------------------------------------------------------

ObjFlower_GetSavedFlags:
	moveq	#0,d0				; Get base table offset
	move.b	oSavedFlagsID(a0),d0
	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,d0

	moveq	#0,d1				; Add time zone to the offset
	move.b	timeZone,d1
	bclr	#7,d1
	add.w	d1,d0

	lea	savedObjFlags,a1		; Get saved flags
	lea	2(a1,d0.w),a1
	rts

; -------------------------------------------------------------------------
; Get a flower object's respawn table entry
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Flower index
; RETURNS:
;	a1.l - Flower position table address
; -------------------------------------------------------------------------

ObjFlower_GetPosBuffer:
	andi.w	#$3F,d0				; Get flower position table offset
	add.w	d0,d0
	add.w	d0,d0

	moveq	#0,d1				; Add time zone to the offset
	move.b	timeZone,d1
	bclr	#7,d1
	lsl.w	#8,d1
	add.w	d1,d0

	lea	flowerPosBuf,a1			; Get flower position table address
	rts

; -------------------------------------------------------------------------
; Growing
; -------------------------------------------------------------------------

ObjFlower_Growing:
	move.w	#$26D7,oTile(a0)		; Set to palette line 1
	move.b	#2,oAnim(a0)			; Set to growing animation
	bra.s	ObjFlower_Animate

; -------------------------------------------------------------------------
; Finished
; -------------------------------------------------------------------------

ObjFlower_Done:
	move.b	#3,oAnim(a0)			; We are now fully grown
	move.b	#4,oRoutine(a0)
	bra.s	ObjFlower_Animate

; -------------------------------------------------------------------------
