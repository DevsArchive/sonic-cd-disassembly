; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Time stone object (special stage)
; -------------------------------------------------------------------------

ObjTimeStone:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	add.w	d0,d0
	move.w	off_13D08(pc,d0.w),d0
	jsr	off_13D08(pc,d0.w)
	bsr.w	DrawObject
	rts

; -------------------------------------------------------------------------
off_13D08:
	dc.w	ObjTimeStone_Init-off_13D08
	dc.w	ObjTimeStone_Wait-off_13D08
	dc.w	ObjTimeStone_Fall-off_13D08
	dc.w	ObjTimeStone_Wait2-off_13D08

; -------------------------------------------------------------------------

ObjTimeStone_Init:
	move.w	#$E424,oTile(a0)
	move.l	#MapSpr_Sparkle,oMap(a0)
	move.w	#$101,oSprX(a0)
	move.w	#$70,oSprY(a0)
	moveq	#0,d0
	bsr.w	SetObjAnim
	move.w	#$1E,oTimer(a0)
	addq.b	#1,oRoutine(a0)

; -------------------------------------------------------------------------

ObjTimeStone_Wait:
	subq.w	#1,oTimer(a0)
	bne.s	.End
	addq.b	#1,oRoutine(a0)

.End:
	rts

; -------------------------------------------------------------------------

ObjTimeStone_Fall:
	addq.w	#4,oSprY(a0)
	cmpi.w	#$150,oSprY(a0)
	bcs.s	.End
	addq.b	#1,oRoutine(a0)
	bset	#0,(sparkleObject1+oFlags).l
	bset	#0,(sparkleObject2+oFlags).l
	move.w	#$3C,oTimer(a0)
	move.b	#$12,(sonicObject+oRoutine).l
	move.b	#$D9,d0
	bsr.w	PlayFMSound

.End:
	rts

; -------------------------------------------------------------------------

ObjTimeStone_Wait2:
	subq.w	#1,oTimer(a0)
	bne.s	.End
	move.b	#1,gotTimeStone

.End:
	rts

; -------------------------------------------------------------------------
; Time stone sparkle 1 object
; -------------------------------------------------------------------------

ObjSparkle1:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	add.w	d0,d0
	move.w	off_13DA4(pc,d0.w),d0
	jsr	off_13DA4(pc,d0.w)
	bsr.w	DrawObject
	rts

; -------------------------------------------------------------------------
off_13DA4:
	dc.w	ObjSparkle1_Init-off_13DA4
	dc.w	ObjSparkle1_Main-off_13DA4

; -------------------------------------------------------------------------

ObjSparkle1_Init:
	move.w	#$E424,oTile(a0)
	move.l	#MapSpr_Sparkle,oMap(a0)
	moveq	#1,d0
	bsr.w	SetObjAnim
	addq.b	#1,oRoutine(a0)

; -------------------------------------------------------------------------

ObjSparkle1_Main:
	move.w	(timeStoneObject+oSprX).l,oSprX(a0)
	move.w	(timeStoneObject+oSprY).l,oSprY(a0)
	subi.w	#$10,oSprY(a0)
	rts

; -------------------------------------------------------------------------
; Time stone sparkle 2 object
; -------------------------------------------------------------------------

ObjSparkle2:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	add.w	d0,d0
	move.w	off_13DEE(pc,d0.w),d0
	jsr	off_13DEE(pc,d0.w)
	bsr.w	DrawObject
	rts

; -------------------------------------------------------------------------
off_13DEE:
	dc.w	ObjSparkle2_Init-off_13DEE
	dc.w	ObjSparkle2_Main-off_13DEE

; -------------------------------------------------------------------------

ObjSparkle2_Init:
	move.w	#$E424,oTile(a0)
	move.l	#MapSpr_Sparkle,oMap(a0)
	moveq	#2,d0
	bsr.w	SetObjAnim
	addq.b	#1,oRoutine(a0)

; -------------------------------------------------------------------------

ObjSparkle2_Main:
	move.w	(timeStoneObject+oSprX).l,oSprX(a0)
	move.w	(timeStoneObject+oSprY).l,oSprY(a0)
	subi.w	#$20,oSprY(a0)
	rts

; -------------------------------------------------------------------------

MapSpr_Sparkle:
	dc.l	byte_13E2E
	dc.l	byte_13E40
	dc.l	byte_13E52
byte_13E2E:
	dc.b	4, 3
	dc.l	byte_13E64
	dc.l	byte_13E6E
	dc.l	byte_13E82
	dc.l	byte_13E78
byte_13E40:
	dc.b	4, 1
	dc.l	byte_13E8C
	dc.l	byte_13E9C
	dc.l	byte_13EAC
	dc.l	byte_13EBC
byte_13E52:
	dc.b	4, 1
	dc.l	byte_13EFC
	dc.l	byte_13EEC
	dc.l	byte_13EDC
	dc.l	byte_13ECC
byte_13E64:
	dc.b	0, 0, 0, 0, 0
	dc.b	$E8, 6, 0, 0, $F8
byte_13E6E:
	dc.b	0, 0, 0, 0, 0
	dc.b	$E8, 6, 0, 6, $F8
byte_13E78:
	dc.b	0, 0, 0, 0, 0
	dc.b	$E8, 6, 8, 6, $F8
byte_13E82:
	dc.b	0, 0, 0, 0, 0
	dc.b	$E8, 6, 0, $C, $F8
byte_13E8C:
	dc.b	1, 0, 0, 0, 0
	dc.b	$E8, 9, 0, $12, $F4
	dc.b	$F8, 0, 0, $18, $FC
	dc.b	0
byte_13E9C:
	dc.b	1, 0, 0, 0, 0
	dc.b	$E8, 0, $10, $18, $FC
	dc.b	$F0, 9, $10, $12, $F4
	dc.b	0
byte_13EAC:
	dc.b	1, 0, 0, 0, 0
	dc.b	$E8, 0, $18, $18, $FC
	dc.b	$F0, 9, $18, $12, $F4
	dc.b	0
byte_13EBC:
	dc.b	1, 0, 0, 0, 0
	dc.b	$E8, 9, 8, $12, $F4
	dc.b	$F8, 0, 8, $18, $FC
	dc.b	0
byte_13ECC:
	dc.b	1, 0, 0, 0, 0
	dc.b	$F0, 0, 0, $19, 0
	dc.b	$F8, 4, 0, $1A, $F8
	dc.b	0
byte_13EDC:
	dc.b	1, 0, 0, 0, 0
	dc.b	$F8, 0, $10, $19, 0
	dc.b	$F0, 4, $10, $1A, $F8
	dc.b	0
byte_13EEC:
	dc.b	1, 0, 0, 0, 0
	dc.b	$F0, 4, $18, $1A, $F8
	dc.b	$F8, 0, $18, $19, $F8
	dc.b	0
byte_13EFC:
	dc.b	1, 0, 0, 0, 0
	dc.b	$F0, 0, 8, $19, $F8
	dc.b	$F8, 4, 8, $1A, $F8
	dc.b	0
	
; -------------------------------------------------------------------------
