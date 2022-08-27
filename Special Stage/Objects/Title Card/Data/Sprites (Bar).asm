	dc.l	.Bar

.Bar:
	dc.b	1, $FF
	dc.l	.Bar0

.Bar0:
	dc.b	5, 0, 0, 0, 0
	dc.b	$90, $B, 0, $60, $F4
	dc.b	$B0, $B, 0, $60, $F4
	dc.b	$D0, $B, 0, $60, $F4
	dc.b	$F0, $B, 0, $60, $F4
	dc.b	$10, $B, 0, $60, $F4
	dc.b	$20, $B, 0, $60, $F4
	even
	