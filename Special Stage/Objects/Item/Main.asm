; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Item objects (special stage)
; -------------------------------------------------------------------------

oItemXVel	EQU	oVar3C			; X velocity
oItemYVel	EQU	oVar40			; Y velocity
oItemSpawnType	EQU	oVar51			; Item type (on spawn)
oItemType	EQU	oVar52			; Item type

; -------------------------------------------------------------------------
; Lost ring object
; -------------------------------------------------------------------------

ObjLostRing:
	moveq	#0,d0				; Run routine
	move.b	oRoutine(a0),d0
	add.w	d0,d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	bra.w	DrawObject			; Draw sprite

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjLostRing_Init-.Index
	dc.w	ObjLostRing_Main-.Index

; -------------------------------------------------------------------------

ObjLostRing_Init:
	move.w	#$E78F,oTile(a0)		; Base tile ID
	move.l	#MapSpr_Item,oMap(a0)		; Mappings

	moveq	#4,d0				; Set type and animation
	move.b	d0,oItemType(a0)
	bsr.w	SetObjAnim

	move.w	sonicObject+oSprX,oSprX(a0)	; Spawn at Sonic's position
	move.w	sonicObject+oSprY,oSprY(a0)

	addq.b	#1,oRoutine(a0)			; Set to main routine
	move.b	#45,oTimer(a0)			; Set timer

	bsr.w	Random				; Get X speed
	move.w	d0,d1
	andi.l	#$3F000,d1
	bchg	#0,lostRingXDir			; Should this ring fly left?
	beq.s	.SetXVel			; If not, branch
	neg.l	d1				; If so, fly left

.SetXVel:
	move.l	d1,oItemXVel(a0)		; Set X velocity

	andi.w	#$F,d0				; Set Y velocity
	move.w	#-$A,oItemYVel(a0)
	sub.w	d0,oItemYVel(a0)

	move.b	#FM_RINGLOSS,d0			; Play ring loss sound
	bsr.w	PlayFMSound

; -------------------------------------------------------------------------

ObjLostRing_Main:
	subq.b	#1,oTimer(a0)			; Decrement timer
	bne.s	.Move				; If it hasn't run out yet, branch
	bset	#0,oFlags(a0)			; Delete object

.Move:
	move.l	oItemXVel(a0),d0		; Move
	add.l	d0,oSprX(a0)
	move.l	oItemYVel(a0),d0
	add.l	d0,oSprY(a0)

	cmpi.w	#216+128,oSprY(a0)		; Is the ring at the bottom of the screen?
	bls.s	.Gravity			; If not, branch
	move.w	#216+128,oSprY(a0)		; Bounce off the bottom of the screen
	neg.l	oItemYVel(a0)
	rts
	
.Gravity:
	addi.l	#$20000,oItemYVel(a0)		; Apply gravity
	rts

; -------------------------------------------------------------------------
; Item object
; -------------------------------------------------------------------------

ObjItem:
	moveq	#0,d0				; Run routine
	move.b	oRoutine(a0),d0
	add.w	d0,d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	bra.w	DrawObject			; Draw sprite

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjItem_Init-.Index
	dc.w	ObjItem_Main-.Index

; -------------------------------------------------------------------------

ObjItem_Init:
	move.w	#$878F,oTile(a0)		; Base tile ID
	move.l	#MapSpr_Item,oMap(a0)		; Mappings

	moveq	#0,d0				; Set type and animation
	move.b	oItemSpawnType(a0),d0
	move.b	d0,oItemType(a0)
	bsr.w	SetObjAnim

	addq.b	#1,oRoutine(a0)			; Set to main routine
	move.b	#$10,oTimer(a0)			; Set timer
	move.w	#-$10,oItemYVel(a0)		; Move upwards

	move.b	#FM_RING,d0			; Play ring sound
	bsr.w	PlayFMSound

; -------------------------------------------------------------------------

ObjItem_Main:
	subq.b	#1,oTimer(a0)			; Decrement timer
	bne.s	.Move				; If it hasn't run out yet, branch
	bset	#0,oFlags(a0)			; Delete object

.Move:
	move.l	oItemYVel(a0),d0		; Move
	add.l	d0,oSprY(a0)
	
	addi.l	#$20000,oItemYVel(a0)		; Decelerate
	rts

; -------------------------------------------------------------------------

MapSpr_Item:
	include	"Special Stage/Objects/Item/Data/Mappings.asm"
	even

; -------------------------------------------------------------------------
