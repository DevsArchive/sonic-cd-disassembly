; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Boulder object
; -------------------------------------------------------------------------

ObjBoulder:
	moveq	#0,d0				; Run routine
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)
	
	jsr	DrawObject			; Draw sprite
	jmp	CheckObjDespawn			; Check despawn

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjBoulder_Init-.Index
	dc.w	ObjBoulder_Main-.Index
	
; -------------------------------------------------------------------------
; Initialization
; -------------------------------------------------------------------------

ObjBoulder_Init:
	addq.b	#2,oRoutine(a0)			; Next routine
	ori.b	#%00000100,oSprFlags(a0)	; Set sprite flags
	move.b	#4,oPriority(a0)		; Set priority
	move.l	#MapSpr_Boulder,oMap(a0)	; Set mappings
	move.b	#$10,oWidth(a0)			; Set width
	move.b	#$10,oYRadius(a0)		; Set height
	move.b	#0,oMapFrame(a0)		; Set sprite frame
	moveq	#$B,d0				; Set base tile ID
	jsr	SetObjectTileID

; -------------------------------------------------------------------------
; Main routine
; -------------------------------------------------------------------------

ObjBoulder_Main:
	tst.b	oSprFlags(a0)			; Are we on screen?
	bpl.s	.End				; If not, branch
	
	lea	objPlayerSlot.w,a1		; Handle solidity
	move.w	oX(a0),d3
	move.w	oY(a0),d4
	jmp	SolidObject

.End:
	rts

; -------------------------------------------------------------------------
; Data
; -------------------------------------------------------------------------

MapSpr_Boulder:
	include	"Level/_Objects/Boulder/Data/Mappings.asm"
	even

; -------------------------------------------------------------------------
