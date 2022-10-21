; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Goddess statue object
; -------------------------------------------------------------------------

oGoddessTime	EQU	oVar2A
oGoddessCount	EQU	oVar2B

; -------------------------------------------------------------------------

ObjGoddessStatue:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)
	jmp	CheckObjDespawn
	
; -------------------------------------------------------------------------

.Index:
	dc.w	ObjGoddessStatue_Init-.Index
	dc.w	ObjGoddessStatue_Main-.Index
	dc.w	ObjGoddessStatue_SpitRings-.Index
	dc.w	ObjGoddessStatue_Done-.Index

; -------------------------------------------------------------------------

ObjGoddessStatue_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oSprFlags(a0)
	move.b	#50,oGoddessCount(a0)

; -------------------------------------------------------------------------

ObjGoddessStatue_Main:
	move.w	objPlayerSlot+oX.w,d0
	sub.w	oX(a0),d0
	addi.w	#16,d0
	bcs.s	.End
	cmpi.w	#32,d0
	bcc.s	.End
	
	move.w	objPlayerSlot+oY.w,d0
	sub.w	oY(a0),d0
	addi.w	#32,d0
	bcs.s	.End
	cmpi.w	#64,d0
	bcc.s	.End
	
	addq.b	#2,oRoutine(a0)
	
.End:
	rts

; -------------------------------------------------------------------------

ObjGoddessStatue_SpitRings:
	subq.b	#1,oGoddessTime(a0)
	bpl.s	ObjGoddessStatue_Done
	move.b	#10,oGoddessTime(a0)
	
	subq.b	#1,oGoddessCount(a0)
	bpl.s	ObjGoddessStatue_SpawnRing
	addq.b	#2,oRoutine(a0)

ObjGoddessStatue_Done:
	rts

; -------------------------------------------------------------------------

ObjGoddessStatue_SpawnRing:
	jsr	FindObjSlot
	bne.s	.End
	
	move.b	#$11,oID(a1)
	addq.b	#2,oRoutine(a1)
	move.b	#8,oYRadius(a1)
	move.b	#8,oXRadius(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	addi.w	#24,oX(a1)
	subi.w	#16,oY(a1)
	move.l	#MapSpr_Ring,oMap(a1)
	move.w	#$A7AE,oTile(a1)
	move.b	#3,oPriority(a1)
	move.b	#4,oSprFlags(a1)
	move.b	#$47,oColType(a1)
	move.b	#8,oWidth(a1)
	move.b	#8,oYRadius(a1)
	move.b	#$FF,ringLossAnimTimer
	
	move.w	#-$200,oYVel(a1)
	jsr	Random
	lsl.w	#1,d0
	andi.w	#$E,d0
	move.w	.XVels(pc,d0.w),oXVel(a1)
	
.End:
	rts

; -------------------------------------------------------------------------

.XVels:
	dc.w	-$100
	dc.w	-$80
	dc.w	0
	dc.w	$80
	dc.w	$100
	dc.w	$180
	dc.w	$200
	dc.w	$280

; -------------------------------------------------------------------------
