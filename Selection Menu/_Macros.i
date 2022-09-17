; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Sound test macros
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Start text string list
; -------------------------------------------------------------------------

__textListID = 0
TEXTSTART macro
	__textListCnt: = -1
	dc.w	__textListCnt\#__textListID
	endm

; -------------------------------------------------------------------------
; End text string list
; -------------------------------------------------------------------------

TEXTEND macro
	__textListCnt\#__textListID\:	EQU __textListCnt
	__textListID: = __textListID+1
	endm

; -------------------------------------------------------------------------
; Start text string list
; -------------------------------------------------------------------------
; PARAMETERS:
;	ptr - Pointer to string
;	x   - X location
;	y   - Y location
; -------------------------------------------------------------------------

TEXTPTR macro ptr, x, y
	dc.l	\ptr
	VDPCMD	dc.l,$C000+((\x)*2)+((\y)*$80),VRAM,WRITE
	VDPCMD	dc.l,$C000+((\x)*2)+(((\y)+1)*$80),VRAM,WRITE
	__textListCnt: = __textListCnt+1
	endm

; -------------------------------------------------------------------------
; Store text string
; -------------------------------------------------------------------------
; PARAMETERS:
;	str - String
; -------------------------------------------------------------------------

TEXTSTR macro str
	local	c, i
	i: = 0
	rept	strlen(\str)
		c: SUBSTR 1+i, 1+i, \str
		if '\c'='-'
			dc.b	$25
		elseif '\c'=','
			dc.b	$26
		elseif '\c'='.'
			dc.b	$27
		elseif '\c'="'"
			dc.b	$28
		elseif '\c'='"'
			dc.b	$29
		elseif '\c'='!'
			dc.b	$2A
		elseif '\c'='?'
			dc.b	$2B
		elseif '\c'='x'
			dc.b	$2C
		elseif ('\c'>='0')&('\c'<='9')
			dc.b	'\c'-'0'+1
		elseif ('\c'>='A')&('\c'<='z')
			dc.b	'\c'-'A'+$B
		elseif ('\c'>='a')&('\c'<='z')&('\c'<>'x')
			dc.b	'\c'-'a'+$B
		else
			dc.b	0
		endif
		i: = i+1
	endr
	dc.b	$FF
	endm

; -------------------------------------------------------------------------
