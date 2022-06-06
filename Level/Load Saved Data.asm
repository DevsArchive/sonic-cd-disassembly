; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Saved data loading functions
; -------------------------------------------------------------------------

TimeTravel_LoadData:
	move.w	travelX,oX(a6)
	move.w	travelY,oY(a6)
	move.b	travelStatus,oStatus(a6)
	move.w	travelGVel,oPlayerGVel(a6)
	move.w	travelXVel,oXVel(a6)
	move.w	travelYVel,oYVel(a6)
	move.w	travelRingCnt,levelRings
	move.b	travelLifeFlags,lifeFlags
	move.l	travelTime,levelTime
	move.b	travelWaterRout,waterRoutine.w
	move.w	travelBtmBound,bottomBound.w
	move.w	travelBtmBound,destBottomBound.w
	move.w	travelCamX,cameraX.w
	move.w	travelCamY,cameraY.w
	move.w	travelCamBgX,cameraBgX.w
	move.w	travelCamBgY,cameraBgY.w
	move.w	travelCamBg2X,cameraBg2X.w
	move.w	travelCamBg2Y,cameraBg2Y.w
	move.w	travelCamBg3X,cameraBg3X.w
	move.w	travelCamBg3Y,cameraBg3Y.w
	cmpi.b	#6,levelZone
	bne.s	.NoMini2
	move.b	travelMiniSonic,miniSonic

.NoMini2:
	tst.b	resetLevelFlags
	bpl.s	.End2
	move.w	travelX,d0
	subi.w	#320/2,d0
	move.w	d0,leftBound.w

.End2:
	rts
; END OF FUNCTION CHUNK	FOR ObjCheckpoint_LoadData
; -------------------------------------------------------------------------

ObjCheckpoint_LoadData:
	lea	objPlayerSlot.w,a6
	cmpi.b	#2,resetLevelFlags
	beq.w	TimeTravel_LoadData
	move.b	savedResetLvlFlags,resetLevelFlags
	move.w	savedX,oX(a6)
	move.w	savedY,oY(a6)
	clr.w	levelRings
	clr.b	lifeFlags
	move.l	savedTime,levelTime
	move.b	#59,levelTime+3
	subq.b	#1,levelTime+2
	move.b	savedWaterRout,waterRoutine.w
	move.w	savedBtmBound,bottomBound.w
	move.w	savedBtmBound,destBottomBound.w
	move.w	savedCamX,cameraX.w
	move.w	savedCamY,cameraY.w
	move.w	savedCamBgX,cameraBgX.w
	move.w	savedCamBgY,cameraBgY.w
	move.w	savedCamBg2X,cameraBg2X.w
	move.w	savedCamBg2Y,cameraBg2Y.w
	move.w	savedCamBg3X,cameraBg3X.w
	move.w	savedCamBg3Y,cameraBg3Y.w
	cmpi.b	#6,levelZone
	bne.s	.NoMini
	move.b	savedMiniSonic,miniSonic

.NoMini:
	cmpi.b	#2,levelZone
	bne.s	.NoWater
	move.w	savedWaterHeight,waterHeight2.w
	move.b	savedWaterRout,waterRoutine.w
	move.b	savedWaterFull,waterFullscreen.w

.NoWater:
	tst.b	resetLevelFlags
	bpl.s	.End
	move.w	savedX,d0
	subi.w	#320/2,d0
	move.w	d0,leftBound.w

.End:
	rts
; End of function ObjCheckpoint_LoadData

; -------------------------------------------------------------------------
