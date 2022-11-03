; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Object time zone check functions
; -------------------------------------------------------------------------

DestroyOnGoodFuture:
	tst.b	goodFuture
	beq.s	.End
	cmpi.b	#1,timeZone
	bne.s	.Destroy
	tst.b	oSubtype(a0)
	beq.s	.End

.Destroy:
	move.w	oX(a0),d5
	move.w	oY(a0),d6
	jsr	DeleteObject
	move.w	d5,oX(a0)
	move.w	d6,oY(a0)
	move.b	#$18,oID(a0)
	tst.b	oSprFlags(a0)
	bpl.s	.NoReturn
	move.w	#FM_EXPLODE,d0
	jsr	PlayFMSound

.NoReturn:
	addq.l	#4,sp

.End:
	rts

; -------------------------------------------------------------------------

CheckAnimalPrescence:
	tst.b	oSubtype(a0)
	bmi.s	.End
	cmpi.b	#2,timeZone
	bge.s	.ChkGoodFuture
	tst.b	projDestroyed
	bne.s	.End
	addq.l	#4,sp
	jmp	CheckObjDespawn

.ChkGoodFuture:
	tst.b	goodFuture
	bne.s	.End
	addq.l	#4,sp
	jmp	DeleteObject

.End:
	rts

; -------------------------------------------------------------------------
