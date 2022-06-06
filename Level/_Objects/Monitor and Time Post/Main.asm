; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Monitor and time post object
; -------------------------------------------------------------------------

ObjTimeIcon:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjTimeIcon_Index(pc,d0.w),d0
	jsr	ObjTimeIcon_Index(pc,d0.w)
	tst.b	timeWarpDir.w
	beq.s	.End
	cmpi.w	#$5A,timeWarpTimer.w
	bcs.s	.Display
	btst	#0,lvlFrameTimer+1
	bne.s	.End

.Display:
	jmp	DrawObject

; -------------------------------------------------------------------------

.End:
	rts
; End of function ObjTimeIcon

; -------------------------------------------------------------------------
ObjTimeIcon_Index:dc.w	ObjTimeIcon_Init-ObjTimeIcon_Index
	dc.w	ObjTimeIcon_Main-ObjTimeIcon_Index
; -------------------------------------------------------------------------

ObjTimeIcon_Init:
	addq.b	#2,oRoutine(a0)
	move.l	#MapSpr_MonitorTimePost,oMap(a0)
	move.w	#$85A8,oTile(a0)
	move.w	#$C4,oX(a0)
	move.w	#$152,oYScr(a0)
; End of function ObjTimeIcon_Init

; -------------------------------------------------------------------------

ObjTimeIcon_Main:
	move.b	#$12,oMapFrame(a0)
	tst.b	timeWarpDir.w
	bmi.s	.End
	move.b	#$13,oMapFrame(a0)

.End:
	rts
; End of function ObjTimeIcon_Main

; -------------------------------------------------------------------------

ObjTimepostTimeIcon:
	tst.b	timeAttackMode
	beq.s	.Proceed
	jmp	DeleteObject

; -------------------------------------------------------------------------

.Proceed:
	cmpi.b	#$A,oSubtype(a0)
	beq.w	ObjTimeIcon

ObjTimepost:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjTimepost_Index(pc,d0.w),d0
	jsr	ObjTimepost_Index(pc,d0.w)
	jsr	DrawObject
	jmp	CheckObjDespawnTime
; End of function ObjTimepostTimeIcon

; -------------------------------------------------------------------------
ObjTimepost_Index:dc.w	ObjTimepost_Init-ObjTimepost_Index
	dc.w	ObjTimepost_Main-ObjTimepost_Index
	dc.w	ObjTimepost_Spin-ObjTimepost_Index
	dc.w	ObjTimepost_Done-ObjTimepost_Index
; -------------------------------------------------------------------------

ObjTimepost_Init:
	addq.b	#2,oRoutine(a0)
	move.b	#$20,oYRadius(a0)
	move.b	#$E,oXRadius(a0)
	move.l	#MapSpr_MonitorTimePost,oMap(a0)
	move.w	#$5A8,oTile(a0)
	move.b	#4,oRender(a0)
	move.b	#3,oPriority(a0)
	cmpi.b	#6,levelZone
	bne.s	.NotFront
	tst.b	oSubtype2(a0)
	bne.s	.NotFront
	move.b	#0,oPriority(a0)
	ori.b	#$80,oTile(a0)

.NotFront:
	move.b	#$F,oWidth(a0)
	move.b	oSubtype(a0),oAnim(a0)
	bsr.w	ObjMonitor_GetRespawn
	bclr	#7,2(a2,d0.w)
	move.b	#$A,oMapFrame(a0)
	cmpi.b	#8,oSubtype(a0)
	beq.s	.ChkActive
	addq.b	#2,oMapFrame(a0)

.ChkActive:
	btst	#0,2(a2,d0.w)
	beq.s	.StillActive
	addq.b	#1,oMapFrame(a0)
	move.b	#6,oRoutine(a0)
	rts

; -------------------------------------------------------------------------

.StillActive:
	move.b	#$DF,oColType(a0)
; End of function ObjTimepost_Init

; -------------------------------------------------------------------------

ObjTimepost_Main:
	tst.b	oColStatus(a0)
	beq.s	.End
	clr.b	oColStatus(a0)
	cmpi.b	#6,levelZone
	bne.s	.ChkTouch
	tst.b	oSubtype2(a0)
	beq.s	.NotBack
	tst.b	lvlDrawLowPlane
	beq.s	.End
	bra.s	.ChkTouch

; -------------------------------------------------------------------------

.NotBack:
	tst.b	lvlDrawLowPlane
	bne.s	.End

.ChkTouch:
	move.b	#$3C,oVar2A(a0)
	addq.b	#2,oRoutine(a0)
	bsr.w	ObjMonitor_GetRespawn
	bset	#0,2(a2,d0.w)
	move.w	#$77,d0
	move.b	#$FF,timeWarpDir.w
	cmpi.b	#8,oSubtype(a0)
	beq.s	.PlaySnd
	move.b	#1,timeWarpDir.w
	subq.w	#1,d0

.PlaySnd:
	jsr	SubCPUCmd

.End:
	rts
; End of function ObjTimepost_Main

; -------------------------------------------------------------------------

ObjTimepost_Spin:
	subq.b	#1,oVar2A(a0)
	beq.s	.StopSpin
	lea	Ani_Monitor,a1
	bra.w	AnimateObject

; -------------------------------------------------------------------------

.StopSpin:
	addq.b	#2,oRoutine(a0)
	move.b	#$B,oMapFrame(a0)
	cmpi.b	#8,oSubtype(a0)
	beq.s	ObjTimepost_Done
	addq.b	#2,oMapFrame(a0)
; End of function ObjTimepost_Spin

; -------------------------------------------------------------------------

ObjTimepost_Done:
	rts
; End of function ObjTimepost_Done

; -------------------------------------------------------------------------

ObjMonitor_GetRespawn:
	lea	lvlObjRespawns,a2
	moveq	#0,d0
	move.b	oRespawn(a0),d0
	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,d0
	moveq	#0,d1
	move.b	timeZone,d1
	bclr	#7,d1
	beq.s	.GotTime
	move.b	timeWarpDir.w,d2
	ext.w	d2
	neg.w	d2
	add.w	d2,d1
	bpl.s	.ChkOverflow
	moveq	#0,d1
	bra.s	.GotTime

; -------------------------------------------------------------------------

.ChkOverflow:
	cmpi.w	#3,d1
	bcs.s	.GotTime
	moveq	#2,d1

.GotTime:
	add.w	d1,d0
	rts
; End of function ObjMonitor_GetRespawn

; -------------------------------------------------------------------------

ObjMonitor_SolidObj:
	cmpi.b	#6,levelZone
	bne.s	.DoSolid
	tst.b	lvlDrawLowPlane
	beq.s	.ChkHighPlane
	tst.b	oSubtype2(a0)
	bne.s	.DoSolid
	rts

; -------------------------------------------------------------------------

.ChkHighPlane:
	tst.b	oSubtype2(a0)
	beq.s	.DoSolid
	rts

; -------------------------------------------------------------------------

.DoSolid:
	move.w	oX(a0),d3
	move.w	oY(a0),d4
	jmp	SolidObject
; End of function ObjMonitor_SolidObj

; -------------------------------------------------------------------------

ObjMonitorTimepost:
	tst.b	oSubtype(a0)
	bne.s	ObjMonitor
	tst.b	timeAttackMode
	beq.s	ObjMonitor
	jmp	CheckObjDespawnTime

; -------------------------------------------------------------------------

ObjMonitor:
	cmpi.b	#8,oSubtype(a0)
	bcc.w	ObjTimepostTimeIcon
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjMonitor_Index(pc,d0.w),d1
	jmp	ObjMonitor_Index(pc,d1.w)
; End of function ObjMonitor_Timepost

; -------------------------------------------------------------------------
ObjMonitor_Index:dc.w	ObjMonitor_Init-ObjMonitor_Index
	dc.w	ObjMonitor_Main-ObjMonitor_Index
	dc.w	ObjMonitor_Break-ObjMonitor_Index
	dc.w	ObjMonitor_Animate-ObjMonitor_Index
	dc.w	ObjMonitor_Display-ObjMonitor_Index
; -------------------------------------------------------------------------

ObjMonitor_Init:
	addq.b	#2,oRoutine(a0)
	move.b	#$E,oYRadius(a0)
	move.b	#$E,oXRadius(a0)
	move.l	#MapSpr_MonitorTimePost,oMap(a0)
	move.w	#$5A8,oTile(a0)
	move.b	#3,oPriority(a0)
	cmpi.b	#6,levelZone
	bne.s	.NotMMZ
	tst.b	oSubtype2(a0)
	bne.s	.NotMMZ
	ori.b	#$80,oTile(a0)
	move.b	#0,oPriority(a0)

.NotMMZ:
	move.b	#4,oRender(a0)
	move.b	#$F,oWidth(a0)
	bsr.w	ObjMonitor_GetRespawn
	bclr	#7,2(a2,d0.w)
	btst	#0,2(a2,d0.w)
	beq.s	.NotBroken
	move.b	#8,oRoutine(a0)
	move.b	#$11,oMapFrame(a0)
	rts

; -------------------------------------------------------------------------

.NotBroken:
	move.b	#$46,oColType(a0)
	move.b	oSubtype(a0),oAnim(a0)
; End of function ObjMonitor_Init

; -------------------------------------------------------------------------

ObjMonitor_Main:
	tst.b	oRender(a0)
	bpl.w	ObjMonitor_Display
	move.b	oRoutine2(a0),d0
	beq.s	.CheckSolid
	bsr.w	ObjMoveGrv
	jsr	CheckFloorEdge
	tst.w	d1
	bpl.w	ObjMonitor_Animate
	add.w	d1,oY(a0)
	clr.w	oYVel(a0)
	clr.b	oRoutine2(a0)
	bra.w	ObjMonitor_Animate

; -------------------------------------------------------------------------

.CheckSolid:
	tst.b	oRender(a0)
	bpl.s	ObjMonitor_Animate
	lea	objPlayerSlot.w,a1
	bsr.w	ObjMonitor_SolidObj
; End of function ObjMonitor_Main

; -------------------------------------------------------------------------

ObjMonitor_Animate:
	tst.w	timeStopTimer
	bne.s	ObjMonitor_Display
	lea	Ani_Monitor,a1
	bsr.w	AnimateObject
; End of function ObjMonitor_Animate

; -------------------------------------------------------------------------

ObjMonitor_Display:
	bsr.w	DrawObject
	jmp	CheckObjDespawnTime
; End of function ObjMonitor_Display

; -------------------------------------------------------------------------

ObjMonitor_Break:
	move.w	#$96,d0
	jsr	PlayFMSound
	addq.b	#4,oRoutine(a0)
	move.b	#0,oColType(a0)
	bsr.w	FindObjSlot
	bne.s	.NoContents
	move.b	#$1A,oID(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	move.b	oAnim(a0),oAnim(a1)
	move.b	oSubtype2(a0),oSubtype2(a1)

.NoContents:
	bsr.w	FindObjSlot
	bne.s	.NoExplosion
	move.b	#$18,oID(a1)
	move.w	oX(a0),oX(a1)
	move.w	oY(a0),oY(a1)
	move.b	#1,oRoutine2(a1)
	move.b	#1,oSubtype(a1)
	move.b	oSubtype2(a0),oSubtype2(a1)

.NoExplosion:
	bsr.w	ObjMonitor_GetRespawn
	bset	#0,2(a2,d0.w)
	move.b	#$11,oMapFrame(a0)
	bra.w	DrawObject
; End of function ObjMonitor_Break

; -------------------------------------------------------------------------

ObjMonitorContents:
	moveq	#0,d0
	move.b	oRoutine(a0),d0
	move.w	ObjMonitorContents_Index(pc,d0.w),d1
	jsr	ObjMonitorContents_Index(pc,d1.w)
	bra.w	DrawObject
; End of function ObjMonitorContents

; -------------------------------------------------------------------------
ObjMonitorContents_Index:dc.w	ObjMonitorContents_Init-ObjMonitorContents_Index
	dc.w	ObjMonitorContents_Main-ObjMonitorContents_Index
	dc.w	ObjMonitorContents_Destroy-ObjMonitorContents_Index
; -------------------------------------------------------------------------

ObjMonitorContents_Init:
	addq.b	#2,oRoutine(a0)
	move.w	#$85A8,oTile(a0)
	tst.b	oSubtype2(a0)
	beq.s	.NotPriority
	andi.b	#$7F,oTile(a0)

.NotPriority:
	move.b	#$24,oRender(a0)
	move.b	#3,oPriority(a0)
	move.b	#8,oWidth(a0)
	move.w	#-$300,oYVel(a0)
	moveq	#0,d0
	move.b	oAnim(a0),d0
	move.b	d0,oMapFrame(a0)
	movea.l	#MapSpr_MonitorTimePost,a1
	add.b	d0,d0
	adda.w	(a1,d0.w),a1
	addq.w	#1,a1
	move.l	a1,oMap(a0)
; End of function ObjMonitorContents_Init

; -------------------------------------------------------------------------

ObjMonitorContents_Main:

; FUNCTION CHUNK AT 0020A8E4 SIZE 00000006 BYTES
; FUNCTION CHUNK AT 0020A946 SIZE 00000076 BYTES

	tst.w	oYVel(a0)
	bpl.w	.GiveBonus
	bsr.w	ObjMove
	addi.w	#$18,oYVel(a0)
	rts

; -------------------------------------------------------------------------

.GiveBonus:
	addq.b	#2,oRoutine(a0)
	move.w	#$1D,oAnimTime(a0)
	move.b	oAnim(a0),d0
	bne.s	.Not1UP

.Gain1UP:
	addq.b	#1,lifeCount
	addq.b	#1,updateLives
	move.w	#$7A,d0
	jmp	SubCPUCmd

; -------------------------------------------------------------------------

.Not1UP:
	cmpi.b	#1,d0
	bne.s	.Not10Rings
	addi.w	#10,levelRings
	ori.b	#1,updateRings
	cmpi.w	#100,levelRings
	bcs.s	.RingSound
	bset	#1,lifeFlags
	beq.w	.Gain1UP
	cmpi.w	#200,levelRings
	bcs.s	.RingSound
	bset	#2,lifeFlags
	beq.w	.Gain1UP

.RingSound:
	move.w	#$95,d0
	jmp	PlayFMSound

; -------------------------------------------------------------------------

.Not10Rings:
	cmpi.b	#2,d0
	bne.s	ObjMonitorContents_NotShield
; End of function ObjMonitorContents_Main

; -------------------------------------------------------------------------

ObjMonitorContents_GainShield:
	move.b	#1,shieldFlag
	move.b	#3,objShieldSlot.w
	move.w	#$97,d0
	jmp	PlayFMSound
; End of function ObjMonitorContents_GainShield

; -------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR ObjMonitorContents_Main

ObjMonitorContents_NotShield:
	cmpi.b	#3,d0
	bne.s	ObjMonitorContents_NotInvinc
; END OF FUNCTION CHUNK	FOR ObjMonitorContents_Main
; -------------------------------------------------------------------------

ObjMonitorContents_GainInvinc:
	move.b	#1,invincibleFlag
	if REGION=USA
		move.w	#$528,objPlayerSlot+oPlayerInvinc.w
	else
		move.w	#$4B0,objPlayerSlot+oPlayerInvinc.w
	endif
	move.b	#3,objInvStar1Slot.w
	move.b	#1,objInvStar1Slot+oAnim.w
	move.b	#3,objInvStar2Slot.w
	move.b	#2,objInvStar2Slot+oAnim.w
	move.b	#3,objInvStar3Slot.w
	move.b	#3,objInvStar3Slot+oAnim.w
	move.b	#3,objInvStar4Slot.w
	move.b	#4,objInvStar4Slot+oAnim.w
	tst.b	timeZone
	bne.s	.NotPast
	move.w	#$82,d0
	jsr	SubCPUCmd

.NotPast:
	move.w	#$6D,d0
	jmp	SubCPUCmd
; End of function ObjMonitorContents_GainInvinc

; -------------------------------------------------------------------------
	rts

; -------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR ObjMonitorContents_Main

ObjMonitorContents_NotInvinc:
	cmpi.b	#4,d0
	bne.s	.NotSpeedShoes

.GainSpeedShoes:
	move.b	#1,speedShoesFlag
	if REGION=USA
		move.w	#$528,objPlayerSlot+oPlayerShoes.w
	else
		move.w	#$4B0,objPlayerSlot+oPlayerShoes.w
	endif
	move.w	#$C00,sonicTopSpeed.w
	move.w	#$18,sonicAcceleration.w
	move.w	#$80,sonicDeceleration.w
	tst.b	timeZone
	bne.s	.NotPast
	move.w	#$82,d0
	jsr	SubCPUCmd

.NotPast:
	move.w	#$6C,d0
	jmp	SubCPUCmd

; -------------------------------------------------------------------------

.NotSpeedShoes:
	cmpi.b	#5,d0
	bne.s	.NotTimeStop
	move.w	#300,timeStopTimer
	rts

; -------------------------------------------------------------------------

.NotTimeStop:
	cmpi.b	#6,d0
	bne.s	.NotBlueRing
	move.w	#$9D,d0
	jsr	PlayFMSound
	move.b	#1,blueRing
	rts

; -------------------------------------------------------------------------

.NotBlueRing:
	bsr.w	ObjMonitorContents_GainShield
	bsr.w	ObjMonitorContents_GainInvinc
	bra.s	.GainSpeedShoes
; END OF FUNCTION CHUNK	FOR ObjMonitorContents_Main
; -------------------------------------------------------------------------

ObjMonitorContents_Destroy:
	subq.w	#1,oAnimTime(a0)
	bmi.w	DeleteObject
	rts
; End of function ObjMonitorContents_Destroy

; -------------------------------------------------------------------------

Ani_Monitor:
	include	"Level/_Objects/Monitor and Time Post/Data/Animations.asm"
	even
MapSpr_MonitorTimePost:
	include	"Level/_Objects/Monitor and Time Post/Data/Mappings.asm"
	even
	
; -------------------------------------------------------------------------
