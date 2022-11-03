; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Special stage Main CPU program
; -------------------------------------------------------------------------

	include	"_Include/Common.i"
	include	"_Include/Main CPU.i"
	include	"_Include/Main CPU Variables.i"
	include	"_Include/Sound.i"
	include	"_Include/MMD.i"
	include	"Special Stage/_Common.i"
	include	"Special Stage/_Global Variables.i"
	include	"Special Stage/Stage Data Labels.i"

; -------------------------------------------------------------------------
; Image buffer VRAM constants
; -------------------------------------------------------------------------

IMGVRAM		EQU	$0020			; VRAM address
IMGV1LEN	EQU	$2000			; Part 1 length

; -------------------------------------------------------------------------
; Variables
; -------------------------------------------------------------------------

	rsset	WORKRAM+$FF00B000
VARSSTART	rs.b	0			; Start of variables
stageImage	rs.b	IMGLENGTH		; Stage image buffer
sprites		rs.b	80*8			; Sprite buffer
		rs.b	4
splashArtLoad	rs.b	1			; Splash art load flag
scrollFlags	rs.b	1			; Scroll flags
		rs.b	$7A
sonicArtBuf	rs.b	$300			; Sonic art buffer
		rs.b	$100
mapKosBuffer	rs.b	0			; Map Kosinski decompression buffer
bgHScroll	rs.b	$200			; Background horizontal scroll buffer (integer)
bgHScrollFrac	rs.b	$200			; Background horizontal scroll buffer (fraction)
stageHScroll1	rs.b	$100			; Stage horizontal scroll buffer (buffer 1)
stageHScroll2	rs.b	$100			; Stage horizontal scroll buffer (buffer 2)
		rs.b	$300
demoData	rs.b	$700			; Demo data bufffer
nemBuffer	rs.b	$200			; Nemesis decompression buffer
palette		rs.w	$40			; Palette buffer
fadePalette	rs.w	$40			; Fade palette buffer
paused		rs.b	1			; Paused flag
		rs.b	1
demoActive	rs.b	1			; Demo active flag
fadedOut	rs.b	1			; Faded out flag
flagsCopy	rs.b	1			; Copy of special stage flags
		rs.b	$3B
vintRoutine	rs.w	1			; V-INT routine ID
resultsTimer	rs.w	1			; Results timer
vintCounter	rs.w	1			; V-INT counter
savedSR		rs.w	1			; Saved status register
extraPlayerCnt	rs.w	1			; Extra player count
		rs.b	$56
rngSeed		rs.l	1			; RNG seed
scrollOffset1	rs.l	1			; Background scroll offset 1
scrollOffset2	rs.l	1			; Background scroll offset 2
scrollOffset3	rs.l	1			; Background scroll offset 3
scrollOffset4	rs.l	1			; Background scroll offset 4
scrollOffset5	rs.l	1			; Background scroll offset 5
scrollOffset6	rs.l	1			; Background scroll offset 6
demoDataPtr	rs.l	1			; Demo data pointer
		rs.b	$40
VARSLEN		EQU	__rs-VARSSTART		; Size of variables area

lagCounter	rs.l	1			; Lag counter

; -------------------------------------------------------------------------
; MMD header
; -------------------------------------------------------------------------

	MMD	0, &
		WORKRAMFILE, $9000, &
		Start, 0, 0

; -------------------------------------------------------------------------
; Program start
; -------------------------------------------------------------------------

Start:
	move.l	#VInterrupt,_LEVEL6+2.w		; Set V-INT address
	move.l	#-1,lagCounter.w		; Disable lag counter
	
	bsr.w	WaitSubCPUStart			; Wait for the Sub CPU program to start
	bsr.w	GiveWordRAMAccess		; Give Word RAM access
	bsr.w	WaitSubCPUInit			; Wait for the Sub CPU program to finish initializing
	
	lea	VARSSTART.w,a0			; Clear variables
	move.w	#VARSLEN/4-1,d7

.ClearVars:
	move.l	#0,(a0)+
	dbf	d7,.ClearVars
	
	bsr.w	InitMDStage			; Initialize Mega Drive hardware
	
	lea	Pal_Stage(pc),a0		; Load palette
	lea	palette.w,a1
	moveq	#(Pal_Stage_End-Pal_Stage)/4-1,d7

.SetPalette:
	move.l	(a0)+,(a1)+
	dbf	d7,.SetPalette
	
	VDPCMD	move.l,$8480,VRAM,WRITE,VDPCTRL	; Load time stone art
	lea	Art_TimeStone(pc),a0
	bsr.w	NemDec
	VDPCMD	move.l,$8800,VRAM,WRITE,VDPCTRL	; Load UFO art
	lea	Art_UFO(pc),a0
	bsr.w	NemDec
	VDPCMD	move.l,$A2C0,VRAM,WRITE,VDPCTRL	; Load title card art
	lea	Art_TitleCard(pc),a0
	bsr.w	NemDec
	VDPCMD	move.l,$B040,VRAM,WRITE,VDPCTRL	; Load splash art
	lea	Art_Splash(pc),a0
	bsr.w	NemDec
	VDPCMD	move.l,$DB80,VRAM,WRITE,VDPCTRL	; Load shadow art
	lea	Art_Shadow(pc),a0
	bsr.w	NemDec
	VDPCMD	move.l,$F1E0,VRAM,WRITE,VDPCTRL	; Load items art
	lea	Art_Items(pc),a0
	bsr.w	NemDec
	VDPCMD	move.l,$F5C0,VRAM,WRITE,VDPCTRL	; Load explosion art
	lea	Art_Explosion(pc),a0
	bsr.w	NemDec
	VDPCMD	move.l,$FBA0,VRAM,WRITE,VDPCTRL	; Load HUD art
	lea	Art_HUD(pc),a0
	bsr.w	NemDec
	
	bsr.w	DrawStageMap			; Draw stage map
	bsr.w	LoadStageData			; Load stage data
	
	lea	stageHScroll1.w,a1		; Set stage buffer 1 horizontal scroll data
	; BUG: d1 isn't set to 0 here
	bsr.w	Fill128
	bsr.w	Fill128
	lea	stageHScroll2.w,a1		; Set stage buffer 2 horizontal scroll data
	move.l	#$1000100,d1
	bsr.w	Fill128
	bsr.w	Fill128
	
	bsr.w	UpdateStage			; Render stage
	bsr.w	WaitWordRAMAccess		; Wait for Word RAM access
	bsr.w	Delay				; Delay for a bit
	bsr.w	GetSubCPUData			; Get Sub CPU data
	bsr.w	GiveWordRAMAccess		; Give back Word RAM access
	
	lea	Stage1Demo(pc),a0		; Get stage 1 demo data
	cmpi.b	#5,demoID			; Are we in the stage 6 demo?
	bne.s	.DecompDemo			; If not, branch
	lea	Stage6Demo(pc),a0		; Get stage 6 demo data

.DecompDemo:
	lea	demoData.w,a1			; Load demo data
	bsr.w	KosDec
	move.l	#demoData&$FFFFFF,demoDataPtr.w
	
	bsr.w	PrepFadeFromWhite		; Prepare to fade from white
	bsr.w	VSync				; VSync
	bset	#6,ipxVDPReg1+1			; Enable screen
	move.w	ipxVDPReg1,VDPCTRL
	bsr.w	FadeFromWhite			; Fade from white
	
	move.b	#1,demoActive.w			; Activate the demo
	move.b	#$80,paused.w			; Enable pausing
	move.l	#0,lagCounter.w			; Enable and reset lag counter

; -------------------------------------------------------------------------

MainLoop:
	; Show stage buffer 2, render to stage 1
	bsr.w	HandlePause			; Handle pausing
	bne.w	.Exit				; If we are exiting the stage, branch
	
	bsr.w	UpdateStage			; Start rendering stage
	bsr.w	BGScroll1			; Scroll first background section 
	move.w	#0,vintRoutine.w		; VSync
	bsr.w	VSync
	
	bsr.w	DrawRingCount			; Draw ring count
	bsr.w	DrawUFOCount			; Draw UFO count
	bsr.w	LoadTimeStonePal		; Load time stone palette if stage is beaten
	bsr.w	BGScroll2			; Scroll second background section 
	move.w	#1,vintRoutine.w		; VSync
	bsr.w	VSync
	
	bsr.w	DrawTimer			; Draw timer
	bsr.w	BGScroll3			; Scroll third background section 
	move.w	#4,vintRoutine.w		; VSync
	bsr.w	VSync
	
	bsr.w	WaitWordRAMAccess		; Wait for Word RAM access
	bsr.w	Delay				; Delay
	btst	#0,GASUBFLAG			; Is the stage over?
	bne.w	.Exit				; If so, branch
	bsr.w	GetSubCPUData			; Get Sub CPU data
	bsr.w	GiveWordRAMAccess		; Give back Word RAM access
	
	; Show stage buffer 2, render to stage 1
	bsr.w	HandlePause			; Handle pausing
	bne.w	.Exit				; If we are exiting the stage, branch
	
	bsr.w	UpdateStage			; Start rendering stage
	bsr.w	BGScroll1			; Scroll first background section 
	move.w	#2,vintRoutine.w		; VSync
	bsr.w	VSync
	
	bsr.w	DrawRingCount			; Draw ring count
	bsr.w	DrawUFOCount			; Draw UFO count
	bsr.w	LoadTimeStonePal		; Load time stone palette if stage is beaten
	bsr.w	BGScroll2			; Scroll second background section 
	move.w	#3,vintRoutine.w		; VSync
	bsr.w	VSync
	
	bsr.w	DrawTimer			; Draw timer
	bsr.w	BGScroll3			; Scroll third background section 
	move.w	#4,vintRoutine.w		; VSync
	bsr.w	VSync
	
	bsr.w	WaitWordRAMAccess		; Wait for Word RAM access
	bsr.w	Delay				; Delay
	btst	#0,GASUBFLAG			; Is the stage over?
	bne.s	.Exit				; If so, branch
	bsr.w	GetSubCPUData			; Get Sub CPU data
	bsr.w	GiveWordRAMAccess		; Give back Word RAM access
	
	bra.w	MainLoop			; Loop
	
.Exit:
	move.b	ufoCount,specStageLost		; Mark the stage as beaten or not based on UFOs left
	move.b	specStageFlags,flagsCopy.w	; Copy flags
	move.b	#0,paused.w			; Disable pausing
	move.b	#1,scrollDisable		; Disable scrolling
	
	move.b	specStageFlags,d0		; Was this a normal special stage?
	andi.b	#%11,d0
	beq.w	Results				; If so, go to the results screen
	
	btst	#1,specStageFlags		; Are we in time attack mode?
	beq.s	.MarkDone			; If not, branch
	move.l	specStageTimer,timeAttackTime	; Save time
	move.b	#1,lives			; Mark the stage as beaten or not
	tst.b	ufoCount
	beq.s	.MarkDone
	move.b	#0,lives

.MarkDone:
	bset	#0,GAMAINFLAG			; Tell Sub CPU the stage is over

.WaitSubCPU:
	btst	#0,GASUBFLAG			; Has the Sub CPU responded?
	bne.s	.WaitSubCPU			; If not, wait
	
	moveq	#0,d0				; Clear communication registers
	move.b	d0,GAMAINFLAG
	move.l	d0,GACOMCMD0
	move.l	d0,GACOMCMD4
	move.l	d0,GACOMCMD8
	move.l	d0,GACOMCMDC

	bsr.w	StopZ80				; Play warp sound
	move.b	#FM_SSWARP,FMDrvQueue1+1
	bsr.w	StartZ80
	
	btst	#2,flagsCopy.w			; Were we in the secret special stage?
	beq.s	.FadeToBlack			; If not, branch
	tst.b	specStageLost			; Did we lose the secret special stage?
	beq.w	FadeToWhite			; If not, fade to white

.FadeToBlack:
	bra.w	FadeToBlack			; Fade to black

; -------------------------------------------------------------------------
; Results screen
; -------------------------------------------------------------------------

Results:
	move.w	specStageRings,d0		; Get ring bonus
	mulu.w	#20,d0
	move.l	d0,ringBonus
	move.l	specStageTimer,d0		; Get time bonus
	mulu.w	#20,d0
	move.l	d0,timeBonus
	
	bsr.w	GiveWordRAMAccess		; Give Word RAM access to the Sub CPU
	
	move.b	#0,demoActive.w			; Deactivate the demo
	move.b	#0,specialStage			; Clear special stage flag
	move.w	#6,vintRoutine.w		; Fade to white
	bsr.w	FadeToWhite
	move.b	specStageID,curSpecStage	; Save next stage ID
	move.b	timeStonesSub,timeStones	; Save time stones retrieved
	
	bset	#0,GAMAINFLAG			; Tell Sub CPU the stage is over

.WaitSubCPU:
	btst	#0,GASUBFLAG			; Has the Sub CPU responded?
	bne.s	.WaitSubCPU			; If not, wait
	
	moveq	#0,d0				; Clear communication registers
	move.b	d0,GAMAINFLAG
	move.l	d0,GACOMCMD0
	move.l	d0,GACOMCMD4
	move.l	d0,GACOMCMD8
	move.l	d0,GACOMCMDC
	
	bclr	#6,ipxVDPReg1+1			; Disable screen
	move.w	ipxVDPReg1,VDPCTRL
	
	bsr.w	GiveWordRAMAccess		; Give Word RAM access to the Sub CPU
	
	lea	VARSSTART.w,a0			; Clear variables
	move.w	#VARSLEN/4-1,d7

.ClearVars:
	move.l	#0,(a0)+
	dbf	d7,.ClearVars
	
	move.w	#5,vintRoutine.w		; Set V-BLANK interrupt routine
	
	bsr.w	InitMDResults			; Initialize Mega Drive hardware
	VDPCMD	move.l,$0000,VSRAM,WRITE,VDPCTRL; Set vertical scroll offsets
	move.l	#$100000,VDPDATA
	VDPCMD	move.l,$D000,VRAM,WRITE,VDPCTRL	; Set horizontal scroll offsets
	move.l	#0,VDPDATA

	lea	Pal_Results(pc),a0		; Load palette
	lea	palette.w,a1
	moveq	#(Pal_Results_End-Pal_Results)/4-1,d7

.SetPalette:
	move.l	(a0)+,(a1)+
	dbf	d7,.SetPalette

	VDPCMD	move.l,$0000,VRAM,WRITE,VDPCTRL	; Load results art
	lea	Art_Results(pc),a0
	bsr.w	NemDec
	if REGION=USA				; Load extra players text art
		VDPCMD	move.l,$4000,VRAM,WRITE,VDPCTRL
		lea	Art_ExtraPlayersText(pc),a0
		bsr.w	NemDec
	endif
	
	bsr.w	DrawResultsBase			; Draw results base
	bsr.w	PrepFadeFromWhite		; Prepare to fade from white
	bsr.w	VSync				; VSync
	bset	#6,ipxVDPReg1+1			; Enable screen
	move.w	ipxVDPReg1,VDPCTRL
	bsr.w	FadeFromWhite			; Fade from white
	
	move.w	#8*60,resultsTimer.w		; Results screen lasts 8 seconds
	move.w	#0,extraPlayerCnt.w		; Reset extra player count

; -------------------------------------------------------------------------

Results_MainLoop:
	tst.l	ringBonus			; Tally ring bonus
	beq.s	.TimeBonus
	bsr.w	TallyScore
	subi.l	#20,ringBonus
	bra.s	.Update				; Don't tally time bonus until ring bonus is tallied

.TimeBonus:
	tst.l	timeBonus			; Tally time bonus
	beq.s	.Update
	subi.l	#20,timeBonus
	bsr.w	TallyScore

.Update:
	bsr.w	VSync				; VSync
	
	tst.b	scoreTallied			; Has the score been tallied up yet?
	bne.s	.NoKaChing			; If so, branch
	move.l	timeBonus,d0			; Has the score just finished tallying up?
	add.l	ringBonus,d0
	bne.s	.NoKaChing			; If not, branch
	move.b	#1,scoreTallied			; Mark score as tallied
	
	bsr.w	StopZ80				; Play ka-ching sound
	move.b	#FM_KACHING,FMDrvQueue1+1
	bsr.w	StartZ80

.NoKaChing:
	btst	#7,ctrlTap			; Has the start button been pressed?
	bne.s	.Done				; If so, exit now
	tst.w	resultsTimer.w			; Is it time to exit?
	bne.w	Results_MainLoop		; If not, loop

.Done:
	move.l	ringBonus,d0			; Add remaining bonuses
	add.l	timeBonus,d0
	bsr.w	AddScore
	
	bsr.w	StopZ80				; Play warp sound
	move.b	#FM_SSWARP,FMDrvQueue1+1
	bsr.w	StartZ80
	bsr.w	FadeToWhite			; Fade to white
	rts

; -------------------------------------------------------------------------

timeBonus:
	dc.l	0				; Time bonus
ringBonus:
	dc.l	0				; Ring bonus
scoreTallied:
	dc.b	0				; Score tallied flag
scrollDisable:
	dc.b	0				; Scroll disable flag

; -------------------------------------------------------------------------
; Tally score
; -------------------------------------------------------------------------

TallyScore:
	if REGION<>EUROPE
		move.b	#FM_TALLY,d0		; Play tally sound
		bsr.w	PlayFMSound
	endif
	moveq	#20,d0				; Add 20 points

; -------------------------------------------------------------------------
; Add points to score
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - Points to add
; -------------------------------------------------------------------------

AddScore:
	move.l	score,d1			; Add points
	add.l	d1,d0

.Check1UP:
	cmp.l	nextLifeScore,d0		; Have we crossed an extra life score threshold?
	bcs.s	.SetScore			; If not, branch
	addi.l	#5000,nextLifeScore		; Set next extra life score threshold
	addq.b	#1,lives			; Add life
	addq.w	#1,extraPlayerCnt.w		; Add extra player icon
	cmpi.b	#250,lives			; Do we have more than 249 lives?
	bcs.s	.Check1UP			; If not, check for more lives to add
	move.b	#249,lives			; Cap at 249 lives
	bra.s	.Check1UP			; Check for more lives to add

.SetScore:
	move.l	d0,score			; Set score
	cmpi.l	#1000000,score			; Is the score too large?
	bcs.s	.End				; If not, branch
	move.l	#999999,score			; Cap the score

.End:
	rts

; -------------------------------------------------------------------------
; Handle pausing
; -------------------------------------------------------------------------

HandlePause:
	move.w	vintRoutine.w,d0		; Get V-BLANK interrupt routine ID
	move.w	ctrlData,d1			; Get controller data

.PauseLoop:
	btst	#0,paused.w			; Is the game paused?
	beq.s	.Unpause			; If not, branch
	btst	#5,GASUBFLAG			; Are we exiting the stage manually?
	bne.s	.Exit				; If so, branch
	bset	#5,GAMAINFLAG			; Pause Sub CPU side
	move.w	#7,vintRoutine.w		; VSync
	bsr.w	VSync
	bra.s	.PauseLoop			; Loop

.Unpause:
	bclr	#5,GAMAINFLAG			; Unpause
	bclr	#0,paused.w
	move.w	d1,ctrlData			; Restore controller data
	move.w	d0,vintRoutine.w		; Restore V-BLANK interrupt routine ID
	moveq	#0,d0				; Still in the special stage
	rts

.Exit:
	bclr	#5,GAMAINFLAG			; Unpause
	bclr	#0,paused.w
	move.w	d1,ctrlData			; Restore controller data
	move.w	d0,vintRoutine.w		; Restore V-BLANK interrupt routine ID
	moveq	#1,d0				; Exit the special stage
	rts

; -------------------------------------------------------------------------
; Draw results screen base
; -------------------------------------------------------------------------

DrawResultsBase:
	moveq	#$3D,d5				; "SPECIAL STAGE"
	tst.l	timeBonus			; Did we run out of time?
	beq.s	.DrawHeader			; If so, branch
	moveq	#$3F,d5				; "GOT THEM ALL!!"
	cmpi.b	#%1111111,timeStones		; Do we have all the time stones?
	beq.s	.DrawHeader			; If so, branch
	moveq	#$3E,d5				; "TIME STONES"

.DrawHeader:
	bsr.w	DrawTilemaps			; Draw header

.CheckStone1:
	btst	#0,timeStones			; Draw time stone 1
	beq.s	.CheckStone2
	moveq	#$29,d5
	bsr.w	DrawTilemaps

.CheckStone2:
	btst	#1,timeStones			; Draw time stone 2
	beq.s	.CheckStone3
	moveq	#$2A,d5
	bsr.w	DrawTilemaps

.CheckStone3:
	btst	#2,timeStones			; Draw time stone 3
	beq.s	.CheckStone4
	moveq	#$2B,d5
	bsr.w	DrawTilemaps

.CheckStone4:
	btst	#3,timeStones			; Draw time stone 4
	beq.s	.CheckStone5
	moveq	#$2C,d5
	bsr.w	DrawTilemaps

.CheckStone5:
	btst	#4,timeStones			; Draw time stone 5
	beq.s	.CheckStone6
	moveq	#$2D,d5
	bsr.w	DrawTilemaps

.CheckStone6:
	btst	#5,timeStones			; Draw time stone 6
	beq.s	.CheckStone7
	moveq	#$2E,d5
	bsr.w	DrawTilemaps

.CheckStone7:
	btst	#6,timeStones			; Draw time stone 7
	beq.s	.DrawSmallText
	moveq	#$2F,d5
	bsr.w	DrawTilemaps

.DrawSmallText:
	move.l	#$33323130,d5			; Draw small text
	jsr	DrawTilemaps
	move.l	#$363534,d5
	jsr	DrawTilemaps
	rts

; -------------------------------------------------------------------------
; Palettes
; -------------------------------------------------------------------------

Pal_Stage:
	incbin	"Special Stage/Data/Palette.bin"
Pal_Stage_End:
	even
	
Pal_Results:
	incbin	"Special Stage/Data/Palette (Results).bin"
Pal_Results_End:
	even

; -------------------------------------------------------------------------
; Load time stone palette when the stage is beaten
; -------------------------------------------------------------------------

LoadTimeStonePal:
	tst.b	ufoCount			; Are there any UFOs left?
	bne.s	.End				; If so, exit
	tst.b	timeStonePalDelay		; Has the palette already been loaded?
	beq.s	.End				; If so, exit
	subq.b	#1,timeStonePalDelay		; Decrement delay time
	bne.s	.End				; If it hasn't run out, exit
	
	moveq	#0,d0				; Load palette
	move.b	specStageID,d0
	mulu.w	#$A,d0
	lea	TimeStonePalettes(pc,d0.w),a1
	lea	palette+($31*2).w,a2
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.w	(a1)+,(a2)+
	
	bset	#1,ipxVSync			; Update CRAM

.End:
	rts

; -------------------------------------------------------------------------

timeStonePalDelay:
	dc.b	20				; Time stone palette load delay timer
	even

; -------------------------------------------------------------------------
; Time stone palettes
; -------------------------------------------------------------------------

TimeStonePalettes:
	dc.w	$040, $EEE, $0E8, $0A4, $062	; Stage 1
	dc.w	$040, $EEE, $06E, $04E, $008	; Stage 2
	dc.w	$040, $EEE, $2EE, $088, $024	; Stage 3
	dc.w	$040, $EEE, $E66, $E44, $C22	; Stage 4
	dc.w	$040, $EEE, $8E4, $AA0, $640	; Stage 5
	dc.w	$040, $EEE, $E08, $804, $402	; Stage 6
	dc.w	$040, $EEE, $00E, $008, $204	; Stage 7
	dc.w	$040, $EEE, $0E8, $0A4, $062	; Stage 8

; -------------------------------------------------------------------------
; Load stage data
; -------------------------------------------------------------------------

LoadStageData:
	moveq	#0,d0				; Run routine
	move.b	specStageID,d0
	add.w	d0,d0
	move.w	.Index(pc,d0.w),d0
	jmp	.Index(pc,d0.w)

; -------------------------------------------------------------------------

.Index:
	dc.w	LoadSS1Data-.Index		; Stage 1
	dc.w	LoadSS2Data-.Index		; Stage 2
	dc.w	LoadSS3Data-.Index		; Stage 3
	dc.w	LoadSS4Data-.Index		; Stage 4
	dc.w	LoadSS5Data-.Index		; Stage 5
	dc.w	LoadSS6Data-.Index		; Stage 6
	dc.w	LoadSS7Data-.Index		; Stage 7
	dc.w	LoadSS8Data-.Index		; Stage 8

; -------------------------------------------------------------------------
; Load special stage 1 data
; -------------------------------------------------------------------------

LoadSS1Data:
	move.w	#$8B03,VDPCTRL			; Enable line scrolling
	
	VDPCMD	move.l,$6020,VRAM,WRITE,VDPCTRL	; Load background art
	lea	Art_SS1BG,a0
	bsr.w	NemDec
	
	move.l	#$17161514,d5			; Draw background
	jsr	DrawTilemaps
	moveq	#$43,d5
	jsr	DrawTilemaps
	
	bsr.w	DrawHUDBase			; Draw HUD base
	
	lea	bgHScroll.w,a1			; Initialize background scrolling
	moveq	#0,d1
	moveq	#0,d2
	bsr.w	InitBGLineHScroll
	
	lea	Pal_SS1,a0			; Load palette
	bra.w	LoadStagePal

; -------------------------------------------------------------------------
; Load special stage 2 data
; -------------------------------------------------------------------------

LoadSS2Data:
	VDPCMD	move.l,$6020,VRAM,WRITE,VDPCTRL	; Load background art
	lea	Art_SS2BG,a0
	bsr.w	NemDec
	
	move.l	#$4030201,d5			; Draw background
	jsr	DrawTilemaps
	moveq	#5,d5
	jsr	DrawTilemaps
	
	bsr.w	DrawHUDBase			; Draw HUD base
	
	lea	Pal_SS2,a0			; Load palette
	bra.w	LoadStagePal

; -------------------------------------------------------------------------
; Load special stage 3 data
; -------------------------------------------------------------------------

LoadSS3Data:
	VDPCMD	move.l,$6020,VRAM,WRITE,VDPCTRL	; Load background art
	lea	Art_SS3BG,a0
	bsr.w	NemDec
	
	move.l	#$9080706,d5			; Draw background
	jsr	DrawTilemaps
	move.l	#$280B0A,d5
	jsr	DrawTilemaps
	
	bsr.w	DrawHUDBase			; Draw HUD base
	
	lea	Pal_SS3,a0			; Load palette
	bra.w	LoadStagePal
	
; -------------------------------------------------------------------------
; Load special stage 4 data
; -------------------------------------------------------------------------

LoadSS4Data:
	VDPCMD	move.l,$6020,VRAM,WRITE,VDPCTRL	; Load background art
	lea	Art_SS4BG,a0
	bsr.w	NemDec
	
	move.l	#$F0E0D0C,d5			; Draw background
	jsr	DrawTilemaps
	move.l	#$1110,d5
	jsr	DrawTilemaps
	
	bsr.w	DrawHUDBase			; Draw HUD base
	
	lea	Pal_SS4,a0			; Load palette
	bra.w	LoadStagePal

; -------------------------------------------------------------------------
; Load special stage 5 data
; -------------------------------------------------------------------------

LoadSS5Data:
	move.w	#$8B03,VDPCTRL			; Enable line scrolling
	
	VDPCMD	move.l,$6020,VRAM,WRITE,VDPCTRL	; Load background art
	lea	Art_SS5BG,a0
	bsr.w	NemDec
	
	move.l	#$1B1A1918,d5			; Draw background
	jsr	DrawTilemaps
	moveq	#$1C,d5
	jsr	DrawTilemaps
	
	bsr.w	DrawHUDBase			; Draw HUD base
	
	lea	bgHScroll.w,a1			; Initialize background scrolling
	move.l	#$FF80,d1
	moveq	#0,d2
	bsr.w	InitBGLineHScroll
	
	lea	Pal_SS5,a0			; Load palette
	bra.w	LoadStagePal
	
; -------------------------------------------------------------------------
; Load special stage 6 data
; -------------------------------------------------------------------------

LoadSS6Data:
	move.w	#$8B03,VDPCTRL			; Enable line scrolling
	
	VDPCMD	move.l,$6020,VRAM,WRITE,VDPCTRL	; Load background art
	lea	Art_SS6BG,a0
	bsr.w	NemDec
	VDPCMD	move.l,$F180,VRAM,WRITE,VDPCTRL	; Load background water top art
	lea	Art_SS6BGWater,a0
	bsr.w	NemDec
	
	move.l	#$201F1E1D,d5			; Draw background
	jsr	DrawTilemaps
	moveq	#$4D,d5
	jsr	DrawTilemaps
	
	bsr.w	DrawHUDBase			; Draw HUD base
	
	lea	bgHScroll.w,a1			; Initialize background scrolling
	moveq	#0,d1
	moveq	#0,d2
	bsr.w	InitBGLineHScroll
	
	lea	Pal_SS6,a0			; Load palette
	bra.w	LoadStagePal

; -------------------------------------------------------------------------
; Load special stage 7 data
; -------------------------------------------------------------------------

LoadSS7Data:
	VDPCMD	move.l,$6020,VRAM,WRITE,VDPCTRL	; Load background art
	lea	Art_SS7BG,a0
	bsr.w	NemDec
	
	move.l	#$24232221,d5			; Draw background
	jsr	DrawTilemaps
	move.l	#$272625,d5
	jsr	DrawTilemaps
	
	bsr.w	DrawHUDBase			; Draw HUD base
	
	lea	Pal_SS7,a0			; Load palette
	bra.w	LoadStagePal

; -------------------------------------------------------------------------
; Load special stage 8 data
; -------------------------------------------------------------------------

LoadSS8Data:
	VDPCMD	move.l,$6020,VRAM,WRITE,VDPCTRL	; Load background art
	lea	Art_SS8BG,a0
	bsr.w	NemDec
	move.l	#$4F4E,d5			; Draw background
	jsr	DrawTilemaps
	
	bsr.w	DrawHUDBase			; Draw HUD base
	
	lea	bgHScroll.w,a1			; Initialize background scrolling
	moveq	#0,d1
	moveq	#0,d2
	bsr.w	InitBGLineHScroll
	
	lea	Pal_SS8,a0			; Load palette

; -------------------------------------------------------------------------
; Load stage palette
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to palette
; -------------------------------------------------------------------------

LoadStagePal:
	lea	palette+($10*2).w,a1		; Load palette
	moveq	#$40/4-1,d7

.Copy:
	move.l	(a0)+,(a1)+
	dbf	d7,.Copy
	rts

; -------------------------------------------------------------------------
; Draw HUD base
; -------------------------------------------------------------------------

DrawHUDBase:
	moveq	#$12,d5				; Draw regular HUD base
	jsr	DrawTilemaps
	btst	#1,specStageFlags		; Are we in time attack mode?
	beq.s	.End				; If not, branch
	moveq	#$13,d5				; Draw time attack HUD base
	jsr	DrawTilemaps

.End:
	rts

; -------------------------------------------------------------------------
; Initialize background horizontal line scrolling
; -------------------------------------------------------------------------
; PARAMETERS:
;	d1.l - Initial integer value
;	d2.l - Initial fraction value
; -------------------------------------------------------------------------

InitBGLineHScroll:
	rept	$200/$80			; Set integer values
		bsr.w	Fill128
	endr

	move.l	d2,d1				; Set fraction values
	rept	$200/$80
		bsr.w	Fill128
	endr
	rts

; -------------------------------------------------------------------------
; Unused function to load the splash art when the flag is set
; -------------------------------------------------------------------------

LoadSplashArt:
	bclr	#0,splashArtLoad.w		; Clear load flag
	beq.s	.End				; If it wasn't set, branch
	VDPCMD	move.l,$AE00,VRAM,WRITE,VDPCTRL	; Load splash art
	lea	Art_Splash(pc),a0
	bsr.w	NemDec

.End:
	rts

; -------------------------------------------------------------------------
; V-BLANK interrupt
; -------------------------------------------------------------------------

VInterrupt:
	movem.l	d0-a6,-(sp)			; Save registers

	move.b	#1,GAIRQ2			; Trigger IRQ2 on Sub CPU
	bclr	#0,ipxVSync			; Clear VSync flag
	beq.w	VInt_Lag			; If it wasn't set, branch
	
	lea	VDPCTRL,a1			; VDP control port
	lea	VDPDATA,a2			; VDP data port
	move.w	(a1),d0				; Reset V-BLANK flag

	jsr	StopZ80(pc)			; Stop the Z80

	bclr	#1,ipxVSync			; Clear CRAM update flag
	beq.s	.Update				; If it wasn't set, branch
	DMA68K	palette,$0000,$80,CRAM		; Copy palette data

.Update:
	move.w	vintRoutine.w,d0		; Run routine
	add.w	d0,d0
	move.w	.Routines(pc,d0.w),d0
	jmp	.Routines(pc,d0.w)

; -------------------------------------------------------------------------

.Routines:
	dc.w	VInt_CopyStage1_1-.Routines	; Copy 1st half of rendered stage art to buffer 1
	dc.w	VInt_CopyStage1_2-.Routines	; Copy 2nd half of rendered stage art to buffer 1
	dc.w	VInt_CopyStage2_1-.Routines	; Copy 1st half of rendered stage art to buffer 2
	dc.w	VInt_CopyStage2_2-.Routines	; Copy 2nd half of rendered stage art to buffer 2
	dc.w	VInt_CopyStageDone-.Routines	; Stage art copy done
	dc.w	VInt_Results-.Routines		; Update results screen
	dc.w	VInt_StageOver-.Routines		; Stage over
	dc.w	VInt_Paused-.Routines		; Paused

; -------------------------------------------------------------------------

VInt_CopyStage1_1:
	bsr.w	ShowStageBuf2			; Show stage buffer 2
	bsr.w	CopyHScroll			; Update horizontal scroll data
	COPYIMG	stageImage, 0, 0		; Copy rendered stage image
	jsr	ReadController(pc)		; Read controller
	bra.w	VInt_Finish			; Finish

; -------------------------------------------------------------------------

VInt_CopyStage1_2:
	bsr.w	CopyHScrollSects		; Update horizontal scroll data
	COPYIMG	stageImage, 0, 1		; Copy rendered stage image
	bsr.w	CopySprites			; Copy sprite data
	bsr.w	PaletteCycle			; Cycle palette
	bra.w	VInt_Finish			; Finish

; -------------------------------------------------------------------------

VInt_CopyStage2_1:
	bsr.w	ShowStageBuf1			; Show stage buffer 1
	bsr.w	CopyHScroll			; Update horizontal scroll data
	COPYIMG	stageImage, 1, 0		; Copy rendered stage image
	jsr	ReadController(pc)		; Read controller
	bra.w	VInt_Finish			; Finish

; -------------------------------------------------------------------------

VInt_CopyStage2_2:
	bsr.w	CopyHScrollSects		; Update horizontal scroll data
	COPYIMG	stageImage, 1, 1		; Copy rendered stage image
	bsr.w	CopySprites			; Copy sprite data
	bsr.w	PaletteCycle			; Cycle palette
	bra.w	VInt_Finish			; Finish

; -------------------------------------------------------------------------

VInt_CopyStageDone:
	bsr.w	CopyHScrollSects		; Update horizontal scroll data
	bra.w	VInt_Finish			; Finish

; -------------------------------------------------------------------------

VInt_Results:
	bsr.w	DrawResultsScore		; Draw results score
	bsr.w	DrawResTimeBonus		; Draw results time bonus
	bsr.w	DarwResRingBonus		; Draw results ring bonus
	bsr.w	DrawExtraPlayers		; Draw extra player icons
	jsr	ReadController(pc)		; Read controller
	bra.w	VInt_Finish			; Finish

; -------------------------------------------------------------------------

VInt_StageOver:
	bra.w	VInt_Finish			; Finish

; -------------------------------------------------------------------------

VInt_Paused:
	jsr	ReadController(pc)		; Read controller
	bra.w	*+4

; -------------------------------------------------------------------------

VInt_Finish:
	bsr.w	StartZ80			; Start the Z80

	tst.w	resultsTimer.w			; Is the results screen timer running?
	beq.s	.NoTimer			; If not, branch
	subq.w	#1,resultsTimer.w		; Decrement timer

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
; Copy sprite data
; -------------------------------------------------------------------------

CopySprites:
	DMA68K	sprites,$D400,$280,VRAM		; Copy sprite data
	DMA68K	sonicArtBuf,$BC00,$300,VRAM	; Copy Sonic art
	rts

; -------------------------------------------------------------------------
; Show stage buffer
; -------------------------------------------------------------------------

ShowStageBuf1:
	bsr.w	CheckLineScroll			; Is line scrolling enabled?
	beq.s	ShowStageBuf1Line		; If so, branch
	move.w	#$8F20,VDPCTRL			; Skip unused scroll entries
	VDPCMD	move.l,$D200,VRAM,WRITE,VDPCTRL	; Set scroll offsets
	moveq	#0,d0
	bra.s	ShowStageBuffer

; -------------------------------------------------------------------------

ShowStageBuf2:
	bsr.w	CheckLineScroll			; Is line scrolling enabled?
	beq.s	ShowStageBuf2Line		; If so, branch
	move.w	#$8F20,VDPCTRL			; Skip unused scroll entries
	VDPCMD	move.l,$D200,VRAM,WRITE,VDPCTRL	; Set scroll offsets
	move.w	#$100,d0

; -------------------------------------------------------------------------

ShowStageBuffer:
	bsr.w	Scroll12Rows			; Set stage buffer scroll offset
	move.w	#$8F02,VDPCTRL			; Reset auto-increment
	rts

; -------------------------------------------------------------------------

ShowStageBuf1Line:
	lea	VDPCTRL,a6			; VDP control port
	move.w	#$8F04,(a6)			; Skip over plane B offsets
	DMA68K2	stageHScroll1,$D200,$C0,VRAM	; Copy horizontal scroll data
	move.w	#$8F02,(a6)			; Reset auto-increment
	rts

; -------------------------------------------------------------------------

ShowStageBuf2Line:
	lea	VDPCTRL,a6			; VDP control port
	move.w	#$8F04,(a6)			; Skip over plane B offsets
	DMA68K2	stageHScroll2,$D200,$C0,VRAM	; Copy horizontal scroll data
	move.w	#$8F02,(a6)			; Reset auto-increment
	rts

; -------------------------------------------------------------------------
; Scroll background section 1
; -------------------------------------------------------------------------

BGScroll1:
	btst	#0,GASUBFLAG			; Is the stage over?
	bne.s	.End				; If so, branch
	tst.b	scrollDisable			; Is scrolling disabled?
	bne.s	.End				; If so, branch
	cmpi.b	#1-1,specStageID		; Handle stage 1 scrolling
	beq.w	BGScroll_SS1Sect1
	cmpi.b	#5-1,specStageID		; Handle stage 5 scrolling
	beq.w	BGScroll_SS5Sect1
	cmpi.b	#6-1,specStageID		; Handle stage 6 scrolling
	beq.w	BGScroll_SS6Sect1

.End:
	rts

; -------------------------------------------------------------------------

BGScroll_SS1Sect1:
	move.l	#$80000,d0			; Update planets scroll offset
	bsr.w	GetScrollSpeed
	add.l	d0,scrollOffset2.w
	asr.l	#1,d0				; Update crystals scroll offset
	add.l	d0,scrollOffset1.w

	lea	bgScrollMode(pc),a0		; Get background scroll direction
	lea	ss1BGScrollShift(pc),a1		; Get background scroll shift intensity
	tst.b	(a0)				; Are we shifting the background left?
	bne.s	.ShiftLeft			; If so, branch

.ShiftRight:
	addq.w	#1,(a1)				; Shift right
	cmpi.w	#$200,(a1)			; Has it shifted right enough?
	bcs.s	.Scroll				; If not, branch
	move.w	#$1FF,(a1)			; Cap it
	move.b	#1,(a0)				; Start shifting in the other direction
	bra.s	.Scroll

.ShiftLeft:
	subq.w	#1,(a1)				; Shift left
	bpl.s	.Scroll				; If not, branch
	move.w	#0,(a1)				; Cap it
	move.b	#0,(a0)				; Start shifting in the other direction

.Scroll:
	lea	bgHScroll.w,a0			; Apply scrolling
	lea	bgHScrollFrac.w,a1
	move.l	#$10000,d0
	move.l	#$400,d1
	moveq	#0,d3
	moveq	#0,d4
	move.w	#24-1,d7
	bra.w	ApplyBGScroll_SS1

; -------------------------------------------------------------------------

BGScroll_SS5Sect1:
	move.l	#$40000,d0			; Update buildings scroll offset
	bsr.w	GetScrollSpeed
	add.l	d0,scrollOffset1.w

	lea	bgScrollMode(pc),a0		; Get background scroll direction
	lea	ss5BGScrollShift(pc),a1		; Get background scroll shift intensity
	move.b	#0,(a0)				; Mark as not moving
	btst	#2,scrollFlags.w		; Are we scrolling left?
	beq.s	.NotLeft			; If not, branch
	move.b	#1,(a0)				; Mark as scrolling left
	addq.w	#1,(a1)				; Shift right as we move left
	andi.w	#$F,(a1)			; Are we looping?
	bne.s	.NotLeft			; If not, branch
	move.b	#2,(a0)				; Mark as looping

.NotLeft:
	btst	#3,scrollFlags.w		; Are we scrolling right?
	beq.s	.NotRight			; If not, branch
	move.b	#-1,(a0)
	subq.w	#1,(a1)				; Shift left as we move right
	andi.w	#$F,(a1)			; Are we looping?
	bne.s	.NotRight			; If not, branch
	move.b	#2,(a0)				; Mark as looping

.NotRight:
	lea	bgHScroll.w,a0			; Apply scrolling
	lea	bgHScrollFrac.w,a1
	lea	SS5BGScrollSpeeds(pc),a2

	moveq	#0,d0				; Top 17 lines are static
	move.w	#17-1,d7

.TopOffset:
	move.l	d0,(a0)+
	move.l	d0,(a1)+
	dbf	d7,.TopOffset

	move.w	#7-1,d7
	bra.w	ApplyBGScroll_SS5

; -------------------------------------------------------------------------

BGScroll_SS6Sect1:
	move.l	#$40000,d0			; Update buildings scroll offset
	bsr.w	GetScrollSpeed
	add.l	d0,scrollOffset1.w

	lea	bgHScroll.w,a0			; Apply scrolling
	lea	SS6BGWave(pc),a2
	moveq	#0,d0
	move.w	ss6BGWaveTableOff,d2
	addq.w	#1,d2
	andi.w	#$7F,d2
	move.w	d2,ss6BGWaveTableOff
	move.w	#24-1,d7
	bra.w	ApplyBGScroll_SS6

; -------------------------------------------------------------------------
; Scroll background section 2
; -------------------------------------------------------------------------

BGScroll2:
	btst	#0,GASUBFLAG			; Is the stage over?
	bne.s	.End				; If so, branch
	tst.b	scrollDisable			; Is scrolling disabled?
	bne.s	.End				; If so, branch
	cmpi.b	#1-1,specStageID		; Handle stage 1 scrolling
	beq.s	BGScroll_SS1Sect2
	cmpi.b	#5-1,specStageID		; Handle stage 5 scrolling
	beq.s	BGScroll_SS5Sect2
	cmpi.b	#6-1,specStageID		; Handle stage 6 scrolling
	beq.w	BGScroll_SS6Sect2

.End:
	rts

; -------------------------------------------------------------------------

BGScroll_SS1Sect2:
	lea	bgHScroll+(24*4).w,a0		; Apply scrolling to planets section
	lea	bgHScrollFrac+(24*4).w,a1
	move.l	#$A000,d0
	move.l	#$400,d1
	move.w	scrollOffset2.w,d3
	moveq	#0,d4
	move.w	#72-1,d7
	bra.w	ApplyBGScroll_SS1

; -------------------------------------------------------------------------

BGScroll_SS5Sect2:
	lea	bgHScroll+(24*4).w,a0		; Apply scrolling to buildings section (top)
	lea	bgHScrollFrac+(24*4).w,a1
	lea	SS5BGScrollSpeeds+(7*4)(pc),a2
	move.w	scrollOffset1.w,d0
	move.w	#56-1,d7
	bra.w	ApplyBGScroll_SS5

; -------------------------------------------------------------------------

BGScroll_SS6Sect2:
	lea	bgHScroll+(24*4).w,a0		; Apply scrolling to buildings section (top)
	lea	SS6BGWave(pc),a2
	move.w	scrollOffset1.w,d0
	move.w	ss6BGWaveTableOff,d2
	move.w	#56-1,d7
	bra.w	ApplyBGScroll_SS6

; -------------------------------------------------------------------------
; Scroll background section 3
; -------------------------------------------------------------------------

BGScroll3:
	btst	#0,GASUBFLAG			; Is the stage over?
	bne.s	.End				; If so, branch
	tst.b	scrollDisable			; Is scrolling disabled?
	bne.s	.End				; If so, branch
	cmpi.b	#1-1,specStageID		; Handle stage 1 scrolling
	beq.s	BGScroll_SS1Sect3
	cmpi.b	#5-1,specStageID		; Handle stage 5 scrolling
	beq.s	BGScroll_SS5Sect3
	cmpi.b	#6-1,specStageID		; Handle stage 6 scrolling
	beq.w	BGScroll_SS6Sect3

.End:
	rts

; -------------------------------------------------------------------------

BGScroll_SS1Sect3:
	lea	bgHScroll+(96*4).w,a0		; Apply scrolling to crystals section
	lea	bgHScrollFrac+(96*4).w,a1
	move.l	#-$8000,d0
	move.l	#$400,d1
	move.w	scrollOffset1.w,d3
	moveq	#0,d4
	move.w	#32-1,d7
	bra.w	ApplyBGScroll_SS1

; -------------------------------------------------------------------------

BGScroll_SS5Sect3:
	lea	bgHScroll+(80*4).w,a0		; Apply scrolling to buildings section (bottom)
	lea	bgHScrollFrac+(80*4).w,a1
	lea	SS5BGScrollSpeeds+(63*4)(pc),a2
	move.w	scrollOffset1.w,d0
	move.w	#48-1,d7
	bra.w	ApplyBGScroll_SS5

; -------------------------------------------------------------------------

BGScroll_SS6Sect3:
	lea	bgHScroll+(80*4).w,a0		; Apply scrolling to buildings section (bottom)
	lea	SS6BGWave(pc),a2
	move.w	scrollOffset1.w,d0
	move.w	ss6BGWaveTableOff,d2
	move.w	#48-1,d7
	bra.w	ApplyBGScroll_SS6

; -------------------------------------------------------------------------

ss1BGScrollShift:
	dc.w	$100				; Stage 1 background scroll shift
ss5BGScrollShift:
ss6BGWaveTableOff:
	dc.w	0				; Stage 1 background scroll shift/stage 6 background scroll table offset
bgScrollMode:
	dc.b	0				; Background scroll mode
	even

; -------------------------------------------------------------------------

SS5BGScrollSpeeds:				; Stage 5 scroll speeds
	dc.l	$3D000, $3E000, $3F000
	dc.l	$40000, $40000, $41000
	dc.l	$41000, $42000, $43000
	dc.l	$43000, $44000, $45000
	dc.l	$45000, $46000, $46000
	dc.l	$47000, $47000, $48000
	dc.l	$49000, $49000, $4A000
	dc.l	$4A000, $4B000, $4B000
	dc.l	$4C000, $4C000, $4D000
	dc.l	$4D000, $4E000, $4E000
	dc.l	$4F000, $4F000, $4F000
	dc.l	$50000, $50000, $51000
	dc.l	$51000, $52000, $52000
	dc.l	$52000, $53000, $53000
	dc.l	$54000, $54000, $54000
	dc.l	$55000, $55000, $55000
	dc.l	$56000, $56000, $56000
	dc.l	$57000, $57000, $57000
	dc.l	$58000, $58000, $58000
	dc.l	$59000, $59000, $59000
	dc.l	$59000, $5A000, $5A000
	dc.l	$5A000, $5A000, $5B000
	dc.l	$5B000, $5B000, $5B000
	dc.l	$5C000, $5C000, $5C000
	dc.l	$5C000, $5C000, $5D000
	dc.l	$5D000, $5D000, $5D000
	dc.l	$5D000, $5D000, $5E000
	dc.l	$5E000, $5E000, $5E000
	dc.l	$5E000, $5E000, $5E000
	dc.l	$5F000, $5F000, $5F000
	dc.l	$5F000, $5F000, $5F000
	dc.l	$5F000, $5F000, $5F000
	dc.l	$5F000, $60000, $60000
	dc.l	$60000, $60000, $60000
	dc.l	$60000, $60000, $60000
	dc.l	$60000, $60000, $60000
	dc.l	$60000, $60000, $60000

SS6BGWave:					; Stage 6 wavy scroll pattern
	dc.b	$00, $FB, $F6, $F1, $EC, $E7, $E2, $DD
	dc.b	$D8, $D4, $D0, $CC, $C8, $C4, $C0, $BD
	dc.b	$BA, $B7, $B4, $B2, $B0, $AE, $AC, $AA
	dc.b	$A8, $A6, $A4, $A3, $A2, $A3, $A4, $A6
	dc.b	$A8, $AB, $AE, $B0, $B2, $B9, $C0, $C8
	dc.b	$D0, $E0, $F0, $00, $10, $15, $1A, $1E
	dc.b	$22, $23, $24, $25, $26, $25, $24, $22
	dc.b	$20, $1C, $18, $14, $10, $0A, $05, $00
	dc.b	$FC, $F7, $F3, $EE, $EA, $E8, $E6, $E4
	dc.b	$E2, $E1, $E0, $DF, $DE, $DF, $E0, $E1
	dc.b	$E2, $E4, $E5, $E7, $E8, $EC, $F0, $F4
	dc.b	$F8, $00, $08, $0F, $16, $1E, $26, $2F
	dc.b	$38, $40, $48, $50, $58, $5E, $64, $6A
	dc.b	$70, $73, $76, $78, $7A, $7B, $7C, $7D
	dc.b	$7E, $7D, $7C, $7A, $78, $72, $6C, $66
	dc.b	$60, $56, $4C, $42, $38, $2A, $1C, $0E

; -------------------------------------------------------------------------
; Apply scrolling for stage 1
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - Initial shift value
;	d1.l - Shift value subtraction value
;	d3.w - Plane A scroll offset (integer)
;	d4.w - Plane A scroll offset (fraction)
;	d7.w - Number of lines to scroll (minus 1)
;	a0.l - Background horizontal scroll buffer (integer)
;	a1.l - Background horizontal scroll buffer (fraction)
; -------------------------------------------------------------------------

ApplyBGScroll_SS1:
	tst.b	bgScrollMode			; Are we shifting left?
	bne.s	.ShiftLeft			; If so, branch

.ShiftRight:
	move.w	d3,(a0)+			; Apply plane A scroll offset
	move.w	d4,(a1)+

	move.w	(a0),d2				; Shift plane B right
	swap	d2
	move.w	(a1),d2
	add.l	d0,d2
	move.w	d2,(a1)+
	swap	d2
	move.w	d2,(a0)+

	sub.l	d1,d0				; Shift less intensely towards the center
	dbf	d7,.ShiftRight			; Loop until lines are set
	rts

.ShiftLeft:
	move.w	d3,(a0)+			; Apply plane A scroll offset
	move.w	d4,(a1)+

	move.w	(a0),d2				; Shift plane B left
	swap	d2
	move.w	(a1),d2
	sub.l	d0,d2
	move.w	d2,(a1)+
	swap	d2
	move.w	d2,(a0)+

	sub.l	d1,d0				; Shift less intensely towards the center
	dbf	d7,.ShiftLeft			; Loop until lines are set
	rts

; -------------------------------------------------------------------------
; Apply scrolling for stage 5
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Plane A scroll offset
;	d7.w - Number of lines to scroll (minus 1)
;	a0.l - Background horizontal scroll buffer (integer)
;	a1.l - Background horizontal scroll buffer (fraction)
;	a2.l - Scroll speed table
; -------------------------------------------------------------------------

ApplyBGScroll_SS5:
	cmpi.b	#2,bgScrollMode			; Are we reseting the scroll offsets?
	beq.w	.Reset				; If so, branch
	tst.b	bgScrollMode			; Are we shifting?
	beq.w	.End				; If not, branch
	bmi.w	.ShiftLeft			; If we are shifting left, branch

.ShiftRight:
	move.w	d0,(a0)+			; Apply plane A scroll offset
	move.w	d0,(a1)+

	move.w	(a0),d2				; Apply scroll speed to plane B right
	swap	d2
	move.w	(a1),d2
	add.l	(a2)+,d2
	move.w	d2,(a1)+
	swap	d2
	move.w	d2,(a0)+

	dbf	d7,.ShiftRight			; Loop until lines are set
	rts

.ShiftLeft:
	move.w	d0,(a0)+			; Apply plane A scroll offset
	move.w	d0,(a1)+

	move.w	(a0),d2				; Apply scroll speed to plane B left
	swap	d2
	move.w	(a1),d2
	sub.l	(a2)+,d2
	move.w	d2,(a1)+
	swap	d2
	move.w	d2,(a0)+

	dbf	d7,.ShiftLeft			; Loop until lines are set
	rts

.Reset:
	move.w	d0,(a0)+			; Apply foreground scroll offset
	move.w	d0,(a1)+
	move.w	#-$80,(a0)+			; Reset plane B scroll offset
	move.w	#0,(a1)+
	dbf	d7,.Reset			; Loop until lines are set

.End:
	rts
	
; -------------------------------------------------------------------------
; Apply scrolling for stage 6
; -------------------------------------------------------------------------
; PARAMETERS:
;	d2.w - Initial scroll pattern table offset
;	d7.w - Number of lines to scroll (minus 1)
;	a0.l - Background horizontal scroll buffer (integer)
;	a2.l - Scroll pattern table
; -------------------------------------------------------------------------

ApplyBGScroll_SS6:
.Loop:
	move.w	d0,(a0)+			; Apply plane A scroll offset

	move.b	(a2,d2.w),d1			; Apply scroll pattern to plane B
	ext.w	d1
	move.w	d1,(a0)+

	addq.w	#1,d2				; Next line
	andi.w	#$7F,d2
	dbf	d7,.Loop			; Loop until lines are set

	move.w	d2,ss6BGWaveTableOff		; Update table offset
	rts

; -------------------------------------------------------------------------
; Basic background scroll
; -------------------------------------------------------------------------

DefaultBGScroll:
	move.l	#$40000,d0			; Offset 3 speed = 4
	bsr.s	GetScrollSpeed
	add.l	d0,scrollOffset3.w
	asr.l	#1,d0				; Offset 2 speed = 2
	add.l	d0,scrollOffset2.w
	asr.l	#1,d0				; Offset 1 speed = 1
	add.l	d0,scrollOffset1.w
	rts

; -------------------------------------------------------------------------
; Calculate scroll speed with regards to direction that is being scrolled
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - Base scroll speed value
;	d1.l - Base scroll speed accumulator value
; RETURNS:
;	d0.l - Calculated scroll speed
;	d1.l - Calculated scroll speed accumulator
; -------------------------------------------------------------------------

GetScrollSpeed:
	btst	#2,scrollFlags.w		; Are we scrolling left?
	bne.s	.End				; If so, branch
	neg.l	d0				; If not, scroll the other way
	neg.l	d1
	btst	#3,scrollFlags.w		; Are we scrolling at all?
	bne.s	.End				; If so, branch
	moveq	#0,d0				; If not, don't scroll at all
	moveq	#0,d1

.End:
	rts

; -------------------------------------------------------------------------
; Copy horizontal scroll data for line scrolled backgrounds
; (Line scrolled backgrounds should already have been updated)
; -------------------------------------------------------------------------

CopyHScrollSects:
	btst	#0,GASUBFLAG			; Is the stage over?
	bne.s	.End				; If so, branch
	tst.b	scrollDisable			; Is scrolling disabled?
	bne.s	.End				; If so, branch
	bsr.w	CheckLineScroll			; Is line scrolling enabled?
	bne.s	CopyHScroll			; If not, do updates

.End:
	rts

; -------------------------------------------------------------------------
; Copy horizontal scroll data
; -------------------------------------------------------------------------

CopyHScroll:
	tst.b	scrollDisable			; Is scrolling disabled?
	bne.s	.End				; If so, branch
	btst	#0,GASUBFLAG			; Is the stage over?
	bne.s	.End				; If so, branch

	moveq	#0,d0				; Run routine
	move.b	specStageID,d0
	add.w	d0,d0
	move.w	.Index(pc,d0.w),d0
	jmp	.Index(pc,d0.w)

.End:
	rts

; -------------------------------------------------------------------------

.Index:
	dc.w	CopyHScroll_Line-.Index		; Stage 1
	dc.w	CopyHScroll_SS2-.Index		; Stage 2
	dc.w	CopyHScroll_SS3-.Index		; Stage 3
	dc.w	CopyHScroll_SS4-.Index		; Stage 4
	dc.w	CopyHScroll_Line-.Index		; Stage 5
	dc.w	CopyHScroll_Line-.Index		; Stage 6
	dc.w	CopyHScroll_SS7-.Index		; Stage 7
	dc.w	CopyHScroll_SS8-.Index		; Stage 8

; -------------------------------------------------------------------------

CopyHScroll_Line:
	DMA68K	bgHScroll,$D000,$200,VRAM	; Copy horizontal scroll data
	rts

; -------------------------------------------------------------------------

CopyHScroll_SS2:
	bsr.w	DefaultBGScroll			; Use default scroll speeds
	move.w	#$8F20,VDPCTRL			; Skip unused scroll entries

	VDPCMD	move.l,$D060,VRAM,WRITE,VDPCTRL	; Front clouds
	move.w	scrollOffset2.w,d0
	bsr.w	Scroll13Rows

	VDPCMD	move.l,$D002,VRAM,WRITE,VDPCTRL	; Back clouds and planet
	move.w	scrollOffset3.w,d0
	bsr.w	Scroll16Rows

	move.w	#$8F02,VDPCTRL			; Reset auto-increment
	rts

; -------------------------------------------------------------------------

CopyHScroll_SS3:
	move.l	#$80000,d0			; Get scroll speed
	move.l	#$10000,d1
	bsr.w	GetScrollSpeed

	add.l	d0,scrollOffset1.w		; Unused
	sub.l	d1,d0				; Top mountains
	add.l	d0,scrollOffset2.w
	sub.l	d1,d0				; Middle mountains
	add.l	d0,scrollOffset3.w
	sub.l	d1,d0				; Bottom mountains
	add.l	d0,scrollOffset4.w
	sub.l	d1,d0				; Structures
	add.l	d0,scrollOffset5.w
	sub.l	d1,d0				; Fade
	add.l	d0,scrollOffset6.w

	move.w	#$8F20,VDPCTRL			; Skip unused scroll entries

	VDPCMD	move.l,$D060,VRAM,WRITE,VDPCTRL	; Structures
	move.w	scrollOffset5.w,d0
	bsr.w	Scroll13Rows

	VDPCMD	move.l,$D002,VRAM,WRITE,VDPCTRL	; Surface
	move.w	#0,d0
	bsr.w	Scroll6Rows

	move.w	scrollOffset2.w,d0		; Top mountains
	bsr.w	Scroll3Rows

	move.w	scrollOffset3.w,(a2)		; Middle mountains

	move.w	scrollOffset4.w,d0		; Bottom mountains
	bsr.w	Scroll4Rows

	move.w	scrollOffset6.w,d0		; Fade
	bsr.w	Scroll2Rows

	move.w	#$8F02,VDPCTRL			; Reset auto-increment
	rts

; -------------------------------------------------------------------------

CopyHScroll_SS4:
	bsr.w	DefaultBGScroll			; Use default scroll speeds
	move.w	#$8F20,VDPCTRL			; Skip unused scroll entries

	VDPCMD	move.l,$D060,VRAM,WRITE,VDPCTRL	; Mountain
	move.w	scrollOffset2.w,d0
	bsr.w	Scroll13Rows

	VDPCMD	move.l,$D002,VRAM,WRITE,VDPCTRL	; Floating islands
	move.w	scrollOffset1.w,d0
	bsr.w	Scroll11Rows

	move.w	scrollOffset3.w,d0		; Bottom islands
	bsr.w	Scroll5Rows

	move.w	#$8F02,VDPCTRL			; Reset auto-increment
	rts

; -------------------------------------------------------------------------

CopyHScroll_SS7:
	move.l	#$80000,d0			; Get scroll speed
	move.l	#$18000,d1
	bsr.w	GetScrollSpeed

	add.l	d0,scrollOffset1.w		; Sky
	sub.l	d1,d0				; Back buildings
	add.l	d0,scrollOffset2.w
	sub.l	d1,d0				; Trees and mountains
	add.l	d0,scrollOffset3.w
	sub.l	d1,d0				; Front buildings
	add.l	d0,scrollOffset4.w

	move.w	#$8F20,VDPCTRL			; Skip unused scroll entries

	VDPCMD	move.l,$D060,VRAM,WRITE,VDPCTRL	; Back buildings
	move.w	scrollOffset2.w,d0
	bsr.w	Scroll11Rows

	move.w	scrollOffset4.w,d0		; Front buildings
	bsr.w	Scroll2Rows

	VDPCMD	move.l,$D002,VRAM,WRITE,VDPCTRL	; Sky
	move.w	scrollOffset1.w,d0
	bsr.w	Scroll10Rows

	move.w	scrollOffset3.w,d0		; Trees and mountains
	bsr.w	Scroll6Rows

	move.w	#$8F02,VDPCTRL			; Reset auto-increment
	rts

; -------------------------------------------------------------------------

CopyHScroll_SS8:
	rts

; -------------------------------------------------------------------------
; Scroll rows
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Scroll offset
;	a2.l - VDP data port
; -------------------------------------------------------------------------

Scroll16Rows:
	move.w	d0,(a2)
Scroll15Rows:
	move.w	d0,(a2)
Scroll14Rows:
	move.w	d0,(a2)
Scroll13Rows:
	move.w	d0,(a2)
Scroll12Rows:
	move.w	d0,(a2)
Scroll11Rows:
	move.w	d0,(a2)
Scroll10Rows:
	move.w	d0,(a2)
Scroll9Rows:
	move.w	d0,(a2)
Scroll8Rows:
	move.w	d0,(a2)
Scroll7Rows:
	move.w	d0,(a2)
Scroll6Rows:
	move.w	d0,(a2)
Scroll5Rows:
	move.w	d0,(a2)
Scroll4Rows:
	move.w	d0,(a2)
Scroll3Rows:
	move.w	d0,(a2)
Scroll2Rows:
	move.w	d0,(a2)
Scroll1Row:
	move.w	d0,(a2)
	rts

; -------------------------------------------------------------------------
; Cycle palette
; -------------------------------------------------------------------------

PaletteCycle:
	lea	palette.w,a6			; Get palette

	moveq	#0,d0				; Run routine
	move.b	specStageID,d0
	add.w	d0,d0
	move.w	.Index(pc,d0.w),d0
	jmp	.Index(pc,d0.w)

; -------------------------------------------------------------------------

.Index:
	dc.w	PalCycle_SS1-.Index		; Stage 1
	dc.w	PalCycle_SS2-.Index		; Stage 2
	dc.w	PalCycle_SS3-.Index		; Stage 3
	dc.w	PalCycle_SS4-.Index		; Stage 4
	dc.w	PalCycle_SS5-.Index		; Stage 5
	dc.w	PalCycle_SS6-.Index		; Stage 6
	dc.w	PalCycle_SS7-.Index		; Stage 7
	dc.w	PalCycle_SS8-.Index		; Stage 8

; -------------------------------------------------------------------------

PalCycle_SS1:
	lea	.Index(pc),a1			; Get and increment cycle index
	moveq	#8,d5
	moveq	#0,d6
	move.w	#1000,d7
	bsr.w	IncValue
	andi.w	#$FFF0,d0

	lea	.Cycle(pc,d0.w),a5		; Get cycle data
	lea	palette+($20*2).w,a6		; Write to line 2
	moveq	#$10-1,d0			; 16 colors

.Loop:
	moveq	#0,d1				; Get color
	move.b	(a5)+,d1
	cmpi.w	#$10,d1				; Is it meant for the blue channel?
	bcs.s	.SetColor			; If not, branch
	lsl.w	#4,d1				; If so, shift it to the blue channel

.SetColor:
	move.w	d1,(a6)+			; Store color
	dbf	d0,.Loop			; Loop until colors are set

	bset	#1,ipxVSync			; Update CRAM
	rts

; -------------------------------------------------------------------------

.Cycle:
	dc.b	$00, $20, $40, $60, $80, $A0, $C0, $E0, $00, $00, $00, $00, $00, $00, $00, $00
	dc.b	$00, $00, $20, $40, $60, $80, $A0, $C0, $00, $00, $00, $00, $00, $00, $00, $20
	dc.b	$00, $00, $00, $20, $40, $60, $80, $A0, $00, $00, $00, $00, $00, $00, $20, $40
	dc.b	$00, $00, $00, $00, $20, $40, $60, $80, $00, $00, $00, $00, $00, $20, $40, $60
	dc.b	$00, $00, $00, $00, $00, $20, $40, $60, $00, $00, $00, $00, $20, $40, $60, $80
	dc.b	$00, $00, $00, $00, $00, $00, $20, $40, $00, $00, $00, $20, $40, $60, $80, $A0
	dc.b	$00, $00, $00, $00, $00, $00, $00, $20, $00, $00, $20, $40, $60, $80, $A0, $C0
	dc.b	$00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $40, $60, $80, $A0, $C0, $E0
	dc.b	$00, $00, $00, $00, $00, $00, $00, $00, $20, $40, $60, $80, $A0, $C0, $E0, $C0
	dc.b	$00, $20, $00, $00, $00, $00, $00, $00, $40, $60, $80, $A0, $C0, $E0, $C0, $A0
	dc.b	$00, $40, $20, $00, $00, $00, $00, $00, $60, $80, $A0, $C0, $E0, $C0, $A0, $80
	dc.b	$00, $60, $40, $20, $00, $00, $00, $00, $80, $A0, $C0, $E0, $C0, $A0, $80, $60
	dc.b	$00, $80, $60, $40, $20, $00, $00, $00, $A0, $C0, $E0, $C0, $A0, $80, $60, $40
	dc.b	$00, $A0, $80, $60, $40, $20, $00, $00, $C0, $E0, $C0, $A0, $80, $60, $40, $20
	dc.b	$00, $C0, $A0, $80, $60, $40, $20, $00, $E0, $C0, $A0, $80, $60, $40, $20, $00
	dc.b	$00, $E0, $C0, $A0, $80, $60, $40, $20, $C0, $A0, $80, $60, $40, $20, $00, $00
	dc.b	$00, $C0, $E0, $C0, $A0, $80, $60, $40, $A0, $80, $60, $40, $20, $00, $00, $00
	dc.b	$00, $A0, $C0, $E0, $C0, $A0, $80, $60, $80, $60, $40, $20, $00, $00, $00, $00
	dc.b	$00, $80, $A0, $C0, $E0, $C0, $A0, $80, $60, $40, $20, $00, $00, $00, $00, $00
	dc.b	$00, $60, $80, $A0, $C0, $E0, $C0, $A0, $40, $20, $00, $00, $00, $00, $00, $00
	dc.b	$00, $40, $60, $80, $A0, $C0, $E0, $C0, $20, $00, $00, $00, $00, $00, $00, $00
	dc.b	$00, $20, $40, $60, $80, $A0, $C0, $E0, $00, $00, $00, $00, $00, $00, $00, $00
	dc.b	$00, $00, $20, $40, $60, $80, $A0, $C0, $00, $00, $00, $00, $00, $00, $00, $02
	dc.b	$00, $00, $00, $20, $40, $60, $80, $A0, $00, $00, $00, $00, $00, $00, $02, $04
	dc.b	$00, $00, $00, $00, $20, $40, $60, $80, $00, $00, $00, $00, $00, $02, $04, $06
	dc.b	$00, $00, $00, $00, $00, $20, $40, $60, $00, $00, $00, $00, $02, $04, $06, $08
	dc.b	$00, $00, $00, $00, $00, $00, $20, $40, $00, $00, $00, $02, $04, $06, $08, $0A
	dc.b	$00, $00, $00, $00, $00, $00, $00, $20, $00, $00, $02, $04, $06, $08, $0A, $0C
	dc.b	$00, $00, $00, $00, $00, $00, $00, $00, $00, $02, $04, $06, $08, $0A, $0C, $0E
	dc.b	$00, $00, $00, $00, $00, $00, $00, $00, $02, $04, $06, $08, $0A, $0C, $0E, $0C
	dc.b	$00, $02, $00, $00, $00, $00, $00, $00, $04, $06, $08, $0A, $0C, $0E, $0C, $0A
	dc.b	$00, $04, $02, $00, $00, $00, $00, $00, $06, $08, $0A, $0C, $0E, $0C, $0A, $08
	dc.b	$00, $06, $04, $02, $00, $00, $00, $00, $08, $0A, $0C, $0E, $0C, $0A, $08, $06
	dc.b	$00, $08, $06, $04, $02, $00, $00, $00, $0A, $0C, $0E, $0C, $0A, $08, $06, $04
	dc.b	$00, $0A, $08, $06, $04, $02, $00, $00, $0C, $0E, $0C, $0A, $08, $06, $04, $02
	dc.b	$00, $0C, $0A, $08, $06, $04, $02, $00, $0E, $0C, $0A, $08, $06, $04, $02, $00
	dc.b	$00, $0E, $0C, $0A, $08, $06, $04, $02, $0C, $0A, $08, $06, $04, $02, $00, $00
	dc.b	$00, $0C, $0E, $0C, $0A, $08, $06, $04, $0A, $08, $06, $04, $02, $00, $00, $00
	dc.b	$00, $0A, $0C, $0E, $0C, $0A, $08, $06, $08, $06, $04, $02, $00, $00, $00, $00
	dc.b	$00, $08, $0A, $0C, $0E, $0C, $0A, $08, $06, $04, $02, $00, $00, $00, $00, $00
	dc.b	$00, $06, $08, $0A, $0C, $0E, $0C, $0A, $04, $02, $00, $00, $00, $00, $00, $00
	dc.b	$00, $04, $06, $08, $0A, $0C, $0E, $0C, $02, $00, $00, $00, $00, $00, $00, $00
	dc.b	$00, $02, $04, $06, $08, $0A, $0C, $0E, $00, $00, $00, $00, $00, $00, $00, $00
	dc.b	$00, $00, $02, $04, $06, $08, $0A, $0C, $00, $00, $00, $00, $00, $00, $00, $20
	dc.b	$00, $00, $00, $02, $04, $06, $08, $0A, $00, $00, $00, $00, $00, $00, $20, $40
	dc.b	$00, $00, $00, $00, $02, $04, $06, $08, $00, $00, $00, $00, $00, $20, $40, $60
	dc.b	$00, $00, $00, $00, $00, $02, $04, $06, $00, $00, $00, $00, $20, $40, $60, $80
	dc.b	$00, $00, $00, $00, $00, $00, $02, $04, $00, $00, $00, $20, $40, $60, $80, $A0
	dc.b	$00, $00, $00, $00, $00, $00, $00, $02, $00, $00, $20, $40, $60, $80, $A0, $C0
	dc.b	$00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $40, $60, $80, $A0, $C0, $E0
	dc.b	$00, $00, $00, $00, $00, $00, $00, $00, $20, $40, $60, $80, $A0, $C0, $E0, $C0
	dc.b	$00, $20, $00, $00, $00, $00, $00, $00, $40, $60, $80, $A0, $C0, $E0, $C0, $A0
	dc.b	$00, $40, $20, $00, $00, $00, $00, $00, $60, $80, $A0, $C0, $E0, $C0, $A0, $80
	dc.b	$00, $60, $40, $20, $00, $00, $00, $00, $80, $A0, $C0, $E0, $C0, $A0, $80, $60
	dc.b	$00, $80, $60, $40, $20, $00, $00, $00, $A0, $C0, $E0, $C0, $A0, $80, $60, $40
	dc.b	$00, $A0, $80, $60, $40, $20, $00, $00, $C0, $E0, $C0, $A0, $80, $60, $40, $20
	dc.b	$00, $C0, $A0, $80, $60, $40, $20, $00, $E0, $C0, $A0, $80, $60, $40, $20, $00
	dc.b	$00, $E0, $C0, $A0, $80, $60, $40, $20, $C0, $A0, $80, $60, $40, $20, $00, $00
	dc.b	$00, $C0, $E0, $C0, $A0, $80, $60, $40, $A0, $80, $60, $40, $20, $00, $00, $00
	dc.b	$00, $A0, $C0, $E0, $C0, $A0, $80, $60, $80, $60, $40, $20, $00, $00, $00, $00
	dc.b	$00, $80, $A0, $C0, $E0, $C0, $A0, $80, $60, $40, $20, $00, $00, $00, $00, $00
	dc.b	$00, $60, $80, $A0, $C0, $E0, $C0, $A0, $40, $20, $00, $00, $00, $00, $00, $00
	dc.b	$00, $40, $60, $80, $A0, $C0, $E0, $C0, $20, $00, $00, $00, $00, $00, $00, $00

.Index:
	dc.w	0				; Palette cycle index

; -------------------------------------------------------------------------

PalCycle_SS2:
	lea	.Index(pc),a5			; Cycle
	move.w	(a5),d0
	addq.w	#2,(a5)
	andi.w	#7,(a5)
	move.l	.Cycle(pc,d0.w),$1A*2(a6)
	move.l	.Cycle+4(pc,d0.w),$1C*2(a6)

	bset	#1,ipxVSync			; Update CRAM
	rts

; -------------------------------------------------------------------------

.Cycle:
	dc.w	$E00, $E60, $EA6, $ECA
	dc.w	$E00, $E60, $EA6, $ECA

.Index:
	dc.w	0				; Palette cycle index

; -------------------------------------------------------------------------

PalCycle_SS3:
	lea	.Index1(pc),a1			; Cycle 1
	moveq	#2,d5
	moveq	#0,d6
	moveq	#$2E,d7
	bsr.w	IncValue
	andi.w	#$FFF8,d0
	move.l	.Cycle1(pc,d0.w),$1A*2(a6)
	move.l	.Cycle1+4(pc,d0.w),$1C*2(a6)

	lea	.Timer(pc),a1			; Get and increment cycle 2 timer
	moveq	#1,d5
	moveq	#0,d6
	moveq	#4,d7
	bsr.w	IncValue
	tst.w	d0				; Should we update cycle 2?
	bne.s	.End				; If not, branch

	lea	.Index2(pc),a1			; Cycle 2
	moveq	#2,d5
	moveq	#0,d6
	moveq	#$A,d7
	bsr.w	IncValue
	move.w	.Cycle2(pc,d0.w),$21*2(a6)

.End:
	bset	#1,ipxVSync			; Update CRAM
	rts

; -------------------------------------------------------------------------

.Cycle1:
	dc.w	$E00, $E42, $E84, $EC4
	dc.w	$E42, $E00, $EC4, $E84
	dc.w	$E84, $E42, $E84, $E42
	dc.w	$EC4, $E84, $E42, $E00
	dc.w	$E84, $EC4, $E00, $E42
	dc.w	$E42, $E84, $E42, $E84

.Cycle2:
	dc.w	$E00, $EC6, $E80, $E00
	dc.w	$E80, $EC6

.Index1:
	dc.w	0				; Palette cycle index 1
.Timer:
	dc.w	0				; Palette cycle 2 timer
.Index2:
	dc.w	0				; Palette cycle index 2

; -------------------------------------------------------------------------

PalCycle_SS4:
	lea	.Index1(pc),a5			; Cycle 1
	move.w	(a5),d0
	addq.w	#2,(a5)
	andi.w	#$18,d0
	move.l	.Cycle1(pc,d0.w),$1A*2(a6)
	move.l	.Cycle1+4(pc,d0.w),$1C*2(a6)

	lea	.Timer(pc),a1			; Get and increment cycle 2 timer
	moveq	#1,d5
	moveq	#0,d6
	moveq	#2,d7
	bsr.w	IncValue
	tst.w	d0				; Should we update cycle 2?
	bne.s	.End				; If not, branch

	move.w	.Index2-.Index1(a5),d0		; Cycle 2
	addq.w	#2,.Index2-.Index1(a5)
	andi.w	#$E,d0
	move.w	.Cycle2(pc,d0.w),$28*2(a6)

.End:
	bset	#1,ipxVSync			; Update CRAM
	rts

; -------------------------------------------------------------------------

.Cycle1:
	dc.w	$E20, $E42, $E84, $EC4
	dc.w	$EC4, $E20, $E42, $E84
	dc.w	$E84, $EC4, $E20, $E42
	dc.w	$E42, $E84, $EC4, $E20

.Cycle2:
	dc.w	$EC6, $EE8, $EEA, $EEC
	dc.w	$EEE, $EEC, $EEA, $EE8

.Index1:
	dc.w	0				; Palette cycle index 1
.Timer:
	dc.w	0				; Palette cycle 2 timer
.Index2:
	dc.w	0				; Palette cycle index 2

; -------------------------------------------------------------------------

PalCycle_SS5:
	lea	.Index1(pc),a1			; Cycle 1
	moveq	#2,d5
	moveq	#0,d6
	moveq	#$C,d7
	bsr.w	IncValue
	move.w	.Cycle1(pc,d0.w),$1A*2(a6)

	lea	.Index2(pc),a1			; Cycle 2
	moveq	#2,d5
	moveq	#0,d6
	moveq	#$32,d7
	bsr.w	IncValue
	move.w	.Cycle2(pc,d0.w),$2D*2(a6)

	lea	.Index3(pc),a1			; Cycle 3
	moveq	#1,d5
	moveq	#0,d6
	moveq	#$33,d7
	bsr.w	IncValue
	andi.w	#$FFFE,d0
	move.w	.Cycle3(pc,d0.w),$2E*2(a6)

	lea	.Index4(pc),a1			; Cycle 4
	moveq	#1,d5
	moveq	#0,d6
	moveq	#$37,d7
	bsr.w	IncValue
	andi.w	#$FFFE,d0
	lea	.Cycle4(pc),a5
	move.w	(a5,d0.w),$2F*2(a6)

	bset	#1,ipxVSync			; Update CRAM
	rts

; -------------------------------------------------------------------------

.Index1:
	dc.w	0				; Palette cycle index 1
.Index2:
	dc.w	0				; Palette cycle index 2
.Index3:
	dc.w	0				; Palette cycle index 3
.Index4:
	dc.w	0				; Palette cycle index 4

.Cycle1:
	dc.w	$E20, $E40, $E60, $E80
	dc.w	$EA0, $E80, $E60

.Cycle2:
	dc.w	$0EE, $0EC, $0EA, $0E8
	dc.w	$0E6, $0E4, $0E2, $2E0
	dc.w	$4E0, $6E0, $8E0, $AE0
	dc.w	$CE0, $EE0, $CE0, $AE0
	dc.w	$8E0, $6E0, $4E0, $2E0
	dc.w	$0E2, $0E4, $0E6, $0E8
	dc.w	$0EA, $0EC

.Cycle3:
	dc.w	$EE0, $CE0, $AE0, $8E0
	dc.w	$6E0, $4E0, $2E0, $0E2
	dc.w	$0E4, $0E6, $0E8, $0EA
	dc.w	$0EC, $0EE, $0EC, $0EA
	dc.w	$0E8, $0E6, $0E4, $0E2
	dc.w	$2E0, $4E0, $6E0, $8E0
	dc.w	$AE0, $CE0

.Cycle4:
	dc.w	$00E, $00C, $00A, $008
	dc.w	$006, $004, $002, $000
	dc.w	$002, $004, $006, $008
	dc.w	$00A, $00C, $00E, $00C
	dc.w	$00A, $008, $006, $004
	dc.w	$002, $000, $002, $004
	dc.w	$006, $008, $00A, $00C

; -------------------------------------------------------------------------

PalCycle_SS6:
	lea	.Index1(pc),a1			; Cycle 1
	moveq	#2,d5
	moveq	#0,d6
	moveq	#$18,d7
	bsr.w	IncValue
	lea	.Cycle1(pc,d0.w),a1
	lea	$21*2(a6),a2
	bsr.w	Copy24
	move.w	(a1)+,(a2)+

	lea	.Index2(pc),a1			; Cycle 2
	moveq	#2,d5
	moveq	#0,d6
	moveq	#$16,d7
	bsr.w	IncValue
	andi.w	#$FFFC,d0
	move.l	.Cycle2(pc,d0.w),$1D*2(a6)

	bset	#1,ipxVSync			; Update CRAM
	rts

; -------------------------------------------------------------------------

.Index1:
	dc.w	0				; Palette cycle index 1
.Index2:
	dc.w	0				; Palette cycle index 2

.Cycle1:
	dc.w	$04E, $08E, $0CE, $4EA
	dc.w	$8E8, $CE4, $EA4, $E68
	dc.w	$E0A, $E2E, $A0E, $60E
	dc.w	$20E, $04E, $08E, $0CE
	dc.w	$4EA, $8E8, $CE4, $EA4
	dc.w	$E68, $E0A, $E2E, $A0E
	dc.w	$60E, $20E

.Cycle2:
	dc.w	$E00, $204, $E20, $406
	dc.w	$E42, $204, $E64, $002
	dc.w	$E42, $000, $E20, $002

; -------------------------------------------------------------------------

PalCycle_SS7:
	lea	.Index(pc),a1			; Cycle
	moveq	#1,d5
	moveq	#0,d6
	moveq	#$17,d7
	bsr.w	IncValue
	andi.w	#$FFFE,d0
	move.w	.Cycle(pc,d0.w),$1F*2(a6)

	bset	#1,ipxVSync			; Update CRAM
	rts

; -------------------------------------------------------------------------

.Index:
	dc.w	0				; Palette cycle index

.Cycle:
	dc.w	$C20, $C20, $E40, $E40
	dc.w	$E60, $E60, $E80, $E80
	dc.w	$E60, $E60, $E40, $E40

; -------------------------------------------------------------------------

PalCycle_SS8:
	rts

; -------------------------------------------------------------------------
; Update the stage
; -------------------------------------------------------------------------

UpdateStage:
	btst	#0,GASUBFLAG			; Is the stage over?
	bne.s	.End				; If so, branch
	btst	#5,GASUBFLAG			; Are we exiting the stage manually?
	bne.s	.End				; If so, branch

	bset	#0,GACOMCMD2			; Tell Sub CPU to update the stage

.WaitSubCPU:
	tst.b	GACOMSTAT2			; Has the Sub CPU responded?
	beq.s	.WaitSubCPU			; If not, wait

	bclr	#0,GACOMCMD2			; Respond to the Sub CPU

.WaitSubCPU2:
	tst.b	GACOMSTAT2			; Has the Sub CPU responded?
	bne.s	.WaitSubCPU2			; If not, wait

.End:
	rts

; -------------------------------------------------------------------------
; Give Sub CPU Word RAM access
; -------------------------------------------------------------------------

GiveWordRAMAccess:
	btst	#0,GASUBFLAG			; Is the stage over?
	bne.s	.End				; If so, branch
	btst	#5,GASUBFLAG			; Are we exiting the stage manually?
	bne.s	.End				; If so, branch

	bset	#1,GAMEMMODE			; Give Sub CPU Word RAM access
	beq.s	GiveWordRAMAccess		; If it hasn't been given yet, branch

.End:
	rts

; -------------------------------------------------------------------------
; Wait for Word RAM access
; -------------------------------------------------------------------------

WaitWordRAMAccess:
	btst	#0,GASUBFLAG			; Is the stage over?
	bne.s	.End				; If so, branch
	btst	#5,GASUBFLAG			; Are we exiting the stage manually?
	bne.s	.End				; If so, branch

	btst	#0,GAMEMMODE			; Do we have Word RAM access?
	beq.s	WaitWordRAMAccess		; If so, branch

.End:
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
; Delay a number of cycles
; -------------------------------------------------------------------------

Delay:
	moveq	#$20-1,d0			; Delay
	dbf	d0,*
	rts

; -------------------------------------------------------------------------
; Check if we are in a stage with line scrolling for the background
; -------------------------------------------------------------------------

CheckLineScroll:
	cmpi.b	#1-1,specStageID		; Stage 1
	beq.s	.End
	cmpi.b	#5-1,specStageID		; Stage 5
	beq.s	.End
	cmpi.b	#6-1,specStageID		; Stage 6

.End:
	rts

; -------------------------------------------------------------------------
; Extra players text art
; -------------------------------------------------------------------------

	if REGION=USA
Art_ExtraPlayersText:
		incbin	"Special Stage/Data/Extra Players Text Art.nem"
		even
	endif

; -------------------------------------------------------------------------
; Fade to black
; -------------------------------------------------------------------------

FadeToBlack:
	move.b	#1,fadedOut.w			; Set faded out flag

	moveq	#8-1,d6				; Red channel
	moveq	#0,d0
	moveq	#1+0,d1

.FadeRed:
	bsr.s	.FadeColorChannel		; Fade channel
	addq.w	#2,d0				; Increase fade intensity
	dbf	d6,.FadeRed			; Loop until channel is faded

	moveq	#8-1,d6				; Green channel
	moveq	#0,d0
	moveq	#1+4,d1

.FadeGreen:
	bsr.s	.FadeColorChannel		; Fade channel
	addq.w	#2,d0				; Increase fade intensity
	dbf	d6,.FadeGreen			; Loop until channel is faded

	moveq	#8-1,d6				; Blue channel
	moveq	#0,d0
	moveq	#1+8,d1

.FadeBlue:
	bsr.s	.FadeColorChannel		; Fade channel
	addq.w	#2,d0				; Increase fade intensity
	dbf	d6,.FadeBlue			; Loop until channel is faded
	rts

; -------------------------------------------------------------------------
; Fade color channel to black
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Fade intensity
;	d1.w - Color bit offset
; -------------------------------------------------------------------------

.FadeColorChannel:
	lea	palette.w,a1			; Palette
	moveq	#$40-1,d7			; Fade entire palette

.ColorLoop:
	move.w	(a1),d2				; Get color
	rol.w	#1,d2				; Rotate to color channel
	ror.w	d1,d2

	move.w	d2,d3				; Split channel out
	andi.w	#$E,d2
	andi.w	#$EEE0,d3

	sub.w	d0,d2				; Apply fade intensity
	bcc.s	.Combine			; If it hasn't underflowed, branch
	moveq	#0,d2				; Cap color

.Combine:
	or.w	d3,d2				; Combine colors
	ror.w	#1,d2				; Rotate color channel back
	rol.w	d1,d2
	
	move.w	d2,(a1)+			; Update color data
	dbf	d7,.ColorLoop			; Loop until all colors are updated

	bset	#1,ipxVSync			; Update CRAM
	bra.w	VSync				; VSync

; -------------------------------------------------------------------------
; Prepare fade from black
; -------------------------------------------------------------------------

PrepFadeFromBlack:
	lea	palette.w,a1			; Palette
	lea	fadePalette.w,a2		; Fade palette buffer

	moveq	#0,d1				; Black
	moveq	#($40*2)/4-1,d7			; Transfer entire palette

.Transfer:
	move.l	(a1),(a2)+			; Transfer to fade buffer
	move.l	d1,(a1)+			; Fill palette with black
	dbf	d7,.Transfer			; Loop until entire palette is processed

	bset	#1,ipxVSync			; Update CRAM
	rts

; -------------------------------------------------------------------------
; Fade from black
; -------------------------------------------------------------------------

FadeFromBlack:
	move.w	#8-1,d6				; Blue channel
	moveq	#0,d0
	moveq	#1+8,d1

.FadeBlue:
	bsr.w	.FadeColorChannel		; Fade channel
	addq.w	#2,d0				; Increase fade intensity
	dbf	d6,.FadeBlue			; Loop until channel is faded

	move.w	#8-1,d6				; Green channel
	moveq	#0,d0
	moveq	#1+4,d1

.FadeGreen:
	bsr.w	.FadeColorChannel		; Fade channel
	addq.w	#2,d0				; Increase fade intensity
	dbf	d6,.FadeGreen			; Loop until channel is faded
	
	move.w	#8-1,d6				; Red channel
	moveq	#0,d0
	moveq	#1+0,d1

.FadeRed:
	bsr.w	.FadeColorChannel		; Fade channel
	addq.w	#2,d0				; Increase fade intensity
	dbf	d6,.FadeRed			; Loop until channel is faded

	move.b	#0,fadedOut.w			; Clear faded out flag
	rts

; -------------------------------------------------------------------------
; Fade color channel from black
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Fade intensity
;	d1.w - Color bit offset
; -------------------------------------------------------------------------

.FadeColorChannel:
	lea	palette.w,a1			; Palette
	lea	fadePalette.w,a2		; Fade palette buffer
	moveq	#$40-1,d7			; Fade entire palette

.ColorLoop:
	move.w	(a2)+,d2			; Get target color
	move.w	(a1),d3				; Get current color
	rol.w	#1,d2				; Rotate to color channel
	rol.w	#1,d3
	ror.w	d1,d2
	ror.w	d1,d3

	andi.w	#$E,d2				; Use channel from target color
	andi.w	#$EEE0,d3			; Retain other channels from current color

	cmp.w	d0,d2				; Cap channel at fade intensity
	bls.s	.Combine
	move.w	d0,d2

.Combine:
	or.w	d3,d2				; Combine colors
	rol.w	d1,d2				; Rotate color channel back
	ror.w	#1,d2
	
	move.w	d2,(a1)+			; Update color data
	dbf	d7,.ColorLoop			; Loop until all colors are updated

	bset	#1,ipxVSync			; Update CRAM
	bra.w	VSync				; VSync

; -------------------------------------------------------------------------
; Fade to white
; -------------------------------------------------------------------------

FadeToWhite:
	move.b	#1,fadedOut.w			; Set faded out flag

	moveq	#8-1,d6				; Red channel
	moveq	#1+0,d1

.FadeRed:
	bsr.s	.FadeColorChannel		; Fade channel
	dbf	d6,.FadeRed			; Loop until channel is faded

	moveq	#8-1,d6				; Green channel
	moveq	#1+4,d1

.FadeGreen:
	bsr.s	.FadeColorChannel		; Fade channel
	dbf	d6,.FadeGreen			; Loop until channel is faded

	moveq	#8-1,d6				; Blue channel
	moveq	#1+8,d1

.FadeBlue:
	bsr.s	.FadeColorChannel		; Fade channel
	dbf	d6,.FadeBlue			; Loop until channel is faded
	rts

; -------------------------------------------------------------------------
; Fade color channel to white
; -------------------------------------------------------------------------
; PARAMETERS:
;	d1.w - Color bit offset
; -------------------------------------------------------------------------

.FadeColorChannel:
	lea	palette.w,a1			; Palette
	moveq	#$40-1,d7			; Fade entire palette

.ColorLoop:
	move.w	(a1),d2				; Get color
	rol.w	#1,d2				; Rotate to color channel
	ror.w	d1,d2

	move.w	d2,d3				; Split channel out
	andi.w	#$E,d2
	andi.w	#$EEE0,d3

	addq.w	#2,d2				; Fade towards white
	cmpi.w	#$E,d2				; Cap at white
	bls.s	.Combine
	moveq	#$E,d2

.Combine:
	or.w	d3,d2				; Combine colors
	ror.w	#1,d2				; Rotate color channel back
	rol.w	d1,d2
	
	move.w	d2,(a1)+			; Update color data
	dbf	d7,.ColorLoop			; Loop until all colors are updated

	bset	#1,ipxVSync			; Update CRAM
	bra.w	VSync				; VSync

; -------------------------------------------------------------------------
; Prepare fade from white
; -------------------------------------------------------------------------

PrepFadeFromWhite:
	lea	palette.w,a1			; Palette
	lea	fadePalette.w,a2		; Fade palette buffer

	move.l	#$EEE0EEE,d1			; White
	moveq	#($40*2)/4-1,d7			; Transfer entire palette

.Transfer:
	move.l	(a1),(a2)+			; Transfer to fade buffer
	move.l	d1,(a1)+			; Fill palette with bwhitelack
	dbf	d7,.Transfer			; Loop until entire palette is processed

	bset	#1,ipxVSync			; Update CRAM
	rts

; -------------------------------------------------------------------------
; Fade from white
; -------------------------------------------------------------------------

FadeFromWhite:
	moveq	#8-1,d6				; Red channel
	moveq	#$E,d0
	moveq	#1+0,d1

.FadeRed:
	bsr.w	.FadeColorChannel		; Fade channel
	subq.w	#2,d0				; Decrease fade intensity
	dbf	d6,.FadeRed			; Loop until channel is faded

	moveq	#8-1,d6				; Green channel
	moveq	#$E,d0
	moveq	#1+4,d1

.FadeGreen:
	bsr.w	.FadeColorChannel		; Fade channel
	subq.w	#2,d0				; Decrease fade intensity
	dbf	d6,.FadeGreen			; Loop until channel is faded
	
	moveq	#8-1,d6				; Blue channel
	moveq	#$E,d0
	moveq	#1+8,d1

.FadeBlue:
	bsr.w	.FadeColorChannel		; Fade channel
	subq.w	#2,d0				; Decrease fade intensity
	dbf	d6,.FadeBlue			; Loop until channel is faded

	move.b	#0,fadedOut.w			; Clear faded out flag
	rts

; -------------------------------------------------------------------------
; Fade color channel from white
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Fade intensity
;	d1.w - Color bit offset
; -------------------------------------------------------------------------

.FadeColorChannel:
	lea	palette.w,a1			; Palette
	lea	fadePalette.w,a2		; Fade palette buffer
	moveq	#$40-1,d7			; Fade entire palette

.ColorLoop:
	move.w	(a2)+,d2			; Get target color
	move.w	(a1),d3				; Get current color
	rol.w	#1,d2				; Rotate to color channel
	rol.w	#1,d3
	ror.w	d1,d2
	ror.w	d1,d3

	andi.w	#$E,d2				; Use channel from target color
	andi.w	#$EEE0,d3			; Retain other channels from current color

	cmp.w	d0,d2				; Cap channel at fade intensity
	bcc.s	.Combine
	move.w	d0,d2

.Combine:
	or.w	d3,d2				; Combine colors
	rol.w	d1,d2				; Rotate color channel back
	ror.w	#1,d2
	
	move.w	d2,(a1)+			; Update color data
	dbf	d7,.ColorLoop			; Loop until all colors are updated

	bset	#1,ipxVSync			; Update CRAM
	bra.w	VSync				; VSync

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
; Send a command to the Sub CPU
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Command ID
; -------------------------------------------------------------------------

SubCPUCmd:
	move.w	d0,GACOMCMD0			; Set command ID

.WaitSubCPU:
	move.w	GACOMSTAT0,d0			; Has the Sub CPU received the command?
	beq.s	.WaitSubCPU			; If not, wait
	cmp.w	GACOMSTAT0,d0
	bne.s	.WaitSubCPU			; If not, wait

	move.w	#0,GACOMCMD0			; Mark as ready to send commands again

.WaitSubCPUDone:
	move.w	GACOMSTAT0,d0			; Is the Sub CPU done processing the command?
	bne.s	.WaitSubCPUDone			; If not, wait
	move.w	GACOMSTAT0,d0
	bne.s	.WaitSubCPUDone			; If not, wait
	rts

; -------------------------------------------------------------------------
; Play an FM sound
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.b - Sound ID
; -------------------------------------------------------------------------

PlayFMSound:
	bsr.w	StopZ80				; Stop the Z80
	tst.b	FMDrvQueue1+1			; Is queue 1 full?
	bne.s	.CheckQueue2			; If so, branch
	move.b	d0,FMDrvQueue1+1		; Set ID in queue 1
	bra.s	.End

.CheckQueue2:
	tst.b	FMDrvQueue2+1			; Is queue 2 full?
	bne.s	.CheckQueue3			; If so, branch
	move.b	d0,FMDrvQueue2+1		; Set ID in queue 2
	bra.s	.End

.CheckQueue3:
	tst.b	FMDrvQueue3+1			; Is queue 3 full?
	bne.s	.End				; If so, branch
	move.b	d0,FMDrvQueue3+1		; Set ID in queue 3

.End:
	bsr.w	StartZ80			; Start the Z80
	rts
	
; -------------------------------------------------------------------------
; Play Sub CPU FM sounds
; -------------------------------------------------------------------------

PlaySubFMSounds:
	bsr.w	StopZ80				; Stop the Z80
	move.b	subSndQueue1,FMDrvQueue1+1	; Update queue 1
	move.b	subSndQueue2,FMDrvQueue2+1	; Update queue 2
	move.b	subSndQueue3,FMDrvQueue3+1	; Update queue 3
	bsr.w	StartZ80			; Start the Z80
	rts

; -------------------------------------------------------------------------
; Draw extra player icons
; -------------------------------------------------------------------------

DrawExtraPlayers:
	addq.w	#1,.AnimTimer			; Increment animation timer
	andi.w	#7,.AnimTimer			; Is the current frame over?
	bne.s	.End				; If not, branch

	addq.w	#1,.AnimFrame			; Increment and loop frame
	andi.w	#1,.AnimFrame

	move.w	extraPlayerCnt.w,d0		; Get number of extra players
	beq.s	.End				; If there are none, branch
	subq.w	#1,d0				; Make count zero based
	cmpi.w	#6-1,d0				; Are there more than 5 extra players?
	bcs.s	.Draw				; If not, branch
	moveq	#5-1,d0				; Cap at 5 icons

.Draw:
	add.w	d0,d0				; Draw icons
	move.w	.IconDraw(pc,d0.w),d0
	jmp	.IconDraw(pc,d0.w)

.End:
	rts

; -------------------------------------------------------------------------

.IconDraw:
	dc.w	.Draw1Icon-.IconDraw		; 1 icon
	dc.w	.Draw2Icons-.IconDraw		; 2 icons
	dc.w	.Draw3Icons-.IconDraw		; 3 icons
	dc.w	.Draw4Icons-.IconDraw		; 4 icons
	dc.w	.Draw45cons-.IconDraw		; 5 icons

; -------------------------------------------------------------------------

.Draw45cons:
	moveq	#8,d0				; Icon 5
	bsr.s	.DrawIcon

.Draw4Icons:
	moveq	#6,d0				; Icon 4
	bsr.s	.DrawIcon

.Draw3Icons:
	moveq	#4,d0				; Icon 3
	bsr.s	.DrawIcon

.Draw2Icons:
	moveq	#2,d0				; Icon 2
	bsr.s	.DrawIcon

.Draw1Icon:
	moveq	#0,d0				; Icon 1

; -------------------------------------------------------------------------

.DrawIcon:
	moveq	#0,d5				; Draw icon frame
	add.w	.AnimFrame,d0
	move.b	.IconMaps(pc,d0.w),d5
	bra.w	DrawTilemaps

; -------------------------------------------------------------------------

.IconMaps:
	dc.b	$39, $38			; Icon 1
	dc.b	$3C, $3B			; Icon 2
	dc.b	$46, $45			; Icon 3
	dc.b	$49, $48			; Icon 4
	dc.b	$4C, $4B			; Icon 5

.AnimFrame:
	dc.w	0				; Animation frame
.AnimTimer:
	dc.w	0				; Animation timer

; -------------------------------------------------------------------------
; Draw results time bonus
; -------------------------------------------------------------------------

DrawResTimeBonus:
	move.b	#0,gotLeadDigit			; Clear leading digit found flag

	lea	DrawNum_10000000(pc),a1		; Draw time bonus
	move.l	#$4A300003,d4
	move.l	#$4AB00003,d5
	move.l	timeBonus,d0
	moveq	#8-1,d1
	bra.s	DrawResultsNum

; -------------------------------------------------------------------------
; Draw results ring bonus
; -------------------------------------------------------------------------

DarwResRingBonus:
	move.b	#0,gotLeadDigit			; Clear leading digit found flag

	lea	DrawNum_10000000(pc),a1		; Draw ring bonus
	VDPCMD	move.l,$C8B0,VRAM,WRITE,d4
	VDPCMD	move.l,$C930,VRAM,WRITE,d5
	move.l	ringBonus,d0
	moveq	#8-1,d1
	bra.s	DrawResultsNum

; -------------------------------------------------------------------------
; Draw results score
; -------------------------------------------------------------------------

DrawResultsScore:
	move.b	#0,gotLeadDigit			; Clear leading digit found flag

	lea	DrawNum_10000000(pc),a1		; Draw score
	VDPCMD	move.l,$C730,VRAM,WRITE,d4
	VDPCMD	move.l,$C7B0,VRAM,WRITE,d5
	move.l	score,d0
	moveq	#8-1,d1

; -------------------------------------------------------------------------
; Draw results number
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - Number to draw
;	d1.w - Number of digits to draw (minus 1)
;	d4.l - VDP command (top tiles)
;	d5.l - VDP command (bottom tiles)
;	a1.l - Pointer to digit counter list
; -------------------------------------------------------------------------

DrawResultsNum:
	move.l	d0,d2				; Multiply number by 10
	add.l	d2,d2
	lsl.l	#3,d0
	add.l	d2,d0

	lea	VDPCTRL,a2			; VDP control port
	lea	VDPDATA,a3			; VDP data port

	tst.l	d0				; Is the number 0?
	beq.w	.DrawZero			; If so, branch

.DigitLoop:
	move.l	d4,(a2)				; Set top VDP command
	moveq	#0,d2				; Reset digit counter
	move.l	(a1)+,d3			; Get digit to isolate

.GetDigit:
	sub.l	d3,d0				; Find digit value
	bcs.s	.GotDigit			; If we haven't got our digit yet, branch
	addq.w	#1,d2				; Increment digit counter
	bra.s	.GetDigit			; Loop

.GotDigit:
	add.l	d3,d0				; Fix value

	tst.b	gotLeadDigit			; Did we already get the leading digit?
	bne.s	.DrawDigit			; If so, branch
	tst.w	d2				; If this digit 0?
	beq.s	.DrawBlank			; If so, draw a blank instead
	move.b	#1,gotLeadDigit			; If not, mark leading digit as found

.DrawDigit:
	add.w	d2,d2				; Draw top
	move.w	.NumTilesUpper(pc,d2.w),(a3)
	move.l	d5,(a2)				; Draw bottom
	move.w	.NumTilesLower(pc,d2.w),(a3)

	bra.s	.NextDigit			; Next digit

.DrawBlank:
	move.w	#0,(a3)				; Draw top blank
	move.l	d5,(a2)				; Draw bottom blank
	move.w	#0,(a3)

.NextDigit:
	addi.l	#$20000,d4			; Shift right
	addi.l	#$20000,d5
	dbf	d1,.DigitLoop			; Loop until number is drawn
	rts

; -------------------------------------------------------------------------

.NumTilesUpper:
	dc.w	$402D				; 0
	dc.w	$402F				; 1
	dc.w	$4031				; 2
	dc.w	$4033				; 3
	dc.w	$4034				; 4
	dc.w	$4036				; 5
	dc.w	$4038				; 6
	dc.w	$4039				; 7
	dc.w	$403A				; 8
	dc.w	$403B				; 9

.NumTilesLower:
	dc.w	$402E				; 0
	dc.w	$4030				; 1
	dc.w	$4032				; 2
	dc.w	$402E				; 3
	dc.w	$4035				; 4
	dc.w	$4037				; 5
	dc.w	$402E				; 6
	dc.w	$4030				; 7
	dc.w	$402E				; 8
	dc.w	$402E				; 9

; -------------------------------------------------------------------------

.DrawZero:
	subq.w	#1,d1				; Number of blank spaces

.DrawBlanksZero:
	move.l	d4,(a2)				; Draw blank tile
	move.w	#0,(a3)
	move.l	d5,(a2)
	move.w	#0,(a3)
	addi.l	#$20000,d4			; Shift right
	addi.l	#$20000,d5
	dbf	d1,.DrawBlanksZero		; Loop until blank tiles are set

	move.l	d4,(a2)				; Draw zero
	move.w	#$402D,(a3)
	move.l	d5,(a2)
	move.w	#$402E,(a3)
	rts

; -------------------------------------------------------------------------

gotLeadDigit:
	dc.b	0				; Leading digit found flag
	even

; -------------------------------------------------------------------------
; Decrease a value within a range
; -------------------------------------------------------------------------
; PARAMETERS:
;	d5.w - Decrement value
;	d6.w - Minimum value
;	d7.w - Maximum value
;	a1.l - Pointer to value
; -------------------------------------------------------------------------

DecValue:
	move.w	(a1),d0				; Get value
	sub.w	d5,d0				; Decrease it

	cmp.w	d6,d0				; Has it passed the minimum value?
	bge.s	.SetValue			; If not, branch
	move.w	d7,d0				; Wrap to the maximum value

.SetValue:
	move.w	d0,(a1)				; Update value
	rts
	
; -------------------------------------------------------------------------
; Increase a value within a range (word)
; -------------------------------------------------------------------------
; PARAMETERS:
;	d5.w - Increment value
;	d6.w - Minimum value
;	d7.w - Maximum value
;	a1.l - Pointer to value
; -------------------------------------------------------------------------

IncValue:
	move.w	(a1),d0				; Get value
	add.w	d5,d0				; Increase it

	cmp.w	d7,d0				; Has it passed the maximum value?
	bls.s	.SetValue			; If not, branch
	move.w	d6,d0				; Wrap to the minimum value

.SetValue:
	move.w	d0,(a1)				; Update value
	rts

; -------------------------------------------------------------------------
; Draw timer
; -------------------------------------------------------------------------

DrawTimer:
	btst	#1,specStageFlags		; Are we in time attack mode?
	bne.s	.TimeAttack			; If so, branch
	
	lea	DrawNum_100(pc),a1		; Draw countdown timer
	VDPCMD	move.l,$C0A0,VRAM,WRITE,d4
	VDPCMD	move.l,$C120,VRAM,WRITE,d5
	move.l	specStageTimer,d0
	moveq	#3-1,d1
	bra.w	DrawNumber

; -------------------------------------------------------------------------

.TimeAttack:
	lea	DrawNum_10(pc),a1		; Draw minute
	VDPCMD	move.l,$C09A,VRAM,WRITE,d4
	VDPCMD	move.l,$C11A,VRAM,WRITE,d5
	move.l	specStageTimer,d0
	swap	d0
	andi.l	#$FF,d0
	moveq	#2-1,d1
	bsr.w	DrawNumber

	lea	DrawNum_10(pc),a1		; Draw second
	VDPCMD	move.l,$C0A0,VRAM,WRITE,d4
	VDPCMD	move.l,$C120,VRAM,WRITE,d5
	move.l	specStageTimer,d0
	lsr.w	#8,d0
	andi.l	#$FF,d0
	moveq	#2-1,d1
	bsr.w	DrawNumber

	lea	DrawNum_10(pc),a1		; Draw centisecond
	VDPCMD	move.l,$C0A6,VRAM,WRITE,d4
	VDPCMD	move.l,$C126,VRAM,WRITE,d5
	move.l	specStageTimer,d0
	andi.l	#$FF,d0
	mulu.w	#100,d0
	divu.w	#60,d0
	ext.l	d0
	moveq	#2-1,d1
	bra.w	DrawNumber

; -------------------------------------------------------------------------
; Draw ring count
; -------------------------------------------------------------------------

DrawRingCount:
	lea	DrawNum_100(pc),a1		; Draw ring count
	VDPCMD	move.l,$C0B6,VRAM,WRITE,d4
	VDPCMD	move.l,$C136,VRAM,WRITE,d5
	move.w	specStageRings,d0
	moveq	#3-1,d1
	bra.s	DrawNumber

; -------------------------------------------------------------------------
; Draw UFO count
; -------------------------------------------------------------------------

DrawUFOCount:
	lea	DrawNum_10(pc),a1		; Draw UDO count
	VDPCMD	move.l,$C08A,VRAM,WRITE,d4
	VDPCMD	move.l,$C10A,VRAM,WRITE,d5
	moveq	#0,d0
	move.b	ufoCount,d0
	moveq	#2-1,d1

; -------------------------------------------------------------------------
; Draw number
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - Number to draw
;	d1.w - Number of digits to draw (minus 1)
;	d4.l - VDP command (top tiles)
;	d5.l - VDP command (bottom tiles)
;	a1.l - Pointer to digit counter list
; -------------------------------------------------------------------------

DrawNumber:
	lea	VDPCTRL,a2			; VDP control port
	lea	VDPDATA,a3			; VDP data port

.DigitLoop:
	move.l	d4,(a2)				; Set top VDP command
	moveq	#0,d2				; Reset digit counter
	move.l	(a1)+,d3			; Get digit to isolate

.GetDigit:
	sub.l	d3,d0				; Find digit value
	bcs.s	.GotDigit			; If we haven't got our digit yet, branch
	addq.w	#1,d2				; Increment digit counter
	bra.s	.GetDigit			; Loop

.GotDigit:
	add.l	d3,d0				; Fix value

	add.w	d2,d2				; Draw top
	move.w	NumTilesUpper(pc,d2.w),(a3)
	move.l	d5,(a2)				; Draw bottom
	move.w	NumTilesLower(pc,d2.w),(a3)

	addi.l	#$20000,d4			; Shift right
	addi.l	#$20000,d5
	dbf	d1,.DigitLoop			; Loop until number is drawn
	rts

; -------------------------------------------------------------------------

DrawNum_10000000:
	dc.l	10000000
DrawNum_1000000:
	dc.l	1000000
DrawNum_100000:
	dc.l	100000
DrawNum_10000:
	dc.l	10000
DrawNum_1000:
	dc.l	1000
DrawNum_100:
	dc.l	100
DrawNum_10:
	dc.l	10
DrawNum_1:
	dc.l	1

NumTilesUpper:
	dc.w	$87DE				; 0
	dc.w	$87DF				; 1
	dc.w	$87E0				; 2
	dc.w	$87E1				; 3
	dc.w	$87E2				; 4
	dc.w	$87E3				; 5
	dc.w	$87E4				; 6
	dc.w	$87E5				; 7
	dc.w	$87E6				; 8
	dc.w	$87DE				; 9
	dc.w	$87E7				; '
	dc.w	$87E8				; "
	
NumTilesLower:
	dc.w	$87E9				; 0
	dc.w	$87EA				; 1
	dc.w	$87EB				; 2
	dc.w	$87EC				; 3
	dc.w	$87ED				; 4
	dc.w	$87EE				; 5
	dc.w	$87EF				; 6
	dc.w	$87F0				; 7
	dc.w	$87F1				; 8
	dc.w	$87F2				; 9
	dc.w	$0000				; '
	dc.w	$0000				; "

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
; Get Sub CPU data
; -------------------------------------------------------------------------

GetSubCPUData:
	lea	WORDRAM2M+IMGBUFFER,a1		; Rendered image in Word RAM
	lea	stageImage.w,a2			; Destination buffer
	move.w	#(IMGLENGTH/$800)-1,d7		; Number of $800 byte chunks to copy

.CopyChunks:
	rept	$800/$80			; Copy $800 bytes
		bsr.s	Copy128
	endr
	dbf	d7,.CopyChunks

	lea	subSprites,a1			; Copy sprite data
	lea	sprites.w,a2
	rept	$280/$80
		bsr.s	Copy128
	endr

	move.b	subSplashLoad,splashArtLoad.w	; Get splash art load flag
	move.b	#0,subSplashLoad
	move.b	subScrollFlags,scrollFlags.w	; Get scroll flags
	move.b	#0,subScrollFlags

	lea	subSonicArtBuf,a1		; Copy Sonic art
	lea	sonicArtBuf.w,a2
	rept	$300/$80
		bsr.s	Copy128
	endr

	bra.w	PlaySubFMSounds			; Play FM sounds played by Sub CPU

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
; Initialize the Mega Drive hardware (results)
; -------------------------------------------------------------------------

InitMDResults:
	lea	ResultsVDPRegs(pc),a0
	bra.s	InitMD

; -------------------------------------------------------------------------
; Initialize the Mega Drive hardware (stage)
; -------------------------------------------------------------------------

InitMDStage:
	lea	StageVDPRegs(pc),a0

; -------------------------------------------------------------------------
; Initialize the Mega Drive hardware
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to VDP register data table
; -------------------------------------------------------------------------

InitMD:
	move.w	#$8000,d0			; Set up VDP registers
	moveq	#$13-1,d7

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

	bsr.w	StopZ80				; Stop the Z80
	
	DMAFILL	0,$10000,0			; Clear VRAM

	VDPCMD	move.l,0,VSRAM,WRITE,VDPCTRL	; Clear VSRAM
	move.l	#0,VDPDATA

	bsr.w	StartZ80			; Start the Z80
	move.w	#$8134,ipxVDPReg1		; Reset IPX VDP register 1 cache
	rts

; -------------------------------------------------------------------------

StageVDPRegs:
	dc.b	%00000100			; No H-INT
	dc.b	%00110100			; V-INT, DMA, mode 5
	dc.b	$C000/$400			; Plane A location
	dc.b	0				; Window location
	dc.b	$E000/$2000			; Plane B location
	dc.b	$D400/$200			; Sprite table location
	dc.b	0				; Reserved
	dc.b	$20				; BG color line 2 color 0
	dc.b	0				; Reserved
	dc.b	0				; Reserved
	dc.b	0				; H-INT counter 0
	dc.b	%00000010			; Scroll by row
	dc.b	%00000000			; H32
	dc.b	$D000/$400			; Horizontal scroll table lcation
	dc.b	0				; Reserved
	dc.b	2				; Auto increment by 2
	dc.b	%00000001			; 64x32 tile plane size
	dc.b	0				; Window horizontal position 0
	dc.b	0				; Window vertical position 0
	even

ResultsVDPRegs:
	dc.b	%00000100			; No H-INT
	dc.b	%00110100			; V-INT, DMA, mode 5
	dc.b	$C000/$400			; Plane A location
	dc.b	0				; Window location
	dc.b	$E000/$2000			; Plane B location
	dc.b	$F000/$200			; Sprite table location
	dc.b	0				; Reserved
	dc.b	0				; BG color line 0 color 0
	dc.b	0				; Reserved
	dc.b	0				; Reserved
	dc.b	0				; H-INT counter 0
	dc.b	%00000000			; Scroll by screen
	dc.b	%10000001			; H40
	dc.b	$F400/$400			; Horizontal scroll table lcation
	dc.b	0				; Reserved
	dc.b	2				; Auto increment by 2
	dc.b	%00000001			; 64x32 tile plane size
	dc.b	0				; Window horizontal position 0
	dc.b	0				; Window vertical position 0
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
	lea	ctrlData,a5			; Controller data buffer
	lea	IODATA1,a6			; Controller port 1
	
	move.b	#0,(a6)				; TH = 0
	tst.w	(a5)				; Delay
	move.b	(a6),d0				; Read start and A buttons
	lsl.b	#2,d0
	andi.b	#$C0,d0

	move.b	#$40,(a6)			; TH = 1
	tst.w	(a5)				; Delay
	move.b	(a6),d1				; Read B, C, and D-pad buttons
	andi.b	#$3F,d1
	
	or.b	d1,d0				; Combine button data
	not.b	d0				; Flip bits

	btst	#0,specStageFlags		; Are we in temporary mode?
	beq.s	.Store				; If not, branch
	btst	#2,specStageFlags		; Are we in secret mode?
	bne.s	.Store				; If so, branch

	bsr.s	RunDemo				; Run demo

.Store:
	move.b	d0,d1				; Make copy
	
	move.b	(a5),d2				; Mask out tapped buttons
	eor.b	d2,d0
	move.b	d1,(a5)+			; Store pressed buttons
	and.b	d1,d0				; Store tapped buttons
	move.b	d0,(a5)+
	bpl.s	.End				; If the start button wasn't pressed, branch

	btst	#7,paused.w			; Is pausing enabled?
	beq.s	.End				; If not, branch
	eori.b	#1,paused.w			; Switch pause flag

.End:
	rts

; -------------------------------------------------------------------------
; Record demo
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Controller input data
; -------------------------------------------------------------------------

RecordDemo:
	tst.b	demoActive.w			; Is the demo activated?
	beq.s	.End				; If not, branch

	movea.l	demoDataPtr.w,a6		; Get current demo data pointer
	move.b	d0,(a6)+			; Store controller input data
	move.l	a6,demoDataPtr.w		; Update demo data pointer

	btst	#7,d0				; Has the start button been pressed?
	bne.s	.Done				; If so, branch

.End:
	rts

.Done:
	move.b	#0,demoActive.w			; Deactivate the demo
	rts

; -------------------------------------------------------------------------
; Run demo
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Controller input data
; RETURNS:
;	d0.w - Demo controller input data
; -------------------------------------------------------------------------

RunDemo:
	btst	#7,d0				; Has the start button been pressed?
	bne.s	.Done				; If so, branch
	tst.b	demoActive.w			; Is the demo activated?
	beq.s	.End				; If not, branch

	movea.l	demoDataPtr.w,a6		; Get current demo data pointer
	move.b	(a6)+,d0			; Read demo controller data
	move.l	a6,demoDataPtr.w		; Update demo data pointer

.End:
	rts

.Done:
	move.b	#0,demoActive.w
	rts

; -------------------------------------------------------------------------
; Draw stage tilemap
; -------------------------------------------------------------------------

DrawStageMap:
	move.w	#$2001,d6			; Buffer 1 base tile ID

	lea	VDPCTRL,a2			; VDP control port
	lea	VDPDATA,a3			; VDP data port

	VDPCMD	move.l,$C800,VRAM,WRITE,d0	; Draw buffer 1 tilemap
	moveq	#IMGWTILE-1,d1
	moveq	#IMGHTILE-1,d2
	bsr.s	.DrawMap

	move.w	#$2181,d6			; Draw buffer 2 tilemap
	VDPCMD	move.l,$C840,VRAM,WRITE,d0
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
	tst.w	d3				; Is this the rightmost tile in the row?
	bne.s	.NoPriority			; If not, branch
	addi.w	#$8000,d5			; If so, set the priority bit

.NoPriority:
	move.w	d5,(a3)				; Write tile ID
	addi.w	#IMGHTILE,d5			; Next column tile
	dbf	d3,.DrawTile			; Loop until row is written
	
	add.l	d4,d0				; Next row
	addq.w	#1,d6				; Next column tile
	dbf	d2,.DrawRow			; Loop until map is drawn
	rts

; -------------------------------------------------------------------------
; Draw tilemaps
; -------------------------------------------------------------------------
; PARAMETERS:
;	d5.l - Tilemap IDs (each byte is an ID)
; -------------------------------------------------------------------------

DrawTilemaps:
	moveq	#4-1,d7				; Number of IDs in the queue

.Loop:
	moveq	#0,d6				; Get tilemap ID
	move.b	d5,d6
	beq.s	.NextMap			; If it's blank, branch

	mulu.w	#$C,d6				; Get tilemap data
	movea.l	.Tilemaps-$C(pc,d6.w),a0
	move.l	(.Tilemaps-$C)+4(pc,d6.w),d0
	move.w	(.Tilemaps-$C)+$A(pc,d6.w),d2
	move.w	(.Tilemaps-$C)+8(pc,d6.w),d1

	tst.w	(a0)+				; Is this tilemap compressed?
	bne.s	.Compressed			; If so, branch
	movea.l	a0,a1				; If not, just draw it
	bra.s	.Draw

.Compressed:
	movem.l	d0-d7,-(sp)			; Decompress the tilemap
	lea	mapKosBuffer.w,a1
	bsr.w	KosDec
	movem.l	(sp)+,d0-d7

	lea	mapKosBuffer.w,a1		; Draw the decompressed tilemap

.Draw:
	jsr	DrawTilemap(pc)			; Draw tilemap

.NextMap:
	ror.l	#8,d5				; Next tilemap ID
	dbf	d7,.Loop			; Loop until tilemaps are drawn
	rts

; -------------------------------------------------------------------------

.Tilemaps:
	dc.l	Map_SS2BGA1			; Stage 2 background chunk A1
	VDPCMD	dc.l,$C000,VRAM,WRITE
	dc.w	$20-1
	dc.w	$10-1
	
	dc.l	Map_SS2BGA2			; Stage 2 background chunk A2
	VDPCMD	dc.l,$C040,VRAM,WRITE
	dc.w	$20-1
	dc.w	$10-1
	
	dc.l	Map_SS2BGB1			; Stage 2 background chunk B1
	VDPCMD	dc.l,$E000,VRAM,WRITE
	dc.w	$20-1
	dc.w	$10-1
	
	dc.l	Map_SS2BGB2			; Stage 2 background chunk B2
	VDPCMD	dc.l,$E040,VRAM,WRITE
	dc.w	$20-1
	dc.w	$10-1
	
	dc.l	Map_SS2BGB3			; Stage 2 background chunk B3
	VDPCMD	dc.l,$E800,VRAM,WRITE
	dc.w	$20-1
	dc.w	$C-1
	
	dc.l	Map_SS3BGA1			; Stage 3 background chunk A1
	VDPCMD	dc.l,$C000,VRAM,WRITE
	dc.w	$20-1
	dc.w	$10-1
	
	dc.l	Map_SS3BGA2			; Stage 3 background chunk A2
	VDPCMD	dc.l,$C040,VRAM,WRITE
	dc.w	$20-1
	dc.w	$10-1
	
	dc.l	Map_SS3BGB1			; Stage 3 background chunk B1
	VDPCMD	dc.l,$E000,VRAM,WRITE
	dc.w	$20-1
	dc.w	$E-1
	
	dc.l	Map_SS3BGB3			; Stage 3 background chunk B3
	VDPCMD	dc.l,$E040,VRAM,WRITE
	dc.w	$20-1
	dc.w	$E-1
	
	dc.l	Map_SS3BGB2			; Stage 3 background chunk B2
	VDPCMD	dc.l,$E700,VRAM,WRITE
	dc.w	$20-1
	dc.w	2-1
	
	dc.l	Map_SS3BGB4			; Stage 3 background chunk B4
	VDPCMD	dc.l,$E740,VRAM,WRITE
	dc.w	$20-1
	dc.w	2-1
	
	dc.l	Map_SS4BGA1			; Stage 4 background chunk A1
	VDPCMD	dc.l,$C000,VRAM,WRITE
	dc.w	$20-1
	dc.w	$10-1
	
	dc.l	Map_SS4BGA2			; Stage 4 background chunk A2
	VDPCMD	dc.l,$C040,VRAM,WRITE
	dc.w	$20-1
	dc.w	$10-1
	
	dc.l	Map_SS4BGB1			; Stage 4 background chunk B1
	VDPCMD	dc.l,$E000,VRAM,WRITE
	dc.w	$20-1
	dc.w	$B-1
	
	dc.l	Map_SS4BGB3			; Stage 4 background chunk B3
	VDPCMD	dc.l,$E040,VRAM,WRITE
	dc.w	$20-1
	dc.w	$B-1
	
	dc.l	Map_SS4BGB2			; Stage 4 background chunk B2
	VDPCMD	dc.l,$E580,VRAM,WRITE
	dc.w	$20-1
	dc.w	5-1
	
	dc.l	Map_SS4BGB4			; Stage 4 background chunk B4
	VDPCMD	dc.l,$E5C0,VRAM,WRITE
	dc.w	$20-1
	dc.w	5-1
	
	dc.l	Map_HUDNormal			; HUD (normal mode)
	dc.l	$40800003
	dc.w	$20-1
	dc.w	2-1
	
	dc.l	Map_HUDTimeAttack		; HUD (time attack mode)
	dc.l	$40800003
	dc.w	$20-1
	dc.w	2-1
	
	dc.l	Map_SS1BGA1			; Stage 1 background chunk A1
	VDPCMD	dc.l,$C000,VRAM,WRITE
	dc.w	$20-1
	dc.w	$10-1
	
	dc.l	Map_SS1BGA3			; Stage 1 background chunk A3
	VDPCMD	dc.l,$C040,VRAM,WRITE
	dc.w	$20-1
	dc.w	$10-1
	
	dc.l	Map_SS1BGB1			; Stage 1 background chunk B1 (left)
	VDPCMD	dc.l,$E000,VRAM,WRITE
	dc.w	$20-1
	dc.w	$10-1
	
	dc.l	Map_SS1BGB1			; Stage 1 background chunk B1 (right)
	VDPCMD	dc.l,$E040,VRAM,WRITE
	dc.w	$20-1
	dc.w	$10-1
	
	dc.l	Map_SS5BGA1			; Stage 5 background chunk A1
	VDPCMD	dc.l,$C000,VRAM,WRITE
	dc.w	$20-1
	dc.w	$10-1
	
	dc.l	Map_SS5BGA2			; Stage 5 background chunk A2
	VDPCMD	dc.l,$C040,VRAM,WRITE
	dc.w	$20-1
	dc.w	$10-1
	
	dc.l	Map_SS5BGB1			; Stage 5 background chunk B1
	VDPCMD	dc.l,$E000,VRAM,WRITE
	dc.w	$20-1
	dc.w	$10-1
	
	dc.l	Map_SS5BGB2			; Stage 5 background chunk B2
	VDPCMD	dc.l,$E040,VRAM,WRITE
	dc.w	$20-1
	dc.w	$10-1
	
	dc.l	Map_SS5BGB3			; Stage 5 background chunk B3
	VDPCMD	dc.l,$E800,VRAM,WRITE
	dc.w	$20-1
	dc.w	$C-1
	
	dc.l	Map_SS6BGA1			; Stage 6 background chunk A1
	VDPCMD	dc.l,$C000,VRAM,WRITE
	dc.w	$20-1
	dc.w	$10-1
	
	dc.l	Map_SS6BGA2			; Stage 6 background chunk A2
	VDPCMD	dc.l,$C040,VRAM,WRITE
	dc.w	$20-1
	dc.w	$10-1
	
	dc.l	Map_SS6BGB1			; Stage 6 background chunk B1 (left)
	VDPCMD	dc.l,$E000,VRAM,WRITE
	dc.w	$20-1
	dc.w	$10-1
	
	dc.l	Map_SS6BGB1			; Stage 6 background chunk B1 (right)
	VDPCMD	dc.l,$E040,VRAM,WRITE
	dc.w	$20-1
	dc.w	$10-1
	
	dc.l	Map_SS7BGA1			; Stage 7 background chunk A1
	VDPCMD	dc.l,$C000,VRAM,WRITE
	dc.w	$20-1
	dc.w	$10-1
	
	dc.l	Map_SS7BGA3			; Stage 7 background chunk A3
	VDPCMD	dc.l,$C040,VRAM,WRITE
	dc.w	$20-1
	dc.w	$10-1
	
	dc.l	Map_SS7BGB1			; Stage 7 background chunk B1
	VDPCMD	dc.l,$E000,VRAM,WRITE
	dc.w	$20-1
	dc.w	$10-1
	
	dc.l	Map_SS7BGB3			; Stage 7 background chunk B3
	VDPCMD	dc.l,$E040,VRAM,WRITE
	dc.w	$20-1
	dc.w	$10-1
	
	dc.l	Map_SS7BGB2			; Stage 7 background chunk B2
	dc.l	$65000003
	dc.w	$1F
	dc.w	3
	
	dc.l	Map_SS7BGB4			; Stage 7 background chunk B4
	dc.l	$65400003
	dc.w	$1F
	dc.w	3
	
	dc.l	Map_SS7BGB9			; Stage 7 background chunk B9
	VDPCMD	dc.l,$E800,VRAM,WRITE
	dc.w	$20-1
	dc.w	$C-1
	
	dc.l	Map_SS3BGB5			; Stage 7 background chunk B5
	VDPCMD	dc.l,$E800,VRAM,WRITE
	dc.w	$20-1
	dc.w	$C-1
	
	dc.l	Map_TimeStone1			; Time stone 1
	VDPCMD	dc.l,$C594,VRAM,WRITE
	dc.w	2-1
	dc.w	2-1
	
	dc.l	Map_TimeStone2			; Time stone 2
	VDPCMD	dc.l,$C59A,VRAM,WRITE
	dc.w	2-1
	dc.w	2-1
	
	dc.l	Map_TimeStone3			; Time stone 3
	VDPCMD	dc.l,$C5A0,VRAM,WRITE
	dc.w	2-1
	dc.w	2-1
	
	dc.l	Map_TimeStone4			; Time stone 4
	VDPCMD	dc.l,$C5A6,VRAM,WRITE
	dc.w	2-1
	dc.w	2-1
	
	dc.l	Map_TimeStone5			; Time stone 5
	VDPCMD	dc.l,$C5AC,VRAM,WRITE
	dc.w	2-1
	dc.w	2-1
	
	dc.l	Map_TimeStone6			; Time stone 6
	VDPCMD	dc.l,$C5B2,VRAM,WRITE
	dc.w	2-1
	dc.w	2-1
	
	dc.l	Map_TimeStone7			; Time stone 7
	VDPCMD	dc.l,$C5B8,VRAM,WRITE
	dc.w	2-1
	dc.w	2-1
	
	dc.l	Map_ScoreText			; "SCORE"
	VDPCMD	dc.l,$C712,VRAM,WRITE
	dc.w	5-1
	dc.w	2-1
	
	dc.l	Map_RingText			; "RING"
	VDPCMD	dc.l,$C892,VRAM,WRITE
	dc.w	4-1
	dc.w	2-1
	
	dc.l	Map_TimeText			; "TIME"
	VDPCMD	dc.l,$CA12,VRAM,WRITE
	dc.w	4-1
	dc.w	2-1
	
	dc.l	Map_BonusText			; "BONUS" (Ring bonus)
	VDPCMD	dc.l,$C89C,VRAM,WRITE
	dc.w	6-1
	dc.w	2-1
	
	dc.l	Map_BonusText			; "BONUS" (Time bonus)
	VDPCMD	dc.l,$CA1C,VRAM,WRITE
	dc.w	6-1
	dc.w	2-1
	
	dc.l	Map_ResultsBG			; Results background
	VDPCMD	dc.l,$E000,VRAM,WRITE
	dc.w	$28-1
	dc.w	$1C-1
	
	dc.l	Map_ExtraPlayersText		; "EXTRA PLAYERS"
	VDPCMD	dc.l,$CB92,VRAM,WRITE
	if REGION=USA
		dc.w	$E-1
	else
		dc.w	$F-1
	endif
	dc.w	2-1
	
	dc.l	Map_ExtraPlayer1		; Extra player icon 1 (frame 1)
	VDPCMD	dc.l,$CBB4,VRAM,WRITE
	dc.w	2-1
	dc.w	3-1
	
	dc.l	Map_ExtraPlayer2		; Extra player icon 1 (frame 2)
	VDPCMD	dc.l,$CBB4,VRAM,WRITE
	dc.w	2-1
	dc.w	3-1
	
	dc.l	Map_ExtraPlayer3		; Extra player icon 1 (frame 3)
	VDPCMD	dc.l,$CBB4,VRAM,WRITE
	dc.w	2-1
	dc.w	3-1
	
	dc.l	Map_ExtraPlayer1		; Extra player icon 2 (frame 1)
	VDPCMD	dc.l,$CBB8,VRAM,WRITE
	dc.w	2-1
	dc.w	3-1
	
	dc.l	Map_ExtraPlayer2		; Extra player icon 2 (frame 2)
	VDPCMD	dc.l,$CBB8,VRAM,WRITE
	dc.w	2-1
	dc.w	3-1
	
	dc.l	Map_ExtraPlayer3		; Extra player icon 2 (frame 3)
	VDPCMD	dc.l,$CBB8,VRAM,WRITE
	dc.w	2-1
	dc.w	3-1
	
	dc.l	Map_SpecialZoneText		; "SPECIAL ZONE"
	VDPCMD	dc.l,$C392,VRAM,WRITE
	dc.w	$17-1
	dc.w	2-1
	
	dc.l	Map_TimeStonesText		; "TIME STONES"
	VDPCMD	dc.l,$C394,VRAM,WRITE
	dc.w	$15-1
	dc.w	2-1
	
	dc.l	Map_GotThemAllText		; "GOT THEM ALL!!"
	VDPCMD	dc.l,$C38E,VRAM,WRITE
	dc.w	$1A-1
	dc.w	2-1
	
	dc.l	Map_BonusZero			; 0 (Score)
	VDPCMD	dc.l,$C736,VRAM,WRITE
	dc.w	5-1
	dc.w	2-1
	
	dc.l	Map_BonusZero			; 0 (Time bonus)
	VDPCMD	dc.l,$C8B6,VRAM,WRITE
	dc.w	5-1
	dc.w	2-1
	
	dc.l	Map_BonusZero			; 0 (Ring bonus)
	VDPCMD	dc.l,$CA36,VRAM,WRITE
	dc.w	5-1
	dc.w	2-1
	
	dc.l	Map_SS1BGB2			; Stage 1 background chunk B2
	VDPCMD	dc.l,$E800,VRAM,WRITE
	dc.w	$20-1
	dc.w	$C-1
	
	dc.l	Map_ExtraPlayer1		; Extra player icon 3 (frame 1)
	VDPCMD	dc.l,$CBBC,VRAM,WRITE
	dc.w	2-1
	dc.w	3-1
	
	dc.l	Map_ExtraPlayer2		; Extra player icon 3 (frame 2)
	VDPCMD	dc.l,$CBBC,VRAM,WRITE
	dc.w	2-1
	dc.w	3-1
	
	dc.l	Map_ExtraPlayer3		; Extra player icon 3 (frame 3)
	VDPCMD	dc.l,$CBBC,VRAM,WRITE
	dc.w	2-1
	dc.w	3-1
	
	dc.l	Map_ExtraPlayer1		; Extra player icon 4 (frame 1)
	VDPCMD	dc.l,$CBC0,VRAM,WRITE
	dc.w	2-1
	dc.w	3-1
	
	dc.l	Map_ExtraPlayer2		; Extra player icon 4 (frame 2)
	VDPCMD	dc.l,$CBC0,VRAM,WRITE
	dc.w	2-1
	dc.w	3-1
	
	dc.l	Map_ExtraPlayer3		; Extra player icon 4 (frame 3)
	VDPCMD	dc.l,$CBC0,VRAM,WRITE
	dc.w	2-1
	dc.w	3-1
	
	dc.l	Map_ExtraPlayer1		; Extra player icon 5 (frame 1)
	VDPCMD	dc.l,$CBC4,VRAM,WRITE
	dc.w	2-1
	dc.w	3-1
	
	dc.l	Map_ExtraPlayer2		; Extra player icon 5 (frame 2)
	VDPCMD	dc.l,$CBC4,VRAM,WRITE
	dc.w	2-1
	dc.w	3-1
	
	dc.l	Map_ExtraPlayer3		; Extra player icon 5 (frame 3)
	VDPCMD	dc.l,$CBC4,VRAM,WRITE
	dc.w	2-1
	dc.w	3-1
	
	dc.l	Map_SS6BGB2			; Stage 6 background chunk B2
	VDPCMD	dc.l,$E800,VRAM,WRITE
	dc.w	$20-1
	dc.w	$C-1
	
	dc.l	Map_SS8BGB1			; Stage 8 background chunk B1
	VDPCMD	dc.l,$E000,VRAM,WRITE
	dc.w	$20-1
	dc.w	$10-1
	
	dc.l	Map_SS8BGB2			; Stage 8 background chunk B2
	VDPCMD	dc.l,$E800,VRAM,WRITE
	dc.w	$20-1
	dc.w	$C-1

; -------------------------------------------------------------------------
; Draw tilemap
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - VDP command
;	d1.w - Width
;	d2.w - Height
;	a0.l - Pointer to tilemap
; -------------------------------------------------------------------------

DrawTilemap:
	lea	VDPCTRL,a2			; VDP control port
	lea	VDPDATA,a3			; VDP data port
	move.l	#$800000,d4			; Row delta

.DrawRow:
	move.l	d0,(a2)				; Set VDP command
	move.w	d1,d3				; Get width

.DrawTile:
	move.w	(a1)+,(a3)			; Draw tile
	dbf	d3,.DrawTile			; Loop until row is drawn

	add.l	d4,d0				; Next row
	dbf	d2,.DrawRow			; Loop until map is drawn
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
	jsr	NemDec_BuildCodeTable(pc)
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
; Decompress Enigma tilemap data into RAM
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to Enigma data
;	a1.l - Pointer to destination buffer
;	d0.w - Base tile attributes
; -------------------------------------------------------------------------

EniDec:
	movem.l	d0-d7/a1-a5,-(sp)
	movea.w	d0,a3				; Store base tile
	move.b	(a0)+,d0
	ext.w	d0
	movea.w	d0,a5				; Store number of bits in inline copy value
	move.b	(a0)+,d4
	lsl.b	#3,d4				; Store PCCVH flags bitfield
	movea.w	(a0)+,a2
	adda.w	a3,a2				; Store incremental copy word
	movea.w	(a0)+,a4
	adda.w	a3,a4				; Store literal copy word
	move.b	(a0)+,d5
	asl.w	#8,d5
	move.b	(a0)+,d5			; Get first word in format list
	moveq	#16,d6				; Initial shift value

EniDec_Loop:
	moveq	#7,d0				; Assume a format list entry is 7 bits
	move.w	d6,d7
	sub.w	d0,d7
	move.w	d5,d1
	lsr.w	d7,d1
	andi.w	#$7F,d1				; Get format list entry
	move.w	d1,d2				; and copy it
	cmpi.w	#$40,d1				; Is the high bit of the entry set?
	bcc.s	.SevenBitEntry
	moveq	#6,d0				; If it isn't, the entry is actually 6 bits
	lsr.w	#1,d2

.SevenBitEntry:
	bsr.w	EniDec_ChkGetNextByte
	andi.w	#$F,d2				; Get repeat count
	lsr.w	#4,d1
	add.w	d1,d1
	jmp	EniDec_JmpTable(pc,d1.w)

; -------------------------------------------------------------------------

EniDec_Sub0:
	move.w	a2,(a1)+			; Copy incremental copy word
	addq.w	#1,a2				; Increment it
	dbf	d2,EniDec_Sub0			; Repeat
	bra.s	EniDec_Loop

; -------------------------------------------------------------------------

EniDec_Sub4:
	move.w	a4,(a1)+			; Copy literal copy word
	dbf	d2,EniDec_Sub4			; Repeat
	bra.s	EniDec_Loop

; -------------------------------------------------------------------------

EniDec_Sub8:
	bsr.w	EniDec_GetInlineCopyVal

.Loop:
	move.w	d1,(a1)+			; Copy inline value
	dbf	d2,.Loop			; Repeat
	bra.s	EniDec_Loop

; -------------------------------------------------------------------------

EniDec_SubA:
	bsr.w	EniDec_GetInlineCopyVal

.Loop:
	move.w	d1,(a1)+			; Copy inline value
	addq.w	#1,d1				; Increment it
	dbf	d2,.Loop			; Repeat
	bra.s	EniDec_Loop

; -------------------------------------------------------------------------

EniDec_SubC:
	bsr.w	EniDec_GetInlineCopyVal

.Loop:
	move.w	d1,(a1)+			; Copy inline value
	subq.w	#1,d1				; Decrement it
	dbf	d2,.Loop			; Repeat
	bra.s	EniDec_Loop

; -------------------------------------------------------------------------

EniDec_SubE:
	cmpi.w	#$F,d2
	beq.s	EniDec_End

.Loop4:
	bsr.w	EniDec_GetInlineCopyVal		; Fetch new inline value
	move.w	d1,(a1)+			; Copy it
	dbf	d2,.Loop4			; Repeat
	bra.s	EniDec_Loop

; -------------------------------------------------------------------------

EniDec_JmpTable:
	bra.s	EniDec_Sub0
	bra.s	EniDec_Sub0
	bra.s	EniDec_Sub4
	bra.s	EniDec_Sub4
	bra.s	EniDec_Sub8
	bra.s	EniDec_SubA
	bra.s	EniDec_SubC
	bra.s	EniDec_SubE

; -------------------------------------------------------------------------

EniDec_End:
	subq.w	#1,a0				; Go back by one byte
	cmpi.w	#16,d6				; Were we going to start a completely new byte?
	bne.s	.NotNewByte			; If not, branch
	subq.w	#1,a0				; And another one if needed

.NotNewByte:
	move.w	a0,d0
	lsr.w	#1,d0				; Are we on an odd byte?
	bcc.s	.Even				; If not, branch
	addq.w	#1,a0				; Ensure we're on an even byte

.Even:
	movem.l	(sp)+,d0-d7/a1-a5
	rts

; -------------------------------------------------------------------------

EniDec_GetInlineCopyVal:
	move.w	a3,d3				; Copy base tile
	move.b	d4,d1				; Copy PCCVH bitfield
	add.b	d1,d1				; Is the priority bit set?
	bcc.s	.NoPriority			; If not, branch
	subq.w	#1,d6
	btst	d6,d5				; Is the priority bit set in the inline render flags?
	beq.s	.NoPriority			; If not, branch
	ori.w	#$8000,d3			; Set priority bit in the base tile

.NoPriority:
	add.b	d1,d1				; Is the high palette line bit set?
	bcc.s	.NoPal1				; If not, branch
	subq.w	#1,d6
	btst	d6,d5				; Is the high palette line bit set in the inline render flags?
	beq.s	.NoPal1				; If not, branch
	addi.w	#$4000,d3			; Set second palette line bit

.NoPal1:
	add.b	d1,d1				; Is the low palette line bit set?
	bcc.s	.NoPal0				; If not, branch
	subq.w	#1,d6
	btst	d6,d5				; Is the low palette line bit set in the inline render flags?
	beq.s	.NoPal0				; If not, branch
	addi.w	#$2000,d3			; Set first palette line bit

.NoPal0:
	add.b	d1,d1				; Is the Y flip bit set?
	bcc.s	.NoYFlip			; If not, branch
	subq.w	#1,d6
	btst	d6,d5				; Is the Y flip bit set in the inline render flags?
	beq.s	.NoYFlip			; If not, branch
	ori.w	#$1000,d3			; Set Y flip bit

.NoYFlip:
	add.b	d1,d1				; Is the X flip bit set?
	bcc.s	.NoXFlip			; If not, branch
	subq.w	#1,d6
	btst	d6,d5				; Is the X flip bit set in the inline render flags?
	beq.s	.NoXFlip			; If not, branch
	ori.w	#$800,d3			; Set X flip bit

.NoXFlip:
	move.w	d5,d1
	move.w	d6,d7
	sub.w	a5,d7				; Subtract length in bits of inline copy value
	bcc.s	.GotEnoughBits			; Branch if a new word doesn't need to be read
	move.w	d7,d6
	addi.w	#16,d6
	neg.w	d7				; Calculate bit deficit
	lsl.w	d7,d1				; and make space for that many bits
	move.b	(a0),d5				; Get next byte
	rol.b	d7,d5				; and rotate the required bits into the lowest positions
	add.w	d7,d7
	and.w	EniDec_Masks-2(pc,d7.w),d5
	add.w	d5,d1				; Combine upper bits with lower bits

.AddBits:
	move.w	a5,d0				; Get length in bits of inline copy value
	add.w	d0,d0
	and.w	EniDec_Masks-2(pc,d0.w),d1	; Mask value
	add.w	d3,d1				; Add base tile
	move.b	(a0)+,d5
	lsl.w	#8,d5
	move.b	(a0)+,d5
	rts

.GotEnoughBits:
	beq.s	.JustEnough			; If the word has been exactly exhausted, branch
	lsr.w	d7,d1				; Get inline copy value
	move.w	a5,d0
	add.w	d0,d0
	and.w	EniDec_Masks-2(pc,d0.w),d1	; Mask it
	add.w	d3,d1				; Add base tile
	move.w	a5,d0
	bra.s	EniDec_ChkGetNextByte

.JustEnough:
	moveq	#16,d6				; Reset shift value
	bra.s	.AddBits

; -------------------------------------------------------------------------

EniDec_Masks:
	dc.w	1,     3,     7,     $F
	dc.w	$1F,   $3F,   $7F,   $FF
	dc.w	$1FF,  $3FF,  $7FF,  $FFF
	dc.w	$1FFF, $3FFF, $7FFF, $FFFF

; -------------------------------------------------------------------------

EniDec_ChkGetNextByte:
	sub.w	d0,d6				; Subtract length of current entry from shift value so that next entry is read next time around
	cmpi.w	#9,d6				; Does a new byte need to be read?
	bcc.s	.End				; If not, branch
	addq.w	#8,d6
	asl.w	#8,d5
	move.b	(a0)+,d5

.End:
	rts

; -------------------------------------------------------------------------
; Data
; -------------------------------------------------------------------------

Map_TimeStone3:
	dc.w	0				; Uncompressed
	dc.w	1, 2
	dc.w	3, 4

Map_TimeStone7:
	dc.w	0				; Uncompressed
	dc.w	5, 6
	dc.w	7, 8

Map_TimeStone1:
	dc.w	0				; Uncompressed
	dc.w	9, $A
	dc.w	$B, $C

Map_TimeStone4:
	dc.w	0				; Uncompressed
	dc.w	$2009, $200A
	dc.w	$200B, $200C

Map_TimeStone6:
	dc.w	0				; Uncompressed
	dc.w	$200D, $200E
	dc.w	$200F, $2010

Map_TimeStone5:
	dc.w	0				; Uncompressed
	dc.w	$2011, $2012
	dc.w	$2013, $2014

Map_TimeStone2:
	dc.w	0				; Uncompressed
	dc.w	$2015, $2016
	dc.w	$2017, $2018

Map_ScoreText:
	dc.w	0				; Uncompressed
	dc.w	$4019, $401A, $401B, $401C, $401D
	dc.w	$401E, $401E, $401E, $401F, $4020

Map_RingText:
	dc.w	0				; Uncompressed
	dc.w	$4027, $4028, $4029, $402A
	dc.w	$401F, $402B, $402C, $401E

Map_TimeText:
	dc.w	0				; Uncompressed
	dc.w	$4021, $4022, $4023, $401D
	dc.w	$4024, $4025, $4026, $4020

Map_BonusText:
	dc.w	0				; Uncompressed
	dc.w	$4027, $401B, $408D, $408E, $408F, $4090
	dc.w	$4091, $401E, $4092, $4093, $4094, $4095

Map_ExtraPlayer1:
	dc.w	0				; Uncompressed
	dc.w	$60B0, $60B1
	dc.w	$60B2, $60B3
	dc.w	$60B4, $60B5

Map_ExtraPlayer2:
	dc.w	0				; Uncompressed
	dc.w	$60B0, $60B1
	dc.w	$60B6, $60B7
	dc.w	$60B8, $60B9

Map_ExtraPlayer3:
	dc.w	0				; Uncompressed
	dc.w	$60B0, $60B1
	dc.w	$60B6, $60B7
	dc.w	$60B8, $60BA

Map_SpecialZoneText:
	dc.w	0				; Uncompressed
	dc.w	$403C, $403D, $403E, $403F, $4040, $4041, $4042, $4043, $4044, $4045, $4046, $4047, $4000, $4000, $4000, $4048, $4049, $404A, $404B, $404C, $404D, $404E, $404F
	dc.w	$4050, $4051, $4052, $4053, $4054, $4055, $4056, $4057, $4058, $4059, $405A, $405B, $405C, $4000, $4000, $405D, $405E, $405F, $4060, $4061, $4062, $4063, $4064

Map_TimeStonesText:
	dc.w	0				; Uncompressed
	dc.w	$4065, $4066, $4067, $4068, $4069, $404E, $404F, $4000, $4000, $403C, $403D, $406A, $406B, $406C, $406D, $406E, $406F, $4040, $4041, $403C, $403D
	dc.w	$4070, $4071, $4072, $4073, $4074, $4063, $4064, $4000, $4000, $4050, $4051, $4075, $4076, $4077, $4078, $4079, $407A, $4054, $4055, $4050, $4051

Map_GotThemAllText:
	dc.w	0				; Uncompressed
	dc.w	$407B, $407C, $404A, $404B, $406A, $407D, $4000, $4000, $406A, $407D, $407E, $407F, $4040, $4041, $4080, $4081, $4000, $4000, $4045, $4046, $4047, $4000, $4082, $4000, $4082, $4082
	dc.w	$4083, $4084, $405F, $4060, $4075, $4085, $4000, $4000, $4075, $4085, $4086, $4087, $4054, $4055, $4088, $4089, $4000, $4000, $4059, $405A, $405B, $405C, $408A, $408B, $408C, $408C

Map_BonusZero:
	dc.w	0				; Uncompressed
	dc.w	$402D, $402D, $402D, $402D, $402D
	dc.w	$402E, $402E, $402E, $402E, $402E

Map_ResultsBG:
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Results Background Map.kos"
	even

Map_ExtraPlayersText:
	dc.w	0				; Uncompressed
	if REGION=USA
		dc.w	$4201, $4202, $4203, $4204, $4205, $4206, $4207, $4208, $4209, $420A, $420B, $420C, $420D, $420E
		dc.w	$420F, $4210, $4211, $4212, $4213, $4214, $4215, $4216, $4217, $4218, $4216, $4219, $421A, $421B
	else
		dc.w	$401D, $4096, $4097, $4098, $4099, $409A, $409B, $409C, $409D, $409E, $409F, $40A0, $40A1, $40A2, $40A3
		dc.w	$4020, $40A4, $40A5, $40A6, $40A7, $40A8, $40A9, $40AA, $40AB, $40AC, $40AD, $40AE, $40AC, $40AF, $40A9
	endif

Map_HUDTimeAttack:
	dc.w	0				; Uncompressed
	dc.w	0, 0, $87F3, $87F4, $87F5, $87DE, $87DE, 0, 0, 0, 0, 0, 0, $87DE, $87DE, $87E7, $87DE, $87DE, $87E8, $87DE, $87DE, 0, 0, 0, 0, 0, 0, $87DE, $87DE, $87DE, 0, 0
	dc.w	0, 0, $87F6, $87F7, $87F8, $87E9, $87E9, 0, 0, $87F9, $87FA, $87FB, 0, $87E9, $87E9, 0, $87E9, $87E9, 0, $87E9, $87E9, 0, 0, $87FC, $87FD, $87FE, $87FF, $87E9, $87E9, $87E9, 0, 0

Map_HUDNormal:
	dc.w	0				; Uncompressed
	dc.w	0, 0, $87F3, $87F4, $87F5, $87DE, $87DE, 0, 0, 0, 0, 0, 0, 0, 0, 0, $87DE, $87DE, 0, 0, 0, 0, 0, 0, 0, 0, 0, $87DE, $87DE, $87DE, 0, 0
	dc.w	0, 0, $87F6, $87F7, $87F8, $87E9, $87E9, 0, 0, 0, $87F9, $87FA, $87FB, 0, 0, 0, $87E9, $87E9, 0, 0, 0, 0, 0, $87FC, $87FD, $87FE, $87FF, $87E9, $87E9, $87E9, 0, 0

Art_Results:
	incbin	"Special Stage/Data/Results Art.nem"
	even

Art_TimeStone:
	incbin	"Special Stage/Objects/Time Stone/Data/Art.nem"
	even

Art_Items:
	incbin	"Special Stage/Objects/Item/Data/Art.nem"
	even

Art_Explosion:
	incbin	"Special Stage/Objects/Explosion/Data/Art.nem"
	even

Art_HUD:
	incbin	"Special Stage/Data/HUD Art.nem"
	even

Art_TitleCard:
	incbin	"Special Stage/Objects/Title Card/Data/Art.nem"
	even

Art_Splash:
	incbin	"Special Stage/Objects/Splash/Data/Art.nem"
	even

Art_Shadow:
	incbin	"Special Stage/Objects/Shadow/Data/Art.nem"
	even

Art_UFO:
	incbin	"Special Stage/Objects/UFO/Data/Art.nem"
	even

Stage1Demo:
	if REGION<>EUROPE
		incbin	"Special Stage/Data/Stage 1/Demo (NTSC).kos"
	else
		incbin	"Special Stage/Data/Stage 1/Demo (PAL).kos"
	endif
	even

Stage6Demo:
	if REGION<>EUROPE
		incbin	"Special Stage/Data/Stage 6/Demo (NTSC).kos"
	else
		incbin	"Special Stage/Data/Stage 6/Demo (PAL).kos"
	endif
	even
	
Art_SS6BGWater:
	incbin	"Special Stage/Data/Stage 6/Background Art (Water).nem"
	even
Map_SS6BGB2:
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 6/Background Chunk B2.kos"
	even

; -------------------------------------------------------------------------
; Pad up to stage data in Word RAM
; -------------------------------------------------------------------------

	align	(WORKRAMFILE-$100)+SpecStgDataCopy, $FF

; -------------------------------------------------------------------------

