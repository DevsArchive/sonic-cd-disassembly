; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Spin tunnel flag object
; -------------------------------------------------------------------------

ObjSpinTunnel:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjSpinTunnel_Index(pc,d0.w),d0
	jsr	ObjSpinTunnel_Index(pc,d0.w)
	tst.b	debugCheat
	beq.s	.NoDisplay
	jsr	DrawObject

.NoDisplay:
	jmp	CheckObjDespawn
; End of function ObjSpinTunnel

; -------------------------------------------------------------------------
ObjSpinTunnel_Index:
	dc.w	ObjSpinTunnel_Init-ObjSpinTunnel_Index
	dc.w	ObjSpinTunnel_Main-ObjSpinTunnel_Index
; -------------------------------------------------------------------------

ObjSpinTunnel_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#%00000100,oSprFlags(a0)
	move.w	#$544,oTile(a0)
	move.l	#MapSpr_Powerup,oMap(a0)
	move.b	oSubtype(a0),oMapFrame(a0)
	addq.b	#1,oMapFrame(a0)
; End of function ObjSpinTunnel_Init

; -------------------------------------------------------------------------

ObjSpinTunnel_Main:
	lea	objPlayerSlot.w,a1
	cmpi.b	#$2B,oAnim(a1)
	beq.w	.End
	cmpi.b	#6,oRoutine(a1)
	bcc.w	.End
	bsr.w	ObjSpinTunnel_CheckInRange
	beq.w	.End
	tst.b	oSubtype(a0)
	bne.s	.ChkSubtype1
	move.w	oXVel(a1),d0
	bpl.s	.AbsVX
	neg.w	d0

.AbsVX:
	move.w	#$A00,d1
	cmpi.b	#5,zone
	bne.s	.GotXCap
	move.w	#$D00,d1

.GotXCap:
	cmp.w	d1,d0
	bcc.s	.CheckXSign
	move.w	d1,d0

.CheckXSign:
	tst.w	oXVel(a1)
	bpl.s	.GotSpeed
	neg.w	d0

.GotSpeed:
	move.w	d0,oXVel(a1)
	move.w	d0,oPlayerGVel(a1)
	move.b	oAngle(a1),d0
	addi.b	#$20,d0
	andi.b	#$C0,d0
	cmpi.b	#$80,d0
	bne.s	.SetRoll
	neg.w	oPlayerGVel(a1)
	bra.s	.SetRoll

; -------------------------------------------------------------------------

.ChkSubtype1:
	cmpi.b	#2,oSubtype(a0)
	bcc.s	.HighSubtype

.Subtype1:
	move.w	oYVel(a1),d0
	bpl.s	.AbsVY
	neg.w	d0

.AbsVY:
	cmpi.w	#$D00,d0
	bcc.s	.GotYCap
	move.w	#$D00,d0

.GotYCap:
	tst.w	oYVel(a1)
	bpl.s	.CheckYSign
	neg.w	d0

.CheckYSign:
	move.w	d0,oYVel(a1)
	move.w	d0,oPlayerGVel(a1)
	bset	#1,oFlags(a1)

.SetRoll:
	bset	#2,oFlags(a1)
	bne.s	.End
	move.b	#$E,oYRadius(a1)
	move.b	#7,oXRadius(a1)
	addq.w	#5,oY(a1)
	move.b	#2,oAnim(a1)

.End:
	rts

; -------------------------------------------------------------------------

.HighSubtype:
	move.b	p1CtrlHold.w,d1
	cmpi.b	#4,oSubtype(a0)
	beq.s	.Subtype4
	cmpi.b	#2,oSubtype(a0)
	bne.s	.Subtype3

.Subtype2:
	tst.w	oYVel(a1)
	bpl.s	.SetRoll
	bra.s	.ChkLaunch

; -------------------------------------------------------------------------

.Subtype3:
	tst.w	oYVel(a1)
	bmi.s	.SetRoll

.ChkLaunch:
	move.w	#$D00,d0
	btst	#3,d1
	bne.s	.GotLaunch
	btst	#2,d1
	beq.s	.SetRoll
	neg.w	d0

.GotLaunch:
	cmpi.b	#2,oSubtype(a0)
	beq.s	.SkipAir
	bset	#1,oFlags(a1)

.SkipAir:
	move.w	d0,oXVel(a1)
	move.w	d0,oPlayerGVel(a1)
	bra.s	.SetRoll

; -------------------------------------------------------------------------

.Subtype4:
	tst.w	oXVel(a1)
	bmi.s	.SetRoll
	btst	#0,d1
	beq.w	.SetRoll
	move.w	#-$A00,d0
	bra.w	.CheckYSign
; End of function ObjSpinTunnel_Main

; -------------------------------------------------------------------------

ObjSpinTunnel_CheckInRange:
	tst.b	debugMode
	bne.s	.NotInRange
	move.w	oX(a1),d0
	sub.w	oX(a0),d0
	addi.w	#$28,d0
	bmi.s	.NotInRange
	cmpi.w	#$50,d0
	bcc.s	.NotInRange
	move.w	oY(a1),d0
	sub.w	oY(a0),d0
	addi.w	#$28,d0
	bmi.s	.NotInRange
	cmpi.w	#$50,d0
	bcc.s	.NotInRange
	moveq	#1,d0
	rts

; -------------------------------------------------------------------------

.NotInRange:
	moveq	#0,d0
	rts

; -------------------------------------------------------------------------
