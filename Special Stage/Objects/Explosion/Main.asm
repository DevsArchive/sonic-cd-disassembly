; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Explosion object (special stage)
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Find explosion object slot
; -------------------------------------------------------------------------
; RETURNS:
;	eq/ne - Not found/found
;	a1.l  - Found slot
; -------------------------------------------------------------------------

FindExplosionObjSlot:
	lea	explosionObjs,a1		; Explosion object slots
	moveq	#EXPLODEOBJCNT-1,d7		; Number of slots to check

.Find:
	tst.w	(a1)				; Is this slot occupied?
	beq.s	.End				; If not, exit
	adda.w	#oSize,a1			; Next slot
	dbf	d7,.Find			; Loop until finished

.End:
	rts

; -------------------------------------------------------------------------
; Explosion object
; -------------------------------------------------------------------------

ObjExplosion:
	moveq	#0,d0				; Run routine
	move.b	oRoutine(a0),d0
	add.w	d0,d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	bsr.w	DrawObject			; Draw sprite
	rts

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjExplosion_Init-.Index
	dc.w	ObjExplosion_Main-.Index

; -------------------------------------------------------------------------

ObjExplosion_Init:
	move.w	#$87AE,oTile(a0)		; Base tile ID
	move.l	#MapSpr_Explosion,oMap(a0)	; Mappings
	moveq	#0,d0				; Set animation
	bsr.w	SetObjAnim
	move.w	#12,oTimer(a0)			; Set timer
	addq.b	#1,oRoutine(a0)			; Set routine to main

	move.b	#FM_A3,d0			; Play explosion sound
	bsr.w	PlayFMSound

; -------------------------------------------------------------------------

ObjExplosion_Main:
	subq.w	#1,oTimer(a0)			; Decrement timer
	bne.s	.End				; If it hasn't run out, branch
	bset	#0,oFlags(a0)			; Delete object

.End:
	rts

; -------------------------------------------------------------------------

MapSpr_Explosion:
	include	"Special Stage/Objects/Explosion/Data/Mappings.asm"
	even

; -------------------------------------------------------------------------
