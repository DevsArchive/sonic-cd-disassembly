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
	dc.b	$C8, 8, 0, $6C, $E8
	dc.b	$C8, 8, 8, $6C, 0
	dc.b	$D0, $F, 0, $6F, $E0
	dc.b	$D0, $F, 8, $6F, 0
	dc.b	$F0, $C, 0, $7F, $E0
	dc.b	$F0, $C, 8, $7F, 0
	dc.b	$F8, 8, 0, $83, $E8
	dc.b	$F8, 8, 8, $83, 0
	even
	
.Dist1_0:
	dc.b	5, 0, 0, 0, 0
	dc.b	$D0, 8, 0, $86, $E8
	dc.b	$D0, 8, 8, $86, 0
	dc.b	$D8, $E, 0, $89, $E0
	dc.b	$D8, $E, 8, $89, 0
	dc.b	$F0, 9, 0, $95, $E8
	dc.b	$F0, 9, 8, $95, 0
	even
	
.Dist2_0:
	dc.b	3, 0, 0, 0, 0
	dc.b	$D8, $B, 0, $9B, $E8
	dc.b	$D8, $B, 8, $9B, 0
	dc.b	$F8, 4, 0, $A7, $F0
	dc.b	$F8, 4, 8, $A7, 0
	even
	
.Dist3_0:
	dc.b	5, 0, 0, 0, 0
	dc.b	$D8, 4, 0, $3D, $F0
	dc.b	$D8, 4, 8, $3D, 0
	dc.b	$E0, $A, 0, $A9, $E8
	dc.b	$E0, $A, 8, $A9, 0
	dc.b	$F8, 4, 0, $B2, $F0
	dc.b	$F8, 4, 8, $B2, 0
	even
	
.Dist4_0:
	dc.b	3, 0, 0, 0, 0
	dc.b	$E0, $A, 0, $B4, $E8
	dc.b	$E0, $A, 8, $B4, 0
	dc.b	$F8, 4, 0, $BD, $F0
	dc.b	$F8, 4, 8, $BD, 0
	even
	
.Dist5_0:
	dc.b	1, 0, 0, 0, 0
	dc.b	$E0, 7, 0, $BF, $F0
	dc.b	$E0, 7, 8, $BF, 0
	even
	
.Dist6_0:
	dc.b	2, 0, 0, 0, 0
	dc.b	$E8, 2, 0, $C7, $F4
	dc.b	$E8, 2, 0, $CA, $FC
	dc.b	$E8, 2, 8, $C7, 4
	even
	
.Dist7_0:
	dc.b	2, 0, 0, 0, 0
	dc.b	$F0, 1, 0, $CD, $F4
	dc.b	$F0, 1, 0, $CF, $FC
	dc.b	$F0, 1, 8, $CD, 4
	even
	
.Dist8_0:
	dc.b	0, 0, 0, 0, 0
	dc.b	$F0, 5, 0, $D1, $F8
	even
	
.Dist9_0:
	dc.b	0, 0, 0, 0, 0
	dc.b	$F8, 0, 0, $D5, $FC
	even
	