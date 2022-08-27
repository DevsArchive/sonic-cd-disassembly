	dc.l	.Text

.Text:
	dc.b	1, $FF
	dc.l	.Text0

.Text0:
	dc.b	$E, 0, 0, 0, 0
	dc.b	$C8, 4, 0, 0, $B8
	dc.b	$D0, 0, 0, 2, $B8
	dc.b	$D8, 5, 0, 3, $B8
	dc.b	$E8, $F, 0, 7, $B8
	dc.b	$E8, $B, 0, $17, $D8
	dc.b	$E8, $A, 0, $23, $F0
	dc.b	0, 6, 0, $26, $F8
	dc.b	$28, 5, 0, $2C, $B8
	dc.b	8, 0, 0, 2, $B8
	dc.b	8, $F, 0, $30, $D0
	dc.b	8, 0, 0, $40, $C8
	dc.b	$10, $A, 0, $41, $B8
	dc.b	$18, $D, 0, $4A, $F0
	dc.b	$18, $D, 0, $52, $10
	dc.b	$18, 9, 0, $5A, $30
	even
	