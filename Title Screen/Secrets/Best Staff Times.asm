; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Best staff times
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
	
	lea	VARSSTART.w,a0			; Clear variables
	move.w	#VARSLEN/4-1,d7

.ClearVars:
	move.l	#0,(a0)+
	dbf	d7,.ClearVars

	lea	VDPRegs(pc),a0			; Initialize Mega Drive hardware
	bsr.w	InitMD
	
	VDPCMD	move.l,$B400,VRAM,WRITE,VDPCTRL	; Clear horizontal scroll data
	move.l	#0,VDPDATA

	VDPCMD	move.l,$0000,VRAM,WRITE,VDPCTRL	; Load art
	lea	Art_SelScreen(pc),a0
	bsr.w	NemDec

	lea	Map_SelScreenBg(pc),a1		; Draw background tilemap
	VDPCMD	move.l,$E000,VRAM,WRITE,d0
	moveq	#$20-1,d1
	moveq	#$1C-1,d2
	bsr.w	DrawTilemapH32

	lea	Text_BestTimes(pc),a0		; Draw header text
	move.w	#0,d0
	bsr.w	DrawText
	
	lea	Text_BestTimesList(pc),a0	; Draw list of best times
	move.w	#$6000,d0
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
	btst	#1,ctrlHold			; Is down being pressed?
	beq.s	.NoDown				; If not, branch
	addq.w	#2,scrollPos			; Scroll down
	cmpi.w	#$200,scrollPos			; Are we at the bottom?
	bcs.s	.NoDown				; If not, branch
	move.w	#$200-1,scrollPos		; Cap at bottom

.NoDown:
	btst	#0,ctrlHold			; Is up being pressed?
	beq.s	.NoUp				; If not, branch
	subq.w	#2,scrollPos			; Scroll up
	bpl.s	.NoUp				; If we are not at the top, branch
	move.w	#0,scrollPos			; Cap at top
	
.NoUp:
	bsr.w	VSync				; VSync

	btst	#7,ctrlHold			; Has the start button been pressed?
	beq.s	MainLoop			; If not, branch

	bsr.w	FadeToBlack			; Fade to black
	rts

; -------------------------------------------------------------------------

scrollPos:					; Scroll position
	dc.w	0

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

Text_BestTimes:
	TEXTSTART
	TEXTPTR	TextDat_BestTimes, 3, 1
	TEXTEND
			
Text_BestTimesList:
	TEXTSTART
	TEXTPTR	TextDat_R11, 4, 4
	TEXTPTR	TextDat_R12, 4, 7
	TEXTPTR	TextDat_R13, 4, 10
	TEXTPTR	TextDat_R31, 4, 13
	TEXTPTR	TextDat_R32, 4, 16
	TEXTPTR	TextDat_R33, 4, 19
	TEXTPTR	TextDat_R41, 4, 22
	TEXTPTR	TextDat_R42, 4, 25
	TEXTPTR	TextDat_R43, 4, 28
	TEXTPTR	TextDat_R51, 4, 31
	TEXTPTR	TextDat_R52, 4, 34
	TEXTPTR	TextDat_R53, 4, 37
	TEXTPTR	TextDat_R61, 4, 40
	TEXTPTR	TextDat_R62, 4, 43
	TEXTPTR	TextDat_R63, 4, 46
	TEXTPTR	TextDat_R71, 4, 49
	TEXTPTR	TextDat_R72, 4, 52
	TEXTPTR	TextDat_R73, 4, 55
	TEXTPTR	TextDat_R81, 4, 58
	TEXTPTR	TextDat_R82, 4, 61
	TEXTPTR	TextDat_R83, 4, 64
	TEXTPTR	TextDat_SS1, 4, 67
	TEXTPTR	TextDat_SS2, 4, 70
	TEXTPTR	TextDat_SS3, 4, 73
	TEXTPTR	TextDat_SS4, 4, 76
	TEXTPTR	TextDat_SS5, 4, 79
	TEXTPTR	TextDat_SS6, 4, 82
	TEXTPTR	TextDat_SS7, 4, 85
	TEXTEND

; -------------------------------------------------------------------------

TextDat_BestTimes:
	TEXTSTR	"SONIC CD TEAM BEST OF TIME"
	even

TextDat_R11:
	TEXTSTR	"STAGE 1-1  00'24''10  CXX"
	even
	
TextDat_R12:
	TEXTSTR	"STAGE 1-2  00'21''55  TOT"
	even
	
TextDat_R13:
	TEXTSTR	"STAGE 1-3  00'21''08  ANN"
	even
	
TextDat_R31:
	TEXTSTR	"STAGE 2-1  00'49''60  TOT"
	even
	
TextDat_R32:
	TEXTSTR	"STAGE 2-2  00'47''50  TOT"
	even
	
TextDat_R33:
	TEXTSTR	"STAGE 2-3  00'14''85  3PE"
	even
	
TextDat_R41:
	TEXTSTR	"STAGE 3-1  00'41''20  3PE"
	even
	
TextDat_R42:
	TEXTSTR	"STAGE 3-2  00'54''75  3PE"
	even
	
TextDat_R43:
	TEXTSTR	"STAGE 3-3  01'01''33  KAZ"
	even
	
TextDat_R51:
	TEXTSTR	"STAGE 4-1  00'28''85  ANN"
	even
	
TextDat_R52:
	TEXTSTR	"STAGE 4-2  00'36''25  DDS"
	even
	
TextDat_R53:
	TEXTSTR	"STAGE 4-3  00'59''60  DDS"
	even
	
TextDat_R61:
	TEXTSTR	"STAGE 5-1  00'50''10  TAC"
	even
	
TextDat_R62:
	TEXTSTR	"STAGE 5-2  00'48''83  AXE"
	even
	
TextDat_R63:
	TEXTSTR	"STAGE 5-3  01'10''50  DDS"
	even
	
TextDat_R71:
	TEXTSTR	"STAGE 6-1  00'33''65  CXX"
	even
	
TextDat_R72:
	TEXTSTR	"STAGE 6-2  00'27''96  TAK"
	even
	
TextDat_R73:
	TEXTSTR	"STAGE 6-3  01'09''75  3PE"
	even
	
TextDat_R81:
	TEXTSTR	"STAGE 7-1  00'32''78  ANN"
	even
	
TextDat_R82:
	TEXTSTR	"STAGE 7-2  02'08''41  UNT"
	even
	
TextDat_R83:
	TEXTSTR	"STAGE 7-3  01'30''75  TNO"
	even
	
TextDat_SS1:
	TEXTSTR	"SPECIAL 1  00'17''00  CXX"
	even
	
TextDat_SS2:
	TEXTSTR	"SPECIAL 2  00'14''85  TOT"
	even
	
TextDat_SS3:
	TEXTSTR	"SPECIAL 3  00'16''00  CXX"
	even
	
TextDat_SS4:
	TEXTSTR	"SPECIAL 4  00'20''65  KAZ"
	even
	
TextDat_SS5:
	TEXTSTR	"SPECIAL 5  00'22''35  KAZ"
	even
	
TextDat_SS6:
	TEXTSTR	"SPECIAL 6  00'16''95  CXX"
	even
	
TextDat_SS7:
	TEXTSTR	"SPECIAL 7  00'19''20  KAZ"
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
	VDPCMD	move.l,0,VSRAM,WRITE,VDPCTRL	; Set scroll position
	move.w	scrollPos,VDPDATA

	jsr	ReadController(pc)		; Read controller
	bsr.w	StartZ80			; Start the Z80

.End:
	movem.l	(sp)+,d0-a6			; Restore registers
	rte
	
; -------------------------------------------------------------------------
; Draw a tilemap (for 32 tile wide planes)
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - VDP command
;	d1.w - Width
;	d2.w - Height
;	a1.l - Pointer to tilemap
; -------------------------------------------------------------------------

DrawTilemapH32:
	lea	VDPCTRL,a2			; VDP control port
	lea	VDPDATA,a3			; VDP data port
	move.l	#$400000,d4			; Row delta

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
; Data
; -------------------------------------------------------------------------

VDPRegs:
	dc.b	%00000100			; No H-INT
	dc.b	%00110100			; V-INT, DMA, mode 5
	dc.b	$C000/$400			; Plane A location
	dc.b	0				; Window location
	dc.b	$E000/$2000			; Plane B location
	dc.b	$B000/$200			; Sprite table location
	dc.b	0				; Reserved
	dc.b	0				; BG color line 0 color 0
	dc.b	0				; Reserved
	dc.b	0				; Reserved
	dc.b	0				; H-INT counter 0
	dc.b	%00000000			; Scroll by screen
	dc.b	%00000000			; H32
	dc.b	$B400/$400			; Horizontal scroll table lcation
	dc.b	0				; Reserved
	dc.b	2				; Auto increment by 2
	dc.b	%00110000			; 32x128 tile plane size
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
	incbin	"Title Screen/Secrets/Data/Background Mappings (H32).bin"
	even

; -------------------------------------------------------------------------

	include	"Title Screen/Secrets/Functions.asm"

; -------------------------------------------------------------------------

	dcb.b	$FF6000-*, 0

; -------------------------------------------------------------------------
