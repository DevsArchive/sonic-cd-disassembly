; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Palmtree Panic Act 1 Bad Future object art manager
; -------------------------------------------------------------------------

LoadCamPLCFull:
	lea	CameraPLC_Ranges(pc),a1
	moveq	#0,d0
	moveq	#0,d1
	move.w	cameraX.w,d0

.Loop:
	cmp.w	(a1)+,d0
	bcs.s	.LoadPLC
	addq.b	#2,d1
	bra.s	.Loop

; -------------------------------------------------------------------------

.LoadPLC:
	move.b	d1,lastCamPLC
	move.w	CameraPLCs_Full(pc,d1.w),d0
	jmp	LoadPLC
; END OF FUNCTION CHUNK	FOR LoadLevelData
; -------------------------------------------------------------------------

LoadCamPLCIncr:
	lea	CameraPLC_Ranges(pc),a1
	moveq	#0,d0
	moveq	#0,d1
	move.w	cameraX.w,d0

.Loop:
	cmp.w	(a1)+,d0
	bcs.s	.FoundRange
	addq.b	#2,d1
	bra.s	.Loop

; -------------------------------------------------------------------------

.FoundRange:
	cmp.b	lastCamPLC,d1
	bne.s	.LoadPLC
	rts

; -------------------------------------------------------------------------

.LoadPLC:
	move.b	d1,lastCamPLC
	move.w	CameraPLCs_Incr(pc,d1.w),d0
	jmp	InitPLC
; End of function LoadCamPLCIncr

; -------------------------------------------------------------------------
CameraPLC_Ranges:
	dc.w	$700
	dc.w	$1100
	dc.w	$1A00
	dc.w	$FFFF
CameraPLCs_Incr:
	dc.w	7
	dc.w	8
	dc.w	9
	dc.w	$A
CameraPLCs_Full:
	dc.w	2
	dc.w	4
	dc.w	5
	dc.w	6
; -------------------------------------------------------------------------

LevelObj_SetBaseTile:
	lea	LevelObj_BaseTileList,a1
	add.w	d0,d0
	move.w	LevelObj_BaseTileList(pc,d0.w),d4
	lea	LevelObj_BaseTileList(pc,d4.w),a2
	moveq	#0,d1
	move.b	oSubtype2(a0),d1
	add.w	d1,d1
	move.w	(a2,d1.w),d5
	move.w	d5,oTile(a0)
	rts
; End of function LevelObj_SetBaseTile

; -------------------------------------------------------------------------
LevelObj_BaseTileList:
	dc.w	word_20CB2A-LevelObj_BaseTileList
	dc.w	word_20CB2C-LevelObj_BaseTileList
	dc.w	word_20CB2E-LevelObj_BaseTileList
	dc.w	word_20CB30-LevelObj_BaseTileList
	dc.w	word_20CB32-LevelObj_BaseTileList
	dc.w	word_20CB34-LevelObj_BaseTileList
	dc.w	word_20CB3A-LevelObj_BaseTileList
	dc.w	word_20CB38-LevelObj_BaseTileList
	dc.w	word_20CB48-LevelObj_BaseTileList
	dc.w	word_20CB48-LevelObj_BaseTileList
	dc.w	word_20CB36-LevelObj_BaseTileList
	dc.w	word_20CB3C-LevelObj_BaseTileList
	dc.w	word_20CB3E-LevelObj_BaseTileList
	dc.w	word_20CB40-LevelObj_BaseTileList
	dc.w	word_20CB42-LevelObj_BaseTileList
	dc.w	word_20CB44-LevelObj_BaseTileList
	dc.w	word_20CB46-LevelObj_BaseTileList
	dc.w	word_20CB48-LevelObj_BaseTileList
word_20CB2A:	dc.w	$23D0
word_20CB2C:	dc.w	$239C
word_20CB2E:	dc.w	$2386
word_20CB30:	dc.w	$2419
word_20CB32:	dc.w	$23D0
word_20CB34:	dc.w	$4334
word_20CB36:	dc.w	$320
word_20CB38:	dc.w	$35A
word_20CB3A:	dc.w	$377
word_20CB3C:	dc.w	$346
word_20CB3E:	dc.w	$8328
word_20CB40:	dc.w	0
word_20CB42:	dc.w	$36F
word_20CB44:	dc.w	$490
word_20CB46:	dc.w	$40B
word_20CB48:	dc.w	0

; -------------------------------------------------------------------------
