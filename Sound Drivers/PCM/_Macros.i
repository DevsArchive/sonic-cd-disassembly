; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; SMPS-PCM driver macros
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Sample index start
; -------------------------------------------------------------------------

SAMPTBLSTART macro
sampCount = 0
SampleTable:
	dc.l	(SampleTable_End-SampleTable)/4-1	; BUG: that "-1" shouldn't be there
	endm

; -------------------------------------------------------------------------
; Sample index end
; -------------------------------------------------------------------------

SAMPTBLEND macro
SampleTable_End:
	endm

; -------------------------------------------------------------------------
; Sample index entry
; -------------------------------------------------------------------------
; PARAMETERS:
;	name - Sample name
; -------------------------------------------------------------------------

SAMPPTR macro name
s\name\	EQU	sampCount
sampCount = sampCount+1
	dc.l	Samp_\name\_Metadata
	endm

; -------------------------------------------------------------------------
; Sample metadata
; -------------------------------------------------------------------------
; PARAMETERS:
;	name     - Sample name
;	loop     - Loop point
;	staccato - Staccato time
;	mode     - Sample mode (0 = stream, else static)
;	dest     - Destination address (only if static)
; -------------------------------------------------------------------------

SAMPLE macro name, loop, staccato, mode, dest
Samp_\name\_Metadata:
	dc.l	Samp_\name
	dc.l	(Samp_\name\_End)-(Samp_\name\)
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
Samp_\name\:
	incbin	\file
Samp_\name\_End:
	endm

; -------------------------------------------------------------------------
