; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Splash object (special stage)
; -------------------------------------------------------------------------

ObjSplash:
	moveq	#0,d0				; Run routine
	move.b	oRoutine(a0),d0
	add.w	d0,d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)
	
	bsr.w	DrawObject			; Draw sprite
	
	tst.b	timeStopped			; Is time stopped?
	beq.s	.End				; If not, branch
	bset	#0,oFlags(a0)			; Delete object

.End:
	rts

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjSplash_Init-.Index
	dc.w	ObjSplash_Large-.Index
	dc.w	ObjSplash_Small-.Index

; -------------------------------------------------------------------------

ObjSplash_Init:
	move.w	#$8582,oTile(a0)		; Base tile ID
	move.l	#MapSpr_Splash,oMap(a0)		; Mappings
	move.w	#128+128,oSprX(a0)		; Set sprite position
	move.w	#216+128,oSprY(a0)
	moveq	#0,d0				; Set large splash animation
	bsr.w	SetObjAnim
	move.w	#14,oTimer(a0)			; Set large splash timer
	addq.b	#1,oRoutine(a0)			; Set to large splash routine
	
	move.b	#FM_A2,d0			; Play splash sound
	bsr.w	PlayFMSound
	
	btst	#1,specStageFlags.w		; Are we in time attack mode?
	bne.s	ObjSplash_Large			; If not, branch
	; NOTE: The timer speed-up lasts shorter than the large splash animation.
	; The timer will go back to normal speed for the last few frames of the animation.
	move.b	#10,timerSpeedUp		; If so, set timer speed-up counter

; -------------------------------------------------------------------------

ObjSplash_Large:
	subq.w	#1,oTimer(a0)			; Decrement timer
	bne.s	.End				; If it hasn't run out yet, branch
	cmpi.b	#3,sonicObject+oPlayerStampC	; Is Sonic on a water stamp?
	bne.s	ObjSplash_Delete		; If not, branch
	
	moveq	#1,d0				; Set small splash animation
	bsr.w	SetObjAnim
	
	move.b	#2,oRoutine(a0)			; Set to small splash routine

.End:
	rts

; -------------------------------------------------------------------------

ObjSplash_Small:
	cmpi.b	#3,sonicObject+oPlayerStampC	; Is Sonic on a water stamp?
	bne.s	ObjSplash_Delete		; If not, branch
	
	tst.b	oAnimFrame(a0)			; Has the animation restarted?
	bne.s	.End				; If not, branch
	move.b	#2,timerSpeedUp			; If so, reset timer speed-up counter

.End:
	rts

; -------------------------------------------------------------------------

ObjSplash_Delete:
	bset	#0,oFlags(a0)			; Delete object
	rts

; -------------------------------------------------------------------------
; Delete splash object
; -------------------------------------------------------------------------

DeleteSplash:
	tst.b	splashObject+oID		; Is the splash object spawned in?
	beq.s	.End				; If not, branch
	bset	#0,splashObject+oFlags		; If so, delete it

.End:
	rts

; -------------------------------------------------------------------------
