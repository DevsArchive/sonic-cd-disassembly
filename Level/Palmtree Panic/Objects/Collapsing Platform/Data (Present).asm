; -------------------------------------------------------------------------
; Sonic CD Disassembly
; By Ralakimus 2021
; -------------------------------------------------------------------------
; Palmtree Panic Present collapsing platform object data
; -------------------------------------------------------------------------

MapSpr_CollapsePlatform1:
	include	"Level/Palmtree Panic/Objects/Collapsing Platform/Data/Mappings (Ledge, Present).asm"
	even

ObjCollapsePlatform_Sizes1:
	dc.w	byte_20C598-ObjCollapsePlatform_Sizes1
byte_20C598:
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
	
MapSpr_CollapsePlatform3:
	include	"Level/Palmtree Panic/Objects/Collapsing Platform/Data/Mappings (Pieces 1, Present).asm"
	even
MapSpr_CollapsePlatform2:
	include	"Level/Palmtree Panic/Objects/Collapsing Platform/Data/Mappings (Present).asm"
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
	dc.b	3, 3
	dc.b	1, 2
	dc.b	2, 2
byte_20C79E:
	dc.b	3, 3
	dc.b	2, 2
	dc.b	2, 2
byte_20C7A4:
	dc.b	1, 3
	dc.b	3, 5
byte_20C7A8:
	dc.b	1, 3
	dc.b	5, 4
	even
	
MapSpr_CollapsePlatform4:
	include	"Level/Palmtree Panic/Objects/Collapsing Platform/Data/Mappings (Pieces 2, Present).asm"
	even

; -------------------------------------------------------------------------
