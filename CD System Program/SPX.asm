; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; System program extension
; -------------------------------------------------------------------------

	include	"_Include/Common.i"
	include	"_Include/Sub CPU.i"
	include	"_Include/System.i"
	include	"_Include/Backup RAM.i"
	include	"_Include/Sound.i"
	include	"Sound Drivers/PCM/_Variables.i"
	include	"Special Stage/_Global Variables.i"
	include	"DA Garden/Track Title Labels.i"

; -------------------------------------------------------------------------
; Files
; -------------------------------------------------------------------------

	org	SPX
File_R11A:
	dc.b	"R11A__.MMD;1", 0		; Palmtree Panic Act 1 Present
File_R11B:
	dc.b	"R11B__.MMD;1", 0		; Palmtree Panic Act 1 Past
File_R11C:
	dc.b	"R11C__.MMD;1", 0		; Palmtree Panic Act 1 Good Future
File_R11D:
	dc.b	"R11D__.MMD;1", 0		; Palmtree Panic Act 1 Bad Future
File_MDInit:
	dc.b	"MDINIT.MMD;1", 0		; Mega Drive initialization
File_SoundTest:
	dc.b	"SOSEL_.MMD;1", 0		; Sound test
File_StageSelect:
	dc.b	"STSEL_.MMD;1", 0		; Stage select
File_R12A:
	dc.b	"R12A__.MMD;1", 0		; Palmtree Panic Act 2 Present
File_R12B:
	dc.b	"R12B__.MMD;1", 0		; Palmtree Panic Act 2 Past
File_R12C:
	dc.b	"R12C__.MMD;1", 0		; Palmtree Panic Act 2 Good Future
File_R12D:
	dc.b	"R12D__.MMD;1", 0		; Palmtree Panic Act 2 Bad Future
File_TitleMain:
	dc.b	"TITLEM.MMD;1", 0		; Title screen (Main CPU)
File_TitleSub:
	dc.b	"TITLES.BIN;1", 0		; Title screen (Sub CPU)
File_Warp:
	dc.b	"WARP__.MMD;1", 0		; Warp sequence
File_TimeAttackMain:
	dc.b	"ATTACK.MMD;1", 0		; Time attack (Main CPU)
File_TimeAttackSub:
	dc.b	"ATTACK.BIN;1", 0		; Time attack (Main CPU)
File_IPX:
	dc.b	"IPX___.MMD;1", 0		; Main program
File_PencilTestData:
	dc.b	"PTEST.STM;1 ", 0		; Pencil test FMV data
File_OpeningData:
	dc.b	"OPN.STM;1   ", 0		; Opening FMV data
File_BadEndData:
	dc.b	"BADEND.STM;1", 0		; Bad ending FMV data
File_GoodEndData:
	dc.b	"GOODEND.STM;1", 0		; Good ending FMV data
File_OpeningMain:
	dc.b	"OPEN_M.MMD;1", 0		; Opening FMV (Main CPU)
File_OpeningSub:
	dc.b	"OPEN_S.BIN;1", 0		; Opening FMV (Sub CPU)
File_CominSoon:
	dc.b	"COME__.MMD;1", 0		; "Comin' Soon" screen
File_DAGardenMain:
	dc.b	"PLANET_M.MMD;1", 0		; D.A. Garden (Main CPU)
File_DAGardenSub:
	dc.b	"PLANET_S.BIN;1", 0		; D.A. Garden (Sub CPU)
File_R31A:
	dc.b	"R31A__.MMD;1", 0		; Collision Chaos Act 1 Present
File_R31B:
	dc.b	"R31B__.MMD;1", 0		; Collision Chaos Act 1 Past
File_R31C:
	dc.b	"R31C__.MMD;1", 0		; Collision Chaos Act 1 Good Future
File_R31D:
	dc.b	"R31D__.MMD;1", 0		; Collision Chaos Act 1 Bad Future
File_R32A:
	dc.b	"R32A__.MMD;1", 0		; Collision Chaos Act 2 Present
File_R32B:
	dc.b	"R32B__.MMD;1", 0		; Collision Chaos Act 2 Past
File_R32C:
	dc.b	"R32C__.MMD;1", 0		; Collision Chaos Act 2 Good Future
File_R32D:
	dc.b	"R32D__.MMD;1", 0		; Collision Chaos Act 2 Bad Future
File_R33C:
	dc.b	"R33C__.MMD;1", 0		; Collision Chaos Act 3 Good Future
File_R33D:
	dc.b	"R33D__.MMD;1", 0		; Collision Chaos Act 3 Bad Future
File_R13C:
	dc.b	"R13C__.MMD;1", 0		; Palmtree Panic Act 3 Good Future
File_R13D:
	dc.b	"R13D__.MMD;1", 0		; Palmtree Panic Act 3 Bad Future
File_R41A:
	dc.b	"R41A__.MMD;1", 0		; Tidal Tempest Act 1 Present
File_R41B:
	dc.b	"R41B__.MMD;1", 0		; Tidal Tempest Act 1 Past
File_R41C:
	dc.b	"R41C__.MMD;1", 0		; Tidal Tempest Act 1 Good Future
File_R41D:
	dc.b	"R41D__.MMD;1", 0		; Tidal Tempest Act 1 Bad Future
File_R42A:
	dc.b	"R42A__.MMD;1", 0		; Tidal Tempest Act 2 Present
File_R42B:
	dc.b	"R42B__.MMD;1", 0		; Tidal Tempest Act 2 Past
File_R42C:
	dc.b	"R42C__.MMD;1", 0		; Tidal Tempest Act 2 Good Future
File_R42D:
	dc.b	"R42D__.MMD;1", 0		; Tidal Tempest Act 2 Bad Future
File_R43C:
	dc.b	"R43C__.MMD;1", 0		; Tidal Tempest Act 3 Good Future
File_R43D:
	dc.b	"R43D__.MMD;1", 0		; Tidal Tempest Act 3 Bad Future
File_R51A:
	dc.b	"R51A__.MMD;1", 0		; Quartz Quadrant Act 1 Present
File_R51B:
	dc.b	"R51B__.MMD;1", 0		; Quartz Quadrant Act 1 Past
File_R51C:
	dc.b	"R51C__.MMD;1", 0		; Quartz Quadrant Act 1 Good Future
File_R51D:
	dc.b	"R51D__.MMD;1", 0		; Quartz Quadrant Act 1 Bad Future
File_R52A:
	dc.b	"R52A__.MMD;1", 0		; Quartz Quadrant Act 2 Present
File_R52B:
	dc.b	"R52B__.MMD;1", 0		; Quartz Quadrant Act 2 Past
File_R52C:
	dc.b	"R52C__.MMD;1", 0		; Quartz Quadrant Act 2 Good Future
File_R52D:
	dc.b	"R52D__.MMD;1", 0		; Quartz Quadrant Act 2 Bad Future
File_R53C:
	dc.b	"R53C__.MMD;1", 0		; Quartz Quadrant Act 3 Good Future
File_R53D:
	dc.b	"R53D__.MMD;1", 0		; Quartz Quadrant Act 3 Bad Future
File_R61A:
	dc.b	"R61A__.MMD;1", 0		; Wacky Workbench Act 1 Present
File_R61B:
	dc.b	"R61B__.MMD;1", 0		; Wacky Workbench Act 1 Past
File_R61C:
	dc.b	"R61C__.MMD;1", 0		; Wacky Workbench Act 1 Good Future
File_R61D:
	dc.b	"R61D__.MMD;1", 0		; Wacky Workbench Act 1 Bad Future
File_R62A:
	dc.b	"R62A__.MMD;1", 0		; Wacky Workbench Act 2 Present
File_R62B:
	dc.b	"R62B__.MMD;1", 0		; Wacky Workbench Act 2 Past
File_R62C:
	dc.b	"R62C__.MMD;1", 0		; Wacky Workbench Act 2 Good Future
File_R62D:
	dc.b	"R62D__.MMD;1", 0		; Wacky Workbench Act 2 Bad Future
File_R63C:
	dc.b	"R63C__.MMD;1", 0		; Wacky Workbench Act 3 Good Future
File_R63D:
	dc.b	"R63D__.MMD;1", 0		; Wacky Workbench Act 3 Bad Future
File_R71A:
	dc.b	"R71A__.MMD;1", 0		; Stardust Speedway Act 1 Present
File_R71B:
	dc.b	"R71B__.MMD;1", 0		; Stardust Speedway Act 1 Past
File_R71C:
	dc.b	"R71C__.MMD;1", 0		; Stardust Speedway Act 1 Good Future
File_R71D:
	dc.b	"R71D__.MMD;1", 0		; Stardust Speedway Act 1 Bad Future
File_R72A:
	dc.b	"R72A__.MMD;1", 0		; Stardust Speedway Act 2 Present
File_R72B:
	dc.b	"R72B__.MMD;1", 0		; Stardust Speedway Act 2 Past
File_R72C:
	dc.b	"R72C__.MMD;1", 0		; Stardust Speedway Act 2 Good Future
File_R72D:
	dc.b	"R72D__.MMD;1", 0		; Stardust Speedway Act 2 Bad Future
File_R73C:
	dc.b	"R73C__.MMD;1", 0		; Stardust Speedway Act 3 Good Future
File_R73D:
	dc.b	"R73D__.MMD;1", 0		; Stardust Speedway Act 3 Bad Future
File_R81A:
	dc.b	"R81A__.MMD;1", 0		; Metallic Madness Act 1 Present
File_R81B:
	dc.b	"R81B__.MMD;1", 0		; Metallic Madness Act 1 Past
File_R81C:
	dc.b	"R81C__.MMD;1", 0		; Metallic Madness Act 1 Good Future
File_R81D:
	dc.b	"R81D__.MMD;1", 0		; Metallic Madness Act 1 Bad Future
File_R82A:
	dc.b	"R82A__.MMD;1", 0		; Metallic Madness Act 2 Present
File_R82B:
	dc.b	"R82B__.MMD;1", 0		; Metallic Madness Act 2 Past
File_R82C:
	dc.b	"R82C__.MMD;1", 0		; Metallic Madness Act 2 Good Future
File_R82D:
	dc.b	"R82D__.MMD;1", 0		; Metallic Madness Act 2 Bad Future
File_R83C:
	dc.b	"R83C__.MMD;1", 0		; Metallic Madness Act 3 Good Future
File_R83D:
	dc.b	"R83D__.MMD;1", 0		; Metallic Madness Act 3 Bad Future
File_SpecialMain:
	dc.b	"SPMM__.MMD;1", 0		; Special Stage (Main CPU)
File_SpecialSub:
	dc.b	"SPSS__.BIN;1", 0		; Special Stage (Sub CPU)
File_R1PCM:
	dc.b	"SNCBNK1B.BIN;1", 0		; PCM driver (Palmtree Panic)
File_R3PCM:
	dc.b	"SNCBNK3B.BIN;1", 0		; PCM driver (Collision Chaos)
File_R4PCM:
	dc.b	"SNCBNK4B.BIN;1", 0		; PCM driver (Tidal Tempest)
File_R5PCM:
	dc.b	"SNCBNK5B.BIN;1", 0		; PCM driver (Quartz Quadrant)
File_R6PCM:
	dc.b	"SNCBNK6B.BIN;1", 0		; PCM driver (Wacky Workbench)
File_R7PCM:
	dc.b	"SNCBNK7B.BIN;1", 0		; PCM driver (Stardust Speedway)
File_R8PCM:
	dc.b	"SNCBNK8B.BIN;1", 0		; PCM driver (Metallic Madness)
File_BossPCM:
	dc.b	"SNCBNKB1.BIN;1", 0		; PCM driver (Boss)
File_FinalPCM:
	dc.b	"SNCBNKB2.BIN;1", 0		; PCM driver (Final boss)
File_DAGardenData:
	dc.b	"PLANET_D.BIN;1", 0		; D.A Garden track title data
File_Demo11A:
	dc.b	"DEMO11A.MMD;1", 0		; Palmtree Panic Act 1 Present demo
File_VisualMode:
	dc.b	"VM____.MMD;1", 0		; Visual Mode
File_BuRAMInit:
	dc.b	"BRAMINIT.MMD;1", 0		; Backup RAM initialization
File_BuRAMSub:
	dc.b	"BRAMSUB.BIN;1", 0		; Backup RAM functions
File_BuRAMMain:
	dc.b	"BRAMMAIN.MMD;1", 0		; Backup RAM manager
File_ThanksMain:
	dc.b	"THANKS_M.MMD;1", 0		; "Thank You" screen (Main CPU)
File_ThanksSub:
	dc.b	"THANKS_S.BIN;1", 0		; "Thank You" screen (Sub CPU)
File_ThanksData:
	dc.b	"THANKS_D.BIN;1", 0		; "Thank You" screen data
File_EndingMain:
	dc.b	"ENDING.MMD;1", 0		; Ending FMV (Main CPU)
File_BadEndSub:
	dc.b	"GOODEND.BIN;1", 0 		; Bad ending FMV (Sub CPU, not a typo)
File_GoodEndSub:
	dc.b	"BADEND.BIN;1", 0 		; Good ending FMV (Sub CPU, not a typo)
File_FunIsInf:
	dc.b	"NISI.MMD;1", 0			; "Fun is infinite" screen
File_SS8Credits:
	dc.b	"SPEEND.MMD;1", 0		; Special stage 8 credits
File_MCSonic:
	dc.b	"DUMMY0.MMD;1", 0		; M.C. Sonic screen
File_Tails:
	dc.b	"DUMMY1.MMD;1", 0		; Tails screen
File_BatmanSonic:
	dc.b	"DUMMY2.MMD;1", 0		; Batman Sonic screen
File_CuteSonic:
	dc.b	"DUMMY3.MMD;1", 0		; Cute Sonic screen
File_StaffTimes:
	dc.b	"DUMMY4.MMD;1", 0		; Best staff times screen
File_Dummy5:
	dc.b	"DUMMY5.MMD;1", 0		; Copy of prototype sound test (Unused)
File_Dummy6:
	dc.b	"DUMMY6.MMD;1", 0		; Copy of prototype sound test (Unused)
File_Dummy7:
	dc.b	"DUMMY7.MMD;1", 0		; Copy of prototype sound test (Unused)
File_Dummy8:
	dc.b	"DUMMY8.MMD;1", 0		; Copy of prototype sound test (Unused)
File_Dummy9:
	dc.b	"DUMMY9.MMD;1", 0		; Copy of prototype sound test (Unused)
File_PencilTestMain:
	dc.b	"PTEST.MMD;1", 0		; Pencil test FMV (Main CPU)
File_PencilTestSub:
	dc.b	"PTEST.BIN;1", 0		; Pencil test FMV (Sub CPU)
File_Demo43C:
	dc.b	"DEMO43C.MMD;1", 0		; Tidal Tempest Act 3 Good Future demo
File_Demo82A:
	dc.b	"DEMO82A.MMD;1", 0		; Metallic Madness Act 2 Present demo
	even

; -------------------------------------------------------------------------
; Backup RAM read parameters
; -------------------------------------------------------------------------

BuRAMReadParams:
	dc.b	"SONICCD____"
	even

; -------------------------------------------------------------------------
; Backup RAM write parameters
; -------------------------------------------------------------------------

BuRAMWriteParams:
	dc.b	"SONICCD____"
	dc.b	0
	dc.w	$B

; -------------------------------------------------------------------------
; System program extension start
; -------------------------------------------------------------------------

	ALIGN	SPXStart
	lea	SPVariables.w,a0		; Clear parameters
	move.w	#SPVARSSZ/4-1,d7

.ClearVars:
	move.l	#0,(a0)+
	dbf	d7,.ClearVars

	bclr	#3,GAIRQMASK.w			; Disable timer interrupt
	move.l	#RunPCMDriver,_LEVEL3+2.w	; Set timer interrupt address
	move.b	#255,GAIRQ3TIME.w		; Set timer interrupt interval

.WaitCommand:
	move.w	GACOMCMD0.w,d0			; Get command ID from Main CPU
	beq.s	.WaitCommand
	cmp.w	GACOMCMD0.w,d0
	bne.s	.WaitCommand
	cmpi.w	#(.SPCmdsEnd-.SPCmds)/2+1,d0	; Note: that "+1" shouldn't be there
	bcc.w	SPCmdFinish			; If it's an invalid ID, branch

	move.w	d0,d1				; Execute command
	add.w	d0,d0
	move.w	.SPCmds(pc,d0.w),d0
	jsr	.SPCmds(pc,d0.w)

	move.l	#SPIRQ2,_USERCALL2+2.w		; Restore IRQ2 address
	bclr	#1,GAIRQMASK.w			; Disable level 1 interrupt
	move.l	#IRQ1Null,_LEVEL1+2.w		; Reset level 1 interrupt address

	bra.s	.WaitCommand			; Loop

; -------------------------------------------------------------------------

.SPCmds:
	dc.w	0				; Invalid
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Palmtree Panic Act 1 Present
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Palmtree Panic Act 1 Past
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Palmtree Panic Act 1 Good Future
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Palmtree Panic Act 1 Bad Future
	dc.w	SPCmd_LoadMDInit-.SPCmds	; Load Mega Drive initialization
	dc.w	SPCmd_LoadStageSel-.SPCmds	; Load stage select
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Palmtree Panic Act 2 Present
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Palmtree Panic Act 2 Past
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Palmtree Panic Act 2 Good Future
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Palmtree Panic Act 2 Bad Future
	dc.w	SPCmd_LoadTitle-.SPCmds		; Load title screen
	dc.w	SPCmd_LoadWarp-.SPCmds		; Load warp sequence
	dc.w	SPCmd_LoadTimeAttack-.SPCmds	; Load time attack menu
	dc.w	SPCmd_FadeOutCDDA-.SPCmds	; Fade out CDDA music
	dc.w	SPCmd_PlayR1AMus-.SPCmds	; Play Palmtree Panic Present music
	dc.w	SPCmd_PlayR1CMus-.SPCmds	; Play Palmtree Panic Good Future music
	dc.w	SPCmd_PlayR1DMus-.SPCmds	; Play Palmtree Panic Bad Future music
	dc.w	SPCmd_PlayR3AMus-.SPCmds	; Play Collision Chaos Present music
	dc.w	SPCmd_PlayR3CMus-.SPCmds	; Play Collision Chaos Good Future music
	dc.w	SPCmd_PlayR3DMus-.SPCmds	; Play Collision Chaos Bad Future music
	dc.w	SPCmd_PlayR4AMus-.SPCmds	; Play Tidal Tempest Present music
	dc.w	SPCmd_PlayR4CMus-.SPCmds	; Play Tidal Tempest Good Future music
	dc.w	SPCmd_PlayR4DMus-.SPCmds	; Play Tidal Tempest Bad Future music
	dc.w	SPCmd_PlayR5AMus-.SPCmds	; Play Quartz Quadrant Present music
	dc.w	SPCmd_PlayR5CMus-.SPCmds	; Play Quartz Quadrant Good Future music
	dc.w	SPCmd_PlayR5DMus-.SPCmds	; Play Quartz Quadrant Bad Future music
	dc.w	SPCmd_PlayR6AMus-.SPCmds	; Play Wacky Workbench Present music
	dc.w	SPCmd_PlayR6CMus-.SPCmds	; Play Wacky Workbench Good Future music
	dc.w	SPCmd_PlayR6DMus-.SPCmds	; Play Wacky Workbench Bad Future music
	dc.w	SPCmd_PlayR7AMus-.SPCmds	; Play Stardust Speedway Present music
	dc.w	SPCmd_PlayR7CMus-.SPCmds	; Play Stardust Speedway Good Future music
	dc.w	SPCmd_PlayR7DMus-.SPCmds	; Play Stardust Speedway Bad Future music
	dc.w	SPCmd_PlayR8AMus-.SPCmds	; Play Metallic Madness Present music
	dc.w	SPCmd_PlayR8CMus-.SPCmds	; Play Metallic Madness Good Future music
	dc.w	SPCmd_LoadIPX-.SPCmds		; Load main program
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Tidal Tempest Act 3 Good Future demo
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Metallic Madness Act 2 Present demo
	dc.w	SPCmd_LoadSndTest-.SPCmds	; Load sound test
	dc.w	SPCmd_LoadLevel-.SPCmds		; Invalid
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Collision Chaos Act 1 Present
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Collision Chaos Act 1 Past
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Collision Chaos Act 1 Good Future
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Collision Chaos Act 1 Bad Future
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Collision Chaos Act 2 Present 
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Collision Chaos Act 2 Past 
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Collision Chaos Act 2 Good Future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Collision Chaos Act 2 Bad Future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Collision Chaos Act 3 Good Future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Collision Chaos Act 3 Bad Future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Palmtree Panic Act 3 Good Future
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Palmtree Panic Act 3 Bad Future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Tidal Tempest Act 1 Present
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Tidal Tempest Act 1 Past
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Tidal Tempest Act 1 Good Future
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Tidal Tempest Act 1 Bad Future
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Tidal Tempest Act 2 Present 
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Tidal Tempest Act 2 Past 
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Tidal Tempest Act 2 Good Future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Tidal Tempest Act 2 Bad Future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Tidal Tempest Act 3 Good Future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Tidal Tempest Act 3 Bad Future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Quartz Quadrant Act 1 Present
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Quartz Quadrant Act 1 Past
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Quartz Quadrant Act 1 Good Future
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Quartz Quadrant Act 1 Bad Future
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Quartz Quadrant Act 2 Present 
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Quartz Quadrant Act 2 Past 
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Quartz Quadrant Act 2 Good Future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Quartz Quadrant Act 2 Bad Future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Quartz Quadrant Act 3 Good Future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Quartz Quadrant Act 3 Bad Future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Wacky Workbench Act 1 Present
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Wacky Workbench Act 1 Past
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Wacky Workbench Act 1 Good Future
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Wacky Workbench Act 1 Bad Future
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Wacky Workbench Act 2 Present 
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Wacky Workbench Act 2 Past 
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Wacky Workbench Act 2 Good Future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Wacky Workbench Act 2 Bad Future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Wacky Workbench Act 3 Good Future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Wacky Workbench Act 3 Bad Future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Stardust Speedway Act 1 Present
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Stardust Speedway Act 1 Past
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Stardust Speedway Act 1 Good Future
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Stardust Speedway Act 1 Bad Future
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Stardust Speedway Act 2 Present 
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Stardust Speedway Act 2 Past 
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Stardust Speedway Act 2 Good Future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Stardust Speedway Act 2 Bad Future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Stardust Speedway Act 3 Good Future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Stardust Speedway Act 3 Bad Future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Metallic Madness Act 1 Present
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Metallic Madness Act 1 Past
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Metallic Madness Act 1 Good Future
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Metallic Madness Act 1 Bad Future
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Metallic Madness Act 2 Present 
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Metallic Madness Act 2 Past 
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Metallic Madness Act 2 Good Future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Metallic Madness Act 2 Bad Future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Metallic Madness Act 3 Good Future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Metallic Madness Act 3 Bad Future 
	dc.w	SPCmd_PlayR8DMus-.SPCmds	; Play Metallic Madness Bad Future music
	dc.w	SPCmd_PlayBossMus-.SPCmds	; Play boss music
	dc.w	SPCmd_PlayFinalMus-.SPCmds	; Play final boss music
	dc.w	SPCmd_PlayTitleMus-.SPCmds	; Play title screen music
	dc.w	SPCmd_PlayTimeAtkMus-.SPCmds	; Play time attack menu music
	dc.w	SPCmd_PlayResultsMus-.SPCmds	; Play results music
	dc.w	SPCmd_PlayShoesMus-.SPCmds	; Play speed shoes music
	dc.w	SPCmd_PlayInvincMus-.SPCmds	; Play invincibility music
	dc.w	SPCmd_PlayGameOverMus-.SPCmds	; Play game over music
	dc.w	SPCmd_PlaySpecStgMus-.SPCmds	; Play special stage music
	dc.w	SPCmd_PlayDAGardenMus-.SPCmds	; Play D.A. Garden music
	dc.w	SPCmd_PlayProtoWarp-.SPCmds	; Play prototype warp sound
	dc.w	SPCmd_PlayOpeningMus-.SPCmds	; Play opening music
	dc.w	SPCmd_PlayEndingMus-.SPCmds	; Play ending music
	dc.w	SPCmd_StopCDDA-.SPCmds		; Stop CDDA music
	dc.w	SPCmd_LoadSpecStage-.SPCmds	; Load special stage
	dc.w	SPCmd_PlayFutureSFX-.SPCmds	; Play "Future" voice clip
	dc.w	SPCmd_PlayPastSFX-.SPCmds	; Play "Past" voice clip
	dc.w	SPCmd_PlayAlrightSFX-.SPCmds	; Play "Alright" voice clip
	dc.w	SPCmd_PlayGiveUpSFX-.SPCmds	; Play "I'm outta here" voice clip
	dc.w	SPCmd_PlayYesSFX-.SPCmds	; Play "Yes" voice clip
	dc.w	SPCmd_PlayYeahSFX-.SPCmds	; Play "Yeah" voice clip
	dc.w	SPCmd_PlayGiggleSFX-.SPCmds	; Play Amy giggle voice clip
	dc.w	SPCmd_PlayAmyYelpSFX-.SPCmds	; Play Amy yelp voice clip
	dc.w	SPCmd_PlayStompSFX-.SPCmds	; Play mech stomp sound
	dc.w	SPCmd_PlayBumperSFX-.SPCmds	; Play bumper sound
	dc.w	SPCmd_PlayPastMus-.SPCmds	; Play past music
	dc.w	SPCmd_LoadDAGarden-.SPCmds	; Load D.A. Garden
	dc.w	SPCmd_FadeOutPCM-.SPCmds	; Fade out PCM
	dc.w	SPCmd_StopPCM-.SPCmds		; Stop PCM
	dc.w	SPCmd_LoadLevel-.SPCmds		; Load Palmtree Panic Act 1 Present demo
	dc.w	SPCmd_LoadVisualMode-.SPCmds	; Load Visual Mode menu
	dc.w	SPCmd_ResetSSFlags2-.SPCmds	; Reset special stage flags
	dc.w	SPCmd_ReadSaveData-.SPCmds	; Read save data
	dc.w	SPCmd_WriteSaveData-.SPCmds	; Write save data
	dc.w	SPCmd_LoadBuRAMInit-.SPCmds	; Load Backup RAM initialization
	dc.w	SPCmd_ResetSSFlags-.SPCmds	; Reset special stage flags
	dc.w	SPCmd_ReadTempSaveData-.SPCmds	; Read temporary save data
	dc.w	SPCmd_WriteTempSaveData-.SPCmds	; Write temporary save data
	dc.w	SPCmd_LoadThankYou-.SPCmds	; Load "Thank You" screen
	dc.w	SPCmd_LoadBuRAMMngr-.SPCmds	; Load Backup RAM manager
	dc.w	SPCmd_ResetCDDAVol-.SPCmds	; Reset CDDA music volume
	dc.w	SPCmd_PausePCM-.SPCmds		; Pause PCM
	dc.w	SPCmd_UnpausePCM-.SPCmds	; Unpause PCM
	dc.w	SPCmd_PlayBreakSFX-.SPCmds	; Play glass break sound
	dc.w	SPCmd_LoadBadEnd-.SPCmds	; Load bad ending FMV
	dc.w	SPCmd_LoadGoodEnd-.SPCmds	; Load good ending FMV
	dc.w	SPCmd_TestR1AMus-.SPCmds	; Play Palmtree Panic Present music (sound test)
	dc.w	SPCmd_TestR1CMus-.SPCmds	; Play Palmtree Panic Good Future music (sound test)
	dc.w	SPCmd_TestR1DMus-.SPCmds	; Play Palmtree Panic Bad Future music (sound test)
	dc.w	SPCmd_TestR3AMus-.SPCmds	; Play Collision Chaos Present music (sound test)
	dc.w	SPCmd_TestR3CMus-.SPCmds	; Play Collision Chaos Good Future music (sound test)
	dc.w	SPCmd_TestR3DMus-.SPCmds	; Play Collision Chaos Bad Future music (sound test)
	dc.w	SPCmd_TestR4AMus-.SPCmds	; Play Tidal Tempest Present music (sound test)
	dc.w	SPCmd_TestR4CMus-.SPCmds	; Play Tidal Tempest Good Future music (sound test)
	dc.w	SPCmd_TestR4DMus-.SPCmds	; Play Tidal Tempest Bad Future music (sound test)
	dc.w	SPCmd_TestR5AMus-.SPCmds	; Play Quartz Quadrant Present music (sound test)
	dc.w	SPCmd_TestR5CMus-.SPCmds	; Play Quartz Quadrant Good Future music (sound test)
	dc.w	SPCmd_TestR5DMus-.SPCmds	; Play Quartz Quadrant Bad Future music (sound test)
	dc.w	SPCmd_TestR6AMus-.SPCmds	; Play Wacky Workbench Present music (sound test)
	dc.w	SPCmd_TestR6CMus-.SPCmds	; Play Wacky Workbench Good Future music (sound test)
	dc.w	SPCmd_TestR6DMus-.SPCmds	; Play Wacky Workbench Bad Future music (sound test)
	dc.w	SPCmd_TestR7AMus-.SPCmds	; Play Stardust Speedway Present music (sound test)
	dc.w	SPCmd_TestR7CMus-.SPCmds	; Play Stardust Speedway Good Future music (sound test)
	dc.w	SPCmd_TestR7DMus-.SPCmds	; Play Stardust Speedway Bad Future music (sound test)
	dc.w	SPCmd_TestR8AMus-.SPCmds	; Play Metallic Madness Present music (sound test)
	dc.w	SPCmd_TestR8CMus-.SPCmds	; Play Metallic Madness Good Future music (sound test)
	dc.w	SPCmd_TestR8DMus-.SPCmds	; Play Metallic Madness Bad Future music (sound test)
	dc.w	SPCmd_TestBossMus-.SPCmds	; Play boss music (sound test)
	dc.w	SPCmd_TestFinalMus-.SPCmds	; Play final boss music (sound test)
	dc.w	SPCmd_TestTitleMus-.SPCmds	; Play title screen music (sound test)
	dc.w	SPCmd_TestTimeAtkMus-.SPCmds	; Play time attack music (sound test)
	dc.w	SPCmd_TestResultsMus-.SPCmds	; Play results music (sound test)
	dc.w	SPCmd_TestShoesMus-.SPCmds	; Play speed shoes music (sound test)
	dc.w	SPCmd_TestInvincMus-.SPCmds	; Play invincibility music (sound test)
	dc.w	SPCmd_TestGameOverMus-.SPCmds	; Play game over music (sound test)
	dc.w	SPCmd_TestSpecialMus-.SPCmds	; Play special stage music (sound test)
	dc.w	SPCmd_TestDAGardenMus-.SPCmds	; Play D.A. Garden music (sound test)
	dc.w	SPCmd_TestProtoWarp-.SPCmds	; Play prototype warp sound (sound test)
	dc.w	SPCmd_TestIntroMus-.SPCmds	; Play opening music (sound test)
	dc.w	SPCmd_TestEndingMus-.SPCmds	; Play ending music (sound test)
	dc.w	SPCmd_TestFutureSFX-.SPCmds	; Play "Future" voice clip (sound test)
	dc.w	SPCmd_TestPastSFX-.SPCmds	; Play "Past" voice clip (sound test)
	dc.w	SPCmd_TestAlrightSFX-.SPCmds	; Play "Alright" voice clip (sound test)
	dc.w	SPCmd_TestGiveUpSFX-.SPCmds	; Play "I'm outta here" voice clip (sound test)
	dc.w	SPCmd_TestYesSFX-.SPCmds	; Play "Yes" voice clip (sound test)
	dc.w	SPCmd_TestYeahSFX-.SPCmds	; Play "Yeah" voice clip (sound test)
	dc.w	SPCmd_TestGiggleSFX-.SPCmds	; Play Amy giggle voice clip (sound test)
	dc.w	SPCmd_TestAmyYelpSFX-.SPCmds	; Play Amy yelp voice clip (sound test)
	dc.w	SPCmd_TestStompSFX-.SPCmds	; Play mech stomp sound (sound test)
	dc.w	SPCmd_TestBumperSFX-.SPCmds	; Play bumper sound (sound test)
	dc.w	SPCmd_TestR1BMus-.SPCmds	; Play Palmtree Panic Past music (sound test)
	dc.w	SPCmd_TestR3BMus-.SPCmds	; Play Collision Chaos Past music (sound test)
	dc.w	SPCmd_TestR4BMus-.SPCmds	; Play Tidal Tempest Past music (sound test)
	dc.w	SPCmd_TestR5BMus-.SPCmds	; Play Quartz Quadrant Past music (sound test)
	dc.w	SPCmd_TestR6BMus-.SPCmds	; Play Palmtree Panic Past music (sound test)
	dc.w	SPCmd_TestR7BMus-.SPCmds	; Play Palmtree Panic Past music (sound test)
	dc.w	SPCmd_TestR8BMus-.SPCmds	; Play Palmtree Panic Past music (sound test)
	dc.w	SPCmd_LoadFunIsInf-.SPCmds	; Load "Fun is infinite" screen
	dc.w	SPCmd_LoadSS8Credits-.SPCmds	; Load special stage 8 credits
	dc.w	SPCmd_LoadMCSonic-.SPCmds	; Load M.C. Sonic screen
	dc.w	SPCmd_LoadTails-.SPCmds		; Load Tails screen
	dc.w	SPCmd_LoadBatmanSonic-.SPCmds	; Load Batman Sonic screen
	dc.w	SPCmd_LoadCuteSonic-.SPCmds	; Load cute Sonic screen
	dc.w	SPCmd_LoadStaffTimes-.SPCmds	; Load best staff times screen
	dc.w	SPCmd_LoadDummyFile1-.SPCmds	; Load dummy file (unused)
	dc.w	SPCmd_LoadDummyFile2-.SPCmds	; Load dummy file (unused)
	dc.w	SPCmd_LoadDummyFile3-.SPCmds	; Load dummy file (unused)
	dc.w	SPCmd_LoadDummyFile4-.SPCmds	; Load dummy file (unused)
	dc.w	SPCmd_LoadDummyFile5-.SPCmds	; Load dummy file (unused)
	dc.w	SPCmd_LoadPencilTest-.SPCmds	; Load pencil test FMV
	dc.w	SPCmd_PauseCDDA-.SPCmds		; Pause CDDA music
	dc.w	SPCmd_UnpauseCDDA-.SPCmds	; Unpause CDDA music
	dc.w	SPCmd_LoadOpening-.SPCmds	; Load opening FMV
	dc.w	SPCmd_LoadCominSoon-.SPCmds	; Load "Comin' Soon" screen
.SPCmdsEnd:

; -------------------------------------------------------------------------
; Load pencil test FMV
; -------------------------------------------------------------------------

SPCmd_LoadPencilTest:
	bclr	#3,GAIRQMASK.w			; Disable timer interrupt

	lea	File_PencilTestMain(pc),a0	; Load Main CPU file
	bsr.w	WaitWordRAMAccess
	lea	WORDRAM2M,a1
	jsr	LoadFile.w
	bsr.w	GiveWordRAMAccess

	lea	File_PencilTestSub(pc),a0	; Load Sub CPU file
	lea	PRGRAM+$30000,a1
	jsr	LoadFile.w

	jsr	PRGRAM+$30000			; Run Sub CPU file code

	move.l	#SPIRQ2,_USERCALL2+2.w		; Restore IRQ2
	andi.b	#$FA,GAMEMMODE.w		; Set to 2M mode
	move.b	#3,GACDCDEVICE.w		; Set CDC device to "Sub CPU"
	move.l	#0,curPCMDriver.w		; Reset current PCM driver
	rts

; -------------------------------------------------------------------------
; Load Backup RAM manager
; -------------------------------------------------------------------------

SPCmd_LoadBuRAMMngr:
	lea	File_BuRAMMain(pc),a0		; Load Main CPU file
	bsr.w	WaitWordRAMAccess
	lea	WORDRAM2M,a1
	jsr	LoadFile.w
	bsr.w	GiveWordRAMAccess

	lea	File_BuRAMSub(pc),a0		; Load Sub CPU file
	lea	PRGRAM+$10000,a1
	jsr	LoadFile.w

	jsr	PRGRAM+$10000			; Run Sub CPU file code

	move.l	#SPIRQ2,_USERCALL2+2.w		; Restore IRQ2
	rts

; -------------------------------------------------------------------------
; Load "Thank You" screen
; -------------------------------------------------------------------------

SPCmd_LoadThankYou:
	bsr.w	WaitWordRAMAccess		; Load Main CPU file
	lea	File_ThanksMain(pc),a0
	lea	WORDRAM2M,a1
	jsr	LoadFile.w

	lea	File_ThanksData(pc),a0		; Load data file
	lea	WORDRAM2M+$10000,a1
	jsr	LoadFile.w
	bsr.w	GiveWordRAMAccess

	lea	File_ThanksSub(pc),a0		; Load Sub CPU file
	lea	PRGRAM+$10000,a1
	jsr	LoadFile.w

	jsr	PRGRAM+$10000			; Run Sub CPU file code

	move.l	#SPIRQ2,_USERCALL2+2.w		; Restore IRQ2
	rts

; -------------------------------------------------------------------------
; Reset special stage flags
; -------------------------------------------------------------------------

SPCmd_ResetSSFlags:
	moveq	#0,d0
	move.b	d0,timeStonesSub.w		; Reset time stones retrieved
	move.b	d0,specStageID.w		; Reset stage ID
	move.l	d0,specStageTimer.w		; Reset timer
	move.w	d0,specStageRings.w		; Reset rings
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Reset special stage flags
; -------------------------------------------------------------------------

SPCmd_ResetSSFlags2:
	moveq	#0,d0
	move.b	d0,timeStonesSub.w		; Reset time stones retrieved
	move.b	d0,specStageID.w		; Reset stage ID
	move.l	d0,specStageTimer.w		; Reset timer
	move.w	d0,specStageRings.w		; Reset rings
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Load Backup RAM initialization
; -------------------------------------------------------------------------

SPCmd_LoadBuRAMInit:
	lea	File_BuRAMInit(pc),a0		; Load Main CPU file
	bsr.w	WaitWordRAMAccess
	lea	WORDRAM2M,a1
	jsr	LoadFile.w
	bsr.w	GiveWordRAMAccess

	lea	File_BuRAMSub(pc),a0		; Load Sub CPU file
	lea	PRGRAM+$10000,a1
	jsr	LoadFile.w

	jsr	PRGRAM+$10000			; Run Sub CPU file code

	move.l	#SPIRQ2,_USERCALL2+2.w		; Restore IRQ2
	rts

; -------------------------------------------------------------------------
; Read save data
; -------------------------------------------------------------------------

SPCmd_ReadSaveData:
	lea	BuRAMScratch(pc),a0		; Initialize Backup RAM interaction
	lea	BuRAMStrings(pc),a1
	move.w	#BRMINIT,d0
	jsr	_BURAM.w

.ReadData:
	bsr.w	WaitWordRAMAccess		; Wait for Word RAM access

	lea	BuRAMReadParams(pc),a0		; Load save data
	lea	WORDRAM2M,a1
	move.w	#BRMREAD,d0
	jsr	_BURAM.w
	bcs.s	.ReadData			; If it failed, try again

	bra.w	GiveWordRAMAccess		; Give Main CPU Word RAM access

; -------------------------------------------------------------------------
; Write save data
; -------------------------------------------------------------------------

SPCmd_WriteSaveData:
	lea	BuRAMScratch(pc),a0		; Initialize Backup RAM interaction
	lea	BuRAMStrings(pc),a1
	move.w	#BRMINIT,d0
	jsr	_BURAM.w

.WriteData:
	bsr.w	WaitWordRAMAccess		; Wait for Word RAM access

	lea	BuRAMWriteParams(pc),a0		; Write save data
	lea	WORDRAM2M,a1
	move.w	#BRMWRITE,d0
	moveq	#0,d1
	jsr	_BURAM.w
	bcs.s	.WriteData			; If it failed, try again
	
	bra.w	GiveWordRAMAccess		; Give Main CPU Word RAM access

; -------------------------------------------------------------------------
; Read temporary save data
; -------------------------------------------------------------------------

SPCmd_ReadTempSaveData:
	bsr.w	WaitWordRAMAccess		; Wait for Word RAM access

	lea	SaveDataTemp.w,a0		; Copy from temporary save data buffer
	lea	WORDRAM2M,a1
	move.w	#BURAMDATASZ/4-1,d7

.Read:
	move.l	(a0)+,(a1)+
	dbf	d7,.Read

	bra.w	GiveWordRAMAccess		; Give Main CPU Word RAM access

; -------------------------------------------------------------------------
; Write temporary save data
; -------------------------------------------------------------------------

SPCmd_WriteTempSaveData:
	bsr.w	WaitWordRAMAccess		; Wait for Word RAM access

	lea	SaveDataTemp.w,a0		; Copy to temporary save data buffer
	lea	WORDRAM2M,a1
	move.w	#BURAMDATASZ/4-1,d7

.Write:
	move.l	(a1)+,(a0)+
	dbf	d7,.Write

	bra.w	GiveWordRAMAccess		; Give Main CPU Word RAM access

; -------------------------------------------------------------------------
; Load level
; -------------------------------------------------------------------------

SPCmd_LoadLevel:
	add.w	d1,d1				; Get level file based on command ID
	lea	.LevelFiles(pc),a1
	move.w	(a1,d1.w),d2
	lea	(a1,d2.w),a0
	move.l	d1,-(sp)

	bsr.w	WaitWordRAMAccess		; Load level file
	lea	WORDRAM2M,a1
	jsr	LoadFile.w

	bsr.w	ResetCDDAVol			; Reset CDDA music volume
	bclr	#3,GAIRQMASK.w			; Disable timer interrupt

	move.l	(sp)+,d1			; Get PCM driver file based on command ID
	add.w	d1,d1
	lea	.PCMDrivers(pc),a1
	move.l	curPCMDriver.w,d0
	cmp.l	(a1,d1.w),d0			; Is this PCM driver already loaded?
	beq.s	.Done				; If so, branch

	movea.l	(a1,d1.w),a0			; If not, load it
	move.l	a0,curPCMDriver.w
	lea	PCMDriver,a1
	jsr	LoadFile.w

.Done:
	bset	#3,GAIRQMASK.w			; Enable timer interrupt
	bra.w	GiveWordRAMAccess		; Give Main CPU Word RAM access

; -------------------------------------------------------------------------
; Level files
; -------------------------------------------------------------------------

.LevelFiles:
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Palmtree Panic Act 1 Present
	dc.w	File_R11B-.LevelFiles		; Palmtree Panic Act 1 Past
	dc.w	File_R11C-.LevelFiles		; Palmtree Panic Act 1 Good Future
	dc.w	File_R11D-.LevelFiles		; Palmtree Panic Act 1 Bad Future
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R12A-.LevelFiles		; Palmtree Panic Act 2 Present
	dc.w	File_R12B-.LevelFiles		; Palmtree Panic Act 2 Past
	dc.w	File_R12C-.LevelFiles		; Palmtree Panic Act 2 Good Future
	dc.w	File_R12D-.LevelFiles		; Palmtree Panic Act 2 Bad Future
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_Demo43C-.LevelFiles	; Tidal Tempest Act 3 Good Future demo
	dc.w	File_Demo82A-.LevelFiles	; Metallic Madness Act 2 Present demo
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R31A-.LevelFiles		; Collision Chaos Act 1 Present
	dc.w	File_R31B-.LevelFiles		; Collision Chaos Act 1 Past
	dc.w	File_R31C-.LevelFiles		; Collision Chaos Act 1 Good Future
	dc.w	File_R31D-.LevelFiles		; Collision Chaos Act 1 Bad Future
	dc.w	File_R32A-.LevelFiles		; Collision Chaos Act 2 Present 
	dc.w	File_R32B-.LevelFiles		; Collision Chaos Act 2 Past 
	dc.w	File_R32C-.LevelFiles		; Collision Chaos Act 2 Good Future 
	dc.w	File_R32D-.LevelFiles		; Collision Chaos Act 2 Bad Future 
	dc.w	File_R33C-.LevelFiles		; Collision Chaos Act 3 Good Future 
	dc.w	File_R33D-.LevelFiles		; Collision Chaos Act 3 Bad Future 
	dc.w	File_R13C-.LevelFiles		; Palmtree Panic Act 3 Good Future
	dc.w	File_R13D-.LevelFiles		; Palmtree Panic Act 3 Bad Future 
	dc.w	File_R41A-.LevelFiles		; Tidal Tempest Act 1 Present
	dc.w	File_R41B-.LevelFiles		; Tidal Tempest Act 1 Past
	dc.w	File_R41C-.LevelFiles		; Tidal Tempest Act 1 Good Future
	dc.w	File_R41D-.LevelFiles		; Tidal Tempest Act 1 Bad Future
	dc.w	File_R42A-.LevelFiles		; Tidal Tempest Act 2 Present 
	dc.w	File_R42B-.LevelFiles		; Tidal Tempest Act 2 Past 
	dc.w	File_R42C-.LevelFiles		; Tidal Tempest Act 2 Good Future 
	dc.w	File_R42D-.LevelFiles		; Tidal Tempest Act 2 Bad Future 
	dc.w	File_R43C-.LevelFiles		; Tidal Tempest Act 3 Good Future 
	dc.w	File_R43D-.LevelFiles		; Tidal Tempest Act 3 Bad Future 
	dc.w	File_R51A-.LevelFiles		; Quartz Quadrant Act 1 Present
	dc.w	File_R51B-.LevelFiles		; Quartz Quadrant Act 1 Past
	dc.w	File_R51C-.LevelFiles		; Quartz Quadrant Act 1 Good Future
	dc.w	File_R51D-.LevelFiles		; Quartz Quadrant Act 1 Bad Future
	dc.w	File_R52A-.LevelFiles		; Quartz Quadrant Act 2 Present 
	dc.w	File_R52B-.LevelFiles		; Quartz Quadrant Act 2 Past 
	dc.w	File_R52C-.LevelFiles		; Quartz Quadrant Act 2 Good Future 
	dc.w	File_R52D-.LevelFiles		; Quartz Quadrant Act 2 Bad Future 
	dc.w	File_R53C-.LevelFiles		; Quartz Quadrant Act 3 Good Future 
	dc.w	File_R53D-.LevelFiles		; Quartz Quadrant Act 3 Bad Future 
	dc.w	File_R61A-.LevelFiles		; Wacky Workbench Act 1 Present
	dc.w	File_R61B-.LevelFiles		; Wacky Workbench Act 1 Past
	dc.w	File_R61C-.LevelFiles		; Wacky Workbench Act 1 Good Future
	dc.w	File_R61D-.LevelFiles		; Wacky Workbench Act 1 Bad Future
	dc.w	File_R62A-.LevelFiles		; Wacky Workbench Act 2 Present 
	dc.w	File_R62B-.LevelFiles		; Wacky Workbench Act 2 Past 
	dc.w	File_R62C-.LevelFiles		; Wacky Workbench Act 2 Good Future 
	dc.w	File_R62D-.LevelFiles		; Wacky Workbench Act 2 Bad Future 
	dc.w	File_R63C-.LevelFiles		; Wacky Workbench Act 3 Good Future 
	dc.w	File_R63D-.LevelFiles		; Wacky Workbench Act 3 Bad Future 
	dc.w	File_R71A-.LevelFiles		; Stardust Speedway Act 1 Present
	dc.w	File_R71B-.LevelFiles		; Stardust Speedway Act 1 Past
	dc.w	File_R71C-.LevelFiles		; Stardust Speedway Act 1 Good Future
	dc.w	File_R71D-.LevelFiles		; Stardust Speedway Act 1 Bad Future
	dc.w	File_R72A-.LevelFiles		; Stardust Speedway Act 2 Present 
	dc.w	File_R72B-.LevelFiles		; Stardust Speedway Act 2 Past 
	dc.w	File_R72C-.LevelFiles		; Stardust Speedway Act 2 Good Future 
	dc.w	File_R72D-.LevelFiles		; Stardust Speedway Act 2 Bad Future 
	dc.w	File_R73C-.LevelFiles		; Stardust Speedway Act 3 Good Future 
	dc.w	File_R73D-.LevelFiles		; Stardust Speedway Act 3 Bad Future 
	dc.w	File_R81A-.LevelFiles		; Metallic Madness Act 1 Present
	dc.w	File_R81B-.LevelFiles		; Metallic Madness Act 1 Past
	dc.w	File_R81C-.LevelFiles		; Metallic Madness Act 1 Good Future
	dc.w	File_R81D-.LevelFiles		; Metallic Madness Act 1 Bad Future
	dc.w	File_R82A-.LevelFiles		; Metallic Madness Act 2 Present 
	dc.w	File_R82B-.LevelFiles		; Metallic Madness Act 2 Past 
	dc.w	File_R82C-.LevelFiles		; Metallic Madness Act 2 Good Future 
	dc.w	File_R82D-.LevelFiles		; Metallic Madness Act 2 Bad Future 
	dc.w	File_R83C-.LevelFiles		; Metallic Madness Act 3 Good Future 
	dc.w	File_R83D-.LevelFiles		; Metallic Madness Act 3 Bad Future 
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_Demo11A-.LevelFiles	; Palmtree Panic Act 1 Present demo
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid
	dc.w	File_R11A-.LevelFiles		; Invalid

; -------------------------------------------------------------------------
; PCM drivers
; -------------------------------------------------------------------------

.PCMDrivers:
	dc.l	File_R11A			; Invalid
	dc.l	File_R1PCM			; Palmtree Panic Act 1 Present
	dc.l	File_R1PCM			; Palmtree Panic Act 1 Past
	dc.l	File_R1PCM			; Palmtree Panic Act 1 Good Future
	dc.l	File_R1PCM			; Palmtree Panic Act 1 Bad Future
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R1PCM			; Palmtree Panic Act 2 Present
	dc.l	File_R1PCM			; Palmtree Panic Act 2 Past
	dc.l	File_R1PCM			; Palmtree Panic Act 2 Good Future
	dc.l	File_R1PCM			; Palmtree Panic Act 2 Bad Future
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_BossPCM			; Tidal Tempest Act 3 Good Future demo
	dc.l	File_R8PCM			; Metallic Madness Act 2 Present demo
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R3PCM			; Collision Chaos Act 1 Present
	dc.l	File_R3PCM			; Collision Chaos Act 1 Past
	dc.l	File_R3PCM			; Collision Chaos Act 1 Good Future
	dc.l	File_R3PCM			; Collision Chaos Act 1 Bad Future
	dc.l	File_R3PCM			; Collision Chaos Act 2 Present 
	dc.l	File_R3PCM			; Collision Chaos Act 2 Past 
	dc.l	File_R3PCM			; Collision Chaos Act 2 Good Future 
	dc.l	File_R3PCM			; Collision Chaos Act 2 Bad Future 
	dc.l	File_R3PCM			; Collision Chaos Act 3 Good Future 
	dc.l	File_R3PCM			; Collision Chaos Act 3 Bad Future 
	dc.l	File_BossPCM			; Palmtree Panic Act 3 Good Future
	dc.l	File_BossPCM			; Palmtree Panic Act 3 Bad Future 
	dc.l	File_R4PCM			; Tidal Tempest Act 1 Present
	dc.l	File_R4PCM			; Tidal Tempest Act 1 Past
	dc.l	File_R4PCM			; Tidal Tempest Act 1 Good Future
	dc.l	File_R4PCM			; Tidal Tempest Act 1 Bad Future
	dc.l	File_R4PCM			; Tidal Tempest Act 2 Present 
	dc.l	File_R4PCM			; Tidal Tempest Act 2 Past 
	dc.l	File_R4PCM			; Tidal Tempest Act 2 Good Future 
	dc.l	File_R4PCM			; Tidal Tempest Act 2 Bad Future 
	dc.l	File_BossPCM			; Tidal Tempest Act 3 Good Future 
	dc.l	File_BossPCM			; Tidal Tempest Act 3 Bad Future 
	dc.l	File_R5PCM			; Quartz Quadrant Act 1 Present
	dc.l	File_R5PCM			; Quartz Quadrant Act 1 Past
	dc.l	File_R5PCM			; Quartz Quadrant Act 1 Good Future
	dc.l	File_R5PCM			; Quartz Quadrant Act 1 Bad Future
	dc.l	File_R5PCM			; Quartz Quadrant Act 2 Present 
	dc.l	File_R5PCM			; Quartz Quadrant Act 2 Past 
	dc.l	File_R5PCM			; Quartz Quadrant Act 2 Good Future 
	dc.l	File_R5PCM			; Quartz Quadrant Act 2 Bad Future 
	dc.l	File_BossPCM			; Quartz Quadrant Act 3 Good Future 
	dc.l	File_BossPCM			; Quartz Quadrant Act 3 Bad Future 
	dc.l	File_R6PCM			; Wacky Workbench Act 1 Present
	dc.l	File_R6PCM			; Wacky Workbench Act 1 Past
	dc.l	File_R6PCM			; Wacky Workbench Act 1 Good Future
	dc.l	File_R6PCM			; Wacky Workbench Act 1 Bad Future
	dc.l	File_R6PCM			; Wacky Workbench Act 2 Present 
	dc.l	File_R6PCM			; Wacky Workbench Act 2 Past 
	dc.l	File_R6PCM			; Wacky Workbench Act 2 Good Future 
	dc.l	File_R6PCM			; Wacky Workbench Act 2 Bad Future 
	dc.l	File_BossPCM			; Wacky Workbench Act 3 Good Future 
	dc.l	File_BossPCM			; Wacky Workbench Act 3 Bad Future 
	dc.l	File_R7PCM			; Stardust Speedway Act 1 Present
	dc.l	File_R7PCM			; Stardust Speedway Act 1 Past
	dc.l	File_R7PCM			; Stardust Speedway Act 1 Good Future
	dc.l	File_R7PCM			; Stardust Speedway Act 1 Bad Future
	dc.l	File_R7PCM			; Stardust Speedway Act 2 Present 
	dc.l	File_R7PCM			; Stardust Speedway Act 2 Past 
	dc.l	File_R7PCM			; Stardust Speedway Act 2 Good Future 
	dc.l	File_R7PCM			; Stardust Speedway Act 2 Bad Future 
	dc.l	File_BossPCM			; Stardust Speedway Act 3 Good Future 
	dc.l	File_BossPCM			; Stardust Speedway Act 3 Bad Future 
	dc.l	File_R8PCM			; Metallic Madness Act 1 Present
	dc.l	File_R8PCM			; Metallic Madness Act 1 Past
	dc.l	File_R8PCM			; Metallic Madness Act 1 Good Future
	dc.l	File_R8PCM			; Metallic Madness Act 1 Bad Future
	dc.l	File_R8PCM			; Metallic Madness Act 2 Present 
	dc.l	File_R8PCM			; Metallic Madness Act 2 Past 
	dc.l	File_R8PCM			; Metallic Madness Act 2 Good Future 
	dc.l	File_R8PCM			; Metallic Madness Act 2 Bad Future 
	dc.l	File_BossPCM			; Metallic Madness Act 3 Good Future 
	dc.l	File_BossPCM			; Metallic Madness Act 3 Bad Future 
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R1PCM			; Palmtree Panic Act 1 Present demo
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid
	dc.l	File_R11A			; Invalid

; -------------------------------------------------------------------------
; Load Mega Drive initialization
; -------------------------------------------------------------------------

SPCmd_LoadMDInit:
	lea	File_MDInit(pc),a0		; Load file
	bsr.w	WaitWordRAMAccess
	lea	WORDRAM2M,a1
	jsr	LoadFile.w
	bra.w	GiveWordRAMAccess

; -------------------------------------------------------------------------
; Load title screen
; -------------------------------------------------------------------------

SPCmd_LoadTitle:
	lea	File_TitleMain(pc),a0		; Load Main CPU file
	bsr.w	WaitWordRAMAccess
	lea	WORDRAM2M,a1
	jsr	LoadFile.w

	lea	File_TitleSub(pc),a0		; Load Sub CPU file
	lea	PRGRAM+$10000,a1
	jsr	LoadFile.w

	bsr.w	GiveWordRAMAccess		; Give Main CPU Word RAM access

	bsr.w	ResetCDDAVol			; Play title screen music
	lea	MusID_Title(pc),a0
	move.w	#MSCPLAY1,d0
	jsr	_CDBIOS.w

	jsr	PRGRAM+$10000			; Run Sub CPU file code

	move.l	#SPIRQ2,_USERCALL2+2.w		; Restore IRQ2
	rts

; -------------------------------------------------------------------------
; Load "Comin' Soon" screen
; -------------------------------------------------------------------------

SPCmd_LoadCominSoon:
	lea	File_CominSoon(pc),a0		; Load file
	bsr.w	WaitWordRAMAccess
	lea	WORDRAM2M,a1
	jsr	LoadFile.w
	bsr.w	GiveWordRAMAccess

	bsr.w	ResetCDDAVol			; Play invincibility music
	lea	MusID_Invinc(pc),a0
	move.w	#MSCPLAYR,d0
	jmp	_CDBIOS.w

; -------------------------------------------------------------------------
; Load special stage 8 credits
; -------------------------------------------------------------------------

SPCmd_LoadSS8Credits:
	lea	File_SS8Credits(pc),a0		; Load file
	bsr.w	WaitWordRAMAccess
	lea	WORDRAM2M,a1
	jsr	LoadFile.w
	bsr.w	GiveWordRAMAccess

	bra.w	SPCmd_PlayEndingMus		; Play ending music

; -------------------------------------------------------------------------
; Load "Fun is infinite" screen
; -------------------------------------------------------------------------

SPCmd_LoadFunIsInf:
	lea	File_FunIsInf(pc),a0		; Load file
	bsr.w	WaitWordRAMAccess
	lea	WORDRAM2M,a1
	jsr	LoadFile.w
	bsr.w	GiveWordRAMAccess

	bra.w	SPCmd_PlayBossMus		; Play boss music

; -------------------------------------------------------------------------
; Load M.C. Sonic screen
; -------------------------------------------------------------------------

SPCmd_LoadMCSonic:
	lea	File_MCSonic(pc),a0		; Load file
	bsr.w	WaitWordRAMAccess
	lea	WORDRAM2M,a1
	jsr	LoadFile.w
	bsr.w	GiveWordRAMAccess

	bra.w	SPCmd_PlayR8AMus		; Play Metallic Madness Present music

; -------------------------------------------------------------------------
; Load Tails screen
; -------------------------------------------------------------------------

SPCmd_LoadTails:
	lea	File_Tails(pc),a0		; Load file
	bsr.w	WaitWordRAMAccess
	lea	WORDRAM2M,a1
	jsr	LoadFile.w
	bsr.w	GiveWordRAMAccess

	bra.w	SPCmd_PlayDAGardenMus		; Play D.A. Garden music

; -------------------------------------------------------------------------
; Load Batman Sonic screen
; -------------------------------------------------------------------------

SPCmd_LoadBatmanSonic:
	lea	File_BatmanSonic(pc),a0		; Load file
	bsr.w	WaitWordRAMAccess
	lea	WORDRAM2M,a1
	jsr	LoadFile.w
	bsr.w	GiveWordRAMAccess

	bra.w	SPCmd_PlayFinalMus		; Play final boss music

; -------------------------------------------------------------------------
; Load cute Sonic screen
; -------------------------------------------------------------------------

SPCmd_LoadCuteSonic:
	lea	File_CuteSonic(pc),a0		; Load file
	bsr.w	WaitWordRAMAccess
	lea	WORDRAM2M,a1
	jsr	LoadFile.w
	bsr.w	GiveWordRAMAccess

	bra.w	SPCmd_PlayR1CMus		; Play Palmtree Panic Good Future music

; -------------------------------------------------------------------------
; Load best staff times screen
; -------------------------------------------------------------------------

SPCmd_LoadStaffTimes:
	lea	File_StaffTimes(pc),a0		; Load file
	bsr.w	WaitWordRAMAccess
	lea	WORDRAM2M,a1
	jsr	LoadFile.w
	bsr.w	GiveWordRAMAccess

	lea	MusID_Shoes(pc),a0		; Play speed shoes music
	bsr.w	ResetCDDAVol
	move.w	#MSCPLAYR,d0
	jmp	_CDBIOS.w

; -------------------------------------------------------------------------
; Load main program
; -------------------------------------------------------------------------

SPCmd_LoadIPX:
	lea	File_IPX(pc),a0			; Load file
	bra.s	LoadFileIntoWordRAM

; -------------------------------------------------------------------------
; Load sound test
; -------------------------------------------------------------------------

SPCmd_LoadSndTest:
	lea	File_SoundTest(pc),a0		; Load file
	bra.s	LoadFileIntoWordRAM

; -------------------------------------------------------------------------
; Load dummy file (unused)
; -------------------------------------------------------------------------

SPCmd_LoadDummyFile1:
	lea	File_MCSonic(pc),a0		; Load file
	bra.s	LoadFileIntoWordRAM

; -------------------------------------------------------------------------
; Load dummy file (unused)
; -------------------------------------------------------------------------

SPCmd_LoadDummyFile2:
	lea	File_MCSonic(pc),a0		; Load file
	bra.s	LoadFileIntoWordRAM

; -------------------------------------------------------------------------
; Load dummy file (unused)
; -------------------------------------------------------------------------

SPCmd_LoadDummyFile3:
	lea	File_MCSonic(pc),a0		; Load file
	bra.s	LoadFileIntoWordRAM

; -------------------------------------------------------------------------
; Load dummy file (unused)
; -------------------------------------------------------------------------

SPCmd_LoadDummyFile4:
	lea	File_MCSonic(pc),a0		; Load file
	bra.s	LoadFileIntoWordRAM

; -------------------------------------------------------------------------
; Load dummy file (unused)
; -------------------------------------------------------------------------

SPCmd_LoadDummyFile5:
	lea	File_MCSonic(pc),a0		; Load file
	bra.s	LoadFileIntoWordRAM

; -------------------------------------------------------------------------
; Load stage select
; -------------------------------------------------------------------------

SPCmd_LoadStageSel:
	lea	File_StageSelect(pc),a0		; Load file
	
; -------------------------------------------------------------------------
; Load file into Word RAM
; -------------------------------------------------------------------------
; PARAMETERS
;	a0.l - Pointer to file name
; -------------------------------------------------------------------------

LoadFileIntoWordRAM:
	bsr.w	WaitWordRAMAccess		; Load file into Word RAM
	lea	WORDRAM2M,a1
	jsr	LoadFile.w
	bra.w	GiveWordRAMAccess

; -------------------------------------------------------------------------
; Load Visual Mode menu
; -------------------------------------------------------------------------

SPCmd_LoadVisualMode:
	lea	File_VisualMode(pc),a0		; Load file
	bsr.w	WaitWordRAMAccess
	lea	WORDRAM2M,a1
	jsr	LoadFile.w

	bsr.w	ResetCDDAVol			; Play title screen music
	lea	MusID_Title(pc),a0
	move.w	#MSCPLAYR,d0
	jsr	_CDBIOS.w

	bra.w	GiveWordRAMAccess		; Give Main CPU Word RAM access

; -------------------------------------------------------------------------
; Load warp sequence
; -------------------------------------------------------------------------

SPCmd_LoadWarp:
	lea	File_Warp(pc),a0		; Load file
	bsr.w	WaitWordRAMAccess
	lea	WORDRAM2M,a1
	jsr	LoadFile.w
	bra.w	GiveWordRAMAccess

; -------------------------------------------------------------------------
; Load time attack menu
; -------------------------------------------------------------------------

SPCmd_LoadTimeAttack:
	lea	File_TimeAttackMain(pc),a0	; Load file
	bsr.w	WaitWordRAMAccess
	lea	WORDRAM2M,a1
	jsr	LoadFile.w
	bsr.w	GiveWordRAMAccess

	bsr.w	ResetCDDAVol			; Play D.A. Garden music
	if REGION=USA
		lea	MusID_DAGarden(pc),a0
	else
		lea	MusID_TimeAttack(pc),a0
	endif
	move.w	#MSCPLAYR,d0
	jsr	_CDBIOS.w
	rts

; -------------------------------------------------------------------------
; Load D.A. Garden
; -------------------------------------------------------------------------

SPCmd_LoadDAGarden:
	lea	File_DAGardenMain(pc),a0	; Load Main CPU file
	bsr.w	WaitWordRAMAccess
	lea	WORDRAM2M,a1
	jsr	LoadFile.w

	lea	File_DAGardenData(pc),a0	; Load data file
	bsr.w	WaitWordRAMAccess
	lea	WORDRAM2M+DAGrdnTrkTitles,a1
	jsr	LoadFile.w
	bsr.w	GiveWordRAMAccess

	lea	File_DAGardenSub(pc),a0		; Load Sub CPU file
	lea	PRGRAM+$10000,a1
	jsr	LoadFile.w

	bsr.w	ResetCDDAVol			; Play D.A. Garden music
	lea	MusID_DAGarden(pc),a0
	move.w	#MSCPLAYR,d0
	jsr	_CDBIOS.w

	jsr	PRGRAM+$10000			; Run Sub CPU file code

	move.l	#SPIRQ2,_USERCALL2+2.w		; Restore IRQ2
	rts

; -------------------------------------------------------------------------
; Load opening FMV
; -------------------------------------------------------------------------

SPCmd_LoadOpening:
	bclr	#3,GAIRQMASK.w			; Disable timer interrupt

	lea	File_OpeningMain(pc),a0		; Load Main CPU file
	bsr.w	WaitWordRAMAccess
	lea	WORDRAM2M,a1
	jsr	LoadFile.w
	bsr.w	GiveWordRAMAccess

	lea	File_OpeningSub(pc),a0		; Load Sub CPU file
	lea	PRGRAM+$30000,a1
	jsr	LoadFile.w

	jsr	PRGRAM+$30000			; Run Sub CPU file code

	move.l	#SPIRQ2,_USERCALL2+2.w		; Restore IRQ2
	andi.b	#$FA,GAMEMMODE.w		; Set to 2M mode
	move.b	#3,GACDCDEVICE.w		; Set CDC device to "Sub CPU"
	move.l	#0,curPCMDriver.w		; Reset current PCM driver
	rts

; -------------------------------------------------------------------------
; Load bad ending FMV
; -------------------------------------------------------------------------

SPCmd_LoadBadEnd:
	bclr	#3,GAIRQMASK.w			; Disable timer interrupt

	lea	File_EndingMain(pc),a0		; Load Main CPU file
	bsr.w	WaitWordRAMAccess
	lea	WORDRAM2M,a1
	jsr	LoadFile.w
	bsr.w	GiveWordRAMAccess

	lea	File_BadEndSub(pc),a0		; Load Sub CPU file
	lea	PRGRAM+$30000,a1		; GOODEND.BIN loads BADEND.STM. Seriously.
	jsr	LoadFile.w

	jsr	PRGRAM+$30000			; Run Sub CPU file code

	move.l	#SPIRQ2,_USERCALL2+2.w		; Restore IRQ2
	andi.b	#$FA,GAMEMMODE.w		; Set to 2M mode
	move.b	#3,GACDCDEVICE.w		; Set CDC device to "Sub CPU"
	move.l	#0,curPCMDriver.w		; Reset current PCM driver
	rts

; -------------------------------------------------------------------------
; Load good ending FMV
; -------------------------------------------------------------------------

SPCmd_LoadGoodEnd:
	bclr	#3,GAIRQMASK.w			; Disable timer interrupt

	lea	File_EndingMain(pc),a0		; Load Main CPU file
	bsr.w	WaitWordRAMAccess
	lea	WORDRAM2M,a1
	jsr	LoadFile.w
	bsr.w	GiveWordRAMAccess

	lea	File_GoodEndSub(pc),a0		; Load Sub CPU file
	lea	PRGRAM+$30000,a1		; BADEND.BIN loads GOODEND.STM. Seriously.
	jsr	LoadFile.w

	jsr	PRGRAM+$30000			; Run Sub CPU file code

	move.l	#SPIRQ2,_USERCALL2+2.w		; Restore IRQ2
	andi.b	#$FA,GAMEMMODE.w		; Set to 2M mode
	move.b	#3,GACDCDEVICE.w		; Set CDC device to "Sub CPU"
	move.l	#0,curPCMDriver.w		; Reset current PCM driver
	rts

; -------------------------------------------------------------------------
; Load special stage
; -------------------------------------------------------------------------

SPCmd_LoadSpecStage:
	bclr	#3,GAIRQMASK.w			; Disable timer interrupt

	move.b	specStageIDCmd.w,specStageID.w	; Set stage ID
	move.b	timeStonesCmd.w,timeStonesSub.w	; Set time stones retrieved
	move.b	specStageFlags.w,ssFlagsCopy.w	; Copy flags

	lea	File_SpecialMain(pc),a0		; Load Main CPU file
	bsr.w	WaitWordRAMAccess
	lea	WORDRAM2M,a1
	jsr	LoadFile.w

	lea	File_SpecialSub(pc),a0		; Load Sub CPU file
	lea	PRGRAM+$10000,a1
	jsr	LoadFile.w

	moveq	#0,d0				; Copy stage data into Word RAM
	move.b	specStageID.w,d0
	mulu.w	#6,d0
	lea	SpecStageData,a0
	move.w	4(a0,d0.w),d7
	movea.l	(a0,d0.w),a0
	lea	WORDRAM2M+SpecStgDataCopy,a1

.CopyData:
	move.b	(a0)+,(a1)+
	dbf	d7,.CopyData

	bsr.w	GiveWordRAMAccess		; Give Main CPU Word RAM access

	bsr.w	ResetCDDAVol			; Play special stage music
	lea	MusID_Special(pc),a0
	move.w	#MSCPLAYR,d0
	jsr	_CDBIOS.w

	jsr	PRGRAM+$10000			; Run Sub CPU file code

	move.l	#SPIRQ2,_USERCALL2+2.w		; Restore IRQ2
	
	btst	#1,ssFlagsCopy.w		; Were we in time attack mode?
	bne.s	.NoResultsMusic			; If so, branch
	
	bsr.w	ResetCDDAVol			; If not, play results music
	lea	MusID_Results(pc),a0
	move.w	#MSCPLAY1,d0
	jsr	_CDBIOS.w

.NoResultsMusic:
	move.b	#0,ssFlagsCopy.w		; Clear special stage flags copy
	move.l	#0,curPCMDriver.w		; Reset current PCM driver
	rts

; -------------------------------------------------------------------------
; Play "Future" voice clip
; -------------------------------------------------------------------------

SPCmd_PlayFutureSFX:
	move.b	#PCMS_FUTURE,PCMDrvQueue
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Play "Past" voice clip
; -------------------------------------------------------------------------

SPCmd_PlayPastSFX:
	move.b	#PCMS_PAST,PCMDrvQueue
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Play "Alright" voice clip
; -------------------------------------------------------------------------

SPCmd_PlayAlrightSFX:
	move.b	#PCMS_ALRIGHT,PCMDrvQueue
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Play "I'm outta here" voice clip
; -------------------------------------------------------------------------

SPCmd_PlayGiveUpSFX:
	move.b	#$B4,PCMDrvQueue
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Play "Yes" voice clip
; -------------------------------------------------------------------------

SPCmd_PlayYesSFX:
	move.b	#PCMS_YES,PCMDrvQueue
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Play "Yeah" voice clip
; -------------------------------------------------------------------------

SPCmd_PlayYeahSFX:
	move.b	#PCMS_YEAH,PCMDrvQueue
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Play Amy giggle voice clip
; -------------------------------------------------------------------------

SPCmd_PlayGiggleSFX:
	move.b	#PCMS_GIGGLE,PCMDrvQueue
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Play Amy yelp voice clip
; -------------------------------------------------------------------------

SPCmd_PlayAmyYelpSFX:
	move.b	#PCMS_AMYYELP,PCMDrvQueue
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Play mech stomp sound
; -------------------------------------------------------------------------

SPCmd_PlayStompSFX:
	move.b	#PCMS_STOMP,PCMDrvQueue
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Play bumper sound
; -------------------------------------------------------------------------

SPCmd_PlayBumperSFX:
	move.b	#PCMS_BUMPER,PCMDrvQueue
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Play glass break sound
; -------------------------------------------------------------------------

SPCmd_PlayBreakSFX:
	move.b	#PCMS_BREAK,PCMDrvQueue
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Play past music
; -------------------------------------------------------------------------

SPCmd_PlayPastMus:
	move.b	#PCMM_PAST,PCMDrvQueue
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Fade out PCM
; -------------------------------------------------------------------------

SPCmd_FadeOutPCM:
	move.b	#$E0,PCMDrvQueue
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Stop PCM
; -------------------------------------------------------------------------

SPCmd_StopPCM:
	move.b	#$E1,PCMDrvQueue
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Pause PCM
; -------------------------------------------------------------------------

SPCmd_PausePCM:
	move.b	#$E2,PCMDrvQueue
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Unpause PCM
; -------------------------------------------------------------------------

SPCmd_UnpausePCM:
	move.b	#$E3,PCMDrvQueue
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Reset CDDA music volume
; -------------------------------------------------------------------------

SPCmd_ResetCDDAVol:
	bsr.w	ResetCDDAVol
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Fade out CDDA music
; -------------------------------------------------------------------------

SPCmd_FadeOutCDDA:
	move.w	#FDRCHG,d0
	moveq	#$20,d1
	jsr	_CDBIOS.w
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Stop CDDA music
; -------------------------------------------------------------------------

SPCmd_StopCDDA:
	move.w	#MSCSTOP,d0
	jsr	_CDBIOS.w
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Pause CDDA music
; -------------------------------------------------------------------------

SPCmd_PauseCDDA:
	move.w	#MSCPAUSEON,d0
	jsr	_CDBIOS.w
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Unpause CDDA music
; -------------------------------------------------------------------------

SPCmd_UnpauseCDDA:
	move.w	#MSCPAUSEOFF,d0
	jsr	_CDBIOS.w
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Reset CDDA music volume
; -------------------------------------------------------------------------

ResetCDDAVol:
	move.l	a0,-(sp)
	
	move.w	#FDRSET,d0			; Set CDDA music volume
	move.w	#$380,d1
	jsr	_CDBIOS.w

	move.w	#FDRSET,d0			; Set CDDA music master volume
	move.w	#$8380,d1
	jsr	_CDBIOS.w

	movea.l	(sp)+,a0
	rts

; -------------------------------------------------------------------------
; Play Palmtree Panic Present music
; -------------------------------------------------------------------------

SPCmd_PlayR1AMus:
	lea	MusID_R1A(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Palmtree Panic Good Future music
; -------------------------------------------------------------------------

SPCmd_PlayR1CMus:
	lea	MusID_R1C(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Palmtree Panic Bad Future music
; -------------------------------------------------------------------------

SPCmd_PlayR1DMus:
	lea	MusID_R1D(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Collision Chaos Present music
; -------------------------------------------------------------------------

SPCmd_PlayR3AMus:
	lea	MusID_R3A(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Collision Chaos Good Future music
; -------------------------------------------------------------------------

SPCmd_PlayR3CMus:
	lea	MusID_R3C(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Collision Chaos Bad Future music
; -------------------------------------------------------------------------

SPCmd_PlayR3DMus:
	lea	MusID_R3D(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Tidal Tempest Present music
; -------------------------------------------------------------------------

SPCmd_PlayR4AMus:
	lea	MusID_R4A(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Tidal Tempest Good Future music
; -------------------------------------------------------------------------

SPCmd_PlayR4CMus:
	lea	MusID_R4C(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Tidal Tempest Bad Future music
; -------------------------------------------------------------------------

SPCmd_PlayR4DMus:
	lea	MusID_R4D(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Quartz Quadrant Present music
; -------------------------------------------------------------------------

SPCmd_PlayR5AMus:
	lea	MusID_R5A(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Quartz Quadrant Good Future music
; -------------------------------------------------------------------------

SPCmd_PlayR5CMus:
	lea	MusID_R5C(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Quartz Quadrant Bad Future music
; -------------------------------------------------------------------------

SPCmd_PlayR5DMus:
	lea	MusID_R5D(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Wacky Workbench Present music
; -------------------------------------------------------------------------

SPCmd_PlayR6AMus:
	lea	MusID_R6A(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Wacky Workbench Good Future music
; -------------------------------------------------------------------------

SPCmd_PlayR6CMus:
	lea	MusID_R6C(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Wacky Workbench Bad Future music
; -------------------------------------------------------------------------

SPCmd_PlayR6DMus:
	lea	MusID_R6D(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Stardust Speedway Present music
; -------------------------------------------------------------------------

SPCmd_PlayR7AMus:
	lea	MusID_R7A(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Stardust Speedway Good Future music
; -------------------------------------------------------------------------

SPCmd_PlayR7CMus:
	lea	MusID_R7C(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Stardust Speedway Bad Future music
; -------------------------------------------------------------------------

SPCmd_PlayR7DMus:
	lea	MusID_R7D(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Metallic Madness Present music
; -------------------------------------------------------------------------

SPCmd_PlayR8AMus:
	lea	MusID_R8A(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Metallic Madness Good Future music
; -------------------------------------------------------------------------

SPCmd_PlayR8CMus:
	lea	MusID_R8C(pc),a0

; -------------------------------------------------------------------------
; Loop CDDA music
; -------------------------------------------------------------------------
; PARAMETERS
;	a0.l - Pointer to music ID
; -------------------------------------------------------------------------

LoopCDDA:
	bsr.w	ResetCDDAVol			; Reset CDDA music volume
	move.w	#MSCPLAYR,d0			; Play track on loop
	jsr	_CDBIOS.w
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Play Metallic Madness Bad Future music
; -------------------------------------------------------------------------

SPCmd_PlayR8DMus:
	lea	MusID_R8D(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play boss music
; -------------------------------------------------------------------------

SPCmd_PlayBossMus:
	lea	MusID_Boss(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play final boss music
; -------------------------------------------------------------------------

SPCmd_PlayFinalMus:
	lea	MusID_Final(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play time attack menu music
; -------------------------------------------------------------------------

SPCmd_PlayTimeAtkMus:
	lea	MusID_TimeAttack(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play special stage music
; -------------------------------------------------------------------------

SPCmd_PlaySpecStgMus:
	lea	MusID_Special(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play D.A. Garden music
; -------------------------------------------------------------------------

SPCmd_PlayDAGardenMus:
	lea	MusID_DAGarden(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play prototype warp sound
; -------------------------------------------------------------------------

SPCmd_PlayProtoWarp:
	lea	MusID_ProtoWarp(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play opening music
; -------------------------------------------------------------------------

SPCmd_PlayOpeningMus:
	lea	MusID_Opening(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play ending music
; -------------------------------------------------------------------------

SPCmd_PlayEndingMus:
	lea	MusID_Ending(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play title screen music
; -------------------------------------------------------------------------

SPCmd_PlayTitleMus:
	lea	MusID_Title(pc),a0
	bra.s	PlayCDDA

; -------------------------------------------------------------------------
; Play results music
; -------------------------------------------------------------------------

SPCmd_PlayResultsMus:
	lea	MusID_Results(pc),a0
	bra.s	PlayCDDA

; -------------------------------------------------------------------------
; Play speed shoes music
; -------------------------------------------------------------------------

SPCmd_PlayShoesMus:
	lea	MusID_Shoes(pc),a0
	bra.s	PlayCDDA

; -------------------------------------------------------------------------
; Play invincibility music
; -------------------------------------------------------------------------

SPCmd_PlayInvincMus:
	lea	MusID_Invinc(pc),a0
	bra.s	PlayCDDA

; -------------------------------------------------------------------------
; Play game over music
; -------------------------------------------------------------------------

SPCmd_PlayGameOverMus:
	lea	MusID_GameOver(pc),a0

; -------------------------------------------------------------------------
; Play CDDA music
; -------------------------------------------------------------------------
; PARAMETERS
;	a0.l - Pointer to music ID
; -------------------------------------------------------------------------

PlayCDDA:
	bsr.w	ResetCDDAVol			; Reset CDDA music volume
	move.w	#MSCPLAY1,d0			; Play track once
	jsr	_CDBIOS.w
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Play Palmtree Panic Present music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR1AMus:
	lea	MusID_R1A(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play Palmtree Panic Good Future music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR1CMus:
	lea	MusID_R1C(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play Palmtree Panic Bad Future music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR1DMus:
	lea	MusID_R1D(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play Collision Chaos Present music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR3AMus:
	lea	MusID_R3A(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play Collision Chaos Good Future music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR3CMus:
	lea	MusID_R3C(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play Collision Chaos Bad Future music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR3DMus:
	lea	MusID_R3D(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play Tidal Tempest Present music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR4AMus:
	lea	MusID_R4A(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play Tidal Tempest Good Future music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR4CMus:
	lea	MusID_R4C(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play Tidal Tempest Bad Future music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR4DMus:
	lea	MusID_R4D(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play Quartz Quadrant Present music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR5AMus:
	lea	MusID_R5A(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play Quartz Quadrant Good Future music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR5CMus:
	lea	MusID_R5C(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play Quartz Quadrant Bad Future music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR5DMus:
	lea	MusID_R5D(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play Wacky Workbench Present music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR6AMus:
	lea	MusID_R6A(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play Wacky Workbench Good Future music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR6CMus:
	lea	MusID_R6C(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play Wacky Workbench Bad Future music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR6DMus:
	lea	MusID_R6D(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play Stardust Speedway Present music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR7AMus:
	lea	MusID_R7A(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play Stardust Speedway Good Future music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR7CMus:
	lea	MusID_R7C(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play Stardust Speedway Bad Future music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR7DMus:
	lea	MusID_R7D(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play Metallic Madness Present music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR8AMus:
	lea	MusID_R8A(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play Metallic Madness Good Future music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR8CMus:
	lea	MusID_R8C(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play Metallic Madness Bad Future music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR8DMus:
	lea	MusID_R8D(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play boss music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestBossMus:
	lea	MusID_Boss(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play final boss music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestFinalMus:
	lea	MusID_Final(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play title screen music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestTitleMus:
	lea	MusID_Title(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play time attack menu music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestTimeAtkMus:
	lea	MusID_TimeAttack(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play results music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestResultsMus:
	lea	MusID_Results(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play speed shoes music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestShoesMus:
	lea	MusID_Shoes(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play invincibility music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestInvincMus:
	lea	MusID_Invinc(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play game over music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestGameOverMus:
	lea	MusID_GameOver(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play special stage music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestSpecialMus:
	lea	MusID_Special(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play D.A. Garden music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestDAGardenMus:
	lea	MusID_DAGarden(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play prototype warp sound (sound test)
; -------------------------------------------------------------------------

SPCmd_TestProtoWarp:
	lea	MusID_ProtoWarp(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play opening music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestIntroMus:
	lea	MusID_Opening(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play ending music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestEndingMus:
	lea	MusID_Ending(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play "Future" voice clip (sound test)
; -------------------------------------------------------------------------

SPCmd_TestFutureSFX:
	lea	File_R1PCM(pc),a0		; Load PCM driver
	bsr.w	LoadPCMDriver
	move.b	#PCMS_FUTURE,PCMDrvQueue	; Queue sound ID
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Play "Past" voice clip (sound test)
; -------------------------------------------------------------------------

SPCmd_TestPastSFX:
	lea	File_R1PCM(pc),a0		; Load PCM driver
	bsr.w	LoadPCMDriver
	move.b	#PCMS_PAST,PCMDrvQueue		; Queue sound ID
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Play "Alright" voice clip (sound test)
; -------------------------------------------------------------------------

SPCmd_TestAlrightSFX:
	lea	File_R1PCM(pc),a0		; Load PCM driver
	bsr.w	LoadPCMDriver
	move.b	#PCMS_ALRIGHT,PCMDrvQueue	; Queue sound ID
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Play "I'm outta here" voice clip (sound test)
; -------------------------------------------------------------------------

SPCmd_TestGiveUpSFX:
	lea	File_R1PCM(pc),a0		; Load PCM driver
	bsr.w	LoadPCMDriver
	move.b	#PCMS_GIVEUP,PCMDrvQueue	; Queue sound ID
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Play "Yes" voice clip (sound test)
; -------------------------------------------------------------------------

SPCmd_TestYesSFX:
	lea	File_R1PCM(pc),a0		; Load PCM driver
	bsr.w	LoadPCMDriver
	move.b	#PCMS_YES,PCMDrvQueue		; Queue sound ID
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Play "Yeah" voice clip (sound test)
; -------------------------------------------------------------------------

SPCmd_TestYeahSFX:
	lea	File_R1PCM(pc),a0		; Load PCM driver
	bsr.w	LoadPCMDriver
	move.b	#PCMS_YEAH,PCMDrvQueue		; Queue sound ID
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Play Amy giggle voice clip (sound test)
; -------------------------------------------------------------------------

SPCmd_TestGiggleSFX:
	lea	File_R1PCM(pc),a0		; Load PCM driver
	bsr.w	LoadPCMDriver
	move.b	#PCMS_GIGGLE,PCMDrvQueue	; Queue sound ID
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Play Amy yelp voice clip (sound test)
; -------------------------------------------------------------------------

SPCmd_TestAmyYelpSFX:
	lea	File_R1PCM(pc),a0		; Load PCM driver
	bsr.w	LoadPCMDriver
	move.b	#PCMS_AMYYELP,PCMDrvQueue	; Queue sound ID
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Play mech stomp sound (sound test)
; -------------------------------------------------------------------------

SPCmd_TestStompSFX:
	lea	File_R3PCM(pc),a0		; Load PCM driver
	bsr.w	LoadPCMDriver
	move.b	#PCMS_STOMP,PCMDrvQueue		; Queue sound ID
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Play bumper sound (sound test)
; -------------------------------------------------------------------------

SPCmd_TestBumperSFX:
	lea	File_R3PCM(pc),a0		; Load PCM driver
	bsr.w	LoadPCMDriver
	move.b	#PCMS_BUMPER,PCMDrvQueue	; Queue sound ID
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Play Palmtree Panic past music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR1BMus:
	lea	File_R1PCM(pc),a0		; Load PCM driver
	bsr.w	LoadPCMDriver
	move.b	#PCMM_PAST,PCMDrvQueue		; Queue music ID
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Play Collision Chaos past music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR3BMus:
	lea	File_R3PCM(pc),a0		; Load PCM driver
	bsr.w	LoadPCMDriver
	move.b	#PCMM_PAST,PCMDrvQueue		; Queue music ID
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Play Tidal Tempest past music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR4BMus:
	lea	File_R4PCM(pc),a0		; Load PCM driver
	bsr.w	LoadPCMDriver
	move.b	#PCMM_PAST,PCMDrvQueue		; Queue music ID
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Play Quartz Quadrant past music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR5BMus:
	lea	File_R5PCM(pc),a0		; Load PCM driver
	bsr.w	LoadPCMDriver
	move.b	#PCMM_PAST,PCMDrvQueue		; Queue music ID
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Play Wacky Workbench past music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR6BMus:
	lea	File_R6PCM(pc),a0		; Load PCM driver
	bsr.w	LoadPCMDriver
	move.b	#PCMM_PAST,PCMDrvQueue		; Queue music ID
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Play Stardust Speedway past music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR7BMus:
	lea	File_R7PCM(pc),a0		; Load PCM driver
	bsr.w	LoadPCMDriver
	move.b	#PCMM_PAST,PCMDrvQueue		; Queue music ID
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Play Metallic Madness past music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR8BMus:
	lea	File_R8PCM(pc),a0		; Load PCM driver
	bsr.w	LoadPCMDriver
	move.b	#PCMM_PAST,PCMDrvQueue		; Queue music ID
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Load PCM driver for sound test
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to file name
; -------------------------------------------------------------------------

LoadPCMDriver:
	bclr	#3,GAIRQMASK.w			; Disable timer interrupt

	move.l	curPCMDriver.w,d0		; Is this driver already loaded?
	move.l	a0,curPCMDriver.w
	cmp.l	a0,d0
	beq.s	.End				; If so, branch
	lea	PCMDriver,a1			; If not, load it
	jsr	LoadFile.w

.End:
	bset	#3,GAIRQMASK.w			; Enable timer interrupt
	rts

; -------------------------------------------------------------------------
; Null level 1 interrupt
; -------------------------------------------------------------------------

IRQ1Null:
	rte

; -------------------------------------------------------------------------
; Run PCM driver (timer interrupt)
; -------------------------------------------------------------------------

RunPCMDriver:
	bchg	#0,pcmDrvFlags.w		; Should we run the driver on this interrupt?
	beq.s	.End				; If not, branch

	movem.l	d0-a6,-(sp)			; Run the driver
	jsr	PCMDrvRun
	movem.l	(sp)+,d0-a6

.End:
	rte

; -------------------------------------------------------------------------
; Give Word RAM access to the Main CPU (and finish off command)
; -------------------------------------------------------------------------

GiveWordRAMAccess:
	bset	#0,GAMEMMODE.w			; Give Word RAM access to Main CPU
	btst	#0,GAMEMMODE.w			; Has it been given?
	beq.s	GiveWordRAMAccess		; If not, wait

; -------------------------------------------------------------------------
; Finish off command
; -------------------------------------------------------------------------

SPCmdFinish:
	move.w	GACOMCMD0.w,GACOMSTAT0.w	; Acknowledge command

.WaitMain:
	move.w	GACOMCMD0.w,d0			; Is the Main CPU ready?
	bne.s	.WaitMain			; If not, wait
	move.w	GACOMCMD0.w,d0
	bne.s	.WaitMain			; If not, wait

	move.w	#0,GACOMSTAT0.w			; Mark as ready for another command
	rts

; -------------------------------------------------------------------------
; Wait for Word RAM access
; -------------------------------------------------------------------------

WaitWordRAMAccess:
	btst	#1,GAMEMMODE.w			; Do we have Word RAM access?
	beq.s	WaitWordRAMAccess		; If not, wait
	rts

; -------------------------------------------------------------------------
; Music IDs
; -------------------------------------------------------------------------

MusID_ProtoWarp:
	dc.w	CDDA_WARP			; Prototype warp
MusID_R1A:
	dc.w	CDDA_R1A			; Palmtree Panic Present
MusID_R1C:
	dc.w	CDDA_R1C			; Palmtree Panic Good Future
MusID_R1D:
	dc.w	CDDA_R1D			; Palmtree Panic Bad Future
MusID_R3A:
	dc.w	CDDA_R3A			; Collision Chaos Present
MusID_R3C:
	dc.w	CDDA_R3C			; Collision Chaos Good Future
MusID_R3D:
	dc.w	CDDA_R3D			; Collision Chaos Bad Future
MusID_R4A:
	dc.w	CDDA_R4A			; Tidal Tempest Present
MusID_R4C:
	dc.w	CDDA_R4C			; Tidal Tempest Good Future
MusID_R4D:
	dc.w	CDDA_R4D			; Tidal Tempest Bad Future
MusID_R5A:
	dc.w	CDDA_R5A			; Quartz Quadrant Present
MusID_R5C:
	dc.w	CDDA_R5C			; Quartz Quadrant Good Future
MusID_R5D:
	dc.w	CDDA_R5D			; Quartz Quadrant Bad Future
MusID_R6A:
	dc.w	CDDA_R6A			; Wacky Workbench Present
MusID_R6C:
	dc.w	CDDA_R6C			; Wacky Workbench Good Future
MusID_R6D:
	dc.w	CDDA_R6D			; Wacky Workbench Bad Future
MusID_R7A:
	dc.w	CDDA_R7A			; Stardust Speedway Present
MusID_R7C:
	dc.w	CDDA_R7C			; Stardust Speedway Good Future
MusID_R7D:
	dc.w	CDDA_R7D			; Stardust Speedway Bad Future
MusID_R8A:
	dc.w	CDDA_R8A			; Metallic Madness Present
MusID_R8C:
	dc.w	CDDA_R8C			; Metallic Madness Good Future
MusID_R8D:
	dc.w	CDDA_R8D			; Metallic Madness Bad Future
MusID_Boss:
	dc.w	CDDA_BOSS			; Boss
MusID_Final:
	dc.w	CDDA_FINAL			; Final boss
MusID_Title:
	dc.w	CDDA_TITLE			; Title screen
MusID_TimeAttack:
	dc.w	CDDA_TMATK			; Time attack menu
MusID_Results:
	dc.w	CDDA_RESULTS			; Results
MusID_Shoes:
	dc.w	CDDA_SHOES			; Speed shoes
MusID_Invinc:
	dc.w	CDDA_INVINC			; Invincibility
MusID_GameOver:
	dc.w	CDDA_GAMEOVER			; Game over
MusID_Special:
	dc.w	CDDA_SPECIAL			; Special stage
MusID_DAGarden:
	dc.w	CDDA_DAGARDEN			; D.A. Garden
MusID_Opening:
	dc.w	CDDA_INTRO			; Opening
MusID_Ending:
	dc.w	CDDA_ENDING			; Ending

; -------------------------------------------------------------------------
; Backup RAM data
; -------------------------------------------------------------------------

BuRAMScratch:
	dcb.b	$640, 0				; Scratch RAM

BuRAMStrings:	
	dcb.b	$C, 0				; Display strings

; -------------------------------------------------------------------------

	ALIGN	$FC00

; -------------------------------------------------------------------------
