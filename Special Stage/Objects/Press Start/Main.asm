; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; "Press Start" objects (special stage)
; -------------------------------------------------------------------------

ObjPressStart:
	moveq	#0,d0				; Run routine
	move.b	oRoutine(a0),d0
	add.w	d0,d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	bsr.w	DrawObject			; Draw sprite
	rts

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjPressStart_Init-.Index
	dc.w	ObjPressStart_Main-.Index

; -------------------------------------------------------------------------

ObjPressStart_Init:
	move.w	#$856A,oTile(a0)		; Base sprite ID
	move.l	#Spr_PressStart,oSprites(a0)	; Sprite data
	move.w	#84+128,oSprX(a0)		; Set position
	move.w	#80+128,oSprY(a0)
	moveq	#0,d0				; Set sprite
	bsr.w	SetObjSprite
	addq.b	#1,oRoutine(a0)			; Set routine to main

; -------------------------------------------------------------------------

ObjPressStart_Main:
	addq.b	#1,oTimer(a0)			; Increment timer
	bset	#2,oFlags(a0)			; Flash every 16 frames
	btst	#4,oTimer(a0)
	bne.s	.End
	bclr	#2,oFlags(a0)

.End:
	rts

; -------------------------------------------------------------------------

Spr_PressStart:
	include	"Special Stage/Objects/Press Start/Data/Sprites.asm"
	even

; -------------------------------------------------------------------------
