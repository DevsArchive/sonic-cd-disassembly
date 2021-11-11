; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Backup RAM initialization
; -------------------------------------------------------------------------

	include	"_inc/common.i"
	include	"_inc/maincpu.i"
	include	"_inc/mainvars.i"
	include	"_inc/buram.i"
	include	"_inc/sound.i"
	include	"_inc/mmd.i"

; -------------------------------------------------------------------------
; Variables
; -------------------------------------------------------------------------

	rsset	WORKRAM+$FF00A000
VARSSTART	rs.b	0			; Start of variables
decompBuffer	rs.b	$2D00			; Decompression buffer
vsyncFlag	rs.b	1			; VSync flag
		RSEVEN
vintRoutine	rs.w	1			; V-INT routine ID
timer		rs.w	1			; Timer
vintCounter	rs.w	1			; V-INT counter
savedSR		rs.w	1			; Saved status register
lagCounter	rs.l	1			; Lag counter
rngSeed		rs.l	1			; Random number generator seed
		rs.b	$2EEE
VARSLEN		EQU	__rs-VARSSTART		; Size of variables area

ctrlData	EQU	GACOMCMDE		; Controller data
ctrlPress	EQU	ctrlData		; Controller pressed buttons data
ctrlTap		EQU	ctrlData+1		; Controller tapped buttons data

; -------------------------------------------------------------------------
; MMD header
; -------------------------------------------------------------------------

	MMD	0, &
		WORKRAMFILE, End-Start, &
		Start, 0, VInterrupt

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

	bsr.w	SyncWithSubCPU1			; Wait for Sub CPU to need Word RAM access
	bsr.w	GiveWordRAMAccess		; Give Sub CPU Word RAM Access
	bsr.w	SyncWithSubCPU2			; Wait for Sub CPU to finish initializing
	
	lea	VARSSTART.w,a0			; Clear variables
	move.w	#VARSLEN/4-1,d7

.ClearVars:
	move.l	#0,(a0)+
	dbf	d7,.ClearVars

	move.w	#0,vintRoutine.w		; Reset V-INT routine ID
	
	bsr.w	InitBuRAM			; Initialize Backup RAM
	cmpi.w	#-1,d0				; Is internal Backup RAM unformatted?
	beq.w	InternalUnformatted		; If so, branch
	cmpi.w	#-2,d0				; Is the RAM cartridge unformatted?
	beq.w	CartUnformatted			; If so, branch

	bsr.w	InitBuRAMParams			; Set up Backup RAM parameters
	bsr.w	SearchBuRAM			; Check if there's already save data stored
	bne.s	.NotFound			; If not, branch

	bsr.w	ReadBuRAM			; Read save data from Backup RAM
	bne.w	BuRAMCorrupted			; If it failed to read, branch
	
	move.b	#0,saveDisabled			; Enable Backup RAM saving
	bsr.w	JmpTo_ReadSaveData		; Read save data
	bra.w	.Success			; Exit

.NotFound:
	bsr.w	InitSaveData			; Initialize save data
	bsr.w	WriteBuRAM			; Write it to Backup RAM
	beq.s	.WriteSave			; If it was successful, branch
	
	move.b	#1,saveDisabled			; Disable Backup RAM saving
	bsr.w	JmpTo_WriteSaveData		; Write temporary save data
	bsr.w	DeleteBuRAM			; Delete save data from Backup RAM
	bra.w	BuRAMFull			; Display Backup RAM full message

.WriteSave:
	move.b	#0,saveDisabled			; Enable Backup RAM saving
	bsr.w	JmpTo_WriteSaveData		; Write save data

.Success:
	bsr.w	Finish				; Finish operations
	moveq	#0,d0				; Mark as successful
	rts

; -------------------------------------------------------------------------
; V-BLANK interrupt
; -------------------------------------------------------------------------

VInterrupt:
	movem.l	d0-a6,-(sp)			; Save registers

	move.b	#1,GAIRQ2			; Trigger IRQ2 on Sub CPU
	tst.b	vsyncFlag.w			; Are we lagging?
	beq.w	.Lag				; If so, branch
	move.b	#0,vsyncFlag.w			; Clear VSync flag

	lea	VDPCTRL,a1			; VDP control port
	lea	VDPDATA,a2			; VDP data port
	move.w	(a1),d0				; Reset V-INT occurance flag
	jsr	StopZ80(pc)			; Stop the Z80

	move.w	vintRoutine.w,d0		; Execute routine
	add.w	d0,d0
	move.w	.Routines(pc,d0.w),d0
	jmp	.Routines(pc,d0.w)

; -------------------------------------------------------------------------

.Routines:
	dc.w	.Main-.Routines

; -------------------------------------------------------------------------
; Main V-INT routine
; -------------------------------------------------------------------------

.Main:
	bra.w	.Main2

.Main2:
	bsr.w	StartZ80			; Start the Z80
	tst.w	timer.w				; Is the timer active?
	beq.s	.NoTimer			; If not, branch
	subq.w	#1,timer.w			; Decrement timer

.NoTimer:
	addq.w	#1,vintCounter.w		; Increment counter
	jsr	ReadController(pc)		; Read controller data

	movem.l	(sp)+,d0-a6			; Restore registers
	rte

; -------------------------------------------------------------------------
; Lag V-INT routine
; -------------------------------------------------------------------------

.Lag:
	addq.l	#1,lagCounter.w			; Increment lag counter
	move.b	vintRoutine+1.w,lagCounter.w	; Set highest byte to V-INT routine ID
	jsr	ReadController(pc)		; Read controller data

	movem.l	(sp)+,d0-a6			; Restore registers
	rte

; -------------------------------------------------------------------------
; Backup RAM corrupted error
; -------------------------------------------------------------------------

BuRAMCorrupted:
	moveq	#0,d0				; Show message
	bsr.w	ShowMessage
	bra.w	ErrorLoop			; Enter infinite loop

; -------------------------------------------------------------------------
; Unformatted internal Backup RAM error
; -------------------------------------------------------------------------

InternalUnformatted:
	moveq	#1,d0				; Show message
	bsr.w	ShowMessage
	bra.w	ErrorLoop			; Enter infinite loop

; -------------------------------------------------------------------------
; Unformatted RAM cartridge error
; -------------------------------------------------------------------------

CartUnformatted:
	moveq	#2,d0				; Show message
	bsr.w	ShowMessage
	bra.w	ErrorLoop			; Enter infinite loop

; -------------------------------------------------------------------------
; Backup RAM full warning
; -------------------------------------------------------------------------

BuRAMFull:
	moveq	#3,d0				; Shoe message
	bsr.w	ShowMessage

.WaitUser:
	move.b	ctrlTap,d0			; Get tapped buttons
	andi.b	#$F0,ctrlTap			; Were A, B, C, or start pressed?
	beq.s	.WaitUser			; If not, wait

	bsr.w	Finish				; Finish operations
	moveq	#1,d0				; Mark as failed
	rts

; -------------------------------------------------------------------------
; Fatal error infinite loop
; -------------------------------------------------------------------------

ErrorLoop:
	bra.w	*

; -------------------------------------------------------------------------
; Show a message
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.b - Message ID
;	       0 = Backup RAM corrupted
;	       1 = Internal Backup RAM unformatted
;	       2 = RAM cartridge unformatted
;	       3 = Backup RAM full
; -------------------------------------------------------------------------

ShowMessage:
	move.l	d0,-(sp)			; Save message ID

	bsr.w	InitMessage			; Initialize message
	bclr	#6,ipxVDPReg1+1			; Disable display
	move.w	ipxVDPReg1,VDPCTRL

	VDPCMD	move.l,$BC00,VRAM,WRITE,VDPCTRL	; Disable sprites
	lea	VDPDATA,a6
	moveq	#0,d0
	move.l	d0,(a6)
	move.l	d0,(a6)

	move.l	#$00010203,d0			; Load art
	jsr	LoadMessageArt

	move.l	(sp)+,d0			; Restore message ID
	add.w	d0,d0

	move.l	d0,-(sp)			; Load first tilemap
	jsr	LoadMessageMap
	move.l	(sp)+,d0

	addq.w	#1,d0				; Load second tilemap
	jsr	LoadMessageMap
	
	bset	#6,ipxVDPReg1+1			; Enable display
	move.w	ipxVDPReg1,VDPCTRL
	rts

; -------------------------------------------------------------------------
; Finish operations
; -------------------------------------------------------------------------

Finish:
	nop
	bset	#7,GAMAINFLAG			; Tell Sub CPU we are done

.WaitSubCPU:
	bsr.w	GiveWordRAMAccess		; Give Sub CPU Word RAM access
	btst	#7,GASUBFLAG			; Is the Sub CPU done?
	beq.s	.WaitSubCPU

	moveq	#0,d0				; Clear communication commands
	move.l	d0,GACOMCMD0
	move.l	d0,GACOMCMD4
	move.l	d0,GACOMCMD8
	move.l	d0,GACOMCMDC
	move.b	d0,GAMAINFLAG
	rts

; -------------------------------------------------------------------------
; Unused function to send some kind of command ID to the Sub CPU
; -------------------------------------------------------------------------

UnkSubCPUCmd:
	move.w	#1,GACOMCMD2			; Send command

.WaitSubCPU:
	tst.w	GACOMSTAT2			; Has the Sub CPU acknowledged it?
	beq.s	.WaitSubCPU
	
	move.w	#0,GACOMCMD2			; Tell Sub CPU we are ready to send more commands

.WaitSubCPU2:
	tst.w	GACOMSTAT2			; Is the Sub CPU ready for more commands?
	bne.s	.WaitSubCPU2			; If not, wait
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
; Wait for Word RAM access
; -------------------------------------------------------------------------

WaitWordRAMAccess:
	btst	#0,GAMEMMODE			; Do we have Word RAM access?
	beq.s	WaitWordRAMAccess		; If not, wait
	rts

; -------------------------------------------------------------------------
; Sync with Sub CPU (wait flag set)
; -------------------------------------------------------------------------

SyncWithSubCPU1:
	btst	#7,GASUBFLAG			; Are we synced with the Sub CPU?
	beq.s	SyncWithSubCPU1			; If not, wait
	rts

; -------------------------------------------------------------------------
; Sync with Sub CPU (wait flag clear)
; -------------------------------------------------------------------------

SyncWithSubCPU2:
	btst	#7,GASUBFLAG			; Are we synced with the Sub CPU?
	bne.s	SyncWithSubCPU2			; If not, wait
	rts

; -------------------------------------------------------------------------
; Initialize message
; -------------------------------------------------------------------------

InitMessage:
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

	bsr.w	StopZ80				; Stop the Z80
	DMAFILL	0,$10000,0			; Clear VRAM

	VDPCMD	move.l,$C000,VRAM,WRITE,VDPCTRL	; Clear Plane A
	move.w	#$1000/2-1,d7

.ClearPlaneA:
	move.w	#0,VDPDATA
	dbf	d7,.ClearPlaneA

	VDPCMD	move.l,$E000,VRAM,WRITE,VDPCTRL	; Clear Plane B
	move.w	#$1000/2-1,d7

.ClearPlaneB:
	move.w	#0,VDPDATA
	dbf	d7,.ClearPlaneB

	VDPCMD	move.l,0,CRAM,WRITE,VDPCTRL	; Load palette
	lea	.Palette(pc),a0
	moveq	#(.PaletteEnd-.Palette)/4-1,d7

.LoadPal:
	move.l	(a0)+,VDPDATA
	dbf	d7,.LoadPal

	VDPCMD	move.l,0,VSRAM,WRITE,VDPCTRL	; Clear VSRAM
	moveq	#VSCROLLSZ/4-1,d0

.ClearVSRAM:
	move.w	#0,VDPDATA
	move.w	#0,VDPDATA
	dbf	d0,.ClearVSRAM

	bsr.w	StartZ80			; Start the Z80
	move.w	#$8134,ipxVDPReg1		; Reset IPX VDP register 1 cache
	rts

; -------------------------------------------------------------------------

.Palette:
	incbin	"buram/init/data/palette.pal"
.PaletteEnd:
	even

.VDPRegs:
	dc.b	%00000100			; No H-INT
	dc.b	%00110100			; V-INT, DMA, mode 5
	dc.b	$C000/$400			; Plane A location
	dc.b	0				; Window location
	dc.b	$E000/$2000			; Plane B location
	dc.b	$BC00/$200			; Sprite table location
	dc.b	0				; Reserved
	dc.b	0				; BG color line 0 color 0
	dc.b	0				; Reserved
	dc.b	0				; Reserved
	dc.b	0				; H-INT counter 0
	dc.b	%00000110			; Scroll by tile
	dc.b	%10000001			; H40
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

	move.b	#0,(a1)				; Pull TH low
	tst.w	(a0)				; Delay
	move.b	(a1),d0				; Read start and A buttons
	lsl.b	#2,d0
	andi.b	#$C0,d0
	
	move.b	#$40,(a1)			; Pull TH high
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
; Load dummy Z80 code
; -------------------------------------------------------------------------

LoadDummyZ80:
	Z80RESOFF				; Set Z80 reset off
	jsr	StopZ80(pc)			; Stop the Z80

	lea	Z80RAM,a1			; Load dummy Z80 code
	move.b	#$F3,(a1)+			; DI
	move.b	#$F3,(a1)+			; DI
	move.b	#$C3,(a1)+			; JP $0000
	move.b	#0,(a1)+
	move.b	#0,(a1)+

	Z80RESON				; Set Z80 reset on
	Z80RESOFF				; Set Z80 reset off
	jmp	StartZ80(pc)			; Start the Z80
	rts

; -------------------------------------------------------------------------
; Play an FM sound in queue 2
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.b - FM sound ID
; -------------------------------------------------------------------------

PlaySound2:
	move.b	d0,fmSndQueue2.w
	rts

; -------------------------------------------------------------------------
; Play an FM sound in queue 3
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.b - FM sound ID
; -------------------------------------------------------------------------

PlaySound3:
	move.b	d0,fmSndQueue3.w
	rts

; -------------------------------------------------------------------------
; Flush the sound queue
; -------------------------------------------------------------------------

FlushSoundQueue:
	jsr	StopZ80				; Stop the Z80

.CheckQueue2:
	tst.b	fmSndQueue2.w			; Is the 2nd sound queue set?
	beq.s	.CheckQueue3			; If not, branch
	move.b	fmSndQueue2.w,FMDrvQueue	; Queue sound in driver
	move.b	#0,fmSndQueue2.w		; Clear 2nd sound queue
	bra.s	.End				; Exit

.CheckQueue3:
	tst.b	fmSndQueue3.w			; Is the 3rd sound queue set?
	beq.s	.End				; If not, branch
	move.b	fmSndQueue3.w,FMDrvQueue	; Queue sound in driver
	move.b	#0,fmSndQueue3.w		; Clear 3rd sound queue

.End:
	jmp	StartZ80			; Start the Z80

; -------------------------------------------------------------------------
; Mass fill 128 bytes
; -------------------------------------------------------------------------
; PARAMETERS:
;	d1.l - Value to fill with
;	a1.l - Pointer to destination buffer
; -------------------------------------------------------------------------

MassFill:
	rept	32
		move.l	d1,(a1)+
	endr
	rts

; -------------------------------------------------------------------------
; Mass fill 128 bytes (VDP)
; -------------------------------------------------------------------------
; PARAMETERS:
;	d1.l - Value to fill with
;	a1.l - VDP control port
; -------------------------------------------------------------------------

MassFillVDP:
	rept	32
		move.l	d1,(a1)
	endr
	rts

; -------------------------------------------------------------------------
; Mass copy 128 bytes
; -------------------------------------------------------------------------
; PARAMETERS:
;	a1.l - Pointer to source data
;	a2.l - Pointer to destination buffer
; -------------------------------------------------------------------------

MassCopy:
	rept	32
		move.l	(a1)+,(a2)+
	endr
	rts

; -------------------------------------------------------------------------
; Mass copy 128 bytes (VDP)
; -------------------------------------------------------------------------
; PARAMETERS:
;	a1.l - Pointer to source data
;	a2.l - VDP control port
; -------------------------------------------------------------------------

MassCopyVDP:
	rept	32
		move.l	(a1)+,(a2)
	endr
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
; Press down all buttons
; -------------------------------------------------------------------------

PressAllButtons:
	move.w	#$FF00,ctrlData			; Press down all buttons
	rts

; -------------------------------------------------------------------------
; Random number generator
; -------------------------------------------------------------------------
; RETURNS:
;	d0.l - Random number
; -------------------------------------------------------------------------

Random:
	move.l	d1,-(sp)			; Save d1
	move.l	rngSeed.w,d1			; Get RNG seed
	bne.s	.GetRandom			; If it's set, branch
	move.l	#$2A6D365A,d1			; If not, initialize it

.GetRandom:
	move.l	d1,d0				; Perform various operations
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
	move.l	(sp)+,d1			; Restore d1
	rts

; -------------------------------------------------------------------------
; Run Backup RAM cartridge command
; -------------------------------------------------------------------------

RAMCartBuRAMCmd:
	moveq	#0,d0				; Get command ID
	move.b	commandID,d0
	beq.s	.End				; If it's zero, branch
	subq.w	#1,d0
	cmpi.w	#(.CommandsEnd-.Commands)/2,d0	; Is it too large?
	bcc.s	.Error				; If so, branch

	add.w	d0,d0				; Execute command
	lea	.Commands,a0
	move.w	(a0,d0.w),d0
	moveq	#0,d1
	jsr	(a0,d0.w)
	bcs.s	.Error				; If an error occured, branch

	move.b	#0,cmdStatus			; Mark as a success
	bra.s	.GetReturnVals

.Error:
	move.b	#-1,cmdStatus			; Mark as a failure

.GetReturnVals:
	move.w	d0,buramD0			; Store return values
	move.w	d1,buramD1
	clr.b	commandID			; Mark command as completed

.End:
	rts

; -------------------------------------------------------------------------

.Commands:
	dc.w	Cmd_InitCartBuRAM-.Commands	; Initialize Backup RAM interaction
	dc.w	Cmd_CartBuRAMStatus-.Commands	; Get Backup RAM status
	dc.w	Cmd_SearchCartBuRAM-.Commands	; Search Backup RAM
	dc.w	Cmd_ReadCartBuRAM-.Commands	; Read from Backup RAM
	dc.w	Cmd_WriteCartBuRAM-.Commands	; Write to Backup RAM
	dc.w	Cmd_DeleteCartBuRAM-.Commands	; Delete Backup RAM
	dc.w	Cmd_FormatCartBuRAM-.Commands	; Format Backup RAM
	dc.w	Cmd_GetCartBuRAMDir-.Commands	; Get Backup RAM directory
	dc.w	Cmd_VerifyCartBuRAM-.Commands	; Verify Backup RAM
.CommandsEnd:

; -------------------------------------------------------------------------
; Initialize cartridge Backup RAM interaction
; -------------------------------------------------------------------------

Cmd_InitCartBuRAM:
	lea	CartBuRAMScratch,a0
	lea	CartBuRAMStrings,a1
	moveq	#BRMINIT,d0
	jmp	_BURAM.w

; -------------------------------------------------------------------------
; Get cartridge Backup RAM status	
; -------------------------------------------------------------------------

Cmd_CartBuRAMStatus:
	moveq	#BRMSTAT,d0
	movea.l	#CartBuRAMStrings,a1
	jmp	_BURAM.w

; -------------------------------------------------------------------------
; Search cartridge Backup RAM
; -------------------------------------------------------------------------

Cmd_SearchCartBuRAM:
	movea.l	#buramParams,a0
	move.b	#0,buramMisc(a0)
	move.l	#0,buramMisc+1(a0)
	moveq	#BRMSERCH,d0
	jmp	_BURAM.w

; -------------------------------------------------------------------------
; Read from cartridge Backup RAM
; -------------------------------------------------------------------------

Cmd_ReadCartBuRAM:
	movea.l	#buramParams,a0
	move.b	#0,buramMisc(a0)
	move.l	#0,buramMisc+1(a0)
	movea.l	#buramData,a1
	moveq	#BRMREAD,d0
	jsr	_BURAM.w
	rts

; -------------------------------------------------------------------------
; Write to cartridge Backup RAM
; -------------------------------------------------------------------------

Cmd_WriteCartBuRAM:
	movea.l	#buramParams,a0
	move.b	writeFlag,buramFlag(a0)
	move.w	blockSize,buramBlkSz(a0)
	movea.l	#buramData,a1
	moveq	#BRMWRITE,d0
	jsr	_BURAM.w
	rts

; -------------------------------------------------------------------------
; Delete cartridge Backup RAM
; -------------------------------------------------------------------------

Cmd_DeleteCartBuRAM:
	movea.l	#buramParams,a0
	move.b	#0,buramMisc(a0)
	move.l	#0,buramMisc+1(a0)
	moveq	#BRMDEL,d0
	jmp	_BURAM.w

; -------------------------------------------------------------------------
; Format cartridge Backup RAM
; -------------------------------------------------------------------------

Cmd_FormatCartBuRAM:
	moveq	#BRMFORMAT,d0
	jmp	_BURAM.w

; -------------------------------------------------------------------------
; Get cartridge Backup RAM directory
; -------------------------------------------------------------------------

Cmd_GetCartBuRAMDir:
	movea.l	#buramParams,a0
	move.b	#0,buramMisc(a0)
	move.l	#0,buramMisc+1(a0)
	movea.l	#buramData+4,a1
	move.l	buramData,d1
	moveq	#BRMDIR,d0
	jmp	_BURAM.w

; -------------------------------------------------------------------------
; Verify cartridge Backup RAM
; -------------------------------------------------------------------------

Cmd_VerifyCartBuRAM:
	movea.l	#buramParams,a0
	move.b	writeFlag,buramFlag(a0)
	move.w	blockSize,buramBlkSz(a0)
	movea.l	#buramData,a1
	moveq	#BRMVERIFY,d0
	jmp	_BURAM.w

; -------------------------------------------------------------------------
; Backup RAM data
; -------------------------------------------------------------------------

CartBuRAMScratch:
	dcb.b	$640*2, 0			; Cartridge scratch RAM

CartBuRAMStrings:	
	dcb.b	$C, 0				; Cartridge display strings

	include	"buram/datainitial.asm"		; Initial data

; -------------------------------------------------------------------------
; Get type of Backup RAM to use
; -------------------------------------------------------------------------

GetBuRAMType:
	bsr.w	CheckRAMCartFound		; Check if a RAM cartridge was found
	bne.s	.SetType			; If so, branch
	clr.b	d0				; Use internal Backup RAM

.SetType:
	move.b	d0,buramType			; Set type
	rts

; -------------------------------------------------------------------------
; Check which kind of Backup RAM is being used
; -------------------------------------------------------------------------

CheckBuRAMType:
	tst.b	buramType
	rts

; -------------------------------------------------------------------------
; Check if a RAM cartridge was found
; -------------------------------------------------------------------------

CheckRAMCartFound:
	tst.b	ramCartFound
	rts

; -------------------------------------------------------------------------
; Initialize and read save data
; -------------------------------------------------------------------------

InitReadSaveData:
	bsr.w	InitBuRAM			; Initialize Backup RAM interaction
	bsr.w	InitBuRAMParams		; Set up parameters
	bsr.w	JmpTo_ReadSaveData		; Read save data
	rts

; -------------------------------------------------------------------------
; Write save data
; -------------------------------------------------------------------------

JmpTo_WriteSaveData:
	bra.w	WriteSaveDAta

; -------------------------------------------------------------------------
; Read save data
; -------------------------------------------------------------------------

JmpTo_ReadSaveData:
	bra.w	ReadSaveDAta

; -------------------------------------------------------------------------
; Initialize save data
; -------------------------------------------------------------------------

InitSaveData:
	jsr	WaitWordRAMAccess		; Wait for Word RAM access
	
	lea	BuRAMTimeAttack,a0		; Setup time attack save data
	lea	buramData,a1
	move.w	#BURAMTIMESZ/4-1,d0

.SetupTimeAttackData:
	move.l	(a0)+,(a1)+
	dbf	d0,.SetupTimeAttackData

	lea	BuRAMMain,a0			; Setup main save data
	lea	buramData+BURAMTIMESZ,a1
	move.w	#BURAMMAINSZ/4-1,d0

.SetupMainData:
	move.l	(a0)+,(a1)+
	dbf	d0,.SetupMainData

	move.b	#0,writeFlag			; Set Backup RAM write flag
	move.w	#$B,blockSize			; Set Backup RAM block size
	rts

; ----------------------- --------------------------------------------------
; Initialize Backup RAM parameters
; -------------------------------------------------------------------------

InitBuRAMParams:
	move.b	#0,writeFlag			; Set Backup RAM write flag
	move.w	#$B,blockSize			; Set Backup RAM block size
	lea	.FileName,a0			; Set file name
	bra.s	SetBuRAMFilename

.FileName:
	dc.b	"SONICCD____"
	even

; -------------------------------------------------------------------------
; Set Backup RAM file name
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to file name
; -------------------------------------------------------------------------

SetBuRAMFileName:
	movem.l	a0-a1,-(sp)			; Save registers
	movea.l	#buramParams,a1			; Copy file name
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	movem.l	(sp)+,a0-a1			; Restore registers
	rts

; -------------------------------------------------------------------------
; Run Backup RAM command
; -------------------------------------------------------------------------

RunBuRAMCmd:
	bsr.w	CheckBuRAMType			; Check which type of Backup RAM we are using
	bne.s	.RAMCart			; If we are using a RAM cartridge, branch
	move.b	saveDisabled,buramDisabled	; Copy save disabled flag
	jsr	GiveWordRAMAccess		; Give Sub CPU Word RAM access
	jsr	WaitWordRAMAccess		; Wait for Word RAM access
	bra.s	.CheckStatus			; Check status

.RAMCart:
	bsr.w	RAMCartBuRAMCmd			; Run RAM cartridge command

.CheckStatus:
	tst.b	cmdStatus			; Check status
	rts

; -------------------------------------------------------------------------
; Initialize Backup RAM interaction
; -------------------------------------------------------------------------
; RETURNS:
;	d0.w - Status
;	        0 = Using RAM cartridge
;	        1 = Using internal Backup RAM
;	       -1 = Internal Backup RAM unformatted
;	       -2 = RAM cartridge unformatted
; -------------------------------------------------------------------------

InitBuRAM:
	jsr	WaitWordRAMAccess		; Wait for Word RAM access
	bsr.w	DetectRAMCart			; Detect RAM cartridge
	bne.w	.NoRAMCart			; If there is no RAM cartridge, branch
	
	move.b	#BRTYPE_CART,buramType		; Set Backup RAM type to RAM cartridge
	move.b	#BRCMD_INIT,commandID		; Initialize Backup RAM interaction
	bsr.s	RunBuRAMCmd
	tst.b	cmdStatus			; Was it a success?
	beq.s	.FoundRAMCart			; If so, branch
	tst.w	buramD1				; Is the RAM cartridge unformatted?
	bne.s	.CartUnformatted		; If so, branch

.NoRAMCart:
	move.b	#0,ramCartFound			; RAM cartridge not found
	bra.s	.InitInternal			; Initialize internal Backup RAM interaction

.FoundRAMCart:
	bsr.w	GetBuRAMStatus			; Get Backup RAM status
	move.b	#1,ramCartFound			; RAM cartridge found

.InitInternal:
	move.b	#BRTYPE_INT,buramType		; Set Backup RAM type to internal
	move.b	#BRCMD_INIT,commandID		; Initialize Backup RAM interaction
	bsr.w	RunBuRAMCmd
	tst.b	cmdStatus			; Was it a success?
	bne.s	.IntUnformatted			; If not, branch
	bsr.w	GetBuRAMStatus			; Get Backup RAM status
	
	tst.b	ramCartFound			; Was a RAM cartridge found?
	beq.s	.NoRAMCart2			; If not, branch
	move.w	#0,d0				; Using RAM cartridge
	rts

.NoRAMCart2:
	move.w	#1,d0				; Using internal Backup RAM
	move.w	#0,d1
	rts

.IntUnformatted:
	move.w	#-1,d0				; Internal Backup RAM unformatted
	rts

.CartUnformatted:
	move.w	#-2,d0				; RAM cartridge unformatted
	rts

; -------------------------------------------------------------------------
; Detect RAM cartridge
; -------------------------------------------------------------------------
; RETURNS:
;	eq/ne - Found/Not found
;	d0.l  - Status
;	         0 = Found
;	        -1 = Not found
; -------------------------------------------------------------------------

DetectRAMCart:
	btst	#7,CARTID			; Is there a special RAM cartridge?
	beq.s	.NormalRAMCart			; If not, branch

	lea	CARTSPECID,a0			; Check for signature
	lea	.RAMSignature,a1
	moveq	#12/4-1,d0

.CheckSpecSig:
	cmpm.l	(a0)+,(a1)+
	bne.s	.NormalRAMCart			; If signature is present, branch
	dbf	d0,.CheckSpecSig

	movea.l	#_BURAM,a0			; Unsure what this does
	jsr	CARTSPECPRG
	bra.w	.Found				; Mark as found

.NormalRAMCart:
	btst	#7,CARTID			; Were we just checking for special RAM cartridge data?
	bne.w	.NotFound			; If so, branch

	move.b	CARTID,d0			; Get size of cartridge data
	andi.l	#7,d0
	move.l	#$2000,d1
	lsl.l	d0,d1
	lsl.l	#1,d1				; Data is stored every other byte

	lea	CARTDATA-($40*2)-1,a2		; Go to end of cartridge data
	adda.l	d1,a2
	
	movea.l	a2,a0				; Check for RAM signature
	adda.w	#$30*2,a0
	lea	.RAMSignature,a1
	movep.l	1(a0),d1
	cmp.l	(a1),d1
	bne.w	.NoSigFound			; If it's not present, branch
	movep.l	1+(4*2)(a0),d1
	cmp.l	4(a1),d1
	bne.w	.NoSigFound			; If it's not present, branch
	movep.l	1+(8*2)(a0),d1
	cmp.l	8(a1),d1
	bne.w	.NoSigFound			; If it's not present, branch

	movea.l	a2,a0				; Check for format signature
	adda.w	#$20*2,a0
	lea	.FormatSig,a1
	movep.l	1(a0),d1
	cmp.l	(a1),d1
	bne.w	.NoSigFound			; If it's not present, branch
	movep.l	1+(4*2)(a0),d1
	cmp.l	4(a1),d1
	bne.w	.NoSigFound			; If it's not present, branch
	movep.l	1+(8*2)(a0),d1
	cmp.l	8(a1),d1
	bne.w	.NoSigFound
	
	bra.w	.Found				; Mark as found

.NoSigFound:
	bset	#0,CARTWREN			; Enable writing
	lea	CARTDATA,a0			; RAM cartridge data
	move.b	(a0),d0				; Save first byte
	
	move.b	#$5A,(a0)			; Write random value
	cmpi.b	#$5A,(a0)			; Was it written?
	bne.s	.WriteFailed			; If not, branch
	move.b	#$A5,(a0)			; Write another random value
	cmpi.b	#$A5,(a0)			; Was it written?
	bne.s	.WriteFailed			; If not, branch

	move.b	d0,(a0)				; Restorefirst byte
	bclr	#0,CARTWREN			; Disable writing
	bra.s	.Found2				; Mark as found

.WriteFailed:
	bclr	#0,CARTWREN			; Disable writing
	bra.s	.NotFound			; Mark as not found

.Found:
	moveq	#0,d0				; Mark as found
	rts

.Found2:
	moveq	#0,d0				; Mark as found
	rts

.NotFound:
	moveq	#-1,d0				; Mark as not found
	rts

; -------------------------------------------------------------------------

.RAMSignature:
	dc.b	"RAM_CARTRIDG"
	even

.FormatSig:
	dc.b	"SEGA_CD_ROM"
	even

; -------------------------------------------------------------------------
; Get Backup RAM directory
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - H: Number of files to skip when all files can't be read
;	          read in one try
;	       L: Size of directory buffer
; -------------------------------------------------------------------------

GetBuRAMDir:
	move.l	d0,-(sp)			; Wait for Word RAM access
	jsr	WaitWordRAMAccess
	move.l	(sp)+,d0

	move.l	d0,buramData			; Set parameters
	lea	.Template,a0			; Set template file name
	bsr.w	SetBuRAMFileName

	move.b	#BRCMD_DIR,commandID		; Get directory
	bra.w	RunBuRAMCmd

; -------------------------------------------------------------------------

.Template:
	dc.b	"***********"
	even

; -------------------------------------------------------------------------
; Get Backup RAM status
; -------------------------------------------------------------------------

GetBuRAMStatus:
	jsr	WaitWordRAMAccess		; Wait for Word RAM access
	move.b	#BRCMD_STATUS,commandID		; Get Backup RAM status
	bra.w	RunBuRAMCmd

; -------------------------------------------------------------------------
; Search Backup RAM
; -------------------------------------------------------------------------

SearchBuRAM:
	jsr	WaitWordRAMAccess		; Wait for Word RAM access
	move.b	#BRCMD_SEARCH,commandID		; Get Backup RAM status
	bra.w	RunBuRAMCmd

; -------------------------------------------------------------------------
; Read Backup RAM
; -------------------------------------------------------------------------

ReadBuRAM:
	jsr	WaitWordRAMAccess		; Wait for Word RAM access
	move.b	#BRCMD_READ,commandID		; Read Backup RAM data
	bra.w	RunBuRAMCmd

; -------------------------------------------------------------------------
; Read save data
; -------------------------------------------------------------------------

ReadSaveData:
	jsr	WaitWordRAMAccess		; Wait for Word RAM access
	move.b	#BRCMD_RDSAVE,commandID		; Read save data
	bra.w	RunBuRAMCmd

; -------------------------------------------------------------------------
; Write Backup RAM
; -------------------------------------------------------------------------

WriteBuRAM:
	jsr	WaitWordRAMAccess		; Wait for Word RAM access
	move.b	#BRCMD_WRITE,commandID		; Write Backup RAM data
	bsr.w	RunBuRAMCmd
	bne.s	.End				; If it failed, branch
	bsr.w	VerifyBuRAM			; Verify Backup RAM

.End:
	rts

; -------------------------------------------------------------------------
; Write save data
; -------------------------------------------------------------------------

WriteSaveData:
	jsr	WaitWordRAMAccess		; Wait for Word RAM access
	move.b	#BRCMD_WRSAVE,commandID		; Write save data
	bsr.w	RunBuRAMCmd
	rts

; -------------------------------------------------------------------------
; Delete Backup RAM
; -------------------------------------------------------------------------

DeleteBuRAM:
	jsr	WaitWordRAMAccess		; Wait for Word RAM access
	move.b	#BRCMD_DELETE,commandID		; Delete Backup RAM
	bra.w	RunBuRAMCmd

; -------------------------------------------------------------------------
; Format Backup RAM
; -------------------------------------------------------------------------

FormatBuRAM:
	jsr	WaitWordRAMAccess		; Wait for Word RAM access
	move.b	#BRCMD_FORMAT,commandID		; Format Backup RAM
	bra.w	RunBuRAMCmd

; -------------------------------------------------------------------------
; Verify Backup RAM
; -------------------------------------------------------------------------

VerifyBuRAM:
	jsr	WaitWordRAMAccess		; Wait for Word RAM access
	move.b	#BRCMD_VERIFY,commandID		; Verify Backup RAM
	bra.w	RunBuRAMCmd

; -------------------------------------------------------------------------
; Load message art
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - Message art ID queue
; -------------------------------------------------------------------------

LoadMessageArt:
	lea	VDPCTRL,a5			; VDP control port
	moveq	#4-1,d2				; Number of IDs to check

.QueueLoop:
	moveq	#0,d1				; Get ID from queue
	move.b	d0,d1
	beq.s	.Next				; If it's blank, branch

	lsl.w	#3,d1				; Get art metadata
	lea	.MessageArt(pc),a0

	move.l	-8(a0,d1.w),(a5)		; VDP command
	movea.l	-4(a0,d1.w),a0			; Art data
	jsr	NemDec(pc)			; Decompress and load art

.Next:
	ror.l	#8,d0				; Shift queue
	dbf	d2,.QueueLoop			; Loop until queue is scanned
	rts

; -------------------------------------------------------------------------

.MessageArt:
	VDPCMD	dc.l,$20,VRAM,WRITE		; Eggman art
	dc.l	Art_Eggman
	VDPCMD	dc.l,$340,VRAM,WRITE		; Message art #1
	dc.l	Art_Message1
	VDPCMD	dc.l,$1C40,VRAM,WRITE		; Message art #2
	dc.l	Art_Message2

; -------------------------------------------------------------------------
; Decompress Nemesis art into VRAM (Note: VDP write command must be
; set beforehand)
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to Nemesis art
; -------------------------------------------------------------------------

NemDec:
	movem.l	d0-a1/a3-a5,-(sp)
	lea	NemPCD_WriteRowToVDP.l,a3	; Write all data to the same location
	lea	VDPDATA,a4			; (the VDP data port)
	bra.s	NemDecMain

; -------------------------------------------------------------------------
; Decompress Nemesis data into RAM
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to Nemesis art
;	a4.l - Pointer to destination buffer
; -------------------------------------------------------------------------

NemDecToRAM:
	movem.l	d0-a1/a3-a5,-(sp)
	lea	NemPCD_WriteRowToRAM,a3		; Advance to the next location after each write

; -------------------------------------------------------------------------

NemDecMain:
	lea	decompBuffer.w,a1		; Prepare decompression buffer
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

	bra.s	NemBCT_Loop			; Loop

; -------------------------------------------------------------------------
; Load message mappings
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.b - Message ID
; -------------------------------------------------------------------------

LoadMessageMap:
	andi.l	#$FFFF,d0			; Get mappings metadata
	mulu.w	#14,d0
	lea	.MessageMaps,a1
	adda.w	d0,a1

	movea.l	(a1)+,a0			; Mappings data
	move.w	(a1)+,d0			; Base tile attributes

	move.l	a1,-(sp)			; Decompress mappings
	lea	decompBuffer.w,a1
	bsr.w	EniDec
	movea.l	(sp)+,a1

	move.w	(a1)+,d3			; Width
	move.w	(a1)+,d2			; Height
	move.l	(a1),d0				; VDP command
	
	lea	decompBuffer.w,a0		; Load mappings into VRAM
	movea.l	#VDPDATA,a1			; VDP data port

.Row:
	move.l	d0,VDPCTRL			; Set VDP command
	move.w	d3,d1				; Get width

.Tile:
	move.w	(a0)+,(a1)			; Copy tile
	dbf	d1,.Tile			; Loop until row is copied
	addi.l	#$800000,d0			; Next row
	dbf	d2,.Row				; Loop until map is copied
	rts

; -------------------------------------------------------------------------

.MessageMaps:
	dc.l	Map_Eggman			; Backup RAM data corrupted
	dc.w	1
	dc.w	$A-1, 6-1
	VDPCMD	dc.l,$C31E,VRAM,WRITE

	dc.l	Map_DataCorrupt
	dc.w	$201A
	dc.w	$1D-1, 6-1
	VDPCMD	dc.l,$E58A,VRAM,WRITE
	
	dc.l	Map_Eggman			; Internal Backup RAM unformatted
	dc.w	1
	dc.w	$A-1, 6-1
	VDPCMD	dc.l,$C31E,VRAM,WRITE

	dc.l	Map_IntUnformatted
	dc.w	$20E2
	dc.w	$1D-1, 8-1
	VDPCMD	dc.l,$E58A,VRAM,WRITE
	
	dc.l	Map_Eggman			; Cartridge Backup RAM unformatted
	dc.w	1
	dc.w	9, 5
	VDPCMD	dc.l,$C29E,VRAM,WRITE

	dc.l	Map_CartUnformatted
	dc.w	$201A
	dc.w	$1D-1, 8-1
	VDPCMD	dc.l,$E50A,VRAM,WRITE
	
	dc.l	Map_Eggman			; Backup RAM full
	dc.w	1
	dc.w	9, 5
	VDPCMD	dc.l,$C31E,VRAM,WRITE

	dc.l	Map_BuRAMFull
	dc.w	$201A
	dc.w	$1D-1, 6-1
	VDPCMD	dc.l,$E58A,VRAM,WRITE

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

Art_Eggman:
	incbin	"buram/init/data/eggman.art.nem"
	even

Map_Eggman:
	incbin	"buram/init/data/eggman.map.eni"
	even

Art_Message1:
	incbin	"buram/init/data/message1.art.nem"
	even

Map_DataCorrupt:
	incbin	"buram/init/data/msgcorrupt.map.eni"
	even

Map_CartUnformatted:
	incbin	"buram/init/data/msgcartridge.map.eni"
	even

Map_BuRAMFull:
	incbin	"buram/init/data/msgfull.map.eni"
	even

Art_Message2:
	incbin	"buram/init/data/message2.art.nem"
	even

Map_IntUnformatted:
	incbin	"buram/init/data/msginternal.map.eni"
	even

; -------------------------------------------------------------------------

End:

; -------------------------------------------------------------------------
