; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Wacky Workbench Act 1 object layout
; -------------------------------------------------------------------------

ObjectLayouts:
	dc.w	.Layout-ObjectLayouts
	dc.w	.Null-ObjectLayouts

; -------------------------------------------------------------------------

	dc.w	$FFFF, 0, 0, 0
	
.Layout:
	incbin	"Level/Wacky Workbench/Data/Objects (Act 1).bin"

.Null:
	dc.w	$FFFF, 0, 0

; -------------------------------------------------------------------------
