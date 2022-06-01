; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Title screen menu arrow sprite mappings
; -------------------------------------------------------------------------

.Map:
	dc.w	.Frame0-.Map
	dc.w	.Frame1-.Map
	dc.w	.Frame2-.Map
	dc.w	.Frame3-.Map
	dc.w	.Frame4-.Map
	dc.w	.Frame5-.Map
	dc.w	.Frame6-.Map

.Frame0:
	dc.b 0
	even

.Frame1:
	dc.b 1
	dc.b 0, 5, 0, 0, 0
	even

.Frame2:
	dc.b 1
	dc.b 0, 5, 0, 0, $FE
	even

.Frame3:
	dc.b 1
	dc.b 0, 5, 0, 0, $FC
	even
	
.Frame4:
	dc.b 1
	dc.b 0, 5, 8, 0, 0
	even
	
.Frame5:
	dc.b 1
	dc.b 0, 5, 8, 0, 2
	even
	
.Frame6:
	dc.b 1
	dc.b 0, 5, 8, 0, 4
	even
	
; -------------------------------------------------------------------------
