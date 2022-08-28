; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Time stone object (special stage)
; -------------------------------------------------------------------------

ObjTimeStone:
	moveq	#0,d0				; Run routine
	move.b	oRoutine(a0),d0
	add.w	d0,d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)
	
	bsr.w	DrawObject			; Draw sprite
	rts

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjTimeStone_Init-.Index
	dc.w	ObjTimeStone_Wait-.Index
	dc.w	ObjTimeStone_Fall-.Index
	dc.w	ObjTimeStone_Wait2-.Index

; -------------------------------------------------------------------------

ObjTimeStone_Init:
	move.w	#$E424,oTile(a0)		; Base tile ID
	move.l	#MapSpr_TimeStone,oMap(a0)
	move.w	#129+128,oSprX(a0)		; Set sprite position
	move.w	#-16+128,oSprY(a0)
	moveq	#0,d0				; Set animation
	bsr.w	SetObjAnim
	move.w	#30,oTimer(a0)			; Set wait timer
	addq.b	#1,oRoutine(a0)			; Start waiting

; -------------------------------------------------------------------------

ObjTimeStone_Wait:
	subq.w	#1,oTimer(a0)			; Decrement wait timer
	bne.s	.End				; If it hasn't run out, branch
	addq.b	#1,oRoutine(a0)			; Start falling

.End:
	rts

; -------------------------------------------------------------------------

ObjTimeStone_Fall:
	addq.w	#4,oSprY(a0)			; Move downwards
	cmpi.w	#208+128,oSprY(a0)		; Have we landed in Sonic's hands?
	bcs.s	.End				; If not, branch
	
	addq.b	#1,oRoutine(a0)			; Stop falling
	bset	#0,sparkleObject1+oFlags	; Delete sparkles
	bset	#0,sparkleObject2+oFlags
	move.w	#60,oTimer(a0)			; Set timer
	
	move.b	#$12,sonicObject+oRoutine	; Mark Sonic hold the time stone
	
	move.b	#FM_D9,d0			; Play time stone sound
	bsr.w	PlayFMSound

.End:
	rts

; -------------------------------------------------------------------------

ObjTimeStone_Wait2:
	subq.w	#1,oTimer(a0)			; Decrement timer
	bne.s	.End				; If it hasn't run out, branch
	move.b	#1,gotTimeStone			; Mark time stone as retrieved

.End:
	rts

; -------------------------------------------------------------------------
; Time stone sparkle 1 object
; -------------------------------------------------------------------------

ObjSparkle1:
	moveq	#0,d0				; Run routine
	move.b	oRoutine(a0),d0
	add.w	d0,d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)
	
	bsr.w	DrawObject			; Draw sprite
	rts


; -------------------------------------------------------------------------

.Index:
	dc.w	ObjSparkle1_Init-.Index
	dc.w	ObjSparkle1_Main-.Index

; -------------------------------------------------------------------------

ObjSparkle1_Init:
	move.w	#$E424,oTile(a0)		; Base tile ID
	move.l	#MapSpr_TimeStone,oMap(a0)	; Mappings
	moveq	#1,d0				; Set animation
	bsr.w	SetObjAnim
	addq.b	#1,oRoutine(a0)			; Set routine to main

; -------------------------------------------------------------------------

ObjSparkle1_Main:
	move.w	timeStoneObject+oSprX,oSprX(a0)	; Move with time stone
	move.w	timeStoneObject+oSprY,oSprY(a0)
	subi.w	#16,oSprY(a0)
	rts

; -------------------------------------------------------------------------
; Time stone sparkle 2 object
; -------------------------------------------------------------------------

ObjSparkle2:
	moveq	#0,d0				; Run routine
	move.b	oRoutine(a0),d0
	add.w	d0,d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)
	
	bsr.w	DrawObject			; Draw sprite
	rts


; -------------------------------------------------------------------------

.Index:
	dc.w	ObjSparkle2_Init-.Index
	dc.w	ObjSparkle2_Main-.Index

; -------------------------------------------------------------------------

ObjSparkle2_Init:
	move.w	#$E424,oTile(a0)		; Base tile ID
	move.l	#MapSpr_TimeStone,oMap(a0)	; Mappings
	moveq	#2,d0				; Set animation
	bsr.w	SetObjAnim
	addq.b	#1,oRoutine(a0)			; Set routine to main

; -------------------------------------------------------------------------

ObjSparkle2_Main:
	move.w	timeStoneObject+oSprX,oSprX(a0)	; Move with time stone
	move.w	timeStoneObject+oSprY,oSprY(a0)
	subi.w	#32,oSprY(a0)
	rts

; -------------------------------------------------------------------------

MapSpr_TimeStone:
	include	"Special Stage/Objects/Time Stone/Data/Mappings.asm"
	even
	
; -------------------------------------------------------------------------
