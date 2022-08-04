; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Main CPU global variables
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Constants
; -------------------------------------------------------------------------

; Time zones
	rsreset
TIME_PAST		rs.b	1		; Past
TIME_PRESENT		rs.b	1		; Present
TIME_FUTURE		rs.b	1		; Future

; -------------------------------------------------------------------------
; Variables
; -------------------------------------------------------------------------

	rsset	WORKRAM+$F00
MAINVARS		rs.b	0		; Main CPU global variables
ipxVSync		rs.b	1		; IPX VSync flag
timeAttackMode		rs.b	1		; Time attack mode flag
savedLevel		rs.w	1		; Saved level
			rs.b	$C
timeAttackTime		rs.l	1		; Time attack time
timeAttackLevel		rs.w	1		; Time attack level
ipxVDPReg1		rs.w	1		; IPX VDP register 1
timeAttackUnlock	rs.b	1		; Last unlocked time attack zone
unkBuRAMVar		rs.b	1		; Unknown Backup RAM variable
goodFutures		rs.b	1		; Good futures achieved flags
			rs.b	1
demoID			rs.b	1		; Demo ID
titleFlags		rs.b	1		; Title screen flags
			rs.b	1
saveDisabled		rs.b	1		; Save disabled flag
timeStones		rs.b	1		; Time stones retrieved flags
curSpecStage		rs.b	1		; Current special stage
palClearFlags		rs.b	1		; Palette clear flags
			rs.b	1
endingID		rs.b	1		; Ending ID
specStageLost		rs.b	1		; Special stage lost flag
			rs.b	$DA
unkLvlBuffer 		rs.b	$200		; Unknown level buffer
lvlObjRespawns 		rs.b	$2FE		; Level object respawn flags
			rs.l	1
levelRestart		rs.w	1		; Level restart flag
lvlFrameTimer 		rs.w	1		; Level frame timer
level			rs.b	0		; Level ID
levelZone		rs.b	1		; Zone ID
levelAct		rs.b	1		; Act ID
lifeCount		rs.b	1		; Life count
usePlayer2 		rs.b	1		; Use player 2
playerAirLeft 		rs.w	1		; Player air left
lvlTimeOver 		rs.b	1		; Level time over
lifeFlags 		rs.b	1		; Life flags
updateLives 		rs.b	1		; Update HUD life count
updateRings 		rs.b	1		; Update HUD ring count
updateTime 		rs.b	1		; Update HUD timer
updateScore 		rs.b	1		; Update HUD score
levelRings		rs.w	1		; Level ring count
levelTime		rs.l	1		; Level time
levelScore		rs.l	1		; Level score
plcLoadFlags		rs.b	1		; PLC load flags
palFadeFlags		rs.b	1		; Palette fade flags
shieldFlag 		rs.b	1		; Shield flag
invincibleFlag 		rs.b	1		; Invincible flag
speedShoesFlag 		rs.b	1		; Speed shoes flag
timeWarpFlag 		rs.b	1		; Time warp flag
resetLevelFlags		rs.b	1		; Reset level flags
savedResetLvlFlags	rs.b	1		; Saved reset level flags
savedX 			rs.w	1		; Saved X position
savedY 			rs.w	1		; Saved Y position
travelRingCnt		rs.w	1		; Time travel saved ring count
savedTime 		rs.l	1		; Saved time
timeZone		rs.b	1		; Time zone
			rs.b	1
savedBtmBound		rs.w	1		; Saved bottom boundary
savedCamX		rs.w	1		; Saved camera X position
savedCamY		rs.w	1		; Saved camera Y position
savedCamBgX		rs.w	1		; Saved background camera X position
savedCamBgY		rs.w	1		; Saved background camera Y position
savedCamBg2X		rs.w	1		; Saved background camera X position 2
savedCamBg2Y		rs.w	1		; Saved background camera Y position 2
savedCamBg3X		rs.w	1		; Saved background camera X position 3
savedCamBg3Y		rs.w	1		; Saved background camera Y position 3
savedWaterHeight	rs.b	1		; Saved water height
savedWaterRout		rs.b	1		; Saved water routine
savedWaterFull		rs.b	1		; Saved water fullscreen flag
travelLifeFlags		rs.b	1		; Time travel saved life flags
travelResetLvlFlags	rs.b	1		; Time travel saved reset level flags
			rs.b	1
travelX 		rs.w	1		; Time travel saved X position
travelY 		rs.w	1		; Time travel saved Y position
travelStatus		rs.b	1
			rs.b	1
travelBtmBound		rs.w	1		; Time travel saved bottom boundary
travelCamX		rs.w	1		; Time travel saved camera X position
travelCamY		rs.w	1		; Time travel saved camera Y position
travelCamBgX		rs.w	1		; Time travel saved background camera X position
travelCamBgY		rs.w	1		; Time travel saved background camera Y position
travelCamBg2X		rs.w	1		; Time travel saved background camera X position 2
travelCamBg2Y		rs.w	1		; Time travel saved background camera Y position 2
travelCamBg3X		rs.w	1		; Time travel saved background camera X position 3
travelCamBg3Y		rs.w	1		; Time travel saved background camera Y position 3
travelWaterHeight	rs.w	1		; Time travel saved water height
travelWaterRout		rs.b	1		; Time travel saved water routine
travelWaterFull		rs.b	1		; Time travel saved water fullscreen flag
travelGVel 		rs.w	1		; Time travel saved ground velocity
travelXVel 		rs.w	1		; Time travel saved X velocity
travelYVel 		rs.w	1		; Time travel saved Y velocity
goodFuture		rs.b	1		; Good future flag
lvlLoadShieldArt	rs.b	1		; Level load shield art flag
unkLevelFlag 		rs.b	1		; Unknown level flag
projDestroyed		rs.b	1		; Projector destroyed flag
enteredBigRing		rs.b	1		; Entered big ring flag
blueRing 		rs.b	1		; Blue ring flag
travelTime 		rs.l	1		; Time travel saved time
lastCamPLC		rs.w	1		; Last camera PLC
			rs.b	1
amyCaptured		rs.b	1		; Amy captured flag
nextLifeScore		rs.l	1		; Next life score
angleBuffer 		rs.b	1		; Angle buffer
angleNormalBuf		rs.b	1		; Angle normal buffer
quadrantNormalBuf	rs.b	1		; Quadrant normal buffer
floorDist 		rs.b	1		; Floor distance
demoMode		rs.w	1		; Demo mode flag
			rs.w	1
s1CreditsIndex		rs.w	1		; Credits index (leftover from Sonic 1)
versionCache 		rs.b	1		; Hardware version cache
			rs.b	1
debugCheat		rs.w	1		; Debug cheat flag
lvlInitFlag 		rs.l	1		; Level initialized flag
lastCheckpoint		rs.b	1		; Last checkpoint ID
			rs.b	1
goodFutureFlags		rs.b	1		; Good future flags
savedMiniSonic		rs.b	1		; Saved mini Sonic flag
			rs.b	1
travelMiniSonic		rs.b	1		; Time travel mini Sonic flag
			rs.b	$6C
flowerPosBuf		rs.b	$300		; Flower position buffer
flowerCount		rs.b	3		; Flower count
lvlEnableDisplay	rs.b	1		; Enable display in level
lvlDebugObject 		rs.b	1		; Level debug object
			rs.b	1
lvlDebugMode 		rs.w	1		; Level debug mode
			rs.w	1
lvlFrameCount 		rs.l	1		; Level frame count
timeStopTimer		rs.w	1		; Time stop timer
logSpikeAnimTimer	rs.b	1		; Log spike animation timer (leftover from Sonic 1)
logSpikeAnimFrame	rs.b	1		; Log spike animation frame (leftover from Sonic 1)
ringAnimTimer		rs.b	1		; Ring animation timer
ringAnimFrame		rs.b	1		; Ring animation frame
lvlUnkAnimTimer		rs.b	1		; Unknown animation timer (leftover from Sonic 1)
lvlUnkAnimFrame		rs.b	1		; Unknown animation frame (leftover from Sonic 1)
ringLossAnimTimer	rs.b	1		; Ring loss animation timer
ringLossAnimFrame	rs.b	1		; Ring loss animation frame
ringLossAnimAccum	rs.w	1		; Ring loss animation accumulator
			rs.b	$C
lvlCamXCopy		rs.l	1		; Level camera X position copy
lvlCamYCopy		rs.l	1		; Level camera Y position copy
lvlCamXBgCopy		rs.l	1		; Level camera background X position copy
lvlCamYBgCopy		rs.l	1		; Level camera background Y position copy
lvlCamXBg2Copy		rs.l	1		; Level camera background X position 2 copy
lvlCamYBg2Copy		rs.l	1		; Level camera background Y position 2 copy
lvlCamXBg3Copy		rs.l	1		; Level camera background X position 3 copy
lvlCamYBg3Copy		rs.l	1		; Level camera background Y position 3 copy
lvlScrollFlagsCopy	rs.l	1		; Level scroll flags copy
			rs.l	1
lvlDebugBlock 		rs.w	1		; Level debug block ID
			rs.l	1
lvlDebugSubtype2	rs.b	1		; Level debug subtype 2 ID
waterSwayAngle		rs.b	1		; Water sway angle
lvlDrawLowPlane		rs.b	1		; Level draw on low plane flag
levelStarted		rs.b	1		; Level started flag
bossMusicPlaying	rs.b	1		; Boss music playing flag
			rs.b	1
wwzBeamMode		rs.b	1		; Wacky Workbench electric beam mode
miniSonic 		rs.b	1		; Mini Sonic flag
			rs.b	$24
aniArtBuffer 		rs.b	$480		; Animated art buffer
lvlLayerSpeeds 		rs.b	$200		; Level layer speeds
MAINVARSSZ		EQU	__rs-MAINVARS	; Size of Main CPU global variables area

WORKRAMFILE		rs.b	$6000		; Work RAM file data
WORKRAMFILESZ		EQU	$FFFB00-WORKRAMFILE

; -------------------------------------------------------------------------
