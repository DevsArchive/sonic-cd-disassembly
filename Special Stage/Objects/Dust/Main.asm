; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Dust object (special stage)
; -------------------------------------------------------------------------

ObjDust:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	add.w	d0,d0
	move.w	off_13C3E(pc,d0.w),d0
	jsr	off_13C3E(pc,d0.w)
	bsr.w	DrawObject
	rts

; -------------------------------------------------------------------------
off_13C3E:
	dc.w	ObjDust_Init-off_13C3E
	dc.w	ObjDust_Main-off_13C3E

; -------------------------------------------------------------------------

ObjDust_Init:
	move.w	#$87AE,oTile(a0)
	move.l	#MapSpr_Dust,oMap(a0)
	move.w	#$F0,oSprX(a0)
	move.w	#$154,oSprY(a0)
	moveq	#0,d0
	bsr.w	SetObjAnim
	move.w	#6,oTimer(a0)
	addq.b	#1,oRoutine(a0)
	bsr.w	Random
	move.w	d0,d1
	andi.w	#$1F,d0
	add.w	d0,oSprX(a0)
	andi.w	#7,d0
	add.w	d0,oSprY(a0)
	move.w	#3,oDustXVel(a0)
	btst	#2,(playerCtrlData).l
	bne.s	ObjDust_Main
	move.w	#-3,oDustXVel(a0)
	btst	#3,(playerCtrlData).l
	bne.s	ObjDust_Main
	move.w	#0,oDustXVel(a0)

; -------------------------------------------------------------------------

ObjDust_Main:
	subq.w	#1,oTimer(a0)
	bne.s	.Move
	bset	#0,oFlags(a0)

.Move:
	move.l	oDustXVel(a0),d0
	add.l	d0,oSprX(a0)
	subq.w	#1,oSprY(a0)
	rts

; -------------------------------------------------------------------------
MapSpr_Dust:
	dc.l	unk_13CC6
unk_13CC6:
	dc.b	  3
	dc.b	  1
	dc.l	byte_13CE8
	dc.l	byte_13CDE
	dc.l	byte_13CD4
byte_13CD4:
	dc.b	0, 0, 0, 0, 0
	dc.b	$FC, 0, 0, $2C, $FC
byte_13CDE:
	dc.b	0, 0, 0, 0, 0
	dc.b	$FC, 0, 0, $2D, $FC
byte_13CE8:
	dc.b	0, 0, 0, 0, 0
	dc.b	$FC, 0, 0, $2E, $FC
	
; -------------------------------------------------------------------------
