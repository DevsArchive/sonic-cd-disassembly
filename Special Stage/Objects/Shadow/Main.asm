; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Shadow objects (special stage)
; -------------------------------------------------------------------------

oShadowSprite	EQU	oVar52			; Current sprite ID
oShadowParent	EQU	oVar54			; Parent object

; -------------------------------------------------------------------------
; Sonic's shadow
; -------------------------------------------------------------------------

ObjSonicShadow:
	moveq	#0,d0				; Run routine
	move.b	oRoutine(a0),d0
	add.w	d0,d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	bsr.w	DrawObject			; Draw sprite
	rts

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjSonicShadow_Init-.Index
	dc.w	ObjSonicShadow_Main-.Index

; -------------------------------------------------------------------------

ObjSonicShadow_Init:
	move.w	#$E6DC,oTile(a0)		; Base tile ID
	move.l	#MapSpr_Shadow,oMap(a0)		; Mappings
	moveq	#5,d0				; Set animation
	move.b	d0,oShadowSprite(a0)
	bsr.w	SetObjAnim
	addq.b	#1,oRoutine(a0)			; Set routine to main

; -------------------------------------------------------------------------

ObjSonicShadow_Main:
	lea	sonicObject,a1			; Move along with Sonic
	move.w	oX(a1),oX(a0)
	move.w	oY(a1),oY(a0)
	move.w	sonicObject+oZ,oZ(a0)
	bra.w	Set3DSpritePos			; Set sprite position

; -------------------------------------------------------------------------
; UFO shadow
; -------------------------------------------------------------------------

ObjUFOShadow:
	moveq	#0,d0				; Run routine
	move.b	oRoutine(a0),d0
	add.w	d0,d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	bsr.w	ObjUFO_ChkOnScreen		; Check if on screen
	bsr.w	DrawObject			; Draw sprite
	rts

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjUFOShadow_Init-.Index
	dc.w	ObjUFOShadow_Main-.Index

; -------------------------------------------------------------------------

ObjUFOShadow_Init:
	move.w	#$E6DC,oTile(a0)		; Base tile ID
	move.l	#MapSpr_Shadow,oMap(a0)		; Mappings
	moveq	#0,d0				; Set animation
	move.b	d0,oShadowSprite(a0)
	bsr.w	SetObjAnim
	addq.b	#1,oRoutine(a0)			; Set routine to main

; -------------------------------------------------------------------------

ObjUFOShadow_Main:
	movea.l	oShadowParent(a0),a1		; Move with UFO
	move.w	oX(a1),oX(a0)
	move.w	oY(a1),oY(a0)

	bset	#2,oFlags(a1)			; Sync draw flag with UFO's
	btst	#2,oFlags(a0)
	bne.s	.Draw
	bclr	#2,oFlags(a1)

.Draw:
	move.w	sonicObject+oZ,oZ(a0)		; Shift Z position according to Sonic's Z position

	bsr.w	ObjUFO_Draw			; Draw sprite
	bsr.w	Set3DSpritePos			; Set sprite position
	rts

; -------------------------------------------------------------------------
