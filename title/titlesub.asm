; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Title screen Sub CPU program
; -------------------------------------------------------------------------

	include	"_inc/common.i"
	include	"_inc/subcpu.i"
	include	"title/common.i"

; -------------------------------------------------------------------------
; Graphics operation variable structure
; -------------------------------------------------------------------------

	rsreset
gfxX		rs.w	1			; X position
gfxY		rs.w	1			; Y position
gfxZoom		rs.w	1			; Zoom
gfxPitch	rs.w	1			; Pitch
gfxPitchSin	rs.w	1			; Sine of pitch
gfxPitchCos	rs.w	1			; Cosine of pitch
gfxYaw		rs.w	1			; Yaw
gfxYawSin	rs.w	1			; Sine of yaw
gfxYawCos	rs.w	1			; Cosine of yaw
gfxYawSinN	rs.w	1			; Negative sine of yaw
gfxYawCosN	rs.w	1			; Negative cosine of yaw
gfx16		rs.w	1
gfx18		rs.w	1
		rs.b	$16			; Unused
gfx30		rs.l	1
gfx34		rs.l	1
		rs.b	8			; Unused
gfx40		rs.l	1
		rs.b	16			; Unused
gfx54		rs.w	1
		rs.b	2			; Unused
gfx58		rs.w	1
		rs.b	2			; Unused
gfx5C		rs.w	1
		rs.b	2			; Unused
gfx60		rs.w	1
gfxSize		rs.b	0			; size of structure

; -------------------------------------------------------------------------
; Variables
; -------------------------------------------------------------------------

	rsset	PRGRAM+$1E000
VARSSTART	rs.b	0			; Start of variables
		rs.b	$300			; Unused
gfxOpFlag	rs.b	1			; Graphics operation flag
		rs.b	$AFF			; Unused
gfxVars		rs.b	gfxSize			; Graphics operation variables
		rs.b	$119E			; Unused
VARSSZ		EQU	__rs-VARSSTART		; Size of variables area

p2CtrlData	EQU	GACOMCMDE		; Player 2 controller data
p2CtrlHold	EQU	p2CtrlData		; Player 2 controller held buttons data
p2CtrlTap	EQU	p2CtrlData+1		; Player 2 controller tapped buttons data

; -------------------------------------------------------------------------
; Program start
; -------------------------------------------------------------------------

	org	$10000

	move.l	#IRQ1,_LEVEL1+2.w		; Set IRQ1 handler
	move.l	#IRQ2,_USERCALL2+2.w		; Set IRQ2 handler
	move.b	#0,GAMEMMODE.w			; Set to 2M mode

	moveq	#0,d0				; Clear communication statuses
	move.w	d0,GACOMSTAT0.w
	move.b	d0,GACOMSTAT2.w
	move.l	d0,GACOMSTAT4.w
	move.l	d0,GACOMSTAT8.w
	move.l	d0,GACOMSTATC.w

	bset	#7,GASUBFLAG.w			; Tell Main CPU we're ready to accept Word RAM access
	bclr	#1,GAIRQMASK.w			; Disable level 1 interrupt
	bclr	#3,GAIRQMASK.w			; Disable timer interrupt
	move.b	#3,GACDCDEVICE.w		; Set CDC device to "Sub CPU"

	lea	VARSSTART,a0			; Clear variables
	move.w	#VARSSZ/4-1,d7

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

	bset	#1,GAIRQMASK.w			; Enable level 1 interrupt
	bclr	#7,GASUBFLAG.w			; Tell Main CPU we're done initializing

; -------------------------------------------------------------------------

MainLoop:
	btst	#0,GAMAINFLAG.w			; Is the Main CPU finished?
	beq.s	.NotDone			; If not, branch
	bset	#0,GASUBFLAG.w			; Tell Main CPU that we have gotten the tip

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
	move.w	#$480,gfxX(a1)			; X position
	move.w	#$480,gfxY(a1)			; Y position
	move.w	#$140,gfxZoom(a1)		; Zoom
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
	add.w	d0,gfxY(a1)			; Scroll clouds

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
	addq.w	#8,gfxZoom(a1)			; Rotate pitch
	cmpi.w	#$7FF,gfxZoom(a1)		; Have we zoomed too much?
	bcs.s	.CheckRight			; If not, branch
	move.w	#$7FF,gfxZoom(a1)		; Cap pitch rotation

.CheckRight:
	btst	#3,p2CtrlData.w			; Is down being held?
	beq.s	.End				; If not, branch
	subq.w	#8,gfxZoom(a1)			; Rotate pitch
	cmpi.w	#$80,gfxZoom(a1)		; Have we zoomed too much?
	bcc.s	.End				; If not, branch
	move.w	#$80,gfxZoom(a1)		; Cap pitch rotation

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
	
	move.w	#$80,gfx16(a1)
	move.w	#-$40,gfx18(a1)
	rts

; -------------------------------------------------------------------------
; Get graphics operation sines
; -------------------------------------------------------------------------

GetGfxSines:
	lea	gfxVars,a6			; Graphics operations variables
	
	move.w	gfxPitch(a6),d3			; Get sine of pitch
	bsr.w	GetSine
	move.w	d3,gfxPitchSin(a6)

	move.w	gfxPitch(a6),d3			; Get cosine of pitch
	bsr.w	GetCosine
	move.w	d3,gfxPitchCos(a6)

	move.w	gfxYaw(a6),d3			; Get sine of yaw
	bsr.w	GetSine
	move.w	d3,gfxYawSin(a6)
	
	move.w	gfxYaw(a6),d3			; Get cosine of yaw
	bsr.w	GetCosine
	move.w	d3,gfxYawCos(a6)

	move.w	gfxYaw(a6),d3			; Get negative sine of yaw
	addi.w	#$100,d3
	bsr.w	GetSine
	move.w	d3,gfxYawSinN(a6)
	
	move.w	gfxYaw(a6),d3			; Get negative cosine of yaw
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
	
	move.w	gfxX(a6),d0			; X position
	lsl.w	#3,d0
	move.w	gfxY(a6),d1			; Y position
	lsl.w	#3,d1

	move.w	#-3,d2				; Initial line(?)
	moveq	#8,d6				; 8 bit shifts

	move.w	gfxPitchCos(a6),d3		; cos(pitch) * sin(yaw)
	muls.w	gfxYawSin(a6),d3
	asr.l	#5,d3
	move.w	d3,gfx5C(a6)

	move.w	gfxPitchCos(a6),d3		; cos(pitch) * cos(yaw)
	muls.w	gfxYawCos(a6),d3
	asr.l	#5,d3
	move.w	d3,gfx60(a6)

	move.w	gfx16(a6),d4			; gfx16 * sin(pitch) * sin(yaw)
	move.w	d4,d3
	muls.w	gfxPitchSin(a6),d3
	muls.w	gfxYawSin(a6),d3
	asr.l	#5,d3
	move.l	d3,gfx30(a6)

	move.w	d4,d3				; gfx16 * sin(pitch) * cos(yaw)
	muls.w	gfxPitchSin(a6),d3
	muls.w	gfxYawCos(a6),d3
	asr.l	#5,d3
	move.l	d3,gfx34(a6)

	move.w	d4,d3				; gfx16 * cos(pitch)
	muls.w	gfxPitchCos(a6),d3
	move.l	d3,gfx40(a6)

	move.w	#-$80,d3			; -$80 * cos(yaw)
	muls.w	gfxYawCos(a6),d3
	lsl.l	#3,d3
	movea.l	d3,a1

	move.w	#-$80,d3			; -$80 * sin(yaw)
	muls.w	gfxYawSin(a6),d3
	lsl.l	#3,d3
	movea.l	d3,a2

	move.w	#$7F,d3				; $7F * cos(yaw)
	muls.w	gfxYawCos(a6),d3
	lsl.l	#3,d3
	movea.l	d3,a3

	move.w	#$7F,d3				; $7F * sin(yaw)
	muls.w	gfxYawSin(a6),d3
	lsl.l	#3,d3
	movea.l	d3,a4

	move.w	gfxPitchSin(a6),d4		; (sin(pitch) * sin(yaw)) * (gfx16 + gfx18)
	muls.w	gfxYawSin(a6),d4
	asr.l	#5,d4
	move.w	gfx16(a6),d3
	add.w	gfx18(a6),d3
	muls.w	d4,d3
	asr.l	d6,d3
	move.w	d3,gfx54(a6)

	move.w	gfxPitchSin(a6),d4		; (sin(pitch) * cos(yaw)) * (gfx16 + gfx18)
	muls.w	gfxYawCos(a6),d4
	asr.l	#5,d4
	move.w	gfx16(a6),d3
	add.w	gfx18(a6),d3
	muls.w	d4,d3
	asr.l	d6,d3
	move.w	d3,gfx58(a6)

	move.w	#IMGHEIGHT-1,d7			; Number of lines

; -------------------------------------------------------------------------

.GenLoop:
	move.w	d2,d3				; (line * sin(pitch)) + gfx40
	muls.w	gfxPitchSin(a6),d3
	add.l	gfx40(a6),d3
	asr.l	#5,d3
	bne.s	.NotZero
	moveq	#1,d3

.NotZero:
	move.l	a3,d4				; ((((a3 - (gfx5C * line)) + gfx30) * zoom) / d3) + X - gfx54
	move.w	gfx5C(a6),d5
	muls.w	d2,d5
	sub.l	d5,d4
	add.l	gfx30(a6),d4
	asr.l	d6,d4
	muls.w	gfxZoom(a6),d4
	divs.w	d3,d4
	add.w	d0,d4
	sub.w	gfx54(a6),d4
	move.w	d4,(a5)+
	
	move.l	a4,d4				; ((((a3 + (gfx60 * line)) - gfx34) * zoom) / d3) + Y + gfx58
	move.w	gfx60(a6),d5
	muls.w	d2,d5
	add.l	d5,d4
	sub.l	gfx34(a6),d4
	asr.l	d6,d4
	muls.w	gfxZoom(a6),d4
	divs.w	d3,d4
	add.w	d1,d4
	add.w	gfx58(a6),d4
	move.w	d4,(a5)+
	
	move.l	a1,d4				; ((((a1 - (gfx5C * line)) + gfx30) * zoom) / d3) + X - gfx54 - X start
	move.w	gfx5C(a6),d5
	muls.w	d2,d5
	sub.l	d5,d4
	add.l	gfx30(a6),d4
	asr.l	d6,d4
	muls.w	gfxZoom(a6),d4
	divs.w	d3,d4
	add.w	d0,d4
	sub.w	gfx54(a6),d4
	sub.w	-4(a5),d4
	move.w	d4,(a5)+
	
	move.l	a2,d4				; ((((a2 + (gfx60 * line)) - gfx34) * zoom) / d3) + Y + gfx58 - Y start
	move.w	gfx60(a6),d5
	muls.w	d2,d5
	add.l	d5,d4
	sub.l	gfx34(a6),d4
	asr.l	d6,d4
	muls.w	gfxZoom(a6),d4
	divs.w	d3,d4
	add.w	d1,d4
	add.w	gfx58(a6),d4
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
	move.w	d4,d3				; Set final valur
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
	incbin	"title/data/clouds.cdart.kos"
	even

StampMap_Clouds:
	incbin	"title/data/clouds.cdmap.kos"
	even

; -------------------------------------------------------------------------
