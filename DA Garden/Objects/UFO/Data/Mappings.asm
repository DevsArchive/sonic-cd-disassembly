MapSpr_UFO:
	dc.w	4
	dc.w	9, MapFrm_UFO0-MapSpr_UFO
	dc.w	9, MapFrm_UFO1-MapSpr_UFO
	dc.w	9, MapFrm_UFO0-MapSpr_UFO
	dc.w	9, MapFrm_UFO3-MapSpr_UFO
	
MapSpr_UFODown:
	dc.w	1
	dc.w	0, MapFrm_UFO1-MapSpr_UFODown
	
MapSpr_UFOUp:
	dc.w	1
	dc.w	0, MapFrm_UFO3-MapSpr_UFOUp
	
MapFrm_UFO0:
	dc.w	1-1
	dc.w	$A00, 1, $C, -$C, $C, -$C
	
MapFrm_UFO1:
	dc.w	1-1
	dc.w	$A00, $A, $C, -$C, $C, -$C
	
MapFrm_UFO3:
	dc.w	1-1
	dc.w	$A00, $13, $C, -$C, $C, -$C
