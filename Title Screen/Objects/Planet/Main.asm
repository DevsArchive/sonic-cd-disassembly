; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Planet object (title screen)
; -------------------------------------------------------------------------

	rsset	oVars
oPlanetOff	rs.b	1			; Offset
oPlanetDelay	rs.b	1			; Delay counter
		rs.b	4
oPlanetY	rs.w	1			; Y position

; -------------------------------------------------------------------------

ObjPlanet:
	bsr.w	BookmarkObject			; Set bookmark
	
	move.l	a0,-(sp)			; Load planet art	
	VDPCMD	move.l,$8040,VRAM,WRITE,VDPCTRL
	lea	Art_Planet(pc),a0
	bsr.w	NemDec
	movea.l	(sp)+,a0
	
	move.l	#MapSpr_Planet,oMap(a0)		; Set mappings
	move.w	#$6000|($8040/$20),oTile(a0)	; Set sprite tile ID
	move.b	#%1,oFlags(a0)			; Set flags
	move.w	#226,oX(a0)			; Set X position
	move.w	#24,oY(a0)			; Set Y position
	move.w	oY(a0),oPlanetY(a0)

; -------------------------------------------------------------------------

.Hover:
	addi.b	#$40,oPlanetDelay(a0)		; Increment delay counter
	bcc.s	.Exit				; If it hasn't overflowed, branch

	moveq	#0,d0				; Get offset value
	move.b	oPlanetOff(a0),d0
	move.b	.Offsets(pc,d0.w),d0
	ext.w	d0
	add.w	d0,oY(a0)

	move.b	oPlanetOff(a0),d0		; Next offset
	addq.b	#1,d0
	andi.b	#$1F,d0
	move.b	d0,oPlanetOff(a0)

.Exit:
	jsr	BookmarkObject(pc)		; Set bookmark
	bra.s	.Hover				; Handle hovering

; -------------------------------------------------------------------------

.Offsets:
	dc.b	0, 0, 0, -1
	dc.b	0, 0, 0, -1
	dc.b	0, 0, 0, -1
	dc.b	0, 0, 0, 0
	dc.b	0, 0, 0, 0
	dc.b	1, 0, 0, 0
	dc.b	1, 0, 0, 0
	dc.b	1, 0, 0, 0

; -------------------------------------------------------------------------
; Planet mappings
; -------------------------------------------------------------------------

MapSpr_Planet:
	include	"Title Screen/Objects/Planet/Data/Mappings.asm"
	even

; -------------------------------------------------------------------------
