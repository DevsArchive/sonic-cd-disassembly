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
		WORKRAMFILE, $4000, &
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

	bsr.w	DrawHeader			; Draw header text

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

	cmpi.w	#7,fmSelID			; Is the 8th special stage code entered in?
	bne.s	.Exit				; If not, branch
	cmpi.w	#7,pcmSelID
	bne.s	.Exit
	cmpi.w	#7,cddaSelID
	bne.s	.Exit
	
	bsr.w	StopZ80				; Play warp sound
	move.b	#FM_SSWARP,FMDrvQueue2
	bsr.w	StartZ80

	bsr.w	FadeToWhite			; Fade to white
	moveq	#1,d0
	rts

.Exit:
	bsr.w	FadeToBlack			; Fade to black
	moveq	#0,d0
	rts

; -------------------------------------------------------------------------

.SoundSels:
	dc.w	SelectFM-.SoundSels		; FM
	dc.w	SelectPCM-.SoundSels		; PCM
	dc.w	SelectCDDA-.SoundSels		; CDDA

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
	bsr.w	DrawFMText			; Draw base text
	bsr.w	DrawPCMText
	bsr.w	DrawCDDAText

	cmpi.w	#0,soundType			; Is FM sound selected?
	beq.w	DrawFMTextSel			; If so, branch
	cmpi.w	#1,soundType			; Is PCM sound selected?
	beq.w	DrawPCMTextSel			; If so, branch
	bra.w	DrawCDDATextSel

; -------------------------------------------------------------------------
; Draw header text
; -------------------------------------------------------------------------

DrawHeader:
	lea	Map_HeaderText(pc),a1		; Draw text
	VDPCMD	move.l,$C39E,VRAM,WRITE,d0
	moveq	#$A-1,d1
	moveq	#2-1,d2
	bra.w	DrawTilemapH64

; -------------------------------------------------------------------------
; Draw FM sound selection header text
; -------------------------------------------------------------------------

DrawFMText:
	lea	Map_FMText(pc),a1		; Draw text
	VDPCMD	move.l,$C58A,VRAM,WRITE,d0
	moveq	#6-1,d1
	moveq	#2-1,d2
	bra.w	DrawTilemapH64

; -------------------------------------------------------------------------
; Draw FM sound selection header text (selected)
; -------------------------------------------------------------------------

DrawFMTextSel:
	lea	Map_FMTextSel(pc),a1		; Draw text
	VDPCMD	move.l,$C58A,VRAM,WRITE,d0
	moveq	#6-1,d1
	moveq	#2-1,d2
	bra.w	DrawTilemapH64

; -------------------------------------------------------------------------
; Draw PCM sound selection header text
; -------------------------------------------------------------------------

DrawPCMText:
	lea	Map_PCMText(pc),a1		; Draw text
	VDPCMD	move.l,$C59E,VRAM,WRITE,d0
	moveq	#7-1,d1
	moveq	#2-1,d2
	bra.w	DrawTilemapH64

; -------------------------------------------------------------------------
; Draw PCM sound selection header text (selected)
; -------------------------------------------------------------------------

DrawPCMTextSel:
	lea	Map_PCMTextSel(pc),a1		; Draw text
	VDPCMD	move.l,$C59E,VRAM,WRITE,d0
	moveq	#7-1,d1
	moveq	#2-1,d2
	bra.w	DrawTilemapH64

; -------------------------------------------------------------------------
; Draw CDDA sound selection header text
; -------------------------------------------------------------------------

DrawCDDAText:
	lea	Map_CDDAText(pc),a1		; Draw text
	VDPCMD	move.l,$C5B4,VRAM,WRITE,d0
	moveq	#6-1,d1
	moveq	#2-1,d2
	bra.w	DrawTilemapH64

; -------------------------------------------------------------------------
; Draw CDDA sound selection header text (selected)
; -------------------------------------------------------------------------

DrawCDDATextSel:
	lea	Map_CDDATextSel(pc),a1		; Draw text
	VDPCMD	move.l,$C5B4,VRAM,WRITE,d0
	moveq	#6-1,d1
	moveq	#2-1,d2
	bra.w	DrawTilemapH64

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
	
Map_HeaderText:
	dc.w $001A, $0001, $001C, $0017, $000E, $0000, $001B, $000F, $001A, $001B
	dc.w $0021, $0021, $0021, $002E, $0027, $0000, $0022, $0028, $0021, $0022
	
Map_FMText:
	dc.w $600F, $6016, $0000, $6017, $6001, $0000
	dc.w $6029, $602D, $0000, $602E, $6021, $603C
	
Map_FMTextSel:
	dc.w $200F, $2016, $0000, $2017, $2001, $0000
	dc.w $2029, $202D, $0000, $202E, $2021, $203C
	
Map_PCMText:
	dc.w $6018, $600D, $6016, $0000, $6017, $6001, $0000
	dc.w $602F, $6021, $602D, $0000, $602E, $6021, $603C
	
Map_PCMTextSel:
	dc.w $2018, $200D, $2016, $0000, $2017, $2001, $0000
	dc.w $202F, $2021, $202D, $0000, $202E, $2021, $203C
	
Map_CDDAText:
	dc.w $600E, $600B, $0000, $6017, $6001, $0000
	dc.w $6027, $6026, $0000, $602E, $6021, $603C
	
Map_CDDATextSel:
	dc.w $200E, $200B, $0000, $2017, $2001, $0000
	dc.w $2027, $2026, $0000, $202E, $2021, $203C

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

	dcb.b	$FF6000-*, 0

; -------------------------------------------------------------------------
