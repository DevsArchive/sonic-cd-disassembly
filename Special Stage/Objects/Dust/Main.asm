; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Dust object (special stage)
; -------------------------------------------------------------------------

oDustXVel	EQU	oVar3C			; X velocity

; -------------------------------------------------------------------------
; Dust object
; -------------------------------------------------------------------------

ObjDust:
	moveq	#0,d0				; Run routine
	move.b	oRoutine(a0),d0
	add.w	d0,d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)
	
	bsr.w	DrawObject			; Draw sprite
	rts

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjDust_Init-.Index
	dc.w	ObjDust_Main-.Index

; -------------------------------------------------------------------------

ObjDust_Init:
	move.w	#$87AE,oTile(a0)		; Base tile ID
	move.l	#MapSpr_Dust,oMap(a0)		; Mappings
	move.w	#112+128,oSprX(a0)		; Set sprite position
	move.w	#212+128,oSprY(a0)
	moveq	#0,d0				; Set animation
	bsr.w	SetObjAnim
	move.w	#6,oTimer(a0)			; Set timer
	addq.b	#1,oRoutine(a0)			; Set to main routine
	
	bsr.w	Random				; Add random offset to sprite position
	move.w	d0,d1
	andi.w	#$1F,d0
	add.w	d0,oSprX(a0)
	andi.w	#7,d0
	add.w	d0,oSprY(a0)
	
	move.w	#3,oDustXVel(a0)		; Move right
	btst	#2,playerCtrlData		; Is the player moving left?
	bne.s	ObjDust_Main			; If so, branch
	move.w	#-3,oDustXVel(a0)		; If not, move left
	btst	#3,playerCtrlData		; Is the player moving right?
	bne.s	ObjDust_Main			; If so, branch
	move.w	#0,oDustXVel(a0)		; If not, don't move horizontally

; -------------------------------------------------------------------------

ObjDust_Main:
	subq.w	#1,oTimer(a0)			; Decrement timer
	bne.s	.Move				; If it hasn't run out, branch
	bset	#0,oFlags(a0)			; If it has, delete object

.Move:
	move.l	oDustXVel(a0),d0		; Move
	add.l	d0,oSprX(a0)
	subq.w	#1,oSprY(a0)
	rts

; -------------------------------------------------------------------------

MapSpr_Dust:
	include	"Special Stage/Objects/Dust/Data/Mappings.asm"
	even
	
; -------------------------------------------------------------------------
