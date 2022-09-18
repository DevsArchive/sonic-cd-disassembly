; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Stage selection menu
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
		WORKRAMFILE, End-Start, &
		Start, 0, 0

; -------------------------------------------------------------------------
; Program start
; -------------------------------------------------------------------------

Start:
	move.l	#VInterrupt,_LEVEL6+2.w		; Set V-INT address

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

	lea	Text_StageSelect(pc),a0		; Draw header text
	move.w	#0,d0
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
	addq.w	#1,selectDelay			; Increment delay counter

	lea	selectID(pc),a1			; Selection
	moveq	#0,d6
	moveq	#(Text_SelectionsEnd-Text_Selections)/$E-1,d7

	move.w	selectDelay,d0			; Should we update the selection?
	andi.w	#7,d0
	bne.s	.DrawText			; If not, branch

	btst	#0,ctrlHold			; Is up being pressed?
	beq.s	.NoUp				; If not, branch
	bsr.w	DecValueW			; Decrease selection

.NoUp:
	btst	#1,ctrlHold			; Is down being pressed?
	beq.s	.DrawText			; If not, branch
	bsr.w	IncValueW			; Increase selection

.DrawText:
	lea	Text_Clear(pc),a0		; Clear selection text
	move.w	#0,d0
	bsr.w	DrawText
	
	move.w	(a1),d0				; Draw selection text
	mulu.w	#$E,d0
	lea	Text_Selections(pc),a0
	lea	(a0,d0.w),a0
	move.w	#$6000,d0
	bsr.w	DrawText

	bsr.w	VSync				; VSync

	move.b	ctrlHold,d0			; Has the start, A, B, or C button been pressed?
	andi.b	#%11110000,d0
	beq.w	MainLoop			; If not, branch

	bsr.w	FadeToBlack			; Fade to black
	move.w	selectID,d0			; Return selection ID
	rts

; -------------------------------------------------------------------------
; Selection data
; -------------------------------------------------------------------------

selectDelay:					; Selection delay
	dc.w	0
selectID:					; Selection ID
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

Text_Clear:
	TEXTSTART
	TEXTPTR	TextDat_Clear, 14, 13
	TEXTEND

Text_StageSelect:
	TEXTSTART
	TEXTPTR	TextDat_StageSelect, 14, 9
	TEXTEND

Text_Selections:
	TEXTSTART
	TEXTPTR	TextDat_R11A, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R11B, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R11C, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R11D, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R12A, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R12B, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R12C, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R12D, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_Warp, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_Opening, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_CominSoon, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R31A, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R31B, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R31C, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R31D, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R32A, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R32B, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R32C, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R32D, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R33C, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R33D, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R13C, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R13D, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R41A, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R41B, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R41C, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R41D, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R42A, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R42B, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R42C, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R42D, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R43C, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R43D, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R51A, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R51B, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R51C, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R51D, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R52A, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R52B, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R52C, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R52D, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R53C, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R53D, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R61A, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R61B, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R61C, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R61D, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R62A, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R62B, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R62C, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R62D, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R63C, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R63D, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R71A, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R71B, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R71C, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R71D, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R72A, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R72B, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R72C, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R72D, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R73C, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R73D, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R81A, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R81B, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R81C, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R81D, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R82A, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R82B, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R82C, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R82D, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R83C, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_R83D, 14, 13
	TEXTEND
	
	TEXTSTART
	TEXTPTR	TextDat_SS1Demo, 14, 13
	TEXTEND
Text_SelectionsEnd:

; -------------------------------------------------------------------------

TextDat_R11A:
	TEXTSTR	"1-1-A"

TextDat_R11B:
	TEXTSTR	"1-1-B"

TextDat_R11C:
	TEXTSTR	"1-1-C"

TextDat_R11D:
	TEXTSTR	"1-1-D"

TextDat_R12A:
	TEXTSTR	"1-2-A"

TextDat_R12B:
	TEXTSTR	"1-2-B"

TextDat_R12C:
	TEXTSTR	"1-2-C"

TextDat_R12D:
	TEXTSTR	"1-2-D"

TextDat_Warp:
	TEXTSTR	"WARP"

TextDat_Opening:
	TEXTSTR	"OPENING"

TextDat_CominSoon:
	TEXTSTR	"COMMING"

TextDat_R31A:
	TEXTSTR	"3-1-A"

TextDat_R31B:
	TEXTSTR	"3-1-B"

TextDat_R31C:
	TEXTSTR	"3-1-C"

TextDat_R31D:
	TEXTSTR	"3-1-D"

TextDat_R32A:
	TEXTSTR	"3-2-A"

TextDat_R32B:
	TEXTSTR	"3-2-B"

TextDat_R32C:
	TEXTSTR	"3-2-C"

TextDat_R32D:
	TEXTSTR	"3-2-D"

TextDat_R33C:
	TEXTSTR	"3-3-C"

TextDat_R33D:
	TEXTSTR	"3-3-D"

TextDat_R13C:
	TEXTSTR	"1-3-C"

TextDat_R13D:
	TEXTSTR	"1-3-D"

TextDat_R41A:
	TEXTSTR	"4-1-A"

TextDat_R41B:
	TEXTSTR	"4-1-B"

TextDat_R41C:
	TEXTSTR	"4-1-C"

TextDat_R41D:
	TEXTSTR	"4-1-D"

TextDat_R42A:
	TEXTSTR	"4-2-A"

TextDat_R42B:
	TEXTSTR	"4-2-B"

TextDat_R42C:
	TEXTSTR	"4-2-C"

TextDat_R42D:
	TEXTSTR	"4-2-D"

TextDat_R43C:
	TEXTSTR	"4-3-C"

TextDat_R43D:
	TEXTSTR	"4-3-D"

TextDat_R51A:
	TEXTSTR	"5-1-A"

TextDat_R51B:
	TEXTSTR	"5-1-B"

TextDat_R51C:
	TEXTSTR	"5-1-C"

TextDat_R51D:
	TEXTSTR	"5-1-D"

TextDat_R52A:
	TEXTSTR	"5-2-A"

TextDat_R52B:
	TEXTSTR	"5-2-B"

TextDat_R52C:
	TEXTSTR	"5-2-C"

TextDat_R52D:
	TEXTSTR	"5-2-D"

TextDat_R53C:
	TEXTSTR	"5-3-C"

TextDat_R53D:
	TEXTSTR	"5-3-D"

TextDat_R61A:
	TEXTSTR	"6-1-A"

TextDat_R61B:
	TEXTSTR	"6-1-B"

TextDat_R61C:
	TEXTSTR	"6-1-C"

TextDat_R61D:
	TEXTSTR	"6-1-D"

TextDat_R62A:
	TEXTSTR	"6-2-A"

TextDat_R62B:
	TEXTSTR	"6-2-B"

TextDat_R62C:
	TEXTSTR	"6-2-C"

TextDat_R62D:
	TEXTSTR	"6-2-D"

TextDat_R63C:
	TEXTSTR	"6-3-C"

TextDat_R63D:
	TEXTSTR	"6-3-D"

TextDat_R71A:
	TEXTSTR	"7-1-A"

TextDat_R71B:
	TEXTSTR	"7-1-B"

TextDat_R71C:
	TEXTSTR	"7-1-C"

TextDat_R71D:
	TEXTSTR	"7-1-D"

TextDat_R72A:
	TEXTSTR	"7-2-A"

TextDat_R72B:
	TEXTSTR	"7-2-B"

TextDat_R72C:
	TEXTSTR	"7-2-C"

TextDat_R72D:
	TEXTSTR	"7-2-D"

TextDat_R73C:
	TEXTSTR	"7-3-C"

TextDat_R73D:
	TEXTSTR	"7-3-D"

TextDat_R81A:
	TEXTSTR	"8-1-A"

TextDat_R81B:
	TEXTSTR	"8-1-B"

TextDat_R81C:
	TEXTSTR	"8-1-C"

TextDat_R81D:
	TEXTSTR	"8-1-D"

TextDat_R82A:
	TEXTSTR	"8-2-A"

TextDat_R82B:
	TEXTSTR	"8-2-B"

TextDat_R82C:
	TEXTSTR	"8-2-C"

TextDat_R82D:
	TEXTSTR	"8-2-D"

TextDat_R83C:
	TEXTSTR	"8-3-C"

TextDat_R83D:
	TEXTSTR	"8-3-D"

TextDat_SS1Demo:
	TEXTSTR	"SPEDEMO"

TextDat_Clear:
	TEXTSTR	"          "

TextDat_StageSelect:
	TEXTSTR	"STAGE SELECT"
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
End:

; -------------------------------------------------------------------------
