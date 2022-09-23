
; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; DA Garden Main CPU program
; -------------------------------------------------------------------------

	include	"_Include/Common.i"
	include	"_Include/Main CPU.i"
	include	"_Include/Main CPU Variables.i"
	include	"_Include/MMD.i"
	include	"DA Garden/_Common.i"
	include	"DA Garden/Track Title Labels.i"

; -------------------------------------------------------------------------
; Image buffer VRAM constants
; -------------------------------------------------------------------------

IMGVRAM		EQU	$0000			; VRAM address
IMGV1LEN	EQU	IMGLENGTH/2		; Part 1 length

; -------------------------------------------------------------------------
; Object structure
; -------------------------------------------------------------------------

	rsreset
oID		rs.w	1			; Object ID
oRoutine	rs.w	1			; Routine ID
oX		rs.l	1			; X position
oY		rs.l	1			; Y position
oXVel		rs.l	1			; X velocity
oYVel		rs.l	1			; X velocity
		rs.b	6			; 
oXOffset	rs.w	1			; X offset
oYOffset	rs.w	1			; Y offset
oFloatAngle	rs.w	1			; Float angle
		rs.b	2
oAnimTime	rs.w	1			; Animation timer
oAnimFrame	rs.w	1			; Animation frame
oTile		rs.w	1			; Base tile ID
oMap		rs.l	1			; Mappings
oFlags		rs.b	1			; Flags
oSpawnID	rs.b	1			; Spawn ID
oDestX		rs.w	1			; Destination X position
oDestY		rs.w	1			; Destination Y position
oFloatSpeed	rs.w	1			; Float speed
oFloatAmp	rs.w	1			; Float amplitude
oModeCnt	rs.b	0			; Mode counter
oTimer		rs.b	1			; Timer
oTimer2		rs.b	1			; Timer 2
		rs.b	$40-__rs
oSize		rs.b	0			; Size of structure

; -------------------------------------------------------------------------
; Track selection structure
; -------------------------------------------------------------------------

	rsreset
trkSelRout	rs.w	1			; Routine ID
trkSelID	rs.w	1			; Selection ID
trkSelTitle	rs.w	1			; Track title object slot
trkSelDir	rs.w	1			; Direction
trkSelSize	rs.b	0			; Size of structure

; -------------------------------------------------------------------------
; Variables
; -------------------------------------------------------------------------

	rsset	WORKRAM+$FF009000
VARSSTART	rs.b	0			; Start of variables
kosBuffer	rs.b	0			; Kosinski decompression buffer
planetImage	rs.b	$5800			; Planet image buffer
sprites		rs.b	80*8			; Sprtie buffer
		rs.b	$80
nemBuffer	rs.b	$200			; Nemesis decompression buffer
palette		rs.w	$40			; Palette buffer
fadePalette	rs.w	$40			; Fade palette buffer
waterPalette	rs.w	$40			; Water palette buffer
waterFadePal	rs.w	$40			; Water fade palette buffer

objects		rs.b	0			; Object pool
object0		rs.b	oSize			; Object 0
object1		rs.b	oSize			; Object 1
object2		rs.b	oSize			; Object 2
object3		rs.b	oSize			; Object 3
object4		rs.b	oSize			; Object 4
object5		rs.b	oSize			; Object 5
object6		rs.b	oSize			; Object 6
object7		rs.b	oSize			; Object 7
object8		rs.b	oSize			; Object 8
object9		rs.b	oSize			; Object 9
object10	rs.b	oSize			; Object 10
object11	rs.b	oSize			; Object 11
object12	rs.b	oSize			; Object 12
object13	rs.b	oSize			; Object 13
object14	rs.b	oSize			; Object 14
object15	rs.b	oSize			; Object 15
OBJCOUNT	EQU	(__rs-objects)/oSize

		rs.b	$40
trackSelData	rs.b	trkSelSize		; Track selection data
		rs.b	$38
palCycleTimer	rs.w	1			; Palette cycle timer
palCycleIndex	rs.w	1			; Palette cycle index
volcanoTimer	rs.w	1			; Volcano animation timer
volcanoIndex	rs.w	1			; Volcano animation index
bufRenderCnt	rs.w	1			; Buffer render counter
sprPalCycTimer	rs.w	1			; Sprite palette cycle timer
sprPalCycIndex	rs.w	1			; Sprite palette cycle index
trackSelFlags	rs.b	1			; Track selection flags
		rs.b	1
		
objSpawnTimers	rs.b	0			; Object spawn timers
flickyTimer	rs.w	1			; Flicky object spawn timer
starTimer	rs.w	1			; Star object spawn timer
ufoTimer	rs.w	1			; UFO object spawn timer
eggmanTimer	rs.w	1			; Eggman object spawn timer
metalTimer	rs.w	1			; Metal Sonic object spawn timer
tailsTimer	rs.w	1			; Tails object spawn timer
OBJTYPECNT	EQU	(__rs-objSpawnTimers)/2

objSpawnFlags	rs.b	1			; Object spawn flags
objSpawnID	rs.b	1			; Object spawn ID
buttonFlags	rs.b	1			; Button flags
vsyncFlag	rs.b	1			; VSync flag
		rs.b	4
vintRoutine	rs.w	1			; V-INT routine ID
timer		rs.w	1			; Timer
vintCounter	rs.w	1			; V-INT counter
savedSR		rs.w	1			; Saved status register
rngSeed		rs.l	1			; RNG seed
lagCounter	rs.l	1			; Lag counter
vsyncFlag2	rs.b	1			; VSync flag 2 (not functional)
		rs.b	1
trackTimeZone	rs.w	1			; Track time zone
palFadeInfo	rs.b	0			; Palette fade info
palFadeStart	rs.b	1			; Palette fade start
palFadeLen	rs.b	1			; Palette fade length
disablePalCycle	rs.b	1			; Disable palette cycle flag
		rs.b	$845
VARSLEN		EQU	__rs-VARSSTART		; Size of variables area

ctrlData	EQU	GACOMCMDE		; Controller data
ctrlHold	EQU	ctrlData		; Controller held buttons data
ctrlTap		EQU	ctrlData+1		; Controller tapped buttons data

; -------------------------------------------------------------------------
; MMD header
; -------------------------------------------------------------------------

	MMD	0, &
		WORKRAMFILE, $7800, &
		Start, 0, 0

; -------------------------------------------------------------------------
; Program start
; -------------------------------------------------------------------------

Start:
	move.l	#VInterrupt,_LEVEL6+2.w		; Set V-INT address
	
	moveq	#0,d0				; Clear communication commands
	move.l	d0,GACOMCMD0
	move.l	d0,GACOMCMD4
	move.l	d0,GACOMCMD8
	move.l	d0,GACOMCMDC
	move.b	d0,GAMAINFLAG
	
	; Go to "InitPlanetRender" for more information on why this is here
	move.w	#$8000,ctrlData			; Force program to assume start button was being held
	
	bsr.w	InitAnimation			; Initialize volcano animation
	
	bsr.w	WaitSubCPUStart			; Wait for the Sub CPU program to start
	bsr.w	GiveWordRAMAccess		; Give Word RAM access
	bsr.w	WaitSubCPUInit			; Wait for the Sub CPU program to finish initializing
	
	lea	VARSSTART.w,a0			; Clear variables
	moveq	#0,d0
	move.w	#VARSLEN/4-1,d7

.ClearVars:
	move.l	d0,(a0)+
	dbf	d7,.ClearVars
	
	bsr.w	InitMD				; Initialize the Mega Drive

	bsr.w	DrawPlanetMap			; Draw planet map
	bsr.w	DrawBackground			; Draw background
	
	move.b	#1,disablePalCycle.w		; Disable palette cycling
	bset	#6,ipxVDPReg1+1			; Enable display
	move.w	ipxVDPReg1,VDPCTRL
	
	bsr.w	InitPlanetRender		; Initialize planet render
	bne.w	Exit				; If we are exiting, branch
	
	lea	Pal_DAGarden(pc),a0		; Load palette
	lea	fadePalette.w,a1
	moveq	#(Pal_DAGardenEnd-Pal_DAGarden)/4-1,d7
	
.LoadPal:
	move.l	(a0)+,(a1)+
	dbf	d7,.LoadPal
	
	bsr.w	FadeFromBlack			; Fade from black
	move.b	#0,disablePalCycle.w		; Enable palette cycling

; -------------------------------------------------------------------------

MainLoop:
	move.w	#2-1,bufRenderCnt.w		; Render to both buffers
	move.w	#0,vintRoutine.w		; Reset V-INT routine

.Loop:
	tst.w	bufRenderCnt.w			; Have both buffers been rendered to?
	blt.s	MainLoop			; If so, branch
	
	bsr.w	UpdateSubCPU			; Update Sub CPU
	jsr	TrackSelection(pc)		; Handle track selection
	jsr	UpdateObjects(pc)		; Update objects
	bsr.w	VSync				; VSync
	
	addq.w	#1,vintRoutine.w		; Next V-INT routine
	jsr	TrackSelection(pc)		; Handle track selection
	jsr	UpdateObjects(pc)		; Update objects
	bsr.w	VSync				; VSync
	
	bsr.w	WaitWordRAMAccess		; Wait for Word RAM access
	move	#$2700,sr			; Disable interrupts
	bsr.w	ChkTrkTitleSpawn		; Check track title object spawn
	bsr.w	GetPlanetImage			; Get planet image
	bsr.w	AnimateVolcano			; Animate volcano
	move	#$2500,sr			; Enable interrupts
	bsr.w	GiveWordRAMAccess		; Give back Word RAM access

	btst	#5,GASUBFLAG			; Is the screen being refreshed?
	beq.s	.CheckExit			; If not, branch
	bsr.w	RefreshScreen			; If so, refresh the screen

.CheckExit:
	btst	#6,GASUBFLAG			; Are we exiting?
	beq.s	.NoExit				; If not, branch
	bsr.w	ExitFadeOut			; If so, fade out
	bra.s	Exit				; Exit

.NoExit:
	subq.w	#1,bufRenderCnt.w		; Decrement buffer render count
	addq.w	#1,vintRoutine.w		; Next V-INT routine
	bra.w	.Loop				; Loop

; -------------------------------------------------------------------------

Exit:
	move.b	#0,GAMAINFLAG			; Mark as done
	nop
	nop
	nop
	rts

; -------------------------------------------------------------------------
; Refresh the screen
; -------------------------------------------------------------------------

RefreshScreen:
	bsr.w	FadeToWhite			; Fade to white
	bsr.w	InitObjects			; Initialize objects
	bsr.w	ResetDAGarden			; Reset DA Garden
	bclr	#5,GAMAINFLAG			; Finish communication with Sub CPU

.WaitSubCPU:
	bsr.w	UpdateSubCPU			; Update Sub CPU
	bsr.w	WaitWordRAMAccess		; Wait for Word RAM access
	bsr.w	GetPlanetImage			; Get planet image
	bsr.w	GiveWordRAMAccess		; Give back Word RAM access
	btst	#6,GASUBFLAG			; Is the Sub CPU exiting?
	bne.w	.End				; If so, branch
	btst	#4,GASUBFLAG			; Is the Sub CPU still switching music tracks?
	bne.s	.WaitSubCPU			; If so, wait
	
	; Show planet buffer 2, render to buffer 1
	move.w	#0,vintRoutine.w		; Set V-INT routine (copy 1st half of last rendered planet art to buffer 1)
	bsr.w	UpdateSubCPU			; Update Sub CPU
	bsr.w	WaitWordRAMAccess		; Wait for Word RAM access
	bsr.w	GetPlanetImage			; Get planet image
	bsr.w	GiveWordRAMAccess		; Give back Word RAM access
	bsr.w	VSync				; VSync
	btst	#6,GASUBFLAG			; Is the Sub CPU exiting?
	bne.s	.End				; If so, branch
	
	move.w	#1,vintRoutine.w		; Set V-INT routine (copy 2nd half of last rendered planet art to buffer 1)
	bsr.w	VSync				; VSync
	btst	#6,GASUBFLAG			; Is the Sub CPU exiting?
	bne.s	.End				; If so, branch
	
	; Show planet buffer 1, render to buffer 2
	move.w	#2,vintRoutine.w		; Set V-INT routine (copy 1st half of last rendered planet art to buffer 2)
	bsr.w	UpdateSubCPU			; Update Sub CPU
	bsr.w	WaitWordRAMAccess		; Wait for Word RAM access
	bsr.w	GetPlanetImage			; Get planet image
	bsr.w	GiveWordRAMAccess		; Give back Word RAM access
	bsr.w	VSync				; VSync
	btst	#6,GASUBFLAG			; Is the Sub CPU exiting?
	bne.s	.End				; If so, branch
	
	move.w	#3,vintRoutine.w		; Set V-INT routine (copy 2nd half of last rendered planet art to buffer 2)
	bsr.w	VSync				; VSync
	btst	#6,GASUBFLAG			; Is the Sub CPU exiting?
	bne.s	.End				; If so, branch
	
	bclr	#0,trackSelFlags.w		; Music switch is done
	move.b	#0,objSpawnFlags.w		; Mark objects as despawned
	
	bsr.w	FadeFromWhite			; Fade from white
	move.w	#0,bufRenderCnt.w		; Clear buffer render count
	move.w	#-1,vintRoutine.w		; Make V-INT routine increment to 0

.End:
	rts

; -------------------------------------------------------------------------
; Initialize planet render
; -------------------------------------------------------------------------

InitPlanetRender:
	; Show planet buffer 2, render to buffer 1
	bsr.w	UpdateSubCPU			; Update Sub CPU
	bsr.w	WaitWordRAMAccess		; Wait for Word RAM access
	bsr.w	GetPlanetImage			; Get planet image
	bsr.w	AnimateVolcano			; Animate volcano
	bsr.w	GiveWordRAMAccess		; Give back Word RAM access
	bsr.w	VSync				; VSync
	
	addq.w	#1,vintRoutine.w		; Set V-INT routine (copy 2nd half of last rendered planet art to buffer 1)
	bsr.w	VSync				; VSync
	btst	#6,GASUBFLAG			; Is the Sub CPU exiting?
	bne.s	.Exit				; If so, branch
	
	; Show planet buffer 1, render to buffer 2
	bsr.w	UpdateSubCPU			; Update Sub CPU
	bsr.w	WaitWordRAMAccess		; Wait for Word RAM access
	bsr.w	GetPlanetImage			; Get planet image
	bsr.w	AnimateVolcano			; Animate volcano
	bsr.w	GiveWordRAMAccess		; Give back Word RAM access
	addq.w	#1,vintRoutine.w		; Set V-INT routine (copy 1st half of last rendered planet art to buffer 2)
	bsr.w	VSync				; VSync
	
	addq.w	#1,vintRoutine.w		; Set V-INT routine (copy 2nd half of last rendered planet art to buffer 2)
	bsr.w	VSync				; VSync
	btst	#6,GASUBFLAG			; Is the Sub CPU exiting?
	bne.s	.Exit				; If so, branch
	
	moveq	#0,d0				; Not exiting
	rts

; -------------------------------------------------------------------------

.Exit:
	move.b	#1,disablePalCycle.w		; Disable palette cycling
	bsr.w	FadeToBlack			; Fade to black
	
	; BUG: That "beq.s" should be a "bne.s".
	; If it were to ever branch here, this could cause a crash, as the Sub CPU
	; will pretty much immediately clear bit 6 in GASUBFLAG, and cause
	; the loop to loop forever. However, because of a line that forces
	; the game to think that start was being held when the program started,
	; it prevents the Sub CPU from ever seeing the start button tapped bit
	; being set during this routine, thus preventing this code from
	; being executed.
	bset	#6,GAMAINFLAG			; Mark as exiting

.WaitSubCPU:
	btst	#6,GASUBFLAG			; Has the Sub CPU responded?
	beq.s	.WaitSubCPU			; If not, wait
	bclr	#6,GAMAINFLAG			; Communication is done
	
	clr.b	disablePalCycle.w		; Enable palette cycling
	moveq	#1,d0				; Exiting
	rts

; -------------------------------------------------------------------------
; Reset DA Garden
; -------------------------------------------------------------------------

ResetDAGarden:
	bsr.w	InitObjects			; Initialize objects

; -------------------------------------------------------------------------
; Load palette
; -------------------------------------------------------------------------

LoadPalette:
	lea	PalCycleTable(pc),a0		; Get time zone palette cycle metadata
	move.w	trackTimeZone.w,d0
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,d0
	lea	(a0,d0.w),a1
	
	movea.l	(a1),a2				; Get planet palette cycle data
	move.w	(a2),d1
	adda.w	d1,a2
	
	lea	4(a0,d0.w),a1			; Get background palette cycle data
	movea.l	(a1),a1
	move.l	(a1),d1				; BUG: Should be "move.w"
	adda.w	d1,a1
	
	lea	fadePalette.w,a0		; Load background palette
	moveq	#$20/4-1,d7

.InitBGPal:
	move.l	(a1)+,(a0)+
	dbf	d7,.InitBGPal
	
	moveq	#$20/4-1,d7			; Load planet palette

.InitPlanetPal:
	move.l	(a2)+,(a0)+
	dbf	d7,.InitPlanetPal
	
	lea	PalCyc_Sprites0,a1		; Load sprite palette
	moveq	#$20/4-1,d7

.InitSpritePal:
	move.l	(a1)+,(a0)+
	dbf	d7,.InitSpritePal
	
	lea	Pal_SelMenu,a1			; Load selection menu palette
	moveq	#$20/4-1,d7

.InitSelectPal:
	move.l	(a1)+,(a0)+
	dbf	d7,.InitSelectPal

; -------------------------------------------------------------------------
; Initialize volcano animation and palette cycle
; -------------------------------------------------------------------------

InitAnimation:
	move.w	#0,d0				; Reset palette cycle index
	move.w	d0,palCycleIndex.w
	add.w	d0,d0
	lea	PalCycleTimes,a0		; Reset palette cycle timer
	move.w	(a0,d0.w),palCycleTimer.w
	
	move.w	#0,d0				; Reset volcano animation index
	move.w	d0,volcanoIndex.w
	add.w	d0,d0
	lea	VolcanoAnimTimes,a0		; Reset volcano animation timer
	move.w	(a0,d0.w),volcanoTimer.w
	
	lea	VolcanoAnimStamps,a0		; Get stamps
	adda.w	(a0,d0.w),a0
	
	movea.l	#WORDRAM2M+STAMPMAP+(6*2),a1	; Get volcano section
	move.w	#$D8,d1				; Base stamp ID
	moveq	#2-1,d7				; Volcano section height

.SetStamps:
	move.w	(a0)+,d0			; Set row stamp 1
	add.w	d1,d0
	move.w	d0,(a1)+
	
	move.w	(a0)+,d0			; Set row stamp 2
	add.w	d1,d0
	move.w	d0,(a1)
	
	lea	$100-2(a1),a1			; Next row
	dbf	d7,.SetStamps			; Loop until all stamps are set
	
	move.w	#5,sprPalCycTimer.w		; Reset sprite palette cycle
	move.w	#0,sprPalCycIndex.w
	rts

; -------------------------------------------------------------------------
; Perform exit fade out
; -------------------------------------------------------------------------

ExitFadeOut:
	move.b	#1,disablePalCycle.w		; Disable palette cycling
	bsr.w	FadeToBlack			; Fade to black
	bsr.w	LoadPalette			; Load palette
	
	bset	#6,GAMAINFLAG			; Mark as exiting

.WaitSubCPU:
	btst	#6,GASUBFLAG			; Has the Sub CPU responded?
	bne.s	.WaitSubCPU			; If not, wait
	bclr	#6,GAMAINFLAG			; Communication is done
	
	clr.b	disablePalCycle.w		; Enable palette cycling
	rts

; -------------------------------------------------------------------------
; Perform exit fade out (wait for Sub CPU)
; -------------------------------------------------------------------------

WaitSubExit:
	move.b	#1,disablePalCycle.w		; Disable palette cycling
	bsr.w	FadeToBlack			; Fade to black
	bsr.w	LoadPalette			; Load palette
	
.WaitSubCPU:
	nop					; Wait a bit
	nop
	nop
	btst	#6,GASUBFLAG			; Is the Sub CPU exiting?
	beq.s	.WaitSubCPU			; If not, wait
	bclr	#6,GAMAINFLAG			; Communication is done
	
	clr.b	disablePalCycle.w		; Enable palette cycling
	rts

; -------------------------------------------------------------------------
; Get rendered planet image
; -------------------------------------------------------------------------

GetPlanetImage:
	lea	WORDRAM2M+IMGBUFFER,a1		; Rendered image in Word RAM
	lea	planetImage.w,a2		; Destination buffer
	move.w	#(IMGLENGTH/$800)-1,d7		; Number of $800 byte chunks to copy

.CopyChunks:
	rept	$800/$80			; Copy $800 bytes
		bsr.s	.Copy128
	endr
	dbf	d7,.CopyChunks
	rts

; -------------------------------------------------------------------------

.Copy128:
	rept	128/4
		move.l	(a1)+,(a2)+
	endr
	rts

; -------------------------------------------------------------------------
; Draw planet tilemap
; -------------------------------------------------------------------------

DrawPlanetMap:
	move.w	#$2000,d6			; Buffer 1 base tile ID
	lea	VDPCTRL,a2			; VDP control port
	lea	VDPDATA,a3			; VDP data port
	
	VDPCMD	move.l,$C180,VRAM,WRITE,d0	; Draw buffer 1 tilemap
	moveq	#IMGWTILE-1,d1
	moveq	#IMGHTILE-1,d2
	bsr.s	.DrawMap
	
	move.w	#$22C0,d6			; Draw buffer 2 tilemap
	VDPCMD	move.l,$C1C0,VRAM,WRITE,d0
	moveq	#IMGWTILE-1,d1
	moveq	#IMGHTILE-1,d2

; -------------------------------------------------------------------------

.DrawMap:
	move.l	#$800000,d4			; Row delta

.DrawRow:
	move.l	d0,(a2)				; Set VDP command
	move.w	d1,d3				; Get width
	move.w	d6,d5				; Get first column tile

.DrawTile:
	move.w	d5,(a3)				; Write tile ID
	addi.w	#IMGHTILE,d5			; Next column tile
	dbf	d3,.DrawTile			; Loop until row is written
	
	add.l	d4,d0				; Next row
	addq.w	#1,d6				; Next column tile
	dbf	d2,.DrawRow			; Loop until map is drawn
	rts
	
; -------------------------------------------------------------------------
; Draw background
; -------------------------------------------------------------------------

DrawBackground:
	lea	Map_DAGardenBg,a0		; Decompress mappings
	lea	kosBuffer.w,a1
	bsr.w	KosDec
	
	lea	kosBuffer.w,a1			; Decompressed mappings
	lea	VDPCTRL,a2			; VDP control port
	
	move.w	#$580,d6			; Base tile ID
	VDPCMD	move.l,$E000,VRAM,WRITE,d0	; VDP write command
	
	move.w	#$16-1,d1			; Get height

.DrawRow:
	move.l	d0,(a2)				; Set VDP command
	move.w	#$20-1,d2			; Get width

.DrawTile:
	move.w	(a1)+,d3			; Draw tile
	add.w	d6,d3
	move.w	d3,VDPDATA
	dbf	d2,.DrawTile			; Loop until row is written
	
	addi.l	#$800000,d0			; Next row
	dbf	d1,.DrawRow			; Loop until map is drawn
	
	VDPCMD	move.l,$B000,VRAM,WRITE,VDPCTRL	; Load background art
	lea	Art_DAGardenBg,a0
	bsr.w	NemDec
	
	VDPCMD	move.l,$DFC0,VRAM,WRITE,VDPCTRL	; Load unknown tiles
	rept	8
		move.l	#$DDDDDDDD,VDPDATA
	endr
	rept	8
		move.l	#$FFFFFFFF,VDPDATA
	endr
	rts

; -------------------------------------------------------------------------
; Animate volcano
; -------------------------------------------------------------------------

AnimateVolcano:
	nop
	tst.w	volcanoTimer.w			; Has the timer ran out?
	bne.s	.End				; If not, exit
	
	cmpi.w	#$C,volcanoIndex.w		; Is the animation restarting?
	blt.s	.GetStamps			; If not, branch
	move.w	#0,volcanoIndex.w		; If so, reset the index

.GetStamps:
	lea	VolcanoAnimTimes,a0		; Set new timer
	move.w	volcanoIndex.w,d0
	add.w	d0,d0
	move.w	(a0,d0.w),volcanoTimer.w
	addq.w	#1,volcanoIndex.w		; Increment index
	
	lea	VolcanoAnimStamps,a0		; Get stamps
	adda.w	(a0,d0.w),a0
	
	movea.l	#WORDRAM2M+STAMPMAP+(6*2),a1	; Get volcano section
	move.w	#$D8,d1				; Base stamp ID
	moveq	#2-1,d6				; Volcano section height

.Row:
	moveq	#2-1,d5				; Volcano section width

.Stamp:
	move.w	(a0)+,d0			; Get stamp ID
	beq.s	.DrawStamp			; If it's blank, branch
	add.w	d1,d0				; If not, add base stamp ID

.DrawStamp:
	move.w	d0,(a1)+			; Store stamp ID
	dbf	d5,.Stamp			; Loop until row is set
	lea	$100-4(a1),a1			; Next row
	dbf	d6,.Row				; Loop until all stamps are set

.End:
	rts

; -------------------------------------------------------------------------
; Update Sub CPU
; -------------------------------------------------------------------------

UpdateSubCPU:
	move.w	#1,GACOMCMD2			; Tell Sub CPU program to update
	
.WaitSubCPU:
	tst.w	GACOMSTAT2			; Has the Sub CPU responded?
	beq.s	.WaitSubCPU			; If not, wait
	
	nop
	nop
	nop
	
	move.w	#0,GACOMCMD2			; Respond to the Sub CPU

.WaitSubCPU2:
	tst.w	GACOMSTAT2			; Has the Sub CPU responded?
	bne.s	.WaitSubCPU2			; If not, wait
	rts
	

; -------------------------------------------------------------------------
; Give Sub CPU Word RAM access
; -------------------------------------------------------------------------

GiveWordRAMAccess:
	btst	#1,GAMEMMODE			; Does the Sub CPU already have Word RAM Access?
	bne.s	.End				; If so, branch
	
.Wait:
	bset	#1,GAMEMMODE			; Give Sub CPU Word RAM access
	btst	#1,GAMEMMODE			; Has it been given?
	beq.s	.Wait				; If not, wait

.End:
	rts
	

; -------------------------------------------------------------------------
; Wait for Word RAM access
; -------------------------------------------------------------------------

WaitWordRAMAccess:
	btst	#0,GAMEMMODE			; Do we have Word RAM access?
	beq.s	WaitWordRAMAccess		; If not, wait
	rts

; -------------------------------------------------------------------------
; Wait for the Sub CPU program to start
; -------------------------------------------------------------------------

WaitSubCPUStart:
	btst	#7,GASUBFLAG			; Has the Sub CPU program started?
	beq.s	WaitSubCPUStart			; If not, wait
	rts 

; -------------------------------------------------------------------------
; Wait for the Sub CPU program to finish initializing
; -------------------------------------------------------------------------

WaitSubCPUInit:
	btst	#7,GASUBFLAG			; Has the Sub CPU program initialized?
	bne.s	WaitSubCPUInit			; If not, wait
	rts

; -------------------------------------------------------------------------
; Decompress Kosinski data into RAM
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Kosinski data pointer
;	a1.l - Destination buffer pointer
; -------------------------------------------------------------------------

KosDec:
	subq.l	#2,sp				; Allocate 2 bytes on the stack
	move.b	(a0)+,1(sp)
	move.b	(a0)+,(sp)
	move.w	(sp),d5				; Get first description field
	moveq	#$F,d4				; Set to loop for 16 bits

KosDec_Loop:
	lsr.w	#1,d5				; Shift bit into the C flag
	move	sr,d6
	dbf	d4,.ChkBit
	move.b	(a0)+,1(sp)
	move.b	(a0)+,(sp)
	move.w	(sp),d5
	moveq	#$F,d4

.ChkBit:
	move	d6,ccr				; Was the bit set?
	bcc.s	KosDec_RLE			; If not, branch

	move.b	(a0)+,(a1)+			; Copy byte as is
	bra.s	KosDec_Loop

; -------------------------------------------------------------------------

KosDec_RLE:
	moveq	#0,d3
	lsr.w	#1,d5				; Get next bit
	move	sr,d6
	dbf	d4,.ChkBit
	move.b	(a0)+,1(sp)
	move.b	(a0)+,(sp)
	move.w	(sp),d5
	moveq	#$F,d4

.ChkBit:
	move	d6,ccr				; Was the bit set?
	bcs.s	KosDec_SeparateRLE		; If yes, branch

	lsr.w	#1,d5				; Shift bit into the X flag
	dbf	d4,.Loop
	move.b	(a0)+,1(sp)
	move.b	(a0)+,(sp)
	move.w	(sp),d5
	moveq	#$F,d4

.Loop:
	roxl.w	#1,d3				; Get high repeat count bit
	lsr.w	#1,d5
	dbf	d4,.Loop2
	move.b	(a0)+,1(sp)
	move.b	(a0)+,(sp)
	move.w	(sp),d5
	moveq	#$F,d4

.Loop2:
	roxl.w	#1,d3				; Get low repeat count bit
	addq.w	#1,d3				; Increment repeat count
	moveq	#$FFFFFFFF,d2
	move.b	(a0)+,d2			; Calculate offset
	bra.s	KosDec_RLELoop

; -------------------------------------------------------------------------

KosDec_SeparateRLE:
	move.b	(a0)+,d0			; Get first byte
	move.b	(a0)+,d1			; Get second byte
	moveq	#$FFFFFFFF,d2
	move.b	d1,d2
	lsl.w	#5,d2
	move.b	d0,d2				; Calculate offset
	andi.w	#7,d1				; Does a third byte need to be read?
	beq.s	KosDec_SeparateRLE2		; If yes, branch
	move.b	d1,d3				; Copy repeat count
	addq.w	#1,d3				; Increment

KosDec_RLELoop:
	move.b	(a1,d2.w),d0			; Copy appropriate byte
	move.b	d0,(a1)+			; Repeat
	dbf	d3,KosDec_RLELoop
	bra.s	KosDec_Loop

; -------------------------------------------------------------------------

KosDec_SeparateRLE2:
	move.b	(a0)+,d1
	beq.s	KosDec_Done			; 0 indicates end of compressed data
	cmpi.b	#1,d1
	beq.w	KosDec_Loop			; 1 indicates new description to be read
	move.b	d1,d3				; Otherwise, copy repeat count
	bra.s	KosDec_RLELoop

; -------------------------------------------------------------------------

KosDec_Done:
	addq.l	#2,sp				; Deallocate the 2 bytes
	rts

; -------------------------------------------------------------------------
; Find free object slot
; -------------------------------------------------------------------------
; RETURNS:
;	eq/ne - Found/Not found
;	a1.l  - Found object slot
; -------------------------------------------------------------------------

FindObjSlot:
	lea	objects.w,a1			; Object slots
	move.w	#OBJCOUNT-1,d0			; Number of slots to check
	
.Find:
	tst.w	(a1)				; Is this slot occupied?
	beq.s	.End				; If not, exit
	lea	oSize(a1),a1			; Next slot
	dbf	d0,.Find			; Loop until finished

.End:
	rts

; -------------------------------------------------------------------------
; Check if any objects are loaded
; -------------------------------------------------------------------------
; RETURNS:
;	eq/ne - No objects/Objects found
; -------------------------------------------------------------------------

CheckObjLoaded:
	lea	objects.w,a1			; Object slots
	move.w	#OBJCOUNT-1,d0			; Number of slots to check
	
.Check:
	tst.w	(a1)				; Is this slot occupied?
	bne.s	.End				; If so, exit
	lea	oSize(a1),a1			; Next slot
	dbf	d0,.Check			; Loop until finished

.End:
	rts

; -------------------------------------------------------------------------
; Update objects
; -------------------------------------------------------------------------

UpdateObjects:
	bsr.w	UpdateObjSpawns			; Update object spawns
	lea	objects.w,a0			; Run objects
	bsr.s	RunObjects
	bsr.w	DrawObjects			; Draw objects
	rts

; -------------------------------------------------------------------------
; Run objects
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to object pool
; -------------------------------------------------------------------------

RunObjects:
	moveq	#OBJCOUNT-1,d7			; Number of slots
	
.Run:
	move.w	(a0),d0				; Get object ID
	beq.s	.NextObject			; If there's no object in this slot, branch
	
	movem.l	d7-a0,-(sp)			; Run object
	bsr.s	RunObject
	movem.l	(sp)+,d7-a0
	
.NextObject:
	lea	oSize(a0),a0			; Next object
	dbf	d7,.Run				; Loop until all objects are run
	rts

; -------------------------------------------------------------------------
; Run object
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Object ID
;	a0.l - Pointer to object slot
; -------------------------------------------------------------------------

RunObject:
	add.w	d0,d0				; Run object
	add.w	d0,d0
	movea.l	ObjIndex-4(pc,d0.w),a1
	jsr	(a1)
	
	btst	#4,oFlags(a0)			; Is this object marked for deletion?
	beq.s	.End				; If not, branch
	bsr.w	ClearObject			; If so, clear object slot
	
.End:
	rts

; -------------------------------------------------------------------------
; Object index
; -------------------------------------------------------------------------

ObjIndex:
	dc.l	ObjFlicky			; Flicky
	dc.l	ObjStar				; Star
	dc.l	ObjEggman			; Eggman
	dc.l	ObjUFO				; UFO
	dc.l	ObjMetalSonic			; Metal Sonic
	dc.l	ObjTails			; Tails
	dc.l	ObjTrackTitle			; Track title
	dc.l	ObjNull				; Blank
	dc.l	ObjNull				; Blank
	dc.l	ObjNull				; Blank
	dc.l	ObjNull				; Blank
	dc.l	ObjNull				; Blank
	dc.l	ObjNull				; Blank
	dc.l	ObjNull				; Blank
	dc.l	ObjNull				; Blank
	dc.l	ObjNull				; Blank
	dc.l	ObjNull				; Blank
	dc.l	ObjNull				; Blank
	dc.l	ObjNull				; Blank
	dc.l	ObjNull				; Blank
	dc.l	ObjNull				; Blank
	dc.l	ObjNull				; Blank
	dc.l	ObjNull				; Blank
	dc.l	ObjNull				; Blank
	dc.l	ObjNull				; Blank
	dc.l	ObjNull				; Blank
	dc.l	ObjNull				; Blank
	dc.l	ObjNull				; Blank
	dc.l	ObjNull				; Blank
	dc.l	ObjNull				; Blank
	dc.l	ObjNull				; Blank
	

; -------------------------------------------------------------------------
; Null object
; -------------------------------------------------------------------------

ObjNull:
	rts

; -------------------------------------------------------------------------
; Draw objects
; -------------------------------------------------------------------------

DrawObjects:
	lea	sprites.w,a1			; Clear first sprite slot
	clr.l	(a1)+
	clr.l	(a1)+
	
	lea	objects.w,a0			; Objects
	lea	sprites.w,a1			; Sprite table
	moveq	#0,d5				; Reset link value
	moveq	#OBJCOUNT-1,d7			; Number of object slots
	
.DrawLoop:
	tst.w	oID(a0)				; Is this object slot occupied?
	beq.w	.NextObject			; If not, branch
	
	movea.l	oMap(a0),a2			; Get mappings
	bsr.w	AnimateObject			; Animation sprite
	
	move.w	oAnimFrame(a0),d0		; Get sprite data
	add.w	d0,d0
	add.w	d0,d0
	adda.w	2+2(a2,d0.w),a2
	
	move.w	(a2)+,d6			; Get number of sprite pieces
	moveq	#$D,d3				; Unknown
	
.DrawPieces:
	moveq	#0,d4				; Reset flip flags
	
	move.w	oX(a0),d0			; Get object X position
	btst	#7,oFlags(a0)			; Is the X flip flag set?
	beq.s	.NoXFlip			; If not, branch
	sub.w	6(a2),d0			; Subtract flipped X offset
	bset	#$B,d4				; Set sprite X flip flag
	bra.s	.SetX

.NoXFlip:
	sub.w	4(a2),d0			; Subtract X offset

.SetX:
	addi.w	#128,d0				; Add origin offset
	move.w	d0,6(a1)			; Set X position in sprite table
	
	move.w	oY(a0),d0			; Get object Y position
	btst	#6,oFlags(a0)			; Is the Y flip flag set?
	beq.s	.NoYFlip			; If not, branch
	sub.w	$A(a2),d0			; Subtract flipped Y offset
	bset	#$C,d4				; Set sprite Y flip flag
	bra.s	.SetY

.NoYFlip:
	sub.w	8(a2),d0			; Subtract Y offset

.SetY:
	addi.w	#128,d0				; Add origin offset
	move.w	d0,0(a1)			; Set Y position in sprite table
	
	addq.w	#1,d5				; Increment link value
	move.w	d5,d0				; Combine with sprite size
	or.w	0(a2),d0
	move.w	d0,2(a1)			; Store in sprite table
	
	move.w	oTile(a0),d0			; Get base tile ID
	btst	#5,oFlags(a0)			; Is the force priority flag set?
	beq.s	.SetTile			; If not, branch
	bset	#$F,d0				; If so, force priority
	
.SetTile:
	add.w	2(a2),d0			; Add sprite tile ID offset
	eor.w	d4,d0				; Apply flip flags
	move.w	d0,4(a1)			; Store in sprite table
	
	addq.l	#8,a1				; Next sprite table entry
	adda.w	#$C,a2				; Next sprite piece
	dbf	d6,.DrawPieces			; Loop until all sprite pieces are drawn
	
.NextObject:
	lea	oSize(a0),a0			; Next object
	dbf	d7,.DrawLoop			; Loop until all objects are drawn
	
	tst.w	d5				; Were any objects drawn at all?
	beq.s	.End				; If not, branch
	move.b	#0,-5(a1)			; If so, set the termination link value
	
.End:
	rts

; -------------------------------------------------------------------------
; Animate object
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to object slot
; -------------------------------------------------------------------------

AnimateObject:
	subq.w	#1,oAnimTime(a0)		; Decrement animation timer
	bhi.s	.End				; If it hasn't run out, branch
	
	move.w	oAnimFrame(a0),d0		; Increment animation frame
	addq.w	#1,d0
	cmp.w	(a2),d0				; Have we reached the end?
	bcs.s	.Update				; If not, branch
	moveq	#0,d0				; If so, loop back to the start
	
.Update:
	move.w	d0,oAnimFrame(a0)		; Set new animation frame
	add.w	d0,d0
	add.w	d0,d0
	move.w	2(a2,d0.w),oAnimTime(a0)	; Reset animation timer
	
.End:
	rts

; -------------------------------------------------------------------------
; Clear object slot
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to object slot
; -------------------------------------------------------------------------

ClearObject:
	movea.l	a0,a1				; Clear object slot
	moveq	#0,d1
	bra.w	Fill64

; -------------------------------------------------------------------------
; Initialize objects
; -------------------------------------------------------------------------

InitObjects:
	lea	objects.w,a1			; Objects
	moveq	#0,d1				; Fill with zero
	moveq	#OBJCOUNT-1,d0			; Number of object slots
	
.ClearLoop:
	jsr	Fill64(pc)			; Clear object slot
	dbf	d0,.ClearLoop			; Loop until all objects are cleared
	rts

; -------------------------------------------------------------------------
; Mass fill
; -------------------------------------------------------------------------
; PARAMETERS:
;	d1.l - Value to fill with
;	a1.l - Pointer to destination buffer
; -------------------------------------------------------------------------

Fill128:
	move.l	d1,(a1)+
Fill124:
	move.l	d1,(a1)+
Fill120:
	move.l	d1,(a1)+
Fill116:
	move.l	d1,(a1)+
Fill112:
	move.l	d1,(a1)+
Fill108:
	move.l	d1,(a1)+
Fill104:
	move.l	d1,(a1)+
Fill100:
	move.l	d1,(a1)+
Fill96:
	move.l	d1,(a1)+
Fill92:
	move.l	d1,(a1)+
Fill88:
	move.l	d1,(a1)+
Fill84:
	move.l	d1,(a1)+
Fill80:
	move.l	d1,(a1)+
Fill76:
	move.l	d1,(a1)+
Fill72:
	move.l	d1,(a1)+
Fill68:
	move.l	d1,(a1)+
Fill64:
	move.l	d1,(a1)+
Fill60:
	move.l	d1,(a1)+
Fill56:
	move.l	d1,(a1)+
Fill52:
	move.l	d1,(a1)+
Fill48:
	move.l	d1,(a1)+
Fill44:
	move.l	d1,(a1)+
Fill40:
	move.l	d1,(a1)+
Fill36:
	move.l	d1,(a1)+
Fill32:
	move.l	d1,(a1)+
Fill28:
	move.l	d1,(a1)+
Fill24:
	move.l	d1,(a1)+
Fill20:
	move.l	d1,(a1)+
Fill16:
	move.l	d1,(a1)+
Fill12:
	move.l	d1,(a1)+
Fill8:
	move.l	d1,(a1)+
Fill4:
	move.l	d1,(a1)+
	rts

; -------------------------------------------------------------------------
; Mass fill (VDP)
; -------------------------------------------------------------------------
; PARAMETERS:
;	d1.l - Value to fill with
;	a1.l - VDP control port
; -------------------------------------------------------------------------

Fill128VDP:
	move.l	d1,(a1)
Fill124VDP:
	move.l	d1,(a1)
Fill120VDP:
	move.l	d1,(a1)
Fill116VDP:
	move.l	d1,(a1)
Fill112VDP:
	move.l	d1,(a1)
Fill108VDP:
	move.l	d1,(a1)
Fill104VDP:
	move.l	d1,(a1)
Fill100VDP:
	move.l	d1,(a1)
Fill96VDP:
	move.l	d1,(a1)
Fill92VDP:
	move.l	d1,(a1)
Fill88VDP:
	move.l	d1,(a1)
Fill84VDP:
	move.l	d1,(a1)
Fill80VDP:
	move.l	d1,(a1)
Fill76VDP:
	move.l	d1,(a1)
Fill72VDP:
	move.l	d1,(a1)
Fill68VDP:
	move.l	d1,(a1)
Fill64VDP:
	move.l	d1,(a1)
Fill60VDP:
	move.l	d1,(a1)
Fill56VDP:
	move.l	d1,(a1)
Fill52VDP:
	move.l	d1,(a1)
Fill48VDP:
	move.l	d1,(a1)
Fill44VDP:
	move.l	d1,(a1)
Fill40VDP:
	move.l	d1,(a1)
Fill36VDP:
	move.l	d1,(a1)
Fill32VDP:
	move.l	d1,(a1)
Fill28VDP:
	move.l	d1,(a1)
Fill24VDP:
	move.l	d1,(a1)
Fill20VDP:
	move.l	d1,(a1)
Fill16VDP:
	move.l	d1,(a1)
Fill12VDP:
	move.l	d1,(a1)
Fill8VDP:
	move.l	d1,(a1)
Fill4VDP:
	move.l	d1,(a1)
	rts

; -------------------------------------------------------------------------
; Mass copy
; -------------------------------------------------------------------------
; PARAMETERS:
;	a1.l - Pointer to source data
;	a2.l - Pointer to destination buffer
; -------------------------------------------------------------------------

Copy128:
	move.l	(a1)+,(a2)+
Copy124:
	move.l	(a1)+,(a2)+
Copy120:
	move.l	(a1)+,(a2)+
Copy116:
	move.l	(a1)+,(a2)+
Copy112:
	move.l	(a1)+,(a2)+
Copy108:
	move.l	(a1)+,(a2)+
Copy104:
	move.l	(a1)+,(a2)+
Copy100:
	move.l	(a1)+,(a2)+
Copy96:
	move.l	(a1)+,(a2)+
Copy92:
	move.l	(a1)+,(a2)+
Copy88:
	move.l	(a1)+,(a2)+
Copy84:
	move.l	(a1)+,(a2)+
Copy80:
	move.l	(a1)+,(a2)+
Copy76:
	move.l	(a1)+,(a2)+
Copy72:
	move.l	(a1)+,(a2)+
Copy68:
	move.l	(a1)+,(a2)+
Copy64:
	move.l	(a1)+,(a2)+
Copy60:
	move.l	(a1)+,(a2)+
Copy56:
	move.l	(a1)+,(a2)+
Copy52:
	move.l	(a1)+,(a2)+
Copy48:
	move.l	(a1)+,(a2)+
Copy44:
	move.l	(a1)+,(a2)+
Copy40:
	move.l	(a1)+,(a2)+
Copy36:
	move.l	(a1)+,(a2)+
Copy32:
	move.l	(a1)+,(a2)+
Copy28:
	move.l	(a1)+,(a2)+
Copy24:
	move.l	(a1)+,(a2)+
Copy20:
	move.l	(a1)+,(a2)+
Copy16:
	move.l	(a1)+,(a2)+
Copy12:
	move.l	(a1)+,(a2)+
Copy8:
	move.l	(a1)+,(a2)+
Copy4:
	move.l	(a1)+,(a2)+
	rts

; -------------------------------------------------------------------------
; Mass copy (VDP)
; -------------------------------------------------------------------------
; PARAMETERS:
;	a1.l - Pointer to source data
;	a2.l - VDP control port
; -------------------------------------------------------------------------

Copy128VDP:
	move.l	(a1)+,(a2)
Copy124VDP:
	move.l	(a1)+,(a2)
Copy120VDP:
	move.l	(a1)+,(a2)
Copy116VDP:
	move.l	(a1)+,(a2)
Copy112VDP:
	move.l	(a1)+,(a2)
Copy108VDP:
	move.l	(a1)+,(a2)
Copy104VDP:
	move.l	(a1)+,(a2)
Copy100VDP:
	move.l	(a1)+,(a2)
Copy96VDP:
	move.l	(a1)+,(a2)
Copy92VDP:
	move.l	(a1)+,(a2)
Copy88VDP:
	move.l	(a1)+,(a2)
Copy84VDP:
	move.l	(a1)+,(a2)
Copy80VDP:
	move.l	(a1)+,(a2)
Copy76VDP:
	move.l	(a1)+,(a2)
Copy72VDP:
	move.l	(a1)+,(a2)
Copy68VDP:
	move.l	(a1)+,(a2)
Copy64VDP:
	move.l	(a1)+,(a2)
Copy60VDP:
	move.l	(a1)+,(a2)
Copy56VDP:
	move.l	(a1)+,(a2)
Copy52VDP:
	move.l	(a1)+,(a2)
Copy48VDP:
	move.l	(a1)+,(a2)
Copy44VDP:
	move.l	(a1)+,(a2)
Copy40VDP:
	move.l	(a1)+,(a2)
Copy36VDP:
	move.l	(a1)+,(a2)
Copy32VDP:
	move.l	(a1)+,(a2)
Copy28VDP:
	move.l	(a1)+,(a2)
Copy24VDP:
	move.l	(a1)+,(a2)
Copy20VDP:
	move.l	(a1)+,(a2)
Copy16VDP:
	move.l	(a1)+,(a2)
Copy12VDP:
	move.l	(a1)+,(a2)
Copy8VDP:
	move.l	(a1)+,(a2)
Copy4VDP:
	move.l	(a1)+,(a2)
	rts

; -------------------------------------------------------------------------
; VSync
; -------------------------------------------------------------------------

VSync:
	move.b	#1,vsyncFlag.w			; Set VSync flag
	move	#$2500,sr			; Enable interrupts

.Wait:
	tst.b	vsyncFlag.w			; Has the V-INT handler run?
	bne.s	.Wait				; If not, wait
	rts
	

; -------------------------------------------------------------------------
; Set all buttons
; -------------------------------------------------------------------------

SetAllButtons:
	move.w	#$FF00,ctrlData
	rts

; -------------------------------------------------------------------------
; Get a random number
; -------------------------------------------------------------------------
; RETURNS:
;	d0.l - Random number
; -------------------------------------------------------------------------

Random:
	move.l	d1,-(sp)
	move.l	rngSeed.w,d1			; Get RNG seed
	bne.s	.GotSeed			; If it's set, branch
	move.l	#$2A6D365A,d1			; Reset RNG seed otherwise

.GotSeed:
	move.l	d1,d0				; Get random number
	asl.l	#2,d1
	add.l	d0,d1
	asl.l	#3,d1
	add.l	d0,d1
	move.w	d1,d0
	swap	d1
	add.w	d1,d0
	move.w	d0,d1
	swap	d1
	move.l	d1,rngSeed.w			; Update RNG seed
	move.l	(sp)+,d1
	rts

; -------------------------------------------------------------------------
; Get sine or cosine of a value
; -------------------------------------------------------------------------
; PARAMETERS:
;	d3.w - Value
; RETURNS:
;	d3.w - Sine/cosine of value
; -------------------------------------------------------------------------

GetCosine:
	addi.w	#$80,d3				; Offset value for cosine

GetSine:
	andi.w	#$1FF,d3			; Keep within range
	move.w	d3,d4
	btst	#7,d3				; Is the value the 2nd or 4th quarters of the sinewave?
	beq.s	.NoInvert			; If not, branch
	not.w	d4				; Invert value to fit sinewave pattern

.NoInvert:
	andi.w	#$7F,d4				; Get sine/cosine value
	add.w	d4,d4
	move.w	SineTable(pc,d4.w),d4

	btst	#8,d3				; Was the input value in the 2nd half of the sinewave?
	beq.s	.SetValue			; If not, branch
	neg.w	d4				; Negate value

.SetValue:
	move.w	d4,d3				; Set final value
	rts

; -------------------------------------------------------------------------

SineTable:
	dc.w	$0000, $0003, $0006, $0009, $000C, $000F, $0012, $0016
	dc.w	$0019, $001C, $001F, $0022, $0025, $0028, $002B, $002F
	dc.w	$0032, $0035, $0038, $003B, $003E, $0041, $0044, $0047
	dc.w	$004A, $004D, $0050, $0053, $0056, $0059, $005C, $005F
	dc.w	$0062, $0065, $0068, $006A, $006D, $0070, $0073, $0076
	dc.w	$0079, $007B, $007E, $0081, $0084, $0086, $0089, $008C
	dc.w	$008E, $0091, $0093, $0096, $0099, $009B, $009E, $00A0
	dc.w	$00A2, $00A5, $00A7, $00AA, $00AC, $00AE, $00B1, $00B3
	dc.w	$00B5, $00B7, $00B9, $00BC, $00BE, $00C0, $00C2, $00C4
	dc.w	$00C6, $00C8, $00CA, $00CC, $00CE, $00D0, $00D1, $00D3
	dc.w	$00D5, $00D7, $00D8, $00DA, $00DC, $00DD, $00DF, $00E0
	dc.w	$00E2, $00E3, $00E5, $00E6, $00E7, $00E9, $00EA, $00EB
	dc.w	$00EC, $00EE, $00EF, $00F0, $00F1, $00F2, $00F3, $00F4
	dc.w	$00F5, $00F6, $00F7, $00F7, $00F8, $00F9, $00FA, $00FA
	dc.w	$00FB, $00FB, $00FC, $00FC, $00FD, $00FD, $00FE, $00FE
	dc.w	$00FE, $00FF, $00FF, $00FF, $00FF, $00FF, $00FF, $0100

; -------------------------------------------------------------------------
; Initialize the Mega Drive hardware
; -------------------------------------------------------------------------

InitMD:
	lea	.VDPRegs(pc),a0			; Set up VDP registers
	move.w	#$8000,d0
	moveq	#.VDPRegsEnd-.VDPRegs-1,d7

.SetVDPRegs:
	move.b	(a0)+,d0
	move.w	d0,VDPCTRL
	addi.w	#$100,d0
	dbf	d7,.SetVDPRegs

	moveq	#$40,d0				; Set up controller ports
	move.b	d0,IOCTRL1
	move.b	d0,IOCTRL2
	move.b	d0,IOCTRL3
	move.b	#$C0,IODATA1
	
	bra.s	.SkipZ80			; Skip the Z80 stuff
	
	Z80RESOFF				; Set Z80 reset off
	bsr.w	StopZ80				; Stop the Z80
	
	lea	Z80RAM,a1			; Load Z80 code
	move.b	#$F3,(a1)+			; DI
	move.b	#$F3,(a1)+			; DI
	move.b	#$C3,(a1)+			; JP $0000
	move.b	#0,(a1)+
	move.b	#0,(a1)+
	
	Z80RESON				; Set Z80 reset on
	Z80RESOFF				; Set Z80 reset off

.SkipZ80:
	bsr.w	StopZ80				; Stop the Z80

	DMAFILL	0,$10000,0			; Clear VRAM

	VDPCMD	move.l,$C000,VRAM,WRITE,VDPCTRL	; Reset plane A
	move.w	#$1000/2-1,d7

.ResetPlaneA:
	move.w	#$E6FF,VDPDATA
	dbf	d7,.ResetPlaneA

	VDPCMD	move.l,$E000,VRAM,WRITE,VDPCTRL	; Reset plane B
	move.w	#$1000/2-1,d7

.ResetPlaneB:
	move.w	#$6FE,VDPDATA
	dbf	d7,.ResetPlaneB
	
	VDPCMD	move.l,0,CRAM,WRITE,VDPCTRL	; Clear CRAM
	lea	.Palette(pc),a0
	moveq	#0,d0
	moveq	#$80/4-1,d7
	
.ClearCRAM:
	move.l	d0,VDPDATA
	dbf	d7,.ClearCRAM

	VDPCMD	move.l,0,VSRAM,WRITE,VDPCTRL	; Reset VSRAM
	move.l	#$FFE0,VDPDATA

	bsr.w	StartZ80			; Start the Z80
	move.w	#$8134,ipxVDPReg1		; Reset IPX VDP register 1 cache
	rts

; -------------------------------------------------------------------------

.Palette:
	incbin	"DA Garden/Data/Palette.bin"
	even

.VDPRegs:
	dc.b	%00000100			; No H-INT
	dc.b	%00110100			; V-INT, DMA, mode 5
	dc.b	$C000/$400			; Plane A location
	dc.b	0				; Window location
	dc.b	$E000/$2000			; Plane B location
	dc.b	$EC00/$200			; Sprite table location
	dc.b	0				; Reserved
	dc.b	0				; BG color line 0 color 0
	dc.b	0				; Reserved
	dc.b	0				; Reserved
	dc.b	0				; H-INT counter 0
	dc.b	%00000000			; Scroll by screen
	dc.b	%00000000			; H32
	dc.b	$D000/$400			; Horizontal scroll table lcation
	dc.b	0				; Reserved
	dc.b	2				; Auto increment by 2
	dc.b	%00000001			; 64x32 tile plane size
	dc.b	0				; Window horizontal position 0
	dc.b	0				; Window vertical position 0
.VDPRegsEnd:
	even
	
; -------------------------------------------------------------------------
; Stop the Z80
; -------------------------------------------------------------------------

StopZ80:
	move	sr,savedSR.w			; Save status register
	Z80STOP					; Stop the Z80
	rts

; -------------------------------------------------------------------------
; Start the Z80
; -------------------------------------------------------------------------

StartZ80:
	Z80START				; Start the Z80
	move	savedSR.w,sr			; Restore status register
	rts

; -------------------------------------------------------------------------
; Read controller data
; -------------------------------------------------------------------------

ReadController:
	lea	ctrlData,a0			; Controller data buffer
	lea	IODATA1,a1			; Controller port 1
	
	move.b	#0,(a1)				; TH = 0
	tst.w	(a0)				; Delay
	move.b	(a1),d0				; Read start and A buttons
	lsl.b	#2,d0
	andi.b	#$C0,d0
	
	move.b	#$40,(a1)			; TH = 1
	tst.w	(a0)				; Delay
	move.b	(a1),d1				; Read B, C, and D-pad buttons
	andi.b	#$3F,d1

	or.b	d1,d0				; Combine button data
	not.b	d0				; Flip bits
	move.b	d0,d1				; Make copy

	move.b	(a0),d2				; Mask out tapped buttons
	eor.b	d2,d0
	move.b	d1,(a0)+			; Store pressed buttons
	and.b	d1,d0				; store tapped buttons
	move.b	d0,(a0)+
	rts

; -------------------------------------------------------------------------
; V-BLANK interrupt
; -------------------------------------------------------------------------

VInterrupt:
	movem.l	d0-a6,-(sp)			; Save registers

	move.b	#1,GAIRQ2			; Trigger IRQ2 on Sub CPU
	tst.b	vsyncFlag.w			; Is the VSync flag set?
	beq.w	VInt_Lag			; If not, branch
	move.b	#0,vsyncFlag.w			; Clear VSync flag
	
	lea	VDPCTRL,a1			; VDP control port
	lea	VDPDATA,a2			; VDP data port
	move.w	(a1),d0				; Reset V-BLANK flag

	jsr	StopZ80(pc)			; Stop the Z80
	
	move.w	vintRoutine.w,d0		; Run routine
	add.w	d0,d0
	move.w	.Routines(pc,d0.w),d0
	jmp	.Routines(pc,d0.w)

; -------------------------------------------------------------------------

.Routines:
	dc.w	VInt_CopyPlanet1_1-.Routines	; Copy 1st half of rendered planet image to buffer 1
	dc.w	VInt_CopyPlanet1_2-.Routines	; Copy 2nd half of rendered planet image to buffer 1
	dc.w	VInt_CopyPlanet2_1-.Routines	; Copy 1st half of rendered planet image to buffer 2
	dc.w	VInt_CopyPlanet2_2-.Routines	; Copy 2nd half of rendered planet image to buffer 2

; -------------------------------------------------------------------------

VInt_CopyPlanet1_1:
	VDPCMD	move.l,$D000,VRAM,WRITE,VDPCTRL	; Show planet buffer 1
	move.w	#$100,(a2)
	COPYIMG	planetImage, 0, 0		; Copy rendered planet image
	jsr	ReadController(pc)
	bra.w	VInt_Done

; -------------------------------------------------------------------------

VInt_CopyPlanet1_2:
	COPYIMG	planetImage, 0, 1		; Copy rendered planet image
	bra.w	VInt_Done

; -------------------------------------------------------------------------

VInt_CopyPlanet2_1:
	VDPCMD	move.l,$D000,VRAM,WRITE,VDPCTRL	; Show planet buffer 2
	move.w	#0,(a2)
	COPYIMG	planetImage, 1, 0		; Copy rendered planet image
	jsr	ReadController(pc)
	bra.w	VInt_Done

; -------------------------------------------------------------------------

VInt_CopyPlanet2_2:
	COPYIMG	planetImage, 1, 1		; Copy rendered planet image

; -------------------------------------------------------------------------

VInt_Done:
	DMA68K	sprites,$EC00,$280,VRAM		; Copy sprite data
	
	tst.b	disablePalCycle.w		; Is palette cycling disabled?
	bne.w	.NoPalCycle			; If so, branch
	
	subq.w	#1,palCycleTimer.w
	bhi.s	.CycleSpritePal
	cmpi.w	#$1F,palCycleIndex.w
	blt.s	.PalCycle
	move.w	#0,palCycleIndex.w

.PalCycle:
	lea	PalCycleTimes,a0		; Reset palette cycle timer
	move.w	palCycleIndex.w,d0
	add.w	d0,d0
	move.w	(a0,d0.w),palCycleTimer.w
	addq.w	#1,palCycleIndex.w		; Increment palette cycle index
	
	lea	PalCycleTable(pc),a0		; Get time zone palette cycle metadata
	move.w	trackTimeZone.w,d1
	add.w	d1,d1
	add.w	d1,d1
	add.w	d1,d1
	lea	(a0,d1.w),a1
	
	movea.l	(a1),a2				; Get planet palette cycle data
	adda.w	(a2,d0.w),a2
	
	lea	4(a0,d1.w),a1			; Get background palette cycle data
	movea.l	(a1),a1
	adda.w	(a1,d0.w),a1
	
	lea	palette.w,a0			; Load background palette
	moveq	#$20/4-1,d7

.UpdateBGPal:
	move.l	(a1)+,(a0)+
	dbf	d7,.UpdateBGPal
	
	moveq	#$20/4-1,d7			; Load planet palette

.UpdatePlanetPal:
	move.l	(a2)+,(a0)+
	dbf	d7,.UpdatePlanetPal

.CycleSpritePal:
	subq.w	#1,sprPalCycTimer.w		; Decrement sprite palette cycle timer
	bgt.s	.ChkVolcanoTimer		; If it hasn't run out, branch
	
	move.w	sprPalCycIndex.w,d0		; Get sprite palette cycle data
	lea	SprPalCycTable,a1
	adda.w	(a1,d0.w),a1
	
	lea	palette+($20*2).w,a0		; Load sprite palette
	moveq	#$20/4-1,d7

.UpdateSprPal:
	move.l	(a1)+,(a0)+
	dbf	d7,.UpdateSprPal
	
	tst.w	d0				; Are we on the last sprite palette cycle index?
	bne.s	.ResetSprPalCyc			; If so, branch
	move.w	#2,sprPalCycIndex.w		; Increment sprite palette cycle index
	bra.s	.ResetSprPalCycTimer

.ResetSprPalCyc:
	move.w	#0,sprPalCycIndex.w		; Reset sprite palette cycle index

.ResetSprPalCycTimer:
	move.w	#5,sprPalCycTimer.w		; Reset sprite palette cycle timer

.NoPalCycle:
	DMA68K	palette,$0000,$80,CRAM		; Copy palette data

.ChkVolcanoTimer:
	tst.w	volcanoTimer.w			; Has the volcano timer run out?
	ble.s	.CheckTimer			; If so, branch
	subq.w	#1,volcanoTimer.w		; Decrement volcano timer

.CheckTimer:
	bsr.w	StartZ80			; Start the Z80
	
	tst.w	timer.w				; Is the timer running?
	beq.s	.NoTimer			; If not, branch
	subq.w	#1,timer.w			; Decrement timer

.NoTimer:
	addq.w	#1,vintCounter.w		; Increment counter
	
	movem.l	(sp)+,d0-a6			; Restore registers
	rte

; -------------------------------------------------------------------------

VInt_Lag:
	addq.l	#1,lagCounter.w			; Increment lag counter
	move.b	vintRoutine+1.w,lagCounter.w	; Save routine ID
	
	movem.l	(sp)+,d0-a6			; Restore registers
	rte

; -------------------------------------------------------------------------
; Fade the screen to white
; -------------------------------------------------------------------------

FadeToWhite:
	move.w	#$3F,palFadeInfo.w		; Set palette fade start and length

	move.w	#(7*3),d4			; Prepare to do fading

.Fade:
	move.b	#$A,vsyncFlag2.w		; VSync
	bsr.w	VSync
	bsr.s	FadeColorsToWhite		; Fade colors once
	dbf	d4,.Fade			; Loop until fading is done

	rts

; -------------------------------------------------------------------------

FadeColorsToWhite:
	moveq	#0,d0				; Get starting palette fade location
	lea	palette.w,a0
	move.b	palFadeStart.w,d0
	adda.w	d0,a0
	move.b	palFadeLen.w,d0			; Get palette fade length

.Loop:
	bsr.s	FadeColorToWhite		; Fade a color
	dbf	d0,.Loop			; Loop until finished

	moveq	#0,d0				; Get starting palette fade location for fade buffer
	lea	fadePalette.w,a0
	move.b	palFadeStart.w,d0
	adda.w	d0,a0
	move.b	palFadeLen.w,d0			; Get palette fade length

.LoopWater:
	bsr.s	FadeColorToWhite		; Fade a color
	dbf	d0,.LoopWater			; Loop until finished
	rts

; -------------------------------------------------------------------------

FadeColorToWhite:
	move.w	(a0),d2				; Get color
	cmpi.w	#$EEE,d2			; Is it already white?
	beq.s	.Skip				; If so, branch

.Red:
	move.w	d2,d1				; Get red component
	andi.w	#$E,d1				; Is it already 0?
	cmpi.w	#$E,d1
	beq.s	.Green				; If so, check green
	addq.w	#2,(a0)+			; Fade red
	rts

.Green:
	move.w	d2,d1				; Get green component
	andi.w	#$E0,d1				; Is it already 0?
	cmpi.w	#$E0,d1
	beq.s	.Blue				; If so, check blue
	addi.w	#$20,(a0)+			; Fade green
	rts

.Blue:
	move.w	d2,d1				; Get blue component
	andi.w	#$E00,d1			; Is it already 0?
	cmpi.w	#$E00,d1
	beq.s	.Skip				; If so, we're done
	addi.w	#$200,(a0)+			; Fade blue
	rts

.Skip:
	addq.w	#2,a0				; Skip over this color
	rts

; -------------------------------------------------------------------------
; Fade the screen from white
; -------------------------------------------------------------------------

FadeFromWhite:
	move.w	#$3F,palFadeInfo.w		; Set palette fade start and length

	moveq	#0,d0				; Get starting palette fill location
	lea	palette.w,a0
	move.b	palFadeStart.w,d0
	adda.w	d0,a0
	move.w	#$EEE,d1			; Get palette fill value (whiyte)
	move.b	palFadeLen.w,d0			; Get palette fill length

.Fill:
	move.w	d1,(a0)+
	dbf	d0,.Fill			; Fill until finished

	move.w	#(7*3),d4			; Prepare to do fading

.Fade:
	move.b	#$A,vsyncFlag.w			; VSync
	bsr.w	VSync
	bsr.s	FadeColorsFromWhite		; Fade colors once
	dbf	d4,.Fade			; Loop until fading is done

	rts

; -------------------------------------------------------------------------

FadeColorsFromWhite:
	moveq	#0,d0				; Get starting palette fade locations
	lea	palette.w,a0
	lea	fadePalette.w,a1
	move.b	palFadeStart.w,d0
	adda.w	d0,a0
	adda.w	d0,a1
	move.b	palFadeLen.w,d0			; Get palette fade length

.Loop:
	bsr.s	FadeColorFromWhite		; Fade a color
	dbf	d0,.Loop			; Loop until finished

	bra.s	.End				; Skip water fade update

	moveq	#0,d0				; Get starting palette fade locations for water
	lea	waterPalette.w,a0
	lea	waterFadePal.w,a1
	move.b	palFadeStart.w,d0
	adda.w	d0,a0
	adda.w	d0,a1
	move.b	palFadeLen.w,d0			; Get palette fade length

.LoopWater:
	bsr.s	FadeColorFromWhite		; Fade a color
	dbf	d0,.LoopWater			; Loop until finished

.End:
	rts

; -------------------------------------------------------------------------

FadeColorFromWhite:
	move.w	(a1)+,d2			; Get target color
	move.w	(a0),d3				; Get current color
	cmp.w	d2,d3				; Are they the same?
	beq.s	.Skip				; If so, branch

	move.w	d3,d1				; Fade blue
	subi.w	#$200,d1			; Is it already 0?
	bcs.s	.Green				; If so, start fading green
	cmp.w	d2,d1				; Is the blue component done?
	bcs.s	.Green				; If so, start fading green
	move.w	d1,(a0)+			; Update color
	rts

.Green:
	move.w	d3,d1				; Fade green
	subi.w	#$20,d1				; Is it already 0?
	bcs.s	.Red				; If so, start fading red
	cmp.w	d2,d1				; Is the green component done?
	bcs.s	.Red				; If so, start fading red
	move.w	d1,(a0)+			; Update color
	rts

.Red:
	subq.w	#2,(a0)+			; Fade red
	rts

.Skip:
	addq.w	#2,a0				; Skip over this color
	rts

; -------------------------------------------------------------------------
; Fade the screen from black
; -------------------------------------------------------------------------

FadeFromBlack:
	move.w	#$3F,palFadeInfo.w		; Set palette fade start and length

	moveq	#0,d0				; Get starting palette fill location
	lea	palette.w,a0
	move.b	palFadeStart.w,d0
	adda.w	d0,a0
	moveq	#0,d1				; Get palette fill value (black)
	move.b	palFadeLen.w,d0			; Get palette fill length

.Clear:
	move.w	d1,(a0)+
	dbf	d0,.Clear			; Fill until finished

	move.w	#(7*3),d4			; Prepare to do fading

.Fade:
	move.b	#$A,vsyncFlag.w			; VSync
	bsr.w	VSync
	bsr.s	FadeColorsFromBlack		; Fade colors once
	dbf	d4,.Fade			; Loop until fading is done

	rts

; -------------------------------------------------------------------------

FadeColorsFromBlack:
	moveq	#0,d0				; Get starting palette fade locations
	lea	palette.w,a0
	lea	fadePalette.w,a1
	move.b	palFadeStart.w,d0
	adda.w	d0,a0
	adda.w	d0,a1
	move.b	palFadeLen.w,d0			; Get palette fade length

.Loop:
	bsr.s	FadeColorFromBlack		; Fade a color
	dbf	d0,.Loop			; Loop until finished

	bra.s	.End				; Skip water fade update

	moveq	#0,d0				; Get starting palette fade locations for water
	lea	waterPalette.w,a0
	lea	waterFadePal.w,a1
	move.b	palFadeStart.w,d0
	adda.w	d0,a0
	adda.w	d0,a1
	move.b	palFadeLen.w,d0			; Get palette fade length

.LoopWater:
	bsr.s	FadeColorFromBlack		; Fade a color
	dbf	d0,.LoopWater			; Loop until finished

.End:
	rts

; -------------------------------------------------------------------------

FadeColorFromBlack:
	move.w	(a1)+,d2			; Get target color
	move.w	(a0),d3				; Get current color
	cmp.w	d2,d3				; Are they the same?
	beq.s	.Skip				; If so, branch

.Blue:
	move.w	d3,d1				; Fade blue
	addi.w	#$200,d1
	cmp.w	d2,d1				; Is the blue component done?
	bhi.s	.Green				; If so, start fading green
	move.w	d1,(a0)+			; Update color
	rts

.Green:
	move.w	d3,d1				; Fade green
	addi.w	#$20,d1
	cmp.w	d2,d1				; Is the green component done?
	bhi.s	.Red				; If so, start fading red
	move.w	d1,(a0)+			; Update color
	rts

.Red:
	addq.w	#2,(a0)+			; Fade red
	rts


.Skip:
	addq.w	#2,a0				; Skip over this color
	rts

; -------------------------------------------------------------------------
; Fade the screen to black
; -------------------------------------------------------------------------

FadeToBlack:
	move.w	#$3F,palFadeInfo.w		; Set palette fade start and length

	move.w	#(7*3),d4			; Prepare to do fading

.Fade:
	move.b	#$A,vsyncFlag.w			; VSync
	bsr.w	VSync
	bsr.s	FadeColorsToBlack		; Fade colors once
	dbf	d4,.Fade			; Loop until fading is done

	rts

; -------------------------------------------------------------------------

FadeColorsToBlack:
	moveq	#0,d0				; Get starting palette fade location
	lea	palette.w,a0
	move.b	palFadeStart.w,d0
	adda.w	d0,a0
	move.b	palFadeLen.w,d0			; Get palette fade length

.Loop:
	bsr.s	FadeColorToBlack		; Fade a color
	dbf	d0,.Loop			; Loop until finished

	moveq	#0,d0				; Get starting palette fade location for water
	lea	waterPalette.w,a0
	move.b	palFadeStart.w,d0
	adda.w	d0,a0
	move.b	palFadeLen.w,d0			; Get palette fade length

.LoopWater:
	bsr.s	FadeColorToBlack		; Fade a color
	dbf	d0,.LoopWater			; Loop until finished

	rts

; -------------------------------------------------------------------------

FadeColorToBlack:
	move.w	(a0),d2				; Get color
	beq.s	.Skip				; If it's already black, branch

.Red:
	move.w	d2,d1				; Get red component
	andi.w	#$E,d1				; Is it already 0?
	beq.s	.Green				; If so, check green
	subq.w	#2,(a0)+			; Fade red
	rts

.Green:
	move.w	d2,d1				; Get green component
	andi.w	#$E0,d1				; Is it already 0?
	beq.s	.Blue				; If so, check blue
	subi.w	#$20,(a0)+			; Fade green
	rts

.Blue:
	move.w	d2,d1				; Get blue component
	andi.w	#$E00,d1			; Is it already 0?
	beq.s	.Skip				; If so, we're done
	subi.w	#$200,(a0)+			; Fade blue
	rts

.Skip:
	addq.w	#2,a0				; Skip over this color
	rts

; -------------------------------------------------------------------------
; Update object spawns
; -------------------------------------------------------------------------

UpdateObjSpawns:
	btst	#0,trackSelFlags.w		; Is track selection active?
	beq.s	.CheckTimers			; If not, branch
	rts

.CheckTimers:
	lea	objSpawnTimers.w,a2		; Spawn timers
	moveq	#OBJTYPECNT-1,d5		; Number of object types

.ChkTimerLoop:
	subq.w	#1,(a2)				; Decrement current timer
	bcs.s	.SpawnObject			; If it has run out, branch
	adda.w	#2,a2				; Next timer
	dbf	d5,.ChkTimerLoop		; Loop until all timers are checked
	rts

; -------------------------------------------------------------------------

.SpawnObject:
	move.w	d5,d0				; Reset timer
	add.w	d0,d0
	add.w	d0,d0
	lea	.SpawnTimes(pc,d0.w),a1
	move.w	(a1)+,(a2)
	
	movem.l	d5/a1-a2,-(sp)			; Add random value to timer
	jsr	Random(pc)
	movem.l	(sp)+,d5/a1-a2
	andi.l	#$FFFF,d0
	moveq	#0,d1
	move.w	(a1),d1
	divs.w	d1,d0
	swap	d0
	add.w	d0,(a2)
	
	move.w	d5,d0				; Spawn object
	add.w	d0,d0
	move.w	.SpawnIndex(pc,d0.w),d0
	jmp	.SpawnIndex(pc,d0.w)

; -------------------------------------------------------------------------

.SpawnTimes:
	dc.w	300, 600
	dc.w	360, 660
	dc.w	420, 720
	dc.w	480, 780
	dc.w	540, 840
	dc.w	600, 900
	
.SpawnIndex:
	dc.w	SpawnFlickies-.SpawnIndex
	dc.w	SpawnStars-.SpawnIndex
	dc.w	SpawnUFOs-.SpawnIndex
	dc.w	SpawnEggman-.SpawnIndex
	dc.w	SpawnMetalSonic-.SpawnIndex
	dc.w	SpawnTails-.SpawnIndex

; -------------------------------------------------------------------------
; Spawn flickies
; -------------------------------------------------------------------------

SpawnFlickies:
	btst	#0,objSpawnFlags.w		; Is spawn slot 0 occupied?
	beq.s	.First				; If not, branch
	btst	#1,objSpawnFlags.w		; Is spawn slot 1 occupied?
	beq.s	.Second				; If not, branch
	rts

.First:
	bset	#0,objSpawnFlags.w		; Occupy spawn slot 0
	move.b	#1,objSpawnID.w
	moveq	#1,d0				; Load art
	jsr	LoadArt
	bra.s	.GetX

.Second:
	bset	#1,objSpawnFlags.w		; Occupy spawn slot 1
	move.b	#2,objSpawnID.w
	moveq	#2,d0				; Load art
	jsr	LoadArt

.GetX:
	jsr	Random(pc)			; Pick horizontal side to spawn from
	move.w	d0,d7
	tst.w	d7
	bge.s	.StartFromLeft
	move.l	#264,d5
	bra.s	.GetCount

.StartFromLeft:
	moveq	#-6,d5

.GetCount:
	jsr	Random(pc)			; Get core Y position
	andi.l	#$7FFF,d0
	divs.w	#160,d0
	swap	d0
	move.w	d0,d6
	addi.w	#16,d6
	
	move.w	d7,d0				; Pick spawn group
	andi.l	#$7FFF,d0
	divu.w	#4,d0
	swap	d0
	add.w	d0,d0
	add.w	d0,d0
	lea	.SpawnGroups,a2
	adda.w	d0,a2
	
	move.w	(a2)+,d2			; Get number of flickies
	move.w	(a2),d0				; Get flicky position offsets
	lea	.SpawnGroups,a2
	adda.w	d0,a2

	btst	#0,objSpawnID.w			; Get base tile ID
	beq.s	.SecondTileID
	move.w	#$5B8,d3
	bra.s	.SpawnObjs

.SecondTileID:
	move.w	#$5DC,d3

.SpawnObjs:
	bsr.w	FindObjSlot			; Spawn flicky
	bne.w	.End
	bsr.w	SpawnFlickyObj
	dbf	d2,.SpawnObjs			; Loop until flickies are spawned

.End:
	move.b	#0,objSpawnID.w			; Reset spawn slot ID
	rts

; -------------------------------------------------------------------------

.SpawnGroups:
	dc.w	4-1, .Group0-.SpawnGroups
	dc.w	4-1, .Group1-.SpawnGroups
	dc.w	6-1, .Group2-.SpawnGroups
	dc.w	6-1, .Group2-.SpawnGroups

.Group0:
	dc.w	0, 0
	dc.w	-24, 8
	dc.w	-48, -8
	dc.w	-34, 20

.Group1:
	dc.w	0, 0
	dc.w	-16, -24
	dc.w	-16, 24
	dc.w	-32, 0

.Group2:
	dc.w	0, 0
	dc.w	-16, -22
	dc.w	-40, -28
	dc.w	-32, 16
	dc.w	-16, 24
	dc.w	-48, -5

; -------------------------------------------------------------------------

SpawnFlickyObj:
	move.w	d3,oTile(a1)			; Set base tile ID
	move.b	objSpawnID.w,oSpawnID(a1)	; Set spawn slot ID
	move.w	d5,oX(a1)			; Set position
	move.w	d6,oY(a1)
	move.w	#$30,oFloatSpeed(a1)		; Set float speed
	move.w	#4,oFloatAmp(a1)		; Set float amplitude

	tst.w	d2				; Is this the last flicky?
	bgt.s	.Normal				; If not, branch

	jsr	Random(pc)			; Randomly determine if this flicky is normal, slow, or glides
	andi.l	#$7FFF,d0
	divs.w	#3,d0
	swap	d0
	beq.s	.Normal				; If normal, branch
	cmpi.w	#1,d0
	beq.s	.Slow				; If slow, branch
	bset	#1,oFlags(a1)			; Mark as gliding
	move.l	#$14000,oXVel(a1)		; Set velocity
	move.l	#$E000,oYVel(a1)
	lea	MapSpr_FlickyGlide(pc),a3	; Get gliding mappings
	bra.s	.Setup

.Slow:
	bset	#0,oFlags(a1)			; Mark as slow
	move.l	#$A000,oXVel(a1)		; Set velocity
	move.l	#0,oYVel(a1)
	lea	MapSpr_FlickySlow(pc),a3	; Get slow mappings
	bra.s	.Setup

.Normal:
	move.l	#$14000,oXVel(a1)		; Set velocity
	move.l	#0,oYVel(a1)
	lea	MapSpr_Flicky(pc),a3		; Get normal mappings

.Setup:
	move.l	a3,oMap(a1)			; Set mappings
	move.w	2(a3),oAnimTime(a1)		; Set initial animation timer

	bset	#3,oFlags(a1)			; Mark as facing right
	move.w	#1,(a1)				; Set object ID
	move.w	(a2)+,d0			; Get X offset
	tst.w	d7				; Is the Flicky moving from the left side of the screen?
	bge.s	.SetOffset			; If so, branch
	bset	#7,oFlags(a1)			; Mark as facing left
	bclr	#3,oFlags(a1)
	neg.w	d0				; Move left
	neg.l	oXVel(a1)

.SetOffset:
	add.w	d0,oX(a1)			; Set X offset
	move.w	(a2)+,d0			; Set Y offset
	add.w	d0,oY(a1)
	rts

; -------------------------------------------------------------------------
; Spawn stars
; -------------------------------------------------------------------------

SpawnStars:
	cmpi.w	#$A,palCycleIndex.w		; Is it night?
	ble.w	.End				; If not, branch
	cmpi.w	#$18,palCycleIndex.w
	bge.w	.End				; If not, branch

	btst	#0,objSpawnFlags.w		; Is spawn slot 0 occupied?
	beq.s	.First				; If not, branch
	btst	#1,objSpawnFlags.w		; Is spawn slot 1 occupied?
	beq.s	.Second				; If not, branch
	rts

.First:
	bset	#0,objSpawnFlags.w		; Occupy spawn slot 0
	move.b	#1,objSpawnID.w
	moveq	#3,d0				; Load art
	jsr	LoadArt
	bra.s	.Spawn

.Second:
	bset	#1,objSpawnFlags.w		; Occupy spawn slot 1
	move.b	#2,objSpawnID.w
	moveq	#4,d0				; Load art
	jsr	LoadArt

.Spawn:
	jsr	Random(pc)			; Get spawn group ID
	move.w	d0,d7

	moveq	#0,d3				; Move right
	jsr	Random(pc)			; Get core X position within left side of the screen
	andi.l	#$7FFF,d0
	divs.w	#128,d0
	swap	d0
	move.w	d0,d5
	addi.w	#0,d5
	cmpi.w	#128,d5				; Is the core X position on the right side of the screen (never happens)?
	bgt.s	.GetTileID			; If so, branch
	moveq	#1,d3				; Move left

.GetTileID:
	moveq	#0,d6				; Get core Y position

	btst	#0,objSpawnID.w			; Get base tile ID
	beq.s	.SecondTileID
	move.w	#$5B8,d1
	bra.s	.GetCount

.SecondTileID:
	move.w	#$5DC,d1

.GetCount:
	move.w	d7,d0				; Pick spawn group
	andi.l	#$7FFF,d0
	divu.w	#5,d0
	swap	d0
	add.w	d0,d0
	add.w	d0,d0
	lea	.SpawnGroups(pc,d0.w),a2

	move.w	(a2)+,d2			; Get number of stars
	move.w	(a2),d0				; Get star position offsets
	lea	.SpawnGroups(pc,d0.w),a2

.SpawnObjs:
	bsr.w	FindObjSlot			; Spawn star
	bne.w	.End
	bsr.w	SpawnStarObj
	dbf	d2,.SpawnObjs			; Loop until stars are spawned

.End:
	move.b	#0,objSpawnID.w			; Reset spawn slot ID
	rts

; -------------------------------------------------------------------------

.SpawnGroups:
	dc.w	3-1, .Group0-.SpawnGroups
	dc.w	3-1, .Group0-.SpawnGroups
	dc.w	2-1, .Group0-.SpawnGroups
	dc.w	1-1, .Group0-.SpawnGroups
	dc.w	3-1, .Group0-.SpawnGroups
	
.Group0:
	dc.w	0, 0				; BUG: those second 0s should not be here
	dc.w	32, 0
	dc.w	-32, 0

; -------------------------------------------------------------------------

SpawnStarObj:
	move.w	#2,oID(a1)			; Set object ID
	move.w	d1,oTile(a1)			; Set base tile ID
	move.b	objSpawnID.w,oSpawnID(a1)	; Set spawn slot ID
	move.w	d5,oX(a1)			; Set position
	move.w	d6,oY(a1)
	
	move.l	#$20000,oXVel(a1)		; Move right
	tst.w	d3				; Are the stars set to move right?
	beq.s	.GetYVel			; If so, branch
	neg.l	oXVel(a1)			; Move left

.GetYVel:
	jsr	Random(pc)			; Set Y velocity
	andi.l	#$7FFF,d0
	divs.w	#$80,d0
	andi.l	#$7FFF0000,d0
	asr.l	#4,d0
	move.l	#$40000,oYVel(a1)
	add.l	d0,oYVel(a1)

	jsr	Random(pc)			; Add random X offset
	andi.l	#$7FFF,d0
	divs.w	#240,d0
	swap	d0
	add.w	d0,oX(a1)

	move.w	(a2)+,d0			; Add Y offset
	add.w	d0,oY(a1)
	rts

; -------------------------------------------------------------------------
; Spawn UFOs
; -------------------------------------------------------------------------

SpawnUFOs:
	nop
	btst	#0,objSpawnFlags.w		; Is spawn slot 0 occupied?
	beq.s	.First				; If not, branch
	btst	#1,objSpawnFlags.w		; Is spawn slot 1 occupied?
	beq.s	.Second				; If not, branch
	rts

.First:
	bset	#0,objSpawnFlags.w		; Occupy spawn slot 0
	move.b	#1,objSpawnID.w
	moveq	#5,d0				; Load art
	jsr	LoadArt
	bra.s	.GetX

.Second:
	bset	#1,objSpawnFlags.w		; Occupy spawn slot 1
	move.b	#2,objSpawnID.w
	moveq	#6,d0				; Load art
	jsr	LoadArt

.GetX:
	jsr	Random(pc)			; Pick horizontal side to spawn from
	move.w	d0,d7
	tst.w	d7
	bge.s	.StartFromLeft
	move.l	#264,d5
	bra.s	.GetTileID

.StartFromLeft:
	moveq	#-6,d5

.GetTileID:
	jsr	Random(pc)			; Get core Y position
	andi.l	#$7FFF,d0
	divs.w	#160,d0
	swap	d0
	move.w	d0,d6
	addi.w	#16,d6

	btst	#0,objSpawnID.w			; Get base tile ID
	beq.s	.SecondTileID
	move.w	#$5B8,d1
	bra.s	.GetCount

.SecondTileID:
	move.w	#$5DC,d1

.GetCount:
	move.w	d7,d0				; Pick spawn group
	andi.l	#$7FFF,d0
	divu.w	#5,d0
	swap	d0
	add.w	d0,d0
	add.w	d0,d0
	lea	.SpawnGroups(pc,d0.w),a2

	move.w	(a2)+,d2			; Get number of UFOs
	move.w	(a2),d0				; Get UFO position offsets
	lea	.SpawnGroups(pc,d0.w),a2

.SpawnObjs:
	bsr.w	FindObjSlot			; Spawn UFO
	bne.w	.End

	move.w	d1,oTile(a1)			; Set tile ID
	move.b	objSpawnID.w,oSpawnID(a1)	; Set spawn slot ID
	move.w	d5,oX(a1)			; Set position
	move.w	d6,oY(a1)
	move.w	#$28,oFloatSpeed(a1)		; Set float speed
	move.w	#6,oFloatAmp(a1)		; Set float amplitude
	move.l	#$20000,oXVel(a1)		; Set velocity
	move.l	#0,oYVel(a1)
	bset	#3,oFlags(a1)			; Mark as facing right
	move.w	#4,oID(a1)			; Set object ID

	move.w	(a2)+,d0			; Get X offset
	tst.w	d7				; Is the UFO moving from the left side of the screen?
	bge.s	.SetPosOffset			; If so, branch
	bset	#7,oFlags(a1)			; Mark as facing left
	bclr	#3,oFlags(a1)
	neg.w	d0				; Move left
	neg.l	oXVel(a1)
	neg.l	oYVel(a1)

.SetPosOffset:
	add.w	d0,oX(a1)			; Set X offset
	move.w	(a2)+,d0			; Set Y offset
	add.w	d0,oY(a1)

	dbf	d2,.SpawnObjs			; Loop until UFOs are spawned

.End:
	move.b	#0,objSpawnID.w			; Reset spawn slot ID
	rts

; -------------------------------------------------------------------------

.SpawnGroups:
	dc.w	1-1, .Group0-.SpawnGroups
	dc.w	2-1, .Group0-.SpawnGroups
	dc.w	1-1, .Group0-.SpawnGroups
	dc.w	2-1, .Group0-.SpawnGroups
	dc.w	1-1, .Group0-.SpawnGroups
	
.Group0:
	dc.w	0
	dc.w	0
	dc.w	$10
	dc.w	$30

; -------------------------------------------------------------------------
; Spawn Eggman
; -------------------------------------------------------------------------

SpawnEggman:
	btst	#0,objSpawnFlags.w		; Is spawn slot 0 occupied?
	bne.w	.End				; If so, branch
	btst	#1,objSpawnFlags.w		; Is spawn slot 1 occupied?
	bne.w	.End				; If so, branch
	bset	#0,objSpawnFlags.w		; Occupy both spawn slots
	bset	#1,objSpawnFlags.w
	move.b	#%11,objSpawnID.w

	moveq	#7,d0				; Load art
	jsr	LoadArt

	jsr	Random(pc)			; Pick horizontal side to spawn from
	move.w	d0,d7
	tst.w	d7
	bge.s	.StartFromRight
	moveq	#-6,d5
	bra.s	.SpawnObj

.StartFromRight:
	move.l	#264,d5

.SpawnObj:
	jsr	Random(pc)			; Get Y position
	andi.l	#$7FFF,d0
	divs.w	#64,d0
	swap	d0
	move.w	d0,d6
	addi.w	#128,d6

	bsr.w	FindObjSlot			; Spawn Eggman
	bne.w	.End
	move.w	#$5B8,oTile(a1)			; Set base tile ID
	move.b	objSpawnID.w,oSpawnID(a1)	; Set spawn slot ID
	move.w	d5,oX(a1)			; Set position
	move.w	d6,oY(a1)
	move.w	#$28,oFloatSpeed(a1)		; Set float speed
	move.w	#$A,oFloatAmp(a1)		; Set float amplitude
	move.l	#-$14000,oXVel(a1)		; Set velocity
	move.l	#-$8000,oYVel(a1)
	move.w	#3,oID(a1)			; Set object ID
	
	tst.w	d7				; Is Eggman moving from the right side of the screen?
	bge.s	.End				; If so, branch
	bset	#7,oFlags(a1)			; Mark as facing right
	neg.l	oXVel(a1)			; Move right

.End:
	move.b	#0,objSpawnID.w			; Reset spawn slot ID
	rts

; -------------------------------------------------------------------------
; Spawn Metal Sonic
; -------------------------------------------------------------------------

SpawnMetalSonic:
	btst	#0,objSpawnFlags.w		; Is spawn slot 0 occupied?
	bne.w	.End				; If so, branch
	btst	#1,objSpawnFlags.w		; Is spawn slot 1 occupied?
	bne.w	.End				; If so, branch
	bset	#0,objSpawnFlags.w		; Occupy both spawn slots
	bset	#1,objSpawnFlags.w
	move.b	#%11,objSpawnID.w

	moveq	#8,d0				; Load art
	jsr	LoadArt

	jsr	Random(pc)			; Get X position and vertical side of screen to spawn from
	move.w	d0,d7
	andi.l	#$7FFF,d0
	divs.w	#$100,d0
	swap	d0
	move.w	d0,d5
	tst.w	d7
	bge.s	.StartFromRight
	move.w	#0,d6
	bra.s	.SpawnObj

.StartFromRight:
	move.w	#192,d6

.SpawnObj:
	bsr.w	FindObjSlot			; Spawn Metal Sonic
	bne.w	.End
	move.w	#$5B8,oTile(a1)			; Set base tile ID
	move.b	objSpawnID.w,oSpawnID(a1)	; Set spawn slot ID
	move.w	d5,oX(a1)			; Set position
	move.w	d6,oY(a1)
	move.w	#$28,oFloatSpeed(a1)		; Set float speed
	move.w	#4,oFloatAmp(a1)		; Set float amplitude
	move.l	#$40000,oXVel(a1)		; Set velocity
	move.l	#$50000,oYVel(a1)
	bset	#3,oFlags(a1)			; Mark as moving down
	move.w	#5,oID(a1)			; Set object ID

	cmpi.w	#128,oX(a1)			; Is Metal Sonic on the left side of the screen?
	blt.s	.CheckYDir			; If so, branch
	bset	#7,oFlags(a1)			; Face left
	neg.l	oXVel(a1)			; Move left

.CheckYDir:
	cmpi.w	#100,oY(a1)			; Is Metal Sonic spawning from the top of the screen?
	blt.s	.End				; If so, branch
	bclr	#3,oFlags(a1)			; Mark as moving up
	neg.l	oYVel(a1)			; Move up

.End:
	move.b	#0,objSpawnID.w			; Reset spawn slot ID
	rts

; -------------------------------------------------------------------------

	; Unknown
	dc.w	32
	dc.w	224

; -------------------------------------------------------------------------
; Spawn Tails
; -------------------------------------------------------------------------

SpawnTails:
	nop
	btst	#0,objSpawnFlags.w		; Is spawn slot 0 occupied?
	bne.w	.End				; If so, branch
	btst	#1,objSpawnFlags.w		; Is spawn slot 1 occupied?
	bne.w	.End				; If so, branch
	bset	#0,objSpawnFlags.w		; Occupy both spawn slots
	bset	#1,objSpawnFlags.w
	move.b	#%11,objSpawnID.w

	moveq	#9,d0				; Load art
	jsr	LoadArt

	jsr	Random(pc)			; Pick horizontal side to spawn from
	move.w	d0,d7
	tst.w	d7
	bge.s	.StartFromLeft
	move.l	#264,d5
	bra.s	.SpawnObj

.StartFromLeft:
	moveq	#-6,d5

.SpawnObj:
	jsr	Random(pc)			; Get Y position
	andi.l	#$7FFF,d0
	divs.w	#160,d0
	swap	d0
	move.w	d0,d6
	addi.w	#32,d6

	bsr.w	FindObjSlot
	bne.w	.End
	move.w	#$5B8,oTile(a1)			; Set base tile ID
	move.b	objSpawnID.w,oSpawnID(a1)	; Set spawn slot ID
	move.w	d5,oX(a1)			; Set position
	move.w	d6,oY(a1)
	move.w	#$24,oFloatSpeed(a1)		; Set float speed
	move.w	#2,oFloatAmp(a1)		; Set float amplitude
	move.l	#$20000,oXVel(a1)		; Set velocity
	move.l	#0,oYVel(a1)
	move.w	#6,oID(a1)			; Set object ID

	tst.w	d7				; Is Tails spawning from the left side of the screen?
	bge.s	.End				; If so, branch
	bset	#7,oFlags(a1)			; Mark as facing left
	neg.l	oXVel(a1)			; Move left
	neg.l	oYVel(a1)

.End:
	move.b	#0,objSpawnID.w			; Reset spawn slot ID
	rts

; -------------------------------------------------------------------------
; Run object routine
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to object slot
;	a1.l - Pointer to routine table
; -------------------------------------------------------------------------

RunObjRoutine:
	move.w	oRoutine(a0),d0			; Run routine
	add.w	d0,d0
	adda.w	(a1,d0.w),a1
	jmp	(a1)

; -------------------------------------------------------------------------
; Delete object
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to object slot
; -------------------------------------------------------------------------

DeleteObject:
	move.b	oSpawnID(a0),d0			; Stop occupying spawn slot
	eor.b	d0,objSpawnFlags.w
	bset	#4,oFlags(a0)			; Mark for deletion
	rts

; -------------------------------------------------------------------------
; Delete object from group
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to object slot
; -------------------------------------------------------------------------

DelObjFromGroup:
	move.w	oID(a0),d0			; Get object ID and clear it
	move.w	#0,oID(a0)

	lea	objects.w,a1			; Object slots
	moveq	#OBJCOUNT-1,d7			; Number of object slots

.Find:
	cmp.w	oID(a1),d0			; Does this object have the same ID?
	beq.s	.Found				; If so, branch
	lea	oSize(a1),a1			; Next object
	dbf	d7,.Find			; Loop until all objects are checked
	
	move.b	oSpawnID(a0),d1			; If this was the last in the group, stop occupying spawn slot
	eor.b	d1,objSpawnFlags.w

.Found:
	bset	#4,oFlags(a0)			; Mark for deletion
	rts

; -------------------------------------------------------------------------
; Check if an object is offscreen
; -------------------------------------------------------------------------
; PARAMETERS:
;	eq/ne - Not offscreen/Offscreen
;	a0.l  - Pointer to object slot
; -------------------------------------------------------------------------

ChkObjOffscreen:
	cmpi.w	#-80,oX(a0)			; Are we past the left side?
	ble.s	.Offscreen			; If so, branch
	cmpi.w	#336,oX(a0)			; Are we past the rigjt side?
	bge.s	.Offscreen			; If so, branch
	cmpi.w	#-5,oY(a0)			; Are we past the top side?
	ble.s	.Offscreen			; If so, branch
	cmpi.w	#224,oY(a0)			; Are we past the bottom side?
	bge.s	.Offscreen			; If so, branch

	moveq	#0,d0				; Not offscreen
	rts

.Offscreen:
	moveq	#1,d0				; Offscreen
	rts

; -------------------------------------------------------------------------
; Find other object by ID
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w  - Object ID
;	a0.l  - Pointer to object slot
; RETURNS:
;	eq/ne - Not found/Found
;	a1.l  - Found pointer to object slot
; -------------------------------------------------------------------------

FindOtherObjByID:
	lea	objects.w,a1			; Object slots
	move.w	#OBJCOUNT-1,d7			; Number of object slots

.Find:
	cmp.w	(a1),d0				; Does this object use this ID?
	bne.s	.NextObject			; If not, branch
	cmpa.w	a0,a1				; Is this object slot ours?
	bne.s	.End				; If not, branch

.NextObject:
	lea	oSize(a1),a1			; Next object
	dbf	d7,.Find			; Loop until all objects are checked
	
	moveq	#0,d0				; Not found

.End:
	rts

; -------------------------------------------------------------------------
; Move floating object
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to object slot
; -------------------------------------------------------------------------

ObjMoveFloat:
	bsr.w	ChkObjOffscreen			; Are we offscreen?
	bne.w	DelObjFromGroup			; If so, delete object

	move.w	oYOffset(a0),d0			; Apply Y offset
	sub.w	d0,oY(a0)

	move.w	oFloatAngle(a0),d3		; Update Y offset
	jsr	GetSine(pc)
	move.w	oFloatAmp(a0),d0
	muls.w	d0,d3
	asr.l	#8,d3
	move.w	d3,oYOffset(a0)
	add.w	d3,oY(a0)

	jsr	Random(pc)			; Increment float angle
	andi.l	#$7FFF,d0
	move.w	oFloatSpeed(a0),d1
	divs.w	d1,d0
	swap	d0
	add.w	d0,oFloatAngle(a0)
	cmpi.w	#$1FF,oFloatAngle(a0)
	blt.s	.GetXVel
	subi.w	#$1FF,oFloatAngle(a0)

.GetXVel:
	move.l	oXVel(a0),d0			; Get X velocity
	tst.b	trackSelFlags.w			; Is track selection active?
	beq.s	.Move				; If not, branch
	asl.l	#3,d0				; If, so, go 8 times as fast

.Move:
	add.l	d0,oX(a0)			; Move X position
	move.l	oYVel(a0),d1			; Move Y position
	add.l	d1,oY(a0)
	rts

; -------------------------------------------------------------------------

	include	"DA Garden/Objects/Flicky/Main.asm"
	include	"DA Garden/Objects/Star/Main.asm"
	include	"DA Garden/Objects/UFO/Main.asm"
	include	"DA Garden/Objects/Eggman/Main.asm"
	include	"DA Garden/Objects/Metal Sonic/Main.asm"
	include	"DA Garden/Objects/Tails/Main.asm"

; -------------------------------------------------------------------------
; Load art
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - Art IDs (each byte is an ID)
; -------------------------------------------------------------------------

LoadArt:
	lea	VDPCTRL,a5			; VDP control port
	moveq	#4-1,d2				; Number of IDs in the queue

.Loop:
	moveq	#0,d1				; Get art ID
	move.b	d0,d1
	beq.s	.NextArt			; If it's blank, branch

	lsl.w	#3,d1				; Load art
	lea	.Art(pc),a0
	move.l	-8(a0,d1.w),(a5)
	movea.l	-4(a0,d1.w),a0
	jsr	NemDec(pc)

.NextArt:
	ror.l	#8,d0				; Next art ID
	dbf	d2,.Loop			; Loop until art is loaded
	rts

; -------------------------------------------------------------------------

.Art:
	VDPCMD	dc.l,$B700,VRAM,WRITE		; Flicky (slot 1)
	dc.l	Art_Flicky
	VDPCMD	dc.l,$BB80,VRAM,WRITE		; Flicky (slot 2)
	dc.l	Art_Flicky
	VDPCMD	dc.l,$B700,VRAM,WRITE		; Star (slot 1)
	dc.l	Art_Star
	VDPCMD	dc.l,$BB80,VRAM,WRITE		; Star (slot 2)
	dc.l	Art_Star
	VDPCMD	dc.l,$B700,VRAM,WRITE		; UFO (slot 1)
	dc.l	Art_UFO
	VDPCMD	dc.l,$BB80,VRAM,WRITE		; UFO (slot 2)
	dc.l	Art_UFO
	VDPCMD	dc.l,$B700,VRAM,WRITE		; Eggman
	dc.l	Art_Eggman
	VDPCMD	dc.l,$B700,VRAM,WRITE		; Metal Sonic
	dc.l	Art_MetalSonic
	VDPCMD	dc.l,$B700,VRAM,WRITE		; Tails
	dc.l	Art_Tails
	VDPCMD	dc.l,$B700,VRAM,WRITE		; "Palmtree Panic" (slot 1)
	dc.l	Art_TrkPPZ
	VDPCMD	dc.l,$B700,VRAM,WRITE		; "Palmtree Panic 'G' mix" (slot 1)
	dc.l	Art_TrkPPZG
	VDPCMD	dc.l,$B700,VRAM,WRITE		; "Palmtree Panic 'B' mix" (slot 1)
	dc.l	Art_TrkPPZB
	VDPCMD	dc.l,$B700,VRAM,WRITE		; "Collision Chaos" (slot 1)
	dc.l	Art_TrkCCZ
	VDPCMD	dc.l,$B700,VRAM,WRITE		; "Collision Chaos 'G' mix" (slot 1)
	dc.l	Art_TrkCCZG
	VDPCMD	dc.l,$B700,VRAM,WRITE		; "Collision Chaos 'B' mix" (slot 1)
	dc.l	Art_TrkCCZB
	VDPCMD	dc.l,$B700,VRAM,WRITE		; "Tidal Tempest" (slot 1)
	dc.l	Art_TrkTTZ
	VDPCMD	dc.l,$B700,VRAM,WRITE		; "Tidal Tempest 'G' mix" (slot 1)
	dc.l	Art_TrkTTZG
	VDPCMD	dc.l,$B700,VRAM,WRITE		; "Tidal Tempest 'B' mix" (slot 1)
	dc.l	Art_TrkTTZB
	VDPCMD	dc.l,$B700,VRAM,WRITE		; "Quartz Quadrant" (slot 1)
	dc.l	Art_TrkQQZ
	VDPCMD	dc.l,$B700,VRAM,WRITE		; "Quartz Quadrant 'G' mix" (slot 1)
	dc.l	Art_TrkQQZG
	VDPCMD	dc.l,$B700,VRAM,WRITE		; "Quartz Quadrant 'B' mix" (slot 1)
	dc.l	Art_TrkQQZB
	VDPCMD	dc.l,$B700,VRAM,WRITE		; "Wacky Workbench" (slot 1)
	dc.l	Art_TrkWWZ
	VDPCMD	dc.l,$B700,VRAM,WRITE		; "Wacky Workbench 'G' mix" (slot 1)
	dc.l	Art_TrkWWZG
	VDPCMD	dc.l,$B700,VRAM,WRITE		; "Wacky Workbench 'B' mix" (slot 1)
	dc.l	Art_TrkWWZB
	VDPCMD	dc.l,$B700,VRAM,WRITE		; "Stardust Speedway" (slot 1)
	dc.l	Art_TrkSSZ
	VDPCMD	dc.l,$B700,VRAM,WRITE		; "Stardust Speedway 'G' mix" (slot 1)
	dc.l	Art_TrkSSZG
	VDPCMD	dc.l,$B700,VRAM,WRITE		; "Stardust Speedway 'B' mix" (slot 1)
	dc.l	Art_TrkSSZB
	VDPCMD	dc.l,$B700,VRAM,WRITE		; "Metallic Madness" (slot 1)
	dc.l	Art_TrkMMZ
	VDPCMD	dc.l,$B700,VRAM,WRITE		; "Metallic Madness 'G' mix" (slot 1)
	dc.l	Art_TrkMMZG
	VDPCMD	dc.l,$B700,VRAM,WRITE		; "Metallic Madness 'B' mix" (slot 1)
	dc.l	Art_TrkMMZB
	VDPCMD	dc.l,$B700,VRAM,WRITE		; "Final Fever" (slot 1)
	dc.l	Art_TrkFinal
	VDPCMD	dc.l,$B700,VRAM,WRITE		; "Little Planet" (slot 1)
	dc.l	Art_TrkLittlePlanet
	VDPCMD	dc.l,$B700,VRAM,WRITE		; "Game Over" (slot 1)
	dc.l	Art_TrkGameOver
	VDPCMD	dc.l,$B700,VRAM,WRITE		; "Zone Clear" (slot 1)
	dc.l	Art_TrkZoneClear
	VDPCMD	dc.l,$B700,VRAM,WRITE		; "Boss!!" (slot 1)
	dc.l	Art_TrkBoss
	VDPCMD	dc.l,$B700,VRAM,WRITE		; "Invincible!!" (slot 1)
	dc.l	Art_TrkInvincible
	VDPCMD	dc.l,$B700,VRAM,WRITE		; "Speed Up!!" (slot 1)
	dc.l	Art_TrkSpeedUp
	VDPCMD	dc.l,$B700,VRAM,WRITE		; "Title" (slot 1)
	dc.l	Art_TrkTitle
	VDPCMD	dc.l,$B700,VRAM,WRITE		; "Special Stage" (slot 1)
	dc.l	Art_TrkSpecStg
	VDPCMD	dc.l,$B700,VRAM,WRITE		; "Opening" (slot 1)
	dc.l	Art_TrkOpening
	VDPCMD	dc.l,$B700,VRAM,WRITE		; "Ending" (slot 1)
	dc.l	Art_TrkEnding
	VDPCMD	dc.l,$BB80,VRAM,WRITE		; "Palmtree Panic" (slot 2)
	dc.l	Art_TrkPPZ
	VDPCMD	dc.l,$BB80,VRAM,WRITE		; "Palmtree Panic 'G' mix" (slot 2)
	dc.l	Art_TrkPPZG
	VDPCMD	dc.l,$BB80,VRAM,WRITE		; "Palmtree Panic 'B' mix" (slot 2)
	dc.l	Art_TrkPPZB
	VDPCMD	dc.l,$BB80,VRAM,WRITE		; "Collision Chaos" (slot 2)
	dc.l	Art_TrkCCZ
	VDPCMD	dc.l,$BB80,VRAM,WRITE		; "Collision Chaos 'G' mix" (slot 2)
	dc.l	Art_TrkCCZG
	VDPCMD	dc.l,$BB80,VRAM,WRITE		; "Collision Chaos 'B' mix" (slot 2)
	dc.l	Art_TrkCCZB
	VDPCMD	dc.l,$BB80,VRAM,WRITE		; "Tidal Tempest" (slot 2)
	dc.l	Art_TrkTTZ
	VDPCMD	dc.l,$BB80,VRAM,WRITE		; "Tidal Tempest 'G' mix" (slot 2)
	dc.l	Art_TrkTTZG
	VDPCMD	dc.l,$BB80,VRAM,WRITE		; "Tidal Tempest 'B' mix" (slot 2)
	dc.l	Art_TrkTTZB
	VDPCMD	dc.l,$BB80,VRAM,WRITE		; "Quartz Quadrant" (slot 2)
	dc.l	Art_TrkQQZ
	VDPCMD	dc.l,$BB80,VRAM,WRITE		; "Quartz Quadrant 'G' mix" (slot 2)
	dc.l	Art_TrkQQZG
	VDPCMD	dc.l,$BB80,VRAM,WRITE		; "Quartz Quadrant 'B' mix" (slot 2)
	dc.l	Art_TrkQQZB
	VDPCMD	dc.l,$BB80,VRAM,WRITE		; "Wacky Workbench" (slot 2)
	dc.l	Art_TrkWWZ
	VDPCMD	dc.l,$BB80,VRAM,WRITE		; "Wacky Workbench 'G' mix" (slot 2)
	dc.l	Art_TrkWWZG
	VDPCMD	dc.l,$BB80,VRAM,WRITE		; "Wacky Workbench 'B' mix" (slot 2)
	dc.l	Art_TrkWWZB
	VDPCMD	dc.l,$BB80,VRAM,WRITE		; "Stardust Speedway" (slot 2)
	dc.l	Art_TrkSSZ
	VDPCMD	dc.l,$BB80,VRAM,WRITE		; "Stardust Speedway 'G' mix" (slot 2)
	dc.l	Art_TrkSSZG
	VDPCMD	dc.l,$BB80,VRAM,WRITE		; "Stardust Speedway 'B' mix" (slot 2)
	dc.l	Art_TrkSSZB
	VDPCMD	dc.l,$BB80,VRAM,WRITE		; "Metallic Madness" (slot 2)
	dc.l	Art_TrkMMZ
	VDPCMD	dc.l,$BB80,VRAM,WRITE		; "Metallic Madness 'G' mix" (slot 2)
	dc.l	Art_TrkMMZG
	VDPCMD	dc.l,$BB80,VRAM,WRITE		; "Metallic Madness 'B' mix" (slot 2)
	dc.l	Art_TrkMMZB
	VDPCMD	dc.l,$BB80,VRAM,WRITE		; "Final Fever" (slot 2)
	dc.l	Art_TrkFinal
	VDPCMD	dc.l,$BB80,VRAM,WRITE		; "Little Planet" (slot 2)
	dc.l	Art_TrkLittlePlanet
	VDPCMD	dc.l,$BB80,VRAM,WRITE		; "Game Over" (slot 2)
	dc.l	Art_TrkGameOver
	VDPCMD	dc.l,$BB80,VRAM,WRITE		; "Zone Clear" (slot 2)
	dc.l	Art_TrkZoneClear
	VDPCMD	dc.l,$BB80,VRAM,WRITE		; "Boss!!" (slot 2)
	dc.l	Art_TrkBoss
	VDPCMD	dc.l,$BB80,VRAM,WRITE		; "Invincible!!" (slot 2)
	dc.l	Art_TrkInvincible
	VDPCMD	dc.l,$BB80,VRAM,WRITE		; "Speed Up!!" (slot 2)
	dc.l	Art_TrkSpeedUp
	VDPCMD	dc.l,$BB80,VRAM,WRITE		; "Title" (slot 2)
	dc.l	Art_TrkTitle
	VDPCMD	dc.l,$BB80,VRAM,WRITE		; "Special Stage" (slot 2)
	dc.l	Art_TrkSpecStg
	VDPCMD	dc.l,$BB80,VRAM,WRITE		; "Opening" (slot 2)
	dc.l	Art_TrkOpening
	VDPCMD	dc.l,$BB80,VRAM,WRITE		; "Ending" (slot 2)
	dc.l	Art_TrkEnding

; -------------------------------------------------------------------------
; Decompress Nemesis art into VRAM (Note: VDP write command must be
; set beforehand)
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Nemesis art pointer
; -------------------------------------------------------------------------

NemDec:
	movem.l	d0-a1/a3-a5,-(sp)
	lea	NemPCD_WriteRowToVDP,a3		; Write all data to the same location
	lea	VDPDATA,a4			; VDP data port
	bra.s	NemDecMain

; -------------------------------------------------------------------------
; Decompress Nemesis data into RAM
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Nemesis data pointer
;	a4.l - Destination buffer pointer
; -------------------------------------------------------------------------

NemDecToRAM:
	movem.l	d0-a1/a3-a5,-(sp)
	lea	NemPCD_WriteRowToRAM,a3		; Advance to the next location after each write

; -------------------------------------------------------------------------

NemDecMain:
	lea	nemBuffer.w,a1			; Prepare decompression buffer
	move.w	(a0)+,d2			; Get number of patterns
	lsl.w	#1,d2
	bcc.s	.NormalMode			; Branch if not in XOR mode
	adda.w	#NemPCD_WriteRowToVDP_XOR-NemPCD_WriteRowToVDP,a3

.NormalMode:
	lsl.w	#2,d2				; Get number of 8-pixel rows in the uncompressed data
	movea.w	d2,a5				; and store it in a5
	moveq	#8,d3				; 8 pixels in a pattern row
	moveq	#0,d2
	moveq	#0,d4
	jsr	NemDec_BuildCodeTable(pc)
	move.b	(a0)+,d5			; Get first word of compressed data
	asl.w	#8,d5
	move.b	(a0)+,d5
	move.w	#16,d6				; Set initial shift value
	bsr.s	NemDec_ProcessCompressedData
	nop
	nop
	nop
	nop
	movem.l	(sp)+,d0-a1/a3-a5
	rts

; -------------------------------------------------------------------------

NemDec_ProcessCompressedData:
	move.w	d6,d7
	subq.w	#8,d7				; Get shift value
	move.w	d5,d1
	lsr.w	d7,d1				; Shift so that the high bit of the code is in bit 7
	cmpi.b	#%11111100,d1			; Are the high 6 bits set?
	bcc.s	NemPCD_InlineData		; If they are, it signifies inline data
	andi.w	#$FF,d1
	add.w	d1,d1
	move.b	(a1,d1.w),d0			; Get the length of the code in bits
	ext.w	d0
	sub.w	d0,d6				; Subtract from shift value so that the next code is read next time around
	cmpi.w	#9,d6				; Does a new byte need to be read?
	bcc.s	.GotEnoughBits			; If not, branch
	addq.w	#8,d6
	asl.w	#8,d5
	move.b	(a0)+,d5			; Read next byte

.GotEnoughBits:
	move.b	1(a1,d1.w),d1
	move.w	d1,d0
	andi.w	#$F,d1				; Get palette index for pixel
	andi.w	#$F0,d0

NemDec_GetRunLength:
	lsr.w	#4,d0				; Get repeat count

NemDec_RunLoop:
	lsl.l	#4,d4				; Shift up by a nibble
	or.b	d1,d4				; Write pixel
	subq.w	#1,d3				; Has an entire 8-pixel row been written?
	bne.s	NemPCD_WritePixel_Loop		; If not, loop
	jmp	(a3)				; Otherwise, write the row to its destination

; -------------------------------------------------------------------------

NemPCD_NewRow:
	moveq	#0,d4				; Reset row
	moveq	#8,d3				; Reset nibble counter

NemPCD_WritePixel_Loop:
	dbf	d0,NemDec_RunLoop
	bra.s	NemDec_ProcessCompressedData

; -------------------------------------------------------------------------

NemPCD_InlineData:
	subq.w	#6,d6				; 6 bits needed to signal inline data
	cmpi.w	#9,d6
	bcc.s	.GotEnoughBits
	addq.w	#8,d6
	asl.w	#8,d5
	move.b	(a0)+,d5

.GotEnoughBits:
	subq.w	#7,d6				; And 7 bits needed for the inline data itself
	move.w	d5,d1
	lsr.w	d6,d1				; Shift so that the low bit of the code is in bit 0
	move.w	d1,d0
	andi.w	#$F,d1				; Get palette index for pixel
	andi.w	#$70,d0				; High nibble is repeat count for pixel
	cmpi.w	#9,d6
	bcc.s	NemDec_GetRunLength
	addq.w	#8,d6
	asl.w	#8,d5
	move.b	(a0)+,d5
	bra.s	NemDec_GetRunLength

; -------------------------------------------------------------------------

NemPCD_WriteRowToVDP:
	move.l	d4,(a4)				; Write 8-pixel row
	subq.w	#1,a5
	move.w	a5,d4				; Have all the 8-pixel rows been written?
	bne.s	NemPCD_NewRow			; If not, branch
	rts

; -------------------------------------------------------------------------

NemPCD_WriteRowToVDP_XOR:
	eor.l	d4,d2				; XOR the previous row with the current row
	move.l	d2,(a4)				; and store it
	subq.w	#1,a5
	move.w	a5,d4				; Have all the 8-pixel rows been written?
	bne.s	NemPCD_NewRow			; If not, branch
	rts

; -------------------------------------------------------------------------

NemPCD_WriteRowToRAM:
	move.l	d4,(a4)+			; Write 8-pixel row
	subq.w	#1,a5
	move.w	a5,d4				; Have all the 8-pixel rows been written?
	bne.s	NemPCD_NewRow			; If not, branch
	rts

; -------------------------------------------------------------------------

NemPCD_WriteRowToRAM_XOR:
	eor.l	d4,d2				; XOR the previous row with the current row
	move.l	d2,(a4)+			; and store it
	subq.w	#1,a5
	move.w	a5,d4				; Have all the 8-pixel rows been written?
	bne.s	NemPCD_NewRow			; If not, branch
	rts

; -------------------------------------------------------------------------

NemDec_BuildCodeTable:
	move.b	(a0)+,d0			; Read first byte

NemBCT_ChkEnd:
	cmpi.b	#$FF,d0				; Has the end of the code table description been reached?
	bne.s	NemBCT_NewPALIndex		; If not, branch
	rts

NemBCT_NewPALIndex:
	move.w	d0,d7

NemBCT_Loop:
	move.b	(a0)+,d0			; Read next byte
	cmpi.b	#$80,d0				; Sign bit signifies a new palette index
	bcc.s	NemBCT_ChkEnd

	move.b	d0,d1
	andi.w	#$F,d7				; Get palette index
	andi.w	#$70,d1				; Get repeat count for palette index
	or.w	d1,d7				; Combine the 2
	andi.w	#$F,d0				; Get the length of the code in bits
	move.b	d0,d1
	lsl.w	#8,d1
	or.w	d1,d7				; Combine with palette index and repeat count to form code table entry
	moveq	#8,d1
	sub.w	d0,d1				; Is the code 8 bits long?
	bne.s	NemBCT_ShortCode		; If not, a bit of extra processing is needed
	move.b	(a0)+,d0			; Get code
	add.w	d0,d0				; Each code gets a word sized entry in the table
	move.w	d7,(a1,d0.w)			; Store the entry for the code

	bra.s	NemBCT_Loop			; Loop

NemBCT_ShortCode:
	move.b	(a0)+,d0			; Get code
	lsl.w	d1,d0				; Get index into code table
	add.w	d0,d0				; Shift so that the high bit is in bit 7
	moveq	#1,d5
	lsl.w	d1,d5
	subq.w	#1,d5				; d5 = 2^d1 - 1

NemBCT_ShortCode_Loop:
	move.w	d7,(a1,d0.w)			; Store entry
	addq.w	#2,d0				; Increment index
	dbf	d5,NemBCT_ShortCode_Loop	; Repeat for required number of entries

	bra.s	NemBCT_Loop

; -------------------------------------------------------------------------
; Handle track selection
; -------------------------------------------------------------------------

TrackSelection:
	lea	trackSelData.w,a2		; Track selection data
	
	moveq	#0,d0				; Run routine
	move.w	trkSelRout(a2),d0
	add.w	d0,d0
	move.w	.Index(pc,d0.w),d0
	jmp	.Index(pc,d0.w)

; -------------------------------------------------------------------------

.Index:
	dc.w	TrkSel_CheckPlay-.Index
	dc.w	TrkSel_SpawnTrkTitle-.Index
	dc.w	TrkSel_Wait-.Index

; -------------------------------------------------------------------------

TrkSel_CheckPlay:
	btst	#5,ctrlHold			; Is C being held?
	bne.s	.CHeld				; If so, branch
	btst	#5,buttonFlags.w		; If not, was it being held before?
	beq.s	.CheckB				; If not, branch
	btst	#0,trackSelFlags.w		; Is track selection active?
	beq.s	.ReleaseC			; If not, branch
	btst	#2,trackSelFlags.w		; Is the title track spawning?
	bne.s	.CheckB				; If so, branch
	bclr	#5,buttonFlags.w		; Mark as released
	bra.s	.DoPlayTrack			; Play track

.CHeld:
	bset	#5,buttonFlags.w		; Mark as held
	bra.s	.CheckB

.ReleaseC:
	bclr	#5,buttonFlags.w		; Mark as released

.CheckB:
	btst	#4,ctrlHold			; Is B being held?
	bne.s	.BHeld				; If so, branch
	btst	#4,buttonFlags.w		; If not, was it being held before?
	beq.s	.CheckC				; If not, branch
	btst	#0,trackSelFlags.w		; Is track selection active?
	beq.s	.ReleaseB			; If not, branch
	btst	#2,trackSelFlags.w		; Is the title track spawning?
	bne.s	.CheckC				; If so, branch
	bclr	#4,buttonFlags.w		; Mark as released
	bra.s	.DoPlayTrack			; Play track

.BHeld:
	bset	#4,buttonFlags.w		; Mark as held
	bra.s	.CheckC

.ReleaseB:
	bclr	#4,buttonFlags.w		; Mark as released

.CheckC:
	btst	#6,ctrlHold			; Is A being held?
	bne.s	.AHeld				; If so, branch
	btst	#6,buttonFlags.w		; If not, was it being held before?
	beq.s	.CheckTextSpawn			; If not, branch
	btst	#0,trackSelFlags.w		; Is track selection active?
	beq.s	.EnableSel			; If not, branch
	btst	#2,trackSelFlags.w		; Is the title track spawning?
	bne.s	.CheckTextSpawn			; If so, branch
	bclr	#6,buttonFlags.w		; Mark as released

.DoPlayTrack:
	bsr.w	.PlayTrack			; Play track
	bra.s	.End

.EnableSel:
	bset	#0,trackSelFlags.w		; Make track selection active
	bset	#2,trackSelFlags.w		; Mark title track as spawning
	bclr	#6,buttonFlags.w		; Mark as released
	bra.s	.CheckTextSpawn

.AHeld:
	bset	#6,buttonFlags.w		; Mark as held
	bra.s	.End
	
.CheckTextSpawn:
	btst	#2,trackSelFlags.w		; Is the title track set to spawn?
	beq.s	.End				; If not, branch
	bsr.w	CheckObjLoaded			; Are there objects currently on screen?
	bne.s	.End				; If so, branch
	bset	#4,GAMAINFLAG			; Mark title track as spawned
	bclr	#2,trackSelFlags.w
	move.w	#1,trkSelRout(a2)		; Set to title track spawn routine

.End:
	rts

; -------------------------------------------------------------------------

.PlayTrack:
	move.b	#0,objSpawnFlags.w		; Reset object spawn flags
	
	move.w	trkSelID(a2),d0			; Set track ID
	move.w	d0,GACOMCMD8
	
	add.w	d0,d0				; Set track time zone
	add.w	d0,d0
	lea	TrackInfo,a1
	move.w	(a1,d0.w),d1
	cmpi.w	#3,d1
	beq.s	.SetTimeZone
	move.w	d1,trackTimeZone.w

.SetTimeZone:
	move.w	d1,GACOMCMDA
	
	bclr	#4,GAMAINFLAG			; Mark track selection as inactive on the Sub CPU side
	bset	#5,GAMAINFLAG			; Play new track
	rts

; -------------------------------------------------------------------------

TrkSel_SpawnTrkTitle:
	bsr.w	FindObjSlot			; Get title track object slot
	bne.w	.End				; If there's no slots available, branch
	move.w	a1,trkSelTitle(a2)		; Set object slot pointer
	bset	#1,trackSelFlags.w		; Mark title track as spawning
	move.w	#2,trkSelRout(a2)		; Set to wait routine

.End:
	rts

; -------------------------------------------------------------------------

TrkSel_Wait:
	rts

; -------------------------------------------------------------------------
; Check if we should spawn the track title
; -------------------------------------------------------------------------

ChkTrkTitleSpawn:
	btst	#1,trackSelFlags.w		; Is the title track spawning?
	beq.s	.End				; If not, branch
	bclr	#1,trackSelFlags.w		; Clear flag
	
	lea	trackSelData.w,a2		; Get object slot
	movea.w	trkSelTitle(a2),a1
	move.w	#7,oID(a1)			; Set object ID
	
	btst	#0,objSpawnFlags.w		; Is the spawn slot 0 occupied?
	bne.s	.Second				; If so, branch
	bset	#0,objSpawnFlags.w		; Occupy spawn slot 0
	move.w	#$5B8,oTile(a1)			; Set base tile ID
	move.b	#1,oSpawnID(a1)			; Set spawn slot ID
	move.w	#$A,d0				; Load art
	add.w	trkSelID(a2),d0
	jsr	LoadArt(pc)
	bra.s	.End

.Second:
	bset	#1,objSpawnFlags.w		; Occupy spawn slot 1
	move.w	#$5DC,oTile(a1)			; Set base tile ID
	move.b	#2,oSpawnID(a1)			; Set spawn slot ID
	move.w	#$A+TRACKCNT,d0			; Load art
	add.w	trkSelID(a2),d0
	jsr	LoadArt(pc)

.End:
	rts

; -------------------------------------------------------------------------

	include	"DA Garden/Objects/Track Title/Main.asm"

; -------------------------------------------------------------------------
; Data
; -------------------------------------------------------------------------

	include	"DA Garden/Data/Palette.asm"
	
	include	"DA Garden/Objects/Flicky/Data/Mappings.asm"
	even
	
MapSpr_Star:
	include	"DA Garden/Objects/Star/Data/Mappings.asm"
	even

	include	"DA Garden/Objects/UFO/Data/Mappings.asm"
	even
	
MapSpr_Eggman:
	include	"DA Garden/Objects/Eggman/Data/Mappings (Normal).asm"
	even
	
MapSpr_EggmanTurn:
	include	"DA Garden/Objects/Eggman/Data/Mappings (Head Turn).asm"
	even

	include	"DA Garden/Objects/Metal Sonic/Data/Mappings.asm"
	even
	
MapSpr_Tails:
	include	"DA Garden/Objects/Tails/Data/Mappings (Straight).asm"
	even
	
MapSpr_TailsDown:
	include	"DA Garden/Objects/Tails/Data/Mappings (Down).asm"
	even
	
MapSpr_TailsUp:
	include	"DA Garden/Objects/Tails/Data/Mappings (Up).asm"
	even

	include	"DA Garden/Track Info.asm"

MapSpr_TrackTitle:
	include	"DA Garden/Objects/Track Title/Data/Mappings.asm"
	
	include	"DA Garden/Data/Volcano Animation.asm"
	
Art_DAGardenBg:
	incbin	"DA Garden/Data/Art (Background).nem"
	even
	
Map_DAGardenBg:
	incbin	"DA Garden/Data/Background Mappings.kos"
	even
	
Art_Flicky:
	incbin	"DA Garden/Objects/Flicky/Data/Art.nem"
	even
	
Art_Star:
	incbin	"DA Garden/Objects/Star/Data/Art.nem"
	even
	
Art_Eggman:
	incbin	"DA Garden/Objects/Eggman/Data/Art.nem"
	even
	
Art_UFO:
	incbin	"DA Garden/Objects/UFO/Data/Art.nem"
	even
	
Art_MetalSonic:
	incbin	"DA Garden/Objects/Metal Sonic/Data/Art.nem"
	even
	
Art_Tails:
	incbin	"DA Garden/Objects/Tails/Data/Art.nem"
	even

; -------------------------------------------------------------------------
