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
unkBuffer 		rs.b	$200		; Unknown level buffer

OBJFLAGSCNT		EQU	$2FC		; Saved object flags entry count
savedObjFlags 		rs.b	2+OBJFLAGSCNT	; Saved object flags

			rs.l	1
levelRestart		rs.w	1		; Level restart flag
levelFrames 		rs.w	1		; Level frame counter
zoneAct			rs.b	0		; Zone and act ID
zone			rs.b	1		; Zone ID
act			rs.b	1		; Act ID
lives			rs.b	1		; Life count
usePlayer2 		rs.b	1		; Use player 2
drownTimer 		rs.w	1		; Drown timer
timeOver 		rs.b	1		; Level time over
livesFlags 		rs.b	1		; Lives flags
updateHUDLives 		rs.b	1		; Update HUD life count
updateHUDRings 		rs.b	1		; Update HUD ring count
updateHUDTime 		rs.b	1		; Update HUD timer
updateHUDScore 		rs.b	1		; Update HUD score
rings			rs.w	1		; Ring count
time			rs.b	1		; Time
timeMinutes		rs.b	1		; Minutes
timeSeconds		rs.b	1		; Seconds
timeFrames		rs.b	1		; Centiseconds
score			rs.l	1		; Score
plcLoadFlags		rs.b	1		; PLC load flags
palFadeFlags		rs.b	1		; Palette fade flags
shield			rs.b	1		; Shield flag
invincible 		rs.b	1		; Invincible flag
speedShoes 		rs.b	1		; Speed shoes flag
timeWarp 		rs.b	1		; Time warp flag
spawnMode		rs.b	1		; Spawn mode flag
savedSpawnMode		rs.b	1		; Saved spawn mode flag
savedX 			rs.w	1		; Saved X position
savedY 			rs.w	1		; Saved Y position
warpRings		rs.w	1		; Time warp ring count
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
savedWaterRoutine	rs.b	1		; Saved water routine
savedWaterFull		rs.b	1		; Saved water fullscreen flag
warpLivesFlags		rs.b	1		; Time warp lives flags
warpSpawnMode		rs.b	1		; Time warp spawn mode flag
			rs.b	1
warpX 			rs.w	1		; Time warp X position
warpY 			rs.w	1		; Time warp Y position
warpPlayerFlags		rs.b	1		; Time warp flags
			rs.b	1
warpBtmBound		rs.w	1		; Time warp bottom boundary
warpCamX		rs.w	1		; Time warp camera X position
warpCamY		rs.w	1		; Time warp camera Y position
warpCamBgX		rs.w	1		; Time warp background camera X position
warpCamBgY		rs.w	1		; Time warp background camera Y position
warpCamBg2X		rs.w	1		; Time warp background camera X position 2
warpCamBg2Y		rs.w	1		; Time warp background camera Y position 2
warpCamBg3X		rs.w	1		; Time warp background camera X position 3
warpCamBg3Y		rs.w	1		; Time warp background camera Y position 3
warpWaterHeight		rs.w	1		; Time warp water height
warpWaterRoutine	rs.b	1		; Time warp water routine
warpWaterFull		rs.b	1		; Time warp water fullscreen flag
warpGVel 		rs.w	1		; Time warp ground velocity
warpXVel 		rs.w	1		; Time warp X velocity
warpYVel 		rs.w	1		; Time warp Y velocity
goodFuture		rs.b	1		; Good future flag
powerup			rs.b	1		; Powerup ID
unkLevelFlag 		rs.b	1		; Unknown level flag
projDestroyed		rs.b	1		; Projector destroyed flag
specialStage		rs.b	1		; Special stage flag
combineRing 		rs.b	1		; Combine ring flag (leftover)
warpTime 		rs.l	1		; Time warp time
sectionID		rs.w	1		; Section ID
			rs.b	1
amyCaptured		rs.b	1		; Amy captured flag
nextLifeScore		rs.l	1		; Next life score
debugAngle 		rs.b	1		; Debug angle
debugAngleShift		rs.b	1		; Debug angle (shifted)
debugQuadrant		rs.b	1		; Debug quadrant
debugFloorDist 		rs.b	1		; Debug floor distance
demoMode		rs.w	1		; Demo mode flag
			rs.w	1
s1CreditsIndex		rs.w	1		; Credits index (leftover from Sonic 1)
versionCache 		rs.b	1		; Hardware version cache
			rs.b	1
debugCheat		rs.w	1		; Debug cheat flag
initFlag 		rs.l	1		; Initialized flag
checkpoint		rs.b	1		; Checkpoint ID
			rs.b	1
goodFutureFlags		rs.b	1		; Good future flags
savedMiniSonic		rs.b	1		; Saved mini Sonic flag
			rs.b	1
warpMiniSonic		rs.b	1		; Time warp mini Sonic flag
			rs.b	$6C
flowerPosBuf		rs.b	$300		; Flower position buffer
flowerCount		rs.b	3		; Flower count
fadeEnableDisplay	rs.b	1		; Enable display when fading
debugObject 		rs.b	1		; Level debug object
			rs.b	1
debugMode 		rs.w	1		; Level debug mode
			rs.w	1
levelVIntCounter	rs.l	1		; Level V-BLANK interrupt counter
timeStopTimer		rs.w	1		; Time stop timer
logSpikeAnimTimer	rs.b	1		; Log spike animation timer (leftover from Sonic 1)
logSpikeAnimFrame	rs.b	1		; Log spike animation frame (leftover from Sonic 1)
ringAnimTimer		rs.b	1		; Ring animation timer
ringAnimFrame		rs.b	1		; Ring animation frame
unkAnimTimer		rs.b	1		; Unknown animation timer (leftover from Sonic 1)
unkAnimFrame		rs.b	1		; Unknown animation frame (leftover from Sonic 1)
ringLossAnimTimer	rs.b	1		; Ring loss animation timer
ringLossAnimFrame	rs.b	1		; Ring loss animation frame
ringLossAnimAccum	rs.w	1		; Ring loss animation accumulator
			rs.b	$C
camXCopy		rs.l	1		; Camera X position copy
camYCopy		rs.l	1		; Camera Y position copy
camXBgCopy		rs.l	1		; Camera background X position copy
camYBgCopy		rs.l	1		; Camera background Y position copy
camXBg2Copy		rs.l	1		; Camera background X position 2 copy
camYBg2Copy		rs.l	1		; Camera background Y position 2 copy
camXBg3Copy		rs.l	1		; Camera background X position 3 copy
camYBg3Copy		rs.l	1		; Camera background Y position 3 copy
scrollFlagsCopy		rs.w	1		; Scroll flags copy
scrollFlagsBgCopy	rs.w	1		; Scroll flags copy (background)
scrollFlagsBg2Copy	rs.w	1		; Scroll flags copy (background 2)
scrollFlagsBg3Copy	rs.w	1		; Scroll flags copy (background 3)
debugBlock 		rs.w	1		; Level debug block ID
			rs.l	1
debugSubtype2		rs.b	1		; Level debug subtype 2 ID
waterSwayAngle		rs.b	1		; Water sway angle
layer			rs.b	1		; Layer ID
levelStarted		rs.b	1		; Level started flag
bossMusic		rs.b	1		; Boss music flag
			rs.b	1
wwzBeamMode		rs.b	1		; Wacky Workbench electric beam mode
miniSonic 		rs.b	1		; Mini Sonic flag
			rs.b	$24
aniArtBuffer 		rs.b	$480		; Animated art buffer
scrlSectSpeeds		rs.b	$200		; Scroll section speeds
MAINVARSSZ		EQU	__rs-MAINVARS	; Size of Main CPU global variables area

WORKRAMFILE		rs.b	$6000		; Work RAM file data
WORKRAMFILESZ		EQU	$FFFB00-WORKRAMFILE

; -------------------------------------------------------------------------
