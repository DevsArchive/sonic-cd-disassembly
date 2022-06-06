; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Sound test easter egg
; -------------------------------------------------------------------------

	include	"_Include/Common.i"
	include	"_Include/Main CPU.i"
	include	"_Include/Main CPU Variables.i"
	include	"_Include/MMD.i"
	include	"Sound Test/_Variables.i"

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
	lea	Art_EasterEgg(pc),a0
	bsr.w	NemDec

	lea	Map_EasterEgg(pc),a1		; Draw tilemap
	VDPCMD	move.l,$E000,VRAM,WRITE,d0
	moveq	#$28-1,d1
	moveq	#$1C-1,d2
	bsr.w	DrawTilemapH64

	lea	Pal_EasterEgg(pc),a0		; Load palette
	lea	palette.w,a1
	moveq	#(Pal_EasterEgg_End-Pal_EasterEgg)/4-1,d7

.LoadPal:
	move.l	(a0)+,(a1)+
	dbf	d7,.LoadPal
	
	bset	#1,ipxVSync			; Update CRAM
	bsr.w	PrepFadeFromWhite		; Prepare to fade from white
	bsr.w	VSync				; VSync
	bsr.w	FadeFromWhite			; Fade from white

.Loop:
	bsr.w	VSync				; VSync
	btst	#7,ctrlHold			; Has the start button been pressed?
	beq.w	.Loop				; If not, loop

	bsr.w	FadeToBlack			; Fade to black
	rts

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

Pal_EasterEgg:
	if EASTEREGG=0
		incbin	"Sound Test/Easter Egg/Data/Fun Is Infinite Palette.bin"
	elseif EASTEREGG=1
		incbin	"Sound Test/Easter Egg/Data/M.C. Sonic Palette.bin"
	elseif EASTEREGG=2
		incbin	"Sound Test/Easter Egg/Data/Tails Palette.bin"
	elseif EASTEREGG=3
		incbin	"Sound Test/Easter Egg/Data/Batman Palette.bin"
	elseif EASTEREGG=4
		incbin	"Sound Test/Easter Egg/Data/Cute Sonic Palette.bin"
	endif
Pal_EasterEgg_End:
	even

Art_EasterEgg:
	if EASTEREGG=0
		incbin	"Sound Test/Easter Egg/Data/Fun Is Infinite Art.nem"
	elseif EASTEREGG=1
		incbin	"Sound Test/Easter Egg/Data/M.C. Sonic Art.nem"
	elseif EASTEREGG=2
		incbin	"Sound Test/Easter Egg/Data/Tails Art.nem"
	elseif EASTEREGG=3
		incbin	"Sound Test/Easter Egg/Data/Batman Art.nem"
	elseif EASTEREGG=4
		incbin	"Sound Test/Easter Egg/Data/Cute Sonic Art.nem"
	endif
	even

Map_EasterEgg:
	if EASTEREGG=0
		incbin	"Sound Test/Easter Egg/Data/Fun Is Infinite Tilemap.bin"
	elseif EASTEREGG=1
		incbin	"Sound Test/Easter Egg/Data/M.C. Sonic Tilemap.bin"
	elseif EASTEREGG=2
		incbin	"Sound Test/Easter Egg/Data/Tails Tilemap.bin"
	elseif EASTEREGG=3
		incbin	"Sound Test/Easter Egg/Data/Batman Tilemap.bin"
	elseif EASTEREGG=4
		incbin	"Sound Test/Easter Egg/Data/Cute Sonic Tilemap.bin"
	endif
	even

; -------------------------------------------------------------------------

	include	"Sound Test/Functions.asm"

; -------------------------------------------------------------------------

	dcb.b	$FF6000-*, 0
End:

; -------------------------------------------------------------------------
