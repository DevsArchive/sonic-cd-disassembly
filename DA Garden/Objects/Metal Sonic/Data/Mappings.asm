MapSpr_MetalSonic:
	dc.w	3
	dc.w	1, MapFrm_MetalSonic0-MapSpr_MetalSonic
	dc.w	1, MapFrm_MetalSonic1-MapSpr_MetalSonic
	dc.w	2, MapFrm_MetalSonic2-MapSpr_MetalSonic
	
MapSpr_MetalSonicBackUp:
	dc.w	3
	dc.w	1, MapFrm_MetalSonic0-MapSpr_MetalSonicBackUp
	dc.w	1, MapFrm_MetalSonic1-MapSpr_MetalSonicBackUp
	dc.w	1, MapFrm_MetalSonic2-MapSpr_MetalSonicBackUp
	
MapFrm_MetalSonic0:
	dc.w	3-1
	dc.w	$F00, $13, $10, $10, $18, $18
	dc.w	$D00, $23, $10, $10, -8, -8
	dc.w	$A00, 1, $1C, -5, $C, -$C
	
MapFrm_MetalSonic1:
	dc.w	3-1
	dc.w	$F00, $13, $10, $10, $18, $18
	dc.w	$D00, $23, $10, $10, -8, -8
	dc.w	$A00, $1001, $1C, -5, $C, -$C
	
MapFrm_MetalSonic2:
	dc.w	2-1
	dc.w	$F00, $13, $10, $10, $18, $18
	dc.w	$D00, $23, $10, $10, -8, -8
	