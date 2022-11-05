; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Freezer object
; -------------------------------------------------------------------------

oFreezerTime	EQU	oVar2A
oFreezerParent	EQU	oVar2A
oFreezerBreak	EQU	oVar30
oFreezerPiece	EQU	oVar31

; -------------------------------------------------------------------------

ObjFreezer:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)
	jsr	DrawObject
	jmp	CheckObjDespawn
	
; -------------------------------------------------------------------------

.Index:
	dc.w	ObjFreezer_Init-.Index
	dc.w	ObjFreezer_Main-.Index
	dc.w	ObjFreezer_Freezer-.Index
	dc.w	ObjFreezer_Reset-.Index
	dc.w	ObjFreezer_IceBlock-.Index
	dc.w	ObjFreezer_IceLanded-.Index
	dc.w	ObjFreezer_IcePiece-.Index
	
; -------------------------------------------------------------------------

ObjFreezer_Init:
	ori.b	#4,oSprFlags(a0)
	move.w	#$310,oTile(a0)
	move.l	#MapSpr_Freezer,oMap(a0)
	move.b	#120,oFreezerTime(a0)
	addq.b	#2,oRoutine(a0)

; -------------------------------------------------------------------------

ObjFreezer_Main:
	tst.b	oFreezerTime(a0)
	beq.s	.End
	subq.b	#1,oFreezerTime(a0)
	bne.s	.End
	
	jsr	FindObjSlot
	bne.s	.End
	
	move.l	a0,oFreezerParent(a1)
	move.b	#5,oID(a1)
	move.b	#3,oPriority(a1)
	ori.b	#4,oSprFlags(a1)
	move.w	oTile(a0),oTile(a1)
	move.l	oMap(a0),oMap(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	addi.w	#36,oY(a1)
	move.b	#4,oRoutine(a1)
	
.End:
	rts

; -------------------------------------------------------------------------

ObjFreezer_Freezer:
	bsr.w	ObjFreezer_ChkSonicFreeze
	lea	Ani_Freezer,a1
	jmp	AnimateObject

; -------------------------------------------------------------------------

ObjFreezer_Reset:
	movea.l	oFreezerParent(a0),a1
	move.b	#120,oFreezerTime(a1)
	jmp	DeleteObject

; -------------------------------------------------------------------------

ObjFreezer_IceBlock:
	addi.w	#$38,oYVel(a0)
	move.l	oY(a0),d3
	move.w	oYVel(a0),d0
	ext.l	d0
	asl.l	#8,d0
	add.l	d0,d3
	move.l	d3,oY(a0)
	
	jsr	ObjGetFloorDist
	tst.w	d1
	bpl.s	.UpdateY
	
	move.w	#SCMD_BREAKSFX,d0
	jsr	SubCPUCmd
	move.b	#$F,oFreezerBreak(a0)
	add.w	d1,oY(a0)
	addq.b	#2,oRoutine(a0)
		
.UpdateY:
	movea.l	oFreezerParent(a0),a1
	move.l	oY(a0),oY(a1)
	rts

; -------------------------------------------------------------------------

ObjFreezer_IceLanded:
	movea.l	oFreezerParent(a0),a1
	tst.b	oFreezerBreak(a0)
	beq.s	.Hurt
	subq.b	#1,oFreezerBreak(a0)
	
	move.b	p1CtrlTap.w,d0
	andi.b	#$70,d0
	beq.s	.End
	
	bclr	#0,oPlayerCtrl(a1)
	bclr	#6,oPlayerCtrl(a1)
	
	move.w	#-$680,oYVel(a1)
	move.b	#$E,oYRadius(a1)
	move.b	#7,oXRadius(a1)
	addq.w	#5,oY(a1)
	bset	#2,oFlags(a1)
	bclr	#5,oFlags(a1)
	move.b	#2,oAnim(a1)
	move.w	#FM_JUMP,d0
	jsr	PlayFMSound
	
	bra.s	.Broken
	
.Hurt:
	movea.l	a0,a3
	movea.l	a0,a2
	movea.l	oFreezerParent(a0),a0
	bclr	#0,oPlayerCtrl(a0)
	bclr	#6,oPlayerCtrl(a0)
	jsr	HurtPlayer
	movea.l	a3,a0

.Broken:
	addq.b	#2,oRoutine(a0)
	move.b	#$A,oMapFrame(a0)
	move.b	#20,oFreezerBreak(a0)
	move.b	#2,oFreezerPiece(a0)
	bsr.w	ObjFreezer_IceBlockBreak

.End:
	rts

; -------------------------------------------------------------------------

ObjFreezer_IcePiece:
	subq.b	#1,oFreezerBreak(a0)
	bne.s	.Move
	
	cmpi.b	#$B,oMapFrame(a0)
	beq.s	.Delete
	
	moveq	#0,d0
	move.b	oFreezerPiece(a0),d0
	add.w	d0,d0
	move.w	.Pieces(pc,d0.w),d0
	lea	.Pieces(pc,d0.w),a3
	moveq	#4-1,d6
	bsr.w	ObjFreezer_IcePieceBreak
	
.Delete:
	jmp	DeleteObject
	
.Move:
	move.w	oXVel(a0),d0
	add.w	d0,oX(a0)
	move.w	oYVel(a0),d0
	add.w	d0,oY(a0)
	rts

; -------------------------------------------------------------------------

.Pieces:
	dc.w	.Piece0-.Pieces
	dc.w	.Piece1-.Pieces
	dc.w	.Piece2-.Pieces

.Piece0:
	dc.b	0, 0, $A, $B, 0, 0, -1, 0
	dc.b	0, 0, $A, $B, 0, 1, 0, 0
	dc.b	0, 0, $A, $B, 0, 0, 1, 0
	dc.b	0, 0, $A, $B, 0, -1, 0, 0

.Piece1:
	dc.b	0, 0, $A, $B, 0, -1, -1, 0
	dc.b	0, 0, $A, $B, 0, 1, -1, 0
	dc.b	0, 0, $A, $B, 0, 0, 1, 0
	dc.b	0, 0, 1, $B, 0, -1, 0, 0

.Piece2:
	dc.b	0, 0, $A, $B, 0, -1, -1, 0
	dc.b	0, 0, $A, $B, 0, 1, -1, 0
	dc.b	0, 0, $A, $B, 0, 1, 1, 0
	dc.b	0, 0, $A, $B, 0, -1, 1, 0

; -------------------------------------------------------------------------

ObjFreezer_IceBlockBreak:
	moveq	#6-1,d6
	lea	ObjFreezer_IceBlockPieces,a3

ObjFreezer_IcePieceBreak:
	moveq	#0,d1
	
.Loop:
	jsr	FindObjSlot
	bne.s	.End
	
	move.b	#5,oID(a1)
	move.b	#$C,oRoutine(a1)
	ori.b	#4,oSprFlags(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	move.w	#$2E1,oTile(a1)
	move.l	#MapSpr_Freezer,oMap(a1)
	
	move.b	(a3,d1.w),d2
	ext.w	d2
	add.w	d2,oX(a1)
	move.b	1(a3,d1.w),d2
	ext.w	d2
	add.w	d2,oY(a1)
	
	move.b	2(a3,d1.w),oFreezerBreak(a1)
	move.b	3(a3,d1.w),oMapFrame(a1)
	move.b	4(a3,d1.w),d2
	or.b	d2,oSprFlags(a1)
	
	move.b	5(a3,d1.w),d2
	ext.w	d2
	move.w	d2,oXVel(a1)
	move.b	6(a3,d1.w),d2
	ext.w	d2
	move.w	d2,oYVel(a1)
	
	move.b	7(a3,d1.w),oFreezerPiece(a1)
	
	addq.w	#8,d1
	dbf	d6,.Loop
	
.End:
	rts

; -------------------------------------------------------------------------

ObjFreezer_IceBlockPieces:
	dc.b	-$10, -$C, $A, 9, 0, -1, -1, 0
	dc.b	-$10, $C, $A, 9, 2, -1, 1, 0
	dc.b	$10, -$C, $A, 9, 1, 1, -1, 0
	dc.b	$10, $C, $A, 9, 3, 1, 1, 0
	dc.b	0, -$10, $F, $A, 1, 0, -1, 1
	dc.b	0, $10, $F, $A, 3, 0, 1, 1

; -------------------------------------------------------------------------

ObjFreezer_FreezeSonic:
	movea.l	a1,a2
	jsr	FindObjSlot
	bne.s	.End
	
	bset	#0,oPlayerCtrl(a2)
	bset	#6,oPlayerCtrl(a2)
	move.l	a2,oFreezerParent(a1)
	
	move.b	#5,oID(a1)
	ori.b	#4,oSprFlags(a1)
	move.w	oX(a2),oX(a1)
	move.w	oY(a2),oY(a1)
	move.w	#$2E1,oTile(a1)
	move.l	#MapSpr_Freezer,oMap(a1)
	move.b	#$18,oXRadius(a1)
	move.b	#$18,oWidth(a1)
	move.b	#$18,oYRadius(a1)
	move.b	#8,oMapFrame(a1)
	move.b	#8,oRoutine(a1)
	
.End:
	rts

; -------------------------------------------------------------------------

ObjFreezer_ChkSonicFreeze:
	cmpi.b	#1,oAnim(a0)
	bne.s	.End
	
	lea	objPlayerSlot.w,a1
	cmpi.b	#$2B,oAnim(a1)
	beq.s	.End
	bsr.s	ObjFreezer_CheckSonic
	bne.s	ObjFreezer_FreezeSonic
	
.End:
	rts

; -------------------------------------------------------------------------

ObjFreezer_CheckSonic:
	tst.b	invincible
	bne.s	.NoFreeze
	tst.b	timeWarp
	bne.s	.NoFreeze
	cmpi.b	#4,oRoutine(a1)
	bcc.s	.NoFreeze
	tst.b	oPlayerCtrl(a1)
	bne.s	.NoFreeze
	
	move.b	oXRadius(a1),d1
	ext.w	d1
	addi.w	#16,d1
	move.w	oX(a1),d0
	sub.w	oX(a0),d0
	add.w	d1,d0
	bmi.s	.NoFreeze
	add.w	d1,d1
	cmp.w	d1,d0
	bcc.s	.NoFreeze
	
	move.b	oYRadius(a1),d1
	ext.w	d1
	addi.w	#32,d1
	move.w	oY(a1),d0
	sub.w	oY(a0),d0
	add.w	d1,d0
	bmi.s	.NoFreeze
	add.w	d1,d1
	cmp.w	d1,d0
	bcc.s	.NoFreeze
	
.Freeze:
	moveq	#1,d0
	rts
	
.NoFreeze:
	moveq	#0,d0
	rts
	
; -------------------------------------------------------------------------

Ani_Freezer:
	include	"Level/Wacky Workbench/Objects/Freezer/Data/Animations.asm"
	even

MapSpr_Freezer:
	include	"Level/Wacky Workbench/Objects/Freezer/Data/Mappings.asm"
	even

; -------------------------------------------------------------------------
