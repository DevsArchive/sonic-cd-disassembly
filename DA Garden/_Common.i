; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Common DA Garden definitions
; -------------------------------------------------------------------------

TRACETBL	EQU	$19A00			; Trace table
IMGBUFFER	EQU	$1A000			; Image buffer
STAMPMAP	EQU	$20000			; Stamp map

IMGWIDTH	EQU	256			; Image buffer width
IMGHEIGHT	EQU	176			; Image buffer height
IMGWTILE	EQU	IMGWIDTH/8		; Image buffer width in tiles
IMGHTILE	EQU	IMGHEIGHT/8		; Image buffer height in tiles

IMGLENGTH	EQU	IMGWTILE*IMGHTILE*$20	; Image buffer length in bytes

; -------------------------------------------------------------------------
