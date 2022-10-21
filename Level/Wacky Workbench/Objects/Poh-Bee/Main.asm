; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Poh-Bee object
; -------------------------------------------------------------------------

oPohTime	EQU	oVar2A
oPohXVel	EQU	oVar2C
oPohShootX	EQU	oVar30
oPohChkTime	EQU	oVar32

; -------------------------------------------------------------------------

ObjPohBee:
	tst.b	oSubtype(a0)
	bmi.w	ObjPohBeeMissile

	jsr	DestroyOnGoodFuture

	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	lea	Ani_PohBee(pc),a1
	jsr	AnimateObject
	jsr	DrawObject
	jmp	CheckObjDespawn

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjPohBee_Init-.Index
	dc.w	ObjPohBee_MoveStart-.Index
	dc.w	ObjPohBee_Move-.Index
	dc.w	ObjPohBee_WaitFlipStart-.Index
	dc.w	ObjPohBee_WaitFlip-.Index
	dc.w	ObjPohBee_WaitMove-.Index
	dc.w	ObjPohBee_WaitShootStart-.Index
	dc.w	ObjPohBee_WaitShoot-.Index
	dc.w	ObjPohBee_Shoot-.Index
	dc.w	ObjPohBee_ShootDone-.Index

; -------------------------------------------------------------------------

ObjPohBee_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oSprFlags(a0)
	move.b	#1,oPriority(a0)
	move.b	#24,oXRadius(a0)
	move.b	#24,oWidth(a0)
	move.b	#12,oYRadius(a0)
	move.w	#$A457,oTile(a0)
	move.b	#$31,oColType(a0)
	move.w	#-8,oPohShootX(a0)

	lea	MapSpr_PohBee(pc),a1
	move.l	#-$10000,d0
	tst.b	oSubtype(a0)
	beq.s	.NotDamaged
	lea	MapSpr_PohBeeDamaged(pc),a1
	move.l	#-$8000,d0

.NotDamaged:
	move.l	a1,oMap(a0)
	move.l	d0,oPohXVel(a0)

; -------------------------------------------------------------------------

ObjPohBee_MoveStart:
	addq.b	#2,oRoutine(a0)
	move.w	#$200,d0
	tst.b	oSubtype(a0)
	beq.s	.SetTime
	move.w	#$400,d0

.SetTime:
	move.w	d0,oPohTime(a0)

; -------------------------------------------------------------------------

ObjPohBee_Move:
	move.l	oPohXVel(a0),d0
	add.l	d0,oX(a0)
	tst.b	oSubtype(a0)
	bne.s	.DecTime
	tst.w	oPohChkTime(a0)
	beq.s	.CheckPlayer
	subq.w	#1,oPohChkTime(a0)
	bra.s	.DecTime

.CheckPlayer:
	lea	objPlayerSlot.w,a1
	bsr.s	ObjPohBee_CheckPlayer
	beq.s	.DecTime
	move.b	#$C,oRoutine(a0)
	rts

.DecTime:
	subq.w	#1,oPohTime(a0)
	bpl.s	.End
	move.b	#6,oRoutine(a0)

.End:
	rts

; -------------------------------------------------------------------------

ObjPohBee_CheckPlayer:
	move.w	oY(a1),d0
	sub.w	oY(a0),d0
	subi.w	#-96,d0
	subi.w	#192,d0
	bcc.s	.NotFound

	move.w	oX(a1),d0
	sub.w	oX(a0),d0
	spl	d1
	subi.w	#-120,d0
	subi.w	#240,d0
	bcc.s	.NotFound

	btst	#0,oSprFlags(a0)
	sne	d2
	eor.b	d1,d2
	beq.s	.FoundPlayer

	neg.l	oPohXVel(a0)
	neg.w	oPohShootX(a0)
	bchg	#0,oSprFlags(a0)
	bchg	#0,oFlags(a0)

.FoundPlayer:
	moveq	#-1,d0
	rts

.NotFound:
	moveq	#0,d0
	rts

; -------------------------------------------------------------------------

ObjPohBee_WaitFlipStart:
	addq.b	#2,oRoutine(a0)
	move.w	#30,oPohTime(a0)

; -------------------------------------------------------------------------

ObjPohBee_WaitFlip:
	subq.w	#1,oPohTime(a0)
	bpl.s	.End
	addq.b	#2,oRoutine(a0)
	move.w	#30,oPohTime(a0)

	neg.l	oPohXVel(a0)
	neg.w	oPohShootX(a0)
	bchg	#0,oSprFlags(a0)
	bchg	#0,oFlags(a0)

.End:
	rts

; -------------------------------------------------------------------------

ObjPohBee_WaitMove:
	subq.w	#1,oPohTime(a0)
	bpl.s	.End
	move.b	#2,oRoutine(a0)

.End:
	rts

; -------------------------------------------------------------------------

ObjPohBee_WaitShootStart:
	addq.b	#2,oRoutine(a0)
	move.w	#30,oPohTime(a0)

; -------------------------------------------------------------------------

ObjPohBee_WaitShoot:
	subq.w	#1,oPohTime(a0)
	bpl.s	.End
	addq.b	#2,oRoutine(a0)
	move.w	#30,oPohTime(a0)

	move.b	#1,oAnim(a0)
	move.b	#$32,oColType(a0)
	move.b	#16,oYRadius(a0)
	move.b	#16,oXRadius(a0)
	move.b	#16,oWidth(a0)

	move.w	oPohShootX(a0),d0
	add.w	d0,oX(a0)
	addq.w	#4,oY(a0)

.End:
	rts

; -------------------------------------------------------------------------

ObjPohBee_Shoot:
	subq.w	#1,oPohTime(a0)
	bpl.w	.End
	addq.b	#2,oRoutine(a0)
	move.w	#30,oPohTime(a0)

	jsr	FindObjSlot
	bne.w	.End
	move.b	oID(a0),oID(a1)
	move.b	#-1,oSubtype(a1)
	move.b	oSprFlags(a0),oSprFlags(a1)
	move.w	oTile(a0),oTile(a1)
	move.l	#MapSpr_PohBeeMissile,oMap(a1)
	move.b	#1,oPriority(a1)
	move.b	#16,oYRadius(a1)
	move.b	#16,oXRadius(a1)
	move.b	#16,oWidth(a1)
	move.b	#$B3,oColType(a1)
	move.w	oY(a0),oY(a1)
	addi.w	#23,oY(a1)
	move.l	#$20000,oPohMissYVel(a1)

	move.w	oX(a0),oX(a1)
	move.w	#7,d0
	move.l	#$20000,d1
	btst	#0,oSprFlags(a0)
	bne.s	.SetX
	neg.w	d0
	neg.l	d1

.SetX:
	add.w	d0,oX(a1)
	move.l	d1,oPohMissXVel(a1)

	tst.b	oSprFlags(a0)
	bpl.s	.End
	move.w	#FM_A0,d0
	jsr	PlayFMSound

.End:
	rts

; -------------------------------------------------------------------------

ObjPohBee_ShootDone:
	subq.w	#1,oPohTime(a0)
	bpl.s	.End
	move.b	#2,oRoutine(a0)
	move.w	#60,oPohChkTime(a0)

	move.b	#0,oAnim(a0)
	move.b	#$31,oColType(a0)
	move.b	#12,oYRadius(a0)
	move.b	#24,oXRadius(a0)
	move.b	#24,oWidth(a0)
	move.w	oPohShootX(a0),d0
	sub.w	d0,oX(a0)
	subq.w	#4,oY(a0)

.End:
	rts

; -------------------------------------------------------------------------

Ani_PohBee:
	include	"Level/Wacky Workbench/Objects/Poh-Bee/Data/Animations (Normal).asm"
	even

MapSpr_PohBee:
	include	"Level/Wacky Workbench/Objects/Poh-Bee/Data/Mappings (Normal).asm"
	even

MapSpr_PohBeeDamaged:
	include	"Level/Wacky Workbench/Objects/Poh-Bee/Data/Mappings (Damaged).asm"
	even

; -------------------------------------------------------------------------
; Poh-Bee missile
; -------------------------------------------------------------------------

oPohMissTime	EQU	oVar2A
oPohMissXVel	EQU	oVar2C
oPohMissYVel	EQU	oVar30

; -------------------------------------------------------------------------

ObjPohBeeMissile:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	jsr	DrawObject
	jmp	CheckObjDespawn

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjPohBeeMissile_Init-.Index
	dc.w	ObjPohBeeMissile_Main-.Index
	dc.w	ObjPohBeeMissile_Move-.Index
	dc.w	ObjPohBeeMissile_Move2-.Index

; -------------------------------------------------------------------------

ObjPohBeeMissile_Init:
	addq.b	#2,oRoutine(a0)
	move.w	#3,oPohMissTime(a0)

; -------------------------------------------------------------------------

ObjPohBeeMissile_Main:
	subq.w	#1,oPohMissTime(a0)
	bpl.s	.End

	addq.b	#2,oRoutine(a0)
	move.b	#1,oMapFrame(a0)
	move.w	#10,oPohMissTime(a0)

.End:
	rts

; -------------------------------------------------------------------------

ObjPohBeeMissile_Move:
	move.l	oPohMissXVel(a0),d0
	add.l	d0,oX(a0)
	move.l	oPohMissYVel(a0),d0
	add.l	d0,oY(a0)

	subq.w	#1,oPohMissTime(a0)
	bpl.s	.End
	addq.b	#2,oRoutine(a0)

.End:
	rts

; -------------------------------------------------------------------------

ObjPohBeeMissile_Move2:
	tst.b	oSprFlags(a0)
	bmi.s	.OnScreen
	jmp	DeleteObject

.OnScreen:
	move.l	oPohMissXVel(a0),d0
	add.l	d0,oX(a0)
	move.l	oPohMissYVel(a0),d0
	add.l	d0,oY(a0)

	lea	Ani_PohBeeMissile(pc),a1
	jmp	AnimateObject

; -------------------------------------------------------------------------

Ani_PohBeeMissile:
	include	"Level/Wacky Workbench/Objects/Poh-Bee/Data/Animations (Missile).asm"
	even


MapSpr_PohBeeMissile:
	include	"Level/Wacky Workbench/Objects/Poh-Bee/Data/Mappings (Missile).asm"
	even

; -------------------------------------------------------------------------
