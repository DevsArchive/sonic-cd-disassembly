; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Level definitions
; -------------------------------------------------------------------------

	include	"_Include/Common.i"
	include	"_Include/Main CPU.i"
	include	"_Include/Main CPU Variables.i"
	include	"_Include/Sound.i"
	include	"_Include/System.i"
	include	"_Include/MMD.i"

; -------------------------------------------------------------------------
; Constants
; -------------------------------------------------------------------------

DemoDataRel	EQU	$6C00			; Demo data location within chunk data
DemoData	EQU	LevelChunks+DemoDataRel	; Demo data location

; -------------------------------------------------------------------------
; Object structure
; -------------------------------------------------------------------------

oSize		EQU	$40
c = 0
	rept	oSize
oVar\$c		EQU	c
		c: = c+1
	endr

	rsreset
oID		rs.b	1			; ID
oSprFlags	rs.b	1			; Sprite flags
oTile		rs.w	1			; Base tile ID
oMap		rs.l	1			; Sprite mappings pointer
oX		rs.w	1			; X position
oYScr		rs.b	0			; Y position (screen mode)
oXSub		rs.w	1			; X position subpixel
oY		rs.w	1			; Y position
oYSub		rs.w	1			; Y position subpixel
oXVel		rs.w	1			; X velocity
oYVel		rs.w	1			; Y velocity
		rs.b	2
oYRadius	rs.b	1			; Y radius
oXRadius	rs.b	1			; X radius
oPriority	rs.b	1			; Sprite draw priority level
oWidth		rs.b	1			; Width
oMapFrame	rs.b	1			; Sprite mapping frame ID
oAnimFrame	rs.b	1			; Animation script frame ID
oAnim		rs.b	1			; Animation ID
oPrevAnim	rs.b	1			; Previous previous animation ID
oAnimTime	rs.b	1			; Animation timer
		rs.b	1
oColType	rs.b	1			; Collision type
oColStatus	rs.b	1			; Collision status
oFlags		rs.b	1			; Flags
oSavedFlagsID	rs.b	1			; Saved flags entry ID
oRoutine	rs.b	1			; Routine ID
oSolidType	rs.b	0			; Solidity type
oRoutine2	rs.b	1			; Secondary routine ID
oAngle		rs.b	1			; Angle
		rs.b	1			; Object specific variable
oSubtype	rs.b	1			; Subtype ID
oLayer		rs.b	0			; Layer ID
oSubtype2	rs.b	1			; Secondary subtype ID

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

oPlayerRotAngle		EQU	oVar2B		; Rotation angle
oPlayerRotDist		EQU	oVar39		; Rotation distance
oPlayerRotCenter	EQU	oVar3E		; Rotation center

oPlayerPushObj		EQU	oVar20		; ID of object being pushed on
oPlayerStandObj		EQU	oVar3D		; ID of object being stood on

oPlayerHangAni		EQU	oVar1F		; Hanging animation timer

; -------------------------------------------------------------------------
; Object layout entry structure
; -------------------------------------------------------------------------

	rsreset
oeX		rs.w	1			; X position
oeY		rs.w	1			; Y position/flags
oeID		rs.b	1			; ID
oeSubtype	rs.b	1			; Subtype
oeTimeZones	rs.b	1			; Time zones
oeSubtype2	rs.b	1			; Subtype 2
oeSize		rs.b	0			; Size of structure

; -------------------------------------------------------------------------
; RAM
; -------------------------------------------------------------------------

	rsset	WORKRAM+$2000
blockBuffer 		rs.b	$2000		; Block buffer
unkBuffer2 		rs.b	$1000		; Unknown buffer
			rs.b	$3000

	rsset	WORKRAM+$FF00A000
levelLayout 		rs.b	$800		; Level layout
deformBuffer		rs.b	$200		; Deformation buffer
nemBuffer		rs.b	$200		; Nemesis decompression buffer
objDrawQueue		rs.b	$400		; Object draw queue
			rs.b	$1800
sonicArtBuf 		rs.b	$300		; Sonic art buffer
sonicRecordBuf		rs.b	$100		; Sonic position record buffer
hscroll 		rs.b	$400		; Horizontal scroll buffer

objects			rs.b	0		; Object pool
resObjects		rs.b	0		; Reserved objects
objPlayerSlot 		rs.b	oSize		; Player slot
objPlayerSlot2 		rs.b	oSize		; Player 2 slot
objHUDScoreSlot		rs.b	oSize		; HUD (score) slot
objHUDLivesSlot		rs.b	oSize		; HUD (lives) slot
objTtlCardSlot		rs.b	oSize		; Title card slot
objHUDRingsSlot		rs.b	oSize		; HUD (rings) slot
objShieldSlot 		rs.b	oSize		; Shield slot
objBubblesSlot 		rs.b	oSize		; Bubbles slot
objInvStar1Slot		rs.b	oSize		; Invincibility star 1 slot
objInvStar2Slot		rs.b	oSize		; Invincibility star 2 slot
objInvStar3Slot		rs.b	oSize		; Invincibility star 3 slot
objInvStar4Slot		rs.b	oSize		; Invincibility star 4 slot
objTimeStar1Slot	rs.b	oSize		; Time warp star 1 slot
objTimeStar2Slot	rs.b	oSize		; Time warp star 2 slot
objTimeStar3Slot	rs.b	oSize		; Time warp star 3 slot
objTimeStar4Slot	rs.b	oSize		; Time warp star 4 slot
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
objHUDIconSlot		rs.b	oSize		; HUD (life icon) slot
resObjectsEnd		rs.b	0

dynObjects 		rs.b	$60*oSize	; Dynamic objects
dynObjectsEnd		rs.b	0
objectsEnd		rs.b	0

OBJCOUNT		EQU	(objectsEnd-objects)/oSize
RESOBJCOUNT		EQU	(resObjectsEnd-resObjects)/oSize
DYNOBJCOUNT		EQU	(dynObjectsEnd-dynObjects)/oSize

			rs.b	$A
fmSndQueue1 		rs.b	1		; FM sound queue 1
fmSndQueue2 		rs.b	1		; FM sound queue 2
fmSndQueue3 		rs.b	1		; FM sound queue 3
			rs.b	$5F3
gameMode 		rs.b	1		; Game mode
			rs.b	1
			
playerCtrl		rs.b	0		; Player controller data
playerCtrlHold 		rs.b	1		; Player held controller data
playerCtrlTap		rs.b	1		; Player tapped controller data
p1CtrlData		rs.b	0		; Player 1 controller data
p1CtrlHold 		rs.b	1		; Player 1 held controller data
p1CtrlTap		rs.b	1		; Player 1 tapped controller data
p2CtrlData		rs.b	0		; Player 2 controller data
p2CtrlHold 		rs.b	1		; Player 2 held controller data
p2CtrlTap		rs.b	1		; Player 2 tapped controller data

			rs.l	1
vdpReg01 		rs.w	1		; VDP register 1
			rs.b	6
vintTimer 		rs.w	1		; V-BLANK interrupt timer
vscrollScreen 		rs.l	1		; Vertical scroll (full screen)
hscrollScreen 		rs.l	1		; Horizontal scroll (full screen)
			rs.b	6
vdpReg0A 		rs.w	1		; H-BLANK interrupt counter
palFadeInfo		rs.b	0		; Palette fade info
palFadeStart		rs.b	1		; Palette fade start
palFadeLen 		rs.b	1		; Palette fade length

miscVariables		rs.b	0
vintECount 		rs.b	1		; V-BLANK interrupt routine E counter
			rs.b	1
vintRoutine 		rs.b	1		; V-BLANK interrupt routine ID
			rs.b	1
spriteCount 		rs.b	1		; Sprite count
			rs.b	9
rngSeed 		rs.l	1		; RNG seed
paused 			rs.w	1		; Paused flag
			rs.l	1
dmaCmdLow		rs.w	1		; DMA command low word buffer
			rs.l	1
waterHeight 		rs.w	1		; Water height (with swaying)
waterHeight2		rs.w	1		; Water height (without swaying)
destWaterHeight		rs.w	1		; Water height destination
waterMoveSpeed		rs.b	1		; Water height move speed
waterRoutine		rs.b	1		; Water routine ID
waterFullscreen 	rs.b	1		; Water fullscreen flag
			rs.b	$17
aniArtFrames		rs.b	6		; Animated art frames
aniArtTimers		rs.b	6		; Animated art timers
			rs.b	$E
plcBuffer 		rs.b	$60		; PLC buffer
plcNemWrite 		rs.l	1		; PLC 
plcRepeat 		rs.l	1		; PLC 
plcPixel 		rs.l	1		; PLC 
plcRow 			rs.l	1		; PLC 
plcRead 		rs.l	1		; PLC 
plcShift 		rs.l	1		; PLC 
plcTileCount 		rs.w	1		; PLC 
plcProcTileCnt 		rs.w	1		; PLC 
hintFlag 		rs.w	1		; H-BLANK interrupt flag
			rs.w	1
			
cameraX 		rs.l	1		; Camera X position
cameraY 		rs.l	1		; Camera Y position
cameraBgX 		rs.l	1		; Background camera X position
cameraBgY 		rs.l	1		; Background camera Y position
cameraBg2X 		rs.l	1		; Background 2 camera X position
cameraBg2Y 		rs.l	1		; Background 2 camera Y position
cameraBg3X 		rs.l	1		; Background 3 camera X position
cameraBg3Y 		rs.l	1		; Background 3 camera Y position
destLeftBound		rs.w	1		; Camera left boundary destination
destRightBound		rs.w	1		; Camera right boundary destination
destTopBound		rs.w	1		; Camera top boundary destination
destBottomBound		rs.w	1		; Camera bottom boundary destination
leftBound 		rs.w	1		; Camera left boundary
rightBound 		rs.w	1		; Camera right boundary
topBound 		rs.w	1		; Camera top boundary
bottomBound 		rs.w	1		; Camera bottom boundary
unusedF730 		rs.w	1
leftBound3 		rs.w	1
			rs.b	6
scrollXDiff		rs.w	1		; Horizontal scroll difference
scrollYDiff		rs.w	1		; Vertical scroll difference
camYCenter 		rs.w	1		; Camera Y center
unusedF740 		rs.b	1
unusedF741 		rs.b	1
eventRoutine		rs.w	1		; Level event routine ID
scrollLock 		rs.w	1		; Scroll lock flag
unusedF746 		rs.w	1
unusedF748 		rs.w	1
horizBlkCrossed		rs.b	1		; Horizontal block crossed flag
vertiBlkCrossed		rs.b	1		; Vertical block crossed flag
horizBlkCrossedBg	rs.b	1		; Horizontal block crossed flag (background)
vertiBlkCrossedBg	rs.b	1		; Vertical block crossed flag (background)
horizBlkCrossedBg2	rs.b	2		; Horizontal block crossed flag (background 2)
horizBlkCrossedBg3	rs.b	1		; Horizontal block crossed flag (background 3)
			rs.b	1
			rs.b	1
			rs.b	1
scrollFlags		rs.w	1		; Scroll flags
scrollFlagsBg		rs.w	1		; Scroll flags (background)
scrollFlagsBg2		rs.w	1		; Scroll flags (background 2)
scrollFlagsBg3		rs.w	1		; Scroll flags (background 3)
btmBoundShift		rs.w	1		; Bottom boundary shifting flag
			rs.b	1
sneezeFlag		rs.b	1		; Sneeze flag (prototype leftover)

sonicTopSpeed		rs.w	1		; Sonic top speed
sonicAcceleration	rs.w	1		; Sonic acceleration
sonicDeceleration	rs.w	1		; Sonic deceleration
sonicLastFrame		rs.b	1		; Sonic's last sprite frame ID
updateSonicArt		rs.b	1		; Update Sonic's art flag
primaryAngle		rs.b	1		; Primary angle
			rs.b	1
secondaryAngle		rs.b	1		; Secondary angle
			rs.b	1
			
objSpawnRoutine		rs.b	1		; Object spawn routine ID
			rs.b	1
objPrevChunk		rs.w	1		; Previous object layout chunk position
objChunkRight		rs.l	1		; Object layout right chunk
objChunkLeft		rs.l	1		; Object layout left chunk
objChunkNullR		rs.l	1		; Object layout right chunk (null)
objChunkNullL		rs.l	1		; Object layout left chunk 2  (null)
boredTimer 		rs.w	1		; Bored timer
boredTimerP2 		rs.w	1		; Player 2 bored timer
timeWarpDir		rs.b	1		; Time warp direction
			rs.b	1
timeWarpTimer		rs.w	1		; Time warp timer
lookMode 		rs.b	1		; Look mode
			rs.b	1
demoDataPtr 		rs.l	1		; Demo data pointer
demoDataIndex 		rs.w	1		; Demo data index
demoS1Index 		rs.w	1		; Demo index (Sonic 1 leftover)
			rs.l	1
collisionPtr		rs.l	1		; Collision data pointer
			rs.b	6
camXCenter 		rs.w	1		; Camera X center
			rs.b	5
bossFlags		rs.b	1		; Boss flags
sonicRecordIndex	rs.w	1		; Sonic position record buffer index
bossFight 		rs.b	1		; Boss fight flag
			rs.b	1
specialChunks 		rs.l	1		; Special chunk IDs
palCycleSteps 		rs.b	7		; Palette cycle steps
palCycleTimers		rs.b	7		; Palette cycle timers
			rs.b	9
windTunnelFlag		rs.b	1		; Wind tunnel flag
			rs.b	1
			rs.b	1
waterSlideFlag 		rs.b	1		; Water slide flag
			rs.b	1
ctrlLocked 		rs.b	1		; Controls locked flag
			rs.b	3
scoreChain		rs.w	1		; Score chain
timeBonus		rs.w	1		; Time bonus
ringBonus		rs.w	1		; Ring bonus
updateHUDBonus		rs.b	1		; Update results bonus flag
			rs.b	3
savedSR 		rs.w	1		; Saved status register
			rs.b	4
switchFlags		rs.b	$20		; Switch press flags
sprites 		rs.b	$200		; Sprite buffer
waterFadePal		rs.b	$80		; Water fade palette buffer (uses part of sprite buffer)
waterPalette		rs.b	$80		; Water palette buffer
palette 		rs.b	$80		; Palette buffer
fadePalette 		rs.b	$80		; Fade palette buffer

; -------------------------------------------------------------------------
; VDP DMA from 68000 memory to VDP memory
; -------------------------------------------------------------------------
; PARAMETERS:
;	src  - Source address in 68000 memory
;	dest - Destination address in VDP memory
;	len  - Length of data in bytes
;	type - Type of VDP memory
; -------------------------------------------------------------------------

LVLDMA macro src, dest, len, type
	lea	VDPCTRL,a5
	move.l	#$94009300|((((\len)/2)&$FF00)<<8)|(((\len)/2)&$FF),(a5)
	move.l	#$96009500|((((\src)/2)&$FF00)<<8)|(((\src)/2)&$FF),(a5)
	move.w	#$9700|(((\src)>>17)&$7F),(a5)
	VDPCMD	move.w,\dest,\type,DMA,>>16,(a5)
	VDPCMD	move.w,\dest,\type,DMA,&$FFFF,dmaCmdLow.w
	move.w	dmaCmdLow.w,(a5)
	endm

; -------------------------------------------------------------------------
; Background section
; -------------------------------------------------------------------------
; PARAMETERS:
;	size - Size of scrion
;	id   - Section type
; -------------------------------------------------------------------------

BGSTATIC	EQU	0
BGDYNAMIC1	EQU	2
BGDYNAMIC2	EQU	4
BGDYNAMIC3	EQU	6

; -------------------------------------------------------------------------

BGSECT macro size, id
	dcb.b	(\size)/16, \id
	endm

; -------------------------------------------------------------------------
; Start debug item index
; -------------------------------------------------------------------------
; PARAMETERS:
;	off - (OPTION) Count offset
; -------------------------------------------------------------------------

__dbgID = 0
DBSTART macro off
	__dbgCount: = 0
	if narg>0
		dc.b	(__dbgCount\#__dbgID\)+(\off)
	else
		dc.b	__dbgCount\#__dbgID
	endif
	even
	endm

; -------------------------------------------------------------------------
; Debug item
; -------------------------------------------------------------------------
; PARAMETERS:
;	id       - Object ID
;	priority - Priority
;	mappings - Mappings
;	tile     - Tile ID
;	subtype  - Subtype
;	flip     - Flip flags
;	subtype2 - Subtype 2
;	frame    - Sprite frame
; -------------------------------------------------------------------------

DBGITEM macro id, priority, mappings, tile, subtype, flip, subtype2, frame
	dc.b	\id, \priority
	dc.l	\mappings
	dc.w	\tile
	dc.b	\subtype, \flip, \subtype2, \frame
	__dbgCount: = __dbgCount+1
	endm

; -------------------------------------------------------------------------
; End debug item index
; -------------------------------------------------------------------------

DBGEND macro
	__dbgCount\#__dbgID: EQU __dbgCount
	endm

; -------------------------------------------------------------------------
