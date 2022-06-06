; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Main program
; -------------------------------------------------------------------------

	include	"_Include/Common.i"
	include	"_Include/Main CPU.i"
	include	"_Include/Main CPU Variables.i"
	include	"_Include/System.i"
	include	"_Include/Backup RAM.i"
	include	"_Include/Sound.i"
	include	"_Include/MMD.i"

; -------------------------------------------------------------------------
; MMD header
; -------------------------------------------------------------------------

	MMD	0, &
		WORKRAM, End-Start, &
		Start, 0, 0

; -------------------------------------------------------------------------
; Program start
; -------------------------------------------------------------------------

Start:
	move.l	#VInterrupt,_LEVEL6+2.w		; Set V-INT address
	bsr.w	GiveWordRAMAccess		; Give Sub CPU Word RAM Access
	
	lea	MAINVARS,a0			; Clear variables
	move.w	#MAINVARSSZ/4-1,d7

.ClearVars:
	move.l	#0,(a0)+
	dbf	d7,.ClearVars

	moveq	#SCMD_MDINIT,d0			; Run Mega Drive initialization
	bsr.w	RunMMD
	move.w	#SCMD_BURAMINIT,d0		; Run Backup RAM initialization
	bsr.w	RunMMD
	tst.b	d0				; Was it a succes?
	beq.s	.GetSaveData			; If so, branch
	bset	#0,saveDisabled			; If not, disable saving to Backup RAM

.GetSaveData:
	bsr.w	ReadSaveData			; Read save data

.GameLoop:
	move.w	#SCMD_INITSS2,d0		; Initialize special stage flags
	bsr.w	SubCPUCmd

	moveq	#0,d0
	move.l	d0,levelScore			; Reset score
	move.b	d0,timeAttackMode		; Reset time attack mode flag
	move.b	d0,enteredBigRing		; Reset entered big ring flag
	move.b	d0,lastCheckpoint		; Reset last checkpoint ID
	move.w	d0,levelRings			; Reset ring count
	move.l	d0,levelTime			; Reset level timer
	move.b	d0,goodFuture			; Reset good future flag
	move.b	d0,projDestroyed		; Reset projector destroyed flag
	move.b	#TIME_PRESENT,timeZone		; Set time zone to present

	moveq	#SCMD_TITLE,d0			; Run title screen
	bsr.w	RunMMD

	ext.w	d1				; Run next scene
	add.w	d1,d1
	move.w	.Scenes(pc,d1.w),d1
	jsr	.Scenes(pc,d1.w)

	bra.s	.GameLoop			; Loop

; -------------------------------------------------------------------------

.Scenes:
	dc.w	Demo-.Scenes			; Demo mode
	dc.w	NewGame-.Scenes			; New game
	dc.w	LoadGame-.Scenes		; Load game
	dc.w	TimeAttack-.Scenes		; Time attack
	dc.w	BuRAMManager-.Scenes		; Backup RAM manager
	dc.w	DAGarden-.Scenes		; D.A. Garden
	dc.w	VisualMode-.Scenes		; Visual mode
	dc.w	SoundTest-.Scenes		; Sound test
	dc.w	StageSelect-.Scenes		; Stage select
	dc.w	BestStaffTimes-.Scenes		; Best staff times

; -------------------------------------------------------------------------
; Best staff times
; -------------------------------------------------------------------------

BestStaffTimes:
	move.w	#SCMD_STAFFTIMES,d0		; Run staff best times screen
	bra.w	RunMMD

; -------------------------------------------------------------------------
; Backup RAM manager
; -------------------------------------------------------------------------

BuRAMManager:
	move.w	#SCMD_BURAMMGR,d0		; Run Backup RAM manager
	bsr.w	RunMMD
	bsr.w	ReadSaveData			; Read save data
	rts

; -------------------------------------------------------------------------
; Run Special Stage 1 demo
; -------------------------------------------------------------------------

SpecStage1Demo:
	move.b	#1-1,GACOMCMD3			; Stage 1
	move.b	#0,GACOMCMDA			; Reset stages beaten
	bset	#0,GACOMCMDB			; Temporary mode
	
	moveq	#SCMD_SPECSTAGE,d0		; Run special stage
	bsr.w	RunMMD
	rts

; -------------------------------------------------------------------------
; Run Special Stage 6 demo
; -------------------------------------------------------------------------

SpecStage6Demo:
	move.b	#6-1,GACOMCMD3			; Stage 6
	move.b	#0,GACOMCMDA			; Reset stages beaten
	bset	#0,GACOMCMDB			; Temporary mode
	
	moveq	#SCMD_SPECSTAGE,d0		; Run special stage
	bsr.w	RunMMD
	rts

; -------------------------------------------------------------------------
; Load game
; -------------------------------------------------------------------------

LoadGame:
	bsr.w	ReadSaveData			; Read save data
	move.w	savedLevel,level		; Get level from save data
	move.b	#3,lifeCount			; Reset life count to 3
	move.b	#0,plcLoadFlags			; Reset PLC load flags

	cmpi.b	#0,levelZone			; Are we in Palmtree Panic?
	beq.w	RunR1				; If so, branch
	cmpi.b	#1,levelZone			; Are we in Collision Chaos?
	bls.w	RunR3				; If so, branch
	cmpi.b	#2,levelZone			; Are we in Tidal Tempest?
	bls.w	RunR4				; If so, branch
	cmpi.b	#3,levelZone			; Are we in Quartz Quadrant?
	bls.w	RunR5				; If so, branch
	cmpi.b	#4,levelZone			; Are we in Wacky Workbench?
	bls.w	RunR6				; If so, branch
	cmpi.b	#5,levelZone			; Are we in Stardust Speedway?
	bls.w	RunR7				; If so, branch
	cmpi.b	#6,levelZone			; Are we in Metallic Madness?
	bls.w	RunR8				; If so, branch

; -------------------------------------------------------------------------
; New game
; -------------------------------------------------------------------------

NewGame:
RunR1:
	moveq	#0,d0
	move.b	d0,plcLoadFlags			; Reset PLC load flags
	move.w	d0,levelZone			; Set level to Palmtree Panic Act 1
	move.w	d0,savedLevel
	move.b	d0,goodFutures			; Reset good futures achieved
	move.b	d0,curSpecStage			; Reset special stage ID
	move.b	d0,timeStones			; Reset time stones retrieved

	bsr.w	WriteSaveData			; Write save data
	
	bsr.w	RunR11				; Run act 1
	bsr.w	RunR12				; Run act 2
	bsr.w	RunR13				; Run act 3

	moveq	#3*1,d0				; Unlock zone in time attack
	bsr.w	UnlockTimeAttackLevel
	bset	#6,titleFlags
	bset	#5,titleFlags
	move.b	#0,lastCheckpoint		; Reset last checkpoint ID
	move.b	#0,projDestroyed		; Reset projector destroyed flag
	
	bclr	#0,goodFuture			; Was act 3 in the good future?
	beq.s	RunR3				; If not, branch
	bset	#0,goodFutures			; Mark good future as achieved

; -------------------------------------------------------------------------

RunR3:
	bsr.w	WriteSaveData			; Write save data
	
	move.b	#0,amyCaptured			; Reset Amy captured flag
	bsr.w	RunR31				; Run act 1
	move.b	#0,amyCaptured			; Reset Amy captured flag
	bsr.w	RunR32				; Run act 2
	bsr.w	RunR33				; Run act 3

	moveq	#3*2,d0				; Unlock zone in time attack
	bsr.w	UnlockTimeAttackLevel
	move.b	#0,lastCheckpoint		; Reset last checkpoint ID
	move.b	#0,projDestroyed		; Reset projector destroyed flag
	
	bclr	#0,goodFuture			; Was act 3 in the good future?
	beq.s	RunR4				; If not, branch
	bset	#1,goodFutures			; Mark good future as achieved

; -------------------------------------------------------------------------

RunR4:
	bsr.w	WriteSaveData			; Write save data
	
	bsr.w	RunR41				; Run act 1
	bsr.w	RunR42				; Run act 2
	bsr.w	RunR43				; Run act 3

	moveq	#3*3,d0				; Unlock zone in time attack
	bsr.w	UnlockTimeAttackLevel
	move.b	#0,lastCheckpoint		; Reset last checkpoint ID
	move.b	#0,projDestroyed		; Reset projector destroyed flag
	
	bclr	#0,goodFuture			; Was act 3 in the good future?
	beq.s	RunR5				; If not, branch
	bset	#2,goodFutures			; Mark good future as achieved

; -------------------------------------------------------------------------

RunR5:
	bsr.w	WriteSaveData			; Write save data
	
	bsr.w	RunR51				; Run act 1
	bsr.w	RunR52				; Run act 2
	bsr.w	RunR53				; Run act 3

	moveq	#3*4,d0				; Unlock zone in time attack
	bsr.w	UnlockTimeAttackLevel
	move.b	#0,lastCheckpoint		; Reset last checkpoint ID
	move.b	#0,projDestroyed		; Reset projector destroyed flag
	
	bclr	#0,goodFuture			; Was act 3 in the good future?
	beq.s	RunR6				; If not, branch
	bset	#3,goodFutures			; Mark good future as achieved

; -------------------------------------------------------------------------

RunR6:
	bsr.w	WriteSaveData			; Write save data
	
	bsr.w	RunR61				; Run act 1
	bsr.w	RunR62				; Run act 2
	bsr.w	RunR63				; Run act 3

	moveq	#3*5,d0				; Unlock zone in time attack
	bsr.w	UnlockTimeAttackLevel
	move.b	#0,lastCheckpoint		; Reset last checkpoint ID
	move.b	#0,projDestroyed		; Reset projector destroyed flag
	
	bclr	#0,goodFuture			; Was act 3 in the good future?
	beq.s	RunR7				; If not, branch
	bset	#4,goodFutures			; Mark good future as achieved

; -------------------------------------------------------------------------

RunR7:
	bsr.w	WriteSaveData			; Write save data
	
	bsr.w	RunR71				; Run act 1
	bsr.w	RunR72				; Run act 2
	bsr.w	RunR73				; Run act 3

	moveq	#3*6,d0				; Unlock zone in time attack
	bsr.w	UnlockTimeAttackLevel
	move.b	#0,lastCheckpoint		; Reset last checkpoint ID
	move.b	#0,projDestroyed		; Reset projector destroyed flag
	
	bclr	#0,goodFuture			; Was act 3 in the good future?
	beq.s	RunR8				; If not, branch
	bset	#5,goodFutures			; Mark good future as achieved

; -------------------------------------------------------------------------

RunR8:
	bsr.w	WriteSaveData			; Write save data
	
	bsr.w	RunR81				; Run act 1
	bsr.w	RunR82				; Run act 2
	bsr.w	RunR83				; Run act 3

	moveq	#3*7,d0				; Unlock zone in time attack
	bsr.w	UnlockTimeAttackLevel
	move.b	#0,lastCheckpoint		; Reset last checkpoint ID
	move.b	#0,projDestroyed		; Reset projector destroyed flag
	
	bclr	#0,goodFuture			; Was act 3 in the good future?
	beq.s	GameDone			; If not, branch
	bset	#6,goodFutures			; Mark good future as achieved

; -------------------------------------------------------------------------

GameDone:
	move.b	goodFutures,gameGoodFutures	; Save good futures achieved
	move.b	timeStones,gameTimeStones	; Save time stones retrieved

	bsr.w	WriteSaveData			; Write save data
	
	cmpi.b	#%01111111,gameGoodFutures	; Were all of the good futures achievd?
	beq.s	GoodEnding			; If so, branch
	cmpi.b	#%01111111,gameTimeStones	; Were all of the time stones retrieved?
	beq.s	GoodEnding			; If so, branch

BadEnding:
	move.b	#0,endingID			; Set ending ID to bad ending
	move.w	#SCMD_BADEND,d0			; Run bad ending file
	bsr.w	RunMMD
	tst.b	mmdReturnCode			; Should we play it again?
	bmi.s	BadEnding			; If so, loop
	rts

GoodEnding:
	move.b	#$7F,endingID			; Set ending ID to good ending
	move.w	#SCMD_GOODEND,d0		; Run good ending file
	bsr.w	RunMMD
	tst.b	mmdReturnCode			; Should we play it again?
	bmi.s	GoodEnding			; If so, loop
	rts

; -------------------------------------------------------------------------
; Game over
; -------------------------------------------------------------------------

GameOver:
	move.b	#0,levelAct			; Reset act
	move.w	level,savedLevel		; Save level ID
	move.b	#0,lastCheckpoint		; Reset last checkpoint ID
	move.b	#0,projDestroyed		; Reset projector destroyed flag
	bclr	#0,goodFuture			; Reset good future flag
	rts

; -------------------------------------------------------------------------
; Final game results data
; -------------------------------------------------------------------------

gameGoodFutures:	
	dc.b	0				; Good futures achieved
gameTimeStones:
	dc.b	0				; Time stones retrieved

; -------------------------------------------------------------------------
; Run Palmtree Panic Act 1
; -------------------------------------------------------------------------

RunR11:
	lea	R11SubCmds(pc),a0
	move.w	#$000,level
	bra.w	RunLevel

; -------------------------------------------------------------------------
; Run Palmtree Panic Act 2
; -------------------------------------------------------------------------

RunR12:
	lea	R12SubCmds(pc),a0
	move.w	#$001,level
	bra.w	RunLevel

; -------------------------------------------------------------------------
; Run Palmtree Panic Act 3
; -------------------------------------------------------------------------

RunR13:
	lea	R13SubCmds(pc),a0
	move.w	#$002,level
	bra.w	RunBossLevel

; -------------------------------------------------------------------------
; Run Collision Chaos Act 1
; -------------------------------------------------------------------------

RunR31:
	lea	R31SubCmds(pc),a0
	move.w	#$100,level
	bra.w	RunLevel

; -------------------------------------------------------------------------
; Run Collision Chaos Act 2
; -------------------------------------------------------------------------

RunR32:
	lea	R32SubCmds(pc),a0
	move.w	#$101,level
	bra.w	RunLevel

; -------------------------------------------------------------------------
; Run Collision Chaos Act 3
; -------------------------------------------------------------------------

RunR33:
	lea	R33SubCmds(pc),a0
	move.w	#$102,level
	bra.w	RunBossLevel

; -------------------------------------------------------------------------
; Run Tidal Tempest Act 1
; -------------------------------------------------------------------------

RunR41:
	lea	R41SubCmds(pc),a0
	move.w	#$200,level
	bra.w	RunLevel

; -------------------------------------------------------------------------
; Run Tidal Tempest Act 2
; -------------------------------------------------------------------------

RunR42:
	lea	R42SubCmds(pc),a0
	move.w	#$201,level
	bra.w	RunLevel

; -------------------------------------------------------------------------
; Run Tidal Tempest Act 3
; -------------------------------------------------------------------------

RunR43:
	lea	R43SubCmds(pc),a0
	move.w	#$202,level
	bra.w	RunBossLevel

; -------------------------------------------------------------------------
; Run Quartz Quadrant Act 1
; -------------------------------------------------------------------------

RunR51:
	lea	R51SubCmds(pc),a0
	move.w	#$300,level
	bra.w	RunLevel

; -------------------------------------------------------------------------
; Run Quartz Quadrant Act 2
; -------------------------------------------------------------------------

RunR52:
	lea	R52SubCmds(pc),a0
	move.w	#$301,level
	bra.w	RunLevel

; -------------------------------------------------------------------------
; Run Quartz Quadrant Act 3
; -------------------------------------------------------------------------

RunR53:
	lea	R53SubCmds(pc),a0
	move.w	#$302,level
	bra.w	RunBossLevel

; -------------------------------------------------------------------------
; Run Wacky Workbench Act 1
; -------------------------------------------------------------------------

RunR61:
	lea	R61SubCmds(pc),a0
	move.w	#$400,level
	bra.s	RunLevel

; -------------------------------------------------------------------------
; Run Wacky Workbench Act 2
; -------------------------------------------------------------------------

RunR62:
	lea	R62SubCmds(pc),a0
	move.w	#$401,level
	bra.s	RunLevel

; -------------------------------------------------------------------------
; Run Wacky Workbench Act 3
; -------------------------------------------------------------------------

RunR63:
	lea	R63SubCmds(pc),a0
	move.w	#$402,level
	bra.w	RunBossLevel

; -------------------------------------------------------------------------
; Run Stardust Speedway Act 1
; -------------------------------------------------------------------------

RunR71:
	lea	R71SubCmds(pc),a0
	move.w	#$500,level
	bra.s	RunLevel

; -------------------------------------------------------------------------
; Run Stardust Speedway Act 2
; -------------------------------------------------------------------------

RunR72:
	lea	R72SubCmds(pc),a0
	move.w	#$501,level
	bra.s	RunLevel

; -------------------------------------------------------------------------
; Run Stardust Speedway Act 3
; -------------------------------------------------------------------------

RunR73:
	lea	R73SubCmds(pc),a0
	move.w	#$502,level
	bra.w	RunBossLevel

; -------------------------------------------------------------------------
; Run Metallic Madness Act 1
; -------------------------------------------------------------------------

RunR81:
	lea	R81SubCmds(pc),a0
	move.w	#$600,level
	bra.s	RunLevel

; -------------------------------------------------------------------------
; Run Metallic Madness Act 2
; -------------------------------------------------------------------------

RunR82:
	lea	R82SubCmds(pc),a0
	move.w	#$601,level
	bra.s	RunLevel

; -------------------------------------------------------------------------
; Run Metallic Madness Act 3
; -------------------------------------------------------------------------

RunR83:
	lea	R83SubCmds(pc),a0
	move.w	#$602,level
	bra.w	RunBossLevel

; -------------------------------------------------------------------------
; Run level
; -------------------------------------------------------------------------

RunLevel:
	moveq	#0,d0				; Get present file load command
	move.b	0(a0),d0

.LevelLoop:
	bsr.w	RunMMD				; Run level file

	tst.b	lifeCount			; Have we run out of lives?
	beq.s	.LevelOver			; If so, branch
	btst	#7,timeZone			; Are we time traveling?
	beq.s	.LevelOver			; If not, branch

	moveq	#SCMD_WARP,d0			; Run warp sequence file
	bsr.w	RunMMD

	move.b	timeZone,d1			; Get new time zone

	moveq	#0,d0				; Get past file load command
	move.b	1(a0),d0
	andi.b	#$7F,d1				; Are we in the past?
	beq.s	.LevelLoop			; If so, branch

	move.b	0(a0),d0			; Get present file load command
	subq.b	#1,d1				; Are we in the present?
	beq.s	.LevelLoop			; If so, branch

	move.b	3(a0),d0			; Get bad future file load command
	tst.b	goodFuture			; Are we in the good future?
	beq.s	.LevelLoop			; If not, branch
	
	move.b	2(a0),d0			; Get good future file load command
	bra.s	.LevelLoop			; Loop

.LevelOver:
	tst.b	lifeCount			; Do we still have lives left?
	bne.s	.CheckSpecStage			; If so, branch
	move.l	(sp)+,d0			; If not, exit
	bra.w	GameOver

.CheckSpecStage:
	tst.b	enteredBigRing			; Has Sonic entered a big ring?
	bne.s	.SpecialStage			; If so, branch
	rts

.SpecialStage:
	move.b	curSpecStage,GACOMCMD3		; Set stage ID
	move.b	timeStones,GACOMCMDA		; Copy time stones retrieved flags
	bclr	#0,GACOMCMDB			; Normal mode

	moveq	#SCMD_SPECSTAGE,d0		; Run special stage
	bsr.w	RunMMD

	move.b	#1,palClearFlags		; Fade from white in next level
	cmpi.b	#%01111111,timeStones		; Do we have all of the time stones now?
	bne.s	.End				; If not, branch
	move.b	#1,goodFuture			; If so, set good future flag

.End:
	rts

; -------------------------------------------------------------------------
; Run boss level
; -------------------------------------------------------------------------

RunBossLevel:
	moveq	#0,d0				; Get good future file load command
	move.b	0(a0),d0
	tst.b	goodFuture			; Are we in the good future?
	bne.s	.RunLevel			; If so, branch
	move.b	1(a0),d0			; Get bad future file load command
	
.RunLevel:
	bsr.w	RunMMD				; Run level file

	tst.b	lifeCount			; Do we still have lives left?
	bne.s	.NextLevel			; If so, branch
	move.l	(sp)+,d0			; If not, exit
	bra.w	GameOver

.NextLevel:
	addq.b	#1,savedLevel			; Next level
	cmpi.b	#7,savedLevel			; Are we at the end of the game?
	bcs.s	.End				; If not, branch
	subq.b	#1,savedLevel			; Cap level ID

.End:
	move.b	#0,lastCheckpoint		; Reset last checkpoint ID
	rts

; -------------------------------------------------------------------------
; Unlock time attack zone
; -------------------------------------------------------------------------
; PARAMETERS
;	d0.b - Level ID
; -------------------------------------------------------------------------

UnlockTimeAttackLevel:
	cmp.b	timeAttackUnlock,d0		; Is this level already unlocked?
	bls.s	.End				; If so, branch
	move.b	d0,timeAttackUnlock		; If not, unlock it

.End:
	rts

; -------------------------------------------------------------------------
; Level loading Sub CPU commands
; -------------------------------------------------------------------------

; Palmtree Panic
R11SubCmds:
	dc.b	SCMD_R11A, SCMD_R11B, SCMD_R11C, SCMD_R11D
R12SubCmds:
	dc.b	SCMD_R12A, SCMD_R12B, SCMD_R12C, SCMD_R12D
R13SubCmds:
	dc.b	SCMD_R13C, SCMD_R13D

; Collision Chaos
R31SubCmds:
	dc.b	SCMD_R31A, SCMD_R31B, SCMD_R31C, SCMD_R31D
R32SubCmds:
	dc.b	SCMD_R32A, SCMD_R32B, SCMD_R32C, SCMD_R32D
R33SubCmds:
	dc.b	SCMD_R33C, SCMD_R33D

; Tidal Tempest
R41SubCmds:
	dc.b	SCMD_R41A, SCMD_R41B, SCMD_R41C, SCMD_R41D
R42SubCmds:
	dc.b	SCMD_R42A, SCMD_R42B, SCMD_R42C, SCMD_R42D
R43SubCmds:
	dc.b	SCMD_R43C, SCMD_R43D

; Quartz Quadrant
R51SubCmds:
	dc.b	SCMD_R51A, SCMD_R51B, SCMD_R51C, SCMD_R51D
R52SubCmds:
	dc.b	SCMD_R52A, SCMD_R52B, SCMD_R52C, SCMD_R52D
R53SubCmds:
	dc.b	SCMD_R53C, SCMD_R53D

; Wacky Workbench
R61SubCmds:
	dc.b	SCMD_R61A, SCMD_R61B, SCMD_R61C, SCMD_R61D
R62SubCmds:
	dc.b	SCMD_R62A, SCMD_R62B, SCMD_R62C, SCMD_R62D
R63SubCmds:
	dc.b	SCMD_R63C, SCMD_R63D

; Stardust Speedway
R71SubCmds:
	dc.b	SCMD_R71A, SCMD_R71B, SCMD_R71C, SCMD_R71D
R72SubCmds:
	dc.b	SCMD_R72A, SCMD_R72B, SCMD_R72C, SCMD_R72D
R73SubCmds:
	dc.b	SCMD_R73C, SCMD_R73D

; Metallic Madness
R81SubCmds:
	dc.b	SCMD_R81A, SCMD_R81B, SCMD_R81C, SCMD_R81D
R82SubCmds:
	dc.b	SCMD_R82A, SCMD_R82B, SCMD_R82C, SCMD_R82D
R83SubCmds:
	dc.b	SCMD_R83C, SCMD_R83D

; -------------------------------------------------------------------------
; Stage select
; -------------------------------------------------------------------------

StageSelect:
	moveq	#SCMD_STAGESEL,d0		; Run stage select file
	bsr.w	RunMMD

	mulu.w	#6,d0				; Get selected stage data
	move.w	StageSels+2(pc,d0.w),level	; Set level
	move.b	StageSels+4(pc,d0.w),timeZone	; Time zone
	move.b	StageSels+5(pc,d0.w),goodFuture	; Good future flag
	move.w	StageSels(pc,d0.w),d0		; File load Sub CPU command
	
	move.b	#0,projDestroyed		; Reset projector destroyed flag

	cmpi.w	#SCMD_SPECSTAGE,d0		; Have we selected the special stage?
	beq.w	SpecStage1Demo			; If so, branch
	
	bsr.w	RunMMD				; Run level file
	rts

; -------------------------------------------------------------------------

StageSels:
	; Palmtree Panic
	dc.w	SCMD_R11A, $000			; Act 1 Present
	dc.b	TIME_PRESENT, 0
	dc.w	SCMD_R11B, $000			; Act 1 Past
	dc.b	TIME_PAST, 0
	dc.w	SCMD_R11C, $000			; Act 1 Good future
	dc.b	TIME_FUTURE, 1
	dc.w	SCMD_R11D, $000			; Act 1 Bad future
	dc.b	TIME_FUTURE, 0
	dc.w	SCMD_R12A, $001			; Act 2 Present
	dc.b	TIME_PRESENT, 0
	dc.w	SCMD_R12B, $001			; Act 2 Past
	dc.b	TIME_PAST, 0
	dc.w	SCMD_R12C, $001			; Act 2 Good future
	dc.b	TIME_FUTURE, 1
	dc.w	SCMD_R12D, $001			; Act 2 Bad future
	dc.b	TIME_FUTURE, 0

	; Warp sequence
	dc.w	SCMD_WARP, $000
	dc.b	TIME_PAST, 0

	; Opening FMV
	dc.w	SCMD_OPENING, $000
	dc.b	TIME_PAST, 0
	
	; "Comin' Soon" screen
	dc.w	SCMD_COMINSOON, $000
	dc.b	TIME_PAST, 0
	
	; Collision Chaos
	dc.w	SCMD_R31A, $100			; Act 1 Present
	dc.b	TIME_PRESENT, 0
	dc.w	SCMD_R31B, $100			; Act 1 Past
	dc.b	TIME_PAST, 0
	dc.w	SCMD_R31C, $100			; Act 1 Good future
	dc.b	TIME_FUTURE, 1
	dc.w	SCMD_R31D, $100			; Act 1 Bad future
	dc.b	TIME_FUTURE, 0

	dc.w	SCMD_R32A, $101			; Act 1 Present
	dc.b	TIME_PRESENT, 0
	dc.w	SCMD_R32B, $101			; Act 1 Past
	dc.b	TIME_PAST, 0
	dc.w	SCMD_R32C, $101			; Act 1 Good future
	dc.b	TIME_FUTURE, 1
	dc.w	SCMD_R32D, $101			; Act 1 Bad future
	dc.b	TIME_FUTURE, 0

	dc.w	SCMD_R33C, $102			; Act 1 Good future
	dc.b	TIME_FUTURE, 1
	dc.w	SCMD_R33D, $102			; Act 1 Bad future
	dc.b	TIME_FUTURE, 0

	; Palmtree Panic Act 3
	dc.w	SCMD_R13C, $002			; Good future
	dc.b	TIME_FUTURE, 1
	dc.w	SCMD_R13D, $002			; Bad future
	dc.b	TIME_FUTURE, 0
	
	; Tidal Tempest
	dc.w	SCMD_R41A, $200			; Act 1 Present
	dc.b	TIME_PRESENT, 0
	dc.w	SCMD_R41B, $200			; Act 1 Past
	dc.b	TIME_PAST, 0
	dc.w	SCMD_R41C, $200			; Act 1 Good future
	dc.b	TIME_FUTURE, 1
	dc.w	SCMD_R41D, $200			; Act 1 Bad future
	dc.b	TIME_FUTURE, 0

	dc.w	SCMD_R42A, $201			; Act 2 Present
	dc.b	TIME_PRESENT, 0
	dc.w	SCMD_R42B, $201			; Act 2 Past
	dc.b	TIME_PAST, 0
	dc.w	SCMD_R42C, $201			; Act 2 Good future
	dc.b	TIME_FUTURE, 1
	dc.w	SCMD_R42D, $201			; Act 2 Bad future
	dc.b	TIME_FUTURE, 0

	dc.w	SCMD_R43C, $202			; Act 3 Good future
	dc.b	TIME_FUTURE, 1
	dc.w	SCMD_R43D, $202			; Act 3 Bad future
	dc.b	TIME_FUTURE, 0
	
	; Quartz Quadrant
	dc.w	SCMD_R51A, $300			; Act 1 Present
	dc.b	TIME_PRESENT, 0
	dc.w	SCMD_R51B, $300			; Act 1 Past
	dc.b	TIME_PAST, 0
	dc.w	SCMD_R51C, $300			; Act 1 Good future
	dc.b	TIME_FUTURE, 1
	dc.w	SCMD_R51D, $300			; Act 1 Bad future
	dc.b	TIME_FUTURE, 0

	dc.w	SCMD_R52A, $301			; Act 2 Present
	dc.b	TIME_PRESENT, 0
	dc.w	SCMD_R52B, $301			; Act 2 Past
	dc.b	TIME_PAST, 0
	dc.w	SCMD_R52C, $301			; Act 2 Good future
	dc.b	TIME_FUTURE, 1
	dc.w	SCMD_R52D, $301			; Act 2 Bad future
	dc.b	TIME_FUTURE, 0

	dc.w	SCMD_R53C, $302			; Act 3 Good future
	dc.b	TIME_FUTURE, 1
	dc.w	SCMD_R53D, $302			; Act 3 Bad future
	dc.b	TIME_FUTURE, 0
	
	; Wacky Workbench
	dc.w	SCMD_R61A, $400			; Act 1 Present
	dc.b	TIME_PRESENT, 0
	dc.w	SCMD_R61B, $400			; Act 1 Past
	dc.b	TIME_PAST, 0
	dc.w	SCMD_R61C, $400			; Act 1 Good future
	dc.b	TIME_FUTURE, 1
	dc.w	SCMD_R61D, $400			; Act 1 Bad future
	dc.b	TIME_FUTURE, 0

	dc.w	SCMD_R62A, $401			; Act 2 Present
	dc.b	TIME_PRESENT, 0
	dc.w	SCMD_R62B, $401			; Act 2 Past
	dc.b	TIME_PAST, 0
	dc.w	SCMD_R62C, $401			; Act 2 Good future
	dc.b	TIME_FUTURE, 1
	dc.w	SCMD_R62D, $401			; Act 2 Bad future
	dc.b	TIME_FUTURE, 0

	dc.w	SCMD_R63C, $402			; Act 3 Good future
	dc.b	TIME_FUTURE, 1
	dc.w	SCMD_R63D, $402			; Act 3 Bad future
	dc.b	TIME_FUTURE, 0
	
	; Stardust Speedway
	dc.w	SCMD_R71A, $500			; Act 1 Present
	dc.b	TIME_PRESENT, 0
	dc.w	SCMD_R71B, $500			; Act 1 Past
	dc.b	TIME_PAST, 0
	dc.w	SCMD_R71C, $500			; Act 1 Good future
	dc.b	TIME_FUTURE, 1
	dc.w	SCMD_R71D, $500			; Act 1 Bad future
	dc.b	TIME_FUTURE, 0

	dc.w	SCMD_R72A, $501			; Act 2 Present
	dc.b	TIME_PRESENT, 0
	dc.w	SCMD_R72B, $501			; Act 2 Past
	dc.b	TIME_PAST, 0
	dc.w	SCMD_R72C, $501			; Act 2 Good future
	dc.b	TIME_FUTURE, 1
	dc.w	SCMD_R72D, $501			; Act 2 Bad future
	dc.b	TIME_FUTURE, 0

	dc.w	SCMD_R73C, $502			; Act 3 Good future
	dc.b	TIME_FUTURE, 1
	dc.w	SCMD_R73D, $502			; Act 3 Bad future
	dc.b	TIME_FUTURE, 0
	
	; Metallic Madness
	dc.w	SCMD_R81A, $600			; Act 1 Present
	dc.b	TIME_PRESENT, 0
	dc.w	SCMD_R81B, $600			; Act 1 Past
	dc.b	TIME_PAST, 0
	dc.w	SCMD_R81C, $600			; Act 1 Good future
	dc.b	TIME_FUTURE, 1
	dc.w	SCMD_R81D, $600			; Act 1 Bad future
	dc.b	TIME_FUTURE, 0

	dc.w	SCMD_R82A, $601			; Act 2 Present
	dc.b	TIME_PRESENT, 0
	dc.w	SCMD_R82B, $601			; Act 2 Past
	dc.b	TIME_PAST, 0
	dc.w	SCMD_R82C, $601			; Act 2 Good future
	dc.b	TIME_FUTURE, 1
	dc.w	SCMD_R82D, $601			; Act 2 Bad future
	dc.b	TIME_FUTURE, 0

	dc.w	SCMD_R83C, $602			; Act 3 Good future
	dc.b	TIME_FUTURE, 1
	dc.w	SCMD_R83D, $602			; Act 3 Bad future
	dc.b	TIME_FUTURE, 0

	; Special Stage 1 demo
	dc.w	SCMD_SPECSTAGE, $000
	dc.b	TIME_PAST, 0
	
	; Unused
	dc.w	SCMD_R11A, $000
	dc.b	TIME_PRESENT, 0
	dc.w	SCMD_R11A, $000
	dc.b	TIME_PRESENT, 0
	dc.w	SCMD_R11A, $000
	dc.b	TIME_PRESENT, 0
	dc.w	SCMD_R11A, $000
	dc.b	TIME_PRESENT, 0

; -------------------------------------------------------------------------
; Demo mode
; -------------------------------------------------------------------------

Demo:
	moveq	#(.DemosEnd-.Demos)/2-1,d1	; Maximum demo ID
	
	lea	demoID,a6			; Get current demo ID
	moveq	#0,d0
	move.b	(a6),d0

	addq.b	#1,(a6)				; Advance demo ID
	cmp.b	(a6),d1				; Are we past the max ID?
	bcc.s	.RunDemo			; If not, branch
	move.b	#0,(a6)				; Wrap demo ID

.RunDemo:
	add.w	d0,d0				; Run demo
	move.w	.Demos(pc,d0.w),d0
	jmp	.Demos(pc,d0.w)

; -------------------------------------------------------------------------

.Demos:
	dc.w	Demo_OpenFMV-.Demos		; Opening FMV
	dc.w	Demo_R11A-.Demos		; Palmtree Panic Act 1 Present
	dc.w	Demo_SpecStg1-.Demos		; Special Stage 1
	dc.w	Demo_R43C-.Demos		; Tidal Tempest Act 3 Good Future
	dc.w	Demo_SpecStg6-.Demos		; Special Stage 6
	dc.w	Demo_R82A-.Demos		; Metallic Madness Act 2 Present
.DemosEnd:

; -------------------------------------------------------------------------
; Palmtree Panic Act 1 Present demo
; -------------------------------------------------------------------------

Demo_R11A:
	move.b	#0,plcLoadFlags			; Reset PLC load flags
	move.w	#$000,level			; Set level to Palmtree Panic Act 1
	move.b	#TIME_PRESENT,timeZone		; Set time zone to present
	move.b	#0,goodFuture			; Reset good future flag
	
	move.w	#SCMD_R11ADEMO,d0		; Run demo file
	bsr.w	RunMMD
	move.w	#0,demoMode			; Reset demo mode flag
	rts

; -------------------------------------------------------------------------
; Tidal Tempest Act 3 Good Future
; -------------------------------------------------------------------------

Demo_R43C:
	move.b	#0,plcLoadFlags			; Reset PLC load flags
	move.w	#$202,level			; Set level to Tidal Tempest Act 3
	move.b	#TIME_FUTURE,timeZone		; Set time zone to present
	move.b	#1,goodFuture			; Set good future flag
	
	move.w	#SCMD_R43CDEMO,d0		; Run demo file
	bsr.w	RunMMD
	move.w	#0,demoMode			; Reset demo mode flag
	rts

; -------------------------------------------------------------------------
; Metallic Madness Act 2 Present
; -------------------------------------------------------------------------

Demo_R82A:
	move.b	#0,plcLoadFlags			; Reset PLC load flags
	move.w	#$601,level			; Set level to Metallic Madness Act 2
	move.b	#TIME_PRESENT,timeZone		; Set time zone to present
	move.b	#0,goodFuture			; Reset good future flag
	
	move.w	#SCMD_R82ADEMO,d0		; Run demo file
	bsr.w	RunMMD
	move.w	#0,demoMode			; Reset demo mode flag
	rts

; -------------------------------------------------------------------------
; Special Stage 1 demo
; -------------------------------------------------------------------------

Demo_SpecStg1:
	move.w	#SCMD_INITSS,d0			; Initialize special stage flags
	bsr.w	SubCPUCmd
	bra.w	SpecStage1Demo			; Run demo file

; -------------------------------------------------------------------------
; Special Stage 6 demo
; -------------------------------------------------------------------------

Demo_SpecStg6:
	move.w	#SCMD_INITSS,d0			; Initialize special stage flags
	bsr.w	SubCPUCmd
	bra.w	SpecStage6Demo			; Run demo file

; -------------------------------------------------------------------------
; Opening FMV
; -------------------------------------------------------------------------

Demo_OpenFMV:
	move.w	#SCMD_OPENING,d0		; Run opening FMV file
	bsr.w	RunMMD
	tst.b	mmdReturnCode			; Should we play it again?
	bmi.s	Demo_OpenFMV			; If so, loop
	rts

; -------------------------------------------------------------------------
; Sound test
; -------------------------------------------------------------------------

SoundTest:
	moveq	#SCMD_SNDTEST,d0		; Run sound test file
	bsr.w	RunMMD

	add.w	d0,d0				; Exit sound test
	move.w	.Exits(pc,d0.w),d0
	jmp	.Exits(pc,d0.w)

; -------------------------------------------------------------------------

.Exits:
	dc.w	SoundTest_Exit-.Exits		; Exit sound test
	dc.w	SoundTest_SpecStg8-.Exits	; Special Stage 8
	dc.w	SoundTest_FunIsInf-.Exits	; Fun is infinite
	dc.w	SoundTest_MCSonic-.Exits	; M.C. Sonic
	dc.w	SoundTest_Tails-.Exits		; Tails
	dc.w	SoundTest_Batman-.Exits		; Batman Sonic
	dc.w	SoundTest_CuteSonic-.Exits	; Cute Sonic

; -------------------------------------------------------------------------
; Exit sound test
; -------------------------------------------------------------------------

SoundTest_Exit:
	rts

; -------------------------------------------------------------------------
; Special Stage 8
; -------------------------------------------------------------------------

SoundTest_SpecStg8:
	move.b	#8-1,GACOMCMD3			; Stage 8
	move.b	#0,GACOMCMDA			; Reset stages beaten
	bset	#0,GACOMCMDB			; Temporary mode
	bset	#2,GACOMCMDB
	
	moveq	#SCMD_SPECSTAGE,d0		; Run special stage
	bsr.w	RunMMD
	tst.b	specStageLost			; Was the stage beaten?
	bne.s	.End				; If not, branch
	move.w	#SCMD_STAFFCREDS,d0		; If so, run staff credits
	bsr.w	RunMMD

.End:
	rts

; -------------------------------------------------------------------------
; "Fun is infinite" easter egg
; -------------------------------------------------------------------------

SoundTest_FunIsInf:
	move.w	#SCMD_FUNISINF,d0
	bra.w	RunMMD

; -------------------------------------------------------------------------
; M.C. Sonic easter egg
; -------------------------------------------------------------------------

SoundTest_MCSonic:
	move.w	#SCMD_MCSONIC,d0
	bra.w	RunMMD

; -------------------------------------------------------------------------
; Tails easter egg
; -------------------------------------------------------------------------

SoundTest_Tails:
	move.w	#SCMD_TAILS,d0
	bra.w	RunMMD

; -------------------------------------------------------------------------
; Batman Sonic easter egg
; -------------------------------------------------------------------------

SoundTest_Batman:
	move.w	#SCMD_BATMAN,d0
	bra.w	RunMMD

; -------------------------------------------------------------------------
; Cute Sonic easter egg
; -------------------------------------------------------------------------

SoundTest_CuteSonic:
	move.w	#SCMD_CUTESONIC,d0
	bra.w	RunMMD

; -------------------------------------------------------------------------
; Visual Mode
; -------------------------------------------------------------------------

VisualMode:
	move.w	#SCMD_VISMODE,d0		; Run Visual Mode file
	bsr.w	RunMMD

	add.w	d0,d0				; Play FMV
	move.w	.FMVs(pc,d0.w),d0
	jmp	.FMVs(pc,d0.w)

; -------------------------------------------------------------------------

.FMVs:
	dc.w	VisualMode_Exit-.FMVs		; Exit Visual Mode
	dc.w	VisualMode_OpenFMV-.FMVs	; Opening FMV
	dc.w	VisualMode_GoodEnd-.FMVs	; Good ending FMV
	dc.w	VisualMode_BadEnd-.FMVs		; Bad ending FMV
	dc.w	VisualMode_PencilTest-.FMVs	; Pencil test FMV

; -------------------------------------------------------------------------
; Play opening FMV
; -------------------------------------------------------------------------

VisualMode_OpenFMV:
	move.w	#SCMD_OPENING,d0		; Run opening FMV file
	bsr.w	RunMMD
	tst.b	mmdReturnCode			; Should we play it again?
	bmi.s	VisualMode_OpenFMV		; If so, loop

	bra.s	VisualMode			; Go back to menu

; -------------------------------------------------------------------------
; Exit Visual Mode
; -------------------------------------------------------------------------

VisualMode_Exit:
	rts

; -------------------------------------------------------------------------
; Play pencil test FMV
; -------------------------------------------------------------------------

VisualMode_PencilTest:
	move.w	#SCMD_PENCILTEST,d0		; Run pencil test FMV file
	bsr.w	RunMMD
	tst.b	mmdReturnCode			; Should we play it again?
	bmi.s	VisualMode_PencilTest		; If so, loop

	bra.s	VisualMode			; Go back to menu

; -------------------------------------------------------------------------
; Play good ending FMV
; -------------------------------------------------------------------------

VisualMode_GoodEnd:
	move.b	#$7F,endingID			; Set ending ID to good ending
	move.w	#SCMD_GOODEND,d0		; Run good ending file
	bsr.w	RunMMD
	tst.b	mmdReturnCode			; Should we play it again?
	bmi.s	VisualMode_GoodEnd		; If so, loop
	
	move.w	#SCMD_THANKYOU,d0		; Run "Thank You" file
	bsr.w	RunMMD

	bra.s	VisualMode			; Go back to menu

; -------------------------------------------------------------------------
; Play bad ending FMV
; -------------------------------------------------------------------------

VisualMode_BadEnd:
	move.b	#0,endingID			; Set ending ID to bad ending
	move.w	#SCMD_BADEND,d0			; Run bad ending file
	bsr.w	RunMMD
	tst.b	mmdReturnCode			; Should we play it again?
	bmi.s	VisualMode_BadEnd		; If so, loop

	bra.s	VisualMode			; Go back to menu

; -------------------------------------------------------------------------
; D.A. Garden
; -------------------------------------------------------------------------

DAGarden:
	move.w	#SCMD_DAGARDEN,d0		; Run D.A. Garden file
	bra.w	RunMMD

; -------------------------------------------------------------------------
; Time Attack
; -------------------------------------------------------------------------

TimeAttack:
	moveq	#SCMD_TIMEATK,d0		; Run time attack menu file
	bsr.w	RunMMD
	move.w	d0,timeAttackLevel		; Set level
	beq.w	.End				; If we are exiting, branch

	move.b	.Selections(pc,d0.w),d0		; Get stage selection ID
	bmi.s	TimeAttack_SS			; If we are entering a special stage, branch

	mulu.w	#6,d0				; Get selected stage data
	lea	StageSels(pc),a6
	move.w	2(a6,d0.w),level		; Set level
	move.b	4(a6,d0.w),timeZone		; Time zone
	move.b	5(a6,d0.w),goodFuture		; Good future flag
	move.w	(a6,d0.w),d0			; File load Sub CPU command
	
	move.b	#1,timeAttackMode		; Set time attack mode flag
	move.b	#0,projDestroyed		; Reset projector destroyed flag
	
	bsr.w	RunMMD				; Run level file
	
	move.b	#0,lastCheckpoint		; Reset last checkpoint ID
	move.l	levelTime,timeAttackTime	; Save time attack time
	
	bra.s	TimeAttack			; Loop back to menu

.End:
	rts

; -------------------------------------------------------------------------

.Selections:
	dc.b	0				; Invalid

	dc.b	0				; Palmtree Panic Act 1
	dc.b	4				; Palmtree Panic Act 2
	dc.b	$16				; Palmtree Panic Act 3
	
	dc.b	$B				; Collision Chaos Act 1
	dc.b	$F				; Collision Chaos Act 2
	dc.b	$14				; Collision Chaos Act 3
	
	dc.b	$17				; Tidal Tempest Act 1
	dc.b	$1B				; Tidal Tempest Act 2
	dc.b	$20				; Tidal Tempest Act 3
	
	dc.b	$21				; Quartz Quadrant Act 1
	dc.b	$25				; Quartz Quadrant Act 2
	dc.b	$2A				; Quartz Quadrant Act 3
	
	dc.b	$2B				; Wacky Workbench Act 1
	dc.b	$2F				; Wacky Workbench Act 2
	dc.b	$34				; Wacky Workbench Act 3
	
	dc.b	$35				; Stardust Speedway Act 1
	dc.b	$39				; Stardust Speedway Act 2
	dc.b	$3E				; Stardust Speedway Act 3
	
	dc.b	$3F				; Metallic Madness Act 1
	dc.b	$43				; Metallic Madness Act 2
	dc.b	$48				; Metallic Madness Act 3

	dc.b	-1				; Special Stage 1
	dc.b	-2				; Special Stage 2
	dc.b	-3				; Special Stage 3
	dc.b	-4				; Special Stage 4
	dc.b	-5				; Special Stage 5
	dc.b	-6				; Special Stage 6
	dc.b	-7				; Special Stage 7
	even

; -------------------------------------------------------------------------

TimeAttack_SS:
	neg.b	d0				; Set special stage ID
	ext.w	d0
	subq.w	#1,d0
	move.b	d0,GACOMCMD3
	move.b	#0,GACOMCMDA			; Reset stages beaten
	bset	#1,GACOMCMDB			; Time attack mode

	moveq	#SCMD_SPECSTAGE,d0		; Run special stage
	bsr.w	RunMMD
	
	bra.w	TimeAttack			; Loop back to menu

; -------------------------------------------------------------------------
; Run MMD file
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - File load Sub CPU command ID
; -------------------------------------------------------------------------

RunMMD:
	move.l	a0,-(sp)			; Save a0
	move.w	d0,GACOMCMD0			; Set Sub CPU command ID

	lea	WORKRAMFILE,a1			; Clear work RAM file buffer
	moveq	#0,d0
	move.w	#WORKRAMFILESZ/16-1,d7

.ClearFileBuffer:
	rept	16/4
		move.l	d0,(a1)+
	endr
	dbf	d7,.ClearFileBuffer

	bsr.w	WaitWordRAMAccess		; Wait for Word RAM access

	move.l	WORDRAM2M+mmdEntry,d0		; Get entry address
	beq.w	.End				; If it's not set, exit
	movea.l	d0,a0

	move.l	WORDRAM2M+mmdOrigin,d0		; Get origin address
	beq.s	.GetHInt			; If it's not set, branch
	
	movea.l	d0,a2				; Copy file to origin address
	lea	WORDRAM2M+mmdFile,a1
	move.w	WORDRAM2M+mmdSize,d7

.CopyFile:
	move.l	(a1)+,(a2)+
	dbf	d7,.CopyFile

.GetHInt:
	move	sr,-(sp)			; Save status register

	move.l	WORDRAM2M+mmdHInt,d0		; Get H-INT address
	beq.s	.GetVInt			; If it's not set, branch
	move.l	d0,_LEVEL4+2.w			; Set H-INT address

.GetVInt:
	move.l	WORDRAM2M+mmdVInt,d0		; Get V-INT address
	beq.s	.CheckFlags			; If it's not set, branch
	move.l	d0,_LEVEL6+2.w			; Set V-INT address

.CheckFlags:
	btst	#MMDSUB,WORDRAM2M+mmdFlags	; Should the Sub CPU have Word RAM access?
	beq.s	.NoSubWordRAM			; If not, branch
	bsr.w	GiveWordRAMAccess		; Give Sub CPU Word RAM access

.NoSubWordRAM:
	move	(sp)+,sr			; Restore status register

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

	jsr	(a0)				; Run file
	move.b	d0,mmdReturnCode		; Set return code

	bsr.w	StopZ80				; Stop the Z80
	move.b	#FMC_STOP,FMDrvQueue2		; Stop FM sound
	bsr.w	StartZ80			; Start the Z80

	move.b	#0,ipxVSync			; Clear VSync flag
	move.l	#BlankInt,_LEVEL4+2.w		; Reset H-INT address
	move.l	#VInterrupt,_LEVEL6+2.w		; Reset V-INT address
	move.w	#$8134,ipxVDPReg1		; Reset VDP register 1 cache
	
	bset	#0,screenDisable		; Set screen disable flag
	bsr.w	VSync				; VSync
	
	bsr.w	GiveWordRAMAccess		; Give Sub CPU Word RAM access

.End:
	movea.l	(sp)+,a0			; Restore a0
	rts

; -------------------------------------------------------------------------

screenDisable:
	dc.b	0				; Screen disable flag
mmdReturnCode:
	dc.b	0				; MMD return code

; -------------------------------------------------------------------------
; V-BLANK interrupt handler
; -------------------------------------------------------------------------

VInterrupt:
	bset	#0,GAIRQ2			; Trigger IRQ2 on Sub CPU
	
	bclr	#0,ipxVSync			; Clear VSync flag
	bclr	#0,screenDisable		; Clear screen disable flag
	beq.s	BlankInt			; If it wasn't set branch
	
	move.w	#$8134,VDPCTRL			; If it was set, disable the screen

BlankInt:
	rte

; -------------------------------------------------------------------------
; Read save data
; -------------------------------------------------------------------------

ReadSaveData:
	bsr.w	GetBuRAMData			; Get Backup RAM data

	move.w	WORDRAM2M+svZone,savedLevel	; Read save data
	move.b	WORDRAM2M+svGoodFutures,goodFutures
	move.b	WORDRAM2M+svTitleFlags,titleFlags
	move.b	WORDRAM2M+svTmAtkUnlock,timeAttackUnlock
	move.b	WORDRAM2M+svUnknown,unkBuRAMVar
	move.b	WORDRAM2M+svSpecStage,curSpecStage
	move.b	WORDRAM2M+svTimeStones,timeStones

	bsr.w	GiveWordRAMAccess		; Give Sub CPU Word RAM access
	rts

; -------------------------------------------------------------------------
; Get Backup RAM data
; -------------------------------------------------------------------------

GetBuRAMData:
	bsr.w	GiveWordRAMAccess		; Give Sub CPU Word RAM access
	
	move.w	#SCMD_RDTEMPSAVE,d0		; Read temporary save data
	btst	#0,saveDisabled			; Is saving to Backup RAM disabled?
	bne.s	.Read				; If so, branch
	move.w	#SCMD_READSAVE,d0		; Read Backup RAM save data
	
.Read:
	bsr.w	SubCPUCmd			; Run command
	bra.w	WaitWordRAMAccess		; Wait for Word RAM access

; -------------------------------------------------------------------------
; Write save data
; -------------------------------------------------------------------------

WriteSaveData:
	bsr.s	GetBuRAMData			; Get Backup RAM data

	move.w	savedLevel,WORDRAM2M+svZone	; Write save data
	move.b	goodFutures,WORDRAM2M+svGoodFutures
	move.b	titleFlags,WORDRAM2M+svTitleFlags
	move.b	timeAttackUnlock,WORDRAM2M+svTmAtkUnlock
	move.b	unkBuRAMVar,WORDRAM2M+svUnknown
	move.b	curSpecStage,WORDRAM2M+svSpecStage
	move.b	timeStones,WORDRAM2M+svTimeStones

	bsr.w	GiveWordRAMAccess		; Give Sub CPU Word RAM access

	move.w	#SCMD_WRTEMPSAVE,d0		; Write temporary save data
	btst	#0,saveDisabled			; Is saving to Backup RAM disabled?
	bne.s	.Read				; If so, branch
	move.w	#SCMD_WRITESAVE,d0		; Write Backup RAM save data
	
.Read:
	bsr.w	SubCPUCmd			; Run command
	bsr.w	WaitWordRAMAccess		; Wait for Word RAM access
	bra.w	GiveWordRAMAccess		; Give Sub CPU Word RAM access
	
; -------------------------------------------------------------------------
; Send the Sub CPU a command
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
; Wait for Word RAM access
; -------------------------------------------------------------------------

WaitWordRAMAccess:
	btst	#0,GAMEMMODE			; Do we have Word RAM access?
	beq.s	WaitWordRAMAccess		; If not, wait
	rts

; -------------------------------------------------------------------------
; Give Sub CPU Word RAM access
; -------------------------------------------------------------------------

GiveWordRAMAccess:
	bset	#1,GAMEMMODE			; Give Sub CPU Word RAM access
	btst	#1,GAMEMMODE			; Has it been given?
	beq.s	GiveWordRAMAccess		; If not, wait
	rts

; -------------------------------------------------------------------------
; Stop the Z80
; -------------------------------------------------------------------------

StopZ80:
	move	sr,savedSR			; Save status register
	move	#$2700,sr			; Disable interrupts
	Z80STOP					; Stop the Z80
	rts

; -------------------------------------------------------------------------
; Start the Z80
; -------------------------------------------------------------------------

StartZ80:
	Z80START				; Start the Z80
	move	savedSR,sr			; Restore status register
	rts

; -------------------------------------------------------------------------
; VSync
; -------------------------------------------------------------------------

VSync:
	bset	#0,ipxVSync			; Set VSync flag
	move	#$2500,sr			; Enable V-INT

.Wait:
	btst	#0,ipxVSync			; Has the V-INT handler run?
	bne.s	.Wait				; If not, wait
	rts

; -------------------------------------------------------------------------
; Send the Sub CPU a command (copy)
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Command ID
; -------------------------------------------------------------------------

SubCPUCmdCopy:
	move.w	d0,GACOMCMD0			; Send the command

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
; Saved status register
; -------------------------------------------------------------------------

savedSR:
	dc.w	0

; -------------------------------------------------------------------------

	jmp	0.w				; Unreferenced
	ALIGN	MAINVARS
End:

; -------------------------------------------------------------------------
