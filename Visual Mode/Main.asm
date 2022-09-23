; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Visual Mode
; -------------------------------------------------------------------------

	include	"_Include/Common.i"
	include	"_Include/Main CPU.i"
	include	"_Include/Main CPU Variables.i"
	include	"_Include/MMD.i"

; -------------------------------------------------------------------------
; Object variables structure
; -------------------------------------------------------------------------

	rsreset
oID		rs.w	1			; ID
		rs.b	2
oX		rs.l	1			; X position
oY		rs.l	1			; Y position
		rs.b	$16
oAnimTime	rs.w	1			; Animation timer
oAnimFrame	rs.w	1			; Animation frame
oTile		rs.w	1			; Base tile ID
oMap		rs.l	1			; Mappings
oFlags		rs.b	1			; Flags
oVars		rs.b	$40-__rs		; Object specific variables
oSize		rs.b	0			; Size of structure

; -------------------------------------------------------------------------
; Variables
; -------------------------------------------------------------------------

	rsset	WORKRAM+$FF009000
VARSSTART	rs.b	0			; Start of variables
		rs.b	$5800
sprites		rs.b	80*8			; Sprtie buffer
		rs.b	$80
nemBuffer	rs.b	$200			; Nemesis decompression buffer
palette		rs.w	$40			; Palette buffer
fadePalette	rs.w	$40			; Fade palette buffer
waterPalette	rs.w	$40			; Water palette buffer
waterFadePal	rs.w	$40			; Water fade palette buffer

objects		rs.b	0			; Object pool
object0		rs.b	oSize			; Object 0
object1		rs.b	oSize			; Object 1
object2		rs.b	oSize			; Object 2
object3		rs.b	oSize			; Object 3
object4		rs.b	oSize			; Object 4
object5		rs.b	oSize			; Object 5
object6		rs.b	oSize			; Object 6
object7		rs.b	oSize			; Object 7
object8		rs.b	oSize			; Object 8
object9		rs.b	oSize			; Object 9
object10	rs.b	oSize			; Object 10
object11	rs.b	oSize			; Object 11
object12	rs.b	oSize			; Object 12
object13	rs.b	oSize			; Object 13
object14	rs.b	oSize			; Object 14
object15	rs.b	oSize			; Object 15
OBJCOUNT	EQU	(__rs-objects)/oSize

		rs.b	$40
exitFlag	rs.b	1			; Exit flag
		rs.b	$41
menuSelection	rs.w	1			; Menu selection
		rs.b	$1A
buttonFlags	rs.b	1			; Button flags
vsyncFlag	rs.b	1			; VSync flag
		rs.b	4
vintRoutine	rs.w	1			; V-INT routine ID
timer		rs.w	1			; Timer
vintCounter	rs.w	1			; V-INT counter
savedSR		rs.w	1			; Saved status register
		rs.b	4
lagCounter	rs.l	1			; Lag counter
		rs.b	4
palFadeInfo	rs.b	0			; Palette fade info
palFadeStart	rs.b	1			; Palette fade start
palFadeLen	rs.b	1			; Palette fade length
		rs.b	$846
VARSLEN		EQU	__rs-VARSSTART		; Size of variables area

ctrlData	EQU	GACOMCMDE		; Controller data
ctrlHold	EQU	ctrlData		; Controller held buttons data
ctrlTap		EQU	ctrlData+1		; Controller tapped buttons data

; -------------------------------------------------------------------------
; MMD header
; -------------------------------------------------------------------------

	MMD	0, &
		WORKRAMFILE, $5000, &
		Start, 0, 0

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
	move.b	d0,GAMAINFLAG
	
	lea	VARSSTART.w,a0			; Clear variables
	moveq	#0,d0
	move.w	#VARSLEN/4-1,d7

.ClearVars:
	move.l	d0,(a0)+
	dbf	d7,.ClearVars
	
	; NOTE: Leftover hotfix from DA Garden. See DA Garden's Main CPU
	; code for more information on why this exists.
	move.w	#$8000,ctrlData			; Force program to assume start button was being held
	
	bsr.w	InitMD				; Initialize the Mega Drive
	bsr.w	DrawBackground			; Draw background
	moveq	#1,d0				; Load art
	jsr	LoadArt
	
	bsr.w	SpawnMenuOptions		; Spawn menu options
	
	bset	#6,ipxVDPReg1+1			; Enable display
	move.w	ipxVDPReg1,VDPCTRL
	
	lea	Pal_VisualMode(pc),a0		; Load palette
	lea	fadePalette.w,a1
	moveq	#(Pal_VisualModeEnd-Pal_VisualMode)/4-1,d7
	
.LoadPal:
	move.l	(a0)+,(a1)+
	dbf	d7,.LoadPal
	
	bsr.w	FadeFromBlack			; Fade from black
	
; -------------------------------------------------------------------------

MainLoop:
	bsr.w	UpdateSelection			; Update menu selection
	tst.b	exitFlag.w			; Are we exiting?
	bne.s	.Exit				; If so, branch
	bsr.w	UpdateObjects			; Update objects
	bsr.w	VSync				; VSync
	bra.s	MainLoop			; Loop
	
.Exit:
	bsr.w	FadeToBlack			; Fade to black
	
	moveq	#0,d0				; Return menu selection
	move.w	menuSelection.w,d0
	nop
	nop
	nop
	rts

; -------------------------------------------------------------------------
; Update menu selection
; -------------------------------------------------------------------------

UpdateSelection:
	btst	#7,ctrlTap			; Has the start button been pressed?
	beq.s	.CheckA				; If not, branch
	move.b	#1,exitFlag.w			; If so, set the exit flag
	rts
	
.CheckA:
	btst	#6,ctrlTap			; Has the A button been pressed?
	beq.s	.CheckB				; If not, branch
	move.b	#1,exitFlag.w			; If so, set the exit flag
	rts

.CheckB:
	btst	#4,ctrlTap			; Has the B button been pressed?
	beq.s	.CheckC				; If not, branch
	move.b	#1,exitFlag.w			; If so, set the exit flag
	rts

.CheckC:
	btst	#5,ctrlTap			; Has the C button been pressed?
	beq.s	.CheckUp			; If not, branch
	move.b	#1,exitFlag.w			; If so, set the exit flag
	rts

.CheckUp:
	btst	#0,ctrlHold			; Is up being held?
	bne.s	.UpHeld				; If so, branch
	btst	#0,buttonFlags.w		; If not, was it being held before?
	beq.s	.CheckDown			; If not, branch
	bclr	#0,buttonFlags.w		; Mark as released
	
	subq.w	#1,menuSelection.w		; Move selection up
	bge.s	.CheckDown			; If it hasn't wrapped, branch
	move.w	#4,menuSelection.w		; Wrap to the bottom
	bra.s	.CheckDown
	
.UpHeld:
	bset	#0,buttonFlags.w		; Mark as held
	
.CheckDown:
	btst	#1,ctrlHold			; Is down being held?
	bne.s	.DownHeld			; If so, branch
	btst	#1,buttonFlags.w		; If not, was it being held before?
	beq.s	.CheckRight			; If not, branch
	bclr	#1,buttonFlags.w		; Mark as released
	
	addq.w	#1,menuSelection.w		; Move selection down
	cmpi.w	#4,menuSelection.w		; Has it wrapped?
	ble.s	.CheckRight			; If not, branch
	move.w	#0,menuSelection.w		; Wrap to the top
	bra.s	.CheckRight
	
.DownHeld:
	bset	#1,buttonFlags.w		; Mark as held
	
.CheckRight:
	btst	#3,ctrlHold			; Is right being held?
	bne.s	.RightHeld			; If so, branch
	btst	#3,buttonFlags.w		; If not, was it being held before?
	beq.s	.CheckLeft			; If not, branch
	bclr	#3,buttonFlags.w		; Mark as released
	
	subq.w	#1,menuSelection.w		; Move selection up
	bge.s	.CheckLeft			; If it hasn't wrapped, branch
	move.w	#4,menuSelection.w		; Wrap to the button
	bra.s	.CheckLeft
	
.RightHeld:
	bset	#3,buttonFlags.w		; Mark as held
	
.CheckLeft:
	btst	#2,ctrlHold			; Is left being held?
	bne.s	.LeftHeld			; If so, branch
	btst	#2,buttonFlags.w		; If not, was it being held before?
	beq.s	.End				; If not, branch
	bclr	#2,buttonFlags.w		; Mark as released
	
	addq.w	#1,menuSelection.w		; Move selection down
	cmpi.w	#4,menuSelection.w		; Has it wrapped?
	ble.s	.End				; If not, branch
	move.w	#0,menuSelection.w		; Wrap to the top
	bra.s	.End
	
.LeftHeld:
	bset	#2,buttonFlags.w		; Mark as held
	
.End:
	rts

; -------------------------------------------------------------------------
; Draw background
; -------------------------------------------------------------------------

DrawBackground:
	lea	VDPCTRL,a2			; VDP control port
	
	lea	Map_VisModeBG,a1		; Background mappings
	move.w	#$4001,d6			; Base tile ID
	VDPCMD	move.l,$C000,VRAM,WRITE,d0	; VDP write command
	
	move.w	#$1C-1,d1			; Get height
	
.DrawRow:
	move.l	d0,(a2)				; Set VDP command
	move.w	#$28-1,d2			; Get width

.DrawTile:
	move.w	(a1)+,d3			; Draw tile
	add.w	d6,d3
	move.w	d3,VDPDATA
	dbf	d2,.DrawTile			; Loop until row is written
	
	addi.l	#$800000,d0			; Next row
	dbf	d1,.DrawRow			; Loop until map is drawn
	
	VDPCMD	move.l,$20,VRAM,WRITE,VDPCTRL	; Load background art
	lea	Art_VisModeBG,a0
	bsr.w	NemDec
	rts
	
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
; Initialize the Mega Drive hardware
; -------------------------------------------------------------------------

InitMD:
	lea	VDPRegs(pc),a0			; Set up VDP registers
	move.w	#$8000,d0
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
	
	bra.s	.SkipZ80			; Skip the Z80 stuff
	
	Z80RESOFF				; Set Z80 reset off
	bsr.w	StopZ80				; Stop the Z80
	
	lea	Z80RAM,a1			; Load Z80 code
	move.b	#$F3,(a1)+			; DI
	move.b	#$F3,(a1)+			; DI
	move.b	#$C3,(a1)+			; JP $0000
	move.b	#0,(a1)+
	move.b	#0,(a1)+
	
	Z80RESON				; Set Z80 reset on
	Z80RESOFF				; Set Z80 reset off

.SkipZ80:
	bsr.w	StopZ80				; Stop the Z80

	DMAFILL	0,$10000,0			; Clear VRAM

	VDPCMD	move.l,$C000,VRAM,WRITE,VDPCTRL	; Reset plane A
	move.w	#$1000/2-1,d7

.ResetPlaneA:
	move.w	#$E6FF,VDPDATA
	dbf	d7,.ResetPlaneA

	VDPCMD	move.l,$E000,VRAM,WRITE,VDPCTRL	; Reset plane B
	move.w	#$1000/2-1,d7

.ResetPlaneB:
	move.w	#$6FE,VDPDATA
	dbf	d7,.ResetPlaneB
	
	VDPCMD	move.l,0,CRAM,WRITE,VDPCTRL	; Clear CRAM
	lea	Pal_VisualMode(pc),a0
	moveq	#0,d0
	moveq	#$80/4-1,d7
	
.ClearCRAM:
	move.l	d0,VDPDATA
	dbf	d7,.ClearCRAM

	VDPCMD	move.l,0,VSRAM,WRITE,VDPCTRL	; Reset VSRAM
	move.l	#$FFE0,VDPDATA

	bsr.w	StartZ80			; Start the Z80
	move.w	#$8134,ipxVDPReg1		; Reset IPX VDP register 1 cache
	rts

; -------------------------------------------------------------------------

Pal_VisualMode:
	incbin	"Visual Mode/Data/Palette.bin"
Pal_VisualModeEnd:
	even

VDPRegs:
	dc.b	%00000100			; No H-INT
	dc.b	%00110100			; V-INT, DMA, mode 5
	dc.b	$C000/$400			; Plane A location
	dc.b	0				; Window location
	dc.b	$E000/$2000			; Plane B location
	dc.b	$EC00/$200			; Sprite table location
	dc.b	0				; Reserved
	dc.b	0				; BG color line 0 color 0
	dc.b	0				; Reserved
	dc.b	0				; Reserved
	dc.b	0				; H-INT counter 0
	dc.b	%00000000			; Scroll by screen
	dc.b	%10000001			; H40
	dc.b	$D000/$400			; Horizontal scroll table lcation
	dc.b	0				; Reserved
	dc.b	2				; Auto increment by 2
	dc.b	%00000001			; 64x32 tile plane size
	dc.b	0				; Window horizontal position 0
	dc.b	0				; Window vertical position 0
VDPRegsEnd:
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
	and.b	d1,d0				; store tapped buttons
	move.b	d0,(a0)+
	rts

; -------------------------------------------------------------------------
; V-BLANK interrupt
; -------------------------------------------------------------------------

VInterrupt:
	movem.l	d0-a6,-(sp)			; Save registers

	move.b	#1,GAIRQ2			; Trigger IRQ2 on Sub CPU
	tst.b	vsyncFlag.w			; Is the VSync flag set?
	beq.w	VInt_Lag			; If not, branch
	move.b	#0,vsyncFlag.w			; Clear VSync flag
	
	lea	VDPCTRL,a1			; VDP control port
	lea	VDPDATA,a2			; VDP data port
	move.w	(a1),d0				; Reset V-BLANK flag

	jsr	StopZ80(pc)			; Stop the Z80
	DMA68K	sprites,$EC00,$280,VRAM		; Copy sprite data
	DMA68K	palette,$0000,$80,CRAM		; Copy palette data
	bsr.w	StartZ80			; Start the Z80
	
	tst.w	timer.w				; Is the timer running?
	beq.s	.NoTimer			; If not, branch
	subq.w	#1,timer.w			; Decrement timer

.NoTimer:
	addq.w	#1,vintCounter.w		; Increment counter
	jsr	ReadController(pc)		; Read controller data
	
	movem.l	(sp)+,d0-a6			; Restore registers
	rte

; -------------------------------------------------------------------------

VInt_Lag:
	addq.l	#1,lagCounter.w			; Increment lag counter
	move.b	vintRoutine+1.w,lagCounter.w	; Save routine ID
	jsr	ReadController(pc)		; Read controller data
	
	movem.l	(sp)+,d0-a6			; Restore registers
	rte

; -------------------------------------------------------------------------
; Mass fill
; -------------------------------------------------------------------------
; PARAMETERS:
;	d1.l - Value to fill with
;	a1.l - Pointer to destination buffer
; -------------------------------------------------------------------------

Fill128:
	move.l	d1,(a1)+
Fill124:
	move.l	d1,(a1)+
Fill120:
	move.l	d1,(a1)+
Fill116:
	move.l	d1,(a1)+
Fill112:
	move.l	d1,(a1)+
Fill108:
	move.l	d1,(a1)+
Fill104:
	move.l	d1,(a1)+
Fill100:
	move.l	d1,(a1)+
Fill96:
	move.l	d1,(a1)+
Fill92:
	move.l	d1,(a1)+
Fill88:
	move.l	d1,(a1)+
Fill84:
	move.l	d1,(a1)+
Fill80:
	move.l	d1,(a1)+
Fill76:
	move.l	d1,(a1)+
Fill72:
	move.l	d1,(a1)+
Fill68:
	move.l	d1,(a1)+
Fill64:
	move.l	d1,(a1)+
Fill60:
	move.l	d1,(a1)+
Fill56:
	move.l	d1,(a1)+
Fill52:
	move.l	d1,(a1)+
Fill48:
	move.l	d1,(a1)+
Fill44:
	move.l	d1,(a1)+
Fill40:
	move.l	d1,(a1)+
Fill36:
	move.l	d1,(a1)+
Fill32:
	move.l	d1,(a1)+
Fill28:
	move.l	d1,(a1)+
Fill24:
	move.l	d1,(a1)+
Fill20:
	move.l	d1,(a1)+
Fill16:
	move.l	d1,(a1)+
Fill12:
	move.l	d1,(a1)+
Fill8:
	move.l	d1,(a1)+
Fill4:
	move.l	d1,(a1)+
	rts

; -------------------------------------------------------------------------
; Mass fill (VDP)
; -------------------------------------------------------------------------
; PARAMETERS:
;	d1.l - Value to fill with
;	a1.l - VDP control port
; -------------------------------------------------------------------------

Fill128VDP:
	move.l	d1,(a1)
Fill124VDP:
	move.l	d1,(a1)
Fill120VDP:
	move.l	d1,(a1)
Fill116VDP:
	move.l	d1,(a1)
Fill112VDP:
	move.l	d1,(a1)
Fill108VDP:
	move.l	d1,(a1)
Fill104VDP:
	move.l	d1,(a1)
Fill100VDP:
	move.l	d1,(a1)
Fill96VDP:
	move.l	d1,(a1)
Fill92VDP:
	move.l	d1,(a1)
Fill88VDP:
	move.l	d1,(a1)
Fill84VDP:
	move.l	d1,(a1)
Fill80VDP:
	move.l	d1,(a1)
Fill76VDP:
	move.l	d1,(a1)
Fill72VDP:
	move.l	d1,(a1)
Fill68VDP:
	move.l	d1,(a1)
Fill64VDP:
	move.l	d1,(a1)
Fill60VDP:
	move.l	d1,(a1)
Fill56VDP:
	move.l	d1,(a1)
Fill52VDP:
	move.l	d1,(a1)
Fill48VDP:
	move.l	d1,(a1)
Fill44VDP:
	move.l	d1,(a1)
Fill40VDP:
	move.l	d1,(a1)
Fill36VDP:
	move.l	d1,(a1)
Fill32VDP:
	move.l	d1,(a1)
Fill28VDP:
	move.l	d1,(a1)
Fill24VDP:
	move.l	d1,(a1)
Fill20VDP:
	move.l	d1,(a1)
Fill16VDP:
	move.l	d1,(a1)
Fill12VDP:
	move.l	d1,(a1)
Fill8VDP:
	move.l	d1,(a1)
Fill4VDP:
	move.l	d1,(a1)
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
; Mass copy (VDP)
; -------------------------------------------------------------------------
; PARAMETERS:
;	a1.l - Pointer to source data
;	a2.l - VDP control port
; -------------------------------------------------------------------------

Copy128VDP:
	move.l	(a1)+,(a2)
Copy124VDP:
	move.l	(a1)+,(a2)
Copy120VDP:
	move.l	(a1)+,(a2)
Copy116VDP:
	move.l	(a1)+,(a2)
Copy112VDP:
	move.l	(a1)+,(a2)
Copy108VDP:
	move.l	(a1)+,(a2)
Copy104VDP:
	move.l	(a1)+,(a2)
Copy100VDP:
	move.l	(a1)+,(a2)
Copy96VDP:
	move.l	(a1)+,(a2)
Copy92VDP:
	move.l	(a1)+,(a2)
Copy88VDP:
	move.l	(a1)+,(a2)
Copy84VDP:
	move.l	(a1)+,(a2)
Copy80VDP:
	move.l	(a1)+,(a2)
Copy76VDP:
	move.l	(a1)+,(a2)
Copy72VDP:
	move.l	(a1)+,(a2)
Copy68VDP:
	move.l	(a1)+,(a2)
Copy64VDP:
	move.l	(a1)+,(a2)
Copy60VDP:
	move.l	(a1)+,(a2)
Copy56VDP:
	move.l	(a1)+,(a2)
Copy52VDP:
	move.l	(a1)+,(a2)
Copy48VDP:
	move.l	(a1)+,(a2)
Copy44VDP:
	move.l	(a1)+,(a2)
Copy40VDP:
	move.l	(a1)+,(a2)
Copy36VDP:
	move.l	(a1)+,(a2)
Copy32VDP:
	move.l	(a1)+,(a2)
Copy28VDP:
	move.l	(a1)+,(a2)
Copy24VDP:
	move.l	(a1)+,(a2)
Copy20VDP:
	move.l	(a1)+,(a2)
Copy16VDP:
	move.l	(a1)+,(a2)
Copy12VDP:
	move.l	(a1)+,(a2)
Copy8VDP:
	move.l	(a1)+,(a2)
Copy4VDP:
	move.l	(a1)+,(a2)
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
; Set all buttons
; -------------------------------------------------------------------------

SetAllButtons:
	move.w	#$FF00,ctrlData
	rts

; -------------------------------------------------------------------------
; Find free object slot
; -------------------------------------------------------------------------
; RETURNS:
;	eq/ne - Found/Not found
;	a1.l  - Found object slot
; -------------------------------------------------------------------------

FindObjSlot:
	lea	objects.w,a1			; Object slots
	move.w	#OBJCOUNT-1,d0			; Number of slots to check
	
.Find:
	tst.w	(a1)				; Is this slot occupied?
	beq.s	.End				; If not, exit
	lea	oSize(a1),a1			; Next slot
	dbf	d0,.Find			; Loop until finished

.End:
	rts

; -------------------------------------------------------------------------
; Check if any objects are loaded
; -------------------------------------------------------------------------
; RETURNS:
;	eq/ne - No objects/Objects found
; -------------------------------------------------------------------------

CheckObjLoaded:
	lea	objects.w,a1			; Object slots
	move.w	#OBJCOUNT-1,d0			; Number of slots to check
	
.Check:
	tst.w	(a1)				; Is this slot occupied?
	bne.s	.End				; If so, exit
	lea	oSize(a1),a1			; Next slot
	dbf	d0,.Check			; Loop until finished

.End:
	rts
	
; -------------------------------------------------------------------------
; Update objects
; -------------------------------------------------------------------------

UpdateObjects:
	lea	objects.w,a0			; Run objects
	bsr.s	RunObjects
	bsr.w	DrawObjects			; Draw objects
	rts
	
; -------------------------------------------------------------------------
; Run objects
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to object pool
; -------------------------------------------------------------------------

RunObjects:
	moveq	#OBJCOUNT-1,d7			; Number of slots
	
.Run:
	move.w	(a0),d0				; Get object ID
	beq.s	.NextObject			; If there's no object in this slot, branch
	
	movem.l	d7-a0,-(sp)			; Run object
	bsr.s	RunObject
	movem.l	(sp)+,d7-a0
	
.NextObject:
	lea	oSize(a0),a0			; Next object
	dbf	d7,.Run				; Loop until all objects are run
	rts
	
; -------------------------------------------------------------------------
; Run object
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Object ID
;	a0.l - Pointer to object slot
; -------------------------------------------------------------------------

RunObject:
	add.w	d0,d0				; Run object
	add.w	d0,d0
	movea.l	ObjIndex-4(pc,d0.w),a1
	jsr	(a1)
	
	btst	#4,oFlags(a0)			; Is this object marked for deletion?
	beq.s	.End				; If not, branch
	bsr.w	ClearObject			; If so, clear object slot
	
.End:
	rts
	
; -------------------------------------------------------------------------
; Object index
; -------------------------------------------------------------------------

ObjIndex:
	dc.l	ObjExit				; Exit option
	dc.l	ObjOpening			; Opening FMV option
	dc.l	ObjGoodEnd			; Good ending FMV option
	dc.l	ObjBadEnd			; Bad ending FMV option
	dc.l	ObjPencilTest			; Pencil test FMV option
	dc.l	ObjNull				; Blank
	dc.l	ObjNull				; Blank
	dc.l	ObjNull				; Blank
	dc.l	ObjNull				; Blank
	dc.l	ObjNull				; Blank
	dc.l	ObjNull				; Blank
	dc.l	ObjNull				; Blank
	dc.l	ObjNull				; Blank
	dc.l	ObjNull				; Blank
	dc.l	ObjNull				; Blank
	
; -------------------------------------------------------------------------
; Null object
; -------------------------------------------------------------------------

ObjNull:
	rts
	
; -------------------------------------------------------------------------
; Draw objects
; -------------------------------------------------------------------------

DrawObjects:
	lea	sprites.w,a1			; Clear first sprite slot
	clr.l	(a1)+
	clr.l	(a1)+
	
	lea	objects.w,a0			; Objects
	lea	sprites.w,a1			; Sprite table
	moveq	#0,d5				; Reset link value
	moveq	#OBJCOUNT-1,d7			; Number of object slots
	
.DrawLoop:
	tst.w	oID(a0)				; Is this object slot occupied?
	beq.w	.NextObject			; If not, branch
	
	movea.l	oMap(a0),a2			; Get mappings
	bsr.w	AnimateObject			; Animation sprite
	
	move.w	oAnimFrame(a0),d0		; Get sprite data
	add.w	d0,d0
	add.w	d0,d0
	adda.w	2+2(a2,d0.w),a2
	
	move.w	(a2)+,d6			; Get number of sprite pieces
	moveq	#$D,d3				; Unknown
	
.DrawPieces:
	moveq	#0,d4				; Reset flip flags
	
	move.w	oX(a0),d0			; Get object X position
	btst	#7,oFlags(a0)			; Is the X flip flag set?
	beq.s	.NoXFlip			; If not, branch
	sub.w	6(a2),d0			; Subtract flipped X offset
	bset	#$B,d4				; Set sprite X flip flag
	bra.s	.SetX

.NoXFlip:
	sub.w	4(a2),d0			; Subtract X offset

.SetX:
	addi.w	#128,d0				; Add origin offset
	move.w	d0,6(a1)			; Set X position in sprite table
	
	move.w	oY(a0),d0			; Get object Y position
	btst	#6,oFlags(a0)			; Is the Y flip flag set?
	beq.s	.NoYFlip			; If not, branch
	sub.w	$A(a2),d0			; Subtract flipped Y offset
	bset	#$C,d4				; Set sprite Y flip flag
	bra.s	.SetY

.NoYFlip:
	sub.w	8(a2),d0			; Subtract Y offset

.SetY:
	addi.w	#128,d0				; Add origin offset
	move.w	d0,0(a1)			; Set Y position in sprite table
	
	addq.w	#1,d5				; Increment link value
	move.w	d5,d0				; Combine with sprite size
	or.w	0(a2),d0
	move.w	d0,2(a1)			; Store in sprite table
	
	move.w	oTile(a0),d0			; Get base tile ID
	btst	#5,oFlags(a0)			; Is the force priority flag set?
	beq.s	.SetTile			; If not, branch
	bset	#$F,d0				; If so, force priority
	
.SetTile:
	add.w	2(a2),d0			; Add sprite tile ID offset
	eor.w	d4,d0				; Apply flip flags
	move.w	d0,4(a1)			; Store in sprite table
	
	addq.l	#8,a1				; Next sprite table entry
	adda.w	#$C,a2				; Next sprite piece
	dbf	d6,.DrawPieces			; Loop until all sprite pieces are drawn
	
.NextObject:
	lea	oSize(a0),a0			; Next object
	dbf	d7,.DrawLoop			; Loop until all objects are drawn
	
	tst.w	d5				; Were any objects drawn at all?
	beq.s	.End				; If not, branch
	move.b	#0,-5(a1)			; If so, set the termination link value
	
.End:
	rts

; -------------------------------------------------------------------------
; Animate object
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to object slot
; -------------------------------------------------------------------------

AnimateObject:
	subq.w	#1,oAnimTime(a0)		; Decrement animation timer
	bhi.s	.End				; If it hasn't run out, branch
	
	move.w	oAnimFrame(a0),d0		; Increment animation frame
	addq.w	#1,d0
	cmp.w	(a2),d0				; Have we reached the end?
	bcs.s	.Update				; If not, branch
	moveq	#0,d0				; If so, loop back to the start
	
.Update:
	move.w	d0,oAnimFrame(a0)		; Set new animation frame
	add.w	d0,d0
	add.w	d0,d0
	move.w	2(a2,d0.w),oAnimTime(a0)	; Reset animation timer
	
.End:
	rts

; -------------------------------------------------------------------------
; Clear object slot
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to object slot
; -------------------------------------------------------------------------

ClearObject:
	movea.l	a0,a1				; Clear object slot
	moveq	#0,d1
	bra.w	Fill64

; -------------------------------------------------------------------------
; Initialize objects
; -------------------------------------------------------------------------

InitObjects:
	lea	objects.w,a1			; Objects
	moveq	#0,d1				; Fill with zero
	moveq	#OBJCOUNT-1,d0			; Number of object slots
	
.ClearLoop:
	jsr	Fill64(pc)			; Clear object slot
	dbf	d0,.ClearLoop			; Loop until all objects are cleared
	rts

; -------------------------------------------------------------------------
; Spawn menu options
; -------------------------------------------------------------------------

SpawnMenuOptions:
	lea	objects.w,a0			; Objects
	moveq	#1,d0				; Initial object ID
	moveq	#0,d1				; Y offset
	moveq	#5-1,d7				; Number of options
	
.SpawnLoop:
	move.w	d0,oID(a0)			; Set object ID
	
	move.w	#192,oX(a0)			; Set position
	move.w	#112,oY(a0)
	add.w	d1,oY(a0)
	
	move.w	#$461,oTile(a0)			; Set base tile ID
	
	move.w	d0,d6				; Set mappings
	add.w	d6,d6
	add.w	d6,d6
	lea	.Mappings(pc,d6.w),a3
	move.l	(a3),oMap(a0)
	
	move.w	#0,oAnimFrame(a0)		; Reset animation
	
	lea	oSize(a0),a0			; Next object slot
	addq.w	#1,d0				; Next object ID
	addi.w	#16,d1				; Move down 16 pixels
	dbf	d7,.SpawnLoop			; Loop until all options are spawned
	
	move.w	#0,menuSelection.w		; Reset menu selection
	rts

; -------------------------------------------------------------------------

.Mappings:
	dc.l	0
	dc.l	MapSpr_Exit			; Exit option mappings
	dc.l	MapSpr_Opening			; Opening FMV option mappings
	dc.l	MapSpr_GoodEnd			; Good ending FMV option mappings
	dc.l	MapSpr_BadEnd			; Bad ending FMV option mappings
	dc.l	MapSpr_PencilTest		; Pencil test FMV option mappings

; -------------------------------------------------------------------------
; Exit option object
; -------------------------------------------------------------------------

ObjExit:
	cmpi.w	#0,menuSelection.w		; Is this option selected?
	bne.s	.NotSelected			; If not, branch
	move.w	#$2461,oTile(a0)		; Highlight option
	bra.s	.End
	
.NotSelected:
	move.w	#$461,oTile(a0)			; Unhighlight option
	
.End:
	rts
	
; -------------------------------------------------------------------------
; Opening FMV option object
; -------------------------------------------------------------------------

ObjOpening:
	cmpi.w	#1,menuSelection.w		; Is this option selected?
	bne.s	.NotSelected			; If not, branch
	move.w	#$2461,oTile(a0)		; Highlight option
	bra.s	.End
	
.NotSelected:
	move.w	#$461,oTile(a0)			; Unhighlight option
	
.End:
	rts
	
; -------------------------------------------------------------------------
; Good ending FMV option object
; -------------------------------------------------------------------------

ObjGoodEnd:
	cmpi.w	#2,menuSelection.w		; Is this option selected?
	bne.s	.NotSelected			; If not, branch
	move.w	#$2461,oTile(a0)		; Highlight option
	bra.s	.End
	
.NotSelected:
	move.w	#$461,oTile(a0)			; Unhighlight option
	
.End:
	rts
	
; -------------------------------------------------------------------------
; Bad ending FMV option object
; -------------------------------------------------------------------------

ObjBadEnd:
	cmpi.w	#3,menuSelection.w		; Is this option selected?
	bne.s	.NotSelected			; If not, branch
	move.w	#$2461,oTile(a0)		; Highlight option
	bra.s	.End
	
.NotSelected:
	move.w	#$461,oTile(a0)			; Unhighlight option
	
.End:
	rts
	
; -------------------------------------------------------------------------
; Pencil test FMV option object
; -------------------------------------------------------------------------

ObjPencilTest:
	cmpi.w	#4,menuSelection.w		; Is this option selected?
	bne.s	.NotSelected			; If not, branch
	move.w	#$2461,oTile(a0)		; Highlight option
	bra.s	.End
	
.NotSelected:
	move.w	#$461,oTile(a0)			; Unhighlight option
	
.End:
	rts

; -------------------------------------------------------------------------
; Load art
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - Art IDs (each byte is an ID)
; -------------------------------------------------------------------------

LoadArt:
	lea	VDPCTRL,a5			; VDP control port
	moveq	#4-1,d2				; Number of IDs in the queue

.Loop:
	moveq	#0,d1				; Get art ID
	move.b	d0,d1
	beq.s	.NextArt			; If it's blank, branch

	lsl.w	#3,d1				; Load art
	lea	.Art(pc),a0
	move.l	-8(a0,d1.w),(a5)
	movea.l	-4(a0,d1.w),a0
	jsr	NemDec(pc)

.NextArt:
	ror.l	#8,d0				; Next art ID
	dbf	d2,.Loop			; Loop until art is loaded
	rts

; -------------------------------------------------------------------------

.Art:
	VDPCMD	dc.l,$8C20,VRAM,WRITE		; Menu text
	dc.l	Art_VisModeText

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

	bra.s	NemBCT_Loop

; -------------------------------------------------------------------------
; Fade the screen from black
; -------------------------------------------------------------------------

FadeFromBlack:
	move.w	#$3F,palFadeInfo.w		; Set palette fade start and length

	moveq	#0,d0				; Get starting palette fill location
	lea	palette.w,a0
	move.b	palFadeStart.w,d0
	adda.w	d0,a0
	moveq	#0,d1				; Get palette fill value (black)
	move.b	palFadeLen.w,d0			; Get palette fill length

.Clear:
	move.w	d1,(a0)+
	dbf	d0,.Clear			; Fill until finished

	move.w	#(7*3),d4			; Prepare to do fading

.Fade:
	move.b	#$A,vsyncFlag.w			; VSync
	bsr.w	VSync
	bsr.s	FadeColorsFromBlack		; Fade colors once
	dbf	d4,.Fade			; Loop until fading is done

	rts

; -------------------------------------------------------------------------

FadeColorsFromBlack:
	moveq	#0,d0				; Get starting palette fade locations
	lea	palette.w,a0
	lea	fadePalette.w,a1
	move.b	palFadeStart.w,d0
	adda.w	d0,a0
	adda.w	d0,a1
	move.b	palFadeLen.w,d0			; Get palette fade length

.Loop:
	bsr.s	FadeColorFromBlack		; Fade a color
	dbf	d0,.Loop			; Loop until finished

	bra.s	.End				; Skip water fade update

	moveq	#0,d0				; Get starting palette fade locations for water
	lea	waterPalette.w,a0
	lea	waterFadePal.w,a1
	move.b	palFadeStart.w,d0
	adda.w	d0,a0
	adda.w	d0,a1
	move.b	palFadeLen.w,d0			; Get palette fade length

.LoopWater:
	bsr.s	FadeColorFromBlack		; Fade a color
	dbf	d0,.LoopWater			; Loop until finished

.End:
	rts

; -------------------------------------------------------------------------

FadeColorFromBlack:
	move.w	(a1)+,d2			; Get target color
	move.w	(a0),d3				; Get current color
	cmp.w	d2,d3				; Are they the same?
	beq.s	.Skip				; If so, branch

.Blue:
	move.w	d3,d1				; Fade blue
	addi.w	#$200,d1
	cmp.w	d2,d1				; Is the blue component done?
	bhi.s	.Green				; If so, start fading green
	move.w	d1,(a0)+			; Update color
	rts

.Green:
	move.w	d3,d1				; Fade green
	addi.w	#$20,d1
	cmp.w	d2,d1				; Is the green component done?
	bhi.s	.Red				; If so, start fading red
	move.w	d1,(a0)+			; Update color
	rts

.Red:
	addq.w	#2,(a0)+			; Fade red
	rts


.Skip:
	addq.w	#2,a0				; Skip over this color
	rts

; -------------------------------------------------------------------------
; Fade the screen to black
; -------------------------------------------------------------------------

FadeToBlack:
	move.w	#$3F,palFadeInfo.w		; Set palette fade start and length

	move.w	#(7*3),d4			; Prepare to do fading

.Fade:
	move.b	#$A,vsyncFlag.w			; VSync
	bsr.w	VSync
	bsr.s	FadeColorsToBlack		; Fade colors once
	dbf	d4,.Fade			; Loop until fading is done

	rts

; -------------------------------------------------------------------------

FadeColorsToBlack:
	moveq	#0,d0				; Get starting palette fade location
	lea	palette.w,a0
	move.b	palFadeStart.w,d0
	adda.w	d0,a0
	move.b	palFadeLen.w,d0			; Get palette fade length

.Loop:
	bsr.s	FadeColorToBlack		; Fade a color
	dbf	d0,.Loop			; Loop until finished

	moveq	#0,d0				; Get starting palette fade location for water
	lea	waterPalette.w,a0
	move.b	palFadeStart.w,d0
	adda.w	d0,a0
	move.b	palFadeLen.w,d0			; Get palette fade length

.LoopWater:
	bsr.s	FadeColorToBlack		; Fade a color
	dbf	d0,.LoopWater			; Loop until finished

	rts

; -------------------------------------------------------------------------

FadeColorToBlack:
	move.w	(a0),d2				; Get color
	beq.s	.Skip				; If it's already black, branch

.Red:
	move.w	d2,d1				; Get red component
	andi.w	#$E,d1				; Is it already 0?
	beq.s	.Green				; If so, check green
	subq.w	#2,(a0)+			; Fade red
	rts

.Green:
	move.w	d2,d1				; Get green component
	andi.w	#$E0,d1				; Is it already 0?
	beq.s	.Blue				; If so, check blue
	subi.w	#$20,(a0)+			; Fade green
	rts

.Blue:
	move.w	d2,d1				; Get blue component
	andi.w	#$E00,d1			; Is it already 0?
	beq.s	.Skip				; If so, we're done
	subi.w	#$200,(a0)+			; Fade blue
	rts

.Skip:
	addq.w	#2,a0				; Skip over this color
	rts

; -------------------------------------------------------------------------
; Mappings
; -------------------------------------------------------------------------

MapSpr_Exit:
	dc.w	1
	dc.w	1, .Frame-MapSpr_Exit
	
.Frame:
	dc.w	1-1
	dc.w	$D00, 0, 0, 0, 0, 0

MapSpr_Opening:
	dc.w	1
	dc.w	1, .Frame-MapSpr_Opening
	
.Frame:
	dc.w	2-1
	dc.w	$D00, 8, 0, 0, 0, 0
	dc.w	$900, $10, -$20, 0, 0, 0

MapSpr_GoodEnd:
	dc.w	1
	dc.w	1, .Frame-MapSpr_GoodEnd
	
.Frame:
	dc.w	3-1
	dc.w	$D00, $16, 0, 0, 0, 0
	dc.w	$D00, $1E, -$20, 0, 0, 0
	dc.w	$900, $26, -$40, 0, 0, 0

MapSpr_BadEnd:
	dc.w	1
	dc.w	1, .Frame-MapSpr_BadEnd
	
.Frame:
	dc.w	3-1
	dc.w	$D00, $2C, 0, 0, 0, 0
	dc.w	$D00, $20, -$20, 0, 0, 0
	dc.w	$500, $12, -$40, 0, 0, 0

MapSpr_PencilTest:
	dc.w	1
	dc.w	1, .Frame-MapSpr_PencilTest
	
.Frame:
	dc.w	3-1
	dc.w	$D00, $34, 0, 0, 0, 0
	dc.w	$D00, $3C, -$20, 0, 0, 0
	dc.w	$500, $44, -$40, 0, 0, 0

; -------------------------------------------------------------------------
; Data
; -------------------------------------------------------------------------

Art_VisModeText:
	incbin	"Visual Mode/Data/Art (Text).nem"
	even
	
Art_VisModeBG:
	incbin	"Visual Mode/Data/Art (Background).nem"
	even
	
Map_VisModeBG:
	incbin	"Visual Mode/Data/Background Mappings.bin"
	even

; -------------------------------------------------------------------------
