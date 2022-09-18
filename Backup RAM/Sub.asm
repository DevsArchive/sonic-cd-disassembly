; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Sub CPU Backup RAM management functions
; -------------------------------------------------------------------------

	include	"_Include/Common.i"
	include	"_Include/Sub CPU.i"
	include	"_Include/System.i"
	include	"_Include/Backup RAM.i"

; -------------------------------------------------------------------------
; Variables
; -------------------------------------------------------------------------

	rsset	PRGRAM+$16000
VARSSTART	rs.b	0			; Start of variables
		rs.b	$800			; Unused
irq1Flag	rs.b	1			; IRQ1 flag
		rs.b	$17FF			; Unused
VARSLEN		EQU	__rs-VARSSTART		; Size of variables area

decompWindow	EQU	WORDRAM2M+$38000	; Decompression sliding window

; -------------------------------------------------------------------------
; Program start
; -------------------------------------------------------------------------

	org	$10000

	move.l	#IRQ1,_LEVEL1+2.w		; Set IRQ1 handler
	move.b	#0,GAMEMMODE.w			; Set to 2M mode

	moveq	#0,d0				; Clear communication statuses
	move.l	d0,GACOMSTAT0.w
	move.l	d0,GACOMSTAT4.w
	move.l	d0,GACOMSTAT8.w
	move.l	d0,GACOMSTATC.w
	
	bset	#7,GASUBFLAG.w			; Mark as started
	bclr	#1,GAIRQMASK.w			; Disable level 1 interrupt
	bclr	#3,GAIRQMASK.w			; Disable timer interrupt
	move.b	#3,GACDCDEVICE.w		; Set CDC device to "Sub CPU"

	lea	VARSSTART,a0			; Clear variables
	move.w	#VARSLEN/4-1,d7

.ClearVars:
	move.l	#0,(a0)+
	dbf	d7,.ClearVars

	bsr.w	WaitWordRAMAccess		; Wait for Word RAM access

	lea	WORDRAM2M,a0			; Clear Word RAM
	move.w	#WORDRAM2MS/8-1,d7

.ClearWordRAM:
	move.l	#0,(a0)+
	move.l	#0,(a0)+
	dbf	d7,.ClearWordRAM

	bset	#1,GAIRQMASK.w			; Enable level 1 interrupt
	bclr	#7,GASUBFLAG.w			; Mark as initialized

; -------------------------------------------------------------------------

MainLoop:
	bsr.w	WaitWordRAMAccess		; Wait for Word RAM access
	btst	#7,GAMAINFLAG.w			; Is the Main CPU finished?
	bne.s	.Done				; If so, branch
	bsr.w	RunBuRAMCmd			; Run Backup RAM command
	bsr.w	GiveWordRAMAccess		; Give Main CPU Word RAM access
	bra.w	MainLoop			; Loop

.Done:
	bset	#7,GASUBFLAG.w			; Tell Main CPU that we are done

.WaitMainCPU:
	btst	#7,GAMAINFLAG.w			; Is the Main CPU done?
	bne.s	.WaitMainCPU			; If not, wait

	moveq	#0,d0				; Clear communication statuses
	move.l	d0,GACOMSTAT0.w
	move.l	d0,GACOMSTAT4.w
	move.l	d0,GACOMSTAT8.w
	move.l	d0,GACOMSTATC.w
	move.b	d0,GASUBFLAG.w
	nop
	rts

; -------------------------------------------------------------------------
; Unused function to get a command ID from the Main CPU
; -------------------------------------------------------------------------
; RETURNS:
;	d0.w - Command ID
; -------------------------------------------------------------------------

GetMainCPUCmd:
	move.w	GACOMCMD2.w,d0			; Get command ID from Main CPU
	beq.w	MainLoop			; If it's zero, exit out
	move.w	GACOMCMD2.w,GACOMSTAT2.w	; Acknowledge command

.WaitMainCPU:
	tst.w	GACOMCMD2.w			; Is the Main CPU ready to send more commands?
	bne.s	.WaitMainCPU			; If not, branch
	
	move.w	#0,GACOMSTAT2.w			; Mark as ready for another command
	rts

; -------------------------------------------------------------------------
; Unknown IRQ1 handler
; -------------------------------------------------------------------------

IRQ1:
	move.b	#0,irq1Flag			; Clear IRQ1 flag
	rte

; -------------------------------------------------------------------------
; Unknown decompression routine
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to compressed data
;	a1.l - Pointer to destination buffer
; -------------------------------------------------------------------------

UnkDecomp:
	movem.l	d0-a2,-(sp)			; Save registers

	lea	decompWindow,a2			; Decompression sliding window
	move.w	(a0)+,d7			; Get size of uncompressed data
	subq.w	#1,d7				; Subtract 1 for dbf
	move.w	#(-$12)&$FFF,d2			; Set window position
	
	move.b	(a0)+,d1			; Get first description field
	move.w	#$FFF,d6			; Set window position mask
	moveq	#8,d0				; Number of bits in description field

.MainLoop:
	dbf	d0,.NextDescBit			; Loop until all flags have been scanned
	moveq	#8-1,d0				; Prepare next description field
	move.b	(a0)+,d1

.NextDescBit:
	lsr.b	#1,d1				; Get next description field bit
	bcc.s	.CopyFromWindow			; 0 | If we are copying from the window, branch

.CopyNextByte:
	move.b	(a0),(a1)+			; 1 | Copy next byte from archive
	move.b	(a0)+,(a2,d2.w)			; Store in window
	addq.w	#1,d2				; Advance window position
	and.w	d6,d2
	dbf	d7,.MainLoop			; Loop until all of the data is decompressed
	bra.s	.End				; Exit out

.CopyFromWindow:
	moveq	#0,d3
	move.b	(a0)+,d3			; Get low byte of window position
	move.b	(a0)+,d4			; Get high bits of window position and length
	
	move.w	d4,d5				; Combine window position bits
	andi.w	#$F0,d5
	lsl.w	#4,d5
	or.w	d5,d3

	andi.w	#$F,d4				; Isolate length
	addq.w	#3-1,d4				; Copy at least 3 bytes from window

.CopyWindowLoop:
	move.b	(a2,d3.w),d5			; Get byte from window
	move.b	d5,(a1)+			; Store in decompressed data buffer
	subq.w	#1,d7				; Decrement bytes left to decompress
	move.b	d5,(a2,d2.w)			; Store in window
	
	addq.w	#1,d3				; Advance copy position
	and.w	d6,d3
	addq.w	#1,d2				; Advance window position
	and.w	d6,d2

	dbf	d4,.CopyWindowLoop		; Loop until all bytes are copied
	tst.w	d7				; Are there any bytes left to decompress?
	bpl.s	.MainLoop			; If so, branch

.End:
	movem.l	(sp)+,d0-a2			; Restore registers
	rts

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
; Wait for the IRQ1 handler to be run
; -------------------------------------------------------------------------

WaitIRQ1:
	move.b	#1,irq1Flag			; Set IRQ1 flag
	move	#$2000,sr			; Enable interrupts

.Wait:
	tst.b	irq1Flag			; Has the IRQ1 handler been run?
	bne.s	.Wait				; If not, wait
	rts

; -------------------------------------------------------------------------
; Sync with Main CPU
; -------------------------------------------------------------------------

SyncWithMainCPU:
	tst.w	GACOMCMD2.w			; Are we synced with the Main CPU?
	bne.s	SyncWithMainCPU			; If not, wait
	rts

; -------------------------------------------------------------------------
; Give Main CPU Word RAM access
; -------------------------------------------------------------------------

GiveWordRAMAccess:
	bset	#0,GAMEMMODE.w			; Give Main CPU Word RAM access
	btst	#0,GAMEMMODE.w			; Has it been given?
	beq.s	GiveWordRAMAccess		; If not, wait
	rts

; -------------------------------------------------------------------------
; Wait for Word RAM access
; -------------------------------------------------------------------------

WaitWordRAMAccess:
	btst	#1,GAMEMMODE.w			; Do we have Word RAM access?
	beq.s	WaitWordRAMAccess		; If not, wait
	rts

; -------------------------------------------------------------------------
; Unknown map data(?) loading routine
; -------------------------------------------------------------------------
; PARAMETERS:
;	a1.l - Pointer to source data
;	d1.w - Width (minus 1)
;	d2.w - Height (minus 1)
; -------------------------------------------------------------------------

UnkMapDataLoad:
	move.l	#$100,d4			; Stride

.SetupRow:
	movea.l	d0,a2				; Set row pointer
	move.w	d1,d3				; Set row width

.RowLoop:
	move.w	(a1)+,d5			; Get data
	lsl.w	#2,d5
	move.w	d5,(a2)+			; Store it
	dbf	d3,.RowLoop			; Loop until row is written
	add.l	d4,d0				; Next row
	dbf	d2,.SetupRow			; Loop until all data is written
	rts

; -------------------------------------------------------------------------
; Run Backup RAM command
; -------------------------------------------------------------------------

RunBuRAMCmd:
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
	dc.w	Cmd_InitBuRAM-.Commands		; Initialize Backup RAM interaction
	dc.w	Cmd_BuRAMStatus-.Commands	; Get Backup RAM status
	dc.w	Cmd_SearchBuRAM-.Commands	; Search Backup RAM
	dc.w	Cmd_ReadBuRAM-.Commands		; Read from Backup RAM
	dc.w	Cmd_WriteBuRAM-.Commands	; Write to Backup RAM
	dc.w	Cmd_DeleteBuRAM-.Commands	; Delete Backup RAM
	dc.w	Cmd_FormatBuRAM-.Commands	; Format Backup RAM
	dc.w	Cmd_GetBuRAMDir-.Commands	; Get Backup RAM directory
	dc.w	Cmd_VerifyBuRAM-.Commands	; Verify Backup RAM
	dc.w	Cmd_ReadSaveData-.Commands	; Read save data
	dc.w	Cmd_WriteSaveData-.Commands	; Write save data
.CommandsEnd:

; -------------------------------------------------------------------------
; Initialize Backup RAM interaction
; -------------------------------------------------------------------------

Cmd_InitBuRAM:
	lea	BuRAMScratch,a0
	lea	BuRAMStrings,a1
	moveq	#BRMINIT,d0
	jmp	_BURAM.w

; -------------------------------------------------------------------------
; Get Backup RAM status	
; -------------------------------------------------------------------------

Cmd_BuRAMStatus:
	moveq	#BRMSTAT,d0
	movea.l	#BuRAMStrings,a1
	jmp	_BURAM.w

; -------------------------------------------------------------------------
; Search Backup RAM
; -------------------------------------------------------------------------

Cmd_SearchBuRAM:
	movea.l	#buramParams,a0
	move.b	#0,buramMisc(a0)
	move.l	#0,buramMisc+1(a0)
	moveq	#BRMSERCH,d0
	jmp	_BURAM.w

; -------------------------------------------------------------------------
; Read from Backup RAM
; -------------------------------------------------------------------------

Cmd_ReadBuRAM:
	movea.l	#buramParams,a0
	move.b	#0,buramMisc(a0)
	move.l	#0,buramMisc+1(a0)
	movea.l	#buramData,a1
	moveq	#BRMREAD,d0
	jsr	_BURAM.w
	rts

; -------------------------------------------------------------------------
; Read save data
; -------------------------------------------------------------------------

Cmd_ReadSaveData:
	tst.b	buramDisabled			; Is Backup RAM disabled?
	bne.s	.BuRAMDisabled			; If so, branch

	bsr.s	Cmd_ReadBuRAM			; Read from Backup RAM
	bsr.w	WriteTempSaveData		; Write read data to temporary save data buffer
	move.w	#0,buramD0
	move.w	#0,buramD1
	rts

.BuRAMDisabled:
	bsr.w	ReadTempSaveData		; Read from temporary save data buffer
	move.w	#0,buramD0
	move.w	#0,buramD1
	rts

; -------------------------------------------------------------------------
; Write to Backup RAM
; -------------------------------------------------------------------------

Cmd_WriteBuRAM:
	movea.l	#buramParams,a0
	move.b	writeFlag,buramFlag(a0)
	move.w	blockSize,buramBlkSz(a0)
	movea.l	#buramData,a1
	moveq	#BRMWRITE,d0
	jsr	_BURAM.w
	rts

; -------------------------------------------------------------------------
; Write save data
; -------------------------------------------------------------------------

Cmd_WriteSaveData:
	tst.b	buramDisabled			; Is Backup RAM disabled?
	bne.s	.BuRAMDisabled			; If so, branch

	bsr.s	Cmd_WriteBuRAM			; Write to Backup RAM
	bsr.w	WriteTempSaveData		; Write to temporary save data buffer
	move.w	#0,buramD0
	move.w	#0,buramD1
	rts

.BuRAMDisabled:
	bsr.w	WriteTempSaveData		; Write to temporary save data buffer
	move.w	#0,buramD0
	move.w	#0,buramD1
	rts

; -------------------------------------------------------------------------
; Delete Backup RAM
; -------------------------------------------------------------------------

Cmd_DeleteBuRAM:
	movea.l	#buramParams,a0
	move.b	#0,buramMisc(a0)
	move.l	#0,buramMisc+1(a0)
	moveq	#BRMDEL,d0
	jmp	_BURAM.w

; -------------------------------------------------------------------------
; Format Backup RAM
; -------------------------------------------------------------------------

Cmd_FormatBuRAM:
	moveq	#BRMFORMAT,d0
	jmp	_BURAM.w

; -------------------------------------------------------------------------
; Get Backup RAM directory
; -------------------------------------------------------------------------

Cmd_GetBuRAMDir:
	movea.l	#buramParams,a0
	move.b	#0,buramMisc(a0)
	move.l	#0,buramMisc+1(a0)
	movea.l	#buramData+4,a1
	move.l	buramData,d1
	moveq	#BRMDIR,d0
	jmp	_BURAM.w

; -------------------------------------------------------------------------
; Verify Backup RAM
; -------------------------------------------------------------------------

Cmd_VerifyBuRAM:
	movea.l	#buramParams,a0
	move.b	writeFlag,buramFlag(a0)
	move.w	blockSize,buramBlkSz(a0)
	movea.l	#buramData,a1
	moveq	#BRMVERIFY,d0
	jmp	_BURAM.w

; -------------------------------------------------------------------------
; Write to temporary save data buffer
; -------------------------------------------------------------------------

WriteTempSaveData:
	movem.l	d0/a0-a1,-(sp)			; Save registers

	movea.l	#buramData,a0			; Write to temporary save data buffer
	movea.l	#SaveDataTemp,a1
	move.w	#BURAMDATASZ/4-1,d0

.Write:
	move.l	(a0)+,(a1)+
	dbf	d0,.Write

	movem.l	(sp)+,d0/a0-a1			; Restore registers
	rts

; -------------------------------------------------------------------------
; Read from temporary save data buffer
; -------------------------------------------------------------------------

ReadTempSaveData:
	movem.l	d0/a0-a1,-(sp)			; Save registers

	movea.l	#SaveDataTemp,a0		; Read from temporary save data buffer
	movea.l	#buramData,a1
	move.w	#BURAMDATASZ/4-1,d0

.read:
	move.l	(a0)+,(a1)+
	dbf	d0,.read

	movem.l	(sp)+,d0/a0-a1			; Restore registers
	rts

; -------------------------------------------------------------------------
; Backup RAM data
; -------------------------------------------------------------------------

BuRAMScratch:
	dcb.b	$640, 0				; Scratch RAM

BuRAMStrings:	
	dcb.b	$C, 0				; Display strings

; -------------------------------------------------------------------------
