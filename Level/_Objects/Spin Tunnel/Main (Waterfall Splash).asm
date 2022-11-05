; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Spin tunnel waterfall splash object
; -------------------------------------------------------------------------

ObjSpinSplash:
	moveq	#0,d0				; Run object routine
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jmp	.Index(pc,d0.w)

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjSpinSplash_Init-.Index	; Initialization
	dc.w	ObjSpinSplash_Main-.Index	; Main
	dc.w	ObjSpinSplash_Destroy-.Index	; Destruction

; -------------------------------------------------------------------------
; Initialization
; -------------------------------------------------------------------------

ObjSpinSplash_Init:
	addq.b	#2,oRoutine(a0)			; Advance routine

	ori.b	#%00000100,oSprFlags(a0)	; Set sprite flags
	move.l	#MapSpr_TunnelWaterfall,oMap(a0); Set mappings
	move.w	#$3E4,oTile(a0)			; Set base tile ID
	tst.b	timeZone
	bne.s	.NotPast
	move.w	#$39E,oTile(a0)

.NotPast:
	move.b	#1,oPriority(a0)		; Set priority

; -------------------------------------------------------------------------
; Main
; -------------------------------------------------------------------------

ObjSpinSplash_Main:
	lea	Ani_TunnelWaterfall,a1		; Animate sprite
	bsr.w	AnimateObject
	jmp	DrawObject			; Draw sprite

; -------------------------------------------------------------------------
; Waterfall splash object destruction routine
; -------------------------------------------------------------------------

ObjSpinSplash_Destroy:
	jmp	DeleteObject			; Delete ourselves

; -------------------------------------------------------------------------
