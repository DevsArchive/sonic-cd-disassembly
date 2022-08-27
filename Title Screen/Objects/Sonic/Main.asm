; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Sonic object (title screen)
; -------------------------------------------------------------------------

	rsset	oVars
oSonicDelay	rs.b	1			; Animation delay

; -------------------------------------------------------------------------

ObjSonic:
	move.l	#MapSpr_Sonic,oMap(a0)		; Set mappings
	move.w	#$E000|($6D00/$20),oTile(a0)	; Set sprite tile ID
	move.b	#%11,oFlags(a0)			; Set flags
	move.w	#91,oX(a0)			; Set X position
	move.w	#15,oY(a0)			; Set Y position

	move.b	#2,oSonicDelay(a0)		; Set animation delay

; -------------------------------------------------------------------------

.Frame0Delay:
	bsr.w	BookmarkObject			; Set bookmark
	subq.b	#1,oSonicDelay(a0)		; Decrement delay timer
	bne.s	.Frame0Delay			; If it hasn't run out, branch

	addq.b	#1,oMapFrame(a0)		; Set next sprite frame
	move.b	#3,oSonicDelay(a0)		; Reset animation delay

; -------------------------------------------------------------------------

.Frame1Delay:
	bsr.w	BookmarkObject			; Set bookmark
	subq.b	#1,oSonicDelay(a0)		; Decrement delay timer
	bne.s	.Frame1Delay			; If it hasn't run out, branch

	move.l	a0,-(sp)			; Load background mountains art
	VDPCMD	move.l,$6000,VRAM,WRITE,VDPCTRL
	lea	Art_Mountains(pc),a0
	bsr.w	NemDec
	movea.l	(sp)+,a0

	addq.b	#1,oMapFrame(a0)		; Set next sprite frame
	move.b	#2,oSonicDelay(a0)		; Reset animation delay

; -------------------------------------------------------------------------

.Frame2Delay:
	bsr.w	BookmarkObject			; Set bookmark
	subq.b	#1,oSonicDelay(a0)		; Decrement delay timer
	bne.s	.Frame2Delay			; If it hasn't run out, branch

	move.l	a0,-(sp)			; Load background mountains art
	VDPCMD	move.l,$6B00,VRAM,WRITE,VDPCTRL
	lea	Art_Water(pc),a0
	bsr.w	NemDec
	movea.l	(sp)+,a0

	addq.b	#1,oMapFrame(a0)		; Set next sprite frame
	move.b	#1,oSonicDelay(a0)		; Reset animation delay

; -------------------------------------------------------------------------

.Frame3Delay:
	bsr.w	BookmarkObject			; Set bookmark
	subq.b	#1,oSonicDelay(a0)		; Decrement delay timer
	bne.s	.Frame3Delay			; If it hasn't run out, branch

	bset	#7,titleMode.w			; Mark Sonic as turned around
	
	lea	ObjSonicArm(pc),a2		; Spawn Sonic's arm
	bsr.w	SpawnObject
	move.w	a0,oArmParent(a1)

	lea	ObjBanner,a2			; Spawn banner
	bsr.w	SpawnObject
	
	addq.b	#1,oMapFrame(a0)		; Set next sprite frame
	move.b	#$14,oSonicDelay(a0)		; Reset animation delay

; -------------------------------------------------------------------------

.Frame4Delay:
	bsr.w	BookmarkObject			; Set bookmark
	subq.b	#1,oSonicDelay(a0)		; Decrement delay timer
	bne.s	.Frame4Delay			; If it hasn't run out, branch
	
	addq.b	#1,oMapFrame(a0)		; Set next sprite frame
	move.b	#4,oSonicDelay(a0)		; Reset animation delay

; -------------------------------------------------------------------------

.Frame5Delay:
	bsr.w	BookmarkObject			; Set bookmark
	subq.b	#1,oSonicDelay(a0)		; Decrement delay timer
	bne.s	.Frame5Delay			; If it hasn't run out, branch
	
	move.b	#4,oMapFrame(a0)		; Go back to frame 4

; -------------------------------------------------------------------------

.Done:
	bsr.w	BookmarkObject			; Set bookmark
	bra.s	.Done				; Remain static

; -------------------------------------------------------------------------
; Sonic mappings
; -------------------------------------------------------------------------

MapSpr_Sonic:
	include	"Title Screen/Objects/Sonic/Data/Mappings.asm"
	even

; -------------------------------------------------------------------------
; Sonic's arm object
; -------------------------------------------------------------------------

	rsset	oVars
oArmDelay	rs.b	1			; Delay counter
		rs.b	3			; Unused
oArmFrame	rs.b	1			; Animatiom frame
		rs.b	3			; Unused
oArmParent	rs.w	1			; Parent object

; -------------------------------------------------------------------------

ObjSonicArm:
	move.l	#MapSpr_Sonic,oMap(a0)		; Set mappings
	move.w	#$E000|($6D00/$20),oTile(a0)	; Set sprite tile ID
	move.b	#%11,oFlags(a0)			; Set flags
	move.w	#140,oX(a0)			; Set X position
	move.w	#104,oY(a0)			; Set Y position
	move.b	#9,oMapFrame(a0)		; Set sprite frame

; -------------------------------------------------------------------------

.Delay:
	bsr.w	BookmarkObject			; Set bookmark
	addi.b	#$12,oArmDelay(a0)		; Increment delay counter
	bcc.s	.Delay				; If it hasn't overflowed, loop

; -------------------------------------------------------------------------

.Animate:
	moveq	#0,d0				; Get animation frame
	move.b	oArmFrame(a0),d0
	move.b	.Frames(pc,d0.w),oMapFrame(a0)

	addq.b	#1,d0				; Increment animation frame ID
	cmpi.b	#.FramesEnd-.Frames,d0		; Are we at the end of the animation?
	bcc.s	.Done				; If so, branch
	move.b	d0,oArmFrame(a0)		; Update animation frame ID
	
	bsr.w	BookmarkObject			; Set bookmark
	bra.s	.Animate			; Animate

; -------------------------------------------------------------------------

.Done:
	bsr.w	BookmarkObject			; Set bookmark
	bra.s	.Done				; Remain static

; -------------------------------------------------------------------------

.Frames:
	dc.b	9, 8, 7, 6, 6, 7, 8, 9
	dc.b	9, 8, 7, 6, 6, 7, 8, 9
.FramesEnd:

; -------------------------------------------------------------------------
