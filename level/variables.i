; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Level variables
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Object structure
; -------------------------------------------------------------------------

	rsreset

oID		rs.b	1			; ID

oRender		rs.b	1			; Render flags
oTile		rs.w	1			; Base tile ID
oMap		rs.l	1			; Sprite mappings pointer

oX		rs.w	1			; X position
oYScr		rs.b	0			; Y position (screen mode)
oXSub		rs.w	1			; X position subpixel
oY		rs.l	1			; Y position

oXVel		rs.w	1			; X velocity
oYVel		rs.w	1			; Y velocity

oVar14		rs.b	1			; Object specific flags
oVar15		rs.b	1

oYRadius	rs.b	1			; Y radius
oXRadius	rs.b	1			; X radius
oPriority	rs.b	1			; Sprite draw priority level
oWidth		rs.b	1			; Width

oMapFrame	rs.b	1			; Sprite mapping frame ID
oAnimFrame	rs.b	1			; Animation script frame ID
oAnim		rs.b	1			; Animation ID
oPrevAnim	rs.b	1			; Previous previous animation ID
oAnimTime	rs.b	1			; Animation timer

oVar1F		rs.b	1			; Object specific flag

oVar20		rs.b	0			; Object specific flag
oColType	rs.b	1			; Collision type
oVar21		rs.b	0			; Object specific flag
oColStatus	rs.b	1			; Collision status

oStatus		rs.b	1			; Status flags
oRespawn	rs.b	1			; Respawn table entry ID
oRoutine	rs.b	1			; Routine ID
oVar25		rs.b	0			; Object specific flag
oRoutine2	rs.b	1			; Secondary routine ID
oAngle		rs.b	1			; Angle

oVar27		rs.b	1			; Object specific flag

oSubtype	rs.b	1			; Subtype ID
oSubtype2	rs.b	1			; Secondary subtype ID

oVar2A		rs.b	1			; Object specific flags
oVar2B		rs.b	1
oVar2C		rs.b	1
oVar2D		rs.b	1
oVar2E		rs.b	1
oVar2F		rs.b	1
oVar30		rs.b	1
oVar31		rs.b	1
oVar32		rs.b	1
oVar33		rs.b	1
oVar34		rs.b	1
oVar35		rs.b	1
oVar36		rs.b	1
oVar37		rs.b	1
oVar38		rs.b	1
oVar39		rs.b	1
oVar3A		rs.b	1
oVar3B		rs.b	1
oVar3C		rs.b	1
oVar3D		rs.b	1
oVar3E		rs.b	1
oVar3F		rs.b	1

oSize		rs.b	0			; Length of object structure

; -------------------------------------------------------------------------
; Player object variables
; -------------------------------------------------------------------------

oPlayerGVel		EQU	oVar14		; Ground velocity
oPlayerCharge		EQU	oVar2A		; Peelout/spindash charge timer

oPlayerCtrl		EQU	oVar2C		; Control flags
oPlayerJump		EQU	oVar3C		; Jump flag
oPlayerMoveLock		EQU	oVar3E		; Movement lock timer

oPlayerPriAngle		EQU	oVar36		; Primary angle
oPlayerSecAngle		EQU	oVar37		; Secondary angle
oPlayerStick		EQU	oVar38		; Collision stick flag

oPlayerHurt		EQU	oVar30		; Hurt timer
oPlayerInvinc		EQU	oVar32		; Invincibility timer
oPlayerShoes		EQU	oVar34		; Speed shoes timer
oPlayerReset		EQU	oVar3A		; Reset timer

oPlayerRotAngle		EQU	oVar2B		; Platform rotation angle
oPlayerRotDist		EQU	oVar39		; Platform rotation distance

oPlayerPushObj		EQU	oVar20		; ID of object being pushed on
oPlayerStandObj		EQU	oVar3D		; ID of object being stood on

; -------------------------------------------------------------------------
; RAM
; -------------------------------------------------------------------------

	rsset	WORKRAM+$2000
levelBlocks 		rs.b	$2000
unkLvlBuffer2 		rs.b	$1000
			rs.b	$3000

	rsset	WORKRAM+$FF00A000
levelLayout 		rs.b	$800
deformBuffer		rs.b	$200
nemBuffer		rs.b	$200
objDrawQueue		rs.b	$400
			rs.b	$1800
sonicArtBuf 		rs.b	$300
sonicRecordBuf		rs.b	$100
hscroll 		rs.b	$400

objects			rs.b	0
objPlayerSlot 		rs.b	oSize
objPlayerSlot2 		rs.b	oSize
objHUDScoreSlot		rs.b	oSize
objHUDLivesSlot		rs.b	oSize
objTtlCardSlot		rs.b	oSize
objHUDRingsSlot		rs.b	oSize
objShieldSlot 		rs.b	oSize
objBubblesSlot 		rs.b	oSize
objInvStar1Slot		rs.b	oSize
objInvStar2Slot		rs.b	oSize
objInvStar3Slot		rs.b	oSize
objInvStar4Slot		rs.b	oSize
objTimeStar1Slot	rs.b	oSize
objTimeStar2Slot	rs.b	oSize
objTimeStar3Slot	rs.b	oSize
objTimeStar4Slot	rs.b	oSize
			rs.b	oSize
			rs.b	oSize
			rs.b	oSize
			rs.b	oSize
			rs.b	oSize
			rs.b	oSize
			rs.b	oSize
			rs.b	oSize
			rs.b	oSize
			rs.b	oSize
			rs.b	oSize
			rs.b	oSize
			rs.b	oSize
			rs.b	oSize
			rs.b	oSize
objHUDIconSlot		rs.b	oSize

dynObjects 		rs.b	$60*oSize
objectsEnd		rs.b	0

			rs.b	$A
fmSndQueue1 		rs.b	1
fmSndQueue2 		rs.b	1
fmSndQueue3 		rs.b	1
			rs.b	$5F3
gameMode 		rs.b	1
			rs.b	1
			
playerCtrl		rs.b	0
playerCtrlHold 		rs.b	1
playerCtrlTap		rs.b	1
p1CtrlData		rs.b	0
p1CtrlHold 		rs.b	1
p1CtrlTap		rs.b	1
p2CtrlData		rs.b	0
p2CtrlHold 		rs.b	1
p2CtrlTap		rs.b	1

			rs.l	1
vdpReg01 		rs.w	1
			rs.b	6
vintTimer 		rs.w	1
vscrollScreen 		rs.l	1
hscrollScreen 		rs.l	1
			rs.b	6
vdpReg0A 		rs.w	1
palFadeInfo		rs.b	0
palFadeStart		rs.b	1
palFadeLen 		rs.b	1

miscVariables		rs.b	0
vintECount 		rs.b	1
			rs.b	1
vintRoutine 		rs.b	1
			rs.b	1
spriteCount 		rs.b	1
			rs.b	9
rngSeed 		rs.l	1
paused 			rs.w	1
			rs.l	1
dmaCmdLow		rs.w	1
			rs.l	1
waterHeight 		rs.w	1
waterHeight2		rs.w	1
			rs.b	3
waterRoutine		rs.b	1
waterFullscreen 	rs.b	1
			rs.b	$17
aniArtFrames		rs.b	6
aniArtTimers		rs.b	6
			rs.b	$E
plcBuffer 		rs.b	$60
plcNemWrite 		rs.l	1
plcRepeat 		rs.l	1
plcPixel 		rs.l	1
plcRow 			rs.l	1
plcRead 		rs.l	1
plcShift 		rs.l	1
plcTileCount 		rs.w	1
plcProcTileCnt 		rs.w	1
hintFlag 		rs.w	1
			rs.w	1
			
cameraX 		rs.l	1
cameraY 		rs.l	1
cameraBgX 		rs.l	1
cameraBgY 		rs.l	1
cameraBg2X 		rs.l	1
cameraBg2Y 		rs.l	1
cameraBg3X 		rs.l	1
cameraBg3Y 		rs.l	1
destLeftBound		rs.w	1
destRightBound		rs.b	2
destTopBound		rs.w	1
destBottomBound		rs.w	1
leftBound 		rs.w	1
rightBound 		rs.w	1
topBound 		rs.w	1
bottomBound 		rs.w	1
unusedF730 		rs.w	1
leftBound3 		rs.w	1
			rs.b	6
scrollXDiff		rs.w	1
scrollYDiff		rs.w	1
camYCenter 		rs.w	1
unusedF740 		rs.b	1
unusedF741 		rs.b	1
eventRoutine		rs.w	1
scrollLock 		rs.w	1
unusedF746 		rs.w	1
unusedF748 		rs.w	1
horizBlkCrossed		rs.b	1
vertiBlkCrossed		rs.b	1
horizBlkCrossedBg	rs.b	1
vertiBlkCrossedBg	rs.b	1
horizBlkCrossedBg2	rs.b	2
horizBlkCrossedBg3	rs.b	1
			rs.b	1
			rs.b	1
			rs.b	1
scrollFlags 		rs.w	1
scrollFlagsBg		rs.w	1
scrollFlagsBg2		rs.w	1
scrollFlagsBg3		rs.w	1
btmBoundShift		rs.w	1
			rs.w	1
			
sonicTopSpeed		rs.w	1
sonicAcceleration	rs.w	1
sonicDeceleration	rs.w	1
sonicLastFrame		rs.b	1
updateSonicArt		rs.b	1
primaryAngle		rs.b	1
			rs.b	1
secondaryAngle		rs.b	1
			rs.b	1
			
objManagerRout		rs.b	1
			rs.b	1
objPrevCamX		rs.w	1
objLoadAddrR		rs.l	1
objLoadAddrL		rs.l	1
objLoadAddr2R		rs.l	1
objLoadAddr2L		rs.l	1
boredTimer 		rs.w	1
boredTimerP2 		rs.w	1
timeWarpDir		rs.b	1
			rs.b	1
timeWarpTimer		rs.w	1
lookMode 		rs.b	1
			rs.b	1
demoPtr 		rs.l	1
demoTimer 		rs.w	1
demoS1Index 		rs.w	1
			rs.l	1
collisionPtr		rs.l	1
			rs.b	6
camXCenter 		rs.w	1
			rs.b	5
bossFlags		rs.b	1
sonicRecordIndex	rs.w	1
bossFight 		rs.b	1
			rs.b	1
specialChunks 		rs.l	1
palCycleSteps 		rs.b	7
palCycleTimers		rs.b	7
			rs.b	9
windTunnelFlag		rs.b	1
			rs.b	1
			rs.b	1
waterSlideFlag 		rs.b	1
			rs.b	1
ctrlLocked 		rs.b	1
			rs.b	3
scoreChain		rs.w	1
bonusCount1		rs.w	1
bonusCount2		rs.w	1
updateResultsBonus	rs.b	1
			rs.b	3
savedSR 		rs.w	1
			rs.b	$24
sprites 		rs.b	$200
waterFadePal		rs.b	$80
waterPalette		rs.b	$80
palette 		rs.b	$80
fadePalette 		rs.b	$80

; ----------------------------------------------------------------------------- ;
