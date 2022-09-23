.Map:
	dc.w	6
	dc.w	1, .Frame0-.Map
	dc.w	2, .Frame1-.Map
	dc.w	3, .Frame2-.Map
	dc.w	4, .Frame3-.Map
	dc.w	3, .Frame4-.Map
	dc.w	2, .Frame5-.Map
	
.Frame0:
	dc.w	1-1
	dc.w	$A00, 0, $C, -$C, $C, -$C
	
.Frame1:
	dc.w	1-1
	dc.w	$A00, 9, $C, -$C, $C, -$C
	
.Frame2:
	dc.w	1-1
	dc.w	$A00, $12, $C, -$C, $C, -$C
	
.Frame3:
	dc.w	1-1
	dc.w	$200, $1B, 4, -4, $C, -$C
	
.Frame4:
	dc.w	1-1
	dc.w	$A00, $812, $C, -$C, $C, -$C
	
.Frame5:
	dc.w	1-1
	dc.w	$A00, $809, $C, -$C, $C, -$C
	