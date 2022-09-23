; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Main CPU opening FMV handler
; -------------------------------------------------------------------------

	include	"_Include/Common.i"
	include	"_Include/Main CPU.i"
	include	"_Include/Main CPU Variables.i"
	include	"_Include/MMD.i"
	
; -------------------------------------------------------------------------
; Variables
; -------------------------------------------------------------------------

	rsset	WORKRAM+$FF008000
VARSSTART	rs.b	0			; Start of variables
frameDMA	rs.b	12			; Frame DMA info
		rs.b	$3FF4
VARSLEN		EQU	__rs-VARSSTART		; Size of variables area

palette		rs.w	$40			; Palette buffer
frameCount	rs.w	1			; Frame counter
curDataAddr	rs.l	1			; Current data read address
readRoutine	rs.w	1			; Data read routine
unkC088		rs.w	1			; Unknown
		rs.b	$A
palFadeDelay	rs.w	1			; Palette fade delay
palFadeCount	rs.w	1			; Palette fade counter
updateBorderPal	rs.b	1			; Update border palette flag
		
	rsset	WORKRAM+$FF00FA00
vsyncFlag	rs.b	1			; VSync flag
		rs.b	$3F
vintRoutine	rs.w	1			; V-INT routine ID
timer		rs.w	1			; Timer
vintCounter	rs.w	1			; V-INT counter
vdpReg1		rs.w	1
		rs.b	2
p1CtrlData	rs.b	0			; Player 1 controller data
p1CtrlHold	rs.b	1			; Player 1 controller held buttons data
p1CtrlTap	rs.b	1			; Player 1 controller tapped buttons data
p2CtrlData	rs.b	0			; Player 2 controller data
p2CtrlHold	rs.b	1			; Player 2 controller held buttons data
p2CtrlTap	rs.b	1			; Player 2 controller tapped buttons data

; -------------------------------------------------------------------------
; MMD header
; -------------------------------------------------------------------------

	MMD	MMDSUBM, &
		WORKRAMFILE, $3000, &
		JmpTo_Start, 0, JmpTo_VInt

; -------------------------------------------------------------------------
; Program start
; -------------------------------------------------------------------------

JmpTo_Start:
	jmp	Start

; -------------------------------------------------------------------------
; V-INT routine
; -------------------------------------------------------------------------

JmpTo_VInt:
	jmp	VInterrupt

; -------------------------------------------------------------------------
; File signature
; -------------------------------------------------------------------------

	dc.l	$C040
	dc.b	'Opning Animaiton'

; -------------------------------------------------------------------------
; Entry point
; -------------------------------------------------------------------------

Start:
	clr.w	vintRoutine.w			; Reset V-INT routine ID
	
	bclr	#1,GAMAINFLAG			; Mark as initializing
	move.l	#VInterrupt,(_LEVEL6+2)&$FFFFFF	; Set V-INT routine
	move.b	#0,GAMAINFLAG			; Clear communication flag
	
	bsr.w	Wait1MMode			; Wait for Word RAM to be in 1M/1M mode
	bsr.w	InitMD				; Initialize the Mega Drive hardware
	
	lea	VDPDATA,a5			; VDP data port
	lea	4(a5),a4			; VDP control port
	VDPCMD	move.l,$E400,VRAM,WRITE,VDPCTRL	; Display buffer 2
	move.l	#$2000200,(a5)
	
	lea	VARSSTART.w,a0			; Clear variables
	move.w	#VARSLEN/4-1,d7

.ClearVars:
	clr.l	(a0)+
	dbf	d7,.ClearVars
	
	bsr.w	ClearPalette			; Clear palette
	bsr.w	DrawFMVTilemaps			; Draw FMV tilemaps
	bsr.w	DrawBorder			; Draw border
	
	move.w	#0,GACOMCMD2			; Clear communication command 2
	bset	#1,GAMAINFLAG			; Mark as initialized
	clr.w	unkC088.w			; Clear unknown variables
	
	bset	#6,vdpReg1+1.w			; Enable display
	move.w	vdpReg1.w,VDPCTRL

.WaitSubCPU:
	btst	#7,GASUBFLAG			; Wait for the Sub CPU to be initialized
	bne.s	.WaitSubCPU
	
	bclr	#1,GAMAINFLAG			; Mark as running
	bclr	#4,GAMAINFLAG
	bsr.w	WaitWordRAMSwap			; Swap Word RAM banks
	
	clr.w	vintRoutine.w			; Reset V-INT routine ID
	move.w	#4,readRoutine.w		; Reset data read routine ID

; -------------------------------------------------------------------------

MainLoop:
	moveq	#0,d0				; Run data read routine
	move.w	readRoutine.w,d0
	lea	FrameReadIndex(pc),a1
	adda.w	(a1,d0.w),a1
	jsr	(a1)
	
	bsr.s	VSync				; VSync
	
	btst	#1,GASUBFLAG			; Is the Sub CPU program still running?
	beq.s	MainLoop			; If so, loop
	btst	#1,GASUBFLAG
	beq.s	MainLoop			; If so, loop
	btst	#1,GASUBFLAG
	beq.s	MainLoop			; If so, loop
	
	bsr.s	Exit				; Exit
	clr.b	GAMAINFLAG			; Clear communication flag
	bsr.w	FadeToBlack			; Fade to black
	rts

; -------------------------------------------------------------------------
; VSync
; -------------------------------------------------------------------------

VSync:
	move.b	#1,vsyncFlag.w			; Set VSync flag

.Wait:
	tst.b	vsyncFlag.w			; Has the V-INT routine run?
	bne.s	.Wait				; If not, wait
	rts

; -------------------------------------------------------------------------
; Exit
; -------------------------------------------------------------------------

Exit:
	clr.w	vintRoutine.w			; Reset V-INT routine ID
	
	move.w	#60,d1				; Wait about a second

.Delay:
	bsr.w	VSync
	dbf	d1,.Delay
	
	bset	#4,GAMAINFLAG			; Mark as exiting

.WaitSubCPU:
	btst	#1,GASUBFLAG			; Has the Sub CPU exited?
	bne.s	.WaitSubCPU			; If not, wait
	btst	#1,GASUBFLAG
	bne.s	.WaitSubCPU			; If not, wait
	btst	#1,GASUBFLAG
	bne.s	.WaitSubCPU			; If not, wait
	rts

; -------------------------------------------------------------------------

FrameReadIndex:
	dc.w	FrameRead_Null-FrameReadIndex
	dc.w	FrameRead_Null-FrameReadIndex
	dc.w	FrameRead_Start-FrameReadIndex
	dc.w	FrameRead_Sect1-FrameReadIndex
	dc.w	FrameRead_Sect2_1-FrameReadIndex
	dc.w	FrameRead_Sect3_1-FrameReadIndex
	dc.w	FrameRead_Buf1Done-FrameReadIndex
	dc.w	FrameRead_NextFrame_1-FrameReadIndex
	dc.w	FrameRead_Sect2_2-FrameReadIndex
	dc.w	FrameRead_Sect3_2-FrameReadIndex
	dc.w	FrameRead_NextFrame_2-FrameReadIndex
	dc.w	FrameRead_NextFrame-FrameReadIndex
	dc.w	FrameRead_Wait1-FrameReadIndex
	dc.w	FrameRead_Wait2-FrameReadIndex
	dc.w	FrameRead_Wait3-FrameReadIndex

; -------------------------------------------------------------------------
; Reset frame read
; -------------------------------------------------------------------------

FrameRead_Start:
	lea	WORDRAM2M,a0			; Start at top of Word RAM bank
	clr.w	frameCount.w			; Reset frame count

; -------------------------------------------------------------------------
; Read section 1 of frame data
; -------------------------------------------------------------------------

FrameRead_Sect1:
	lea	palette.w,a1			; Palette buffer
	movea.l	a1,a3
	
	lea	$10*2(a1),a2			; Transfer work palette line into display palette line
	moveq	#$20/4-1,d7

.TransferPal:
	move.l	(a1)+,(a2)+
	dbf	d7,.TransferPal
	
	movea.l	a3,a1				; Load next frame's palette data into work palette line
	moveq	#$20/4-1,d7

.LoadPal:
	move.l	(a0)+,(a1)+
	dbf	d7,.LoadPal
	
	move.w	#5,vintRoutine.w		; Set V-INT routine for buffer 2 section 1 copying
	move.w	#$10,readRoutine.w		; Advance data read routine
	VDPCMD	move.l,$3A00,VRAM,WRITE,d0	; VRAM write command for buffer 2 section 1
	
	btst	#0,frameCount+1.w		; Are we displaying buffer 2?
	beq.s	LoadFrameSect			; If not, branch
	
	move.w	#8,readRoutine.w		; Set V-INT routine for buffer 1 section 1 copying
	move.w	#1,vintRoutine.w		; Advance data read routine
	VDPCMD	move.l,$0200,VRAM,WRITE,d0	; VRAM write command for buffer 1 section 1
	bra.s	LoadFrameSect			; Load frame data section

; -------------------------------------------------------------------------
; Read section 2 of frame data for buffer 1
; -------------------------------------------------------------------------

FrameRead_Sect2_1:
	move.w	#2,vintRoutine.w		; Set V-INT routine for buffer 1 section 2 copying
	move.w	#$A,readRoutine.w		; Advance data read routine
	VDPCMD	move.l,$14C0,VRAM,WRITE,d0	; VRAM write command for buffer 1 section 2

; -------------------------------------------------------------------------
; Read section of frame data
; -------------------------------------------------------------------------

LoadFrameSect:
	lea	frameDMA.w,a2			; Frame DMA info
	move.w	#1,(a2)+			; Activate DMA
	move.l	d0,(a2)+			; Set VRAM write command
	move.l	a0,(a2)+			; Set source address
	move.w	#$12C0/2,(a2)+			; Set DMA length
	
	lea	$12C0(a0),a0			; Set next data address
	move.l	a0,curDataAddr.w
	rts

; -------------------------------------------------------------------------
; Read section 2 of frame data for buffer 2
; -------------------------------------------------------------------------

FrameRead_Sect2_2:
	move.w	#6,vintRoutine.w		; Set V-INT routine for buffer 2 section 2 copying
	move.w	#$12,readRoutine.w		; Advance data read routine
	VDPCMD	move.l,$4CC0,VRAM,WRITE,d0	; VRAM write command for buffer 2 section 2
	bra.s	LoadFrameSect			; Load frame data section

; -------------------------------------------------------------------------
; Read section 3 of frame data for buffer 2
; -------------------------------------------------------------------------

FrameRead_Sect3_2:
	move.w	#7,vintRoutine.w		; Set V-INT routine for buffer 2 section 3 copying
	move.w	#$14,readRoutine.w		; Advance data read routine
	VDPCMD	move.l,$5F80,VRAM,WRITE,d0	; VRAM write command for buffer 2 section 3
	bra.s	LoadFrameSect3			; Load frame data section

; -------------------------------------------------------------------------
; Read section 3 of frame data for buffer 1
; -------------------------------------------------------------------------

FrameRead_Sect3_1:
	move.w	#3,vintRoutine.w		; Set V-INT routine for buffer 1 section 3 copying
	move.w	#$C,readRoutine.w		; Advance data read routine
	VDPCMD	move.l,$2780,VRAM,WRITE,d0	; VRAM write command for buffer 1 section 3

; -------------------------------------------------------------------------
; Read section 3 of frame data
; -------------------------------------------------------------------------

LoadFrameSect3:
	lea	frameDMA.w,a2			; Frame DMA info
	move.w	#1,(a2)+			; Activate DMA
	move.l	d0,(a2)+			; Set VRAM write command
	move.l	a0,(a2)+			; Set source address
	move.w	#$1280/2,(a2)+			; Set DMA length

	lea	$1280(a0),a0			; Set next data address
	move.l	a0,curDataAddr.w
	rts

; -------------------------------------------------------------------------
; Buffer 1 done
; -------------------------------------------------------------------------

FrameRead_Buf1Done:
	move.w	#4,vintRoutine.w		; Set V-INT routine for delay frame
	if REGION<>EUROPE
		move.w	#$E,readRoutine.w	; Advance data read routine
		rts
	else
		bra.s	FrameRead_NextFrame	; PAL doesn't use this delay frame
	endif

; -------------------------------------------------------------------------
; Advance frame for buffer 1
; -------------------------------------------------------------------------

FrameRead_NextFrame_1:
	clr.w	vintRoutine.w			; Reset V-INT routine ID
	bra.s	FrameRead_NextFrame		; Advance frame

; -------------------------------------------------------------------------
; Advance frame for buffer 2
; -------------------------------------------------------------------------

FrameRead_NextFrame_2:
	move.w	#8,vintRoutine.w		; Reset V-INT routine ID
	
; -------------------------------------------------------------------------

FrameRead_NextFrame:
	bsr.w	CheckFMVStop			; Check if the FMV should be stopped
	
	clr.w	vintRoutine.w			; Reset V-INT routine ID
	addq.w	#1,frameCount.w			; Advance frame counter
	cmpi.w	#8,frameCount.w			; Are we at the end of the Word RAM bank?
	bpl.s	.SwapWordRAM			; If so, branch
	move.w	#$18,readRoutine.w		; Advance data read routine
	rts

.SwapWordRAM:
	bsr.w	WaitWordRAMSwap			; Wait for Word RAM bank swap (takes a few frames)
	move.w	#4,readRoutine.w		; Reset data read
	move.l	(sp)+,d0			; Skip VSync and immediately start reading new data
	bra.w	MainLoop

; -------------------------------------------------------------------------
; Delay frame 1
; -------------------------------------------------------------------------

FrameRead_Wait1:
	move.w	#$1A,readRoutine.w		; Advance data read routine
	rts

; -------------------------------------------------------------------------
; Delay frame 2
; -------------------------------------------------------------------------

FrameRead_Wait2:
	if REGION<>EUROPE
		move.w	#$1C,readRoutine.w	; Advance data read routine
	else	
		move.w	#6,readRoutine.w	; Reset data read routine ID
	endif
	rts

; -------------------------------------------------------------------------
; Delay frame 3 (NTSC only)
; -------------------------------------------------------------------------

FrameRead_Wait3:
	move.w	#6,readRoutine.w		; Reset data read routine ID
	rts

; -------------------------------------------------------------------------
; Null
; -------------------------------------------------------------------------

FrameRead_Null:
	rts

; -------------------------------------------------------------------------
; Fade to black
; -------------------------------------------------------------------------

FadeToBlack:
	move.w	#8-1,palFadeCount.w		; Fade all the way to black
	
	lea	Pal_OpenFMV+$20(pc),a1		; Load border palette
	lea	palette+$40.w,a2
	moveq	#$20/2-1,d7

.LoadBorderPal:
	move.w	(a1)+,(a2)+
	dbf	d7,.LoadBorderPal

.FadeLoop:
	move.w	#2,palFadeDelay.w		; Set fade delay
	
	lea	palette+$20.w,a1		; Fade the currently displayed frame and border palette
	moveq	#$20-1,d7
	
	move.w	#$F,d0				; Red mask
	move.w	#$F0,d1				; Green mask
	move.w	#$F00,d2			; Blue mask

.ColorLoop:
	move.w	(a1),d3				; Get color
	move.w	d3,d4
	move.w	d3,d5
	
	and.w	d0,d3				; Isolate red
	beq.s	.FadeGreen			; If it's already 0, branch
	subq.w	#2,d3				; Fade out red

.FadeGreen:
	and.w	d1,d4				; Isolate green
	beq.s	.FadeBlue			; If it's already 0, branch
	subi.w	#$20,d4				; Fade out green

.FadeBlue:
	and.w	d2,d5				; Isolate blue
	beq.s	.Combine			; If it's already 0, branch
	subi.w	#$200,d5			; Fade out blue

.Combine:
	or.w	d5,d4				; Combine new color values
	or.w	d4,d3
	move.w	d3,(a1)+			; Store new color
	dbf	d7,.ColorLoop			; Loop until colors are faded
	
	st	updateBorderPal.w		; Update the border palette in CRAM

.Delay:
	bsr.w	VSync				; VSync
	subq.w	#1,palFadeDelay.w		; Decrement delay timer
	bne.s	.Delay				; If it hasn't run out, branch
	
	subq.w	#1,palFadeCount.w		; Decrement fade counter
	bpl.s	.FadeLoop			; If it hasn't run out, loop
	rts

; -------------------------------------------------------------------------
; Draw FMV tilemaps
; -------------------------------------------------------------------------

DrawFMVTilemaps:
	moveq	#$10,d4				; Draw buffer 1
	VDPCMD	move.l,$C608,VRAM,WRITE,d0
	move.w	#$20-1,d1
	move.w	#$E-1,d2
	bsr.s	.DrawMap
	
	move.w	#$1D0,d4			; Draw buffer 2
	VDPCMD	move.l,$C688,VRAM,WRITE,d0
	move.w	#$20-1,d1
	move.w	#$E-1,d2

; -------------------------------------------------------------------------

.DrawMap:
.DrawRow:
	move.l	d0,(a4)				; Set VDP command
	move.l	d1,d3				; Get width

.DrawTile:
	move.w	d4,(a5)				; Set tile ID
	addq.w	#1,d4				; Increment tile ID
	dbf	d3,.DrawTile			; Loop until row is drawn
	
	addi.l	#$1000000,d0			; Next row
	dbf	d2,.DrawRow			; Loop until tilemap is drawn
	rts

; -------------------------------------------------------------------------
; Clear palette
; -------------------------------------------------------------------------

ClearPalette:
	moveq	#$80/4-1,d7			; Clear palette
	lea	palette.w,a1

.ClearLoop:
	clr.l	(a1)+
	dbf	d7,.ClearLoop
	rts

; -------------------------------------------------------------------------
; Wait for Word RAM to be switched to 1M/1M mode
; -------------------------------------------------------------------------

Wait1MMode:
	btst	#2,GAMEMMODE			; Is Word RAM in 1M/1M mode yet?
	beq.s	Wait1MMode			; If not, wait
	rts

; -------------------------------------------------------------------------
; Check if the FMV should be stopped
; -------------------------------------------------------------------------

CheckFMVStop:
	btst	#7,p1CtrlHold.w			; Has the start button been pressed?
	beq.s	.End				; If not, branch
	bset	#2,GAMAINFLAG			; If so, stop FMV now

.End:
	rts

; -------------------------------------------------------------------------
; Initialize the Mega Drive hardware
; -------------------------------------------------------------------------

InitMD:
	lea	VDPRegs(pc),a1			; Set up VDP registers
	jsr	BIOS_SetVDPRegs.w
	
	moveq	#$40,d0				; Set up controller ports
	move.b	d0,IOCTRL1
	move.b	d0,IOCTRL2
	move.b	d0,IOCTRL3
	move.b	#$C0,IODATA1

	Z80STOP					; Stop the Z80
	
	DMAFILL	0,$10000,0			; Clear VRAM
	
	VDPCMD	move.l,$C000,VRAM,WRITE,VDPCTRL	; Set up plane A
	move.w	#$2000/2-1,d7

.SetupPlaneA:
	move.w	#$E7E1,VDPDATA
	dbf	d7,.SetupPlaneA
	
	VDPCMD	move.l,$0000,CRAM,WRITE,VDPCTRL	; Load palette
	lea	Pal_OpenFMV(pc),a0
	moveq	#(Pal_OpenFMVEnd-Pal_OpenFMV)/4-1,d7

.LoadPal:
	move.l	(a0)+,VDPDATA
	dbf	d7,.LoadPal
	
	VDPCMD	move.l,0,VSRAM,WRITE,VDPCTRL	; Clear VSRAM
	move.l	#0,VDPDATA

	Z80START				; Start the Z80
	move.w	#$8134,vdpReg1.w		; Reset VDP register 1 cache
	rts

; -------------------------------------------------------------------------

Pal_OpenFMV:
	incbin	"FMV/Data/Palette (Opening).bin"
Pal_OpenFMVEnd:
	even

VDPRegs:
	dc.w	$8000|%00000100			; No H-INT
	dc.w	$8100|%00110100			; V-INT, DMA, mode 5
	dc.w	$8200|($C000/$400)		; Plane A location
	dc.w	$8300|0				; Window location
	dc.w	$8400|($A000/$2000)		; Plane B location
	dc.w	$8500|($E000/$200)		; Sprite table location
	dc.w	$8600|0				; Reserved
	dc.w	$8700|0				; BG color line 0 color 0
	dc.w	$8A00|0				; Reserved
	dc.w	$8B00|0				; Reserved
	dc.w	$8C00|%10000001			; H40
	dc.w	$8D00|($E400/$400)		; Horizontal scroll table lcation
	dc.w	$8F00|02			; Auto increment by 2
	dc.w	$9000|%00000011			; 128x32 tile plane size
	dc.w	$9100|0				; Window horizontal position 0
	dc.w	$9200|0				; Window vertical position 0
	dc.w	0				; End of VDP register list

; -------------------------------------------------------------------------
; Read controllers
; -------------------------------------------------------------------------

ReadControllers:
	lea	p1CtrlData.w,a0			; Player 1 controller data buffer
	lea	IODATA1,a1			; Controller port 1
	bsr.s	ReadController			; Read controller data
	
	lea	p2CtrlData.w,a0			; Player 2 controller data buffer
	lea	IODATA2,a1			; Controller port 2

; -------------------------------------------------------------------------

ReadController:
	move.b	#0,(a1)				; TH = 0
	tst.w	(a0)				; Delay
	move.b	(a1),d0				; Read start and A buttons
	lsl.b	#2,d0
	andi.b	#$C0,d0
	
	move.b	#$40,(a1)			; TH = 1
	tst.w	(a0)				; Delay
	move.b	(a1),d1				; Read B, C, and D-pad buttons
	andi.b	#$3F,d1

	or.b	d1,d0				; Combine button data
	not.b	d0				; Flip bits
	move.b	d0,d1				; Make copy

	move.b	(a0),d2				; Mask out tapped buttons
	eor.b	d2,d0
	move.b	d1,(a0)+			; Store pressed buttons
	and.b	d1,d0				; Store tapped buttons
	move.b	d0,(a0)+
	rts

; -------------------------------------------------------------------------
; Wait for Word RAM swap
; -------------------------------------------------------------------------

WaitWordRAMSwap:
	btst	#1,GASUBFLAG
	bne.s	.End
	btst	#0,GASUBFLAG
	beq.s	WaitWordRAMSwap
	btst	#0,GASUBFLAG
	beq.s	WaitWordRAMSwap
	btst	#0,GASUBFLAG
	beq.s	WaitWordRAMSwap
	btst	#2,GAMAINFLAG
	bne.s	WaitWordRAMSwap
	bclr	#1,GAMEMMODE
	bset	#0,GAMAINFLAG

.WaitSubCPU:
	btst	#1,GAMEMMODE
	bne.s	.WaitSubCPU
	btst	#1,GAMEMMODE
	bne.s	.WaitSubCPU
	btst	#1,GAMEMMODE
	bne.s	.WaitSubCPU
	bclr	#0,GAMAINFLAG

.End:
	rts

; -------------------------------------------------------------------------
; Draw border
; -------------------------------------------------------------------------

DrawBorder:
	DMA68K	Art_Border,$7D00,$1C00,VRAM	; Load border art
	
	VDPCMD	move.l,$A000,VRAM,WRITE,d0	; VRAM write command
	move.w	#$28-1,d1			; Width
	move.w	#$1C-1,d2			; Height
	lea	Map_Border(pc),a1		; Map data

.DrawRow:
	move.l	d0,(a4)				; Set VDP command
	move.l	d1,d3				; Get height

.DrawTile:
	move.w	(a1)+,(a5)			; Draw tile
	dbf	d3,.DrawTile			; Loop until row is drawn
	addi.l	#$1000000,d0			; Next row
	dbf	d2,.DrawRow			; Loop until map is drawn
	rts

; -------------------------------------------------------------------------
; V-BLANK interrupt
; -------------------------------------------------------------------------

VInterrupt:
	movem.l	d0-a6,-(sp)			; Save registers
	
	move.b	#1,GAIRQ2			; Trigger IRQ2 on Sub CPU
	tst.b	vsyncFlag.w			; Is this a lag frame?
	beq.w	VInt_End			; If so, branch
	clr.b	vsyncFlag.w			; Clear VSync flag
	
	lea	VDPDATA,a5			; VDP control port
	lea	4(a5),a4			; VDP data port
	move.w	(a4),d0				; Reset V-BLANK flag
	
	move.w	vintRoutine.w,d0		; Run routine
	add.w	d0,d0
	move.w	.Routines(pc,d0.w),d0
	jmp	.Routines(pc,d0.w)
	
; -------------------------------------------------------------------------

.Routines:
	dc.w	VInt_LoadFramePal-.Routines
	dc.w	VInt_DisplayBuf2-.Routines
	dc.w	VInt_CopyFrameData-.Routines
	dc.w	VInt_CopyFrameData-.Routines
	dc.w	VInt_CopyFrameData-.Routines
	dc.w	VInt_DisplayBuf1-.Routines
	dc.w	VInt_CopyFrameData-.Routines
	dc.w	VInt_CopyFrameData-.Routines
	dc.w	VInt_CopyFrameData-.Routines
	dc.w	VInt_LoadFrameWork-.Routines
	
; -------------------------------------------------------------------------

VInt_DisplayBuf2:
	VDPCMD	move.l,$E400,VRAM,WRITE,VDPCTRL	; Display buffer 2
	move.l	#$2000000,(a5)
	bra.s	VInt_CopyFrameData		; Copy frame data

; -------------------------------------------------------------------------

VInt_DisplayBuf1:
	VDPCMD	move.l,$E400,VRAM,WRITE,VDPCTRL	; Display buffer 1
	move.l	#0,(a5)

; -------------------------------------------------------------------------

VInt_CopyFrameData:
	lea	frameDMA.w,a0			; Get frame DMA info
	move.w	(a0),d7				; Get activated flag
	clr.w	(a0)+				; Clear it
	tst.w	d7				; Was the flag set?
	beq.s	VInt_LoadFramePal		; If not, branch
	
	move.l	(a0)+,d0			; Copy frame art into VRAM
	move.l	(a0)+,d1
	move.w	(a0)+,d2
	movem.l	d7-a0,-(sp)
	jsr	BIOS_DMA68k.w
	movem.l	(sp)+,d7-a0

; -------------------------------------------------------------------------

VInt_LoadFramePal:
	VDPCMD	move.l,$0000,CRAM,WRITE,VDPCTRL	; Copy currently displayed frame palette into CRAM
	moveq	#$20/2-1,d7
	lea	palette+$20.w,a1

.CopyFramePal:
	move.w	(a1)+,(a5)
	dbf	d7,.CopyFramePal
	
	tst.w	updateBorderPal.w		; Does the border palette need to be updated?
	beq.s	.NoBorderPalCopy		; If not, branch
	clr.w	updateBorderPal.w		; If so, update it
	moveq	#$20/2-1,d7

.CopyBorderPal:
	move.w	(a1)+,(a5)
	dbf	d7,.CopyBorderPal

.NoBorderPalCopy:
	bset	#6,vdpReg1+1.w			; Enable display
	move.w	vdpReg1.w,VDPCTRL
	
	jsr	ReadControllers(pc)		; Read controllers

	tst.w	timer.w				; Is the timer running?
	beq.s	.NoTimer			; If not, branch
	subq.w	#1,timer.w			; Decrement timer

.NoTimer:
	addq.w	#1,vintCounter.w		; Increment counter
	
VInt_End:
	movem.l	(sp)+,d0-a6
	rte

; -------------------------------------------------------------------------
; Unused V-INT routine to copy the currently worked on frame data
; into VDP memory
; -------------------------------------------------------------------------

VInt_LoadFrameWork:
	lea	frameDMA.w,a0			; Get frame DMA info
	move.w	(a0),d7				; Get activated flag
	clr.w	(a0)+				; Clear it
	tst.w	d7				; Was the flag set?
	beq.s	.NoArt				; If not, branch
	
	move.l	(a0)+,d0			; Copy frame art into VRAM
	move.l	(a0)+,d1
	move.w	#$12C0/2,d2
	movem.l	d7-a0,-(sp)
	jsr	BIOS_DMA68k.w
	movem.l	(sp)+,d7-a0

.NoArt:
	VDPCMD	move.l,$0000,CRAM,WRITE,VDPCTRL	; Copy currently displayed frame palette into CRAM
	moveq	#$20/2-1,d7
	lea	palette.w,a1

.CopyFramePal:
	move.w	(a1)+,(a5)
	dbf	d7,.CopyFramePal
	
	bra.w	VInt_LoadFramePal		; Load palette data

; -------------------------------------------------------------------------
; Data
; -------------------------------------------------------------------------

Art_Border:
	incbin	"FMV/Data/Art (Border, Opening).bin"
	even
	
Map_Border:
	incbin	"FMV/Data/Border Mappings (Opening).bin"
	even
	
; -------------------------------------------------------------------------
