; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Copyright text object (title screen)
; -------------------------------------------------------------------------

ObjCopyright:
	move.l	#MapSpr_Copyright,oMap(a0)	; Set mappings
	move.w	#$E000|($DE00/$20),oTile(a0)	; Set sprite tile ID
	move.b	#%1,oFlags(a0)			; Set flags
	if REGION=USA
		move.w	#208,oY(a0)		; Set Y position
		move.w	#80,oX(a0)		; Set X position
		move.b	#1,oMapFrame(a0)	; Display with trademark
	else
		move.w	#91,oX(a0)		; Set X position
		move.w	#208,oY(a0)		; Set Y position
	endif

; -------------------------------------------------------------------------

.Done:
	bsr.w	BookmarkObject			; Set bookmark
	bra.s	.Done				; Remain static

; -------------------------------------------------------------------------
; Copyright text mappings
; -------------------------------------------------------------------------

MapSpr_Copyright:
	if REGION=USA
		include	"Title Screen/Objects/Copyright/Data/Mappings (Copyright, USA).asm"
	else
		include	"Title Screen/Objects/Copyright/Data/Mappings (Copyright, JPN and EUR).asm"
	endif
	even

; -------------------------------------------------------------------------
; Trademark symbol object
; -------------------------------------------------------------------------

ObjTM:
	move.l	#MapSpr_TM,oMap(a0)		; Set mappings
	if REGION=USA				; Set sprite tile ID
		move.w	#$E000|($DFC0/$20),oTile(a0)
	else
		move.w	#$E000|($DF20/$20),oTile(a0)
	endif
	move.b	#%1,oFlags(a0)			; Set flags
	move.w	#194,oX(a0)			; Set X position
	move.w	#131,oY(a0)			; Set Y position
	
; -------------------------------------------------------------------------

.Done:
	bsr.w	BookmarkObject			; Set bookmark
	bra.s	.Done				; Remain static

; -------------------------------------------------------------------------
; Trademark symbol mappings
; -------------------------------------------------------------------------

MapSpr_TM:
	include	"Title Screen/Objects/Copyright/Data/Mappings (TM).asm"
	even

; -------------------------------------------------------------------------
