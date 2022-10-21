; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Palmtree Panic level data load functions
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Load level data
; -------------------------------------------------------------------------

LoadLevelData:
	moveq	#0,d0				; Prepare level data index
	lea	LevelDataIndex,a2
	move.l	a2,-(sp)

	addq.l	#4,a2				; Skip over level art pointer (art is loaded in PLCs instead)

	move.l	(a2)+,d1			; Load level blocks
	andi.l	#$3FFFFF,d1
	movea.l	d1,a0
	lea	blockBuffer,a4
	bsr.w	NemDecToRAM

	movea.l	(a2)+,a0			; Skip over level chunks (chunks are uncompressed, and are referenced directly
						; by collision and drawing routines)

	bsr.w	LoadLevelLayout			; Load level layout

	move.w	(a2)+,d0			; Load level palette
	move.w	(a2),d0
	andi.w	#$FF,d0
	bsr.w	LoadFadePal

	movea.l	(sp)+,a2			; Skip over to PLC ID
	addq.w	#4,a2

	tst.b	spawnMode			; Is the player being spawned at the beginning?
	beq.s	.ChkStdPLC			; If so, branch
	jmp	LoadSectionArt			; If not, load section art

.ChkStdPLC:
	btst	#1,plcLoadFlags			; Was the title card marked as loaded?
	beq.s	.End				; If not, branch

	moveq	#0,d0				; Load PLCs
	move.b	(a2),d0
	beq.s	.End				; If the PLC ID is 0, branch
	bsr.w	LoadPLC

.End:
	rts

; -------------------------------------------------------------------------
; Load a level layout
; -------------------------------------------------------------------------

LoadLevelLayout:
	lea	levelLayout.w,a3		; Clear layout RAM
	move.w	#$1FF,d1
	moveq	#0,d0

.Clear:
	move.l	d0,(a3)+
	dbf	d1,.Clear			; Loop until finished

	lea	levelLayout.w,a3		; Load foreground layout
	moveq	#0,d1
	bsr.w	.LoadPlane

	lea	levelLayout+$40.w,a3		; Load background layout
	moveq	#2,d1

; -------------------------------------------------------------------------

.LoadPlane:
	moveq	#0,d0				; Get pointer to layout data
	add.w	d1,d0
	lea	LevelLayouts,a1
	move.w	(a1,d0.w),d0
	lea	(a1,d0.w),a1

	moveq	#0,d1				; Get layout size
	move.w	d1,d2
	move.b	(a1)+,d1
	move.b	(a1)+,d2

.RowLoop:
	move.w	d1,d0				; Prepare to copy row
	movea.l	a3,a0

.ChunkLoop:
	move.b	(a1)+,(a0)+			; Copy row of layout data
	dbf	d0,.ChunkLoop			; Loop until finished

	lea	$80(a3),a3			; Next row
	dbf	d2,.RowLoop			; Loop until finished

	rts

; -------------------------------------------------------------------------
