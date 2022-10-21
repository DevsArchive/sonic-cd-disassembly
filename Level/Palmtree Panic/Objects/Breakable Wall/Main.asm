; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Breakable wall object
; -------------------------------------------------------------------------

ObjBreakableWall:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjBreakableWall_Index(pc,d0.w),d0
	jmp	ObjBreakableWall_Index(pc,d0.w)
; End of function ObjBreakableWall

; -------------------------------------------------------------------------
ObjBreakableWall_Index:
	dc.w	ObjBreakableWall_Init-ObjBreakableWall_Index
	dc.w	ObjBreakableWall_Main-ObjBreakableWall_Index
	dc.w	ObjBreakableWall_Fall-ObjBreakableWall_Index
; -------------------------------------------------------------------------

ObjBreakableWall_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oSprFlags(a0)
	move.b	#1,oPriority(a0)
	move.b	#$10,oXRadius(a0)
	move.b	#$10,oWidth(a0)
	move.b	#$18,oYRadius(a0)
	move.b	#$EF,oColType(a0)
	move.w	#$44BE,oTile(a0)
	move.l	#MapSpr_BreakableWall,oMap(a0)
	move.b	oSubtype(a0),oMapFrame(a0)
; End of function ObjBreakableWall_Init

; -------------------------------------------------------------------------

ObjBreakableWall_Main:
	tst.b	oColStatus(a0)
	beq.s	.Solid
	clr.w	oColType(a0)
	addq.b	#2,oRoutine(a0)
	lea	objPlayerSlot.w,a1
	move.w	oXVel(a1),oVar2A(a0)
	move.w	oYVel(a1),oVar2E(a0)
	bra.s	.BreakUp

; -------------------------------------------------------------------------

.Solid:
	lea	objPlayerSlot.w,a1
	jsr	SolidObject
	jsr	DrawObject
	jmp	CheckObjDespawn

; -------------------------------------------------------------------------

.BreakUp:
	move.w	#FM_B0,d0
	jsr	PlayFMSound
	lea	objPlayerSlot.w,a6
	asr	oXVel(a6)
	lea	ObjBreakableWall_PieceFrames(pc),a5
	moveq	#0,d0
	move.b	oSubtype(a0),d0
	lsl.w	#3,d0
	adda.w	d0,a5
	lea	ObjBreakableWall_PieceDeltas(pc),a4
	lea	ObjBreakableWall_PieceSpeeds(pc),a3
	moveq	#5,d6
	movea.w	a0,a1
	bra.s	.InitLoop

; -------------------------------------------------------------------------

.Loop:
	jsr	FindObjSlot
	bne.s	ObjBreakableWall_Fall
	move.b	oID(a0),oID(a1)
	move.b	oRoutine(a0),oRoutine(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	move.b	oSprFlags(a0),oSprFlags(a1)
	move.b	oPriority(a0),oPriority(a1)
	move.l	oMap(a0),oMap(a1)
	move.w	oTile(a0),oTile(a1)

.InitLoop:
	move.b	#8,oXRadius(a1)
	move.b	#8,oWidth(a1)
	move.b	#8,oYRadius(a1)
	move.b	(a5)+,oMapFrame(a1)
	move.w	(a4)+,d0
	move.w	(a4)+,d1
	add.w	d0,oX(a1)
	add.w	d1,oY(a1)
	move.l	(a3)+,d0
	move.l	(a3)+,oVar2E(a1)
	tst.w	oXVel(a6)
	bpl.s	.NoFlip
	neg.l	d0

.NoFlip:
	move.l	d0,oVar2A(a1)
	dbf	d6,.Loop
; End of function ObjBreakableWall_Main

; -------------------------------------------------------------------------

ObjBreakableWall_Fall:
	addi.l	#$4000,oVar2E(a0)
	move.l	oVar2A(a0),d0
	move.l	oVar2E(a0),d1
	add.l	d0,oX(a0)
	add.l	d1,oY(a0)
	lea	objPlayerSlot.w,a1
	move.w	oY(a1),d0
	sub.w	oY(a0),d0
	cmpi.w	#-$E0,d0
	ble.s	.Destroy
	jmp	DrawObject

; -------------------------------------------------------------------------

.Destroy:
	jmp	DeleteObject
; End of function ObjBreakableWall_Fall

; -------------------------------------------------------------------------
MapSpr_BreakableWall:
	include	"Level/Palmtree Panic/Objects/Breakable Wall/Data/Mappings.asm"
	even
ObjBreakableWall_PieceFrames:
	dc.b	8, 9,	8, $C, $D, $C, 0, 0
	dc.b	8, 9, 8, $A, $B, $A, 0, 0
	dc.b	$A, $B, $A, $A, $B, $A, 0, 0
	dc.b	$A, $B, $A, $C, $D, $C, 0, 0
	dc.b	9, 8, 9, $D, $C, $D, 0, 0
	dc.b	9, 8, 9, $B, $A, $B, 0, 0
	dc.b	$B, $A, $B, $B, $A, $B, 0, 0
	dc.b	$B, $A, $B, $D, $C, $D, 0, 0
ObjBreakableWall_PieceDeltas:
	dc.w	$FFF8, $FFF0
	dc.w	0,	$10
	dc.w	0,	$20
	dc.w	$10, 0
	dc.w	$10, $10
	dc.w	$10, $20
ObjBreakableWall_PieceSpeeds:
	dc.w	$FFFD, $97C
	dc.w	$FFFE, $B750
	dc.w	$FFFC, $25EE
	dc.w	0,	0
	dc.w	$FFFD, $97C
	dc.w	1,	$48B0
	dc.w	$FFFD, $97C
	dc.w	$FFFE, $4445
	dc.w	$FFFC, $97B5
	dc.w	0,	0
	dc.w	$FFFD, $97C
	dc.w	1,	$BBBB

; -------------------------------------------------------------------------
