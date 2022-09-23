MapSpr_Flicky:
	dc.w	2
	dc.w	3, MapFrm_Flicky0-MapSpr_Flicky
	dc.w	3, MapFrm_Flicky1-MapSpr_Flicky
	
MapSpr_FlickySlow:
	dc.w	2
	dc.w	8, MapFrm_Flicky0-MapSpr_FlickySlow
	dc.w	8, MapFrm_Flicky1-MapSpr_FlickySlow
	
MapSpr_FlickyCatchUp:
	dc.w	2
	dc.w	1, MapFrm_Flicky0-MapSpr_FlickyCatchUp
	dc.w	1, MapFrm_Flicky1-MapSpr_FlickyCatchUp
	
MapSpr_FlickyGlide:
	dc.w	1
	dc.w	0, MapFrm_Flicky0-MapSpr_FlickyGlide
	
MapFrm_Flicky0:
	dc.w	1-1
	dc.w	$500, 0, 8, -8, 8, -8
	
MapFrm_Flicky1:
	dc.w	1-1
	dc.w	$500, 4, 8, -8, 8, -8
	