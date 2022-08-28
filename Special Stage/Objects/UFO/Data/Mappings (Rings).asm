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
	dc.b	7, 0, 0, 0, 0
	dc.b	$C8, 8, 0, 0, $E8
	dc.b	$C8, 8, 8, 0, 0
	dc.b	$D0, $F, 0, 3, $E0
	dc.b	$D0, $F, 8, 3, 0
	dc.b	$F0, $C, 0, $13, $E0
	dc.b	$F0, $C, 8, $13, 0
	dc.b	$F8, 8, 0, $17, $E8
	dc.b	$F8, 8, 8, $17, 0
	even
	
.Dist1_0:
	dc.b	5, 0, 0, 0, 0
	dc.b	$D0, 8, 0, $1A, $E8
	dc.b	$D0, 8, 8, $1A, 0
	dc.b	$D8, $E, 0, $1D, $E0
	dc.b	$D8, $E, 8, $1D, 0
	dc.b	$F0, 9, 0, $29, $E8
	dc.b	$F0, 9, 8, $29, 0
	even
	
.Dist2_0:
	dc.b	3, 0, 0, 0, 0
	dc.b	$D8, $B, 0, $2F, $E8
	dc.b	$D8, $B, 8, $2F, 0
	dc.b	$F8, 4, 0, $3B, $F0
	dc.b	$F8, 4, 8, $3B, 0
	even
	
.Dist3_0:
	dc.b	5, 0, 0, 0, 0
	dc.b	$D8, 4, 0, $3D, $F0
	dc.b	$D8, 4, 8, $3D, 0
	dc.b	$E0, $A, 0, $3F, $E8
	dc.b	$E0, $A, 8, $3F, 0
	dc.b	$F8, 4, 0, $48, $F0
	dc.b	$F8, 4, 8, $48, 0
	even
	
.Dist4_0:
	dc.b	3, 0, 0, 0, 0
	dc.b	$E0, $A, 0, $4A, $E8
	dc.b	$E0, $A, 8, $4A, 0
	dc.b	$F8, 4, 0, $53, $F0
	dc.b	$F8, 4, 8, $53, 0
	even
	
.Dist5_0:
	dc.b	1, 0, 0, 0, 0
	dc.b	$E0, 7, 0, $55, $F0
	dc.b	$E0, 7, 8, $55, 0
	even
	
.Dist6_0:
	dc.b	2, 0, 0, 0, 0
	dc.b	$E8, 2, 0, $5D, $F4
	dc.b	$E8, 2, 0, $60, $FC
	dc.b	$E8, 2, 8, $5D, 4
	even
	
.Dist7_0:
	dc.b	2, 0, 0, 0, 0
	dc.b	$F0, 1, 0, $63, $F4
	dc.b	$F0, 1, 0, $65, $FC
	dc.b	$F0, 1, 8, $63, 4
	even
	
.Dist8_0:
	dc.b	0, 0, 0, 0, 0
	dc.b	$F0, 5, 0, $67, $F8
	even
	
.Dist9_0:
	dc.b	0, 0, 0, 0, 0
	dc.b	$F8, 0, 0, $6B, $FC
	even
	