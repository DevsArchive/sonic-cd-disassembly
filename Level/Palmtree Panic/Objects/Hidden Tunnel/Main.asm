; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Hidden tunnel object
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Sonic hole object
; -------------------------------------------------------------------------

ObjSonicHole:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjSonicHole_Index(pc,d0.w),d0
	jsr	ObjSonicHole_Index(pc,d0.w)
	jmp	CheckObjDespawnTime

; -------------------------------------------------------------------------
ObjSonicHole_Index:dc.w	ObjSonicHole_Init-ObjSonicHole_Index
	dc.w	ObjSonicHole_Main-ObjSonicHole_Index
	dc.w	ObjSonicHole_Display-ObjSonicHole_Index
; -------------------------------------------------------------------------

ObjSonicHole_Init:
	addq.b	#2,oRoutine(a0)
	ori.b	#4,oRender(a0)
	move.w	#$3A0,oTile(a0)
	tst.b	timeZone
	bne.s	.NotPast
	move.w	#$3BB,oTile(a0)

.NotPast:
	move.l	#MapSpr_SonicHole,4(a0)
	move.b	#$10,oWidth(a0)
	move.b	#$10,oYRadius(a0)
	move.b	#6,oPriority(a0)
	bsr.w	ObjSonicHole_SetDisplay
	beq.s	.ClearDisplay
	addq.b	#2,oRoutine(a0)
	bra.w	ObjSonicHole_Display

; -------------------------------------------------------------------------

.ClearDisplay:
	bclr	#6,2(a1,d0.w)
; End of function ObjSonicHole_Init

; -------------------------------------------------------------------------

ObjSonicHole_Main:
	lea	objPlayerSlot.w,a6
	tst.b	oPlayerCtrl(a6)
	beq.s	.End
	move.w	oX(a6),d0
	sub.w	oX(a0),d0
	addi.w	#$20,d0
	bmi.s	.End
	cmpi.w	#$40,d0
	bcc.s	.End
	move.w	oY(a6),d0
	sub.w	oY(a0),d0
	addi.w	#$20,d0
	bmi.s	.End
	cmpi.w	#$40,d0
	bcc.s	.End
	bsr.s	ObjSonicHole_SetDisplay
	move.w	#$A3,d0
	jsr	PlayFMSound
	addq.b	#2,oRoutine(a0)
	bra.s	ObjSonicHole_Display

; -------------------------------------------------------------------------

.End:
	rts

; -------------------------------------------------------------------------

ObjSonicHole_Display:
	jmp	DrawObject
; End of function ObjSonicHole_Main

; -------------------------------------------------------------------------

ObjSonicHole_SetDisplay:
	moveq	#0,d0
	move.b	oRespawn(a0),d0
	lea	lvlObjRespawns,a1
	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,d0
	moveq	#0,d1
	move.b	timeZone,d1
	add.w	d1,d0
	bset	#6,2(a1,d0.w)
	rts
; End of function ObjSonicHole_SetDisplay

; -------------------------------------------------------------------------

MapSpr_SonicHole:
	include	"Level/Palmtree Panic/Objects/Hidden Tunnel/Data/Mappings (Hole).asm"
	even

; -------------------------------------------------------------------------
; Hidden tunnel object
; -------------------------------------------------------------------------

ObjHiddenTunnel:
	btst	#7,timeZone
	beq.s	.NoRespawn
	moveq	#0,d0
	move.b	oRespawn(a0),d0
	beq.s	.NoRespawn
	lea	lvlObjRespawns,a1
	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,d0
	moveq	#0,d1
	move.b	timeZone,d1
	bclr	#7,d1
	move.b	timeWarpDir.w,d2
	ext.w	d2
	neg.w	d2
	add.w	d2,d1
	bpl.s	.NoCap
	moveq	#0,d1
	bra.s	.GetRespawn

; -------------------------------------------------------------------------

.NoCap:
	cmpi.w	#3,d1
	bcs.s	.GetRespawn
	moveq	#2,d1

.GetRespawn:
	add.w	d1,d0
	bclr	#7,2(a1,d0.w)

.NoRespawn:
	lea	objPlayerSlot.w,a6
	cmpi.b	#$2B,oAnim(a6)
	beq.s	.End
	cmpi.b	#6,oRoutine(a6)
	bcc.s	.End
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjHiddenTunnel_Index(pc,d0.w),d1
	jsr	ObjHiddenTunnel_Index(pc,d1.w)
	cmpi.b	#4,oRoutine(a0)
	bcc.s	.End
	jmp	CheckObjDespawnTime

; -------------------------------------------------------------------------

.End:
	rts
; End of function ObjHiddenTunnel

; -------------------------------------------------------------------------
ObjHiddenTunnel_Index:
	dc.w	ObjHiddenTunnel_Init-ObjHiddenTunnel_Index
	dc.w	ObjHiddenTunnel_Main-ObjHiddenTunnel_Index
	dc.w	ObjHiddenTunnel_InitPlayer-ObjHiddenTunnel_Index
	dc.w	ObjHiddenTunnel_CtrlPlayer-ObjHiddenTunnel_Index
; -------------------------------------------------------------------------

ObjHiddenTunnel_Init:
	move.l	#MapSpr_Powerup,oMap(a0)
	move.b	#4,oRender(a0)
	move.b	#1,oPriority(a0)
	move.b	#$10,oWidth(a0)
	move.w	#$541,oTile(a0)
	addq.b	#2,oRoutine(a0)
	move.b	oSubtype(a0),d0
	add.w	d0,d0
	andi.w	#$FE,d0
	lea	ObjHiddenTunnel_TargetPos(pc),a2
	adda.w	(a2,d0.w),a2
	move.w	(a2)+,oVar3A(a0)
	move.l	a2,oVar3C(a0)
	move.w	(a2)+,oVar36(a0)
	move.w	(a2)+,oVar38(a0)
; End of function ObjHiddenTunnel_Init

; -------------------------------------------------------------------------

ObjHiddenTunnel_Main:
	move.w	oX(a6),d0
	sub.w	oX(a0),d0
	addi.w	#$10,d0
	cmpi.w	#$20,d0
	bcc.w	.End
	move.w	oY(a6),d1
	sub.w	oY(a0),d1
	addi.w	#$10,d1
	cmpi.w	#$20,d1
	bcc.w	.End
	tst.b	oPlayerCtrl(a6)
	bne.w	.End
	cmpi.b	#4,oRoutine(a6)
	bne.s	.NotHurt
	subq.b	#2,oRoutine(a6)
	move.w	#$78,oPlayerHurt(a6)

.NotHurt:
	addq.b	#2,oRoutine(a0)
	move.b	#$81,oPlayerCtrl(a6)
	tst.b	oSubtype2(a0)
	beq.s	.SetAnimIntertia
	ori.b	#$40,oPlayerCtrl(a6)

.SetAnimIntertia:
	move.b	#2,oAnim(a6)
	bsr.w	ObjHiddenTunnel_SetPlayerGVel
	move.w	#0,oXVel(a6)
	move.w	#0,oYVel(a6)
	bclr	#5,oStatus(a0)
	bclr	#5,oStatus(a6)
	bset	#1,oStatus(a6)
	clr.b	oPlayerJump(a6)
	move.w	oX(a0),oX(a6)
	move.w	oY(a0),oY(a6)
	clr.b	oVar32(a0)
	move.w	#$91,d0
	jsr	PlayFMSound

.End:
	rts
; End of function ObjHiddenTunnel_Main

; -------------------------------------------------------------------------

ObjHiddenTunnel_InitPlayer:
	bsr.w	ObjHiddenTunnel_SetPlayerSpeeds
	addq.b	#2,oRoutine(a0)
	move.w	#$91,d0
	jsr	PlayFMSound
	rts
; End of function ObjHiddenTunnel_InitPlayer

; -------------------------------------------------------------------------

ObjHiddenTunnel_CtrlPlayer:
	subq.b	#1,oVar2E(a0)
	bpl.s	.MovePlayer
	move.w	oVar36(a0),oX(a6)
	move.w	oVar38(a0),oY(a6)
	moveq	#0,d1
	move.b	oVar3A(a0),d1
	addq.b	#4,d1
	cmp.b	oVar3B(a0),d1
	bcs.s	.UpdatePlayer
	moveq	#0,d1
	bra.s	.ResetObj

; -------------------------------------------------------------------------

.UpdatePlayer:
	move.b	d1,oVar3A(a0)
	movea.l	oVar3C(a0),a2
	move.w	(a2,d1.w),oVar36(a0)
	move.w	2(a2,d1.w),oVar38(a0)
	bra.w	ObjHiddenTunnel_SetPlayerSpeeds

; -------------------------------------------------------------------------

.MovePlayer:
	move.l	oX(a6),d2
	move.l	oY(a6),d3
	move.w	oXVel(a6),d0
	ext.l	d0
	asl.l	#8,d0
	add.l	d0,d2
	move.w	oYVel(a6),d0
	ext.l	d0
	asl.l	#8,d0
	add.l	d0,d3
	move.l	d2,oX(a6)
	move.l	d3,oY(a6)
	rts

; -------------------------------------------------------------------------

.ResetObj:
	andi.w	#$7FF,oY(a6)
	clr.b	oRoutine(a0)
	clr.b	oPlayerCtrl(a6)
	move.w	#2,oRoutine(a0)
	rts
; End of function ObjHiddenTunnel_CtrlPlayer

; -------------------------------------------------------------------------

ObjHiddenTunnel_SetPlayerSpeeds:
	moveq	#0,d0
	move.w	oPlayerGVel(a6),d2
	move.w	oPlayerGVel(a6),d3
	move.w	oVar36(a0),d0
	sub.w	oX(a6),d0
	bge.s	.PlayerLeft
	neg.w	d0
	neg.w	d2

.PlayerLeft:
	moveq	#0,d1
	move.w	oVar38(a0),d1
	sub.w	oY(a6),d1
	bge.s	.PlayerAbove
	neg.w	d1
	neg.w	d3

.PlayerAbove:
	cmp.w	d0,d1
	bcs.s	.DXGreater
	moveq	#0,d1
	move.w	oVar38(a0),d1
	sub.w	oY(a6),d1
	swap	d1
	divs.w	d3,d1
	moveq	#0,d0
	move.w	oVar36(a0),d0
	sub.w	oX(a6),d0
	beq.s	.ZeroDivide
	swap	d0
	divs.w	d1,d0

.ZeroDivide:
	move.w	d0,oXVel(a6)
	move.w	d3,oYVel(a6)
	tst.w	d1
	bpl.s	.SetSign
	neg.w	d1

.SetSign:
	move.w	d1,oVar2E(a0)
	rts

; -------------------------------------------------------------------------

.DXGreater:
	moveq	#0,d0
	move.w	oVar36(a0),d0
	sub.w	oX(a6),d0
	swap	d0
	divs.w	d2,d0
	moveq	#0,d1
	move.w	oVar38(a0),d1
	sub.w	oY(a6),d1
	beq.s	.ZeroDivide2
	swap	d1
	divs.w	d0,d1

.ZeroDivide2:
	move.w	d1,oYVel(a6)
	move.w	d2,oXVel(a6)
	tst.w	d0
	bpl.s	.SetSign2
	neg.w	d0

.SetSign2:
	move.w	d0,oVar2E(a0)
	rts
; End of function ObjHiddenTunnel_SetPlayerSpeeds

; -------------------------------------------------------------------------

ObjHiddenTunnel_SetPlayerGVel:
	move.w	#$1000,oPlayerGVel(a6)
	moveq	#0,d0
	move.b	oSubtype(a0),d0
	bmi.s	.End
	andi.w	#$F,d0
	add.w	d0,d0
	move.w	ObjHiddenTunnel_GVels(pc,d0.w),d0
	cmp.w	oPlayerGVel(a6),d0
	ble.s	.End
	move.w	d0,oPlayerGVel(a6)

.End:
	rts
; End of function ObjHiddenTunnel_SetPlayerGVel

; -------------------------------------------------------------------------
ObjHiddenTunnel_GVels:
	dc.w	$1000
	dc.w	$C00
	dc.w	$C00
	dc.w	$800

ObjHiddenTunnel_TargetPos:
	dc.w	word_208D9E-ObjHiddenTunnel_TargetPos
	dc.w	word_208E28-ObjHiddenTunnel_TargetPos
	dc.w	word_208E6E-ObjHiddenTunnel_TargetPos

word_208D9E:
	dc.w	$88, $1440, $F0, $1478, $108, $1490, $140, $1490
	dc.w	$1E0, $1440, $1F8, $1400, $1E0, $13F0, $1C0, $13F0
	dc.w	$180, $1400, $170, $1420, $168, $1440, $170, $1468
	dc.w	$1A8, $1660, $218, $16A0, $210, $16C0, $1F8, $16D0
	dc.w	$1C8, $16C0, $1A8, $1680, $198, $1658, $1A0, $1640
	dc.w	$1C8, $1650, $1F0, $1680, $200, $16C0, $200, $16D0
	dc.w	$210, $16D0, $288, $16C0, $2C0, $1680, $2D8, $1650
	dc.w	$2C0, $1650, $2A0, $1680, $290, $1700, $290, $1728
	dc.w	$2A0, $1728, $2E0, $1700, $2F0

word_208E28:
	dc.w	$44, $F08, $1A0, $F90, $1A0, $FC8, $1B8, $FE0
	dc.w	$1F0, $FE0, $260, $1000, $290, $1030, $2A0, $1068
	dc.w	$288, $1080, $250, $1068, $218, $1030, $200, $FF0
	dc.w	$220, $FE0, $260, $1000, $290, $1030, $2A0, $1068
	dc.w	$288, $1130, $1C8

word_208E6E:
	dc.w	$44, $1630, $290, $1630, $318, $1638, $338, $16D0
	dc.w	$3D0, $1700, $3E0, $1738, $3C8, $1758, $390, $1738
	dc.w	$358, $16F8, $340, $16C0, $360, $16A8, $390, $16D0
	dc.w	$3D0, $1700, $3E0, $1738, $3C8, $17B8, $348, $17D0
	dc.w	$320, $17D0, $268

; -------------------------------------------------------------------------
