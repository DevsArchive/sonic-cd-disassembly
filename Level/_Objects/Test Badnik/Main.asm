; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Test badnik object
; -------------------------------------------------------------------------

oUnusedBadX	EQU	oVar30			; X position copy

; -------------------------------------------------------------------------

ObjTestBadnik:
	moveq	#0,d0				; Run object routine
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jmp	.Index(pc,d0.w)

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjTestBadnik_Init-.Index	; Initialization
	dc.w	ObjTestBadnik_Main-.Index	; Main

; -------------------------------------------------------------------------
; Unused badnik initialization routine
; -------------------------------------------------------------------------

ObjTestBadnik_Init:
	btst	#7,oFlags(a0)			; Are we offscreen?
	bne.w	DeleteObject			; If so, delete ourselves

	addq.b	#2,oRoutine(a0)			; Advance routine

	move.b	#%00000100,oSprFlags(a0)	; Set sprite flags
	move.b	#1,oPriority(a0)		; Set priority
	move.l	#MapSpr_Powerup,oMap(a0)	; Set mappings
	move.w	#$541,oTile(a0)			; Set base tile
	move.w	oX(a0),oUnusedBadX(a0)		; Copy X position
	move.b	#6,oColType(a0)			; Enable collision

; -------------------------------------------------------------------------
; Main unused badnik routine
; -------------------------------------------------------------------------

ObjTestBadnik_Main:
	move.w	oUnusedBadX(a0),d0		; Get the object's chunk position
	andi.w	#$FF80,d0
	move.w	cameraX.w,d1			; Get the camera's chunk position
	subi.w	#$80,d1
	andi.w	#$FF80,d1

	sub.w	d1,d0				; Has the object gone offscreen?
	cmpi.w	#$80+(320+$40)+$80,d0
	bhi.w	DeleteObject			; If so, delete ourselves

	lea	Ani_Powerup,a1			; Animate sprite
	bsr.w	AnimateObject
	jmp	DrawObject			; Draw sprite

; -------------------------------------------------------------------------
