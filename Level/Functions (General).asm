; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; General level functions
; -------------------------------------------------------------------------

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
; Initialize joypads
; -------------------------------------------------------------------------

InitControllers:
	bsr.w	StopZ80				; Stop the Z80

	moveq	#$40,d0				; Initialize controller ports
	move.b	d0,IOCTRL1
	move.b	d0,IOCTRL2
	move.b	d0,IOCTRL3

	bra.w	StartZ80			; Start the Z80

; -------------------------------------------------------------------------
; Read joypad data
; -------------------------------------------------------------------------

ReadControllers:
	lea	p1CtrlData.w,a0			; Read player 1 controller
	lea	IODATA1,a1
	bsr.s	ReadController
	
	if DEMO<>0
		movea.l	demoDataPtr.w,a2	; Get demo data
		tst.w	demoMode		; Are we in a demo?
		beq.s	.NotDemo		; If not, branch
		
		move.w	demoDataIndex.w,d0	; Get data index
		cmpi.w	#$800,d0		; Has the demo run out?
		bcc.s	.NotDemo		; If so, branch
		move.w	d0,d1
		add.w	d0,d0
		
		move.w	-2(a0),d2		; Retain start button
		andi.w	#$80,d2
		move.w	(a2,d0.w),-2(a0)	; Read demo data
		or.w	d2,-2(a0)
		
		addq.w	#1,d1			; Advance demo
		move.w	d1,demoDataIndex.w
		
.NotDemo:
	endif
	
	addq.w	#p2CtrlData-p1CtrlData,a1	; Read player 2 controller

; -------------------------------------------------------------------------
; Read a joypad's data
; -------------------------------------------------------------------------

ReadController:
	move.b	#0,(a1)				; Pull TH low
	nop
	nop
	move.b	(a1),d0				; Get start and A button
	lsl.b	#2,d0
	andi.b	#$C0,d0
	move.b	#$40,(a1)			; Pull TH high
	nop
	nop
	move.b	(a1),d1				; Get B, C, and directional buttons
	andi.b	#$3F,d1
	or.b	d1,d0				; Combine buttons
	not.b	d0				; Swap bits
	move.b	(a0),d1				; Prepare previously held buttons
	eor.b	d0,d1
	move.b	d0,(a0)+			; Store new held buttons
	and.b	d0,d1				; Update pressed buttons
	move.b	d1,(a0)+
	rts

; -------------------------------------------------------------------------
; Initialize the VDP
; -------------------------------------------------------------------------

InitVDP:
	lea	VDPCTRL,a0			; Get VDP ports
	lea	VDPDATA,a1

	lea	VDPInitRegs,a2			; Prepare VDP registers
	moveq	#$13-1,d7

.InitRegs:
	move.w	(a2)+,(a0)			; Set VDP register
	dbf	d7,.InitRegs			; Loop until finished

	move.w	VDPInitReg1,d0			; Set VDP register 1
	move.w	d0,vdpReg01.w
	move.w	#$8ADF,vdpReg0A.w		; Set H-INT counter

	moveq	#0,d0				; Clear CRAM
	move.l	#$C0000000,VDPCTRL
	move.w	#$3F,d7

.ClearCRAM:
	move.w	d0,(a1)
	dbf	d7,.ClearCRAM			; Loop until finished

	clr.l	vscrollScreen.w			; Clear scroll values
	clr.l	hscrollScreen.w

	move.l	d1,-(sp)			; Clear VRAM via DMA fill
	lea	VDPCTRL,a5
	move.w	#$8F01,(a5)
	move.l	#$94FF93FF,(a5)
	move.w	#$9780,(a5)
	move.l	#$40000080,(a5)
	move.w	#0,VDPDATA

.WaitVRAMClear:
	move.w	(a5),d1
	btst	#1,d1
	bne.s	.WaitVRAMClear
	move.w	#$8F02,(a5)
	move.l	(sp)+,d1

	rts

; -------------------------------------------------------------------------

VDPInitRegs:
	dc.w	$8004				; H-INT disabled
VDPInitReg1:
	dc.w	$8134				; DMA and V-INT enabled, display disabled
	dc.w	$8230				; Plane A at $C000
	dc.w	$8328				; Window plane at $A000
	dc.w	$8407				; Plane B at $E000
	dc.w	$857C				; Sprite table at $F800
	dc.w	$8600				; Unused
	dc.w	$8700				; Background color at line 0 color 0
	dc.w	$8800				; Unused
	dc.w	$8900				; Unused
	dc.w	$8A00				; H-INT counter 0
	dc.w	$8B00				; HScroll by screen, VScroll by screen
	dc.w	$8C81				; H40 mode
	dc.w	$8D3F				; HScroll at $FC00
	dc.w	$8E00				; Unused
	dc.w	$8F02				; Auto-increment by 2
	dc.w	$9001				; Plane size 64x32
	dc.w	$9100				; Window X at 0
	dc.w	$9200				; Window Y at 0

; -------------------------------------------------------------------------
; Clear the screen
; -------------------------------------------------------------------------

ClearScreen:
	lea	VDPCTRL,a5			; Clear plane A
	move.w	#$8F01,(a5)
	move.l	#$940F93FF,(a5)
	move.w	#$9780,(a5)
	move.l	#$40000083,(a5)
	move.w	#0,VDPDATA

.WaitPlane1Clear:
	move.w	(a5),d1
	btst	#1,d1
	bne.s	.WaitPlane1Clear
	move.w	#$8F02,(a5)

	lea	VDPCTRL,a5			; Clear plane B
	move.w	#$8F01,(a5)
	move.l	#$940F93FF,(a5)
	move.w	#$9780,(a5)
	move.l	#$60000083,(a5)
	move.w	#0,VDPDATA

.WaitPlane2Clear:
	move.w	(a5),d1
	btst	#1,d1
	bne.s	.WaitPlane2Clear
	move.w	#$8F02,(a5)

	clr.l	vscrollScreen.w			; Reset scroll values
	clr.l	hscrollScreen.w

	lea	sprites.w,a1			; Clear sprite buffer
	moveq	#0,d0
	move.w	#$280/4,d1			; Should be $280/4-1

.ClearSprites:
	move.l	d0,(a1)+
	dbf	d1,.ClearSprites

	lea	hscroll.w,a1			; Clear horizontal scroll buffer
	moveq	#0,d0
	move.w	#$400/4,d1			; Should be $400/4-1

.ClearHScroll:
	move.l	d0,(a1)+
	dbf	d1,.ClearHScroll

	rts

; -------------------------------------------------------------------------
; Stop the Z80
; -------------------------------------------------------------------------

StopZ80:
	move	sr,savedSR.w			; Save SR
	move	#$2700,sr			; Disable interrupts
	move.w	#$100,Z80BUS			; Stop the Z80

.Wait:
	btst	#0,Z80BUS
	bne.s	.Wait
	rts

; -------------------------------------------------------------------------
; Start the Z80
; -------------------------------------------------------------------------

StartZ80:
	move.w	#0,Z80BUS			; Start the Z80
	move	savedSR.w,sr			; Restore SR
	rts

; -------------------------------------------------------------------------
; Dead code to initialize the Z80 with dummy code
; -------------------------------------------------------------------------

InitZ80Dummy:
	move.w	#$100,Z80RESET			; Stop Z80 reset
	jsr	StopZ80(pc)			; Stop the Z80

	lea	Z80RAM,a1			; Prepare Z80 RAM
	move.b	#$F3,(a1)+			; di
	move.b	#$F3,(a1)+			; di
	move.b	#$C3,(a1)+			; jp $0000
	move.b	#0,(a1)+
	move.b	#0,(a1)+

	move.w	#0,Z80RESET			; Reset the Z80
	ror.b	#8,d0				; Wait
	move.w	#$100,Z80RESET			; Stop Z80 reset
	jmp	StartZ80(pc)			; Start the Z80
	rts

; -------------------------------------------------------------------------
; Play an FM sound
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.b - Sound ID
; -------------------------------------------------------------------------

PlayFMSound:
	if (REGION=USA)|((REGION<>USA)&(DEMO=0))
		tst.b	fmSndQueue1.w		; Is queue 1 full?
		bne.s	.CheckQueue2		; If so, branch
		move.b	d0,fmSndQueue1.w	; Set ID in queue 1
		rts

.CheckQueue2:
	endif
	tst.b	fmSndQueue2.w			; Is queue 2 full?
	bne.s	.CheckQueue3			; If so, branch
	move.b	d0,fmSndQueue2.w		; Set ID in queue 2
	rts

.CheckQueue3:
	if (REGION=USA)|((REGION<>USA)&(DEMO=0))
		tst.b	fmSndQueue3.w		; Is queue 3 full?
		bne.s	.End			; If so, branch
	endif
	move.b	d0,fmSndQueue3.w		; Set ID in queue 3

.End:
	rts

; -------------------------------------------------------------------------
; Update FM driver queues
; -------------------------------------------------------------------------

UpdateFMQueues:
	jsr	StopZ80				; Stop the Z80

	if (REGION=USA)|((REGION<>USA)&(DEMO=0))
		tst.b	fmSndQueue1.w		; Update queue 1
		beq.s	.CheckQueue2
		move.b	fmSndQueue1.w,FMDrvQueue1
		move.b	#0,fmSndQueue1.w

.CheckQueue2:
		tst.b	fmSndQueue2.w		; Update queue 2
		beq.s	.CheckQueue3
		move.b	fmSndQueue2.w,FMDrvQueue2
		move.b	#0,fmSndQueue2.w

.CheckQueue3:
		tst.b	fmSndQueue3.w		; Update queue 3
		beq.s	.End
		move.b	fmSndQueue3.w,FMDrvQueue3
		move.b	#0,fmSndQueue3.w
		
.End:
	else
		tst.b	fmSndQueue2.w		; Update queues
		beq.w	StartZ80
		move.b	fmSndQueue2.w,FMDrvQueue1
		move.b	fmSndQueue3.w,fmSndQueue2.w
		move.b	#0,fmSndQueue3.w
	endif
	bra.w	StartZ80			; Start the Z80

; -------------------------------------------------------------------------
; Draw a tilemap
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - Base VDP command
;	d1.w - Tilemap width (minus 1)
;	d2.w - Tilemap height (minus 1)
;	a1.l - Tilemap data pointer
; -------------------------------------------------------------------------

DrawTilemap:
	lea	VDPDATA,a6			; Prepare VDP data
	move.l	#$800000,d4			; VDP command line delta

.RowLoop:
	move.l	d0,4(a6)			; Set VDP command
	move.w	d1,d3				; Prepare row width

.TileLoop:
	move.w	(a1)+,(a6)			; Copy tile data
	dbf	d3,.TileLoop			; Loop until row is drawn

	add.l	d4,d0				; Next row
	dbf	d2,.RowLoop			; Loop until tilemap is drawn
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
	bne.s	NemBCT_NewPalIndex		; If not, branch
	rts

NemBCT_NewPalIndex:
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
; Load a PLC list
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - PLC list ID
; -------------------------------------------------------------------------

LoadPLC:
	movem.l	a1-a2,-(sp)			; Save registers
	
	lea	PLCLists,a1			; Prepare PLC list index
	add.w	d0,d0				; Get pointer to PLC list
	move.w	(a1,d0.w),d0
	lea	(a1,d0.w),a1
	lea	plcBuffer.w,a2			; Prepare PLC buffer

.Loop:
	tst.l	(a2)				; Is this PLC entry free?
	beq.s	.FoundFree			; If so, branch
	addq.w	#6,a2				; Check next entry
	bra.s	.Loop

.FoundFree:
	move.w	(a1)+,d0			; Get number of PLC entries
	bmi.s	.End				; If it's 0 (or less), branch

.Load:
	move.l	(a1)+,(a2)+			; Copy art pointer
	move.w	(a1)+,(a2)+			; Copy VRAM location
	dbf	d0,.Load			; Loop until all entries are queued

.End:
	movem.l	(sp)+,a1-a2			; Restore registers
	rts

; -------------------------------------------------------------------------
; Clear PLCs and load a PLC list
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - PLC list ID
; -------------------------------------------------------------------------

InitPLC:
	movem.l	a1-a2,-(sp)			; Save registers
	
	lea	PLCLists,a1			; Prepare PLC list index
	add.w	d0,d0				; Get pointer to PLC list
	move.w	(a1,d0.w),d0
	lea	(a1,d0.w),a1

	bsr.s	ClearPLCs			; Clear PLCs

	lea	plcBuffer.w,a2			; Prepare PLC buffer

	move.w	(a1)+,d0			; Get number of PLC entries
	bmi.s	.End				; If it's 0 (or less), branch

.Load:
	move.l	(a1)+,(a2)+			; Copy art pointer
	move.w	(a1)+,(a2)+			; Copy VRAM location
	dbf	d0,.Load			; Loop until all entries are queued

.End:
	movem.l	(sp)+,a1-a2			; Restore registers
	rts

; -------------------------------------------------------------------------
; Clear PLCs
; -------------------------------------------------------------------------

ClearPLCs:
	lea	plcBuffer.w,a2			; Clear PLC buffer
	moveq	#$80/4-1,d0

.Clear:
	clr.l	(a2)+
	dbf	d0,.Clear			; Loop until finished
	rts

; -------------------------------------------------------------------------
; Process PLC queue in RAM
; -------------------------------------------------------------------------

ProcessPLCs:
	tst.l	plcBuffer.w			; Is the PLC queue empty?
	beq.s	.End				; If so, branch
	tst.w	plcTileCount.w			; Is there a decompression in process already?
	bne.s	.End				; If so, branch

	movea.l	plcBuffer.w,a0			; Get art pointer
	lea	NemPCD_WriteRowToVDP,a3		; Write to VRAM
	lea	nemBuffer.w,a1			; Prepare Nemesis buffer
	move.w	(a0)+,d2
	bpl.s	.NotXOR				; Branch if not in XOR mode
	adda.w	#NemPCD_WriteRowToVDP_XOR-NemPCD_WriteRowToVDP,a3

.NotXOR:
	andi.w	#$7FFF,d2			; Store number of tiles to decompress
	move.w	d2,plcTileCount.w

	bsr.w	NemDec_BuildCodeTable		; Build code table for this art

	move.b	(a0)+,d5			; Get first word of compressed data
	asl.w	#8,d5
	move.b	(a0)+,d5
	moveq	#$10,d6				; Set initial shift value

	moveq	#0,d0				; Prepare decompression registers
	move.l	a0,plcBuffer.w
	move.l	a3,plcNemWrite.w
	move.l	d0,plcRepeat.w
	move.l	d0,plcPixel.w
	move.l	d0,plcRow.w
	move.l	d5,plcRead.w
	move.l	d6,plcShift.w

.End:
	rts

; -------------------------------------------------------------------------
; Process PLC decompression (fast)
; -------------------------------------------------------------------------

DecompPLCFast:
	tst.w	plcTileCount.w			; Is there anything to decompress?
	beq.w	DecompPLC_Done			; If not, branch

; -------------------------------------------------------------------------

DecompPLCFast_Large:
	move.w	#18,plcProcTileCnt.w		; Decompress 18 tiles in this batch
	moveq	#0,d0				; Get VRAM address
	move.w	plcBuffer+4.w,d0
	addi.w	#18*$20,plcBuffer+4.w		; Advance VRAM address
	bra.s	DecompPLC_Main

; -------------------------------------------------------------------------
; Process PLC decompression (slow)
; -------------------------------------------------------------------------

DecompPLCSlow:
	tst.w	plcTileCount.w			; Is there anything to decompress?
	beq.s	DecompPLC_Done			; If not, branch
	tst.b	scrollLock.w			; Is scrolling locked?
	bne.s	DecompPLCFast_Large		; If so, go with the large batch instead

	move.w	#3,plcProcTileCnt.w		; Decompress 3 tiles in this batch
	moveq	#0,d0				; Get VRAM address
	move.w	plcBuffer+4.w,d0
	addi.w	#3*$20,plcBuffer+4.w		; Advance VRAM address

; -------------------------------------------------------------------------

DecompPLC_Main:
	lea	VDPCTRL,a4			; Set VDP write command
	lsl.l	#2,d0
	lsr.w	#2,d0
	ori.w	#$4000,d0
	swap	d0
	move.l	d0,(a4)
	subq.w	#4,a4				; Prepare data port

	movea.l	plcBuffer.w,a0			; Get decompression registers
	movea.l	plcNemWrite.w,a3
	move.l	plcRepeat.w,d0
	move.l	plcPixel.w,d1
	move.l	plcRow.w,d2
	move.l	plcRead.w,d5
	move.l	plcShift.w,d6
	lea	nemBuffer.w,a1

.Decomp:
	movea.w	#8,a5				; Store decompressed tile in VRAM
	bsr.w	NemPCD_NewRow
	subq.w	#1,plcTileCount.w		; Decrement total tile count
	beq.s	DecompPLC_Pop			; If this art is finished being decompressed, branch
	subq.w	#1,plcProcTileCnt.w		; Decrement number of tiles left to decompress in this batch
	bne.s	.Decomp				; If we are not done, branch

	move.l	a0,plcBuffer.w			; Update decompression registers
	move.l	a3,plcNemWrite.w
	move.l	d0,plcRepeat.w
	move.l	d1,plcPixel.w
	move.l	d2,plcRow.w
	move.l	d5,plcRead.w
	move.l	d6,plcShift.w

DecompPLC_Done:
	rts

; -------------------------------------------------------------------------

DecompPLC_Pop:
	; This code is bugged. Due to the fact that 15 PLC queue entries = $5A bytes,
	; which is not divisible by 4, this code only copies over $58 bytes, which means
	; the last VRAM address in the queue is left out. It also doesn't properly
	; clear out the popped entry, so if the queue is full, then it'll constantly
	; queue the last entry over and over again.
	lea	plcBuffer.w,a0			; Pop a PLC queue entry out
	moveq	#($60-6)/4-1,d0			; Copy $58 bytes (instead of the proper $5A)

.Pop:
	move.l	6(a0),(a0)+
	dbf	d0,.Pop
	rts

; -------------------------------------------------------------------------
; Load and decompress a PLC list immediately
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - PLC list ID
; -------------------------------------------------------------------------

LoadPLCImm:
	lea	PLCLists,a1			; Prepare PLC list index
	add.w	d0,d0				; Get pointer to PLC list
	move.w	(a1,d0.w),d0
	lea	(a1,d0.w),a1

	move.w	(a1)+,d1			; Get number of entries

.Load:
	movea.l	(a1)+,a0			; Get art pointer

	moveq	#0,d0				; Get VRAM address
	move.w	(a1)+,d0
	lsl.l	#2,d0				; Convert VRAM address to VDP write command and set it
	lsr.w	#2,d0
	ori.w	#$4000,d0
	swap	d0
	move.l	d0,VDPCTRL

	bsr.w	NemDec				; Decompress the art

	dbf	d1,.Load
	rts

; -------------------------------------------------------------------------
; Decompress Enigma tilemap data into RAM
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Enigma data pointer
;	a1.l - Destination buffer pointer
;	d0.w - Base tile
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
; Get player object
; -------------------------------------------------------------------------
; RETURNS:
;	a6.l - Player object RAM
; -------------------------------------------------------------------------

GetPlayerObject:
	lea	objPlayerSlot.w,a6		; Player 1
	tst.b	usePlayer2			; Are we using player 2?
	beq.s	.Done				; If not, branch
	lea	objPlayerSlot2.w,a6		; Player 2

.Done:
	rts

; -------------------------------------------------------------------------
