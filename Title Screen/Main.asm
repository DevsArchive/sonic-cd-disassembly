; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Title screen Main CPU program
; -------------------------------------------------------------------------

	include	"_Include/Common.i"
	include	"_Include/Main CPU.i"
	include	"_Include/Main CPU Variables.i"
	include	"_Include/Sound.i"
	include	"_Include/MMD.i"
	include	"Title Screen/_Common.i"

; -------------------------------------------------------------------------
; Image buffer VRAM constants
; -------------------------------------------------------------------------

IMGVRAM		EQU	$0020			; VRAM address
IMGV1LEN	EQU	IMGLENGTH/2		; Part 1 length

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
oVars		rs.b	$40-__rs		; Object specific variables
oSize		rs.b	0			; Size of structure

; -------------------------------------------------------------------------
; Variables
; -------------------------------------------------------------------------

	rsset	WORKRAM+$FF00A000
VARSSTART	rs.b	0			; Start of variables
cloudsImage	rs.b	IMGLENGTH		; Clouds image buffer
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
OBJCOUNT	EQU	(__rs-objects)/oSize

	if REGION=JAPAN
		rs.b	$1200
	else
		rs.b	$1180
	endif

nemBuffer	rs.b	$200			; Nemesis decompression buffer
palette		rs.w	$40			; Palette buffer
fadePalette	rs.w	$40			; Fade palette buffer
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
	
	bsr.w	WaitSubCPUStart			; Wait for the Sub CPU program to start
	bsr.w	GiveWordRAMAccess		; Give Word RAM access
	bsr.w	WaitSubCPUInit			; Wait for the Sub CPU program to finish initializing
	
	bsr.w	InitMD				; Initialize Mega Drive hardware
	bsr.w	ClearSprites			; Clear sprites
	bsr.w	ClearObjects			; Clear objects
	bsr.w	DrawTilemaps			; Draw tilemaps
	
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
	
	bsr.w	DrawCloudsMap			; Draw clouds map
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
	bsr.w	Copy128
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
	
	; Show clouds buffer 2, render to buffer 1
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
	bsr.w	GetCloudsImage			; Get rendered clouds image
	bsr.w	GiveWordRAMAccess		; Give back Word RAM access

	tst.b	exitFlag.w			; Are we exiting the title screen?
	bne.s	.Exit				; If so, branch
	
	; Show clouds buffer 1, render to buffer 2
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
	bsr.w	GetCloudsImage			; Get rendered clouds image
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
	dc.w	VInt_CopyClouds1_1-.Routines	; Copy 1st half of rendered clouds image to buffer 1
	dc.w	VInt_CopyClouds1_2-.Routines	; Copy 2nd half of rendered clouds image to buffer 1
	dc.w	VInt_CopyClouds2_1-.Routines	; Copy 1st half of rendered clouds image to buffer 2
	dc.w	VInt_CopyClouds2_2-.Routines	; Copy 2nd half of rendered clouds image to buffer 2
	dc.w	VInt_Nothing-.Routines		; Does nothing
	dc.w	VInt_NoClouds-.Routines		; Don't render clouds

; -------------------------------------------------------------------------

VInt_CopyClouds1_1:
	DMA68K	sprites,$D400,$280,VRAM		; Copy sprite data
	COPYIMG	cloudsImage, 0, 0		; Copy rendered clouds image
	jsr	ReadControllers(pc)		; Read controllers
	bra.w	VInt_Finish			; Finish

; -------------------------------------------------------------------------

VInt_CopyClouds1_2:
	DMA68K	sprites,$D400,$280,VRAM		; Copy sprite data
	COPYIMG	cloudsImage, 0, 1		; Copy rendered clouds image
	jsr	ReadControllers(pc)		; Read controllers
	bra.w	VInt_Finish			; Finish

; -------------------------------------------------------------------------

VInt_CopyClouds2_1:
	DMA68K	sprites,$D400,$280,VRAM		; Copy sprite data
	COPYIMG	cloudsImage, 1, 0		; Copy rendered clouds image
	jsr	ReadControllers(pc)		; Read controllers
	bra.w	VInt_Finish			; Finish

; -------------------------------------------------------------------------

VInt_CopyClouds2_2:
	DMA68K	sprites,$D400,$280,VRAM		; Copy sprite data
	COPYIMG	cloudsImage, 1, 1		; Copy rendered clouds image
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
; Unused functions to show a clouds buffer
; -------------------------------------------------------------------------
; PARAMETERS:
;	a1.l - VDP control port
;	a2.l - VDP data port
; -------------------------------------------------------------------------

ShowCloudsBuf1:
	move.w	#$8F20,(a1)			; Set for every 8 scanlines
	VDPCMD	move.l,$D002,VRAM,WRITE,VDPCTRL	; Write background scroll data
	moveq	#0,d0				; Show clouds buffer 1
	bra.s	ShowCloudsBuf

; -------------------------------------------------------------------------

ShowCloudsBuf2:
	move.w	#$8F20,(a1)			; Set for every 8 scanlines
	VDPCMD	move.l,$D002,VRAM,WRITE,VDPCTRL	; Write background scroll data
	move.w	#$100,d0			; Show clouds buffer 2

; -------------------------------------------------------------------------

ShowCloudsBuf:
	rept	(IMGHEIGHT-8)/8			; Set scroll offset for clouds
		move.w	d0,(a2)
	endr
	move.w	#$8F02,(a1)			; Restore autoincrement
	rts

; -------------------------------------------------------------------------
; Scroll background (show clouds buffer 1)
; -------------------------------------------------------------------------

ScrollBgBuf1:
	lea	hscroll.w,a1			; Show clouds buffer 1
	moveq	#(IMGHEIGHT-8)-1,d1

.ShowClouds:
	clr.l	(a1)+
	dbf	d1,.ShowClouds

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
; Scroll background (show clouds buffer 2)
; -------------------------------------------------------------------------

ScrollBgBuf2:
	lea	hscroll.w,a1			; Show clouds buffer 2
	moveq	#(IMGHEIGHT-8)-1,d1

.ShowClouds:
	move.l	#$100,(a1)+
	dbf	d1,.ShowClouds

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
	and.b	d1,d0				; Store tapped buttons
	move.b	d0,(a0)+
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
; Draw clouds tilemap
; -------------------------------------------------------------------------

DrawCloudsMap:
	lea	VDPCTRL,a2			; VDP control port
	lea	VDPDATA,a3			; VDP data port

	move.w	#$8001,d6			; Draw buffer 1 tilemap
	VDPCMD	move.l,$E000,VRAM,WRITE,d0
	moveq	#IMGWTILE-1,d1
	moveq	#IMGHTILE-1,d2
	bsr.s	.DrawMap

	move.w	#$8181,d6			; Draw buffer 2 tilemap
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
	cmpi.b	#1,GACOMSTAT2			; Has the Sub CPU responded?
	beq.s	.CommDone			; If so, branch
	addq.w	#1,subWaitTime.w		; Increment wait time
	bcc.s	.WaitSubCPU			; If we should wait some more, loop

.CommDone:
	clr.l	subWaitTime.w			; Reset Sub CPU wait time
	move.b	#0,GACOMCMD2			; Respond to the Sub CPU

.WaitSubCPU2:
	tst.b	GACOMSTAT2			; Has the Sub CPU responded?
	beq.s	.End				; If so, branch
	addq.w	#1,subWaitTime.w		; Increment wait time
	bcc.s	.WaitSubCPU2			; If we should wait some more, loop

.End:
	clr.l	subWaitTime.w			; Reset Sub CPU wait time
	rts

; -------------------------------------------------------------------------
; Wait for the Sub CPU program to start
; -------------------------------------------------------------------------

WaitSubCPUStart:
	cmpi.b	#4,subFailCount.w		; Is the Sub CPU deemed unreliable?
	bcc.s	.End				; If so, branch
	
	btst	#7,GASUBFLAG			; Has the Sub CPU program started?
	bne.s	.End				; If so, branch
	addq.w	#1,subWaitTime.w		; Increment wait time
	bcc.s	WaitSubCPUStart			; If we should wait some more, loop
	addq.b	#1,subFailCount.w		; Increment Sub CPU fail count

.End:
	clr.l	subWaitTime.w			; Reset Sub CPU wait time
	rts

; -------------------------------------------------------------------------
; Wait for the Sub CPU program to finish initializing
; -------------------------------------------------------------------------

WaitSubCPUInit:
	cmpi.b	#4,subFailCount.w		; Is the Sub CPU deemed unreliable?
	bcc.s	.End				; If so, branch
	
	btst	#7,GASUBFLAG			; Has the Sub CPU program initialized?
	beq.s	.End				; If so, branch
	addq.w	#1,subWaitTime.w		; Increment wait time
	bcc.s	WaitSubCPUInit			; If we should wait some more, loop
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
	incbin	"Title Screen/Data/Palette (Initialization).bin"
.PaletteEnd:
	even

; -------------------------------------------------------------------------
; Palette
; -------------------------------------------------------------------------

Pal_Title:
	incbin	"Title Screen/Data/Palette.bin"
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
; Get clouds image
; -------------------------------------------------------------------------

GetCloudsImage:
	lea	WORDRAM2M+IMGBUFFER,a1		; Rendered image in Word RAM
	lea	cloudsImage.w,a2		; Destination buffer
	move.w	#(IMGLENGTH/$800)-1,d7		; Number of $800 byte chunks to copy

.CopyChunks:
	rept	$800/$80			; Copy $800 bytes
		bsr.s	Copy128
	endr
	dbf	d7,.CopyChunks			; Loop until chunks are copied
	rts

; -------------------------------------------------------------------------
; Copy 128 bytes from a source to a destination buffer
; -------------------------------------------------------------------------
; PARAMAETERS:
;	a1.l - Pointer to source
;	a2.l - Pointer to destination buffer
; -------------------------------------------------------------------------

Copy128:
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
	bsr.w	NemDec_BuildCodeTable
	move.b	(a0)+,d5			; Get first word of compressed data
	asl.w	#8,d5
	move.b	(a0)+,d5
	move.w	#16,d6				; Set initial shift value
	bsr.s	NemDec_ProcessCompressedData
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

	bra.s	NemBCT_Loop			; Loop

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

	include	"Title Screen/Objects/Sonic/Main.asm"
	include	"Title Screen/Objects/Banner/Main.asm"
	include	"Title Screen/Objects/Planet/Main.asm"
	include	"Title Screen/Objects/Menu/Main.asm"
	include	"Title Screen/Objects/Copyright/Main.asm"

; -------------------------------------------------------------------------
; Draw tilemaps
; -------------------------------------------------------------------------

DrawTilemaps:
	lea	VDPCTRL,a2			; VDP control port
	lea	VDPDATA,a3			; VDP data port

	lea	Map_Emblem(pc),a0		; Draw emblem
	VDPCMD	move.l,$C206,VRAM,WRITE,d0
	moveq	#$1A-1,d1
	moveq	#$13-1,d2
	bsr.s	DrawFgTilemap

	lea	Map_Water(pc),a0		; Draw water (left side)
	VDPCMD	move.l,$EA00,VRAM,WRITE,d0
	moveq	#$20-1,d1
	moveq	#8-1,d2
	bsr.s	DrawBgTilemap

	lea	Map_Water(pc),a0		; Draw water (right side)
	VDPCMD	move.l,$EA40,VRAM,WRITE,d0
	moveq	#$20-1,d1
	moveq	#8-1,d2
	bsr.s	DrawBgTilemap

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

DrawBgTilemap:
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
	dbf	d3,.DrawTile			; Loop until row is drawn
	
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

DrawFgTilemap:
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
	incbin	"Title Screen/Data/Water Mappings.bin"
	even

Map_Mountains:
	incbin	"Title Screen/Data/Moutains Mappings.bin"
	even

Map_Emblem:
	incbin	"Title Screen/Data/Emblem Mappings.bin"
	even

Art_Water:
	incbin	"Title Screen/Data/Water Art.nem"
	even

Art_Mountains:
	incbin	"Title Screen/Data/Moutains Art.nem"
	even

Art_Emblem:
	incbin	"Title Screen/Data/Emblem Art.nem"
	even

Art_Banner:
	incbin	"Title Screen/Objects/Banner/Data/Art.nem"
	even

Art_Planet:
	incbin	"Title Screen/Objects/Planet/Data/Art.nem"
	even

Art_Sonic:
	incbin	"Title Screen/Objects/Sonic/Data/Art.nem"
	even

Art_SolidColor:
	incbin	"Title Screen/Data/Solid Color Art.nem"
	even

Art_NewGameText:
	incbin	"Title Screen/Objects/Menu/Data/Art (Text, New Game).nem"
	even

Art_ContinueText:
	incbin	"Title Screen/Objects/Menu/Data/Art (Text, Continue).nem"
	even

Art_TimeAttackText:
	incbin	"Title Screen/Objects/Menu/Data/Art (Text, Time Attack).nem"
	even

Art_RamDataText:
	incbin	"Title Screen/Objects/Menu/Data/Art (Text, RAM Data).nem"
	even

Art_DAGardenText:
	incbin	"Title Screen/Objects/Menu/Data/Art (Text, D.A. Garden).nem"
	even

Art_VisualModeText:
	incbin	"Title Screen/Objects/Menu/Data/Art (Text, Visual Mode).nem"
	even

Art_PressStartText:
	incbin	"Title Screen/Objects/Menu/Data/Art (Text, Press Start).nem"
	even

Art_MenuArrow:
	incbin	"Title Screen/Objects/Menu/Data/Art (Arrow).nem"
	even

Art_Copyright:
	incbin	"Title Screen/Objects/Copyright/Data/Art (Copyright, JPN and EUR).nem"
	even

	if REGION=USA
Art_TM:
		incbin	"Title Screen/Objects/Copyright/Data/Art (TM, USA).nem"
		even

Art_CopyrightTM:
		incbin	"Title Screen/Objects/Copyright/Data/Art (Copyright, USA).nem"
		even
	else
Art_TM:
		incbin	"Title Screen/Objects/Copyright/Data/Art (TM, JPN and EUR).nem"
		even
	endif

; -------------------------------------------------------------------------

End:

; -------------------------------------------------------------------------
