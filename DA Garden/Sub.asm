; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; DA Garden Sub CPU program
; -------------------------------------------------------------------------

	include	"_Include/Common.i"
	include	"_Include/Sub CPU.i"
	include	"_Include/Sound.i"
	include	"DA Garden/_Common.i"
	
; -------------------------------------------------------------------------
; Graphics operation parameters structure
; -------------------------------------------------------------------------

	rsreset
gfxX		rs.w	1			; X position
gfxY		rs.w	1			; Y position
gfxZ		rs.w	1			; Z position
gfxAngle	rs.w	1			; Angle
		rs.b	8
gfx10		rs.w	1			; Unknown
gfx12		rs.b	1			; Unknown
gfxParamSize	rs.b	0			; Size of structure

; -------------------------------------------------------------------------
; Graphics operation variable structure
; -------------------------------------------------------------------------

	rsreset
gfxSin		rs.w	1			; Sine of angle
gfxCos		rs.w	1			; Cosine of angle
gfxXOrigin	rs.w	1			; X origin
gfxYOrigin	rs.w	1			; Y origin
gfxScale	rs.w	1			; Scale
gfxXTranslate	rs.w	1			; X translation
gfxYTranslate	rs.w	1			; Y translation
gfxXDelta	rs.w	1			; X delta
gfxYDelta	rs.w	1			; Y delta
gfxXStart	rs.w	1			; X start
gfxYStart	rs.w	1			; Y start
gfxXStartRot	rs.l	1			; X start (rotated)
gfxYStartRot	rs.l	1			; Y start (rotated)
gfxScaleInv	rs.w	1			; Inverted scale
gfxVarsSize	rs.b	0			; Size of structure

; -------------------------------------------------------------------------
; Object structure
; -------------------------------------------------------------------------

	rsreset
		rs.b	3
oRoutine	rs.b	1			; Routine
		rs.b	$C
oAngle		rs.w	1			; Angle
		rs.b	2
oX		rs.l	1			; X position
oY		rs.l	1			; Y position
oZ		rs.l	1			; Z position
oUnk		rs.w	1			; Unknown
oSize		rs.b	0			; Size of structure

; -------------------------------------------------------------------------
; Variables
; -------------------------------------------------------------------------

	rsset	PRGRAM+$1C000
VARSSTART	rs.b	0			; Start of variables
		rs.b	$800
gfxOpFlag	rs.b	1			; Graphics operation flag
		rs.b	1
scaleDirection	rs.w	1			; Scale direction
angleDirection	rs.w	1			; Angle direction
angleSpeed	rs.l	1			; Angle speed
planetFlags	rs.b	1			; Planet flags
		rs.b	$F5
gfxVars		rs.b	gfxVarsSize		; Graphics operation variables
		rs.b	$E0
planetObj	rs.b	oSize			; Planet object slot
		rs.b	$DE
gfxParams	rs.b	gfxParamSize		; Graphics operation parameters
		rs.b	$14F0
VARSLEN		EQU	__rs-VARSSTART		; Size of variables area

ctrlData	EQU	GACOMCMDE		; Controller data
ctrlHold	EQU	ctrlData		; Controller held buttons data
ctrlTap		EQU	ctrlData+1		; Controller tapped buttons data

; -------------------------------------------------------------------------
; Program start
; -------------------------------------------------------------------------

	org	$10000
	
	move.l	#IRQ1,_LEVEL1+2.w		; Set graphics interrupt handler
	move.b	#0,GAMEMMODE.w			; Set to 2M mode
	
	moveq	#0,d0				; Clear communication statuses
	move.l	d0,GACOMSTAT0.w
	move.l	d0,GACOMSTAT4.w
	move.l	d0,GACOMSTAT8.w
	move.l	d0,GACOMSTATC.w
	
	bclr	#3,GASUBFLAG.w			; Clear unused flag
	bclr	#4,GASUBFLAG.w			; Clear music change flag
	bclr	#5,GASUBFLAG.w			; Clear music change communication flag
	bclr	#6,GASUBFLAG.w			; Clear exit flag
	
	bset	#7,GASUBFLAG.w			; Mark as started
	bclr	#1,GAIRQMASK.w			; Disable graphics interrupt
	bclr	#3,GAIRQMASK.w			; Disable timer interrupt
	move.b	#3,GACDCDEVICE.w		; Set CDC device to "Sub CPU"

	bsr.w	InitRAM				; Initialize RAM
	bsr.w	InitGfxOperation		; Initialize graphics operation
	bsr.w	InitPlanetData			; Initialize planet data
	
	bset	#1,GAIRQMASK.w			; Enable graphics interrupt
	bclr	#7,GASUBFLAG.w			; Mark as initialized

; -------------------------------------------------------------------------

MainLoop:
	move.w	GACOMCMD2.w,d0			; Should we run a graphics operation?
	beq.s	MainLoop			; If not, branch
	move.w	GACOMCMD2.w,GACOMSTAT2.w	; Tell Main CPU we received the tip

.WaitMainCPU:
	tst.w	GACOMCMD2.w			; Has the Main CPU received our tip?
	bne.s	.WaitMainCPU			; If not, wait
	move.w	#0,GACOMSTAT2.w			; Communication is done

	bsr.w	ObjPlanet			; Run planet object
	
	btst	#4,GASUBFLAG.w			; Is the music changing?
	beq.s	.NoChange			; If not, branch
	bsr.w	WaitWordRAMAccess		; Wait for Word RAM access
	bsr.w	PlayCDDAMusic			; Play music
	bsr.w	UpdatePlanetData		; Update planet data
	bclr	#4,GASUBFLAG.w			; Clear flag

.NoChange:
	bsr.w	RunGfxOperation			; Run graphics operation
	bsr.w	GiveWordRAMAccess		; Give Main CPU Word RAM access
	
	btst	#5,GAMAINFLAG.w			; Is the Main CPU telling us to change the music?
	beq.s	.CheckExit			; If not, branch
	bset	#5,GASUBFLAG.w			; Acknowledge Main CPU

.WaitMainCPU2:
	btst	#5,GAMAINFLAG.w			; Has the Main CPU responded?
	bne.s	.WaitMainCPU2			; If not, wait
	bclr	#5,GASUBFLAG.w			; Communication is done
	bset	#4,GASUBFLAG.w			; Mark music as changing

.CheckExit:
	btst	#6,GASUBFLAG.w			; Are we exiting?
	beq.s	MainLoop			; If not, branch

.WaitMainCPU3:
	btst	#6,GAMAINFLAG.w			; Has the Main CPU responded?
	beq.s	.WaitMainCPU3			; If not, wait
	bclr	#6,GASUBFLAG.w			; Communication is done
	
	move.b	#0,GASUBFLAG.w			; Clear communication flag
	nop
	nop
	nop
	rts

; -------------------------------------------------------------------------
; Update planet data
; -------------------------------------------------------------------------

UpdatePlanetData:
	move.w	GACOMCMDA.w,d0			; Get time zone
	move.w	GACOMCMDA.w,d0
	cmpi.w	#3,d0				; Should we not update?
	beq.s	.End				; If so, branch
	
	lea	PlanetData(pc),a1		; Get pointer to planet metadata
	move.w	GACOMCMDA.w,d0
	add.w	d0,d0
	add.w	d0,d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0
	lea	(a1,d0.w),a0
	
	movea.l	(a0),a0				; Load stamps
	movem.l	d0/a1,-(sp)
	lea	WORDRAM2M+$200,a1
	bsr.w	KosDec
	
	movem.l	(sp)+,d0/a1			; Load animation stamps
	lea	4(a1,d0.w),a0
	movea.l	(a0),a0
	movem.l	d0/a1,-(sp)
	lea	WORDRAM2M+$6E00,a1
	bsr.w	KosDec
	movem.l	(sp)+,d0/a1
	
	lea	8(a1,d0.w),a0			; Get stamp map
	movea.l	(a0),a0
	lea	WORDRAM2M+STAMPMAP,a1
	movea.l	a1,a2
	move.w	#7-1,d0				; Get height

.Row:
	move.w	#8-1,d1				; Get width
	movea.l	a2,a1				; Set row address

.Stamp:
	move.w	(a0)+,(a1)+			; Copy stamp UD
	dbf	d1,.Stamp			; Loop until row is written
	
	adda.l	#$100,a2			; Next row
	dbf	d0,.Row				; Loop until stamp map is written

.End:
	rts

; -------------------------------------------------------------------------
; Initialize RAM
; -------------------------------------------------------------------------

InitRAM:
	lea	VARSSTART,a0			; Clear variables
	move.w	#VARSLEN/4-1,d7

.ClearVars:
	move.l	#0,(a0)+
	dbf	d7,.ClearVars
	
	bsr.w	WaitWordRAMAccess		; Wait for Word RAM access

	lea	WORDRAM2M,a0			; Clear stamps
	move.w	#$12C00/8-1,d7

.ClearStamps:
	move.l	#0,(a0)+
	move.l	#0,(a0)+
	dbf	d7,.ClearStamps
	
	lea	WORDRAM2M+TRACETBL,a0		; Clear trace table and image buffer
	move.w	#(WORDRAM2MS-TRACETBL)/8-1,d7

.ClearTraceImg:
	move.l	#0,(a0)+
	move.l	#0,(a0)+
	dbf	d7,.ClearTraceImg
	
	lea	WORDRAM2M+$30000,a0		; Load unknown data
	move.w	#$1FFF,d7

.LoadUnkData:
	move.l	#$1080108,(a0)+
	dbf	d7,.LoadUnkData
	rts

; -------------------------------------------------------------------------
; Initialize planet data
; -------------------------------------------------------------------------

InitPlanetData:
	lea	Stamps_Present(pc),a0		; Load stamps
	lea	WORDRAM2M+$200,a1
	bsr.w	KosDec
	
	lea	Stamps_PresGFAnim,a0		; Load animation stamps
	lea	WORDRAM2M+$6E00,a1
	bsr.w	KosDec
	
	lea	StampMap_Present,a0		; Get stamp map
	lea	WORDRAM2M+STAMPMAP,a1
	movea.l	a1,a2
	move.w	#7-1,d0				; Get height

.Row:
	move.w	#8-1,d1				; Get width
	movea.l	a2,a1				; Set row address

.Stamp:
	move.w	(a0)+,(a1)+			; Copy stamp UD
	dbf	d1,.Stamp			; Loop until row is written
	
	adda.l	#$100,a2			; Next row
	dbf	d0,.Row				; Loop until stamp map is written
	rts

; -------------------------------------------------------------------------
; Graphics operation interrupt
; -------------------------------------------------------------------------

IRQ1:
	move.b	#0,gfxOpFlag			; Clear graphics operation flag
	rte

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
; Wait for the Main CPU to start an update
; -------------------------------------------------------------------------

WaitUpdateStart:
	tst.w	GACOMCMD2.w			; Should we start the update?
	bne.s	WaitUpdateStart			; If not, wait
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
; Load stamp map
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - Destination address
;	d1.w - Width (minus 1)
;	d2.w - Height (minus 1)
; -------------------------------------------------------------------------

LoadStampMap:
	move.l	#$100,d4			; Row delta

.Row:
	movea.l	d0,a2				; Set row address
	move.w	d1,d3				; Get width

.Stamp:
	move.w	(a1)+,d5			; Write stamp ID
	lsl.w	#2,d5
	move.w	d5,(a2)+
	dbf	d3,.Stamp			; Loop until row is written

	add.l	d4,d0				; Next row
	dbf	d2,.Row				; Loop until stamp map is written
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
	move.b	d0,d2				; Calculate offset
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
; Run graphics operation
; -------------------------------------------------------------------------

RunGfxOperation:
	lea	gfxParams,a6			; Graphics operation parameters
	move.w	planetObj+oAngle,gfxAngle(a6)	; Set angle
	move.w	planetObj+oX,gfxX(a6)		; Set X position
	move.w	planetObj+oY,gfxY(a6)		; Set Y position
	move.w	planetObj+oZ,gfxZ(a6)		; Set Z position
	
	bsr.w	GenGfxTraceTbl			; Generate trace table
	andi.b	#%11100111,GAMEMMODE.w		; Disable priority mode
	move.w	#STAMPMAP/4,GASTAMPMAP.w	; Stamp map
	move.w	#IMGHEIGHT,GAIMGVDOT.w		; Image buffer height
	move.w	#TRACETBL/4,GAIMGTRACE.w	; Set trace table and start operation
	bra.w	WaitGfxOperation		; Wait for graphics operation to finish

; -------------------------------------------------------------------------
; Initialize graphics operation
; -------------------------------------------------------------------------

InitGfxOperation:
	move.w	#%110,GASTAMPSIZE.w		; 32x32 stamps, 4096x4096 map, not repeated
	move.w	#IMGHTILE-1,GAIMGVCELL.w	; Height in tiles
	move.w	#IMGBUFFER/4,GAIMGSTART.w	; Image buffer address
	move.w	#0,GAIMGOFFSET.w		; Image buffer offset
	move.w	#IMGWIDTH,GAIMGHDOT.w		; Image buffer width
	rts
	
; -------------------------------------------------------------------------
; Generate trace table
; -------------------------------------------------------------------------
; PARAMETERS:
;	a6.l - Graphics operation parameters
; -------------------------------------------------------------------------

GenGfxTraceTbl:
	lea	WORDRAM2M+TRACETBL,a1		; Trace table buffer
	lea	gfxVars,a2			; Graphics operations variables
	
	move.w	#$80,gfxXTranslate(a2)		; Set X translation
	move.w	#$70,gfxYTranslate(a2)		; Set Y translation
	move.w	#$80,gfxXOrigin(a2)		; Set X origin
	move.w	#$70,gfxYOrigin(a2)		; Set Y origin
	
	moveq	#0,d0				; Set scale
	move.w	gfxZ(a6),d0
	addi.w	#$80,d0
	ext.l	d0
	asl.l	#8,d0
	divs.w	#$80,d0
	move.w	d0,gfxScale(a2)
	
	moveq	#0,d0				; Set inverted scale
	move.w	gfxZ(a6),d0
	addi.w	#$80,d0
	ext.l	d0
	move.l	#$8000,d1
	divs.w	d0,d1
	move.w	d0,gfxScaleInv(a2)
	
	move.w	gfxAngle(a6),d3			; cos(angle)
	bsr.w	GetCosine
	move.w	d3,gfxCos(a2)
	
	move.w	gfxAngle(a6),d3			; sin(angle)
	bsr.w	GetSine
	move.w	d3,gfxSin(a2)
	
	move.w	gfxCos(a2),d0			; X delta = cos(angle) * scale
	move.w	gfxScale(a2),d1
	muls.w	d1,d0
	asr.l	#5,d0
	move.w	d0,gfxXDelta(a2)
	
	move.w	gfxSin(a2),d0			; Y delta = sin(angle) * scale
	move.w	gfxScale(a2),d1
	muls.w	d1,d0
	asr.l	#5,d0
	move.w	d0,gfxYDelta(a2)
	
	move.w	gfxX(a6),d0			; X start = X - X origin
	sub.w	gfxXOrigin(a2),d0
	move.w	d0,gfxXStart(a2)
	
	move.w	gfxY(a6),d0			; Y start = (Y - Y origin) + (height / 2)
	sub.w	gfxYOrigin(a2),d0
	move.w	d0,gfxYStart(a2)
	addi.w	#IMGHEIGHT/2,gfxYStart(a2)
	
	bsr.w	GetRotatedX			; Get rotated X start
	asr.l	#3,d0
	move.w	d0,gfxXStartRot(a2)
	
	bsr.w	GetRotatedY			; Get rotated Y start
	asr.l	#3,d0
	move.w	d0,gfxYStartRot(a2)
	
	move.w	gfxCos(a2),d0			; X translation = (cos(angle) / 2) + rotated X start
	muls.w	#$80,d0
	asr.l	#8,d0
	move.w	gfxXStartRot(a2),d1
	add.w	d1,d0
	move.w	d0,gfxXTranslate(a2)
	
	move.w	gfxSin(a2),d0			; Y translation = (sin(angle) / 2) + rotated Y start
	muls.w	#$80,d0
	asr.l	#8,d0
	move.w	gfxYStartRot(a2),d1
	add.w	d1,d0
	move.w	d0,gfxYTranslate(a2)
	
	move.w	gfxX(a6),d0			; X start = X - X origin
	sub.w	gfxXOrigin(a2),d0
	move.w	d0,gfxXStart(a2)
	
	move.w	gfxY(a6),d0			; Y start = Y - Y origin
	sub.w	gfxYOrigin(a2),d0
	move.w	d0,gfxYStart(a2)
	
	move.w	#IMGHEIGHT-1,d7			; Number of lines

.GenLoop:
	bsr.w	GetRotatedX			; X start
	bsr.w	GetScaledX
	move.w	d0,(a1)+
	
	bsr.w	GetRotatedY			; Y start
	bsr.w	GetScaledY
	move.w	d0,(a1)+
	
	move.w	gfxXDelta(a2),d0		; X delta
	move.w	d0,(a1)+
	
	move.w	gfxYDelta(a2),d0		; Y delta
	move.w	d0,(a1)+
	
	addq.w	#1,gfxYStart(a2)		; Next line
	dbf	d7,.GenLoop			; Loop until entire table is generated
	rts

; -------------------------------------------------------------------------
; Get rotated X
; -------------------------------------------------------------------------
; PARAMETERS:
;	a2.l - Graphics operation variables
; RETURNS:
;	d0.w - Rotated X
; -------------------------------------------------------------------------

GetRotatedX:
	move.w	gfxXStart(a2),d0		; X start * cos(angle)
	move.w	gfxCos(a2),d1
	muls.w	d0,d1
	
	move.w	gfxYStart(a2),d0		; Y start * sin(angle)
	move.w	gfxSin(a2),d2
	muls.w	d0,d2
	
	sub.l	d2,d1				; ((X start * cos(angle)) - (Y start * sin(angle))) + X origin
	moveq	#0,d0
	move.w	gfxXOrigin(a2),d0
	ext.l	d0
	asl.l	#8,d0
	add.l	d1,d0
	asr.l	#5,d0
	rts

; -------------------------------------------------------------------------
; Get scaled X
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Rotated X
;	a2.l - Graphics operation variables
; RETURNS:
;	d0.w - Scaled X
; -------------------------------------------------------------------------

GetScaledX:
	move.w	gfxScale(a2),d2			; Rotated X * scale
	muls.w	d2,d0
	asr.l	#8,d0
	
	move.w	gfxXTranslate(a2),d1		; X translation * scale
	move.w	gfxScale(a2),d2
	muls.w	d1,d2
	
	move.w	gfxXTranslate(a2),d1		; (Rotated X * scale) + (X translation - (X translation * scale))
	ext.l	d1
	asl.l	#8,d1
	sub.l	d2,d1
	asr.l	#5,d1
	add.l	d1,d0
	rts
	
; -------------------------------------------------------------------------
; Get rotated Y
; -------------------------------------------------------------------------
; PARAMETERS:
;	a2.l - Graphics operation variables
; RETURNS:
;	d0.w - Rotated Y
; -------------------------------------------------------------------------

GetRotatedY:
	move.w	gfxXStart(a2),d0		; X start * sin(angle)
	move.w	gfxSin(a2),d1
	muls.w	d0,d1
	
	move.w	gfxYStart(a2),d0		; Y start * cos(angle)
	move.w	gfxCos(a2),d2
	muls.w	d0,d2
	
	add.l	d1,d2				; ((X start * sin(angle)) + (Y start * cos(angle))) + Y origin
	moveq	#0,d0
	move.w	gfxYOrigin(a2),d0
	ext.l	d0
	asl.l	#8,d0
	add.l	d2,d0
	asr.l	#5,d0
	rts

; -------------------------------------------------------------------------
; Get scaled Y
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Rotated Y
;	a2.l - Graphics operation variables
; RETURNS:
;	d0.w - Scaled Y
; -------------------------------------------------------------------------

GetScaledY:
	move.w	gfxScale(a2),d2			; Rotated Y * scale
	muls.w	d2,d0
	asr.l	#8,d0
	
	move.w	gfxYTranslate(a2),d1		; Y translation * scale
	move.w	gfxScale(a2),d2
	muls.w	d1,d2
	
	move.w	gfxYTranslate(a2),d1		; (Rotated Y * scale) + (Y translation - (Y translation * scale))
	ext.l	d1
	asl.l	#8,d1
	sub.l	d2,d1
	asr.l	#5,d1
	add.l	d1,d0
	rts

; -------------------------------------------------------------------------

	include	"DA Garden/Objects/Planet/Main.asm"

; -------------------------------------------------------------------------
; Play music
; -------------------------------------------------------------------------

PlayCDDAMusic:
	move.w	GACOMCMD8.w,d0			; Play music ID
	move.w	GACOMCMD8.w,d0
	add.w	d0,d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)
	rts

; -------------------------------------------------------------------------

.Index:
	dc.w	PlayR1AMusic-.Index
	dc.w	PlayR1CMusic-.Index
	dc.w	PlayR1DMusic-.Index
	dc.w	PlayR3AMusic-.Index
	dc.w	PlayR3CMusic-.Index
	dc.w	PlayR3DMusic-.Index
	dc.w	PlayR4AMusic-.Index
	dc.w	PlayR4CMusic-.Index
	dc.w	PlayR4DMusic-.Index
	dc.w	PlayR5AMusic-.Index
	dc.w	PlayR5CMusic-.Index
	dc.w	PlayR5DMusic-.Index
	dc.w	PlayR6AMusic-.Index
	dc.w	PlayR6CMusic-.Index
	dc.w	PlayR6DMusic-.Index
	dc.w	PlayR7AMusic-.Index
	dc.w	PlayR7CMusic-.Index
	dc.w	PlayR7DMusic-.Index
	dc.w	PlayR8AMusic-.Index
	dc.w	PlayR8CMusic-.Index
	dc.w	PlayR8DMusic-.Index
	dc.w	PlayFinalMusic-.Index
	dc.w	PlayDAGardenMusic-.Index
	dc.w	PlayGameOverMusic-.Index
	dc.w	PlayResultsMusic-.Index
	dc.w	PlayBossMusic-.Index
	dc.w	PlayInvincMusic-.Index
	dc.w	PlayShoesMusic-.Index
	dc.w	PlayTitleMusic-.Index
	dc.w	PlaySpecStgMusic-.Index
	dc.w	PlayOpeningMusic-.Index
	dc.w	PlayEndingMusic-.Index

; -------------------------------------------------------------------------
; Play Palmtree Panic Present music
; -------------------------------------------------------------------------

PlayR1AMusic:
	lea	MusID_R1A(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Palmtree Panic Good Future music
; -------------------------------------------------------------------------

PlayR1CMusic:
	lea	MusID_R1C(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Palmtree Panic Bad Future music
; -------------------------------------------------------------------------

PlayR1DMusic:
	lea	MusID_R1D(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Collision Chaos Present music
; -------------------------------------------------------------------------

PlayR3AMusic:
	lea	MusID_R3A(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Collision Chaos Good Future music
; -------------------------------------------------------------------------

PlayR3CMusic:
	lea	MusID_R3C(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Collision Chaos Bad Future music
; -------------------------------------------------------------------------

PlayR3DMusic:
	lea	MusID_R3D(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Tidal Tempest Present music
; -------------------------------------------------------------------------

PlayR4AMusic:
	lea	MusID_R4A(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Tidal Tempest Good Future music
; -------------------------------------------------------------------------

PlayR4CMusic:
	lea	MusID_R4C(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Tidal Tempest Bad Future music
; -------------------------------------------------------------------------

PlayR4DMusic:
	lea	MusID_R4D(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Quartz Quadrant Present music
; -------------------------------------------------------------------------

PlayR5AMusic:
	lea	MusID_R5A(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Quartz Quadrant Good Future music
; -------------------------------------------------------------------------

PlayR5CMusic:
	lea	MusID_R5C(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Quartz Quadrant Bad Future music
; -------------------------------------------------------------------------

PlayR5DMusic:
	lea	MusID_R5D(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Wacky Workbench Present music
; -------------------------------------------------------------------------

PlayR6AMusic:
	lea	MusID_R6A(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Wacky Workbench Good Future music
; -------------------------------------------------------------------------

PlayR6CMusic:
	lea	MusID_R6C(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Wacky Workbench Bad Future music
; -------------------------------------------------------------------------

PlayR6DMusic:
	lea	MusID_R6D(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Stardust Speedway Present music
; -------------------------------------------------------------------------

PlayR7AMusic:
	lea	MusID_R7A(pc),a0

; -------------------------------------------------------------------------
; Loop CDDA music
; -------------------------------------------------------------------------
; PARAMETERS
;	a0.l - Pointer to music ID
; -------------------------------------------------------------------------

LoopCDDA:
	bsr.w	ResetCDDAVol			; Reset CDDA music volume
	move.w	#MSCPLAYR,d0			; Play track on loop
	jsr	_CDBIOS.w
	rts

; -------------------------------------------------------------------------
; Play Stardust Speedway Good Future music
; -------------------------------------------------------------------------

PlayR7CMusic:
	lea	MusID_R7C(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Stardust Speedway Bad Future music
; -------------------------------------------------------------------------

PlayR7DMusic:
	lea	MusID_R7D(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Metallic Madness Present music
; -------------------------------------------------------------------------

PlayR8AMusic:
	lea	MusID_R8A(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Metallic Madness Good Future music
; -------------------------------------------------------------------------

PlayR8CMusic:
	lea	MusID_R8C(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play Metallic Madness Bad Future music
; -------------------------------------------------------------------------

PlayR8DMusic:
	lea	MusID_R8D(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play boss music
; -------------------------------------------------------------------------

PlayBossMusic:
	lea	MusID_Boss(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play final boss music
; -------------------------------------------------------------------------

PlayFinalMusic:
	lea	MusID_Final(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play title screen music
; -------------------------------------------------------------------------

PlayTitleMusic:
	lea	MusID_Title(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play time attack menu music
; -------------------------------------------------------------------------

PlayTimeAtkMusic:
	lea	MusID_TimeAttack(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play level end music
; -------------------------------------------------------------------------

PlayResultsMusic:
	lea	MusID_Results(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play speed shoes music
; -------------------------------------------------------------------------

PlayShoesMusic:
	lea	MusID_Shoes(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play invincibility music
; -------------------------------------------------------------------------

PlayInvincMusic:
	lea	MusID_Invinc(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play game over music
; -------------------------------------------------------------------------

PlayGameOverMusic:
	lea	MusID_GameOver(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play special stage music
; -------------------------------------------------------------------------

PlaySpecStgMusic:
	lea	MusID_Special(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play D.A. Garden music
; -------------------------------------------------------------------------

PlayDAGardenMusic:
	lea	MusID_DAGarden(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play prototype warp sound
; -------------------------------------------------------------------------

PlayProtoWarp:
	lea	MusID_ProtoWarp(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play opening music
; -------------------------------------------------------------------------

PlayOpeningMusic:
	lea	MusID_Opening(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------
; Play ending music
; -------------------------------------------------------------------------

PlayEndingMusic:
	lea	MusID_Ending(pc),a0
	bra.s	LoopCDDA

; -------------------------------------------------------------------------

MusID_ProtoWarp:
	dc.w	CDDA_WARP			; Prototype warp
MusID_R1A:
	dc.w	CDDA_R1A			; Palmtree Panic Present
MusID_R1C:
	dc.w	CDDA_R1C			; Palmtree Panic Good Future
MusID_R1D:
	dc.w	CDDA_R1D			; Palmtree Panic Bad Future
MusID_R3A:
	dc.w	CDDA_R3A			; Collision Chaos Present
MusID_R3C:
	dc.w	CDDA_R3C			; Collision Chaos Good Future
MusID_R3D:
	dc.w	CDDA_R3D			; Collision Chaos Bad Future
MusID_R4A:
	dc.w	CDDA_R4A			; Tidal Tempest Present
MusID_R4C:
	dc.w	CDDA_R4C			; Tidal Tempest Good Future
MusID_R4D:
	dc.w	CDDA_R4D			; Tidal Tempest Bad Future
MusID_R5A:
	dc.w	CDDA_R5A			; Quartz Quadrant Present
MusID_R5C:
	dc.w	CDDA_R5C			; Quartz Quadrant Good Future
MusID_R5D:
	dc.w	CDDA_R5D			; Quartz Quadrant Bad Future
MusID_R6A:
	dc.w	CDDA_R6A			; Wacky Workbench Present
MusID_R6C:
	dc.w	CDDA_R6C			; Wacky Workbench Good Future
MusID_R6D:
	dc.w	CDDA_R6D			; Wacky Workbench Bad Future
MusID_R7A:
	dc.w	CDDA_R7A			; Stardust Speedway Present
MusID_R7C:
	dc.w	CDDA_R7C			; Stardust Speedway Good Future
MusID_R7D:
	dc.w	CDDA_R7D			; Stardust Speedway Bad Future
MusID_R8A:
	dc.w	CDDA_R8A			; Metallic Madness Present
MusID_R8C:
	dc.w	CDDA_R8C			; Metallic Madness Good Future
MusID_R8D:
	dc.w	CDDA_R8D			; Metallic Madness Bad Future
MusID_Boss:
	dc.w	CDDA_BOSS			; Boss
MusID_Final:
	dc.w	CDDA_FINAL			; Final boss
MusID_Title:
	dc.w	CDDA_TITLE			; Title screen
MusID_TimeAttack:
	dc.w	CDDA_TMATK			; Time attack menu
MusID_Results:
	dc.w	CDDA_RESULTS			; Results
MusID_Shoes:
	dc.w	CDDA_SHOES			; Speed shoes
MusID_Invinc:
	dc.w	CDDA_INVINC			; Invincibility
MusID_GameOver:
	dc.w	CDDA_GAMEOVER			; Game over
MusID_Special:
	dc.w	CDDA_SPECIAL			; Special stage
MusID_DAGarden:
	dc.w	CDDA_DAGARDEN			; D.A. Garden
MusID_Opening:
	dc.w	CDDA_INTRO			; Opening
MusID_Ending:
	dc.w	CDDA_ENDING			; Ending

; -------------------------------------------------------------------------
; Reset CDDA music volume
; -------------------------------------------------------------------------

ResetCDDAVol:
	move.l	a0,-(sp)
	
	move.w	#FDRSET,d0			; Set CDDA music volume
	move.w	#$400,d1
	jsr	_CDBIOS.w

	move.w	#FDRSET,d0			; Set CDDA music master volume
	move.w	#$8400,d1
	jsr	_CDBIOS.w

	movea.l	(sp)+,a0
	rts

; -------------------------------------------------------------------------
; Planet data
; -------------------------------------------------------------------------

PlanetData:
	dc.l Stamps_Present, Stamps_PresGFAnim,	StampMap_Present
	dc.l Stamps_GoodFuture,	Stamps_PresGFAnim, StampMap_GoodFuture
	dc.l Stamps_BadFuture, Stamps_BadFutAnim, StampMap_BadFuture
	
; -------------------------------------------------------------------------
; Data
; -------------------------------------------------------------------------

Stamps_Present:
	incbin	"DA Garden/Data/Stamps (Present).kos"
	align	$10
	
Stamps_GoodFuture:
	incbin	"DA Garden/Data/Stamps (Good Future).kos"
	align	$10

Stamps_BadFuture:
	incbin	"DA Garden/Data/Stamps (Bad Future).kos"
	align	$10

StampMap_Present:
	incbin	"DA Garden/Data/Stamp Map (Present).bin"
	even
	
StampMap_GoodFuture:
	incbin	"DA Garden/Data/Stamp Map (Good Future).bin"
	even
	
StampMap_BadFuture:
	incbin	"DA Garden/Data/Stamp Map (Bad Future).bin"
	even
	
Stamps_PresGFAnim:
	incbin	"DA Garden/Data/Stamps (Animation, Present, Good Future).kos"
	align	$10
	
Stamps_BadFutAnim:
	incbin	"DA Garden/Data/Stamps (Animation, Bad Future).kos"
	align	$10

; -------------------------------------------------------------------------
