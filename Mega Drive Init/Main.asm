; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Mega Drive initialization
; -------------------------------------------------------------------------

	include	"_Include/Common.i"
	include	"_Include/Main CPU.i"
	include	"_Include/Main CPU Variables.i"
	include	"_Include/MMD.i"

; -------------------------------------------------------------------------
; MMD header
; -------------------------------------------------------------------------

	MMD	MMDSUBM, &
		WORKRAMFILE, $2000, &
		Start, 0, 0

; -------------------------------------------------------------------------
; Program start
; -------------------------------------------------------------------------

Start:
	lea	MAINVARS,a0			; Clear variables
	move.w	#MAINVARSSZ/4-1,d7

.ClearVars:
	move.l	#0,(a0)+
	dbf	d7,.ClearVars

	lea	VDPRegs(pc),a0			; Initialize Mega Drive hardware
	bsr.w	InitMD

	VDPCMD	move.l,$E400,VRAM,WRITE,VDPCTRL	; Reset horizontal scroll data
	move.l	#0,VDPDATA

	VDPCMD	move.l,0,CRAM,WRITE,VDPCTRL	; Clear CRAM
	lea	VDPDATA,a0
	moveq	#PALETTESZ/4-1,d7

.ClearCRAM:
	move.l	#0,(a0)
	dbf	d7,.ClearCRAM
	
	Z80RESOFF				; Set Z80 reset off
	bsr.w	StopZ80				; Stop the Z80

	lea	FMSFXDriver(pc),a0		; Load FM SFX sound driver
	lea	Z80RAM,a1
	move.w	#FMSFXDriverEnd-FMSFXDriver-1,d7

.LoadDriver:
	move.b	(a0)+,(a1)+
	dbf	d7,.LoadDriver

	Z80RESON				; Set Z80 reset on
	Z80RESOFF				; Set Z80 reset off
	bsr.w	StartZ80			; Start the Z80

	move.b	#%10010000,titleFlags		; Set title screen flags
	rts

; -------------------------------------------------------------------------
; Read player 2 controller data
; -------------------------------------------------------------------------

ReadController:
	lea	ctrlData,a0			; Controller data buffer
	lea	IODATA2,a1			; Controller port 2

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

ctrlData:					; Controller data
ctrlPress:
	dc.b	0				; Controller pressed buttons data
ctrlTap:
	dc.b	0				; Controller tapped buttons data

; -------------------------------------------------------------------------
; VDP register data
; -------------------------------------------------------------------------

VDPRegs:
	dc.b	%00000100			; No H-INT
	dc.b	%00110100			; V-INT, DMA, mode 5
	dc.b	$C000/$400			; Plane A location
	dc.b	0				; Window location
	dc.b	$C000/$2000			; Plane B location
	dc.b	$E000/$200			; Sprite table location
	dc.b	0				; Reserved
	dc.b	0				; BG color line 0 color 0
	dc.b	0				; Reserved
	dc.b	0				; Reserved
	dc.b	0				; H-INT counter 0
	dc.b	%00000000			; Scroll by screen
	dc.b	%10000001			; H40
	dc.b	$E400/$400			; Horizontal scroll table lcation
	dc.b	0				; Reserved
	dc.b	2				; Auto increment by 2
	dc.b	%00000001			; 64x32 tile plane size
	dc.b	0				; Window horizontal position 0
	dc.b	0				; Window vertical position 0
VDPRegsEnd:
	even

; -------------------------------------------------------------------------
; FM SFX Sound driver
; -------------------------------------------------------------------------

FMSFXDriver:
	incbin	"_Built/Misc/FM Sound Driver.bin"
FMSFXDriverEnd:
	even

; -------------------------------------------------------------------------
; Saved status register
; -------------------------------------------------------------------------

savedSR:
	dc.w	0

; -------------------------------------------------------------------------
; Initialize the Mega Drive hardware
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to VDP register data table
; -------------------------------------------------------------------------

InitMD:
	move.w	#$8000,d0			; Set up VDP registers
	moveq	#VDPRegsEnd-VDPRegs-1,d7

.SetupVDPRegs:
	move.b	(a0)+,d0
	move.w	d0,VDPCTRL
	addi.w	#$100,d0
	dbf	d7,.SetupVDPRegs

	moveq	#$40,d0				; Set up controller ports
	move.b	d0,IOCTRL1
	move.b	d0,IOCTRL2
	move.b	d0,IOCTRL3
	move.b	#$C0,IODATA1

	bsr.w	StopZ80				; Stop the Z80

	VDPCMD	move.l,0,VRAM,WRITE,VDPCTRL	; Clear VRAM
	lea	VDPDATA,a0
	moveq	#0,d0
	move.w	#$10000/16-1,d7

.ClearVRAM:
	rept	16/4
		move.l	d0,(a0)
	endr
	dbf	d7,.ClearVRAM

	VDPCMD	move.l,0,VSRAM,WRITE,VDPCTRL	; Reset vertical scroll data
	move.l	#0,VDPDATA

	bsr.w	StartZ80			; Start the Z80
	move.w	#$8134,ipxVDPReg1		; Reset IPX VDP register 1 cache
	rts

; -------------------------------------------------------------------------
; Stop the Z80
; -------------------------------------------------------------------------

StopZ80:
	move	sr,savedSR			; Save status register
	move	#$2700,sr			; Disable interrupts
	Z80STOP					; Stop the Z80
	rts

; -------------------------------------------------------------------------
; Start the Z80
; -------------------------------------------------------------------------

StartZ80:
	Z80START				; Start the Z80
	move	savedSR,sr			; Restore status register
	rts

; -------------------------------------------------------------------------
