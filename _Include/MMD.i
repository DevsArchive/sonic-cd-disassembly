; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; MMD format definitions
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Flags
; -------------------------------------------------------------------------

MMDSUB		EQU	6			; Sub CPU Word RAM access flag
MMDSUBM		EQU	1<<MMDSUB		; Sub CPU Word RAM access flag mask

; -------------------------------------------------------------------------
; MMD header structure
; -------------------------------------------------------------------------

	rsreset
mmdFlags	rs.b	1			; Flags
		rs.b	1
mmdOrigin	rs.l	1			; Origin address
mmdSize		rs.w	1			; Size of file data
mmdEntry	rs.l	1			; Entry address
mmdHInt		rs.l	1			; H-BLANK interrupt address
mmdVInt		rs.l	1			; V-BLANK interrupt address
		rs.b	$100-__rs
mmdFile		rs.b	0			; Start of file data
MMDHEADSZ	rs.b	0			; Size of structure

; -------------------------------------------------------------------------
; MMD header
; -------------------------------------------------------------------------
; PARAMETERS:
;	flags  - Flags
;	origin - Origin address
;	size   - Size of file data (if origin is not Word RAM)
;	entry  - Entry address
;	hint   - H-BLANK interrupt address
;	vint   - V-BLANK interrupt address
; -------------------------------------------------------------------------

MMD macro flags, origin, size, entry, hint, vint
	if (\origin)=WORDRAM2M
		org	WORDRAM2M
	else
		org	(\origin)-MMDHEADSZ
	endif

	dc.b	\flags, 0
	if (\origin)=WORDRAM2M
		dc.l	0
		dc.w	0
	else
		dc.l	\origin
		dc.w	(\size)/4-1
	endif
	dc.l	\entry, \hint, \vint

	ALIGN	MMDHEADSZ
	endm

; -------------------------------------------------------------------------
