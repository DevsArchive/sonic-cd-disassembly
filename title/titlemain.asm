; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Title screen Main CPU program
; -------------------------------------------------------------------------

	include	"_inc/common.i"
	include	"_inc/maincpu.i"
	include	"_inc/mainvars.i"
	include	"_inc/sound.i"
	include	"_inc/mmd.i"
	include	"title/titlecommon.i"

; -------------------------------------------------------------------------
; Object variables structure
; -------------------------------------------------------------------------

	rsreset
oAddr		rs.w	1			; Address
oActive		rs.b	1			; Active flag
oFlags		rs.b	1			; Flags
oTile		rs.w	1			; Base sprite tile
oMap		rs.l	1			; Mappings
oMapFrame	rs.b	1			; Mappings frame
		rs.b	1
oX		rs.l	1			; X position
oY		rs.l	1			; Y position
oVars		rs.b	$40-__rs
oSize		rs.b	0			; Size of structure

; -------------------------------------------------------------------------
; Variables
; -------------------------------------------------------------------------

	rsset	WORKRAM+$FF00A000
VARSSTART	rs.b	0			; Start of variables
cloudsArt	rs.b	IMGLENGTH		; Clouds art buffer
hscroll		rs.b	$380			; Horizontal scroll buffer
		rs.b	$80
sprites		rs.b	80*8			; Sprite buffer
scrollBuf	rs.b	$100			; Scroll buffer
		rs.b	$B80

objects		rs.b	0			; Object pool
object0		rs.b	oSize			; Object 0
object1		rs.b	oSize			; Object 1
object2		rs.b	oSize			; Object 2
object3		rs.b	oSize			; Object 3
object4		rs.b	oSize			; Object 4
object5		rs.b	oSize			; Object 5
object6		rs.b	oSize			; Object 6
object7		rs.b	oSize			; Object 7
	if REGION<>JAPAN
object8		rs.b	oSize			; Object 8
object9		rs.b	oSize			; Object 9
	endif
objectsEnd	rs.b	0			; End of object pool
OBJCOUNT	EQU	(objectsEnd-objects)/oSize

	if REGION=JAPAN
		rs.b	$1200
	else
		rs.b	$1180
	endif

nemBuffer	rs.b	$200			; Nemesis decompression buffer
palette		rs.b	$80			; Palette buffer
fadePalette	rs.b	$80			; Fade palette buffer
		rs.b	1
unkPalFadeFlag	rs.b	1			; Unknown palette fade flag
palFadeInfo	rs.b	0			; Palette fade info
palFadeStart	rs.b	1			; Palette fade start
palFadeLen	rs.b	1			; Palette fade length
titleMode	rs.b	1			; Title screen mode
		rs.b	5
unkObjYSpeed	rs.w	1			; Unknown global object Y speed
palCycleFrame	rs.b	1			; Palette cycle frame
palCycleDelay	rs.b	1			; Palette cycle delay
exitFlag	rs.b	1			; Exit flag
menuSel		rs.b	1			; Menu selection
menuOptions	rs.b	8			; Available menu options
p2CtrlData	rs.b	0			; Player 2 controller data
p2CtrlHold	rs.b	1			; Player 2 controller held buttons data
p2CtrlTap	rs.b	1			; Player 2 controller tapped buttons data
p1CtrlData	rs.b	0			; Player 1 controller data
p1CtrlHold	rs.b	1			; Player 1 controller held buttons data
p1CtrlTap	rs.b	1			; Player 1 controller tapped buttons data
cloudsCtrlFlag	rs.b	1			; Clouds control flag
		RSEVEN
fmSndQueue	rs.b	1			; FM sound queue
		RSEVEN
subWaitTime	rs.l	1			; Sub CPU wait time
subFailCount	rs.b	1			; Sub CPU fail count
		RSEVEN
enableDisplay	rs.b	1			; Enable display flag
		rs.b	$19
vintRoutine	rs.w	1			; V-INT routine ID
timer		rs.w	1			; Timer
vintCounter	rs.w	1			; V-INT counter
savedSR		rs.w	1			; Saved status register
spriteCount	rs.b	1			; Sprite count
		RSEVEN
curSpriteSlot	rs.l	1			; Current sprite slot
		rs.b	$B2
VARSLEN		EQU	__rs-VARSSTART		; Size of variables area
lagCounter	rs.l	1			; Lag counter

subP2CtrlData	EQU	GACOMCMDE		; Sub CPU player 2 controller data
subP2CtrlHold	EQU	subP2CtrlData		; Sub CPU player 2 controller held buttons data
subP2CtrlTap	EQU	subP2CtrlData+1		; Sub CPU player 2 controller tapped buttons data

; -------------------------------------------------------------------------
; MMD header
; -------------------------------------------------------------------------

	MMD	MMDSUBM, &
		WORKRAMFILE, $8000, &
		Start, 0, 0

; -------------------------------------------------------------------------
; Program start
; -------------------------------------------------------------------------

Start:
	move.w	#$8134,ipxVDPReg1		; Disable display
	move.w	ipxVDPReg1,VDPCTRL
	
	move.l	#VInterrupt,_LEVEL6+2.w		; Set V-INT address
	move.l	#-1,lagCounter.w		; Disable lag counter

	moveq	#0,d0				; Clear communication registers
	move.l	d0,GACOMCMD0
	move.l	d0,GACOMCMD4
	move.l	d0,GACOMCMD8
	move.l	d0,GACOMCMDC
	move.b	d0,GAMAINFLAG
	
	move.b	d0,enableDisplay.w		; Clear display enable flag
	move.l	d0,subWaitTime.w		; Reset Sub CPU wait time
	move.b	d0,subFailCount.w		; Reset Sub CPU fail count
	
	lea	VARSSTART.w,a0			; Clear variables
	move.w	#VARSLEN/4-1,d7

.ClearVars:
	clr.l	(a0)+
	dbf	d7,.ClearVars
	
	bsr.w	SyncWithSubCPU1			; Wait for Sub CPU to need Word RAM access
	bsr.w	GiveWordRAMAccess		; Give Sub CPU Word RAM Access
	bsr.w	SyncWithSubCPU2			; Wait for Sub CPU to finish initializing
	
	bsr.w	InitMD				; Initialize Mega Drive hardware
	bsr.w	ClearSprites			; Clear sprites
	bsr.w	ClearObjects			; Clear objects
	bsr.w	LoadTilemaps			; Load tile maps
	
	VDPCMD	move.l,$D800,VRAM,WRITE,VDPCTRL	; Load press start text art
	lea	Art_PressStartText(pc),a0
	bsr.w	NemDec
	VDPCMD	move.l,$DC00,VRAM,WRITE,VDPCTRL	; Load menu arrow art
	lea	Art_MenuArrow(pc),a0
	bsr.w	NemDec
	if REGION=USA				; Load copyright/TM art
		VDPCMD	move.l,$DE00,VRAM,WRITE,VDPCTRL
		lea	Art_CopyrightTM(pc),a0
		bsr.w	NemDec
		VDPCMD	move.l,$DFC0,VRAM,WRITE,VDPCTRL
		lea	Art_TM(pc),a0
		bsr.w	NemDec
	else
		VDPCMD	move.l,$DE00,VRAM,WRITE,VDPCTRL
		lea	Art_Copyright(pc),a0
		bsr.w	NemDec
		VDPCMD	move.l,$DF20,VRAM,WRITE,VDPCTRL
		lea	Art_TM(pc),a0
		bsr.w	NemDec
	endif
	VDPCMD	move.l,$F000,VRAM,WRITE,VDPCTRL	; Load banner art
	lea	Art_Banner(pc),a0
	bsr.w	NemDec
	VDPCMD	move.l,$6D00,VRAM,WRITE,VDPCTRL	; Load Sonic art
	lea	Art_Sonic(pc),a0
	bsr.w	NemDec

	lea	ObjSonic(pc),a2			; Spawn Sonic
	bsr.w	SpawnObject
	
	VDPCMD	move.l,$BC20,VRAM,WRITE,VDPCTRL	; Load solid tiles
	lea	Art_SolidColor(pc),a0
	bsr.w	NemDec
	
	bsr.w	LoadCloudsMap			; Load clouds map
	bsr.w	VSync				; VSync

	move.b	#1,enableDisplay.w		; Enable display
	move.w	#4,vintRoutine.w		; VSync
	bsr.w	VSync

	if REGION=USA
		move.w	#48-1,d7		; Delay 48 frames

.Delay:
		bsr.w	VSync
		dbf	d7,.Delay
	endif

	move.l	#0,lagCounter.w			; Enable and reset lag counter
	jsr	RunObjects(pc)			; Run objects
	move.w	#5,vintRoutine.w		; VSync
	bsr.w	VSync

	lea	Pal_Title+($30*2),a1		; Fade in Sonic palette
	lea	fadePalette+($30*2).w,a2
	movem.l	(a1)+,d0-d7
	movem.l	d0-d7,(a2)
	move.w	#($30<<9)|($10-1),palFadeInfo.w
	bsr.w	FadeFromBlack

.WaitSonicTurn:
	move.b	#1,titleMode.w			; Set to "Sonic turning" mode
	
	jsr	ClearSprites(pc)		; Clear sprites
	jsr	RunObjects(pc)			; Run objects

	btst	#7,titleMode.w			; Has Sonic turned around?
	bne.s	.FlashWhite			; If so, branch
	move.w	#5,vintRoutine.w		; VSync
	bsr.w	VSync
	bra.w	.WaitSonicTurn			; Loop

.FlashWhite:
	bclr	#7,titleMode.w			; Clear Sonic turned flag

	VDPCMD	move.l,$6D80,VRAM,WRITE,VDPCTRL	; Load emblem art
	lea	Art_Emblem(pc),a0
	bsr.w	NemDec

	lea	Pal_Title,a1			; Flash white and fade in title screen paltte
	lea	fadePalette.w,a2
	bsr.w	Copy128Bytes
	move.w	#($00<<9)|($30-1),palFadeInfo.w
	bsr.w	FadeFromWhite2

	lea	ObjPlanet(pc),a2		; Spawn background planet
	bsr.w	SpawnObject
	lea	ObjMenu,a2			; Spawn menu
	bsr.w	SpawnObject
	lea	ObjCopyright(pc),a2		; Spawn copyright
	bsr.w	SpawnObject
	if REGION<>JAPAN
		lea	ObjTM(pc),a2		; Spawn TM symbol
		bsr.w	SpawnObject
	endif

; -------------------------------------------------------------------------

MainLoop:
	move.b	#2,titleMode.w			; Set to "menu" mode
	
	; Display clouds buffer 2, render to buffer 1
	bsr.w	RenderClouds			; Start rendering clouds
	jsr	ClearSprites(pc)		; Clear sprites
	jsr	RunObjects(pc)			; Run objects
	bsr.w	PaletteCycle			; Run palette cycle
	bsr.w	ScrollBgBuf2			; Scroll background (show clouds buffer 2)
	move.w	#0,vintRoutine.w		; VSync (copy 1st half of last rendered clouds art to buffer 1)
	bsr.w	VSync

	jsr	ClearSprites(pc)		; Clear sprites
	jsr	RunObjects(pc)			; Run objects
	move.w	#1,vintRoutine.w		; VSync (copy 2nd half of last rendered clouds art to buffer 1)
	bsr.w	VSync

	bsr.w	WaitWordRAMAccess		; Wait for Word RAM access
	bsr.w	GetCloudsArt			; Get rendered clouds art
	bsr.w	GiveWordRAMAccess		; Give back Word RAM access

	tst.b	exitFlag.w			; Are we exiting the title screen?
	bne.s	.Exit				; If so, branch
	
	; Display clouds buffer 1, render to buffer 2
	jsr	ClearSprites(pc)		; Clear sprites
	jsr	RunObjects(pc)			; Run objects
	bsr.w	PaletteCycle			; Run palette cycle
	bsr.w	RenderClouds			; Start rendering clouds
	bsr.w	ScrollBgBuf1			; Scroll background (show clouds buffer 1)
	move.w	#2,vintRoutine.w		; VSync (copy 1st half of last rendered clouds art to buffer 2)
	bsr.w	VSync

	jsr	ClearSprites(pc)		; Clear sprites
	jsr	RunObjects(pc)			; Run objects
	move.w	#3,vintRoutine.w		; VSync (copy 2nd half of last rendered clouds art to buffer 12)
	bsr.w	VSync

	bsr.w	WaitWordRAMAccess		; Wait for Word RAM access
	bsr.w	GetCloudsArt			; Get rendered clouds art
	bsr.w	GiveWordRAMAccess		; Give back Word RAM access

	tst.b	exitFlag.w			; Are we exiting the title screen?
	bne.s	.Exit				; If so, branch
	bra.w	MainLoop			; Loop

.Exit:
	if REGION=USA
		cmpi.b	#4,subFailCount.w	; Is the Sub CPU deemed unreliable?
		bcc.s	.FadeOut		; If so, branch
	endif
	bset	#0,GAMAINFLAG			; Tell Sub CPU we are finished

.WaitSubCPU:
	btst	#0,GASUBFLAG			; Has the Sub CPU received our tip?
	beq.s	.WaitSubCPU			; If not, branch
	bclr	#0,GAMAINFLAG			; Respond to the Sub CPU

.FadeOut:
	move.w	#5,vintRoutine.w		; Fade to black
	bsr.w	FadeToBlack

	moveq	#0,d1				; Set exit code
	move.b	exitFlag.w,d1
	bmi.s	.NegFlag			; If it was negative, branch
	rts

.NegFlag:
	moveq	#0,d1				; Override with 0
	rts

; -------------------------------------------------------------------------
; VSync
; -------------------------------------------------------------------------

VSync:
	bset	#0,ipxVSync			; Set VSync flag
	move	#$2500,sr			; Enable interrupts

.Wait:
	btst	#0,ipxVSync			; Has the V-INT handler run?
	bne.s	.Wait				; If not, wait
	rts

; -------------------------------------------------------------------------
; V-BLANK interrupt
; -------------------------------------------------------------------------

VInterrupt:
	movem.l	d0-a6,-(sp)			; Save registers

	move.b	#1,GAIRQ2			; Trigger IRQ2 on Sub CPU
	bclr	#0,ipxVSync			; Clear VSync flag
	beq.w	VInt_Lag			; If it wasn't set, branch
	
	tst.b	enableDisplay.w			; Should we enable the display?
	beq.s	.Update				; If not, branch
	bset	#6,ipxVDPReg1+1			; Enable display
	move.w	ipxVDPReg1,VDPCTRL
	clr.b	enableDisplay.w			; Clear enable display flag

.Update:
	lea	VDPCTRL,a1			; VDP control port
	lea	VDPDATA,a2			; VDP data port
	move.w	(a1),d0				; Reset V-BLANK flag

	jsr	StopZ80(pc)			; Stop the Z80
	DMA68K	palette,$0000,$80,CRAM		; Copy palette data
	DMA68K	hscroll,$D000,$380,VRAM		; Copy horizontal scroll data

	move.w	vintRoutine.w,d0		; Run routine
	add.w	d0,d0
	move.w	.Routines(pc,d0.w),d0
	jmp	.Routines(pc,d0.w)

; -------------------------------------------------------------------------

.Routines:
	dc.w	VInt_NormalBuf1_1-.Routines	; Copy 1st half of rendered clouds art to buffer 1
	dc.w	VInt_NormalBuf1_2-.Routines	; Copy 2nd half of rendered clouds art to buffer 1
	dc.w	VInt_NormalBuf2_1-.Routines	; Copy 1st half of rendered clouds art to buffer 2
	dc.w	VInt_NormalBuf2_2-.Routines	; Copy 2nd half of rendered clouds art to buffer 2
	dc.w	VInt_Nothing-.Routines		; Does nothing
	dc.w	VInt_NoClouds-.Routines		; Don't render clouds

; -------------------------------------------------------------------------

VInt_NormalBuf1_1:
	DMA68K	sprites,$D400,$280,VRAM		; Copy sprite data
						; Copy rendered clouds art
	DMA68K	cloudsArt,$0020,IMGLENGTH/2,VRAM
	jsr	ReadControllers(pc)		; Read controllers
	bra.w	VInt_Finish			; Finish

; -------------------------------------------------------------------------

VInt_NormalBuf1_2:
	DMA68K	sprites,$D400,$280,VRAM		; Copy sprite data
						; Copy rendered clouds art
	DMA68K	cloudsArt+(IMGLENGTH/2),$0020+(IMGLENGTH/2),IMGLENGTH/2,VRAM
	jsr	ReadControllers(pc)		; Read controllers
	bra.w	VInt_Finish			; Finish

; -------------------------------------------------------------------------

VInt_NormalBuf2_1:
	DMA68K	sprites,$D400,$280,VRAM		; Copy sprite data
						; Copy rendered clouds art
	DMA68K	cloudsArt,$3020,IMGLENGTH/2,VRAM
	jsr	ReadControllers(pc)		; Read controllers
	bra.w	VInt_Finish			; Finish

; -------------------------------------------------------------------------

VInt_NormalBuf2_2:
	DMA68K	sprites,$D400,$280,VRAM		; Copy sprite data
						; Copy rendered clouds art
	DMA68K	cloudsArt+(IMGLENGTH/2),$3020+(IMGLENGTH/2),IMGLENGTH/2,VRAM
	jsr	ReadControllers(pc)		; Read controllers
	bra.w	VInt_Finish			; Finish

; -------------------------------------------------------------------------

VInt_Nothing:
	bra.w	VInt_Finish			; Finish

; -------------------------------------------------------------------------

VInt_NoClouds:
	DMA68K	sprites,$D400,$280,VRAM		; Copy sprite data
	jsr	ReadControllers(pc)		; Read controllers

; -------------------------------------------------------------------------

VInt_Finish:
	tst.b	fmSndQueue.w			; Is there a sound queued?
	beq.s	.NoSound			; If not, branch
	move.b	fmSndQueue.w,FMDrvQueue2	; Queue sound in driver
	clr.b	fmSndQueue.w			; Clear sound queue

.NoSound:
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
	cmpi.l	#-1,lagCounter.w		; Is the lag counter disabled?
	beq.s	.NoLagCounter			; If so, branch
	addq.l	#1,lagCounter.w			; Increment lag counter
	move.b	vintRoutine+1.w,lagCounter.w	; Save routine ID

.NoLagCounter:
	movem.l	(sp)+,d0-a6			; Restore registers
	rte

; -------------------------------------------------------------------------
; Unused functions to display a clouds buffer
; -------------------------------------------------------------------------
; PARAMETERS:
;	a1.l - VDP control port
;	a2.l - VDP data port
; -------------------------------------------------------------------------

DisplayCloudsBuf1:
	move.w	#$8F20,(a1)			; Set for every 8 scanlines
	VDPCMD	move.l,$D002,VRAM,WRITE,VDPCTRL	; Write background scroll data
	moveq	#0,d0				; Display clouds buffer 1
	bra.s	DisplayCloudsBuf

; -------------------------------------------------------------------------

DisplayCloudsBuf2:
	move.w	#$8F20,(a1)			; Set for every 8 scanlines
	VDPCMD	move.l,$D002,VRAM,WRITE,VDPCTRL	; Write background scroll data
	move.w	#$100,d0			; Display clouds buffer 2

; -------------------------------------------------------------------------

DisplayCloudsBuf:
	rept	(IMGHEIGHT-8)/8			; Set scroll offset for clouds
		move.w	d0,(a2)
	endr
	move.w	#$8F02,(a1)			; Restore autoincrement
	rts

; -------------------------------------------------------------------------
; Scroll background (display clouds buffer 1)
; -------------------------------------------------------------------------

ScrollBgBuf1:
	lea	hscroll.w,a1			; Display clouds buffer 1
	moveq	#(IMGHEIGHT-8)-1,d1

.DisplayClouds:
	clr.l	(a1)+
	dbf	d1,.DisplayClouds

	lea	scrollBuf.w,a2			; Water scroll buffer
	moveq	#64-1,d2			; 64 scanlines
	move.l	#$1000,d1			; Speed accumulator
	move.l	#$4000,d0			; Initial speed

.MoveWaterSects:
	add.l	d0,(a2)+			; Move water line
	add.l	d1,d0				; Increase speed
	dbf	d2,.MoveWaterSects		; Loop until all lines are moved

	lea	scrollBuf.w,a2			; Set water scroll positions
	lea	hscroll+(160*4).w,a1
	moveq	#64-1,d2			; 64 scanlines
	moveq	#0,d0

.SetWaterScroll:
	move.w	(a2),d0				; Set scanline offset
	move.l	d0,(a1)+
	lea	4(a2),a2			; Next line
	dbf	d2,.SetWaterScroll		; Loop until all scanlines are set
	rts

; -------------------------------------------------------------------------
; Scroll background (display clouds buffer 2)
; -------------------------------------------------------------------------

ScrollBgBuf2:
	lea	hscroll.w,a1			; Display clouds buffer 2
	moveq	#(IMGHEIGHT-8)-1,d1

.DisplayClouds:
	move.l	#$100,(a1)+
	dbf	d1,.DisplayClouds

	lea	scrollBuf.w,a2			; Water scroll buffer
	moveq	#64-1,d2			; 64 scanlines
	move.l	#$1000,d1			; Speed accumulator
	move.l	#$4000,d0			; Initial speed

.MoveWaterSects:
	add.l	d0,(a2)+			; Move water line
	add.l	d1,d0				; Increase speed
	dbf	d2,.MoveWaterSects		; Loop until all lines are moved

	lea	scrollBuf.w,a2			; Set water scroll positions
	lea	hscroll+(160*4).w,a1
	moveq	#64-1,d2			; 64 scanlines
	moveq	#0,d0

.SetWaterScroll:
	move.w	(a2),d0				; Set scanline offset
	move.l	d0,(a1)+
	lea	4(a2),a2			; Next line
	dbf	d2,.SetWaterScroll		; Loop until all scanlines are set
	rts

; -------------------------------------------------------------------------
; Read controller data
; -------------------------------------------------------------------------

ReadControllers:
	lea	p1CtrlData.w,a0			; Player 1 controller data buffer
	lea	IODATA1,a1			; Controller port 1
	bsr.s	ReadController			; Read controller data
	
	lea	p2CtrlData.w,a0			; Player 2 controller data buffer
	lea	IODATA2,a1			; Controller port 2
	tst.b	cloudsCtrlFlag.w		; Are the clouds controllable?
	beq.s	ReadController			; If not, branch
	move.w	p2CtrlData.w,subP2CtrlData	; Send controller data to Sub CPU for controlling the clouds

; -------------------------------------------------------------------------

ReadController:
	include	"_common/readctrl.asm"		; Read controller
	rts

; -------------------------------------------------------------------------
; Run palette cycle
; -------------------------------------------------------------------------

PaletteCycle:
	addi.b	#$40,palCycleDelay.w		; Run delay timer
	bcs.s	.Update				; If it's time to update, branch
	rts

.Update:
	moveq	#0,d0				; Get frame
	move.b	palCycleFrame.w,d0
	addq.b	#1,d0				; Increment frame
	cmpi.b	#3,d0				; Is it time to wrap?
	bcs.s	.NoWrap				; If not, branch
	clr.b	d0				; Wrap back to start

.NoWrap:
	move.b	d0,palCycleFrame.w		; Update frame ID

	lea	.WaterPalCycle(pc),a1		; Set palette cycle colors
	lea	palette+(5*2).w,a2
	add.b	d0,d0
	add.b	d0,d0
	add.b	d0,d0
	lea	(a1,d0.w),a1
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	rts

; -------------------------------------------------------------------------

.WaterPalCycle:
	dc.w	$ECC, $ECA, $EEE, $EA8
	dc.w	$EA8, $ECC, $ECC, $ECA
	dc.w	$ECA, $EA8, $ECA, $ECC

; -------------------------------------------------------------------------
; Load clouds tilemap
; -------------------------------------------------------------------------

LoadCloudsMap:
	lea	VDPCTRL,a2			; VDP control port
	lea	VDPDATA,a3			; VDP data port

	move.w	#$8001,d6			; Set buffer 1 tilemap
	VDPCMD	move.l,$E000,VRAM,WRITE,d0
	moveq	#IMGWTILE-1,d1
	moveq	#IMGHTILE-1,d2
	bsr.s	.DrawMap

	move.w	#$8181,d6			; Set buffer 2 tilemap
	VDPCMD	move.l,$E040,VRAM,WRITE,d0
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
; Render the clouds
; -------------------------------------------------------------------------

RenderClouds:
	cmpi.b	#4,subFailCount.w		; Is the Sub CPU deemed unreliable?
	bcc.s	.End				; If so, branch
	
	move.b	#1,GACOMCMD2			; Tell Sub CPU to render clouds

.WaitSubCPU:
	cmpi.b	#1,GACOMSTAT2			; Has the Sub CPU received our tip?
	beq.s	.CommDone			; If so, branch
	addq.w	#1,subWaitTime.w		; Increment wait time
	bcc.s	.WaitSubCPU			; If we should wait some more, loop

.CommDone:
	clr.l	subWaitTime.w			; Reset Sub CPU wait time
	move.b	#0,GACOMCMD2			; Respond to the Sub CPU

.WaitSubCPU2:
	tst.b	GACOMSTAT2			; Has the Sub CPU received our tip?
	beq.s	.End				; If so, branch
	addq.w	#1,subWaitTime.w		; Increment wait time
	bcc.s	.WaitSubCPU2			; If we should wait some more, loop

.End:
	clr.l	subWaitTime.w			; Reset Sub CPU wait time
	rts

; -------------------------------------------------------------------------
; Sync with Sub CPU (wait flag set)
; -------------------------------------------------------------------------

SyncWithSubCPU1:
	cmpi.b	#4,subFailCount.w		; Is the Sub CPU deemed unreliable?
	bcc.s	.End				; If so, branch
	
	btst	#7,GASUBFLAG			; Are we synced with the Sub CPU?
	bne.s	.End				; If so, wait
	addq.w	#1,subWaitTime.w		; Increment wait time
	bcc.s	SyncWithSubCPU1			; If we should wait some more, loop
	addq.b	#1,subFailCount.w		; Increment Sub CPU fail count

.End:
	clr.l	subWaitTime.w			; Reset Sub CPU wait time
	rts

; -------------------------------------------------------------------------
; Sync with Sub CPU (wait flag clear)
; -------------------------------------------------------------------------

SyncWithSubCPU2:
	cmpi.b	#4,subFailCount.w		; Is the Sub CPU deemed unreliable?
	bcc.s	.End				; If so, branch
	
	btst	#7,GASUBFLAG			; Are we synced with the Sub CPU?
	beq.s	.End				; If so, wait
	addq.w	#1,subWaitTime.w		; Increment wait time
	bcc.s	SyncWithSubCPU2			; If we should wait some more, loop
	addq.b	#1,subFailCount.w		; Increment Sub CPU fail count

.End:
	clr.l	subWaitTime.w			; Reset Sub CPU wait time
	rts

; -------------------------------------------------------------------------
; Give Sub CPU Word RAM access
; -------------------------------------------------------------------------

GiveWordRAMAccess:
	cmpi.b	#4,subFailCount.w		; Is the Sub CPU deemed unreliable?
	bcc.s	.Done				; If so, branch
	
	btst	#1,GAMEMMODE			; Does the Sub CPU already have Word RAM Access?
	bne.s	.End				; If so, branch
	bset	#1,GAMEMMODE			; Give Sub CPU Word RAM access

.Wait:
	btst	#1,GAMEMMODE			; Has it been given?
	bne.s	.Done				; If so, branch
	addq.w	#1,subWaitTime.w		; Increment wait time
	bcc.s	.Wait				; If we should wait some more, loop
	addq.b	#1,subFailCount.w		; Increment Sub CPU fail count

.Done:
	clr.l	subWaitTime.w			; Reset Sub CPU wait time

.End:
	rts

; -------------------------------------------------------------------------
; Wait for Word RAM access
; -------------------------------------------------------------------------

WaitWordRAMAccess:
	cmpi.b	#4,subFailCount.w		; Is the Sub CPU deemed unreliable?
	bcc.s	.End				; If so, branch

	btst	#0,GAMEMMODE			; Do we have Word RAM access?
	bne.s	.End				; If so, branch

	addq.w	#1,subWaitTime.w		; Increment wait time
	bcc.s	WaitWordRAMAccess		; If we should wait some more, loop
	addq.b	#1,subFailCount.w		; Increment Sub CPU fail count

.End:
	clr.l	subWaitTime.w			; Reset Sub CPU wait time
	rts

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

	jsr	StopZ80(pc)			; Stop the Z80
	DMAFILL	0,$10000,0			; Clear VRAM

	lea	.Palette(pc),a0			; Load palette
	lea	palette.w,a1
	moveq	#(.PaletteEnd-.Palette)/4-1,d7

.LoadPal:
	move.l	(a0)+,d0
	move.l	d0,(a1)+
	dbf	d7,.LoadPal

	VDPCMD	move.l,0,VSRAM,WRITE,VDPCTRL	; Clear VSRAM
	move.l	#0,VDPDATA

	jsr	StartZ80(pc)			; Start the Z80
	move.w	#$8134,ipxVDPReg1		; Reset IPX VDP register 1 cache
	rts

; -------------------------------------------------------------------------

.VDPRegs:
	dc.b	%00000100			; No H-INT
	dc.b	%00110100			; V-INT, DMA, mode 5
	dc.b	$C000/$400			; Plane A location
	dc.b	0				; Window location
	dc.b	$E000/$2000			; Plane B location
	dc.b	$D400/$200			; Sprite table location
	dc.b	0				; Reserved
	dc.b	0				; BG color line 0 color 0
	dc.b	0				; Reserved
	dc.b	0				; Reserved
	dc.b	0				; H-INT counter 0
	dc.b	%00000011			; Scroll by line
	dc.b	%00000000			; H32
	dc.b	$D000/$400			; Horizontal scroll table lcation
	dc.b	0				; Reserved
	dc.b	2				; Auto increment by 2
	dc.b	%00000001			; 64x32 tile plane size
	dc.b	0				; Window horizontal position 0
	dc.b	0				; Window vertical position 0
.VDPRegsEnd:
	even

.Palette:
	incbin	"title/data/palinit.pal"
.PaletteEnd:
	even

; -------------------------------------------------------------------------
; Palette
; -------------------------------------------------------------------------

Pal_Title:
	incbin	"title/data/palette.pal"
	even

; -------------------------------------------------------------------------
; Stop the Z80
; -------------------------------------------------------------------------

StopZ80:
	move	sr,savedSR.w			; Save status register
	move	#$2700,sr			; Disable interrupts
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
; Get clouds art
; -------------------------------------------------------------------------

GetCloudsArt:
	lea	WORDRAM2M+IMGBUFFER,a1		; Rendered data in Word RAM
	lea	cloudsArt.w,a2			; Destination buffer
	move.w	#(IMGLENGTH/$800)-1,d7		; Number of $800 byte chunks to copy

.CopyChunks:
	rept	$800/$80			; Copy $800 bytes
		bsr.s	Copy128Bytes
	endr
	dbf	d7,.CopyChunks			; Loop until chunks are copied

	if (IMGLENGTH&$7FF)<>0			; Copy leftover data
		move.w	#(IMGLENGTH&$7FF)/4-1,d7

.CopyLeftovers:
		move.l	(a1)+,(a2)+
		dbf	d7,.CopyLeftovers

		if (IMGLENGTH&2)<>0
			move.w	(a1)+,(a2)+
		endif
		if (IMGLENGTH&1)<>0
			move.b	(a1)+,(a2)+
		endif
	endif
	rts

; -------------------------------------------------------------------------
; Copy 128 bytes from a source to a destination buffer
; -------------------------------------------------------------------------
; PARAMAETERS:
;	a1.l - Pointer to source
;	a2.l - Pointer to destination buffer
; -------------------------------------------------------------------------

Copy128Bytes:
	movem.l	(a1)+,d0-d5/a3-a4
	movem.l	d0-d5/a3-a4,(a2)
	movem.l	(a1)+,d0-d5/a3-a4
	movem.l	d0-d5/a3-a4,$20(a2)
	movem.l	(a1)+,d0-d5/a3-a4
	movem.l	d0-d5/a3-a4,$40(a2)
	movem.l	(a1)+,d0-d5/a3-a4
	movem.l	d0-d5/a3-a4,$60(a2)
	lea	$80(a2),a2
	rts

; -------------------------------------------------------------------------
; Fade to black
; -------------------------------------------------------------------------

FadeToBlack:
	move.w	#($00<<9)|($40-1),palFadeInfo.w	; Fade entire palette
	move.w	#(7*3),d4			; Number of fade frames

.Loop:
	move.b	#1,unkPalFadeFlag.w		; Set unknown flag
	bsr.w	VSync				; VSync
	bsr.s	FadeToBlackFrame		; Do a frame of fading
	dbf	d4,.Loop			; Loop until palette is faded
	rts

; -------------------------------------------------------------------------
; Do a frame of a fade to black
; -------------------------------------------------------------------------

FadeToBlackFrame:
	moveq	#0,d0				; Get palette offset
	lea	palette.w,a0
	move.b	palFadeStart.w,d0
	adda.w	d0,a0

	move.b	palFadeLen.w,d0			; Get color count

.FadeColors:
	bsr.s	FadeColorToBlack		; Fade color
	dbf	d0,.FadeColors			; Loop until all colors have faded a frame
	rts

; -------------------------------------------------------------------------
; Fade a color to black
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to palette color
; RETURNS:
;	a0.l - Pointer to next color
; -------------------------------------------------------------------------

FadeColorToBlack:
	move.w	(a0),d2				; Get color
	beq.s	.End				; If it's already black, branch

.CheckRed:
	move.w	d2,d1				; Check red channel
	andi.w	#$E,d1
	beq.s	.CheckGreen			; If it's already 0, branch
	subq.w	#2,(a0)+			; Decrement red channel
	rts

.CheckGreen:
	move.w	d2,d1				; Check green channel
	andi.w	#$E0,d1
	beq.s	.CheckBlue			; If it's already 0, branch
	subi.w	#$20,(a0)+			; Decrement green channel
	rts

.CheckBlue:
	move.w	d2,d1				; Check blue channel
	andi.w	#$E00,d1
	beq.s	.End				; If it's already 0, branch
	subi.w	#$200,(a0)+			; Decrement blue channel
	rts

.End:
	addq.w	#2,a0				; Skip to next color
	rts

; -------------------------------------------------------------------------
; Fade from black
; -------------------------------------------------------------------------

FadeFromBlack:
	moveq	#0,d0				; Get palette offset
	lea	palette.w,a0
	move.b	palFadeStart.w,d0
	adda.w	d0,a0
	moveq	#0,d1				; Black
	move.b	palFadeLen.w,d0			; Get color count

.FillBlack:
	move.w	d1,(a0)+			; Fill palette region with black
	dbf	d0,.FillBlack

	move.w	#(7*3),d4			; Number of fade frames

.Loop:
	move.b	#1,unkPalFadeFlag.w		; Set unknown flag
	bsr.w	VSync				; VSync
	bsr.s	FadeFromBlackFrame		; Do a frame of fading
	dbf	d4,.Loop			; Loop until palette is faded
	rts

; -------------------------------------------------------------------------
; Do a frame of a fade from black
; -------------------------------------------------------------------------

FadeFromBlackFrame:
	moveq	#0,d0				; Get palette offsets
	lea	palette.w,a0
	lea	fadePalette.w,a1
	move.b	palFadeStart.w,d0
	adda.w	d0,a0
	adda.w	d0,a1
	move.b	palFadeLen.w,d0			; Get color count

.FadeColors:
	bsr.s	FadeColorFromBlack		; Fade color
	dbf	d0,.FadeColors			; Loop until all colors have faded a frame
	rts

; -------------------------------------------------------------------------
; Fade a color from black
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to palette color
;	a1.l - Pointer to target palette color
; RETURNS:
;	a0.l - Pointer to next color
;	a1.l - Pointer to next target color
; -------------------------------------------------------------------------

FadeColorFromBlack:
	move.w	(a1)+,d2			; Get target color
	move.w	(a0),d3				; Get color
	cmp.w	d2,d3				; Are they the same?
	beq.s	.End				; If so, branch

.CheckBlue:
	move.w	d3,d1				; Increment blue channel
	addi.w	#$200,d1
	cmp.w	d2,d1				; Have we gone past the target channel value?
	bhi.s	.CheckGreen			; If so, branch
	move.w	d1,(a0)+			; Update color
	rts

.CheckGreen:
	move.w	d3,d1				; Increment green channel
	addi.w	#$20,d1
	cmp.w	d2,d1				; Have we gone past the target channel value?
	bhi.s	.IncRed				; If so, branch
	move.w	d1,(a0)+			; Update color
	rts

.IncRed:
	addq.w	#2,(a0)+			; Increment red channel
	rts

.End:
	addq.w	#2,a0				; Skip to next color
	rts

; -------------------------------------------------------------------------
; Fade from white
; -------------------------------------------------------------------------

FadeFromWhite:
	move.w	#($00<<9)|($40-1),palFadeInfo.w	; Fade entire palette
	
FadeFromWhite2:
	moveq	#0,d0				; Get palette offset
	lea	palette.w,a0
	move.b	palFadeStart.w,d0
	adda.w	d0,a0
	move.w	#$EEE,d1			; White
	move.b	palFadeLen.w,d0			; Get color count

.FillWhite:
	move.w	d1,(a0)+			; Fill palette region with black
	dbf	d0,.FillWhite
	move.w	#0,palette+($2E*2).w		; Set line 2 color 14 to black

	move.w	#(7*3),d4			; Number of fade frames

.Loop:
	move.b	#1,unkPalFadeFlag.w		; Set unknown flag
	bsr.w	VSync				; VSync
	
	move.l	d4,-(sp)			; Scrapped code?
	; ?
	move.l	(sp)+,d4
	
	bsr.s	FadeFromWhiteFrame		; Do a frame of fading
	dbf	d4,.Loop			; Loop until palette is faded
	
	clr.b	unkPalFadeFlag.w		; Clear unknown flag
	rts

; -------------------------------------------------------------------------
; Do a frame of a fade from white
; -------------------------------------------------------------------------

FadeFromWhiteFrame:
	moveq	#0,d0				; Get palette offsets
	lea	palette.w,a0
	lea	fadePalette.w,a1
	move.b	palFadeStart.w,d0
	adda.w	d0,a0
	adda.w	d0,a1
	move.b	palFadeLen.w,d0			; Get color count

.FadeColors:
	bsr.s	FadeColorFromWhite		; Fade color
	dbf	d0,.FadeColors			; Loop until all colors have faded a frame
	rts

; -------------------------------------------------------------------------
; Fade a color from white
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to palette color
;	a1.l - Pointer to target palette color
; RETURNS:
;	a0.l - Pointer to next color
;	a1.l - Pointer to next target color
; -------------------------------------------------------------------------

FadeColorFromWhite:
	move.w	(a1)+,d2			; Get target color
	move.w	(a0),d3				; Get color
	cmp.w	d2,d3				; Are they the same?
	beq.s	.End				; If so, branch

.CheckBlue:
	move.w	d3,d1				; Decrement blue channel
	subi.w	#$200,d1
	bcs.s	.CheckGreen			; If it underflowed, branch
	cmp.w	d2,d1				; Have we gone past the target channel value?
	bcs.s	.CheckGreen			; If so, branch
	move.w	d1,(a0)+			; Update color
	rts

.CheckGreen:
	move.w	d3,d1				; Decrement green channel
	subi.w	#$20,d1
	bcs.s	.IncRed				; If it underflowed, branch
	cmp.w	d2,d1				; Have we gone past the target channel value?
	bcs.s	.IncRed				; If so, branch
	move.w	d1,(a0)+			; Update color
	rts

.IncRed:
	subq.w	#2,(a0)+			; Decrement red channel
	rts

.End:
	addq.w	#2,a0				; Skip to next color
	rts

; -------------------------------------------------------------------------
; Fade to white
; -------------------------------------------------------------------------

FadeToWhite:
	move.w	#($00<<9)|($40-1),palFadeInfo.w	; Fade entire palette
	move.w	#(7*3),d4			; Number of fade frames

.Loop:
	move.b	#1,unkPalFadeFlag.w		; Set unknown flag
	bsr.w	VSync				; VSync
	bsr.s	FadeToWhiteFrame		; Do a frame of fading
	dbf	d4,.Loop			; Loop until palette is faded
	
	clr.b	unkPalFadeFlag.w		; Clear unknown flag
	rts

; -------------------------------------------------------------------------
; Do a frame of a fade to white
; -------------------------------------------------------------------------

FadeToWhiteFrame:
	moveq	#0,d0				; Get palette offset
	lea	palette.w,a0
	move.b	palFadeStart.w,d0
	adda.w	d0,a0

	move.b	palFadeLen.w,d0			; Get color count

.FadeColors:
	bsr.s	FadeColorToWhite		; Fade color
	dbf	d0,.FadeColors			; Loop until all colors have faded a frame
	rts

; -------------------------------------------------------------------------
; Fade a color to white
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to palette color
; RETURNS:
;	a0.l - Pointer to next color
; -------------------------------------------------------------------------

FadeColorToWhite:
	move.w	(a0),d2				; Get color
	cmpi.w	#$EEE,d2			; Is it already white?
	beq.s	.End				; If so, branch

.CheckRed:
	move.w	d2,d1				; Check red channel
	andi.w	#$E,d1
	cmpi.w	#$E,d1				; Is it already at max?
	beq.s	.CheckGreen			; If so, branch
	addq.w	#2,(a0)+			; Decrement red channel
	rts

.CheckGreen:
	move.w	d2,d1				; Check green channel
	andi.w	#$E0,d1
	cmpi.w	#$E0,d1				; Is it already at max?
	beq.s	.CheckBlue			; If so, branch
	addi.w	#$20,(a0)+			; Decrement green channel
	rts

.CheckBlue:
	move.w	d2,d1				; Check blue channel
	andi.w	#$E00,d1
	cmpi.w	#$E00,d1			; Is it already at max?
	beq.s	.End				; If so, branch
	addi.w	#$200,(a0)+			; Decrement blue channel
	rts

.End:
	addq.w	#2,a0				; Skip to next color
	rts

; -------------------------------------------------------------------------

	include	"_common/nemdec.asm"		; Nemesis decompression

; -------------------------------------------------------------------------
; Run objects
; -------------------------------------------------------------------------

RunObjects:
	lea	objects.w,a0			; Object pool
	moveq	#OBJCOUNT-1,d7			; Number of objects

.RunLoop:
	tst.b	oActive(a0)			; Is this slot active?
	beq.s	.NextObjRun			; If not, branch

	move.l	d7,-(sp)			; Run object
	jsr	RunObject
	move.l	(sp)+,d7

	btst	#1,oFlags(a0)			; Should the global Y speed be applied?
	beq.s	.NextObjRun			; If not, branch
	moveq	#0,d0
	move.w	unkObjYSpeed.w,d0		; Apply global Y speed
	swap	d0
	sub.l	d0,oY(a0)

.NextObjRun:
	lea	oSize(a0),a0			; Next object
	dbf	d7,.RunLoop			; Loop until all objects are run

	lea	objectsEnd-oSize.w,a0		; Start from the bottom of the object pool
	moveq	#OBJCOUNT-1,d7			; Number of objects

.DrawLoop:
	tst.b	oActive(a0)			; Is this slot active?
	beq.s	.NextObjDraw			; If not, branch
	btst	#0,oFlags(a0)			; Is this object set to be drawn?
	beq.s	.NextObjDraw			; If not, branch
	bsr.w	DrawObject			; Draw object

.NextObjDraw:
	lea	-oSize(a0),a0			; Next object
	dbf	d7,.DrawLoop			; Loop until all objects are drawn
	rts

; -------------------------------------------------------------------------
; Run an object
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to object slot
; -------------------------------------------------------------------------

RunObject:
	moveq	#$FFFFFFFF,d0			; Run object
	move.w	oAddr(a0),d0
	movea.l	d0,a1
	jmp	(a1)

; -------------------------------------------------------------------------
; Spawn an object
; -------------------------------------------------------------------------
; PARAMETERS:
;	a2.l - Pointer to object code
; RETURNS:
;	eq/ne - Object slot not found/Found
;	a1.l  - Found object slot
; -------------------------------------------------------------------------

SpawnObject:
	moveq	#-1,d0				; Active flag
	lea	objects.w,a1			; Object pool
	moveq	#OBJCOUNT-1,d2			; Number of objects

.FindSlot:
	tst.b	oActive(a1)			; Is this slot active?
	beq.s	.Found				; If not, branch
	lea	oSize(a1),a1			; Next object slot
	dbf	d2,.FindSlot			; Loop until all slots are checked

.NotFound:
	ori	#1,ccr				; Object slot not found
	rts

.Found:
	move.b	d0,oActive(a1)			; Set active flag
	move.w	a2,oAddr(a1)			; Set code address
	rts

; -------------------------------------------------------------------------
; Clear objects
; -------------------------------------------------------------------------

ClearObjects:
	lea	objects.w,a0			; Clear object data
	
	if OBJCOUNT<=8
		moveq	#(objectsEnd-objects)/4-1,d7
	else
		move.l	#(objectsEnd-objects)/4-1,d7
	endif

.Clear:
	clr.l	(a0)+
	dbf	d7,.Clear

	if ((objectsEnd-objects)&2)<>0		; Clear leftovers
		clr.w	(a0)+
	endif
	if ((objectsEnd-objects)&1)<>0
		clr.b	(a0)+
	endif
	rts

; -------------------------------------------------------------------------
; Set object bookmark and exit
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to object slot
; -------------------------------------------------------------------------

BookmarkObject:
	move.l	(sp)+,d0			; Set bookmark and exit
	move.w	d0,oAddr(a0)
	rts

; -------------------------------------------------------------------------
; Set object bookmark and continue
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to object slot
; -------------------------------------------------------------------------

BookmarkObjCont:
	move.l	(sp)+,d0			; Set bookmark
	move.w	d0,oAddr(a0)
	movea.l	d0,a0				; BUG: Overwrites object slot pointer
	jmp	(a0)				; Go back to object code

; -------------------------------------------------------------------------
; Set object address
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to object slot
;	a1.l - Pointer to object code
; -------------------------------------------------------------------------

SetObjectAddr:
	move.l	a1,oAddr(a0)			; BUG: Writes longword when it should've been truncated to a word
	rts

; -------------------------------------------------------------------------
; Delete object
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to object slot
; -------------------------------------------------------------------------

DeleteObject:
	; BUG: It advances a0, but doesn't restore it, so when it exits
	; back to RunObjects, it'll skip the object after this one
	moveq	#oSize/4-1,d0			; Clear object

.Clear:
	clr.l	(a0)+
	dbf	d0,.Clear

	if (oSize&2)<>0				; Clear leftovers
		clr.w	(a0)+
	endif
	if (oSize&1)<>0
		clr.b	(a0)+
	endif
	rts

; -------------------------------------------------------------------------
; Clear sprites
; -------------------------------------------------------------------------

ClearSprites:
	lea	sprites.w,a0			; Clear sprite buffer
	moveq	#(64*8)/4-1,d0			; H32 mode only allows 64 sprites

.Clear:
	clr.l	(a0)+
	dbf	d0,.Clear

	move.b	#1,spriteCount.w		; Reset sprite count
	lea	sprites.w,a0			; Reset sprite slot
	move.l	a0,curSpriteSlot.w
	rts

; -------------------------------------------------------------------------
; Draw an object
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to object slot
; -------------------------------------------------------------------------

DrawObject:
	move.l	d7,-(sp)			; Save d7

	move.w	oX(a0),d4			; Get X position
	move.w	oY(a0),d3			; Get Y position
	addi.w	#128,d4				; Add screen origin point
	addi.w	#128,d3
	move.w	oTile(a0),d5			; Get base sprite tile ID
	
	movea.l	oMap(a0),a3			; Get pointer to sprite frame
	moveq	#0,d0
	move.b	oMapFrame(a0),d0
	add.w	d0,d0
	move.w	(a3,d0.w),d0
	lea	(a3,d0.w),a4
	movea.l	curSpriteSlot.w,a5		; Get current sprite slot

	move.b	(a4)+,d7			; Get sprite count
	beq.s	.End				; If there are no sprites, branch
	subq.b	#1,d7				; Subtract 1 for DBF

.DrawLoop:
	cmpi.b	#64,spriteCount.w		; Are there too many sprites?
	bcc.s	.End				; If so, branch

	move.b	(a4)+,d0			; Set sprite Y position
	ext.w	d0
	add.w	d3,d0
	move.w	d0,(a5)+

	move.b	(a4)+,(a5)+			; Set sprite size
	move.b	spriteCount.w,(a5)+		; Set sprite link
	addq.b	#1,spriteCount.w		; Increment sprite count

	move.b	(a4)+,d0			; Get sprite tile ID
	lsl.w	#8,d0
	move.b	(a4)+,d0
	add.w	d5,d0

	move.w	d0,d6				; Does this sprite point to the solid tiles?
	andi.w	#$7FF,d6
	cmpi.w	#$BC20/$20,d6
	bne.s	.SetSpriteTile			; If not, branch
	subi.w	#$2000,d0			; Decrement palette line

.SetSpriteTile:
	move.w	d0,(a5)+			; Set sprite tile ID

	move.b	(a4)+,d0			; Get sprite X position
	ext.w	d0
	add.w	d4,d0
	andi.w	#$1FF,d0
	bne.s	.SetSpriteX			; If it's not 0, branch
	addq.w	#1,d0				; Keep it away from 0

.SetSpriteX:
	move.w	d0,(a5)+			; Set sprite X position

	dbf	d7,.DrawLoop			; Loop until all sprites are drawn

.End:
	move.l	a5,curSpriteSlot.w		; Update current sprite slot
	move.l	(sp)+,d7			; Restore d7
	rts

; -------------------------------------------------------------------------
; Sonic object
; -------------------------------------------------------------------------

	rsset	oVars
oSonicDelay	rs.b	1			; Animation delay

; -------------------------------------------------------------------------

ObjSonic:
	move.l	#MapSpr_Sonic,oMap(a0)		; Set mappings
	move.w	#$E000|($6D00/$20),oTile(a0)	; Set sprite tile ID
	move.b	#%11,oFlags(a0)			; Set flags
	move.w	#91,oX(a0)			; Set X position
	move.w	#15,oY(a0)			; Set Y position

	move.b	#2,oSonicDelay(a0)		; Set animation delay

; -------------------------------------------------------------------------

.Frame0Delay:
	bsr.w	BookmarkObject			; Set bookmark
	subq.b	#1,oSonicDelay(a0)		; Decrement delay timer
	bne.s	.Frame0Delay			; If it hasn't run out, branch

	addq.b	#1,oMapFrame(a0)		; Set next sprite frame
	move.b	#3,oSonicDelay(a0)		; Reset animation delay

; -------------------------------------------------------------------------

.Frame1Delay:
	bsr.w	BookmarkObject			; Set bookmark
	subq.b	#1,oSonicDelay(a0)		; Decrement delay timer
	bne.s	.Frame1Delay			; If it hasn't run out, branch

	move.l	a0,-(sp)			; Load background mountains art
	VDPCMD	move.l,$6000,VRAM,WRITE,VDPCTRL
	lea	Art_Mountains(pc),a0
	bsr.w	NemDec
	movea.l	(sp)+,a0

	addq.b	#1,oMapFrame(a0)		; Set next sprite frame
	move.b	#2,oSonicDelay(a0)		; Reset animation delay

; -------------------------------------------------------------------------

.Frame2Delay:
	bsr.w	BookmarkObject			; Set bookmark
	subq.b	#1,oSonicDelay(a0)		; Decrement delay timer
	bne.s	.Frame2Delay			; If it hasn't run out, branch

	move.l	a0,-(sp)			; Load background mountains art
	VDPCMD	move.l,$6B00,VRAM,WRITE,VDPCTRL
	lea	Art_Water(pc),a0
	bsr.w	NemDec
	movea.l	(sp)+,a0

	addq.b	#1,oMapFrame(a0)		; Set next sprite frame
	move.b	#1,oSonicDelay(a0)		; Reset animation delay

; -------------------------------------------------------------------------

.Frame3Delay:
	bsr.w	BookmarkObject			; Set bookmark
	subq.b	#1,oSonicDelay(a0)		; Decrement delay timer
	bne.s	.Frame3Delay			; If it hasn't run out, branch

	bset	#7,titleMode.w			; Mark Sonic as turned around
	
	lea	ObjSonicArm(pc),a2		; Spawn Sonic's arm
	bsr.w	SpawnObject
	move.w	a0,oArmParent(a1)

	lea	ObjBanner,a2			; Spawn banner
	bsr.w	SpawnObject
	
	addq.b	#1,oMapFrame(a0)		; Set next sprite frame
	move.b	#$14,oSonicDelay(a0)		; Reset animation delay

; -------------------------------------------------------------------------

.Frame4Delay:
	bsr.w	BookmarkObject			; Set bookmark
	subq.b	#1,oSonicDelay(a0)		; Decrement delay timer
	bne.s	.Frame4Delay			; If it hasn't run out, branch
	
	addq.b	#1,oMapFrame(a0)		; Set next sprite frame
	move.b	#4,oSonicDelay(a0)		; Reset animation delay

; -------------------------------------------------------------------------

.Frame5Delay:
	bsr.w	BookmarkObject			; Set bookmark
	subq.b	#1,oSonicDelay(a0)		; Decrement delay timer
	bne.s	.Frame5Delay			; If it hasn't run out, branch
	
	move.b	#4,oMapFrame(a0)		; Go back to frame 4

; -------------------------------------------------------------------------

.Done:
	bsr.w	BookmarkObject			; Set bookmark
	bra.s	.Done				; Remain static

; -------------------------------------------------------------------------
; Sonic mappings
; -------------------------------------------------------------------------

MapSpr_Sonic:
	include	"title/data/sonic.spr.asm"
	even

; -------------------------------------------------------------------------
; Sonic's arm object
; -------------------------------------------------------------------------

	rsset	oVars
oArmDelay	rs.b	1			; Delay counter
		rs.b	3			; Unused
oArmFrame	rs.b	1			; Animatiom frame
		rs.b	3			; Unused
oArmParent	rs.w	1			; Parent object

; -------------------------------------------------------------------------

ObjSonicArm:
	move.l	#MapSpr_Sonic,oMap(a0)		; Set mappings
	move.w	#$E000|($6D00/$20),oTile(a0)	; Set sprite tile ID
	move.b	#%11,oFlags(a0)			; Set flags
	move.w	#140,oX(a0)			; Set X position
	move.w	#104,oY(a0)			; Set Y position
	move.b	#9,oMapFrame(a0)		; Set sprite frame

; -------------------------------------------------------------------------

.Delay:
	bsr.w	BookmarkObject			; Set bookmark
	addi.b	#$12,oArmDelay(a0)		; Increment delay counter
	bcc.s	.Delay				; If it hasn't overflowed, loop

; -------------------------------------------------------------------------

.Animate:
	moveq	#0,d0				; Get animation frame
	move.b	oArmFrame(a0),d0
	move.b	.Frames(pc,d0.w),oMapFrame(a0)

	addq.b	#1,d0				; Increment animation frame ID
	cmpi.b	#.FramesEnd-.Frames,d0		; Are we at the end of the animation?
	bcc.s	.Done				; If so, branch
	move.b	d0,oArmFrame(a0)		; Update animation frame ID
	
	bsr.w	BookmarkObject			; Set bookmark
	bra.s	.Animate			; Animate

; -------------------------------------------------------------------------

.Done:
	bsr.w	BookmarkObject			; Set bookmark
	bra.s	.Done				; Remain static

; -------------------------------------------------------------------------

.Frames:
	dc.b	9, 8, 7, 6, 6, 7, 8, 9
	dc.b	9, 8, 7, 6, 6, 7, 8, 9
.FramesEnd:

; -------------------------------------------------------------------------
; Banner object
; -------------------------------------------------------------------------

ObjBanner:
	move.l	#MapSpr_Banner,oMap(a0)		; Set mappings
	move.w	#$A000|($F000/$20),oTile(a0)	; Set sprite tile ID
	move.b	#%11,oFlags(a0)			; Set flags
	move.w	#127,oX(a0)			; Set X position
	move.w	#127,oY(a0)			; Set Y position

; -------------------------------------------------------------------------

.Done:
	jsr	BookmarkObject(pc)		; Set bookmark
	bra.s	.Done				; Remain static

; -------------------------------------------------------------------------
; Banner mappings
; -------------------------------------------------------------------------

MapSpr_Banner:
	include	"title/data/banner.spr.asm"
	even

; -------------------------------------------------------------------------
; Planet object
; -------------------------------------------------------------------------

	rsset	oVars
oPlanetOff	rs.b	1			; Offset
oPlanetDelay	rs.b	1			; Delay counter
		rs.b	4
oPlanetY	rs.w	1			; Y position

; -------------------------------------------------------------------------

ObjPlanet:
	bsr.w	BookmarkObject			; Set bookmark
	
	move.l	a0,-(sp)			; Load planet art	
	VDPCMD	move.l,$8040,VRAM,WRITE,VDPCTRL
	lea	Art_Planet(pc),a0
	bsr.w	NemDec
	movea.l	(sp)+,a0
	
	move.l	#MapSpr_Planet,oMap(a0)		; Set mappings
	move.w	#$6000|($8040/$20),oTile(a0)	; Set sprite tile ID
	move.b	#%1,oFlags(a0)			; Set flags
	move.w	#226,oX(a0)			; Set X position
	move.w	#24,oY(a0)			; Set Y position
	move.w	oY(a0),oPlanetY(a0)

; -------------------------------------------------------------------------

.Hover:
	addi.b	#$40,oPlanetDelay(a0)		; Increment delay counter
	bcc.s	.Exit				; If it hasn't overflowed, branch

	moveq	#0,d0				; Get offset value
	move.b	oPlanetOff(a0),d0
	move.b	.Offsets(pc,d0.w),d0
	ext.w	d0
	add.w	d0,oY(a0)

	move.b	oPlanetOff(a0),d0		; Next offset
	addq.b	#1,d0
	andi.b	#$1F,d0
	move.b	d0,oPlanetOff(a0)

.Exit:
	jsr	BookmarkObject(pc)		; Set bookmark
	bra.s	.Hover				; Handle hovering

; -------------------------------------------------------------------------

.Offsets:
	dc.b	0, 0, 0, -1
	dc.b	0, 0, 0, -1
	dc.b	0, 0, 0, -1
	dc.b	0, 0, 0, 0
	dc.b	0, 0, 0, 0
	dc.b	1, 0, 0, 0
	dc.b	1, 0, 0, 0
	dc.b	1, 0, 0, 0

; -------------------------------------------------------------------------
; Planet mappings
; -------------------------------------------------------------------------

MapSpr_Planet:
	include	"title/data/planet.spr.asm"
	even

; -------------------------------------------------------------------------
; Menu object
; -------------------------------------------------------------------------

	rsset	oVars
oMenuDelay	rs.b	1			; Delay counter
		rs.b	3
oMenuOption	rs.b	1			; Option ID
oMenuAllowSel	rs.b	1			; Allow selection flag
		rs.b	$16
oMenuCloudsIdx	rs.b	1			; Clouds cheat index
		rs.b	3
oMenuSndTestIdx	rs.b	1			; Sound test cheat index
		rs.b	3
oMenuStgSelIdx	rs.b	1			; Stage select cheat index
		rs.b	3
oMenuBestTmsIdx	rs.b	1			; Best times cheat index

; -------------------------------------------------------------------------

ObjMenu:
	move.l	#MapSpr_Menu,oMap(a0)		; Set mappings
	move.w	#$A000|($D800/$20),oTile(a0)	; Set sprite tile ID
	move.b	#%1,oFlags(a0)			; Set flags
	move.w	#83,oX(a0)			; Set X position
	move.w	#180,oY(a0)			; Set Y position
	if REGION=USA				; Activate timer
		move.w	#$3FC,timer.w
	else
		move.w	#$1E0,timer.w
	endif

; -------------------------------------------------------------------------

ObjMenu_PressStart:
	addi.b	#$10,oMenuDelay(a0)		; Increment delay counter
	bcc.s	.NoFlash			; If it hasn't overflowed, branch
	eori.b	#1,oMapFrame(a0)		; Flash text

.NoFlash:
	btst	#7,p1CtrlTap.w			; Has the start button been pressed?
	bne.s	.PrepareMenu			; If so, branch

	bsr.w	ObjMenu_CloudsCheat		; Check clouds cheat
	bsr.w	ObjMenu_ChkCloudCtrl		; Check cloud control

	bsr.w	ObjMenu_SoundTestCheat		; Check sound test cheat
	tst.b	d0				; Was it activated?
	bne.w	ObjMenu_CheatActivated		; If so, branch

	bsr.w	ObjMenu_StageSelCheat		; Check stage select cheat
	tst.b	d0				; Was it activated?
	bne.w	ObjMenu_CheatActivated		; If so, branch
	
	bsr.w	ObjMenu_BestTimesCheat		; Check best times cheat
	tst.b	d0				; Was it activated?
	bne.w	ObjMenu_CheatActivated		; If so, branch

	tst.w	timer.w				; Has the timer run out?
	beq.w	ObjMenu_TimeOut			; If so, branch

	bsr.w	BookmarkObject			; Set bookmark
	bra.s	ObjMenu_PressStart		; Update

; -------------------------------------------------------------------------

.PrepareMenu:
	clr.w	p1CtrlData.w			; Clear controller data
	move.b	#1,oMapFrame(a0)		; Make invisible
	move.w	#$1E0,timer.w			; Reset timer

	lea	menuOptions.w,a2		; Options buffer
	move.b	titleFlags,d1			; Title screen flags

	move.w	#$FF02,(a2)+			; Add stop flag and new game option
	moveq	#1,d0				; Highlight new game option
	btst	#6,d1				; Is there a save file?
	beq.s	.SetSelection			; If not, branch
	moveq	#2,d0				; Highlight continue option
	move.b	#3,(a2)+			; Add continue option

.SetSelection:
	move.b	d0,menuSel.w			; Set menu selection

	btst	#5,d1				; Is time attack enabled?
	beq.s	.NoTimeAttack			; If not, branch
	move.b	#4,(a2)+			; Add time attack option

.NoTimeAttack:
	btst	#4,d1				; Is save management enabled?
	beq.s	.NoRamData			; If not, branch
	move.b	#5,(a2)+			; Add save management option

.NoRamData:
	btst	#3,d1				; Is DA Garden enabled?
	beq.s	.NoDAGarden			; If not, branch
	move.b	#6,(a2)+			; Add DA Garden option

.NoDAGarden:
	btst	#2,d1				; Is Visual Mode enabled?
	beq.s	.NoVisualMode			; If not, branch
	move.b	#7,(a2)+			; Add Visual Mode option

.NoVisualMode:
	move.b	#$FF,(a2)			; Add stop flag

	lea	ObjMenuArrow(pc),a2		; Spawn left menu arrow
	bsr.w	SpawnObject
	move.w	a0,oArrowParent(a1)
	lea	ObjMenuArrow(pc),a2		; Spawn right menu arrow
	bsr.w	SpawnObject
	move.w	a0,oArrowParent(a1)
	move.b	#1,oArrowID(a1)

; -------------------------------------------------------------------------

ObjMenu_MoveRight:
	move.w	#$C000|($D800/$20),oTile(a0)	; Unhighlight text
	clr.b	oMenuAllowSel(a0)		; Disable selection
	bsr.w	BookmarkObject			; Set bookmark
	addi.b	#$80,oMenuDelay(a0)		; Incremenet delay counter
	bcc.s	ObjMenu_MoveRight		; If it hasn't overflowed, branch

.MoveOut:
	move.w	oX(a0),d0			; Move in
	addi.w	#$20,d0
	move.w	d0,oX(a0)
	bsr.w	BookmarkObject			; Set bookmark
	cmpi.w	#$100,oX(a0)			; Is the text fully off screen?
	bcs.s	.MoveOut			; If not, branch
	bsr.w	BookmarkObject			; Set bookmark
	
	lea	menuOptions.w,a2		; Set option ID
	moveq	#0,d0
	move.b	menuSel.w,d0
	lea	(a2,d0.w),a2
	move.b	(a2),d0
	move.b	d0,oMenuOption(a0)
	bsr.w	ObjMenu_SetOption

	move.w	#-$2D,oX(a0)			; Move to left side of screen
	bsr.w	BookmarkObject			; Set bookmark

.MoveIn:
	move.w	oX(a0),d0			; Move in
	addi.w	#$10,d0
	move.w	d0,oX(a0)
	bsr.w	BookmarkObject			; Set bookmark
	tst.w	oX(a0)				; Is the text still off screen?
	bmi.s	.MoveIn				; If so, branch
	cmpi.w	#$53,oX(a0)			; Is the text fully on screen?
	bcs.s	.MoveIn				; If not, branch
	move.w	#$53,oX(a0)			; Stop moving
	
	move.w	#$A000|($D800/$20),oTile(a0)	; Highlight text
	bra.w	ObjMenu_WaitSelection		; Wait for selection

; -------------------------------------------------------------------------

ObjMenu_MoveLeft:
	move.w	#$C000|($D800/$20),oTile(a0)	; Unhighlight text
	clr.b	oMenuAllowSel(a0)		; Disable selection
	bsr.w	BookmarkObject			; Set bookmark
	addi.b	#$80,oMenuDelay(a0)		; Incremenet delay counter
	bcc.s	ObjMenu_MoveLeft		; If it hasn't overflowed, branch

.MoveOut:
	move.w	oX(a0),d0			; Move in
	subi.w	#$20,d0
	move.w	d0,oX(a0)
	bsr.w	BookmarkObject			; Set bookmark
	tst.w	oX(a0)				; Is the text still on screen?
	bpl.s	.MoveOut			; If so, branch
	cmpi.w	#-$35,oX(a0)			; Is the text fully off screen?
	bcc.s	.MoveOut			; If not, branch
	bsr.w	BookmarkObject			; Set bookmark
	
	lea	menuOptions.w,a2		; Set option ID
	moveq	#0,d0
	move.b	menuSel.w,d0
	lea	(a2,d0.w),a2
	move.b	(a2),d0
	move.b	d0,oMenuOption(a0)
	bsr.w	ObjMenu_SetOption

	move.w	#$D3,oX(a0)			; Move to right side of screen
	
.MoveIn:
	bsr.w	BookmarkObject			; Set bookmark
	move.w	oX(a0),d0			; Move in
	subi.w	#$10,d0
	move.w	d0,oX(a0)
	cmpi.w	#$53,oX(a0)			; Is the text fully on screen?
	bcc.s	.MoveIn				; If not, branch
	move.w	#$53,oX(a0)			; Stop moving
	
	move.w	#$A000|($D800/$20),oTile(a0)	; Highlight text
	bra.w	ObjMenu_WaitSelection		; Wait for selection

; -------------------------------------------------------------------------

ObjMenu_WaitSelection:
	move.b	#3,oMenuAllowSel(a0)		; Allow selection
	bsr.w	BookmarkObject			; Set bookmark

.CheckButtons:
	lea	menuOptions.w,a2		; Options buffer
	btst	#2,p1CtrlHold.w			; Has left been pressed?
	bne.s	ObjMenu_SelectLeft		; If so, branch
	btst	#3,p1CtrlHold.w			; Has right been pressed?
	bne.w	ObjMenu_SelectRight		; If so, branch

	move.b	p1CtrlTap.w,d0			; Has any of the face buttons been pressed?
	andi.b	#%11110000,d0
	bne.w	ObjMenu_SelectOption		; If so, branch

	tst.w	timer.w				; Has the timer run out?
	beq.w	ObjMenu_TimeOut			; If so, branch

	bsr.w	BookmarkObject			; Set bookmark
	bra.s	.CheckButtons			; Check buttons

; -------------------------------------------------------------------------

ObjMenu_SelectLeft:
	move.w	#$1E0,timer.w			; Reset timer
	
	moveq	#0,d0				; Move selection left
	move.b	menuSel.w,d0
	subq.b	#1,d0
	move.b	(a2,d0.w),d1
	cmpi.b	#$FF,d1				; Should we stop?
	beq.s	.End				; If so, branch
	
	move.b	d0,menuSel.w			; Set selection
	bra.w	ObjMenu_MoveRight		; Move text right

.End:
	rts

; -------------------------------------------------------------------------

ObjMenu_SelectRight:
	move.w	#$1E0,timer.w			; Reset timer
	
	moveq	#0,d0				; Move selection right
	move.b	menuSel.w,d0
	addq.b	#1,d0
	move.b	(a2,d0.w),d1
	cmpi.b	#$FF,d1				; Should we stop?
	beq.s	.End				; If so, branch
	
	move.b	d0,menuSel.w			; Set selection
	bra.w	ObjMenu_MoveLeft		; Move text left

.End:
	rts

; -------------------------------------------------------------------------

ObjMenu_SelectOption:
	lea	menuOptions.w,a2		; Get option ID
	moveq	#0,d0
	move.b	menuSel.w,d0
	lea	(a2,d0.w),a2
	move.b	(a2),d0
	subq.b	#1,d0				; Make it zero based
	bcc.s	.SetExitFlag			; If it hasn't underflowed, branch
	move.b	#1,d0				; If it has, use new game option

.SetExitFlag:
	move.b	d0,exitFlag.w			; Set exit flag

.Done:
	bsr.w	BookmarkObject			; Set bookmark
	bra.s	.Done				; Remain static

; -------------------------------------------------------------------------

ObjMenu_TimeOut:
	move.b	#$FF,exitFlag.w			; Go to attract mode

.Done:
	bsr.w	BookmarkObject			; Set bookmark
	bra.s	.Done				; Remain static

; -------------------------------------------------------------------------

ObjMenu_CheatActivated:
	move.b	d0,exitFlag.w			; Set exit flag

.Done:
	bsr.w	BookmarkObject			; Set bookmark
	bra.s	.Done				; Remain static

; -------------------------------------------------------------------------

ObjMenu_CloudsCheat:
	moveq	#0,d0				; Get pointer to current cheat button
	lea	.Cheat(pc),a2
	move.b	oMenuCloudsIdx(a0),d0
	lea	(a2,d0.w),a2

	btst	#6,p1CtrlHold.w			; Is A being held?
	beq.s	.Failed				; If not, branch

	move.b	p1CtrlTap.w,d0			; Get current buttons being tapped
	move.b	(a2),d1				; Get current cheat button
	cmp.b	d1,d0				; Do they match?
	bne.s	.Failed				; If not, branch

	addq.b	#1,oMenuCloudsIdx(a0)		; Advance cheat
	cmpi.b	#.CheatEnd-.Cheat,oMenuCloudsIdx(a0)
	beq.s	.Activate			; If the cheat is now done, branch
	bra.s	.NotActivated			; Not done yet

.Failed:
	tst.b	d0				; Were any buttons tapped at all?
	beq.s	.NotActivated			; If not, branch
	clr.b	oMenuCloudsIdx(a0)		; Reset cheat

.NotActivated:
	moveq	#0,d0				; Not activated
	rts

.Activate:
	bsr.w	ObjMenu_PlayRingSound		; Play ring sound
	moveq	#-1,d0				; Activated
	move.b	d0,cloudsCtrlFlag.w		; Enable cloud control
	rts

; -------------------------------------------------------------------------

.Cheat:
	dc.b	1, 2, 2, 2, 2, 1
.CheatEnd:
	dc.b	$FF
	even

; -------------------------------------------------------------------------

ObjMenu_ChkCloudCtrl:
	tst.b	cloudsCtrlFlag.w		; Is cloud control enabled?
	beq.s	.End				; If not, branch
	move.b	p2CtrlHold.w,d0			; Get player 2 buttons
	beq.s	.End				; If nothing is being pressed, branch
	move.w	#$1E0,timer.w			; Reset timer

.End:
	rts

; -------------------------------------------------------------------------

ObjMenu_SoundTestCheat:
	moveq	#0,d0				; Get pointer to current cheat button
	lea	.Cheat(pc),a2
	move.b	oMenuSndTestIdx(a0),d0
	lea	(a2,d0.w),a2

	move.b	p1CtrlTap.w,d0			; Get current buttons being tapped
	move.b	(a2),d1				; Get current cheat button
	cmp.b	d1,d0				; Do they match?
	bne.s	.Failed				; If not, branch

	addq.b	#1,oMenuSndTestIdx(a0)		; Advance cheat
	cmpi.b	#.CheatEnd-.Cheat,oMenuSndTestIdx(a0)
	beq.s	.Activate			; If the cheat is now done, branch
	bra.s	.NotActivated			; Not done yet

.Failed:
	tst.b	d0				; Were any buttons tapped at all?
	beq.s	.NotActivated			; If not, branch
	clr.b	oMenuSndTestIdx(a0)		; Reset cheat

.NotActivated:
	moveq	#0,d0				; Not activated
	rts

.Activate:
	bsr.w	ObjMenu_PlayRingSound		; Play ring sound
	moveq	#7,d0				; Exit to sound test
	rts

; -------------------------------------------------------------------------

.Cheat:
	dc.b	2, 2, 2, 4, 8, $40
.CheatEnd:
	dc.b	$FF
	even

; -------------------------------------------------------------------------

ObjMenu_StageSelCheat:
	moveq	#0,d0				; Get pointer to current cheat button
	lea	.Cheat(pc),a2
	move.b	oMenuStgSelIdx(a0),d0
	lea	(a2,d0.w),a2

	move.b	p1CtrlTap.w,d0			; Get current buttons being tapped
	move.b	(a2),d1				; Get current cheat button
	cmp.b	d1,d0				; Do they match?
	bne.s	.Failed				; If not, branch

	addq.b	#1,oMenuStgSelIdx(a0)		; Advance cheat
	cmpi.b	#.CheatEnd-.Cheat,oMenuStgSelIdx(a0)
	beq.s	.Activate			; If the cheat is now done, branch
	bra.s	.NotActivated			; Not done yet

.Failed:
	tst.b	d0				; Were any buttons tapped at all?
	beq.s	.NotActivated			; If not, branch
	clr.b	oMenuStgSelIdx(a0)		; Reset cheat

.NotActivated:
	moveq	#0,d0				; Not activated
	rts

.Activate:
	bsr.w	ObjMenu_PlayRingSound		; Play ring sound
	moveq	#8,d0				; Exit to stage select
	rts

; -------------------------------------------------------------------------

.Cheat:
	dc.b	1, 2, 2, 4, 8, $10
.CheatEnd:
	dc.b	$FF
	even

; -------------------------------------------------------------------------

ObjMenu_BestTimesCheat:
	moveq	#0,d0				; Get pointer to current cheat button
	lea	.Cheat(pc),a2
	move.b	oMenuBestTmsIdx(a0),d0
	lea	(a2,d0.w),a2

	move.b	p1CtrlTap.w,d0			; Get current buttons being tapped
	move.b	(a2),d1				; Get current cheat button
	cmp.b	d1,d0				; Do they match?
	bne.s	.Failed				; If not, branch

	addq.b	#1,oMenuBestTmsIdx(a0)		; Advance cheat
	cmpi.b	#.CheatEnd-.Cheat,oMenuBestTmsIdx(a0)
	beq.s	.Activate			; If the cheat is now done, branch
	bra.s	.NotActivated			; Not done yet

.Failed:
	tst.b	d0				; Were any buttons tapped at all?
	beq.s	.NotActivated			; If not, branch
	clr.b	oMenuBestTmsIdx(a0)		; Reset cheat

.NotActivated:
	moveq	#0,d0				; Not activated
	rts

.Activate:
	bsr.w	ObjMenu_PlayRingSound		; Play ring sound
	moveq	#9,d0				; Exit to best times screen
	rts

; -------------------------------------------------------------------------

.Cheat:
	dc.b	8, 8, 1, 1, 2, $20
.CheatEnd:
	dc.b	$FF
	even

; -------------------------------------------------------------------------

ObjMenu_PlayRingSound:
	move.b	#$95,fmSndQueue.w		; Play ring sound
	rts

; -------------------------------------------------------------------------

ObjMenu_SetOption:
	moveq	#0,d0				; Get option
	move.b	oMenuOption(a0),d0
	move.b	d0,oMapFrame(a0)

	move.l	a0,-(sp)			; Load text art
	add.w	d0,d0
	move.w	.Text(pc,d0.w),d0
	lea	.Text(pc,d0.w),a0
	VDPCMD	move.l,$D800,VRAM,WRITE,VDPCTRL
	bsr.w	NemDec
	movea.l	(sp)+,a0
	rts

; -------------------------------------------------------------------------

.Text:
	dc.w	Art_PressStartText-.Text
	dc.w	Art_PressStartText-.Text
	dc.w	Art_NewGameText-.Text
	dc.w	Art_ContinueText-.Text
	dc.w	Art_TimeAttackText-.Text
	dc.w	Art_RamDataText-.Text
	dc.w	Art_DAGardenText-.Text
	dc.w	Art_VisualModeText-.Text

; -------------------------------------------------------------------------
; Menu mappings
; -------------------------------------------------------------------------

MapSpr_Menu:
	include	"title/data/menu.spr.asm"
	even

; -------------------------------------------------------------------------
; Menu arrow option
; -------------------------------------------------------------------------

	rsset	oVars
oArrowDelay	rs.b	1			; Animation delay counter
oArrowFrame	rs.b	1			; Animation frame
		rs.b	2
oArrowID	rs.b	1			; Text ID
		rs.b	3
oArrowParent	rs.w	1			; Parent object

; -------------------------------------------------------------------------

ObjMenuArrow:
	move.l	#MapSpr_MenuArrow,oMap(a0)	; Set mappings
	move.w	#$A000|($DC00/$20),oTile(a0)	; Set sprite tile ID
	move.b	#%1,oFlags(a0)			; Set flags
	move.w	#181,oY(a0)			; Set Y position
	move.w	#72,oX(a0)			; Set left arrow X position
	tst.b	oArrowID(a0)			; Is this the right arrow?
	beq.s	ObjMenuArrow_Left		; If not, branch
	move.w	#168,oX(a0)			; Set right arrow X position

; -------------------------------------------------------------------------

ObjMenuArrow_Right:
	movea.w	oArrowParent(a0),a1		; Get parent object
	tst.b	oMenuAllowSel(a1)		; Is selection enabled?
	bne.s	.CheckOption			; If so, branch

.Invisible:
	clr.b	oMapFrame(a0)			; Don't display
	clr.w	oArrowDelay(a0)

	bsr.w	BookmarkObject			; Set bookmark
	bra.s	ObjMenuArrow_Right		; Check display

.CheckOption:
	lea	menuOptions.w,a2		; Get option on the right
	moveq	#0,d0
	move.b	menuSel.w,d0
	addq.b	#1,d0
	move.b	(a2,d0.w),d0
	cmpi.b	#$FF,d0				; Is there no options on the right?
	beq.s	.Invisible			; If so, branch

	moveq	#0,d0				; Display animation frame
	move.b	oArrowFrame(a0),d0
	move.b	.Frames(pc,d0.w),oMapFrame(a0)

	addi.b	#$10,oArrowDelay(a0)		; Increment animation delay counter
	bcc.s	.Displayed			; If it hasn't overflowed, branch
	addq.b	#1,oArrowFrame(a0)		; Increment animation frame
	cmpi.b	#.FramesEnd-.Frames,oArrowFrame(a0)
	bcs.s	.Displayed			; Branch if it doesn't need to wrap
	clr.b	oArrowFrame(a0)			; Wrap to the start

.Displayed:
	bsr.w	BookmarkObject			; Set bookmark
	bra.s	ObjMenuArrow_Right		; Check display

; -------------------------------------------------------------------------

.Frames:
	dc.b	4, 5, 6
.FramesEnd:
	even

; -------------------------------------------------------------------------

ObjMenuArrow_Left:
	movea.w	oArrowParent(a0),a1		; Get parent object
	tst.b	oMenuAllowSel(a1)		; Is selection enabled?
	bne.s	.CheckOption			; If so, branch

.Invisible:
	clr.b	oMapFrame(a0)			; Don't display
	clr.w	oArrowDelay(a0)

	bsr.w	BookmarkObject			; Set bookmark
	bra.s	ObjMenuArrow_Left		; Check display

.CheckOption:
	lea	menuOptions.w,a2		; Get option on the left
	moveq	#0,d0
	move.b	menuSel.w,d0
	subq.b	#1,d0
	move.b	(a2,d0.w),d0
	cmpi.b	#$FF,d0				; Is there no options on the right?
	beq.s	.Invisible			; If so, branch

	moveq	#0,d0				; Display animation frame
	move.b	oArrowFrame(a0),d0
	move.b	.Frames(pc,d0.w),oMapFrame(a0)

	addi.b	#$10,oArrowDelay(a0)		; Increment animation delay counter
	bcc.s	.Displayed			; If it hasn't overflowed, branch
	addq.b	#1,oArrowFrame(a0)		; Increment animation frame
	cmpi.b	#.FramesEnd-.Frames,oArrowFrame(a0)
	bcs.s	.Displayed			; Branch if it doesn't need to wrap
	clr.b	oArrowFrame(a0)			; Wrap to the start

.Displayed:
	bsr.w	BookmarkObject			; Set bookmark
	bra.s	ObjMenuArrow_Left		; Check display

; -------------------------------------------------------------------------

.Frames:
	dc.b	1, 2, 3
.FramesEnd:
	even

; -------------------------------------------------------------------------
; Menu arrow mappings
; -------------------------------------------------------------------------

MapSpr_MenuArrow:
	include	"title/data/menuarrow.spr.asm"
	even

; -------------------------------------------------------------------------
; Copyright text object
; -------------------------------------------------------------------------

ObjCopyright:
	move.l	#MapSpr_Copyright,oMap(a0)	; Set mappings
	move.w	#$E000|($DE00/$20),oTile(a0)	; Set sprite tile ID
	move.b	#%1,oFlags(a0)			; Set flags
	if REGION=USA
		move.w	#208,oY(a0)		; Set Y position
		move.w	#80,oX(a0)		; Set X position
		move.b	#1,oMapFrame(a0)	; Display with trademark
	else
		move.w	#91,oX(a0)		; Set X position
		move.w	#208,oY(a0)		; Set Y position
	endif

; -------------------------------------------------------------------------

.Done:
	bsr.w	BookmarkObject			; Set bookmark
	bra.s	.Done				; Remain static

; -------------------------------------------------------------------------
; Copyright text mappings
; -------------------------------------------------------------------------

MapSpr_Copyright:
	if REGION=USA
		include	"title/data/copyright.usa.spr.asm"
	else
		include	"title/data/copyright.jpeu.spr.asm"
	endif
	even

; -------------------------------------------------------------------------
; Trademark symbol object
; -------------------------------------------------------------------------

ObjTM:
	move.l	#MapSpr_TM,oMap(a0)		; Set mappings
	if REGION=USA				; Set sprite tile ID
		move.w	#$E000|($DFC0/$20),oTile(a0)
	else
		move.w	#$E000|($DF20/$20),oTile(a0)
	endif
	move.b	#%1,oFlags(a0)			; Set flags
	move.w	#194,oX(a0)			; Set X position
	move.w	#131,oY(a0)			; Set Y position
	
; -------------------------------------------------------------------------

.Done:
	bsr.w	BookmarkObject			; Set bookmark
	bra.s	.Done				; Remain static

; -------------------------------------------------------------------------
; Trademark symbol mappings
; -------------------------------------------------------------------------

MapSpr_TM:
	include	"title/data/tm.spr.asm"
	even

; -------------------------------------------------------------------------
; Load tilemaps
; -------------------------------------------------------------------------

LoadTilemaps:
	lea	VDPCTRL,a2			; VDP control port
	lea	VDPDATA,a3			; VDP data port

	lea	Map_Emblem(pc),a0		; Draw emblem
	VDPCMD	move.l,$C206,VRAM,WRITE,d0
	moveq	#$1A-1,d1
	moveq	#$13-1,d2
	bsr.s	LoadFgTilemap

	lea	Map_Water(pc),a0		; Draw water (left side)
	VDPCMD	move.l,$EA00,VRAM,WRITE,d0
	moveq	#$20-1,d1
	moveq	#8-1,d2
	bsr.s	LoadBgTilemap

	lea	Map_Water(pc),a0		; Draw water (right side)
	VDPCMD	move.l,$EA40,VRAM,WRITE,d0
	moveq	#$20-1,d1
	moveq	#8-1,d2
	bsr.s	LoadBgTilemap

	lea	Map_Mountains(pc),a0		; Draw mountains
	VDPCMD	move.l,$E580,VRAM,WRITE,d0
	moveq	#$20-1,d1
	moveq	#9-1,d2

; -------------------------------------------------------------------------
; Draw background tilemap
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - VDP command
;	d1.w - Width
;	d2.w - Height
;	a0.l - Pointer to tilemap
;	a2.l - VDP control port
;	a3.l - VDP data port
; -------------------------------------------------------------------------

LoadBgTilemap:
	move.l	#$800000,d4			; Row delta

.DrawRow:
	move.l	d0,(a2)				; Set VDP command
	move.w	d1,d3				; Get width

.DrawTile:
	move.w	#$300,d6			; Get tile ID
	move.b	(a0)+,d6
	bne.s	.WriteTile			; If it's not blank, branch
	move.w	#0,d6

.WriteTile:
	move.w	d6,(a3)				; Write tile ID
	dbf	d3,.DrawTile			; Loop until row is written
	
	add.l	d4,d0				; Next row
	dbf	d2,.DrawRow			; Loop until map is drawn
	rts

; -------------------------------------------------------------------------
; Draw foreground tilemap
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - VDP command
;	d1.w - Width
;	d2.w - Height
;	a0.l - Pointer to tilemap
;	a2.l - VDP control port
;	a3.l - VDP data port
; -------------------------------------------------------------------------

LoadFgTilemap:
	move.l	#$800000,d4			; Row delta

.DrawRow:
	move.l	d0,(a2)				; Set VDP command
	move.w	d1,d3				; Get width

.DrawTile:
	move.w	(a0)+,d6			; Get tile ID
	beq.s	.WriteTile			; If it's blank, branch
	addi.w	#$C000|($6D80/$20),d6		; Add base tile ID

.WriteTile:
	addi.w	#0,d6				; Write tile ID
	move.w	d6,(a3)
	dbf	d3,.DrawTile			; Loop until row is written
	
	add.l	d4,d0				; Next row
	dbf	d2,.DrawRow			; Loop until map is drawn
	rts

; -------------------------------------------------------------------------
; Data
; -------------------------------------------------------------------------

Map_Water:
	incbin	"title/data/water.map"
	even

Map_Mountains:
	incbin	"title/data/mountains.map"
	even

Map_Emblem:
	incbin	"title/data/emblem.map"
	even

Art_Water:
	incbin	"title/data/water.art.nem"
	even

Art_Mountains:
	incbin	"title/data/mountains.art.nem"
	even

Art_Emblem:
	incbin	"title/data/emblem.art.nem"
	even

Art_Banner:
	incbin	"title/data/banner.art.nem"
	even

Art_Planet:
	incbin	"title/data/planet.art.nem"
	even

Art_Sonic:
	incbin	"title/data/sonic.art.nem"
	even

Art_SolidColor:
	incbin	"title/data/solidcolor.art.nem"
	even

Art_NewGameText:
	incbin	"title/data/textnewgame.art.nem"
	even

Art_ContinueText:
	incbin	"title/data/textcontinue.art.nem"
	even

Art_TimeAttackText:
	incbin	"title/data/texttimeattack.art.nem"
	even

Art_RamDataText:
	incbin	"title/data/textramdata.art.nem"
	even

Art_DAGardenText:
	incbin	"title/data/textdagarden.art.nem"
	even

Art_VisualModeText:
	incbin	"title/data/textvisualmode.art.nem"
	even

Art_PressStartText:
	incbin	"title/data/textpressstart.art.nem"
	even

Art_MenuArrow:
	incbin	"title/data/menuarrow.art.nem"
	even

Art_Copyright:
	incbin	"title/data/copyright.art.nem"
	even

	if REGION=USA
Art_TM:
		incbin	"title/data/tm.usa.art.nem"
		even

Art_CopyrightTM:
		incbin	"title/data/copyrighttm.art.nem"
		even
	else
Art_TM:
		incbin	"title/data/tm.jpeu.art.nem"
		even
	endif

; -------------------------------------------------------------------------

End:

; -------------------------------------------------------------------------
