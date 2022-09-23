.Map:
	dc.w	8
	dc.w	1, .Frame0-.Map
	dc.w	1, .Frame1-.Map
	dc.w	1, .Frame2-.Map
	dc.w	1, .Frame1-.Map
	dc.w	1, .Frame4-.Map
	dc.w	1, .Frame1-.Map
	dc.w	1, .Frame6-.Map
	dc.w	1, .Frame1-.Map
	
.Frame1:
	dc.w	4-1
	dc.w	$D00, $B, $14, $C, $14, $14
	dc.w	$100, 9, -$C, $14, $14, $14
	dc.w	$E00, $13, $14, $C, 4, 4
	dc.w	$600, $1F, -$C, $1C, 4, 4
	
.Frame0:
	dc.w	5-1
	dc.w	$D00, $B, $14, $C, $14, $14
	dc.w	$100, 9, -$C, $14, $14, $14
	dc.w	$E00, $13, $14, $C, 4, 4
	dc.w	$600, $1F, -$C, $1C, 4, 4
	dc.w	$A00, $25, -9, $25, -3, -3
	
.Frame2:
	dc.w	5-1
	dc.w	$D00, $B, $14, $C, $14, $14
	dc.w	$100, 9, -$C, $14, $14, $14
	dc.w	$E00, $13, $14, $C, 4, 4
	dc.w	$600, $1F, -$C, $1C, 4, 4
	dc.w	$A00, $2E, -9, $25, -3, -3
	
.Frame4:
	dc.w	5-1
	dc.w	$D00, $B, $14, $C, $14, $14
	dc.w	$100, 9, -$C, $14, $14, $14
	dc.w	$E00, $13, $14, $C, 4, 4
	dc.w	$600, $1F, -$C, $1C, 4, 4
	dc.w	$A00, $1825, -9, $25, -3, -3
	
.Frame6:
	dc.w	5-1
	dc.w	$D00, $B, $14, $C, $14, $14
	dc.w	$100, 9, -$C, $14, $14, $14
	dc.w	$E00, $13, $14, $C, 4, 4
	dc.w	$600, $1F, -$C, $1C, 4, 4
	dc.w	$A00, $182E, -9, $25, -3, -3
	