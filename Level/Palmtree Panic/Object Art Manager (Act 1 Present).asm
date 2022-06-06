; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Palmtree Panic Act 1 Present object art manager
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
	dc.w	$680
	dc.w	$F80
	dc.w	$1980
	dc.w	$1F80
	dc.w	$FFFF
CameraPLCs_Incr:dc.w	8
	dc.w	9
	dc.w	$A
	dc.w	$B
	dc.w	$C
CameraPLCs_Full:dc.w	2
	dc.w	4
	dc.w	5
	dc.w	6
	dc.w	7
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
	dc.w	word_20CF6C-LevelObj_BaseTileList
	dc.w	word_20CF6E-LevelObj_BaseTileList
	dc.w	word_20CF70-LevelObj_BaseTileList
	dc.w	word_20CF74-LevelObj_BaseTileList
	dc.w	word_20CF76-LevelObj_BaseTileList
	dc.w	word_20CF78-LevelObj_BaseTileList
	dc.w	word_20CF82-LevelObj_BaseTileList
	dc.w	word_20CF7C-LevelObj_BaseTileList
	dc.w	word_20CF80-LevelObj_BaseTileList
	dc.w	word_20CF7E-LevelObj_BaseTileList
	dc.w	word_20CF7A-LevelObj_BaseTileList
	dc.w	word_20CF84-LevelObj_BaseTileList
	dc.w	word_20CF86-LevelObj_BaseTileList
	dc.w	word_20CF88-LevelObj_BaseTileList
	dc.w	word_20CF8A-LevelObj_BaseTileList
	dc.w	word_20CF8C-LevelObj_BaseTileList
	dc.w	word_20CF8E-LevelObj_BaseTileList
	dc.w	word_20CF90-LevelObj_BaseTileList
word_20CF6C:	dc.w	$23A0
word_20CF6E:	dc.w	$23B0
word_20CF70:	dc.w	$2409
		dc.w	$2370
word_20CF74:	dc.w	$2000
word_20CF76:	dc.w	$2428
word_20CF78:	dc.w	$4334
word_20CF7A:	dc.w	$320
word_20CF7C:	dc.w	0
word_20CF7E:	dc.w	$4000
word_20CF80:	dc.w	$4000
word_20CF82:	dc.w	$409
word_20CF84:	dc.w	$374
word_20CF86:	dc.w	$8328
word_20CF88:	dc.w	0
word_20CF8A:	dc.w	0
word_20CF8C:	dc.w	$490
word_20CF8E:	dc.w	$3E4
word_20CF90:	dc.w	0

; -------------------------------------------------------------------------
