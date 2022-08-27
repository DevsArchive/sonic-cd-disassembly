; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Banner object (title screen)
; -------------------------------------------------------------------------

ObjBanner:
	move.l	#MapSpr_Banner,oMap(a0)		; Set mappings
	move.w	#$A000|($F000/$20),oTile(a0)	; Set sprite tile ID
	move.b	#%11,oFlags(a0)			; Set flags
	move.w	#127,oX(a0)			; Set X position
	move.w	#127,oY(a0)			; Set Y position

; -------------------------------------------------------------------------

.Done:
	jsr	BookmarkObject(pc)		; Set bookmark
	bra.s	.Done				; Remain static

; -------------------------------------------------------------------------
; Banner mappings
; -------------------------------------------------------------------------

MapSpr_Banner:
	include	"Title Screen/Objects/Banner/Data/Mappings.asm"
	even

; -------------------------------------------------------------------------
