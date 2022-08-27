	dc.l	.Explosion

.Explosion:
	dc.b	5, 2
	dc.l	.Explosion0
	dc.l	.Explosion1
	dc.l	.Explosion2
	dc.l	.Explosion3
	dc.l	.Explosion4

.Explosion0:
	dc.b	1, 0, 0, 0, 0
	dc.b	$F8, 1, 0, 0, $F8
	dc.b	$F8, 1, 8, 0, 0
	even

.Explosion1:
	dc.b	2, 0, 0, 0, 0
	dc.b	$F0, $D, 0, 2, $F0
	dc.b	0, 5, 0, $A, $F0
	dc.b	0, 5, 8, $A, 0
	even

.Explosion2:
	dc.b	3, 0, 0, 0, 0
	dc.b	$F0, 5, 0, $E, $F0
	dc.b	$F0, 5, 0, $12, 0
	dc.b	0, 5, 0, $16, $F0
	dc.b	0, 5, $18, $E, 0
	even

.Explosion3:
	dc.b	5, 0, 0, 0, 0
	dc.b	$E8, 6, 0, $1A, $EC
	dc.b	$E8, 2, 0, $20, $FC
	dc.b	$E8, 6, 8, $1A, 4
	dc.b	0, 6, $10, $1A, $EC
	dc.b	0, 2, $18, $20, $FC
	dc.b	0, 6, $18, $1A, 4
	even

.Explosion4:
	dc.b	5, 0, 0, 0, 0
	dc.b	$E8, 6, 0, $23, $EC
	dc.b	$E8, 2, 0, $29, $FC
	dc.b	$E8, 6, 8, $23, 4
	dc.b	0, 6, $10, $23, $EC
	dc.b	0, 2, $18, $29, $FC
	dc.b	0, 6, $18, $23, 4
	even