; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Title screen menu sprite mappings
; -------------------------------------------------------------------------

.Map:
	dc.w	.Frame0-MapSpr_Menu
	dc.w	.Frame1-MapSpr_Menu
	dc.w	.Frame2-MapSpr_Menu
	dc.w	.Frame3-MapSpr_Menu
	dc.w	.Frame4-MapSpr_Menu
	dc.w	.Frame5-MapSpr_Menu
	dc.w	.Frame6-MapSpr_Menu
	dc.w	.Frame7-MapSpr_Menu

.Frame0:
	dc.b	0
	even

.Frame1:
	dc.b	4
	dc.b	0, $D, 0, 0, 0
	dc.b	0, 1, 0, 6, $20
	dc.b	0, 1, 0, 6, $30
	dc.b	0, $D, 0, 8, $38
	even

.Frame2:
	dc.b	3
	dc.b	0, $D, 0, 0, $A
	dc.b	0, $D, 0, 8, $2A
	dc.b	0, 1, 0, $10, $4A
	even

.Frame3:
	dc.b	2
	dc.b	0, $D, 0, 0, $D
	dc.b	0, $D, 0, 8, $2D
	even

.Frame4:
	dc.b	3
	dc.b	0, $D, 0, 0, 2
	dc.b	0, $D, 0, 8, $22
	dc.b	0, 9, 0, $10, $42
	even

.Frame5:
	dc.b	3
	dc.b	0, $D, 0, 0, $D
	dc.b	0, $D, 0, 8, $2D
	dc.b	0, 1, 0, $10, $4D
	even

.Frame6:
	dc.b	3
	dc.b	0, $D, 0, 0, 6
	dc.b	0, $D, 0, 8, $26
	dc.b	0, 5, 0, $10, $46
	even

.Frame7:
	dc.b	3
	dc.b	0, $D, 0, 0, 4
	dc.b	0, $D, 0, 8, $24
	dc.b	0, 9, 0, $10, $44
	even

; -------------------------------------------------------------------------
