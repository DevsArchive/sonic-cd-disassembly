; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Load saved data
; -------------------------------------------------------------------------

LoadTimeWarpData:
	move.w	warpX,oX(a6)
	move.w	warpY,oY(a6)
	move.b	warpPlayerFlags,oFlags(a6)
	move.w	warpGVel,oPlayerGVel(a6)
	move.w	warpXVel,oXVel(a6)
	move.w	warpYVel,oYVel(a6)
	move.w	warpRings,rings
	move.b	warpLivesFlags,livesFlags
	move.l	warpTime,time
	move.b	warpWaterRoutine,waterRoutine.w
	move.w	warpBtmBound,bottomBound.w
	move.w	warpBtmBound,destBottomBound.w
	move.w	warpCamX,cameraX.w
	move.w	warpCamY,cameraY.w
	move.w	warpCamBgX,cameraBgX.w
	move.w	warpCamBgY,cameraBgY.w
	move.w	warpCamBg2X,cameraBg2X.w
	move.w	warpCamBg2Y,cameraBg2Y.w
	move.w	warpCamBg3X,cameraBg3X.w
	move.w	warpCamBg3Y,cameraBg3Y.w
	cmpi.b	#6,zone
	bne.s	.NoMini2
	move.b	warpMiniSonic,miniSonic

.NoMini2:
	tst.b	spawnMode
	bpl.s	.End
	move.w	warpX,d0
	subi.w	#320/2,d0
	move.w	d0,leftBound.w

.End:
	rts
	
; -------------------------------------------------------------------------

LoadCheckpointData:
	lea	objPlayerSlot.w,a6
	cmpi.b	#2,spawnMode
	beq.w	LoadTimeWarpData
	
	move.b	savedSpawnMode,spawnMode
	move.w	savedX,oX(a6)
	move.w	savedY,oY(a6)
	clr.w	rings
	clr.b	livesFlags
	move.l	savedTime,time
	move.b	#59,timeFrames
	subq.b	#1,timeSeconds
	move.b	savedWaterRoutine,waterRoutine.w
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
	cmpi.b	#6,zone
	bne.s	.NoMini
	move.b	savedMiniSonic,miniSonic

.NoMini:
	cmpi.b	#2,zone
	bne.s	.NoWater
	move.w	savedWaterHeight,waterHeight2.w
	move.b	savedWaterRoutine,waterRoutine.w
	move.b	savedWaterFull,waterFullscreen.w

.NoWater:
	tst.b	spawnMode
	bpl.s	.End
	move.w	savedX,d0
	subi.w	#320/2,d0
	move.w	d0,leftBound.w

.End:
	rts

; -------------------------------------------------------------------------
