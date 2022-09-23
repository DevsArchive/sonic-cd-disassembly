; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; DA Garden Eggman object
; -------------------------------------------------------------------------

ObjEggman:
	lea	.Index,a1			; Run routine
	jmp	RunObjRoutine

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjEggman_Init-.Index
	dc.w	ObjEggman_Main-.Index

; -------------------------------------------------------------------------

ObjEggman_Init:
	addi.w	#$4000,oTile(a0)		; Set to sprite palette
	move.w	#0,oAnimFrame(a0)		; Reset animation
	lea	MapSpr_Eggman(pc),a1
	move.l	a1,oMap(a0)
	move.w	2(a1),oAnimTime(a0)
	clr.w	oXOffset(a0)			; Reset position offset
	clr.w	oYOffset(a0)
	
	move.b	#3,oTimer(a0)			; Set face timer
	move.w	#1,oRoutine(a0)			; Set to main routine
	rts

; -------------------------------------------------------------------------

ObjEggman_Main:
	tst.b	oTimer(a0)			; Has the face timer run out?
	ble.s	.ChkHeadTurn			; If not, branch
	subq.b	#1,oTimer(a0)			; Decrement timer
	bgt.s	.Move				; If it hasn't run out, branch
	lea	MapSpr_Eggman(pc),a3		; Turn our head back
	move.l	a3,oMap(a0)

.ChkHeadTurn:
	jsr	Random(pc)			; Should we turn our head?
	andi.l	#$7FFF,d0
	move.w	d0,d1
	divs.w	#16,d0
	swap	d0
	tst.w	d0
	bne.s	.Move				; If not, branch
	
	divs.w	#16,d1				; Set face timer
	swap	d1
	addi.w	#32,d1
	move.b	d1,oTimer(a0)
	lea	MapSpr_EggmanTurn(pc),a3	; Turn head
	move.l	a3,oMap(a0)

.Move:
	bsr.w	ObjMoveFloat
	rts

; -------------------------------------------------------------------------
