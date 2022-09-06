; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Sonic object (time warp)
; -------------------------------------------------------------------------

ObjSonic:
	moveq	#0,d0				; Run routine
	move.b	oRoutine(a0),d0
	add.w	d0,d0
	move.w	.Index(pc,d0.w),d0
	jmp	.Index(pc,d0.w)

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjSonic_Init-.Index
	dc.w	ObjSonic_Enter-.Index
	dc.w	ObjSonic_Wait-.Index
	dc.w	ObjSonic_Leave-.Index
	dc.w	ObjSonic_Done-.Index

; -------------------------------------------------------------------------

ObjSonic_Init:	
	move.w	#$8000,oTile(a0)		; Base tile ID
	move.l	#MapSpr_Sonic,oMap(a0)		; Mappings
	move.w	#160+128,oX(a0)			; Set position
	move.w	#288+128,oY(a0)
	
	moveq	#0,d0				; Set animation
	jsr	SetObjAnim(pc)
	
	addq.b	#1,oRoutine(a0)			; Enter in

; -------------------------------------------------------------------------

ObjSonic_Enter:	
	subq.w	#8,oY(a0)			; Move up
	cmpi.w	#120+128,oY(a0)			; Have we moved up enough?
	bne.s	.End				; If not, branch
	addq.b	#1,oRoutine(a0)			; Stop moving
	move.b	#120,oTimer(a0)

.End:	
	rts

; -------------------------------------------------------------------------

ObjSonic_Wait:	
	subq.b	#1,oTimer(a0)			; Decrement timer
	bne.s	.End				; If it hasn't run out, branch
	addq.b	#1,oRoutine(a0)			; Exit out

.End:	
	rts

; -------------------------------------------------------------------------

ObjSonic_Leave:	
	subq.w	#8,oY(a0)			; Move up
	cmpi.w	#-32+128,oY(a0)			; Have we moved up enough?
	bne.s	ObjSonic_Done			; If not, branch
	addq.b	#1,oRoutine(a0)			; Stop

; -------------------------------------------------------------------------

ObjSonic_Done:
	rts

; -------------------------------------------------------------------------

MapSpr_Sonic:
	include	"Time Warp Cutscene/Objects/Sonic/Data/Mappings.asm"
	even
	
; -------------------------------------------------------------------------
