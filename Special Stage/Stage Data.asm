; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Special stage data
; -------------------------------------------------------------------------

	include	"_Include/Common.i"
	include	"_Include/Main CPU.i"
	include	"_Include/Main CPU Variables.i"
	include	"Special Stage/_Global Variables.i"

; -------------------------------------------------------------------------

	org	SpecStageData
	
	dc.l	SS1Data
	dc.w	SS1DataEnd-SS1Data
	dc.l	SS2Data
	dc.w	SS2DataEnd-SS2Data
	dc.l	SS3Data
	dc.w	SS3DataEnd-SS3Data
	dc.l	SS4Data
	dc.w	SS4DataEnd-SS4Data
	dc.l	SS5Data
	dc.w	SS5DataEnd-SS5Data
	dc.l	SS6Data
	dc.w	SS6DataEnd-SS6Data
	dc.l	SS7Data
	dc.w	SS7DataEnd-SS7Data
	dc.l	SS8Data
	dc.w	SS8DataEnd-SS8Data
	
; -------------------------------------------------------------------------
; Special stage 1
; -------------------------------------------------------------------------

SS1Data:
	obj	(WORKRAMFILE-$100)+SpecStgDataCopy

Pal_SS1:
	incbin	"Special Stage/Data/Stage 1/Palette.bin"
	even
Art_SS1BG:
	incbin	"Special Stage/Data/Stage 1/Background Art.nem"
	even
Map_SS1BGA1:
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 1/Background Chunk A1.kos"
	even
Map_SS1BGA2:					; Unused
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 1/Background Chunk A2.kos"
	even
Map_SS1BGA3:
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 1/Background Chunk A3.kos"
	even
Map_SS1BGA4:					; Unused
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 1/Background Chunk A4.kos"
	even
Map_SS1BGB1:
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 1/Background Chunk B1.kos"
	even
Map_SS1BGB2:
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 1/Background Chunk B2.kos"
	even

	objend
SS1DataEnd:
	
; -------------------------------------------------------------------------
; Special stage 2
; -------------------------------------------------------------------------
	
SS2Data:
	obj	(WORKRAMFILE-$100)+SpecStgDataCopy

Pal_SS2:
	incbin	"Special Stage/Data/Stage 2/Palette.bin"
	even
Art_SS2BG:
	incbin	"Special Stage/Data/Stage 2/Background Art.nem"
	even
Map_SS2BGA1:
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 2/Background Chunk A1.kos"
	even
Map_SS2BGA2:
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 2/Background Chunk A2.kos"
	even
Map_SS2BGA3:					; Unused
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 2/Background Chunk A3.kos"
	even
Map_SS2BGA4:					; Unused
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 2/Background Chunk A4.kos"
	even
Map_SS2BGB1:
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 2/Background Chunk B1.kos"
	even
Map_SS2BGB2:
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 2/Background Chunk B2.kos"
	even
Map_SS2BGB3:
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 2/Background Chunk B3.kos"
	even

	objend
SS2DataEnd:

; -------------------------------------------------------------------------
; Special stage 3
; -------------------------------------------------------------------------

SS3Data:
	obj	(WORKRAMFILE-$100)+SpecStgDataCopy

Pal_SS3:
	incbin	"Special Stage/Data/Stage 3/Palette.bin"
	even
Art_SS3BG:
	incbin	"Special Stage/Data/Stage 3/Background Art.nem"
	even
Map_SS3BGA1:
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 3/Background Chunk A1.kos"
	even
Map_SS3BGA2:
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 3/Background Chunk A2.kos"
	even
Map_SS3BGA3:					; Unused
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 3/Background Chunk A3.kos"
	even
Map_SS3BGA4:					; Unused
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 3/Background Chunk A4.kos"
	even
Map_SS3BGB1:
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 3/Background Chunk B1.kos"
	even
Map_SS3BGB2:
	dc.w	0				; Uncompressed
	incbin	"Special Stage/Data/Stage 3/Background Chunk B2.bin"
	even
Map_SS3BGB3:
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 3/Background Chunk B3.kos"
	even
Map_SS3BGB4:
	dc.w	0				; Uncompressed
	incbin	"Special Stage/Data/Stage 3/Background Chunk B4.bin"
	even
Map_SS3BGB5:
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 3/Background Chunk B5.kos"
	even

	objend
SS3DataEnd:

; -------------------------------------------------------------------------
; Special stage 4
; -------------------------------------------------------------------------

SS4Data:
	obj	(WORKRAMFILE-$100)+SpecStgDataCopy

Pal_SS4:
	incbin	"Special Stage/Data/Stage 4/Palette.bin"
	even
Art_SS4BG:
	incbin	"Special Stage/Data/Stage 4/Background Art.nem"
	even
Map_SS4BGA1:
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 4/Background Chunk A1.kos"
	even
Map_SS4BGA2:
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 4/Background Chunk A2.kos"
	even
Map_SS4BGB1:
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 4/Background Chunk B1.kos"
	even
Map_SS4BGB2:
	dc.w	0				; Uncompressed
	incbin	"Special Stage/Data/Stage 4/Background Chunk B2.bin"
	even
Map_SS4BGB3:
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 4/Background Chunk B3.kos"
	even
Map_SS4BGB4:
	dc.w	0				; Uncompressed
	incbin	"Special Stage/Data/Stage 4/Background Chunk B4.bin"
	even
Map_SS4BGB5:					; Unused
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 4/Background Chunk B5.kos"
	even
Map_SS4BGB6:					; Unused
	dc.w	0				; Uncompressed
	incbin	"Special Stage/Data/Stage 4/Background Chunk B6.bin"
	even
Map_SS4BGB7:					; Unused
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 4/Background Chunk B7.kos"
	even
Map_SS4BGB8:					; Unused
	dc.w	0				; Uncompressed
	incbin	"Special Stage/Data/Stage 4/Background Chunk B8.bin"
	even

	objend
SS4DataEnd:

; -------------------------------------------------------------------------
; Special stage 5
; -------------------------------------------------------------------------

SS5Data:
	obj	(WORKRAMFILE-$100)+SpecStgDataCopy

Pal_SS5:
	incbin	"Special Stage/Data/Stage 5/Palette.bin"
	even
Art_SS5BG:
	incbin	"Special Stage/Data/Stage 5/Background Art.nem"
	even
Map_SS5BGA1:
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 5/Background Chunk A1.kos"
	even
Map_SS5BGA2:
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 5/Background Chunk A2.kos"
	even
Map_SS5BGA3:					; Unused
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 5/Background Chunk A3.kos"
	even
Map_SS5BGA4:					; Unused
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 5/Background Chunk A4.kos"
	even
Map_SS5BGB1:
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 5/Background Chunk B1.kos"
	even
Map_SS5BGB2:
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 5/Background Chunk B2.kos"
	even
Map_SS5BGB3:
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 5/Background Chunk B3.kos"
	even

	objend
SS5DataEnd:

; -------------------------------------------------------------------------
; Special stage 6
; -------------------------------------------------------------------------

SS6Data:
	obj	(WORKRAMFILE-$100)+SpecStgDataCopy

Pal_SS6:
	incbin	"Special Stage/Data/Stage 6/Palette.bin"
	even
Art_SS6BG:
	incbin	"Special Stage/Data/Stage 6/Background Art (Main).nem"
	even
Map_SS6BGA1:
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 6/Background Chunk A1.kos"
	even
Map_SS6BGA2:
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 6/Background Chunk A2.kos"
	even
Map_SS6BGA3:					; Unused
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 6/Background Chunk A3.kos"
	even
Map_SS6BGA4:					; Unused
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 6/Background Chunk A4.kos"
	even
Map_SS6BGB1:
	dc.w	0				; Uncompressed
	incbin	"Special Stage/Data/Stage 6/Background Chunk B1.bin"
	even

	objend
SS6DataEnd:

; -------------------------------------------------------------------------
; Special stage 7
; -------------------------------------------------------------------------

SS7Data:
	obj	(WORKRAMFILE-$100)+SpecStgDataCopy

Pal_SS7:
	incbin	"Special Stage/Data/Stage 7/Palette.bin"
	even
Art_SS7BG:
	incbin	"Special Stage/Data/Stage 7/Background Art.nem"
	even
Map_SS7BGA1:
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 7/Background Chunk A1.kos"
	even
Map_SS7BGA2:					; Unused
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 7/Background Chunk A2.kos"
	even
Map_SS7BGA3:
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 7/Background Chunk A3.kos"
	even
Map_SS7BGA4:					; Unused
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 7/Background Chunk A4.kos"
	even
Map_SS7BGB1:
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 7/Background Chunk B1.kos"
	even
Map_SS7BGB2:
	dc.w	0				; Uncompressed
	incbin	"Special Stage/Data/Stage 7/Background Chunk B2.bin"
	even
Map_SS7BGB3:
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 7/Background Chunk B3.kos"
	even
Map_SS7BGB4:
	dc.w	0				; Uncompressed
	incbin	"Special Stage/Data/Stage 7/Background Chunk B4.bin"
	even
Map_SS7BGB5:					; Unused
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 7/Background Chunk B5.kos"
	even
Map_SS7BGB6:					; Unused
	dc.w	0				; Uncompressed
	incbin	"Special Stage/Data/Stage 7/Background Chunk B6.bin"
	even
Map_SS7BGB7:					; Unused
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 7/Background Chunk B7.kos"
	even
Map_SS7BGB8:					; Unused
	dc.w	0				; Uncompressed
	incbin	"Special Stage/Data/Stage 7/Background Chunk B8.bin"
	even
Map_SS7BGB9:
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 7/Background Chunk B9.kos"
	even
	
	objend
SS7DataEnd:

; -------------------------------------------------------------------------
; Special stage 8
; -------------------------------------------------------------------------

SS8Data:
	obj	(WORKRAMFILE-$100)+SpecStgDataCopy

Pal_SS8:
	incbin	"Special Stage/Data/Stage 8/Palette.bin"
	even
Art_SS8BG:
	incbin	"Special Stage/Data/Stage 8/Background Art.nem"
	even
Map_SS8BGB1:
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 8/Background Chunk B1.kos"
	even
Map_SS8BGB2:
	dc.w	1				; Compressed
	incbin	"Special Stage/Data/Stage 8/Background Chunk B2.kos"
	even

	objend
SS8DataEnd:

; -------------------------------------------------------------------------
