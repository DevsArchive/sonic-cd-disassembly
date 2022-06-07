; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Palmtree Panic Past collapsing platform object data
; -------------------------------------------------------------------------

MapSpr_CollapsePlatform1:
	include	"Level/Palmtree Panic/Objects/Collapsing Platform/Data/Mappings (Ledge, Past).asm"
	even

ObjCollapsePlatform_Sizes1:
	dc.w	byte_20C446-ObjCollapsePlatform_Sizes1
	dc.w	byte_20C45C-ObjCollapsePlatform_Sizes1
byte_20C446:
	dc.b	4,   3
	dc.b	$FF, $FF
	dc.b	0,   0
	dc.b	0,   1
	dc.b	2,   3
	dc.b	3,   4
	dc.b	0,   5
	dc.b	5,   5
	dc.b	5,   6
	dc.b	6,   6
	dc.b	6,   6
byte_20C45C:
	dc.b	3,   2
	dc.b	1,   2
	dc.b	3,   3
	dc.b	5,   5
	dc.b	5,   5
	dc.b	6,   6
	dc.b	6,   6
	
MapSpr_CollapsePlatform3:
	include	"Level/Palmtree Panic/Objects/Collapsing Platform/Data/Mappings (Pieces 1, Past).asm"
	even
MapSpr_CollapsePlatform2:
	include	"Level/Palmtree Panic/Objects/Collapsing Platform/Data/Mappings (Past).asm"
	even

ObjCollapsePlatform_Sizes2:
	dc.w	byte_20C790-ObjCollapsePlatform_Sizes2
	dc.w	byte_20C790-ObjCollapsePlatform_Sizes2
	dc.w	byte_20C798-ObjCollapsePlatform_Sizes2
	dc.w	byte_20C79E-ObjCollapsePlatform_Sizes2
	dc.w	byte_20C7A4-ObjCollapsePlatform_Sizes2
	dc.w	byte_20C7A8-ObjCollapsePlatform_Sizes2
byte_20C790:
	dc.b	5, 1
	dc.b	0, 0
	dc.b	0, 0
	dc.b	0, 0
byte_20C798:
	dc.b	8, 3
	dc.b	1, 3
	dc.b	3, 3
	dc.b	3, 3
	dc.b	3, 3
	dc.b	2
byte_20C79E:
	dc.b	4, 2
	dc.b	4, 6
	dc.b	6, 6
	dc.b	6
byte_20C7A4:
	dc.b	4, 2
	dc.b	6, 6
	dc.b	6, 6
	dc.b	5
byte_20C7A8:
	dc.b	9, 3
	dc.b	1, 3
	dc.b	3, 3
	dc.b	3, 3
	dc.b	3, 3
	dc.b	3, 2
	dc.b	0
	even
	
MapSpr_CollapsePlatform4:
	include	"Level/Palmtree Panic/Objects/Collapsing Platform/Data/Mappings (Pieces 2, Past).asm"
	even

; -------------------------------------------------------------------------
