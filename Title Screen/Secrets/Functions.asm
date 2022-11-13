; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Title screen secret functions
; -------------------------------------------------------------------------

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
; Decrease a value within a range (word)
; -------------------------------------------------------------------------
; PARAMETERS:
;	d6.w - Minimum value
;	d7.w - Maximum value
;	a1.l - Pointer to value
; -------------------------------------------------------------------------

DecValueW:
	move.w	(a1),d0				; Get value
	subq.w	#1,d0				; Decrease it

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
;	d6.w - Minimum value
;	d7.w - Maximum value
;	a1.l - Pointer to value
; -------------------------------------------------------------------------

IncValueW:
	move.w	(a1),d0				; Get value
	addq.w	#1,d0				; Increase it

	cmp.w	d7,d0				; Has it passed the maximum value?
	bls.s	.SetValue			; If not, branch
	move.w	d6,d0				; Wrap to the minimum value

.SetValue:
	move.w	d0,(a1)				; Update value
	rts

; -------------------------------------------------------------------------
; Decrease a value within a range (byte)
; -------------------------------------------------------------------------
; PARAMETERS:
;	d6.b - Minimum value
;	d7.b - Maximum value
;	a1.l - Pointer to value
; -------------------------------------------------------------------------

DecValueB:
	move.b	(a1),d0				; Get value
	subq.b	#1,d0				; Decrease it

	cmp.b	d6,d0				; Has it passed the minimum value?
	bge.s	.SetValue			; If not, branch
	move.b	d7,d0				; Wrap to the maximum value

.SetValue:
	move.b	d0,(a1)				; Update value
	rts

; -------------------------------------------------------------------------
; Increase a value within a range (byte)
; -------------------------------------------------------------------------
; PARAMETERS:
;	d6.b - Minimum value
;	d7.b - Maximum value
;	a1.l - Pointer to value
; -------------------------------------------------------------------------

IncValueB:
	move.b	(a1),d0				; Get value
	addq.b	#1,d0				; Increase it

	cmp.b	d7,d0				; Has it passed the maximum value?
	bls.s	.SetValue			; If not, branch
	move.b	d6,d0				; Wrap to the minimum value

.SetValue:
	move.b	d0,(a1)				; Update value
	rts

; -------------------------------------------------------------------------
; Initialize the Mega Drive hardware
; -------------------------------------------------------------------------

InitMD:
	move.w	#$8000,d0			; Set up VDP registers
	moveq	#VDPRegsEnd-VDPRegs-1,d7

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

	VDPCMD	move.l,0,VRAM,WRITE,VDPCTRL	; Clear VRAM
	lea	VDPDATA,a0
	moveq	#0,d0
	move.w	#$10000/$10-1,d7

.ClearVRAM:
	move.l	d0,(a0)
	move.l	d0,(a0)
	move.l	d0,(a0)
	move.l	d0,(a0)
	dbf	d7,.ClearVRAM

	VDPCMD	move.l,0,VSRAM,WRITE,VDPCTRL	; Clear VSRAM
	move.l	#0,VDPDATA

	bsr.w	StartZ80			; Start the Z80
	move.w	#$8134,ipxVDPReg1		; Reset IPX VDP register 1 cache
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
; Stop the Z80
; -------------------------------------------------------------------------

StopZ80:
	move	sr,savedSR.w			; Save status register
	move	#$2700,sr			; Disable interrupts
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
	move.b	d0,d1				; Make copy

	move.b	(a5),d2				; Mask out tapped buttons
	eor.b	d2,d0
	move.b	d1,(a5)+			; Store pressed buttons
	and.b	d1,d0				; store tapped buttons
	move.b	d0,(a5)+
	rts

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

	if PROTOTYPE=0
	
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

	else
	
; -------------------------------------------------------------------------
; Send a command to the Sub CPU
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Command ID
; -------------------------------------------------------------------------

SubCPUCmd:
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
; Unused function to send a Backup RAM command to the Sub CPU
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Command ID
; -------------------------------------------------------------------------

SubBuRAMCmd:
	move.w	d0,GACOMCMD2			; Send command

.WaitSubCPU:
	tst.w	GACOMSTAT2			; Has the Sub CPU acknowledged it?
	beq.s	.WaitSubCPU
	
	move.w	#0,GACOMCMD2			; Tell Sub CPU we are ready to send more commands

.WaitSubCPU2:
	tst.w	GACOMSTAT2			; Is the Sub CPU ready for more commands?
	bne.s	.WaitSubCPU2			; If not, wait
	rts
	
; -------------------------------------------------------------------------

	endif

; -------------------------------------------------------------------------
