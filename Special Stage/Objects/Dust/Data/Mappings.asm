	dc.l	.Dust
	
.Dust:
	dc.b	3
	dc.b	1
	dc.l	.Dust0
	dc.l	.Dust1
	dc.l	.Dust2
	
.Dust2:
	dc.b	0, 0, 0, 0, 0
	dc.b	$FC, 0, 0, $2C, $FC
	even
	
.Dust1:
	dc.b	0, 0, 0, 0, 0
	dc.b	$FC, 0, 0, $2D, $FC
	even
	
.Dust0:
	dc.b	0, 0, 0, 0, 0
	dc.b	$FC, 0, 0, $2E, $FC
	even
	