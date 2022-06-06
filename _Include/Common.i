; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Common definitions
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Regions
; -------------------------------------------------------------------------

JAPAN		EQU	0
USA		EQU	1
EUROPE		EQU	2

; -------------------------------------------------------------------------
; Align
; -------------------------------------------------------------------------
; PARAMETERS:
;	bound - Size boundary
;	value - (OPTIONAL) Value to pad with
; -------------------------------------------------------------------------

ALIGN macro bound, value
	local	pad
pad	=	((\bound)-((*)%(\bound)))%(\bound)
	if narg>1
		dcb.b	pad,\value
	else
		dcb.b	pad,0
	endif
	endm

; -------------------------------------------------------------------------
; Pad RS to even address
; -------------------------------------------------------------------------

RSEVEN macros
	rs.b	__rs&1

; -------------------------------------------------------------------------
; Generate repeated RS structure entries
; -------------------------------------------------------------------------
; PARAMETERS:
;	name  - Entry name base
;	count - Number of entries
;	size  - Size of entry
; -------------------------------------------------------------------------

RSRPT macro name, count, size
	local cnt
cnt	=	0
	rept	\count
\name\\$cnt	rs.\0	\size
cnt		=	cnt+1
	endr
	endm

; -------------------------------------------------------------------------
; Store string with static size
; -------------------------------------------------------------------------
; PARAMETERS:
;	len - Length of string
;	str - String to store
; -------------------------------------------------------------------------

STRSZ macro len, str
	local	len2, str2
	if strlen(\str)>(\len)
len2		=	\len
str2		SUBSTR	1,\len,\str
	else
len2		= 	strlen(\str)
str2		EQUS	\str
	endif
	dc.b	"\str2"
	dcb.b	\len-len2, " "
	endm

; -------------------------------------------------------------------------
; Store number with static number of digits
; -------------------------------------------------------------------------
; PARAMETERS:
;	digits - Number of digits
;	num    - Number to store
; -------------------------------------------------------------------------

NUMSTR macro digits, num
	local	num2, digits2, mask
num2	=	\num
digits2	=	1
mask	=	10
	while	(num2<>0)&(digits2<(\digits))
num2		=	num2/10
mask		=	mask*10
digits2		=	digits2+1
	endw
num2	=	(\num)%mask
	dcb.b	(\digits)-strlen("\#num2"), "0"
	dc.b	"\#num2"
	endm

; -------------------------------------------------------------------------
; Store month string
; -------------------------------------------------------------------------

MNTHSTR macro month
	local	mthstr
mthstr	SUBSTR	1+((\month)*3), 3+((\month)*3), &
	"JANFEBMARAPRMAYJUNJULAUGSEPOCTNOVDEC"
	dc.b	"\mthstr"
	endm

; -------------------------------------------------------------------------
