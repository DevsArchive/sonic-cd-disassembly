; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Title screen Sub CPU program
; -------------------------------------------------------------------------

	include	"_Include/Common.i"
	include	"_Include/Sub CPU.i"
	include	"Title Screen/_Common.i"

; -------------------------------------------------------------------------
; Graphics operation variable structure
; -------------------------------------------------------------------------

	rsreset
gfxCamX		rs.w	1			; Camera X
gfxCamY		rs.w	1			; Camera Y
gfxCamZ		rs.w	1			; Camera Z
gfxPitch	rs.w	1			; Pitch
gfxPitchSin	rs.w	1			; Sine of pitch
gfxPitchCos	rs.w	1			; Cosine of pitch
gfxYaw		rs.w	1			; Yaw
gfxYawSin	rs.w	1			; Sine of yaw
gfxYawCos	rs.w	1			; Cosine of yaw
gfxYawSinN	rs.w	1			; Negative sine of yaw
gfxYawCosN	rs.w	1			; Negative cosine of yaw
gfxFOV		rs.w	1			; FOV
gfxCenter	rs.w	1			; Center point
		rs.b	$16
gfxPsYsFOV	rs.l	1			; sin(pitch) * sin(yaw) * FOV
gfxPsYcFOV	rs.l	1			; sin(pitch) * cos(yaw) * FOV
		rs.b	8
gfxPcFOV	rs.l	1			; cos(pitch) * FOV
		rs.b	4
gfxYsFOV	rs.w	1			; sin(yaw) * FOV
		rs.b	2
gfxYcFOV	rs.w	1			; cos(yaw) * FOV
		rs.b	6
gfxCenterX	rs.w	1			; Center point X offset
		rs.b	2
gfxCenterY	rs.w	1			; Center point Y offset
		rs.b	2
gfxPcYs		rs.w	1			; cos(pitch) * sin(yaw)
		rs.b	2
gfxPcYc		rs.w	1			; cos(pitch) * cos(yaw)
gfxSize		rs.b	0			; Size of structure

; -------------------------------------------------------------------------
; Variables
; -------------------------------------------------------------------------

	rsset	PRGRAM+$1E000
VARSSTART	rs.b	0			; Start of variables
		rs.b	$300
gfxOpFlag	rs.b	1			; Graphics operation flag
		rs.b	$AFF
gfxVars		rs.b	gfxSize			; Graphics operation variables
		rs.b	$119E
VARSLEN		EQU	__rs-VARSSTART		; Size of variables area

p2CtrlData	EQU	GACOMCMDE		; Player 2 controller data
p2CtrlHold	EQU	p2CtrlData		; Player 2 controller held buttons data
p2CtrlTap	EQU	p2CtrlData+1		; Player 2 controller tapped buttons data

; -------------------------------------------------------------------------
; Program start
; -------------------------------------------------------------------------

	org	$10000

	move.l	#IRQ1,_LEVEL1+2.w		; Set graphics interrupt handler
	move.l	#IRQ2,_USERCALL2+2.w		; Set MD interrupt handler
	move.b	#0,GAMEMMODE.w			; Set to 2M mode

	moveq	#0,d0				; Clear communication statuses
	move.w	d0,GACOMSTAT0.w
	move.b	d0,GACOMSTAT2.w
	move.l	d0,GACOMSTAT4.w
	move.l	d0,GACOMSTAT8.w
	move.l	d0,GACOMSTATC.w

	bset	#7,GASUBFLAG.w			; Mark as started
	bclr	#1,GAIRQMASK.w			; Disable graphics interrupt
	bclr	#3,GAIRQMASK.w			; Disable timer interrupt
	move.b	#3,GACDCDEVICE.w		; Set CDC device to "Sub CPU"

	lea	VARSSTART,a0			; Clear variables
	move.w	#VARSLEN/4-1,d7

.ClearVars:
	move.l	#0,(a0)+
	dbf	d7,.ClearVars

	bsr.w	InitGfxOperation		; Initialize graphics operation
	bsr.w	WaitWordRAMAccess		; Wait for Word RAM access

	lea	WORDRAM2M,a0			; Clear Word RAM
	move.w	#WORDRAM2MS/8-1,d7

.ClearWordRAM:
	move.l	#0,(a0)+
	move.l	#0,(a0)+
	dbf	d7,.ClearWordRAM

	lea	WORDRAM2M+$30000,a0		; Load unknown data
	move.w	#$8000/4-1,d7

.LoadUnkData:
	move.l	#$01080108,(a0)+
	dbf	d7,.LoadUnkData

	bsr.w	LoadCloudsData			; Load clouds data
	bsr.w	InitGfxParams			; Initialize graphics operation parameters

	bset	#1,GAIRQMASK.w			; Enable graphics interrupt
	bclr	#7,GASUBFLAG.w			; Mark as initialized

; -------------------------------------------------------------------------

MainLoop:
	btst	#0,GAMAINFLAG.w			; Is the Main CPU finished?
	beq.s	.NotDone			; If not, branch
	bset	#0,GASUBFLAG.w			; Respond to the Main CPU

.WaitMainCPUDone:
	btst	#0,GAMAINFLAG.w			; Has the Main CPU responded?
	bne.s	.WaitMainCPUDone		; If not, wait
	bclr	#0,GASUBFLAG.w			; Communication is done

	move.w	#FDRCHG,d0			; Fade music out
	moveq	#$20,d1
	jsr	_CDBIOS.w

	moveq	#0,d1
	rts

.NotDone:
	move.b	GACOMCMD2.w,d0			; Should we run a graphics operation?
	beq.s	MainLoop			; If not, branch
	move.b	GACOMCMD2.w,GACOMSTAT2.w	; Tell Main CPU we received the tip

.WaitMainCPU:
	tst.b	GACOMCMD2.w			; Has the Main CPU received our tip?
	bne.s	.WaitMainCPU			; If not, wait
	move.b	#0,GACOMSTAT2.w			; Communication is done

	bsr.w	GetGfxSines			; Get sines for graphics operation
	bsr.w	RunGfxOperation			; Run graphics operation
	bsr.w	ControlClouds			; Control the clouds
	bsr.w	WaitGfxOperation		; Wait for graphics operation to be done
	
	bsr.w	GiveWordRAMAccess		; Give Main CPU Word RAM access
	bra.w	MainLoop			; Loop

; -------------------------------------------------------------------------
; Initialize graphics operation parameters
; -------------------------------------------------------------------------

InitGfxParams:
	lea	gfxVars,a1			; Graphics operations variables
	move.w	#$480,gfxCamX(a1)		; Camera X
	move.w	#$480,gfxCamY(a1)		; Camera Y
	move.w	#$140,gfxCamZ(a1)		; Camera Z
	move.w	#$44,gfxPitch(a1)		; Pitch
	move.w	#$100,gfxYaw(a1)		; Yaw
	rts

; -------------------------------------------------------------------------
; Control the clouds (only works if the cheat is entered, uses
; player 2 controls)
; -------------------------------------------------------------------------

ControlClouds:
	lea	gfxVars,a1			; Graphics operations variables
	
	move.w	#4,d0				; Yaw rotation speed
	btst	#6,p2CtrlData.w			; Is A being held?
	beq.s	.CheckC				; If not, branch
	sub.w	d0,gfxYaw(a1)			; Rotate yaw
	andi.w	#$1FF,gfxYaw(a1)

.CheckC:
	btst	#5,p2CtrlData.w			; Is C being held?
	beq.s	.CheckB				; If not, branch
	add.w	d0,gfxYaw(a1)			; Rotate yaw
	andi.w	#$1FF,gfxYaw(a1)

.CheckB:
	moveq	#2,d0				; Normal scroll speed
	btst	#4,p2CtrlData.w			; Is B being held?
	beq.s	.ScrollClouds			; If not, branch
	moveq	#4,d0				; Fast scroll speed

.ScrollClouds:
	add.w	d0,gfxCamY(a1)			; Scroll clouds

	btst	#0,p2CtrlData.w			; Is up being held?
	beq.s	.CheckDown			; If not, branch
	subq.w	#2,gfxPitch(a1)			; Rotate pitch
	bcc.s	.CheckDown			; If it hasn't underflowed, branch
	clr.w	gfxPitch(a1)			; Cap pitch rotation

.CheckDown:
	btst	#1,p2CtrlData.w			; Is down being held?
	beq.s	.CheckLeft			; If not, branch
	addq.w	#2,gfxPitch(a1)			; Rotate pitch
	cmpi.w	#$50,gfxPitch(a1)		; Has it rotated too much?
	bcs.s	.CheckLeft			; If not, branch
	move.w	#$50,gfxPitch(a1)		; Cap pitch rotation

.CheckLeft:
	btst	#2,p2CtrlData.w			; Is up being held?
	beq.s	.CheckRight			; If not, branch
	addq.w	#8,gfxCamZ(a1)			; Rotate pitch
	cmpi.w	#$7FF,gfxCamZ(a1)		; Have we zoomed too much?
	bcs.s	.CheckRight			; If not, branch
	move.w	#$7FF,gfxCamZ(a1)		; Cap camera Z

.CheckRight:
	btst	#3,p2CtrlData.w			; Is down being held?
	beq.s	.End				; If not, branch
	subq.w	#8,gfxCamZ(a1)			; Rotate pitch
	cmpi.w	#$80,gfxCamZ(a1)		; Have we zoomed too much?
	bcc.s	.End				; If not, branch
	move.w	#$80,gfxCamZ(a1)		; Cap camera Z

.End:
	rts

; -------------------------------------------------------------------------
; Wait for a graphics operation to be over
; -------------------------------------------------------------------------

WaitGfxOperation:
	move.b	#1,gfxOpFlag			; Set flag
	move	#$2000,sr			; Enable interrupts

.Wait:
	tst.b	gfxOpFlag			; Is the operation over?
	bne.s	.Wait				; If not, wait
	rts

; -------------------------------------------------------------------------
; Give Main CPU Word RAM access
; -------------------------------------------------------------------------

GiveWordRAMAccess:
	btst	#0,GAMEMMODE.w			; Do we have Word RAM access?
	bne.s	.End				; If not, branch
	bset	#0,GAMEMMODE.w			; Give Main CPU Word RAM access
	btst	#0,GAMEMMODE.w			; Has it been given?
	beq.s	GiveWordRAMAccess		; If not, wait

.End:
	rts

; -------------------------------------------------------------------------
; Wait for Word RAM access
; -------------------------------------------------------------------------

WaitWordRAMAccess:
	btst	#1,GAMEMMODE.w			; Do we have Word RAM access?
	beq.s	WaitWordRAMAccess		; If not, wait
	rts

; -------------------------------------------------------------------------
; Initialize graphics operation
; -------------------------------------------------------------------------

InitGfxOperation:
	lea	gfxVars,a1			; Graphics operations variables
	
	move.w	#%111,GASTAMPSIZE.w		; 32x32 stamps, 4096x4096 map, repeated
	move.w	#IMGHTILE-1,GAIMGVCELL.w	; Height in tiles
	move.w	#IMGBUFFER/4,GAIMGSTART.w	; Image buffer address
	move.w	#0,GAIMGOFFSET.w		; Image buffer offset
	move.w	#IMGWIDTH,GAIMGHDOT.w		; Image buffer width
	
	move.w	#$80,gfxFOV(a1)			; Set FOV
	move.w	#-$40,gfxCenter(a1)
	rts

; -------------------------------------------------------------------------
; Get graphics operation sines
; -------------------------------------------------------------------------

GetGfxSines:
	lea	gfxVars,a6			; Graphics operations variables
	
	move.w	gfxPitch(a6),d3			; sin(pitch)
	bsr.w	GetSine
	move.w	d3,gfxPitchSin(a6)

	move.w	gfxPitch(a6),d3			; cos(pitch)
	bsr.w	GetCosine
	move.w	d3,gfxPitchCos(a6)

	move.w	gfxYaw(a6),d3			; sin(yaw)
	bsr.w	GetSine
	move.w	d3,gfxYawSin(a6)
	
	move.w	gfxYaw(a6),d3			; cos(yaw)
	bsr.w	GetCosine
	move.w	d3,gfxYawCos(a6)

	move.w	gfxYaw(a6),d3			; -sin(yaw)
	addi.w	#$100,d3
	bsr.w	GetSine
	move.w	d3,gfxYawSinN(a6)
	
	move.w	gfxYaw(a6),d3			; -cos(yaw)
	addi.w	#$100,d3
	bsr.w	GetCosine
	move.w	d3,gfxYawCosN(a6)

	rts

; -------------------------------------------------------------------------
; Run graphics operation
; -------------------------------------------------------------------------

RunGfxOperation:
	bsr.w	GenGfxTraceTbl			; Generate trace table
	andi.b	#%11100111,GAMEMMODE.w		; Disable priority mode
	move.w	#STAMPMAP/4,GASTAMPMAP.w	; Stamp map
	move.w	#IMGHEIGHT,GAIMGVDOT.w		; Image buffer height
	move.w	#TRACETBL/4,GAIMGTRACE.w	; Set trace table and start operation
	rts

; -------------------------------------------------------------------------
; Generate trace table
; -------------------------------------------------------------------------

GenGfxTraceTbl:
	lea	WORDRAM2M+TRACETBL,a5		; Trace table buffer
	lea	gfxVars,a6			; Graphics operations variables
	
	move.w	gfxCamX(a6),d0			; Camera X
	lsl.w	#3,d0
	move.w	gfxCamY(a6),d1			; Camera Y
	lsl.w	#3,d1

	move.w	#-3,d2				; Initial line ID
	moveq	#8,d6				; 8 bit shifts

	move.w	gfxPitchCos(a6),d3		; cos(pitch) * sin(yaw)
	muls.w	gfxYawSin(a6),d3
	asr.l	#5,d3
	move.w	d3,gfxPcYs(a6)

	move.w	gfxPitchCos(a6),d3		; cos(pitch) * cos(yaw)
	muls.w	gfxYawCos(a6),d3
	asr.l	#5,d3
	move.w	d3,gfxPcYc(a6)

	move.w	gfxFOV(a6),d4			; FOV * sin(pitch) * sin(yaw)
	move.w	d4,d3
	muls.w	gfxPitchSin(a6),d3
	muls.w	gfxYawSin(a6),d3
	asr.l	#5,d3
	move.l	d3,gfxPsYsFOV(a6)

	move.w	d4,d3				; FOV * sin(pitch) * cos(yaw)
	muls.w	gfxPitchSin(a6),d3
	muls.w	gfxYawCos(a6),d3
	asr.l	#5,d3
	move.l	d3,gfxPsYcFOV(a6)

	move.w	d4,d3				; FOV * cos(pitch)
	muls.w	gfxPitchCos(a6),d3
	move.l	d3,gfxPcFOV(a6)

	move.w	#-128,d3			; -128 * cos(yaw)
	muls.w	gfxYawCos(a6),d3
	lsl.l	#3,d3
	movea.l	d3,a1

	move.w	#-128,d3			; -128 * sin(yaw)
	muls.w	gfxYawSin(a6),d3
	lsl.l	#3,d3
	movea.l	d3,a2

	move.w	#127,d3				; 127 * cos(yaw)
	muls.w	gfxYawCos(a6),d3
	lsl.l	#3,d3
	movea.l	d3,a3

	move.w	#127,d3				; 127 * sin(yaw)
	muls.w	gfxYawSin(a6),d3
	lsl.l	#3,d3
	movea.l	d3,a4

	move.w	gfxPitchSin(a6),d4		; (sin(pitch) * sin(yaw)) * (FOV + center point)
	muls.w	gfxYawSin(a6),d4
	asr.l	#5,d4
	move.w	gfxFOV(a6),d3
	add.w	gfxCenter(a6),d3
	muls.w	d4,d3
	asr.l	d6,d3
	move.w	d3,gfxCenterX(a6)

	move.w	gfxPitchSin(a6),d4		; (sin(pitch) * cos(yaw)) * (FOV + center point)
	muls.w	gfxYawCos(a6),d4
	asr.l	#5,d4
	move.w	gfxFOV(a6),d3
	add.w	gfxCenter(a6),d3
	muls.w	d4,d3
	asr.l	d6,d3
	move.w	d3,gfxCenterY(a6)

	move.w	#IMGHEIGHT-1,d7			; Number of lines

; -------------------------------------------------------------------------

.GenLoop:
	; X point = -(line * cos(pitch) * sin(yaw)) + (FOV * sin(pitch) * sin(yaw))
	; Y point =  (line * cos(pitch) * cos(yaw)) - (FOV * sin(pitch) * cos(yaw))
	; Z point =  (line * sin(pitch)) + (FOV * cos(pitch))
	
	; Shear left X  = Camera X + (((127 * cos(yaw)) + X point) * (Camera Z / Z point)) - Center X
	; Shear left Y  = Camera Y + (((127 * sin(yaw)) + Y point) * (Camera Z / Z point)) + Center Y
	; Shear right X = Camera X + (((-128 * cos(yaw)) + X point) * (Camera Z / Z point)) - Center X
	; Shear right Y = Camera Y + (((-128 * sin(yaw)) + Y point) * (Camera Z / Z point)) + Center Y

	move.w	d2,d3				; Z point
	muls.w	gfxPitchSin(a6),d3
	add.l	gfxPcFOV(a6),d3
	asr.l	#5,d3
	bne.s	.NotZero
	moveq	#1,d3

.NotZero:
	move.l	a3,d4				; X start = Shear left X
	move.w	gfxPcYs(a6),d5
	muls.w	d2,d5
	sub.l	d5,d4
	add.l	gfxPsYsFOV(a6),d4
	asr.l	d6,d4
	muls.w	gfxCamZ(a6),d4
	divs.w	d3,d4
	add.w	d0,d4
	sub.w	gfxCenterX(a6),d4
	move.w	d4,(a5)+
	
	move.l	a4,d4				; Y start = Shear left Y
	move.w	gfxPcYc(a6),d5
	muls.w	d2,d5
	add.l	d5,d4
	sub.l	gfxPsYcFOV(a6),d4
	asr.l	d6,d4
	muls.w	gfxCamZ(a6),d4
	divs.w	d3,d4
	add.w	d1,d4
	add.w	gfxCenterY(a6),d4
	move.w	d4,(a5)+
	
	move.l	a1,d4				; X delta = Shear right X - Shear left X
	move.w	gfxPcYs(a6),d5
	muls.w	d2,d5
	sub.l	d5,d4
	add.l	gfxPsYsFOV(a6),d4
	asr.l	d6,d4
	muls.w	gfxCamZ(a6),d4
	divs.w	d3,d4
	add.w	d0,d4
	sub.w	gfxCenterX(a6),d4
	sub.w	-4(a5),d4
	move.w	d4,(a5)+
	
	move.l	a2,d4				; Y delta = Shear right Y - Shear left Y
	move.w	gfxPcYc(a6),d5
	muls.w	d2,d5
	add.l	d5,d4
	sub.l	gfxPsYcFOV(a6),d4
	asr.l	d6,d4
	muls.w	gfxCamZ(a6),d4
	divs.w	d3,d4
	add.w	d1,d4
	add.w	gfxCenterY(a6),d4
	sub.w	-4(a5),d4
	move.w	d4,(a5)+

	subq.w	#1,d2				; Next line
	dbf	d7,.GenLoop			; Loop until entire table is generated
	rts

; -------------------------------------------------------------------------
; Get sine or cosine of a value
; -------------------------------------------------------------------------
; PARAMETERS:
;	d3.w - Value
; RETURNS:
;	d3.w - Sine/cosine of value
; -------------------------------------------------------------------------

GetCosine:
	addi.w	#$80,d3				; Offset value for cosine

GetSine:
	andi.w	#$1FF,d3			; Keep within range
	move.w	d3,d4
	btst	#7,d3				; Is the value the 2nd or 4th quarters of the sinewave?
	beq.s	.NoInvert			; If not, branch
	not.w	d4				; Invert value to fit sinewave pattern

.NoInvert:
	andi.w	#$7F,d4				; Get sine/cosine value
	add.w	d4,d4
	move.w	SineTable(pc,d4.w),d4

	btst	#8,d3				; Was the input value in the 2nd half of the sinewave?
	beq.s	.SetValue			; If not, branch
	neg.w	d4				; Negate value

.SetValue:
	move.w	d4,d3				; Set final value
	rts

; -------------------------------------------------------------------------

SineTable:
	dc.w	$0000, $0003, $0006, $0009, $000C, $000F, $0012, $0016
	dc.w	$0019, $001C, $001F, $0022, $0025, $0028, $002B, $002F
	dc.w	$0032, $0035, $0038, $003B, $003E, $0041, $0044, $0047
	dc.w	$004A, $004D, $0050, $0053, $0056, $0059, $005C, $005F
	dc.w	$0062, $0065, $0068, $006A, $006D, $0070, $0073, $0076
	dc.w	$0079, $007B, $007E, $0081, $0084, $0086, $0089, $008C
	dc.w	$008E, $0091, $0093, $0096, $0099, $009B, $009E, $00A0
	dc.w	$00A2, $00A5, $00A7, $00AA, $00AC, $00AE, $00B1, $00B3
	dc.w	$00B5, $00B7, $00B9, $00BC, $00BE, $00C0, $00C2, $00C4
	dc.w	$00C6, $00C8, $00CA, $00CC, $00CE, $00D0, $00D1, $00D3
	dc.w	$00D5, $00D7, $00D8, $00DA, $00DC, $00DD, $00DF, $00E0
	dc.w	$00E2, $00E3, $00E5, $00E6, $00E7, $00E9, $00EA, $00EB
	dc.w	$00EC, $00EE, $00EF, $00F0, $00F1, $00F2, $00F3, $00F4
	dc.w	$00F5, $00F6, $00F7, $00F7, $00F8, $00F9, $00FA, $00FA
	dc.w	$00FB, $00FB, $00FC, $00FC, $00FD, $00FD, $00FE, $00FE
	dc.w	$00FE, $00FF, $00FF, $00FF, $00FF, $00FF, $00FF, $0100

; -------------------------------------------------------------------------
; Graphics operation interrupt
; -------------------------------------------------------------------------

IRQ1:
	clr.b	gfxOpFlag			; Clear graphics operation flag
	rte

; -------------------------------------------------------------------------
; IRQ2
; -------------------------------------------------------------------------

IRQ2:
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
	move.b	d0,d2				; Calcualte offset
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
; Load clouds data
; -------------------------------------------------------------------------

LoadCloudsData:
	lea	Stamps_Clouds(pc),a0		; Load stamp art
	lea	WORDRAM2M+$200,a1
	bsr.w	KosDec
	
	lea	StampMap_Clouds(pc),a0		; Load stamp map
	lea	WORDRAM2M+STAMPMAP,a1
	bsr.w	KosDec

	rts

; -------------------------------------------------------------------------
; Clouds data
; -------------------------------------------------------------------------

Stamps_Clouds:
	incbin	"Title Screen/Data/Cloud Stamps.kos"
	even

StampMap_Clouds:
	incbin	"Title Screen/Data/Cloud Stamp Map.kos"
	even

; -------------------------------------------------------------------------
