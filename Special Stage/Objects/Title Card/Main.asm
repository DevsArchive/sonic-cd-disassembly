; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Title card object (special stage)
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Title card text object
; -------------------------------------------------------------------------

ObjTitleCardText:
	moveq	#0,d0				; Run routine
	move.b	oRoutine(a0),d0
	add.w	d0,d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	bsr.w	DrawObject			; Draw sprite
	rts

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjTitleCardText_Init-.Index
	dc.w	ObjTitleCardText_MoveLeft-.Index
	dc.w	ObjTitleCardText_Wait-.Index
	dc.w	ObjTitleCardText_MoveRight-.Index

; -------------------------------------------------------------------------

ObjTitleCardText_Init:
	move.w	#$8516,oTile(a0)		; Base tile ID
	move.l	#MapSpr_TitleCardText,oMap(a0)	; Mappings
	move.w	#328+128,oSprX(a0)		; Set position
	move.w	#112+128,oSprY(a0)
	moveq	#0,d0				; Set animation
	bsr.w	SetObjAnim
	addq.b	#1,oRoutine(a0)			; Start moving left

; -------------------------------------------------------------------------

ObjTitleCardText_MoveLeft:
	subi.w	#32,oSprX(a0)			; Move left
	cmpi.w	#184+128,oSprX(a0)		; Have we reached the target position?
	bhi.s	.End				; If not, branch
	move.w	#184+128,oSprX(a0)		; Set at target position
	move.w	#80,oTimer(a0)			; Set wait timer
	addq.b	#1,oRoutine(a0)			; Start waiting

.End:
	rts

; -------------------------------------------------------------------------

ObjTitleCardText_Wait:
	subq.w	#1,oTimer(a0)			; Decrement wait timer
	bne.s	.End				; If it hasn't run out, branch
	addq.b	#1,oRoutine(a0)			; Start moving right

.End:
	rts

; -------------------------------------------------------------------------

ObjTitleCardText_MoveRight:
	addi.w	#32,oSprX(a0)			; Move right
	cmpi.w	#336+128,oSprX(a0)		; Have we gone offscreen?
	bls.s	.End				; If not, branch
	bset	#0,oFlags(a0)			; Delete object

.End:
	rts

; -------------------------------------------------------------------------

MapSpr_TitleCardText:
	include	"Special Stage/Objects/Title Card/Data/Mappings (Text).asm"
	even

; -------------------------------------------------------------------------
; Title card bar object
; -------------------------------------------------------------------------

ObjTitleCardBar:
	moveq	#0,d0				; Run routine
	move.b	oRoutine(a0),d0
	add.w	d0,d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	bsr.w	DrawObject			; Draw sprite
	rts

; -------------------------------------------------------------------------
.Index:
	dc.w	ObjTitleCardBar_Init-.Index
	dc.w	ObjTitleCardBar_MoveDown-.Index
	dc.w	ObjTitleCardBar_Wait-.Index
	dc.w	ObjTitleCardBar_MoveUp-.Index
	dc.w	ObjTitleCardBar_Done-.Index

; -------------------------------------------------------------------------

ObjTitleCardBar_Init:
	move.w	#$8516,oTile(a0)		; Base tile ID
	move.l	#MapSpr_TitleCardBar,oMap(a0)	; Mappings
	move.w	#116+128,oSprX(a0)		; Set position
	move.w	#-96+128,oSprY(a0)
	moveq	#0,d0				; Set animation
	bsr.w	SetObjAnim
	addq.b	#1,oRoutine(a0)			; Start moving down

; -------------------------------------------------------------------------

ObjTitleCardBar_MoveDown:
	addi.w	#32,oSprY(a0)			; Move down
	cmpi.w	#112+128,oSprY(a0)		; Have we reached the target position?
	bcs.s	.End				; If not, branch
	move.w	#112+128,oSprY(a0)		; Set at target position
	move.w	#80,oTimer(a0)			; Set wait timer
	addq.b	#1,oRoutine(a0)			; Start waiting

.End:
	rts

; -------------------------------------------------------------------------

ObjTitleCardBar_Wait:
	subq.w	#1,oTimer(a0)			; Decrement wait timer
	bne.s	.CheckSonic			; If it hasn't run out, branch
	addq.b	#1,oRoutine(a0)			; Start moving up

.CheckSonic:
	cmpi.w	#50,oTimer(a0)			; Should Sonic do his starting pose?
	bne.s	.End				; If not, branch
	move.b	#$15,sonicObject+oRoutine	; If so, make him do so

.End:
	rts

; -------------------------------------------------------------------------

ObjTitleCardBar_MoveUp:
	subi.w	#32,oSprY(a0)			; Move up
	bpl.s	.End				; If we haven't gone offscreen, branch
	move.w	#3,oTimer(a0)			; Set wait timer
	bset	#2,oFlags(a0)			; Disable drawing
	addq.b	#1,oRoutine(a0)			; Start waiting
	move.b	#1,sonicObject+oRoutine		; Let Sonic movie

.End:
	rts

; -------------------------------------------------------------------------

ObjTitleCardBar_Done:
	subq.w	#1,oTimer(a0)			; Decrement wait timer
	bne.s	.End				; If it hasn't run out, branch
	bset	#0,oFlags(a0)			; Delete object
	move.b	#0,stageInactive		; Mark stage as active

.End:
	rts

; -------------------------------------------------------------------------

MapSpr_TitleCardBar:
	include	"Special Stage/Objects/Title Card/Data/Mappings (Bar).asm"
	even

; -------------------------------------------------------------------------
