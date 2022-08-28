	dc.l	.Dist0
	dc.l	.Dist1
	dc.l	.Dist2
	dc.l	.Dist3
	dc.l	.Dist4
	dc.l	.Dist5
	dc.l	.Dist6
	dc.l	.Dist7
	dc.l	.Dist8
	dc.l	.Dist9
	
.Dist0:
	dc.b	1, $FF
	dc.l	.Dist0_0
	
.Dist1:
	dc.b	1, $FF
	dc.l	.Dist1_0
	
.Dist2:
	dc.b	1, $FF
	dc.l	.Dist2_0
	
.Dist3:
	dc.b	1, $FF
	dc.l	.Dist3_0
	
.Dist4:
	dc.b	1, $FF
	dc.l	.Dist4_0
	
.Dist5:
	dc.b	1, $FF
	dc.l	.Dist5_0
	
.Dist6:
	dc.b	1, $FF
	dc.l	.Dist6_0
	
.Dist7:
	dc.b	1, $FF
	dc.l	.Dist7_0
	
.Dist8:
	dc.b	1, $FF
	dc.l	.Dist8_0
	
.Dist9:
	dc.b	1, $FF
	dc.l	.Dist9_0
	
.Dist0_0:
	dc.b	1, 0, 0, 0, 0
	dc.b	$F8, $D, 0, 0, $E0
	dc.b	$F8, $D, 8, 0, 0
	even
	
.Dist1_0:
	dc.b	2, 0, 0, 0, 0
	dc.b	$F8, 9, 0, 8, $E4
	dc.b	$F8, 1, 0, $E, $FC
	dc.b	$F8, 9, 8, 8, 4
	even
	
.Dist2_0:
	dc.b	1, 0, 0, 0, 0
	dc.b	$FC, 8, 0, $10, $E8
	dc.b	$FC, 8, 8, $10, 0
	even
	
.Dist3_0:
	dc.b	1, 0, 0, 0, 0
	dc.b	$FC, 8, 0, $13, $E8
	dc.b	$FC, 8, 8, $13, 0
	even
	
.Dist4_0:
	dc.b	2, 0, 0, 0, 0
	dc.b	$FC, 4, 0, $16, $EC
	dc.b	$FC, 4, 8, $16, 4
	dc.b	$FC, 0, 0, $18, $FC
	even
	
.Dist5_0:
	dc.b	1, 0, 0, 0, 0
	dc.b	$FC, 4, 0, $19, $F0
	dc.b	$FC, 4, 8, $19, 0
	even
	
.Dist6_0:
	dc.b	0, 0, 0, 0, 0
	dc.b	$FC, 8, 0, $1B, $F4
	even
	
.Dist7_0:
	dc.b	0, 0, 0, 0, 0
	dc.b	$FC, 8, 0, $1E, $F4
	even
	
.Dist8_0:
	dc.b	0, 0, 0, 0, 0
	dc.b	$FC, 4, 0, $21, $F8
	even
	
.Dist9_0:
	dc.b	0, 0, 0, 0, 0
	dc.b	$FC, 0, 0, $23, $FC
	even
	