; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Sound test
; -------------------------------------------------------------------------

	include	"_Include/Common.i"
	include	"_Include/Main CPU.i"
	include	"_Include/Main CPU Variables.i"
	include	"_Include/System.i"
	include	"_Include/Sound.i"
	include	"_Include/MMD.i"
	include	"Title Screen/Secrets/_Variables.i"
	include	"Title Screen/Secrets/_Macros.i"

; -------------------------------------------------------------------------
; MMD header
; -------------------------------------------------------------------------

	MMD	0, &
		WORKRAMFILE, $3000, &
		Start, 0, 0

; -------------------------------------------------------------------------
; Program start
; -------------------------------------------------------------------------

Start:
	move.l	#VInterrupt,_LEVEL6+2.w		; Set V-INT address
	bsr.w	GiveWordRAMAccess		; Give Sub CPU Word RAM Access
	
	lea	VARSSTART.w,a0			; Clear variables
	move.w	#VARSLEN/4-1,d7

.ClearVars:
	move.l	#0,(a0)+
	dbf	d7,.ClearVars

	lea	VDPRegs(pc),a0			; Initialize Mega Drive hardware
	bsr.w	InitMD
	
	VDPCMD	move.l,$F400,VRAM,WRITE,VDPCTRL	; Clear horizontal scroll data
	move.l	#0,VDPDATA

	VDPCMD	move.l,$0000,VRAM,WRITE,VDPCTRL	; Load art
	lea	Art_SelScreen(pc),a0
	bsr.w	NemDec

	lea	Map_SelScreenBg(pc),a1		; Draw background tilemap
	VDPCMD	move.l,$E000,VRAM,WRITE,d0
	moveq	#$28-1,d1
	moveq	#$1C-1,d2
	bsr.w	DrawTilemapH64

	lea	Text_SoundTest(pc),a0		; Draw header text
	move.w	#$8000,d0
	bsr.w	DrawText

	lea	Pal_SelScreen(pc),a0		; Load palette
	lea	palette.w,a1
	moveq	#(Pal_SelScreen_End-Pal_SelScreen)/4-1,d7

.LoadPal:
	move.l	(a0)+,(a1)+
	dbf	d7,.LoadPal
	
	bset	#1,ipxVSync			; Update CRAM
	bsr.w	PrepFadeFromBlack		; Prepare to fade from black
	bsr.w	VSync				; VSync
	bsr.w	FadeFromBlack			; Fade from black

; -------------------------------------------------------------------------

MainLoop:
	addq.w	#1,lrSelDelay			; Increment delay counters
	addq.w	#1,fmSelDelay
	addq.w	#1,pcmSelDelay
	addq.w	#1,cddaSelDelay

	lea	soundType(pc),a1		; Select sound type
	moveq	#0,d6
	moveq	#2,d7

	move.w	lrSelDelay,d0			; Should we update the selection?
	andi.w	#7,d0
	bne.s	.NoSoundTypeSel			; If not, branch

	btst	#2,ctrlHold			; Is left being pressed?
	beq.s	.NoLeft				; If not, branch
	bsr.w	DecValueW			; Decrease selection

.NoLeft:
	btst	#3,ctrlHold			; Is right being pressed?
	beq.s	.NoSoundTypeSel			; If not, branch
	bsr.w	IncValueW			; Increase selection
	bra.s	.NoSoundTypeSel

; -------------------------------------------------------------------------

.SoundSels:
	dc.w	SelectFM-.SoundSels		; FM
	dc.w	SelectPCM-.SoundSels		; PCM
	dc.w	SelectCDDA-.SoundSels		; CDDA

; -------------------------------------------------------------------------

.NoSoundTypeSel:
	bsr.w	DrawTypesText			; Draw sound types text
	bsr.w	DrawFMSel			; Draw FM sound selection
	bsr.w	DrawPCMSel			; Draw PCM sound selection
	bsr.w	DrawCDDASel			; Draw CDDA sound selection

	move.w	soundType,d0			; Update sound ID selection
	add.w	d0,d0
	move.w	.SoundSels(pc,d0.w),d0
	jsr	.SoundSels(pc,d0.w)

	bsr.w	VSync				; VSync

	btst	#7,ctrlHold			; Has the start button been pressed?
	beq.w	MainLoop			; If not, branch

	move.w	#SCMD_STOPCDDA,d0		; Stop CDDA
	bsr.w	SelSubCPUCmd
	bsr.w	VSync
	move.w	#SCMD_STOPPCM,d0		; Stop PCM
	bsr.w	SelSubCPUCmd
	bsr.w	VSync

	bsr.w	CheckEasterEgg			; Run exit routine
	add.w	d0,d0
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

SoundTest_Exit:
	bsr.w	FadeToBlack			; Fade to black
	moveq	#0,d0
	rts

; -------------------------------------------------------------------------

SoundTest_SpecStg8:
	bsr.w	StopZ80				; Play sound
	move.b	#FM_RINGL,FMDrvQueue2
	bsr.w	StartZ80

	lea	Text_SpecStg8(pc),a0		; Draw text
	move.w	#$6000,d0
	bsr.w	DrawText

	move.w	#(60*2)-1,d7			; Wait 2 seconds

.Wait:
	bsr.w	VSync
	dbf	d7,.Wait

	bsr.w	StopZ80				; Play warp sound
	move.b	#FM_SSWARP,FMDrvQueue2
	bsr.w	StartZ80

	bsr.w	FadeToWhite			; Fade to white
	moveq	#1,d0
	rts

; -------------------------------------------------------------------------

SoundTest_FunIsInf:
	bsr.w	StopZ80				; Play warp sound
	move.b	#FM_SSWARP,FMDrvQueue2
	bsr.w	StartZ80

	bsr.w	FadeToWhite			; Fade to white
	moveq	#2,d0
	rts

; -------------------------------------------------------------------------

SoundTest_MCSonic:
	bsr.w	StopZ80				; Play warp sound
	move.b	#FM_SSWARP,FMDrvQueue2
	bsr.w	StartZ80

	bsr.w	FadeToWhite			; Fade to white
	moveq	#3,d0
	rts

; -------------------------------------------------------------------------

SoundTest_Tails:
	bsr.w	StopZ80				; Play warp sound
	move.b	#FM_SSWARP,FMDrvQueue2
	bsr.w	StartZ80

	bsr.w	FadeToWhite			; Fade to white
	moveq	#4,d0

	move.w	#1,debugCheat			; Set debug cheat flag
	rts

; -------------------------------------------------------------------------

SoundTest_Batman:
	bsr.w	StopZ80				; Play warp sound
	move.b	#FM_SSWARP,FMDrvQueue2
	bsr.w	StartZ80

	bsr.w	FadeToWhite			; Fade to white
	moveq	#5,d0
	rts

; -------------------------------------------------------------------------

SoundTest_CuteSonic:
	bsr.w	StopZ80				; Play warp sound
	move.b	#FM_SSWARP,FMDrvQueue2
	bsr.w	StartZ80

	bsr.w	FadeToWhite			; Fade to white
	moveq	#6,d0
	rts

; -------------------------------------------------------------------------
; Check easter egg
; -------------------------------------------------------------------------
; RETURNS:
;	Exit code
; -------------------------------------------------------------------------

CheckEasterEgg:
	moveq	#1,d0				; Start with 1st easter egg
	move.w	fmSelID,d5			; Get sound selection IDs
	move.w	pcmSelID,d6
	move.w	cddaSelID,d7

.CheckLoop:
	move.w	d0,d1				; Get code to check
	mulu.w	#6,d1
	move.w	.Codes(pc,d1.w),d2		; Are we at the end?
	bmi.s	.NoEasterEgg			; If so, branch

	cmp.w	.Codes(pc,d1.w),d5		; Does the FM sound selection ID match?
	bne.s	.NextCode			; If not, branch
	cmp.w	.Codes+2(pc,d1.w),d6		; Does the PCM sound selection ID match?
	bne.s	.NextCode			; If not, branch
	cmp.w	.Codes+4(pc,d1.w),d7		; Does the CDDA sound selection ID match?
	bne.s	.NextCode			; If not, branch

.GotEasterEgg:
	rts

.NextCode:
	addq.w	#1,d0				; Check next code
	bra.s	.CheckLoop

.NoEasterEgg:
	moveq	#0,d0
	rts

; -------------------------------------------------------------------------

.Codes:
	dc.w	$00, $00, $00
	dc.w	$07, $07, $07			; Special stage 8
	dc.w	$2E, $0C, $19			; Fun is infinite
	dc.w	$2A, $03, $01			; M.C. Sonic
	dc.w	$28, $0C, $0B			; Tails
	dc.w	$2A, $04, $15			; Batman
	dc.w	$2C, $0B, $09			; Cute Sonic
	dc.w	-1, 0, 0

; -------------------------------------------------------------------------
; Select an FM sound
; -------------------------------------------------------------------------

SelectFM:
	lea	fmSelID(pc),a1			; Select ID
	lea	fmSelDelay(pc),a2
	moveq	#0,d6
	moveq	#.IDsEnd-.IDs-1,d7
	bsr.w	UpdateSelection

	move.b	ctrlTap,d0			; Has A, B, or C been tapped?
	andi.b	#%1110000,d0
	beq.s	.End				; If not, branch

	bsr.w	StopZ80				; Play sound
	move.w	fmSelID,d0
	move.b	.IDs(pc,d0.w),FMDrvQueue2
	bsr.w	StartZ80

.End:
	rts

; -------------------------------------------------------------------------

.IDs:
	dc.b	FM_SKID				; Skid
	dc.b	FM_91				; 91
	dc.b	FM_JUMP				; Jump
	dc.b	FM_HURT				; Hurt
	dc.b	FM_RINGLOSS			; Ring loss
	dc.b	FM_RING				; Ring
	dc.b	FM_DESTROY			; Destroy
	dc.b	FM_SHIELD			; Shield
	dc.b	FM_SPRING			; Spring
	dc.b	FM_99				; 99
	dc.b	FM_KACHING			; Ka-ching
	dc.b	FM_9B				; 9B
	dc.b	FM_9B				; 9B
	dc.b	FM_SIGNPOST			; Signpost
	dc.b	FM_EXPLODE			; Explosion
	dc.b	FM_9F				; 9F
	dc.b	FM_A0				; A0
	dc.b	FM_A1				; A1
	dc.b	FM_A2				; A2
	dc.b	FM_A3				; A3
	dc.b	FM_A4				; A4
	dc.b	FM_A5				; A5
	dc.b	FM_A5				; A5
	dc.b	FM_A7				; A7
	dc.b	FM_RINGL			; Ring (left channel)
	dc.b	FM_RINGL			; Ring (left channel)
	dc.b	FM_AA				; AA
	dc.b	FM_AA				; AA
	dc.b	FM_AC				; AC
	dc.b	FM_AD				; AD
	dc.b	FM_CHECKPOINT			; Checkpoint
	dc.b	FM_BIGRING			; Big ring
	dc.b	FM_B0				; B0
	dc.b	FM_B1				; B1
	dc.b	FM_B2				; B2
	dc.b	FM_B3				; B3
	dc.b	FM_B4				; B4
	dc.b	FM_B5				; B5
	dc.b	FM_B6				; B6
	dc.b	FM_B7				; B7
	dc.b	FM_B8				; B8
	dc.b	FM_B9				; B9
	dc.b	FM_BA				; BA
	dc.b	FM_BB				; BB
	dc.b	FM_BC				; BC
	dc.b	FM_TALLY			; Tally
	dc.b	FM_BE				; BE
	dc.b	FM_BF				; BF
	dc.b	FM_C0				; C0
	dc.b	FM_C1				; C1
	dc.b	FM_C2				; C2
	dc.b	FM_C3				; C3
	dc.b	FM_C3				; C3
	dc.b	FM_C5				; C5
	dc.b	FM_C6				; C6
	dc.b	FM_C7				; C7
	dc.b	FM_SSWARP			; Special stage warp
	dc.b	FM_C9				; C9
	dc.b	FM_CA				; CA
	dc.b	FM_CB				; CB
	dc.b	FM_CC				; CC
	dc.b	FM_CD				; CD
	dc.b	FM_CE				; CE
	dc.b	FM_CF				; CF
	dc.b	FM_D0				; D0
	dc.b	FM_D0				; D0
	dc.b	FM_D2				; D2
	dc.b	FM_D3				; D3
	dc.b	FM_D4				; D4
	dc.b	FM_D5				; D5
	dc.b	FM_D6				; D6
	dc.b	FM_D7				; D7
	dc.b	FM_D8				; D8
	dc.b	FM_D9				; D9
	dc.b	FM_DA				; DA
	dc.b	FM_DB				; DB
	dc.b	FM_DC				; DC
	dc.b	FM_DD				; DD
	dc.b	FM_DE				; DE
	dc.b	FM_DF				; DF
.IDsEnd:
	even

; -------------------------------------------------------------------------
; Select a PCM sound
; -------------------------------------------------------------------------

SelectPCM:
	lea	pcmSelID(pc),a1			; Select ID
	lea	pcmSelDelay(pc),a2
	moveq	#0,d6
	moveq	#.IDsEnd-.IDs-1,d7
	bsr.w	UpdateSelection

	move.b	ctrlTap,d0			; Has A, B, or C been tapped?
	andi.b	#%1110000,d0
	beq.s	.End				; If not, branch

	move.w	#SCMD_STOPCDDA,d0		; Stop CDDA
	bsr.w	SelSubCPUCmd
	bsr.w	VSync
	move.w	#SCMD_STOPPCM,d0		; Stop PCM
	bsr.w	SelSubCPUCmd
	bsr.w	VSync

	move.w	pcmSelID,d1			; Play sound
	moveq	#0,d0
	move.b	.IDs(pc,d1.w),d0
	bsr.w	SelSubCPUCmd

.End:
	rts

; -------------------------------------------------------------------------

.IDs:
	dc.b	SCMD_FUTURESFXT			; "Future"
	dc.b	SCMD_PASTSFXT			; "Past"
	dc.b	SCMD_ALRGHTSFXT			; "Alright"
	dc.b	SCMD_GIVEUPSFXT			; "I'm outta here"
	dc.b	SCMD_YESSFXT			; "Yes"
	dc.b	SCMD_YEAHSFXT			; "Yeah"
	dc.b	SCMD_GIGGLESFXT			; Amy giggle
	dc.b	SCMD_YELPSFXT			; Amy yelp
	dc.b	SCMD_STOMPSFXT			; Mech stomp
	dc.b	SCMD_BUMPERSFXT			; Bumper
	dc.b	SCMD_R1BMUST			; Palmtree Panic past music
	dc.b	SCMD_R3BMUST			; Collision Chaos past music
	dc.b	SCMD_R4BMUST			; Tidal Tempest past music
	dc.b	SCMD_R5BMUST			; Quartz Quadrant past music
	dc.b	SCMD_R6BMUST			; Wacky Workbench past music
	dc.b	SCMD_R7BMUST			; Stardust Speedway past music
	dc.b	SCMD_R8BMUST			; Metallic Madness past music
.IDsEnd:
	even

; -------------------------------------------------------------------------
; Select a CDDA sound
; -------------------------------------------------------------------------

SelectCDDA:
	lea	cddaSelID(pc),a1		; Select ID
	lea	cddaSelDelay(pc),a2
	moveq	#0,d6
	moveq	#.IDsEnd-.IDs-1,d7
	bsr.w	UpdateSelection

	move.b	ctrlTap,d0			; Has A, B, or C been tapped?
	andi.b	#%1110000,d0
	beq.s	.End				; If not, branch

	move.w	#SCMD_STOPPCM,d0		; Stop PCM
	bsr.w	SelSubCPUCmd
	bsr.w	VSync

	move.w	cddaSelID,d1			; Play sound
	moveq	#0,d0
	move.b	.IDs(pc,d1.w),d0
	bsr.w	SelSubCPUCmd

.End:
	rts

; -------------------------------------------------------------------------

.IDs:
	dc.b	SCMD_R1AMUST			; Palmtree Panic present music
	dc.b	SCMD_R1CMUST			; Palmtree Panic good future music
	dc.b	SCMD_R1DMUST			; Palmtree Panic bad future music
	dc.b	SCMD_R3AMUST			; Collision Chaos present music
	dc.b	SCMD_R3CMUST			; Collision Chaos good future music
	dc.b	SCMD_R3DMUST			; Collision Chaos bad future music
	dc.b	SCMD_R4AMUST			; Tidal Tempest present music
	dc.b	SCMD_R4CMUST			; Tidal Tempest good future music
	dc.b	SCMD_R4DMUST			; Tidal Tempest bad future music
	dc.b	SCMD_R5AMUST			; Quartz Quadrant present music
	dc.b	SCMD_R5CMUST			; Quartz Quadrant good future music
	dc.b	SCMD_R5DMUST			; Quartz Quadrant bad future music
	dc.b	SCMD_R6AMUST			; Wacky Workbench present music
	dc.b	SCMD_R6CMUST			; Wacky Workbench good future music
	dc.b	SCMD_R6DMUST			; Wacky Workbench bad future music
	dc.b	SCMD_R7AMUST			; Stardust Speedway present music
	dc.b	SCMD_R7CMUST			; Stardust Speedway good future music
	dc.b	SCMD_R7DMUST			; Stardust Speedway bad future music
	dc.b	SCMD_R8AMUST			; Metallic Madness present music
	dc.b	SCMD_R8CMUST			; Metallic Madness good future music
	dc.b	SCMD_R8DMUST			; Metallic Madness bad future music
	dc.b	SCMD_BOSSMUST			; Boss music
	dc.b	SCMD_FINALMUST			; Final boss music
	dc.b	SCMD_TITLEMUST			; Title screen music
	dc.b	SCMD_TMATKMUST			; Time attack music
	dc.b	SCMD_RESULTMUST			; Results music
	dc.b	SCMD_SHOESMUST			; Speed shoes music
	dc.b	SCMD_INVINCMUST			; Invincibility music
	dc.b	SCMD_GMOVERMUST			; Game over music
	dc.b	SCMD_SPECMUST			; Special stage music
	dc.b	SCMD_DAGRDNMUST			; D.A. Garden music
	dc.b	SCMD_PROTOWARPT			; Prototype warp sound
	dc.b	SCMD_INTROMUST			; Opening music
	dc.b	SCMD_ENDINGMUST			; Ending music
.IDsEnd:
	even

; -------------------------------------------------------------------------
; Selection data
; -------------------------------------------------------------------------

lrSelDelay:					; Left/right selection delay
	dc.w	0
fmSelDelay:					; FM sound selection delay
	dc.w	2
pcmSelDelay:					; PCM sound selection delay
	dc.w	4
cddaSelDelay:					; CDDA selection delay
	dc.w	6
soundType:					; Selected sound type
	dc.w	0
fmSelID:					; FM sound selection ID
	dc.w	0
pcmSelID:					; PCM sound selection ID
	dc.w	0
cddaSelID:					; CDDA sound selection ID
	dc.w	0

; -------------------------------------------------------------------------
; Send a command to the Sub CPU
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Command ID
; -------------------------------------------------------------------------

SelSubCPUCmd:
	move.w	d0,GACOMCMD0			; Set command ID

.WaitSubCPU:
	tst.w	GACOMSTAT0			; Has the Sub CPU received the command?
	beq.s	.WaitSubCPU			; If not, wait

	move.w	#0,GACOMCMD0			; Mark as ready to send commands again

.WaitSubCPUDone:
	tst.w	GACOMSTAT0			; Is the Sub CPU done processing the command?
	bne.s	.WaitSubCPUDone			; If not, wait
	rts

; -------------------------------------------------------------------------
; Update a selection
; -------------------------------------------------------------------------
; PARAMETERS:
;	d6.w - Minimum ID
;	d7.w - Maximum ID
;	a1.l - Pointer to selection ID
;	a2.l - Pointer to delay counter
; -------------------------------------------------------------------------

UpdateSelection:
	move.w	(a2),d0				; Should we update the selection?
	andi.w	#7,d0
	bne.s	.End				; If not, branch

	btst	#0,ctrlHold			; Is up being pressed?
	beq.s	.NoUp				; If not, branch
	bsr.w	DecValueW			; Decrease selection

.NoUp:
	btst	#1,ctrlHold			; Is down being pressed?
	beq.s	.End				; If not, branch
	bsr.w	IncValueW			; Increase selection

.End:
	rts

; -------------------------------------------------------------------------
; Draw sound types text
; -------------------------------------------------------------------------

DrawTypesText:
	lea	Text_SndTypes(pc),a0		; Draw base text
	move.w	#$6000,d0
	bsr.w	DrawText

	cmpi.w	#0,soundType			; Is FM sound selected?
	beq.s	.FM				; If so, branch
	cmpi.w	#1,soundType			; Is PCM sound selected?
	beq.s	.PCM				; If so, branch

.CDDA:
	lea	Text_CDDANo(pc),a0		; Highlight CDDA selection
	move.w	#$2000,d0
	bra.w	DrawText

.FM:
	lea	Text_FMNo(pc),a0		; Highlight FM selection
	move.w	#$2000,d0
	bra.w	DrawText

.PCM:
	lea	Text_PCMNo(pc),a0		; Highlight PCM selection
	move.w	#$2000,d0
	bra.w	DrawText

; -------------------------------------------------------------------------
; Draw FM sound selection
; -------------------------------------------------------------------------

DrawFMSel:
	lea	DrawNum_10(pc),a1		; Draw number
	VDPCMD	move.l,$C596,VRAM,WRITE,d4
	VDPCMD	move.l,$C596+$80,VRAM,WRITE,d5
	move.w	fmSelID,d0
	moveq	#2-1,d1
	bra.s	DrawNumber

; -------------------------------------------------------------------------
; Draw PCM sound selection
; -------------------------------------------------------------------------

DrawPCMSel:
	lea	DrawNum_10(pc),a1		; Draw number
	VDPCMD	move.l,$C5AC,VRAM,WRITE,d4
	VDPCMD	move.l,$C5AC+$80,VRAM,WRITE,d5
	move.w	pcmSelID,d0
	moveq	#2-1,d1
	bra.s	DrawNumber

; -------------------------------------------------------------------------
; Draw CDDA sound selection
; -------------------------------------------------------------------------

DrawCDDASel:
	lea	DrawNum_10(pc),a1		; Draw number
	VDPCMD	move.l,$C5C0,VRAM,WRITE,d4
	VDPCMD	move.l,$C5C0+$80,VRAM,WRITE,d5
	move.w	cddaSelID,d0
	moveq	#2-1,d1

; -------------------------------------------------------------------------
; Draw number
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Number
;	d1.w - Number of digits (minus 1)
;	d4.l - Top VDP command
;	d5.l - Bottom VDP command
;	a1.l - Pointer to top of number conversion table
; -------------------------------------------------------------------------

DrawNumber:
	lea	VDPCTRL,a2			; VDP control port
	lea	VDPDATA,a3			; VDP data port

.DigitLoop:
	move.l	d4,(a2)				; Set top VDP command
	moveq	#0,d2				; Reset digit counter
	move.w	(a1)+,d3			; Get digit to isolate

.GetDigit:
	sub.w	d3,d0				; Find digit value
	bcs.s	.GotDigit			; If we haven't got our digit yet, branch
	addq.w	#1,d2				; Increment digit counter
	bra.s	.GetDigit			; Loop

.GotDigit:
	add.w	d3,d0				; Fix value

	add.w	d2,d2				; Draw top
	move.w	NumTilesUpper(pc,d2.w),(a3)
	move.l	d5,(a2)				; Draw bottom
	move.w	NumTilesLower(pc,d2.w),(a3)

	addi.l	#$20000,d4			; Shift right
	addi.l	#$20000,d5
	dbf	d1,.DigitLoop			; Loop until number is drawn
	rts

; -------------------------------------------------------------------------

DrawNum_1000:
	dc.w	1000
DrawNum_100:
	dc.w	100
DrawNum_10:
	dc.w	10
DrawNum_1:
	dc.w	1

NumTilesUpper:
	dc.w	$6001				; 0
	dc.w	$6002				; 1
	dc.w	$6003				; 2
	dc.w	$6004				; 3
	dc.w	$6005				; 4
	dc.w	$6006				; 5
	dc.w	$6007				; 6
	dc.w	$6008				; 7
	dc.w	$6009				; 8
	dc.w	$600A				; 9

NumTilesLower:
	dc.w	$6021				; 0
	dc.w	$6022				; 1
	dc.w	$6023				; 2
	dc.w	$6021				; 3
	dc.w	$6024				; 4
	dc.w	$6021				; 5
	dc.w	$6021				; 6
	dc.w	$6022				; 7
	dc.w	$6021				; 8
	dc.w	$6025				; 9

; -------------------------------------------------------------------------
; Draw text
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Base tile ID
;	a0.l - Pointer to text data
; -------------------------------------------------------------------------

DrawText:
	movem.l	d0-a6,-(sp)			; Save registers
	lea	VDPCTRL,a2			; VDP control port
	lea	VDPDATA,a3			; VDP data port

	move.w	(a0)+,d7			; Get number of entries

.TextLoop:
	movea.l	(a0)+,a1			; Get string data
	move.l	(a0)+,d3			; Get top VDP command
	move.l	(a0)+,d4			; Get bottom VDP command

.CharLoop:
	moveq	#0,d1				; Get character
	move.b	(a1)+,d1
	cmpi.b	#$FF,d1				; Is it the termination character?
	beq.s	.Done				; If so, branch

	move.l	d3,(a2)				; Draw top of character
	moveq	#0,d2
	move.b	.TilesUpper(pc,d1.w),d2
	add.w	d0,d2
	move.w	d2,(a3)

	move.l	d4,(a2)				; Draw bottom of character
	moveq	#0,d2
	move.b	.TilesLower(pc,d1.w),d2
	add.w	d0,d2
	move.w	d2,(a3)

	addi.l	#$20000,d3			; Shift right
	addi.l	#$20000,d4
	bra.s	.CharLoop			; Loop until string is drawn

.Done:
	dbf	d7,.TextLoop			; Loop until all text is drawn
	movem.l	(sp)+,d0-a6			; Restore registers
	rts

; -------------------------------------------------------------------------

.TilesUpper:
	dc.b	$00				; Space
	dc.b	$01				; 0
	dc.b	$02				; 1
	dc.b	$03				; 2
	dc.b	$04				; 3
	dc.b	$05				; 4
	dc.b	$06				; 5
	dc.b	$07				; 6
	dc.b	$08				; 7
	dc.b	$09				; 8
	dc.b	$0A				; 9
	dc.b	$0B				; A
	dc.b	$0C				; B
	dc.b	$0D				; C
	dc.b	$0E				; D
	dc.b	$0F				; E
	dc.b	$0F				; F
	dc.b	$10				; G
	dc.b	$11				; H
	dc.b	$12				; I
	dc.b	$13				; J
	dc.b	$14				; K
	dc.b	$15				; L
	dc.b	$16				; M
	dc.b	$17				; N
	dc.b	$01				; O
	dc.b	$18				; P
	dc.b	$01				; Q
	dc.b	$19				; R
	dc.b	$1A				; S
	dc.b	$1B				; T
	dc.b	$1C				; U
	dc.b	$1C				; V
	dc.b	$1D				; W
	dc.b	$1E				; X
	dc.b	$1F				; Y
	dc.b	$20				; Z
	dc.b	$35				; -
	dc.b	$36				; ,
	dc.b	$00				; .
	dc.b	$37				; '
	dc.b	$38				; "
	dc.b	$12				; !
	dc.b	$39				; ?
	dc.b	$3A				; x

.TilesLower:
	dc.b	$00				; Space
	dc.b	$21				; 0
	dc.b	$22				; 1
	dc.b	$23				; 2
	dc.b	$21				; 3
	dc.b	$24				; 4
	dc.b	$21				; 5
	dc.b	$21				; 6
	dc.b	$22				; 7
	dc.b	$21				; 8
	dc.b	$25				; 9
	dc.b	$26				; A
	dc.b	$27				; B
	dc.b	$21				; C
	dc.b	$27				; D
	dc.b	$28				; E
	dc.b	$29				; F
	dc.b	$2A				; G
	dc.b	$26				; H
	dc.b	$22				; I
	dc.b	$21				; J
	dc.b	$2B				; K
	dc.b	$2C				; L
	dc.b	$2D				; M
	dc.b	$2E				; N
	dc.b	$21				; O
	dc.b	$2F				; P
	dc.b	$30				; Q
	dc.b	$31				; R
	dc.b	$21				; S
	dc.b	$22				; T
	dc.b	$21				; U
	dc.b	$32				; V
	dc.b	$33				; W
	dc.b	$34				; X
	dc.b	$22				; Y
	dc.b	$2C				; Z
	dc.b	$00				; -
	dc.b	$3B				; ,
	dc.b	$3C				; .
	dc.b	$00				; '
	dc.b	$00				; "
	dc.b	$3D				; !
	dc.b	$3D				; ?
	dc.b	$3E				; x

; -------------------------------------------------------------------------
; Text data
; -------------------------------------------------------------------------

Text_SoundTest:
	TEXTSTART
	TEXTPTR	TextDat_SoundTest, 15, 7
	TEXTEND

Text_SndTypes:
	TEXTSTART
	TEXTPTR	TextDat_FMNo, 5, 11
	TEXTPTR	TextDat_PCMNo, 15, 11
	TEXTPTR	TextDat_CDDANo, 26, 11
	TEXTEND

Text_SpecStg8:
	TEXTSTART
	TEXTPTR	TextDat_SpecStg8, 4, 18
	TEXTEND

Text_FMNo:
	TEXTSTART
	TEXTPTR	TextDat_FMNo, 5, 11
	TEXTEND

Text_PCMNo:
	TEXTSTART
	TEXTPTR	TextDat_PCMNo, 15, 11
	TEXTEND

Text_CDDANo:
	TEXTSTART
	TEXTPTR	TextDat_CDDANo, 26, 11
	TEXTEND

; -------------------------------------------------------------------------

TextDat_SoundTest:
	TEXTSTR	"SOUND TEST"
	even

TextDat_FMNo:
	TEXTSTR	"FM NO."
	even

TextDat_PCMNo:
	TEXTSTR	"PCM NO."
	even

TextDat_CDDANo:
	TEXTSTR	"DA NO."
	even

TextDat_SpecStg8:
	TEXTSTR	"WELCOME TO SECRET SPECIAL STAGE"
	even

; -------------------------------------------------------------------------
; V-BLANK interrupt
; -------------------------------------------------------------------------

VInterrupt:
	movem.l	d0-a6,-(sp)			; Save registers

	move.b	#1,GAIRQ2			; Trigger IRQ2 on Sub CPU
	bclr	#0,ipxVSync			; Clear VSync flag
	beq.s	.End				; If it wasn't set, branch
	
	bset	#6,ipxVDPReg1+1			; Enable display
	move.w	ipxVDPReg1,VDPCTRL
	
	bsr.w	StopZ80				; Stop the Z80
	move.w	VDPCTRL,d0			; Reset V-BLANK flag

	bclr	#1,ipxVSync			; Should we update CRAM?
	beq.s	.NoCRAMUpdate			; If not, branch
	DMA68K	palette,$0000,$80,CRAM		; Copy palette data

.NoCRAMUpdate:
	jsr	ReadController(pc)		; Read controller
	bsr.w	StartZ80			; Start the Z80

.End:
	movem.l	(sp)+,d0-a6			; Restore registers
	rte

; -------------------------------------------------------------------------
; Give Sub CPU Word RAM access
; -------------------------------------------------------------------------

GiveWordRAMAccess:
	btst	#1,GAMEMMODE			; Does the Sub CPU already have Word RAM Access?
	bne.s	.End				; If so, branch
	bset	#1,GAMEMMODE			; Give Sub CPU Word RAM access

.Wait:
	btst	#1,GAMEMMODE			; Has it been given?
	beq.s	.Wait				; If not, wait

.End:
	rts

; -------------------------------------------------------------------------
; Data
; -------------------------------------------------------------------------

VDPRegs:
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
VDPRegsEnd:
	even

Pal_SelScreen:
	incbin	"Title Screen/Secrets/Data/Palette.bin"
Pal_SelScreen_End:
	even

Art_SelScreen:
	incbin	"Title Screen/Secrets/Data/Art.nem"
	even

Map_SelScreenBg:
	incbin	"Title Screen/Secrets/Data/Background Mappings (H40).bin"
	even
	
; -------------------------------------------------------------------------
; Draw a tilemap (for 64 tile wide planes)
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - VDP command
;	d1.w - Width
;	d2.w - Height
;	a1.l - Pointer to tilemap
; -------------------------------------------------------------------------

DrawTilemapH64:
	lea	VDPCTRL,a2			; VDP control port
	lea	VDPDATA,a3			; VDP data port
	move.l	#$800000,d4			; Row delta

.DrawRow:
	move.l	d0,(a2)				; Set VDP command
	move.w	d1,d3				; Get width

.DrawTile:
	move.w	(a1)+,(a3)			; Draw tile
	dbf	d3,.DrawTile			; Loop until row is written
	
	add.l	d4,d0				; Next row
	dbf	d2,.DrawRow			; Loop until map is drawn
	rts

; -------------------------------------------------------------------------
; Draw a tilemap (for 128 tile wide planes)
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - VDP command
;	d1.w - Width
;	d2.w - Height
;	a1.l - Pointer to tilemap
; -------------------------------------------------------------------------

DrawTilemapH128:
	lea	VDPCTRL,a2			; VDP control port
	lea	VDPDATA,a3			; VDP data port
	move.l	#$1000000,d4			; Row delta

.DrawRow:
	move.l	d0,(a2)				; Set VDP command
	move.w	d1,d3				; Get width

.DrawTile:
	move.w	(a1)+,(a3)			; Draw tile
	dbf	d3,.DrawTile			; Loop until row is written
	
	add.l	d4,d0				; Next row
	dbf	d2,.DrawRow			; Loop until map is drawn
	rts

; -------------------------------------------------------------------------

	include	"Title Screen/Secrets/Functions.asm"

; -------------------------------------------------------------------------

	dcb.b	$FF5000-*, 0

; -------------------------------------------------------------------------
