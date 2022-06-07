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
	dc.w	$1100
	dc.w	$1A00
	dc.w	$2000
	dc.w	$FFFF
CameraPLCs_Incr:
	dc.w	9
	dc.w	$A
	dc.w	$B
	dc.w	$C
CameraPLCs_Full:
	dc.w	2
	dc.w	6
	dc.w	7
	dc.w	8
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
	dc.w	word_20CFB8-LevelObj_BaseTileList
	dc.w	word_20CFBA-LevelObj_BaseTileList
	dc.w	word_20CFBC-LevelObj_BaseTileList
	dc.w	word_20CFBE-LevelObj_BaseTileList
	dc.w	word_20CFC0-LevelObj_BaseTileList
	dc.w	word_20CFC2-LevelObj_BaseTileList
	dc.w	word_20CFCC-LevelObj_BaseTileList
	dc.w	word_20CFC6-LevelObj_BaseTileList
	dc.w	word_20CFCA-LevelObj_BaseTileList
	dc.w	word_20CFC8-LevelObj_BaseTileList
	dc.w	word_20CFC4-LevelObj_BaseTileList
	dc.w	word_20CFCE-LevelObj_BaseTileList
	dc.w	word_20CFD0-LevelObj_BaseTileList
	dc.w	word_20CFD2-LevelObj_BaseTileList
	dc.w	word_20CFD4-LevelObj_BaseTileList
	dc.w	word_20CFD6-LevelObj_BaseTileList
	dc.w	word_20CFD8-LevelObj_BaseTileList
	dc.w	word_20CFDA-LevelObj_BaseTileList
word_20CFB8:	dc.w	$2396
word_20CFBA:	dc.w	$243F
word_20CFBC:	dc.w	$23ED
word_20CFBE:	dc.w	$2000
word_20CFC0:	dc.w	$2403
word_20CFC2:	dc.w	$4334
word_20CFC4:	dc.w	$320
word_20CFC6:	dc.w	$381
word_20CFC8:	dc.w	$4000
word_20CFCA:	dc.w	$4000
word_20CFCC:	dc.w	$372
word_20CFCE:	dc.w	$346
word_20CFD0:	dc.w	$8328
word_20CFD2:	dc.w	0
word_20CFD4:	dc.w	0
word_20CFD6:	dc.w	$490
word_20CFD8:	dc.w	$39E
word_20CFDA:	dc.w	0

; -------------------------------------------------------------------------
