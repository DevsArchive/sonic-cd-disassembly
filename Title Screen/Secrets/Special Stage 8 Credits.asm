; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Special stage 8 credits
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

	lea	Text_Staff(pc),a0		; Draw header text
	move.w	#0,d0
	bsr.w	DrawText
	lea	Text_CreditsLeft(pc),a0		; Draw credits text (left)
	move.w	#$2000,d0
	bsr.w	DrawText
	lea	Text_CreditsRight(pc),a0	; Draw credits text (right)
	move.w	#$6000,d0
	bsr.w	DrawText

	lea	Pal_SelScreen(pc),a0		; Load palette
	lea	palette.w,a1
	moveq	#(Pal_SelScreen_End-Pal_SelScreen)/4-1,d7

.LoadPal:
	move.l	(a0)+,(a1)+
	dbf	d7,.LoadPal
	
	bset	#1,ipxVSync			; Update CRAM
	bsr.w	PrepFadeFromWhite		; Prepare to fade from white
	bsr.w	VSync				; VSync
	bsr.w	FadeFromWhite			; Fade from white

; -------------------------------------------------------------------------

MainLoop:
	bsr.w	VSync				; VSync

	btst	#7,ctrlHold			; Has the start button been pressed?
	beq.w	MainLoop			; If not, branch

	bsr.w	FadeToBlack			; Fade to black
	moveq	#1,d0
	rts

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

Text_Staff:
	TEXTSTART
	TEXTPTR	TextDat_Staff, 13, 1
	TEXTEND

Text_CreditsLeft:
	TEXTSTART
	TEXTPTR	TextDat_CredLeft1, 3, 4
	TEXTPTR	TextDat_CredLeft2, 3, 7
	TEXTPTR	TextDat_CredLeft3, 3, 10
	TEXTPTR	TextDat_CredLeft4, 3, 13
	TEXTPTR	TextDat_CredLeft5, 3, 16
	TEXTPTR	TextDat_CredLeft6, 3, 19
	TEXTEND

Text_CreditsRight:
	TEXTSTART
	TEXTPTR	TextDat_CredRight1, 18, 4
	TEXTPTR	TextDat_CredRight2, 18, 7
	TEXTPTR	TextDat_CredRight3, 18, 10
	TEXTPTR	TextDat_CredRight4, 18, 13
	TEXTPTR	TextDat_CredRight5, 18, 16
	TEXTPTR	TextDat_CredRight6, 18, 19
	TEXTPTR	TextDat_CredRight7, 18, 22
	TEXTPTR	TextDat_CredRight8, 18, 25
	TEXTEND

; -------------------------------------------------------------------------

TextDat_Staff:
	TEXTSTR	"STAFF"
	even

TextDat_CredLeft1:
	TEXTSTR	"PLAN"
	even

TextDat_CredLeft2:
	TEXTSTR	"SPRITE DESIGN"
	even

TextDat_CredLeft3:
	TEXTSTR	"SCROLL DESIGN"
	even

TextDat_CredLeft4:
	TEXTSTR	"SOUND"
	even

TextDat_CredLeft5:
	TEXTSTR	"PROGRAM"
	even

TextDat_CredLeft6:
	TEXTSTR	"SPECIAL THANKS"
	even

TextDat_CredRight1:
	TEXTSTR	"HIROAKI CHINO"
	even

TextDat_CredRight2:
	TEXTSTR	"KAZUYUKI HOSHINO"
	even

TextDat_CredRight3:
	TEXTSTR	"YASUSHI YAMAGUCHI"
	even

TextDat_CredRight4:
	TEXTSTR	"MASAFUMI OGATA"
	even

TextDat_CredRight5:
	TEXTSTR	"KEIICHI YAMAMOTO"
	even

TextDat_CredRight6:
	TEXTSTR	"3PEI"
	even

TextDat_CredRight7:
	TEXTSTR	"MAJIN  ,  100SHIKI"
	even

TextDat_CredRight8:
	TEXTSTR	"SYUJI TAKAHASHI"
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
