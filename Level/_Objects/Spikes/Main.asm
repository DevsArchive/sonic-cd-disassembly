; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Spikes object
; -------------------------------------------------------------------------

ObjSpikes:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjSpikes_Index(pc,d0.w),d0
	jmp	ObjSpikes_Index(pc,d0.w)
; End of function ObjSpikes

; -------------------------------------------------------------------------
ObjSpikes_Index:dc.w	ObjSpikes_Init-ObjSpikes_Index
	dc.w	ObjSpikes_Main-ObjSpikes_Index
; -------------------------------------------------------------------------

ObjSpikes_Init:
	addq.b	#2,oRoutine(a0)
	move.l	#MapSpr_Spikes,oMap(a0)
	ori.b	#4,oRender(a0)
	move.b	#3,oPriority(a0)
	moveq	#$A,d0
	jsr	LevelObj_SetBaseTile(pc)
	move.b	#$10,oWidth(a0)
	move.b	#8,oYRadius(a0)
	btst	#1,oRender(a0)
	beq.s	ObjSpikes_Main
	move.b	#$12,oWidth(a0)
	move.b	#$83,oColType(a0)
; End of function ObjSpikes_Init

; -------------------------------------------------------------------------

ObjSpikes_Main:
	lea	objPlayerSlot.w,a1
	move.w	oY(a1),d0
	sub.w	oY(a0),d0
	bcc.s	.AbsDY
	neg.w	d0

.AbsDY:
	cmpi.w	#$20,d0
	bcc.s	.Display
	btst	#1,oRender(a0)
	beq.s	.ChkStand
	lea	objPlayerSlot.w,a1
	jsr	SolidObject
	bra.s	.Display

; -------------------------------------------------------------------------

.ChkStand:
	jsr	SolidObject
	beq.s	.Display
	btst	#3,oStatus(a0)
	beq.s	.Display
	tst.b	timeWarpFlag
	bne.s	.Display
	tst.b	invincibleFlag
	bne.s	.Display
	move.l	a0,-(sp)
	movea.l	a0,a2
	lea	objPlayerSlot.w,a0
	cmpi.b	#4,oRoutine(a0)
	bcc.s	.Restore
	tst.w	oPlayerHurt(a0)
	bne.s	.Restore
	move.l	oY(a0),d3
	move.w	oYVel(a0),d0
	ext.l	d0
	asl.l	#8,d0
	sub.l	d0,d3
	move.l	d3,oY(a0)
	jsr	HurtPlayer

.Restore:
	movea.l	(sp)+,a0

.Display:
	jsr	DrawObject
	jmp	CheckObjDespawnTime
; End of function ObjSpikes_Main

; -------------------------------------------------------------------------
MapSpr_Spikes:
	include	"Level/_Objects/Spikes/Data/Mappings.asm"
	even

; -------------------------------------------------------------------------
