	dc.l	.Sonic
	
.Sonic:
	dc.b	5, 2
	dc.l	.Sonic0
	dc.l	.Sonic1
	dc.l	.Sonic2
	dc.l	.Sonic3
	dc.l	.Sonic4
	
.Sonic0:
	dc.b	3
	dc.b	$E8, 5, 0, $13, $F8
	dc.b	$F8, 5, 0, $17, $F0
	dc.b	$F8, 5, 0, $1B, 0
	dc.b	8, 5, 0, $1F, $F8
	even
	
.Sonic1:
	dc.b	1
	dc.b	$E8, $B, 0, $23, $F0
	dc.b	8, 5, 0, $2F, $F8
	even
	
.Sonic2:
	dc.b	3
	dc.b	$E8, 4, 0, $33, $F8
	dc.b	$F0, 9, 0, $35, $F0
	dc.b	0, $D, 0, $3B, $F0
	dc.b	$10, 8, 0, $43, $F0
	even
	
.Sonic3:
	dc.b	3
	dc.b	$E8, 4, 8, $33, $F8
	dc.b	$F0, 9, 8, $35, $F8
	dc.b	0, $D, 8, $3B, $F0
	dc.b	$10, 8, 8, $43, $F8
	even
	
.Sonic4:
	dc.b	1
	dc.b	$E8, $B, 8, $23, $F8
	dc.b	8, 5, 8, $2F, $F8
	even
	