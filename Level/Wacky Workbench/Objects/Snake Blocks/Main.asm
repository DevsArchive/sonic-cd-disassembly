; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Snake blocks object
; -------------------------------------------------------------------------

oSnakePath	EQU	oVar2C
oSnakeIndex	EQU	oVar32
oSnakeSpawn	EQU	oVar34

; -------------------------------------------------------------------------
; Main block
; -------------------------------------------------------------------------

ObjSnakeBlocks:
	tst.b	oSubtype(a0)
	bmi.w	ObjSnakeSub
	
ObjSnakeMain:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)
	
	lea	objPlayerSlot.w,a1
	jsr	SolidObject
	jsr	DrawObject
	jmp	CheckObjDespawn

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjSnakeMain_Init-.Index
	dc.w	ObjSnakeMain_Main-.Index
	
; -------------------------------------------------------------------------

ObjSnakeMain_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oSprFlags(a0)
	move.b	#1,oPriority(a0)
	move.b	#16,oXRadius(a0)
	move.b	#16,oWidth(a0)
	move.b	#16,oYRadius(a0)
	move.w	#$3A8,oTile(a0)
	move.l	#MapSpr_SnakeBlocks,oMap(a0)
	move.w	a0,oSnakeParent(a0)
	st	oSnakeSpawn(a0)
	move.w	#0,oSnakeIndex(a0)

; -------------------------------------------------------------------------

ObjSnakeMain_Main:
	tst.b	oSnakeSpawn(a0)
	beq.s	.End
	sf	oSnakeSpawn(a0)
	
	lea	ObjSnakeBlocks_Paths(pc),a1
	moveq	#0,d0
	move.b	oSubtype(a0),d0
	add.w	d0,d0
	adda.w	(a1,d0.w),a1
	move.w	oSnakeIndex(a0),d0
	adda.w	(a1,d0.w),a1
	move.l	a1,oSnakePath(a0)
	
	addq.w	#2,oSnakeIndex(a0)
	cmpi.w	#8,oSnakeIndex(a0)
	blt.s	.SpawnBlock
	clr.w	oSnakeIndex(a0)
	
.SpawnBlock:
	bsr.w	ObjSnakeBlocks_Spawn
	beq.s	.End
	jmp	DeleteObject
	
.End:
	rts

; -------------------------------------------------------------------------
; Sub block
; -------------------------------------------------------------------------

oSnakeParent	EQU	oVar2A
oSnakeTime	EQU	oVar30
oSnakeSolidYVel	EQU	oVar34
oSnakePrev	EQU	oVar36
oSnakeXVel	EQU	oVar38
oSnakeYVel	EQU	oVar3C

; -------------------------------------------------------------------------

ObjSnakeSub:
	movea.w	oSnakeParent(a0),a1
	cmpi.b	#$2A,oID(a1)
	bne.w	ObjSnakeSub_Delete
	move.b	oSubtype2(a0),d0
	cmp.b	oSubtype2(a1),d0
	bne.w	ObjSnakeSub_Delete
	
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)
	
	lea	objPlayerSlot.w,a1
	jsr	SolidObject
	jmp	DrawObject

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjSnakeSub_Init-.Index
	dc.w	ObjSnakeSub_Move-.Index
	dc.w	ObjSnakeSub_StartWait-.Index
	dc.w	ObjSnakeSub_Wait-.Index
	dc.w	ObjSnakeSub_WaitMove-.Index
	dc.w	ObjSnakeSub_StartMoveBack-.Index
	dc.w	ObjSnakeSub_MoveBack-.Index
	dc.w	ObjSnakeSub_StartWait2-.Index
	dc.w	ObjSnakeSub_Wait2-.Index
	dc.w	ObjSnakeSub_Done-.Index

; -------------------------------------------------------------------------

ObjSnakeSub_Init:
	addq.b	#2,oRoutine(a0)
	move.w	#63,oSnakeTime(a0)
	move.l	#0,oSnakeXVel(a0)
	move.l	#0,oSnakeYVel(a0)
	
	movea.l	oSnakePath(a0),a1
	move.b	-1(a1),d0
	bne.s	.NotUp
	move.l	#-$8000,oSnakeYVel(a0)
	
.NotUp:
	subq.b	#1,d0
	bne.s	.NotRight
	move.l	#$8000,oSnakeXVel(a0)
	
.NotRight:
	subq.b	#1,d0
	bne.s	.NotDown
	move.l	#$8000,oSnakeYVel(a0)
	
.NotDown:
	subq.b	#1,d0
	bne.s	.NotLeft
	move.l	#-$8000,oSnakeXVel(a0)
	
.NotLeft:
	movea.w	oSnakeParent(a0),a1
	cmpi.b	#2,oSubtype(a1)
	bne.s	ObjSnakeSub_Move
	
	moveq	#1,d0
	tst.w	oSnakeYVel(a0)
	bpl.s	.SetSolidYVel
	moveq	#-1,d0
	
.SetSolidYVel:
	move.w	d0,oSnakeSolidYVel(a0)
	move.w	d0,oYVel(a0)

; -------------------------------------------------------------------------

ObjSnakeSub_Move:
	move.l	oSnakeXVel(a0),d0
	add.l	d0,oX(a0)
	move.l	oSnakeYVel(a0),d0
	add.l	d0,oY(a0)
	
	subq.w	#1,oSnakeTime(a0)
	bpl.s	.End
	addq.b	#2,oRoutine(a0)
	
.End:
	rts

; -------------------------------------------------------------------------

ObjSnakeSub_StartWait:
	addq.b	#2,oRoutine(a0)
	clr.w	oYVel(a0)
	
	move.w	#30,d0
	cmpi.b	#2,oSubtype(a1)
	bne.s	.SetTime
	move.w	#0,d0
	
.SetTime:
	move.w	d0,oSnakeTime(a0)

; -------------------------------------------------------------------------

ObjSnakeSub_Wait:
	subq.w	#1,oSnakeTime(a0)
	bpl.s	.End
	addq.b	#2,oRoutine(a0)
	
	bsr.w	ObjSnakeBlocks_Spawn
	beq.s	.End
	addq.b	#2,oRoutine(a0)
	movea.w	oSnakeParent(a0),a1
	st	oSnakeSpawn(a1)
	
.End:
	rts

; -------------------------------------------------------------------------

ObjSnakeSub_WaitMove:
	rts

; -------------------------------------------------------------------------

ObjSnakeSub_StartMoveBack:
	addq.b	#2,oRoutine(a0)
	move.w	#63,oSnakeTime(a0)
	move.w	oSnakeSolidYVel(a0),oYVel(a0)
	neg.w	oYVel(a0)

; -------------------------------------------------------------------------

ObjSnakeSub_MoveBack:
	move.l	oSnakeXVel(a0),d0
	sub.l	d0,oX(a0)
	move.l	oSnakeYVel(a0),d0
	sub.l	d0,oY(a0)
	
	subq.w	#1,oSnakeTime(a0)
	bpl.s	.End
	addq.b	#2,oRoutine(a0)
	
.End:
	rts

; -------------------------------------------------------------------------

ObjSnakeSub_StartWait2:
	addq.b	#2,oRoutine(a0)
	clr.w	oYVel(a0)
	
	move.w	#30,d0
	cmpi.b	#2,oSubtype(a1)
	bne.s	.SetTime
	move.w	#0,d0
	
.SetTime:
	move.w	d0,oSnakeTime(a0)

; -------------------------------------------------------------------------

ObjSnakeSub_Wait2:
	subq.w	#1,oSnakeTime(a0)
	bpl.s	.End
	
	movea.w	oSnakePrev(a0),a1
	tst.b	oSubtype(a1)
	bpl.s	.Done
	addq.b	#2,oRoutine(a1)
	
.Done:
	addq.b	#2,oRoutine(a0)
	
.End:
	rts

; -------------------------------------------------------------------------

ObjSnakeSub_Done:
	lea	objPlayerSlot.w,a1
	jsr	SolidObject
	beq.s	.Done
	jsr	GetOffObject
	
.Done:
	addq.l	#4,sp

; -------------------------------------------------------------------------

ObjSnakeSub_Delete:
	jmp	DeleteObject

; -------------------------------------------------------------------------

ObjSnakeBlocks_Spawn:
	movea.l	oSnakePath(a0),a6
	tst.b	(a6)+
	bmi.s	.End
	jsr	FindObjSlot
	bne.s	.End
	
	movea.l	a0,a2
	movea.l	a1,a3
	rept	oSnakePath/4
		move.l	(a2)+,(a3)+
	endr
	if (oSnakePath&2)<>0
		move.w	(a2)+,(a3)+
	endif
	if (oSnakePath&1)<>0
		move.b	(a2)+,(a3)+
	endif
	
	move.b	#-1,oSubtype(a1)
	move.w	a0,oSnakePrev(a1)
	move.l	a6,oSnakePath(a1)
	addq.b	#1,oPriority(a1)
	clr.b	oRoutine(a1)
	
.End:
	rts

; -------------------------------------------------------------------------

MapSpr_SnakeBlocks:
	include	"Level/Wacky Workbench/Objects/Snake Blocks/Data/Mappings.asm"
	even

; -------------------------------------------------------------------------

ObjSnakeBlocks_Paths:
	dc.w ObjSnakeBlocks_Path0-ObjSnakeBlocks_Paths
	dc.w ObjSnakeBlocks_Path1-ObjSnakeBlocks_Paths
	dc.w ObjSnakeBlocks_Path2-ObjSnakeBlocks_Paths
	dc.w ObjSnakeBlocks_Path3-ObjSnakeBlocks_Paths
	dc.w ObjSnakeBlocks_Path4-ObjSnakeBlocks_Paths
		
ObjSnakeBlocks_Path0:
	dc.w unk_20EE9A-ObjSnakeBlocks_Path0
	dc.w unk_20EE9E-ObjSnakeBlocks_Path0
	dc.w unk_20EEA2-ObjSnakeBlocks_Path0
	dc.w unk_20EEA6-ObjSnakeBlocks_Path0
	
ObjSnakeBlocks_Path3:
	dc.w unk_20EEA6-ObjSnakeBlocks_Path3
	dc.w unk_20EEA2-ObjSnakeBlocks_Path3
	dc.w unk_20EE9E-ObjSnakeBlocks_Path3
	dc.w unk_20EE9A-ObjSnakeBlocks_Path3
	
unk_20EE9A:
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	$FF
	
unk_20EE9E:
	dc.b	1
	dc.b	1
	dc.b	1
	dc.b	$FF
	
unk_20EEA2:
	dc.b	2 
	dc.b	2
	dc.b	2
	dc.b	$FF
	
unk_20EEA6:
	dc.b	3
	dc.b	3
	dc.b	3
	dc.b	$FF
	
ObjSnakeBlocks_Path1:
	dc.w unk_20EEB2-ObjSnakeBlocks_Path1
	dc.w unk_20EEB6-ObjSnakeBlocks_Path1
	dc.w unk_20EEBA-ObjSnakeBlocks_Path1
	dc.w unk_20EEBE-ObjSnakeBlocks_Path1
	
unk_20EEB2:
	dc.b	0
	dc.b	0
	dc.b	1
	dc.b	$FF
	
unk_20EEB6:
	dc.b	1
	dc.b	0
	dc.b	1
	dc.b	$FF
	
unk_20EEBA:
	dc.b	2
	dc.b	2
	dc.b	1
	dc.b	$FF
	
unk_20EEBE:
	dc.b	3
	dc.b	3
	dc.b	3
	dc.b	$FF
	
ObjSnakeBlocks_Path2:
	dc.w unk_20EECA-ObjSnakeBlocks_Path2
	dc.w unk_20EECD-ObjSnakeBlocks_Path2
	dc.w unk_20EECA-ObjSnakeBlocks_Path2
	dc.w unk_20EECD-ObjSnakeBlocks_Path2
	
unk_20EECA:
	dc.b	0 
	dc.b	0
	dc.b	$FF
	
unk_20EECD:
	dc.b	2 
	dc.b	2
	dc.b	$FF
	
ObjSnakeBlocks_Path4:
	dc.w unk_20EED8-ObjSnakeBlocks_Path4
	dc.w unk_20EEDC-ObjSnakeBlocks_Path4
	dc.w unk_20EEE0-ObjSnakeBlocks_Path4
	dc.w unk_20EEE4-ObjSnakeBlocks_Path4
	
unk_20EED8:
	dc.b	1 
	dc.b	1
	dc.b	0
	dc.b	$FF
	
unk_20EEDC:
	dc.b	2
	dc.b	3
	dc.b	3
	dc.b	$FF
	
unk_20EEE0:
	dc.b	3
	dc.b	0
	dc.b	3
	dc.b	$FF
	
unk_20EEE4:
	dc.b	0
	dc.b	1
	dc.b	0
	dc.b	$FF

; -------------------------------------------------------------------------
