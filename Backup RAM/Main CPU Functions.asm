; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Main CPU Backup RAM functions
; -------------------------------------------------------------------------

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

	include	"Backup RAM/Initial Data.asm"	; Initial data

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
	bsr.w	InitBuRAMParams			; Set up parameters
	bsr.w	JmpTo_ReadSaveData		; Read save data
	rts

; -------------------------------------------------------------------------
; Write save data
; -------------------------------------------------------------------------

JmpTo_WriteSaveData:
	bra.w	WriteSaveData

; -------------------------------------------------------------------------
; Read save data
; -------------------------------------------------------------------------

JmpTo_ReadSaveData:
	bra.w	ReadSaveData

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
