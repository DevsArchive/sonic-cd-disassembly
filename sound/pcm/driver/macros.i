; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; SMPS-PCM driver macros
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Sample table start
; -------------------------------------------------------------------------

SAMPTBLSTART macro
SampleTable:
	dc.l	(SampleTable_End-SampleTable)/4-1	; BUG: that "-1" shouldn't be there
	endm

; -------------------------------------------------------------------------
; Sample table end
; -------------------------------------------------------------------------

SAMPTBLEND macro
SampleTable_End:
	endm

; -------------------------------------------------------------------------
; Sample index entry
; -------------------------------------------------------------------------
; PARAMETERS:
;	name     - Sample name
;	loop     - Loop point
;	staccato - Staccato time
;	mode     - Sample mode (0 = stream, else static)
;	dest     - Destination address (only if static)
; -------------------------------------------------------------------------

SAMPLE macro name, loop, staccato, mode, dest
\name\_Metadata:
	dc.l	\name
	dc.l	(\name\_End)-(\name\)
	dc.l	\loop
	dc.b	\staccato
	dc.b	\mode
	dc.w	\dest
	endm

; -------------------------------------------------------------------------
; Sample data
; -------------------------------------------------------------------------
; PARAMETERS:
;	name - Sample name
;	file - File path
; -------------------------------------------------------------------------

SAMPDAT macro name, file
\name\:
	incbin	\file
\name\_End:
	endm

; -------------------------------------------------------------------------
