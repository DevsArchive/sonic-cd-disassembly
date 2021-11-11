; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; System program extension
; -------------------------------------------------------------------------

	include	"_inc/common.i"
	include	"_inc/subcpu.i"
	include	"_inc/system.i"
	include	"_inc/sound.i"
	include	"_inc/buram.i"

; -------------------------------------------------------------------------
; Files
; -------------------------------------------------------------------------

	org	SPX
File_R11A:
	dc.b	"R11A__.MMD;1", 0		; Palmtree Panic Act 1 present
File_R11B:
	dc.b	"R11B__.MMD;1", 0		; Palmtree Panic Act 1 past
File_R11C:
	dc.b	"R11C__.MMD;1", 0		; Palmtree Panic Act 1 good future
File_R11D:
	dc.b	"R11D__.MMD;1", 0		; Palmtree Panic Act 1 bad future
File_MDInit:
	dc.b	"MDINIT.MMD;1", 0		; Mega Drive initialization
File_SoundTest:
	dc.b	"SOSEL_.MMD;1", 0		; Sound test
File_StageSelect:
	dc.b	"STSEL_.MMD;1", 0		; Stage select
File_R12A:
	dc.b	"R12A__.MMD;1", 0		; Palmtree Panic Act 2 present
File_R12B:
	dc.b	"R12B__.MMD;1", 0		; Palmtree Panic Act 2 past
File_R12C:
	dc.b	"R12C__.MMD;1", 0		; Palmtree Panic Act 2 good future
File_R12D:
	dc.b	"R12D__.MMD;1", 0		; Palmtree Panic Act 2 bad future
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
	dc.b	"R31A__.MMD;1", 0		; Collision Chaos Act 1 present
File_R31B:
	dc.b	"R31B__.MMD;1", 0		; Collision Chaos Act 1 past
File_R31C:
	dc.b	"R31C__.MMD;1", 0		; Collision Chaos Act 1 good future
File_R31D:
	dc.b	"R31D__.MMD;1", 0		; Collision Chaos Act 1 bad future
File_R32A:
	dc.b	"R32A__.MMD;1", 0		; Collision Chaos Act 2 present
File_R32B:
	dc.b	"R32B__.MMD;1", 0		; Collision Chaos Act 2 past
File_R32C:
	dc.b	"R32C__.MMD;1", 0		; Collision Chaos Act 2 good future
File_R32D:
	dc.b	"R32D__.MMD;1", 0		; Collision Chaos Act 2 bad future
File_R33C:
	dc.b	"R33C__.MMD;1", 0		; Collision Chaos Act 3 good future
File_R33D:
	dc.b	"R33D__.MMD;1", 0		; Collision Chaos Act 3 bad future
File_R13C:
	dc.b	"R13C__.MMD;1", 0		; Palmtree Panic Act 3 good future
File_R13D:
	dc.b	"R13D__.MMD;1", 0		; Palmtree Panic Act 3 bad future
File_R41A:
	dc.b	"R41A__.MMD;1", 0		; Tidal Tempest Act 1 present
File_R41B:
	dc.b	"R41B__.MMD;1", 0		; Tidal Tempest Act 1 past
File_R41C:
	dc.b	"R41C__.MMD;1", 0		; Tidal Tempest Act 1 good future
File_R41D:
	dc.b	"R41D__.MMD;1", 0		; Tidal Tempest Act 1 bad future
File_R42A:
	dc.b	"R42A__.MMD;1", 0		; Tidal Tempest Act 2 present
File_R42B:
	dc.b	"R42B__.MMD;1", 0		; Tidal Tempest Act 2 past
File_R42C:
	dc.b	"R42C__.MMD;1", 0		; Tidal Tempest Act 2 good future
File_R42D:
	dc.b	"R42D__.MMD;1", 0		; Tidal Tempest Act 2 bad future
File_R43C:
	dc.b	"R43C__.MMD;1", 0		; Tidal Tempest Act 3 good future
File_R43D:
	dc.b	"R43D__.MMD;1", 0		; Tidal Tempest Act 3 bad future
File_R51A:
	dc.b	"R51A__.MMD;1", 0		; Quartz Quadrant Act 1 present
File_R51B:
	dc.b	"R51B__.MMD;1", 0		; Quartz Quadrant Act 1 past
File_R51C:
	dc.b	"R51C__.MMD;1", 0		; Quartz Quadrant Act 1 good future
File_R51D:
	dc.b	"R51D__.MMD;1", 0		; Quartz Quadrant Act 1 bad future
File_R52A:
	dc.b	"R52A__.MMD;1", 0		; Quartz Quadrant Act 2 present
File_R52B:
	dc.b	"R52B__.MMD;1", 0		; Quartz Quadrant Act 2 past
File_R52C:
	dc.b	"R52C__.MMD;1", 0		; Quartz Quadrant Act 2 good future
File_R52D:
	dc.b	"R52D__.MMD;1", 0		; Quartz Quadrant Act 2 bad future
File_R53C:
	dc.b	"R53C__.MMD;1", 0		; Quartz Quadrant Act 3 good future
File_R53D:
	dc.b	"R53D__.MMD;1", 0		; Quartz Quadrant Act 3 bad future
File_R61A:
	dc.b	"R61A__.MMD;1", 0		; Wacky Workbench Act 1 present
File_R61B:
	dc.b	"R61B__.MMD;1", 0		; Wacky Workbench Act 1 past
File_R61C:
	dc.b	"R61C__.MMD;1", 0		; Wacky Workbench Act 1 good future
File_R61D:
	dc.b	"R61D__.MMD;1", 0		; Wacky Workbench Act 1 bad future
File_R62A:
	dc.b	"R62A__.MMD;1", 0		; Wacky Workbench Act 2 present
File_R62B:
	dc.b	"R62B__.MMD;1", 0		; Wacky Workbench Act 2 past
File_R62C:
	dc.b	"R62C__.MMD;1", 0		; Wacky Workbench Act 2 good future
File_R62D:
	dc.b	"R62D__.MMD;1", 0		; Wacky Workbench Act 2 bad future
File_R63C:
	dc.b	"R63C__.MMD;1", 0		; Wacky Workbench Act 3 good future
File_R63D:
	dc.b	"R63D__.MMD;1", 0		; Wacky Workbench Act 3 bad future
File_R71A:
	dc.b	"R71A__.MMD;1", 0		; Stardust Speedway Act 1 present
File_R71B:
	dc.b	"R71B__.MMD;1", 0		; Stardust Speedway Act 1 past
File_R71C:
	dc.b	"R71C__.MMD;1", 0		; Stardust Speedway Act 1 good future
File_R71D:
	dc.b	"R71D__.MMD;1", 0		; Stardust Speedway Act 1 bad future
File_R72A:
	dc.b	"R72A__.MMD;1", 0		; Stardust Speedway Act 2 present
File_R72B:
	dc.b	"R72B__.MMD;1", 0		; Stardust Speedway Act 2 past
File_R72C:
	dc.b	"R72C__.MMD;1", 0		; Stardust Speedway Act 2 good future
File_R72D:
	dc.b	"R72D__.MMD;1", 0		; Stardust Speedway Act 2 bad future
File_R73C:
	dc.b	"R73C__.MMD;1", 0		; Stardust Speedway Act 3 good future
File_R73D:
	dc.b	"R73D__.MMD;1", 0		; Stardust Speedway Act 3 bad future
File_R81A:
	dc.b	"R81A__.MMD;1", 0		; Metallic Madness Act 1 present
File_R81B:
	dc.b	"R81B__.MMD;1", 0		; Metallic Madness Act 1 past
File_R81C:
	dc.b	"R81C__.MMD;1", 0		; Metallic Madness Act 1 good future
File_R81D:
	dc.b	"R81D__.MMD;1", 0		; Metallic Madness Act 1 bad future
File_R82A:
	dc.b	"R82A__.MMD;1", 0		; Metallic Madness Act 2 present
File_R82B:
	dc.b	"R82B__.MMD;1", 0		; Metallic Madness Act 2 past
File_R82C:
	dc.b	"R82C__.MMD;1", 0		; Metallic Madness Act 2 good future
File_R82D:
	dc.b	"R82D__.MMD;1", 0		; Metallic Madness Act 2 bad future
File_R83C:
	dc.b	"R83C__.MMD;1", 0		; Metallic Madness Act 3 good future
File_R83D:
	dc.b	"R83D__.MMD;1", 0		; Metallic Madness Act 3 bad future
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
	dc.b	"PLANET_D.BIN;1", 0		; D.A Garden data
File_Demo11A:
	dc.b	"DEMO11A.MMD;1", 0		; Palmtree Panic Act 1 present demo
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
File_GoodEndSub:
	dc.b	"GOODEND.BIN;1", 0 		; Good ending FMV (Sub CPU)
File_BadEndSub:
	dc.b	"BADEND.BIN;1", 0 		; Bad ending FMV (Sub CPU)
File_FunIsInf:
	dc.b	"NISI.MMD;1", 0			; "Fun is infinite" screen
File_StaffCredits:
	dc.b	"SPEEND.MMD;1", 0		; Staff credits
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
	dc.b	"DUMMY5.MMD;1", 0		; Copy of sound test (Unused)
File_Dummy6:
	dc.b	"DUMMY6.MMD;1", 0		; Copy of sound test (Unused)
File_Dummy7:
	dc.b	"DUMMY7.MMD;1", 0		; Copy of sound test (Unused)
File_Dummy8:
	dc.b	"DUMMY8.MMD;1", 0		; Copy of sound test (Unused)
File_Dummy9:
	dc.b	"DUMMY9.MMD;1", 0		; Copy of sound test (Unused)
File_PencilTestMain:
	dc.b	"PTEST.MMD;1", 0		; Pencil test FMV (Main CPU)
File_PencilTestSub:
	dc.b	"PTEST.BIN;1", 0		; Pencil test FMV (Sub CPU)
File_Demo43C:
	dc.b	"DEMO43C.MMD;1", 0		; Tidal Tempest Act 3 good future demo
File_Demo82A:
	dc.b	"DEMO82A.MMD;1", 0		; Metallic Madness Act 2 present demo
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
	dc.w	0				; $00 | Invalid
	dc.w	SPCmd_LoadLevel-.SPCmds		; $01 | Load Palmtree Panic Act 1 present
	dc.w	SPCmd_LoadLevel-.SPCmds		; $02 | Load Palmtree Panic Act 1 past
	dc.w	SPCmd_LoadLevel-.SPCmds		; $03 | Load Palmtree Panic Act 1 good future
	dc.w	SPCmd_LoadLevel-.SPCmds		; $04 | Load Palmtree Panic Act 1 bad future
	dc.w	SPCmd_LoadMDInit-.SPCmds	; $05 | Load Mega Drive initialization
	dc.w	SPCmd_LoadStageSel-.SPCmds	; $06 | Load stage select
	dc.w	SPCmd_LoadLevel-.SPCmds		; $07 | Load Palmtree Panic Act 2 present
	dc.w	SPCmd_LoadLevel-.SPCmds		; $08 | Load Palmtree Panic Act 2 past
	dc.w	SPCmd_LoadLevel-.SPCmds		; $09 | Load Palmtree Panic Act 2 good future
	dc.w	SPCmd_LoadLevel-.SPCmds		; $0A | Load Palmtree Panic Act 2 bad future
	dc.w	SPCmd_LoadTitle-.SPCmds		; $0B | Load title screen
	dc.w	SPCmd_LoadWarp-.SPCmds		; $0C | Load warp sequence
	dc.w	SPCmd_LoadTimeAttack-.SPCmds	; $0D | Load time attack menu
	dc.w	SPCmd_FadeOutCDDA-.SPCmds	; $0E | Fade out CDDA music
	dc.w	SPCmd_PlayR1AMus-.SPCmds	; $0F | Play Palmtree Panic present music
	dc.w	SPCmd_PlayR1CMus-.SPCmds	; $10 | Play Palmtree Panic good future music
	dc.w	SPCmd_PlayR1DMus-.SPCmds	; $11 | Play Palmtree Panic bad future music
	dc.w	SPCmd_PlayR3AMus-.SPCmds	; $12 | Play Collision Chaos present music
	dc.w	SPCmd_PlayR3CMus-.SPCmds	; $13 | Play Collision Chaos good future music
	dc.w	SPCmd_PlayR3DMus-.SPCmds	; $14 | Play Collision Chaos bad future music
	dc.w	SPCmd_PlayR4AMus-.SPCmds	; $15 | Play Tidal Tempest present music
	dc.w	SPCmd_PlayR4CMus-.SPCmds	; $16 | Play Tidal Tempest good future music
	dc.w	SPCmd_PlayR4DMus-.SPCmds	; $17 | Play Tidal Tempest bad future music
	dc.w	SPCmd_PlayR5AMus-.SPCmds	; $18 | Play Quartz Quadrant present music
	dc.w	SPCmd_PlayR5CMus-.SPCmds	; $19 | Play Quartz Quadrant good future music
	dc.w	SPCmd_PlayR5DMus-.SPCmds	; $1A | Play Quartz Quadrant bad future music
	dc.w	SPCmd_PlayR6AMus-.SPCmds	; $1B | Play Wacky Workbench present music
	dc.w	SPCmd_PlayR6CMus-.SPCmds	; $1C | Play Wacky Workbench good future music
	dc.w	SPCmd_PlayR6DMus-.SPCmds	; $1D | Play Wacky Workbench bad future music
	dc.w	SPCmd_PlayR7AMus-.SPCmds	; $1E | Play Stardust Speedway present music
	dc.w	SPCmd_PlayR7CMus-.SPCmds	; $1F | Play Stardust Speedway good future music
	dc.w	SPCmd_PlayR7DMus-.SPCmds	; $20 | Play Stardust Speedway bad future music
	dc.w	SPCmd_PlayR8AMus-.SPCmds	; $21 | Play Metallic Madness present music
	dc.w	SPCmd_PlayR8CMus-.SPCmds	; $22 | Play Metallic Madness good future music
	dc.w	SPCmd_LoadIPX-.SPCmds		; $23 | Load main program
	dc.w	SPCmd_LoadLevel-.SPCmds		; $24 | Load Tidal Tempest Act 3 good future demo
	dc.w	SPCmd_LoadLevel-.SPCmds		; $25 | Load Metallic Madness Act 2 present demo
	dc.w	SPCmd_LoadSndTest-.SPCmds	; $26 | Load sound test
	dc.w	SPCmd_LoadLevel-.SPCmds		; $27 | Invalid
	dc.w	SPCmd_LoadLevel-.SPCmds		; $28 | Load Collision Chaos Act 1 present
	dc.w	SPCmd_LoadLevel-.SPCmds		; $29 | Load Collision Chaos Act 1 past
	dc.w	SPCmd_LoadLevel-.SPCmds		; $2A | Load Collision Chaos Act 1 good future
	dc.w	SPCmd_LoadLevel-.SPCmds		; $2B | Load Collision Chaos Act 1 bad future
	dc.w	SPCmd_LoadLevel-.SPCmds		; $2C | Load Collision Chaos Act 2 present 
	dc.w	SPCmd_LoadLevel-.SPCmds		; $2D | Load Collision Chaos Act 2 past 
	dc.w	SPCmd_LoadLevel-.SPCmds		; $2E | Load Collision Chaos Act 2 good future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; $2F | Load Collision Chaos Act 2 bad future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; $30 | Load Collision Chaos Act 3 good future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; $31 | Load Collision Chaos Act 3 bad future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; $32 | Load Palmtree Panic Act 3 good future
	dc.w	SPCmd_LoadLevel-.SPCmds		; $33 | Load Palmtree Panic Act 3 bad future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; $34 | Load Tidal Tempest Act 1 present
	dc.w	SPCmd_LoadLevel-.SPCmds		; $35 | Load Tidal Tempest Act 1 past
	dc.w	SPCmd_LoadLevel-.SPCmds		; $36 | Load Tidal Tempest Act 1 good future
	dc.w	SPCmd_LoadLevel-.SPCmds		; $37 | Load Tidal Tempest Act 1 bad future
	dc.w	SPCmd_LoadLevel-.SPCmds		; $38 | Load Tidal Tempest Act 2 present 
	dc.w	SPCmd_LoadLevel-.SPCmds		; $39 | Load Tidal Tempest Act 2 past 
	dc.w	SPCmd_LoadLevel-.SPCmds		; $3A | Load Tidal Tempest Act 2 good future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; $3B | Load Tidal Tempest Act 2 bad future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; $3C | Load Tidal Tempest Act 3 good future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; $3D | Load Tidal Tempest Act 3 bad future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; $3E | Load Quartz Quadrant Act 1 present
	dc.w	SPCmd_LoadLevel-.SPCmds		; $3F | Load Quartz Quadrant Act 1 past
	dc.w	SPCmd_LoadLevel-.SPCmds		; $40 | Load Quartz Quadrant Act 1 good future
	dc.w	SPCmd_LoadLevel-.SPCmds		; $41 | Load Quartz Quadrant Act 1 bad future
	dc.w	SPCmd_LoadLevel-.SPCmds		; $42 | Load Quartz Quadrant Act 2 present 
	dc.w	SPCmd_LoadLevel-.SPCmds		; $43 | Load Quartz Quadrant Act 2 past 
	dc.w	SPCmd_LoadLevel-.SPCmds		; $44 | Load Quartz Quadrant Act 2 good future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; $45 | Load Quartz Quadrant Act 2 bad future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; $46 | Load Quartz Quadrant Act 3 good future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; $47 | Load Quartz Quadrant Act 3 bad future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; $48 | Load Wacky Workbench Act 1 present
	dc.w	SPCmd_LoadLevel-.SPCmds		; $49 | Load Wacky Workbench Act 1 past
	dc.w	SPCmd_LoadLevel-.SPCmds		; $4A | Load Wacky Workbench Act 1 good future
	dc.w	SPCmd_LoadLevel-.SPCmds		; $4B | Load Wacky Workbench Act 1 bad future
	dc.w	SPCmd_LoadLevel-.SPCmds		; $4C | Load Wacky Workbench Act 2 present 
	dc.w	SPCmd_LoadLevel-.SPCmds		; $4D | Load Wacky Workbench Act 2 past 
	dc.w	SPCmd_LoadLevel-.SPCmds		; $4E | Load Wacky Workbench Act 2 good future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; $4F | Load Wacky Workbench Act 2 bad future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; $50 | Load Wacky Workbench Act 3 good future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; $51 | Load Wacky Workbench Act 3 bad future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; $52 | Load Stardust Speedway Act 1 present
	dc.w	SPCmd_LoadLevel-.SPCmds		; $53 | Load Stardust Speedway Act 1 past
	dc.w	SPCmd_LoadLevel-.SPCmds		; $54 | Load Stardust Speedway Act 1 good future
	dc.w	SPCmd_LoadLevel-.SPCmds		; $55 | Load Stardust Speedway Act 1 bad future
	dc.w	SPCmd_LoadLevel-.SPCmds		; $56 | Load Stardust Speedway Act 2 present 
	dc.w	SPCmd_LoadLevel-.SPCmds		; $57 | Load Stardust Speedway Act 2 past 
	dc.w	SPCmd_LoadLevel-.SPCmds		; $58 | Load Stardust Speedway Act 2 good future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; $59 | Load Stardust Speedway Act 2 bad future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; $5A | Load Stardust Speedway Act 3 good future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; $5B | Load Stardust Speedway Act 3 bad future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; $5C | Load Metallic Madness Act 1 present
	dc.w	SPCmd_LoadLevel-.SPCmds		; $5D | Load Metallic Madness Act 1 past
	dc.w	SPCmd_LoadLevel-.SPCmds		; $5E | Load Metallic Madness Act 1 good future
	dc.w	SPCmd_LoadLevel-.SPCmds		; $5F | Load Metallic Madness Act 1 bad future
	dc.w	SPCmd_LoadLevel-.SPCmds		; $60 | Load Metallic Madness Act 2 present 
	dc.w	SPCmd_LoadLevel-.SPCmds		; $61 | Load Metallic Madness Act 2 past 
	dc.w	SPCmd_LoadLevel-.SPCmds		; $62 | Load Metallic Madness Act 2 good future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; $63 | Load Metallic Madness Act 2 bad future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; $64 | Load Metallic Madness Act 3 good future 
	dc.w	SPCmd_LoadLevel-.SPCmds		; $65 | Load Metallic Madness Act 3 bad future 
	dc.w	SPCmd_PlayR8DMus-.SPCmds	; $66 | Play Metallic Madness bad future music
	dc.w	SPCmd_PlayBossMus-.SPCmds	; $67 | Play boss music
	dc.w	SPCmd_PlayFinalMus-.SPCmds	; $68 | Play final boss music
	dc.w	SPCmd_PlayTitleMus-.SPCmds	; $69 | Play title screen music
	dc.w	SPCmd_PlayTimeAtkMus-.SPCmds	; $6A | Play time attack menu music
	dc.w	SPCmd_PlayLvlEndMus-.SPCmds	; $6B | Play level end music
	dc.w	SPCmd_PlayShoesMus-.SPCmds	; $6C | Play speed shoes music
	dc.w	SPCmd_PlayInvincMus-.SPCmds	; $6D | Play invincibility music
	dc.w	SPCmd_PlayGameOverMus-.SPCmds	; $6E | Play game over music
	dc.w	SPCmd_PlaySpecialMus-.SPCmds	; $6F | Play special stage music
	dc.w	SPCmd_PlayDAGardenMus-.SPCmds	; $70 | Play D.A. Garden music
	dc.w	SPCmd_PlayProtoWarp-.SPCmds	; $71 | Play prototype warp sound
	dc.w	SPCmd_PlayIntroMus-.SPCmds	; $72 | Play opening music
	dc.w	SPCmd_PlayEndingMus-.SPCmds	; $73 | Play ending music
	dc.w	SPCmd_StopCDDA-.SPCmds		; $74 | Stop CDDA music
	dc.w	SPCmd_LoadSpecStage-.SPCmds	; $75 | Load special stage
	dc.w	SPCmd_PlayFutureSFX-.SPCmds	; $76 | Play "Future" voice clip
	dc.w	SPCmd_PlayPastSFX-.SPCmds	; $77 | Play "Past" voice clip
	dc.w	SPCmd_PlayAlrightSFX-.SPCmds	; $78 | Play "Alright" voice clip
	dc.w	SPCmd_PlayGiveUpSFX-.SPCmds	; $79 | Play "I'm outta here" voice clip
	dc.w	SPCmd_PlayYesSFX-.SPCmds	; $7A | Play "Yes" voice clip
	dc.w	SPCmd_PlayYeahSFX-.SPCmds	; $7B | Play "Yeah" voice clip
	dc.w	SPCmd_PlayGiggleSFX-.SPCmds	; $7C | Play Amy giggle voice clip
	dc.w	SPCmd_PlayAmyYelpSFX-.SPCmds	; $7D | Play Amy yelp voice clip
	dc.w	SPCmd_PlayStompSFX-.SPCmds	; $7E | Play boss stomp sound
	dc.w	SPCmd_PlayBumperSFX-.SPCmds	; $7F | Play bumper sound
	dc.w	SPCmd_PlayPastMus-.SPCmds	; $80 | Play past music
	dc.w	SPCmd_LoadDAGarden-.SPCmds	; $81 | Load D.A. Garden
	dc.w	SPCmd_FadeOutPCM-.SPCmds	; $82 | Fade out PCM
	dc.w	SPCmd_StopPCM-.SPCmds		; $83 | Stop PCM
	dc.w	SPCmd_LoadLevel-.SPCmds		; $84 | Load Palmtree Panic Act 1 present demo
	dc.w	SPCmd_LoadVisualMode-.SPCmds	; $85 | Load Visual Mode menu
	dc.w	SPCmd_ResetSSFlags2-.SPCmds	; $86 | Reset special stage flags
	dc.w	SPCmd_ReadSaveData-.SPCmds	; $87 | Read save data
	dc.w	SPCmd_WriteSaveData-.SPCmds	; $88 | Write save data
	dc.w	SPCmd_LoadBuRAMInit-.SPCmds	; $89 | Load Backup RAM initialization
	dc.w	SPCmd_ResetSSFlags-.SPCmds	; $8A | Reset special stage flags
	dc.w	SPCmd_ReadTempSaveData-.SPCmds	; $8B | Read temporary save data
	dc.w	SPCmd_WriteTempSaveData-.SPCmds	; $8C | Write temporary save data
	dc.w	SPCmd_LoadThankYou-.SPCmds	; $8D | Load "Thank You" screen
	dc.w	SPCmd_LoadBuRAMMngr-.SPCmds	; $8E | Load Backup RAM manager
	dc.w	SPCmd_ResetCDDAVol-.SPCmds	; $8F | Reset CDDA music volume
	dc.w	SPCmd_PausePCM-.SPCmds		; $90 | Pause PCM
	dc.w	SPCmd_UnpausePCM-.SPCmds	; $91 | Unpause PCM
	dc.w	SPCmd_PlayBreakSFX-.SPCmds	; $92 | Play glass break sound
	dc.w	SPCmd_LoadGoodEnd-.SPCmds	; $93 | Load good ending FMV
	dc.w	SPCmd_LoadBadEnd-.SPCmds	; $94 | Load bad ending FMV
	dc.w	SPCmd_TestR1AMus-.SPCmds	; $95 | Play Palmtree Panic present music (sound test)
	dc.w	SPCmd_TestR1CMus-.SPCmds	; $96 | Play Palmtree Panic good future music (sound test)
	dc.w	SPCmd_TestR1DMus-.SPCmds	; $97 | Play Palmtree Panic bad future music (sound test)
	dc.w	SPCmd_TestR3AMus-.SPCmds	; $98 | Play Collision Chaos present music (sound test)
	dc.w	SPCmd_TestR3CMus-.SPCmds	; $99 | Play Collision Chaos good future music (sound test)
	dc.w	SPCmd_TestR3DMus-.SPCmds	; $9A | Play Collision Chaos bad future music (sound test)
	dc.w	SPCmd_TestR4AMus-.SPCmds	; $9B | Play Tidal Tempest present music (sound test)
	dc.w	SPCmd_TestR4CMus-.SPCmds	; $9C | Play Tidal Tempest good future music (sound test)
	dc.w	SPCmd_TestR4DMus-.SPCmds	; $9D | Play Tidal Tempest bad future music (sound test)
	dc.w	SPCmd_TestR5AMus-.SPCmds	; $9E | Play Quartz Quadrant present music (sound test)
	dc.w	SPCmd_TestR5CMus-.SPCmds	; $9F | Play Quartz Quadrant good future music (sound test)
	dc.w	SPCmd_TestR5DMus-.SPCmds	; $A0 | Play Quartz Quadrant bad future music (sound test)
	dc.w	SPCmd_TestR6AMus-.SPCmds	; $A1 | Play Wacky Workbench present music (sound test)
	dc.w	SPCmd_TestR6CMus-.SPCmds	; $A2 | Play Wacky Workbench good future music (sound test)
	dc.w	SPCmd_TestR6DMus-.SPCmds	; $A3 | Play Wacky Workbench bad future music (sound test)
	dc.w	SPCmd_TestR7AMus-.SPCmds	; $A4 | Play Stardust Speedway present music (sound test)
	dc.w	SPCmd_TestR7CMus-.SPCmds	; $A5 | Play Stardust Speedway good future music (sound test)
	dc.w	SPCmd_TestR7DMus-.SPCmds	; $A6 | Play Stardust Speedway bad future music (sound test)
	dc.w	SPCmd_TestR8AMus-.SPCmds	; $A7 | Play Metallic Madness present music (sound test)
	dc.w	SPCmd_TestR8CMus-.SPCmds	; $A8 | Play Metallic Madness good future music (sound test)
	dc.w	SPCmd_TestR8DMus-.SPCmds	; $A9 | Play Metallic Madness bad future music (sound test)
	dc.w	SPCmd_TestBossMus-.SPCmds	; $AA | Play boss music (sound test)
	dc.w	SPCmd_TestFinalMus-.SPCmds	; $AB | Play final boss music (sound test)
	dc.w	SPCmd_TestTitleMus-.SPCmds	; $AC | Play title screen music (sound test)
	dc.w	SPCmd_TestTimeAtkMus-.SPCmds	; $AD | Play time attack music (sound test)
	dc.w	SPCmd_TestLvlEndMus-.SPCmds	; $AE | Play level end music (sound test)
	dc.w	SPCmd_TestShoesMus-.SPCmds	; $AF | Play speed shoes music (sound test)
	dc.w	SPCmd_TestInvincMus-.SPCmds	; $B0 | Play invincibility music (sound test)
	dc.w	SPCmd_TestGameOverMus-.SPCmds	; $B1 | Play game over music (sound test)
	dc.w	SPCmd_TestSpecialMus-.SPCmds	; $B2 | Play special stage music (sound test)
	dc.w	SPCmd_TestDAGardenMus-.SPCmds	; $B3 | Play D.A. Garden music (sound test)
	dc.w	SPCmd_TestProtoWarp-.SPCmds	; $B4 | Play prototype warp sound (sound test)
	dc.w	SPCmd_TestIntroMus-.SPCmds	; $B5 | Play opening music (sound test)
	dc.w	SPCmd_TestEndingMus-.SPCmds	; $B6 | Play ending music (sound test)
	dc.w	SPCmd_TestFutureSFX-.SPCmds	; $B7 | Play "Future" voice clip (sound test)
	dc.w	SPCmd_TestPastSFX-.SPCmds	; $B8 | Play "Past" voice clip (sound test)
	dc.w	SPCmd_TestAlrightSFX-.SPCmds	; $B9 | Play "Alright" voice clip (sound test)
	dc.w	SPCmd_TestGiveUpSFX-.SPCmds	; $BA | Play "I'm outta here" voice clip (sound test)
	dc.w	SPCmd_TestYesSFX-.SPCmds	; $BB | Play "Yes" voice clip (sound test)
	dc.w	SPCmd_TestYeahSFX-.SPCmds	; $BC | Play "Yeah" voice clip (sound test)
	dc.w	SPCmd_TestGiggleSFX-.SPCmds	; $BD | Play Amy giggle voice clip (sound test)
	dc.w	SPCmd_TestAmyYelpSFX-.SPCmds	; $BE | Play Amy yelp voice clip (sound test)
	dc.w	SPCmd_TestStompSFX-.SPCmds	; $BF | Play boss stomp sound (sound test)
	dc.w	SPCmd_TestBumperSFX-.SPCmds	; $C0 | Play bumper sound (sound test)
	dc.w	SPCmd_TestR1BMus-.SPCmds	; $C1 | Play Palmtree Panic past music (sound test)
	dc.w	SPCmd_TestR3BMus-.SPCmds	; $C2 | Play Collision Chaos past music (sound test)
	dc.w	SPCmd_TestR4BMus-.SPCmds	; $C3 | Play Tidal Tempest past music (sound test)
	dc.w	SPCmd_TestR5BMus-.SPCmds	; $C4 | Play Quartz Quadrant past music (sound test)
	dc.w	SPCmd_TestR6BMus-.SPCmds	; $C5 | Play Palmtree Panic past music (sound test)
	dc.w	SPCmd_TestR7BMus-.SPCmds	; $C6 | Play Palmtree Panic past music (sound test)
	dc.w	SPCmd_TestR8BMus-.SPCmds	; $C7 | Play Palmtree Panic past music (sound test)
	dc.w	SPCmd_LoadFunIsInf-.SPCmds	; $C8 | Load "Fun is infinite" screen
	dc.w	SPCmd_LoadStaffCreds-.SPCmds	; $C9 | Load staff credits
	dc.w	SPCmd_LoadMCSonic-.SPCmds	; $CA | Load M.C. Sonic screen
	dc.w	SPCmd_LoadTails-.SPCmds		; $CB | Load Tails screen
	dc.w	SPCmd_LoadBatmanSonic-.SPCmds	; $CC | Load Batman Sonic screen
	dc.w	SPCmd_LoadCuteSonic-.SPCmds	; $CD | Load cute Sonic screen
	dc.w	SPCmd_LoadStaffTimes-.SPCmds	; $CE | Load best staff times screen
	dc.w	SPCmd_LoadDummyFile1-.SPCmds	; $CF | Load dummy file (unused)
	dc.w	SPCmd_LoadDummyFile2-.SPCmds	; $D0 | Load dummy file (unused)
	dc.w	SPCmd_LoadDummyFile3-.SPCmds	; $D1 | Load dummy file (unused)
	dc.w	SPCmd_LoadDummyFile4-.SPCmds	; $D2 | Load dummy file (unused)
	dc.w	SPCmd_LoadDummyFile5-.SPCmds	; $D3 | Load dummy file (unused)
	dc.w	SPCmd_LoadPencilTest-.SPCmds	; $D4 | Load pencil test FMV
	dc.w	SPCmd_PauseCDDA-.SPCmds		; $D5 | Pause CDDA music
	dc.w	SPCmd_UnpauseCDDA-.SPCmds	; $D6 | Unpause CDDA music
	dc.w	SPCmd_LoadOpening-.SPCmds	; $D7 | Load opening FMV
	dc.w	SPCmd_LoadCominSoon-.SPCmds	; $D8 | Load "Comin' Soon" screen
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
	move.b	d0,GACOMSTATA.w
	move.b	d0,GACOMSTAT3.w
	move.l	d0,GACOMSTAT6.w
	move.w	d0,GACOMSTAT4.w
	bra.w	SPCmdFinish

; -------------------------------------------------------------------------
; Reset special stage flags
; -------------------------------------------------------------------------

SPCmd_ResetSSFlags2:
	moveq	#0,d0
	move.b	d0,GACOMSTATA.w
	move.b	d0,GACOMSTAT3.w
	move.l	d0,GACOMSTAT6.w
	move.w	d0,GACOMSTAT4.w
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
	dc.w	File_R11A-.LevelFiles		; $00 | Invalid
	dc.w	File_R11A-.LevelFiles		; $01 | Palmtree Panic Act 1 present
	dc.w	File_R11B-.LevelFiles		; $02 | Palmtree Panic Act 1 past
	dc.w	File_R11C-.LevelFiles		; $03 | Palmtree Panic Act 1 good future
	dc.w	File_R11D-.LevelFiles		; $04 | Palmtree Panic Act 1 bad future
	dc.w	File_R11A-.LevelFiles		; $05 | Invalid
	dc.w	File_R11A-.LevelFiles		; $06 | Invalid
	dc.w	File_R12A-.LevelFiles		; $07 | Palmtree Panic Act 2 present
	dc.w	File_R12B-.LevelFiles		; $08 | Palmtree Panic Act 2 past
	dc.w	File_R12C-.LevelFiles		; $09 | Palmtree Panic Act 2 good future
	dc.w	File_R12D-.LevelFiles		; $0A | Palmtree Panic Act 2 bad future
	dc.w	File_R11A-.LevelFiles		; $0B | Invalid
	dc.w	File_R11A-.LevelFiles		; $0C | Invalid
	dc.w	File_R11A-.LevelFiles		; $0D | Invalid
	dc.w	File_R11A-.LevelFiles		; $0E | Invalid
	dc.w	File_R11A-.LevelFiles		; $0F | Invalid
	dc.w	File_R11A-.LevelFiles		; $10 | Invalid
	dc.w	File_R11A-.LevelFiles		; $11 | Invalid
	dc.w	File_R11A-.LevelFiles		; $12 | Invalid
	dc.w	File_R11A-.LevelFiles		; $13 | Invalid
	dc.w	File_R11A-.LevelFiles		; $14 | Invalid
	dc.w	File_R11A-.LevelFiles		; $15 | Invalid
	dc.w	File_R11A-.LevelFiles		; $16 | Invalid
	dc.w	File_R11A-.LevelFiles		; $17 | Invalid
	dc.w	File_R11A-.LevelFiles		; $18 | Invalid
	dc.w	File_R11A-.LevelFiles		; $19 | Invalid
	dc.w	File_R11A-.LevelFiles		; $1A | Invalid
	dc.w	File_R11A-.LevelFiles		; $1B | Invalid
	dc.w	File_R11A-.LevelFiles		; $1C | Invalid
	dc.w	File_R11A-.LevelFiles		; $1D | Invalid
	dc.w	File_R11A-.LevelFiles		; $1E | Invalid
	dc.w	File_R11A-.LevelFiles		; $1F | Invalid
	dc.w	File_R11A-.LevelFiles		; $20 | Invalid
	dc.w	File_R11A-.LevelFiles		; $21 | Invalid
	dc.w	File_R11A-.LevelFiles		; $22 | Invalid
	dc.w	File_R11A-.LevelFiles		; $23 | Invalid
	dc.w	File_Demo43C-.LevelFiles	; $24 | Tidal Tempest Act 3 good future demo
	dc.w	File_Demo82A-.LevelFiles	; $25 | Metallic Madness Act 2 present demo
	dc.w	File_R11A-.LevelFiles		; $26 | Invalid
	dc.w	File_R11A-.LevelFiles		; $27 | Invalid
	dc.w	File_R31A-.LevelFiles		; $28 | Collision Chaos Act 1 present
	dc.w	File_R31B-.LevelFiles		; $29 | Collision Chaos Act 1 past
	dc.w	File_R31C-.LevelFiles		; $2A | Collision Chaos Act 1 good future
	dc.w	File_R31D-.LevelFiles		; $2B | Collision Chaos Act 1 bad future
	dc.w	File_R32A-.LevelFiles		; $2C | Collision Chaos Act 2 present 
	dc.w	File_R32B-.LevelFiles		; $2D | Collision Chaos Act 2 past 
	dc.w	File_R32C-.LevelFiles		; $2E | Collision Chaos Act 2 good future 
	dc.w	File_R32D-.LevelFiles		; $2F | Collision Chaos Act 2 bad future 
	dc.w	File_R33C-.LevelFiles		; $30 | Collision Chaos Act 3 good future 
	dc.w	File_R33D-.LevelFiles		; $31 | Collision Chaos Act 3 bad future 
	dc.w	File_R13C-.LevelFiles		; $32 | Palmtree Panic Act 3 good future
	dc.w	File_R13D-.LevelFiles		; $33 | Palmtree Panic Act 3 bad future 
	dc.w	File_R41A-.LevelFiles		; $34 | Tidal Tempest Act 1 present
	dc.w	File_R41B-.LevelFiles		; $35 | Tidal Tempest Act 1 past
	dc.w	File_R41C-.LevelFiles		; $36 | Tidal Tempest Act 1 good future
	dc.w	File_R41D-.LevelFiles		; $37 | Tidal Tempest Act 1 bad future
	dc.w	File_R42A-.LevelFiles		; $38 | Tidal Tempest Act 2 present 
	dc.w	File_R42B-.LevelFiles		; $39 | Tidal Tempest Act 2 past 
	dc.w	File_R42C-.LevelFiles		; $3A | Tidal Tempest Act 2 good future 
	dc.w	File_R42D-.LevelFiles		; $3B | Tidal Tempest Act 2 bad future 
	dc.w	File_R43C-.LevelFiles		; $3C | Tidal Tempest Act 3 good future 
	dc.w	File_R43D-.LevelFiles		; $3D | Tidal Tempest Act 3 bad future 
	dc.w	File_R51A-.LevelFiles		; $3E | Quartz Quadrant Act 1 present
	dc.w	File_R51B-.LevelFiles		; $3F | Quartz Quadrant Act 1 past
	dc.w	File_R51C-.LevelFiles		; $40 | Quartz Quadrant Act 1 good future
	dc.w	File_R51D-.LevelFiles		; $41 | Quartz Quadrant Act 1 bad future
	dc.w	File_R52A-.LevelFiles		; $42 | Quartz Quadrant Act 2 present 
	dc.w	File_R52B-.LevelFiles		; $43 | Quartz Quadrant Act 2 past 
	dc.w	File_R52C-.LevelFiles		; $44 | Quartz Quadrant Act 2 good future 
	dc.w	File_R52D-.LevelFiles		; $45 | Quartz Quadrant Act 2 bad future 
	dc.w	File_R53C-.LevelFiles		; $46 | Quartz Quadrant Act 3 good future 
	dc.w	File_R53D-.LevelFiles		; $47 | Quartz Quadrant Act 3 bad future 
	dc.w	File_R61A-.LevelFiles		; $48 | Wacky Workbench Act 1 present
	dc.w	File_R61B-.LevelFiles		; $49 | Wacky Workbench Act 1 past
	dc.w	File_R61C-.LevelFiles		; $4A | Wacky Workbench Act 1 good future
	dc.w	File_R61D-.LevelFiles		; $4B | Wacky Workbench Act 1 bad future
	dc.w	File_R62A-.LevelFiles		; $4C | Wacky Workbench Act 2 present 
	dc.w	File_R62B-.LevelFiles		; $4D | Wacky Workbench Act 2 past 
	dc.w	File_R62C-.LevelFiles		; $4E | Wacky Workbench Act 2 good future 
	dc.w	File_R62D-.LevelFiles		; $4F | Wacky Workbench Act 2 bad future 
	dc.w	File_R63C-.LevelFiles		; $50 | Wacky Workbench Act 3 good future 
	dc.w	File_R63D-.LevelFiles		; $51 | Wacky Workbench Act 3 bad future 
	dc.w	File_R71A-.LevelFiles		; $52 | Stardust Speedway Act 1 present
	dc.w	File_R71B-.LevelFiles		; $53 | Stardust Speedway Act 1 past
	dc.w	File_R71C-.LevelFiles		; $54 | Stardust Speedway Act 1 good future
	dc.w	File_R71D-.LevelFiles		; $55 | Stardust Speedway Act 1 bad future
	dc.w	File_R72A-.LevelFiles		; $56 | Stardust Speedway Act 2 present 
	dc.w	File_R72B-.LevelFiles		; $57 | Stardust Speedway Act 2 past 
	dc.w	File_R72C-.LevelFiles		; $58 | Stardust Speedway Act 2 good future 
	dc.w	File_R72D-.LevelFiles		; $59 | Stardust Speedway Act 2 bad future 
	dc.w	File_R73C-.LevelFiles		; $5A | Stardust Speedway Act 3 good future 
	dc.w	File_R73D-.LevelFiles		; $5B | Stardust Speedway Act 3 bad future 
	dc.w	File_R81A-.LevelFiles		; $5C | Metallic Madness Act 1 present
	dc.w	File_R81B-.LevelFiles		; $5D | Metallic Madness Act 1 past
	dc.w	File_R81C-.LevelFiles		; $5E | Metallic Madness Act 1 good future
	dc.w	File_R81D-.LevelFiles		; $5F | Metallic Madness Act 1 bad future
	dc.w	File_R82A-.LevelFiles		; $60 | Metallic Madness Act 2 present 
	dc.w	File_R82B-.LevelFiles		; $61 | Metallic Madness Act 2 past 
	dc.w	File_R82C-.LevelFiles		; $62 | Metallic Madness Act 2 good future 
	dc.w	File_R82D-.LevelFiles		; $63 | Metallic Madness Act 2 bad future 
	dc.w	File_R83C-.LevelFiles		; $64 | Metallic Madness Act 3 good future 
	dc.w	File_R83D-.LevelFiles		; $65 | Metallic Madness Act 3 bad future 
	dc.w	File_R11A-.LevelFiles		; $66 | Invalid
	dc.w	File_R11A-.LevelFiles		; $67 | Invalid
	dc.w	File_R11A-.LevelFiles		; $68 | Invalid
	dc.w	File_R11A-.LevelFiles		; $69 | Invalid
	dc.w	File_R11A-.LevelFiles		; $6A | Invalid
	dc.w	File_R11A-.LevelFiles		; $6B | Invalid
	dc.w	File_R11A-.LevelFiles		; $6C | Invalid
	dc.w	File_R11A-.LevelFiles		; $6D | Invalid
	dc.w	File_R11A-.LevelFiles		; $6E | Invalid
	dc.w	File_R11A-.LevelFiles		; $6F | Invalid
	dc.w	File_R11A-.LevelFiles		; $70 | Invalid
	dc.w	File_R11A-.LevelFiles		; $71 | Invalid
	dc.w	File_R11A-.LevelFiles		; $72 | Invalid
	dc.w	File_R11A-.LevelFiles		; $73 | Invalid
	dc.w	File_R11A-.LevelFiles		; $74 | Invalid
	dc.w	File_R11A-.LevelFiles		; $75 | Invalid
	dc.w	File_R11A-.LevelFiles		; $76 | Invalid
	dc.w	File_R11A-.LevelFiles		; $77 | Invalid
	dc.w	File_R11A-.LevelFiles		; $78 | Invalid
	dc.w	File_R11A-.LevelFiles		; $79 | Invalid
	dc.w	File_R11A-.LevelFiles		; $7A | Invalid
	dc.w	File_R11A-.LevelFiles		; $7B | Invalid
	dc.w	File_R11A-.LevelFiles		; $7C | Invalid
	dc.w	File_R11A-.LevelFiles		; $7D | Invalid
	dc.w	File_R11A-.LevelFiles		; $7E | Invalid
	dc.w	File_R11A-.LevelFiles		; $7F | Invalid
	dc.w	File_R11A-.LevelFiles		; $80 | Invalid
	dc.w	File_R11A-.LevelFiles		; $81 | Invalid
	dc.w	File_R11A-.LevelFiles		; $82 | Invalid
	dc.w	File_R11A-.LevelFiles		; $83 | Invalid
	dc.w	File_Demo11A-.LevelFiles	; $84 | Palmtree Panic Act 1 present demo
	dc.w	File_R11A-.LevelFiles		; $85 | Invalid
	dc.w	File_R11A-.LevelFiles		; $86 | Invalid
	dc.w	File_R11A-.LevelFiles		; $87 | Invalid
	dc.w	File_R11A-.LevelFiles		; $88 | Invalid
	dc.w	File_R11A-.LevelFiles		; $89 | Invalid
	dc.w	File_R11A-.LevelFiles		; $8A | Invalid
	dc.w	File_R11A-.LevelFiles		; $8B | Invalid
	dc.w	File_R11A-.LevelFiles		; $8C | Invalid
	dc.w	File_R11A-.LevelFiles		; $8D | Invalid
	dc.w	File_R11A-.LevelFiles		; $8E | Invalid
	dc.w	File_R11A-.LevelFiles		; $8F | Invalid
	dc.w	File_R11A-.LevelFiles		; $90 | Invalid
	dc.w	File_R11A-.LevelFiles		; $91 | Invalid
	dc.w	File_R11A-.LevelFiles		; $92 | Invalid
	dc.w	File_R11A-.LevelFiles		; $93 | Invalid
	dc.w	File_R11A-.LevelFiles		; $94 | Invalid
	dc.w	File_R11A-.LevelFiles		; $95 | Invalid

; -------------------------------------------------------------------------
; PCM drivers
; -------------------------------------------------------------------------

.PCMDrivers:
	dc.l	File_R11A			; $00 | Invalid
	dc.l	File_R1PCM			; $01 | Palmtree Panic Act 1 present
	dc.l	File_R1PCM			; $02 | Palmtree Panic Act 1 past
	dc.l	File_R1PCM			; $03 | Palmtree Panic Act 1 good future
	dc.l	File_R1PCM			; $04 | Palmtree Panic Act 1 bad future
	dc.l	File_R11A			; $05 | Invalid
	dc.l	File_R11A			; $06 | Invalid
	dc.l	File_R1PCM			; $07 | Palmtree Panic Act 2 present
	dc.l	File_R1PCM			; $08 | Palmtree Panic Act 2 past
	dc.l	File_R1PCM			; $09 | Palmtree Panic Act 2 good future
	dc.l	File_R1PCM			; $0A | Palmtree Panic Act 2 bad future
	dc.l	File_R11A			; $0B | Invalid
	dc.l	File_R11A			; $0C | Invalid
	dc.l	File_R11A			; $0D | Invalid
	dc.l	File_R11A			; $0E | Invalid
	dc.l	File_R11A			; $0F | Invalid
	dc.l	File_R11A			; $10 | Invalid
	dc.l	File_R11A			; $11 | Invalid
	dc.l	File_R11A			; $12 | Invalid
	dc.l	File_R11A			; $13 | Invalid
	dc.l	File_R11A			; $14 | Invalid
	dc.l	File_R11A			; $15 | Invalid
	dc.l	File_R11A			; $16 | Invalid
	dc.l	File_R11A			; $17 | Invalid
	dc.l	File_R11A			; $18 | Invalid
	dc.l	File_R11A			; $19 | Invalid
	dc.l	File_R11A			; $1A | Invalid
	dc.l	File_R11A			; $1B | Invalid
	dc.l	File_R11A			; $1C | Invalid
	dc.l	File_R11A			; $1D | Invalid
	dc.l	File_R11A			; $1E | Invalid
	dc.l	File_R11A			; $1F | Invalid
	dc.l	File_R11A			; $20 | Invalid
	dc.l	File_R11A			; $21 | Invalid
	dc.l	File_R11A			; $22 | Invalid
	dc.l	File_R11A			; $23 | Invalid
	dc.l	File_BossPCM			; $24 | Tidal Tempest Act 3 good future demo
	dc.l	File_R8PCM			; $25 | Metallic Madness Act 2 present demo
	dc.l	File_R11A			; $26 | Invalid
	dc.l	File_R11A			; $27 | Invalid
	dc.l	File_R3PCM			; $28 | Collision Chaos Act 1 present
	dc.l	File_R3PCM			; $29 | Collision Chaos Act 1 past
	dc.l	File_R3PCM			; $2A | Collision Chaos Act 1 good future
	dc.l	File_R3PCM			; $2B | Collision Chaos Act 1 bad future
	dc.l	File_R3PCM			; $2C | Collision Chaos Act 2 present 
	dc.l	File_R3PCM			; $2D | Collision Chaos Act 2 past 
	dc.l	File_R3PCM			; $2E | Collision Chaos Act 2 good future 
	dc.l	File_R3PCM			; $2F | Collision Chaos Act 2 bad future 
	dc.l	File_R3PCM			; $30 | Collision Chaos Act 3 good future 
	dc.l	File_R3PCM			; $31 | Collision Chaos Act 3 bad future 
	dc.l	File_BossPCM			; $32 | Palmtree Panic Act 3 good future
	dc.l	File_BossPCM			; $33 | Palmtree Panic Act 3 bad future 
	dc.l	File_R4PCM			; $34 | Tidal Tempest Act 1 present
	dc.l	File_R4PCM			; $35 | Tidal Tempest Act 1 past
	dc.l	File_R4PCM			; $36 | Tidal Tempest Act 1 good future
	dc.l	File_R4PCM			; $37 | Tidal Tempest Act 1 bad future
	dc.l	File_R4PCM			; $38 | Tidal Tempest Act 2 present 
	dc.l	File_R4PCM			; $39 | Tidal Tempest Act 2 past 
	dc.l	File_R4PCM			; $3A | Tidal Tempest Act 2 good future 
	dc.l	File_R4PCM			; $3B | Tidal Tempest Act 2 bad future 
	dc.l	File_BossPCM			; $3C | Tidal Tempest Act 3 good future 
	dc.l	File_BossPCM			; $3D | Tidal Tempest Act 3 bad future 
	dc.l	File_R5PCM			; $3E | Quartz Quadrant Act 1 present
	dc.l	File_R5PCM			; $3F | Quartz Quadrant Act 1 past
	dc.l	File_R5PCM			; $40 | Quartz Quadrant Act 1 good future
	dc.l	File_R5PCM			; $41 | Quartz Quadrant Act 1 bad future
	dc.l	File_R5PCM			; $42 | Quartz Quadrant Act 2 present 
	dc.l	File_R5PCM			; $43 | Quartz Quadrant Act 2 past 
	dc.l	File_R5PCM			; $44 | Quartz Quadrant Act 2 good future 
	dc.l	File_R5PCM			; $45 | Quartz Quadrant Act 2 bad future 
	dc.l	File_BossPCM			; $46 | Quartz Quadrant Act 3 good future 
	dc.l	File_BossPCM			; $47 | Quartz Quadrant Act 3 bad future 
	dc.l	File_R6PCM			; $48 | Wacky Workbench Act 1 present
	dc.l	File_R6PCM			; $49 | Wacky Workbench Act 1 past
	dc.l	File_R6PCM			; $4A | Wacky Workbench Act 1 good future
	dc.l	File_R6PCM			; $4B | Wacky Workbench Act 1 bad future
	dc.l	File_R6PCM			; $4C | Wacky Workbench Act 2 present 
	dc.l	File_R6PCM			; $4D | Wacky Workbench Act 2 past 
	dc.l	File_R6PCM			; $4E | Wacky Workbench Act 2 good future 
	dc.l	File_R6PCM			; $4F | Wacky Workbench Act 2 bad future 
	dc.l	File_BossPCM			; $50 | Wacky Workbench Act 3 good future 
	dc.l	File_BossPCM			; $51 | Wacky Workbench Act 3 bad future 
	dc.l	File_R7PCM			; $52 | Stardust Speedway Act 1 present
	dc.l	File_R7PCM			; $53 | Stardust Speedway Act 1 past
	dc.l	File_R7PCM			; $54 | Stardust Speedway Act 1 good future
	dc.l	File_R7PCM			; $55 | Stardust Speedway Act 1 bad future
	dc.l	File_R7PCM			; $56 | Stardust Speedway Act 2 present 
	dc.l	File_R7PCM			; $57 | Stardust Speedway Act 2 past 
	dc.l	File_R7PCM			; $58 | Stardust Speedway Act 2 good future 
	dc.l	File_R7PCM			; $59 | Stardust Speedway Act 2 bad future 
	dc.l	File_BossPCM			; $5A | Stardust Speedway Act 3 good future 
	dc.l	File_BossPCM			; $5B | Stardust Speedway Act 3 bad future 
	dc.l	File_R8PCM			; $5C | Metallic Madness Act 1 present
	dc.l	File_R8PCM			; $5D | Metallic Madness Act 1 past
	dc.l	File_R8PCM			; $5E | Metallic Madness Act 1 good future
	dc.l	File_R8PCM			; $5F | Metallic Madness Act 1 bad future
	dc.l	File_R8PCM			; $60 | Metallic Madness Act 2 present 
	dc.l	File_R8PCM			; $61 | Metallic Madness Act 2 past 
	dc.l	File_R8PCM			; $62 | Metallic Madness Act 2 good future 
	dc.l	File_R8PCM			; $63 | Metallic Madness Act 2 bad future 
	dc.l	File_BossPCM			; $64 | Metallic Madness Act 3 good future 
	dc.l	File_BossPCM			; $65 | Metallic Madness Act 3 bad future 
	dc.l	File_R11A			; $66 | Invalid
	dc.l	File_R11A			; $67 | Invalid
	dc.l	File_R11A			; $68 | Invalid
	dc.l	File_R11A			; $69 | Invalid
	dc.l	File_R11A			; $6A | Invalid
	dc.l	File_R11A			; $6B | Invalid
	dc.l	File_R11A			; $6C | Invalid
	dc.l	File_R11A			; $6D | Invalid
	dc.l	File_R11A			; $6E | Invalid
	dc.l	File_R11A			; $6F | Invalid
	dc.l	File_R11A			; $70 | Invalid
	dc.l	File_R11A			; $71 | Invalid
	dc.l	File_R11A			; $72 | Invalid
	dc.l	File_R11A			; $73 | Invalid
	dc.l	File_R11A			; $74 | Invalid
	dc.l	File_R11A			; $75 | Invalid
	dc.l	File_R11A			; $76 | Invalid
	dc.l	File_R11A			; $77 | Invalid
	dc.l	File_R11A			; $78 | Invalid
	dc.l	File_R11A			; $79 | Invalid
	dc.l	File_R11A			; $7A | Invalid
	dc.l	File_R11A			; $7B | Invalid
	dc.l	File_R11A			; $7C | Invalid
	dc.l	File_R11A			; $7D | Invalid
	dc.l	File_R11A			; $7E | Invalid
	dc.l	File_R11A			; $7F | Invalid
	dc.l	File_R11A			; $80 | Invalid
	dc.l	File_R11A			; $81 | Invalid
	dc.l	File_R11A			; $82 | Invalid
	dc.l	File_R11A			; $83 | Invalid
	dc.l	File_R1PCM			; $84 | Palmtree Panic Act 1 present demo
	dc.l	File_R11A			; $85 | Invalid
	dc.l	File_R11A			; $86 | Invalid
	dc.l	File_R11A			; $87 | Invalid
	dc.l	File_R11A			; $88 | Invalid
	dc.l	File_R11A			; $89 | Invalid
	dc.l	File_R11A			; $8A | Invalid
	dc.l	File_R11A			; $8B | Invalid
	dc.l	File_R11A			; $8C | Invalid
	dc.l	File_R11A			; $8D | Invalid
	dc.l	File_R11A			; $8E | Invalid
	dc.l	File_R11A			; $8F | Invalid
	dc.l	File_R11A			; $90 | Invalid
	dc.l	File_R11A			; $91 | Invalid
	dc.l	File_R11A			; $92 | Invalid
	dc.l	File_R11A			; $93 | Invalid
	dc.l	File_R11A			; $94 | Invalid
	dc.l	File_R11A			; $95 | Invalid

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
; Load staff credits
; -------------------------------------------------------------------------

SPCmd_LoadStaffCreds:
	lea	File_StaffCredits(pc),a0	; Load file
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

	bra.w	SPCmd_PlayR8AMus		; Play Metallic Madness present music

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

	bra.w	SPCmd_PlayR1CMus		; Play Palmtree Panic good future music

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
	lea	MusID_DAGarden(pc),a0
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
	lea	WORDRAM2M+$12C00,a1
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

SPCmd_LoadGoodEnd:
	bclr	#3,GAIRQMASK.w			; Disable timer interrupt

	lea	File_EndingMain(pc),a0		; Load Main CPU file
	bsr.w	WaitWordRAMAccess
	lea	WORDRAM2M,a1
	jsr	LoadFile.w
	bsr.w	GiveWordRAMAccess

	lea	File_GoodEndSub(pc),a0		; Load Sub CPU file
	lea	PRGRAM+$30000,a1
	jsr	LoadFile.w

	jsr	PRGRAM+$30000			; Run Sub CPU file code

	move.l	#SPIRQ2,_USERCALL2+2.w		; Restore IRQ2
	andi.b	#$FA,GAMEMMODE.w		; Set to 2M mode
	move.b	#3,GACDCDEVICE.w		; Set CDC device to "Sub CPU"
	move.l	#0,curPCMDriver.w		; Reset current PCM driver
	rts

; -------------------------------------------------------------------------

SPCmd_LoadBadEnd:
	bclr	#3,GAIRQMASK.w			; Disable timer interrupt

	lea	File_EndingMain(pc),a0		; Load Main CPU file
	bsr.w	WaitWordRAMAccess
	lea	WORDRAM2M,a1
	jsr	LoadFile.w
	bsr.w	GiveWordRAMAccess

	lea	File_BadEndSub(pc),a0		; Load Sub CPU file
	lea	PRGRAM+$30000,a1
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

	move.b	GACOMCMD3.w,GACOMSTAT3.w	; Set stage ID
	move.b	GACOMCMDA.w,GACOMSTATA.w	; Set stages beaten array
	move.b	GACOMCMDB.w,ssFlags.w		; Set flags

	lea	File_SpecialMain(pc),a0		; Load Main CPU file
	bsr.w	WaitWordRAMAccess
	lea	WORDRAM2M,a1
	jsr	LoadFile.w

	lea	File_SpecialSub(pc),a0		; Load Sub CPU file
	lea	PRGRAM+$10000,a1
	jsr	LoadFile.w

	moveq	#0,d0				; Copy background graphics data into Word RAM
	move.b	GACOMSTAT3.w,d0
	mulu.w	#6,d0
	lea	PRGRAM+$18000,a0
	move.w	4(a0,d0.w),d7
	movea.l	(a0,d0.w),a0
	lea	WORDRAM2M+$6D00,a1

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
	
	btst	#1,ssFlags.w			; Should we play the level end music?
	bne.s	.NoLevelEndMusic		; If not, branch
	bsr.w	ResetCDDAVol			; If so, play it
	lea	MusID_LevelEnd(pc),a0
	move.w	#MSCPLAY1,d0
	jsr	_CDBIOS.w

.NoLevelEndMusic:
	move.b	#0,ssFlags.w			; Clear special stage flags
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
; Play boss stomp sound
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
; Play Palmtree Panic present music
; -------------------------------------------------------------------------

SPCmd_PlayR1AMus:
	lea	MusID_R1A(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Palmtree Panic good future music
; -------------------------------------------------------------------------

SPCmd_PlayR1CMus:
	lea	MusID_R1C(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Palmtree Panic bad future music
; -------------------------------------------------------------------------

SPCmd_PlayR1DMus:
	lea	MusID_R1D(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Collision Chaos present music
; -------------------------------------------------------------------------

SPCmd_PlayR3AMus:
	lea	MusID_R3A(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Collision Chaos good future music
; -------------------------------------------------------------------------

SPCmd_PlayR3CMus:
	lea	MusID_R3C(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Collision Chaos bad future music
; -------------------------------------------------------------------------

SPCmd_PlayR3DMus:
	lea	MusID_R3D(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Tidal Tempest present music
; -------------------------------------------------------------------------

SPCmd_PlayR4AMus:
	lea	MusID_R4A(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Tidal Tempest good future music
; -------------------------------------------------------------------------

SPCmd_PlayR4CMus:
	lea	MusID_R4C(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Tidal Tempest bad future music
; -------------------------------------------------------------------------

SPCmd_PlayR4DMus:
	lea	MusID_R4D(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Quartz Quadrant present music
; -------------------------------------------------------------------------

SPCmd_PlayR5AMus:
	lea	MusID_R5A(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Quartz Quadrant good future music
; -------------------------------------------------------------------------

SPCmd_PlayR5CMus:
	lea	MusID_R5C(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Quartz Quadrant bad future music
; -------------------------------------------------------------------------

SPCmd_PlayR5DMus:
	lea	MusID_R5D(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Wacky Workbench present music
; -------------------------------------------------------------------------

SPCmd_PlayR6AMus:
	lea	MusID_R6A(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Wacky Workbench good future music
; -------------------------------------------------------------------------

SPCmd_PlayR6CMus:
	lea	MusID_R6C(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Wacky Workbench bad future music
; -------------------------------------------------------------------------

SPCmd_PlayR6DMus:
	lea	MusID_R6D(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Stardust Speedway present music
; -------------------------------------------------------------------------

SPCmd_PlayR7AMus:
	lea	MusID_R7A(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Stardust Speedway good future music
; -------------------------------------------------------------------------

SPCmd_PlayR7CMus:
	lea	MusID_R7C(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Stardust Speedway bad future music
; -------------------------------------------------------------------------

SPCmd_PlayR7DMus:
	lea	MusID_R7D(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Metallic Madness present music
; -------------------------------------------------------------------------

SPCmd_PlayR8AMus:
	lea	MusID_R8A(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Metallic Madness good future music
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
; Play Metallic Madness bad future music
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

SPCmd_PlaySpecialMus:
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

SPCmd_PlayIntroMus:
	lea	MusID_Intro(pc),a0
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
; Play level end music
; -------------------------------------------------------------------------

SPCmd_PlayLvlEndMus:
	lea	MusID_LevelEnd(pc),a0
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
; Play Palmtree Panic present music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR1AMus:
	lea	MusID_R1A(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play Palmtree Panic good future music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR1CMus:
	lea	MusID_R1C(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play Palmtree Panic bad future music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR1DMus:
	lea	MusID_R1D(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play Collision Chaos present music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR3AMus:
	lea	MusID_R3A(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play Collision Chaos good future music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR3CMus:
	lea	MusID_R3C(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play Collision Chaos bad future music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR3DMus:
	lea	MusID_R3D(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play Tidal Tempest present music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR4AMus:
	lea	MusID_R4A(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play Tidal Tempest good future music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR4CMus:
	lea	MusID_R4C(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play Tidal Tempest bad future music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR4DMus:
	lea	MusID_R4D(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play Quartz Quadrant present music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR5AMus:
	lea	MusID_R5A(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play Quartz Quadrant good future music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR5CMus:
	lea	MusID_R5C(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play Quartz Quadrant bad future music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR5DMus:
	lea	MusID_R5D(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play Wacky Workbench present music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR6AMus:
	lea	MusID_R6A(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play Wacky Workbench good future music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR6CMus:
	lea	MusID_R6C(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play Wacky Workbench bad future music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR6DMus:
	lea	MusID_R6D(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play Stardust Speedway present music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR7AMus:
	lea	MusID_R7A(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play Stardust Speedway good future music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR7CMus:
	lea	MusID_R7C(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play Stardust Speedway bad future music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR7DMus:
	lea	MusID_R7D(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play Metallic Madness present music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR8AMus:
	lea	MusID_R8A(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play Metallic Madness good future music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestR8CMus:
	lea	MusID_R8C(pc),a0
	bra.w	PlayCDDA

; -------------------------------------------------------------------------
; Play Metallic Madness bad future music (sound test)
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
; Play level end music (sound test)
; -------------------------------------------------------------------------

SPCmd_TestLvlEndMus:
	lea	MusID_LevelEnd(pc),a0
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
	lea	MusID_Intro(pc),a0
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
; Play stomp sound (sound test)
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
	dc.w	CDDA_R1A			; Palmtree Panic present
MusID_R1C:
	dc.w	CDDA_R1C			; Palmtree Panic good future
MusID_R1D:
	dc.w	CDDA_R1D			; Palmtree Panic bad future
MusID_R3A:
	dc.w	CDDA_R3A			; Collision Chaos present
MusID_R3C:
	dc.w	CDDA_R3C			; Collision Chaos good future
MusID_R3D:
	dc.w	CDDA_R3D			; Collision Chaos bad future
MusID_R4A:
	dc.w	CDDA_R4A			; Tidal Tempest present
MusID_R4C:
	dc.w	CDDA_R4C			; Tidal Tempest good future
MusID_R4D:
	dc.w	CDDA_R4D			; Tidal Tempest bad future
MusID_R5A:
	dc.w	CDDA_R5A			; Quartz Quadrant present
MusID_R5C:
	dc.w	CDDA_R5C			; Quartz Quadrant good future
MusID_R5D:
	dc.w	CDDA_R5D			; Quartz Quadrant bad future
MusID_R6A:
	dc.w	CDDA_R6A			; Wacky Workbench present
MusID_R6C:
	dc.w	CDDA_R6C			; Wacky Workbench good future
MusID_R6D:
	dc.w	CDDA_R6D			; Wacky Workbench bad future
MusID_R7A:
	dc.w	CDDA_R7A			; Stardust Speedway present
MusID_R7C:
	dc.w	CDDA_R7C			; Stardust Speedway good future
MusID_R7D:
	dc.w	CDDA_R7D			; Stardust Speedway bad future
MusID_R8A:
	dc.w	CDDA_R8A			; Metallic Madness present
MusID_R8C:
	dc.w	CDDA_R8C			; Metallic Madness good future
MusID_R8D:
	dc.w	CDDA_R8D			; Metallic Madness bad future
MusID_Boss:
	dc.w	CDDA_BOSS			; Boss
MusID_Final:
	dc.w	CDDA_FINAL			; Final boss
MusID_Title:
	dc.w	CDDA_TITLE			; Title screen
MusID_TimeAttack:
	dc.w	CDDA_TMATK			; Time attack menu
MusID_LevelEnd:
	dc.w	CDDA_LVLEND			; Level end
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
MusID_Intro:
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
